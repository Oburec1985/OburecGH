# -*- coding: utf-8 -*-
import io
import difflib

p1 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPanZoomListener.pas"
p2 = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas.utf8"

with io.open(p1, "r", encoding="cp1251") as f:
    c1 = f.read()
    
with io.open(p2, "r", encoding="utf-8") as f:
    c2 = f.read()

def get_func_lines(content, func_name):
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
        body.append(line.strip())
        stripped = line.strip().lower()
        if "begin" in stripped:
            depth += 1
        if "end;" in stripped or "end." in stripped:
            depth -= 1
            if depth <= 0 and idx > start + 3:
                break
    return body

print("Checking FitPageZoom...")
f1_fpz = get_func_lines(c1, "FitPageZoom")
f2_fpz = get_func_lines(c2, "FitPageZoom")
diff_fpz = list(difflib.unified_diff(f2_fpz, f1_fpz, fromfile="Original", tofile="Refactored"))
if diff_fpz:
    print("Mismatch in FitPageZoom:")
    for line in diff_fpz:
        print(line)
else:
    print("FitPageZoom MATCHES")

print("\nChecking FitZoomX...")
f1_fzx = get_func_lines(c1, "FitZoomX")
f2_fzx = get_func_lines(c2, "FitZoomX")
diff_fzx = list(difflib.unified_diff(f2_fzx, f1_fzx, fromfile="Original", tofile="Refactored"))
if diff_fzx:
    print("Mismatch in FitZoomX:")
    for line in diff_fzx:
        print(line)
else:
    print("FitZoomX MATCHES")

print("\nChecking FitZoomY...")
f1_fzy = get_func_lines(c1, "FitZoomY")
f2_fzy = get_func_lines(c2, "FitZoomY")
diff_fzy = list(difflib.unified_diff(f2_fzy, f1_fzy, fromfile="Original", tofile="Refactored"))
if diff_fzy:
    print("Mismatch in FitZoomY:")
    for line in diff_fzy:
        print(line)
else:
    print("FitZoomY MATCHES")

print("\nChecking FitZoomXY...")
f1_fzxy = get_func_lines(c1, "FitZoomXY")
f2_fzxy = get_func_lines(c2, "FitZoomXY")
diff_fzxy = list(difflib.unified_diff(f2_fzxy, f1_fzxy, fromfile="Original", tofile="Refactored"))
if diff_fzxy:
    print("Mismatch in FitZoomXY:")
    for line in diff_fzxy:
        print(line)
else:
    print("FitZoomXY MATCHES")
