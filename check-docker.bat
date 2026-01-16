@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Docker Durum Kontrolü
echo ========================================
echo.

:: Docker kontrolü
echo Docker versiyonu kontrol ediliyor...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [91m✗ Docker bulunamadı![0m
    echo.
    echo Docker Desktop'ı yüklemeniz gerekiyor:
    echo https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

docker --version
echo [92m✓ Docker yüklü[0m
echo.

:: Docker'ın çalışıp çalışmadığını kontrol et
echo Docker servis durumu kontrol ediliyor...
docker info >nul 2>&1
if errorlevel 1 (
    echo [91m✗ Docker çalışmıyor![0m
    echo.
    echo Docker Desktop'ı başlatmanız gerekiyor:
    echo 1. Başlat menüsünden "Docker Desktop" uygulamasını açın
    echo 2. Docker Desktop'ın tamamen başlamasını bekleyin
    echo 3. Sistem tepsinde Docker ikonu göründüğünde hazırdır
    echo.
    pause
    exit /b 1
)

echo [92m✓ Docker çalışıyor[0m
echo.

:: Docker Compose kontrolü
echo Docker Compose kontrol ediliyor...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [91m✗ Docker Compose bulunamadı![0m
    ) else (
        docker compose version
        echo [92m✓ Docker Compose v2 mevcut[0m
    )
) else (
    docker-compose --version
    echo [92m✓ Docker Compose mevcut[0m
)
echo.

echo [92m========================================[0m
echo [92m   ✅ Docker Hazır![0m
echo [92m========================================[0m
echo.

pause
















