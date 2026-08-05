$ErrorActionPreference = 'Stop'

$testsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Resolve-Path (Join-Path $testsRoot '..\..')
$lazbuild = 'C:\lazarus\lazbuild.exe'
$sharedUtilsPath = Resolve-Path (Join-Path $workspaceRoot 'SharedUtils')
$lazutilsPath = 'C:\lazarus\components\lazutils\lib\x86_64-win64'

if (-not (Test-Path -LiteralPath $lazbuild)) {
    throw "lazbuild not found: $lazbuild"
}

$testProjects = Get-ChildItem -LiteralPath $testsRoot -Recurse -Filter 'Recorder*Test.lpi' |
    Sort-Object FullName

foreach ($project in $testProjects) {
    $testDir = $project.DirectoryName
    $libDir = Join-Path $testDir 'lib'
    $programName = [IO.Path]::GetFileNameWithoutExtension($project.Name)

    Write-Host "BUILD $programName"
    & $lazbuild -B "--opt=-Fu$sharedUtilsPath" "--opt=-Fu$lazutilsPath" $project.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed: $programName"
    }

    # Find the output executable
    $exePath = Join-Path $testDir ($programName + '.exe')
    if (-not (Test-Path -LiteralPath $exePath)) {
        $exePath = Join-Path $libDir ($programName + '.exe')
    }
    if (-not (Test-Path -LiteralPath $exePath)) {
        throw "Executable not found for project: $programName"
    }

    Write-Host "RUN $programName"
    & $exePath
    if ($LASTEXITCODE -ne 0) {
        throw "Test failed: $programName"
    }
}

Write-Host 'All RecorderTests passed.'
