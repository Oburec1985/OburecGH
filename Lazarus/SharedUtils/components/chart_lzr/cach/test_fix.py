# -*- coding: utf-8 -*-
import io

fp = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartSelectListener.pas"

# Read binary first to see the actual raw bytes currently in the file
with open(fp, "rb") as f:
    raw = f.read()
print("Raw bytes length: %d" % len(raw))

# Decode raw bytes from cp1251, replacing any \r\n with \n, and any \r with \n
content = raw.decode("cp1251")
content_clean = content.replace("\r\n", "\n").replace("\r", "\n")

# Now splitlines on the clean content
lines = content_clean.split("\n")
if lines and lines[-1] == "":
    lines.pop()

print("Clean lines count: %d" % len(lines))

# Write this clean content back with newline='\r\n' and join with '\n'
with io.open(fp, "w", encoding="cp1251", newline="\r\n") as f:
    f.write("\n".join(lines) + "\n")

# Read back using splitlines to verify
with io.open(fp, "r", encoding="cp1251") as f:
    reread = f.read().splitlines()
print("Re-read line count: %d" % len(reread))

# Inspect first 20 lines
for i in range(min(20, len(reread))):
    print("%d: %r" % (i, reread[i]))
