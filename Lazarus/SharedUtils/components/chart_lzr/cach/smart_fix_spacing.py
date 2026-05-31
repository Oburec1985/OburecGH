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
        
        # Detect if double-spaced
        non_empty_count = 0
        followed_by_empty_count = 0
        for i in range(len(lines) - 1):
            if lines[i].strip() != "":
                non_empty_count += 1
                if lines[i+1].strip() == "":
                    followed_by_empty_count += 1
        
        is_double_spaced = False
        if non_empty_count > 0:
            ratio = followed_by_empty_count / float(non_empty_count)
            # If more than 70% of non-empty lines are followed by an empty line, it's double-spaced
            if ratio > 0.70:
                is_double_spaced = True
        
        print("%s: ratio = %.2f, is_double_spaced = %s" % (os.path.basename(file_path), ratio if non_empty_count > 0 else 0, is_double_spaced))
        
        # 1. Apply double-space removal if detected
        cleaned = []
        if is_double_spaced:
            i = 0
            while i < len(lines):
                line = lines[i]
                cleaned.append(line)
                if line.strip() != "":
                    if i + 1 < len(lines) and lines[i+1].strip() == "":
                        i += 2
                        continue
                i += 1
        else:
            cleaned = lines
            
        # 2. Collapse consecutive empty lines (more than 1 empty line in a row -> 1 empty line)
        final_lines = []
        prev_empty = False
        for line in cleaned:
            is_empty = (line.strip() == "")
            if is_empty:
                if not prev_empty:
                    final_lines.append(line)
                prev_empty = True
            else:
                final_lines.append(line)
                prev_empty = False
        
        # Write back in CP1251 with CRLF
        with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
            f.write("\r\n".join(final_lines) + "\r\n")
            
        print("Processed %s: lines reduced from %d to %d" % (os.path.basename(file_path), len(lines), len(final_lines)))
    else:
        print("Warning: File not found: %s" % file_path)

print("Smart spacing correction complete.")
