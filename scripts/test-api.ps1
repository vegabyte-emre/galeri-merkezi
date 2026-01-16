# PowerShell API Test Script
# Windows için API test scripti

$API_URL = "http://localhost:3000/api"

Write-Host "🧪 API Test Script Başlatılıyor..." -ForegroundColor Cyan
Write-Host ""

# Health Check
Write-Host "1. Health Check Testi..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$API_URL/health" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Health check başarılı" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Health check başarısız" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
Write-Host ""

# Register Test
Write-Host "2. Kullanıcı Kayıt Testi..." -ForegroundColor Yellow
$registerBody = @{
    phone = "+905551234567"
    password = "Test123!"
    name = "Test User"
    email = "test@example.com"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_URL/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    if ($response.success) {
        Write-Host "✓ Kayıt başarılı" -ForegroundColor Green
        Write-Host "Response: $($response | ConvertTo-Json -Depth 2)"
    }
} catch {
    Write-Host "✗ Kayıt başarısız" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
Write-Host ""

# Login Test
Write-Host "3. Giriş Testi..." -ForegroundColor Yellow
$loginBody = @{
    phone = "+905551234567"
    password = "Test123!"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_URL/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    if ($response.accessToken) {
        Write-Host "✓ Giriş başarılı" -ForegroundColor Green
        $token = $response.accessToken
        Write-Host "Token alındı: $($token.Substring(0, [Math]::Min(20, $token.Length)))..."
    }
} catch {
    Write-Host "✗ Giriş başarısız" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
Write-Host ""

Write-Host "✅ Test tamamlandı!" -ForegroundColor Green
















