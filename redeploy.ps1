add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts47 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts47
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3
$stackId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

# Stack bilgisini al
$stackUrl = "$portainerUrl/api/stacks/$stackId"
$stack = Invoke-RestMethod -Uri $stackUrl -Headers $headers -Method Get

# Redeploy with git pull
Write-Host "Stack redeploy ediliyor..."
$redeployUrl = "$portainerUrl/api/stacks/$stackId/git/redeploy?endpointId=$endpointId"
$body = @{
    pullImage = $true
    repositoryReferenceName = "refs/heads/main"
    env = $stack.Env
} | ConvertTo-Json -Depth 5

$result = Invoke-RestMethod -Uri $redeployUrl -Headers $headers -Method Put -Body $body
Write-Host "Redeploy basarili!"
