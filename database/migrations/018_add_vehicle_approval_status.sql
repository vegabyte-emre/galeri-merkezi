-- Migration: Add vehicle approval workflow support
-- This migration adds the pending_approval and rejected statuses to vehicles
-- and adds columns for tracking approval submissions

-- Step 1: Drop the existing constraint and add a new one with more statuses
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS vehicles_status_check;
ALTER TABLE vehicles ADD CONSTRAINT vehicles_status_check 
    CHECK (status IN ('draft', 'pending_approval', 'published', 'paused', 'archived', 'sold', 'rejected'));

-- Step 2: Add columns for tracking approval submissions
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMP;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS submitted_by UUID REFERENCES users(id);
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES users(id);
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMP;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS rejected_by UUID REFERENCES users(id);
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Step 3: Create index for pending approval queries
CREATE INDEX IF NOT EXISTS idx_vehicles_pending_approval ON vehicles(status) WHERE status = 'pending_approval';
CREATE INDEX IF NOT EXISTS idx_vehicles_submitted_at ON vehicles(submitted_at) WHERE submitted_at IS NOT NULL;

-- Step 4: Ensure integrations table exists and has NetGSM
CREATE TABLE IF NOT EXISTS integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'inactive',
    config JSONB DEFAULT '{}',
    last_sync TIMESTAMP,
    last_error TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert NetGSM if not exists
INSERT INTO integrations (name, type, status, config) 
VALUES (
    'NetGSM', 
    'sms', 
    'active', 
    '{"enabled": true, "username": "", "password": "", "msgHeader": "GALERIPLATFORM"}'::jsonb
) ON CONFLICT (name) DO NOTHING;

-- Also ensure other common integrations exist
INSERT INTO integrations (name, type, status, config) 
VALUES (
    'Firebase', 
    'push', 
    'inactive', 
    '{"enabled": false}'::jsonb
) ON CONFLICT (name) DO NOTHING;

INSERT INTO integrations (name, type, status, config) 
VALUES (
    'SendGrid', 
    'email', 
    'inactive', 
    '{"enabled": false}'::jsonb
) ON CONFLICT (name) DO NOTHING;
