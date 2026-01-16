import sharp from 'sharp';
import { MinIOClient } from '../utils/minio';
import { query } from '@galeri/shared/database/connection';
import { logger } from '@galeri/shared/utils/logger';

interface MediaJob {
  mediaId: string;
  vehicleId: string;
  originalUrl: string;
  type: 'photo' | 'video' | 'document';
}

export class MediaProcessingService {
  private minio: MinIOClient;

  constructor() {
    this.minio = new MinIOClient();
  }

  async processMedia(job: MediaJob) {
    try {
      // Update status to processing
      await query(
        'UPDATE vehicle_media SET processing_status = $1 WHERE id = $2',
        ['processing', job.mediaId]
      );

      if (job.type === 'photo') {
        await this.processPhoto(job);
      } else if (job.type === 'video') {
        await this.processVideo(job);
      } else if (job.type === 'document') {
        await this.processDocument(job);
      }

      // Update status to completed
      await query(
        `UPDATE vehicle_media 
         SET processing_status = 'completed', updated_at = NOW()
         WHERE id = $1`,
        [job.mediaId]
      );

      logger.info('Media processing completed', { mediaId: job.mediaId });
    } catch (error: any) {
      logger.error('Media processing failed', { error: error.message, mediaId: job.mediaId });

      await query(
        `UPDATE vehicle_media 
         SET processing_status = 'failed', processing_error = $1
         WHERE id = $2`,
        [error.message, job.mediaId]
      );

      throw error;
    }
  }

  private async processPhoto(job: MediaJob) {
    // Download original
    const originalBuffer = await this.minio.download(job.originalUrl);

    // Process variants
    const variants = {
      original: { width: 2000, height: 1500, quality: 90 },
      large: { width: 1200, height: 800, quality: 85 },
      medium: { width: 600, height: 400, quality: 85 },
      thumb: { width: 300, height: 200, quality: 80 },
      mini: { width: 150, height: 100, quality: 75 }
    };

    const processedUrls: any = {};

    for (const [variant, config] of Object.entries(variants)) {
      let image = sharp(originalBuffer)
        .resize(config.width, config.height, {
          fit: 'inside',
          withoutEnlargement: true
        })
        .webp({ quality: config.quality });

      // Add watermark for large and original
      if (variant === 'large' || variant === 'original') {
        // TODO: Add watermark
      }

      const processedBuffer = await image.toBuffer();
      const fileName = `${job.mediaId}_${variant}.webp`;
      const url = await this.minio.upload(fileName, processedBuffer, 'image/webp');

      processedUrls[`${variant}_url`] = url;
    }

    // Update database with processed URLs
    await query(
      `UPDATE vehicle_media 
       SET large_url = $1, medium_url = $2, thumbnail_url = $3, 
           watermarked_url = $4, updated_at = NOW()
       WHERE id = $5`,
      [
        processedUrls.large_url,
        processedUrls.medium_url,
        processedUrls.thumb_url,
        processedUrls.large_url, // watermarked
        job.mediaId
      ]
    );
  }

  private async processVideo(job: MediaJob) {
    // TODO: Implement video processing with FFmpeg
    // For now, just create a placeholder
    logger.info('Video processing not yet implemented', { mediaId: job.mediaId });
  }

  private async processDocument(job: MediaJob) {
    // TODO: Implement document processing (PDF thumbnail)
    logger.info('Document processing not yet implemented', { mediaId: job.mediaId });
  }
}
















