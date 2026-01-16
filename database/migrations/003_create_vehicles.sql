-- Create vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gallery_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    listing_no VARCHAR(20) UNIQUE NOT NULL,
    brand VARCHAR(100),
    series VARCHAR(100),
    model VARCHAR(100),
    year INTEGER,
    fuel_type VARCHAR(20) CHECK (fuel_type IN ('benzin', 'dizel', 'lpg', 'elektrik', 'hibrit')),
    transmission VARCHAR(20) CHECK (transmission IN ('manuel', 'otomatik', 'yarı_otomatik')),
    body_type VARCHAR(20) CHECK (body_type IN ('sedan', 'hatchback', 'suv', 'pickup', 'minivan', 'coupe', 'cabrio', 'station')),
    engine_power INTEGER,
    engine_cc INTEGER,
    drivetrain VARCHAR(20) CHECK (drivetrain IN ('önden', 'arkadan', 'dört_çeker')),
    color VARCHAR(50),
    vehicle_condition VARCHAR(20) CHECK (vehicle_condition IN ('sıfır', 'ikinci_el')),
    mileage INTEGER,
    has_warranty BOOLEAN DEFAULT FALSE,
    warranty_details TEXT,
    heavy_damage_record BOOLEAN DEFAULT FALSE,
    plate_number VARCHAR(20),
    plate_nationality VARCHAR(10) DEFAULT 'TR',
    seller_type VARCHAR(20) CHECK (seller_type IN ('galeriden', 'sahibinden')),
    trade_in_acceptable BOOLEAN DEFAULT FALSE,
    base_price DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'TRY',
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'paused', 'archived', 'sold')),
    search_vector TSVECTOR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Create indexes
CREATE INDEX idx_vehicles_gallery ON vehicles(gallery_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_brand ON vehicles(brand);
CREATE INDEX idx_vehicles_year ON vehicles(year);
CREATE INDEX idx_vehicles_price ON vehicles(base_price);
CREATE INDEX idx_vehicles_listing ON vehicles(listing_no);
CREATE INDEX idx_vehicles_search ON vehicles USING GIN(search_vector);

-- Create function to update search vector
CREATE OR REPLACE FUNCTION update_vehicle_search_vector() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('turkish', COALESCE(NEW.brand, '')), 'A') ||
        setweight(to_tsvector('turkish', COALESCE(NEW.series, '')), 'A') ||
        setweight(to_tsvector('turkish', COALESCE(NEW.model, '')), 'A') ||
        setweight(to_tsvector('turkish', COALESCE(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER vehicle_search_vector_update
    BEFORE INSERT OR UPDATE ON vehicles
    FOR EACH ROW
    EXECUTE FUNCTION update_vehicle_search_vector();
















