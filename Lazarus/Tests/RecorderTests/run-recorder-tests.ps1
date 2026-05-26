$ErrorActionPreference = 'Stop'

$testsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Resolve-Path (Join-Path $testsRoot '..\..')
$corePath = Join-Path $workspaceRoot 'RecorderLnx\Core'
$fpc = 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe'

if (-not (Test-Path -LiteralPath $fpc)) {
    throw "FPC not found: $fpc"
}

$testProjects = Get-ChildItem -LiteralPath $testsRoot -Recurse -Filter 'Recorder*Test.lpr' |
    Sort-Object FullName

foreach ($project in $testProjects) {
    $testDir = $project.DirectoryName
    $libDir = Join-Path $testDir 'lib'
    $programName = [IO.Path]::GetFileNameWithoutExtension($project.Name)
    $exePath = Join-Path $libDir ($programName + '.exe')

    New-Item -ItemType Directory -Force -Path $libDir | Out-Null

    Write-Host "BUILD $programName"
    & $fpc -MObjFPC "-Fu$corePath" "-FU$libDir" "-o$exePath" $project.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed: $programName"
    }

    Write-Host "RUN $programName"
    & $exePath
    if ($LASTEXITCODE -ne 0) {
        throw "Test failed: $programName"
    }
}

Write-Host 'All RecorderTests passed.'
