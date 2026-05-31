# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

# Read the file in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Replace uses clause
old_uses = "uOglChartFrameListener, uOglChartBaseObj;"
new_uses = "uOglChartFrameListener, uOglChartSelectListener, uOglChartPanZoomListener,\n  uOglChartPageGeometryListener, uOglChartVertexEditListener,\n  uOglChartLabelEditListener, uOglChartBaseObj;"

if old_uses in content:
    content = content.replace(old_uses, new_uses)
    print("Successfully replaced uses clause.")
else:
    print("Warning: uses clause not found or already replaced.")

# Replace listener registration
old_listeners = """  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
  AddFrameListener(TChartSelectListener.Create);"""

new_listeners = """  // Добавление стандартных слушателей перетаскивания (Pan/Zoom) и выделения элементов
  AddFrameListener(TChartPanZoomListener.Create);
  AddFrameListener(TChartPageGeometryListener.Create);
  AddFrameListener(TChartVertexEditListener.Create);
  AddFrameListener(TChartLabelEditListener.Create);
  AddFrameListener(TChartSelectListener.Create);"""

# Normalize line endings for replacement match
content_normalized = content.replace('\r\n', '\n')
old_listeners_normalized = old_listeners.replace('\r\n', '\n')
new_listeners_normalized = new_listeners.replace('\r\n', '\n')

if old_listeners_normalized in content_normalized:
    content_normalized = content_normalized.replace(old_listeners_normalized, new_listeners_normalized)
    # Restore CRLF
    content = content_normalized.replace('\n', '\r\n')
    print("Successfully replaced listener registration.")
else:
    # Try exact match with CRLF
    if old_listeners in content:
        content = content.replace(old_listeners, new_listeners)
        print("Successfully replaced listener registration (CRLF).")
    else:
        print("Error: listener registration not found!")

# Write back in CP1251 with CRLF
with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
    f.write(content)

print("Finished updating uoglchart.pas")
