# -*- coding: utf-8 -*-
import io
import sys

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

# Read the file in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Normalize CRLF
content_normalized = content.replace('\r\n', '\n')

action = "comment"
if len(sys.argv) > 1:
    action = sys.argv[1]

target_lines = [
    "  AddFrameListener(TChartPageGeometryListener.Create);",
    "  AddFrameListener(TChartVertexEditListener.Create);",
    "  AddFrameListener(TChartLabelEditListener.Create);"
]

if action == "comment":
    for line in target_lines:
        commented = "  //" + line.strip()
        if line in content_normalized:
            content_normalized = content_normalized.replace(line, commented)
            print("Commented out: %s" % line.strip())
        else:
            print("Already commented or not found: %s" % line.strip())
elif action == "uncomment":
    for line in target_lines:
        commented = "  //" + line.strip()
        if commented in content_normalized:
            content_normalized = content_normalized.replace(commented, line)
            print("Uncommented: %s" % line.strip())
        else:
            print("Already uncommented or not found: %s" % commented.strip())

# Restore CRLF
content = content_normalized.replace('\n', '\r\n')

# Write back in CP1251
with io.open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
    f.write(content)

print("Finished toggling listeners in uoglchart.pas")
