param(
    [string]$CoordinatorBinary = ''
)

$ErrorActionPreference = 'Stop'
$installerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $installerDir '..\..\..\..')).Path
if ([string]::IsNullOrWhiteSpace($CoordinatorBinary)) {
    $CoordinatorBinary = Join-Path $repoRoot 'Lazarus\RecorderCoordinator\lib\x86_64-linux\RecorderCoordinator'
}
$CoordinatorBinary = (Resolve-Path $CoordinatorBinary).Path
$payloadDir = Join-Path $installerDir 'payload'
$payloadBinary = Join-Path $payloadDir 'RecorderCoordinator'
$sourceIcon = Join-Path $repoRoot 'Lazarus\RecorderCoordinator\resources\app\rcPanel.png'
$payloadIcon = Join-Path $payloadDir 'rcpanel.png'
$checksumFile = Join-Path $payloadDir 'RecorderCoordinator.sha256'

function Get-Sha256Hex {
    param([string]$Path)

    $stream = [System.IO.File]::OpenRead($Path)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha256.ComputeHash($stream)
        return ([System.BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
    } finally {
        $sha256.Dispose()
        $stream.Dispose()
    }
}

if (-not (Test-Path -LiteralPath $payloadDir)) {
    New-Item -ItemType Directory -Path $payloadDir | Out-Null
}

$header = [System.IO.File]::ReadAllBytes($CoordinatorBinary)
if (($header.Length -lt 4) -or ($header[0] -ne 0x7f) -or
    ($header[1] -ne 0x45) -or ($header[2] -ne 0x4c) -or ($header[3] -ne 0x46)) {
    throw "RecorderCoordinator is not a Linux ELF binary: $CoordinatorBinary"
}

Copy-Item -LiteralPath $CoordinatorBinary -Destination $payloadBinary -Force
Copy-Item -LiteralPath $sourceIcon -Destination $payloadIcon -Force
$binaryHash = Get-Sha256Hex $payloadBinary
$iconHash = Get-Sha256Hex $payloadIcon
[System.IO.File]::WriteAllText(
    $checksumFile,
    "$binaryHash  RecorderCoordinator`n$iconHash  rcpanel.png`n",
    [System.Text.Encoding]::ASCII
)
Write-Host "Prepared: $payloadBinary"
Write-Host "Prepared: $payloadIcon"
Write-Host "SHA256:   $binaryHash"
