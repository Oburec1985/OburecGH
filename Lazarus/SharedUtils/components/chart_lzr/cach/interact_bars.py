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
    time.sleep(2.0)
    
    hwnd = win32gui.FindWindow(None, "Form1")
    if not hwnd:
        print("Error: Form1 window not found")
        return
        
    win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
    win32gui.SetForegroundWindow(hwnd)
    time.sleep(1.0)
    
    rect = get_window_rect(hwnd)
    left, top, right, bottom = rect
    
    x = left + 250
    y = top + 300
    
    # Move mouse to PageBars
    win32api.SetCursorPos((x, y))
    time.sleep(0.5)
    
    # Zoom out
    print("Scrolling mouse wheel down on PageBars...")
    win32api.mouse_event(win32con.MOUSEEVENTF_WHEEL, 0, 0, -120, 0)
    time.sleep(0.5)
    
    # Drag (pan) with Right Button using MOUSEEVENTF_MOVE
    print("Panning on PageBars with Right Mouse Button...")
    win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
    time.sleep(0.2)
    # Move relative dx=150, dy=50
    win32api.mouse_event(win32con.MOUSEEVENTF_MOVE, 150, 50, 0, 0)
    time.sleep(0.2)
    win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
    time.sleep(0.5)
    
    # Grab panned screenshot
    img = ImageGrab.grab(bbox=(left, top, right, bottom))
    img.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\bars_panned.png")
    print("Saved bars_panned.png")
    
    # Close application
    win32gui.PostMessage(hwnd, win32con.WM_CLOSE, 0, 0)
    time.sleep(1.0)

if __name__ == "__main__":
    run_test()
