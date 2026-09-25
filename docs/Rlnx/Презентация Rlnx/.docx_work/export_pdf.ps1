$ErrorActionPreference = 'Stop'
$docx = 'D:\works\OburecGH\docs\Rlnx\Презентация Rlnx\Сценарий презентации Rlnx.docx'
$pdf = 'D:\works\OburecGH\docs\Rlnx\Презентация Rlnx\.docx_work\Сценарий презентации Rlnx.pdf'
$word = $null
$document = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $document = $word.Documents.Open($docx, $false, $false)
    $document.Fields.Update() | Out-Null
    $document.Repaginate()
    $document.Save()
    $document.ExportAsFixedFormat($pdf, 17)
    Write-Output "PAGES=$($document.ComputeStatistics(2))"
}
finally {
    if ($document -ne $null) { $document.Close($false) }
    if ($word -ne $null) { $word.Quit() }
    if ($document -ne $null) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($document) }
    if ($word -ne $null) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
