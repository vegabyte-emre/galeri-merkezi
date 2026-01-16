/**
 * Vehicle Catalog Import Script
 * Imports brand, model, and engine data from autoevolution JSON files
 */

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'galeri_merkezi',
  user: process.env.DB_USER || 'galeri_user',
  password: process.env.DB_PASSWORD || 'galeri_password'
});

// Helper function to parse model name and extract year range
function parseModelName(name) {
  // Example: "AC  Aceca 1998-2000 Photos, engines & full specs"
  const cleanName = name.replace(/Photos.*$/i, '').replace(/&amp;/g, '&').trim();
  const yearMatch = cleanName.match(/(\d{4})-(\d{4}|\s*present)?/i);
  
  let modelName = cleanName;
  let yearStart = null;
  let yearEnd = null;
  
  if (yearMatch) {
    yearStart = parseInt(yearMatch[1]);
    yearEnd = yearMatch[2] && yearMatch[2] !== 'present' ? parseInt(yearMatch[2]) : null;
    modelName = cleanName.replace(/\d{4}.*$/, '').trim();
  }
  
  // Remove brand name from model name if it's at the beginning
  modelName = modelName.replace(/^[A-Z]+\s+/i, '').trim();
  
  return { modelName, yearStart, yearEnd };
}

// Helper function to parse engine specs
function parseEngineSpecs(specs) {
  const result = {
    cylinders: null,
    displacement_cc: null,
    power_hp: null,
    power_kw: null,
    torque_nm: null,
    fuel_type: null,
    fuel_system: null,
    top_speed_kmh: null,
    acceleration_0_100: null,
    drive_type: null,
    gearbox: null,
    length_mm: null,
    width_mm: null,
    height_mm: null,
    wheelbase_mm: null,
    cargo_volume_l: null,
    weight_kg: null,
    fuel_city_l100km: null,
    fuel_highway_l100km: null,
    fuel_combined_l100km: null,
    co2_emissions: null
  };

  if (!specs) return result;

  // Engine Specs
  const engineSpecs = specs['Engine Specs'] || {};
  result.cylinders = engineSpecs['Cylinders:'] || null;
  
  // Parse displacement
  const dispMatch = (engineSpecs['Displacement:'] || '').match(/(\d+)\s*Cm3/i);
  if (dispMatch) result.displacement_cc = parseInt(dispMatch[1]);
  
  // Parse power
  const powerStr = engineSpecs['Power:'] || '';
  const hpMatch = powerStr.match(/(\d+)\s*Hp/i);
  const kwMatch = powerStr.match(/(\d+\.?\d*)\s*Kw/i);
  if (hpMatch) result.power_hp = parseInt(hpMatch[1]);
  if (kwMatch) result.power_kw = parseFloat(kwMatch[1]);
  
  // Parse torque
  const torqueMatch = (engineSpecs['Torque:'] || '').match(/(\d+)\s*Nm/i);
  if (torqueMatch) result.torque_nm = parseInt(torqueMatch[1]);
  
  // Fuel type
  const fuel = engineSpecs['Fuel:'] || '';
  if (fuel.toLowerCase().includes('gasoline') || fuel.toLowerCase().includes('petrol')) {
    result.fuel_type = 'Benzin';
  } else if (fuel.toLowerCase().includes('diesel')) {
    result.fuel_type = 'Dizel';
  } else if (fuel.toLowerCase().includes('electric')) {
    result.fuel_type = 'Elektrik';
  } else if (fuel.toLowerCase().includes('hybrid')) {
    result.fuel_type = 'Hibrit';
  } else if (fuel.toLowerCase().includes('lpg')) {
    result.fuel_type = 'LPG';
  }
  
  result.fuel_system = engineSpecs['Fuel System:'] || null;

  // Performance Specs
  const perfSpecs = specs['Performance Specs'] || {};
  const speedMatch = (perfSpecs['Top Speed:'] || '').match(/(\d+)\s*Km\/H/i);
  if (speedMatch) result.top_speed_kmh = parseInt(speedMatch[1]);
  
  const accelMatch = (perfSpecs['Acceleration 0-62 Mph (0-100 Kph):'] || '').match(/(\d+\.?\d*)\s*S/i);
  if (accelMatch) result.acceleration_0_100 = parseFloat(accelMatch[1]);

  // Transmission Specs
  const transSpecs = specs['Transmission Specs'] || {};
  const driveType = transSpecs['Drive Type:'] || '';
  if (driveType.toLowerCase().includes('front')) {
    result.drive_type = 'Önden Çekiş';
  } else if (driveType.toLowerCase().includes('rear')) {
    result.drive_type = 'Arkadan İtiş';
  } else if (driveType.toLowerCase().includes('all') || driveType.toLowerCase().includes('4wd') || driveType.toLowerCase().includes('awd')) {
    result.drive_type = '4x4';
  }
  result.gearbox = transSpecs['Gearbox:'] || null;

  // Dimensions
  const dimSpecs = specs['Dimensions'] || {};
  const lengthMatch = (dimSpecs['Length:'] || '').match(/(\d+)\s*Mm/i);
  if (lengthMatch) result.length_mm = parseInt(lengthMatch[1]);
  
  const widthMatch = (dimSpecs['Width:'] || '').match(/(\d+)\s*Mm/i);
  if (widthMatch) result.width_mm = parseInt(widthMatch[1]);
  
  const heightMatch = (dimSpecs['Height:'] || '').match(/(\d+)\s*Mm/i);
  if (heightMatch) result.height_mm = parseInt(heightMatch[1]);
  
  const wheelbaseMatch = (dimSpecs['Wheelbase:'] || '').match(/(\d+)\s*Mm/i);
  if (wheelbaseMatch) result.wheelbase_mm = parseInt(wheelbaseMatch[1]);
  
  const cargoMatch = (dimSpecs['Cargo Volume:'] || '').match(/(\d+)\s*L/i);
  if (cargoMatch) result.cargo_volume_l = parseInt(cargoMatch[1]);

  // Weight
  const weightSpecs = specs['Weight Specs'] || {};
  const weightMatch = (weightSpecs['Unladen Weight:'] || '').match(/(\d+)\s*Kg/i);
  if (weightMatch) result.weight_kg = parseInt(weightMatch[1]);

  // Fuel Economy
  const fuelEconomy = specs['Fuel Economy (Nedc)'] || specs['Fuel Economy (Wltp)'] || {};
  const cityMatch = (fuelEconomy['City:'] || '').match(/(\d+\.?\d*)\s*L\/100Km/i);
  if (cityMatch) result.fuel_city_l100km = parseFloat(cityMatch[1]);
  
  const hwMatch = (fuelEconomy['Highway:'] || '').match(/(\d+\.?\d*)\s*L\/100Km/i);
  if (hwMatch) result.fuel_highway_l100km = parseFloat(hwMatch[1]);
  
  const combMatch = (fuelEconomy['Combined:'] || '').match(/(\d+\.?\d*)\s*L\/100Km/i);
  if (combMatch) result.fuel_combined_l100km = parseFloat(combMatch[1]);

  return result;
}

