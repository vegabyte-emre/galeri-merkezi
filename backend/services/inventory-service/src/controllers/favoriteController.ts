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

export class FavoriteController {
  async list(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      `SELECT 
        f.id,
        f.vehicle_id,
        f.created_at,
        v.brand,
        v.model,
        v.year,
        v.mileage,
        v.base_price,
        v.status,
        (SELECT vm.original_url FROM vehicle_media vm WHERE vm.vehicle_id = v.id AND vm.is_cover = true LIMIT 1) as cover_image_url
       FROM favorites f
       JOIN vehicles v ON v.id = f.vehicle_id
       WHERE f.gallery_id = $1
       ORDER BY f.created_at DESC`,
      [galleryId]
    );

    res.json({
      success: true,
      data: result.rows.map((row: any) => ({
        id: row.id,
        vehicleId: row.vehicle_id,
        createdAt: row.created_at,
        vehicle: {
          id: row.vehicle_id,
          brand: row.brand,
          model: row.model,
          year: row.year,
          mileage: row.mileage,
          basePrice: row.base_price,
          status: row.status,
          coverImageUrl: row.cover_image_url
        }
      }))
    });
  }

  async add(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { vehicleId } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    if (!vehicleId) {
      throw new ValidationError('Vehicle ID is required');
    }

    // Check if vehicle exists
    const vehicleResult = await query(
      'SELECT id FROM vehicles WHERE id = $1',
      [vehicleId]
    );

    if (vehicleResult.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    // Check if already favorited
    const existingResult = await query(
      'SELECT id FROM favorites WHERE gallery_id = $1 AND vehicle_id = $2',
      [galleryId, vehicleId]
    );

    if (existingResult.rows.length > 0) {
      return res.json({
        success: true,
        message: 'Vehicle already in favorites',
        data: existingResult.rows[0]
      });
    }

    // Add to favorites
    const result = await query(
      'INSERT INTO favorites (gallery_id, vehicle_id) VALUES ($1, $2) RETURNING *',
      [galleryId, vehicleId]
    );

    res.json({
      success: true,
      message: 'Vehicle added to favorites',
      data: result.rows[0]
    });
  }

  async remove(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { vehicleId } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    if (!vehicleId) {
      throw new ValidationError('Vehicle ID is required');
    }

    const result = await query(
      'DELETE FROM favorites WHERE gallery_id = $1 AND vehicle_id = $2 RETURNING *',
      [galleryId, vehicleId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Favorite not found');
    }

    res.json({
      success: true,
      message: 'Vehicle removed from favorites'
    });
  }
}




