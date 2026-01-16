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

export class ReportController {
  async getSalesReport(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { start_date, end_date } = req.query;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    let dateFilter = '';
    const params: any[] = [galleryId];

    if (start_date && end_date) {
      dateFilter = ' AND v.updated_at >= $2 AND v.updated_at <= $3';
      params.push(start_date, end_date);
    }

    // Get sold vehicles
    const soldResult = await query(
      `SELECT 
        COUNT(*) as total,
        SUM(v.base_price) as total_revenue
       FROM vehicles v
       WHERE v.gallery_id = $1 AND v.status = 'sold'${dateFilter}`,
      params
    );

    // Get sales by month
    const monthlyResult = await query(
      `SELECT 
        DATE_TRUNC('month', v.updated_at) as month,
        COUNT(*) as count,
        SUM(v.base_price) as revenue
       FROM vehicles v
       WHERE v.gallery_id = $1 AND v.status = 'sold'${dateFilter ? ' AND v.updated_at >= $2 AND v.updated_at <= $3' : ''}
       GROUP BY DATE_TRUNC('month', v.updated_at)
       ORDER BY month DESC
       LIMIT 12`,
      params
    );

    // Get sales by brand
    const brandResult = await query(
      `SELECT 
        v.brand,
        COUNT(*) as count,
        SUM(v.base_price) as revenue
       FROM vehicles v
       WHERE v.gallery_id = $1 AND v.status = 'sold'${dateFilter}
       GROUP BY v.brand
       ORDER BY count DESC
       LIMIT 10`,
      params
    );

    res.json({
      success: true,
      data: {
        summary: {
          totalSold: parseInt(soldResult.rows[0].total || 0),
          totalRevenue: parseFloat(soldResult.rows[0].total_revenue || 0)
        },
        monthly: monthlyResult.rows.map((row: any) => ({
          month: row.month,
          count: parseInt(row.count),
          revenue: parseFloat(row.revenue || 0)
        })),
        byBrand: brandResult.rows.map((row: any) => ({
          brand: row.brand,
          count: parseInt(row.count),
          revenue: parseFloat(row.revenue || 0)
        }))
      }
    });
  }

  async getInventoryReport(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Get vehicles by status
    const statusResult = await query(
      `SELECT 
        status,
        COUNT(*) as count
       FROM vehicles
       WHERE gallery_id = $1
       GROUP BY status`,
      [galleryId]
    );

    // Get vehicles by brand
    const brandResult = await query(
      `SELECT 
        brand,
        COUNT(*) as count,
        AVG(base_price) as avg_price
       FROM vehicles
       WHERE gallery_id = $1
       GROUP BY brand
       ORDER BY count DESC`,
      [galleryId]
    );

    // Get average days on market
    const daysOnMarketResult = await query(
      `SELECT 
        AVG(EXTRACT(EPOCH FROM (updated_at - created_at)) / 86400) as avg_days
       FROM vehicles
       WHERE gallery_id = $1 AND status = 'sold'`,
      [galleryId]
    );

    res.json({
      success: true,
      data: {
        byStatus: statusResult.rows.map((row: any) => ({
          status: row.status,
          count: parseInt(row.count)
        })),
        byBrand: brandResult.rows.map((row: any) => ({
          brand: row.brand,
          count: parseInt(row.count),
          avgPrice: parseFloat(row.avg_price || 0)
        })),
        avgDaysOnMarket: parseFloat(daysOnMarketResult.rows[0]?.avg_days || 0)
      }
    });
  }

  async getOfferReport(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { start_date, end_date } = req.query;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    let dateFilter = '';
    const params: any[] = [galleryId];

    if (start_date && end_date) {
      dateFilter = ' AND o.created_at >= $2 AND o.created_at <= $3';
      params.push(start_date, end_date);
    }

    // Get offers by status
    const statusResult = await query(
      `SELECT 
        o.status,
        COUNT(*) as count,
        AVG(o.price) as avg_price
       FROM offers o
       WHERE o.seller_gallery_id = $1${dateFilter}
       GROUP BY o.status`,
      params
    );

    // Get incoming vs outgoing
    const incomingResult = await query(
      `SELECT COUNT(*) as count FROM offers WHERE seller_gallery_id = $1${dateFilter}`,
      params
    );

    const outgoingParams = [...params];
    if (dateFilter) {
      outgoingParams[0] = galleryId;
    }
    const outgoingResult = await query(
      `SELECT COUNT(*) as count FROM offers WHERE buyer_gallery_id = $1${dateFilter}`,
      outgoingParams
    );

    res.json({
      success: true,
      data: {
        byStatus: statusResult.rows.map((row: any) => ({
          status: row.status,
          count: parseInt(row.count),
          avgPrice: parseFloat(row.avg_price || 0)
        })),
        incoming: parseInt(incomingResult.rows[0].count),
        outgoing: parseInt(outgoingResult.rows[0].count)
      }
    });
  }
}
