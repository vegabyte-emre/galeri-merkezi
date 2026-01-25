-- Add SEO-friendly slug column to vehicles table
-- This enables clean URLs like /arac/2024-bmw-320i-m-sport-beyaz-12345

-- Add slug column to vehicles
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS slug VARCHAR(500);

-- Create index for slug lookups
CREATE INDEX IF NOT EXISTS idx_vehicles_slug ON vehicles(slug);

-- Create function to generate SEO-friendly slug
CREATE OR REPLACE FUNCTION generate_vehicle_slug() RETURNS TRIGGER AS $$
DECLARE
    base_slug TEXT;
    final_slug TEXT;
    slug_exists BOOLEAN;
    counter INTEGER := 0;
BEGIN
    -- Build base slug from vehicle info: year-brand-model-series-color-listing_no
    base_slug := LOWER(
        COALESCE(NEW.year::TEXT, '') || '-' ||
        COALESCE(NEW.brand, '') || '-' ||
        COALESCE(NEW.model, '') ||
        CASE WHEN NEW.series IS NOT NULL AND NEW.series != '' THEN '-' || NEW.series ELSE '' END ||
        CASE WHEN NEW.color IS NOT NULL AND NEW.color != '' THEN '-' || NEW.color ELSE '' END ||
        '-' || COALESCE(NEW.listing_no, NEW.id::TEXT)
    );
    
    -- Turkish character replacements
    base_slug := REPLACE(base_slug, 'ş', 's');
    base_slug := REPLACE(base_slug, 'ğ', 'g');
    base_slug := REPLACE(base_slug, 'ı', 'i');
    base_slug := REPLACE(base_slug, 'ö', 'o');
    base_slug := REPLACE(base_slug, 'ü', 'u');
    base_slug := REPLACE(base_slug, 'ç', 'c');
    base_slug := REPLACE(base_slug, 'Ş', 's');
    base_slug := REPLACE(base_slug, 'Ğ', 'g');
    base_slug := REPLACE(base_slug, 'İ', 'i');
    base_slug := REPLACE(base_slug, 'Ö', 'o');
    base_slug := REPLACE(base_slug, 'Ü', 'u');
    base_slug := REPLACE(base_slug, 'Ç', 'c');
    
    -- Remove special characters and replace spaces with hyphens
    base_slug := REGEXP_REPLACE(base_slug, '[^a-z0-9\-]', '-', 'g');
    base_slug := REGEXP_REPLACE(base_slug, '\-+', '-', 'g');
    base_slug := TRIM(BOTH '-' FROM base_slug);
    
    -- Set final slug
    final_slug := base_slug;
    
    -- Check for uniqueness and add counter if needed
    LOOP
        SELECT EXISTS(
            SELECT 1 FROM vehicles 
            WHERE slug = final_slug AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::UUID)
        ) INTO slug_exists;
        
        EXIT WHEN NOT slug_exists;
        
        counter := counter + 1;
        final_slug := base_slug || '-' || counter;
    END LOOP;
    
    NEW.slug := final_slug;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate slug
DROP TRIGGER IF EXISTS vehicle_slug_generate ON vehicles;
CREATE TRIGGER vehicle_slug_generate
    BEFORE INSERT OR UPDATE OF brand, model, series, year, color, listing_no ON vehicles
    FOR EACH ROW
    WHEN (NEW.slug IS NULL OR NEW.slug = '' OR 
          OLD.brand IS DISTINCT FROM NEW.brand OR 
          OLD.model IS DISTINCT FROM NEW.model OR
          OLD.series IS DISTINCT FROM NEW.series OR
          OLD.year IS DISTINCT FROM NEW.year OR
          OLD.color IS DISTINCT FROM NEW.color)
    EXECUTE FUNCTION generate_vehicle_slug();

-- Update existing vehicles with slugs
UPDATE vehicles SET slug = NULL WHERE slug IS NULL OR slug = '';
UPDATE vehicles v SET 
    slug = LOWER(
        COALESCE(year::TEXT, '') || '-' ||
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    COALESCE(brand, '') || '-' || COALESCE(model, '') ||
                    CASE WHEN series IS NOT NULL AND series != '' THEN '-' || series ELSE '' END ||
                    CASE WHEN color IS NOT NULL AND color != '' THEN '-' || color ELSE '' END ||
                    '-' || COALESCE(listing_no, id::TEXT),
                'ş', 's'), 'ğ', 'g'), 'ı', 'i'), 'ö', 'o'), 'ü', 'u'), 'ç', 'c'),
                'Ş', 's'), 'Ğ', 'g'), 'İ', 'i'), 'Ö', 'o'), 'Ü', 'u'), 'Ç', 'c'),
                '[^a-zA-Z0-9\-]', '-', 'g'),
            '\-+', '-', 'g')
    )
WHERE slug IS NULL OR slug = '';

-- Make slug NOT NULL after populating existing records
-- ALTER TABLE vehicles ALTER COLUMN slug SET NOT NULL;

-- Add unique constraint (optional - might cause issues if duplicates exist)
-- ALTER TABLE vehicles ADD CONSTRAINT vehicles_slug_unique UNIQUE (slug);
