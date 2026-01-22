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

  async registerFCMToken(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;

    if (!userId) {
      throw new ValidationError('User ID not found');
    }

    const { token, deviceType, deviceId, appVersion } = req.body;

    if (!token) {
      throw new ValidationError('FCM token is required');
    }

    try {
      // Check if token already exists
      const existing = await query(
        'SELECT id FROM fcm_tokens WHERE user_id = $1 AND token = $2',
        [userId, token]
      );

      if (existing.rows.length > 0) {
        // Update existing token
        await query(
          `UPDATE fcm_tokens 
           SET is_active = TRUE, 
               device_type = COALESCE($1, device_type),
               device_id = COALESCE($2, device_id),
               app_version = COALESCE($3, app_version),
               last_used_at = NOW(),
               updated_at = NOW()
           WHERE user_id = $4 AND token = $5`,
          [deviceType, deviceId, appVersion, userId, token]
        );
      } else {
        // Insert new token
        await query(
          `INSERT INTO fcm_tokens (user_id, token, device_type, device_id, app_version, is_active)
           VALUES ($1, $2, $3, $4, $5, TRUE)
           ON CONFLICT (user_id, token) DO UPDATE SET
             is_active = TRUE,
             last_used_at = NOW(),
             updated_at = NOW()`,
          [userId, token, deviceType || null, deviceId || null, appVersion || null]
        );
      }

      res.json({
        success: true,
        message: 'FCM token registered successfully'
      });
    } catch (error: any) {
      throw new ValidationError('Failed to register FCM token: ' + error.message);
    }
  }

  async unregisterFCMToken(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const { token } = req.body;

    if (!userId) {
      throw new ValidationError('User ID not found');
    }

    if (!token) {
      throw new ValidationError('FCM token is required');
    }

    try {
      await query(
        'UPDATE fcm_tokens SET is_active = FALSE, updated_at = NOW() WHERE user_id = $1 AND token = $2',
        [userId, token]
      );

      res.json({
        success: true,
        message: 'FCM token unregistered successfully'
      });
    } catch (error: any) {
      throw new ValidationError('Failed to unregister FCM token: ' + error.message);
    }
  }
}
