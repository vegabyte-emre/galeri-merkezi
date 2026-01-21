add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts55 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts55
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$portainerUrl = "https://72.62.115.27:9443"
$apiKey = "ptr_JdUVeJJw0jI6Dq8SfFesSLlOonyu8yvUn4eR8SPsD6Y="
$endpointId = 3

$headers = @{ 
    "X-API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$containers = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/json?all=true" -Headers $headers -Method Get
$postgres = $containers | Where-Object { $_.Names[0] -like "*postgres*" }

function Run-Exec($cmd) {
    $execBody = @{
        AttachStdin = $false
        AttachStdout = $true
        AttachStderr = $true
        Tty = $false
        Cmd = @("sh", "-c", $cmd)
    } | ConvertTo-Json -Depth 10

    $execCreate = Invoke-RestMethod -Uri "$portainerUrl/api/endpoints/$endpointId/docker/containers/$($postgres.Id)/exec" -Headers $headers -Method Post -Body $execBody
    
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

# SQL dosyasini oku ve base64 encode et
$sqlContent = Get-Content "C:\Users\Emre\Desktop\Cursor\GaleriMerkezi\galeri-merkezi\check-users.sql" -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($sqlContent)
$base64 = [Convert]::ToBase64String($bytes)

Write-Host "=== Kullanicilar ==="
$cmd = "echo '$base64' | base64 -d > /tmp/check.sql && psql -U otobia_user -d otobia_db -f /tmp/check.sql"
$result = Run-Exec $cmd
Write-Host $result
