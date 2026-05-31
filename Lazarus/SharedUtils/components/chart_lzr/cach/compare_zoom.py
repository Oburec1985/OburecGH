# -*- coding: utf-8 -*-
import io

p1 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"
p2 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas.utf8"

with io.open(p1, "r", encoding="cp1251") as f:
    c1 = f.read()
    
with io.open(p2, "r", encoding="utf-8") as f:
    c2 = f.read()

# Helper to normalize whitespace
def normalize(s):
    lines = s.splitlines()
    clean = []
    for line in lines:
        stripped = line.strip().lower()
        if stripped != "":
            # replace all spaces/tabs with single space
            words = stripped.split()
            clean.append(" ".join(words))
    return "\n".join(clean)

# Let's extract ProcessObjectBounds from both
def get_func(content, func_name):
    lines = content.splitlines()
    start = -1
    for idx, line in enumerate(lines):
        if func_name.lower() in line.lower() and "procedure" in line.lower() and not "forward" in line.lower() and not "overload" in line.lower():
            start = idx
            break
    if start == -1:
        return ""
    
    # scan until "end;" at the outer level
    depth = 0
    body = []
    for idx in range(start, len(lines)):
        line = lines[idx]
        body.append(line)
        stripped = line.strip().lower()
        if "begin" in stripped:
            depth += 1
        if "end;" in stripped or "end." in stripped:
            depth -= 1
            if depth <= 0 and idx > start + 3:
                break
    return "\n".join(body)

for func in ["ProcessObjectBounds", "FitZoomX", "FitZoomY", "FitZoomXY", "FitZoomXY", "FitPageZoom"]:
    f1 = get_func(c1, func)
    f2 = get_func(c2, func)
    
    n1 = normalize(f1)
    n2 = normalize(f2)
    
    if n1 == n2:
        print("Function %s matches perfectly." % func)
    else:
        print("Function %s MISMATCH!" % func)
        print("--- Refactored ---")
        print("\n".join(f1.splitlines()[:15]))
        print("--- Original ---")
        print("\n".join(f2.splitlines()[:15]))
        print("------------------")
