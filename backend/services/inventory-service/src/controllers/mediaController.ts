import { Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';
import { v4 as uuidv4 } from 'uuid';
import { ValidationError } from '@galeri/shared/utils/errors';
import { PresignedUrlService } from '../services/presignedUrlService';
import { EventPublisher } from '../services/eventPublisher';

interface AuthenticatedRequest extends Request {
  user?: {
    sub: string;
    gallery_id?: string;
  };
}

export class MediaController {
  private presignedUrlService = new PresignedUrlService();

  async getPresignedUrl(req: AuthenticatedRequest, res: Response) {
    const { vehicleId } = req.params;
    const { fileName, fileType } = req.body;

    if (!fileName || !fileType) {
      throw new ValidationError('File name and type are required');
    }

    const { uploadUrl, fileKey } = await this.presignedUrlService.generateUploadUrl(
      vehicleId,
      fileType,
      fileName
    );

    res.json({
      success: true,
      data: {
        uploadUrl,
        fileKey
      }
    });
  }

  async list(req: AuthenticatedRequest, res: Response) {
    const { vehicleId } = req.params;

    const result = await query(
      'SELECT * FROM vehicle_media WHERE vehicle_id = $1 ORDER BY sort_order, created_at',
      [vehicleId]
    );

    res.json({
      success: true,
      data: result.rows
    });
  }

  async upload(req: AuthenticatedRequest, res: Response) {
    const { vehicleId } = req.params;
    const { type, originalUrl, fileName, fileSize, mimeType } = req.body;

    // TODO: Upload to MinIO and get URLs
    // For now, just store the reference

    const result = await query(
      `INSERT INTO vehicle_media (
        vehicle_id, type, original_url, file_name, file_size, mime_type, processing_status
      ) VALUES ($1, $2, $3, $4, $5, $6, 'pending')
      RETURNING *`,
      [vehicleId, type, originalUrl, fileName, fileSize, mimeType]
    );

    // Publish event for media processing
    await this.eventPublisher.publishMediaProcessing(
      result.rows[0].id,
      vehicleId,
      type,
      originalUrl
    );

    res.json({
      success: true,
      data: result.rows[0]
    });
  }

  async update(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, mediaId } = req.params;
    const { sortOrder, isCover } = req.body;

    if (isCover) {
      // Remove cover from other media
      await query(
        'UPDATE vehicle_media SET is_cover = FALSE WHERE vehicle_id = $1',
        [vehicleId]
      );
    }

    await query(
      `UPDATE vehicle_media 
       SET sort_order = COALESCE($1, sort_order), 
           is_cover = COALESCE($2, is_cover),
           updated_at = NOW()
       WHERE id = $3 AND vehicle_id = $4`,
      [sortOrder, isCover, mediaId, vehicleId]
    );

    res.json({
      success: true,
      message: 'Media updated successfully'
    });
  }

  async delete(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, mediaId } = req.params;

    await query(
      'DELETE FROM vehicle_media WHERE id = $1 AND vehicle_id = $2',
      [mediaId, vehicleId]
    );

    // TODO: Delete from MinIO

    res.json({
      success: true,
      message: 'Media deleted successfully'
    });
  }

  async setCover(req: AuthenticatedRequest, res: Response) {
    const { vehicleId, mediaId } = req.params;

    // Remove cover from all media
    await query(
      'UPDATE vehicle_media SET is_cover = FALSE WHERE vehicle_id = $1',
      [vehicleId]
    );

    // Set new cover
    await query(
      'UPDATE vehicle_media SET is_cover = TRUE WHERE id = $1 AND vehicle_id = $2',
      [mediaId, vehicleId]
    );

    res.json({
      success: true,
      message: 'Cover image set successfully'
    });
  }
}

