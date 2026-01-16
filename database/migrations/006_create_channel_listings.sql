-- Create channel_listings table
CREATE TABLE IF NOT EXISTS channel_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    channel_id UUID NOT NULL REFERENCES channels(id) ON DELETE CASCADE,
    base_price DECIMAL(15,2),
    channel_price DECIMAL(15,2),
    pricing_rule_type VARCHAR(20) CHECK (pricing_rule_type IN ('fixed', 'percentage', 'manual')),
    pricing_rule_value DECIMAL(10,2),
    rounding_rule VARCHAR(20) CHECK (rounding_rule IN ('none', 'round_100', 'round_1000', 'round_up', 'round_down')),
    min_price_protection DECIMAL(15,2),
    campaign_price DECIMAL(15,2),
    campaign_start DATE,
    campaign_end DATE,
    external_listing_id VARCHAR(100),
    external_url VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'paused', 'error', 'removed')),
    last_sync_at TIMESTAMP,
    last_sync_status VARCHAR(20) CHECK (last_sync_status IN ('success', 'partial', 'failed')),
    last_error TEXT,
    retry_count INTEGER DEFAULT 0,
    next_retry_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(vehicle_id, channel_id)
);

-- Create indexes
CREATE INDEX idx_channel_listings_vehicle ON channel_listings(vehicle_id);
CREATE INDEX idx_channel_listings_channel ON channel_listings(channel_id);
CREATE INDEX idx_channel_listings_status ON channel_listings(status);
CREATE INDEX idx_channel_listings_external ON channel_listings(external_listing_id);
















