import subprocess
import time
from PIL import ImageGrab
import os
import ctypes

# Win32 API constants and functions
HWND_TOPMOST = -1
HWND_NOTOPMOST = -2
SWP_NOSIZE = 0x0001
SWP_NOMOVE = 0x0002
SWP_SHOWWINDOW = 0x0040

# Global list to store window handles for our process
process_hwnds = []
target_pid = 0

def enum_windows_callback(hwnd, lParam):
    global target_pid
    if ctypes.windll.user32.IsWindowVisible(hwnd):
        lpdw_process_id = ctypes.c_ulong()
        ctypes.windll.user32.GetWindowThreadProcessId(hwnd, ctypes.byref(lpdw_process_id))
        if lpdw_process_id.value == target_pid:
            # Check window title
            length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
            buff = ctypes.create_unicode_buffer(length + 1)
            ctypes.windll.user32.GetWindowTextW(hwnd, buff, length + 1)
            title = buff.value
            
            # Also get class name
            class_buff = ctypes.create_unicode_buffer(256)
            ctypes.windll.user32.GetClassNameW(hwnd, class_buff, 256)
            class_name = class_buff.value
            
            print(f"Candidate window: HWND={hwnd}, Title='{title}', Class='{class_name}'")
            process_hwnds.append(hwnd)
    return True

def force_foreground(hwnd):
    # Hack to bypass SetForegroundWindow restrictions on Windows
    ctypes.windll.user32.keybd_event(0x12, 0, 0, 0) # Alt down
    ctypes.windll.user32.SetForegroundWindow(hwnd)
    ctypes.windll.user32.keybd_event(0x12, 0, 2, 0) # Alt up
    
    ctypes.windll.user32.ShowWindow(hwnd, 5) # SW_SHOW
    
    # Make it topmost to bring to front
    ctypes.windll.user32.SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_SHOWWINDOW)
    time.sleep(0.5)
    # Revert topmost so it doesn't stay on top forever, but it will remain in front
    ctypes.windll.user32.SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_SHOWWINDOW)

def main():
    global target_pid
    exe_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1_test.exe"
    screenshot_path = r"c:\Oburec\OburecGH\cach\chart_screenshot.png"
    
    if os.path.exists(screenshot_path):
        os.remove(screenshot_path)
        
    print("Starting process...")
    proc = subprocess.Popen([exe_path])
    target_pid = proc.pid
    print(f"Target PID: {target_pid}")
    
    # Wait for the GUI to render
    time.sleep(3)
    
    # Find window
    EnumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)
    ctypes.windll.user32.EnumWindows(EnumWindowsProc(enum_windows_callback), 0)
    
    if process_hwnds:
        print(f"Found process window(s): {process_hwnds}")
        # Bring our window to foreground
        hwnd = process_hwnds[0]
        force_foreground(hwnd)
        time.sleep(1)
    else:
        print("No windows found for this PID.")
        
    print("Taking screenshot...")
    screenshot = ImageGrab.grab()
    screenshot.save(screenshot_path)
    print(f"Screenshot saved to {screenshot_path}")
    
    print("Terminating process...")
    proc.terminate()
    proc.wait()
    print("Done.")

if __name__ == "__main__":
    main()
