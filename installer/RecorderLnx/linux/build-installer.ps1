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

if (-not (Test-Path $linuxExe)) {
    throw "Linux binary not found: $linuxExe. Build RecorderLnx on Linux first."
}
if (-not (Test-Path $builder)) {
    throw "Deb builder not found: $builder"
}

Write-Host "Packaging RecorderLnx Linux installer..."
& $Python $builder --repo-root $repoRoot --version $Version --architecture $Architecture
if ($LASTEXITCODE -ne 0) {
    throw "Linux installer build failed: exit code $LASTEXITCODE"
}

$outputFile = Join-Path $installerDir "Output\recorderlnx_${Version}_${Architecture}.deb"
Write-Host $outputFile
