-- ========== 001_create_galleries.sql ==========
-- Create galleries table
CREATE TABLE IF NOT EXISTS galleries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    tax_type VARCHAR(4) NOT NULL CHECK (tax_type IN ('TCKN', 'VKN')),
    tax_number VARCHAR(11) NOT NULL,
    authority_document_no VARCHAR(50),
    authority_verified BOOLEAN DEFAULT FALSE,
    authority_verified_at TIMESTAMP,
    eids_verified BOOLEAN DEFAULT FALSE,
    eids_verification_date TIMESTAMP,
    eids_verification_code VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'suspended', 'rejected')),
    rejection_reason TEXT,
    rejection_template_id UUID,
    phone VARCHAR(20),
    whatsapp VARCHAR(20),
    email VARCHAR(255),
    city VARCHAR(100),
    district VARCHAR(100),
    neighborhood VARCHAR(100),
    address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    logo_url VARCHAR(500),
    cover_url VARCHAR(500),
    working_hours JSONB,
    subscription_plan_id UUID,
    subscription_start DATE,
    subscription_end DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by UUID
);

-- Create indexes
CREATE INDEX idx_galleries_status ON galleries(status);
CREATE INDEX idx_galleries_city ON galleries(city);
CREATE INDEX idx_galleries_slug ON galleries(slug);
CREATE INDEX idx_galleries_tax ON galleries(tax_number);


















-- ========== 002_create_users.sql ==========
-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gallery_id UUID REFERENCES galleries(id) ON DELETE CASCADE,
    phone VARCHAR(20) UNIQUE NOT NULL,
    phone_verified BOOLEAN DEFAULT FALSE,
    phone_verified_at TIMESTAMP,
    email VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    tckn VARCHAR(11),
    avatar_url VARCHAR(500),
    role VARCHAR(50) NOT NULL CHECK (role IN (
        'superadmin', 'compliance_officer', 'support_agent', 'integration_manager', 'finance_reporter',
        'gallery_owner', 'gallery_manager', 'sales_rep', 'inventory_manager', 'viewer'
    )),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
    last_login TIMESTAMP,
    failed_login_count INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    password_changed_at TIMESTAMP,
    notification_prefs JSONB DEFAULT '{"sms": true, "email": true, "push": true, "quiet_hours": {"start": "22:00", "end": "08:00"}}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_role_gallery_relation CHECK (
        (gallery_id IS NULL AND role IN ('superadmin', 'compliance_officer', 'support_agent', 'integration_manager', 'finance_reporter'))
        OR
        (gallery_id IS NOT NULL AND role IN ('gallery_owner', 'gallery_manager', 'sales_rep', 'inventory_manager', 'viewer'))
    )
);

-- Create indexes
CREATE INDEX idx_users_gallery ON users(gallery_id);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);


















-- ========== 003_create_vehicles.sql ==========
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


















-- ========== 004_create_vehicle_media.sql ==========
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


















-- ========== 005_create_channels.sql ==========
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


















-- ========== 006_create_channel_listings.sql ==========
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


















-- ========== 007_create_offers.sql ==========
-- Create offers table
CREATE TABLE IF NOT EXISTS offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    seller_gallery_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    buyer_gallery_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TRY',
    note TEXT,
    valid_until TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN (
        'draft', 'sent', 'viewed', 'counter_offer', 'accepted', 'rejected', 'cancelled', 'expired', 'converted'
    )),
    parent_offer_id UUID REFERENCES offers(id),
    version INTEGER DEFAULT 1,
    reserved_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    accepted_by UUID REFERENCES users(id),
    accepted_at TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_offers_seller ON offers(seller_gallery_id);
CREATE INDEX idx_offers_buyer ON offers(buyer_gallery_id);
CREATE INDEX idx_offers_vehicle ON offers(vehicle_id);
CREATE INDEX idx_offers_status ON offers(status);
CREATE INDEX idx_offers_valid ON offers(valid_until) WHERE status IN ('sent', 'viewed');
-- Partial unique index for active offers
CREATE UNIQUE INDEX idx_offers_unique_active ON offers(vehicle_id, buyer_gallery_id) 
    WHERE status IN ('sent', 'viewed', 'counter_offer');






-- ========== 008_create_offer_history.sql ==========
-- Create offer_history table
CREATE TABLE IF NOT EXISTS offer_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    old_amount DECIMAL(15,2),
    new_amount DECIMAL(15,2),
    change_reason TEXT,
    changed_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_offer_history_offer ON offer_history(offer_id);


















