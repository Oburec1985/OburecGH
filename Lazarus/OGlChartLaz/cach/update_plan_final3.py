import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"

with open(PLAN_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('utf-8')

new_steps = """
- [x] Шаг 40: Исправление багов перетаскивания вершин Безье в `TChartPanZoomListener.MouseMove` (удаление ошибочного прерывания `fIsDraggingPoint := False`).
- [x] Шаг 41: Добавление переопределения `KeyPress` в `TChartSelectListener` для изменения типа интерполяции выделенной вершины тренда (клавиши `1` - Corner, `2` - Smooth, `3` - Null, `T`/`t` - циклический перебор).
- [x] Шаг 42: Реализация отрисовки различных форм вершин Безье (квадрат для bptCorner, ромб для bptSmooth, треугольник для bptNull) в `TOpenGLChartRenderer.DrawTrendPoints`.
"""

content = content.strip() + "\n" + new_steps.strip() + "\n"

with open(PLAN_PATH, 'wb') as f:
    f.write(content.encode('utf-8'))

print("Updated plan.md successfully.")
