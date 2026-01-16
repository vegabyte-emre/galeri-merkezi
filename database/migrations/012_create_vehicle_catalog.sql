-- Auto-generated vehicle catalog from Excel
-- Generated on: 2026-01-16T20:18:57.369Z

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
INSERT INTO vehicle_catalog_classes (name) VALUES ('Otomobil');

-- Insert brands
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Abarth',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Aion',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Alfa Romeo',
    true,
    3
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Alpine',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Anadol',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Arora',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Aston Martin',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Audi',
    true,
    8
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'BYD',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Bentley',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Buick',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Cadillac',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Chery',
    false,
    999
);
INSERT INTO vehicle_catalog_brands (class_id, name, is_popular, sort_order) VALUES (
    (SELECT id FROM vehicle_catalog_classes WHERE name = 'Otomobil'),
    'Chevrolet',
    true,
    14
);

-- Insert series
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Abarth'),
    '500e'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aion'),
    'S'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aion'),
    'S Plus'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '145'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '146'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '147'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '155'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '156'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '159'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '166'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '33'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    '75'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'Brera'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'GT'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'GTV'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'Giulia'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'Giulia Quadrifoglio'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'Giulietta'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alfa Romeo'),
    'Mito'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Alpine'),
    'A290'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Anadol'),
    'A'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Anadol'),
    'SV'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Arora'),
    'S1'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'DB11'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'DB12'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'DB7'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'DB9'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'DBS'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'Rapide'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'Vanquish'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Aston Martin'),
    'Vantage'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    '100 Serisi'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    '200 Serisi'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    '80 Serisi'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A1'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A2'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A3'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A4'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A5'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A6'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'A8'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'E-Tron GT'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'R8'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'RS'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'S Serisi'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Audi'),
    'TTS'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Bentley'),
    'Azure'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Bentley'),
    'Continental'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Bentley'),
    'Flying Spor'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Bentley'),
    'Mulsanne'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Buick'),
    'Le Sabre'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Buick'),
    'Park Avenue'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Buick'),
    'Regal'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Buick'),
    'Riviera'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Buick'),
    'Roadmaster'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Buick'),
    'Skylark'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'BYD'),
    'Dolphin'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'BYD'),
    'F3'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'BYD'),
    'Han'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'BYD'),
    'Seal'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'BYD'),
    'Song L'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'Brougham'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'CTS'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'DeVille'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'Eldorado'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'Fleetwood'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'STS'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Cadillac'),
    'Seville'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chery'),
    'Alia'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chery'),
    'Chance'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chery'),
    'Kimo'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chery'),
    'Niche'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Aveo'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Camaro'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Caprice'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Celebrity'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Corvette'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Cruze'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Epica'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Evanda'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Impala'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Kalos'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Lacetti'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Rezzo'
);
INSERT INTO vehicle_catalog_series (brand_id, name) VALUES (
    (SELECT id FROM vehicle_catalog_brands WHERE name = 'Chevrolet'),
    'Spark'
);

