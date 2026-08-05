# -*- coding: utf-8 -*-
import io
import os
import time

fp = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartSelectListener.pas"

# 1. Read
with io.open(fp, "r", encoding="cp1251") as f:
    lines = f.read().splitlines()
print("Read lines: %d" % len(lines))

# 2. Clean
cleaned = []
i = 0
while i < len(lines):
    line = lines[i]
    cleaned.append(line)
    if line.strip() != "":
        if i + 1 < len(lines) and lines[i+1].strip() == "":
            i += 2
            continue
    i += 1

final_lines = []
prev_empty = False
for line in cleaned:
    if line.strip() == "":
        if not prev_empty:
            final_lines.append("")
        prev_empty = True
    else:
        final_lines.append(line)
        prev_empty = False

print("Cleaned line count: %d" % len(final_lines))

# 3. Write
with io.open(fp, "w", encoding="cp1251", newline="\r\n") as f:
    f.write("\r\n".join(final_lines) + "\r\n")

# 4. Verify immediately
time.sleep(0.5)
with io.open(fp, "r", encoding="cp1251") as f:
    reread_lines = f.read().splitlines()
print("Re-read line count immediately: %d" % len(reread_lines))

# 5. Wait a bit more and check again
time.sleep(2.0)
with io.open(fp, "r", encoding="cp1251") as f:
    reread_lines_2 = f.read().splitlines()
print("Re-read line count after 2s: %d" % len(reread_lines_2))
