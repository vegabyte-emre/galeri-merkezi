add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts65 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts65
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$containers = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/json?all=true" -Headers $headers -Method Get

Write-Output "Container sayisi: $($containers.Length)"

# Admin container'i bul
$admin = $null
foreach ($c in $containers) {
    $name = $c.Names[0]
    if ($name -match "admin") {
        $admin = $c
        Write-Output "Admin bulundu: $name - ID: $($c.Id.Substring(0,12))"
    }
}

if ($admin) {
    Write-Output "Container durduruluyor..."
    try {
        Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/$($admin.Id)/stop" -Headers $headers -Method Post
        Write-Output "Durduruldu"
    } catch {
        Write-Output "Durdurma hatasi (zaten durmus olabilir)"
    }
    
    Write-Output "Container siliniyor..."
    try {
        Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/$($admin.Id)?force=true" -Headers $headers -Method Delete
        Write-Output "Silindi!"
    } catch {
        Write-Output "Silme hatasi: $_"
    }
}
