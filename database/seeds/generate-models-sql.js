/**
 * Generate SQL for popular brand models
 */

const fs = require('fs');
const path = require('path');

// Popular brand names (must match exactly with JSON data)
const popularBrandNames = [
  'RENAULT', 'VOLKSWAGEN', 'FIAT', 'FORD', 'TOYOTA', 'HYUNDAI', 'OPEL', 
  'PEUGEOT', 'CITROEN', 'DACIA', 'BMW', 'MERCEDES BENZ', 'AUDI', 'HONDA',
  'NISSAN', 'KIA', 'SKODA', 'SEAT', 'MAZDA', 'VOLVO'
];

// Read JSON files
const brandsPath = path.join(__dirname, 'brands.json');
const automobilesPath = path.join(__dirname, 'automobiles.json');
const enginesPath = path.join(__dirname, 'engines.json');

console.log('Reading JSON files...');
const brands = JSON.parse(fs.readFileSync(brandsPath, 'utf8'));
const automobiles = JSON.parse(fs.readFileSync(automobilesPath, 'utf8'));
const engines = JSON.parse(fs.readFileSync(enginesPath, 'utf8'));

// Get popular brand IDs from JSON
const popularBrandIds = new Set();
const brandNameMap = new Map();

brands.forEach(brand => {
  if (popularBrandNames.includes(brand.name)) {
    popularBrandIds.add(brand.id);
    brandNameMap.set(brand.id, brand.name);
  }
});

console.log(`Found ${popularBrandIds.size} popular brands`);

// Filter automobiles for popular brands
const popularAutos = automobiles.filter(auto => popularBrandIds.has(auto.brand_id));
console.log(`Found ${popularAutos.length} models for popular brands`);

// Parse model name to extract clean name and years
function parseModelName(name, brandName) {
  // Clean up the name
  let cleanName = name
    .replace(/Photos.*$/i, '')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim();
  
  // Extract year range
  const yearMatch = cleanName.match(/(\d{4})-(\d{4}|present)?/i);
  let yearStart = null;
  let yearEnd = null;
  
  if (yearMatch) {
    yearStart = parseInt(yearMatch[1]);
    yearEnd = yearMatch[2] && yearMatch[2].toLowerCase() !== 'present' ? parseInt(yearMatch[2]) : null;
    cleanName = cleanName.replace(/\d{4}.*$/, '').trim();
  }
  
  // Remove brand name from beginning
  const brandRegex = new RegExp(`^${brandName}\\s+`, 'i');
  cleanName = cleanName.replace(brandRegex, '').trim();
  
  return { modelName: cleanName, yearStart, yearEnd };
}

// Escape SQL string
function escapeSql(str) {
  if (!str) return 'NULL';
  return `'${str.replace(/'/g, "''")}'`;
}

// Generate SQL
let sql = `-- Auto-generated models for popular brands
-- Generated on ${new Date().toISOString()}

`;

// Group by brand
const modelsByBrand = new Map();

popularAutos.forEach(auto => {
  const brandName = brandNameMap.get(auto.brand_id);
  const { modelName, yearStart, yearEnd } = parseModelName(auto.name, brandName);
  
  if (!modelName) return;
  
  if (!modelsByBrand.has(brandName)) {
    modelsByBrand.set(brandName, []);
  }
  
  modelsByBrand.get(brandName).push({
    autoId: auto.id,
    modelName,
    yearStart,
    yearEnd,
    photos: auto.photos || []
  });
});

// Generate INSERT statements per brand
modelsByBrand.forEach((models, brandName) => {
  sql += `\n-- ${brandName} Models (${models.length})\n`;
  
  models.forEach(model => {
    const yearStartStr = model.yearStart ? model.yearStart : 'NULL';
    const yearEndStr = model.yearEnd ? model.yearEnd : 'NULL';
    const photosStr = model.photos.length > 0 
      ? `ARRAY[${model.photos.slice(0, 3).map(p => escapeSql(p)).join(', ')}]`
      : 'NULL';
    
    sql += `INSERT INTO vehicle_models (brand_id, name, year_start, year_end, photos) 
SELECT id, ${escapeSql(model.modelName)}, ${yearStartStr}, ${yearEndStr}, ${photosStr}
FROM vehicle_brands WHERE name = ${escapeSql(brandName)}
ON CONFLICT (brand_id, name) DO NOTHING;\n`;
  });
});

// Write SQL file
const outputPath = path.join(__dirname, 'import-models.sql');
fs.writeFileSync(outputPath, sql);
console.log(`Generated SQL file: ${outputPath}`);
console.log(`Total models: ${popularAutos.length}`);

