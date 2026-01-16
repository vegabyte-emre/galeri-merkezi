-- Test Kullanıcıları ve Chat Room Oluşturma SQL Scripti
-- Bu script iki test galerisi ve kullanıcısı oluşturur, aralarında bir chat room açar

BEGIN;

-- 1. İlk Test Galerisi
DO $$
DECLARE
    gallery1_id UUID := gen_random_uuid();
    user1_id UUID := gen_random_uuid();
    password_hash1 TEXT := '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJZ5Q5K5u'; -- Test123!@#
BEGIN
    -- Galeri 1 oluştur
    INSERT INTO galleries (
        id, name, slug, tax_type, tax_number, authority_document_no,
        phone, email, city, district, neighborhood, address, status
    ) VALUES (
        gallery1_id,
        'Test Galeri 1',
        'test-galeri-1',
        'VKN',
        '1234567890',
        'TEST001',
        '+905551234567',
        'test1@galeri.com',
        'İstanbul',
        'Kadıköy',
        'Moda',
        'Test Adres 1',
        'active'
    );

    -- Kullanıcı 1 oluştur
    INSERT INTO users (
        id, gallery_id, phone, phone_verified, phone_verified_at,
        email, email_verified, password_hash,
        first_name, last_name, role, status
    ) VALUES (
        user1_id,
        gallery1_id,
        '+905551234567',
        true,
        NOW(),
        'test1@galeri.com',
        true,
        password_hash1,
        'Test',
        'Kullanıcı 1',
        'gallery_owner',
        'active'
    );

    RAISE NOTICE 'Test Galeri 1 ve Kullanıcı 1 oluşturuldu. Galeri ID: %, Kullanıcı ID: %', gallery1_id, user1_id;
END $$;

-- 2. İkinci Test Galerisi
DO $$
DECLARE
    gallery2_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    password_hash2 TEXT := '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJZ5Q5K5u'; -- Test123!@#
BEGIN
    -- Galeri 2 oluştur
    INSERT INTO galleries (
        id, name, slug, tax_type, tax_number, authority_document_no,
        phone, email, city, district, neighborhood, address, status
    ) VALUES (
        gallery2_id,
        'Test Galeri 2',
        'test-galeri-2',
        'VKN',
        '0987654321',
        'TEST002',
        '+905559876543',
        'test2@galeri.com',
        'Ankara',
        'Çankaya',
        'Kızılay',
        'Test Adres 2',
        'active'
    );

    -- Kullanıcı 2 oluştur
    INSERT INTO users (
        id, gallery_id, phone, phone_verified, phone_verified_at,
        email, email_verified, password_hash,
        first_name, last_name, role, status
    ) VALUES (
        user2_id,
        gallery2_id,
        '+905559876543',
        true,
        NOW(),
        'test2@galeri.com',
        true,
        password_hash2,
        'Test',
        'Kullanıcı 2',
        'gallery_owner',
        'active'
    );

    RAISE NOTICE 'Test Galeri 2 ve Kullanıcı 2 oluşturuldu. Galeri ID: %, Kullanıcı ID: %', gallery2_id, user2_id;
END $$;

-- 3. Chat Room oluştur (gallery_a_id ve gallery_b_id'yi dinamik olarak al)
DO $$
DECLARE
    gallery1_id UUID;
    gallery2_id UUID;
    user1_id UUID;
    user2_id UUID;
    room_id UUID := gen_random_uuid();
    message1_id UUID := gen_random_uuid();
    message2_id UUID := gen_random_uuid();
    message3_id UUID := gen_random_uuid();
BEGIN
    -- Gallery ID'leri al
    SELECT id INTO gallery1_id FROM galleries WHERE slug = 'test-galeri-1';
    SELECT id INTO gallery2_id FROM galleries WHERE slug = 'test-galeri-2';
    SELECT id INTO user1_id FROM users WHERE email = 'test1@galeri.com';
    SELECT id INTO user2_id FROM users WHERE email = 'test2@galeri.com';

    -- Chat Room oluştur
    INSERT INTO chat_rooms (
        id, gallery_a_id, gallery_b_id, room_type, is_active, created_at, updated_at
    ) VALUES (
        room_id,
        gallery1_id,
        gallery2_id,
        'support',
        true,
        NOW(),
        NOW()
    );

    -- Test mesajları ekle
    INSERT INTO chat_messages (
        id, room_id, sender_id, message_type, content, created_at
    ) VALUES 
        (message1_id, room_id, user1_id, 'text', 'Merhaba! Test mesajı 1', NOW() - INTERVAL '5 minutes'),
        (message2_id, room_id, user2_id, 'text', 'Merhaba! Test mesajı 2', NOW() - INTERVAL '3 minutes'),
        (message3_id, room_id, user1_id, 'text', 'Bu bir test mesajıdır', NOW() - INTERVAL '1 minute');

    -- Chat room'u güncelle
    UPDATE chat_rooms 
    SET last_message_at = NOW(), 
        last_message_preview = 'Bu bir test mesajıdır',
        updated_at = NOW()
    WHERE id = room_id;

    RAISE NOTICE 'Chat Room oluşturuldu. Room ID: %', room_id;
END $$;

COMMIT;

-- Bilgileri göster
SELECT 
    'TEST KULLANICI 1' as bilgi,
    u.email,
    u.phone,
    g.name as galeri,
    'Test123!@#' as sifre
FROM users u
JOIN galleries g ON u.gallery_id = g.id
WHERE u.email = 'test1@galeri.com'

UNION ALL

SELECT 
    'TEST KULLANICI 2' as bilgi,
    u.email,
    u.phone,
    g.name as galeri,
    'Test123!@#' as sifre
FROM users u
JOIN galleries g ON u.gallery_id = g.id
WHERE u.email = 'test2@galeri.com';













