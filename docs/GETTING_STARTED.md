# Başlangıç Rehberi

Bu rehber, Galeri Merkezi B2B platformunu yerel ortamda çalıştırmanız için gerekli adımları içerir.

## 📋 Gereksinimler

- **Node.js** >= 18.0.0
- **Docker** >= 20.10.0
- **Docker Compose** >= 2.0.0
- **npm** >= 9.0.0
- **Portainer** (opsiyonel, yönetim için)

## 🚀 Hızlı Başlangıç

### 1. Ortam Değişkenlerini Ayarlayın

```bash
# .env dosyasını oluşturun
cp .env.example .env

# .env dosyasını düzenleyin (gerekirse)
# Varsayılan değerler Docker Compose ile çalışır
```

### 2. Docker Servislerini Başlatın

```bash
# Tüm servisleri başlat (infrastructure + services + workers + frontend)
docker-compose -f docker/docker-compose.yml up -d

# Veya npm script kullanarak
npm run dev
```

### 3. Servis Durumunu Kontrol Edin

```bash
# Tüm servislerin durumunu kontrol et
docker-compose -f docker/docker-compose.yml ps

# Logları görüntüle
docker-compose -f docker/docker-compose.yml logs -f

# Belirli bir servisin loglarını görüntüle
docker-compose -f docker/docker-compose.yml logs -f api-gateway
```

### 4. Veritabanı Migration'larını Çalıştırın

```bash
# Migration'ları çalıştır
npm run migrate

# Veya manuel olarak
node backend/shared/database/migrate.js
```

### 5. Test Verilerini Yükleyin (Opsiyonel)

```bash
# Seed script'i çalıştır
npm run seed
```

## 🌐 Servis URL'leri

Servisler başlatıldıktan sonra şu URL'lerden erişilebilir:

### Frontend Uygulamaları
- **Landing**: http://localhost:3000
- **Admin Panel**: http://localhost:3001
- **Galeri Panel**: http://localhost:3002

### Backend API
- **API Gateway**: http://localhost:3000/api
- **Auth Service**: http://localhost:3001 (internal)
- **Gallery Service**: http://localhost:3002 (internal)
- **Inventory Service**: http://localhost:3003 (internal)
- **Offer Service**: http://localhost:3004 (internal)
- **Chat Service**: http://localhost:3005 (internal)

### Infrastructure
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Meilisearch**: http://localhost:7700
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)
- **Traefik Dashboard**: http://localhost:8080

## 🧪 Test Etme

### 1. API Testleri

#### Health Check
```bash
# API Gateway health check
curl http://localhost:3000/health

# Servis health check'leri
curl http://localhost:3001/health
curl http://localhost:3002/health
```

#### Kullanıcı Kaydı
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+905551234567",
    "password": "Test123!",
    "name": "Test User",
    "email": "test@example.com"
  }'
```

#### Giriş Yapma
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+905551234567",
    "password": "Test123!"
  }'
```

### 2. Frontend Testleri

1. **Landing Sayfası**: http://localhost:3000
   - Ana sayfa görüntülenmeli
   - Kayıt/Giriş sayfalarına erişilebilmeli

2. **Admin Panel**: http://localhost:3001
   - Dashboard görüntülenmeli
   - Galeri yönetimi sayfalarına erişilebilmeli

3. **Galeri Panel**: http://localhost:3002
   - Dashboard görüntülenmeli
   - Araç yönetimi sayfalarına erişilebilmeli

### 3. Veritabanı Kontrolü

```bash
# PostgreSQL'e bağlan
docker exec -it galeri-merkezi-postgres-1 psql -U galeri_user -d galeri_db

# Tabloları listele
\dt

# Örnek sorgu
SELECT * FROM galleries LIMIT 5;
```

### 4. Redis Kontrolü

```bash
# Redis CLI'ye bağlan
docker exec -it galeri-merkezi-redis-1 redis-cli

# Key'leri listele
KEYS *

# Bir key'in değerini görüntüle
GET <key>
```

## 🔧 Geliştirme Modu

