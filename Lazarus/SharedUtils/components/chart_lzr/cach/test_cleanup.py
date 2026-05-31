# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartSelectListener.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    lines = f.read().splitlines()

print("Original line count: %d" % len(lines))

# Run the cleanup logic
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

print("Cleaned line count (de-double-spaced): %d" % len(cleaned))

for j in range(min(25, len(cleaned))):
    print("%d: %r" % (j, cleaned[j]))
