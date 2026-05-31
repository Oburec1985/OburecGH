# -*- coding: utf-8 -*-
import subprocess
import time
from PIL import ImageGrab
import os
import win32gui
import win32con
import win32process

exe_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
screenshot_path = r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\gui_screenshot.png"

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
            title = win32gui.GetWindowText(hwnd)
            print(f"Found window for process {pid}: HWND={hwnd}, Title='{title}'")
            hwnd_to_focus = hwnd

win32gui.EnumWindows(enum_windows_callback, None)

if hwnd_to_focus:
    print(f"Bringing HWND {hwnd_to_focus} to topmost...")
    try:
        # Show and restore window if minimized
        win32gui.ShowWindow(hwnd_to_focus, win32con.SW_RESTORE)
        # Bring to topmost
        win32gui.SetWindowPos(hwnd_to_focus, win32con.HWND_TOPMOST, 0, 0, 0, 0, 
                             win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW)
    except Exception as e:
        print(f"Failed to position window: {e}")
    time.sleep(1.0) # Wait for window to render in foreground
else:
    print("Could not find window for process!")

# Capture the screen
print("Capturing screenshot...")
screenshot = ImageGrab.grab()
screenshot.save(screenshot_path)
print(f"Screenshot saved to {screenshot_path}")

# Terminate the application
print("Terminating project1_test.exe...")
proc.terminate()
try:
    proc.wait(timeout=2)
except subprocess.TimeoutExpired:
    proc.kill()
print("Done.")
