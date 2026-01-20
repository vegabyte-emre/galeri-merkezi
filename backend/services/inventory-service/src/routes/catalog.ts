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

export default router;
