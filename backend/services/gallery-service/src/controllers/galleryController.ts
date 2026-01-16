import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { ValidationError } from '@galeri/shared/utils/errors';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
  };
}

export class GalleryController {
  async getMyGallery(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      `SELECT * FROM galleries WHERE id = $1`,
      [galleryId]
    );

    if (result.rows.length === 0) {
      throw new ValidationError('Gallery not found');
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async updateMyGallery(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const updates = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const allowedFields = [
      'name', 'phone', 'whatsapp', 'email', 'city', 'district',
      'neighborhood', 'address', 'latitude', 'longitude', 'working_hours'
    ];

    const updateFields: string[] = [];
    const values: any[] = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      if (allowedFields.includes(key)) {
        updateFields.push(`${key} = $${paramCount++}`);
        values.push(value);
      }
    }

    if (updateFields.length === 0) {
      throw new ValidationError('No valid fields to update');
    }

    updateFields.push(`updated_at = NOW()`);
    values.push(galleryId);

    await query(
      `UPDATE galleries SET ${updateFields.join(', ')} WHERE id = $${paramCount}`,
      values
    );

    res.json({
      success: true,
      message: 'Gallery updated successfully'
    });
  }

  async uploadLogo(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { logoUrl } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    await query(
      'UPDATE galleries SET logo_url = $1, updated_at = NOW() WHERE id = $2',
      [logoUrl, galleryId]
    );

    res.json({
      success: true,
      message: 'Logo updated successfully'
    });
  }

  async uploadCover(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { coverUrl } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    await query(
      'UPDATE galleries SET cover_url = $1, updated_at = NOW() WHERE id = $2',
      [coverUrl, galleryId]
    );

    res.json({
      success: true,
      message: 'Cover image updated successfully'
    });
  }

  async getMyGalleryStats(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const stats = await query(
      `SELECT 
        (SELECT COUNT(*) FROM vehicles WHERE gallery_id = $1) as total_vehicles,
        (SELECT COUNT(*) FROM vehicles WHERE gallery_id = $1 AND status = 'published') as published_vehicles,
        (SELECT COUNT(*) FROM offers WHERE seller_gallery_id = $1 OR buyer_gallery_id = $1) as total_offers,
        (SELECT COUNT(*) FROM offers WHERE seller_gallery_id = $1 AND status = 'sent') as incoming_offers
      `,
      [galleryId]
    );

    res.json({
      success: true,
      data: stats.rows[0]
    });
  }

  async getSettings(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Get gallery profile
    const galleryResult = await query(
      `SELECT name, email, phone, address, city, district, whatsapp, working_hours, logo_url 
       FROM galleries WHERE id = $1`,
      [galleryId]
    );

    // Get connected channels
    const channelsResult = await query(
      `SELECT c.id, c.name, c.type, gcc.status, gcc.last_sync_at
       FROM channels c
       LEFT JOIN gallery_channel_credentials gcc ON gcc.channel_id = c.id AND gcc.gallery_id = $1
       WHERE c.status = 'active'
       ORDER BY c.name`,
      [galleryId]
    );

    // Get notification settings from system_settings
    const notifResult = await query(
      `SELECT value FROM system_settings WHERE key = $1 LIMIT 1`,
      [`gallery_${galleryId}_notifications`]
    );

    const defaultNotifications = {
      newOffer: true,
      newMessage: true,
      offerAccepted: true,
      offerRejected: true,
      vehicleSold: true
    };

    let notificationSettings = defaultNotifications;
    if (notifResult.rows.length > 0) {
      try {
        notificationSettings = { ...defaultNotifications, ...JSON.parse(notifResult.rows[0].value) };
      } catch (e) {
        // Use defaults
      }
    }

    res.json({
      success: true,
      data: {
        profile: galleryResult.rows[0] || {},
        channels: channelsResult.rows.map((ch: any) => ({
          id: ch.id,
          name: ch.name,
          type: ch.type,
          status: ch.status || 'disconnected',
          lastSyncAt: ch.last_sync_at
        })),
        notifications: notificationSettings
      }
    });
  }

  async updateSettings(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { profile, notifications } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // Update profile if provided
    if (profile) {
      const allowedFields = ['name', 'email', 'phone', 'address', 'city', 'district', 'whatsapp', 'working_hours'];
      const updateFields: string[] = [];
      const values: any[] = [];
      let paramCount = 1;

      for (const [key, value] of Object.entries(profile)) {
        if (allowedFields.includes(key)) {
          updateFields.push(`${key} = $${paramCount++}`);
          values.push(value);
        }
      }

      if (updateFields.length > 0) {
        updateFields.push(`updated_at = NOW()`);
        values.push(galleryId);

        await query(
          `UPDATE galleries SET ${updateFields.join(', ')} WHERE id = $${paramCount}`,
          values
        );
      }
    }

    // Update notification settings if provided
    if (notifications) {
      const settingsKey = `gallery_${galleryId}_notifications`;
      
      // Check if exists
      const existing = await query(
        `SELECT id FROM system_settings WHERE key = $1`,
        [settingsKey]
      );

      if (existing.rows.length === 0) {
        await query(
          `INSERT INTO system_settings (key, value, description) VALUES ($1, $2, $3)`,
          [settingsKey, JSON.stringify(notifications), `Notification settings for gallery ${galleryId}`]
        );
      } else {
        await query(
          `UPDATE system_settings SET value = $1, updated_at = NOW() WHERE key = $2`,
          [JSON.stringify(notifications), settingsKey]
        );
      }
    }

    res.json({
      success: true,
      message: 'Ayarlar basariyla guncellendi'
    });
  }
}
















