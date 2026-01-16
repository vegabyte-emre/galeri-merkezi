-- Create channels table
CREATE TABLE IF NOT EXISTS channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    logo_url VARCHAR(500),
    adapter_type VARCHAR(50),
    api_base_url VARCHAR(500),
    api_version VARCHAR(20),
    rate_limit_per_minute INTEGER DEFAULT 60,
    supports_push BOOLEAN DEFAULT TRUE,
    supports_pull BOOLEAN DEFAULT FALSE,
    field_mapping JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create gallery_channel_credentials table
CREATE TABLE IF NOT EXISTS gallery_channel_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gallery_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    channel_id UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    credentials JSONB NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(gallery_id, channel_id)
);

-- Create indexes
CREATE INDEX idx_channel_credentials_gallery ON gallery_channel_credentials(gallery_id);
CREATE INDEX idx_channel_credentials_channel ON gallery_channel_credentials(channel_id);
















