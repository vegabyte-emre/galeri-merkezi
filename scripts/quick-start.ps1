# PowerShell Quick Start Script
# Windows için otomatik kurulum ve başlatma

$ErrorActionPreference = "Stop"

Write-Host "🚀 Galeri Merkezi Quick Start" -ForegroundColor Cyan
Write-Host ""

# 1. .env dosyasını kontrol et
if (-not (Test-Path .env)) {
    Write-Host "📝 .env dosyası oluşturuluyor..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✓ .env dosyası oluşturuldu" -ForegroundColor Green
} else {
    Write-Host "✓ .env dosyası mevcut" -ForegroundColor Green
}
Write-Host ""

# 2. Docker servislerini başlat
Write-Host "🐳 Docker servisleri başlatılıyor..." -ForegroundColor Yellow
docker-compose -f docker/docker-compose.yml up -d
Write-Host "✓ Docker servisleri başlatıldı" -ForegroundColor Green
Write-Host ""

# 3. Servislerin hazır olmasını bekle
Write-Host "⏳ Servislerin hazır olması bekleniyor (30 saniye)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
Write-Host ""

# 4. Servis durumunu kontrol et
Write-Host "🔍 Servis durumu kontrol ediliyor..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File scripts/check-services.ps1
Write-Host ""

# 5. Migration'ları çalıştır
Write-Host "🗄️  Veritabanı migration'ları çalıştırılıyor..." -ForegroundColor Yellow
npm run migrate
Write-Host "✓ Migration'lar tamamlandı" -ForegroundColor Green
Write-Host ""

# 6. Seed (opsiyonel)
$seed = Read-Host "Test verilerini yüklemek ister misiniz? (y/n)"
if ($seed -eq "y" -or $seed -eq "Y") {
    Write-Host "🌱 Test verileri yükleniyor..." -ForegroundColor Yellow
    npm run seed
    Write-Host "✓ Test verileri yüklendi" -ForegroundColor Green
}
Write-Host ""

Write-Host "✅ Kurulum tamamlandı!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Frontend URL'leri:" -ForegroundColor Cyan
Write-Host "   - Landing: http://localhost:3000"
Write-Host "   - Admin Panel: http://localhost:3001"
Write-Host "   - Galeri Panel: http://localhost:3002"
Write-Host ""
Write-Host "📊 Infrastructure URL'leri:" -ForegroundColor Cyan
Write-Host "   - RabbitMQ: http://localhost:15672 (guest/guest)"
Write-Host "   - MinIO: http://localhost:9001 (minioadmin/minioadmin)"
Write-Host "   - Traefik: http://localhost:8080"
Write-Host ""
















