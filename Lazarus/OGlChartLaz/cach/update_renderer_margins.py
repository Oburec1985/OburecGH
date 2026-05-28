import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print(f"Modifying {os.path.basename(FILE_PATH)} for dynamic Y-axis margins...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Normalize newlines
text = text.replace('\r\n', '\n').replace('\r', '\n')

old_method = """function TOpenGLChartRenderer.PageContentRect(APage: TChartPage): TChartPixelRect;
begin
  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left;
  Result.Top := fPageRect.Top + APage.PixelTabSpace.Top;
  Result.Right := fPageRect.Right - APage.PixelTabSpace.Right;
  Result.Bottom := fPageRect.Bottom - APage.PixelTabSpace.Bottom;

  if Result.Right < Result.Left + 20 then
    Result.Right := Result.Left + 20;
  if Result.Bottom < Result.Top + 20 then
    Result.Bottom := Result.Top + 20;
end;"""

new_method = """function TOpenGLChartRenderer.PageContentRect(APage: TChartPage): TChartPixelRect;
var
  lAdditionalLeft: Integer;
  lYAxis: TChartAxis;
  lYTicks: TChartTickArray;
  lAxisFont: cOglFont;
  lMaxTextWidth, lTextWidth: Integer;
  lIndex, I: Integer;
  lAxisOffset, lTotalSpace: Integer;
begin
  lAdditionalLeft := 0;
  lAxisOffset := 0;

  if Assigned(APage) then
  begin
    for I := 0 to APage.ChildCount - 1 do
      if APage.Children[I] is TChartAxis then
      begin
        lYAxis := TChartAxis(APage.Children[I]);
        BuildAxisTicks(lYAxis, 8, lYTicks);

        if lYAxis = fSelectedObject then
          lAxisFont := fFontMng.Font(cfAxisSelected)
        else
          lAxisFont := fFontMng.Font(cfAxisLabel);

        lMaxTextWidth := 0;
        for lIndex := 0 to High(lYTicks) do
        begin
          lTextWidth := lAxisFont.TextPixelWidth(lYTicks[lIndex].Text);
          if lTextWidth > lMaxTextWidth then
            lMaxTextWidth := lTextWidth;
        end;

        lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
      end;

    if lAxisOffset > 0 then
    begin
      lTotalSpace := lAxisOffset - 8;
      if lTotalSpace > APage.PixelTabSpace.Left then
        lAdditionalLeft := lTotalSpace - APage.PixelTabSpace.Left;
    end;
  end;

  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left + lAdditionalLeft;
  Result.Top := fPageRect.Top + APage.PixelTabSpace.Top;
  Result.Right := fPageRect.Right - APage.PixelTabSpace.Right;
  Result.Bottom := fPageRect.Bottom - APage.PixelTabSpace.Bottom;

  if Result.Right < Result.Left + 20 then
    Result.Right := Result.Left + 20;
  if Result.Bottom < Result.Top + 20 then
    Result.Bottom := Result.Top + 20;
end;"""

if old_method in text:
    text = text.replace(old_method, new_method)
    print("  Successfully replaced PageContentRect with dynamic calculation.")
else:
    print("  FAIL: old_method block not found!")

# Restore CRLF line endings
text = text.replace('\n', '\r\n')

# Write back as Windows-1251
with open(FILE_PATH, 'w', encoding='cp1251', newline='') as f:
    f.write(text)
print("Saved file successfully.")
