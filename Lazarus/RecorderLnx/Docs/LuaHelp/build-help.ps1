$ErrorActionPreference = 'Stop'
$helpDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = (Resolve-Path (Join-Path $helpDir '..\..')).Path
$generator = Join-Path $helpDir 'build_lua_help.py'
$compiler = 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\chmcmd.exe'
$project = Join-Path $helpDir 'src\RecorderLnxLua.hhp'
$output = Join-Path $helpDir 'RecorderLnxLua.chm'
$stageDir = Join-Path $projectRoot 'lib\x86_64-win64\help'

if (-not (Test-Path -LiteralPath $compiler)) {
    throw "CHM compiler not found: $compiler"
}

python $generator
if ($LASTEXITCODE -ne 0) {
    throw "Lua help source generation failed: exit code $LASTEXITCODE"
}

Push-Location (Split-Path -Parent $project)
try {
    & $compiler $project
    if ($LASTEXITCODE -ne 0) {
        throw "Lua CHM build failed: exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path -LiteralPath $output)) {
    throw "Lua CHM output not found: $output"
}
New-Item -ItemType Directory -Force -Path $stageDir | Out-Null
Copy-Item -LiteralPath $output -Destination (Join-Path $stageDir 'RecorderLnxLua.chm') -Force
Write-Host (Join-Path $stageDir 'RecorderLnxLua.chm')
