param(
    [string]$Configuration = 'Release',
    [string]$Version = '0.1.10'
)

$ErrorActionPreference = 'Stop'
$installerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $installerDir '..\..\..')).Path
$projectFile = Join-Path $repoRoot 'Lazarus\RecorderLnx\RecorderLnx.lpi'
$hostAgentProjectFile = Join-Path $repoRoot 'Lazarus\RecorderHostAgent\RecorderHostAgent.lpi'
$hostAgentPackage = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-win64\RecorderHostAgent.exe'
$compiler = 'C:\lazarus\lazbuild.exe'
$iscc = 'C:\Program Files\Inno Setup 7\ISCC.exe'
$appConfig = Join-Path $repoRoot 'Lazarus\RecorderLnx\config\app.ini'
$projectSqlConfig = Join-Path $repoRoot 'Lazarus\RecorderLnx\config\projects\default\sql-db.ini'

if (-not (Test-Path $compiler)) {
    throw "Lazarus compiler not found: $compiler"
}
if (-not (Test-Path $iscc)) {
    throw "Inno Setup compiler not found: $iscc"
}
if (-not (Test-Path -LiteralPath $appConfig)) {
    throw "RecorderLnx app.ini not found: $appConfig"
}
if (-not (Test-Path -LiteralPath $projectSqlConfig)) {
    throw "RecorderLnx project sql-db.ini not found: $projectSqlConfig"
}
if (-not (Select-String -LiteralPath $appConfig -Pattern '^\[SQLdbConnection\]$' -Quiet)) {
    throw "RecorderLnx app.ini does not contain [SQLdbConnection]: $appConfig"
}

Write-Host 'Building RecorderLnx...'
& $compiler -B $projectFile
if ($LASTEXITCODE -ne 0) {
    throw "RecorderLnx build failed: exit code $LASTEXITCODE"
}

Write-Host 'Building RecorderHostAgent...'
& $compiler -B $hostAgentProjectFile
if ($LASTEXITCODE -ne 0) {
    throw "RecorderHostAgent build failed: exit code $LASTEXITCODE"
}
Write-Host 'Staging RecorderHostAgent beside RecorderLnx...'
if (-not (Test-Path -LiteralPath $hostAgentPackage)) {
    throw "RecorderHostAgent build output not found beside RecorderLnx: $hostAgentPackage"
}

Write-Host 'Building Windows installer...'
& $iscc "/DAppVersion=$Version" (Join-Path $installerDir 'RecorderLnx.iss')
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup build failed: exit code $LASTEXITCODE"
}

Write-Host (Join-Path $installerDir "Output\RecorderLnx-Setup-$Version.exe")
