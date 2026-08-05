# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

# Read in cp1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

target_shader_block = """  // Шейдер для рендеринга 2D-линий с поддержкой логарифмических шкал по X/Y
  SHADER_LINE_LG_VERT =
    'uniform vec4 a_minmax;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(max(x, 1e-10))/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range, test;'#10 +
    '  gl_Position = gl_Vertex;'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg[0] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[1]);'#10 +
    '    if (a_minmax[0] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[0]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[1] - a_minmax[0];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[0] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[0] = a_minmax[0] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[0]) - lgMin) * lgRange;'#10 +
    '      gl_Position[0] = range * rate + a_minmax[0];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  if (a_Lg[1] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[3]);'#10 +
    '    if (a_minmax[2] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[2]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[3] - a_minmax[2];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[1] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[1] = a_minmax[2] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[1]) - lgMin) * lgRange;'#10 +
    '      gl_Position[1] = range * rate + a_minmax[2];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;'#10 +
    '}';
  // Шейдер для рендеринга одномерных буферизованных данных
  SHADER_LINE_LG_1D_VERT =
    '#version 130'#10 +
    'uniform vec4 a_minmax;'#10 +
    'uniform vec2 a_LinePar;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(max(x, 1e-10))/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range, test;'#10 +
    '  gl_Position = gl_Vertex;'#10 +
    '  gl_Position[0] = a_LinePar[0] + a_LinePar[1] * gl_Vertex[1];'#10 +
    '  gl_Position[1] = gl_Vertex[0];'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg[0] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[1]);'#10 +
    '    if (a_minmax[0] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[0]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[1] - a_minmax[0];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[0] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[0] = a_minmax[0] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[0]) - lgMin) * lgRange;'#10 +
    '      gl_Position[0] = range * rate + a_minmax[0];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  if (a_Lg[1] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[3]);'#10 +
    '    if (a_minmax[2] <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax[2]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[3] - a_minmax[2];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[1] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[1] = a_minmax[2] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[1]) - lgMin) * lgRange;'#10 +
    '      gl_Position[1] = range * rate + a_minmax[2];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;'#10 +
    '}';"""

replacement_shader_block = """  // Шейдер для рендеринга 2D-линий с поддержкой логарифмических шкал по X/Y
  SHADER_LINE_LG_VERT =
    'uniform vec4 a_minmax;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(max(x, 1e-10))/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range;'#10 +
    '  vec4 pos = gl_Vertex;'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg.x == 1) {'#10 +
    '    lgMax = Log10(a_minmax.y);'#10 +
    '    if (a_minmax.x <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax.x);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax.y - a_minmax.x;'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (pos.x <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      pos.x = a_minmax.x - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(pos.x) - lgMin) * lgRange;'#10 +
    '      pos.x = range * rate + a_minmax.x;'#10 +
    '    }'#10 +
    '  }'#10 +
    '  if (a_Lg.y == 1) {'#10 +
    '    lgMax = Log10(a_minmax.w);'#10 +
    '    if (a_minmax.z <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax.z);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax.w - a_minmax.z;'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (pos.y <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      pos.y = a_minmax.z - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(pos.y) - lgMin) * lgRange;'#10 +
    '      pos.y = range * rate + a_minmax.z;'#10 +
    '    }'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * pos;'#10 +
    '}';
  // Шейдер для рендеринга одномерных буферизованных данных
  SHADER_LINE_LG_1D_VERT =
    'uniform vec4 a_minmax;'#10 +
    'uniform vec2 a_LinePar;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(max(x, 1e-10))/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range;'#10 +
    '  vec4 pos = gl_Vertex;'#10 +
    '  pos.x = a_LinePar.x + a_LinePar.y * gl_Vertex.y;'#10 +
    '  pos.y = gl_Vertex.x;'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg.x == 1) {'#10 +
    '    lgMax = Log10(a_minmax.y);'#10 +
    '    if (a_minmax.x <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax.x);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax.y - a_minmax.x;'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (pos.x <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      pos.x = a_minmax.x - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(pos.x) - lgMin) * lgRange;'#10 +
    '      pos.x = range * rate + a_minmax.x;'#10 +
    '    }'#10 +
    '  }'#10 +
    '  if (a_Lg.y == 1) {'#10 +
    '    lgMax = Log10(a_minmax.w);'#10 +
    '    if (a_minmax.z <= 0.0) lgMin = -10.0;'#10 +
    '    else lgMin = Log10(a_minmax.z);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax.w - a_minmax.z;'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (pos.y <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      pos.y = a_minmax.z - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(pos.y) - lgMin) * lgRange;'#10 +
    '      pos.y = range * rate + a_minmax.z;'#10 +
    '    }'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * pos;'#10 +
    '}';"""

def norm(txt):
    return txt.replace("\r\n", "\n").replace("\r", "\n").replace("\n", "\r\n")

content = content.replace(norm(target_shader_block), norm(replacement_shader_block))

# Save back in cp1251
with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Shaders patch applied successfully!")
