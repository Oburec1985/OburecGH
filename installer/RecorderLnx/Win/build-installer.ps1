param(
    [string]$Configuration = 'Release',
    [string]$Version = ''
)

$ErrorActionPreference = 'Stop'
$installerDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $installerDir '..\..\..')).Path
$versionSource = Join-Path $repoRoot 'Lazarus\RecorderLnx\Core\uRecorderAppVersion.pas'
if ([string]::IsNullOrWhiteSpace($Version)) {
    if (-not (Test-Path -LiteralPath $versionSource)) {
        throw "RecorderLnx version source not found: $versionSource"
    }
    $versionMatch = [regex]::Match(
        [IO.File]::ReadAllText($versionSource),
        "CRecorderLnxVersion\s*=\s*'(?<version>[^']+)'"
    )
    if (-not $versionMatch.Success) {
        throw "Could not read CRecorderLnxVersion from: $versionSource"
    }
    $Version = $versionMatch.Groups['version'].Value
}
if ($Version -notmatch '^\d+\.\d+\.\d+([+~-][0-9A-Za-z.]+)?$') {
    throw "Invalid RecorderLnx installer version: $Version"
}
Write-Host "RecorderLnx installer version: $Version"
$projectFile = Join-Path $repoRoot 'Lazarus\RecorderLnx\RecorderLnx.lpi'
$hostAgentProjectFile = Join-Path $repoRoot 'Lazarus\RecorderHostAgent\RecorderHostAgent.lpi'
$luaPluginProjectFile = Join-Path $repoRoot 'Lazarus\RecorderLnx\Plugins\LuaCalcPlugin\LuaCalcPlugin.lpi'
$oscillographPluginProjectFile = Join-Path $repoRoot 'Lazarus\RecorderLnx\Plugins\SampleInfoPlugin\SampleInfoPlugin.lpi'
$hostAgentPackage = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-win64\RecorderHostAgent.exe'
$pluginPackageDir = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-win64\plugins'
$luaPluginPackage = Join-Path $pluginPackageDir 'LuaCalcPlugin.dll'
$oscillographPluginPackage = Join-Path $pluginPackageDir 'SampleInfoPlugin.dll'
$luaRuntimePackage = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-win64\lua54.dll'
$luaHelpBuild = Join-Path $repoRoot 'Lazarus\RecorderLnx\Docs\LuaHelp\build-help.ps1'
$luaHelpPackage = Join-Path $repoRoot 'Lazarus\RecorderLnx\lib\x86_64-win64\help\RecorderLnxLua.chm'
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

Write-Host 'Building LuaCalcPlugin...'
& $compiler -B $luaPluginProjectFile
if ($LASTEXITCODE -ne 0) {
    throw "LuaCalcPlugin build failed: exit code $LASTEXITCODE"
}

Write-Host 'Building SampleInfoPlugin (oscillograph)...'
& $compiler -B $oscillographPluginProjectFile
if ($LASTEXITCODE -ne 0) {
    throw "SampleInfoPlugin build failed: exit code $LASTEXITCODE"
}

foreach ($packageFile in @($luaPluginPackage, $oscillographPluginPackage, $luaRuntimePackage)) {
    if (-not (Test-Path -LiteralPath $packageFile)) {
        throw "Required plugin package file not found: $packageFile"
    }
}

Write-Host 'Building Lua CHM help...'
& $luaHelpBuild
if ($LASTEXITCODE -ne 0) {
    throw "Lua CHM help build failed: exit code $LASTEXITCODE"
}
if (-not (Test-Path -LiteralPath $luaHelpPackage)) {
    throw "Lua CHM help package not found: $luaHelpPackage"
}

Write-Host 'Building Windows installer...'
& $iscc "/DAppVersion=$Version" (Join-Path $installerDir 'RecorderLnx.iss')
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup build failed: exit code $LASTEXITCODE"
}

Write-Host (Join-Path $installerDir "Output\RecorderLnx-Setup-$Version.exe")
