# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

target = """    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;"""

replacement = """    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    if Assigned(lRenderer.SelectedObject) then
      lRenderer.LogToFile('MouseMove: SelectedObject = ' + lRenderer.SelectedObject.Name)
    else
      lRenderer.LogToFile('MouseMove: SelectedObject = nil');"""

# Normalize just in case
def norm(txt):
    return txt.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")

content = content.replace(norm(target), norm(replacement))

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Debug log patch applied successfully!")
