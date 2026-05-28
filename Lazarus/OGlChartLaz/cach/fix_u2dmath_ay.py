import os

MATH_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\math\u2DMath.pas"

print("Fixing duplicate identifier by using Ay inside GoldenSectionSearch body...")

with open(MATH_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Restore Ay in the signature
target_sig = "function GoldenSectionSearch(a, b, Tolerance: Double; Func: TFunc; px, py, A, x0, fA, y0: Double): Double;"
replacement_sig = "function GoldenSectionSearch(a, b, Tolerance: Double; Func: TFunc; px, py, Ay, x0, fA, y0: Double): Double;"

if target_sig in content_lf:
    content_lf = content_lf.replace(target_sig, replacement_sig)
    print("Reverted signature parameter to Ay.")
else:
    # If the previous change didn't apply or was different, we try to make sure it's the correct one
    print("Warning: target_sig not found, checking if already correct...")

# 2. Replace A with Ay inside the while loop calls
target_body = """  while (b - a) > Tolerance do
  begin
    fc := Func(c, px, py, A, x0, fA, y0);
    fd := Func(d, px, py, A, x0, fA, y0);"""

replacement_body = """  while (b - a) > Tolerance do
  begin
    fc := Func(c, px, py, Ay, x0, fA, y0);
    fd := Func(d, px, py, Ay, x0, fA, y0);"""

if target_body in content_lf:
    content_lf = content_lf.replace(target_body, replacement_body)
    print("Func calls inside GoldenSectionSearch updated to use Ay.")
else:
    print("Warning: target_body not found!")

with open(MATH_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
