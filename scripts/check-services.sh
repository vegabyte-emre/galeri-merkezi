#!/bin/bash

# Service Health Check Script
# Tüm servislerin durumunu kontrol eder

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Servis Durumu Kontrol Ediliyor..."
echo ""

# Docker Compose servisleri
echo "📦 Docker Servisleri:"
docker-compose -f docker/docker-compose.yml ps
echo ""

# API Gateway
echo "🌐 API Gateway:"
if curl -s -f http://localhost:3000/health > /dev/null; then
    echo -e "${GREEN}✓ API Gateway çalışıyor${NC}"
else
    echo -e "${RED}✗ API Gateway çalışmıyor${NC}"
fi

# PostgreSQL
echo "🗄️  PostgreSQL:"
if docker exec galeri-merkezi-postgres-1 pg_isready -U galeri_user > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL çalışıyor${NC}"
else
    echo -e "${RED}✗ PostgreSQL çalışmıyor${NC}"
fi

# Redis
echo "💾 Redis:"
if docker exec galeri-merkezi-redis-1 redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Redis çalışıyor${NC}"
else
    echo -e "${RED}✗ Redis çalışmıyor${NC}"
fi

# RabbitMQ
echo "🐰 RabbitMQ:"
if curl -s -f -u guest:guest http://localhost:15672/api/overview > /dev/null; then
    echo -e "${GREEN}✓ RabbitMQ çalışıyor${NC}"
else
    echo -e "${RED}✗ RabbitMQ çalışmıyor${NC}"
fi

# Meilisearch
echo "🔍 Meilisearch:"
if curl -s -f http://localhost:7700/health > /dev/null; then
    echo -e "${GREEN}✓ Meilisearch çalışıyor${NC}"
else
    echo -e "${RED}✗ Meilisearch çalışmıyor${NC}"
fi

# MinIO
echo "📦 MinIO:"
if curl -s -f http://localhost:9000/minio/health/live > /dev/null; then
    echo -e "${GREEN}✓ MinIO çalışıyor${NC}"
else
    echo -e "${RED}✗ MinIO çalışmıyor${NC}"
fi

echo ""
echo "✅ Kontrol tamamlandı!"
















