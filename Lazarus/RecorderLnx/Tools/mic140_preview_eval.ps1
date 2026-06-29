param(

    [int]$Seconds = 3,

    [int]$SettleSec = 6,

    [double]$BlocksPerSec = 5.0,

    [string]$Exe = "D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64\RecorderLnx.exe",

    [string]$Log = "D:\works\OburecGH\Lazarus\RecorderLnx\LogWindows.log"

)



function Get-Mic140BlocksPerSecFromLog {

    param([string[]]$Lines, [double]$DefaultBlocksPerSec)



    $freq = 0.0

    $freqLine = $Lines | Select-String -Pattern "freq=([\d,\.]+)\s*Hz" | Select-Object -Last 1

    if ($freqLine -and ($freqLine.Line -match "freq=([\d,\.]+)\s*Hz")) {

        $freq = [double]($Matches[1] -replace ',', '.')

    }

    if ($freq -gt 0.1) {

        # DataUpdateMs=200 in default.run-control.ini -> host polls at half the scan rate.

        return [math]::Max(1.0, $freq / 2.0)

    }

    return $DefaultBlocksPerSec

}



function Test-Mic140LogPass {

    param([string]$LogPath, [int]$DurationSec, [double]$DefaultBlocksPerSec)



    $lines = Get-Content $LogPath -ErrorAction SilentlyContinue

    if (-not $lines) { return @{ Pass = $false; Reason = "empty log" } }



    $stop = $lines | Select-String -Pattern "Src_MIC-140.*stream stop: published=" | Select-Object -Last 1

    if (-not $stop) {

        $stop = $lines | Select-String -Pattern "stream stop: published=" | Select-Object -Last 1

    }

    if (-not $stop) { return @{ Pass = $false; Reason = "no stream stop line" } }



    if ($stop.Line -match "published=(\d+) read=(\d+) readGaps=(\d+) dupRead=\d+ corruptRead=(\d+) publishGaps=(\d+)(?: corruptPublish=(\d+))?") {

        $pub = [int]$Matches[1]

        $read = [int]$Matches[2]

        $readGaps = [int]$Matches[3]

        $corrupt = [int]$Matches[4]

        $pubGaps = [int]$Matches[5]

        $corruptPublish = 0

        if ($Matches[6]) { $corruptPublish = [int]$Matches[6] }

    } else {

        return @{ Pass = $false; Reason = "cannot parse: $($stop.Line)" }

    }



    $blocksPerSec = Get-Mic140BlocksPerSecFromLog -Lines $lines -DefaultBlocksPerSec $DefaultBlocksPerSec

    $expectedPub = [int][math]::Round($DurationSec * $blocksPerSec)

    $minPub = [math]::Max(1, [int][math]::Floor($expectedPub * 0.90))

    $maxPub = [int][math]::Ceiling($expectedPub * 1.25) + 1



    $softRestart = ($lines | Select-String -Pattern "soft restart").Count

    $codeViolations = ($lines | Select-String -Pattern "MIC-140 code quality violation").Count



    $block1 = $lines | Select-String -Pattern "block1 channels:" | Select-Object -Last 1

    $readingsOk = $false

    $readReason = "no block1 line"

    if ($block1) {

        $rawMatches = [regex]::Matches($block1.Line, "raw=(-?\d+)")

        $bad = 0

        $good = 0

        foreach ($m in $rawMatches) {

            $v = [int]$m.Groups[1].Value

            if (($v -ge 32760) -or ($v -le -32760) -or ($v -gt 500) -or ($v -lt -15000)) { $bad++ }

            else { $good++ }

        }

        $hasCh12 = $block1.Line -match "MIC140_12 raw=(-?\d+)"

        $ch12ok = $false

        if ($hasCh12) {

            $v12 = [int]$Matches[1]

            $ch12ok = ($v12 -le 500) -and ($v12 -ge -15000)

        }

        if ($rawMatches.Count -ge 4 -and $bad -eq 0 -and $good -ge 4 -and $ch12ok) {

            $readingsOk = $true

            $readReason = "ok good=$good ch12=$v12"

        } else {

            $readReason = "raw good=$good bad=$bad ch12ok=$ch12ok"

        }

    }



    $pubRatio = if ($read -gt 0) { $pub * 100 / $read } else { 0 }

    $countOk = ($pub -ge $minPub) -and ($pub -le $maxPub)

    $streamOk = ($corrupt -eq 0) -and ($pubGaps -eq 0) -and ($readGaps -eq 0) -and ($corruptPublish -eq 0) -and ($codeViolations -eq 0) -and ($softRestart -eq 0) -and $countOk -and ($pubRatio -ge 85)



    $pass = $streamOk -and $readingsOk

    $reason = "pub=$pub read=$read ratio=$([int]$pubRatio)% corrupt=$corrupt corruptPublish=$corruptPublish codeBad=$codeViolations pubGaps=$pubGaps readGaps=$readGaps softRestart=$softRestart expected=$expectedPub range=$minPub..$maxPub bps=$blocksPerSec readings=$readReason"

    return @{ Pass = $pass; Reason = $reason }

}



if ($SettleSec -gt 0) { Start-Sleep -Seconds $SettleSec }

if (Test-Path $Log) { Remove-Item $Log -Force }

$p = Start-Process -FilePath $Exe -ArgumentList "--preview-seconds=$Seconds" -PassThru -Wait -WindowStyle Hidden

if ($p.ExitCode -ne 0) {

    Write-Output "FAIL exe exit code $($p.ExitCode)"

    exit 1

}

Start-Sleep -Seconds 2

$r = Test-Mic140LogPass -LogPath $Log -DurationSec $Seconds -DefaultBlocksPerSec $BlocksPerSec

if ($r.Pass) {

    Write-Output "PASS $($r.Reason)"

    exit 0

} else {

    Write-Output "FAIL $($r.Reason)"

    exit 1

}


