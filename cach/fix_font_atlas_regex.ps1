$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1251))

# 1. Восстанавливаем gUseTextureAtlas := True
$content = $content -replace "gUseTextureAtlas:\s*Boolean\s*=\s*False;", "gUseTextureAtlas: Boolean = True;"

# 2. Заменяем фрагмент в BuildTextureAtlas с помощью регулярного выражения, устойчивого к переносам строк
$pattern = "(?s)lBitmap\s*:=\s*TBitmap\.Create;\s*try\s*lBitmap\.PixelFormat\s*:=\s*pf32bit;\s*lBitmap\.Canvas\.Font\.Name\s*:=\s*fName;\s*lBitmap\.Canvas\.Font\.Size\s*:=\s*Round\(fScale\s*\*\s*7\.2\);\s*if\s*fBold\s*then\s*lBitmap\.Canvas\.Font\.Style\s*:=\s*\[fsBold\]\s*else\s*lBitmap\.Canvas\.Font\.Style\s*:=\s*\[\];\s*lHeight\s*:=\s*lBitmap\.Canvas\.TextHeight\('A'\);"

$replacement = @"
lBitmap := TBitmap.Create;
  try
    lBitmap.PixelFormat := pf32bit;
    // Обеспечиваем ненулевой размер битмапа для корректной работы GDI / Canvas.TextHeight
    lBitmap.Width := 32;
    lBitmap.Height := 32;
    
    // Подменяем логическое имя шрифта на реальный системный шрифт для рисования
    if (fName = 'PageCaption') or (fName = 'AxisLabel') or (fName = 'AxisSelected') or
       (fName = 'GridTick') or (fName = 'Legend') or (fName = 'Debug') then
      lBitmap.Canvas.Font.Name := 'Arial'
    else
      lBitmap.Canvas.Font.Name := fName;
    
    lBitmap.Canvas.Font.Size := Round(fScale * 7.2);
    if fBold then
      lBitmap.Canvas.Font.Style := [fsBold]
    else
      lBitmap.Canvas.Font.Style := [];

    lHeight := lBitmap.Canvas.TextHeight('A');
"@

if ($content -match $pattern) {
    Write-Output "Pattern found, replacing..."
    $content = $content -replace $pattern, $replacement
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::GetEncoding(1251))
    Write-Output "Replacement done."
} else {
    Write-Output "Pattern NOT found!"
}
