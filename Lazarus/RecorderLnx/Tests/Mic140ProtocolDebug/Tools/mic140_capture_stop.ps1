# Остановка netsh trace после сессии Recorder.

$Root = Split-Path $PSScriptRoot -Parent
$CapDir = Join-Path $Root 'Data\captures'

Write-Host "Stopping netsh trace..."
try {
    netsh trace stop 2>&1
} catch {
    Write-Warning $_
}

$latest = Get-ChildItem $CapDir -Filter 'session_*.txt' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latest) {
    Write-Host "Last session: $($latest.FullName)"
    Get-Content $latest.FullName
}

Write-Host "Captures in: $CapDir"
