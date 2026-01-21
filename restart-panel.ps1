add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts49 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts49
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

# Container listesini al
$containers = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/json?all=true" -Headers $headers -Method Get

# Panel container'ini bul
$panel = $containers | Where-Object { $_.Names[0] -like "*panel*" }
if ($panel) {
    Write-Host "Panel container: $($panel.Names[0])"
    Write-Host "State: $($panel.State)"
    Write-Host "Status: $($panel.Status)"
    
    # Container'i restart et
    Write-Host "`nPanel container restart ediliyor..."
    $restartUrl = "$portainerUrl/api/endpoints/$endpointId/docker/containers/$($panel.Id)/restart"
    Invoke-RestMethod -Uri $restartUrl -Headers $headers -Method Post
    Write-Host "Panel restart edildi!"
} else {
    Write-Host "Panel container bulunamadi"
}
