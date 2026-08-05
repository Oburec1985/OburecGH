# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

# Read in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Target line replacement
target = "'  gl_Position[0] = a_LinePar[0] + a_LinePar[1] * float(gl_VertexID);'#10 +"
replacement = "'  gl_Position[0] = a_LinePar[0] + a_LinePar[1] * gl_Vertex[1];'#10 +"

if target in content:
    content = content.replace(target, replacement)
    with io.open(file_path, "w", encoding="cp1251", newline="") as f:
        f.write(content)
    print("Shader patch successful!")
else:
    print("Error: Target shader string not found!")
