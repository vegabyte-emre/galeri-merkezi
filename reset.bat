@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Projeyi Sıfırlama
echo ========================================
echo.
echo ⚠️  UYARI: Bu işlem tüm verileri silecektir!
echo.
set /p CONFIRM="Devam etmek istediğinizden emin misiniz? (E/H): "

if /i not "%CONFIRM%"=="E" (
    echo İşlem iptal edildi.
    pause
    exit /b 0
)

echo.
echo Servisler durduruluyor...
docker-compose -f docker/docker-compose.yml down -v

echo.
echo Volume'lar temizleniyor...
docker volume prune -f

echo.
echo ✅ Proje sıfırlandı!
echo.
echo Şimdi setup.bat dosyasını çalıştırarak yeniden kurabilirsiniz.
echo.
pause
















