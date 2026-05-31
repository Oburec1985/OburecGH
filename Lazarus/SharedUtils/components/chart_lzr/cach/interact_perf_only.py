# -*- coding: utf-8 -*-
import sys
import os
import time
import win32gui
import win32con
from PIL import ImageGrab
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

# Read original
with io.open(file_path, "r", encoding="cp1251") as f:
    orig_content = f.read()

# Comment out other page additions
temp_content = orig_content
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageTrend);", "// OglChart1.Model.AddChild(lPageTrend);")
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageSignals);", "// OglChart1.Model.AddChild(lPageSignals);")
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageBars);", "// OglChart1.Model.AddChild(lPageBars);")
temp_content = temp_content.replace("OglChart1.Model.AddChild(lPageOwnX);", "// OglChart1.Model.AddChild(lPageOwnX);")

# Write temporary
with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(temp_content)

try:
    # Build
    print("Compiling project with only PagePerf...")
    os.system(r"c:\lazarus\lazbuild.exe c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1.lpi > nul")
    
    # Run
    print("Running project1_test.exe...")
    os.system(r"start c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe")
    time.sleep(3.0)
    
    hwnd = win32gui.FindWindow(None, "Form1")
    if hwnd:
        win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
        try:
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
        
        # Close app
        win32gui.PostMessage(hwnd, win32con.WM_CLOSE, 0, 0)
        time.sleep(1.0)
    else:
        print("Error: Form1 window not found")
        
finally:
    # Restore original file
    print("Restoring original unit1.pas...")
    with io.open(file_path, "w", encoding="cp1251", newline="") as f:
        f.write(orig_content)
    
    # Rebuild original
    print("Rebuilding original project...")
    os.system(r"c:\lazarus\lazbuild.exe c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1.lpi > nul")
    print("Done!")
