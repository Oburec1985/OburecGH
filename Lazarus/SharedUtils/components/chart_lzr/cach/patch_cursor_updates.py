# -*- coding: utf-8 -*-
import io

# 1. Update uoglchart.pas (move cursor listener to the top)
file_oglchart = "uoglchart.pas"
with io.open(file_oglchart, "r", encoding="cp1251") as f:
    content_ogl = f.read()

content_ogl = content_ogl.replace("\r\n", "\n").replace("\r", "\n")

target_reg_old = """  fListeners := TList.Create;
  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
    AddFrameListener(TChartPageGeometryListener.Create);
    AddFrameListener(TChartVertexEditListener.Create);
    AddFrameListener(TChartLabelEditListener.Create);
  AddFrameListener(TChartSelectListener.Create);
  AddFrameListener(TChartCursorListener.Create);"""

replacement_reg_new = """  fListeners := TList.Create;
  AddFrameListener(TChartCursorListener.Create);
  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
    AddFrameListener(TChartPageGeometryListener.Create);
    AddFrameListener(TChartVertexEditListener.Create);
    AddFrameListener(TChartLabelEditListener.Create);
  AddFrameListener(TChartSelectListener.Create);"""

if target_reg_old in content_ogl:
    content_ogl = content_ogl.replace(target_reg_old, replacement_reg_new)
    print("uoglchart.pas listener order updated.")
else:
    print("Warning: listener order target not found (might already be updated)")

content_ogl = content_ogl.replace("\n", "\r\n")
with io.open(file_oglchart, "w", encoding="cp1251", newline="") as f:
    f.write(content_ogl)


# 2. Update uOglChartRenderer.pas (flag positioning, background light, text dark)
file_renderer = "uOglChartRenderer.pas"
with io.open(file_renderer, "r", encoding="cp1251") as f:
    content_ren = f.read()

content_ren = content_ren.replace("\r\n", "\n").replace("\r", "\n")

target_draw_label = """    lRect.Left := Round(AXPixel - lTextWidth / 2 - 6);
    lRect.Right := Round(AXPixel + lTextWidth / 2 + 6);
    lRect.Top := Round(AYPixel - lTextHeight / 2 - 4);
    lRect.Bottom := Round(AYPixel + lTextHeight / 2 + 4);
    
    SetGLColor($E515151A); // Прозрачный темно-серый фон
    FillRect(lRect);
    
    SetGLColor(ACursor.Color);
    glLineWidth(1);
    DrawRect(lRect);
    
    SetGLColor($FFFFFFFF);"""

replacement_draw_label = """    lRect.Left := Round(AXPixel + 2);
    lRect.Right := Round(AXPixel + 2 + lTextWidth + 12);
    lRect.Top := Round(AYPixel - lTextHeight / 2 - 4);
    lRect.Bottom := Round(AYPixel + lTextHeight / 2 + 4);
    
    SetGLColor($D8F5F5FA); // Светлая подложка флага (85% непрозрачности)
    FillRect(lRect);
    
    SetGLColor(ACursor.Color);
    glLineWidth(1);
    DrawRect(lRect);
    
    SetGLColor($FF101010); // Темный текст для контраста"""

if target_draw_label in content_ren:
    content_ren = content_ren.replace(target_draw_label, replacement_draw_label)
    print("uOglChartRenderer.pas DrawCursorLabel updated.")
else:
    print("Error: DrawCursorLabel target not found in uOglChartRenderer.pas")

content_ren = content_ren.replace("\n", "\r\n")
with io.open(file_renderer, "w", encoding="cp1251", newline="") as f:
    f.write(content_ren)


# 3. Update uOglChartCursorListener.pas (GetCursorLabelRect left alignment)
file_listener = "uOglChartCursorListener.pas"
with io.open(file_listener, "r", encoding="cp1251") as f:
    content_lis = f.read()

content_lis = content_lis.replace("\r\n", "\n").replace("\r", "\n")

target_lis_rect = """    Result.Left := Round(AXPixel - lTextWidth / 2 - 6);
    Result.Right := Round(AXPixel + lTextWidth / 2 + 6);
    Result.Top := Round(AYPixel - lTextHeight / 2 - 4);
    Result.Bottom := Round(AYPixel + lTextHeight / 2 + 4);"""

replacement_lis_rect = """    Result.Left := Round(AXPixel + 2);
    Result.Right := Round(AXPixel + 2 + lTextWidth + 12);
    Result.Top := Round(AYPixel - lTextHeight / 2 - 4);
    Result.Bottom := Round(AYPixel + lTextHeight / 2 + 4);"""

if target_lis_rect in content_lis:
    content_lis = content_lis.replace(target_lis_rect, replacement_lis_rect)
    print("uOglChartCursorListener.pas GetCursorLabelRect updated.")
else:
    print("Error: GetCursorLabelRect target not found in uOglChartCursorListener.pas")

content_lis = content_lis.replace("\n", "\r\n")
with io.open(file_listener, "w", encoding="cp1251", newline="") as f:
    f.write(content_lis)

print("All updates prepared.")
