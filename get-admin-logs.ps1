add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts72 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts72
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

# Find admin container
$containers = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/json?all=true" -Headers $headers -Method Get
$admin = $containers | Where-Object { $_.Names[0] -eq "/otobia-admin" }

if ($admin) {
    Write-Host "Admin container ID: $($admin.Id.Substring(0,12))"
    Write-Host "Image: $($admin.Image)"
    Write-Host "ImageID: $($admin.ImageID.Substring(7,12))"
    Write-Host ""
    
    # Get logs
    $logs = Invoke-WebRequest -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/$($admin.Id)/logs?stdout=true&stderr=true&tail=50" -Headers $headers -Method Get -UseBasicParsing
    
    Write-Host "=== Logs ==="
    $logs.Content
}
