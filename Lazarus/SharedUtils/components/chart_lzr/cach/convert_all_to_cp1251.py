# -*- coding: utf-8 -*-
import io
import os

files_to_convert = [
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartSelectListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPageGeometryListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartVertexEditListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLabelEditListener.pas"
]

for file_path in files_to_convert:
    if os.path.exists(file_path):
        # 1. Read file as UTF-8
        with io.open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # 2. Write file as CP1251 with CRLF endings
        with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
            f.write(content)
        
        print("Converted to CP1251 (no BOM, CRLF): %s" % file_path)
    else:
        print("Warning: File does not exist: %s" % file_path)

print("All files processed.")
