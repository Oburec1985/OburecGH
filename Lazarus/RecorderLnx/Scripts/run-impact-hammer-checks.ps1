param(
  [string]$LazBuild = 'C:\lazarus\lazbuild.exe',
  [switch]$SkipRecorderBuild
)

$ErrorActionPreference = 'Stop'
$recorderRoot = Split-Path -Parent $PSScriptRoot
$lazarusRoot = Split-Path -Parent $recorderRoot
$testsRoot = Join-Path $lazarusRoot 'Tests\RecorderTests'
$logRoot = Join-Path $recorderRoot 'cach\impact-hammer-checks'

$checks = @(
  @{ Name = 'ImpactHammer'; Project = 'ImpactHammer\ImpactHammerTest.lpi' },
  @{ Name = 'ImpactHammerService'; Project = 'ImpactHammerService\ImpactHammerServiceTest.lpi' },
  @{ Name = 'ImpactHammerUiSmoke'; Project = 'ImpactHammerUiSmoke\ImpactHammerUiSmoke.lpi' },
  @{ Name = 'ImpactSession'; Project = 'ImpactSession\ImpactSessionTest.lpi' },
  @{ Name = 'CoreServices'; Project = 'CoreServices\RecorderCoreServicesTest.lpi' }
)

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

New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

foreach ($check in $checks) {
  $projectPath = Join-Path $testsRoot $check.Project
  $projectDir = Split-Path -Parent $projectPath
  $buildLog = Join-Path $logRoot ($check.Name + '-build.log')
  $runLog = Join-Path $logRoot ($check.Name + '-run.log')

  Write-Host "[BUILD] $($check.Name)"
  Invoke-CheckedProcess $LazBuild @('-B', $projectPath) $buildLog

  $executable = Get-ChildItem -LiteralPath $projectDir -Filter '*.exe' -Recurse |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if ($null -eq $executable) {
    throw "Executable was not produced for $($check.Name)"
  }

  Write-Host "[RUN]   $($check.Name)"
  Invoke-CheckedProcess $executable.FullName @() $runLog
}

if (-not $SkipRecorderBuild) {
  $recorderLog = Join-Path $logRoot 'RecorderLnx-build.log'
  Write-Host '[BUILD] RecorderLnx'
  try {
    Invoke-CheckedProcess $LazBuild @('-B', (Join-Path $recorderRoot 'RecorderLnx.lpi')) $recorderLog
  }
  catch {
    if (Get-Process -Name 'RecorderLnx' -ErrorAction SilentlyContinue) {
      throw "RecorderLnx build reached a locked target. Close the running RecorderLnx.exe and rerun. See $recorderLog"
    }
    throw
  }
}

Write-Host '[PASS] Impact Hammer verification completed.'