### Backend Servislerini Geliştirme Modunda Çalıştırma

```bash
# Her servis için ayrı terminal açın

# API Gateway
cd backend/services/api-gateway
npm install
npm run dev

# Auth Service
cd backend/services/auth-service
npm install
npm run dev

# Gallery Service
cd backend/services/gallery-service
npm install
npm run dev

# Inventory Service
cd backend/services/inventory-service
npm install
npm run dev

# Offer Service
cd backend/services/offer-service
npm install
npm run dev

# Chat Service
cd backend/services/chat-service
npm install
npm run dev
```

### Frontend Uygulamalarını Geliştirme Modunda Çalıştırma

```bash
# Her frontend için ayrı terminal açın

# Landing
cd frontend/landing
npm install
npm run dev

# Admin Panel
cd frontend/admin
npm install
npm run dev

# Galeri Panel
cd frontend/panel
npm install
npm run dev
```

## 🐳 Portainer ile Yönetim

### Portainer Kurulumu

```bash
# Portainer'ı başlat
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce
```

### Stack'leri Portainer'a Yükleme

1. Portainer'a giriş yapın: http://localhost:9000
2. **Stacks** > **Add stack** seçeneğine gidin
3. Her stack dosyasını sırayla yükleyin:
   - `docker/portainer-stacks/galeri-infrastructure.yml`
   - `docker/portainer-stacks/galeri-services.yml`
   - `docker/portainer-stacks/galeri-workers.yml`
   - `docker/portainer-stacks/galeri-frontend.yml`
   - `docker/portainer-stacks/galeri-monitoring.yml`

## 🐛 Sorun Giderme

### Servisler Başlamıyor

```bash
# Logları kontrol et
docker-compose -f docker/docker-compose.yml logs

# Servisleri yeniden başlat
docker-compose -f docker/docker-compose.yml restart

# Servisleri sıfırdan başlat
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml up -d
```

### Veritabanı Bağlantı Hatası

```bash
# PostgreSQL'in çalıştığını kontrol et
docker ps | grep postgres

# PostgreSQL loglarını kontrol et
docker logs galeri-merkezi-postgres-1

# Veritabanını yeniden oluştur
docker-compose -f docker/docker-compose.yml down -v
docker-compose -f docker/docker-compose.yml up -d postgres
```

### Port Çakışması

Eğer portlar kullanılıyorsa, `docker/docker-compose.yml` dosyasındaki port mapping'leri değiştirin:

```yaml
ports:
  - "3001:3000"  # Sol taraf host portu, sağ taraf container portu
```

### Frontend Build Hatası

```bash
# Node modules'ü temizle ve yeniden yükle
cd frontend/landing
rm -rf node_modules package-lock.json
npm install

# Build'i tekrar dene
npm run build
```

## 📊 Monitoring

### Prometheus

- URL: http://localhost:9090
- Metrics endpoint'leri otomatik olarak scrape edilir

### Grafana

- URL: http://localhost:3001 (port çakışması varsa değiştirin)
- Varsayılan kullanıcı: admin/admin
- Prometheus datasource'u otomatik olarak eklenir

### Loki Logs

- Loglar otomatik olarak toplanır
- Grafana'da Loki datasource'u ekleyerek logları görüntüleyebilirsiniz

## 🧹 Temizleme

```bash
# Tüm servisleri durdur ve kaldır
docker-compose -f docker/docker-compose.yml down

# Volume'ları da sil (veritabanı verileri silinir!)
docker-compose -f docker/docker-compose.yml down -v

# Image'ları da sil
docker-compose -f docker/docker-compose.yml down --rmi all
```

## 📝 Notlar

- İlk başlatmada servislerin tamamen hazır olması 1-2 dakika sürebilir
- Migration'lar otomatik çalışmaz, manuel olarak çalıştırmanız gerekir
- Production ortamında mutlaka `.env` dosyasındaki değerleri değiştirin
- JWT_SECRET ve diğer güvenlik değişkenlerini production'da mutlaka değiştirin
















