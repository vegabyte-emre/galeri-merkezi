import { Router, Request, Response } from 'express';
import { GalleryController } from '../controllers/galleryController';
import { query } from '@galeri/shared/database/connection';

const router = Router();
const controller = new GalleryController();

// List all galleries (for mobile app marketplace)
router.get('/', async (req: Request, res: Response) => {
  try {
    const { city, district, search, limit = 50, skip = 0 } = req.query;
    const currentGalleryId = req.headers['x-gallery-id'] as string;
    
    let whereClause = "WHERE status = 'active'";
    const params: any[] = [];
    let paramCount = 1;
    
    // Exclude current gallery
    if (currentGalleryId) {
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
    
    const result = await query(
      `SELECT id, name, slug, phone, email, city, district, logo_url, cover_url, 
              working_hours, latitude, longitude, created_at
       FROM galleries 
       ${whereClause}
       ORDER BY created_at DESC
       LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), Number(skip)]
    );
    
    const countResult = await query(
      `SELECT COUNT(*) as total FROM galleries ${whereClause}`,
      params
    );
    
    res.json({
      success: true,
      data: result.rows,
      pagination: {
        total: parseInt(countResult.rows[0].total),
        limit: Number(limit),
        skip: Number(skip)
      }
    });
  } catch (error: any) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get single gallery by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const result = await query(
      `SELECT g.id, g.name, g.slug, g.phone, g.email, g.city, g.district, 
              g.neighborhood, g.address, g.logo_url, g.cover_url, 
              g.working_hours, g.latitude, g.longitude, g.created_at,
              (SELECT COUNT(*) FROM vehicles WHERE gallery_id = g.id AND status = 'published') as vehicle_count
       FROM galleries g
       WHERE g.id = $1`,
      [id]
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

// My gallery
router.get('/my', controller.getMyGallery.bind(controller));
router.put('/my', controller.updateMyGallery.bind(controller));
router.put('/my/logo', controller.uploadLogo.bind(controller));
router.put('/my/cover', controller.uploadCover.bind(controller));
router.get('/my/stats', controller.getMyGalleryStats.bind(controller));

// Settings  
router.get('/settings', controller.getSettings.bind(controller));
router.put('/settings', controller.updateSettings.bind(controller));

export { router as galleryRoutes };
















