import { Request, Response } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import bcrypt from 'bcrypt';
import { ValidationError } from '@galeri/shared/utils/errors';
import { validatePassword, validateEmail } from '@galeri/shared/utils/validation';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
    role: string;
  };
}

export class UserController {
  async getMe(req: AuthenticatedRequest, res: Response) {
    const userId = req.user?.sub;

    const result = await query(
      `SELECT u.id, u.email, u.first_name, u.last_name, u.avatar_url, u.role, u.gallery_id,
              g.name as gallery_name, g.status as gallery_status
       FROM users u
       LEFT JOIN galleries g ON u.gallery_id = g.id
       WHERE u.id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('User not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async updateMe(req: AuthenticatedRequest, res: Response) {
    const userId = req.user?.sub;
    const { firstName, lastName, email, avatarUrl } = req.body;

    if (email && !validateEmail(email)) {
      throw new ValidationError('Invalid email format');
    }

    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (firstName) {
      updates.push(`first_name = $${paramCount++}`);
      values.push(firstName);
    }
    if (lastName) {
      updates.push(`last_name = $${paramCount++}`);
      values.push(lastName);
    }
    if (email) {
      updates.push(`email = $${paramCount++}, email_verified = FALSE`);
      values.push(email);
    }
    if (avatarUrl) {
      updates.push(`avatar_url = $${paramCount++}`);
      values.push(avatarUrl);
    }

    if (updates.length === 0) {
      throw new ValidationError('No fields to update');
    }

    updates.push(`updated_at = NOW()`);
    values.push(userId);

    await query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}`,
      values
    );

    res.json({
      success: true,
      message: 'Profile updated successfully'
    });
  }

  async changePassword(req: AuthenticatedRequest, res: Response) {
    const userId = req.user?.sub;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      throw new ValidationError('Current password and new password are required');
    }

    const passwordValidation = validatePassword(newPassword);
    if (!passwordValidation.valid) {
      throw new ValidationError(passwordValidation.errors.join(', '));
    }

    // Get current password hash
    const result = await query('SELECT password_hash FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) {
      throw new ValidationError('User not found');
    }

    // Verify current password
    const passwordValid = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
    if (!passwordValid) {
      throw new ValidationError('Current password is incorrect');
    }

    // Update password
    const newPasswordHash = await bcrypt.hash(newPassword, 12);
    await query(
      'UPDATE users SET password_hash = $1, password_changed_at = NOW() WHERE id = $2',
      [newPasswordHash, userId]
    );

    res.json({
      success: true,
      message: 'Password changed successfully'
    });
  }

  async getSessions(req: AuthenticatedRequest, res: Response) {
    // TODO: Implement session tracking
    res.json({
      success: true,
      data: []
    });
  }

  async deleteSession(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    // TODO: Implement session deletion
    res.json({
      success: true,
      message: 'Session deleted'
    });
  }
}
















