import { Router, Request, Response, NextFunction } from 'express';
import { query } from '@galeri/shared/database/connection';

const router = Router();

// Helper for async error handling
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => Promise.resolve(fn(req, res, next)).catch(next);

interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    gallery_id: string;
    role: string;
  };
}

function getUserFromHeaders(req: AuthenticatedRequest) {
  return {
    userId: req.headers['x-user-id'] as string || req.user?.id,
    galleryId: req.headers['x-gallery-id'] as string || req.user?.gallery_id,
    role: req.headers['x-user-role'] as string || req.user?.role
  };
}

/**
 * GET /shorts
 * Get all shorts feed (public)
 */
router.get('/', asyncHandler(async (req: Request, res: Response) => {
  const { gallery_id, limit = 20, skip = 0 } = req.query;
  const { userId } = getUserFromHeaders(req as AuthenticatedRequest);

  let whereClause = "os.status = 'published'";
  const params: any[] = [];
  let paramIndex = 1;

  if (gallery_id) {
    whereClause += ` AND os.gallery_id = $${paramIndex}`;
    params.push(gallery_id);
    paramIndex++;
  }

  const result = await query(`
    SELECT 
      os.id,
      os.vehicle_id,
      os.gallery_id,
      os.video_url as video,
      os.thumbnail_url as thumbnail,
      os.title,
      os.view_count as views,
      os.like_count,
      os.comment_count,
      os.created_at,
      os.updated_at,
      g.name as gallery_name,
      g.logo_url as gallery_logo,
      v.brand,
      v.model,
      v.year,
      v.price,
      v.currency,
      v.mileage,
      v.fuel_type,
      v.transmission,
      v.status as vehicle_status,
      CASE WHEN sl.user_id IS NOT NULL THEN true ELSE false END as liked_by_me
    FROM oto_shorts os
    JOIN galleries g ON g.id = os.gallery_id
    JOIN vehicles v ON v.id = os.vehicle_id
    LEFT JOIN shorts_likes sl ON sl.short_id = os.id AND sl.user_id = $${paramIndex}
    WHERE ${whereClause}
    ORDER BY os.created_at DESC
    LIMIT $${paramIndex + 1} OFFSET $${paramIndex + 2}
  `, [...params, userId || null, parseInt(limit as string), parseInt(skip as string)]);

  // Transform data
  const shorts = result.rows.map(row => ({
    id: row.id,
    vehicle_id: row.vehicle_id,
    gallery_id: row.gallery_id,
    video: row.video,
    thumbnail: row.thumbnail,
    title: row.title,
    views: row.views || 0,
    like_count: row.like_count || 0,
    comment_count: row.comment_count || 0,
    created_at: row.created_at,
    liked_by_me: row.liked_by_me,
    gallery: {
      id: row.gallery_id,
      gallery_name: row.gallery_name,
      logo: row.gallery_logo,
    },
    vehicle: {
      id: row.vehicle_id,
      brand: row.brand,
      model: row.model,
      year: row.year,
      price: row.price,
      currency: row.currency || 'TRY',
      mileage: row.mileage,
      fuel_type: row.fuel_type,
      transmission: row.transmission,
      status: row.vehicle_status,
    },
    likes: [],
    comments: [],
  }));

  res.json({
    success: true,
    data: shorts
  });
}));

/**
 * GET /shorts/my
 * Get my gallery's shorts
 */
router.get('/my', asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const { galleryId } = getUserFromHeaders(req);

  if (!galleryId) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }

  const result = await query(`
    SELECT 
      os.*,
      v.brand,
      v.model,
      v.year,
      v.price,
      v.currency
    FROM oto_shorts os
    JOIN vehicles v ON v.id = os.vehicle_id
    WHERE os.gallery_id = $1
    ORDER BY os.created_at DESC
  `, [galleryId]);

  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /shorts/:id
 * Get single short
 */
router.get('/:id', asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { userId } = getUserFromHeaders(req as AuthenticatedRequest);

  const result = await query(`
    SELECT 
      os.*,
      g.name as gallery_name,
      g.logo_url as gallery_logo,
      v.brand,
      v.model,
      v.year,
      v.price,
      v.currency,
      v.mileage,
      v.fuel_type,
      v.transmission,
      CASE WHEN sl.user_id IS NOT NULL THEN true ELSE false END as liked_by_me
    FROM oto_shorts os
    JOIN galleries g ON g.id = os.gallery_id
    JOIN vehicles v ON v.id = os.vehicle_id
    LEFT JOIN shorts_likes sl ON sl.short_id = os.id AND sl.user_id = $2
    WHERE os.id = $1
  `, [id, userId || null]);

  if (result.rows.length === 0) {
    return res.status(404).json({
      success: false,
      error: 'Short not found'
    });
  }

  res.json({
    success: true,
    data: result.rows[0]
  });
}));

/**
 * POST /shorts/:id/like
 * Like/unlike a short
 */
router.post('/:id/like', asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const { id } = req.params;
  const { userId, galleryId } = getUserFromHeaders(req);

  if (!userId) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }

  // Check if already liked
  const existingLike = await query(`
    SELECT id FROM shorts_likes WHERE short_id = $1 AND user_id = $2
  `, [id, userId]);

  if (existingLike.rows.length > 0) {
    // Unlike
    await query(`DELETE FROM shorts_likes WHERE short_id = $1 AND user_id = $2`, [id, userId]);
    await query(`UPDATE oto_shorts SET like_count = GREATEST(0, like_count - 1) WHERE id = $1`, [id]);
    
    res.json({
      success: true,
      liked: false,
      message: 'Unliked successfully'
    });
  } else {
    // Like
    await query(`
      INSERT INTO shorts_likes (short_id, user_id, gallery_id, created_at)
      VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
      ON CONFLICT (short_id, user_id) DO NOTHING
    `, [id, userId, galleryId]);
    await query(`UPDATE oto_shorts SET like_count = like_count + 1 WHERE id = $1`, [id]);
    
    res.json({
      success: true,
      liked: true,
      message: 'Liked successfully'
    });
  }
}));