-- Insert models
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Abarth' AND s.name = '500e'),
    'Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aion' AND s.name = 'S'),
    '580'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aion' AND s.name = 'S Plus'),
    '70'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia'),
    '2.0 T'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia Quadrifoglio'),
    '2.9'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta'),
    '1.4 TB'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta'),
    '1.6 JTD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta'),
    '1.75 TBI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145'),
    '1.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145'),
    '1.7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146'),
    '1.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146'),
    '2.0 Ti'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147'),
    '1.6 TS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147'),
    '1.9'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147'),
    '2.0 TS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '155'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156'),
    '1.6 TS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156'),
    '1.9 JTD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156'),
    '2.0 JTS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156'),
    '2.0 TS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156'),
    '2.5'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159'),
    '1.9 JTD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159'),
    '1.9 JTS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159'),
    '3.2 TJS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '166'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '33'),
    '1.5'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '33'),
    '1.7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '75'),
    '1.8 T'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Brera'),
    '2.2'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'GT'),
    '1.9 JTD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'GT'),
    '2.0 JTS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'GTV'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito'),
    '1.3 jtd'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito'),
    '1.4 TB'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito'),
    '1.6 JTD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alpine' AND s.name = 'A290'),
    'GT'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alpine' AND s.name = 'A290'),
    'GTS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Anadol' AND s.name = 'A'),
    'A1'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Anadol' AND s.name = 'A'),
    'A2'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Anadol' AND s.name = 'A'),
    'A2 SL'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Anadol' AND s.name = 'SV'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB11'),
    'Coupe'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB12'),
    'Coupe'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB12'),
    'Volante'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB7'),
    'Coupe'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB7'),
    'Volante'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB9'),
    'Coupe'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB9'),
    'GT 007 Bond Edition'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DB9'),
    'Volante'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'DBS'),
    'DBS Coupe'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Rapide'),
    'V12 Rapide'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Rapide'),
    'V12 Rapide S'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Vanquish'),
    'V12'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Vantage'),
    'V8 Vantage'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Vantage'),
    'V8 Vantage F1 Edition'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Vantage'),
    'V8 Vantage N430'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Vantage'),
    'V8 Vantage Roadster'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Aston Martin' AND s.name = 'Vantage'),
    'V8 Vantage S'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1'),
    '1.6 TDI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A2'),
    '1.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3'),
    'A3 Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3'),
    'A3 Hatchback'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3'),
    'A3 Sedan'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3'),
    'A3 Sportback'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A3 Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A3 Hatchback'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A3 Sportback'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A4 AVANT'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A4 Allroad quatro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A4 Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4'),
    'A4 Sedan'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A3 Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A3 Hatchback'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A5 Avant'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A5 Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A5 Coupe'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A5 Sedan'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5'),
    'A5 Sportback'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A6'),
    'A3 Cabrio'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '2.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '2.5 TDI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '3.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '3.0 TDI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '3.2 FSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '4.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '4.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '4.2 TDI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '46057'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '50 TDI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '55 TFSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '6.3 FSI Quattro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8'),
    '60 TFSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'E-Tron GT'),
    'GT Quattro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'E-Tron GT'),
    'GT RS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'R8'),
    '4.2 FSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'R8'),
    '5.2 FSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'RS'),
    'RS 3'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'RS'),
    'RS 4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'RS'),
    'RS 6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'RS'),
    'RS 7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi'),
    'S3'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi'),
    'S4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi'),
    'S5'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi'),
    'S6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'TTS'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '1.6 D'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '1.6 TD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '1.8 S'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '1.9 TDI'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '46174'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '46235'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '80 Serisi'),
    '46236'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '100 Serisi'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '100 Serisi'),
    '2.8 Quattro'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '100 Serisi'),
    '46266'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = '200 Serisi'),
    '46055'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Continental'),
    'Flying Spur'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Continental'),
    'Flying Spur Speed'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Continental'),
    'GT'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Continental'),
    'GT Supersports'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Continental'),
    'GTC'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Continental'),
    'GTC Speed'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Flying Spor'),
    '4.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Flying Spor'),
    '6.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Azure'),
    '6.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Bentley' AND s.name = 'Mulsanne'),
    '6.75'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Buick' AND s.name = 'Le Sabre'),
    '3.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Buick' AND s.name = 'Park Avenue'),
    '3.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Buick' AND s.name = 'Regal'),
    '3.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Buick' AND s.name = 'Riviera'),
    '3.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Buick' AND s.name = 'Roadmaster'),
    '5.7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Buick' AND s.name = 'Skylark'),
    '2.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Dolphin'),
    'Confort'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Dolphin'),
    'Design'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Dolphin'),
    'Standart'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'F3'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Han'),
    'Executive'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Song L'),
    'Excellence'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Seal'),
    'Design'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'BYD' AND s.name = 'Seal'),
    'Excellence'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'CTS'),
    '2.0 L'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'CTS'),
    '2.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'CTS'),
    '3.2'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'CTS'),
    '6.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'Brougham'),
    '5.7 STD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'DeVille'),
    '4.6 Concours'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'DeVille'),
    '4.6 DTS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'Eldorado'),
    '4.9 STD'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'Fleetwood'),
    '4.9'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'Fleetwood'),
    '5.7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'Seville'),
    '4.6 STS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'Seville'),
    '4.9 STS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Cadillac' AND s.name = 'STS'),
    '3.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Alia'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Chance'),
    '1.6 Norma'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Chance'),
    '2.0 Lusso'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Kimo'),
    '1.3'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Niche'),
    '1.6 Lusso'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Niche'),
    '1.6 Norma'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Niche'),
    '2.0 Lusso'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo'),
    '1.2'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo'),
    '1.3 D'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo'),
    '1.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Camaro'),
    '2.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Camaro'),
    '3.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Camaro'),
    '6.2'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Camaro'),
    'RS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Camaro'),
    'SS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Camaro'),
    'Z28'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Caprice'),
    '5.0 LS'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Celebrity'),
    '3.1'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Corvette'),
    'C4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Corvette'),
    'C5'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Corvette'),
    'C6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Corvette'),
    'C7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Corvette'),
    'C8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Corvette'),
    'Z06'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze'),
    '1.4 T'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze'),
    '2.0 D'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Epica'),
    '2.0 D LT'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Epica'),
    '2.0 LT'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Evanda'),
    '2.0 CDX'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Impala'),
    '3.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Impala'),
    '3.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Impala'),
    '5.7'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Kalos'),
    '1.2'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Kalos'),
    '1.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti'),
    '1.4'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti'),
    '1.6'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Rezzo'),
    '1.6 SX Comfort'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark'),
    '0.8'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark'),
    '1.0'
);
INSERT INTO vehicle_catalog_models (series_id, name) VALUES (
    (SELECT s.id FROM vehicle_catalog_series s 
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark'),
    '1.2'
);

-- Insert alt models
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia' AND m.name = '2.0'),
    'Competizione'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia' AND m.name = '2.0'),
    'Veloce'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia' AND m.name = '2.0 T'),
    'Sprint'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulia' AND m.name = '2.0 T'),
    'Veloce'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.4 TB'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.4 TB'),
    'MultiAir Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.4 TB'),
    'MultiAir Progression Pluse'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.4 TB'),
    'MultiAir Super TCT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.4 TB'),
    'Progression Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'Giulietta'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'Progression'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'Progression Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'Sprint'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'Super TCT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.6 JTD'),
    'TI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Giulietta' AND m.name = '1.75 TBI'),
    'Quadrifoglio Verde'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145' AND m.name = '1.4'),
    'TS STD'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145' AND m.name = '1.6'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145' AND m.name = '1.6'),
    'L'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145' AND m.name = '1.6'),
    'TS Sportivo'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145' AND m.name = '2.0'),
    'Quadrifoglio'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '145' AND m.name = '2.0'),
    'TS QV'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146' AND m.name = '1.4'),
    'TS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146' AND m.name = '1.4'),
    'TS Ritmo'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146' AND m.name = '1.6'),
    'L'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146' AND m.name = '1.6'),
    'TS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '146' AND m.name = '2.0 Ti'),
    'L'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '1.6 TS'),
    'Black Line'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '1.6 TS'),
    'Collezione'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '1.6 TS'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '1.6 TS'),
    'Progression'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '1.9'),
    'JTD Q2'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '2.0 TS'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '147' AND m.name = '2.0 TS'),
    'Selespeed Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '155' AND m.name = '2.0'),
    'TS Sportivo'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '155' AND m.name = '2.0'),
    'TS Super Losso'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '1.6 TS'),
    '1.6 TS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '1.6 TS'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '1.6 TS'),
    'Progression'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '1.9 JTD'),
    'Impression'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '1.9 JTD'),
    'Sportwagon'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '2.0 JTS'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '2.0 TS'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '2.0 TS'),
    'Executive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '2.0 TS'),
    'Selespeed'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '156' AND m.name = '2.5'),
    '46144'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159' AND m.name = '1.9 JTD'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159' AND m.name = '1.9 JTD'),
    'Distinctive Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159' AND m.name = '1.9 JTD'),
    'Progression'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159' AND m.name = '1.9 JTS'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '159' AND m.name = '3.2 TJS'),
    'Q4 Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '166' AND m.name = '2.0'),
    'TB'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '33' AND m.name = '1.5'),
    'Giardinetta'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = '33' AND m.name = '1.7'),
    'IE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Brera' AND m.name = '2.2'),
    'JTS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'GT' AND m.name = '1.9 JTD'),
    'Q2'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'GT' AND m.name = '2.0 JTS'),
    'Dis. Selespeed'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'GTV' AND m.name = '2.0'),
    'TB'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.3 jtd'),
    'City'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.4 TB'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.4 TB'),
    'Multi Quadrifoglio Verde'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.4 TB'),
    'MultiAir TCT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.4 TB'),
    'MultiAir TCT Sportivo'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.4 TB'),
    'Prograssion'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.6 JTD'),
    'Distinctive'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Alfa Romeo' AND s.name = 'Mito' AND m.name = '1.6 JTD'),
    'Prograssion'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1' AND m.name = '1.4 TFSI'),
    'Ambition'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1' AND m.name = '1.4 TFSI'),
    'Attraction'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1' AND m.name = '1.6 TDI'),
    'Ambition'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1' AND m.name = '1.6 TDI'),
    'Attraction'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1' AND m.name = '1.6 TDI'),
    'S Line'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A1' AND m.name = '1.6 TDI'),
    'Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '1.2 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '1.5 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Cabrio'),
    '35 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A3 Cabrio'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A3 Cabrio'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A6' AND m.name = 'A3 Cabrio'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '1.6 FSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '1.6 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '1.8'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '1.9 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '2.0 FSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Hatchback'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A3 Hatchback'),
    '1.8'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A3 Hatchback'),
    '1.8'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '1.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '1.2 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '1.5 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '1.6 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '30 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '30 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sedan'),
    '35 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.2 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.5 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.6 FSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.6 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.8'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.8 T'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '1.9 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '2.0 FSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '3.2'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '30 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '30 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A3' AND m.name = 'A3 Sportback'),
    '35 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A3 Sportback'),
    '35 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '1.8'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '1.8 T'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '1.9 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0 TDI Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0 TDI Dynamic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0 TDI Quatto Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0 TDI Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.0 TFSI Quttro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.5 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.5 TDI Quatro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '2.7'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '3.0 Quatro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 AVANT'),
    '40 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Cabrio'),
    '1.8 T'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Cabrio'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Cabrio'),
    '2.5 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Cabrio'),
    '3.0'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Cabrio'),
    '3.0 Quatro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.4 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.4 TFSI Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.4 TFSI Dynamic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.4 TFSI Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.8'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.8 Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.8 T'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.8 T Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.9 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '1.9 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Dynamic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Quatro Dynamic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Quatto'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Quatto Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Quattro Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI S Line'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TDI Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TFSI Quatro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.0 TFSI Quattro S Line'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.4'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.5 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.5 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.7 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '2.8 Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '3.0 Quatro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '3.0 TDI Quttaro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '40 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Sedan'),
    '45 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Allroad quatro'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Allroad quatro'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Allroad quatro'),
    '40 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A4' AND m.name = 'A4 Allroad quatro'),
    '45 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Avant'),
    '2.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Cabrio'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Cabrio'),
    '2.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Cabrio'),
    '40 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Cabrio'),
    '45 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '1.4 TFSI Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '1.4 TFSI Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '1.8 TFSI S Line'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '2.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '2.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '2.7 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '3.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '3.2 FSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '40 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Coupe'),
    '45 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sedan'),
    '2.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sedan'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sedan'),
    '2.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '1.4 TFSI Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '1.4 TFSI Dynamic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '1.4 TFSI Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '1.8 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TDI Quattro Design'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TDI Quattro Dynamic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TDI Quattro Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '2.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '3.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '40 TDI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A5' AND m.name = 'A5 Sportback'),
    '45 TFSI'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '50 TDI'),
    'Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '50 TDI'),
    'Quattro Long'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '55 TFSI'),
    'Quattro Long'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '60 TFSI'),
    'Quattro Long'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '3.0 TDI'),
    'Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '3.0 TDI'),
    'Quattro Long'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '46057'),
    'FSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '46057'),
    'Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '46057'),
    'Quattro Long'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '4.2 TDI'),
    'Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'A8' AND m.name = '4.2 TDI'),
    'Quattro Long'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'R8' AND m.name = '4.2 FSI'),
    'Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'R8' AND m.name = '4.2 FSI'),
    'Quattro R-tronic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'R8' AND m.name = '5.2 FSI'),
    'Quattro R-tronic'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi' AND m.name = 'S3'),
    '1.8 T Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi' AND m.name = 'S3'),
    '2.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi' AND m.name = 'S4'),
    '3.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi' AND m.name = 'S5'),
    '3.0 TFSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi' AND m.name = 'S5'),
    '4.2 FSI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'S Serisi' AND m.name = 'S6'),
    '3.0 TDI Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Audi' AND s.name = 'TTS' AND m.name = '2.0 TFSI'),
    'Quattro'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Alia' AND m.name = '1.6'),
    'Acteco Forza'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Alia' AND m.name = '1.6'),
    'Acteco Lusso'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Alia' AND m.name = '1.6'),
    'Acteco Norma'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Kimo' AND m.name = '1.3'),
    'Forza'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chery' AND s.name = 'Kimo' AND m.name = '1.3'),
    'Lusso'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.2'),
    'LS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.2'),
    'S'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.2'),
    'SE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.2'),
    'SX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.3 D'),
    'LS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.3 D'),
    'LT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.3 D'),
    'LTZ'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.4'),
    'LS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.4'),
    'LT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.4'),
    'LTZ'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.4'),
    'S'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.4'),
    'SE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Aveo' AND m.name = '1.4'),
    'SX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.4 T'),
    'LT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.4 T'),
    'LTZ'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.4 T'),
    'Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.4 T'),
    'Sport Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    '1.6'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'Design Edition'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'Design Edition Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'LS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'LS Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'LT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'LT Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'Sport'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'Sport Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'WTCC Edition'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '1.6'),
    'wtcc Edition Plus'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '2.0 D'),
    'LT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Cruze' AND m.name = '2.0 D'),
    'LTZ'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Kalos' AND m.name = '1.2'),
    'S'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Kalos' AND m.name = '1.4'),
    'SE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.4'),
    'CDX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.4'),
    'SX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.4'),
    'WTCC'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.6'),
    'CDX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.6'),
    'SE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.6'),
    'SX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Lacetti' AND m.name = '1.6'),
    'WTCC'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '0.8'),
    'S'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '0.8'),
    'SE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '1.0'),
    'LS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '1.0'),
    'SE'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '1.0'),
    'SX'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '1.2'),
    'LS'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '1.2'),
    'LT'
);
INSERT INTO vehicle_catalog_alt_models (model_id, name) VALUES (
    (SELECT m.id FROM vehicle_catalog_models m 
     JOIN vehicle_catalog_series s ON m.series_id = s.id
     JOIN vehicle_catalog_brands b ON s.brand_id = b.id 
     WHERE b.name = 'Chevrolet' AND s.name = 'Spark' AND m.name = '1.2'),
    'LTZ'
);

