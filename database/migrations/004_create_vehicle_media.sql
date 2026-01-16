-- Create vehicle_media table
CREATE TABLE IF NOT EXISTS vehicle_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('photo', 'video', 'document', 'expertise')),
    original_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    watermarked_url VARCHAR(500),
    large_url VARCHAR(500),
    medium_url VARCHAR(500),
    cdn_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size INTEGER,
    mime_type VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    is_cover BOOLEAN DEFAULT FALSE,
    processing_status VARCHAR(20) DEFAULT 'pending' CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')),
    processing_error TEXT,
    cdn_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by UUID REFERENCES users(id)
);

-- Create indexes
CREATE INDEX idx_vehicle_media_vehicle ON vehicle_media(vehicle_id);
CREATE INDEX idx_vehicle_media_type ON vehicle_media(type);
CREATE INDEX idx_vehicle_media_cover ON vehicle_media(vehicle_id, is_cover) WHERE is_cover = TRUE;

-- Ensure only one cover per vehicle
CREATE UNIQUE INDEX idx_vehicle_media_unique_cover ON vehicle_media(vehicle_id) WHERE is_cover = TRUE;
















