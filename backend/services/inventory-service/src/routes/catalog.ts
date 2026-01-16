import { Router, Request, Response, NextFunction } from 'express';
import { query } from '@galeri/shared/database/connection';

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
 */
router.get('/models/:modelId/alt-models', asyncHandler(async (req: Request, res: Response) => {
  const { modelId } = req.params;
  const { search } = req.query;
  
  let sql = `
    SELECT am.id, am.name, m.name as model_name, s.name as series_name, b.name as brand_name,
           (SELECT COUNT(*) FROM vehicle_catalog_trims WHERE alt_model_id = am.id) as trim_count
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
 * Get all trims for a specific alt model with specifications
 */
router.get('/alt-models/:altModelId/trims', asyncHandler(async (req: Request, res: Response) => {
  const { altModelId } = req.params;
  
  const result = await query(`
    SELECT t.id, t.name, t.body_type, t.fuel_type, t.transmission, 
           t.engine_power, t.engine_displacement,
           am.name as alt_model_name, m.name as model_name, 
           s.name as series_name, b.name as brand_name
    FROM vehicle_catalog_trims t
    JOIN vehicle_catalog_alt_models am ON t.alt_model_id = am.id
    JOIN vehicle_catalog_models m ON am.model_id = m.id
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE t.alt_model_id = $1
    ORDER BY t.name ASC NULLS FIRST
  `, [altModelId]);
  
  res.json({
    success: true,
    data: result.rows
  });
}));

/**
 * GET /catalog/models/:modelId/trims
 * Get all trims for a specific model (for models without alt models)
 */
router.get('/models/:modelId/trims', asyncHandler(async (req: Request, res: Response) => {
  const { modelId } = req.params;
  
  const result = await query(`
    SELECT t.id, t.name, t.body_type, t.fuel_type, t.transmission, 
           t.engine_power, t.engine_displacement,
           m.name as model_name, s.name as series_name, b.name as brand_name
    FROM vehicle_catalog_trims t
    JOIN vehicle_catalog_models m ON t.model_id = m.id
    JOIN vehicle_catalog_series s ON m.series_id = s.id
    JOIN vehicle_catalog_brands b ON s.brand_id = b.id
    WHERE t.model_id = $1 AND t.alt_model_id IS NULL
    ORDER BY t.name ASC NULLS FIRST
  `, [modelId]);
  
  res.json({
    success: true,
    data: result.rows
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
 * Get specifications for a selected vehicle (brand -> series -> model -> alt_model)
 */
router.get('/specifications', asyncHandler(async (req: Request, res: Response) => {
  const { altModelId, modelId } = req.query;
  
  if (!altModelId && !modelId) {
    return res.status(400).json({
      success: false,
      message: 'altModelId or modelId is required'
    });
  }
  
  let sql: string;
  let params: any[];
  
  if (altModelId) {
    sql = `
      SELECT DISTINCT ON (t.body_type, t.fuel_type, t.transmission)
             t.body_type, t.fuel_type, t.transmission, 
             t.engine_power, t.engine_displacement,
             am.name as alt_model_name, m.name as model_name,
             s.name as series_name, b.name as brand_name
      FROM vehicle_catalog_trims t
      JOIN vehicle_catalog_alt_models am ON t.alt_model_id = am.id
      JOIN vehicle_catalog_models m ON am.model_id = m.id
      JOIN vehicle_catalog_series s ON m.series_id = s.id
      JOIN vehicle_catalog_brands b ON s.brand_id = b.id
      WHERE t.alt_model_id = $1
      ORDER BY t.body_type, t.fuel_type, t.transmission, t.engine_power DESC
    `;
    params = [altModelId];
  } else {
    sql = `
      SELECT DISTINCT ON (t.body_type, t.fuel_type, t.transmission)
             t.body_type, t.fuel_type, t.transmission, 
             t.engine_power, t.engine_displacement,
             m.name as model_name, s.name as series_name, b.name as brand_name
      FROM vehicle_catalog_trims t
      JOIN vehicle_catalog_models m ON t.model_id = m.id
      JOIN vehicle_catalog_series s ON m.series_id = s.id
      JOIN vehicle_catalog_brands b ON s.brand_id = b.id
      WHERE t.model_id = $1 AND t.alt_model_id IS NULL
      ORDER BY t.body_type, t.fuel_type, t.transmission, t.engine_power DESC
    `;
    params = [modelId];
  }
  
  const result = await query(sql, params);
  
  if (result.rows.length > 0) {
    const firstSpec = result.rows[0];
    res.json({
      success: true,
      data: {
        bodyType: firstSpec.body_type,
        fuelType: firstSpec.fuel_type,
        transmission: firstSpec.transmission,
        enginePower: firstSpec.engine_power,
        engineDisplacement: firstSpec.engine_displacement,
        brandName: firstSpec.brand_name,
        seriesName: firstSpec.series_name,
        modelName: firstSpec.model_name,
        altModelName: firstSpec.alt_model_name || null,
        allSpecs: result.rows
      }
    });
  } else {
    res.json({
      success: true,
      data: null
    });
  }
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
      { value: 'Gumus', label: 'Gumus' },
      { value: 'Lacivert', label: 'Lacivert' },
      { value: 'Mavi', label: 'Mavi' },
      { value: 'Kirmizi', label: 'Kirmizi' },
      { value: 'Bordo', label: 'Bordo' },
      { value: 'Kahverengi', label: 'Kahverengi' },
      { value: 'Bej', label: 'Bej' },
      { value: 'Yesil', label: 'Yesil' },
      { value: 'Turuncu', label: 'Turuncu' },
      { value: 'Sari', label: 'Sari' },
      { value: 'Mor', label: 'Mor' },
      { value: 'Altin', label: 'Altin' },
      { value: 'Bronz', label: 'Bronz' },
      { value: 'Diger', label: 'Diger' }
    ]
  });
}));

export default router;