-- Insert trims with specifications
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Elektrik', 'Otomatik', 175, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Abarth' 
  AND s.name = '500e' 
  AND m.name = 'Cabrio';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Elektrik', 'Otomatik', 150, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aion' 
  AND s.name = 'S' 
  AND m.name = '580';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Elektrik', 'Otomatik', 150, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aion' 
  AND s.name = 'S Plus' 
  AND m.name = '70';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 280, 1995
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulia' 
  AND m.name = '2.0'
  AND am.name = 'Competizione';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 280, 1995
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulia' 
  AND m.name = '2.0'
  AND am.name = 'Veloce';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 200, 1995
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulia' 
  AND m.name = '2.0 T'
  AND am.name = 'Sprint';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 280, 1995
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulia' 
  AND m.name = '2.0 T'
  AND am.name = 'Veloce';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 520, 2891
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulia Quadrifoglio' 
  AND m.name = '2.9';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 120, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.4 TB'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 170, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.4 TB'
  AND am.name = 'MultiAir Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 170, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.4 TB'
  AND am.name = 'MultiAir Progression Pluse';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 170, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.4 TB'
  AND am.name = 'MultiAir Super TCT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 120, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.4 TB'
  AND am.name = 'Progression Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Giulietta';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Progression';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Progression Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Sprint';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Super TCT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.6 JTD'
  AND am.name = 'TI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 235, 1742
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Giulietta' 
  AND m.name = '1.75 TBI'
  AND am.name = 'Quadrifoglio Verde';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 103, 1370
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '1.4'
  AND am.name = 'TS STD';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 103, 1596
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '1.6'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 103, 1596
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '1.6'
  AND am.name = 'L';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '1.6'
  AND am.name = 'TS Sportivo';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 129, 1712
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '1.7';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 155, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '2.0'
  AND am.name = 'Quadrifoglio';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 150, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '145' 
  AND m.name = '2.0'
  AND am.name = 'TS QV';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 103, 1370
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '146' 
  AND m.name = '1.4'
  AND am.name = 'TS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 103, 1370
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '146' 
  AND m.name = '1.4'
  AND am.name = 'TS Ritmo';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 125, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '146' 
  AND m.name = '1.6'
  AND am.name = 'L';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 125, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '146' 
  AND m.name = '1.6'
  AND am.name = 'TS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 150, 1900
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '146' 
  AND m.name = '2.0 Ti'
  AND am.name = 'L';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '1.6 TS'
  AND am.name = 'Black Line';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '1.6 TS'
  AND am.name = 'Collezione';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '1.6 TS'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '1.6 TS'
  AND am.name = 'Progression';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Dizel', 'Manuel', 150, 1910
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '1.9'
  AND am.name = 'JTD Q2';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 150, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '2.0 TS'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 150, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '147' 
  AND m.name = '2.0 TS'
  AND am.name = 'Selespeed Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 150, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '155' 
  AND m.name = '2.0'
  AND am.name = 'TS Sportivo';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 150, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '155' 
  AND m.name = '2.0'
  AND am.name = 'TS Super Losso';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '1.6 TS'
  AND am.name = '1.6 TS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '1.6 TS'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '1.6 TS'
  AND am.name = 'Progression';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 125, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '1.9 JTD'
  AND am.name = 'Impression';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Manuel', 150, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '1.9 JTD'
  AND am.name = 'Sportwagon';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 165, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '2.0 JTS'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 155, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '2.0 TS'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 150, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '2.0 TS'
  AND am.name = 'Executive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 155, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '2.0 TS'
  AND am.name = 'Selespeed';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 190, 2492
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '156' 
  AND m.name = '2.5'
  AND am.name = '46144';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 150, 1910
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '159' 
  AND m.name = '1.9 JTD'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 150, 1910
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '159' 
  AND m.name = '1.9 JTD'
  AND am.name = 'Distinctive Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 150, 1910
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '159' 
  AND m.name = '1.9 JTD'
  AND am.name = 'Progression';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 160, 1859
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '159' 
  AND m.name = '1.9 JTS'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 260, 3195
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '159' 
  AND m.name = '3.2 TJS'
  AND am.name = 'Q4 Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 205, 1996
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '166' 
  AND m.name = '2.0'
  AND am.name = 'TB';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 94, 1490
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '33' 
  AND m.name = '1.5'
  AND am.name = 'Giardinetta';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 132, 1712
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '33' 
  AND m.name = '1.7'
  AND am.name = 'IE';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Manuel', 175, 1601
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = '75' 
  AND m.name = '1.8 T';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Manuel', 185, 2198
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Brera' 
  AND m.name = '2.2'
  AND am.name = 'JTS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Dizel', 'Manuel', 150, 1910
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'GT' 
  AND m.name = '1.9 JTD'
  AND am.name = 'Q2';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 165, 1970
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'GT' 
  AND m.name = '2.0 JTS'
  AND am.name = 'Dis. Selespeed';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Manuel', 200, 1996
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'GTV' 
  AND m.name = '2.0'
  AND am.name = 'TB';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Dizel', 'Manuel', 85, 1248
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.3 jtd'
  AND am.name = 'City';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 155, 1300
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.4 TB'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 170, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.4 TB'
  AND am.name = 'Multi Quadrifoglio Verde';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 135, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.4 TB'
  AND am.name = 'MultiAir TCT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 150, 1201
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.4 TB'
  AND am.name = 'MultiAir TCT Sportivo';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 155, 1368
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.4 TB'
  AND am.name = 'Prograssion';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Dizel', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Distinctive';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Dizel', 'Manuel', 120, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alfa Romeo' 
  AND s.name = 'Mito' 
  AND m.name = '1.6 JTD'
  AND am.name = 'Prograssion';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Elektrik', 'Otomatik', 200, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alpine' 
  AND s.name = 'A290' 
  AND m.name = 'GT';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Elektrik', 'Otomatik', 225, 1300
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Alpine' 
  AND s.name = 'A290' 
  AND m.name = 'GTS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 100, 1301
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Anadol' 
  AND s.name = 'A' 
  AND m.name = 'A1';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 75, 1300
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Anadol' 
  AND s.name = 'A' 
  AND m.name = 'A2';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 100, 1300
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Anadol' 
  AND s.name = 'A' 
  AND m.name = 'A2 SL';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 75, 1301
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Anadol' 
  AND s.name = 'SV' 
  AND m.name = '1.6';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 608, 5200
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB11' 
  AND m.name = 'Coupe';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 601, 3500
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB12' 
  AND m.name = 'Coupe';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 601, 3500
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB12' 
  AND m.name = 'Volante';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 425, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB7' 
  AND m.name = 'Coupe';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 425, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB7' 
  AND m.name = 'Volante';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 475, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB9' 
  AND m.name = 'Coupe';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 500, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB9' 
  AND m.name = 'Volante';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 547, 5935
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DB9' 
  AND m.name = 'GT 007 Bond Edition';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 517, 5935
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'DBS' 
  AND m.name = 'DBS Coupe';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 476, 5935
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Rapide' 
  AND m.name = 'V12 Rapide';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 575, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Rapide' 
  AND m.name = 'V12 Rapide S';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 601, 6001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Vanquish' 
  AND m.name = 'V12';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 426, 4735
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Vantage' 
  AND m.name = 'V8 Vantage';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 550, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Vantage' 
  AND m.name = 'V8 Vantage F1 Edition';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 525, 4501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Vantage' 
  AND m.name = 'V8 Vantage N430';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Roadster', 'Benzin', 'Otomatik', 385, 4300
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Vantage' 
  AND m.name = 'V8 Vantage Roadster';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 430, 4735
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Aston Martin' 
  AND s.name = 'Vantage' 
  AND m.name = 'V8 Vantage S';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 122, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A1' 
  AND m.name = '1.4 TFSI'
  AND am.name = 'Ambition';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 122, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A1' 
  AND m.name = '1.4 TFSI'
  AND am.name = 'Attraction';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 90, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A1' 
  AND m.name = '1.6 TDI'
  AND am.name = 'Ambition';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 90, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A1' 
  AND m.name = '1.6 TDI'
  AND am.name = 'Attraction';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 100, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A1' 
  AND m.name = '1.6 TDI'
  AND am.name = 'S Line';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A1' 
  AND m.name = '1.6 TDI'
  AND am.name = 'Sport';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 75, 1390
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A2' 
  AND m.name = '1.4';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design', 'Cabrio', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Cabrio', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Manuel', 105, 1197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.2 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Cabrio', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Cabrio', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attaction', 'Cabrio', 'Benzin', 'Otomatik', 140, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Cabrio', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A6' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design Line', 'Cabrio', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Cabrio', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Manuel', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 160, 1798
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Dizel', 'Otomatik', 140, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Cabrio'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.4 TFSI', 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attaction', 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.6', 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 101, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attaction', 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.6 FSI', 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 115, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6 FSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 3 Kapı', 'Dizel', 'Otomatik', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 3 Kapı', 'Dizel', 'Otomatik', 125, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attaction', 'Hatchback 3 Kapı', 'Dizel', 'Otomatik', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 3 Kapı', 'Benzin + LPG', 'Manuel', 125, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.8';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 125, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.8';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attaction', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 150, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.8';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attaction', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 105, 1896
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S - Line', 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 200, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 3 Kapı', 'Benzin', 'Otomatik', NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '2.0 FSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '2.0 TDI', 'Hatchback 3 Kapı', 'Dizel', 'Manuel', 140, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Hatchback'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design', 'Sedan', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '30 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Sedan', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '30 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Sedan', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '30 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Advanced', 'Sedan', 'Hibrit', 'Otomatik', 110, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '30 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Sedan', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '30 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S Line', 'Sedan', 'Hibrit', 'Otomatik', 110, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '30 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '35 TFSI', 'Sedan', 'Benzin', 'Otomatik', 150, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Advanced', 'Sedan', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design', 'Sedan', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Sedan', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S Line', 'Sedan', 'Hibrit', 'Otomatik', 150, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Sedan', 'Benzin', 'Otomatik', 150, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.0 TFSI', 'Sedan', 'Benzin', 'Otomatik', 125, 1300
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design Line', 'Sedan', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Sedan', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Sedan', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Sedan', 'Benzin', 'Manuel', 110, 1197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.2 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Sedan', 'Benzin', 'Manuel', 110, 1197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.2 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Sedan', 'Benzin', 'Manuel', 110, 1197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.2 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Sedan', 'Benzin', 'Otomatik', 140, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Sedan', 'Benzin', 'Otomatik', 140, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Sedan', 'Benzin', 'Otomatik', 140, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design Line', 'Sedan', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Sedan', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Sedan', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.6 TDI', 'Sedan', 'Dizel', 'Otomatik', 125, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Sedan', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Sedan', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Sedan', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design Line', 'Sedan', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Sedan', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S Line', 'Sedan', 'Dizel', 'Otomatik', 125, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Sedan', 'Dizel', 'Otomatik', 125, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sedan'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '30 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '30 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '30 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Advanced', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 110, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '30 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '30 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S Line', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 110, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '30 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Advanced', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'All Street', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A3 Sportback'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S Line', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '35 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design Line', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 116, 999
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 110, 1197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.2 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 110, 1197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.2 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.4 TFSI', 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 125, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 125, 1390
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 125, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1498
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.5 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.6', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 100, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 FSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Standart', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 105, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 110, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design Line', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Dynamic', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport Line', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 116, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.6 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 125, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.8';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambiente', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 150, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.8 T';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 160, 1798
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 160, 1798
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '1.9 TDI', 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 150, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Attraction', 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 125, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 150, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '2.0 FSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, '2.0 TDI', 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 140, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition', 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 140, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition Qutro', 'Hatchback 5 Kapı', 'Dizel', 'Manuel', 140, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Ambition Qutro', 'Hatchback 3 Kapı', 'Benzin', 'Manuel', 275, 3001
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A3' 
  AND m.name = 'A3 Sportback'
  AND am.name = '3.2';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Advanced', 'Station Wagon', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quttro S Line', 'Station Wagon', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin + LPG', 'Manuel', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin', 'Manuel', 125, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '1.8';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin + LPG', 'Manuel', 150, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '1.8 T';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 175, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Manuel', 150, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin + LPG', 'Manuel', 150, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 150, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0 TDI Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0 TDI Dynamic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0 TDI Quatto Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0 TDI Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin', 'Otomatik', 200, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.0 TFSI Quttro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Manuel', 163, 2496
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.5 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 150, 2496
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.5 TDI Quatro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Manuel', 200, 2500
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '2.7';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Benzin', 'Otomatik', 220, 2976
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 AVANT'
  AND am.name = '3.0 Quatro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 163, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Cabrio'
  AND am.name = '1.8 T';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 200, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Cabrio'
  AND am.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Dizel', 'Otomatik', 175, 2001
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Cabrio'
  AND am.name = '2.5 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin + LPG', 'Otomatik', 220, 2976
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Cabrio'
  AND am.name = '3.0';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 175, 2500
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Cabrio'
  AND am.name = '3.0 Quatro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Advanced', 'Sedan', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Advanced', 'Sedan', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Design', 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'S Line', 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro S Line', 'Sedan', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Sedan', 'Dizel', 'Otomatik', 200, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Advanced', 'Sedan', 'Benzin', 'Otomatik', 245, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quatro Design', 'Sedan', 'Benzin', 'Otomatik', 245, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro S Line', 'Sedan', 'Benzin', 'Otomatik', 265, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.4 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.4 TFSI Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.4 TFSI Dynamic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.4 TFSI Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 102, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 125, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.8';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 175, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.8 Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 163, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.8 T';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 120, 1789
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 150, 1781
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.8 T Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 130, 1896
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 115, 1896
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '1.9 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 130, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 177, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Dynamic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 200, 2001
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI S Line';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Quatto';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Quatto Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Quatro Dynamic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TDI Quattro Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 200, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 200, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TFSI Quatro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 225, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.0 TFSI Quattro S Line';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 170, 2393
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.4';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 163, 2496
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.5 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 180, 2496
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.5 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 150, 2598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 190, 2698
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.7 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 193, 2771
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '2.8 Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 220, 2996
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '3.0 Quatro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 250, 2501
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Sedan'
  AND am.name = '3.0 TDI Quttaro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 225, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Allroad quatro'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Hibrit', 'Otomatik', 265, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Allroad quatro'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 177, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Allroad quatro'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 275, 2001
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A4' 
  AND m.name = 'A4 Allroad quatro'
  AND am.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Station Wagon', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Avant'
  AND am.name = '2.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro S Line', 'Cabrio', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Cabrio'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro S Line', 'Cabrio', 'Benzin', 'Otomatik', 265, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Cabrio'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 175, 1601
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Cabrio'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 211, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Cabrio'
  AND am.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Advanced', 'Coupe', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro S Line', 'Coupe', 'Dizel', 'Otomatik', 250, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro S Line', 'Coupe', 'Benzin', 'Otomatik', 265, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '1.4 TFSI Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '1.4 TFSI Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 170, 1798
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Manuel', 200, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '1.8 TFSI S Line';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Dizel', 'Otomatik', 177, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '2.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 211, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 211, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Dizel', 'Otomatik', 190, 2698
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '2.7 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Dizel', 'Otomatik', 240, 2967
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '3.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 265, 3197
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Coupe'
  AND am.name = '3.2 FSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sedan'
  AND am.name = '2.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 204, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sedan'
  AND am.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 204, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sedan'
  AND am.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Advance', 'Hatchback 5 Kapı', 'Hibrit', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Design', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quatro S Line', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 204, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Sport', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '40 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quattro Advance', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 265, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Quatro S Line', 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 265, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '45 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '1.4 TFSI Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '1.4 TFSI Dynamic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 150, 1395
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '1.4 TFSI Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 160, 1798
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '1.8 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 200, 1801
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TDI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TDI Quattro Design';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TDI Quattro Dynamic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 190, 1968
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TDI Quattro Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 180, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 211, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, 'Sport', 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 252, 1984
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Dizel', 'Otomatik', 240, 2967
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A5' 
  AND m.name = 'A5 Sportback'
  AND am.name = '3.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '50 TDI'
  AND am.name = 'Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '50 TDI'
  AND am.name = 'Quattro Long';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '55 TFSI'
  AND am.name = 'Quattro Long';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '60 TFSI'
  AND am.name = 'Quattro Long';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '2.5 TDI';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '3.0';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '3.0 TDI'
  AND am.name = 'Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '3.0 TDI'
  AND am.name = 'Quattro Long';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '3.2 FSI';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '4.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '4.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '46057'
  AND am.name = 'FSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '46057'
  AND am.name = 'Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '46057'
  AND am.name = 'Quattro Long';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '4.2 TDI'
  AND am.name = 'Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '4.2 TDI'
  AND am.name = 'Quattro Long';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'A8' 
  AND m.name = '6.3 FSI Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'E-Tron GT' 
  AND m.name = 'GT Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'E-Tron GT' 
  AND m.name = 'GT RS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'R8' 
  AND m.name = '4.2 FSI'
  AND am.name = 'Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'R8' 
  AND m.name = '4.2 FSI'
  AND am.name = 'Quattro R-tronic';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'R8' 
  AND m.name = '5.2 FSI'
  AND am.name = 'Quattro R-tronic';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'RS' 
  AND m.name = 'RS 3';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'RS' 
  AND m.name = 'RS 4';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'RS' 
  AND m.name = 'RS 6';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'RS' 
  AND m.name = 'RS 7';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'S Serisi' 
  AND m.name = 'S3'
  AND am.name = '1.8 T Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'S Serisi' 
  AND m.name = 'S3'
  AND am.name = '2.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'S Serisi' 
  AND m.name = 'S4'
  AND am.name = '3.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'S Serisi' 
  AND m.name = 'S5'
  AND am.name = '3.0 TFSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'S Serisi' 
  AND m.name = 'S5'
  AND am.name = '4.2 FSI Quattro';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'S Serisi' 
  AND m.name = 'S6'
  AND am.name = '3.0 TDI Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'TTS' 
  AND m.name = '2.0 TFSI';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = 'TTS' 
  AND m.name = '2.0 TFSI'
  AND am.name = 'Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '46174';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '1.6 D';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '1.6 TD';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '46235';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '1.8 S';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '1.9 TDI';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '2.0';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '80 Serisi' 
  AND m.name = '46236';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '100 Serisi' 
  AND m.name = '46266';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '100 Serisi' 
  AND m.name = '2.0';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '100 Serisi' 
  AND m.name = '2.8 Quattro';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, NULL, NULL, NULL, NULL, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Audi' 
  AND s.name = '200 Serisi' 
  AND m.name = '46055';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 560, 5998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Continental' 
  AND m.name = 'Flying Spur';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 610, 5998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Continental' 
  AND m.name = 'Flying Spur Speed';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 525, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Continental' 
  AND m.name = 'GT';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 575, 3500
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Continental' 
  AND m.name = 'GTC';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 601, 3500
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Continental' 
  AND m.name = 'GTC Speed';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 630, 5998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Continental' 
  AND m.name = 'GT Supersports';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 550, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Flying Spor' 
  AND m.name = '4.0';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 575, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Flying Spor' 
  AND m.name = '6.0';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 575, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Azure' 
  AND m.name = '6.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 512, 6752
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Bentley' 
  AND s.name = 'Mulsanne' 
  AND m.name = '6.75';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 205, 3797
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Buick' 
  AND s.name = 'Le Sabre' 
  AND m.name = '3.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 225, 3797
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Buick' 
  AND s.name = 'Park Avenue' 
  AND m.name = '3.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 170, 3595
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Buick' 
  AND s.name = 'Regal' 
  AND m.name = '3.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 325, 3500
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Buick' 
  AND s.name = 'Riviera' 
  AND m.name = '3.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 262, 5733
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Buick' 
  AND s.name = 'Roadmaster' 
  AND m.name = '5.7';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 150, 2001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Buick' 
  AND s.name = 'Skylark' 
  AND m.name = '2.4';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Elektrik', 'Otomatik', 204, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Dolphin' 
  AND m.name = 'Standart';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Elektrik', 'Otomatik', 204, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Dolphin' 
  AND m.name = 'Confort';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Elektrik', 'Otomatik', 225, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Dolphin' 
  AND m.name = 'Design';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 125, 1301
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'F3' 
  AND m.name = '1.6';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Elektrik', 'Otomatik', 601, 6001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Han' 
  AND m.name = 'Executive';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Elektrik', 'Otomatik', 225, 1300
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Song L' 
  AND m.name = 'Excellence';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Elektrik', 'Otomatik', 218, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Seal' 
  AND m.name = 'Design';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Elektrik', 'Otomatik', 530, NULL
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'BYD' 
  AND s.name = 'Seal' 
  AND m.name = 'Excellence';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 300, 2001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'CTS' 
  AND m.name = '2.0 L';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 211, 2792
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'CTS' 
  AND m.name = '2.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 223, 3175
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'CTS' 
  AND m.name = '3.2';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Manuel', 400, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'CTS' 
  AND m.name = '6.0';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 223, 5735
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'Brougham' 
  AND m.name = '5.7 STD';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 175, 4001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'DeVille' 
  AND m.name = '4.6 Concours';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 400, 4501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'DeVille' 
  AND m.name = '4.6 DTS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 325, 4501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'Eldorado' 
  AND m.name = '4.9 STD';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 200, 4894
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'Fleetwood' 
  AND m.name = '4.9';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 260, 5733
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'Fleetwood' 
  AND m.name = '5.7';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 300, 4572
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'Seville' 
  AND m.name = '4.6 STS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 200, 4917
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'Seville' 
  AND m.name = '4.9 STS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 258, 3564
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Cadillac' 
  AND s.name = 'STS' 
  AND m.name = '3.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 110, 1595
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Alia' 
  AND m.name = '1.6'
  AND am.name = 'Acteco Forza';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 110, 1597
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Alia' 
  AND m.name = '1.6'
  AND am.name = 'Acteco Lusso';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 110, 1597
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Alia' 
  AND m.name = '1.6'
  AND am.name = 'Acteco Norma';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 119, 1597
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Chance' 
  AND m.name = '1.6 Norma';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 136, 1971
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Chance' 
  AND m.name = '2.0 Lusso';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 84, 1297
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Kimo' 
  AND m.name = '1.3'
  AND am.name = 'Forza';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Otomatik', 84, 1297
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Kimo' 
  AND m.name = '1.3'
  AND am.name = 'Lusso';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 125, 1301
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Niche' 
  AND m.name = '1.6 Lusso';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 119, 1597
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Niche' 
  AND m.name = '1.6 Norma';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 136, 1971
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chery' 
  AND s.name = 'Niche' 
  AND m.name = '2.0 Lusso';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 70, 1229
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.2'
  AND am.name = 'LS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 72, 1150
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.2'
  AND am.name = 'S';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 72, 1150
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.2'
  AND am.name = 'SE';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 84, 1206
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.2'
  AND am.name = 'SX';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 75, 1248
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.3 D'
  AND am.name = 'LS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 75, 1248
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.3 D'
  AND am.name = 'LT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Manuel', 95, 1248
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.3 D'
  AND am.name = 'LTZ';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 100, 1398
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.4'
  AND am.name = 'LS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 100, 1398
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.4'
  AND am.name = 'LT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 100, 1398
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.4'
  AND am.name = 'LTZ';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 94, 1399
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.4'
  AND am.name = 'S';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 94, 1399
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.4'
  AND am.name = 'SE';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 94, 1399
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Aveo' 
  AND m.name = '1.4'
  AND am.name = 'SX';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 275, 1998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Camaro' 
  AND m.name = '2.0';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 350, 3500
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Camaro' 
  AND m.name = '3.6';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 500, 6001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Camaro' 
  AND m.name = '6.2';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 350, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Camaro' 
  AND m.name = 'RS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Manuel', 432, 6162
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Camaro' 
  AND m.name = 'SS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin + LPG', 'Otomatik', 300, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Camaro' 
  AND m.name = 'Z28';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 475, 5001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Caprice' 
  AND m.name = '5.0 LS';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Statino Wagon', 'Benzin', 'Otomatik', 175, 3001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Celebrity' 
  AND m.name = '3.1';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 400, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Corvette' 
  AND m.name = 'C4';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 344, 5666
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Corvette' 
  AND m.name = 'C5';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 404, 5967
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Corvette' 
  AND m.name = 'C6';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 550, 6001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Corvette' 
  AND m.name = 'C7';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Coupe', 'Benzin', 'Otomatik', 755, 6162
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Corvette' 
  AND m.name = 'C8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Cabrio', 'Benzin', 'Otomatik', 500, 6001
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Corvette' 
  AND m.name = 'Z06';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Statino Wagon', 'Benzin + LPG', 'Manuel', 140, 1362
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.4 T'
  AND am.name = 'LT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 140, 1362
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.4 T'
  AND am.name = 'LTZ';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 140, 1362
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.4 T'
  AND am.name = 'Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 140, 1362
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.4 T'
  AND am.name = 'Sport Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = '1.6';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'Design Edition';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'Design Edition Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 113, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'LS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'LS Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'LT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'LT Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'Sport';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 117, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'Sport Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'WTCC Edition';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 124, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '1.6'
  AND am.name = 'wtcc Edition Plus';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 163, 1998
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '2.0 D'
  AND am.name = 'LT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Dizel', 'Otomatik', 163, 1998
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Cruze' 
  AND m.name = '2.0 D'
  AND am.name = 'LTZ';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 150, 1998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Epica' 
  AND m.name = '2.0 D LT';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Manuel', 150, 1998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Epica' 
  AND m.name = '2.0 LT';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 131, 1998
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Evanda' 
  AND m.name = '2.0 CDX';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 325, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Impala' 
  AND m.name = '3.6';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 225, 3501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Impala' 
  AND m.name = '3.8';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Sedan', 'Benzin', 'Otomatik', 200, 5501
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Impala' 
  AND m.name = '5.7';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 72, 1150
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Kalos' 
  AND m.name = '1.2'
  AND am.name = 'S';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 72, 1150
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Kalos' 
  AND m.name = '1.4'
  AND am.name = 'SE';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 109, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.4'
  AND am.name = 'CDX';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 95, 1399
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.4'
  AND am.name = 'SX';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 95, 1399
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.4'
  AND am.name = 'WTCC';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 125, 1301
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.6'
  AND am.name = 'CDX';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 109, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.6'
  AND am.name = 'SE';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Otomatik', 109, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.6'
  AND am.name = 'SX';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Sedan', 'Benzin + LPG', 'Otomatik', 109, 1598
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Lacetti' 
  AND m.name = '1.6'
  AND am.name = 'WTCC';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'MPV', 'Benzin', 'Manuel', 108, 1598
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Rezzo' 
  AND m.name = '1.6 SX Comfort';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 51, 796
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '0.8'
  AND am.name = 'S';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 51, 796
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '0.8'
  AND am.name = 'SE';
INSERT INTO vehicle_catalog_trims (model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT m.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 68, 995
FROM vehicle_catalog_models m
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.0';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 75, 1300
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.0'
  AND am.name = 'LS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin + LPG', 'Manuel', 66, 995
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.0'
  AND am.name = 'SE';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 66, 995
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.0'
  AND am.name = 'SX';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 81, 1206
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.2'
  AND am.name = 'LS';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 81, 1206
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.2'
  AND am.name = 'LT';
INSERT INTO vehicle_catalog_trims (alt_model_id, name, body_type, fuel_type, transmission, engine_power, engine_displacement)
SELECT am.id, NULL, 'Hatchback 5 Kapı', 'Benzin', 'Manuel', 82, 1206
FROM vehicle_catalog_alt_models am
JOIN vehicle_catalog_models m ON am.model_id = m.id
JOIN vehicle_catalog_series s ON m.series_id = s.id
JOIN vehicle_catalog_brands b ON s.brand_id = b.id
WHERE b.name = 'Chevrolet' 
  AND s.name = 'Spark' 
  AND m.name = '1.2'
  AND am.name = 'LTZ';
