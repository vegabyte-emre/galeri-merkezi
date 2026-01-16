import { Request, Response } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError, ForbiddenError, ConflictError } from '@galeri/shared/utils/errors';
import { OfferStatus } from '@galeri/shared/types';

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

export class OfferController {
  async getAll(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { page = 1, limit = 20, status } = req.query;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Get both incoming and outgoing offers
    const incomingResult = await query(
      `SELECT o.*, v.brand, v.model, v.year, v.base_price, g.name as buyer_gallery_name, 'incoming' as type
       FROM offers o
       JOIN vehicles v ON o.vehicle_id = v.id
       JOIN galleries g ON o.buyer_gallery_id = g.id
       WHERE o.seller_gallery_id = $1
       ORDER BY o.created_at DESC`,
      [galleryId]
    );

    const outgoingResult = await query(
      `SELECT o.*, v.brand, v.model, v.year, v.base_price, g.name as seller_gallery_name, 'outgoing' as type
       FROM offers o
       JOIN vehicles v ON o.vehicle_id = v.id
       JOIN galleries g ON o.seller_gallery_id = g.id
       WHERE o.buyer_gallery_id = $1
       ORDER BY o.created_at DESC`,
      [galleryId]
    );

    const allOffers = [...incomingResult.rows, ...outgoingResult.rows].sort((a, b) => 
      new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    );

    res.json({
      success: true,
      data: allOffers
    });
  }

