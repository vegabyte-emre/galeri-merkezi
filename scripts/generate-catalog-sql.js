const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

// Find xlsx file
const rootDir = path.join(__dirname, '..');
const files = fs.readdirSync(rootDir).filter(f => f.endsWith('.xlsx'));
if (files.length === 0) {
    console.error('No xlsx file found!');
    process.exit(1);
}

const workbook = XLSX.readFile(path.join(rootDir, files[0]));
const sheet = workbook.Sheets[workbook.SheetNames[0]];
const data = XLSX.utils.sheet_to_json(sheet);

console.log('Processing', files[0], 'with', data.length, 'rows');

// Data structures
const classes = new Map(); // name -> id
const brands = new Map(); // name -> {id, classId}
const series = new Map(); // 'brand::series' -> {id, brandId, name}
const models = new Map(); // 'brand::series::model' -> {id, seriesId, name}
const altModels = new Map(); // 'brand::series::model::altModel' -> {id, modelId, name}
const trims = []; // All trim records

// Counters
let classId = 1;
let brandId = 1;
let seriesId = 1;
let modelId = 1;
let altModelId = 1;
let trimId = 1;

// Popular brands list
const popularBrands = ['BMW', 'Mercedes-Benz', 'Audi', 'Volkswagen', 'Toyota', 'Honda', 'Ford', 'Renault', 'Fiat', 'Hyundai', 'Kia', 'Nissan', 'Peugeot', 'Opel', 'Volvo', 'Mazda', 'Skoda', 'Seat', 'Citroen', 'Suzuki'];

// Normalize functions
const normalize = (str) => (str || '').toString().trim();
const normalizeFuel = (str) => {
    const s = normalize(str).toLowerCase();
    if (s.includes('elektrik')) return 'Elektrikli';
    if (s.includes('hibrit')) return 'Hibrit';
    if (s.includes('dizel')) return 'Dizel';
    if (s.includes('lpg')) return 'Benzin & LPG';
    if (s.includes('benzin')) return 'Benzinli';
    return normalize(str) || null;
};
const normalizeTransmission = (str) => {
    const s = normalize(str).toLowerCase();
    if (s.includes('otomatik')) return 'Otomatik';
    if (s.includes('manuel')) return 'Manuel';
    return normalize(str) || null;
};
const normalizeBodyType = (str) => {
    const s = normalize(str).toLowerCase();
    if (s.includes('sedan')) return 'Sedan';
    if (s.includes('hatchback') || s.includes('hp 5') || s.includes('hp 3')) return 'Hatchback';
    if (s.includes('station') || s.includes('sw')) return 'Station Wagon';
    if (s.includes('suv')) return 'SUV';
    if (s.includes('coupe')) return 'Coupe';
    if (s.includes('cabrio') || s.includes('roadster')) return 'Cabrio';
    if (s.includes('mpv')) return 'MPV';
    if (s.includes('pickup')) return 'Pickup';
    return normalize(str) || null;
};

// Process data
data.forEach(row => {
    const sinif = normalize(row['Sınıf']) || 'Otomobil';
    const marka = normalize(row['Marka']);
    const seri = normalize(row['Seri']);
    const model = normalize(row['Model']);
    const altModel = normalize(row['Alt Model']);
    const kasaTipi = normalizeBodyType(row['Kasa Tipi']);
    const yakitTipi = normalizeFuel(row['Yakıt Tipi']);
    const vites = normalizeTransmission(row['Vites']);
    const motorGucu = normalize(row['Motor Gücü ']);
    const motorHacmi = row['Motor Hacmi'] ? parseInt(row['Motor Hacmi']) : null;

    if (!marka || !seri) return;

    // Add class
    if (!classes.has(sinif)) {
        classes.set(sinif, classId++);
    }

    // Add brand
    if (!brands.has(marka)) {
        brands.set(marka, { id: brandId++, classId: classes.get(sinif) });
    }

    // Add series
    const seriesKey = marka + '::' + seri;
    if (!series.has(seriesKey)) {
        series.set(seriesKey, { id: seriesId++, brandId: brands.get(marka).id, name: seri });
    }

    // Add model
    if (model) {
        const modelKey = seriesKey + '::' + model;
        if (!models.has(modelKey)) {
            models.set(modelKey, { id: modelId++, seriesId: series.get(seriesKey).id, name: model });
        }

        // Add alt model
        if (altModel) {
            const altModelKey = modelKey + '::' + altModel;
            if (!altModels.has(altModelKey)) {
                altModels.set(altModelKey, { id: altModelId++, modelId: models.get(modelKey).id, name: altModel });
            }

            // Add trim with alt model
            trims.push({
                id: trimId++,
                altModelId: altModels.get(altModelKey).id,
                modelId: null,
                name: altModel,
                bodyType: kasaTipi,
                fuelType: yakitTipi,
                transmission: vites,
                enginePower: motorGucu,
                engineDisplacement: motorHacmi
            });
        } else {
            // Add trim without alt model (directly under model)
            trims.push({
                id: trimId++,
                altModelId: null,
                modelId: models.get(modelKey).id,
                name: null,
                bodyType: kasaTipi,
                fuelType: yakitTipi,
                transmission: vites,
                enginePower: motorGucu,
                engineDisplacement: motorHacmi
            });
        }
    }
});

