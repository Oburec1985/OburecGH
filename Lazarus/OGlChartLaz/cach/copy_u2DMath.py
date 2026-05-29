import os

SRC_PATH = r"c:\Oburec\OburecGH\sharedUtils\math\u2DMath.pas"
DST_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\u2DMath.pas"

print(f"Copying {SRC_PATH} to {DST_PATH}...")
with open(SRC_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251
text = raw_data.decode('cp1251')

# Normalize newlines to CRLF
text = text.replace('\r\n', '\n').replace('\r', '\n').replace('\n', '\r\n')

# Write to destination
with open(DST_PATH, 'wb') as f:
    f.write(text.encode('cp1251'))

print("Copy completed successfully.")
