import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Normalize newlines
text = text.replace('\r\n', '\n').replace('\r', '\n')

# 1. Update ProcessObject variables and body (Axis Y and Axis Own X)
old_process_object = """  procedure ProcessObject(AObject: TChartBaseObject; ACurrentAxis: TChartAxis);
  var
    lIndex, lPtIdx: Integer;
    lLine: TChartLineSeries;
    lBuff1d: cBuffTrend1d;
    lAxis: TChartAxis;
    lAxisMinY, lAxisMaxY: Double;
    lAxisMinX, lAxisMaxX: Double;
    lHasAxisY, lHasAxisX: Boolean;
  begin"""

new_process_object = """  procedure ProcessObject(AObject: TChartBaseObject; ACurrentAxis: TChartAxis);
  var
    lIndex, lPtIdx: Integer;
    lLine: TChartLineSeries;
    lBuff1d: cBuffTrend1d;
    lAxis: TChartAxis;
    lAxisMinY, lAxisMaxY: Double;
    lAxisMinX, lAxisMaxX: Double;
    lHasAxisY, lHasAxisX: Boolean;
    lSpan: Double;
  begin"""

if old_process_object in text:
    text = text.replace(old_process_object, new_process_object)
    print("  Successfully added lSpan to ProcessObject var block.")
else:
    print("  FAIL: old_process_object var block not found!")

# 2. Update Y axis zoom fitting
old_y_fit = """      if lHasAxisY then
      begin
        if Abs(lAxisMaxY - lAxisMinY) < 1E-9 then
        begin
          lAxisMinY := lAxisMinY - 1.0;
          lAxisMaxY := lAxisMaxY + 1.0;
        end;
        lAxis.MinValue := lAxisMinY;
        lAxis.MaxValue := lAxisMaxY;
      end;"""

new_y_fit = """      if lHasAxisY then
      begin
        if Abs(lAxisMaxY - lAxisMinY) < 1E-9 then
        begin
          lAxisMinY := lAxisMinY - 1.0;
          lAxisMaxY := lAxisMaxY + 1.0;
        end
        else
        begin
          lSpan := lAxisMaxY - lAxisMinY;
          lAxisMinY := lAxisMinY - lSpan * 0.1;
          lAxisMaxY := lAxisMaxY + lSpan * 0.1;
        end;
        lAxis.MinValue := lAxisMinY;
        lAxis.MaxValue := lAxisMaxY;
      end;"""

if old_y_fit in text:
    text = text.replace(old_y_fit, new_y_fit)
    print("  Successfully updated Y-axis fit formula with 20% margin.")
else:
    print("  FAIL: old_y_fit not found!")

# 3. Update Own X zoom fitting
old_own_x_fit = """      if lAxis.UseOwnX and lHasAxisX then
      begin
        if Abs(lAxisMaxX - lAxisMinX) < 1E-9 then
        begin
          lAxisMinX := lAxisMinX - 1.0;
          lAxisMaxX := lAxisMaxX + 1.0;
        end;
        lAxis.XMinValue := lAxisMinX;
        lAxis.XMaxValue := lAxisMaxX;
      end;"""

new_own_x_fit = """      if lAxis.UseOwnX and lHasAxisX then
      begin
        if Abs(lAxisMaxX - lAxisMinX) < 1E-9 then
        begin
          lAxisMinX := lAxisMinX - 1.0;
          lAxisMaxX := lAxisMaxX + 1.0;
        end
        else
        begin
          lSpan := lAxisMaxX - lAxisMinX;
          lAxisMinX := lAxisMinX - lSpan * 0.1;
          lAxisMaxX := lAxisMaxX + lSpan * 0.1;
        end;
        lAxis.XMinValue := lAxisMinX;
        lAxis.XMaxValue := lAxisMaxX;
      end;"""

if old_own_x_fit in text:
    text = text.replace(old_own_x_fit, new_own_x_fit)
    print("  Successfully updated Own X-axis fit formula with 20% margin.")
else:
    print("  FAIL: old_own_x_fit not found!")

# 4. Update FitPageZoom variables and Page X zoom fitting
old_fit_page_zoom_end = """  for lIdx := 0 to APage.ChildCount - 1 do
    ProcessObject(APage.Children[lIdx], nil);

  if lHasPageX then
  begin
    if Abs(lPageMaxX - lPageMinX) < 1E-9 then
    begin
      lPageMinX := lPageMinX - 1.0;
      lPageMaxX := lPageMaxX + 1.0;
    end;
    APage.XMinValue := lPageMinX;
    APage.XMaxValue := lPageMaxX;
  end;
end;"""

new_fit_page_zoom_end = """  for lIdx := 0 to APage.ChildCount - 1 do
    ProcessObject(APage.Children[lIdx], nil);

  if lHasPageX then
  begin
    if Abs(lPageMaxX - lPageMinX) < 1E-9 then
    begin
      lPageMinX := lPageMinX - 1.0;
      lPageMaxX := lPageMaxX + 1.0;
    end
    else
    begin
      lSpan := lPageMaxX - lPageMinX;
      lPageMinX := lPageMinX - lSpan * 0.1;
      lPageMaxX := lPageMaxX + lSpan * 0.1;
    end;
    APage.XMinValue := lPageMinX;
    APage.XMaxValue := lPageMaxX;
  end;
end;"""

if old_fit_page_zoom_end in text:
    text = text.replace(old_fit_page_zoom_end, new_fit_page_zoom_end)
    print("  Successfully updated Page X-axis fit formula with 20% margin.")
else:
    print("  FAIL: old_fit_page_zoom_end not found!")

# Add lSpan to FitPageZoom local variables
old_fit_page_zoom_vars = """procedure FitPageZoom(APage: TChartPage);
var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;"""

new_fit_page_zoom_vars = """procedure FitPageZoom(APage: TChartPage);
var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lSpan: Double;"""

if old_fit_page_zoom_vars in text:
    text = text.replace(old_fit_page_zoom_vars, new_fit_page_zoom_vars)
    print("  Successfully added lSpan to FitPageZoom var block.")
else:
    print("  FAIL: old_fit_page_zoom_vars not found!")

# Restore CRLF line endings
text = text.replace('\n', '\r\n')

# Write back as Windows-1251 (CP1251)
with open(FILE_PATH, 'w', encoding='cp1251', newline='') as f:
    f.write(text)
print("Saved file successfully.")