console.log('Processed:');
console.log('  Classes:', classes.size);
console.log('  Brands:', brands.size);
console.log('  Series:', series.size);
console.log('  Models:', models.size);
console.log('  Alt Models:', altModels.size);
console.log('  Trims:', trims.length);

// Escape SQL string
const escapeSQL = (str) => str ? str.replace(/'/g, "''") : null;

// Generate SQL
let sql = '-- Auto-generated vehicle catalog from Excel\n';
sql += '-- Source: ' + files[0] + '\n';
sql += '-- Generated on: ' + new Date().toISOString() + '\n\n';

sql += 'BEGIN;\n\n';

// Drop and recreate tables
sql += '-- Drop existing catalog tables\n';
sql += 'DROP TABLE IF EXISTS vehicle_catalog_trims CASCADE;\n';
sql += 'DROP TABLE IF EXISTS vehicle_catalog_alt_models CASCADE;\n';
sql += 'DROP TABLE IF EXISTS vehicle_catalog_models CASCADE;\n';
sql += 'DROP TABLE IF EXISTS vehicle_catalog_series CASCADE;\n';
sql += 'DROP TABLE IF EXISTS vehicle_catalog_brands CASCADE;\n';
sql += 'DROP TABLE IF EXISTS vehicle_catalog_classes CASCADE;\n\n';

// Create tables
sql += '-- Create tables\n';
sql += `CREATE TABLE vehicle_catalog_classes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE vehicle_catalog_series (
    id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL REFERENCES vehicle_catalog_brands(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(brand_id, name)
);

CREATE TABLE vehicle_catalog_models (
    id SERIAL PRIMARY KEY,
    series_id INT NOT NULL REFERENCES vehicle_catalog_series(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(series_id, name)
);

CREATE TABLE vehicle_catalog_alt_models (
    id SERIAL PRIMARY KEY,
    model_id INT NOT NULL REFERENCES vehicle_catalog_models(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(model_id, name)
);

CREATE TABLE vehicle_catalog_trims (
    id SERIAL PRIMARY KEY,
    alt_model_id INT REFERENCES vehicle_catalog_alt_models(id) ON DELETE CASCADE,
    model_id INT REFERENCES vehicle_catalog_models(id) ON DELETE CASCADE,
    name VARCHAR(200),
    body_type VARCHAR(50),
    fuel_type VARCHAR(50),
    transmission VARCHAR(50),
    engine_power VARCHAR(50),
    engine_displacement INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (alt_model_id IS NOT NULL OR model_id IS NOT NULL)
);

`;

// Create indexes
sql += '-- Create indexes\n';
sql += 'CREATE INDEX idx_catalog_brands_class ON vehicle_catalog_brands(class_id);\n';
sql += 'CREATE INDEX idx_catalog_brands_popular ON vehicle_catalog_brands(is_popular);\n';
sql += 'CREATE INDEX idx_catalog_series_brand ON vehicle_catalog_series(brand_id);\n';
sql += 'CREATE INDEX idx_catalog_models_series ON vehicle_catalog_models(series_id);\n';
sql += 'CREATE INDEX idx_catalog_alt_models_model ON vehicle_catalog_alt_models(model_id);\n';
sql += 'CREATE INDEX idx_catalog_trims_alt_model ON vehicle_catalog_trims(alt_model_id);\n';
sql += 'CREATE INDEX idx_catalog_trims_model ON vehicle_catalog_trims(model_id);\n\n';

// Insert classes
sql += '-- Insert classes\n';
classes.forEach((id, name) => {
    sql += `INSERT INTO vehicle_catalog_classes (id, name) VALUES (${id}, '${escapeSQL(name)}');\n`;
});
sql += `SELECT setval('vehicle_catalog_classes_id_seq', ${classId});\n\n`;

// Insert brands (sorted: popular first, then alphabetically)
sql += '-- Insert brands\n';
const sortedBrands = Array.from(brands.entries()).sort((a, b) => {
    const aPopular = popularBrands.includes(a[0]);
    const bPopular = popularBrands.includes(b[0]);
    if (aPopular && !bPopular) return -1;
    if (!aPopular && bPopular) return 1;
    return a[0].localeCompare(b[0]);
});

sortedBrands.forEach(([name, data]) => {
    const isPopular = popularBrands.includes(name);
    const sortOrder = isPopular ? popularBrands.indexOf(name) + 1 : 999;
    sql += `INSERT INTO vehicle_catalog_brands (id, class_id, name, is_popular, sort_order) VALUES (${data.id}, ${data.classId}, '${escapeSQL(name)}', ${isPopular}, ${sortOrder});\n`;
});
sql += `SELECT setval('vehicle_catalog_brands_id_seq', ${brandId});\n\n`;

// Insert series
sql += '-- Insert series\n';
series.forEach((data, key) => {
    sql += `INSERT INTO vehicle_catalog_series (id, brand_id, name) VALUES (${data.id}, ${data.brandId}, '${escapeSQL(data.name)}');\n`;
});
sql += `SELECT setval('vehicle_catalog_series_id_seq', ${seriesId});\n\n`;

// Insert models
sql += '-- Insert models\n';
models.forEach((data, key) => {
    sql += `INSERT INTO vehicle_catalog_models (id, series_id, name) VALUES (${data.id}, ${data.seriesId}, '${escapeSQL(data.name)}');\n`;
});
sql += `SELECT setval('vehicle_catalog_models_id_seq', ${modelId});\n\n`;

// Insert alt models
sql += '-- Insert alt models\n';
altModels.forEach((data, key) => {
    sql += `INSERT INTO vehicle_catalog_alt_models (id, model_id, name) VALUES (${data.id}, ${data.modelId}, '${escapeSQL(data.name)}');\n`;
});
sql += `SELECT setval('vehicle_catalog_alt_models_id_seq', ${altModelId});\n\n`;

// Insert trims
sql += '-- Insert trims\n';
trims.forEach(trim => {
    const altModelIdVal = trim.altModelId ? trim.altModelId : 'NULL';
    const modelIdVal = trim.modelId ? trim.modelId : 'NULL';
    const nameVal = trim.name ? `'${escapeSQL(trim.name)}'` : 'NULL';
    const bodyTypeVal = trim.bodyType ? `'${escapeSQL(trim.bodyType)}'` : 'NULL';
    const fuelTypeVal = trim.fuelType ? `'${escapeSQL(trim.fuelType)}'` : 'NULL';
    const transmissionVal = trim.transmission ? `'${escapeSQL(trim.transmission)}'` : 'NULL';
    const enginePowerVal = trim.enginePower ? `'${escapeSQL(trim.enginePower)}'` : 'NULL';
    const engineDisplacementVal = trim.engineDisplacement ? trim.engineDisplacement : 'NULL';

    sql += `INSERT INTO vehicle_catalog_trims (id, alt_model_id, model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement) VALUES (${trim.id}, ${altModelIdVal}, ${modelIdVal}, ${nameVal}, ${bodyTypeVal}, ${fuelTypeVal}, ${transmissionVal}, ${enginePowerVal}, ${engineDisplacementVal});\n`;
});
sql += `SELECT setval('vehicle_catalog_trims_id_seq', ${trimId});\n\n`;

sql += 'COMMIT;\n\n';
sql += '-- Migration complete\n';

// Write to file
const outputPath = path.join(rootDir, 'docker', 'catalog-migration-complete.sql');
fs.writeFileSync(outputPath, sql, 'utf8');
console.log('\nSQL file written to:', outputPath);
console.log('Total SQL lines:', sql.split('\n').length);
