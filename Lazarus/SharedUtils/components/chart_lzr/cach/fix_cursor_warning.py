# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLabelEditListener.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

old_line = "else if TControl(ASender).Cursor in [crSizeNWSE, crSizeWE, crSizeNS, crSizeAll] then"
new_line = "else if (TControl(ASender).Cursor = crSizeNWSE) or (TControl(ASender).Cursor = crSizeWE) or (TControl(ASender).Cursor = crSizeNS) or (TControl(ASender).Cursor = crSizeAll) then"

if old_line in content:
    content = content.replace(old_line, new_line)
    with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
        f.write(content)
    print("Successfully fixed cursor set warning.")
else:
    print("Pattern not found.")
