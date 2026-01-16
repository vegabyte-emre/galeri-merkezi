# Test Kullanıcıları Oluşturma Rehberi

## Ön Gereksinimler

1. **Migration'ların çalıştırılmış olması gerekiyor**
   - Database'de `galleries`, `users`, `chat_rooms`, `chat_messages` tabloları olmalı
   - Eğer migration'lar çalışmamışsa önce migration'ları çalıştırın

## Test Kullanıcıları Oluşturma

### Yöntem 1: SQL Script ile (Önerilen)

```bash
# SQL script'i çalıştır
Get-Content scripts/create-test-users.sql | docker exec -i galeri-postgres psql -U galeri_user -d galeri_db
```

### Yöntem 2: Manuel SQL ile

PostgreSQL container'ına bağlanıp aşağıdaki SQL komutlarını çalıştırın:

```sql
-- Test Galeri 1 ve Kullanıcı 1
-- (scripts/create-test-users.sql dosyasındaki SQL komutlarını kullanın)
```

## Oluşturulan Test Kullanıcıları

### Kullanıcı 1
- **Email**: `test1@galeri.com`
- **Telefon**: `+905551234567`
- **Şifre**: `Test123!@#`
- **Galeri**: Test Galeri 1

### Kullanıcı 2
- **Email**: `test2@galeri.com`
- **Telefon**: `+905559876543`
- **Şifre**: `Test123!@#`
- **Galeri**: Test Galeri 2

## Mesajlaşma Testi Adımları

1. **İki farklı tarayıcı/sekmede** http://localhost:3002 adresine gidin
2. **Bir sekmede Kullanıcı 1 ile giriş yapın:**
   - Email: `test1@galeri.com`
   - Şifre: `Test123!@#`
3. **Diğer sekmede Kullanıcı 2 ile giriş yapın:**
   - Email: `test2@galeri.com`
   - Şifre: `Test123!@#`
4. **Her iki sekmede de `/chats` sayfasına gidin**
5. **Mesajlaşmayı test edin!**

## Notlar

- Galeriler `active` status'ünde oluşturulur
- Kullanıcılar `gallery_owner` rolünde oluşturulur
- Chat room `support` tipinde oluşturulur
- 3 test mesajı otomatik olarak eklenir
- Şifre hash'i: `$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJZ5Q5K5u` (Test123!@#)

## Sorun Giderme

### Migration'lar çalışmamışsa:

```bash
# Backend shared klasöründe build yapın
cd backend/shared
npm run build

# Sonra migration'ları çalıştırın
npm run migrate
```

### Database bağlantı sorunları:

```bash
# PostgreSQL container'ının çalıştığını kontrol edin
docker ps | grep postgres

# Database'e bağlanmayı test edin
docker exec galeri-postgres psql -U galeri_user -d galeri_db -c "SELECT 1;"
```