  async getIncoming(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { page = 1, limit = 20, status } = req.query;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offset = (Number(page) - 1) * Number(limit);
    let whereClause = 'WHERE seller_gallery_id = $1';
    const params: any[] = [galleryId];
    let paramCount = 2;

    if (status) {
      whereClause += ` AND status = $${paramCount++}`;
      params.push(status);
    }

    const result = await query(
      `SELECT o.*, v.brand, v.model, v.year, v.base_price, g.name as buyer_gallery_name
       FROM offers o
       JOIN vehicles v ON o.vehicle_id = v.id
       JOIN galleries g ON o.buyer_gallery_id = g.id
       ${whereClause}
       ORDER BY o.created_at DESC
       LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total FROM offers ${whereClause}`,
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

  async getIncomingOffer(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    const result = await query(
      `SELECT o.*, v.*, g.name as buyer_gallery_name
       FROM offers o
       JOIN vehicles v ON o.vehicle_id = v.id
       JOIN galleries g ON o.buyer_gallery_id = g.id
       WHERE o.id = $1 AND o.seller_gallery_id = $2`,
      [id, galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Offer not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async getOutgoing(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { page = 1, limit = 20, status } = req.query;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offset = (Number(page) - 1) * Number(limit);
    let whereClause = 'WHERE buyer_gallery_id = $1';
    const params: any[] = [galleryId];
    let paramCount = 2;

    if (status) {
      whereClause += ` AND status = $${paramCount++}`;
      params.push(status);
    }

    const result = await query(
      `SELECT o.*, v.brand, v.model, v.year, v.base_price, g.name as seller_gallery_name
       FROM offers o
       JOIN vehicles v ON o.vehicle_id = v.id
       JOIN galleries g ON o.seller_gallery_id = g.id
       ${whereClause}
       ORDER BY o.created_at DESC
       LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total FROM offers ${whereClause}`,
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

  async getOutgoingOffer(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;

    const result = await query(
      `SELECT o.*, v.*, g.name as seller_gallery_name
       FROM offers o
       JOIN vehicles v ON o.vehicle_id = v.id
       JOIN galleries g ON o.seller_gallery_id = g.id
       WHERE o.id = $1 AND o.buyer_gallery_id = $2`,
      [id, galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Offer not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async create(req: AuthenticatedRequest, res: Response) {
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { vehicleId, amount, note, validUntil } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Get vehicle and seller gallery
    const vehicleResult = await query(
      'SELECT gallery_id, status FROM vehicles WHERE id = $1',
      [vehicleId]
    );

    if (vehicleResult.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    const sellerGalleryId = vehicleResult.rows[0].gallery_id;

    if (sellerGalleryId === galleryId) {
      throw new ValidationError('Cannot make offer on your own vehicle');
    }

    if (vehicleResult.rows[0].status !== 'published') {
      throw new ValidationError('Vehicle is not published');
    }

    // Check for existing active offer
    const existingOffer = await query(
      `SELECT id FROM offers 
       WHERE vehicle_id = $1 AND buyer_gallery_id = $2 
       AND status IN ('sent', 'viewed', 'counter_offer')`,
      [vehicleId, galleryId]
    );

    if (existingOffer.rows.length > 0) {
      throw new ConflictError('Active offer already exists for this vehicle');
    }

    const result = await query(
      `INSERT INTO offers (
        vehicle_id, seller_gallery_id, buyer_gallery_id,
        amount, currency, note, valid_until, status, created_by
      ) VALUES ($1, $2, $3, $4, 'TRY', $5, $6, 'draft', $7)
      RETURNING *`,
      [vehicleId, sellerGalleryId, galleryId, amount, note, validUntil, userInfo.sub]
    );

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async update(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const userInfo = getUserFromHeaders(req);
    const galleryId = userInfo.gallery_id;
    const { amount, note, validUntil } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Check if offer exists and belongs to buyer
    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND buyer_gallery_id = $2 AND status = $3',
      [id, galleryId, 'draft']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be updated');
    }

    const updateFields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    if (amount !== undefined) {
      updateFields.push(`amount = $${paramCount++}`);
      values.push(amount);
    }
    if (note !== undefined) {
      updateFields.push(`note = $${paramCount++}`);
      values.push(note);
    }
    if (validUntil !== undefined) {
      updateFields.push(`valid_until = $${paramCount++}`);
      values.push(validUntil);
    }

    if (updateFields.length === 0) {
      throw new ValidationError('No fields to update');
    }

    updateFields.push(`updated_at = NOW()`);
    values.push(id);

    await query(
      `UPDATE offers SET ${updateFields.join(', ')} WHERE id = $${paramCount}`,
      values
    );

    res.json({
      success: true,
      message: 'Offer updated successfully'
    });
  }

  async send(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND buyer_gallery_id = $2 AND status = $3',
      [id, galleryId, 'draft']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be sent');
    }

    await query(
      `UPDATE offers SET status = 'sent', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    // Publish event for notification
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    await publishToQueue('notifications_queue', {
      id: uuidv4(),
      userId: offerResult.rows[0].seller_gallery_id, // TODO: Get user ID from gallery
      type: 'new_offer',
      title: 'Yeni Teklif',
      body: `Araçınız için yeni bir teklif geldi`,
      channels: ['push', 'email']
    });

    res.json({
      success: true,
      message: 'Offer sent successfully'
    });
  }

  async counter(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;
    const { amount, note } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND seller_gallery_id = $2 AND status IN ($3, $4)',
      [id, galleryId, 'sent', 'viewed']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be countered');
    }

    const originalOffer = offerResult.rows[0];

    const client = await getClient();
    try {
      await client.query('BEGIN');

      // Update original offer status
      await client.query(
        `UPDATE offers SET status = 'counter_offer', updated_at = NOW() WHERE id = $1`,
        [id]
      );

      // Create counter offer
      const counterResult = await client.query(
        `INSERT INTO offers (
          vehicle_id, seller_gallery_id, buyer_gallery_id,
          amount, currency, note, status, parent_offer_id, version, created_by
        ) VALUES ($1, $2, $3, $4, 'TRY', $5, 'sent', $6, $7, $8)
        RETURNING *`,
        [
          originalOffer.vehicle_id,
          originalOffer.seller_gallery_id,
          originalOffer.buyer_gallery_id,
          amount,
          note,
          id,
          (originalOffer.version || 1) + 1,
          req.user?.sub
        ]
      );

      // Record history
      await client.query(
        `INSERT INTO offer_history (offer_id, old_status, new_status, old_amount, new_amount, changed_by)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [id, originalOffer.status, 'counter_offer', originalOffer.amount, amount, req.user?.sub]
      );

      await client.query('COMMIT');

      // Publish event for notification
      const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
      await publishToQueue('notifications_queue', {
        id: uuidv4(),
        userId: originalOffer.buyer_gallery_id, // TODO: Get user ID
        type: 'offer_counter',
        title: 'Karşı Teklif',
        body: `Teklifinize karşı teklif yapıldı`,
        channels: ['push', 'email']
      });

      res.json({
        success: true,
        data: counterResult.rows[0]
      });
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async accept(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const allowedRoles = ['gallery_owner', 'gallery_manager'];
    if (!allowedRoles.includes(req.user?.role || '')) {
      throw new ForbiddenError('Insufficient permissions');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND seller_gallery_id = $2 AND status IN ($3, $4, $5)',
      [id, galleryId, 'sent', 'viewed', 'counter_offer']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be accepted');
    }

    const offer = offerResult.rows[0];

    const client = await getClient();
    try {
      await client.query('BEGIN');

      // Update offer status
      await client.query(
        `UPDATE offers SET status = 'accepted', accepted_by = $1, accepted_at = NOW() WHERE id = $2`,
        [req.user?.sub, id]
      );

      // Cancel other active offers for this vehicle
      await client.query(
        `UPDATE offers SET status = 'cancelled', updated_at = NOW()
         WHERE vehicle_id = $1 AND id != $2 AND status IN ('sent', 'viewed', 'counter_offer')`,
        [offer.vehicle_id, id]
      );

      // Record history
      await client.query(
        `INSERT INTO offer_history (offer_id, old_status, new_status, changed_by)
         VALUES ($1, $2, $3, $4)`,
        [id, offer.status, 'accepted', req.user?.sub]
      );

      await client.query('COMMIT');

      // Publish event for notification
      const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
      await publishToQueue('notifications_queue', {
        id: uuidv4(),
        userId: offer.buyer_gallery_id, // TODO: Get user ID
        type: 'offer_accepted',
        title: 'Teklif Kabul Edildi',
        body: `Teklifiniz kabul edildi`,
        channels: ['push', 'email', 'sms']
      });

      res.json({
        success: true,
        message: 'Offer accepted successfully'
      });
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async reject(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;
    const { reason } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND seller_gallery_id = $2 AND status IN ($3, $4, $5)',
      [id, galleryId, 'sent', 'viewed', 'counter_offer']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be rejected');
    }

    const offer = offerResult.rows[0];

    await query(
      `UPDATE offers SET status = 'rejected', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    // Record history
    await query(
      `INSERT INTO offer_history (offer_id, old_status, new_status, change_reason, changed_by)
       VALUES ($1, $2, $3, $4, $5)`,
      [id, offer.status, 'rejected', reason, req.user?.sub]
    );

    // Publish event for notification
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    await publishToQueue('notifications_queue', {
      id: uuidv4(),
      userId: offer.buyer_gallery_id, // TODO: Get user ID
      type: 'offer_rejected',
      title: 'Teklif Reddedildi',
      body: `Teklifiniz reddedildi`,
      channels: ['push', 'email']
    });

    res.json({
      success: true,
      message: 'Offer rejected'
    });
  }

  async cancel(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND buyer_gallery_id = $2 AND status IN ($3, $4)',
      [id, galleryId, 'draft', 'sent']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be cancelled');
    }

    await query(
      `UPDATE offers SET status = 'cancelled', updated_at = NOW() WHERE id = $1`,
      [id]
    );

    res.json({
      success: true,
      message: 'Offer cancelled'
    });
  }

  async reserve(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;
    const { reservedUntil } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND seller_gallery_id = $2 AND status = $3',
      [id, galleryId, 'accepted']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be reserved');
    }

    await query(
      `UPDATE offers SET reserved_until = $1 WHERE id = $2`,
      [reservedUntil, id]
    );

    res.json({
      success: true,
      message: 'Vehicle reserved'
    });
  }

  async convert(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const offerResult = await query(
      'SELECT * FROM offers WHERE id = $1 AND seller_gallery_id = $2 AND status = $3',
      [id, galleryId, 'accepted']
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found or cannot be converted');
    }

    const offer = offerResult.rows[0];

    const client = await getClient();
    try {
      await client.query('BEGIN');

      // Update offer status
      await client.query(
        `UPDATE offers SET status = 'converted', updated_at = NOW() WHERE id = $1`,
        [id]
      );

      // Mark vehicle as sold
      await client.query(
        `UPDATE vehicles SET status = 'sold', updated_at = NOW() WHERE id = $1`,
        [offer.vehicle_id]
      );

      // Record history
      await client.query(
        `INSERT INTO offer_history (offer_id, old_status, new_status, changed_by)
         VALUES ($1, $2, $3, $4)`,
        [id, 'accepted', 'converted', req.user?.sub]
      );

      await client.query('COMMIT');

      // Publish events for notification and channel sync
      const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
      await publishToQueue('notifications_queue', {
        id: uuidv4(),
        userId: offer.buyer_gallery_id, // TODO: Get user ID
        type: 'offer_converted',
        title: 'Satış Gerçekleşti',
        body: `Teklifiniz satışa dönüştürüldü`,
        channels: ['push', 'email', 'sms']
      });
      
      await publishToQueue('channel_sync_queue', {
        vehicleId: offer.vehicle_id,
        action: 'delete' // Remove from channels
      });

      res.json({
        success: true,
        message: 'Offer converted to sale successfully'
      });
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async getHistory(req: AuthenticatedRequest, res: Response) {
    const { id } = req.params;
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Verify offer belongs to gallery
    const offerResult = await query(
      'SELECT id FROM offers WHERE id = $1 AND (seller_gallery_id = $2 OR buyer_gallery_id = $2)',
      [id, galleryId]
    );

    if (offerResult.rows.length === 0) {
      throw new ValidationError('Offer not found');
    }

    const result = await query(
      `SELECT oh.*, u.first_name, u.last_name
       FROM offer_history oh
       LEFT JOIN users u ON oh.changed_by = u.id
       WHERE oh.offer_id = $1
       ORDER BY oh.created_at DESC`,
      [id]
    );

    res.json({
      success: true,
      data: result.rows
    });
  }
}

