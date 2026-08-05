# -*- coding: utf-8 -*-
import sys
import os
import time
import subprocess
import win32gui
import win32process
import win32con
from PIL import ImageGrab
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

# Read original
with io.open(file_path, "r", encoding="cp1251") as f:
    orig_content = f.read()

# Comment out other page additions to isolate PagePerf
temp_content = orig_content
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageTrend);", "// OglChart1.Model.AddChild(lPageTrend);")
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageSignals);", "// OglChart1.Model.AddChild(lPageSignals);")
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageBars);", "// OglChart1.Model.AddChild(lPageBars);")
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageOwnX);", "// OglChart1.Model.AddChild(lPageOwnX);")

# Write temporary
with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(temp_content)

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

try:
    print("Compiling isolated performance project...")
    os.system(r"c:\lazarus\lazbuild.exe c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1.lpi > nul")
    
    # Minimize Lazarus IDE windows to make room
    def minimize_lazarus(hwnd, extra):
        title = win32gui.GetWindowText(hwnd)
        if "Lazarus" in title:
            win32gui.ShowWindow(hwnd, win32con.SW_MINIMIZE)
    win32gui.EnumWindows(minimize_lazarus, None)
    time.sleep(0.5)

    print("Running project1_test.exe...")
    proc = subprocess.Popen([r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"])
    pid = proc.pid
    time.sleep(3.0)
    
    hwnd = find_hwnd_for_pid(pid)
    if hwnd:
        win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 50, 50, 1000, 700, win32con.SWP_SHOWWINDOW)
        time.sleep(0.5)
        try:
            win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
            win32gui.SetForegroundWindow(hwnd)
        except Exception:
            pass
        time.sleep(1.0)
        
        rect = win32gui.GetWindowRect(hwnd)
        left, top, right, bottom = rect
        
        # Grab screenshot
        img = ImageGrab.grab(bbox=(left, top, right, bottom))
        img.save(r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\perf_isolated.png")
        print("Saved perf_isolated.png")
        
        proc.terminate()
        time.sleep(1.0)
    else:
        print("Error: HWND not found for PID", pid)
        proc.terminate()
        
finally:
    # Restore original file
    print("Restoring original unit1.pas...")
    with io.open(file_path, "w", encoding="cp1251", newline="") as f:
        f.write(orig_content)
    
    # Rebuild original
    print("Rebuilding original project...")
    os.system(r"c:\lazarus\lazbuild.exe c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1.lpi > nul")
    
    # Restore Lazarus IDE windows
    def restore_lazarus(hwnd, extra):
        title = win32gui.GetWindowText(hwnd)
        if "Lazarus" in title:
            win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
    win32gui.EnumWindows(restore_lazarus, None)
    print("Done!")
