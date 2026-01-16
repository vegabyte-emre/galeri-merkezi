const XLSX = require('xlsx');
const fs = require('fs');

// Find the Excel file
const files = fs.readdirSync('.');
const excelFile = files.find(f => f.endsWith('.xlsx') && f.includes('Sahibinden'));
console.log('Found Excel file:', excelFile);

const wb = XLSX.readFile(excelFile);
const ws = wb.Sheets[wb.SheetNames[0]];

// Read with raw option to preserve strings
const data = XLSX.utils.sheet_to_json(ws, { header: 1, raw: false });

// Column indexes based on headers
const headers = data[0];
console.log('Headers:', headers);

const COL = {
  ANA_KATEGORI: 0,  // Ana Kategori
  SINIF: 1,         // Sınıf
  MARKA: 2,         // Marka
  SERI: 3,          // Seri
  MODEL: 4,         // Model
  ALT_MODEL: 5,     // Alt Model
  TRIM: 6,          // Trim
  KASA_TIPI: 7,     // Kasa Tipi
  YAKIT_TIPI: 8,    // Yakıt Tipi
  VITES: 9,         // Vites
  MOTOR_GUCU: 10,   // Motor Gücü
  MOTOR_HACMI: 11,  // Motor Hacmi
  YIL: 12           // YIL
};

// Normalize functions
const normalizeText = (text) => {
  if (!text) return null;
  return String(text).trim();
};

const normalizeBrand = (brand) => {
  if (!brand) return null;
  let normalized = String(brand).trim();
  // Normalize known variations
  const brandMap = {
    'ALFA ROMEO': 'Alfa Romeo',
    'ASTON MARTIN': 'Aston Martin',
    'MERCEDES BENZ': 'Mercedes-Benz',
    'MERCEDES-BENZ': 'Mercedes-Benz',
    'MERCEDES': 'Mercedes-Benz',
    'BMW': 'BMW',
    'BYD': 'BYD',
  };
  
  const upper = normalized.toUpperCase();
  if (brandMap[upper]) return brandMap[upper];
  
  // Title case
  return normalized.split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join(' ');
};

const normalizeYakitTipi = (yakit) => {
  if (!yakit) return null;
  const normalized = String(yakit).trim().toLowerCase();
  
  const yakitMap = {
    'benzinli': 'Benzin',
    'benzili': 'Benzin',      // Typo fix
    'benzinlik': 'Benzin',    // Typo fix
    'benzin': 'Benzin',
    'dizel': 'Dizel',
    'elektrikli': 'Elektrik',
    'elektrik': 'Elektrik',
    'hibrit': 'Hibrit',
    'hybrid': 'Hibrit',
    'benzin & lpg': 'Benzin + LPG',
    'benzin + lpg': 'Benzin + LPG',
    'lpg': 'LPG',
  };
  
  return yakitMap[normalized] || yakit.trim();
};

const normalizeVites = (vites) => {
  if (!vites) return null;
  const normalized = String(vites).trim().toLowerCase();
  
  if (normalized.includes('otomatik')) return 'Otomatik';
  if (normalized.includes('manuel')) return 'Manuel';
  if (normalized.includes('yarı')) return 'Yarı Otomatik';
  
  return vites.trim();
};

const normalizeKasaTipi = (kasa) => {
  if (!kasa) return null;
  let normalized = String(kasa).trim();
  
  const kasaMap = {
    'sedan': 'Sedan',
    'sedan ': 'Sedan',
    'hp 5 kapı': 'Hatchback 5 Kapı',
    'hp 5 kapı ': 'Hatchback 5 Kapı',
    'hp 3 kapı': 'Hatchback 3 Kapı',
    'hp 3 kapı ': 'Hatchback 3 Kapı',
    'station wagon': 'Station Wagon',
    'cabrio': 'Cabrio',
    'coupe': 'Coupe',
    'roadster': 'Roadster',
    'suv': 'SUV',
    'pickup': 'Pickup',
    'mpv': 'MPV',
    'crossover': 'Crossover',
    'van': 'Van',
  };
  
  const lower = normalized.toLowerCase();
  return kasaMap[lower] || normalized;
};

