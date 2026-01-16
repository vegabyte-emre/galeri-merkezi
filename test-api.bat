@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   API Test Script
echo ========================================
echo.

powershell -ExecutionPolicy Bypass -File scripts/test-api.ps1

pause
















