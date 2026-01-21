add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts68 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts68
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$images = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/images/json" -Headers $headers -Method Get

$images | ConvertTo-Json -Depth 5 | Out-File "images.json"
Write-Host "Images exported to images.json"
Write-Host "Image count: $($images.Count)"