-- ========== 009_create_chat_rooms.sql ==========
-- Create chat_rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_type VARCHAR(20) NOT NULL CHECK (room_type IN ('offer', 'vehicle', 'support')),
    offer_id UUID REFERENCES offers(id) ON DELETE CASCADE,
    vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
    gallery_a_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    gallery_b_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    closed_at TIMESTAMP,
    last_message_at TIMESTAMP,
    last_message_preview VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_room_type_relation CHECK (
        (room_type = 'offer' AND offer_id IS NOT NULL) OR
        (room_type = 'vehicle' AND vehicle_id IS NOT NULL) OR
        (room_type = 'support')
    )
);

-- Create indexes
CREATE INDEX idx_chat_rooms_offer ON chat_rooms(offer_id);
CREATE INDEX idx_chat_rooms_vehicle ON chat_rooms(vehicle_id);
CREATE INDEX idx_chat_rooms_gallery_a ON chat_rooms(gallery_a_id);
CREATE INDEX idx_chat_rooms_gallery_b ON chat_rooms(gallery_b_id);
CREATE INDEX idx_chat_rooms_active ON chat_rooms(is_active, last_message_at DESC);


















-- ========== 010_create_chat_messages.sql ==========
-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('text', 'file', 'system', 'offer_update')),
    content TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size INTEGER,
    file_type VARCHAR(100),
    read_at TIMESTAMP,
    read_by UUID REFERENCES users(id),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_chat_messages_room ON chat_messages(room_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);
CREATE INDEX idx_chat_messages_unread ON chat_messages(room_id, read_at) WHERE read_at IS NULL;


















-- ========== 011_create_subscriptions.sql ==========
-- Create subscription_plans table
CREATE TABLE IF NOT EXISTS subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    monthly_price DECIMAL(10,2),
    yearly_price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'TRY',
    max_vehicles INTEGER DEFAULT -1,
    max_users INTEGER DEFAULT 5,
    max_channels INTEGER DEFAULT 2,
    features JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create subscription_orders table
CREATE TABLE IF NOT EXISTS subscription_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gallery_id UUID NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    billing_period VARCHAR(20) NOT NULL CHECK (billing_period IN ('monthly', 'yearly')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TRY',
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    paid_at TIMESTAMP,
    invoice_no VARCHAR(50),
    invoice_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_sub_orders_gallery ON subscription_orders(gallery_id);
CREATE INDEX idx_sub_orders_period ON subscription_orders(period_start, period_end);
CREATE INDEX idx_sub_orders_payment ON subscription_orders(payment_status);


















-- ========== 012_create_notifications.sql ==========
-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gallery_id UUID REFERENCES galleries(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    channels VARCHAR(50)[] DEFAULT ARRAY['push']::VARCHAR(50)[],
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notification_templates table
CREATE TABLE IF NOT EXISTS notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    sms_template TEXT,
    email_subject VARCHAR(255),
    email_body_html TEXT,
    email_body_text TEXT,
    push_template TEXT,
    variables JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notification_logs table
CREATE TABLE IF NOT EXISTS notification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('sms', 'email', 'push')),
    provider VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'bounced')),
    error_message TEXT,
    provider_response JSONB,
    retry_count INTEGER DEFAULT 0,
    next_retry_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_gallery ON notifications(gallery_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id) WHERE read_at IS NULL;
CREATE INDEX idx_notif_logs_notification ON notification_logs(notification_id);
CREATE INDEX idx_notif_logs_status ON notification_logs(status);
CREATE INDEX idx_notif_logs_retry ON notification_logs(next_retry_at) WHERE status = 'pending';


















-- ========== 013_create_audit_logs.sql ==========
-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    gallery_id UUID REFERENCES galleries(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    request_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_gallery ON audit_logs(gallery_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- Partition by month for better performance (optional, can be added later)
-- CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');


















-- ========== 014_create_system_settings.sql ==========
-- Create system_settings table
CREATE TABLE IF NOT EXISTS system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);

-- Create rejection_templates table
CREATE TABLE IF NOT EXISTS rejection_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0
);

-- Insert default rejection templates
INSERT INTO rejection_templates (code, title, description, sort_order) VALUES
    ('INVALID_AUTHORITY_DOC', 'Yetki Belgesi Geçersiz', 'Yetki belgesi geçersiz veya süresi dolmuş', 1),
    ('IDENTITY_VERIFICATION', 'Kimlik Doğrulama Hatası', 'Kimlik bilgileri doğrulanamadı', 2),
    ('EIDS_FAILED', 'EİDS Doğrulaması Başarısız', 'EİDS doğrulaması başarısız', 3),
    ('INCOMPLETE_ADDRESS', 'Adres Bilgileri Eksik', 'Adres bilgileri eksik veya hatalı', 4),
    ('DUPLICATE_GALLERY', 'Tekrar Eden Galeri', 'Aynı vergi numarasıyla kayıtlı galeri mevcut', 5),
    ('OTHER', 'Diğer', 'Diğer nedenler', 6)
