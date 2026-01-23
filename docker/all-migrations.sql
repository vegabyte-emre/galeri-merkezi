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


















-- ========== 012_create_vehicle_catalog.sql ==========
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

-- ========== 015_add_audit_logs_columns.sql ==========
-- Add missing columns to audit_logs
ALTER TABLE audit_logs 
ADD COLUMN IF NOT EXISTS level VARCHAR(20) DEFAULT 'info' CHECK (level IN ('info', 'success', 'warning', 'error')),
ADD COLUMN IF NOT EXISTS details TEXT,
ADD COLUMN IF NOT EXISTS service VARCHAR(50),
ADD COLUMN IF NOT EXISTS resolved BOOLEAN DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_audit_level ON audit_logs(level);
CREATE INDEX IF NOT EXISTS idx_audit_service ON audit_logs(service);

-- ========== 016_create_subscriptions.sql ==========
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gallery_id UUID REFERENCES galleries(id) ON DELETE CASCADE NOT NULL,
    plan VARCHAR(50) NOT NULL CHECK (plan IN ('basic', 'premium', 'enterprise', 'trial')),
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('monthly', 'yearly', 'lifetime')),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled', 'suspended')),
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'TRY',
    auto_renew BOOLEAN DEFAULT TRUE,
    trial_days INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_gallery ON subscriptions(gallery_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_end_date ON subscriptions(end_date);

-- ========== 017_create_email_templates.sql ==========
CREATE TABLE IF NOT EXISTS email_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL UNIQUE,
    body_html TEXT,
    body_text TEXT,
    variables JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default email templates
INSERT INTO email_templates (name, subject, type, body_html, body_text, variables) VALUES
    ('Hoş Geldiniz', 'Otobia''ya Hoş Geldiniz', 'welcome', '<p>Merhaba {{name}},</p><p>Otobia platformuna hoş geldiniz!</p>', 'Merhaba {{name}}, Otobia platformuna hoş geldiniz!', '["name", "email"]'::jsonb),
    ('Şifre Sıfırlama', 'Şifre Sıfırlama Talebi', 'password_reset', '<p>Şifre sıfırlama linkiniz: {{reset_link}}</p>', 'Şifre sıfırlama linkiniz: {{reset_link}}', '["reset_link", "expires_in"]'::jsonb),
    ('Galeri Onayı', 'Galeri Başvurunuz Onaylandı', 'gallery_approved', '<p>Galeri başvurunuz onaylandı!</p>', 'Galeri başvurunuz onaylandı!', '["gallery_name"]'::jsonb),
    ('Galeri Reddi', 'Galeri Başvurunuz Reddedildi', 'gallery_rejected', '<p>Galeri başvurunuz reddedildi. Sebep: {{reason}}</p>', 'Galeri başvurunuz reddedildi. Sebep: {{reason}}', '["gallery_name", "reason"]'::jsonb),
    ('Yeni Teklif', 'Aracınıza Yeni Teklif Geldi', 'new_offer', '<p>Aracınıza yeni bir teklif geldi: {{offer_amount}}</p>', 'Aracınıza yeni bir teklif geldi: {{offer_amount}}', '["vehicle_name", "offer_amount", "buyer_name"]'::jsonb)
ON CONFLICT (type) DO NOTHING;

-- ========== 018_create_roles_permissions.sql ==========
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- Insert default permissions
INSERT INTO permissions (id, name, description, category) VALUES
    (1, 'Galerileri Görüntüle', 'Galeri listesini görüntüleme izni', 'galleries'),
    (2, 'Galerileri Düzenle', 'Galeri bilgilerini düzenleme izni', 'galleries'),
    (3, 'Galerileri Sil', 'Galeri silme izni', 'galleries'),
    (4, 'Kullanıcıları Görüntüle', 'Kullanıcı listesini görüntüleme izni', 'users'),
    (5, 'Kullanıcıları Düzenle', 'Kullanıcı bilgilerini düzenleme izni', 'users'),
    (6, 'Kullanıcıları Sil', 'Kullanıcı silme izni', 'users'),
    (7, 'Raporları Görüntüle', 'Rapor görüntüleme izni', 'reports'),
    (8, 'Sistem Ayarları', 'Sistem ayarlarını düzenleme izni', 'system'),
    (9, 'Yedekleme Yönetimi', 'Yedekleme işlemleri izni', 'system'),
    (10, 'Entegrasyon Yönetimi', 'Entegrasyon yönetimi izni', 'system')
ON CONFLICT (id) DO NOTHING;

-- Insert default roles (matching existing system roles)
INSERT INTO roles (id, name, description, is_default, is_system) VALUES
    (1, 'Süper Admin', 'Tüm sistem erişimi', TRUE, TRUE),
    (2, 'Admin', 'Yönetim paneli erişimi', FALSE, TRUE),
    (3, 'Uyum Sorumlusu', 'Galeri onay işlemleri', FALSE, TRUE),
    (4, 'Destek Temsilcisi', 'Müşteri desteği', FALSE, TRUE),
    (5, 'Galeri Sahibi', 'Galeri yönetimi', FALSE, TRUE),
    (6, 'Galeri Yöneticisi', 'Galeri operasyonları', FALSE, TRUE)
ON CONFLICT (id) DO NOTHING;

-- Insert default role permissions
INSERT INTO role_permissions (role_id, permission_id) VALUES
    -- Süper Admin: All permissions
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10),
    -- Admin: Limited permissions
    (2, 1), (2, 2), (2, 4), (2, 5), (2, 7),
    -- Uyum Sorumlusu
    (3, 1), (3, 2), (3, 7),
    -- Destek Temsilcisi
    (4, 1), (4, 4), (4, 7),
    -- Galeri Sahibi
    (5, 1), (5, 4),
    -- Galeri Yöneticisi
    (6, 1)
