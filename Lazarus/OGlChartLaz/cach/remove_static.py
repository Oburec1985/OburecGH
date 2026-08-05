import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\uCommonTypes.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

# Replace static; in class operators
raw = raw.replace(b"; static;", b";")

with open(FILE_PATH, 'wb') as f:
    f.write(raw)

print("File saved successfully.")
