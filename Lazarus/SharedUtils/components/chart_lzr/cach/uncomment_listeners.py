# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

# Read
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Uncomment the listeners
new_content = content.replace("//AddFrameListener(TChartPageGeometryListener.Create);", "  AddFrameListener(TChartPageGeometryListener.Create);")
new_content = new_content.replace("//AddFrameListener(TChartVertexEditListener.Create);", "  AddFrameListener(TChartVertexEditListener.Create);")
new_content = new_content.replace("//AddFrameListener(TChartLabelEditListener.Create);", "  AddFrameListener(TChartLabelEditListener.Create);")

# Save
with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
    f.write(new_content)

print("Listeners uncommented successfully in uoglchart.pas.")
