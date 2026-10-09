param(
    [string]$Configuration = 'Release',
    [string]$Version = '',
    [string]$VendorDevApiDir = '',
    [string]$VcRedistX86Path = '',
    [switch]$SkipLuaHelpBuild
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
$collector = Join-Path $installerDir 'collect-files.bat'
$payloadDir = Join-Path $installerDir 'files'
$appConfig = Join-Path $repoRoot 'Lazarus\RecorderLnx\config\app.ini'
$projectSqlConfig = Join-Path $repoRoot 'Lazarus\RecorderLnx\config\projects\default\sql-db.ini'
$mx248Manifest = Join-Path $repoRoot 'Lazarus\RecorderLnx\Device\PXI\MX248\Vendor\Win32\manifest.sha256'
$mx248RepositoryVendorDir = Join-Path $repoRoot 'Lazarus\RecorderLnx\Device\PXI\MX248\Vendor\Win32'
$mx248BridgeDir = Join-Path $repoRoot 'Lazarus\RecorderLnx\Device\PXI\MX248\Bridge'
$mx248BridgeProject = Join-Path $mx248BridgeDir 'PxiMx248Bridge.dpr'
$mx248BridgeExe = Join-Path $mx248BridgeDir 'PxiMx248Bridge.exe'
$mx248ProtocolTest = Join-Path $mx248BridgeDir 'Tests\PxiMx248BridgeProtocolTest.dpr'
$mx248ProtocolTestExe = Join-Path $mx248BridgeDir 'Tests\PxiMx248BridgeProtocolTest.exe'
$mx248AbiSmoke = Join-Path $mx248BridgeDir 'Tests\PxiMx248DevApiAbiSmoke.dpr'
$mx248AbiSmokeExe = Join-Path $mx248BridgeDir 'Tests\PxiMx248DevApiAbiSmoke.exe'
$mx248ProcessSmokeProject = Join-Path $repoRoot 'Lazarus\RecorderLnx\Device\PXI\MX248\Transport\Windows\Tests\PxiMx248BridgeProcessSmoke.lpi'
$mx248ProcessSmokeExe = Join-Path $repoRoot 'Lazarus\RecorderLnx\Device\PXI\MX248\Transport\Windows\Tests\lib\x86_64-win64\PxiMx248BridgeProcessSmoke.exe'
$dcc32 = 'C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\DCC32.EXE'
$mx248VendorFiles = @(
    'DevAPI.dll',
    'mdpC6424.dll',
    'MDProtocol.dll',
    'mx224v14.dll',
    'FTD2XX.dll',
    'mfc90.dll',
    'msvcp90.dll',
    'msvcr90.dll',
    'wd_utils.dll'
)

function Get-PeMachine([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
        throw "Not a PE file: $Path"
    }
    $peOffset = [BitConverter]::ToInt32($bytes, 60)
    if ($peOffset -lt 0 -or ($peOffset + 6) -gt $bytes.Length) {
        throw "Invalid PE header offset: $Path"
    }
    return [BitConverter]::ToUInt16($bytes, $peOffset + 4)
}

function Invoke-BoundedProcess([string]$FileName, [string[]]$Arguments,
    [int]$TimeoutMs = 15000) {
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $FileName
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    foreach ($argument in $Arguments) { [void]$startInfo.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    if (-not $process.Start()) { throw "Could not start: $FileName" }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($TimeoutMs)) {
        try { $process.Kill($true) } catch {}
        throw "Process timeout after $TimeoutMs ms: $FileName"
    }
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    if ($stdout) { Write-Host $stdout.TrimEnd() }
    if ($stderr) { Write-Host $stderr.TrimEnd() }
    if ($process.ExitCode -ne 0) {
        throw "Process failed with exit code $($process.ExitCode): $FileName"
    }
}

function Assert-Mx248VendorStack([string]$Directory) {
    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        throw "MX-248 DevAPI directory not found: $Directory"
    }
    foreach ($fileName in $mx248VendorFiles) {
        $filePath = Join-Path $Directory $fileName
        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            throw "Required MX-248 vendor file not found: $filePath"
        }
        $machine = Get-PeMachine $filePath
        if ($machine -ne 0x014C) {
            throw ('MX-248 vendor file must be x86 (PE machine 0x014C): ' +
                "$filePath, actual=0x$($machine.ToString('X4'))")
        }
    }
    if (-not (Test-Path -LiteralPath $mx248Manifest -PathType Leaf)) {
        throw "MX-248 vendor hash manifest not found: $mx248Manifest"
    }
    $expectedHashes = @{}
    foreach ($line in [IO.File]::ReadAllLines($mx248Manifest)) {
        if ($line -match '^(?<hash>[0-9a-fA-F]{64}) \*(?<name>.+)$') {
            $expectedHashes[$matches.name] = $matches.hash.ToLowerInvariant()
        }
    }
    foreach ($fileName in $mx248VendorFiles) {
        if (-not $expectedHashes.ContainsKey($fileName)) {
            throw "MX-248 manifest entry missing: $fileName"
        }
        $filePath = Join-Path $Directory $fileName
        $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $filePath).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHashes[$fileName]) {
            throw "MX-248 vendor hash mismatch: $filePath"
        }
    }
}

