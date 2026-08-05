$path = "c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFontMng.pas"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::GetEncoding(1251))

# Заменяем блок получения данных RawImage и загрузки текстуры
$pattern = "(?s)lRawData\s*:=\s*lBitmap\.RawImage\.Data;\s*lLineStride\s*:=\s*lBitmap\.RawImage\.Description\.BytesPerLine;\s*for\s*lRow\s*:=\s*0\s*to\s*lTexHeight\s*-\s*1\s*do\s*begin\s*lPixelPtr\s*:=\s*PDWord\(lRawData\s*\+\s*lRow\s*\*\s*lLineStride\);\s*for\s*lCol\s*:=\s*0\s*to\s*lTexWidth\s*-\s*1\s*do\s*begin\s*lColorVal\s*:=\s*lPixelPtr\^;\s*lAlpha\s*:=\s*lColorVal\s*and\s*`\$FF;\s*lPixelPtr\^\s*:=\s*\(Cardinal\(lAlpha\)\s*shl\s*24\)\s*or\s*`\$00FFFFFF;\s*Inc\(lPixelPtr\);\s*end;\s*end;\s*glGenTextures\(1,\s*@fTextureId\);\s*glBindTexture\(GL_TEXTURE_2D,\s*fTextureId\);\s*glTexParameteri\(GL_TEXTURE_2D,\s*GL_TEXTURE_MIN_FILTER,\s*GL_NEAREST\);\s*glTexParameteri\(GL_TEXTURE_2D,\s*GL_TEXTURE_MAG_FILTER,\s*GL_NEAREST\);\s*glTexParameteri\(GL_TEXTURE_2D,\s*GL_TEXTURE_WRAP_S,\s*GL_CLAMP_TO_EDGE\);\s*glTexParameteri\(GL_TEXTURE_2D,\s*GL_TEXTURE_WRAP_T,\s*GL_CLAMP_TO_EDGE\);\s*glTexImage2D\(GL_TEXTURE_2D,\s*0,\s*GL_RGBA,\s*lTexWidth,\s*lTexHeight,\s*0,\s*GL_RGBA,\s*GL_UNSIGNED_BYTE,\s*lRawData\);"

$replacement = @"
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
          lPixelPtr^ := (Cardinal(lAlpha) shl 24) or $00FFFFFF;
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

if ($content -match $pattern) {
    Write-Output "Pattern found, replacing..."
    $content = $content -replace $pattern, $replacement
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::GetEncoding(1251))
    Write-Output "Replacement done."
} else {
    Write-Output "Pattern NOT found!"
}
