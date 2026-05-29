import os
import shutil

SRC_MATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\u2DMath.pas"
DST_DIR = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\math"
DST_MATH = os.path.join(DST_DIR, "u2DMath.pas")
LPI_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\project1.lpi"

print("Moving math unit and updating project paths...")

# 1. Create directory if not exists
os.makedirs(DST_DIR, exist_ok=True)

# 2. Move file
if os.path.exists(SRC_MATH):
    shutil.move(SRC_MATH, DST_MATH)
    print(f"Moved {SRC_MATH} to {DST_MATH}")
else:
    print("Source math file not found (might already be moved).")

# 3. Update project1.lpi
if os.path.exists(LPI_PATH):
    with open(LPI_PATH, 'rb') as f:
        raw_lpi = f.read()
    content_lpi = raw_lpi.decode('utf-8')
    
    target = '<OtherUnitFiles Value="..\\..\\SharedUtils;..\\..\\SharedUtils\\components\\chart_lzr"/>'
    replacement = '<OtherUnitFiles Value="..\\..\\SharedUtils;..\\..\\SharedUtils\\math;..\\..\\SharedUtils\\components\\chart_lzr"/>'
    
    if target in content_lpi:
        content_lpi = content_lpi.replace(target, replacement)
        print("Search paths updated in project1.lpi.")
    else:
        # Check if already updated
        if replacement in content_lpi:
            print("Project paths already updated.")
        else:
            print("Warning: target SearchPaths string not found!")
            
    with open(LPI_PATH, 'wb') as f:
        f.write(content_lpi.encode('utf-8'))

print("Move and update completed successfully.")
