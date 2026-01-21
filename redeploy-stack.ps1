add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts64 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts64
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_akR/jOJE+d7s/QU40cCRbl8W3wydQkX/kBxhxEYI/Gc="
$endpointId = 3
$stackId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$stackUrl = "$portainerUrl/api/stacks/$stackId"
$stack = Invoke-RestMethod -Uri $stackUrl -Headers $headers -Method Get

Write-Host "Stack redeploy ediliyor..."
$redeployUrl = "$portainerUrl/api/stacks/$stackId/git/redeploy?endpointId=$endpointId"
$body = @{
    pullImage = $true
    prune = $true
    repositoryReferenceName = "refs/heads/main"
    env = $stack.Env
} | ConvertTo-Json -Depth 5

$result = Invoke-RestMethod -Uri $redeployUrl -Headers $headers -Method Put -Body $body
Write-Host "Redeploy basarili! Panel yeniden build ediliyor..."
