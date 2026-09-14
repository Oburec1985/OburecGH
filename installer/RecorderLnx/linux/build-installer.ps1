param(
    [string]$Version = '0.1.10',
    [string]$Architecture = 'amd64',
    [string]$Python = 'python'
)

$ErrorActionPreference = 'Stop'
$installerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $installerDir '..\..\..')).Path
$builder = Join-Path $installerDir 'build_deb.py'
$linuxExe = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-linux\RecorderLnx'
$linuxAgentExe = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-linux\RecorderHostAgent'
$linuxShareManagerExe = Join-Path $repoRoot 'Lazarus\RecorderLnx\Tools\NetworkShareManager\lib\x86_64-linux\NetworkShareManager'
$outputDir = Join-Path $installerDir 'Output'
$outputFile = Join-Path $outputDir "recorderlnx_${Version}_${Architecture}.deb"
$previousOutputFile = Join-Path $outputDir "recorderlnx_${Version}_${Architecture}.previous.deb"
$appConfig = Join-Path $repoRoot 'Lazarus\RecorderLnx\config\app.ini'
$projectSqlConfig = Join-Path $repoRoot 'Lazarus\RecorderLnx\config\projects\default\sql-db.ini'

if (-not (Test-Path $linuxExe)) {
    throw "Linux binary not found: $linuxExe. Build RecorderLnx on Linux first."
}
if (-not (Test-Path $builder)) {
    throw "Deb builder not found: $builder"
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
if (Select-String -LiteralPath $projectSqlConfig -Pattern '^(Host|Port|Database|UserName|Password)=' -Quiet) {
    throw "Project sql-db.ini contains system connection settings: $projectSqlConfig"
}

if (-not (Test-Path -LiteralPath $linuxAgentExe)) {
    throw "Linux RecorderHostAgent build output not found beside RecorderLnx: $linuxAgentExe"
}
if (-not (Test-Path -LiteralPath $linuxShareManagerExe)) {
    throw "Linux NetworkShareManager build output not found: $linuxShareManagerExe"
}

$agentRoot = Join-Path $repoRoot 'Lazarus\RecorderHostAgent'
$agentSources = @(
    Get-Item (Join-Path $agentRoot 'RecorderHostAgent.lpi')
    Get-Item (Join-Path $agentRoot 'RecorderHostAgent.lpr')
    Get-ChildItem -Path (Join-Path $agentRoot 'Core\*.pas') -File
    Get-ChildItem -Path (Join-Path $agentRoot 'Service\*.pas') -File
)
$newestAgentSource = $agentSources | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
if (($null -ne $newestAgentSource) -and
    ($newestAgentSource.LastWriteTimeUtc -gt (Get-Item -LiteralPath $linuxAgentExe).LastWriteTimeUtc)) {
    throw "Linux RecorderHostAgent is older than source: $($newestAgentSource.FullName). Build it on Linux first."
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
