import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    role: string;
  };
}

export class AdminController {
  async listGalleries(req: AuthenticatedRequest, res: Response) {
    // Only superadmin roles
    const allowedRoles = ['superadmin', 'compliance_officer'];
    if (!allowedRoles.includes(req.user?.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const { page = 1, limit = 20, status } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    
    let whereClause = 'WHERE 1=1';
    const params: any[] = [];
    let paramCount = 1;

    if (status) {
      whereClause += ` AND status = $${paramCount++}`;
      params.push(status);
    }

    const result = await query(
      `SELECT * FROM galleries ${whereClause} ORDER BY created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total FROM galleries ${whereClause}`,
      params
    );

    res.json({
      success: true,
      data: result.rows,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: parseInt(countResult.rows[0].total),
        totalPages: Math.ceil(parseInt(countResult.rows[0].total) / Number(limit))
      }
    });
  }

  async getGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    const result = await query('SELECT * FROM galleries WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      throw new ValidationError('Gallery not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async updateGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const updates = req.body;

    // Only superadmin can update
    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can update galleries');
    }

    const allowedFields = ['status', 'rejection_reason', 'rejection_template_id'];
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
    values.push(id);

    await query(
      `UPDATE galleries SET ${updateFields.join(', ')} WHERE id = $${paramCount}`,
      values
    );

    res.json({
      success: true,
      message: 'Gallery updated successfully'
    });
  }

  async approveGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can approve galleries');
    }

    await query(
      `UPDATE galleries 
       SET status = 'active', approved_at = NOW(), approved_by = $1, updated_at = NOW()
       WHERE id = $2`,
      [req.user?.sub, id]
    );

    // Publish event for notification
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    const galleryResult = await query('SELECT * FROM galleries WHERE id = $1', [id]);
    if (galleryResult.rows.length > 0) {
      const ownerResult = await query(
        'SELECT id FROM users WHERE gallery_id = $1 AND role = $2',
        [id, 'gallery_owner']
      );
      if (ownerResult.rows.length > 0) {
        await publishToQueue('notifications_queue', {
          id: uuidv4(),
          userId: ownerResult.rows[0].id,
          type: 'gallery_approved',
          title: 'Galeri Onaylandı',
          body: `Galeriniz onaylandı. Artık platformu kullanmaya başlayabilirsiniz.`,
          channels: ['push', 'email', 'sms']
        });
      }
    }

    res.json({
      success: true,
      message: 'Gallery approved successfully'
    });
  }

  async rejectGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const { reason, templateId } = req.body;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can reject galleries');
    }

    await query(
      `UPDATE galleries 
       SET status = 'rejected', rejection_reason = $1, rejection_template_id = $2, updated_at = NOW()
       WHERE id = $3`,
      [reason, templateId, id]
    );

    // Publish event for notification
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    const ownerResult = await query(
      'SELECT id FROM users WHERE gallery_id = $1 AND role = $2',
      [id, 'gallery_owner']
    );
    if (ownerResult.rows.length > 0) {
      await publishToQueue('notifications_queue', {
        id: uuidv4(),
        userId: ownerResult.rows[0].id,
        type: 'gallery_rejected',
        title: 'Galeri Başvurusu Reddedildi',
        body: `Galeri başvurunuz reddedildi. Sebep: ${reason}`,
        channels: ['push', 'email']
      });
    }

    res.json({
      success: true,
      message: 'Gallery rejected'
    });
  }

  async suspendGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can suspend galleries');
    }

    await query(
      `UPDATE galleries SET status = 'suspended', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    res.json({
      success: true,
      message: 'Gallery suspended'
    });
  }

  async activateGallery(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;

    if (req.user?.role !== 'superadmin') {
      throw new ForbiddenError('Only superadmin can activate galleries');
    }

    await query(
      `UPDATE galleries SET status = 'active', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    res.json({
      success: true,
      message: 'Gallery activated'
    });
  }
}

