$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1251))

# Используем литеральную замену через String.Replace
$old_block = @"
    lRawData := lBitmap.RawImage.Data;
    lLineStride := lBitmap.RawImage.Description.BytesPerLine;
    for lRow := 0 to lTexHeight - 1 do
    begin
      lPixelPtr := PDWord(lRawData + lRow * lLineStride);
      for lCol := 0 to lTexWidth - 1 do
      begin
        lColorVal := lPixelPtr^;
        lAlpha := lColorVal and `$FF;
        lPixelPtr^ := (Cardinal(lAlpha) shl 24) or `$00FFFFFF;
        Inc(lPixelPtr);
      end;
    end;

    glGenTextures(1, @fTextureId);
    glBindTexture(GL_TEXTURE_2D, fTextureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, lTexWidth, lTexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, lRawData);
"@

# Заменяем CRLF в старом блоке на LF для надежности (и будем делать замену в нормализованном виде)
$content_normalized = $content.Replace("`r`n", "`n")
$old_block_normalized = $old_block.Replace("`r`n", "`n")

$replacement_normalized = @"
    lRawData := nil;
    GetMem(lRawData, lTexWidth * lTexHeight * 4);
    try
      lPixelPtr := PDWord(lRawData);
      for lRow := 0 to lTexHeight - 1 do
      begin
        for lCol := 0 to lTexWidth - 1 do
        begin
          lColorVal := lBitmap.Canvas.Pixels[lCol, lRow];
          lAlpha := Byte(lColorVal); // Получаем яркость (Red) для маски шрифта
          lPixelPtr^ := (Cardinal(lAlpha) shl 24) or `$00FFFFFF;
          Inc(lPixelPtr);
        end;
      end;

      glGenTextures(1, @fTextureId);
      glBindTexture(GL_TEXTURE_2D, fTextureId);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
      
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, lTexWidth, lTexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, lRawData);
    finally
      FreeMem(lRawData);
    end;
"@
$replacement_normalized = $replacement_normalized.Replace("`r`n", "`n")

if ($content_normalized.Contains($old_block_normalized)) {
    Write-Output "Literal block found, replacing..."
    $content_normalized = $content_normalized.Replace($old_block_normalized, $replacement_normalized)
    
    # Возвращаем CRLF переносы строк
    $content_final = $content_normalized.Replace("`n", "`r`n")
    [System.IO.File]::WriteAllText($path, $content_final, [System.Text.Encoding]::GetEncoding(1251))
    Write-Output "Replacement done."
} else {
    Write-Output "Literal block NOT found!"
}
