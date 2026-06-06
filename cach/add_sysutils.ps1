$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1251))

$old_uses = "uses`r`n  Math, gl, glext, Graphics;"
$new_uses = "uses`r`n  Math, gl, glext, Graphics, SysUtils;"

$content = $content.Replace($old_uses, $new_uses)
[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::GetEncoding(1251))
Write-Output "SysUtils added to uses."
