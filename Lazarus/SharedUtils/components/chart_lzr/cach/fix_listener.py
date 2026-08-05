# -*- coding: utf-8 -*-
import io

file_path = 'uOglChartCursorListener.pas'

with io.open(file_path, 'r', encoding='cp1251') as f:
    content = f.read()

# Normalize line endings
content = content.replace('\r\n', '\n').replace('\r', '\n')

# If there's an extra newline after every single line, let's replace double newlines with single newlines
# Wait, let's do it multiple times to ensure we shrink all gaps
while '\n\n' in content:
    content = content.replace('\n\n', '\n')

# Now restore a few key blank lines for readability (e.g. before implementation, before procedures)
content = content.replace('implementation', '\nimplementation\n')
content = content.replace('constructor', '\nconstructor')
content = content.replace('procedure', '\nprocedure')
content = content.replace('function', '\nfunction')

target_rect = """    Result.Left := AXPixel - lTextWidth / 2 - 6;
    Result.Right := AXPixel + lTextWidth / 2 + 6;
    Result.Top := AYPixel - lTextHeight / 2 - 4;
    Result.Bottom := AYPixel + lTextHeight / 2 + 4;"""

replacement_rect = """    Result.Left := Round(AXPixel - lTextWidth / 2 - 6);
    Result.Right := Round(AXPixel + lTextWidth / 2 + 6);
    Result.Top := Round(AYPixel - lTextHeight / 2 - 4);
    Result.Bottom := Round(AYPixel + lTextHeight / 2 + 4);"""

if target_rect in content:
    content = content.replace(target_rect, replacement_rect)
    print("Rounding fixed successfully.")
else:
    print("Error: Target rect still not found in normalized content")

content = content.replace('\n', '\r\n')

with io.open(file_path, 'w', encoding='cp1251', newline='') as f:
    f.write(content)

print("Listener cleanup complete.")
