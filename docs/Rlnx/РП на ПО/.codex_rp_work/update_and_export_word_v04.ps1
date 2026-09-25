$ErrorActionPreference = 'Stop'
$docxPath = 'D:\works\OburecGH\docs\Rlnx\РП на ПО\БЛИЖ.409801.100.236-01 34_v04.docx'
$pdfPath = 'D:\works\OburecGH\docs\Rlnx\РП на ПО\.codex_rp_work\БЛИЖ.409801.100.236-01 34_v04.pdf'
$word = $null
$doc = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $doc = $word.Documents.Open($docxPath, $false, $false)
    foreach ($toc in $doc.TablesOfContents) { $toc.Update() }
    $doc.Fields.Update() | Out-Null
    foreach ($section in $doc.Sections) {
        foreach ($header in $section.Headers) { $header.Range.Fields.Update() | Out-Null }
        foreach ($footer in $section.Footers) { $footer.Range.Fields.Update() | Out-Null }
    }
    $doc.Repaginate()
    $doc.Fields.Update() | Out-Null
    $doc.Save()
    $doc.ExportAsFixedFormat($pdfPath, 17)
    Write-Output "DOCX=$docxPath"
    Write-Output "PDF=$pdfPath"
    Write-Output "PAGES=$($doc.ComputeStatistics(2))"
}
finally {
    if ($doc -ne $null) { $doc.Close($false) }
    if ($word -ne $null) { $word.Quit() }
    if ($doc -ne $null) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($doc) }
    if ($word -ne $null) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