// Now generate engines SQL
console.log('\nGenerating engines SQL...');

// Get auto IDs for popular brands
const popularAutoIds = new Set(popularAutos.map(a => a.id));

// Filter engines for popular brand models
const popularEngines = engines.filter(e => popularAutoIds.has(e.automobile_id));
console.log(`Found ${popularEngines.length} engines for popular brands`);

// Parse engine specs
function parseEngineSpecs(specs) {
  const result = {
    cylinders: null,
    displacement_cc: null,
    power_hp: null,
    power_kw: null,
    torque_nm: null,
    fuel_type: null,
    drive_type: null,
    gearbox: null
  };

  if (!specs) return result;

  const engineSpecs = specs['Engine Specs'] || {};
  result.cylinders = engineSpecs['Cylinders:'] || null;
  
  const dispMatch = (engineSpecs['Displacement:'] || '').match(/(\d+)\s*Cm3/i);
  if (dispMatch) result.displacement_cc = parseInt(dispMatch[1]);
  
  const powerStr = engineSpecs['Power:'] || '';
  const hpMatch = powerStr.match(/(\d+)\s*Hp/i);
  const kwMatch = powerStr.match(/(\d+\.?\d*)\s*Kw/i);
  if (hpMatch) result.power_hp = parseInt(hpMatch[1]);
  if (kwMatch) result.power_kw = parseFloat(kwMatch[1]);
  
  const torqueMatch = (engineSpecs['Torque:'] || '').match(/(\d+)\s*Nm/i);
  if (torqueMatch) result.torque_nm = parseInt(torqueMatch[1]);
  
  const fuel = engineSpecs['Fuel:'] || '';
  if (fuel.toLowerCase().includes('gasoline') || fuel.toLowerCase().includes('petrol')) {
    result.fuel_type = 'Benzin';
  } else if (fuel.toLowerCase().includes('diesel')) {
    result.fuel_type = 'Dizel';
  } else if (fuel.toLowerCase().includes('electric')) {
    result.fuel_type = 'Elektrik';
  } else if (fuel.toLowerCase().includes('hybrid')) {
    result.fuel_type = 'Hibrit';
  }

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

  return result;
}

// Create auto ID to model name mapping
const autoIdToModel = new Map();
popularAutos.forEach(auto => {
  const brandName = brandNameMap.get(auto.brand_id);
  const { modelName } = parseModelName(auto.name, brandName);
  autoIdToModel.set(auto.id, { modelName, brandName });
});

let engineSql = `-- Auto-generated engines for popular brands
-- Generated on ${new Date().toISOString()}

`;

// Limit engines per model for performance (top 5 by power)
const enginesByModel = new Map();
popularEngines.forEach(engine => {
  const modelInfo = autoIdToModel.get(engine.automobile_id);
  if (!modelInfo) return;
  
  const key = `${modelInfo.brandName}|${modelInfo.modelName}`;
  if (!enginesByModel.has(key)) {
    enginesByModel.set(key, []);
  }
  
  const specs = parseEngineSpecs(engine.specs);
  enginesByModel.get(key).push({
    name: engine.name,
    ...specs
  });
});

// Generate engine INSERT statements
enginesByModel.forEach((engines, key) => {
  const [brandName, modelName] = key.split('|');
  
  // Sort by power and take top 5
  const topEngines = engines
    .sort((a, b) => (b.power_hp || 0) - (a.power_hp || 0))
    .slice(0, 5);
  
  topEngines.forEach(engine => {
    engineSql += `INSERT INTO vehicle_engines (model_id, name, cylinders, displacement_cc, power_hp, power_kw, torque_nm, fuel_type, drive_type, gearbox) 
SELECT vm.id, ${escapeSql(engine.name)}, ${escapeSql(engine.cylinders)}, ${engine.displacement_cc || 'NULL'}, ${engine.power_hp || 'NULL'}, ${engine.power_kw || 'NULL'}, ${engine.torque_nm || 'NULL'}, ${escapeSql(engine.fuel_type)}, ${escapeSql(engine.drive_type)}, ${escapeSql(engine.gearbox)}
FROM vehicle_models vm
JOIN vehicle_brands vb ON vb.id = vm.brand_id
WHERE vb.name = ${escapeSql(brandName)} AND vm.name = ${escapeSql(modelName)}
ON CONFLICT DO NOTHING;\n`;
  });
});

const engineOutputPath = path.join(__dirname, 'import-engines.sql');
fs.writeFileSync(engineOutputPath, engineSql);
console.log(`Generated engines SQL file: ${engineOutputPath}`);






