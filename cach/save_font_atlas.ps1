$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1251))

# Заменяем блок логирования, чтобы добавить SaveToFile
$old_block = @"
    // Логирование параметров шрифта в файл
    try
      AssignFile(lFile, 'font_debug.log');
      if FileExists('font_debug.log') then
        Append(lFile)
      else
        Rewrite(lFile);
      WriteLn(lFile, Format('Font: %s, Scale: %.2f, Height: %d, TexWidth: %d, TexHeight: %d, SpaceWidth: %d, AWidth: %d',
        [fName, fScale, lHeight, lTexWidth, lTexHeight, CharPixelWidth(' '), CharPixelWidth('A')]));
      CloseFile(lFile);
    except
    end;
"@

$new_block = @"
    // Сохраняем атлас в файл для визуальной диагностики
    try
      lBitmap.SaveToFile('font_atlas_' + fName + '.bmp');
    except
    end;

    // Логирование параметров шрифта в файл
    try
      AssignFile(lFile, 'font_debug.log');
      if FileExists('font_debug.log') then
        Append(lFile)
      else
        Rewrite(lFile);
      WriteLn(lFile, Format('Font: %s, Scale: %.2f, Height: %d, TexWidth: %d, TexHeight: %d, SpaceWidth: %d, AWidth: %d',
        [fName, fScale, lHeight, lTexWidth, lTexHeight, CharPixelWidth(' '), CharPixelWidth('A')]));
      CloseFile(lFile);
    except
    end;
"@

$content_normalized = $content.Replace("`r`n", "`n")
$old_block_normalized = $old_block.Replace("`r`n", "`n")
$new_block_normalized = $new_block.Replace("`r`n", "`n")

if ($content_normalized.Contains($old_block_normalized)) {
    $content_normalized = $content_normalized.Replace($old_block_normalized, $new_block_normalized)
    $content_final = $content_normalized.Replace("`n", "`r`n")
    [System.IO.File]::WriteAllText($path, $content_final, [System.Text.Encoding]::GetEncoding(1251))
    Write-Output "SaveToFile added to BuildTextureAtlas."
} else {
    Write-Output "Block NOT found!"
}
