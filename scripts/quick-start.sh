#!/bin/bash

# Quick Start Script
# Tüm kurulum ve başlatma işlemlerini otomatik yapar

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Galeri Merkezi Quick Start${NC}"
echo ""

# 1. .env dosyasını kontrol et
if [ ! -f .env ]; then
    echo "📝 .env dosyası oluşturuluyor..."
    cp .env.example .env
    echo -e "${GREEN}✓ .env dosyası oluşturuldu${NC}"
else
    echo -e "${GREEN}✓ .env dosyası mevcut${NC}"
fi
echo ""

# 2. Docker servislerini başlat
echo "🐳 Docker servisleri başlatılıyor..."
docker-compose -f docker/docker-compose.yml up -d
echo -e "${GREEN}✓ Docker servisleri başlatıldı${NC}"
echo ""

# 3. Servislerin hazır olmasını bekle
echo "⏳ Servislerin hazır olması bekleniyor (30 saniye)..."
sleep 30
echo ""

# 4. Servis durumunu kontrol et
echo "🔍 Servis durumu kontrol ediliyor..."
bash scripts/check-services.sh
echo ""

# 5. Migration'ları çalıştır
echo "🗄️  Veritabanı migration'ları çalıştırılıyor..."
npm run migrate
echo -e "${GREEN}✓ Migration'lar tamamlandı${NC}"
echo ""

# 6. Seed (opsiyonel)
read -p "Test verilerini yüklemek ister misiniz? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌱 Test verileri yükleniyor..."
    npm run seed
    echo -e "${GREEN}✓ Test verileri yüklendi${NC}"
fi
echo ""

echo -e "${GREEN}✅ Kurulum tamamlandı!${NC}"
echo ""
echo "🌐 Frontend URL'leri:"
echo "   - Landing: http://localhost:3000"
echo "   - Admin Panel: http://localhost:3001"
echo "   - Galeri Panel: http://localhost:3002"
echo ""
echo "📊 Infrastructure URL'leri:"
echo "   - RabbitMQ: http://localhost:15672 (guest/guest)"
echo "   - MinIO: http://localhost:9001 (minioadmin/minioadmin)"
echo "   - Traefik: http://localhost:8080"
echo ""
















