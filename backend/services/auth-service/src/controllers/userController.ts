import { Request, Response } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import bcrypt from 'bcrypt';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';
import { validatePassword, validateEmail } from '@galeri/shared/utils/validation';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
    role: string;
  };
}

// Helper to get user from headers (set by API Gateway)
const getUserFromHeaders = (req: Request): { sub: string; gallery_id?: string; role: string } => {
  return {
    sub: req.headers['x-user-id'] as string || '',
    gallery_id: req.headers['x-gallery-id'] as string || undefined,
    role: req.headers['x-user-role'] as string || ''
  };
};

export class UserController {
  // ========== ADMIN USER MANAGEMENT ==========
  
  // List all users (superadmin/admin only)
  async listUsers(req: Request, res: Response) {
    const userInfo = getUserFromHeaders(req);
    
    if (userInfo.role !== 'superadmin' && userInfo.role !== 'admin') {
      throw new ForbiddenError('Only admin can list all users');
    }
    
    const { page = 1, limit = 50, search, role, status } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    
    let whereClause = 'WHERE 1=1';
    const params: any[] = [];
    let paramCount = 1;
    
    if (search) {
      whereClause += ` AND (LOWER(first_name || ' ' || last_name) LIKE LOWER($${paramCount}) OR LOWER(email) LIKE LOWER($${paramCount}))`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    if (role) {
      whereClause += ` AND role = $${paramCount}`;
      params.push(role);
      paramCount++;
    }
    
    if (status) {
      whereClause += ` AND status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }
    
    const result = await query(
      `SELECT u.id, u.email, u.first_name, u.last_name, u.role, u.status, u.gallery_id,
              u.created_at, u.last_login,
              g.name as gallery_name
       FROM users u
       LEFT JOIN galleries g ON u.gallery_id = g.id
       ${whereClause}
       ORDER BY u.created_at DESC
       LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );
    
    const countResult = await query(
      `SELECT COUNT(*) as total FROM users u ${whereClause}`,
      params
    );
    
    // Map to frontend format
    const users = result.rows.map(u => ({
      id: u.id,
      name: `${u.first_name || ''} ${u.last_name || ''}`.trim() || u.email,
      email: u.email,
      role: u.role,
      status: u.status,
      gallery: u.gallery_name,
      galleryId: u.gallery_id,
      lastLogin: u.last_login,
      createdAt: u.created_at
    }));
    
    res.json({
      success: true,
      users,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: parseInt(countResult.rows[0].total),
        totalPages: Math.ceil(parseInt(countResult.rows[0].total) / Number(limit))
      }
    });
  }
  
  // Create new user (superadmin/admin only)
  async createUser(req: Request, res: Response) {
    const userInfo = getUserFromHeaders(req);
    
    if (userInfo.role !== 'superadmin' && userInfo.role !== 'admin') {
      throw new ForbiddenError('Only admin can create users');
    }
    
    const { name, email, phone, password, role, galleryId, galleryName, taxType, taxNumber } = req.body;
    
    if (!name || !email || !phone || !password) {
      throw new ValidationError('Name, email, phone and password are required');
    }
    
    if (!validateEmail(email)) {
      throw new ValidationError('Invalid email format');
    }
    
    const passwordValidation = validatePassword(password);
    if (!passwordValidation.valid) {
      throw new ValidationError(passwordValidation.errors.join(', '));
    }
    
    // Check if email already exists
    const existingUser = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
      throw new ValidationError('Email already exists');
    }
    
