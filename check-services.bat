@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   Servis Durumu Kontrol
echo ========================================
echo.

powershell -ExecutionPolicy Bypass -File scripts/check-services.ps1

pause
















