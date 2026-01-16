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




