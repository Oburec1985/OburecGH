param(
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'
$installerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $installerDir '..\..\..')).Path
$projectFile = Join-Path $repoRoot 'Lazarus\RecorderLnx\RecorderLnx.lpi'
$compiler = 'C:\lazarus\lazbuild.exe'
$iscc = 'C:\Program Files\Inno Setup 7\ISCC.exe'

if (-not (Test-Path $compiler)) {
    throw "Lazarus compiler not found: $compiler"
}
if (-not (Test-Path $iscc)) {
    throw "Inno Setup compiler not found: $iscc"
}

Write-Host 'Building RecorderLnx...'
& $compiler -B $projectFile
if ($LASTEXITCODE -ne 0) {
    throw "RecorderLnx build failed: exit code $LASTEXITCODE"
}

Write-Host 'Building Windows installer...'
& $iscc (Join-Path $installerDir 'RecorderLnx.iss')
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup build failed: exit code $LASTEXITCODE"
}

Write-Host (Join-Path $installerDir 'Output\RecorderLnx-Setup-0.1.0.exe')

