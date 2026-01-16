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
