/**
 * POST /shorts/:id/comment
 * Add comment to a short
 */
router.post('/:id/comment', asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const { id } = req.params;
  const { content } = req.body;
  const { userId, galleryId } = getUserFromHeaders(req);

  if (!userId) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }

  if (!content || content.trim().length === 0) {
    return res.status(400).json({
      success: false,
      error: 'Comment content is required'
    });
  }

  // Get gallery name
  const galleryResult = await query(`SELECT name FROM galleries WHERE id = $1`, [galleryId]);
  const galleryName = galleryResult.rows[0]?.name || 'Galeri';

  const result = await query(`
    INSERT INTO shorts_comments (short_id, user_id, gallery_id, gallery_name, content, created_at)
    VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
    RETURNING id, user_id, gallery_name, content, created_at
  `, [id, userId, galleryId, galleryName, content.trim()]);

  // Update comment count
  await query(`UPDATE oto_shorts SET comment_count = comment_count + 1 WHERE id = $1`, [id]);

  res.json({
    success: true,
    data: result.rows[0]
  });
}));

/**
 * GET /shorts/:id/comments
 * Get comments for a short
 */
router.get('/:id/comments', asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { limit = 50, skip = 0 } = req.query;

  const result = await query(`
    SELECT 
      sc.id,
      sc.user_id,
      sc.gallery_name,
      sc.content,
      sc.created_at,
      g.logo_url as gallery_logo
    FROM shorts_comments sc
    LEFT JOIN galleries g ON g.id = sc.gallery_id
    WHERE sc.short_id = $1
    ORDER BY sc.created_at DESC
    LIMIT $2 OFFSET $3
  `, [id, parseInt(limit as string), parseInt(skip as string)]);

  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * DELETE /shorts/:id/comments/:commentId
 * Delete a comment
 */
router.delete('/:id/comments/:commentId', asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const { id, commentId } = req.params;
  const { userId } = getUserFromHeaders(req);

  if (!userId) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }

  // Check ownership
  const comment = await query(`
    SELECT user_id FROM shorts_comments WHERE id = $1 AND short_id = $2
  `, [commentId, id]);

  if (comment.rows.length === 0) {
    return res.status(404).json({
      success: false,
      error: 'Comment not found'
    });
  }

  if (comment.rows[0].user_id !== userId) {
    return res.status(403).json({
      success: false,
      error: 'Not authorized to delete this comment'
    });
  }

  await query(`DELETE FROM shorts_comments WHERE id = $1`, [commentId]);
  await query(`UPDATE oto_shorts SET comment_count = GREATEST(0, comment_count - 1) WHERE id = $1`, [id]);

  res.json({
    success: true,
    message: 'Comment deleted successfully'
  });
}));

/**
 * POST /shorts/:id/view
 * Record a view
 */
router.post('/:id/view', asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;

  await query(`UPDATE oto_shorts SET view_count = view_count + 1 WHERE id = $1`, [id]);

  res.json({
    success: true,
    message: 'View recorded'
  });
}));

/**
 * POST /shorts/:id/share
 * Record a share
 */
router.post('/:id/share', asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { platform } = req.body;

  await query(`UPDATE oto_shorts SET share_count = share_count + 1 WHERE id = $1`, [id]);

  res.json({
    success: true,
    message: 'Share recorded'
  });
}));

/**
 * POST /shorts/:id/report
 * Report a short
 */
router.post('/:id/report', asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const { id } = req.params;
  const { reason, description } = req.body;
  const { userId } = getUserFromHeaders(req);

  if (!userId) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }

  if (!reason) {
    return res.status(400).json({
      success: false,
      error: 'Report reason is required'
    });
  }

  await query(`
    INSERT INTO shorts_reports (short_id, user_id, reason, description, created_at)
    VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
  `, [id, userId, reason, description || null]);

  res.json({
    success: true,
    message: 'Report submitted successfully'
  });
}));

/**
 * DELETE /shorts/:id
 * Delete own short
 */
router.delete('/:id', asyncHandler(async (req: AuthenticatedRequest, res: Response) => {
  const { id } = req.params;
  const { galleryId } = getUserFromHeaders(req);

  if (!galleryId) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }

  // Check ownership
  const short = await query(`SELECT gallery_id FROM oto_shorts WHERE id = $1`, [id]);

  if (short.rows.length === 0) {
    return res.status(404).json({
      success: false,
      error: 'Short not found'
    });
  }

  if (short.rows[0].gallery_id !== galleryId) {
    return res.status(403).json({
      success: false,
      error: 'Not authorized to delete this short'
    });
  }

  await query(`DELETE FROM shorts_comments WHERE short_id = $1`, [id]);
  await query(`DELETE FROM shorts_likes WHERE short_id = $1`, [id]);
  await query(`DELETE FROM oto_shorts WHERE id = $1`, [id]);

  res.json({
    success: true,
    message: 'Short deleted successfully'
  });
}));

export { router as shortsRoutes };
