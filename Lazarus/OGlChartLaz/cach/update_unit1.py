import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Update TrendLine creation with Bezie points
target_trend = """  lSeries := AddLine(lAxisY, 'TrendLine', 'Trend line', $FF303030);
  lSeries.AddPoint(0, 0.22);
  lSeries.AddPoint(1, 0.36);
  lSeries.AddPoint(2, 0.31);
  lSeries.AddPoint(3, 0.58);
  lSeries.AddPoint(4, 0.48);
  lSeries.AddPoint(5, 0.74);
  lSeries.AddPoint(6, 0.69);
  lSeries.AddPoint(7, 0.86);
  lSeries.AddPoint(8, 0.63);
  lSeries.AddPoint(9, 0.78);
  lSeries.AddPoint(10, 0.52);
  lSeries.AddPoint(11, 0.66);"""

replacement_trend = """  lSeries := AddLine(lAxisY, 'TrendLine', 'Trend line', $FF303030);
  lSeries.ShowPoints := True;
  lSeries.Smooth := True;
  lSeries.AddBeziePoint(0, 0.22, bptCorner);
  lSeries.AddBeziePoint(1, 0.36, bptSmooth);
  lSeries.AddBeziePoint(2, 0.31, bptSmooth);
  lSeries.AddBeziePoint(3, 0.58, bptCorner);
  lSeries.AddBeziePoint(4, 0.48, bptSmooth);
  lSeries.AddBeziePoint(5, 0.74, bptSmooth);
  lSeries.AddBeziePoint(6, 0.69, bptCorner);
  lSeries.AddBeziePoint(7, 0.86, bptSmooth);
  lSeries.AddBeziePoint(8, 0.63, bptSmooth);
  lSeries.AddBeziePoint(9, 0.78, bptCorner);
  lSeries.AddBeziePoint(10, 0.52, bptSmooth);
  lSeries.AddBeziePoint(11, 0.66, bptCorner);
  lSeries.GenerateSplinePoints();"""

if target_trend in content_lf:
    content_lf = content_lf.replace(target_trend, replacement_trend)
    print("TrendLine creation updated successfully.")
else:
    print("Warning: target_trend not found!")

# 2. Update OglChart1MouseMove coordinate reporting
target_move = """          // Ищем выбранную ось
          lSelectedAxis := nil;
          if OglChart1.SelectedObject is TChartAxis then
            lSelectedAxis := TChartAxis(OglChart1.SelectedObject)"""

replacement_move = """          // Ищем выбранную ось или ось выбранного тренда
          lSelectedAxis := nil;
          if OglChart1.SelectedObject is TChartAxis then
            lSelectedAxis := TChartAxis(OglChart1.SelectedObject)
          else if OglChart1.SelectedObject is cTrend then
            lSelectedAxis := cTrend(OglChart1.SelectedObject).YAxis;"""

if target_move in content_lf:
    content_lf = content_lf.replace(target_move, replacement_move)
    print("OglChart1MouseMove logic updated successfully.")
else:
    print("Warning: target_move not found!")

# Save the file back as cp1251 with CRLF
content_crlf = content_lf.replace('\n', '\r\n')
with open(FILE_PATH, 'wb') as f:
    f.write(content_crlf.encode('cp1251'))

print("File unit1.pas saved successfully.")
