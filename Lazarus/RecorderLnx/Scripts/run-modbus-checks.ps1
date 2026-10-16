param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$lazarusRoot = 'C:\lazarus'
$lazbuild = Join-Path $lazarusRoot 'lazbuild.exe'
$fpc = Join-Path $lazarusRoot 'fpc\3.2.2\bin\x86_64-win64\fpc.exe'
$log = Join-Path $projectRoot 'modbus-checks.log'

function Invoke-Checked([string]$Label, [scriptblock]$Action) {
  "=== $Label ===" | Tee-Object -FilePath $log -Append
  & $Action 2>&1 | Tee-Object -FilePath $log -Append
  if ($LASTEXITCODE -ne 0) { throw "$Label failed with exit code $LASTEXITCODE" }
}

Set-Content -LiteralPath $log -Value "RecorderLnx Modbus checks $(Get-Date -Format o)"

$coreProject = Join-Path $projectRoot '..\Tests\RecorderTests\Modbus\ModbusCoreTest.lpi'
Invoke-Checked 'Core forced build' { & $lazbuild -B $coreProject }
$coreExe = Join-Path $projectRoot '..\Tests\RecorderTests\Modbus\lib\x86_64-win64\ModbusCoreTest.exe'
Invoke-Checked 'Core tests' { & $coreExe }

$runtimeDir = Join-Path $projectRoot 'Device\Modbus\Runtime\Tests'
$coreUnits = Join-Path $projectRoot 'Device\Modbus\Core'
$runtimeUnits = Join-Path $projectRoot 'Device\Modbus\Runtime'
Invoke-Checked 'Runtime forced build' {
  Push-Location $runtimeDir
  try { & $fpc -B "-Fu$coreUnits" "-Fu$runtimeUnits" ModbusRuntimeTests.lpr }
  finally { Pop-Location }
}
Invoke-Checked 'Runtime fake TCP/RTU tests' {
  & (Join-Path $runtimeDir 'ModbusRuntimeTests.exe')
}

$uiProject = Join-Path $projectRoot 'Device\Modbus\UI\Tests\ModbusEditorSmoke.lpi'
Invoke-Checked 'UI smoke forced build' { & $lazbuild -B $uiProject }
$uiExe = Join-Path $projectRoot 'Device\Modbus\UI\Tests\lib\x86_64-win64\ModbusEditorSmoke.exe'
Invoke-Checked 'UI smoke' { & $uiExe }

# The normal application may be open and lock RecorderLnx.exe.  The alternate
# output name still performs a complete forced compile and link.
Push-Location $projectRoot
try {
  Invoke-Checked 'RecorderLnx forced build' {
    & $lazbuild -B '--opt=-omodbus-recorderlnx-verify.exe' 'RecorderLnx.lpi'
  }
}
finally { Pop-Location }

"RESULT all Modbus checks passed" | Tee-Object -FilePath $log -Append