async function importData() {
  const client = await pool.connect();
  
  try {
    console.log('Starting vehicle catalog import...');
    
    // Read JSON files
    const brandsPath = path.join(__dirname, 'brands.json');
    const automobilesPath = path.join(__dirname, 'automobiles.json');
    const enginesPath = path.join(__dirname, 'engines.json');
    
    console.log('Reading brands.json...');
    const brands = JSON.parse(fs.readFileSync(brandsPath, 'utf8'));
    
    console.log('Reading automobiles.json...');
    const automobiles = JSON.parse(fs.readFileSync(automobilesPath, 'utf8'));
    
    console.log('Reading engines.json...');
    const engines = JSON.parse(fs.readFileSync(enginesPath, 'utf8'));
    
    console.log(`Loaded: ${brands.length} brands, ${automobiles.length} models, ${engines.length} engines`);
    
    // Create brand ID mapping
    const brandIdMap = new Map();
    const modelIdMap = new Map();
    
    await client.query('BEGIN');
    
    // Import brands
    console.log('Importing brands...');
    for (const brand of brands) {
      const result = await client.query(`
        INSERT INTO vehicle_brands (name, logo_url)
        VALUES ($1, $2)
        ON CONFLICT (name) DO UPDATE SET logo_url = EXCLUDED.logo_url
        RETURNING id
      `, [brand.name, brand.logo]);
      
      brandIdMap.set(brand.id, result.rows[0].id);
    }
    console.log(`Imported ${brands.length} brands`);
    
    // Import models
    console.log('Importing models...');
    let modelCount = 0;
    for (const auto of automobiles) {
      const dbBrandId = brandIdMap.get(auto.brand_id);
      if (!dbBrandId) continue;
      
      const { modelName, yearStart, yearEnd } = parseModelName(auto.name);
      if (!modelName) continue;
      
      try {
        const result = await client.query(`
          INSERT INTO vehicle_models (brand_id, name, year_start, year_end, photos)
          VALUES ($1, $2, $3, $4, $5)
          ON CONFLICT (brand_id, name) DO UPDATE SET 
            year_start = COALESCE(EXCLUDED.year_start, vehicle_models.year_start),
            year_end = COALESCE(EXCLUDED.year_end, vehicle_models.year_end),
            photos = COALESCE(EXCLUDED.photos, vehicle_models.photos)
          RETURNING id
        `, [dbBrandId, modelName, yearStart, yearEnd, auto.photos || []]);
        
        modelIdMap.set(auto.id, result.rows[0].id);
        modelCount++;
        
        if (modelCount % 500 === 0) {
          console.log(`  Imported ${modelCount} models...`);
        }
      } catch (err) {
        console.error(`Error importing model: ${modelName}`, err.message);
      }
    }
    console.log(`Imported ${modelCount} models`);
    
    // Import engines
    console.log('Importing engines...');
    let engineCount = 0;
    for (const engine of engines) {
      const dbModelId = modelIdMap.get(engine.automobile_id);
      if (!dbModelId) continue;
      
      const specs = parseEngineSpecs(engine.specs);
      
      try {
        await client.query(`
          INSERT INTO vehicle_engines (
            model_id, name, cylinders, displacement_cc, power_hp, power_kw,
            torque_nm, fuel_type, fuel_system, top_speed_kmh, acceleration_0_100,
            drive_type, gearbox, length_mm, width_mm, height_mm, wheelbase_mm,
            cargo_volume_l, weight_kg, fuel_city_l100km, fuel_highway_l100km,
            fuel_combined_l100km, co2_emissions
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)
        `, [
          dbModelId, engine.name, specs.cylinders, specs.displacement_cc, specs.power_hp, specs.power_kw,
          specs.torque_nm, specs.fuel_type, specs.fuel_system, specs.top_speed_kmh, specs.acceleration_0_100,
          specs.drive_type, specs.gearbox, specs.length_mm, specs.width_mm, specs.height_mm, specs.wheelbase_mm,
          specs.cargo_volume_l, specs.weight_kg, specs.fuel_city_l100km, specs.fuel_highway_l100km,
          specs.fuel_combined_l100km, specs.co2_emissions
        ]);
        
        engineCount++;
        
        if (engineCount % 2000 === 0) {
          console.log(`  Imported ${engineCount} engines...`);
        }
      } catch (err) {
        // Skip duplicate entries
      }
    }
    console.log(`Imported ${engineCount} engines`);
    
    await client.query('COMMIT');
    console.log('Vehicle catalog import completed successfully!');
    
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Import failed:', err);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

importData().catch(console.error);






