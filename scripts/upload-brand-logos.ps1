# PowerShell script to upload brand logos
# Usage: .\upload-brand-logos.ps1 -LogosFolder "C:\Users\Emre\Desktop\otobia\Araç Kataloğu"

param(
    [Parameter(Mandatory=$true)]
    [string]$LogosFolder,
    
    [string]$ApiUrl = "https://api.otobia.com",
    [string]$ImportKey = "otobia-catalog-import-2026"
)

# Get all logo files
$logoFiles = Get-ChildItem -Path $LogosFolder -Filter "*.svg" -ErrorAction SilentlyContinue
if (-not $logoFiles) {
    $logoFiles = Get-ChildItem -Path $LogosFolder -Include "*.svg","*.png","*.jpg" -ErrorAction SilentlyContinue
}

Write-Host "Found $($logoFiles.Count) logo files" -ForegroundColor Cyan

# Step 1: Import brands to database
Write-Host "`n1. Importing brands to database..." -ForegroundColor Yellow

$brands = @()
foreach ($file in $logoFiles) {
    $brandName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $brands += @{ name = $brandName; logo_url = $null }
}

$importBody = @{ brands = $brands } | ConvertTo-Json -Depth 3

try {
    $importResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/catalog/import" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{ "X-Import-Key" = $ImportKey } `
        -Body $importBody
    
    Write-Host "Import result: $($importResponse.message)" -ForegroundColor Green
    Write-Host "Brands imported: $($importResponse.data.brands)" -ForegroundColor Green
}
catch {
    Write-Host "Import failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Get brand list
Write-Host "`n2. Fetching brand list..." -ForegroundColor Yellow

try {
    $brandsResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/catalog/brands" -Method GET
    $brandsMap = @{}
    foreach ($brand in $brandsResponse.data) {
        $brandsMap[$brand.name.ToLower()] = $brand.id
    }
    Write-Host "Found $($brandsMap.Count) brands in database" -ForegroundColor Green
}
catch {
    Write-Host "Failed to fetch brands: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Upload logos
Write-Host "`n3. Uploading logos..." -ForegroundColor Yellow

$successCount = 0
$failCount = 0

foreach ($file in $logoFiles) {
    $brandName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $brandId = $brandsMap[$brandName.ToLower()]
    
    if (-not $brandId) {
        Write-Host "  [SKIP] $brandName - not found in database" -ForegroundColor Yellow
        $failCount++
        continue
    }
    
    try {
        # Read file and create multipart form
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $boundary = [System.Guid]::NewGuid().ToString()
        
        $LF = "`r`n"
        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"logo`"; filename=`"$($file.Name)`"",
            "Content-Type: image/svg+xml",
            "",
            [System.Text.Encoding]::UTF8.GetString($fileBytes),
            "--$boundary--"
        )
        $body = $bodyLines -join $LF
        
        $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/catalog/brands/$brandId/logo" `
            -Method POST `
            -ContentType "multipart/form-data; boundary=$boundary" `
            -Body $body
        
        Write-Host "  [OK] $brandName -> $($response.data.logo_url)" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "  [FAIL] $brandName - $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n4. Done!" -ForegroundColor Cyan
Write-Host "   Success: $successCount" -ForegroundColor Green
Write-Host "   Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
