# -*- coding: utf-8 -*-
import subprocess
import time
import win32gui
import win32con
import os
import sys

# Ensure clean logs
log_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\chart_events.log"
if os.path.exists(log_path):
    try:
        os.remove(log_path)
    except:
        pass

# Start the application
app_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
proc = subprocess.Popen(app_path, cwd=os.path.dirname(app_path))
time.sleep(1.5)

# Find Form1 window
hwnd = None
def enum_win(h, extra):
    global hwnd
    if win32gui.IsWindowVisible(h):
        title = win32gui.GetWindowText(h)
        if "Form1" in title:
            hwnd = h
            return False
    return True

win32gui.EnumWindows(enum_win, None)

if hwnd is None:
    print("Form1 window not found!", flush=True)
    proc.terminate()
    sys.exit(1)

print(f"Form1 HWND: {hwnd}", flush=True)

# Locate Chart and Edit controls
chart_hwnd = None
edit_hwnd = None

children = []
win32gui.EnumChildWindows(hwnd, lambda h, _: children.append(h), None)
for h in children:
    cls = win32gui.GetClassName(h)
    r = win32gui.GetWindowRect(h)
    w = r[2] - r[0]
    rel_left = r[0] - win32gui.GetWindowRect(hwnd)[0]
    if cls == 'Edit' and w > 250:
        edit_hwnd = h
    elif cls == 'Window':
        if rel_left < 20 and w > 400:
            chart_hwnd = h

print(f"Detected -> Chart: {chart_hwnd}, Edit: {edit_hwnd}", flush=True)

if not edit_hwnd or not chart_hwnd:
    print("Failed to detect all controls!", flush=True)
    proc.terminate()
    sys.exit(1)

# Check Edit text to confirm PerfAxis1D is selected
val = win32gui.GetWindowText(edit_hwnd)
print(f"Selected object text on startup: '{val}'", flush=True)

if "PerfAxis1DAxisY" not in val:
    print("Error: PerfAxis1DAxisY was not successfully selected on startup!", flush=True)
    proc.terminate()
    sys.exit(1)

# Get chart dimensions relative to form
chart_rect = win32gui.GetWindowRect(chart_hwnd)
chart_w = chart_rect[2] - chart_rect[0]
chart_h = chart_rect[3] - chart_rect[1]

# Panning start and end coordinates in chart_hwnd client space
# Middle of PagePerf (bottom page)
start_x = int(chart_w * 0.5)
start_y = int(chart_h * 0.8)
end_x = start_x
end_y = start_y - 100  # Pan 100 pixels up

print(f"Panning from ({start_x}, {start_y}) to ({end_x}, {end_y})...", flush=True)

# 1. Right button down
lParam_start = (start_y << 16) | start_x
win32gui.SendMessage(chart_hwnd, win32con.WM_RBUTTONDOWN, win32con.MK_RBUTTON, lParam_start)
time.sleep(0.1)

# 2. Mouse move with right button held
lParam_end = (end_y << 16) | end_x
win32gui.SendMessage(chart_hwnd, win32con.WM_MOUSEMOVE, win32con.MK_RBUTTON, lParam_end)
time.sleep(0.1)

# 3. Right button up
win32gui.SendMessage(chart_hwnd, win32con.WM_RBUTTONUP, 0, lParam_end)
time.sleep(0.5)

# Terminate process to release log
proc.terminate()
time.sleep(0.5)

# Analyze log for limits
print("\nAnalyzing log for PerfAxis1D and PerfAxis2D limits before and after pan:", flush=True)
with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()

axis_states = []
for line in lines:
    if "Axis: PerfAxis" in line:
        axis_states.append(line.strip())

# Find first states and last states
first_1d = None
first_2d = None
last_1d = None
last_2d = None

for state in axis_states:
    if "PerfAxis1DAxisY" in state:
        if first_1d is None:
            first_1d = state
        last_1d = state
    elif "PerfAxis2DAxisY" in state:
        if first_2d is None:
            first_2d = state
        last_2d = state

print(f"PerfAxis1D Initial: {first_1d}", flush=True)
print(f"PerfAxis1D Final:   {last_1d}", flush=True)
print(f"PerfAxis2D Initial: {first_2d}", flush=True)
print(f"PerfAxis2D Final:   {last_2d}", flush=True)

# Verify isolation
def parse_limits(state_str):
    parts = state_str.split("MinValue=")[1].split(" MaxValue=")
    min_val = float(parts[0].replace(",", "."))
    max_val = float(parts[1].replace(",", "."))
    return min_val, max_val

min1_i, max1_i = parse_limits(first_1d)
min1_f, max1_f = parse_limits(last_1d)
min2_i, max2_i = parse_limits(first_2d)
min2_f, max2_f = parse_limits(last_2d)

print(f"\nPerfAxis1D MinValue: Initial={min1_i:.4f}, Final={min1_f:.4f}", flush=True)
print(f"PerfAxis2D MinValue: Initial={min2_i:.4f}, Final={min2_f:.4f}", flush=True)

if abs(min1_f - min1_i) > 0.01 and abs(min2_f - min2_i) < 1e-7:
    print("\nPan isolation verification: SUCCESS!", flush=True)
    sys.exit(0)
else:
    print("\nPan isolation verification: FAILED!", flush=True)
    sys.exit(1)
