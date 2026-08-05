import os

RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"
LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Updating renderer and listeners with AModel parameter...")

# 1. Update uOglChartRenderer.pas
with open(RENDERER_PATH, 'rb') as f:
    raw_renderer = f.read()
content_renderer = raw_renderer.decode('cp1251')
content_renderer_lf = content_renderer.replace('\r\n', '\n').replace('\r', '\n')

# Replace interface declaration
target_decl = "    function GetAxisHitAt(AX, AY: Integer; out AAxis: TChartAxis): Boolean;"
replacement_decl = "    function GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;"

if target_decl in content_renderer_lf:
    content_renderer_lf = content_renderer_lf.replace(target_decl, replacement_decl)
    print("Renderer interface updated.")
else:
    print("Warning: target_decl not found in renderer!")

# Replace implementation header
target_impl = "function TOpenGLChartRenderer.GetAxisHitAt(AX, AY: Integer; out AAxis: TChartAxis): Boolean;\nvar\n  lIndex, I, J: Integer;"
replacement_impl = "function TOpenGLChartRenderer.GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;\nvar\n  lIndex, I, J: Integer;"

# If that exact string isn't found due to spacing, let's do a search and replace
if "function TOpenGLChartRenderer.GetAxisHitAt(AX, AY: Integer;" in content_renderer_lf:
    content_renderer_lf = content_renderer_lf.replace(
        "function TOpenGLChartRenderer.GetAxisHitAt(AX, AY: Integer; out AAxis: TChartAxis): Boolean;",
        "function TOpenGLChartRenderer.GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;"
    )
    print("Renderer implementation header updated.")
else:
    print("Warning: implementation header not found in renderer!")

# Replace fModel with AModel in GetAxisHitAt implementation
content_renderer_lf = content_renderer_lf.replace("for lIndex := 0 to fModel.ChildCount - 1 do", "for lIndex := 0 to AModel.ChildCount - 1 do")
content_renderer_lf = content_renderer_lf.replace("if fModel.Children[lIndex] is TChartPage then", "if AModel.Children[lIndex] is TChartPage then")
content_renderer_lf = content_renderer_lf.replace("lPage := TChartPage(fModel.Children[lIndex]);", "lPage := TChartPage(AModel.Children[lIndex]);")

with open(RENDERER_PATH, 'wb') as f:
    f.write(content_renderer_lf.replace('\n', '\r\n').encode('cp1251'))

# 2. Update uOglChartFrameListener.pas
with open(LISTENER_PATH, 'rb') as f:
    raw_listener = f.read()
content_listener = raw_listener.decode('cp1251')
content_listener_lf = content_listener.replace('\r\n', '\n').replace('\r', '\n')

# Replace GetAxisHitAt call
target_call = "lRenderer.GetAxisHitAt(X, Y, lSelectedAxis)"
replacement_call = "lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis)"

if target_call in content_listener_lf:
    content_listener_lf = content_listener_lf.replace(target_call, replacement_call)
    print("Listener updated.")
else:
    print("Warning: target_call not found in listener!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_listener_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
