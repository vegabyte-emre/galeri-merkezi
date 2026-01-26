import { Request, Response } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError } from '@galeri/shared/utils/errors';
import { VehicleStatus } from '@galeri/shared/types';
import { EventPublisher } from '../services/eventPublisher';
import { logger } from '@galeri/shared/utils/logger';

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

    // Superadmin tüm araçları görebilir
    const isSuperadmin = userInfo.role === 'superadmin';

    if (!galleryId && !isSuperadmin) {
      throw new ValidationError('Gallery ID not found');
    }

    const offset = (Number(page) - 1) * Number(limit);
    let whereClause = isSuperadmin ? '' : 'WHERE gallery_id = $1';
    const params: any[] = isSuperadmin ? [] : [galleryId];
    let paramCount = isSuperadmin ? 1 : 2;

    if (status) {
      whereClause += (whereClause ? ' AND ' : 'WHERE ') + `status = $${paramCount++}`;
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

    // Use Meilisearch if available, otherwise fallback to database search
    try {
      const MeiliSearch = require('meilisearch');
      const client = new MeiliSearch.Client({
        host: process.env.MEILISEARCH_HOST || 'http://localhost:7700',
        apiKey: process.env.MEILISEARCH_MASTER_KEY || 'master_key'
      });

      const index = client.index('vehicles');
      const searchResults = await index.search(q as string, {
        limit: Number(limit),
        offset: (Number(page) - 1) * Number(limit)
      });

      res.json({
        success: true,
        data: searchResults.hits || [],
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total: searchResults.estimatedTotalHits || 0
        }
      });
      return;
    } catch (error: any) {
      // Fallback to database search if Meilisearch is not available
      logger.warn('Meilisearch not available, using database search', { error: error.message });
    }

    // Database fallback search
    const searchQuery = `%${q}%`;
    const result = await query(`
      SELECT * FROM vehicles 
      WHERE (brand ILIKE $1 OR model ILIKE $1 OR series ILIKE $1)
      LIMIT $2 OFFSET $3
    `, [searchQuery, limit, (Number(page) - 1) * Number(limit)]);

    res.json({
      success: true,
      data: result.rows || [],
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

    // Check if it's a UUID or a slug (SEO-friendly URL support)
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);

    let result;
    if (galleryId) {
      // Gallery user: only their vehicles
      result = await query(
        `SELECT * FROM vehicles WHERE ${isUUID ? 'id' : 'slug'} = $1 AND gallery_id = $2`,
        [id, galleryId]
      );
    } else {
      // Public access (no gallery restriction)
      result = await query(
        `SELECT v.*, g.name as gallery_name, g.slug as gallery_slug, g.phone as gallery_phone, g.city as gallery_city
         FROM vehicles v
         LEFT JOIN galleries g ON v.gallery_id = g.id
         WHERE v.${isUUID ? 'id' : 'slug'} = $1 AND v.status = 'published'`,
        [id]
      );
    }

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

    // Normalize field names - accept both camelCase and snake_case
    const fuelType = vehicleData.fuelType || vehicleData.fuel_type;
    const bodyType = vehicleData.bodyType || vehicleData.body_type;
    const enginePower = vehicleData.enginePower || vehicleData.horsepower || vehicleData.engine_power;
    const engineCc = vehicleData.engineCc || vehicleData.engine_cc || vehicleData.engine_size;
    const vehicleCondition = vehicleData.vehicleCondition || vehicleData.vehicle_condition;
    const hasWarranty = vehicleData.hasWarranty || vehicleData.has_warranty || false;
    const warrantyDetails = vehicleData.warrantyDetails || vehicleData.warranty_details;
    const heavyDamageRecord = vehicleData.heavyDamageRecord || vehicleData.heavy_damage_record || false;
    const plateNumber = vehicleData.plateNumber || vehicleData.plate_number;
    const sellerType = vehicleData.sellerType || vehicleData.seller_type || 'gallery';
    const tradeInAcceptable = vehicleData.tradeInAcceptable || vehicleData.trade_in_acceptable || false;
    const basePrice = vehicleData.basePrice || vehicleData.base_price || vehicleData.price;
    
    // Features and body damage (JSONB)
    const features = vehicleData.features || vehicleData.vehicle_features || {};
    const bodyDamage = vehicleData.bodyDamage || vehicleData.body_damage || {};

    // Generate listing number
    const listingNo = `GM-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

    // Yeni araçlar direkt olarak onaya gider (pending_approval)
    const result = await query(
      `INSERT INTO vehicles (
        gallery_id, listing_no, brand, series, model, year, fuel_type, transmission,
        body_type, engine_power, engine_cc, drivetrain, color, vehicle_condition,
        mileage, has_warranty, warranty_details, heavy_damage_record, plate_number,
        seller_type, trade_in_acceptable, base_price, currency, description,
        features, body_damage,
        status, submitted_at, submitted_by, created_by
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, 'pending_approval', NOW(), $27, $27
      ) RETURNING *`,
      [
        galleryId, listingNo, vehicleData.brand, vehicleData.series, vehicleData.model,
        vehicleData.year, fuelType, vehicleData.transmission,
        bodyType, enginePower, engineCc,
        vehicleData.drivetrain, vehicleData.color, vehicleCondition,
        vehicleData.mileage, hasWarranty, warrantyDetails,
        heavyDamageRecord, plateNumber,
        sellerType, tradeInAcceptable,
        basePrice, vehicleData.currency || 'TRY', vehicleData.description,
        JSON.stringify(features), JSON.stringify(bodyDamage),
        userInfo.sub
      ]
    );

    const vehicle = result.rows[0];

    // Publish event for search indexing
    await this.eventPublisher.publishVehicleCreated(vehicle.id);

    // Superadmin'e bildirim gönder (araç otomatik onaya gönderildi)
    await this.eventPublisher.publishVehicleSubmittedForApproval(vehicle.id, galleryId);

    logger.info('Vehicle created and submitted for approval', { vehicleId: vehicle.id, galleryId });

    res.json({
      success: true,
      data: vehicle,
      message: 'Araç oluşturuldu ve onaya gönderildi'
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
      'description', 'features', 'body_damage'
    ];
    
    // JSONB fields that need special handling
    const jsonbFields = ['features', 'body_damage'];

    const updateFields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      const dbKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowedFields.includes(dbKey)) {
        updateFields.push(`${dbKey} = $${paramCount++}`);
        // Stringify JSONB fields
        if (jsonbFields.includes(dbKey) && typeof value === 'object') {
          values.push(JSON.stringify(value));
        } else {
          values.push(value);
        }
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

    // Check EİDS verification if required
    const galleryResult = await query('SELECT eids_verified FROM galleries WHERE id = $1', [galleryId]);
    if (galleryResult.rows.length > 0 && !galleryResult.rows[0].eids_verified) {
      throw new ValidationError('Gallery EİDS verification is required before publishing vehicles');
    }

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

  // Galeri sahibi araç onaya gönderir
  async submitForApproval(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    let galleryId = userInfo.gallery_id;

    // Önce aracı bul (gallery_id kontrolü olmadan)
    const vehicleCheck = await query(
      'SELECT * FROM vehicles WHERE id = $1',
      [id]
    );

    if (vehicleCheck.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    const vehicle = vehicleCheck.rows[0];

    // Eğer kullanıcının gallery_id'si yoksa, aracın gallery_id'sini kullan
    // Bu superadmin veya gallery_id eksik kullanıcılar için gerekli
    if (!galleryId) {
      galleryId = vehicle.gallery_id;
    }

    // Yetki kontrolü: Kullanıcı ya superadmin olmalı ya da aracın sahibi olmalı
    if (userInfo.role !== 'superadmin' && vehicle.gallery_id !== galleryId) {
      throw new ForbiddenError('You can only submit your own vehicles for approval');
    }

    const currentStatus = vehicle.status;
    if (currentStatus !== 'draft' && currentStatus !== 'rejected') {
      throw new ValidationError('Only draft or rejected vehicles can be submitted for approval');
    }

    await query(
      `UPDATE vehicles SET status = 'pending_approval', submitted_at = NOW(), submitted_by = $2 WHERE id = $1`,
      [id, userInfo.sub]
    );

    // Superadmin'e bildirim gönder
    await this.eventPublisher.publishVehicleSubmittedForApproval(id, vehicle.gallery_id);

    res.json({
      success: true,
      message: 'Vehicle submitted for approval'
    });
  }

  // Superadmin onay bekleyen araçları listeler
  async listPendingApproval(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const { page = 1, limit = 20 } = req.query;

    // Superadmin ve admin erişebilir
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(userInfo.role)) {
      logger.warn('Pending approval access denied', { role: userInfo.role, userId: userInfo.sub });
      throw new ForbiddenError('Only superadmin or admin can access pending approvals');
    }

    const offset = (Number(page) - 1) * Number(limit);

    const result = await query(
      `SELECT v.*, g.name as gallery_name, g.city as gallery_city 
       FROM vehicles v 
       LEFT JOIN galleries g ON v.gallery_id = g.id
       WHERE v.status = 'pending_approval' 
       ORDER BY v.submitted_at ASC 
       LIMIT $1 OFFSET $2`,
      [Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total FROM vehicles WHERE status = 'pending_approval'`
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

  // Superadmin aracı onaylar
  async approve(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);

    // Superadmin ve admin onaylayabilir
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(userInfo.role)) {
      throw new ForbiddenError('Only superadmin or admin can approve vehicles');
    }

    // Aracın mevcut durumunu kontrol et
    const vehicle = await query(
      'SELECT * FROM vehicles WHERE id = $1',
      [id]
    );

    if (vehicle.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    if (vehicle.rows[0].status !== 'pending_approval') {
      throw new ValidationError('Vehicle is not pending approval');
    }

    await query(
      `UPDATE vehicles SET status = 'published', published_at = NOW(), approved_by = $2, approved_at = NOW() WHERE id = $1`,
      [id, userInfo.sub]
    );

    // Galeri sahibine bildirim gönder ve Oto Pazarı'nda yayınla
    await this.eventPublisher.publishVehicleApproved(id, vehicle.rows[0].gallery_id);
    await this.eventPublisher.publishVehiclePublished(id);

    res.json({
      success: true,
      message: 'Vehicle approved and published to Oto Pazarı'
    });
  }

  // Superadmin aracı reddeder
  async reject(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const { reason } = req.body;
    const userInfo = getUserFromHeaders(req);

    // Superadmin ve admin reddedebilir
    const allowedRoles = ['superadmin', 'admin'];
    if (!allowedRoles.includes(userInfo.role)) {
      throw new ForbiddenError('Only superadmin or admin can reject vehicles');
    }

    // Aracın mevcut durumunu kontrol et
    const vehicle = await query(
      'SELECT * FROM vehicles WHERE id = $1',
      [id]
    );

    if (vehicle.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    if (vehicle.rows[0].status !== 'pending_approval') {
      throw new ValidationError('Vehicle is not pending approval');
    }

    await query(
      `UPDATE vehicles SET status = 'rejected', rejection_reason = $2, rejected_by = $3, rejected_at = NOW() WHERE id = $1`,
      [id, reason || 'Belirtilmedi', userInfo.sub]
    );

    // Galeri sahibine bildirim gönder
    await this.eventPublisher.publishVehicleRejected(id, vehicle.rows[0].gallery_id, reason);

    res.json({
      success: true,
      message: 'Vehicle rejected'
    });
  }
}

