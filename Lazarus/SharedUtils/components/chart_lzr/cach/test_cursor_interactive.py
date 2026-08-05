# -*- coding: utf-8 -*-
import subprocess
import time
import win32gui
import win32con
import win32api
import os
import sys
from PIL import ImageGrab

# 1. Clean logs if any
log_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\chart_events.log"
if os.path.exists(log_path):
    try:
        os.remove(log_path)
    except:
        pass

app_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
proc = subprocess.Popen(app_path, cwd=os.path.dirname(app_path))
time.sleep(2.0)

# Find Form1
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

# Make window topmost and show it
win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 50, 50, 1000, 650, win32con.SWP_SHOWWINDOW)
time.sleep(1.0)

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

if not chart_hwnd:
    print("Failed to detect chart control!", flush=True)
    proc.terminate()
    sys.exit(1)

# Click chart to focus it
chart_rect = win32gui.GetWindowRect(chart_hwnd)
chart_w = chart_rect[2] - chart_rect[0]
chart_h = chart_rect[3] - chart_rect[1]

# We click on the upper half where PageSine/PageBars is. Let's aim at X=0.3, Y=0.3
click_x = chart_rect[0] + int(chart_w * 0.3)
click_y = chart_rect[1] + int(chart_h * 0.3)

win32api.SetCursorPos((click_x, click_y))
time.sleep(0.2)
win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
time.sleep(0.1)
win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
time.sleep(0.5)

# Send Alt+3 to toggle cursor on (single mode)
print("Sending Alt+3 key combination...", flush=True)
win32api.keybd_event(win32con.VK_MENU, 0, 0, 0) # Alt down
time.sleep(0.1)
win32api.keybd_event(ord('3'), 0, 0, 0) # '3' down
time.sleep(0.1)
win32api.keybd_event(ord('3'), 0, win32con.KEYEVENTF_KEYUP, 0) # '3' up
time.sleep(0.1)
win32api.keybd_event(win32con.VK_MENU, 0, win32con.KEYEVENTF_KEYUP, 0) # Alt up
time.sleep(1.0)

# Capture screenshot with cursor enabled
bbox = win32gui.GetWindowRect(hwnd)
img_enabled = ImageGrab.grab(bbox)
img_enabled.save(r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\cursor_enabled.png")
print("Saved cursor_enabled.png", flush=True)

# Cursor is default at X1=0.0. Since X range is -50 to 50, X1=0.0 is exactly in the center of the page!
# Let's drag the cursor line from the center (X=0.5, Y=0.3) to the right (X=0.6, Y=0.3)
drag_start_x = chart_rect[0] + int(chart_w * 0.5)
drag_start_y = chart_rect[1] + int(chart_h * 0.3)
drag_end_x = chart_rect[0] + int(chart_w * 0.6)
drag_end_y = chart_rect[1] + int(chart_h * 0.3)

print(f"Dragging cursor from ({drag_start_x}, {drag_start_y}) to ({drag_end_x}, {drag_end_y})...", flush=True)
win32api.SetCursorPos((drag_start_x, drag_start_y))
time.sleep(0.5)
win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
time.sleep(0.2)
win32api.SetCursorPos((drag_end_x, drag_end_y))
time.sleep(0.5)
win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
time.sleep(1.0)

# Capture screenshot after drag
img_dragged = ImageGrab.grab(bbox)
img_dragged.save(r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\cursor_dragged.png")
print("Saved cursor_dragged.png", flush=True)

# Now, let's test dragging the label (flag).
# The flag is initially aligned with the cursor line (left edge at AXPixel+2)
# and vertically at LabelY1Offset * height (default 0.5).
# So the flag is at X = drag_end_x + some pixels, Y = drag_start_y.
# Let's drag it vertically from drag_start_y to a lower position (Y=0.4)
label_drag_start_x = drag_end_x + 15
label_drag_start_y = drag_start_y
label_drag_end_y = chart_rect[1] + int(chart_h * 0.4)

print(f"Dragging label from ({label_drag_start_x}, {label_drag_start_y}) to ({label_drag_start_x}, {label_drag_end_y})...", flush=True)
win32api.SetCursorPos((label_drag_start_x, label_drag_start_y))
time.sleep(0.5)
win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
time.sleep(0.2)
win32api.SetCursorPos((label_drag_start_x, label_drag_end_y))
time.sleep(0.5)
win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
time.sleep(1.0)

# Capture screenshot after label drag
img_label_dragged = ImageGrab.grab(bbox)
img_label_dragged.save(r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\cursor_label_dragged.png")
print("Saved cursor_label_dragged.png", flush=True)

proc.terminate()
print("Interactive cursor test completed successfully.")
