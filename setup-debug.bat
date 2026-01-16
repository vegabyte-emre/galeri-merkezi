@echo on
chcp 65001
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Galeri Merkezi - Otomatik Kurulum (DEBUG)
echo ========================================
echo.

:: Docker kontrolu
echo Docker versiyonu kontrol ediliyor...
docker --version
if errorlevel 1 (
    echo HATA: Docker bulunamadi!
    pause
    exit /b 1
)

echo.
echo Docker bilgileri kontrol ediliyor...
docker info
if errorlevel 1 (
    echo.
    echo UYARI: Docker info basarisiz, bekleniyor...
    set COUNT=0
    :wait_docker
    docker info >nul 2>&1
    if errorlevel 1 (
        set /a COUNT+=1
        echo Deneme !COUNT!/6
        if !COUNT! GEQ 6 (
            echo HATA: Docker 30 saniye icinde hazir olmadi!
            pause
            exit /b 1
        )
        timeout /t 5 /nobreak
        goto wait_docker
    )
    echo Docker hazir!
)

echo.
echo Docker Compose kontrol ediliyor...
docker-compose --version 2>nul || docker compose version

echo.
echo Node.js kontrol ediliyor...
node --version

echo.
echo Tum kontroller tamamlandi!
pause















