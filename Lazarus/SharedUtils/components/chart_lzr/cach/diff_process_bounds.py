# -*- coding: utf-8 -*-
import io
import difflib

p1 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"
p2 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas.utf8"

with io.open(p1, "r", encoding="cp1251") as f:
    c1 = f.read()
    
with io.open(p2, "r", encoding="utf-8") as f:
    c2 = f.read()

# Extract ProcessObjectBounds
def get_func_lines(content, func_name):
    lines = content.splitlines()
    start = -1
    for idx, line in enumerate(lines):
        if func_name.lower() in line.lower() and "procedure" in line.lower() and not "forward" in line.lower() and not "overload" in line.lower():
            start = idx
            break
    if start == -1:
        return []
    
    depth = 0
    body = []
    for idx in range(start, len(lines)):
        line = lines[idx]
        body.append(line.strip())
        stripped = line.strip().lower()
        if "begin" in stripped:
            depth += 1
        if "end;" in stripped or "end." in stripped:
            depth -= 1
            if depth <= 0 and idx > start + 3:
                break
    return body

f1 = get_func_lines(c1, "ProcessObjectBounds")
f2 = get_func_lines(c2, "ProcessObjectBounds")

diff = difflib.unified_diff(f2, f1, fromfile="Original", tofile="Refactored")
for line in diff:
    print(line)
