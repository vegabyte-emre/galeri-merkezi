add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts71 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts71
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$containers = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/json?all=true" -Headers $headers -Method Get

Write-Host "=== Container Durumu ==="
foreach ($c in $containers) {
    $name = $c.Names[0]
    $state = $c.State
    $status = $c.Status
    if ($name -match "admin|panel") {
        Write-Host "$name : $state - $status"
    }
}
