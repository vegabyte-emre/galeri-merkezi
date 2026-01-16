import { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { query } from '@galeri/shared/database/connection';

const router = Router();

// Configure multer for video uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, '/tmp/uploads');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `video-${uuidv4()}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: {
    fileSize: 30 * 1024 * 1024, // 30 MB max
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['video/mp4', 'video/quicktime', 'video/webm', 'video/x-m4v'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid video format. Allowed: MP4, MOV, WebM'));
    }
  }
});

// Helper for async error handling
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => Promise.resolve(fn(req, res, next)).catch(next);

/**
 * POST /vehicles/video
 * Upload a video for a vehicle
 */
router.post('/', upload.single('video'), asyncHandler(async (req: Request, res: Response) => {
  const file = req.file;
  const { vehicleId, publishToOtoShorts } = req.body;
  const userId = (req as any).user?.id;
  const galleryId = (req as any).user?.galleryId;

  if (!file) {
    return res.status(400).json({
      success: false,
      error: 'No video file uploaded'
    });
  }

  if (!vehicleId) {
    return res.status(400).json({
      success: false,
      error: 'Vehicle ID is required'
    });
  }

  // In production, this would upload to MinIO/S3 and return the CDN URL
  // For now, we'll simulate the URL
  const videoUrl = `/uploads/videos/${file.filename}`;
  const thumbnailUrl = `/uploads/videos/thumbnails/${file.filename.replace(/\.[^.]+$/, '.jpg')}`;

  // Insert into vehicle_media table
  const mediaResult = await query(`
    INSERT INTO vehicle_media (vehicle_id, type, original_url, thumbnail_url, file_name, file_size, mime_type, processing_status, uploaded_by)
    VALUES ($1, 'video', $2, $3, $4, $5, $6, 'completed', $7)
    RETURNING id
  `, [vehicleId, videoUrl, thumbnailUrl, file.originalname, file.size, file.mimetype, userId]);

  // Update vehicle with video URL
  await query(`
    UPDATE vehicles 
    SET video_url = $1, 
        video_thumbnail_url = $2,
        publish_to_oto_shorts = $3,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = $4
  `, [videoUrl, thumbnailUrl, publishToOtoShorts === 'true', vehicleId]);

  // If publish to Oto Shorts is enabled, create an oto_shorts entry
  if (publishToOtoShorts === 'true' && galleryId) {
    // Get vehicle info for title
    const vehicleResult = await query(`
      SELECT brand, model, year FROM vehicles WHERE id = $1
    `, [vehicleId]);

    const vehicle = vehicleResult.rows[0];
    const title = vehicle ? `${vehicle.brand} ${vehicle.model} ${vehicle.year}` : 'Araç Videosu';

    await query(`
      INSERT INTO oto_shorts (vehicle_id, gallery_id, video_url, thumbnail_url, file_size_bytes, title, status, created_by)
      VALUES ($1, $2, $3, $4, $5, $6, 'pending', $7)
      ON CONFLICT (vehicle_id) 
      DO UPDATE SET 
        video_url = EXCLUDED.video_url,
        thumbnail_url = EXCLUDED.thumbnail_url,
        file_size_bytes = EXCLUDED.file_size_bytes,
        status = 'pending',
        updated_at = CURRENT_TIMESTAMP
    `, [vehicleId, galleryId, videoUrl, thumbnailUrl, file.size, title, userId]);
  }

  res.json({
    success: true,
    data: {
      mediaId: mediaResult.rows[0]?.id,
      videoUrl,
      thumbnailUrl,
      fileName: file.originalname,
      fileSize: file.size,
      publishedToOtoShorts: publishToOtoShorts === 'true'
    }
  });
}));

/**
 * DELETE /vehicles/video/:vehicleId
 * Remove video from a vehicle
 */
router.delete('/:vehicleId', asyncHandler(async (req: Request, res: Response) => {
  const { vehicleId } = req.params;

  // Remove from vehicle_media
  await query(`
    DELETE FROM vehicle_media WHERE vehicle_id = $1 AND type = 'video'
  `, [vehicleId]);

  // Update vehicle
  await query(`
    UPDATE vehicles 
    SET video_url = NULL, 
        video_thumbnail_url = NULL,
        publish_to_oto_shorts = FALSE,
        oto_shorts_status = NULL,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = $1
  `, [vehicleId]);

  // Remove from oto_shorts
  await query(`
    DELETE FROM oto_shorts WHERE vehicle_id = $1
  `, [vehicleId]);

  res.json({
    success: true,
    message: 'Video removed successfully'
  });
}));

/**
 * GET /vehicles/video/:vehicleId
 * Get video info for a vehicle
 */
router.get('/:vehicleId', asyncHandler(async (req: Request, res: Response) => {
  const { vehicleId } = req.params;

  const result = await query(`
    SELECT 
      v.video_url,
      v.video_thumbnail_url,
      v.publish_to_oto_shorts,
      v.oto_shorts_status,
      vm.file_name,
      vm.file_size,
      vm.duration_seconds,
      os.view_count,
      os.like_count,
      os.status as shorts_status,
      os.published_at as shorts_published_at
    FROM vehicles v
    LEFT JOIN vehicle_media vm ON vm.vehicle_id = v.id AND vm.type = 'video'
    LEFT JOIN oto_shorts os ON os.vehicle_id = v.id
    WHERE v.id = $1
  `, [vehicleId]);

  if (result.rows.length === 0) {
    return res.status(404).json({
      success: false,
      error: 'Vehicle not found'
    });
  }

  res.json({
    success: true,
    data: result.rows[0]
  });
}));

export { router as videoRoutes };