const parseMotorGucu = (gucu) => {
  if (!gucu) return null;
  const str = String(gucu).trim();
  
  // If it's a range like "151-175", take the higher value
  if (str.includes('-')) {
    const parts = str.split('-');
    return parseInt(parts[1], 10) || null;
  }
  
  return parseInt(str, 10) || null;
};

const parseMotorHacmi = (hacmi) => {
  if (!hacmi) return null;
  return parseInt(String(hacmi).trim(), 10) || null;
};

// Parse data
const vehicles = [];
const classesSet = new Set();
const brandsSet = new Set();
const serisMap = new Map(); // brand -> Set of series
const modelsMap = new Map(); // brand_seri -> Set of models
const altModelsMap = new Map(); // brand_seri_model -> Set of alt models
const trimsMap = new Map(); // brand_seri_model_altmodel -> Set of trims

for (let i = 1; i < data.length; i++) {
  const row = data[i];
  if (!row || !row[COL.MARKA]) continue;
  
  const sinif = normalizeText(row[COL.SINIF]) || 'Otomobil';
  const marka = normalizeBrand(row[COL.MARKA]);
  const seri = normalizeText(row[COL.SERI]);
  const model = normalizeText(row[COL.MODEL]);
  const altModel = normalizeText(row[COL.ALT_MODEL]);
  const trim = normalizeText(row[COL.TRIM]);
  const kasaTipi = normalizeKasaTipi(row[COL.KASA_TIPI]);
  const yakitTipi = normalizeYakitTipi(row[COL.YAKIT_TIPI]);
  const vites = normalizeVites(row[COL.VITES]);
  const motorGucu = parseMotorGucu(row[COL.MOTOR_GUCU]);
  const motorHacmi = parseMotorHacmi(row[COL.MOTOR_HACMI]);
  
  if (!marka) continue;
  
  classesSet.add(sinif);
  brandsSet.add(marka);
  
  if (seri) {
    if (!serisMap.has(marka)) serisMap.set(marka, new Set());
    serisMap.get(marka).add(seri);
    
    const seriKey = `${marka}|||${seri}`;
    if (model) {
      if (!modelsMap.has(seriKey)) modelsMap.set(seriKey, new Set());
      modelsMap.get(seriKey).add(model);
      
      const modelKey = `${seriKey}|||${model}`;
      if (altModel) {
        if (!altModelsMap.has(modelKey)) altModelsMap.set(modelKey, new Set());
        altModelsMap.get(modelKey).add(altModel);
      }
    }
  }
  
  vehicles.push({
    sinif,
    marka,
    seri,
    model,
    altModel,
    trim,
    kasaTipi,
    yakitTipi,
    vites,
    motorGucu,
    motorHacmi
  });
}

console.log('\n=== NORMALIZED DATA STATS ===');
console.log('Total vehicles:', vehicles.length);
console.log('Classes:', Array.from(classesSet));
console.log('Brands:', Array.from(brandsSet).sort());
console.log('Fuel types:', [...new Set(vehicles.map(v => v.yakitTipi).filter(Boolean))].sort());
console.log('Transmission types:', [...new Set(vehicles.map(v => v.vites).filter(Boolean))].sort());
console.log('Body types:', [...new Set(vehicles.map(v => v.kasaTipi).filter(Boolean))].sort());

