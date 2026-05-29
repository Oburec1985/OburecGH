import os

RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print("Fixing float-to-int type conversion in uOglChartRenderer.pas...")

with open(RENDERER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

target = "  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left + lTotalOffset;"
replacement = "  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left + Round(lTotalOffset);"

if target in content_lf:
    content_lf = content_lf.replace(target, replacement)
    print("Round wrapper added successfully.")
else:
    print("Warning: target not found!")

with open(RENDERER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))
