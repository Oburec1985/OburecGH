param(
    [string]$Version = '0.1.0',
    [string]$Architecture = 'amd64',
    [string]$Python = 'python'
)

$ErrorActionPreference = 'Stop'
$installerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $installerDir '..\..\..')).Path
$builder = Join-Path $installerDir 'build_deb.py'
$linuxExe = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-linux\RecorderLnx'
$outputDir = Join-Path $installerDir 'Output'
$outputFile = Join-Path $outputDir "recorderlnx_${Version}_${Architecture}.deb"
$previousOutputFile = Join-Path $outputDir "recorderlnx_${Version}_${Architecture}.previous.deb"

if (-not (Test-Path $linuxExe)) {
    throw "Linux binary not found: $linuxExe. Build RecorderLnx on Linux first."
}
if (-not (Test-Path $builder)) {
    throw "Deb builder not found: $builder"
}

Write-Host "Packaging RecorderLnx Linux installer..."
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}
if (Test-Path $outputFile) {
    if (Test-Path $previousOutputFile) {
        Remove-Item -LiteralPath $previousOutputFile -Force
    }
    Move-Item -LiteralPath $outputFile -Destination $previousOutputFile -Force
    Write-Host "Previous package moved to: $previousOutputFile"
}
& $Python $builder --repo-root $repoRoot --version $Version --architecture $Architecture
if ($LASTEXITCODE -ne 0) {
    throw "Linux installer build failed: exit code $LASTEXITCODE"
}

if (-not (Test-Path $outputFile)) {
    throw "Linux installer build completed, but output file was not created: $outputFile"
}

$item = Get-Item -LiteralPath $outputFile
Write-Host ("Created package: {0}" -f $item.FullName)
Write-Host ("Package timestamp: {0}" -f $item.LastWriteTime)
