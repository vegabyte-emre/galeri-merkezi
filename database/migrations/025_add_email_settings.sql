-- Add email_settings column to system_settings
-- This uses the row-based structure (id = 1) that the admin panel expects

-- First, ensure the system_settings table has the needed structure
DO $$
BEGIN
    -- Add id column if it doesn't exist (for row-based access)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'system_settings' AND column_name = 'id'
    ) THEN
        -- Create a new unified settings table
        CREATE TABLE IF NOT EXISTS system_settings_v2 (
            id INTEGER PRIMARY KEY DEFAULT 1,
            platform_name VARCHAR(255) DEFAULT 'Otobia',
            contact_email VARCHAR(255) DEFAULT 'info@otobia.com',
            contact_phone VARCHAR(50) DEFAULT '+90 212 555 0000',
            maintenance_mode BOOLEAN DEFAULT FALSE,
            min_password_length INTEGER DEFAULT 8,
            require_2fa BOOLEAN DEFAULT FALSE,
            session_timeout INTEGER DEFAULT 60,
            email_notifications BOOLEAN DEFAULT TRUE,
            sms_notifications BOOLEAN DEFAULT FALSE,
            push_notifications BOOLEAN DEFAULT TRUE,
            email_settings JSONB DEFAULT '{
                "provider": "smtp",
                "smtp": {
                    "host": "smtp.gmail.com",
                    "port": 587,
                    "secure": false,
                    "user": "",
                    "password": "",
                    "fromEmail": "",
                    "fromName": "Otobia"
                },
                "gmail": {
                    "clientId": "",
                    "clientSecret": "",
                    "refreshToken": "",
                    "accessToken": "",
                    "fromEmail": "",
                    "fromName": "Otobia"
                }
            }'::jsonb,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT single_row CHECK (id = 1)
        );

        -- Insert default row
        INSERT INTO system_settings_v2 (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

        -- Rename tables
        ALTER TABLE system_settings RENAME TO system_settings_legacy;
        ALTER TABLE system_settings_v2 RENAME TO system_settings;
    END IF;
END $$;

-- If id column exists but email_settings doesn't, add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'system_settings' AND column_name = 'email_settings'
    ) THEN
        ALTER TABLE system_settings ADD COLUMN email_settings JSONB DEFAULT '{
            "provider": "smtp",
            "smtp": {
                "host": "smtp.gmail.com",
                "port": 587,
                "secure": false,
                "user": "",
                "password": "",
                "fromEmail": "",
                "fromName": "Otobia"
            },
            "gmail": {
                "clientId": "",
                "clientSecret": "",
                "refreshToken": "",
                "accessToken": "",
                "fromEmail": "",
                "fromName": "Otobia"
            }
        }'::jsonb;
    END IF;
END $$;

-- Ensure default row exists
INSERT INTO system_settings (id) 
SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM system_settings WHERE id = 1)
ON CONFLICT DO NOTHING;
