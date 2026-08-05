# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

# Read the file in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Locate TOpenGLChartRenderer.Render(AModel: TObject);
target = "procedure TOpenGLChartRenderer.Render(AModel: TObject);\nvar\n  lColor: Cardinal;\n  r: Single;\n  g: Single;\n  b: Single;\n  a: Single;\n  lModel: TChartModel;\n  lIndex: Integer;\nbegin"

# Normalize line endings
content_normalized = content.replace('\r\n', '\n')
target_normalized = target.replace('\r\n', '\n')

replacement_normalized = """procedure TOpenGLChartRenderer.Render(AModel: TObject);
var
  lColor: Cardinal;
  r: Single;
  g: Single;
  b: Single;
  a: Single;
  lModel: TChartModel;
  lIndex: Integer;
  lPage: TChartPage;
  lAxisIdx: Integer;
  lAxis: TChartAxis;
begin
  if Assigned(AModel) and (AModel is TChartModel) then
  begin
    lModel := TChartModel(AModel);
    LogToFile('=== TOpenGLChartRenderer.Render ===');
    LogToFile('Host Width=' + IntToStr(fHost.GetWidth) + ', Height=' + IntToStr(fHost.GetHeight));
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPage := TChartPage(lModel.Children[lIndex]);
        LogToFile('Page: ' + lPage.Name + 
                  ' Visible=' + BoolToStr(lPage.Visible, True) +
                  ' XMinValue=' + FloatToStr(lPage.XMinValue) +
                  ' XMaxValue=' + FloatToStr(lPage.XMaxValue) +
                  ' Align=' + IntToStr(Ord(lPage.Align)) +
                  ' Rect=(' + FloatToStr(lPage.FloatRect.Left) + ',' + FloatToStr(lPage.FloatRect.Top) +
                  ',' + FloatToStr(lPage.FloatRect.Right) + ',' + FloatToStr(lPage.FloatRect.Bottom) + ')');
        for lAxisIdx := 0 to lPage.ChildCount - 1 do
          if lPage.Children[lAxisIdx] is TChartAxis then
          begin
            lAxis := TChartAxis(lPage.Children[lAxisIdx]);
            LogToFile('  Axis: ' + lAxis.Name + 
                      ' MinValue=' + FloatToStr(lAxis.MinValue) +
                      ' MaxValue=' + FloatToStr(lAxis.MaxValue));
          end;
      end;
  end;"""

if target_normalized in content_normalized:
    content_normalized = content_normalized.replace(target_normalized, replacement_normalized)
    print("Successfully injected debug print into TOpenGLChartRenderer.Render")
else:
    # Try with different whitespace spacing
    print("Error: Target signature not found in TOpenGLChartRenderer.Render")

# Restore CRLF
content = content_normalized.replace('\n', '\r\n')

# Write back in CP1251
with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
    f.write(content)

print("Finished inject_debug_print.py")
