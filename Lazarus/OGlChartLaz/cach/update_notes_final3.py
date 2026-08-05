import os

NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

with open(NOTES_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('utf-8')

new_notes = """
9. **Типы интерполяции и перемещение вершин тренда**:
   - Исправлена критическая ошибка в `TChartPanZoomListener.MouseMove`, где переменная `fIsDraggingPoint` ошибочно сбрасывалась в `False` в самом начале метода. Это мешало перетаскиванию вершин Безье. Сброс перенесен в `MouseUp`, и теперь вершины плавно перетаскиваются мышкой.
   - Реализована обработка нажатия клавиш в методе `KeyPress` слушателя `TChartSelectListener`. При выделении вершины тренда пользователь может изменять её тип интерполяции на лету:
     - `'1'` — `bptCorner` (линейная)
     - `'2'` — `bptSmooth` (гладкая, кубический сплайн Безье)
     - `'3'` — `bptNull` (ступенчатая)
     - `'T'` / `'t'` — циклическое переключение типа
   - Внедрена наглядная отрисовка вершин Безье разной формы в методе `TOpenGLChartRenderer.DrawTrendPoints`:
     - `bptCorner` (линейная) — классический Квадрат (GL_QUADS)
     - `bptSmooth` (гладкая) — Ромб (GL_QUADS с повернутыми вершинами)
     - `bptNull` (ступенчатая) — Треугольник (GL_TRIANGLES)
"""

content = content.strip() + "\n" + new_notes.strip() + "\n"

with open(NOTES_PATH, 'wb') as f:
    f.write(content.encode('utf-8'))

print("Updated notes_current.md successfully.")
