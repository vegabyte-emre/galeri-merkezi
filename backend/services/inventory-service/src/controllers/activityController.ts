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

export class ActivityController {
  async list(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const { limit = 50, offset = 0, type, start_date, end_date } = req.query;

    let queryStr = `
      SELECT 
        id,
        action_type,
        entity_type,
        entity_id,
        description,
        user_id,
        gallery_id,
        ip_address,
        user_agent,
        created_at
      FROM audit_logs
      WHERE gallery_id = $1
    `;

    const params: any[] = [galleryId];

    if (type) {
      queryStr += ' AND action_type = $' + (params.length + 1);
      params.push(type);
    }

    if (start_date) {
      queryStr += ' AND created_at >= $' + (params.length + 1);
      params.push(start_date);
    }

    if (end_date) {
      queryStr += ' AND created_at <= $' + (params.length + 1);
      params.push(end_date);
    }

    queryStr += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
    params.push(limit, offset);

    const result = await query(queryStr, params);

    res.json({
      success: true,
      data: result.rows
    });
  }

  async getStats(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Get activity count by type for last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const result = await query(
      `SELECT 
        action_type,
        COUNT(*) as count
       FROM audit_logs
       WHERE gallery_id = $1 AND created_at >= $2
       GROUP BY action_type
       ORDER BY count DESC`,
      [galleryId, thirtyDaysAgo]
    );

    // Get total activity count
    const totalResult = await query(
      'SELECT COUNT(*) as count FROM audit_logs WHERE gallery_id = $1',
      [galleryId]
    );

    res.json({
      success: true,
      stats: {
        total: parseInt(totalResult.rows[0].count),
        byType: result.rows.map((row: any) => ({
          type: row.action_type,
          count: parseInt(row.count)
        }))
      }
    });
  }
}