ON CONFLICT (code) DO NOTHING;

-- Insert default system settings
INSERT INTO system_settings (key, value, description) VALUES
    ('cdn_settings', '{"enabled": false, "provider": "cloudflare", "account_id": "", "api_token": ""}'::jsonb, 'CDN configuration'),
    ('sms_settings', '{"primary_provider": "netgsm", "backup_provider": "ileti_merkezi", "daily_limit": 1000}'::jsonb, 'SMS provider settings'),
    ('watermark_settings', '{"enabled": true, "position": "bottom-right", "opacity": 0.7}'::jsonb, 'Watermark settings'),
    ('maintenance_mode', '{"enabled": false, "message": "Bakım çalışması devam ediyor"}'::jsonb, 'Maintenance mode settings')
ON CONFLICT (key) DO NOTHING;


















-- ========== 015_create_indexes.sql ==========
-- Additional indexes for performance optimization

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_vehicles_gallery_status ON vehicles(gallery_id, status);
CREATE INDEX IF NOT EXISTS idx_vehicles_status_published ON vehicles(status, published_at DESC) WHERE status = 'published';
CREATE INDEX IF NOT EXISTS idx_offers_buyer_status ON offers(buyer_gallery_id, status);
CREATE INDEX IF NOT EXISTS idx_offers_seller_status ON offers(seller_gallery_id, status);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_created ON chat_messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_gallery_created ON audit_logs(gallery_id, created_at DESC);

-- Partial indexes for active records
CREATE INDEX IF NOT EXISTS idx_galleries_active ON galleries(id) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_users_active ON users(id) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_vehicles_published ON vehicles(id) WHERE status = 'published';
CREATE INDEX IF NOT EXISTS idx_channel_listings_active ON channel_listings(id) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_offers_active ON offers(id) WHERE status IN ('sent', 'viewed', 'counter_offer');

-- Full-text search indexes (already created in vehicles table, but adding here for reference)
-- The search_vector index is already created in 003_create_vehicles.sql

