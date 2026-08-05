# -*- coding: utf-8 -*-
import sys
import os
import time
import subprocess
import win32gui
import win32process
import win32con
import win32api
from PIL import ImageGrab

def find_hwnd_for_pid(pid):
    result = []
    def callback(hwnd, extra):
        if win32gui.IsWindowVisible(hwnd):
            _, win_pid = win32process.GetWindowThreadProcessId(hwnd)
            if win_pid == pid:
                title = win32gui.GetWindowText(hwnd)
                if title:
                    result.append(hwnd)
    win32gui.EnumWindows(callback, None)
    return result[0] if result else None

def force_foreground(hwnd):
    # Try multiple ways to bring window to foreground
    try:
        win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
        win32gui.SetForegroundWindow(hwnd)
    except Exception:
        pass
    try:
        win32gui.BringWindowToTop(hwnd)
    except Exception:
        pass

def run_test():
    # Let's first minimize Lazarus IDE windows to make room
    def minimize_lazarus(hwnd, extra):
        title = win32gui.GetWindowText(hwnd)
        if "Lazarus" in title:
            win32gui.ShowWindow(hwnd, win32con.SW_MINIMIZE)
    win32gui.EnumWindows(minimize_lazarus, None)
    time.sleep(0.5)

    cmd = [r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"]
    proc = subprocess.Popen(cmd)
    pid = proc.pid
    print("Started process with PID:", pid)
    time.sleep(3.0)
    
    hwnd = find_hwnd_for_pid(pid)
    if not hwnd:
        print("Error: HWND not found for PID", pid)
        proc.terminate()
        return
        
    print("Found HWND:", hwnd, "Title:", win32gui.GetWindowText(hwnd))
    
    # Position the window at (50, 50, 1000, 700)
    win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 50, 50, 1000, 700, win32con.SWP_SHOWWINDOW)
    time.sleep(0.5)
    force_foreground(hwnd)
    time.sleep(1.0)
    
    rect = win32gui.GetWindowRect(hwnd)
    left, top, right, bottom = rect
    print("Rect to grab:", left, top, right, bottom)
    
    # Grab screenshot
    img = ImageGrab.grab(bbox=(left, top, right, bottom))
    img.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\perf_by_pid.png")
    print("Saved perf_by_pid.png")
    
    # Terminate process
    proc.terminate()
    time.sleep(1.0)

    # Restore Lazarus IDE windows
    def restore_lazarus(hwnd, extra):
        title = win32gui.GetWindowText(hwnd)
        if "Lazarus" in title:
            win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
    win32gui.EnumWindows(restore_lazarus, None)

if __name__ == "__main__":
    run_test()
