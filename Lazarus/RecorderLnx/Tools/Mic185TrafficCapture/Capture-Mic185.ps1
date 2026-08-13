[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DeviceIp,
    [int]$Port = 4000,
    [ValidateSet('auto', 'recorderlnx', 'original', 'custom')]
    [string]$Client = 'auto',
    [string]$RunName = '',
    [int]$DurationSec = 0,
    [switch]$Probe,
    [switch]$NoElevate
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Read-ProcessNames([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Warning "Config not found: $Path. Using RecorderLnx and Recorder."
        return @('RecorderLnx', 'Recorder')
    }

    $section = ''
    foreach ($line in Get-Content -LiteralPath $Path) {
        $text = $line.Trim()
        if (-not $text -or $text.StartsWith(';') -or $text.StartsWith('#')) { continue }
        if ($text -match '^\[(.+)\]$') {
            $section = $Matches[1]
            continue
        }
        if (($section -ieq 'Clients') -and ($text -match '^ProcessNames\s*=\s*(.+)$')) {
            $names = @($Matches[1].Split(',') | ForEach-Object {
                $_.Trim() -replace '(?i)\.exe$', ''
            } | Where-Object { $_ })
            if ($names.Count -gt 0) { return $names }
        }
    }
    throw "[Clients] ProcessNames is missing in $Path"
}

$config = Join-Path $root 'Mic185TrafficCapture.ini'
$script:ProcessNames = @(Read-ProcessNames $config)

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = [Security.Principal.WindowsPrincipal]::new($id)
    $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-Mark([string]$Stage, [string]$Text) {
    $now = Get-Date
    $ms = [math]::Round(($now - $script:Started).TotalMilliseconds, 3)
    ('{0:O},{1},{2},"{3}"' -f $now, $ms, $Stage, $Text.Replace('"', '""')) |
        Add-Content -LiteralPath $script:Marks -Encoding UTF8
    Write-Host ("[MARK {0,8:N0} ms] {1}: {2}" -f $ms, $Stage, $Text) -ForegroundColor Yellow
}

function Get-ClientLabel([Diagnostics.Process]$Process) {
    return $Process.ProcessName.ToLowerInvariant()
}

function Find-ClientProcess {
    $processes = @(Get-Process -Name $script:ProcessNames -ErrorAction SilentlyContinue)
    if ($processes.Count -eq 0) { return $null }

    $links = Get-NetTCPConnection -RemoteAddress $DeviceIp -RemotePort $Port `
        -State Established -ErrorAction SilentlyContinue
    $owners = @($links | ForEach-Object { $_.OwningProcess })
    $linked = @($processes | Where-Object { $owners -contains $_.Id } |
        Sort-Object StartTime -Descending)
    if ($linked.Count -gt 0) { return $linked[0] }

    if ($processes.Count -eq 1) { return $processes[0] }

    $started = @($processes | Where-Object {
        $_.StartTime -ge $script:Started.AddSeconds(-2)
    } | Sort-Object StartTime -Descending)
    if ($started.Count -gt 0) {
        return $started[0]
    }
    return $null
}

if (-not (Test-Admin) -and -not $NoElevate) {
    $args2 = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath),
        '-DeviceIp', $DeviceIp, '-Port', $Port, '-Client', $Client)
    if ($RunName) { $args2 += @('-RunName', $RunName) }
    if ($DurationSec -gt 0) { $args2 += @('-DurationSec', $DurationSec) }
    if ($Probe) { $args2 += '-Probe' }
    $p = Start-Process powershell.exe -Verb RunAs -ArgumentList $args2 -PassThru -Wait
    exit $p.ExitCode
}
if (-not (Test-Admin)) {
    Write-Error 'Administrator rights are required. Run Start-Capture.bat.'
    exit 5
}

$captures = Join-Path $root 'captures'
New-Item -ItemType Directory -Force -Path $captures | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$safeRun = if ($RunName) { $RunName -replace '[^A-Za-z0-9_.-]', '_' } else { 'run' }
$prefix = '{0}_{1}_{2}_{3}' -f $DeviceIp, $Client, $safeRun, $stamp
$out = Join-Path $captures $prefix
New-Item -ItemType Directory -Path $out | Out-Null
$etl = Join-Path $out ($prefix + '.etl')
$pcap = Join-Path $out ($prefix + '.pcapng')
$txt = Join-Path $out ($prefix + '_pktmon.txt')
$csv = Join-Path $out ($prefix + '_packets.csv')
$timeline = Join-Path $out ($prefix + '_timeline.txt')
$events = Join-Path $out ($prefix + '_events.csv')
$autoReport = Join-Path $out ($prefix + '_lifecycle.md')
$meta = Join-Path $out ($prefix + '_README.md')
$route = Join-Path $out ($prefix + '_route.txt')
$runLog = Join-Path $out ($prefix + '_capture.log')
$script:Marks = Join-Path $out ($prefix + '_marks.csv')
$parser = Join-Path $root 'parse_mic185_pcapng.py'
$analyzer = Join-Path $root 'analyze_mic185_capture.py'
$startedCapture = $false
$script:Started = Get-Date
$detectedClient = $Client
$clientProcess = $null
$pktmon = Join-Path $env:SystemRoot 'System32\PktMon.exe'
if (-not (Test-Path -LiteralPath $pktmon)) {
    $pktmon = Join-Path $env:SystemRoot 'Sysnative\PktMon.exe'
}
if (-not (Test-Path -LiteralPath $pktmon)) {
    throw "PktMon.exe was not found. This Windows version does not include the required packet monitor."
}
$transcriptStarted = $false
try {
    Start-Transcript -LiteralPath $runLog -Force | Out-Null
    $transcriptStarted = $true
} catch {
    "Transcript start failed: $($_.Exception.Message)" | Set-Content -LiteralPath $runLog -Encoding UTF8
}

function Run-Pktmon([string[]]$Arguments, [string]$Step) {
    Write-Host "[PKTMON] $Step" -ForegroundColor Cyan
    Write-Host "pktmon $($Arguments -join ' ')"
    $text = (& $script:pktmon @Arguments 2>&1 | Out-String)
    $code = $LASTEXITCODE
    if ($text) { Write-Host $text.TrimEnd() }
    Write-Host "Exit code: $code"
    if ($code -ne 0) { throw "$Step failed (exit $code): $text" }
}

function Clear-Pktmon {
    & $env:ComSpec /d /c ('"{0}" stop >nul 2>&1' -f $script:pktmon)
    & $env:ComSpec /d /c ('"{0}" filter remove >nul 2>&1' -f $script:pktmon)
}

function Remove-PktmonFilter {
    & $env:ComSpec /d /c ('"{0}" filter remove >nul 2>&1' -f $script:pktmon)
}

function Send-Probe {
    Write-Host "[PROBE] Opening TCP $DeviceIp`:$Port..." -ForegroundColor Cyan
    $tcp = [Net.Sockets.TcpClient]::new()
    try {
        $wait = $tcp.BeginConnect($DeviceIp, $Port, $null, $null)
        if (-not $wait.AsyncWaitHandle.WaitOne(2000)) { throw 'TCP connect timeout' }
        $tcp.EndConnect($wait)
        Write-Host '[PROBE] Connected; closing test connection.' -ForegroundColor Green
    } finally {
        $tcp.Close()
    }
}

'time,relative_ms,stage,note' | Set-Content -LiteralPath $script:Marks -Encoding UTF8
@(
    "Device: $DeviceIp`:$Port",
    "Computer: $env:COMPUTERNAME",
    "Captured: $((Get-Date).ToString('O'))",
    '',
    '=== Windows route selected for the device ==='
) | Set-Content -LiteralPath $route -Encoding UTF8
try {
    Find-NetRoute -RemoteIPAddress $DeviceIp -ErrorAction Stop |
        Format-List * | Out-String | Add-Content -LiteralPath $route -Encoding UTF8
} catch {
    "Find-NetRoute failed: $($_.Exception.Message)" | Add-Content -LiteralPath $route -Encoding UTF8
}
'=== Network adapters and addresses ===' | Add-Content -LiteralPath $route -Encoding UTF8
try {
    Get-NetIPConfiguration -ErrorAction Stop |
        Format-List InterfaceAlias,InterfaceIndex,IPv4Address,IPv4DefaultGateway |
        Out-String | Add-Content -LiteralPath $route -Encoding UTF8
} catch {
    "Get-NetIPConfiguration failed: $($_.Exception.Message)" |
        Add-Content -LiteralPath $route -Encoding UTF8
}
try {
    Write-Host '[PREPARE] Removing old pktmon filters...' -ForegroundColor Cyan
    Clear-Pktmon
    Run-Pktmon -Arguments @('filter', 'add', 'MIC185', '-i', $DeviceIp, '-t', 'TCP', '-p', "$Port") -Step 'Add filter'
    Run-Pktmon -Arguments @('filter', 'list') -Step 'Verify filter'
    Write-Host "[START] Capturing only $DeviceIp`:$Port" -ForegroundColor Cyan
    Run-Pktmon -Arguments @('start', '--capture', '--comp', 'nics', '--pkt-size', '0', '--file-name', $etl,
        '--file-size', '1024', '--log-mode', 'circular') -Step 'Start capture'
    $startedCapture = $true
    $script:Started = Get-Date
    Add-Mark 'capture' 'capture started'
    if ($Probe) {
        Start-Sleep -Milliseconds 300
        Send-Probe
    }

    Write-Host ''
    Write-Host "Client process names: $($script:ProcessNames -join ', ')" -ForegroundColor Cyan
    Write-Host 'Waiting for a configured client. Capture will finish when that process exits.' -ForegroundColor Green
    while ($true) {
        $elapsed = [int]((Get-Date) - $script:Started).TotalSeconds
        if ($DurationSec -gt 0 -and $elapsed -ge $DurationSec) { break }
        if (-not $clientProcess) {
            $clientProcess = Find-ClientProcess
            if ($clientProcess) {
                $detectedClient = Get-ClientLabel $clientProcess
                Add-Mark 'client' "$detectedClient; pid=$($clientProcess.Id); exe=$($clientProcess.Path)"
                Write-Host "[CLIENT] $detectedClient, PID $($clientProcess.Id)" -ForegroundColor Green
            }
        } elseif (-not (Get-Process -Id $clientProcess.Id -ErrorAction SilentlyContinue)) {
            Add-Mark 'finish' "$detectedClient process exited"
            Write-Host "[CLIENT] $detectedClient exited; finalizing capture." -ForegroundColor Green
            break
        }
        Start-Sleep -Milliseconds 200
        if (($elapsed % 5) -eq 0) {
            $size = if (Test-Path $etl) { '{0:N1} MB' -f ((Get-Item $etl).Length / 1MB) } else { 'waiting' }
            $state = if ($clientProcess) { "$detectedClient PID $($clientProcess.Id)" } else { 'waiting for client' }
            Write-Progress -Activity "MIC-185 $DeviceIp capture" -Status "$elapsed s; $state; $size"
        }
    }
}
finally {
    Write-Progress -Activity "MIC-185 $DeviceIp capture" -Completed
    if ($startedCapture) {
        try { Run-Pktmon -Arguments @('stop') -Step 'Stop capture' } catch { Write-Warning $_ }
    }
    Remove-PktmonFilter
}

$stopped = Get-Date
Write-Host '[CONVERT] ETL -> PCAPNG and text/hex...' -ForegroundColor Cyan
& $pktmon etl2pcap $etl --out $pcap
if ($LASTEXITCODE -ne 0) { throw "etl2pcap failed: $LASTEXITCODE" }
& $pktmon etl2txt $etl --out $txt --verbose 3 --hex

$python = Get-Command python.exe -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py.exe -ErrorAction SilentlyContinue }
if ($python) {
    Write-Host '[PARSE] Creating decoded CSV and timeline...' -ForegroundColor Cyan
    & $python.Source $parser --input $pcap --ip $DeviceIp --port $Port --csv $csv --timeline $timeline
    if ($LASTEXITCODE -ne 0) { Write-Warning 'Parser failed; raw capture is still valid.' }
    else {
        Write-Host '[DECODE] Reassembling TCP and decoding MIC-185 lifecycle...' -ForegroundColor Cyan
        & $python.Source $analyzer --packets $csv --events $events --report $autoReport
        if ($LASTEXITCODE -ne 0) { Write-Warning 'Lifecycle decoder failed; packet CSV is still valid.' }
    }
} else {
    Write-Warning 'Python not found. Raw ETL, PCAPNG and hex text were saved; parse them later on another PC.'
}

