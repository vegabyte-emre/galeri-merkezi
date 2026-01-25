import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';
import { validateEmail, validatePassword } from '@galeri/shared/utils/validation';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
    role: string;
  };
}

export class UserController {
  async getMyUsers(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Only gallery owner can manage users
    if (req.user?.role !== 'gallery_owner') {
      throw new ForbiddenError('Only gallery owner can manage users');
    }

    // Exclude deleted users from the list
    const result = await query(
      `SELECT id, email, first_name, last_name, role, status, last_login, created_at 
       FROM users 
       WHERE gallery_id = $1 AND status != 'deleted'
       ORDER BY created_at DESC`,
      [galleryId]
    );

    res.json({
      success: true,
      data: result.rows
    });
  }

  async createUser(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { email, firstName, lastName, role, password } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    if (req.user?.role !== 'gallery_owner') {
      throw new ForbiddenError('Only gallery owner can create users');
    }

    if (!email || !validateEmail(email)) {
      throw new ValidationError('Valid email is required');
    }

    if (!password) {
      const passwordValidation = validatePassword(password);
      if (!passwordValidation.valid) {
        throw new ValidationError(passwordValidation.errors.join(', '));
      }
    }

    // Check if email exists
    const existing = await query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      throw new ValidationError('Email already exists');
    }

    const passwordHash = password ? await bcrypt.hash(password, 12) : null;
    const tempPassword = passwordHash || null;

    const result = await query(
      `INSERT INTO users (gallery_id, email, first_name, last_name, role, password_hash, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'active')
       RETURNING id, email, first_name, last_name, role`,
      [galleryId, email, firstName, lastName, role, tempPassword]
    );

    res.json({
      success: true,
      data: result.rows[0],
      message: 'User created successfully'
    });
  }

  async getUser(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { id } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      'SELECT id, email, first_name, last_name, role, status, last_login FROM users WHERE id = $1 AND gallery_id = $2',
      [id, galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('User not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async updateUser(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { id } = req.params;
    const updates = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    if (req.user?.role !== 'gallery_owner') {
      throw new ForbiddenError('Only gallery owner can update users');
    }

    const allowedFields = ['first_name', 'last_name', 'email', 'role', 'status'];
    const updateFields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      if (allowedFields.includes(key)) {
        updateFields.push(`${key} = $${paramCount++}`);
        values.push(value);
      }
    }

    if (updateFields.length === 0) {
      throw new ValidationError('No valid fields to update');
    }

    updateFields.push(`updated_at = NOW()`);
    values.push(id, galleryId);

    await query(
      `UPDATE users SET ${updateFields.join(', ')} WHERE id = $${paramCount} AND gallery_id = $${paramCount + 1}`,
      values
    );

    res.json({
      success: true,
      message: 'User updated successfully'
    });
  }

  async deleteUser(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { id } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    if (req.user?.role !== 'gallery_owner') {
      throw new ForbiddenError('Only gallery owner can delete users');
    }

    // Don't allow deleting yourself
    if (id === req.user?.sub) {
      throw new ValidationError('Cannot delete your own account');
    }

    await query(
      'UPDATE users SET status = $1 WHERE id = $2 AND gallery_id = $3',
      ['deleted', id, galleryId]
    );

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  }
}
















