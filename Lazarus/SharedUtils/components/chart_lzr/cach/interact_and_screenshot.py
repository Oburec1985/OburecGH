# -*- coding: utf-8 -*-
import subprocess
import time
from PIL import ImageGrab
import os
import win32gui
import win32con
import win32process
import win32api

exe_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
os.environ["PATH"] = os.path.dirname(exe_path) + ";" + os.environ.get("PATH", "")

# Start the application
print("Starting project1_test.exe...")
proc = subprocess.Popen([exe_path], cwd=os.path.dirname(exe_path))

# Wait for it to initialize
time.sleep(3.0)

# Find window of this process
hwnd_to_focus = None

def enum_windows_callback(hwnd, extra):
    global hwnd_to_focus
    if win32gui.IsWindowVisible(hwnd):
        _, pid = win32process.GetWindowThreadProcessId(hwnd)
        if pid == proc.pid:
            hwnd_to_focus = hwnd

win32gui.EnumWindows(enum_windows_callback, None)

if hwnd_to_focus:
    print(f"Bringing HWND {hwnd_to_focus} to topmost...")
    win32gui.ShowWindow(hwnd_to_focus, win32con.SW_RESTORE)
    win32gui.SetWindowPos(hwnd_to_focus, win32con.HWND_TOPMOST, 100, 100, 1000, 600, win32con.SWP_SHOWWINDOW)
    time.sleep(1.0)
    
    # Get window rect
    rect = win32gui.GetWindowRect(hwnd_to_focus)
    left, top, right, bottom = rect
    print(f"Window rect: {rect}")
    
    # 1. Scroll on PageTrend (around left + 200, top + 150)
    target_x = left + 200
    target_y = top + 150
    win32api.SetCursorPos((target_x, target_y))
    time.sleep(0.2)
    
    # Send wheel scroll down (out zoom)
    print("Scrolling mouse wheel down...")
    win32api.mouse_event(win32con.MOUSEEVENTF_WHEEL, 0, 0, -120, 0)
    time.sleep(1.0)
    
    # Take screenshot of zoomed out state
    scr_zoomed = ImageGrab.grab()
    scr_zoomed.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\gui_screenshot_zoomed.png")
    print("Saved zoomed screenshot.")
    
    # 2. Let's do fit zoom (double click or Ctrl + drag up-left)
    # Actually let's try right button drag (pan)
    print("Panning...")
    win32api.SetCursorPos((target_x, target_y))
    time.sleep(0.1)
    win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
    time.sleep(0.1)
    # Drag to right
    for i in range(1, 51):
        win32api.SetCursorPos((target_x + i*2, target_y))
        time.sleep(0.01)
    win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
    time.sleep(1.0)
    
    scr_panned = ImageGrab.grab()
    scr_panned.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\gui_screenshot_panned.png")
    print("Saved panned screenshot.")

else:
    print("Could not find window!")

# Terminate
proc.terminate()
try:
    proc.wait(timeout=2)
except:
    proc.kill()
print("Done.")