@(
    '# MIC-185 traffic capture', '',
    "- Device: $DeviceIp`:$Port", "- Client: $detectedClient", "- Run: $safeRun",
    "- Start: $($script:Started.ToString('O'))", "- Stop: $($stopped.ToString('O'))",
    "- Filter: IPv4 $DeviceIp, TCP $Port, NIC level", "- Computer: $env:COMPUTERNAME", '',
    '## Scenario marks', '', "See `$([IO.Path]::GetFileName($script:Marks))`.", '',
    '## Artifacts', '',
    "- `$([IO.Path]::GetFileName($etl))` - original Windows ETL.",
    "- `$([IO.Path]::GetFileName($pcap))` - portable raw packets.",
    "- `$([IO.Path]::GetFileName($txt))` - full pktmon hex text.",
    "- `$([IO.Path]::GetFileName($csv))` - decoded packets when Python is available.",
    "- `$([IO.Path]::GetFileName($timeline))` - decoded lifecycle timeline when Python is available."
    "- `$([IO.Path]::GetFileName($events))` - automatically decoded MIC-185 events."
    "- `$([IO.Path]::GetFileName($autoReport))` - ordered init/reset/start/data/service/stop report."
    "- `$([IO.Path]::GetFileName($route))` - Windows route and NIC selected for the device."
    "- `$([IO.Path]::GetFileName($runLog))` - complete capture command/error log."
) | Set-Content -LiteralPath $meta -Encoding UTF8

Write-Host '[DONE]' -ForegroundColor Green
Write-Host "Capture directory: $out"
Write-Host $pcap
Write-Host $script:Marks
Write-Host $meta
if ($transcriptStarted) { Stop-Transcript | Out-Null }
