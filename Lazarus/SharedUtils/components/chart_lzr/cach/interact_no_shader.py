# -*- coding: utf-8 -*-
import sys
import os
import time
import win32gui
import win32con
import win32api
from PIL import ImageGrab

def get_child_windows(parent):
    res = []
    def callback(hwnd, extra):
        title = win32gui.GetWindowText(hwnd)
        cls = win32gui.GetClassName(hwnd)
        res.append((hwnd, title, cls))
        return True
    win32gui.EnumChildWindows(parent, callback, None)
    return res

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
    
    rect = win32gui.GetWindowRect(hwnd)
    left, top, right, bottom = rect
    width = right - left
    height = bottom - top
    print("Window rect: %s, size: %dx%d" % (rect, width, height))
    
    children = get_child_windows(hwnd)
    print("Child windows:")
    for child in children:
        print(child)
        
    # Let's find "Использовать шейдеры" checkbox.
    # In Lazarus LCL, standard checkboxes might be windowless or might have class "Window" or custom.
    # If not found, let's click using relative coordinates:
    # Right panel is on the right. Usually it takes about 250px on the right.
    # Checkboxes are located on PanelLogControls which is on the bottom right.
    # Let's find "Использовать шейдеры" using its text:
    cb_hwnd = 0
    for h, title, cls in children:
        if "шейдер" in title.lower() or "shader" in title.lower():
            cb_hwnd = h
            break
            
    if cb_hwnd:
        print("Found checkbox handle: %s" % cb_hwnd)
        c_rect = win32gui.GetWindowRect(cb_hwnd)
        cx = (c_rect[0] + c_rect[2]) // 2
        cy = (c_rect[1] + c_rect[3]) // 2
        win32api.SetCursorPos((cx, cy))
        time.sleep(0.2)
        win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        time.sleep(0.1)
        win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
    else:
        # Fallback click: bottom-right area.
        # Let's find PanelLogControls or check standard relative coords:
        # In a 1000x500 window, PanelLogControls is around bottom-right (e.g. x = width - 150, y = height - 80).
        # Let's try x = left + width - 150, y = top + height - 80
        cx = left + width - 150
        cy = top + height - 85
        win32api.SetCursorPos((cx, cy))
        time.sleep(0.2)
        win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
        time.sleep(0.1)
        win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        
    time.sleep(1.0)
    
    # Grab screenshot
    img = ImageGrab.grab(bbox=(left, top, right, bottom))
    img.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\no_shader.png")
    print("Saved no_shader.png")
    
    # Close application
    win32gui.PostMessage(hwnd, win32con.WM_CLOSE, 0, 0)
    time.sleep(1.0)

if __name__ == "__main__":
    run_test()
