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

# Start the application with environment variable CHART_TEST_SELECT_AXIS=1
app_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
env = os.environ.copy()
env["CHART_TEST_SELECT_AXIS"] = "1"
proc = subprocess.Popen(app_path, env=env, cwd=os.path.dirname(app_path))
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

# Show window and make it topmost
win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 100, 100, 1000, 600, win32con.SWP_SHOWWINDOW)
time.sleep(0.5)

form_rect = win32gui.GetWindowRect(hwnd)

# Locate Chart and Edit controls
chart_hwnd = None
edit_hwnd = None

children = []
win32gui.EnumChildWindows(hwnd, lambda h, _: children.append(h), None)
for h in children:
    cls = win32gui.GetClassName(h)
    r = win32gui.GetWindowRect(h)
    w = r[2] - r[0]
    rel_left = r[0] - form_rect[0]
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

# Check Edit text using standard win32gui.GetWindowText to confirm PerfAxis1D is selected
val = win32gui.GetWindowText(edit_hwnd)
print(f"Selected object text on startup: '{val}'", flush=True)

if "PerfAxis1D" not in val:
    print("Error: PerfAxis1D was not successfully selected on startup!", flush=True)
    proc.terminate()
    sys.exit(1)

# Now capture screenshot of selected state
from PIL import ImageGrab
bbox = win32gui.GetWindowRect(hwnd)
img_sel = ImageGrab.grab(bbox)
img_sel.save(r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\axis_selected.png")
print("Saved axis_selected.png", flush=True)

# Now perform zoom (mouse wheel) inside PagePerf chart content area
# Get chart rect relative to form
chart_rect = win32gui.GetWindowRect(chart_hwnd)
chart_left = chart_rect[0] - form_rect[0]
chart_top = chart_rect[1] - form_rect[1]
chart_w = chart_rect[2] - chart_rect[0]
chart_h = chart_rect[3] - chart_rect[1]

# PagePerf is in the lower-middle part of the chart area.
# Vertically, PagePerf is at 0.66 to 0.98. Let's aim at Y=0.8
# Horizontally, PagePerf is at 0.01 to 0.99. Let's aim at X=0.5
chart_x = int(chart_left + chart_w * 0.5)
chart_y = int(chart_top + chart_h * 0.8)

screen_x = form_rect[0] + chart_x
screen_y = form_rect[1] + chart_y
lParam = (screen_y << 16) | screen_x

# Hover first on chart
win32gui.SendMessage(chart_hwnd, win32con.WM_MOUSEMOVE, 0, (chart_y << 16) | chart_x)
time.sleep(0.1)

# Scroll mouse wheel up (zoom in)
print("Sending MouseWheel Zoom-In to chart...", flush=True)
win32gui.SendMessage(chart_hwnd, win32con.WM_MOUSEWHEEL, (120 << 16), lParam)
time.sleep(0.2)
win32gui.SendMessage(chart_hwnd, win32con.WM_MOUSEWHEEL, (120 << 16), lParam)
time.sleep(0.5)

# Capture zoomed screenshot
img_zoom = ImageGrab.grab(bbox)
img_zoom.save(r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\axis_zoomed.png")
print("Saved axis_zoomed.png", flush=True)

# Terminate process to release log
proc.terminate()
time.sleep(0.5)

# Analyze log for limits
print("\nAnalyzing log for PerfAxis1D and PerfAxis2D limits before and after zoom:", flush=True)
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
    if "PerfAxis1D" in state:
        if first_1d is None:
            first_1d = state
        last_1d = state
    elif "PerfAxis2D" in state:
        if first_2d is None:
            first_2d = state
        last_2d = state

print(f"PerfAxis1D Initial: {first_1d}", flush=True)
print(f"PerfAxis1D Final:   {last_1d}", flush=True)
print(f"PerfAxis2D Initial: {first_2d}", flush=True)
print(f"PerfAxis2D Final:   {last_2d}", flush=True)

# Verify zoom isolation
def parse_limits(state_str):
    parts = state_str.split("MinValue=")[1].split(" MaxValue=")
    min_val = float(parts[0].replace(",", "."))
    max_val = float(parts[1].replace(",", "."))
    return min_val, max_val

min1_i, max1_i = parse_limits(first_1d)
min1_f, max1_f = parse_limits(last_1d)
min2_i, max2_i = parse_limits(first_2d)
min2_f, max2_f = parse_limits(last_2d)

print(f"\nPerfAxis1D Range: Initial={max1_i - min1_i:.4f}, Final={max1_f - min1_f:.4f}", flush=True)
print(f"PerfAxis2D Range: Initial={max2_i - min2_i:.4f}, Final={max2_f - min2_f:.4f}", flush=True)

if (max1_f - min1_f) < (max1_i - min1_i - 0.05) and abs((max2_f - min2_f) - (max2_i - min2_i)) < 1e-7:
    print("\nZoom isolation verification: SUCCESS!", flush=True)
else:
    print("\nZoom isolation verification: FAILED!", flush=True)
