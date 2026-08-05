import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\uCommonTypes.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

# Replace uses block
raw = raw.replace(b"uses\r\n  Classes, SysUtils, Types;", b"uses\r\n  Classes, SysUtils, Types, Math;")
raw = raw.replace(b"uses\n  Classes, SysUtils, Types;", b"uses\n  Classes, SysUtils, Types, Math;")

with open(FILE_PATH, 'wb') as f:
    f.write(raw)

print("File saved successfully.")
