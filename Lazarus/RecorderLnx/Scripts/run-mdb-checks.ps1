$ErrorActionPreference = 'Stop'

$recorderRoot = Split-Path -Parent $PSScriptRoot
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $recorderRoot)
$testRoot = Join-Path $repositoryRoot 'Lazarus\Tests\RecorderTests\Mdb'
$lazbuild = 'C:\lazarus\lazbuild.exe'

if (-not (Test-Path -LiteralPath $lazbuild)) {
  throw "lazbuild not found: $lazbuild"
}

& $lazbuild --build-all --no-write-project (Join-Path $testRoot 'RecorderMdbTest.lpi')
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& (Join-Path $testRoot 'lib\RecorderMdbTest.exe')
exit $LASTEXITCODE
