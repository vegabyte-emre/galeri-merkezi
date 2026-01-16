/**
 * Test Kullanıcıları ve Chat Room Oluşturma Scripti
 * 
 * Bu script iki test galerisi ve kullanıcısı oluşturur,
 * aralarında bir chat room açar ve test mesajları ekler.
 * 
 * Kullanım: npx tsx scripts/create-test-users.ts
 * veya: docker exec -it galeri-api-gateway npx tsx /app/scripts/create-test-users.ts
 */

import { getClient } from '../backend/shared/database/connection';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

// Database connection
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  user: process.env.POSTGRES_USER || 'galeri_user',
  password: process.env.POSTGRES_PASSWORD || 'galeri_password',
  database: process.env.POSTGRES_DB || 'galeri_db',
});

async function createTestUsers() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    console.log('🚀 Test kullanıcıları oluşturuluyor...\n');

    // 1. İlk Test Galerisi ve Kullanıcısı
    const gallery1Id = uuidv4();
    const user1Id = uuidv4();
    const password1 = 'Test123!@#';
    const passwordHash1 = await bcrypt.hash(password1, 12);

    // Galeri 1 oluştur
    await client.query(`
      INSERT INTO galleries (
        id, name, slug, tax_type, tax_number, authority_document_no,
        phone, email, city, district, neighborhood, address, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `, [
      gallery1Id,
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
      'active' // Aktif olmalı ki mesaj gönderebilsin
    ]);

    // Kullanıcı 1 oluştur
    await client.query(`
      INSERT INTO users (
        id, gallery_id, phone, phone_verified, phone_verified_at,
        email, email_verified, password_hash,
        first_name, last_name, role, status
      ) VALUES ($1, $2, $3, $4, NOW(), $5, $6, $7, $8, $9, $10, $11)
    `, [
      user1Id,
      gallery1Id,
      '+905551234567',
      true,
      'test1@galeri.com',
      true,
      passwordHash1,
      'Test',
      'Kullanıcı 1',
      'gallery_owner',
      'active'
    ]);

    console.log('✅ Test Galeri 1 ve Kullanıcı 1 oluşturuldu:');
    console.log(`   Galeri ID: ${gallery1Id}`);
    console.log(`   Kullanıcı ID: ${user1Id}`);
    console.log(`   Email: test1@galeri.com`);
    console.log(`   Telefon: +905551234567`);
    console.log(`   Şifre: ${password1}\n`);

    // 2. İkinci Test Galerisi ve Kullanıcısı
    const gallery2Id = uuidv4();
    const user2Id = uuidv4();
    const password2 = 'Test123!@#';
    const passwordHash2 = await bcrypt.hash(password2, 12);

    // Galeri 2 oluştur
    await client.query(`
      INSERT INTO galleries (
        id, name, slug, tax_type, tax_number, authority_document_no,
        phone, email, city, district, neighborhood, address, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `, [
      gallery2Id,
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
    ]);

    // Kullanıcı 2 oluştur
    await client.query(`
      INSERT INTO users (
        id, gallery_id, phone, phone_verified, phone_verified_at,
        email, email_verified, password_hash,
        first_name, last_name, role, status
      ) VALUES ($1, $2, $3, $4, NOW(), $5, $6, $7, $8, $9, $10, $11)
    `, [
      user2Id,
      gallery2Id,
      '+905559876543',
      true,
      'test2@galeri.com',
      true,
      passwordHash2,
      'Test',
      'Kullanıcı 2',
      'gallery_owner',
      'active'
    ]);

    console.log('✅ Test Galeri 2 ve Kullanıcı 2 oluşturuldu:');
    console.log(`   Galeri ID: ${gallery2Id}`);
    console.log(`   Kullanıcı ID: ${user2Id}`);
    console.log(`   Email: test2@galeri.com`);
    console.log(`   Telefon: +905559876543`);
    console.log(`   Şifre: ${password2}\n`);

    // 3. Chat Room oluştur
    const roomId = uuidv4();
    await client.query(`
      INSERT INTO chat_rooms (
        id, gallery_a_id, gallery_b_id, room_type, is_active, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
    `, [
      roomId,
      gallery1Id,
      gallery2Id,
      'support', // Migration'da 'offer', 'vehicle', 'support' var
      true
    ]);

    console.log('✅ Chat Room oluşturuldu:');
    console.log(`   Room ID: ${roomId}`);
    console.log(`   Galeri 1 ↔ Galeri 2\n`);

    // 4. Test mesajları ekle
    const message1Id = uuidv4();
    const message2Id = uuidv4();
    const message3Id = uuidv4();

    await client.query(`
      INSERT INTO chat_messages (
        id, room_id, sender_id, message_type, content, created_at
      ) VALUES ($1, $2, $3, $4, $5, NOW() - INTERVAL '5 minutes')
    `, [message1Id, roomId, user1Id, 'text', 'Merhaba! Test mesajı 1']);

    await client.query(`
      INSERT INTO chat_messages (
        id, room_id, sender_id, message_type, content, created_at
      ) VALUES ($1, $2, $3, $4, $5, NOW() - INTERVAL '3 minutes')
    `, [message2Id, roomId, user2Id, 'text', 'Merhaba! Test mesajı 2']);

    await client.query(`
      INSERT INTO chat_messages (
        id, room_id, sender_id, message_type, content, created_at
      ) VALUES ($1, $2, $3, $4, $5, NOW() - INTERVAL '1 minute')
    `, [message3Id, roomId, user1Id, 'text', 'Bu bir test mesajıdır']);

    // Chat room'u güncelle
    await client.query(`
      UPDATE chat_rooms 
      SET last_message_at = NOW(), 
          last_message_preview = 'Bu bir test mesajıdır',
          updated_at = NOW()
      WHERE id = $1
    `, [roomId]);

    console.log('✅ Test mesajları eklendi (3 mesaj)\n');

    await client.query('COMMIT');

    console.log('📋 GİRİŞ BİLGİLERİ:\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('TEST KULLANICI 1:');
    console.log('  Email/Telefon: test1@galeri.com veya +905551234567');
    console.log('  Şifre: Test123!@#');
    console.log('  Galeri: Test Galeri 1');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('TEST KULLANICI 2:');
    console.log('  Email/Telefon: test2@galeri.com veya +905559876543');
    console.log('  Şifre: Test123!@#');
    console.log('  Galeri: Test Galeri 2');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log('💬 MESAJLAŞMA TESTİ:');
    console.log('  1. İki farklı tarayıcı/sekmede http://localhost:3002 adresine gidin');
    console.log('  2. Bir sekmede Kullanıcı 1 ile, diğerinde Kullanıcı 2 ile giriş yapın');
    console.log('  3. Her iki sekmede de /chats sayfasına gidin');
    console.log('  4. Mesajlaşmayı test edin!\n');

    return {
      user1: {
        id: user1Id,
        email: 'test1@galeri.com',
        phone: '+905551234567',
        password: password1,
        galleryId: gallery1Id
      },
      user2: {
        id: user2Id,
        email: 'test2@galeri.com',
        phone: '+905559876543',
        password: password2,
        galleryId: gallery2Id
      },
      roomId
    };

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Hata:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Script'i çalıştır
if (require.main === module) {
  createTestUsers()
    .then(() => {
      console.log('✅ Tüm test verileri başarıyla oluşturuldu!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Hata oluştu:', error);
      process.exit(1);
    });
}

export { createTestUsers };

