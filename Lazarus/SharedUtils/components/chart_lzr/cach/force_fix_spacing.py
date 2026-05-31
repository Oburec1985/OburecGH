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
        with io.open(file_path, "r", encoding="cp1251") as f:
            lines = f.read().splitlines()
        
        # 1. Force de-double-spacing (remove empty line immediately following non-empty line)
        cleaned = []
        i = 0
        while i < len(lines):
            line = lines[i]
            cleaned.append(line)
            if line.strip() != "":
                if i + 1 < len(lines) and lines[i+1].strip() == "":
                    i += 2
                    continue
            i += 1
            
        # 2. Collapse consecutive empty lines (keep at most 1 empty line in a row)
        final_lines = []
        prev_empty = False
        for line in cleaned:
            is_empty = (line.strip() == "")
            if is_empty:
                if not prev_empty:
                    final_lines.append("") # write completely empty line instead of whitespace-only line
                prev_empty = True
            else:
                final_lines.append(line)
                prev_empty = False
        
        # Write back in CP1251 with CRLF
        with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
            f.write("\r\n".join(final_lines) + "\r\n")
            
        print("Forced cleaned %s: lines reduced from %d to %d" % (os.path.basename(file_path), len(lines), len(final_lines)))
    else:
        print("Warning: File not found: %s" % file_path)

print("Forced spacing cleanup complete.")
