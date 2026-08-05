# -*- coding: utf-8 -*-
import subprocess
import time
from PIL import ImageGrab
import os
import win32gui
import win32con
import win32process

exe_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"

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
    
    # Grab screenshot
    img = ImageGrab.grab(bbox=(left, top, right, bottom))
    img.save(r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\startup_state_fresh.png")
    print("Saved startup_state_fresh.png")
else:
    print("Could not find window!")

# Terminate
proc.terminate()
try:
    proc.wait(timeout=2)
except:
    proc.kill()
print("Done.")
