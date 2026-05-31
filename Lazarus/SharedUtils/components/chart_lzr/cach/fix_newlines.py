# -*- coding: utf-8 -*-
import io
import os

files_to_fix = [
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartSelectListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPageGeometryListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartVertexEditListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLabelEditListener.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"
]

for file_path in files_to_fix:
    if os.path.exists(file_path):
        # 1. Read binary
        with open(file_path, "rb") as f:
            raw_bytes = f.read()
        
        # 2. Decode as cp1251
        content = raw_bytes.decode("cp1251")
        
        # 3. Clean all carriage return mess (normalize to \n)
        content_clean = content.replace("\r\n", "\n").replace("\r", "\n")
        
        # 4. Write back using cp1251 and proper CRLF newline translation
        with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
            f.write(content_clean)
        
        print("Normalized newlines in: %s" % os.path.basename(file_path))
    else:
        print("Warning: File not found: %s" % file_path)

print("Newline normalization complete.")
