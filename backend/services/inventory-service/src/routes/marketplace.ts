import { Router, Request, Response } from 'express';
import { query } from '@galeri/shared/database/connection';

const router = Router();

// Public endpoint - Get all published vehicles for marketplace
// If user is logged in, exclude their own gallery's vehicles
router.get('/', async (req: Request, res: Response) => {
  try {
    const { 
      page = 1, 
      limit = 20, 
      brand, 
      minPrice, 
      maxPrice, 
      minYear, 
      maxYear,
      fuelType,
      transmission,
      city,
      sort = 'newest'
    } = req.query;

    // Get gallery_id from headers (set by API Gateway if user is authenticated)
    const currentGalleryId = req.headers['x-gallery-id'] as string | undefined;

    const offset = (Number(page) - 1) * Number(limit);
    let whereClause = "WHERE v.status = 'published'";
    const params: any[] = [];
    let paramCount = 1;

    // Exclude current user's gallery vehicles if logged in
    if (currentGalleryId) {
      whereClause += ` AND v.gallery_id != $${paramCount++}`;
      params.push(currentGalleryId);
    }

    if (brand) {
      whereClause += ` AND v.brand = $${paramCount++}`;
      params.push(brand);
    }

    if (minPrice) {
      whereClause += ` AND v.base_price >= $${paramCount++}`;
      params.push(Number(minPrice));
    }

    if (maxPrice) {
      whereClause += ` AND v.base_price <= $${paramCount++}`;
      params.push(Number(maxPrice));
    }

    if (minYear) {
      whereClause += ` AND v.year >= $${paramCount++}`;
      params.push(Number(minYear));
    }

    if (maxYear) {
      whereClause += ` AND v.year <= $${paramCount++}`;
      params.push(Number(maxYear));
    }

    if (fuelType) {
      whereClause += ` AND v.fuel_type = $${paramCount++}`;
      params.push(fuelType);
    }

    if (transmission) {
      whereClause += ` AND v.transmission = $${paramCount++}`;
      params.push(transmission);
    }

    if (city) {
      whereClause += ` AND g.city = $${paramCount++}`;
      params.push(city);
    }

    let orderBy = 'ORDER BY v.published_at DESC';
    if (sort === 'price_asc') orderBy = 'ORDER BY v.base_price ASC';
    else if (sort === 'price_desc') orderBy = 'ORDER BY v.base_price DESC';
    else if (sort === 'year_desc') orderBy = 'ORDER BY v.year DESC';
    else if (sort === 'mileage_asc') orderBy = 'ORDER BY v.mileage ASC';

    const result = await query(
      `SELECT 
        v.id, v.listing_no, v.brand, v.series, v.model, v.year, 
        v.fuel_type, v.transmission, v.body_type, v.color,
        v.mileage, v.base_price, v.currency, v.description,
        v.has_warranty, v.published_at, v.created_at,
        g.id as gallery_id, g.name as gallery_name, g.city, g.district,
        g.logo_url as gallery_logo, g.phone as gallery_phone,
        (SELECT original_url FROM vehicle_media WHERE vehicle_id = v.id AND is_cover = true LIMIT 1) as primary_image,
        (SELECT COUNT(*) FROM vehicle_media WHERE vehicle_id = v.id) as image_count
      FROM vehicles v
      LEFT JOIN galleries g ON v.gallery_id = g.id
      ${whereClause}
      ${orderBy}
      LIMIT $${paramCount} OFFSET $${paramCount + 1}`,
      [...params, Number(limit), offset]
    );

    const countResult = await query(
      `SELECT COUNT(*) as total 
       FROM vehicles v 
       LEFT JOIN galleries g ON v.gallery_id = g.id 
       ${whereClause}`,
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
  } catch (error: any) {
    console.error('Marketplace list error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// Get single vehicle details (public)
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      `SELECT 
        v.*,
        g.id as gallery_id, g.name as gallery_name, g.city, g.district,
        g.logo_url as gallery_logo, g.phone as gallery_phone, g.address as gallery_address,
        g.working_hours
      FROM vehicles v
      LEFT JOIN galleries g ON v.gallery_id = g.id
      WHERE v.id = $1 AND v.status = 'published'`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Vehicle not found' });
    }

    // Get all images
    const mediaResult = await query(
      `SELECT * FROM vehicle_media WHERE vehicle_id = $1 ORDER BY sort_order, created_at`,
      [id]
    );

    // Increment view count
    await query('UPDATE vehicles SET view_count = COALESCE(view_count, 0) + 1 WHERE id = $1', [id]);

    res.json({
      success: true,
      data: {
        ...result.rows[0],
        images: mediaResult.rows
      }
    });
  } catch (error: any) {
    console.error('Marketplace get error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// Get available filter options
router.get('/filters/options', async (req: Request, res: Response) => {
  try {
    const brandsResult = await query(
      `SELECT DISTINCT brand FROM vehicles WHERE status = 'published' AND brand IS NOT NULL ORDER BY brand`
    );
    
    const citiesResult = await query(
      `SELECT DISTINCT g.city FROM vehicles v 
       LEFT JOIN galleries g ON v.gallery_id = g.id 
       WHERE v.status = 'published' AND g.city IS NOT NULL ORDER BY g.city`
    );

    const yearsResult = await query(
      `SELECT MIN(year) as min_year, MAX(year) as max_year FROM vehicles WHERE status = 'published'`
    );

    const pricesResult = await query(
      `SELECT MIN(base_price) as min_price, MAX(base_price) as max_price FROM vehicles WHERE status = 'published'`
    );

    res.json({
      success: true,
      data: {
        brands: brandsResult.rows.map(r => r.brand),
        cities: citiesResult.rows.map(r => r.city),
        fuelTypes: ['benzin', 'dizel', 'elektrik', 'hibrit', 'lpg'],
        transmissions: ['manuel', 'otomatik', 'yari_otomatik'],
        yearRange: yearsResult.rows[0],
        priceRange: pricesResult.rows[0]
      }
    });
  } catch (error: any) {
    console.error('Filters error:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

export { router as marketplaceRoutes };
