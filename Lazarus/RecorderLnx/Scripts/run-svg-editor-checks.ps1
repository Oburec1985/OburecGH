param(
  [string]$LazBuild = 'C:\lazarus\lazbuild.exe'
)

$ErrorActionPreference = 'Stop'
$recorderRoot = Split-Path -Parent $PSScriptRoot
$lazarusRoot = Split-Path -Parent $recorderRoot
$testRoot = Join-Path $lazarusRoot 'Tests\RecorderTests\SvgParameters'
$projectPath = Join-Path $testRoot 'SvgParametersTest.lpi'
$artifactRoot = Join-Path $recorderRoot 'cach\svg-editor-checks'
$buildLog = Join-Path $artifactRoot 'build.log'
$runLog = Join-Path $artifactRoot 'run.log'
$renderArtifact = Join-Path $artifactRoot 'parametric-dual-gauge.png'
$uiTestRoot = Join-Path $lazarusRoot 'Tests\RecorderTests\SvgImageSettingsUiSmoke'
$uiProjectPath = Join-Path $uiTestRoot 'SvgImageSettingsUiSmoke.lpi'
$uiBuildLog = Join-Path $artifactRoot 'ui-build.log'
$uiRunLog = Join-Path $artifactRoot 'ui-run.log'

function Invoke-CheckedProcess {
  param(
    [string]$FilePath,
    [string[]]$Arguments,
    [string]$LogPath
  )

  & $FilePath @Arguments 2>&1 | Tee-Object -FilePath $LogPath
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code $LASTEXITCODE. See $LogPath"
  }
}

if (-not (Test-Path -LiteralPath $LazBuild -PathType Leaf)) {
  throw "lazbuild not found: $LazBuild"
}

New-Item -ItemType Directory -Force -Path $artifactRoot | Out-Null

Write-Host '[BUILD] SVG parameter editor checks'
Invoke-CheckedProcess $LazBuild @('-B', $projectPath) $buildLog

$executable = Get-ChildItem -LiteralPath $testRoot -Filter 'SvgParametersTest.exe' -Recurse |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1
if ($null -eq $executable) {
  throw 'SvgParametersTest executable was not produced.'
}

Write-Host '[RUN]   SVG parameter editor checks'
Invoke-CheckedProcess $executable.FullName @() $runLog

$generatedRender = [IO.Path]::ChangeExtension($executable.FullName, '.gauge.png')
if (-not (Test-Path -LiteralPath $generatedRender -PathType Leaf)) {
  throw "Renderer did not produce the acceptance image: $generatedRender"
}
Copy-Item -LiteralPath $generatedRender -Destination $renderArtifact -Force

Write-Host "[RENDER] $renderArtifact"

Write-Host '[BUILD] SVG settings UI smoke'
Invoke-CheckedProcess $LazBuild @('-B', $uiProjectPath) $uiBuildLog
$uiExecutable = Get-ChildItem -LiteralPath $uiTestRoot -Filter 'SvgImageSettingsUiSmoke.exe' -Recurse |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1
if ($null -eq $uiExecutable) {
  throw 'SvgImageSettingsUiSmoke executable was not produced.'
}

Write-Host '[RUN]   SVG settings UI smoke'
Invoke-CheckedProcess $uiExecutable.FullName @() $uiRunLog
Write-Host '[PASS] SVG parameter editor checks completed.'
