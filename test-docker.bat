@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Docker Test
echo ========================================
echo.

echo Docker versiyonu:
docker --version
echo.

echo Docker bilgileri:
docker info
echo.

echo Docker container listesi:
docker ps
echo.

echo Docker Compose versiyonu:
docker-compose --version 2>nul || docker compose version
echo.

pause















