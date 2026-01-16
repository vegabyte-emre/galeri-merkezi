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
















