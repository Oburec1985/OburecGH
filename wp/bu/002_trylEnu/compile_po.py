import subprocess
import os

msgfmt = r"C:\Program Files (x86)\dxgettext\msgfmt.exe"
po = "WPExtPack.po"
mo = r"locale\en\LC_MESSAGES\WPExtPack.mo"

# Use a list of arguments for subprocess.run, it handles spaces and quotes automatically
try:
    print(f"Compiling {po} -> {mo}")
    result = subprocess.run([msgfmt, "-o", mo, po], capture_output=True, text=True, timeout=20)
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)
    if result.returncode == 0:
        print("Success!")
    else:
        print("Failed with code:", result.returncode)
except Exception as e:
    print("Error:", e)
