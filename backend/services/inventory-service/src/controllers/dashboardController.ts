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

export class DashboardController {
  async getStats(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Get total vehicles count
    const vehiclesResult = await query(
      'SELECT COUNT(*) as total FROM vehicles WHERE gallery_id = $1',
      [galleryId]
    );
    const totalVehicles = parseInt(vehiclesResult.rows[0].total);

    // Get published vehicles count
    const publishedResult = await query(
      'SELECT COUNT(*) as total FROM vehicles WHERE gallery_id = $1 AND status = $2',
      [galleryId, 'published']
    );
    const publishedVehicles = parseInt(publishedResult.rows[0].total);

    // Get vehicles added this month
    const thisMonth = new Date();
    thisMonth.setDate(1);
    thisMonth.setHours(0, 0, 0, 0);
    
    const monthlyVehiclesResult = await query(
      'SELECT COUNT(*) as total FROM vehicles WHERE gallery_id = $1 AND created_at >= $2',
      [galleryId, thisMonth]
    );
    const monthlyVehicles = parseInt(monthlyVehiclesResult.rows[0].total);

    // Get vehicles sold this month
    const monthlySoldResult = await query(
      'SELECT COUNT(*) as total FROM vehicles WHERE gallery_id = $1 AND status = $2 AND updated_at >= $3',
      [galleryId, 'sold', thisMonth]
    );
    const monthlySales = parseInt(monthlySoldResult.rows[0].total);

    // Get recent vehicles (last 5)
    const recentVehiclesResult = await query(
      `SELECT v.*, 
        (SELECT vm.original_url FROM vehicle_media vm WHERE vm.vehicle_id = v.id AND vm.is_primary = true LIMIT 1) as cover_image_url
       FROM vehicles v
       WHERE v.gallery_id = $1
       ORDER BY v.created_at DESC
       LIMIT 5`,
      [galleryId]
    );

    const recentVehicles = recentVehiclesResult.rows.map((v: any) => ({
      id: v.id,
      brand: v.brand,
      model: v.model,
      year: v.year,
      mileage: v.mileage,
      base_price: v.base_price,
      status: v.status,
      cover_image_url: v.cover_image_url
    }));

    res.json({
      success: true,
      stats: {
        totalVehicles: {
          value: totalVehicles,
          change: monthlyVehicles > 0 ? `+${monthlyVehicles}` : '0'
        },
        publishedVehicles: {
          value: publishedVehicles,
          change: '0'
        },
        monthlySales: {
          value: monthlySales,
          change: '0%'
        }
      },
      recentVehicles
    });
  }
}
