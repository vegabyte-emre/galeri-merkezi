import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { ValidationError } from '@galeri/shared/utils/errors';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
  };
}

export class ChannelController {
  async getMyChannels(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    const result = await query(
      `SELECT c.*, gcc.is_active, gcc.verified_at, gcc.last_used_at
       FROM channels c
       LEFT JOIN gallery_channel_credentials gcc ON c.id = gcc.channel_id AND gcc.gallery_id = $1
       WHERE c.is_active = TRUE
       ORDER BY c.name`,
      [galleryId]
    );

    res.json({
      success: true,
      data: result.rows
    });
  }

  async setCredentials(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { channelId } = req.params;
    const { credentials } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // TODO: Encrypt credentials
    await query(
      `INSERT INTO gallery_channel_credentials (gallery_id, channel_id, credentials, is_active)
       VALUES ($1, $2, $3, FALSE)
       ON CONFLICT (gallery_id, channel_id) 
       DO UPDATE SET credentials = $3, updated_at = NOW()`,
      [galleryId, channelId, JSON.stringify(credentials)]
    );

    res.json({
      success: true,
      message: 'Credentials saved successfully'
    });
  }

  async updateCredentials(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { channelId } = req.params;
    const { credentials } = req.body;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    await query(
      `UPDATE gallery_channel_credentials 
       SET credentials = $1, updated_at = NOW()
       WHERE gallery_id = $2 AND channel_id = $3`,
      [JSON.stringify(credentials), galleryId, channelId]
    );

    res.json({
      success: true,
      message: 'Credentials updated successfully'
    });
  }

  async deleteCredentials(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { channelId } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    await query(
      'DELETE FROM gallery_channel_credentials WHERE gallery_id = $1 AND channel_id = $2',
      [galleryId, channelId]
    );

    res.json({
      success: true,
      message: 'Credentials deleted successfully'
    });
  }

  async verifyCredentials(req: AuthenticatedRequest, res: Response) {
    const galleryId = req.user?.gallery_id;
    const { channelId } = req.params;

    if (!galleryId) {
      throw new ValidationError('Gallery ID not found');
    }

    // TODO: Implement actual verification logic
    await query(
      `UPDATE gallery_channel_credentials 
       SET is_active = TRUE, verified_at = NOW()
       WHERE gallery_id = $1 AND channel_id = $2`,
      [galleryId, channelId]
    );

    res.json({
      success: true,
      message: 'Credentials verified successfully'
    });
  }
}
















