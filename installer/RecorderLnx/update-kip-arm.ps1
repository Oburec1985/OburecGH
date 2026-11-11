param(
    [string]$ConfigFile = (Join-Path $PSScriptRoot 'update-kip-arm.local.psd1'),
    [switch]$SkipBuild,
    [string]$TargetName = ''
)

$ErrorActionPreference = 'Stop'
$scriptRoot = $PSScriptRoot
$config = Import-PowerShellDataFile -LiteralPath $ConfigFile
if ($TargetName -ne '') {
    $config.Targets = @($config.Targets | Where-Object { $_.Name -eq $TargetName })
    if ($config.Targets.Count -ne 1) {
        throw ('Expected exactly one deployment target: ' + $TargetName)
    }
}
$vmrun = 'C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe'
$askPass = Join-Path $scriptRoot 'Tools\recorder-ssh-askpass.exe'
$deployScript = Join-Path $scriptRoot 'deploy-linux-all.bat'
$packageScript = Join-Path $scriptRoot 'linux\build-installer.ps1'
$buildScript = $config.LinuxRepoRoot + '/installer/RecorderLnx/linux/build-linux-all.sh'
$outputDir = Join-Path $scriptRoot 'linux\Output'
$transcriptFile = Join-Path $outputDir 'update-kip-arm-latest.log'
$inventoryFile = Join-Path $env:TEMP ('recorder-kip-arm-' + [guid]::NewGuid().ToString('N') + '.txt')
$startedVm = $false

function Invoke-TargetSsh {
    param($Target, [string]$Command)
    $env:RECORDER_DEPLOY_PASSWORD = $Target.Password
    $env:SSH_ASKPASS = $askPass
    $env:SSH_ASKPASS_REQUIRE = 'force'
    $env:DISPLAY = 'recorderlnx-update'
    & ssh.exe -T -o StrictHostKeyChecking=accept-new -o BatchMode=no `
        -o NumberOfPasswordPrompts=1 -o ConnectTimeout=10 `
        ($Target.User + '@' + $Target.Host) $Command
    return $LASTEXITCODE
}

