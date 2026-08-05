import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\uCommonTypes.pas"

print(f"Modifying {os.path.basename(FILE_PATH)} using binary replacement...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

target = b"{$mode objfpc}{$H+}"
replacement = b"{$mode objfpc}{$H+}\r\n{$modeswitch advancedrecords}"

if target in raw:
    raw = raw.replace(target, replacement)
    print("Binary replacement successful.")
else:
    # Try LF only
    target_lf = b"{$mode objfpc}{$H+}"
    replacement_lf = b"{$mode objfpc}{$H+}\n{$modeswitch advancedrecords}"
    if target_lf in raw:
        raw = raw.replace(target_lf, replacement_lf)
        print("Binary replacement (LF) successful.")
    else:
        print("Warning: target directive not found!")

with open(FILE_PATH, 'wb') as f:
    f.write(raw)

print("File saved successfully.")
