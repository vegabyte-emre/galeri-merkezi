import { Router, Request, Response, NextFunction } from 'express';
import { query, getClient } from '@galeri/shared/database/connection';
import { uploadFile } from '@galeri/shared/utils/minio';
import { logger } from '@galeri/shared/utils/logger';
import multer from 'multer';

const router = Router();

// Helper for async error handling
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) => 
  (req: Request, res: Response, next: NextFunction) => Promise.resolve(fn(req, res, next)).catch(next);

/**
 * GET /catalog/classes
 * Get all vehicle classes
 */
router.get('/classes', asyncHandler(async (req: Request, res: Response) => {
  const result = await query(`
    SELECT id, name
    FROM vehicle_catalog_classes
    ORDER BY name ASC
  `);
  
  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /catalog/brands
 * Get all vehicle brands, optionally filtered by class
 */
router.get('/brands', asyncHandler(async (req: Request, res: Response) => {
  const { classId, popular } = req.query;
  
  let sql = `
    SELECT b.id, b.name, b.logo_url, b.is_popular, b.sort_order, c.name as class_name
    FROM vehicle_catalog_brands b
    JOIN vehicle_catalog_classes c ON b.class_id = c.id
    WHERE 1=1
  `;
  
  const params: any[] = [];
  let paramCount = 1;
  
  if (classId) {
    sql += ` AND b.class_id = $${paramCount++}`;
    params.push(classId);
  }
  
  if (popular === 'true') {
    sql += ` AND b.is_popular = true`;
  }
  
  sql += ` ORDER BY b.is_popular DESC, b.sort_order ASC, b.name ASC`;
  
  const result = await query(sql, params);
  
  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /catalog/brands/:brandId/series
 * Get all series for a specific brand
 */
router.get('/brands/:brandId/series', asyncHandler(async (req: Request, res: Response) => {
  const { brandId } = req.params;
  const { search } = req.query;
  
  let sql = `
    SELECT s.id, s.name, b.name as brand_name,
           (SELECT COUNT(*) FROM vehicle_catalog_models WHERE series_id = s.id) as model_count
    FROM vehicle_catalog_series s
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE s.brand_id = $1
  `;
  
  const params: any[] = [brandId];
  
  if (search) {
    sql += ` AND s.name ILIKE $2`;
    params.push(`%${search}%`);
  }
  
  sql += ` ORDER BY s.name ASC`;
  
  const result = await query(sql, params);
  
  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /catalog/series/:seriesId/models
 * Get all models for a specific series
 */
router.get('/series/:seriesId/models', asyncHandler(async (req: Request, res: Response) => {
  const { seriesId } = req.params;
  const { search } = req.query;
  
  let sql = `
    SELECT m.id, m.name, s.name as series_name, b.name as brand_name,
           (SELECT COUNT(*) FROM vehicle_catalog_alt_models WHERE model_id = m.id) as alt_model_count
    FROM vehicle_catalog_models m
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE m.series_id = $1
  `;
  
  const params: any[] = [seriesId];
  
  if (search) {
    sql += ` AND m.name ILIKE $2`;
    params.push(`%${search}%`);
  }
  
  sql += ` ORDER BY m.name ASC`;
  
  const result = await query(sql, params);
  
  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /catalog/models/:modelId/alt-models
 * Get all alt models for a specific model
 * Returns: id, name, has_multiple_trims (boolean), trim_count
 */
router.get('/models/:modelId/alt-models', asyncHandler(async (req: Request, res: Response) => {
  const { modelId } = req.params;
  const { search } = req.query;
  
  let sql = `
    SELECT 
      am.id, 
      am.name, 
      m.name as model_name, 
      s.name as series_name, 
      b.name as brand_name,
      (SELECT COUNT(*) FROM vehicle_catalog_trims WHERE alt_model_id = am.id) as trim_count,
      (SELECT COUNT(DISTINCT name) FROM vehicle_catalog_trims WHERE alt_model_id = am.id AND name IS NOT NULL AND name != '') as named_trim_count,
      CASE 
        WHEN (SELECT COUNT(DISTINCT name) FROM vehicle_catalog_trims WHERE alt_model_id = am.id AND name IS NOT NULL AND name != '') > 1 
        THEN true 
        ELSE false 
      END as has_multiple_trims
    FROM vehicle_catalog_alt_models am
    JOIN vehicle_catalog_models m ON am.model_id = m.id
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE am.model_id = $1
  `;
  
  const params: any[] = [modelId];
  
  if (search) {
    sql += ` AND am.name ILIKE $2`;
    params.push(`%${search}%`);
  }
  
  sql += ` ORDER BY am.name ASC`;
  
  const result = await query(sql, params);
  
  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /catalog/alt-models/:altModelId/trims
 * Get all trims for a specific alt model
 * If alt model has multiple named trims -> return list for selection
 * If alt model has single/no named trim -> return specs for auto-fill
 */
router.get('/alt-models/:altModelId/trims', asyncHandler(async (req: Request, res: Response) => {
  const { altModelId } = req.params;
  
  // First, check how many distinct named trims exist
  const countResult = await query(`
    SELECT 
      COUNT(*) as total_count,
      COUNT(DISTINCT CASE WHEN name IS NOT NULL AND name != '' THEN name END) as named_trim_count
    FROM vehicle_catalog_trims 
    WHERE alt_model_id = $1
  `, [altModelId]);
  
  const totalCount = parseInt(countResult.rows[0].total_count);
  const namedTrimCount = parseInt(countResult.rows[0].named_trim_count);
  
  // Get all trims with their specs
  const result = await query(`
    SELECT 
      t.id, 
      t.name, 
      t.body_type, 
      t.fuel_type, 
      t.transmission, 
      t.engine_power, 
      t.engine_displacement,
      am.name as alt_model_name, 
      m.name as model_name, 
      s.name as series_name, 
      b.name as brand_name
    FROM vehicle_catalog_trims t
    JOIN vehicle_catalog_alt_models am ON t.alt_model_id = am.id
    JOIN vehicle_catalog_models m ON am.model_id = m.id
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE t.alt_model_id = $1
    ORDER BY t.name ASC NULLS FIRST
  `, [altModelId]);
  
  // Determine if user needs to select a trim
  const requiresTrimSelection = namedTrimCount > 1;
  
  // If only one trim or no named trims, auto-fill with first spec
  let autoFillSpecs = null;
  if (!requiresTrimSelection && result.rows.length > 0) {
    const firstTrim = result.rows[0];
    autoFillSpecs = {
      body_type: firstTrim.body_type,
      fuel_type: firstTrim.fuel_type,
      transmission: firstTrim.transmission,
      engine_power: firstTrim.engine_power,
      engine_displacement: firstTrim.engine_displacement,
      trim_id: firstTrim.id,
      trim_name: firstTrim.name
    };
  }
  
  res.json({
    success: true,
    data: {
      requires_trim_selection: requiresTrimSelection,
      total_count: totalCount,
      named_trim_count: namedTrimCount,
      auto_fill_specs: autoFillSpecs,
      trims: result.rows
    }
  });
}));

/**
 * GET /catalog/models/:modelId/trims
 * Get all trims for a specific model (for models without alt models)
 */
router.get('/models/:modelId/trims', asyncHandler(async (req: Request, res: Response) => {
  const { modelId } = req.params;
  
  // Check how many distinct named trims exist
  const countResult = await query(`
    SELECT 
      COUNT(*) as total_count,
      COUNT(DISTINCT CASE WHEN name IS NOT NULL AND name != '' THEN name END) as named_trim_count
    FROM vehicle_catalog_trims 
    WHERE model_id = $1 AND alt_model_id IS NULL
  `, [modelId]);
  
  const totalCount = parseInt(countResult.rows[0].total_count);
  const namedTrimCount = parseInt(countResult.rows[0].named_trim_count);
  
  const result = await query(`
    SELECT 
      t.id, 
      t.name, 
      t.body_type, 
      t.fuel_type, 
      t.transmission, 
      t.engine_power, 
      t.engine_displacement,
      m.name as model_name, 
      s.name as series_name, 
      b.name as brand_name
    FROM vehicle_catalog_trims t
    JOIN vehicle_catalog_models m ON t.model_id = m.id
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE t.model_id = $1 AND t.alt_model_id IS NULL
    ORDER BY t.name ASC NULLS FIRST
  `, [modelId]);
  
  const requiresTrimSelection = namedTrimCount > 1;
  
  let autoFillSpecs = null;
  if (!requiresTrimSelection && result.rows.length > 0) {
    const firstTrim = result.rows[0];
    autoFillSpecs = {
      body_type: firstTrim.body_type,
      fuel_type: firstTrim.fuel_type,
      transmission: firstTrim.transmission,
      engine_power: firstTrim.engine_power,
      engine_displacement: firstTrim.engine_displacement,
      trim_id: firstTrim.id,
      trim_name: firstTrim.name
    };
  }
  
  res.json({
    success: true,
    data: {
      requires_trim_selection: requiresTrimSelection,
      total_count: totalCount,
      named_trim_count: namedTrimCount,
      auto_fill_specs: autoFillSpecs,
      trims: result.rows
    }
  });
}));

/**
 * GET /catalog/trims/:trimId
 * Get full specifications for a specific trim
 */
router.get('/trims/:trimId', asyncHandler(async (req: Request, res: Response) => {
  const { trimId } = req.params;
  
  const result = await query(`
    SELECT t.*,
           COALESCE(am.name, '') as alt_model_name,
           m.name as model_name,
           s.name as series_name,
           b.name as brand_name,
           b.logo_url as brand_logo
    FROM vehicle_catalog_trims t
    LEFT JOIN vehicle_catalog_alt_models am ON t.alt_model_id = am.id
    LEFT JOIN vehicle_catalog_models m ON COALESCE(am.model_id, t.model_id) = m.id
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE t.id = $1
  `, [trimId]);
  
  if (result.rows.length === 0) {
    return res.status(404).json({
      success: false,
      message: 'Trim not found'
    });
  }
  
  res.json({
    success: true,
    data: result.rows[0]
  });
}));

/**
 * GET /catalog/specifications
 * Get auto-fill specifications for a selected alt_model or model
 * This endpoint is called after alt_model selection to determine if trim selection is needed
 */
router.get('/specifications', asyncHandler(async (req: Request, res: Response) => {
  const { altModelId, modelId } = req.query;
  
  if (!altModelId && !modelId) {
    return res.status(400).json({
      success: false,
      message: 'altModelId or modelId is required'
    });
  }
  
  let countSql: string;
  let dataSql: string;
  let params: any[];
  
  if (altModelId) {
    countSql = `
      SELECT 
        COUNT(*) as total_count,
        COUNT(DISTINCT CASE WHEN name IS NOT NULL AND name != '' THEN name END) as named_trim_count
      FROM vehicle_catalog_trims 
      WHERE alt_model_id = $1
    `;
    dataSql = `
      SELECT 
        t.id as trim_id,
        t.name as trim_name,
        t.body_type, 
        t.fuel_type, 
        t.transmission, 
        t.engine_power, 
        t.engine_displacement,
        am.name as alt_model_name, 
        m.name as model_name,
        s.name as series_name, 
        b.name as brand_name
      FROM vehicle_catalog_trims t
      JOIN vehicle_catalog_alt_models am ON t.alt_model_id = am.id
      JOIN vehicle_catalog_models m ON am.model_id = m.id
      JOIN vehicle_catalog_series s ON m.series_id = s.id
      JOIN vehicle_catalog_brands b ON s.brand_id = b.id
      WHERE t.alt_model_id = $1
      ORDER BY t.name ASC NULLS FIRST
    `;
    params = [altModelId];
  } else {
    countSql = `
      SELECT 
        COUNT(*) as total_count,
        COUNT(DISTINCT CASE WHEN name IS NOT NULL AND name != '' THEN name END) as named_trim_count
      FROM vehicle_catalog_trims 
      WHERE model_id = $1 AND alt_model_id IS NULL
    `;
    dataSql = `
      SELECT 
        t.id as trim_id,
        t.name as trim_name,
        t.body_type, 
        t.fuel_type, 
        t.transmission, 
        t.engine_power, 
        t.engine_displacement,
        m.name as model_name, 
        s.name as series_name, 
        b.name as brand_name
      FROM vehicle_catalog_trims t
      JOIN vehicle_catalog_models m ON t.model_id = m.id
      JOIN vehicle_catalog_series s ON m.series_id = s.id
      JOIN vehicle_catalog_brands b ON s.brand_id = b.id
      WHERE t.model_id = $1 AND t.alt_model_id IS NULL
      ORDER BY t.name ASC NULLS FIRST
    `;
    params = [modelId];
  }
  
  const countResult = await query(countSql, params);
  const dataResult = await query(dataSql, params);
  
  const namedTrimCount = parseInt(countResult.rows[0].named_trim_count);
  const requiresTrimSelection = namedTrimCount > 1;
  
  // If no trim selection required, return auto-fill specs
  let autoFillSpecs = null;
  if (!requiresTrimSelection && dataResult.rows.length > 0) {
    const firstSpec = dataResult.rows[0];
    autoFillSpecs = {
      trim_id: firstSpec.trim_id,
      trim_name: firstSpec.trim_name,
      body_type: firstSpec.body_type,
      fuel_type: firstSpec.fuel_type,
      transmission: firstSpec.transmission,
      engine_power: firstSpec.engine_power,
      engine_displacement: firstSpec.engine_displacement
    };
  }
  
  // Get unique trims for selection (only if multiple named trims exist)
  let trimsForSelection: any[] = [];
  if (requiresTrimSelection) {
    // Get unique named trims
    const uniqueTrims = new Map();
    dataResult.rows.forEach((row: any) => {
      if (row.trim_name && !uniqueTrims.has(row.trim_name)) {
        uniqueTrims.set(row.trim_name, {
          id: row.trim_id,
          name: row.trim_name,
          body_type: row.body_type,
          fuel_type: row.fuel_type,
          transmission: row.transmission,
          engine_power: row.engine_power,
          engine_displacement: row.engine_displacement
        });
      }
    });
    trimsForSelection = Array.from(uniqueTrims.values());
  }
  
  res.json({
    success: true,
    data: {
      requires_trim_selection: requiresTrimSelection,
      named_trim_count: namedTrimCount,
      auto_fill_specs: autoFillSpecs,
      trims_for_selection: trimsForSelection,
      all_specs: dataResult.rows
    }
  });
}));

/**
 * GET /catalog/search
 * Search across brands, series, models
 */
router.get('/search', asyncHandler(async (req: Request, res: Response) => {
  const { q, limit = 20 } = req.query;
  
  if (!q || String(q).length < 2) {
    return res.json({
      success: true,
      data: { brands: [], series: [], models: [] }
    });
  }
  
  const searchTerm = `%${q}%`;
  
  const brandsResult = await query(`
    SELECT b.id, b.name, b.logo_url, b.is_popular, c.name as class_name
    FROM vehicle_catalog_brands b
    JOIN vehicle_catalog_classes c ON b.class_id = c.id
    WHERE b.name ILIKE $1
    ORDER BY b.is_popular DESC, b.name ASC
    LIMIT 10
  `, [searchTerm]);
  
  const seriesResult = await query(`
    SELECT s.id, s.name as series_name, b.id as brand_id, b.name as brand_name, b.logo_url
    FROM vehicle_catalog_series s
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE s.name ILIKE $1 OR b.name || ' ' || s.name ILIKE $1
    ORDER BY b.is_popular DESC, b.name ASC, s.name ASC
    LIMIT $2
  `, [searchTerm, limit]);
  
  const modelsResult = await query(`
    SELECT m.id, m.name as model_name, s.id as series_id, s.name as series_name,
           b.id as brand_id, b.name as brand_name, b.logo_url
    FROM vehicle_catalog_models m
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE m.name ILIKE $1 OR b.name || ' ' || s.name || ' ' || m.name ILIKE $1
    ORDER BY b.is_popular DESC, b.name ASC, s.name ASC, m.name ASC
    LIMIT $2
  `, [searchTerm, limit]);
  
  res.json({
    success: true,
    data: {
      brands: brandsResult.rows,
      series: seriesResult.rows,
      models: modelsResult.rows
    }
  });
}));

/**
 * GET /catalog/fuel-types
 */
router.get('/fuel-types', asyncHandler(async (req: Request, res: Response) => {
  const result = await query(`
    SELECT DISTINCT fuel_type 
    FROM vehicle_catalog_trims 
    WHERE fuel_type IS NOT NULL 
    ORDER BY fuel_type ASC
  `);
  
  res.json({
    success: true,
    data: result.rows.map(r => ({ value: r.fuel_type, label: r.fuel_type }))
  });
}));

/**
 * GET /catalog/transmissions
 */
router.get('/transmissions', asyncHandler(async (req: Request, res: Response) => {
  const result = await query(`
    SELECT DISTINCT transmission 
    FROM vehicle_catalog_trims 
    WHERE transmission IS NOT NULL 
    ORDER BY transmission ASC
  `);
  
  res.json({
    success: true,
    data: result.rows.map(r => ({ value: r.transmission, label: r.transmission }))
  });
}));

/**
 * GET /catalog/body-types
 */
router.get('/body-types', asyncHandler(async (req: Request, res: Response) => {
  const result = await query(`
    SELECT DISTINCT body_type 
    FROM vehicle_catalog_trims 
    WHERE body_type IS NOT NULL 
    ORDER BY body_type ASC
  `);
  
  res.json({
    success: true,
    data: result.rows.map(r => ({ value: r.body_type, label: r.body_type }))
  });
}));

/**
 * GET /catalog/colors
 */
router.get('/colors', asyncHandler(async (req: Request, res: Response) => {
  res.json({
    success: true,
    data: [
      { value: 'Siyah', label: 'Siyah' },
      { value: 'Beyaz', label: 'Beyaz' },
      { value: 'Gri', label: 'Gri' },
      { value: 'Gumus', label: 'Gümüş' },
      { value: 'Lacivert', label: 'Lacivert' },
      { value: 'Mavi', label: 'Mavi' },
      { value: 'Kirmizi', label: 'Kırmızı' },
      { value: 'Bordo', label: 'Bordo' },
      { value: 'Kahverengi', label: 'Kahverengi' },
      { value: 'Bej', label: 'Bej' },
      { value: 'Yesil', label: 'Yeşil' },
      { value: 'Turuncu', label: 'Turuncu' },
      { value: 'Sari', label: 'Sarı' },
      { value: 'Mor', label: 'Mor' },
      { value: 'Altin', label: 'Altın' },
      { value: 'Bronz', label: 'Bronz' },
      { value: 'Diger', label: 'Diğer' }
    ]
  });
}));

// ==================== CATALOG IMPORT ENDPOINTS ====================

// Multer for file uploads
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

/**
 * POST /catalog/import
 * Import catalog data from Google Sheets (JSON format)
 * Requires X-Import-Key header for authentication
 */
router.post('/import', asyncHandler(async (req: Request, res: Response) => {
  const importKey = req.headers['x-import-key'];
  const expectedKey = process.env.CATALOG_IMPORT_KEY || 'otobia-catalog-import-2026';
  
  if (importKey !== expectedKey) {
    return res.status(403).json({ success: false, message: 'Invalid import key' });
  }
  
  const { brands } = req.body;
  
  if (!brands || !Array.isArray(brands)) {
    return res.status(400).json({ success: false, message: 'brands array is required' });
  }
  
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    
    // Clear existing catalog data (in reverse order of dependencies)
    await client.query('DELETE FROM vehicle_catalog_trims');
    await client.query('DELETE FROM vehicle_catalog_alt_models');
    await client.query('DELETE FROM vehicle_catalog_models');
    await client.query('DELETE FROM vehicle_catalog_series');
    await client.query('DELETE FROM vehicle_catalog_brands');
    await client.query('DELETE FROM vehicle_catalog_classes');
    
    // Reset sequences
    await client.query("ALTER SEQUENCE vehicle_catalog_classes_id_seq RESTART WITH 1");
    await client.query("ALTER SEQUENCE vehicle_catalog_brands_id_seq RESTART WITH 1");
    await client.query("ALTER SEQUENCE vehicle_catalog_series_id_seq RESTART WITH 1");
    await client.query("ALTER SEQUENCE vehicle_catalog_models_id_seq RESTART WITH 1");
    await client.query("ALTER SEQUENCE vehicle_catalog_alt_models_id_seq RESTART WITH 1");
    await client.query("ALTER SEQUENCE vehicle_catalog_trims_id_seq RESTART WITH 1");
    
    // Insert default class
    const classResult = await client.query(
      "INSERT INTO vehicle_catalog_classes (name) VALUES ('Otomobil') RETURNING id"
    );
    const classId = classResult.rows[0].id;
    
    // Insert brands
    let insertedBrands = 0;
    for (const brand of brands) {
      const brandName = brand.name || brand.Marka || brand;
      const logoUrl = brand.logo_url || brand.logoUrl || null;
      const isPopular = brand.is_popular || brand.isPopular || false;
      
      if (brandName && typeof brandName === 'string' && brandName.trim()) {
        await client.query(
          `INSERT INTO vehicle_catalog_brands (class_id, name, logo_url, is_popular, sort_order) 
           VALUES ($1, $2, $3, $4, 999)
           ON CONFLICT (class_id, name) DO UPDATE SET logo_url = EXCLUDED.logo_url`,
          [classId, brandName.trim(), logoUrl, isPopular]
        );
        insertedBrands++;
      }
    }
    
    await client.query('COMMIT');
    
    logger.info('Catalog import completed', { brandsImported: insertedBrands });
    
    res.json({
      success: true,
      message: `Katalog başarıyla içe aktarıldı`,
      data: {
        brands: insertedBrands
      }
    });
  } catch (error: any) {
    await client.query('ROLLBACK');
    logger.error('Catalog import failed', { error: error.message });
    res.status(500).json({ success: false, message: error.message });
  } finally {
    client.release();
  }
}));

/**
 * POST /catalog/brands/:brandId/logo
 * Upload logo for a specific brand
 */
router.post('/brands/:brandId/logo', upload.single('logo'), asyncHandler(async (req: Request, res: Response) => {
  const { brandId } = req.params;
  const file = req.file;
  
  if (!file) {
    return res.status(400).json({ success: false, message: 'Logo file is required' });
  }
  
  // Check if brand exists
  const brandResult = await query('SELECT id, name FROM vehicle_catalog_brands WHERE id = $1', [brandId]);
  if (brandResult.rows.length === 0) {
    return res.status(404).json({ success: false, message: 'Brand not found' });
  }
  
  const brandName = brandResult.rows[0].name;
  const extension = file.originalname.split('.').pop() || 'svg';
  const objectName = `brands/${brandName.toLowerCase().replace(/\s+/g, '-')}.${extension}`;
  
  try {
    const logoUrl = await uploadFile('galeri-media', objectName, file.buffer, file.mimetype);
    
    // Update brand with logo URL
    await query('UPDATE vehicle_catalog_brands SET logo_url = $1 WHERE id = $2', [logoUrl, brandId]);
    
    res.json({
      success: true,
      message: 'Logo uploaded successfully',
      data: { logo_url: logoUrl }
    });
  } catch (error: any) {
    logger.error('Logo upload failed', { error: error.message, brandId });
    res.status(500).json({ success: false, message: 'Logo upload failed' });
  }
}));

/**
 * POST /catalog/brands/bulk-logos
 * Upload multiple brand logos at once
 * Expects multipart form with files named as brand names
 */
router.post('/brands/bulk-logos', upload.array('logos', 100), asyncHandler(async (req: Request, res: Response) => {
  const files = req.files as Express.Multer.File[];
  
  if (!files || files.length === 0) {
    return res.status(400).json({ success: false, message: 'No files uploaded' });
  }
  
  const results: { brand: string; success: boolean; logo_url?: string; error?: string }[] = [];
  
  for (const file of files) {
    // Extract brand name from filename (e.g., "BMW.svg" -> "BMW")
    const brandName = file.originalname.replace(/\.[^/.]+$/, '');
    const extension = file.originalname.split('.').pop() || 'svg';
    
    // Find brand in database (case-insensitive)
    const brandResult = await query(
      'SELECT id, name FROM vehicle_catalog_brands WHERE LOWER(name) = LOWER($1)',
      [brandName]
    );
    
    if (brandResult.rows.length === 0) {
      results.push({ brand: brandName, success: false, error: 'Brand not found in database' });
      continue;
    }
    
    const brand = brandResult.rows[0];
    const objectName = `brands/${brand.name.toLowerCase().replace(/\s+/g, '-')}.${extension}`;
    
    try {
      const logoUrl = await uploadFile('galeri-media', objectName, file.buffer, file.mimetype);
      await query('UPDATE vehicle_catalog_brands SET logo_url = $1 WHERE id = $2', [logoUrl, brand.id]);
      results.push({ brand: brand.name, success: true, logo_url: logoUrl });
    } catch (error: any) {
      results.push({ brand: brand.name, success: false, error: error.message });
    }
  }
  
  const successCount = results.filter(r => r.success).length;
  const failCount = results.filter(r => !r.success).length;
  
  logger.info('Bulk logo upload completed', { success: successCount, failed: failCount });
  
  res.json({
    success: true,
    message: `${successCount} logo yüklendi, ${failCount} başarısız`,
    data: results
  });
}));

/**
 * DELETE /catalog/clear
 * Clear all catalog data
 */
router.delete('/clear', asyncHandler(async (req: Request, res: Response) => {
  const importKey = req.headers['x-import-key'];
  const expectedKey = process.env.CATALOG_IMPORT_KEY || 'otobia-catalog-import-2026';
  
  if (importKey !== expectedKey) {
    return res.status(403).json({ success: false, message: 'Invalid import key' });
  }
  
  const client = await getClient();
  
  try {
    await client.query('BEGIN');
    
    // Clear all catalog data
    await client.query('DELETE FROM vehicle_catalog_trims');
    await client.query('DELETE FROM vehicle_catalog_alt_models');
    await client.query('DELETE FROM vehicle_catalog_models');
    await client.query('DELETE FROM vehicle_catalog_series');
    await client.query('DELETE FROM vehicle_catalog_brands');
    await client.query('DELETE FROM vehicle_catalog_classes');
    
    await client.query('COMMIT');
    
    logger.info('Catalog cleared');
    
    res.json({
      success: true,
      message: 'Katalog verileri temizlendi'
    });
  } catch (error: any) {
    await client.query('ROLLBACK');
    res.status(500).json({ success: false, message: error.message });
  } finally {
    client.release();
  }
}));

/**
 * PUT /catalog/brands/:brandId
 * Update a specific brand (logo_url, is_popular, etc.)
 */
router.put('/brands/:brandId', asyncHandler(async (req: Request, res: Response) => {
  const { brandId } = req.params;
  const { logo_url, is_popular, sort_order } = req.body;
  
  const updates: string[] = [];
  const params: any[] = [];
  let paramCount = 1;
  
  if (logo_url !== undefined) {
    updates.push(`logo_url = $${paramCount++}`);
    params.push(logo_url);
  }
  if (is_popular !== undefined) {
    updates.push(`is_popular = $${paramCount++}`);
    params.push(is_popular);
  }
  if (sort_order !== undefined) {
    updates.push(`sort_order = $${paramCount++}`);
    params.push(sort_order);
  }
  
  if (updates.length === 0) {
    return res.status(400).json({ success: false, message: 'No fields to update' });
  }
  
  params.push(brandId);
  
  const result = await query(
    `UPDATE vehicle_catalog_brands SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
    params
  );
  
  if (result.rows.length === 0) {
    return res.status(404).json({ success: false, message: 'Brand not found' });
  }
  
  res.json({
    success: true,
    data: result.rows[0]
  });
}));

export default router;
