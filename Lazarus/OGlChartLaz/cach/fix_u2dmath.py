import os

MATH_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\math\u2DMath.pas"

print("Fixing math signature and function reference in u2DMath.pas...")

with open(MATH_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Replace Ay with A in parameter list of GoldenSectionSearch
target_sig = "function GoldenSectionSearch(a, b, Tolerance: Double; Func: TFunc; px, py, Ay, x0, fA, y0: Double): Double;"
replacement_sig = "function GoldenSectionSearch(a, b, Tolerance: Double; Func: TFunc; px, py, A, x0, fA, y0: Double): Double;"

if target_sig in content_lf:
    content_lf = content_lf.replace(target_sig, replacement_sig)
    print("Parameter name 'Ay' replaced with 'A'.")
else:
    print("Warning: target_sig not found!")

# 2. Add address operator @ to SquareDistance in DistanceToExponential
target_call = """  MinX := GoldenSectionSearch(
    XMin, XMax, 1e-6,
    SquareDistance,
    px, py, A, x0, fA, y0
  );"""

replacement_call = """  MinX := GoldenSectionSearch(
    XMin, XMax, 1e-6,
    @SquareDistance,
    px, py, A, x0, fA, y0
  );"""

if target_call in content_lf:
    content_lf = content_lf.replace(target_call, replacement_call)
    print("GoldenSectionSearch call updated with address operator.")
else:
    print("Warning: target_call not found!")

with open(MATH_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
