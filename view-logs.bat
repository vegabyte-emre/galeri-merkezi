@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Servis Logları
echo ========================================
echo.

echo Hangi servisin loglarını görmek istersiniz?
echo.
echo 1. Tüm servisler
echo 2. API Gateway
echo 3. Auth Service
echo 4. Gallery Service
echo 5. Inventory Service
echo 6. Offer Service
echo 7. Chat Service
echo 8. PostgreSQL
echo 9. Redis
echo 10. RabbitMQ
echo.
set /p CHOICE="Seçiminiz (1-10): "

if "%CHOICE%"=="1" (
    docker-compose -f docker/docker-compose.yml logs -f
) else if "%CHOICE%"=="2" (
    docker-compose -f docker/docker-compose.yml logs -f api-gateway
) else if "%CHOICE%"=="3" (
    docker-compose -f docker/docker-compose.yml logs -f auth-service
) else if "%CHOICE%"=="4" (
    docker-compose -f docker/docker-compose.yml logs -f gallery-service
) else if "%CHOICE%"=="5" (
    docker-compose -f docker/docker-compose.yml logs -f inventory-service
) else if "%CHOICE%"=="6" (
    docker-compose -f docker/docker-compose.yml logs -f offer-service
) else if "%CHOICE%"=="7" (
    docker-compose -f docker/docker-compose.yml logs -f chat-service
) else if "%CHOICE%"=="8" (
    docker-compose -f docker/docker-compose.yml logs -f postgres
) else if "%CHOICE%"=="9" (
    docker-compose -f docker/docker-compose.yml logs -f redis
) else if "%CHOICE%"=="10" (
    docker-compose -f docker/docker-compose.yml logs -f rabbitmq
) else (
    echo Geçersiz seçim!
    pause
    exit /b 1
)
















