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
















