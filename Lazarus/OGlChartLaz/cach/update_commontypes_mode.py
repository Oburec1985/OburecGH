import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\uCommonTypes.pas"

print(f"Modifying {os.path.basename(FILE_PATH)} compiler mode...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

# Replace modeswitch and objfpc mode with delphi mode
raw = raw.replace(b"{$mode objfpc}{$H+}", b"{$mode delphi}{$H+}")
raw = raw.replace(b"{$modeswitch advancedrecords}", b"")

with open(FILE_PATH, 'wb') as f:
    f.write(raw)

print("File saved successfully.")
