import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartAxis.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Replace ancestor class
target = "cAxis = class(cDrawObj)"
replacement = "cAxis = class(cMoveObj)"

if target in text:
    text = text.replace(target, replacement)
    print("  Successfully changed ancestor to cMoveObj.")
else:
    print("  Target cAxis declaration not found!")

# Normalize lines to CRLF
text = text.replace('\r\n', '\n').replace('\r', '\n').replace('\n', '\r\n')

# Save back as cp1251
with open(FILE_PATH, 'w', encoding='cp1251', newline='') as f:
    f.write(text)
print("  File saved in CP1251 successfully.")