if (-not (Test-Path $compiler)) {
    throw "Lazarus compiler not found: $compiler"
}
if (-not (Test-Path $iscc)) {
    throw "Inno Setup compiler not found: $iscc"
}
if (-not (Test-Path -LiteralPath $collector -PathType Leaf)) {
    throw "Installer payload collector not found: $collector"
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

if ([string]::IsNullOrWhiteSpace($VendorDevApiDir)) {
    $VendorDevApiDir = $mx248RepositoryVendorDir
}
Assert-Mx248VendorStack $VendorDevApiDir
Write-Host "MX-248 x86 DevAPI stack verified: $VendorDevApiDir"
if ([string]::IsNullOrWhiteSpace($VcRedistX86Path)) {
    $redist = Get-ChildItem 'C:\ProgramData\Package Cache' -Recurse `
        -Filter 'VC_redist.x86.exe' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
    if ($null -ne $redist) {
        $VcRedistX86Path = $redist.FullName
    }
}
if (-not (Test-Path -LiteralPath $VcRedistX86Path -PathType Leaf)) {
    throw ('Official VC++ 2015-2022 x86 redistributable not found. Pass ' +
        '-VcRedistX86Path explicitly.')
}
if ((Get-PeMachine $VcRedistX86Path) -ne 0x014C) {
    throw "VC++ redistributable is not x86: $VcRedistX86Path"
}
$redistExpected = ([IO.File]::ReadAllLines($mx248Manifest) |
    Where-Object { $_ -match '^[0-9a-fA-F]{64} \*VC_redist\.x86\.exe$' } |
    Select-Object -First 1).Substring(0, 64).ToLowerInvariant()
$redistActual = (Get-FileHash -Algorithm SHA256 -LiteralPath $VcRedistX86Path).Hash.ToLowerInvariant()
if ($redistActual -ne $redistExpected) {
    throw "VC++ x86 redistributable hash mismatch: $VcRedistX86Path"
}
Write-Host "VC++ x86 redistributable verified: $VcRedistX86Path"

if (-not (Test-Path -LiteralPath $dcc32 -PathType Leaf)) {
    throw "Delphi Win32 compiler not found: $dcc32"
}
Write-Host 'Building and testing PXI MX-248 x86 bridge...'
Push-Location $mx248BridgeDir
try {
    & $dcc32 -B '-E.' $mx248BridgeProject
    if ($LASTEXITCODE -ne 0) { throw "MX-248 bridge build failed: exit code $LASTEXITCODE" }
} finally { Pop-Location }
Push-Location (Join-Path $mx248BridgeDir 'Tests')
try {
    & $dcc32 -B '-E.' $mx248ProtocolTest
    if ($LASTEXITCODE -ne 0) { throw "MX-248 protocol test build failed: exit code $LASTEXITCODE" }
    Invoke-BoundedProcess $mx248ProtocolTestExe @()
    & $dcc32 -B '-E.' $mx248AbiSmoke
    if ($LASTEXITCODE -ne 0) { throw "MX-248 ABI smoke build failed: exit code $LASTEXITCODE" }
    $oldVendorDir = $env:RECORDER_MX248_VENDOR_DIR
    try {
        $env:RECORDER_MX248_VENDOR_DIR = $VendorDevApiDir
        Invoke-BoundedProcess $mx248AbiSmokeExe @()
    } finally { $env:RECORDER_MX248_VENDOR_DIR = $oldVendorDir }
} finally { Pop-Location }
if ((Get-PeMachine $mx248BridgeExe) -ne 0x014C) {
    throw "MX-248 bridge is not x86: $mx248BridgeExe"
}

Write-Host 'Building RecorderLnx...'
& $compiler -B $projectFile
if ($LASTEXITCODE -ne 0) {
    throw "RecorderLnx build failed: exit code $LASTEXITCODE"
}

Write-Host 'Building installed-layout MX-248 bridge process smoke...'
& $compiler -B $mx248ProcessSmokeProject
if ($LASTEXITCODE -ne 0) {
    throw "MX-248 process smoke build failed: exit code $LASTEXITCODE"
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

if (-not $SkipLuaHelpBuild) {
    Write-Host 'Building Lua CHM help...'
    & $luaHelpBuild
    if ($LASTEXITCODE -ne 0) {
        throw "Lua CHM help build failed: exit code $LASTEXITCODE"
    }
} else {
    Write-Host 'Using existing Lua CHM help package (-SkipLuaHelpBuild).'
}
if (-not (Test-Path -LiteralPath $luaHelpPackage)) {
    throw "Lua CHM help package not found: $luaHelpPackage"
}

Write-Host 'Collecting structured installer payload...'
& $collector $VendorDevApiDir $VcRedistX86Path
if ($LASTEXITCODE -ne 0) {
    throw "Installer payload collection failed: exit code $LASTEXITCODE"
}
$stagedBridge = Join-Path $payloadDir 'app\mx248\vendor\PxiMx248Bridge.exe'
$stagedRecorder = Join-Path $payloadDir 'app\RecorderLnx.exe'
$stagedRedist = Join-Path $payloadDir 'redist\VC_redist.x86.exe'
foreach ($stagedFile in @($stagedRecorder, $stagedBridge, $stagedRedist)) {
    if (-not (Test-Path -LiteralPath $stagedFile -PathType Leaf)) {
        throw "Required staged installer file not found: $stagedFile"
    }
}
if ((Get-PeMachine $stagedBridge) -ne 0x014C) {
    throw "Staged MX-248 bridge is not x86: $stagedBridge"
}
Write-Host 'Running installed-layout MX-248 bridge process smoke from files...'
Invoke-BoundedProcess $mx248ProcessSmokeExe @($stagedBridge)

Write-Host 'Building Windows installer...'
& $iscc "/DAppVersion=$Version" (Join-Path $installerDir 'RecorderLnx.iss')
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup build failed: exit code $LASTEXITCODE"
}

Write-Host (Join-Path $installerDir "Output\RecorderLnx-Setup-$Version.exe")
