param(
  [string]$LazbuildPath = 'C:\lazarus\lazbuild.exe',
  [string]$GuiConfig = ''
)

$ErrorActionPreference = 'Stop'

function Invoke-BoundedSmoke([string]$Exe, [string]$Library = '', [string]$Config = '') {
  $stdout = "$Exe.stdout.log"
  $stderr = "$Exe.stderr.log"
  $start = @{ FilePath=$Exe; WindowStyle='Hidden'; RedirectStandardOutput=$stdout;
    RedirectStandardError=$stderr; PassThru=$true }
  if ($Library -ne '') { $start.ArgumentList = '"' + $Library + '"' }
  if ($Config -ne '') { $start.ArgumentList += ' "' + $Config + '"' }
  $process = Start-Process @start
  # Cache the process handle before a fast GUI smoke exits; Windows PowerShell
  # otherwise may return a null ExitCode even after a successful WaitForExit.
  $null = $process.Handle
  if (-not $process.WaitForExit(30000)) {
    $process.Kill()
    $process.WaitForExit()
    throw "Smoke timeout: $Exe; logs: $stdout, $stderr"
  }
  Get-Content -LiteralPath $stdout
  Get-Content -LiteralPath $stderr
  $process.Refresh()
  if ($null -eq $process.ExitCode) { throw "Smoke exit status unavailable: $Exe" }
  if ($process.ExitCode -ne 0) { throw "Smoke failed ($($process.ExitCode)): $Exe" }
}

if (-not (Test-Path -LiteralPath $LazbuildPath)) {
  throw "lazbuild not found: $LazbuildPath"
}

$testDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$projects = @(
  'StatefulVisualProbePlugin.lpi',
  'VisualComponentAbiV2StateRoundTrip.lpi',
  'VisualComponentAbiV2Probe.lpi'
)

foreach ($project in $projects) {
  & $LazbuildPath -B (Join-Path $testDirectory $project)
  if ($LASTEXITCODE -ne 0) {
    throw "Build failed ($LASTEXITCODE): $project"
  }
}

$outputDirectory = Join-Path $testDirectory 'lib/x86_64-win64'
& (Join-Path $outputDirectory 'VisualComponentAbiV2Probe.exe')
if ($LASTEXITCODE -ne 0) {
  throw "ABI layout probe failed ($LASTEXITCODE)"
}

& (Join-Path $outputDirectory 'VisualComponentAbiV2StateRoundTrip.exe') `
  (Join-Path $outputDirectory 'StatefulVisualProbePlugin.dll')
if ($LASTEXITCODE -ne 0) {
  throw "State round-trip probe failed ($LASTEXITCODE)"
}

$recorderRoot = (Resolve-Path (Join-Path $testDirectory '..\..\..\..')).Path
$runtimeTestProject = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\PluginVisualModelTest.lpi'
& $LazbuildPath -B $runtimeTestProject
if ($LASTEXITCODE -ne 0) {
  throw "Runtime host test build failed ($LASTEXITCODE)"
}
$runtimeTestExe = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\lib\plugin-visual-model-test\PluginVisualModelTest.exe'
Invoke-BoundedSmoke $runtimeTestExe (Join-Path $outputDirectory 'StatefulVisualProbePlugin.dll')

$aliasProject = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\AliasDiscoverySmoke.lpi'
& $LazbuildPath -B $aliasProject
if ($LASTEXITCODE -ne 0) { throw "Alias discovery test build failed ($LASTEXITCODE)" }
$aliasExe = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\lib\alias-discovery-smoke\AliasDiscoverySmoke.exe'
Invoke-BoundedSmoke $aliasExe (Join-Path $outputDirectory 'StatefulVisualProbePlugin.dll')

$editorProject = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\PluginEditorStateSmoke.lpi'
& $LazbuildPath -B $editorProject
if ($LASTEXITCODE -ne 0) { throw "Plugin editor state test build failed ($LASTEXITCODE)" }
$editorExe = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\lib\plugin-editor-state-smoke\PluginEditorStateSmoke.exe'
Invoke-BoundedSmoke $editorExe (Join-Path $outputDirectory 'StatefulVisualProbePlugin.dll')

$productionRoot = Join-Path $recorderRoot 'Plugins\SampleInfoPlugin'
$productionOutput = Join-Path $productionRoot '_buildverify_v2'
New-Item -ItemType Directory -Force (Join-Path $productionOutput 'units') | Out-Null
& $LazbuildPath -B (Join-Path $productionRoot 'SampleInfoPlugin.lpi') `
  "--opt=-FU$productionOutput\units -FE$productionOutput"
if ($LASTEXITCODE -ne 0) { throw "Production plugin build failed ($LASTEXITCODE)" }
$pluginProbeProject = Join-Path $productionRoot 'Tests\SamplePluginProbe.lpi'
& $LazbuildPath -B $pluginProbeProject
if ($LASTEXITCODE -ne 0) { throw "Production descriptor probe build failed ($LASTEXITCODE)" }
Invoke-BoundedSmoke (Join-Path $productionRoot 'Tests\lib\x86_64-win64\SamplePluginProbe.exe') `
  (Join-Path $productionOutput 'SampleInfoPlugin.dll')
$productionTestProject = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\OscillogramRuntimeSmoke.lpi'
& $LazbuildPath -B $productionTestProject
if ($LASTEXITCODE -ne 0) { throw "Production runtime test build failed ($LASTEXITCODE)" }
$productionTestExe = Join-Path $recorderRoot '..\Tests\RecorderTests\FormModel\lib\oscillogram-runtime-smoke\OscillogramRuntimeSmoke.exe'
Invoke-BoundedSmoke $productionTestExe (Join-Path $productionOutput 'SampleInfoPlugin.dll') $GuiConfig

$componentSmokes = @(
  @{ Project='oscillogram\editor\OscSettingsSmoke.lpi'; Exe='oscillogram\editor\OscSettingsSmoke.exe' },
  @{ Project='oscillogram\view\OscViewSmoke.lpi'; Exe='oscillogram\view\lib\OscViewSmoke.exe' },
  @{ Project='oscillogram\view\BaseFormSmoke.lpi'; Exe='oscillogram\view\lib\BaseFormSmoke.exe' }
)
foreach ($smoke in $componentSmokes) {
  & $LazbuildPath -B (Join-Path $productionRoot $smoke.Project)
  if ($LASTEXITCODE -ne 0) { throw "Plugin-local smoke build failed: $($smoke.Project)" }
  Invoke-BoundedSmoke (Join-Path $productionRoot $smoke.Exe)
}
