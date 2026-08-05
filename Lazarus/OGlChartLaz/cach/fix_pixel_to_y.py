import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

print(f"Fixing PixelToAxisValue in {os.path.basename(FILE_PATH)}...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Normalize newlines
text = text.replace('\r\n', '\n').replace('\r', '\n')

old_line = "lAxisYVal := lRenderer.PixelToYValue(lPage, lSelectedAxis, Y, lContentRect.Top, lContentRect.Bottom);"
new_line = "lAxisYVal := lRenderer.PixelToAxisValue(lSelectedAxis, Y, lContentRect.Bottom, lContentRect.Top);"

if old_line in text:
    text = text.replace(old_line, new_line)
    print("  Successfully replaced PixelToYValue with PixelToAxisValue.")
else:
    print("  FAIL: old_line not found!")

# Restore CRLF line endings
text = text.replace('\n', '\r\n')

# Save file
with open(FILE_PATH, 'w', encoding='cp1251', newline='') as f:
    f.write(text)
print("Saved file successfully.")
