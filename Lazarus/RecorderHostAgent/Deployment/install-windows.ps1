param(
    [string]$InstallDir = "$env:ProgramFiles\Mera\RecorderLnx",
    [string]$RecorderPath = "$env:ProgramFiles\Mera\RecorderLnx\RecorderLnx.exe"
)

$ErrorActionPreference = 'Stop'
$sourceDir = Split-Path -Parent $PSScriptRoot
$sourceExe = Join-Path $sourceDir 'lib\x86_64-win64\RecorderHostAgent.exe'
$targetExe = Join-Path $InstallDir 'RecorderHostAgent.exe'
$targetIni = Join-Path $InstallDir 'RecorderHostAgent.ini'

if (-not (Test-Path -LiteralPath $sourceExe)) {
    throw "Build RecorderHostAgent first: $sourceExe"
}
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item -LiteralPath $sourceExe -Destination $targetExe -Force
if (-not (Test-Path -LiteralPath $targetIni)) {
    @"
[agent]
listen=0.0.0.0
port=8766
recorder_path=$RecorderPath
allow_shutdown=0
api_token=
"@ | Set-Content -LiteralPath $targetIni -Encoding UTF8
}

$runKey = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
New-ItemProperty -Path $runKey -Name 'MeraRecorderHostAgent' `
    -Value ('"{0}"' -f $targetExe) -PropertyType String -Force | Out-Null
Write-Host "RecorderHostAgent installed. It will start at the next user logon."
