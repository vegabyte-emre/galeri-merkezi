import { Request, Response } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';
import { VehicleStatus } from '@galeri/shared/types';
import { EventPublisher } from '../services/eventPublisher';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
    role: string;
  };
}

// Helper function to extract user info from headers (passed by API Gateway)
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

export class VehicleController {
  private eventPublisher = new EventPublisher();

  async list(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { page = 1, limit = 20, status } = req.query;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offset = (Number(page) - 1) * Number(limit);
    let whereClause = 'WHERE gallery_id = $1';
    const params: any[] = [galleryId];
    let paramCount = 2;

    if (status) {
      whereClause += ` AND status = $${paramCount++}`;
      params.push(status);
    }

    const result = await query(
      `SELECT * FROM vehicles ${whereClause} ORDER BY created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total FROM vehicles ${whereClause}`,
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

  async search(req: AuthenticatedRequest, res: Response) {
    const { q, page = 1, limit = 20 } = req.query;

    if (!q) {
      throw new ValidationError('Search query is required');
    }

    // TODO: Implement Meilisearch integration
    res.json({
      success: true,
      data: [],
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: 0,
        totalPages: 0
      }
    });
  }

  async get(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    const result = await query(
      'SELECT * FROM vehicles WHERE id = $1 AND gallery_id = $2',
      [id, galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async create(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const vehicleData = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Check permissions
    const allowedRoles = ['gallery_owner', 'gallery_manager', 'inventory_manager'];
    if (!allowedRoles.includes(userInfo.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    // Generate listing number
    const listingNo = `GM-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

    const result = await query(
      `INSERT INTO vehicles (
        gallery_id, listing_no, brand, series, model, year, fuel_type, transmission,
        body_type, engine_power, engine_cc, drivetrain, color, vehicle_condition,
        mileage, has_warranty, warranty_details, heavy_damage_record, plate_number,
        seller_type, trade_in_acceptable, base_price, currency, description,
        status, created_by
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, 'draft', $25
      ) RETURNING *`,
      [
        galleryId, listingNo, vehicleData.brand, vehicleData.series, vehicleData.model,
        vehicleData.year, vehicleData.fuelType, vehicleData.transmission,
        vehicleData.bodyType, vehicleData.enginePower, vehicleData.engineCc,
        vehicleData.drivetrain, vehicleData.color, vehicleData.vehicleCondition,
        vehicleData.mileage, vehicleData.hasWarranty || false, vehicleData.warrantyDetails,
        vehicleData.heavyDamageRecord || false, vehicleData.plateNumber,
        vehicleData.sellerType, vehicleData.tradeInAcceptable || false,
        vehicleData.basePrice, vehicleData.currency || 'TRY', vehicleData.description,
        userInfo.sub
      ]
    );

    // Publish event for search indexing
    await this.eventPublisher.publishVehicleCreated(result.rows[0].id);

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async update(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const updates = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const allowedRoles = ['gallery_owner', 'gallery_manager', 'inventory_manager'];
    if (!allowedRoles.includes(userInfo.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const allowedFields = [
      'brand', 'series', 'model', 'year', 'fuel_type', 'transmission', 'body_type',
      'engine_power', 'engine_cc', 'drivetrain', 'color', 'vehicle_condition',
      'mileage', 'has_warranty', 'warranty_details', 'heavy_damage_record',
      'plate_number', 'seller_type', 'trade_in_acceptable', 'base_price',
      'description'
    ];

    const updateFields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      const dbKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(dbKey)) {
        updateFields.push(`${dbKey} = $${paramCount++}`);
        values.push(value);
      }
    }

    if (updateFields.length === 0) {
      throw new ValidationError('No valid fields to update');
    }

    updateFields.push(`updated_at = NOW()`, `updated_by = $${paramCount++}`);
    values.push(userInfo.sub, id, galleryId);

    await query(
      `UPDATE vehicles SET ${updateFields.join(', ')} WHERE id = $${paramCount} AND gallery_id = $${paramCount + 1}`,
      values
    );

    // Publish event for search indexing
    await this.eventPublisher.publishVehicleUpdated(id);

    res.json({
      success: true,
      message: 'Vehicle updated successfully'
    });
  }

  async delete(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const allowedRoles = ['gallery_owner', 'gallery_manager', 'inventory_manager'];
    if (!allowedRoles.includes(userInfo.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }

    await query(
      'DELETE FROM vehicles WHERE id = $1 AND gallery_id = $2',
      [id, galleryId]
    );

    res.json({
      success: true,
      message: 'Vehicle deleted successfully'
    });
  }

  async publish(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // TODO: Check EİDS verification

    await query(
      `UPDATE vehicles SET status = 'published', published_at = NOW() WHERE id = $1 AND gallery_id = $2`,
      [id, galleryId]
    );

    // Publish events for channel sync and search indexing
    await this.eventPublisher.publishVehiclePublished(id);

    res.json({
      success: true,
      message: 'Vehicle published successfully'
    });
  }

  async pause(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    await query(
      `UPDATE vehicles SET status = 'paused' WHERE id = $1 AND gallery_id = $2`,
      [id, galleryId]
    );

    res.json({
      success: true,
      message: 'Vehicle paused successfully'
    });
  }

  async archive(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    await query(
      `UPDATE vehicles SET status = 'archived' WHERE id = $1 AND gallery_id = $2`,
      [id, galleryId]
    );

    res.json({
      success: true,
      message: 'Vehicle archived successfully'
    });
  }

  async markSold(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    await query(
      `UPDATE vehicles SET status = 'sold' WHERE id = $1 AND gallery_id = $2`,
      [id, galleryId]
    );

    res.json({
      success: true,
      message: 'Vehicle marked as sold'
    });
  }
}

