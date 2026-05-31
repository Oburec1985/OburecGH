# -*- coding: utf-8 -*-
import win32gui
import win32process
import psutil

def callback(hwnd, extra):
    title = win32gui.GetWindowText(hwnd)
    if title:
        try:
            _, pid = win32process.GetWindowThreadProcessId(hwnd)
            name = psutil.Process(pid).name()
            if "Form1" in title or "project1" in title or "python" in name.lower():
                print(f"HWND: {hwnd} | Title: '{title}' | PID: {pid} | Process: {name}")
        except Exception:
            pass

win32gui.EnumWindows(callback, None)
