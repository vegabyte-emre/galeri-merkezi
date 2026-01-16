# Test Kullanıcıları Oluşturma

Bu script iki test galerisi ve kullanıcısı oluşturur, aralarında bir chat room açar.

## Kullanım

### Yöntem 1: Docker Container İçinde (Önerilen)

```bash
# Backend container'ını bulun
docker ps | grep backend

# Script'i container'a kopyalayın ve çalıştırın
docker cp scripts/create-test-users.ts <container-name>:/app/scripts/
docker exec -it <container-name> npx tsx /app/scripts/create-test-users.ts
```

### Yöntem 2: Doğrudan Node.js ile (Gerekli paketler yüklüyse)

```bash
# Gerekli paketleri yükleyin
npm install pg bcrypt uuid

# Script'i çalıştırın
node scripts/create-test-users.js
```

### Yöntem 3: SQL ile Manuel Oluşturma

Eğer script çalışmazsa, aşağıdaki SQL komutlarını doğrudan database'de çalıştırabilirsiniz:

```sql
-- Test Galeri 1 ve Kullanıcı 1
INSERT INTO galleries (id, name, slug, tax_type, tax_number, phone, email, city, district, status)
VALUES (gen_random_uuid(), 'Test Galeri 1', 'test-galeri-1', 'VKN', '1234567890', '+905551234567', 'test1@galeri.com', 'İstanbul', 'Kadıköy', 'active')
RETURNING id;

-- Yukarıdaki query'den dönen gallery_id'yi kullanarak:
INSERT INTO users (id, gallery_id, phone, phone_verified, phone_verified_at, email, email_verified, password_hash, first_name, last_name, role, status)
VALUES (gen_random_uuid(), '<gallery_id>', '+905551234567', true, NOW(), 'test1@galeri.com', true, '$2b$12$...', 'Test', 'Kullanıcı 1', 'gallery_owner', 'active');

-- Test Galeri 2 ve Kullanıcı 2 (aynı şekilde)
-- Chat Room oluşturma
-- Test mesajları ekleme
```

## Oluşturulan Test Kullanıcıları

### Kullanıcı 1
- **Email/Telefon**: `test1@galeri.com` veya `+905551234567`
- **Şifre**: `Test123!@#`
- **Galeri**: Test Galeri 1

### Kullanıcı 2
- **Email/Telefon**: `test2@galeri.com` veya `+905559876543`
- **Şifre**: `Test123!@#`
- **Galeri**: Test Galeri 2

## Mesajlaşma Testi

1. İki farklı tarayıcı/sekmede http://localhost:3002 adresine gidin
2. Bir sekmede Kullanıcı 1 ile, diğerinde Kullanıcı 2 ile giriş yapın
3. Her iki sekmede de `/chats` sayfasına gidin
4. Mesajlaşmayı test edin!

## Notlar

- Galeriler `active` status'ünde oluşturulur
- Kullanıcılar `gallery_owner` rolünde oluşturulur
- Chat room `support` tipinde oluşturulur
- 3 test mesajı otomatik olarak eklenir













