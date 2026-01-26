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
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;
    const isSuperadmin = userInfo.role === 'superadmin' || userInfo.role === 'admin';

    const { page = 1, limit = 50, offset, unread_only } = req.query;
    const pageNum = Number(page);
    const limitNum = Number(limit);
    const offsetNum = offset !== undefined ? Number(offset) : (pageNum - 1) * limitNum;

    let queryStr: string;
    let countQueryStr: string;
    let params: any[];

    if (isSuperadmin && userId) {
      // Superadmin: Get notifications by user_id
      queryStr = `
        SELECT 
          n.id,
          n.type,
          n.title,
          n.body,
          n.data,
          n.read_at,
          n.created_at
        FROM notifications n
        WHERE n.user_id = $1
      `;
      countQueryStr = 'SELECT COUNT(*) as count FROM notifications WHERE user_id = $1';
      params = [userId];
    } else if (galleryId) {
      // Gallery users: Get notifications by gallery_id
      queryStr = `
        SELECT 
          n.id,
          n.type,
          n.title,
          n.body,
          n.data,
          n.read_at,
          n.created_at
        FROM notifications n
        WHERE n.gallery_id = $1
      `;
      countQueryStr = 'SELECT COUNT(*) as count FROM notifications WHERE gallery_id = $1';
      params = [galleryId];
    } else {
      throw new ValidationError('Gallery ID or User ID not found');
    }

    if (unread_only === 'true') {
      queryStr += ' AND n.read_at IS NULL';
      countQueryStr += ' AND read_at IS NULL';
    }

    queryStr += ' ORDER BY n.created_at DESC LIMIT $2 OFFSET $3';
    params.push(limitNum, offsetNum);

    const result = await query(queryStr, params);

    // Get total count
    const totalResult = await query(countQueryStr, [params[0]]);
    const total = parseInt(totalResult.rows[0].count);

    // Get unread count
    let unreadCountQuery: string;
    if (isSuperadmin && userId) {
      unreadCountQuery = 'SELECT COUNT(*) as count FROM notifications WHERE user_id = $1 AND read_at IS NULL';
    } else {
      unreadCountQuery = 'SELECT COUNT(*) as count FROM notifications WHERE gallery_id = $1 AND read_at IS NULL';
    }
    const unreadResult = await query(unreadCountQuery, [params[0]]);
    const unreadCount = parseInt(unreadResult.rows[0].count);

    res.json({
      success: true,
      data: result.rows,
      unreadCount,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum)
      }
    });
  }

  async markRead(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;
    const isSuperadmin = userInfo.role === 'superadmin' || userInfo.role === 'admin';
    const { id } = req.params;

    let result;
    if (isSuperadmin && userId) {
      result = await query(
        'UPDATE notifications SET read_at = NOW() WHERE id = $1 AND user_id = $2 RETURNING *',
        [id, userId]
      );
    } else if (galleryId) {
      result = await query(
        'UPDATE notifications SET read_at = NOW() WHERE id = $1 AND gallery_id = $2 RETURNING *',
        [id, galleryId]
      );
    } else {
      throw new ValidationError('Gallery ID or User ID not found');
    }

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
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;
    const isSuperadmin = userInfo.role === 'superadmin' || userInfo.role === 'admin';

    if (isSuperadmin && userId) {
      await query(
        'UPDATE notifications SET read_at = NOW() WHERE user_id = $1 AND read_at IS NULL',
        [userId]
      );
    } else if (galleryId) {
      await query(
        'UPDATE notifications SET read_at = NOW() WHERE gallery_id = $1 AND read_at IS NULL',
        [galleryId]
      );
    } else {
      throw new ValidationError('Gallery ID or User ID not found');
    }

    res.json({
      success: true,
      message: 'All notifications marked as read'
    });
  }

  async getUnreadCount(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const userId = userInfo.sub;
    const galleryId = userInfo.gallery_id;
    const isSuperadmin = userInfo.role === 'superadmin' || userInfo.role === 'admin';

    let result;
    if (isSuperadmin && userId) {
      result = await query(
        'SELECT COUNT(*) as count FROM notifications WHERE user_id = $1 AND read_at IS NULL',
        [userId]
      );
    } else if (galleryId) {
      result = await query(
        'SELECT COUNT(*) as count FROM notifications WHERE gallery_id = $1 AND read_at IS NULL',
        [galleryId]
      );
    } else {
      throw new ValidationError('Gallery ID or User ID not found');
    }

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
