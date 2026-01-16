import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { ValidationError } from '@galeri/shared/utils/errors';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
  };
}

export class ChannelListingController {
  async list(req: AuthenticatedRequest, res: Response) {
    const { vehicleId } = req.params;

    const result = await query(
      `SELECT cl.*, c.name as channel_name, c.slug as channel_slug
       FROM channel_listings cl
       JOIN channels c ON cl.channel_id = c.id
       WHERE cl.vehicle_id = $1`,
      [vehicleId]
    );

    res.json({
      success: true,
      data: result.rows
    });
  }

  async create(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, channelId } = req.params;
    const {
      channelPrice,
      pricingRuleType,
      pricingRuleValue,
      roundingRule,
      minPriceProtection
    } = req.body;

    // Get vehicle base price
    const vehicleResult = await query(
      'SELECT base_price FROM vehicles WHERE id = $1',
      [vehicleId]
    );

    if (vehicleResult.rows.length === 0) {
      throw new ValidationError('Vehicle not found');
    }

    const basePrice = parseFloat(vehicleResult.rows[0].base_price);

    // Calculate channel price
    let calculatedPrice = basePrice;
    if (pricingRuleType === 'percentage') {
      calculatedPrice = basePrice * (1 + pricingRuleValue / 100);
    } else if (pricingRuleType === 'fixed') {
      calculatedPrice = basePrice + pricingRuleValue;
    } else if (pricingRuleType === 'manual') {
      calculatedPrice = channelPrice || basePrice;
    }

    // Apply rounding
    if (roundingRule === 'round_100') {
      calculatedPrice = Math.round(calculatedPrice / 100) * 100;
    } else if (roundingRule === 'round_1000') {
      calculatedPrice = Math.round(calculatedPrice / 1000) * 1000;
    } else if (roundingRule === 'round_up') {
      calculatedPrice = Math.ceil(calculatedPrice);
    } else if (roundingRule === 'round_down') {
      calculatedPrice = Math.floor(calculatedPrice);
    }

    // Apply minimum price protection
    if (minPriceProtection && calculatedPrice < minPriceProtection) {
      calculatedPrice = minPriceProtection;
    }

    const finalPrice = channelPrice || calculatedPrice;

    const result = await query(
      `INSERT INTO channel_listings (
        vehicle_id, channel_id, base_price, channel_price,
        pricing_rule_type, pricing_rule_value, rounding_rule,
        min_price_protection, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending')
      ON CONFLICT (vehicle_id, channel_id) 
      DO UPDATE SET 
        channel_price = $4,
        pricing_rule_type = $5,
        pricing_rule_value = $6,
        rounding_rule = $7,
        min_price_protection = $8,
        updated_at = NOW()
      RETURNING *`,
      [
        vehicleId, channelId, basePrice, finalPrice,
        pricingRuleType, pricingRuleValue, roundingRule,
        minPriceProtection
      ]
    );

    // Publish event for channel sync
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    await publishToQueue('channel_sync_queue', {
      vehicleId,
      channelId,
      action: 'create'
    });

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async update(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, channelId } = req.params;
    const updates = req.body;

    const allowedFields = [
      'channel_price', 'pricing_rule_type', 'pricing_rule_value',
      'rounding_rule', 'min_price_protection', 'campaign_price',
      'campaign_start', 'campaign_end'
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

    updateFields.push(`updated_at = NOW()`);
    values.push(vehicleId, channelId);

    await query(
      `UPDATE channel_listings SET ${updateFields.join(', ')} 
       WHERE vehicle_id = $${paramCount} AND channel_id = $${paramCount + 1}`,
      values
    );

    res.json({
      success: true,
      message: 'Channel listing updated successfully'
    });
  }

  async delete(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, channelId } = req.params;

    await query(
      'DELETE FROM channel_listings WHERE vehicle_id = $1 AND channel_id = $2',
      [vehicleId, channelId]
    );

    // Publish event to remove from channel
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    await publishToQueue('channel_sync_queue', {
      vehicleId,
      channelId,
      action: 'delete'
    });

    res.json({
      success: true,
      message: 'Channel listing deleted successfully'
    });
  }

  async sync(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, channelId } = req.params;

    // Publish event for immediate sync
    const { publishToQueue } = await import('@galeri/shared/utils/rabbitmq');
    await publishToQueue('channel_sync_queue', {
      vehicleId,
      channelId,
      action: 'update'
    });

    res.json({
      success: true,
      message: 'Sync initiated'
    });
  }
}

