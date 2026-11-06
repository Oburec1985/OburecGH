param([string]$OutputDirectory = $PSScriptRoot)

# Read-only inventories. No audio playback, service changes or driver changes.
$ErrorActionPreference = 'Continue'
$OutputEncoding = [Text.UTF8Encoding]::new($false)
$logStamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportPath = Join-Path $OutputDirectory "Mic315-audio-$logStamp.log"
$nativeReportPath = Join-Path $OutputDirectory "Mic315-portaudio-$logStamp.log"
$probePath = Join-Path $PSScriptRoot 'Mic315AudioProbe.exe'
$installedDirectory = 'C:\Program Files (x86)\Mera\RecorderLnx'
$audioLibraryPath = $null

& {
    'MIC315 audio read-only diagnostics'
    "Time=$(Get-Date -Format o) Host=$env:COMPUTERNAME Session=$([Diagnostics.Process]::GetCurrentProcess().SessionId) ProcessBits=$([IntPtr]::Size * 8)"

    '--- Running Recorder audio library ---'
    try {
        $recorders = @(Get-Process -Name RecorderLnx -ErrorAction Stop)
        foreach ($recorderProcess in $recorders) {
            "Recorder PID=$($recorderProcess.Id) Session=$($recorderProcess.SessionId)"
            try {
                $audioModules = @($recorderProcess.Modules | Where-Object {
                    $_.ModuleName -match 'portaudio'
                })
                if ($audioModules.Count -eq 0) { 'No loaded PortAudio module found' }
                foreach ($audioModule in $audioModules) {
                    $audioLibraryPath = $audioModule.FileName
                    "LoadedAudioLibrary=$audioLibraryPath"
                    "FileVersion=$($audioModule.FileVersionInfo.FileVersion)"
                    Get-FileHash -LiteralPath $audioLibraryPath -Algorithm SHA256 |
                        Select-Object Path, Hash | Format-List
                }
            } catch { "ERROR stage=process-modules: $($_.Exception.Message)" }
        }
    } catch { "ERROR stage=running-recorder: $($_.Exception.Message)" }

    '--- Audio services (read only) ---'
    try {
        Get-Service -Name Audiosrv, AudioEndpointBuilder -ErrorAction Stop |
            Select-Object Name, Status, StartType | Format-Table -AutoSize
    } catch { "ERROR stage=services: $($_.Exception.Message)" }

    '--- Sound controllers ---'
    try {
        Get-CimInstance -ClassName Win32_SoundDevice -ErrorAction Stop |
            Select-Object Name, Status, ConfigManagerErrorCode, @{
                Name = 'USB_ID'; Expression = {
                    if ($_.PNPDeviceID -match 'VID_[0-9A-F]{4}&PID_[0-9A-F]{4}') { $Matches[0] }
                }
            } | Format-Table -AutoSize
    } catch { "ERROR stage=sound-controllers: $($_.Exception.Message)" }

    '--- PnP audio endpoints ---'
    try {
        Get-PnpDevice -Class AudioEndpoint -ErrorAction Stop |
            Select-Object Status, Class, FriendlyName | Format-Table -AutoSize
    } catch { "ERROR stage=pnp-audio-endpoints: $($_.Exception.Message)" }

    '--- MMDevices render endpoint inventory ---'
    'State flags: 1=active, 2=disabled, 4=not-present, 8=unplugged'
    try {
        $renderRoot = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render'
        $renderKeys = @(Get-ChildItem -LiteralPath $renderRoot -ErrorAction Stop)
        foreach ($renderKey in $renderKeys) {
            try {
                $endpointData = Get-ItemProperty -LiteralPath $renderKey.PSPath -ErrorAction Stop
                $endpointProperties = Get-ItemProperty -LiteralPath ($renderKey.PSPath + '\Properties') -ErrorAction Stop
                $friendlyName = $endpointProperties.'{a45c254e-df1c-4efd-8020-67d146a850e0},14'
                "Endpoint=$($renderKey.PSChildName) State=$($endpointData.DeviceState) Name=$friendlyName"
            } catch { "ERROR stage=render-endpoint: $($_.Exception.Message)" }
        }
    } catch { "ERROR stage=render-inventory: $($_.Exception.Message)" }

    '--- Native PortAudio / WinMM probe ---'
    if (-not $audioLibraryPath) {
        foreach ($libraryName in @('portaudio.dll', 'libportaudio-2.dll')) {
            $libraryCandidate = Join-Path $installedDirectory $libraryName
            if (Test-Path -LiteralPath $libraryCandidate) {
                $audioLibraryPath = $libraryCandidate
                break
            }
        }
    }
    if (-not $audioLibraryPath) {
        'ERROR stage=library-path: no readable installed PortAudio DLL found'
    } elseif (-not (Test-Path -LiteralPath $probePath)) {
        "ERROR stage=probe-file: missing $probePath"
    } else {
        "ProbeLibrary=$audioLibraryPath"
        & $probePath "--library=$audioLibraryPath" "--out=$nativeReportPath" | Out-Null
        "ProbeExit=$LASTEXITCODE"
        if (Test-Path -LiteralPath $nativeReportPath) {
            Get-Content -LiteralPath $nativeReportPath -Encoding UTF8
        } else { 'ERROR stage=probe-report: native report was not created' }
    }
    '--- End ---'
} *>&1 | Out-File -LiteralPath $reportPath -Encoding UTF8 -Width 240

Write-Output "Diagnostics saved: $reportPath"
Write-Output "Native report: $nativeReportPath"
