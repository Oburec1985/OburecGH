[CmdletBinding()]
param(
    [string]$DeviceIp = '192.168.14.48',
    [int]$Port = 4000,
    [ValidateSet('original_recorder', 'recorderlnx_test', 'custom')]
    [string]$Scenario = 'original_recorder',
    [switch]$LaunchRecorder,
    [int]$DurationSec = 0
)

$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $lIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $lPrincipal = [Security.Principal.WindowsPrincipal]::new($lIdentity)
    return $lPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    $lArguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"{0}"' -f $PSCommandPath),
        '-DeviceIp', $DeviceIp,
        '-Port', $Port,
        '-Scenario', $Scenario
    )
    if ($LaunchRecorder) {
        $lArguments += '-LaunchRecorder'
    }
    if ($DurationSec -gt 0) {
        $lArguments += @('-DurationSec', $DurationSec)
    }
    Start-Process powershell.exe -Verb RunAs -ArgumentList $lArguments -Wait
    exit $LASTEXITCODE
}

$lTestRoot = Split-Path -Parent $PSScriptRoot
$lCaptureDir = Join-Path $lTestRoot 'data\captures'
New-Item -ItemType Directory -Force -Path $lCaptureDir | Out-Null

$lTimestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$lPrefix = '{0}_{1}_{2}' -f $DeviceIp, $Scenario, $lTimestamp
$lEtl = Join-Path $lCaptureDir ($lPrefix + '.etl')
$lPcap = Join-Path $lCaptureDir ($lPrefix + '.pcapng')
$lPktmonText = Join-Path $lCaptureDir ($lPrefix + '_pktmon.txt')
$lCsv = Join-Path $lCaptureDir ($lPrefix + '_packets.csv')
$lTimeline = Join-Path $lCaptureDir ($lPrefix + '_timeline.txt')
$lMeta = Join-Path $lCaptureDir ($lPrefix + '_README.md')
$lParser = Join-Path $PSScriptRoot 'parse_mic140_pcapng.py'

$lRecorderPath = 'C:\Program Files (x86)\Mera\Recorder\Recorder.exe'
$lRecorderProcess = $null
$lStarted = $false
$lStartTime = Get-Date

