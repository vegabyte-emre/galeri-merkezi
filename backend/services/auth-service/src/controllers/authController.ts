import { Request, Response } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import Redis from 'ioredis';
import { config } from '@galeri/shared/config';
import { logger } from '@galeri/shared/utils/logger';
import { ValidationError, UnauthorizedError, ConflictError } from '@galeri/shared/utils/errors';
import { validatePhone, validateEmail, validatePassword, validateTCKN, validateVKN } from '@galeri/shared/utils/validation';

const redis = new Redis({
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password
});

export class AuthController {
  // Step 1: Start registration with phone
  async startRegistration(req: Request, res: Response) {
    const { phone } = req.body;

    if (!phone || !validatePhone(phone)) {
      throw new ValidationError('Invalid phone number format. Must be +90XXXXXXXXXX');
    }

    // Check if phone already exists
    const existing = await query('SELECT id FROM users WHERE phone = $1', [phone]);
    if (existing.rows.length > 0) {
      throw new ConflictError('Phone number already registered');
    }

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpKey = `otp:${phone}`;
    const attemptsKey = `otp:attempts:${phone}`;

    // Check daily limit
    const dailyCount = await redis.get(`otp:daily:${phone}`);
    if (dailyCount && parseInt(dailyCount) >= 5) {
      throw new ValidationError('Daily OTP limit reached. Please try again tomorrow.');
    }

    // Store OTP in Redis (3 minutes expiry)
    await redis.setex(otpKey, 180, otp);
    await redis.setex(attemptsKey, 180, '0');
    await redis.incr(`otp:daily:${phone}`);
    await redis.expire(`otp:daily:${phone}`, 86400); // 24 hours

    // TODO: Send SMS via notification worker
    logger.info('OTP generated', { phone, otp: '***' });

    res.json({
      success: true,
      message: 'OTP sent to your phone',
      expiresIn: 180
    });
  }

  // Step 2: Verify phone OTP
  async verifyPhone(req: Request, res: Response) {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      throw new ValidationError('Phone and OTP are required');
    }

    const otpKey = `otp:${phone}`;
    const attemptsKey = `otp:attempts:${phone}`;
    const storedOTP = await redis.get(otpKey);
    const attempts = parseInt(await redis.get(attemptsKey) || '0');

    if (attempts >= 3) {
      throw new ValidationError('Maximum OTP attempts reached. Please request a new OTP.');
    }

    if (!storedOTP || storedOTP !== otp) {
      await redis.incr(attemptsKey);
      await redis.expire(attemptsKey, 30); // 30 seconds wait after wrong attempt
      throw new ValidationError('Invalid OTP');
    }

    // Mark phone as verified
    await redis.setex(`phone:verified:${phone}`, 3600, 'true'); // 1 hour
    await redis.del(otpKey);
    await redis.del(attemptsKey);

