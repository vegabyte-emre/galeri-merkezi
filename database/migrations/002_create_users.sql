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
















