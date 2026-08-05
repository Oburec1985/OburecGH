$path = 'd:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas'
$bytes = [System.IO.File]::ReadAllBytes($path)

[byte[]]$target = @(0xC2, 0xFB, 0xE1, 0xF0, 0xE0, 0xED, 0xED, 0xE0, 0xFF, 0x20, 0xEE, 0xF1, 0xFC, 0x3A, 0x20, 0xD0, 0xBD, 0xD0, 0xB5, 0xD1, 0x82)
[byte[]]$replacement = @(0xC2, 0xFB, 0xE1, 0xF0, 0xE0, 0xED, 0xED, 0xE0, 0xFF, 0x20, 0xEE, 0xF1, 0xFC, 0x3A, 0x20, 0xED, 0xE5, 0xF2)

$result = New-Object System.Collections.Generic.List[byte]
for ($i = 0; $i -lt $bytes.Length; $i++) {
    $match = $true
    if ($i + $target.Length -le $bytes.Length) {
        for ($j = 0; $j -lt $target.Length; $j++) {
            if ($bytes[$i + $j] -ne $target[$j]) {
                $match = $false
                break
            }
        }
    } else {
        $match = $false
    }
    if ($match) {
        foreach ($b in $replacement) { $result.Add($b) }
        $i += $target.Length - 1
    } else {
        $result.Add($bytes[$i])
    }
}

[System.IO.File]::WriteAllBytes($path, $result.ToArray())
