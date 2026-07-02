# MIC-140 capture: proxy + netsh filter by device IP.
# Usage:
#   .\mic140_capture_start.ps1
#   Start Recorder, press Preview.
#   .\mic140_capture_stop.ps1

param(
    [string]$DeviceHost = '192.168.14.155',
    [int]$DevicePort = 4000,
    [int]$ProxyPort = 4001
)

$ErrorActionPreference = 'Continue'
$Root = Split-Path $PSScriptRoot -Parent
$CapDir = Join-Path $Root 'Data\captures'
$Cli = Join-Path $Root 'Mic140ProtocolDebugCli.exe'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$SessionFile = Join-Path $CapDir "session_$Stamp.txt"

New-Item -ItemType Directory -Force -Path $CapDir | Out-Null

$header = @(
    "# MIC-140 capture session $Stamp"
    "device=${DeviceHost}:${DevicePort}"
    "proxy_listen=127.0.0.1:${ProxyPort}"
    "started=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)
$header | Set-Content -Encoding UTF8 $SessionFile

Write-Host "=== MIC-140 capture session $Stamp ==="
Write-Host "Device: ${DeviceHost}:${DevicePort}"
Write-Host "Session: $SessionFile"

if (Test-Path $Cli) {
    $proxyLog = Join-Path $CapDir "mdp_proxy_$Stamp.log"
    $proxyErr = Join-Path $CapDir "mdp_proxy_$Stamp.err.log"
    $argList = "--proxy $ProxyPort $DeviceHost $DevicePort"
    Start-Process -FilePath $Cli -ArgumentList $argList -RedirectStandardOutput $proxyLog `
        -RedirectStandardError $proxyErr -WindowStyle Minimized | Out-Null
    Add-Content $SessionFile "proxy_log=$proxyLog"
    Add-Content $SessionFile "proxy_err=$proxyErr"
    Write-Host "MDP proxy: 127.0.0.1:$ProxyPort -> ${DeviceHost}:$DevicePort"
    Write-Host "  log: $proxyLog"
} else {
    Write-Warning "Build Mic140ProtocolDebugCli.lpi first"
}

$etl = Join-Path $CapDir "netsh_${DeviceHost}_$Stamp.etl"
netsh trace stop 2>$null | Out-Null
$ns = netsh trace start capture=yes tracefile="$etl" overwrite=yes maxsize=256 IPv4.Address=$DeviceHost 2>&1
if ($LASTEXITCODE -eq 0) {
    Add-Content $SessionFile "netsh_etl=$etl"
    Write-Host "netsh trace: $etl (IPv4.Address=$DeviceHost)"
} else {
    Write-Warning "netsh trace failed (run PowerShell as Administrator): $ns"
}

Write-Host ""
Write-Host "Ready. Start Recorder and press Preview."
Write-Host "  Recorder: C:\Program Files (x86)\Mera\Recorder\Recorder.exe"
$recorder = 'C:\Program Files (x86)\Mera\Recorder\Recorder.exe'
if (Test-Path $recorder) {
    Start-Process -FilePath $recorder | Out-Null
    Write-Host "  launched Recorder.exe"
}
Write-Host "Stop capture: mic140_capture_stop.ps1"