try {
    Write-Host '[PREPARE] Resetting pktmon filters...' -ForegroundColor Cyan
    & pktmon filter remove | Out-Null
    & pktmon filter add MIC140 -i $DeviceIp -t TCP -p $Port | Out-Null
    Write-Host "[PREPARE] Starting NIC capture for $DeviceIp`:$Port..." -ForegroundColor Cyan
    & pktmon start --capture --comp nics --pkt-size 0 --file-name $lEtl --file-size 1024 --log-mode circular
    if ($LASTEXITCODE -ne 0) {
        throw "pktmon start failed with exit code $LASTEXITCODE"
    }
    $lStarted = $true
    $lStartTime = Get-Date

    Write-Host ''
    Write-Host "Capture started: $DeviceIp`:$Port" -ForegroundColor Green
    Write-Host "Scenario: $Scenario"
    Write-Host "Output: $lPcap"

    if ($LaunchRecorder) {
        if (-not (Test-Path -LiteralPath $lRecorderPath)) {
            throw "Original Recorder was not found: $lRecorderPath"
        }
        $lRecorderProcess = Start-Process -FilePath $lRecorderPath -PassThru
        Write-Host 'Original Recorder started. Run Connect/Init/Config/Play/Stop, then close Recorder.'
    }

    if ($LaunchRecorder) {
        while (-not $lRecorderProcess.HasExited) {
            $lElapsed = [int]((Get-Date) - $lStartTime).TotalSeconds
            $lEtlState = if (Test-Path -LiteralPath $lEtl) {
                $lInfo = Get-Item -LiteralPath $lEtl
                '{0:N1} MB, write {1}' -f ($lInfo.Length / 1MB), $lInfo.LastWriteTime.ToString('HH:mm:ss')
            } else {
                'waiting for ETL'
            }
            Write-Host ("[CAPTURING] {0,5} s | Recorder PID {1} running | {2}" -f `
                $lElapsed, $lRecorderProcess.Id, $lEtlState) -ForegroundColor Green
            Start-Sleep -Seconds 1
            $lRecorderProcess.Refresh()
        }
        Write-Host '[RECORDER CLOSED] Finalizing network capture...' -ForegroundColor Yellow
    } elseif ($DurationSec -gt 0) {
        Write-Host "Capture will stop automatically in $DurationSec seconds."
        Start-Sleep -Seconds $DurationSec
    } else {
        Read-Host 'Press Enter after the required device lifecycle is complete'
    }
}
finally {
    if ($lStarted) {
        Write-Host '[STOPPING] Stopping pktmon...' -ForegroundColor Yellow
        & pktmon stop | Out-Null
    }
    & pktmon filter remove | Out-Null
}

$lStopTime = Get-Date
Write-Host '[CONVERTING] ETL -> PCAPNG...' -ForegroundColor Cyan
& pktmon etl2pcap $lEtl --out $lPcap
if ($LASTEXITCODE -ne 0) {
    throw "ETL to PCAPNG conversion failed with exit code $LASTEXITCODE"
}
Write-Host '[CONVERTING] ETL -> verbose text/hex...' -ForegroundColor Cyan
& pktmon etl2txt $lEtl --out $lPktmonText --verbose 3 --hex

$lPython = Get-Command python.exe -ErrorAction SilentlyContinue
if (-not $lPython) {
    $lPython = Get-Command py.exe -ErrorAction SilentlyContinue
}
if (-not $lPython) {
    throw 'Python was not found. PCAPNG is saved, but CSV was not generated.'
}

Write-Host '[PARSING] Building packet CSV and timeline...' -ForegroundColor Cyan
$lParserOutput = & $lPython.Source $lParser `
    --input $lPcap `
    --ip $DeviceIp `
    --port $Port `
    --csv $lCsv `
    --timeline $lTimeline
if ($LASTEXITCODE -ne 0) {
    throw "PCAPNG parser failed with exit code $LASTEXITCODE"
}
$lParserOutput | ForEach-Object { Write-Host "[PARSING] $_" }

$lRecorderVersion = 'not launched by this script'
if ($LaunchRecorder -and (Test-Path -LiteralPath $lRecorderPath)) {
    $lRecorderVersion = (Get-Item -LiteralPath $lRecorderPath).VersionInfo.FileVersion
}

$lMetaLines = @(
    '# MIC-140 reference network capture',
    '',
    "- Device: $DeviceIp, port $Port",
    '- Confirmed type: MIC-140-48v3',
    "- Scenario: $Scenario",
    "- Started: $($lStartTime.ToString('yyyy-MM-dd HH:mm:ss.fff zzz'))",
    "- Stopped: $($lStopTime.ToString('yyyy-MM-dd HH:mm:ss.fff zzz'))",
    "- Computer: $env:COMPUTERNAME",
    "- Recorder: $lRecorderVersion",
    "- Filter: IPv4 $DeviceIp, TCP $Port, NIC level",
    '',
    '## Files',
    '',
    "- $([IO.Path]::GetFileName($lPcap)) - unmodified network packets.",
    "- $([IO.Path]::GetFileName($lCsv)) - packet CSV for machine comparison.",
    "- $([IO.Path]::GetFileName($lTimeline)) - compact packet timeline.",
    "- $([IO.Path]::GetFileName($lPktmonText)) - full pktmon text and hex dump.",
    "- $([IO.Path]::GetFileName($lEtl)) - original Windows ETL.",
    '',
    'The reference must contain the complete lifecycle:',
    'Connect -> Init -> Config -> Play -> several seconds of data -> Stop -> Disconnect.'
)
Set-Content -LiteralPath $lMeta -Value $lMetaLines -Encoding UTF8

Write-Host ''
Write-Host '[DONE] Capture artifacts are ready:' -ForegroundColor Green
Write-Host $lPcap
Write-Host $lCsv
Write-Host $lTimeline
Write-Host $lMeta
