# -*- coding: utf-8 -*-
import subprocess
import time
from PIL import ImageGrab
import os

exe_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
screenshot_path = r"C:\Users\User12345\.gemini\antigravity\brain\70e36783-e693-4826-ab53-beef99760b41\gui_screenshot.png"

# Start the application
print("Starting project1_test.exe...")
proc = subprocess.Popen([exe_path], cwd=os.path.dirname(exe_path))

# Wait for it to draw
time.sleep(3.0)

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