-- Indexes for foreign keys (most are already created, but ensuring all are present)
CREATE INDEX IF NOT EXISTS idx_galleries_subscription_plan ON galleries(subscription_plan_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_created_by ON vehicles(created_by);
CREATE INDEX IF NOT EXISTS idx_vehicles_updated_by ON vehicles(updated_by);
CREATE INDEX IF NOT EXISTS idx_vehicle_media_uploaded_by ON vehicle_media(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_offers_created_by ON offers(created_by);
CREATE INDEX IF NOT EXISTS idx_offers_accepted_by ON offers(accepted_by);
CREATE INDEX IF NOT EXISTS idx_offer_history_changed_by ON offer_history(changed_by);
CREATE INDEX IF NOT EXISTS idx_chat_messages_read_by ON chat_messages(read_by);
CREATE INDEX IF NOT EXISTS idx_subscription_orders_plan ON subscription_orders(plan_id);
CREATE INDEX IF NOT EXISTS idx_notifications_gallery ON notifications(gallery_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);


















-- ========== 016_add_vehicle_video_shorts.sql ==========
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


-- ========== TEST USERS ==========
-- Test Kullanıcıları ve Chat Room Oluşturma SQL Scripti
-- Bu script iki test galerisi ve kullanıcısı oluşturur, aralarında bir chat room açar

BEGIN;

-- 1. İlk Test Galerisi
DO $$
DECLARE
    gallery1_id UUID := gen_random_uuid();
    user1_id UUID := gen_random_uuid();
    password_hash1 TEXT := '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJZ5Q5K5u'; -- Test123!@#
BEGIN
    -- Galeri 1 oluştur
    INSERT INTO galleries (
        id, name, slug, tax_type, tax_number, authority_document_no,
        phone, email, city, district, neighborhood, address, status
    ) VALUES (
        gallery1_id,
        'Test Galeri 1',
        'test-galeri-1',
        'VKN',
        '1234567890',
        'TEST001',
        '+905551234567',
        'test1@galeri.com',
        'İstanbul',
        'Kadıköy',
        'Moda',
        'Test Adres 1',
        'active'
    );

    -- Kullanıcı 1 oluştur
    INSERT INTO users (
        id, gallery_id, phone, phone_verified, phone_verified_at,
        email, email_verified, password_hash,
        first_name, last_name, role, status
    ) VALUES (
        user1_id,
        gallery1_id,
        '+905551234567',
        true,
        NOW(),
        'test1@galeri.com',
        true,
        password_hash1,
        'Test',
        'Kullanıcı 1',
        'gallery_owner',
        'active'
    );

    RAISE NOTICE 'Test Galeri 1 ve Kullanıcı 1 oluşturuldu. Galeri ID: %, Kullanıcı ID: %', gallery1_id, user1_id;
END $$;

-- 2. İkinci Test Galerisi
DO $$
DECLARE
    gallery2_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    password_hash2 TEXT := '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJZ5Q5K5u'; -- Test123!@#
BEGIN
    -- Galeri 2 oluştur
    INSERT INTO galleries (
        id, name, slug, tax_type, tax_number, authority_document_no,
        phone, email, city, district, neighborhood, address, status
    ) VALUES (
        gallery2_id,
        'Test Galeri 2',
        'test-galeri-2',
        'VKN',
        '0987654321',
        'TEST002',
        '+905559876543',
        'test2@galeri.com',
        'Ankara',
        'Çankaya',
        'Kızılay',
        'Test Adres 2',
        'active'
    );

    -- Kullanıcı 2 oluştur
    INSERT INTO users (
        id, gallery_id, phone, phone_verified, phone_verified_at,
        email, email_verified, password_hash,
        first_name, last_name, role, status
    ) VALUES (
        user2_id,
        gallery2_id,
        '+905559876543',
        true,
        NOW(),
        'test2@galeri.com',
        true,
        password_hash2,
        'Test',
        'Kullanıcı 2',
        'gallery_owner',
        'active'
    );

    RAISE NOTICE 'Test Galeri 2 ve Kullanıcı 2 oluşturuldu. Galeri ID: %, Kullanıcı ID: %', gallery2_id, user2_id;
END $$;

-- 3. Chat Room oluştur (gallery_a_id ve gallery_b_id'yi dinamik olarak al)
DO $$
DECLARE
    gallery1_id UUID;
    gallery2_id UUID;
    user1_id UUID;
    user2_id UUID;
    room_id UUID := gen_random_uuid();
    message1_id UUID := gen_random_uuid();
    message2_id UUID := gen_random_uuid();
    message3_id UUID := gen_random_uuid();
BEGIN
    -- Gallery ID'leri al
    SELECT id INTO gallery1_id FROM galleries WHERE slug = 'test-galeri-1';
    SELECT id INTO gallery2_id FROM galleries WHERE slug = 'test-galeri-2';
    SELECT id INTO user1_id FROM users WHERE email = 'test1@galeri.com';
    SELECT id INTO user2_id FROM users WHERE email = 'test2@galeri.com';

    -- Chat Room oluştur
    INSERT INTO chat_rooms (
        id, gallery_a_id, gallery_b_id, room_type, is_active, created_at, updated_at
    ) VALUES (
        room_id,
        gallery1_id,
        gallery2_id,
        'support',
        true,
        NOW(),
        NOW()
    );

    -- Test mesajları ekle
    INSERT INTO chat_messages (
        id, room_id, sender_id, message_type, content, created_at
    ) VALUES 
        (message1_id, room_id, user1_id, 'text', 'Merhaba! Test mesajı 1', NOW() - INTERVAL '5 minutes'),
        (message2_id, room_id, user2_id, 'text', 'Merhaba! Test mesajı 2', NOW() - INTERVAL '3 minutes'),
        (message3_id, room_id, user1_id, 'text', 'Bu bir test mesajıdır', NOW() - INTERVAL '1 minute');

    -- Chat room'u güncelle
    UPDATE chat_rooms 
    SET last_message_at = NOW(), 
        last_message_preview = 'Bu bir test mesajıdır',
        updated_at = NOW()
    WHERE id = room_id;

    RAISE NOTICE 'Chat Room oluşturuldu. Room ID: %', room_id;
END $$;

COMMIT;

-- Bilgileri göster
SELECT 
    'TEST KULLANICI 1' as bilgi,
    u.email,
    u.phone,
    g.name as galeri,
    'Test123!@#' as sifre
FROM users u
JOIN galleries g ON u.gallery_id = g.id
WHERE u.email = 'test1@galeri.com'

UNION ALL

SELECT 
    'TEST KULLANICI 2' as bilgi,
    u.email,
    u.phone,
    g.name as galeri,
    'Test123!@#' as sifre
FROM users u
JOIN galleries g ON u.gallery_id = g.id
WHERE u.email = 'test2@galeri.com';














