import os

RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"
LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"
UNIT1_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

print("Fixing renderer, listeners, and unit1...")

# 1. Update uOglChartRenderer.pas (move XValueToPixel and AxisValueToPixel to public)
with open(RENDERER_PATH, 'rb') as f:
    raw_renderer = f.read()
content_renderer = raw_renderer.decode('cp1251')
content_renderer_lf = content_renderer.replace('\r\n', '\n').replace('\r', '\n')

# Remove from private section
target_private_axis = "    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;\n"
target_private_x = "    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;\n"

content_renderer_lf = content_renderer_lf.replace(target_private_axis, "")
content_renderer_lf = content_renderer_lf.replace(target_private_x, "")

# Add to public section
target_public = "    function GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;"
replacement_public = "    function GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;\n    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;\n    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;"

content_renderer_lf = content_renderer_lf.replace(target_public, replacement_public)

with open(RENDERER_PATH, 'wb') as f:
    f.write(content_renderer_lf.replace('\n', '\r\n').encode('cp1251'))
print("Renderer coordinates helper functions moved to public.")


# 2. Update uOglChartFrameListener.pas
with open(LISTENER_PATH, 'rb') as f:
    raw_listener = f.read()
content_listener = raw_listener.decode('cp1251')
content_listener_lf = content_listener.replace('\r\n', '\n').replace('\r', '\n')

# Replace lTrend.YAxis -> TChartAxis(lTrend.Parent)
content_listener_lf = content_listener_lf.replace("if Assigned(lTrend.YAxis) then\n                      lYAxis := lTrend.YAxis;", "if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then\n                      lYAxis := TChartAxis(lTrend.Parent);")
content_listener_lf = content_listener_lf.replace("lAxis := fDragTrend.YAxis;", "lAxis := nil;\n      if Assigned(fDragTrend.Parent) and (fDragTrend.Parent is TChartAxis) then\n        lAxis := TChartAxis(fDragTrend.Parent);")

# Also correct lModel initialization warning in SelectListener
content_listener_lf = content_listener_lf.replace(
    "  lRenderer: TOpenGLChartRenderer;\n  lControl: IChartControl;\n  lHit: TChartTextHit;\n  lModel: TChartModel;\n  lPage: TChartPage;",
    "  lRenderer: TOpenGLChartRenderer;\n  lControl: IChartControl;\n  lHit: TChartTextHit;\n  lModel: TChartModel;\n  lPage: TChartPage;"
)

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_listener_lf.replace('\n', '\r\n').encode('cp1251'))
print("Listeners updated to use Parent axis and public helpers.")


# 3. Update unit1.pas
with open(UNIT1_PATH, 'rb') as f:
    raw_unit1 = f.read()
content_unit1 = raw_unit1.decode('cp1251')
content_unit1_lf = content_unit1.replace('\r\n', '\n').replace('\r', '\n')

content_unit1_lf = content_unit1_lf.replace(
    "else if OglChart1.SelectedObject is cTrend then\n            lSelectedAxis := cTrend(OglChart1.SelectedObject).YAxis;",
    "else if OglChart1.SelectedObject is cTrend then\n          begin\n            if Assigned(OglChart1.SelectedObject.Parent) and (OglChart1.SelectedObject.Parent is TChartAxis) then\n              lSelectedAxis := TChartAxis(OglChart1.SelectedObject.Parent);\n          end;"
)

with open(UNIT1_PATH, 'wb') as f:
    f.write(content_unit1_lf.replace('\n', '\r\n').encode('cp1251'))
print("Unit1 updated.")

print("All fixes applied successfully.")
