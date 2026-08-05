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
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas",
    r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLineHelper.pas"
]

for file_path in files_to_fix:
    if os.path.exists(file_path):
        # Read file as raw text, normalizing line endings
        with io.open(file_path, "r", encoding="cp1251") as f:
            content = f.read()
            
        # Replace \r\n and \r with \n
        content = content.replace("\r\n", "\n").replace("\r", "\n")
        lines = content.split("\n")
        
        # Clean lines (strip whitespace from end)
        lines = [line.rstrip() for line in lines]
        
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
        
        # Write back in CP1251 using binary mode to write exact \r\n CRLF endings and prevent double-CR
        out_content = "\r\n".join(final_lines) + "\r\n"
        out_bytes = out_content.encode("cp1251")
        
        with open(file_path, "wb") as f:
            f.write(out_bytes)
            
        print("Fixed %s: lines reduced from %d to %d" % (os.path.basename(file_path), len(lines), len(final_lines)))
    else:
        print("Warning: File not found: %s" % file_path)

print("All files fixed and formatted with correct CRLF.")