    res.json({
      success: true,
      message: 'Phone verified successfully'
    });
  }

  // Resend OTP
  async resendOTP(req: Request, res: Response) {
    const { phone } = req.body;

    if (!phone || !validatePhone(phone)) {
      throw new ValidationError('Invalid phone number format');
    }

    // Check daily limit
    const dailyCount = await redis.get(`otp:daily:${phone}`);
    if (dailyCount && parseInt(dailyCount) >= 5) {
      throw new ValidationError('Daily OTP limit reached');
    }

    // Generate new OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpKey = `otp:${phone}`;

    await redis.setex(otpKey, 180, otp);
    await redis.incr(`otp:daily:${phone}`);
    await redis.expire(`otp:daily:${phone}`, 86400);

    // TODO: Send SMS
    logger.info('OTP resent', { phone, otp: '***' });

    res.json({
      success: true,
      message: 'OTP resent successfully'
    });
  }

  // Step 3-6: Complete registration
  async completeRegistration(req: Request, res: Response) {
    const {
      phone,
      firstName,
      lastName,
      email,
      password,
      taxType,
      taxNumber,
      authorityDocumentNo,
      galleryName,
      city,
      district,
      neighborhood,
      address
    } = req.body;

    // Verify phone was verified
    const phoneVerified = await redis.get(`phone:verified:${phone}`);
    if (!phoneVerified) {
      throw new ValidationError('Phone must be verified first');
    }

    // Validate inputs
    if (!email || !validateEmail(email)) {
      throw new ValidationError('Invalid email format');
    }

    const passwordValidation = validatePassword(password);
    if (!passwordValidation.valid) {
      throw new ValidationError(passwordValidation.errors.join(', '));
    }

    if (taxType === 'TCKN' && (!taxNumber || !validateTCKN(taxNumber))) {
      throw new ValidationError('Invalid TCKN');
    }
    if (taxType === 'VKN' && (!taxNumber || !validateVKN(taxNumber))) {
      throw new ValidationError('Invalid VKN');
    }

    // Check if email exists
    const emailExists = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (emailExists.rows.length > 0) {
      throw new ConflictError('Email already registered');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Create user and gallery in transaction
    const client = await getClient();
    try {
      await client.query('BEGIN');

      // Create gallery
      const galleryResult = await client.query(`
        INSERT INTO galleries (
          name, slug, tax_type, tax_number, authority_document_no,
          phone, email, city, district, neighborhood, address, status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'pending')
        RETURNING id
      `, [
        galleryName,
        galleryName.toLowerCase().replace(/\s+/g, '-'),
        taxType,
        taxNumber,
        authorityDocumentNo,
        phone,
        email,
        city,
        district,
        neighborhood,
        address
      ]);

      const galleryId = galleryResult.rows[0].id;

      // Create user
      const userResult = await client.query(`
        INSERT INTO users (
          gallery_id, phone, phone_verified, phone_verified_at,
          email, email_verified, password_hash,
          first_name, last_name, tckn, role, status
        ) VALUES ($1, $2, TRUE, NOW(), $3, FALSE, $4, $5, $6, $7, 'gallery_owner', 'active')
        RETURNING id
      `, [
        galleryId,
        phone,
        email,
        passwordHash,
        firstName,
        lastName,
        taxType === 'TCKN' ? taxNumber : null
      ]);

      await client.query('COMMIT');

      // Clear phone verification
      await redis.del(`phone:verified:${phone}`);

      res.json({
        success: true,
        message: 'Registration completed. Waiting for admin approval.',
        userId: userResult.rows[0].id,
        galleryId
      });
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Login
  async login(req: Request, res: Response) {
    const { phone, email, password } = req.body;

    if ((!phone && !email) || !password) {
      throw new ValidationError('Phone/email and password are required');
    }

    // Find user
    const userResult = await query(
      'SELECT u.*, g.status as gallery_status FROM users u LEFT JOIN galleries g ON u.gallery_id = g.id WHERE u.phone = $1 OR u.email = $1',
      [phone || email]
    );

    if (userResult.rows.length === 0) {
      throw new UnauthorizedError('Invalid credentials');
    }

    const user = userResult.rows[0];

    // Check if gallery is active (for gallery users)
    if (user.gallery_id && user.gallery_status !== 'active') {
      throw new UnauthorizedError('Gallery is not active');
    }

    // Check if user is active
    if (user.status !== 'active') {
      throw new UnauthorizedError('Account is suspended');
    }

    // Check if locked
    if (user.locked_until && new Date(user.locked_until) > new Date()) {
      throw new UnauthorizedError('Account is temporarily locked');
    }

    // Verify password
    const passwordValid = await bcrypt.compare(password, user.password_hash);
    if (!passwordValid) {
      // Increment failed login count
      const failedCount = (user.failed_login_count || 0) + 1;
      if (failedCount >= 10) {
        await query(
          'UPDATE users SET failed_login_count = $1, locked_until = NOW() + INTERVAL \'30 minutes\' WHERE id = $2',
          [failedCount, user.id]
        );
        throw new UnauthorizedError('Too many failed attempts. Account locked for 30 minutes.');
      }
      await query('UPDATE users SET failed_login_count = $1 WHERE id = $2', [failedCount, user.id]);
      throw new UnauthorizedError('Invalid credentials');
    }

    // Reset failed login count
    await query('UPDATE users SET failed_login_count = 0, last_login = NOW() WHERE id = $1', [user.id]);

    // Generate tokens
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    // Store refresh token in Redis
    await redis.setex(`refresh:${user.id}:${refreshToken}`, 7 * 24 * 60 * 60, 'true');

    res.json({
      success: true,
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role,
        galleryId: user.gallery_id
      }
    });
  }

  // Logout
  async logout(req: Request, res: Response) {
    const { refreshToken } = req.body;
    const userId = (req as any).user?.sub;

    if (refreshToken && userId) {
      await redis.del(`refresh:${userId}:${refreshToken}`);
    }

    res.json({ success: true, message: 'Logged out successfully' });
  }

  // Refresh token
  async refreshToken(req: Request, res: Response) {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new ValidationError('Refresh token is required');
    }

    try {
      const decoded = jwt.verify(refreshToken, config.jwt.secret) as any;
      const tokenKey = `refresh:${decoded.sub}:${refreshToken}`;
      const exists = await redis.get(tokenKey);

      if (!exists) {
        throw new UnauthorizedError('Invalid refresh token');
      }

      // Get user
      const userResult = await query('SELECT * FROM users WHERE id = $1', [decoded.sub]);
      if (userResult.rows.length === 0) {
        throw new UnauthorizedError('User not found');
      }

      const user = userResult.rows[0];

      // Generate new tokens
      const newAccessToken = this.generateAccessToken(user);
      const newRefreshToken = this.generateRefreshToken(user);

      // Delete old refresh token and store new one
      await redis.del(tokenKey);
      await redis.setex(`refresh:${user.id}:${newRefreshToken}`, 7 * 24 * 60 * 60, 'true');

      res.json({
        success: true,
        accessToken: newAccessToken,
        refreshToken: newRefreshToken
      });
    } catch (error) {
      throw new UnauthorizedError('Invalid refresh token');
    }
  }

  // Forgot password
  async forgotPassword(req: Request, res: Response) {
    const { email } = req.body;

    if (!email || !validateEmail(email)) {
      throw new ValidationError('Valid email is required');
    }

    // Find user
    const userResult = await query('SELECT id, email FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      // Don't reveal if email exists
      return res.json({ success: true, message: 'If email exists, reset link has been sent' });
    }

    const user = userResult.rows[0];
    const resetToken = uuidv4();
    const resetKey = `reset:${resetToken}`;

    // Store reset token (1 hour expiry)
    await redis.setex(resetKey, 3600, user.id);

    // TODO: Send email via notification worker
    logger.info('Password reset token generated', { userId: user.id, token: '***' });

    res.json({
      success: true,
      message: 'If email exists, reset link has been sent'
    });
  }

  // Reset password
  async resetPassword(req: Request, res: Response) {
    const { token, password } = req.body;

    if (!token || !password) {
      throw new ValidationError('Token and password are required');
    }

    const resetKey = `reset:${token}`;
    const userId = await redis.get(resetKey);

    if (!userId) {
      throw new ValidationError('Invalid or expired reset token');
    }

    const passwordValidation = validatePassword(password);
    if (!passwordValidation.valid) {
      throw new ValidationError(passwordValidation.errors.join(', '));
    }

    // Update password
    const passwordHash = await bcrypt.hash(password, 12);
    await query(
      'UPDATE users SET password_hash = $1, password_changed_at = NOW() WHERE id = $2',
      [passwordHash, userId]
    );

    // Delete reset token
    await redis.del(resetKey);

    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  }

  private generateAccessToken(user: any): string {
    const payload = {
      sub: user.id,
      gallery_id: user.gallery_id,
      role: user.role,
      permissions: [], // TODO: Load from database
      jti: uuidv4()
    };
    // @ts-ignore - expiresIn type mismatch with newer jsonwebtoken versions
    return jwt.sign(payload, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
  }

  private generateRefreshToken(user: any): string {
    const payload = {
      sub: user.id,
      jti: uuidv4()
    };
    // @ts-ignore - expiresIn type mismatch with newer jsonwebtoken versions
    return jwt.sign(payload, config.jwt.secret, { expiresIn: config.jwt.refreshExpiresIn });
  }
}

