$ErrorActionPreference = 'Stop'
$docx = 'D:\works\OburecGH\Lazarus\RecorderLnx\Docs\Руководство пользователя\Руководство пользователя RecorderLnx.docx'
$qaDir = 'D:\works\OburecGH\Lazarus\RecorderLnx\cach\user-guide-word-qa'
$pdf = Join-Path $qaDir 'RecorderLnx-user-guide.pdf'
New-Item -ItemType Directory -Force -Path $qaDir | Out-Null
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
    $doc = $word.Documents.Open($docx, $false, $true)
    $doc.Fields.Update() | Out-Null
    $doc.SaveAs2($pdf, 17)
    $doc.Close($false)
} finally {
    $word.Quit()
}
Write-Output $pdf
