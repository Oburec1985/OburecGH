import subprocess
import time
import win32gui

proc = subprocess.Popen([r"C:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"])
time.sleep(3.0)

def enum_win(h, _):
    if win32gui.IsWindowVisible(h):
        title = win32gui.GetWindowText(h)
        cls = win32gui.GetClassName(h)
        if title:
            print(f"HWND: {h}, Class: '{cls}', Text: '{title}'")

win32gui.EnumWindows(enum_win, None)
proc.terminate()
print("Scan finished.")
