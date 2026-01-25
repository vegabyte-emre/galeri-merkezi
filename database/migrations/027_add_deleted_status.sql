-- Add 'deleted' status to galleries, users, and vehicles tables
-- This is required for soft delete functionality

-- Remove the old check constraint and add new one with 'deleted' status for galleries
ALTER TABLE galleries DROP CONSTRAINT IF EXISTS galleries_status_check;
ALTER TABLE galleries ADD CONSTRAINT galleries_status_check 
    CHECK (status IN ('pending', 'active', 'suspended', 'rejected', 'deleted'));

-- Remove the old check constraint and add new one with 'deleted' status for users
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_status_check;
ALTER TABLE users ADD CONSTRAINT users_status_check 
    CHECK (status IN ('pending', 'active', 'suspended', 'deleted'));

-- Remove the old check constraint and add new one with 'deleted' status for vehicles
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS vehicles_status_check;
ALTER TABLE vehicles ADD CONSTRAINT vehicles_status_check 
    CHECK (status IN ('draft', 'published', 'paused', 'archived', 'sold', 'deleted', 'pending_approval', 'rejected'));
