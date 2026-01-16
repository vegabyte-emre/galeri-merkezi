import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { ValidationError } from '@galeri/shared/utils/errors';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
    role: string;
  };
}

function getUserFromHeaders(req: AuthenticatedRequest) {
  const userId = req.headers['x-user-id'] as string;
  const galleryId = req.headers['x-gallery-id'] as string;
  const userRole = req.headers['x-user-role'] as string;
  
  return {
    sub: userId || req.user?.sub,
    gallery_id: galleryId || req.user?.gallery_id,
    role: userRole || req.user?.role || ''
  };
}

export class NotificationController {
  async list(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const { limit = 50, offset = 0, unread_only } = req.query;

    let queryStr = `
      SELECT 
        n.id,
        n.type,
        n.title,
        n.message,
        n.is_read,
        n.created_at,
        n.related_entity_type,
        n.related_entity_id
      FROM notifications n
      WHERE n.gallery_id = $1
    `;

    const params: any[] = [galleryId];

    if (unread_only === 'true') {
      queryStr += ' AND n.is_read = FALSE';
    }

    queryStr += ' ORDER BY n.created_at DESC LIMIT $2 OFFSET $3';
    params.push(limit, offset);

    const result = await query(queryStr, params);

    // Get unread count
    const unreadResult = await query(
      'SELECT COUNT(*) as count FROM notifications WHERE gallery_id = $1 AND is_read = FALSE',
      [galleryId]
    );
    const unreadCount = parseInt(unreadResult.rows[0].count);

    res.json({
      success: true,
      data: result.rows,
      unreadCount
    });
  }

  async markRead(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { id } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      'UPDATE notifications SET is_read = TRUE, updated_at = NOW() WHERE id = $1 AND gallery_id = $2 RETURNING *',
      [id, galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Notification not found');
    }

    res.json({
      success: true,
      message: 'Notification marked as read',
      data: result.rows[0]
    });
  }

  async markAllRead(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    await query(
      'UPDATE notifications SET is_read = TRUE, updated_at = NOW() WHERE gallery_id = $1 AND is_read = FALSE',
      [galleryId]
    );

    res.json({
      success: true,
      message: 'All notifications marked as read'
    });
  }

  async getUnreadCount(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      'SELECT COUNT(*) as count FROM notifications WHERE gallery_id = $1 AND is_read = FALSE',
      [galleryId]
    );

    res.json({
      success: true,
      count: parseInt(result.rows[0].count)
    });
  }
}
