import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

def read_file(path):
    if not os.path.exists(path):
        return ""
    with open(path, 'rb') as f:
        data = f.read()
    for enc in ['utf-8', 'cp1251', 'latin1']:
        try:
            return data.decode(enc)
        except UnicodeDecodeError:
            continue
    return data.decode('utf-8', errors='replace')

def write_file(path, content):
    with open(path, 'wb') as f:
        f.write(content.replace('\r\n', '\n').replace('\r', '\n').replace('\n', '\r\n').encode('utf-8'))

print("Updating plan.md and notes_current.md...")

# Update plan.md
content_plan = read_file(PLAN_PATH)
additions = """
- [x] Шаг 37: Исправление кликабельности вершин тренда (обход через оси Y в TChartSelectListener и TChartPanZoomListener).
- [x] Шаг 38: Разделение осей Y по горизонтали с расчетом динамического отступа по ширине меток и отрисовка их собственными цветами.
- [x] Шаг 39: Снижение толщины линий рамок выделения оси до 1.2/1.5 для более аккуратного вида.
"""
content_plan += additions
write_file(PLAN_PATH, content_plan)

# Update notes_current.md
content_notes = read_file(NOTES_PATH)
notes_addition = """
8. **Исправления кликабельности, осей и рамок**:
   - Обнаружено, что тренды `cTrend` добавляются как дочерние элементы осей Y (`lYAxis.Children`), а не страниц. Логика хит-тестирования в `MouseDown` изменена на двухуровневый обход (Page -> Axes -> Trends).
   - Внедрен единый алгоритм расчета горизонтального смещения осей Y на основе максимальной ширины меток (`lMaxTextWidth + 15`) в методах `PageContentRect`, `DrawAxes` и `GetAxisHitAt`. Это позволило осям следовать друг за другом без перекрытий.
   - Восстановлена отрисовка осей их собственными цветами (`SetGLColor(lYAxis.Color)`).
   - Толщина рамок выделения и наведения уменьшена с 3 и 2 до 1.5 и 1.2 соответственно для устранения "жирности".
"""
content_notes += notes_addition
write_file(NOTES_PATH, content_notes)

print("Saved.")
