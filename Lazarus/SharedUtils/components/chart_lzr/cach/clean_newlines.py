# -*- coding: utf-8 -*-
import io

def clean_file(path):
    with io.open(path, 'r', encoding='cp1251') as f:
        content = f.read()
    # Normalize double line endings and other variations
    content = content.replace('\r\n', '\n').replace('\r', '\n')
    while '\n\n\n' in content:
        content = content.replace('\n\n\n', '\n\n')
    return content

# 1. Clean uOglChartCursorListener.pas
content = clean_file('uOglChartCursorListener.pas')

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
    print("Rounding fixed in listener.")
else:
    # Let's try matching with space/blank line variations
    cleaned_target = target_rect.replace("\n", "")
    print("Warning: Direct match failed, attempting normalized match")

# Save back with clean CRLF
content = content.replace('\n', '\r\n')
with io.open('uOglChartCursorListener.pas', 'w', encoding='cp1251', newline='') as f:
    f.write(content)
print("uOglChartCursorListener.pas cleaned.")

# 2. Clean uOglChartCursor.pas
content = clean_file('uOglChartCursor.pas')
content = content.replace('\n', '\r\n')
with io.open('uOglChartCursor.pas', 'w', encoding='cp1251', newline='') as f:
    f.write(content)
print("uOglChartCursor.pas cleaned.")
