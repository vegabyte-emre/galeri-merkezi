@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Servisleri Durdurma
echo ========================================
echo.

echo Servisler durduruluyor...
docker-compose -f docker/docker-compose.yml down

echo.
echo ✅ Servisler durduruldu!
echo.
pause
















