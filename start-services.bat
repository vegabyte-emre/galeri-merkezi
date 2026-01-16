@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Servisleri Başlatma
echo ========================================
echo.

echo Servisler başlatılıyor...
docker-compose -f docker/docker-compose.yml up -d

echo.
echo ✅ Servisler başlatıldı!
echo.
echo Logları görmek için: docker-compose -f docker/docker-compose.yml logs -f
echo.
pause
















