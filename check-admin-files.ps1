add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts73 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts73
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

function Run-Exec($containerId, $cmd) {
    $execBody = @{
        AttachStdin = $false
        AttachStdout = $true
        AttachStderr = $true
        Tty = $false
        Cmd = @("sh", "-c", $cmd)
    } | ConvertTo-Json -Depth 10

    $execCreate = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/$containerId/exec" -Headers $headers -Method Post -Body $execBody
    
    $startBody = '{"Detach":false,"Tty":false}'
    $result = Invoke-WebRequest -Uri "$portainerUrl/api/endpoints/$endpointId/docker/exec/$($execCreate.Id)/start" -Headers $headers -Method Post -Body $startBody -UseBasicParsing
    
    $text = ""
    for ($i = 0; $i -lt $result.Content.Length; $i++) {
        $b = [byte][char]$result.Content[$i]
        if ($b -ge 32 -and $b -le 126) { $text += [char]$b }
        elseif ($b -eq 10) { $text += "`n" }
    }
    return $text
}

Write-Host "=== Admin Container Files ==="
$result = Run-Exec $admin.Id "ls -la /usr/share/nginx/html/"
Write-Host $result

Write-Host ""
Write-Host "=== Check for vehicle-approvals in _nuxt files ==="
$result = Run-Exec $admin.Id "find /usr/share/nginx/html -name '*vehicle*' 2>/dev/null || echo 'not found'"
Write-Host $result
