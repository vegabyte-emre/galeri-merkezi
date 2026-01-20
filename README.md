# Otobia - Oto Galeri B2B Platform

Çok kiracılı (multi-tenant) B2B oto galeri platformu. Galeriler arası stok yönetimi, teklif/pazarlık, mesajlaşma ve pazar yerlerine ilan aktarımı yapabilen kapsamlı bir sistem.

## 🌐 Domain

- **Production**: https://otobia.com
- **API**: https://api.otobia.com

## 🏗️ Mimari

- **Backend**: Node.js + TypeScript (Microservices)
- **Frontend**: Nuxt.js 3 + Tailwind CSS
- **Database**: PostgreSQL (Primary + Replica)
- **Cache**: Redis
- **Queue**: RabbitMQ
- **Search**: Meilisearch
- **Storage**: MinIO (S3-compatible)
- **Reverse Proxy**: Traefik
- **Container Management**: Portainer

## 📁 Proje Yapısı

```
otobia/
├── backend/
│   ├── services/          # API servisleri
│   ├── workers/           # Arka plan işlemleri
│   └── shared/            # Ortak kütüphaneler
├── frontend/
│   ├── landing/           # Landing sayfası (otobia.com)
│   ├── admin/             # Süperadmin paneli (admin.otobia.com)
│   └── panel/             # Galeri paneli (panel.otobia.com)
├── database/
│   └── migrations/        # DB migration dosyaları
└── docker/
    └── portainer-stacks/  # Portainer stack tanımları
```

## 🚀 Hızlı Başlangıç

### Gereksinimler

- Node.js >= 18.0.0
- Docker & Docker Compose
- Portainer (opsiyonel, yönetim için)

### Kurulum

#### Windows (Önerilen - Tek Tıkla Kurulum)
```batch
setup.bat
```

Bu script otomatik olarak:
- ✅ .env dosyasını oluşturur
- ✅ Docker servislerini başlatır
- ✅ Migration'ları çalıştırır
- ✅ Test verilerini yükler (opsiyonel)

#### Manuel Kurulum

1. **Ortam değişkenlerini ayarlayın:**
   ```bash
   cp .env.example .env
   # .env dosyasını düzenleyin (gerekirse)
   ```

2. **Docker servislerini başlatın:**
   ```bash
   npm run dev
   # veya
   docker-compose -f docker/docker-compose.yml up -d
   ```

3. **Servis durumunu kontrol edin:**
   ```bash
   # Windows
   check-services.bat
   # veya
   powershell -ExecutionPolicy Bypass -File scripts/check-services.ps1
   
   # Linux/Mac
   bash scripts/check-services.sh
   ```

4. **Veritabanı migration'larını çalıştırın:**
   ```bash
   npm run migrate
   ```

5. **Test verilerini yükleyin (opsiyonel):**
   ```bash
   npm run seed
   ```

### Test ve Önizleme

Detaylı test ve önizleme rehberi için: [GETTING_STARTED.md](docs/GETTING_STARTED.md)

**Hızlı Test:**
```batch
# Windows
test-api.bat
check-services.bat

# Linux/Mac
bash scripts/test-api.sh
bash scripts/check-services.sh
```

**Yardımcı Batch Dosyaları (Windows):**
- `setup.bat` - Otomatik kurulum
- `start-services.bat` - Servisleri başlat
- `stop-services.bat` - Servisleri durdur
- `view-logs.bat` - Logları görüntüle
- `test-api.bat` - API testleri
- `check-services.bat` - Servis durumu
- `reset.bat` - Projeyi sıfırla (dikkatli kullanın!)

**Local Development URL'leri:**
- Landing: http://localhost:3000
- Süperadmin Panel: http://localhost:3001
- Galeri Panel: http://localhost:3002

**Production URL'leri:**
- Landing: https://otobia.com
- Süperadmin Panel: https://admin.otobia.com
- Galeri Panel: https://panel.otobia.com
- API: https://api.otobia.com

## 📚 Servisler

### Backend Servisleri

- **API Gateway** (Port: 8000) - Routing, authentication, rate limiting
- **Auth Service** (Port: 3007) - Kullanıcı kayıt, giriş, JWT
- **Gallery Service** (Port: 3006) - Galeri yönetimi
- **Inventory Service** (Port: 3003) - Araç envanteri
- **Offer Service** (Port: 3004) - Teklif yönetimi
- **Chat Service** (Port: 3005) - Mesajlaşma (WebSocket)

### Worker Servisleri

- **Notification Worker** - SMS, e-posta, push bildirimleri
- **Media Worker** - Görsel/video işleme
- **Search Indexer** - Arama index güncelleme

## 🔧 Portainer Yönetimi

Tüm servisler Portainer üzerinden yönetilebilir. Stack dosyaları `docker/portainer-stacks/` klasöründe bulunur:

- `otobia-infrastructure.yml` - Altyapı servisleri
- `otobia-services.yml` - Backend API servisleri
- `otobia-workers.yml` - Worker servisleri
- `otobia-frontend.yml` - Frontend uygulamaları
- `otobia-monitoring.yml` - İzleme ve loglama

## 📖 Dokümantasyon

Detaylı teknik dokümantasyon için `docs/` klasörüne bakın.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje özel bir projedir. © 2026 Otobia. Tüm hakları saklıdır.
