add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustCerts53 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustCerts53
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

# Superadmin kullanicisi olustur
# Password: Admin123! (bcrypt hash)
$sql = @"
INSERT INTO users (id, email, password_hash, first_name, last_name, role, status, email_verified)
VALUES (
  gen_random_uuid(),
  'admin@otobia.com',
  '\$2b\$12\$ZX2lixz7Zi/.PmK5ydAPJeEdpmCKMrD6xGawdK93o3Uz/LW07LZDu',
  'Super',
  'Admin',
  'superadmin',
  'active',
  true
)
ON CONFLICT (email) DO UPDATE SET role = 'superadmin';
"@

Write-Host "=== Superadmin kullanicisi olusturuluyor ==="
$result = Run-Exec "psql -U otobia_user -d otobia_db -c `"$sql`""
Write-Host $result

# Mevcut kullanicilari listele
Write-Host "`n=== Kullanicilar ==="
$result = Run-Exec "psql -U otobia_user -d otobia_db -t -c 'SELECT email, role FROM users;'"
Write-Host $result
