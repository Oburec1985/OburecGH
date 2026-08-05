# -*- coding: utf-8 -*-
import io
import difflib

p1 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"
p2 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas.utf8"

with io.open(p1, "r", encoding="cp1251") as f:
    c1 = f.read()
    
with io.open(p2, "r", encoding="utf-8") as f:
    c2 = f.read()

def get_func_lines_clean(content, func_name):
    lines = content.splitlines()
    start = -1
    for idx, line in enumerate(lines):
        if func_name in line and "procedure" in line and not "forward" in line:
            start = idx
            break
    if start == -1:
        return []
    
    depth = 0
    body = []
    for idx in range(start, len(lines)):
        line = lines[idx]
        stripped = line.strip()
        if not stripped:
            continue
        body.append(stripped)
        stripped_lower = stripped.lower()
        if "begin" in stripped_lower:
            depth += 1
        if "end;" in stripped_lower or "end." in stripped_lower:
            depth -= 1
            if depth <= 0 and idx > start + 3:
                break
    return body

for func in ["ProcessObjectBounds", "FitZoomX", "FitZoomY", "FitZoomXY", "FitPageZoom"]:
    f1 = get_func_lines_clean(c1, func)
    f2 = get_func_lines_clean(c2, func)
    diff = list(difflib.unified_diff(f2, f1, fromfile="Original", tofile="Refactored"))
    if diff:
        print(f"--- SEMANTIC MISMATCH in {func} ---")
        for line in diff:
            print(line)
    else:
        print(f"{func} matches perfectly semantically.")
