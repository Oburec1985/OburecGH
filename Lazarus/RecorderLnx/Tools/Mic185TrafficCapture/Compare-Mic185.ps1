[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ReferenceCsv,
    [Parameter(Mandatory = $true)][string]$ActualCsv,
    [string]$OutFile = ''
)

$ErrorActionPreference = 'Stop'
if (-not $OutFile) {
    $OutFile = Join-Path $PSScriptRoot ('captures\compare_{0}.md' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}
$python = Get-Command python.exe -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py.exe -ErrorAction SilentlyContinue }
if (-not $python) { throw 'Python is required only for comparison. Copy captures to a PC with Python.' }
$tmp = Join-Path $env:TEMP ('mic185_compare_' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
$refEvents = Join-Path $tmp 'reference_events.csv'
$actEvents = Join-Path $tmp 'actual_events.csv'
try {
    & $python.Source (Join-Path $PSScriptRoot 'analyze_mic185_capture.py') `
        --packets $ReferenceCsv --events $refEvents --report (Join-Path $tmp 'reference.md')
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $python.Source (Join-Path $PSScriptRoot 'analyze_mic185_capture.py') `
        --packets $ActualCsv --events $actEvents --report (Join-Path $tmp 'actual.md')
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $python.Source (Join-Path $PSScriptRoot 'compare_mic185_events.py') `
        --reference $refEvents --actual $actEvents --out $OutFile
} finally {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
}
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Report: $OutFile" -ForegroundColor Green