    // Parse name into first_name and last_name
    const nameParts = name.trim().split(' ');
    const firstName = nameParts[0];
    const lastName = nameParts.slice(1).join(' ') || '';
    
    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);
    
    // Determine gallery_id based on role
    let finalGalleryId = null;
    if (galleryId) {
      // Eğer formda mevcut galeri seçildiyse onu kullan
      finalGalleryId = galleryId;
    } else if (role === 'gallery_owner' && galleryName && taxType && taxNumber) {
      // Galeri sahibi için yeni galeri oluştur (form bilgileriyle)
      const slug = galleryName.toLowerCase()
        .replace(/[^a-z0-9\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .trim() + '-' + Date.now();
      
      const galleryResult = await query(
        `INSERT INTO galleries (name, slug, status, tax_type, tax_number, created_at, updated_at) 
         VALUES ($1, $2, 'pending', $3, $4, NOW(), NOW()) RETURNING id`,
        [galleryName, slug, taxType, taxNumber]
      );
      finalGalleryId = galleryResult.rows[0].id;
    }
    
    // Create user
    const result = await query(
      `INSERT INTO users (email, phone, password_hash, first_name, last_name, role, gallery_id, status, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'active', NOW())
       RETURNING id, email, phone, first_name, last_name, role, gallery_id, status, created_at`,
      [email, phone, passwordHash, firstName, lastName, role || 'gallery_owner', finalGalleryId]
    );
    
    const newUser = result.rows[0];
    
    // Get gallery name if exists
    let createdGalleryName = null;
    if (newUser.gallery_id) {
      const galleryResult = await query('SELECT name FROM galleries WHERE id = $1', [newUser.gallery_id]);
      if (galleryResult.rows.length > 0) {
        createdGalleryName = galleryResult.rows[0].name;
      }
    }
    
    res.status(201).json({
      success: true,
      id: newUser.id,
      name: `${newUser.first_name || ''} ${newUser.last_name || ''}`.trim() || newUser.email,
      email: newUser.email,
      role: newUser.role,
      status: newUser.status,
      gallery: createdGalleryName,
      galleryId: newUser.gallery_id,
      createdAt: newUser.created_at
    });
  }
  
  // Update user (superadmin/admin only)
  async updateUser(req: Request, res: Response) {
    const userInfo = getUserFromHeaders(req);
    
    if (userInfo.role !== 'superadmin' && userInfo.role !== 'admin') {
      throw new ForbiddenError('Only admin can update users');
    }
    
    const { id } = req.params;
    const { name, email, phone, role, status, galleryId, password } = req.body;
    
    // Check if user exists
    const existingUser = await query('SELECT id FROM users WHERE id = $1', [id]);
    if (existingUser.rows.length === 0) {
      throw new ValidationError('User not found');
    }
    
    const updates: string[] = [];
    const values: any[] = [];
    let paramCount = 1;
    
    if (name) {
      const nameParts = name.trim().split(' ');
      const firstName = nameParts[0];
      const lastName = nameParts.slice(1).join(' ') || '';
      updates.push(`first_name = $${paramCount++}`);
      values.push(firstName);
      updates.push(`last_name = $${paramCount++}`);
      values.push(lastName);
    }
    
    if (email) {
      if (!validateEmail(email)) {
        throw new ValidationError('Invalid email format');
      }
      // Check if email is taken by another user
      const emailCheck = await query('SELECT id FROM users WHERE email = $1 AND id != $2', [email, id]);
      if (emailCheck.rows.length > 0) {
        throw new ValidationError('Email already in use');
      }
      updates.push(`email = $${paramCount++}`);
      values.push(email);
    }
    
    if (phone) {
      // Check if phone is taken by another user
      const phoneCheck = await query('SELECT id FROM users WHERE phone = $1 AND id != $2', [phone, id]);
      if (phoneCheck.rows.length > 0) {
        throw new ValidationError('Phone number already in use');
      }
      updates.push(`phone = $${paramCount++}`);
      values.push(phone);
    }
    
    if (role) {
      updates.push(`role = $${paramCount++}`);
      values.push(role);
    }
    
    if (status) {
      updates.push(`status = $${paramCount++}`);
      values.push(status);
    }
    
    if (galleryId !== undefined) {
      updates.push(`gallery_id = $${paramCount++}`);
      values.push(galleryId || null);
    }
    
    if (password) {
      const passwordValidation = validatePassword(password);
      if (!passwordValidation.valid) {
        throw new ValidationError(passwordValidation.errors.join(', '));
      }
      const passwordHash = await bcrypt.hash(password, 12);
      updates.push(`password_hash = $${paramCount++}`);
      values.push(passwordHash);
    }
    
    if (updates.length === 0) {
      throw new ValidationError('No fields to update');
    }
    
    updates.push(`updated_at = NOW()`);
    values.push(id);
    
    const result = await query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}
       RETURNING id, email, first_name, last_name, role, status, gallery_id, created_at`,
      values
    );
    
    const updatedUser = result.rows[0];
    
    // Get gallery name if exists
    let galleryName = null;
    if (updatedUser.gallery_id) {
      const galleryResult = await query('SELECT name FROM galleries WHERE id = $1', [updatedUser.gallery_id]);
      if (galleryResult.rows.length > 0) {
        galleryName = galleryResult.rows[0].name;
      }
    }
    
    res.json({
      success: true,
      id: updatedUser.id,
      name: `${updatedUser.first_name || ''} ${updatedUser.last_name || ''}`.trim() || updatedUser.email,
      email: updatedUser.email,
      role: updatedUser.role,
      status: updatedUser.status,
      gallery: galleryName,
      galleryId: updatedUser.gallery_id,
      createdAt: updatedUser.created_at
    });
  }
  
  // Delete user (superadmin/admin only)
  async deleteUser(req: Request, res: Response) {
    const userInfo = getUserFromHeaders(req);
    
    if (userInfo.role !== 'superadmin' && userInfo.role !== 'admin') {
      throw new ForbiddenError('Only admin can delete users');
    }
    
    const { id } = req.params;
    
    // Don't allow deleting self
    if (id === userInfo.sub) {
      throw new ValidationError('Cannot delete yourself');
    }
    
    // Check if user exists
    const existingUser = await query('SELECT id, role FROM users WHERE id = $1', [id]);
    if (existingUser.rows.length === 0) {
      throw new ValidationError('User not found');
    }
    
    // Don't allow deleting other superadmins
    if (existingUser.rows[0].role === 'superadmin') {
      throw new ValidationError('Cannot delete superadmin users');
    }
    
    await query('DELETE FROM users WHERE id = $1', [id]);
    
    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  }
  
  // ========== USER SELF-SERVICE ==========
  
  async getMe(req: AuthenticatedRequest, res: Response) {
    const userId = (req.headers['x-user-id'] as string) || req.user?.sub;

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
    const userId = (req.headers['x-user-id'] as string) || req.user?.sub;
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
    const userId = (req.headers['x-user-id'] as string) || req.user?.sub;
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
















