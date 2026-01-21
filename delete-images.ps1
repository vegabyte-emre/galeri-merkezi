add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts69 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts69
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$images = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/images/json" -Headers $headers -Method Get

# Admin image'lari sil
foreach ($img in $images) {
    $tags = $img.RepoTags
    foreach ($tag in $tags) {
        if ($tag -match "admin") {
            Write-Host "Siliniyor: $tag"
            try {
                $encodedTag = [System.Web.HttpUtility]::UrlEncode($tag)
                Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/images/$encodedTag`?force=true" -Headers $headers -Method Delete
                Write-Host "Silindi: $tag"
            } catch {
                Write-Host "Silme hatasi: $tag - $_"
            }
        }
    }
}

# Panel image'lari da sil
foreach ($img in $images) {
    $tags = $img.RepoTags
    foreach ($tag in $tags) {
        if ($tag -match "panel") {
            Write-Host "Siliniyor: $tag"
            try {
                $encodedTag = [System.Web.HttpUtility]::UrlEncode($tag)
                Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/images/$encodedTag`?force=true" -Headers $headers -Method Delete
                Write-Host "Silindi: $tag"
            } catch {
                Write-Host "Silme hatasi: $tag - $_"
            }
        }
    }
}

Write-Host "Tamamlandi!"
