param(
    [switch]$DryRun,
    [switch]$Help,
    [string]$OutputDirectory = $PSScriptRoot
)

# One-shot MIC315 audio endpoint service repair. No drivers, registry or PXI changes.
$ErrorActionPreference = 'Stop'
Write-Output 'Audio repair retired: the device recovered using the correct RDP profile. No changes made.'
exit 0
if ($Help) {
    Write-Output 'Repair-Mic315AudioEndpoints.ps1 [-DryRun] [-OutputDirectory directory]'
    Write-Output 'Real mode requires MIC315/MIC-315 and administrator approval; restarts audio services once.'
    exit 0
}
$nativePowerShell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $nativePowerShell = Join-Path $env:SystemRoot 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
}
if ($env:COMPUTERNAME -notin @('MIC315', 'MIC-315')) {
    Write-Error 'Refusing audio repair: computer must be MIC315 or MIC-315.'
    exit 1
}
if (@(Get-Process -Name 'RecorderLnx*' -ErrorAction SilentlyContinue).Count -gt 0) {
    Write-Error 'Refusing audio repair while RecorderLnx is running. No processes were stopped.'
    exit 1
}
if ($DryRun) {
    Write-Output "DRY-RUN Host=$env:COMPUTERNAME ProcessBits=$([IntPtr]::Size * 8)"
    Write-Output "NativePowerShell=$nativePowerShell"
    Write-Output 'Plan: hostname guard; elevate if needed; diagnostics before; restart audio stack once with bounded waits; restore initially running services; diagnostics after.'
    Write-Output 'No files or services changed.'
    exit 0
}
$logPath = Join-Path $OutputDirectory ("Mic315-audio-repair-{0}-{1}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss-fff'), $PID)
$script:repairLogFailed = $false
function Write-RepairLog([string]$Message) {
    $line = '{0:o} {1}' -f (Get-Date), $Message
    try { Add-Content -LiteralPath $logPath -Value $line -Encoding UTF8 -ErrorAction Stop }
    catch {
        $script:repairLogFailed = $true
        try { Write-Warning 'Repair log write failed; service restoration will still be attempted.' -WarningAction Continue } catch { }
    }
    try { Write-Output $line } catch { }
}
function Set-AudioServiceState([string]$Name, [bool]$Running) {
    $controller = [ServiceProcess.ServiceController]::new($Name)
    try {
        $targetState = [ServiceProcess.ServiceControllerStatus]::Stopped
        if ($Running) { $targetState = [ServiceProcess.ServiceControllerStatus]::Running }
        $controller.Refresh()
        if ($controller.Status -eq $targetState) { return }
        if ($Running) { $controller.Start() } else { $controller.Stop() }
        $controller.WaitForStatus($targetState, [TimeSpan]::FromSeconds(10))
        Write-RepairLog "stage=service-transition Name=$Name Status=$targetState"
    } finally {
        $controller.Dispose()
    }
}
try {
    Write-RepairLog "stage=preflight Host=$env:COMPUTERNAME ProcessBits=$([IntPtr]::Size * 8)"
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin -or ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess)) {
        Write-RepairLog 'stage=elevation Request native PowerShell; UAC approval may be required.'
        $scriptLiteral = $PSCommandPath.Replace("'", "''")
        $outputLiteral = $OutputDirectory.Replace("'", "''")
        $command = "& '$scriptLiteral' -OutputDirectory '$outputLiteral'"
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
        $startOptions = @{
            FilePath = $nativePowerShell
            ArgumentList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encoded)
            WindowStyle = 'Hidden'
            Wait = $true
            PassThru = $true
        }
        if (-not $isAdmin) { $startOptions.Verb = 'RunAs' }
        $child = Start-Process @startOptions
        Write-RepairLog "stage=elevation ChildExitCode=$($child.ExitCode)"
        exit $child.ExitCode
    }
    $diagnosticScript = Join-Path $PSScriptRoot 'Read-Mic315AudioDiagnostics.ps1'
    if (-not (Test-Path -LiteralPath $diagnosticScript -PathType Leaf)) {
        throw 'Sibling read-only diagnostic script is missing; no services changed.'
    }
    # Capture the transitive dependency tree before any stop, so unrelated
    # previously running dependents can be restored after the forced restart.
    $pending = [Collections.Generic.Queue[string]]::new()
    $pending.Enqueue('AudioEndpointBuilder')
    $serviceStates = @{}
    while ($pending.Count -gt 0) {
        $name = $pending.Dequeue()
        if ($serviceStates.ContainsKey($name)) { continue }
        $service = Get-Service -Name $name
        if ($name -notin @('AudioEndpointBuilder', 'Audiosrv')) {
            throw "Unknown dependent service '$name'; refusing forced restart. No services changed."
        }
        $serviceStates[$name] = $service.Status.ToString()
        if ($serviceStates[$name] -notin @('Running', 'Stopped')) {
            throw "Service '$name' is in transitional state; no service changes allowed."
        }
        foreach ($dependent in $service.DependentServices) { $pending.Enqueue($dependent.Name) }
    }
    foreach ($name in @($serviceStates.Keys | Sort-Object)) {
        Write-RepairLog "stage=before-service Name=$name Status=$($serviceStates[$name])"
    }
    if (-not $serviceStates.ContainsKey('Audiosrv')) {
        $serviceStates['Audiosrv'] = (Get-Service -Name Audiosrv).Status.ToString()
        Write-RepairLog "stage=before-service Name=Audiosrv Status=$($serviceStates['Audiosrv'])"
    }
    if ($serviceStates['Audiosrv'] -notin @('Running', 'Stopped')) {
        throw 'Audiosrv is in transitional state; no service changes allowed.'
    }
    if ($serviceStates['AudioEndpointBuilder'] -ne 'Running') {
        throw 'AudioEndpointBuilder was not running; refusing to start an initially stopped service.'
    }
    Write-RepairLog 'stage=diagnostics-before'
    & $diagnosticScript -OutputDirectory $OutputDirectory 2>&1 |
        ForEach-Object { Write-RepairLog "diagnostic-before $_" }
    $repairFailed = $false
    try {
        if (@(Get-Process -Name 'RecorderLnx*' -ErrorAction SilentlyContinue).Count -gt 0) {
            throw 'RecorderLnx started during diagnostics; refusing service changes.'
        }
        if ($script:repairLogFailed) { throw 'Repair log is unavailable; refusing service changes.' }
        Write-RepairLog 'stage=restart audio endpoint stack (once, each transition bounded to 10 seconds)'
        if ($serviceStates['Audiosrv'] -eq 'Running') {
            Set-AudioServiceState 'Audiosrv' $false
        }
        Set-AudioServiceState 'AudioEndpointBuilder' $false
        Set-AudioServiceState 'AudioEndpointBuilder' $true
    } catch {
        $repairFailed = $true
        Write-RepairLog "stage=restart ERROR=$($_.Exception.Message)"
    } finally {
        foreach ($name in @('AudioEndpointBuilder', 'Audiosrv')) {
            if ($serviceStates[$name] -eq 'Running') {
                try {
                    Set-AudioServiceState $name $true
                    Write-RepairLog "stage=restore-running Name=$name"
                } catch {
                    $repairFailed = $true
                    Write-RepairLog "stage=restore-running Name=$name ERROR=$($_.Exception.Message)"
                }
            }
        }
    }
    Start-Sleep -Seconds 2
    foreach ($service in @(Get-Service -Name AudioEndpointBuilder, Audiosrv)) {
        Write-RepairLog "stage=after-service Name=$($service.Name) Status=$($service.Status)"
        if ($service.Status.ToString() -ne $serviceStates[$service.Name]) {
            $repairFailed = $true
        }
    }
    Write-RepairLog 'stage=diagnostics-after'
    & $diagnosticScript -OutputDirectory $OutputDirectory 2>&1 |
        ForEach-Object { Write-RepairLog "diagnostic-after $_" }
    if ($repairFailed -or $script:repairLogFailed) { throw 'Audio service restart, restoration or diagnostic logging failed.' }
    Write-RepairLog 'RESULT service restart complete; compare diagnostic endpoint counts to confirm recovery.'
    exit 0
} catch {
    if ($logPath) {
        try { Write-RepairLog "RESULT FAILED: $($_.Exception.Message)" } catch { }
    }
    Write-Error $_ -ErrorAction Continue
    exit 1
}
