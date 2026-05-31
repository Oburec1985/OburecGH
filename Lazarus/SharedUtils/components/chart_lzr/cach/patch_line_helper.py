# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLineHelper.pas"

# Read in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Target string
target = "  if AUseShader and AShaderInitialized then\n  begin"
replacement = "  if AUseShader and AShaderInitialized and (ATrend.Count > 2000) then\n  begin"

# Normalize line endings in target/replacement to match content
if "\r\n" in content:
    target = target.replace("\n", "\r\n")
    replacement = replacement.replace("\n", "\r\n")

if target in content:
    content = content.replace(target, replacement)
    # Write back in CP1251 with exact bytes
    with io.open(file_path, "w", encoding="cp1251", newline="") as f:
        f.write(content)
    print("Patch successful!")
else:
    print("Error: Target string not found in file!")
