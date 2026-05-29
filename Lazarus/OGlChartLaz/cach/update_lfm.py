import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.lfm"

print(f"Modifying {os.path.basename(FILE_PATH)}...")
with open(FILE_PATH, 'rb') as f:
    raw_data = f.read()

# Decode as cp1251 (or utf-8, lfm files are typically UTF-8 or ANSI. Let's decode as cp1251 or default utf-8)
try:
    text = raw_data.decode('utf-8')
    encoding = 'utf-8'
except UnicodeDecodeError:
    text = raw_data.decode('cp1251')
    encoding = 'cp1251'

# Normalize newlines
text = text.replace('\r\n', '\n').replace('\r', '\n')

# 1. Insert Splitter1 before TreeView1
old_treeview_start = "  object TreeView1: TTreeView"
splitter_def = """  object Splitter1: TSplitter
    Left = 987
    Height = 525
    Top = 0
    Width = 5
    Align = alRight
    ResizeAnchor = akRight
  end
"""

if old_treeview_start in text:
    text = text.replace(old_treeview_start, splitter_def + "  object TreeView1: TTreeView")
    print("  Successfully inserted Splitter1 into LFM.")
else:
    print("  FAIL: old_treeview_start not found!")

# 2. Insert StatusBar1 at the end of Form1 (before final end)
# We can find the last "end" of the form component definition
# Let's search for "  end\nend" or similar, or just before the final "end"
# Since ImageList1 is the last component, let's insert it before the very last "end" of the file.
lines = text.split('\n')
if lines[-1] == '':
    lines.pop()

# Check if last line is "end"
if lines[-1].strip() == 'end':
    statusbar_def = """  object StatusBar1: TStatusBar
    Left = 0
    Height = 23
    Top = 502
    Width = 1407
    Panels = <>
  end"""
    lines.insert(-1, statusbar_def)
    text = '\n'.join(lines)
    print("  Successfully inserted StatusBar1 into LFM.")
else:
    print("  FAIL: last line is not 'end'!")

# Restore CRLF line endings
text = text.replace('\n', '\r\n')

# Save file
with open(FILE_PATH, 'w', encoding=encoding, newline='') as f:
    f.write(text)
print("Saved LFM successfully.")