// Generate SQL
let sql = `-- Auto-generated vehicle catalog from Excel
-- Generated on: ${new Date().toISOString()}

-- Drop existing catalog tables (in reverse order of dependencies)
DROP TABLE IF EXISTS vehicle_catalog_trims CASCADE;
DROP TABLE IF EXISTS vehicle_catalog_alt_models CASCADE;
DROP TABLE IF EXISTS vehicle_catalog_models CASCADE;
DROP TABLE IF EXISTS vehicle_catalog_series CASCADE;
DROP TABLE IF EXISTS vehicle_catalog_brands CASCADE;
DROP TABLE IF EXISTS vehicle_catalog_classes CASCADE;

-- Drop old catalog tables if they exist
DROP TABLE IF EXISTS vehicle_engines CASCADE;
DROP TABLE IF EXISTS vehicle_models CASCADE;
DROP TABLE IF EXISTS vehicle_brands CASCADE;

-- Classes table
CREATE TABLE vehicle_catalog_classes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Brands table
CREATE TABLE vehicle_catalog_brands (
    id SERIAL PRIMARY KEY,
    class_id INT NOT NULL REFERENCES vehicle_catalog_classes(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    logo_url TEXT,
    is_popular BOOLEAN DEFAULT false,
    sort_order INT DEFAULT 999,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(class_id, name)
);

-- Series table
CREATE TABLE vehicle_catalog_series (
    id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL REFERENCES vehicle_catalog_brands(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(brand_id, name)
);

-- Models table
CREATE TABLE vehicle_catalog_models (
    id SERIAL PRIMARY KEY,
    series_id INT NOT NULL REFERENCES vehicle_catalog_series(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(series_id, name)
);

-- Alt Models table
CREATE TABLE vehicle_catalog_alt_models (
    id SERIAL PRIMARY KEY,
    model_id INT NOT NULL REFERENCES vehicle_catalog_models(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(model_id, name)
);

-- Trims table (with specifications)
CREATE TABLE vehicle_catalog_trims (
    id SERIAL PRIMARY KEY,
    alt_model_id INT REFERENCES vehicle_catalog_alt_models(id) ON DELETE CASCADE,
    model_id INT REFERENCES vehicle_catalog_models(id) ON DELETE CASCADE,
    name VARCHAR(200),
    body_type VARCHAR(50),
    fuel_type VARCHAR(50),
    transmission VARCHAR(50),
    engine_power INT,
    engine_displacement INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (alt_model_id IS NOT NULL OR model_id IS NOT NULL)
);

-- Create indexes
CREATE INDEX idx_catalog_brands_class ON vehicle_catalog_brands(class_id);
CREATE INDEX idx_catalog_brands_popular ON vehicle_catalog_brands(is_popular);
CREATE INDEX idx_catalog_series_brand ON vehicle_catalog_series(brand_id);
CREATE INDEX idx_catalog_models_series ON vehicle_catalog_models(series_id);
CREATE INDEX idx_catalog_alt_models_model ON vehicle_catalog_alt_models(model_id);
CREATE INDEX idx_catalog_trims_alt_model ON vehicle_catalog_trims(alt_model_id);
CREATE INDEX idx_catalog_trims_model ON vehicle_catalog_trims(model_id);

-- Insert classes
`;

// Insert classes
const classes = Array.from(classesSet).sort();
classes.forEach(cls => {
  sql += `INSERT INTO vehicle_catalog_classes (name) VALUES ('${cls.replace(/'/g, "''")}');\n`;
});

// Insert brands
sql += `\n-- Insert brands\n`;
const brands = Array.from(brandsSet).sort();
const popularBrands = ['Audi', 'BMW', 'Mercedes-Benz', 'Volkswagen', 'Ford', 'Toyota', 'Renault', 'Fiat', 'Hyundai', 'Honda', 'Opel', 'Peugeot', 'Citroen', 'Dacia', 'Nissan', 'Kia', 'Skoda', 'Seat', 'Mazda', 'Volvo', 'Alfa Romeo', 'Chevrolet'];

brands.forEach((brand, idx) => {
  const isPopular = popularBrands.map(b => b.toLowerCase()).includes(brand.toLowerCase());
  sql += `INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    '${brand.replace(/'/g, "''")}',
    ${isPopular},
    ${isPopular ? idx + 1 : 999}
);\n`;
});

// Insert series
sql += `\n-- Insert series\n`;
serisMap.forEach((seriesSet, brand) => {
  Array.from(seriesSet).sort().forEach(seri => {
    sql += `INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = '${brand.replace(/'/g, "''")}'),
    '${seri.replace(/'/g, "''")}'
);\n`;
  });
});

// Insert models
sql += `\n-- Insert models\n`;
modelsMap.forEach((modelsSet, seriKey) => {
  const [brand, seri] = seriKey.split('|||');
  Array.from(modelsSet).sort().forEach(model => {
    sql += `INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = '${brand.replace(/'/g, "''")}' AND s.name = '${seri.replace(/'/g, "''")}'),
    '${String(model).replace(/'/g, "''")}'
);\n`;
  });
});