function Wait-GuestTools {
    for ($attempt = 1; $attempt -le 30; $attempt++) {
        & $vmrun -T ws -gu $config.VmUser -gp $config.VmPassword `
            listProcessesInGuest $config.VmPath *> $null
        if ($LASTEXITCODE -eq 0) { return }
        Start-Sleep -Seconds 2
    }
    throw 'Linux build VM did not become ready in 60 seconds.'
}

function Wait-HostAgent {
    param($Target)
    $uri = 'http://' + $Target.Host + ':8766/api/v1/status'
    for ($attempt = 1; $attempt -le 20; $attempt++) {
        try {
            $status = Invoke-RestMethod -Uri $uri -TimeoutSec 3
            if ($status.status -eq 'ready') { return }
        }
        catch { }
        Start-Sleep -Seconds 1
    }
    throw ('RecorderHostAgent is unavailable on ' + $Target.Name)
}

function Stop-RecorderOnTarget {
    param($Target)
    Wait-HostAgent $Target
    # Terminate out of process: a hung device session must not keep the old
    # executable alive while dpkg replaces the application.
    # Send TERM now and schedule KILL out of band.  Do not wait over SSH for a
    # process stuck in uninterruptible device I/O: such a wait previously
    # blocked the complete fleet update on ARM indefinitely.
    $command = 'pkill -TERM -x RecorderLnx 2>/dev/null || true; ' +
        'nohup sh -c ''sleep 5; pkill -KILL -x RecorderLnx 2>/dev/null || true'' ' +
        '>/dev/null 2>&1 </dev/null & exit 0'
    if ($Target.Name -eq 'АРМ') {
        # On ARM the UI may be blocked inside a display/device call.  Its SSH
        # channel has then been observed to remain open even after the remote
        # shell exits.  Dispatch the kill command asynchronously and continue
        # after the KILL grace period; dpkg may safely replace an opened ELF.
        $env:RECORDER_DEPLOY_PASSWORD = $Target.Password
        $env:SSH_ASKPASS = $askPass
        $env:SSH_ASKPASS_REQUIRE = 'force'
        $env:DISPLAY = 'recorderlnx-update'
        Start-Process -FilePath ssh.exe -WindowStyle Hidden -ArgumentList @(
            '-T', '-o', 'StrictHostKeyChecking=accept-new', '-o', 'BatchMode=no',
            '-o', 'NumberOfPasswordPrompts=1', '-o', 'ConnectTimeout=10',
            ($Target.User + '@' + $Target.Host), $command) | Out-Null
        Start-Sleep -Seconds 6
        Write-Host ('  stop dispatched: ' + $Target.Name)
        return
    }
    $exitCode = Invoke-TargetSsh $Target $command
    if ($exitCode -ne 0) { throw ('Could not stop Recorder on ' + $Target.Name) }
    Write-Host ('  stopped: ' + $Target.Name)
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
Start-Transcript -LiteralPath $transcriptFile -Force | Out-Null
try {
    if (-not (Test-Path -LiteralPath $vmrun)) { throw "vmrun not found: $vmrun" }
    if (-not (Test-Path -LiteralPath $askPass)) { throw "SSH helper not found: $askPass" }

    if (-not $SkipBuild) {
        $runningVms = & $vmrun list
        if ($runningVms -notcontains $config.VmPath) {
            Write-Host 'Starting Linux build VM...'
            & $vmrun start $config.VmPath nogui
            if ($LASTEXITCODE -ne 0) { throw 'Could not start Linux build VM.' }
            $startedVm = $true
        }
        Wait-GuestTools

        Write-Host 'Rebuilding all Linux binaries...'
        & $vmrun -T ws -gu $config.VmUser -gp $config.VmPassword `
            runProgramInGuest $config.VmPath /bin/bash $buildScript $config.LinuxRepoRoot
        if ($LASTEXITCODE -ne 0) { throw 'Linux build failed. See build-linux-latest.log.' }

        Write-Host 'Building Debian package...'
        & $packageScript
        if ($LASTEXITCODE -ne 0) { throw 'DEB package build failed.' }
    }

    $inventory = [Collections.Generic.List[string]]::new()
    $inventory.Add('# Generated for KIP/ARM update only.')
    $inventory.Add(('# coordinator={0}' -f $config.CoordinatorUrl))
    foreach ($target in $config.Targets) {
        $inventory.Add(('{0}@{1}|{2}' -f $target.User, $target.Host,
            $target.Password))
    }
    [IO.File]::WriteAllLines($inventoryFile, $inventory.ToArray(),
        [Text.ASCIIEncoding]::new())

    Write-Host 'Stopping Recorder on every target computer...'
    foreach ($target in $config.Targets) {
        Stop-RecorderOnTarget $target
    }

    Write-Host 'Installing package on KIP-1..KIP-4 and ARM...'
    $env:RECORDER_DEPLOY_NO_PAUSE = '1'
    & $deployScript $inventoryFile 'user'
    if ($LASTEXITCODE -ne 0) { throw 'Deployment failed on one or more targets.' }

    Write-Host 'Starting the new Recorder version on KIP computers...'
    foreach ($target in $config.Targets) {
        Wait-HostAgent $target
        if ($target.StartAfterUpdate) {
            $uri = 'http://' + $target.Host + ':8766/api/v1/recorder/start'
            Invoke-RestMethod -Method Post -Uri $uri -TimeoutSec 10 | Out-Null
            # Each Recorder registers signal metadata in the shared Firebird
            # database during startup.  Stagger fleet starts so those short
            # write transactions do not collide on the same metadata rows.
            Start-Sleep -Seconds 3
        }
    }
    Start-Sleep -Seconds 3

    $expectedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath `
        (Join-Path $scriptRoot '..\..\Lazarus\RecorderLnx\lib\x86_64-linux\RecorderLnx')).Hash.ToLowerInvariant()
    foreach ($target in $config.Targets) {
        $mustRun = [bool]$target.StartAfterUpdate
        $env:RECORDER_DEPLOY_PASSWORD = $target.Password
        $env:SSH_ASKPASS = $askPass
        $env:SSH_ASKPASS_REQUIRE = 'force'
        $env:DISPLAY = 'recorderlnx-update'
        $verify = "installed=`$(sha256sum /opt/mera/RecorderLnx/RecorderLnx | cut -d' ' -f1); " +
            "count=`$(ps -C RecorderLnx -o stat= | grep -vc '^[[:space:]]*Z'); " +
            'echo $installed $count'
        $result = & ssh.exe -T -o StrictHostKeyChecking=accept-new `
            ($target.User + '@' + $target.Host) $verify
        if ($LASTEXITCODE -ne 0) { throw ('Verification failed on ' + $target.Name) }
        $parts = ($result -join '').Trim().Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
        $expectedCount = $(if ($mustRun) { '1' } else { '0' })
        if (($parts.Count -lt 2) -or ($parts[0] -ne $expectedHash) -or
            ($parts[1] -ne $expectedCount)) {
            throw ("Unexpected state on {0}: {1}" -f $target.Name, ($result -join ' '))
        }
        Write-Host ("  OK {0}: Recorder={1}, SHA256={2}" -f $target.Name,
            $(if ($mustRun) { 'running' } else { 'stopped' }), $expectedHash)
    }
    Write-Host 'Update completed successfully.' -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $inventoryFile) {
        Remove-Item -LiteralPath $inventoryFile -Force
    }
    if ($startedVm) {
        Write-Host 'Stopping Linux build VM...'
        & $vmrun stop $config.VmPath soft | Out-Null
    }
    Remove-Item Env:RECORDER_DEPLOY_PASSWORD -ErrorAction SilentlyContinue
    Stop-Transcript | Out-Null
}
