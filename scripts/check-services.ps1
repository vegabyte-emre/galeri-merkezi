# PowerShell Service Health Check Script
# Windows için servis durumu kontrol scripti

Write-Host "🔍 Servis Durumu Kontrol Ediliyor..." -ForegroundColor Cyan
Write-Host ""

# Docker Compose servisleri
Write-Host "📦 Docker Servisleri:" -ForegroundColor Yellow
docker-compose -f docker/docker-compose.yml ps
Write-Host ""

# API Gateway
Write-Host "🌐 API Gateway:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method GET -UseBasicParsing -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ API Gateway çalışıyor" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ API Gateway çalışmıyor" -ForegroundColor Red
}

# PostgreSQL
Write-Host "🗄️  PostgreSQL:" -ForegroundColor Yellow
try {
    $result = docker exec galeri-merkezi-postgres-1 pg_isready -U galeri_user 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ PostgreSQL çalışıyor" -ForegroundColor Green
    } else {
        Write-Host "✗ PostgreSQL çalışmıyor" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ PostgreSQL çalışmıyor" -ForegroundColor Red
}

# Redis
Write-Host "💾 Redis:" -ForegroundColor Yellow
try {
    $result = docker exec galeri-merkezi-redis-1 redis-cli ping 2>&1
    if ($result -eq "PONG") {
        Write-Host "✓ Redis çalışıyor" -ForegroundColor Green
    } else {
        Write-Host "✗ Redis çalışmıyor" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Redis çalışmıyor" -ForegroundColor Red
}

# RabbitMQ
Write-Host "🐰 RabbitMQ:" -ForegroundColor Yellow
try {
    $cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("guest:guest"))
    $headers = @{ Authorization = "Basic $cred" }
    $response = Invoke-WebRequest -Uri "http://localhost:15672/api/overview" -Headers $headers -UseBasicParsing -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ RabbitMQ çalışıyor" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ RabbitMQ çalışmıyor" -ForegroundColor Red
}

# Meilisearch
Write-Host "🔍 Meilisearch:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:7700/health" -Method GET -UseBasicParsing -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Meilisearch çalışıyor" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Meilisearch çalışmıyor" -ForegroundColor Red
}

# MinIO
Write-Host "📦 MinIO:" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9000/minio/health/live" -Method GET -UseBasicParsing -TimeoutSec 2
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ MinIO çalışıyor" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ MinIO çalışmıyor" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Kontrol tamamlandı!" -ForegroundColor Green
















