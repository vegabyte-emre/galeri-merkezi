-- Add video and Oto Shorts support to vehicles
-- Migration: 016_add_vehicle_video_shorts.sql

-- Add video-related columns to vehicle_media table
ALTER TABLE vehicle_media 
ADD COLUMN IF NOT EXISTS duration_seconds INTEGER,
ADD COLUMN IF NOT EXISTS video_thumbnail_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS video_preview_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS width INTEGER,
ADD COLUMN IF NOT EXISTS height INTEGER;

-- Add Oto Shorts publishing columns to vehicles table
ALTER TABLE vehicles
ADD COLUMN IF NOT EXISTS video_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS video_thumbnail_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS publish_to_oto_shorts BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS oto_shorts_status VARCHAR(20) DEFAULT NULL CHECK (oto_shorts_status IS NULL OR oto_shorts_status IN ('pending', 'processing', 'published', 'rejected', 'removed')),
ADD COLUMN IF NOT EXISTS oto_shorts_published_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS oto_shorts_view_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS oto_shorts_like_count INTEGER DEFAULT 0;

-- Create oto_shorts table for managing short videos
CREATE TABLE IF NOT EXISTS oto_shorts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    gallery_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    
    -- Video details
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration_seconds INTEGER,
    file_size_bytes INTEGER,
    
    -- Publishing info
    title VARCHAR(200),
    description TEXT,
    hashtags TEXT[], -- Array of hashtags
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'published', 'rejected', 'removed')),
    rejection_reason TEXT,
    
    -- Engagement
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    
    -- Audit
    created_by UUID REFERENCES users(id),
    
    CONSTRAINT unique_vehicle_short UNIQUE(vehicle_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_oto_shorts_gallery ON oto_shorts(gallery_id);
CREATE INDEX IF NOT EXISTS idx_oto_shorts_status ON oto_shorts(status);
CREATE INDEX IF NOT EXISTS idx_oto_shorts_published ON oto_shorts(published_at DESC) WHERE status = 'published';
CREATE INDEX IF NOT EXISTS idx_oto_shorts_popular ON oto_shorts(view_count DESC) WHERE status = 'published';

-- Add comment for documentation
COMMENT ON TABLE oto_shorts IS 'Stores vehicle short videos for Oto Shorts feature in mobile app';
COMMENT ON COLUMN vehicles.publish_to_oto_shorts IS 'Whether to publish vehicle video to Oto Shorts (default true)';
COMMENT ON COLUMN oto_shorts.hashtags IS 'Array of hashtags for discoverability';
