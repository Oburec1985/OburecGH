$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1251))

# 1. Заменяем var блок
$old_var = "var`r`n  lBitmap: TBitmap;"
$new_var = "var`r`n  lBitmap: TBitmap;`r`n  lFile: TextFile;"
$content = $content.Replace($old_var, $new_var)

# 2. Заменяем блок перед fTextHeight := lHeight;
$old_end = "    fTextHeight := lHeight;`r`n  finally"
$new_end = @"
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

    fTextHeight := lHeight;
  finally
"@

$content_normalized = $content.Replace("`r`n", "`n")
$old_end_normalized = $old_end.Replace("`r`n", "`n")
$new_end_normalized = $new_end.Replace("`r`n", "`n")

if ($content_normalized.Contains($old_end_normalized)) {
    $content_normalized = $content_normalized.Replace($old_end_normalized, $new_end_normalized)
    $content_final = $content_normalized.Replace("`n", "`r`n")
    [System.IO.File]::WriteAllText($path, $content_final, [System.Text.Encoding]::GetEncoding(1251))
    Write-Output "Debug log added."
} else {
    Write-Output "End block NOT found!"
}