ON CONFLICT DO NOTHING;

-- Set sequence for roles to start after 100 (for custom roles)
SELECT setval('roles_id_seq', 100, false);

-- ========== 023_create_fcm_tokens.sql ==========
CREATE TABLE IF NOT EXISTS fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type VARCHAR(20) CHECK (device_type IN ('ios', 'android', 'web')),
    device_id VARCHAR(255),
    app_version VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, token)
);

CREATE INDEX idx_fcm_tokens_user ON fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_active ON fcm_tokens(user_id, is_active) WHERE is_active = TRUE;

-- ========== 024_create_pricing_plans.sql ==========
CREATE TABLE IF NOT EXISTS pricing_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    price_custom BOOLEAN DEFAULT FALSE,
    price_display VARCHAR(50), -- For custom pricing like "Özel"
    billing_note VARCHAR(255),
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    features JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default pricing plans
INSERT INTO pricing_plans (name, slug, description, price_monthly, price_yearly, price_display, billing_note, is_featured, sort_order, features) VALUES
    ('Başlangıç', 'starter', 'Küçük galeriler için', 499.00, 4990.00, NULL, 'Aylık ödeme', FALSE, 1, '["50 araç yükleme", "Temel stok yönetimi", "E-posta desteği", "Temel raporlar", "1 kanal bağlantısı"]'::jsonb),
    ('Profesyonel', 'professional', 'Büyüyen galeriler için', 999.00, 9990.00, NULL, 'Aylık ödeme', TRUE, 2, '["Sınırsız araç yükleme", "Gelişmiş stok yönetimi", "Öncelikli destek", "Detaylı analitik", "Tüm kanal bağlantıları", "API erişimi", "Özel entegrasyonlar"]'::jsonb),
    ('Kurumsal', 'enterprise', 'Büyük galeriler için', NULL, NULL, 'Özel', 'Özel fiyatlandırma', FALSE, 3, '["Sınırsız araç yükleme", "Gelişmiş stok yönetimi", "7/24 öncelikli destek", "Özel analitik dashboard", "Tüm kanal bağlantıları", "API erişimi", "Özel entegrasyonlar", "Dedike hesap yöneticisi", "Özel eğitim ve danışmanlık"]'::jsonb)
ON CONFLICT (slug) DO NOTHING;

CREATE INDEX idx_pricing_plans_active ON pricing_plans(is_active, sort_order);

-- ========== 019_create_backups.sql ==========
CREATE TABLE IF NOT EXISTS backups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    backup_type VARCHAR(20) NOT NULL CHECK (backup_type IN ('manual', 'scheduled', 'automatic')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'expired')),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_backups_status ON backups(status);
CREATE INDEX idx_backups_created_at ON backups(created_at DESC);
CREATE INDEX idx_backups_type ON backups(backup_type);

-- ========== 020_create_integrations.sql ==========
CREATE TABLE IF NOT EXISTS integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'inactive' CHECK (status IN ('active', 'inactive', 'error')),
    config JSONB DEFAULT '{}'::jsonb,
    last_sync TIMESTAMP,
    last_error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default integrations
INSERT INTO integrations (name, type, status, config) VALUES
    ('Sahibinden.com', 'listing', 'inactive', '{"enabled": false}'::jsonb),
    ('Arabam.com', 'listing', 'inactive', '{"enabled": false}'::jsonb),
    ('Firebase', 'push_notification', 'active', '{"enabled": true}'::jsonb),
    ('NetGSM', 'sms', 'active', '{"enabled": true, "username": "", "password": "", "msgHeader": "GALERIPLATFORM"}'::jsonb),
    ('SendGrid', 'email', 'active', '{"enabled": true}'::jsonb)
ON CONFLICT (name) DO NOTHING;

-- ========== 021_create_oto_shorts.sql ==========
CREATE TABLE IF NOT EXISTS oto_shorts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gallery_id UUID REFERENCES galleries(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(255) NOT NULL,
    video_url TEXT NOT NULL,
    thumbnail_url TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    views INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_oto_shorts_gallery ON oto_shorts(gallery_id);
CREATE INDEX idx_oto_shorts_status ON oto_shorts(status);
CREATE INDEX idx_oto_shorts_created_at ON oto_shorts(created_at DESC);

-- ========== 022_create_reports.sql ==========
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    format VARCHAR(20) NOT NULL DEFAULT 'csv' CHECK (format IN ('csv', 'xlsx', 'pdf', 'json')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'generating', 'ready', 'failed', 'expired')),
    file_path TEXT,
    file_size BIGINT,
    parameters JSONB DEFAULT '{}'::jsonb,
    generated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    generated_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reports_type ON reports(type);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);














