# Sistem Mimarisi

## Genel Bakış

Oto Galeri B2B Platform, mikroservis mimarisi kullanılarak geliştirilmiştir. Tüm servisler Docker container'ları olarak çalışır ve Portainer üzerinden yönetilir.

## Mimari Katmanlar

### 1. Reverse Proxy (Traefik)
- Tüm HTTP/HTTPS trafiğini yönetir
- SSL sertifikalarını otomatik yönetir (Let's Encrypt)
- Service discovery ile otomatik routing
- Rate limiting ve güvenlik middleware'leri

### 2. API Gateway
- Tüm API isteklerinin giriş noktası
- JWT authentication
- Rate limiting (IP ve kullanıcı bazlı)
- Request routing ve load balancing

### 3. Backend Servisleri
- **Auth Service**: Kullanıcı kayıt, giriş, JWT yönetimi
- **Gallery Service**: Galeri profil yönetimi, EİDS entegrasyonu
- **Inventory Service**: Araç envanter yönetimi
- **Offer Service**: Teklif yönetimi ve pazarlık
- **Chat Service**: WebSocket tabanlı mesajlaşma
- **Channel Connector**: Pazar yeri entegrasyonları

### 4. Worker Servisleri
- **Notification Worker**: SMS, e-posta, push bildirimleri
- **Media Worker**: Görsel/video işleme, watermark
- **Search Indexer**: Meilisearch index güncelleme

### 5. Veri Katmanı
- **PostgreSQL**: Ana veritabanı (Primary + Replica)
- **Redis**: Cache ve session yönetimi
- **RabbitMQ**: Message queue
- **Meilisearch**: Arama motoru
- **MinIO**: Object storage (S3-compatible)

### 6. Frontend Uygulamaları
- **Landing**: Public-facing web sitesi (SSR)
- **Admin Panel**: Süperadmin yönetim paneli (SPA)
- **Gallery Panel**: Galeri yönetim paneli (SPA)

## Veri Akışı

### Kullanıcı Kayıt Akışı
1. Kullanıcı telefon numarası girer
2. Auth Service OTP gönderir (Notification Worker)
3. OTP doğrulandıktan sonra kullanıcı bilgileri alınır
4. Galeri ve kullanıcı kaydı oluşturulur
5. Süperadmin onayı beklenir

### Araç Yayınlama Akışı
1. Galeri araç bilgilerini girer (Inventory Service)
2. Medya yüklenir (MinIO)
3. Media Worker görselleri işler
4. Araç yayınlandığında:
   - Search Indexer Meilisearch'e ekler
   - Channel Connector pazar yerlerine aktarır (RabbitMQ)

### Teklif Akışı
1. Alıcı galeri teklif oluşturur (Offer Service)
2. Teklif gönderilir
3. Bildirim gönderilir (Notification Worker)
4. Satıcı teklifi görüntüler/kabul eder/reddeder
5. Karşı teklif yapılabilir
6. Kabul edilirse rezervasyon yapılır

## Güvenlik

- JWT tabanlı authentication
- Rate limiting (IP ve kullanıcı bazlı)
- Tenant isolation (gallery_id bazlı)
- Veri şifreleme (bcrypt, AES-256)
- Audit logging

## Ölçeklenebilirlik

- Horizontal scaling: Her servis bağımsız ölçeklenebilir
- Load balancing: Traefik ile otomatik
- Database replication: Read replica ile okuma yükü dağıtımı
- Caching: Redis ile performans optimizasyonu
- Queue-based processing: RabbitMQ ile asenkron işlemler
















