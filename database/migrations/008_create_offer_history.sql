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
