// Insert alt models
sql += `\n-- Insert alt models\n`;
altModelsMap.forEach((altModelsSet, modelKey) => {
  const [brand, seri, model] = modelKey.split('|||');
  Array.from(altModelsSet).sort().forEach(altModel => {
    sql += `INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = '${brand.replace(/'/g, "''")}' AND s.name = '${seri.replace(/'/g, "''")}' AND m.name = '${String(model).replace(/'/g, "''")}'),
    '${altModel.replace(/'/g, "''")}'
);\n`;
  });
});

// Insert trims with specs - using unique combinations
sql += `\n-- Insert trims with specifications\n`;

// Create unique trim combinations map
const uniqueTrims = new Map();
vehicles.forEach(v => {
  if (!v.marka || !v.seri || !v.model) return;
  
  // Create unique key for this combination
  const key = JSON.stringify({
    marka: v.marka,
    seri: v.seri,
    model: v.model,
    altModel: v.altModel || '',
    trim: v.trim || '',
    kasaTipi: v.kasaTipi || '',
    yakitTipi: v.yakitTipi || '',
    vites: v.vites || '',
    motorGucu: v.motorGucu || '',
    motorHacmi: v.motorHacmi || ''
  });
  
  if (!uniqueTrims.has(key)) {
    uniqueTrims.set(key, v);
  }
});

console.log('Unique trim combinations:', uniqueTrims.size);

uniqueTrims.forEach(v => {
  const trimName = v.trim ? `'${v.trim.replace(/'/g, "''")}'` : 'NULL';
  const bodyType = v.kasaTipi ? `'${v.kasaTipi.replace(/'/g, "''")}'` : 'NULL';
  const fuelType = v.yakitTipi ? `'${v.yakitTipi.replace(/'/g, "''")}'` : 'NULL';
  const transmission = v.vites ? `'${v.vites.replace(/'/g, "''")}'` : 'NULL';
  const enginePower = v.motorGucu || 'NULL';
  const engineDisplacement = v.motorHacmi || 'NULL';
  
  if (v.altModel) {
    sql += `INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, ${trimName}, ${bodyType}, ${fuelType}, ${transmission}, ${enginePower}, ${engineDisplacement}
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = '${v.marka.replace(/'/g, "''")}' 
  AND s.name = '${v.seri.replace(/'/g, "''")}' 
  AND m.name = '${String(v.model).replace(/'/g, "''")}'
  AND am.name = '${v.altModel.replace(/'/g, "''")}';
`;
  } else {
    sql += `INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, ${trimName}, ${bodyType}, ${fuelType}, ${transmission}, ${enginePower}, ${engineDisplacement}
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = '${v.marka.replace(/'/g, "''")}' 
  AND s.name = '${v.seri.replace(/'/g, "''")}' 
  AND m.name = '${String(v.model).replace(/'/g, "''")}';
`;
  }
});

// Write SQL file
fs.writeFileSync('database/migrations/012_create_vehicle_catalog.sql', sql);
console.log('\n=== SQL FILE GENERATED ===');
console.log('Output: database/migrations/012_create_vehicle_catalog.sql');
console.log('Lines:', sql.split('\n').length);

// Generate JSON for frontend reference
const catalogData = {
  classes: Array.from(classesSet),
  brands: brands.map(b => ({
    name: b,
    isPopular: popularBrands.map(pb => pb.toLowerCase()).includes(b.toLowerCase())
  })),
  fuelTypes: [...new Set(vehicles.map(v => v.yakitTipi).filter(Boolean))].sort(),
  transmissions: [...new Set(vehicles.map(v => v.vites).filter(Boolean))].sort(),
  bodyTypes: [...new Set(vehicles.map(v => v.kasaTipi).filter(Boolean))].sort(),
  totalVehicles: vehicles.length
};

fs.writeFileSync('database/seeds/catalog-summary.json', JSON.stringify(catalogData, null, 2));
console.log('Summary: database/seeds/catalog-summary.json');
