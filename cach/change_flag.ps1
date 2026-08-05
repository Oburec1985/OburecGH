$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = Get-Content -Path $path -Encoding default
$content = $content -replace "gUseTextureAtlas: Boolean = True;", "gUseTextureAtlas: Boolean = False;"
Set-Content -Path $path -Value $content -Encoding default
