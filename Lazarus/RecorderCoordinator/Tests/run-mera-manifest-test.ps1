$ErrorActionPreference = 'Stop'
$testRoot = $PSScriptRoot
$workingApps = @('C:\Mera Files\RecorderLnx\app.ini',
    'D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64\app.ini')
$before = @{}
foreach ($app in $workingApps) {
    $before[$app] = if (Test-Path -LiteralPath $app) {
        (Get-FileHash -LiteralPath $app -Algorithm SHA256).Hash
    } else { 'absent' }
}
$fixture = Join-Path $env:TEMP ('MeraManifestApp-' + [guid]::NewGuid().ToString('N'))
$cfg = Join-Path $fixture 'app.ini'
$testExit = 1
try {
    $process = Start-Process -FilePath (Join-Path $testRoot 'lib\manifest208\MeraPackageManifestTest.exe') `
        -ArgumentList ('/cfg:' + $cfg) -PassThru -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $testRoot 'manifest-run-win.log') `
        -RedirectStandardError (Join-Path $testRoot 'manifest-run-win-err.log')
    if (-not $process.WaitForExit(30000)) {
        Stop-Process -Id $process.Id -Force
        throw 'Manifest fixture timeout'
    }
    $process.Refresh()
    $testExit = $process.ExitCode
    Get-Content (Join-Path $testRoot 'manifest-run-win.log')
    Write-Output ('fixture=' + $fixture)
} finally {
    $results = foreach ($app in $workingApps) {
        $after = if (Test-Path -LiteralPath $app) {
            (Get-FileHash -LiteralPath $app -Algorithm SHA256).Hash
        } else { 'absent' }
        [pscustomobject]@{ Path=$app; Before=$before[$app]; After=$after; Unchanged=($before[$app] -eq $after) }
    }
    $results | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $testRoot 'manifest-fingerprints-win.json')
    if (@($results | Where-Object { -not $_.Unchanged }).Count -gt 0) {
        throw 'Working application INI changed during an isolated manifest fixture'
    }
}
exit $testExit
