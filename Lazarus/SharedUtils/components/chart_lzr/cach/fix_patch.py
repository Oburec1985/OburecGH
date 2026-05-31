# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLineHelper.pas"

# Read in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Let's replace the first occurrence at line 91 back to normal
# We can split content by lines, modify line 91 (index 90) and line 210 (index 209), and write it back.
lines = content.splitlines()

# Let's print them first to verify
print("Before fix:")
print("Line 91:", repr(lines[90]))
print("Line 210:", repr(lines[209]))

# Line 91 is at index 90 (1-based line 91).
# Let's verify it matches our target
if "ATrend.Count" in lines[90]:
    lines[90] = "  if AUseShader and AShaderInitialized then"
    print("Fixed line 91 to normal.")

# Line 210 is at index 209 (1-based line 210).
# Let's verify it has ATrend.Count > 2000
if "ATrend.Count" in lines[209]:
    print("Line 210 is already correct.")
else:
    lines[209] = "  if AUseShader and AShaderInitialized and (ATrend.Count > 2000) then"
    print("Fixed line 210.")

# Write back in CP1251 with standard CRLF line endings
out_content = "\r\n".join(lines) + "\r\n"
with open(file_path, "wb") as f:
    f.write(out_content.encode("cp1251"))

print("Save complete.")
