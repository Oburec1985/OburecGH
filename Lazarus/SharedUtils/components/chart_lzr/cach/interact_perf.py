# -*- coding: utf-8 -*-
import sys
import os
import time
import win32gui
import win32con
import win32api
from PIL import ImageGrab

def get_window_rect(hwnd):
    return win32gui.GetWindowRect(hwnd)

def run_test():
    cmd = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
    os.system("start " + cmd)
    time.sleep(3.0)
    
    hwnd = win32gui.FindWindow(None, "Form1")
    if not hwnd:
        print("Error: Form1 window not found")
        return
        
    win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
    time.sleep(1.0)
    
    # Try to set foreground window multiple times
    for _ in range(5):
        try:
            win32gui.SetForegroundWindow(hwnd)
            break
        except Exception:
            time.sleep(0.5)
            
    time.sleep(1.5)
    
    rect = get_window_rect(hwnd)
    left, top, right, bottom = rect
    print("Rect to grab:", left, top, right, bottom)
    
    # Grab screenshot
    img = ImageGrab.grab(bbox=(left, top, right, bottom))
    img.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\perf_check.png")
    print("Saved perf_check.png")
    
    # Close application
    win32gui.PostMessage(hwnd, win32con.WM_CLOSE, 0, 0)
    time.sleep(1.0)

if __name__ == "__main__":
    run_test()
