import os

OGLCHART_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

print("Suppressing compiler hints in uoglchart.pas...")

with open(OGLCHART_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

target = """    fRenderer.Resize(Width, Height);
    
    QueryPerformanceFrequency(lFreq);"""

replacement = """    fRenderer.Resize(Width, Height);
    
    lFreq := 0;
    lStart := 0;
    lEnd := 0;
    QueryPerformanceFrequency(lFreq);"""

if target in content_lf:
    content_lf = content_lf.replace(target, replacement)
    print("Hints suppressed.")
else:
    print("Warning: target not found!")

with open(OGLCHART_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
