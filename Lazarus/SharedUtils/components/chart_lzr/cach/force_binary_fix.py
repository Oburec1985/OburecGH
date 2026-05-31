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
        
        # 3. Normalize all line endings to simple \n
        content_normalized = content.replace("\r\n", "\n").replace("\r", "\n")
        
        # 4. Split by \n
        lines = content_normalized.split("\n")
        if lines and lines[-1] == "":
            lines.pop()
            
        # Clean lines (strip trailing spaces)
        lines = [line.rstrip() for line in lines]
        
        # 5. Format spacing
        new_lines = []
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped == "":
                if len(new_lines) == 0:
                    continue
                
                prev_line = new_lines[-1].strip()
                
                # Keep empty line if previous line is 'end;', 'end.', or 'end'
                if prev_line.lower() in ['end;', 'end.', 'end']:
                    new_lines.append("")
                    continue
                
                # Keep empty line if next line is a major declaration or section
                next_line = ""
                for k in range(i + 1, len(lines)):
                    if lines[k].strip() != "":
                        next_line = lines[k].strip().lower()
                        break
                if next_line.startswith(('procedure ', 'function ', 'constructor ', 'destructor ', 'implementation', 'initialization', 'finalization', 'type', 'var', 'const')):
                    new_lines.append("")
                    continue
                
                continue
            else:
                new_lines.append(line)
        
        # Collapse consecutive empty lines
        final_lines = []
        prev_empty = False
        for line in new_lines:
            is_empty = (line.strip() == "")
            if is_empty:
                if not prev_empty:
                    final_lines.append("")
                prev_empty = True
            else:
                final_lines.append(line)
                prev_empty = False
                
        # 6. Write back in CP1251 with exact CRLF line endings, using newline="" to prevent doubling
        output_str = "\r\n".join(final_lines) + "\r\n"
        with io.open(file_path, "w", encoding="cp1251", newline="") as f:
            f.write(output_str)
            
        print("Binary format complete for %s: lines reduced to %d" % (os.path.basename(file_path), len(final_lines)))
    else:
        print("Warning: File not found: %s" % file_path)

print("All files formatted cleanly with binary-safe line endings.")
