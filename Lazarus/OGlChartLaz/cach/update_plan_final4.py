import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

# 1. Update plan.md
with open(PLAN_PATH, 'rb') as f:
    raw_p = f.read()
content_p = raw_p.decode('utf-8')

new_step = "- [x] Шаг 43: Реализация отрисовки касательных векторов Безье (gray-линии и серые маркеры в точках Left/Right) для выделенных сглаженных (bptSmooth) вершин в `TOpenGLChartRenderer.DrawTrendPoints`."
content_p = content_p.strip() + "\n" + new_step + "\n"

with open(PLAN_PATH, 'wb') as f:
    f.write(content_p.encode('utf-8'))

# 2. Update notes_current.md
with open(NOTES_PATH, 'rb') as f:
    raw_n = f.read()
content_n = raw_n.decode('utf-8')

new_note = "10. **Отрисовка касательных векторов**: В `TOpenGLChartRenderer.DrawTrendPoints` добавлено проецирование и отрисовка касательных векторов. Если вершина имеет тип `bptSmooth` и выделена, то из неё рисуются серые линии к опорным точкам векторов `Left` и `Right`, а в конечных точках — серые маркеры 5x5 пикселей."
content_n = content_n.strip() + "\n" + new_note + "\n"

with open(NOTES_PATH, 'wb') as f:
    f.write(content_n.encode('utf-8'))

print("Updated plan and notes successfully.")
