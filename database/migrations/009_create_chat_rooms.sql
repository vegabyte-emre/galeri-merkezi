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
















