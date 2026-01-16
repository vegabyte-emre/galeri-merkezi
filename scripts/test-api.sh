#!/bin/bash

# API Test Script
# Bu script temel API endpoint'lerini test eder

API_URL="http://localhost:3000/api"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🧪 API Test Script Başlatılıyor..."
echo ""

# Health Check
echo "1. Health Check Testi..."
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $API_URL/health)
if [ $HEALTH -eq 200 ]; then
    echo -e "${GREEN}✓ Health check başarılı${NC}"
else
    echo -e "${RED}✗ Health check başarısız (Status: $HEALTH)${NC}"
fi
echo ""

# Register Test
echo "2. Kullanıcı Kayıt Testi..."
REGISTER_RESPONSE=$(curl -s -X POST $API_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+905551234567",
    "password": "Test123!",
    "name": "Test User",
    "email": "test@example.com"
  }')

if echo "$REGISTER_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ Kayıt başarılı${NC}"
    echo "Response: $REGISTER_RESPONSE"
else
    echo -e "${RED}✗ Kayıt başarısız${NC}"
    echo "Response: $REGISTER_RESPONSE"
fi
echo ""

# Login Test
echo "3. Giriş Testi..."
LOGIN_RESPONSE=$(curl -s -X POST $API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+905551234567",
    "password": "Test123!"
  }')

if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
    echo -e "${GREEN}✓ Giriş başarılı${NC}"
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
    echo "Token alındı: ${TOKEN:0:20}..."
else
    echo -e "${RED}✗ Giriş başarısız${NC}"
    echo "Response: $LOGIN_RESPONSE"
fi
echo ""

echo "✅ Test tamamlandı!"
















