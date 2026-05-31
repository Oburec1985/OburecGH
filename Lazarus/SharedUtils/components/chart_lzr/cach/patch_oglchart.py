# -*- coding: utf-8 -*-
import io

file_path = "uoglchart.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Normalize
content = content.replace("\r\n", "\n").replace("\r", "\n")

# Uses clause replacement
target_uses = """  uOglChartFrameListener, uOglChartSelectListener, uOglChartPanZoomListener,
  uOglChartPageGeometryListener, uOglChartVertexEditListener,
  uOglChartLabelEditListener, uOglChartBaseObj;"""

replacement_uses = """  uOglChartFrameListener, uOglChartSelectListener, uOglChartPanZoomListener,
  uOglChartPageGeometryListener, uOglChartVertexEditListener,
  uOglChartLabelEditListener, uOglChartBaseObj, uOglChartCursorListener;"""

if target_uses in content:
    content = content.replace(target_uses, replacement_uses)
    print("Uses clause updated.")
else:
    print("Error: uses clause target not found")

# Listener registration replacement
target_listeners = """  fListeners := TList.Create;
  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
    AddFrameListener(TChartPageGeometryListener.Create);
    AddFrameListener(TChartVertexEditListener.Create);
    AddFrameListener(TChartLabelEditListener.Create);
  AddFrameListener(TChartSelectListener.Create);"""

replacement_listeners = """  fListeners := TList.Create;
  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
    AddFrameListener(TChartPageGeometryListener.Create);
    AddFrameListener(TChartVertexEditListener.Create);
    AddFrameListener(TChartLabelEditListener.Create);
  AddFrameListener(TChartSelectListener.Create);
  AddFrameListener(TChartCursorListener.Create);"""

if target_listeners in content:
    content = content.replace(target_listeners, replacement_listeners)
    print("Listener registration updated.")
else:
    print("Error: listener registration target not found")

content = content.replace("\n", "\r\n")

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Done.")
