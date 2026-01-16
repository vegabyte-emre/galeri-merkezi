@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
title Galeri Merkezi - Otomatik Kurulum

echo.
echo ========================================
echo   Galeri Merkezi - Otomatik Kurulum
echo ========================================
echo.

:: 1. .env dosyasini kontrol et
echo [93m.env dosyasi kontrol ediliyor...[0m
if not exist .env (
    if not exist .env.example (
        echo [91m.env.example dosyasi bulunamadi![0m
        echo [93m  .env.example dosyasi olusturuluyor...[0m
        if exist create-env-example.bat (
            call create-env-example.bat
            if errorlevel 1 (
                echo [91m.env.example dosyasi olusturulamadi![0m
                echo.
                pause
                exit /b 1
            )
        ) else (
            echo [91mcreate-env-example.bat dosyasi bulunamadi![0m
            echo.
            pause
            exit /b 1
        )
        echo [92m.env.example dosyasi olusturuldu[0m
    )
    echo [92m.env dosyasi olusturuluyor...[0m
    copy .env.example .env >nul 2>&1
    if errorlevel 1 (
        echo [91m.env dosyasi olusturulamadi![0m
        echo.
        pause
        exit /b 1
    )
    echo [92m.env dosyasi olusturuldu[0m
) else (
    echo [92m.env dosyasi mevcut[0m
)
echo.

:: 2. Docker kontrolu
echo [93mDocker kontrol ediliyor...[0m
docker --version >nul 2>&1
if errorlevel 1 (
    echo [91mDocker bulunamadi![0m
    echo.
    echo [93mDocker Desktop Kurulumu:[0m
    echo    1. https://www.docker.com/products/docker-desktop adresinden Docker Desktop'i indirin
    echo    2. Docker Desktop'i yukleyin ve baslatin
    echo    3. Kurulum tamamlandiktan sonra bu script'i tekrar calistirin
    echo.
    pause
    exit /b 1
)

:: Docker'in calisip calismadigini kontrol et
echo [93mDocker servis durumu kontrol ediliyor...[0m
docker info >nul 2>&1
if errorlevel 1 (
    echo [93mDocker henuz hazir degil, bekleniyor...[0m
    echo [93mDocker Desktop'in tamamen baslamasini bekleyin...[0m
    echo.
    set COUNT=0
    :wait_docker
    docker info >nul 2>&1
    if errorlevel 1 (
        set /a COUNT=COUNT+1
        if !COUNT! GEQ 6 goto docker_timeout
        echo [93m  Bekleniyor... [!COUNT!/6][0m
        timeout /t 5 /nobreak >nul 2>&1
        goto wait_docker
    )
    echo [92mDocker hazir![0m
    echo.
    goto docker_ready
    :docker_timeout
    echo.
    echo [91mDocker 30 saniye icinde hazir olmadi![0m
    echo.
    echo [93mLutfen asagidaki adimlari kontrol edin:[0m
    echo    1. Docker Desktop'in sistem tepsisinde gorundugunden emin olun
    echo    2. Docker Desktop'i yeniden baslatin
    echo    3. Bir kac dakika bekleyin ve tekrar deneyin
    echo.
    echo [93mManuel kontrol icin: docker info[0m
    echo.
    pause
    exit /b 1
    :docker_ready
        echo [93m  Bekleniyor... [!COUNT!/6][0m
        timeout /t 5 /nobreak >nul 2>&1
        goto wait_docker
    )
    echo [92mDocker hazir![0m
    echo.
)

docker --version
echo [92mDocker mevcut ve calisiyor[0m
echo.

:: 3. Docker Compose kontrolu
echo [93mDocker Compose kontrol ediliyor...[0m
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [91mDocker Compose bulunamadi![0m
        echo [93m  Docker Desktop ile birlikte gelmelidir. Docker Desktop'i yeniden baslatmayi deneyin.[0m
        echo.
        pause
        exit /b 1
    ) else (
        docker compose version
        echo [92mDocker Compose v2 mevcut (docker compose)[0m
    )
) else (
    docker-compose --version
    echo [92mDocker Compose mevcut[0m
)
echo.

:: 4. Node.js kontrolu
echo [93mNode.js kontrol ediliyor...[0m
node --version >nul 2>&1
if errorlevel 1 (
    echo [91mNode.js bulunamadi! Lutfen Node.js yukleyin.[0m
    echo.
    pause
    exit /b 1
)
node --version
echo [92mNode.js mevcut[0m
echo.

:: 5. Docker servislerini baslat
echo [93mDocker servisleri baslatiliyor...[0m
docker-compose -f docker/docker-compose.yml up -d
if errorlevel 1 (
    echo [91mDocker servisleri baslatilamadi![0m
    echo.
    pause
    exit /b 1
)
echo [92mDocker servisleri baslatildi[0m
echo.

:: 6. Servislerin hazir olmasini bekle
echo [93mServislerin hazir olmasi bekleniyor (30 saniye)...[0m
timeout /t 30 /nobreak >nul 2>&1
echo [92mBekleme tamamlandi[0m
echo.

:: 7. Servis durumunu kontrol et
echo [93mServis durumu kontrol ediliyor...[0m
docker-compose -f docker/docker-compose.yml ps
echo.

:: 8. PostgreSQL hazir olana kadar bekle
echo [93mPostgreSQL hazir olana kadar bekleniyor...[0m
:wait_postgres
docker exec galeri-postgres pg_isready -U galeri_user >nul 2>&1
if errorlevel 1 (
    echo [93m  PostgreSQL henuz hazir degil, 5 saniye bekleniyor...[0m
    timeout /t 5 /nobreak >nul 2>&1
    goto wait_postgres
)
echo [92mPostgreSQL hazir[0m
echo.

:: 9. Migration'lari calistir
echo [93mVeritabani migration'lari calistiriliyor...[0m
call npm run migrate
if errorlevel 1 (
    echo [91mMigration'lar calistirilamadi![0m
    echo [93m  Devam ediliyor...[0m
) else (
    echo [92mMigration'lar tamamlandi[0m
)
echo.

:: 10. Test verileri sorusu
set /p SEED="Test verilerini yuklemek ister misiniz? (E/H): "
if /i "%SEED%"=="E" (
    echo [93mTest verileri yukleniyor...[0m
    call npm run seed
    if errorlevel 1 (
        echo [91mTest verileri yuklenemedi![0m
    ) else (
        echo [92mTest verileri yuklendi[0m
    )
    echo.
)

:: 11. Ozet bilgiler
echo.
echo [92m========================================[0m
echo [92m   Kurulum Tamamlandi![0m
echo [92m========================================[0m
echo.
echo [93mFrontend URL'leri:[0m
echo    - Landing:        http://localhost:3000
echo    - Admin Panel:   http://localhost:3001
echo    - Galeri Panel:  http://localhost:3002
echo.
echo [93mInfrastructure URL'leri:[0m
echo    - RabbitMQ:      http://localhost:15672 (guest/guest)
echo    - MinIO Console: http://localhost:9001 (minioadmin/minioadmin)
echo    - Traefik:       http://localhost:8080
echo    - Meilisearch:   http://localhost:7700
echo.
echo [93mNotlar:[0m
echo    - Servislerin tamamen hazir olmasi birkac dakika surebilir
echo    - Loglari gormek icin: docker-compose -f docker/docker-compose.yml logs -f
echo    - Servisleri durdurmak icin: docker-compose -f docker/docker-compose.yml down
echo.
echo [93mTest icin:[0m
echo    - API Test:      powershell -ExecutionPolicy Bypass -File scripts/test-api.ps1
echo    - Servis Kontrol: powershell -ExecutionPolicy Bypass -File scripts/check-services.ps1
echo.
echo.
echo [93mKurulum tamamlandi. Pencereyi kapatmak icin bir tusa basin...[0m
pause
