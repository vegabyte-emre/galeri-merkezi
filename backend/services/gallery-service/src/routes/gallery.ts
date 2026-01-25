import { Router, Request, Response } from 'express';
import { GalleryController } from '../controllers/galleryController';
import { query } from '@galeri/shared/database/connection';

const router = Router();
const controller = new GalleryController();

// =========================
// IMPORTANT: Route ordering
// =========================
// Static routes like /my and /settings MUST come before "/:id"
// otherwise Express will treat "my" or "settings" as an :id param.

// List all galleries (for both admin panel and mobile app)
router.get('/', async (req: Request, res: Response) => {
  try {
    const { city, district, search, status, limit = 50, skip = 0, page } = req.query;
    const currentGalleryId = req.headers['x-gallery-id'] as string;
    const userRole = req.headers['x-user-role'] as string;
    
    // Admin roles can see all statuses, others only see active
    const isAdmin = ['superadmin', 'admin', 'compliance_officer'].includes(userRole);
    
    let whereClause = 'WHERE 1=1';
    const params: any[] = [];
    let paramCount = 1;
    
    // Non-admin users only see active galleries
    if (!isAdmin) {
      whereClause += " AND status = 'active'";
    } else if (status) {
      whereClause += ` AND status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }
    
    // Exclude current gallery for mobile marketplace
    if (currentGalleryId && !isAdmin) {
      whereClause += ` AND id != $${paramCount}`;
      params.push(currentGalleryId);
      paramCount++;
    }
    
    if (city) {
      whereClause += ` AND city = $${paramCount}`;
      params.push(city);
      paramCount++;
    }
    
    if (district) {
      whereClause += ` AND district = $${paramCount}`;
      params.push(district);
      paramCount++;
    }
    
    if (search) {
      whereClause += ` AND (LOWER(name) LIKE LOWER($${paramCount}) OR LOWER(city) LIKE LOWER($${paramCount}))`;
      params.push(`%${search}%`);
      paramCount++;
    }
    
    // Calculate offset from page if provided
    const actualLimit = Number(limit);
    const actualOffset = page ? (Number(page) - 1) * actualLimit : Number(skip);
    
    const result = await query(
      `SELECT id, name, slug, phone, email, city, district, status, logo_url, cover_url, 
              working_hours, latitude, longitude, created_at, updated_at
       FROM galleries 
       ${whereClause}
       ORDER BY created_at DESC
       LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, actualLimit, actualOffset]
    );
    
    const countResult = await query(
      `SELECT COUNT(*) as total FROM galleries ${whereClause}`,
      params
    );
    
    const total = parseInt(countResult.rows[0].total);
    
    // Return in format compatible with both admin panel and mobile
    res.json({
      success: true,
      galleries: result.rows,  // For admin panel compatibility
      data: result.rows,       // For mobile app compatibility
      pagination: {
        total,
        limit: actualLimit,
        skip: actualOffset,
        page: page ? Number(page) : Math.floor(actualOffset / actualLimit) + 1,
        totalPages: Math.ceil(total / actualLimit)
      }
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// My gallery
router.get('/my', controller.getMyGallery.bind(controller));
router.put('/my', controller.updateMyGallery.bind(controller));
router.put('/my/logo', controller.uploadLogo.bind(controller));
router.put('/my/cover', controller.uploadCover.bind(controller));
router.get('/my/stats', controller.getMyGalleryStats.bind(controller));

// Settings  
router.get('/settings', controller.getSettings.bind(controller));
router.put('/settings', controller.updateSettings.bind(controller));

// Get single gallery by ID or slug (SEO-friendly)
router.get('/:idOrSlug', async (req: Request, res: Response) => {
  try {
    const { idOrSlug } = req.params;
    
    // Check if it's a UUID or a slug
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(idOrSlug);
    
    const result = await query(
      `SELECT g.id, g.name, g.slug, g.phone, g.email, g.city, g.district, 
              g.neighborhood, g.address, g.logo_url, g.cover_url, 
              g.working_hours, g.latitude, g.longitude, g.created_at,
              (SELECT COUNT(*) FROM vehicles WHERE gallery_id = g.id AND status = 'published') as vehicle_count
       FROM galleries g
       WHERE ${isUUID ? 'g.id = $1' : 'g.slug = $1'}`,
      [idOrSlug]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Gallery not found' });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Admin actions on galleries
router.post('/:id/approve', async (req: Request, res: Response) => {
  try {
    const userRole = req.headers['x-user-role'] as string;
    const userId = req.headers['x-user-id'] as string;
    
    if (!['superadmin', 'admin'].includes(userRole)) {
      return res.status(403).json({ success: false, message: 'Only admin can approve galleries' });
    }
    
    const { id } = req.params;
    await query(
      `UPDATE galleries SET status = 'active', approved_at = NOW(), approved_by = $1, updated_at = NOW() WHERE id = $2`,
      [userId, id]
    );
    
    res.json({ success: true, message: 'Gallery approved successfully' });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/:id/reject', async (req: Request, res: Response) => {
  try {
    const userRole = req.headers['x-user-role'] as string;
    
    if (!['superadmin', 'admin'].includes(userRole)) {
      return res.status(403).json({ success: false, message: 'Only admin can reject galleries' });
    }
    
    const { id } = req.params;
    const { reason } = req.body;
    
    await query(
      `UPDATE galleries SET status = 'rejected', rejection_reason = $1, updated_at = NOW() WHERE id = $2`,
      [reason || 'No reason provided', id]
    );
    
    res.json({ success: true, message: 'Gallery rejected' });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/:id/suspend', async (req: Request, res: Response) => {
  try {
    const userRole = req.headers['x-user-role'] as string;
    
    if (!['superadmin', 'admin'].includes(userRole)) {
      return res.status(403).json({ success: false, message: 'Only admin can suspend galleries' });
    }
    
    const { id } = req.params;
    await query(
      `UPDATE galleries SET status = 'suspended', updated_at = NOW() WHERE id = $1`,
      [id]
    );
    
    res.json({ success: true, message: 'Gallery suspended' });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

export { router as galleryRoutes };
















