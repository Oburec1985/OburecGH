import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

# Helper to read with fallback encoding
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

# Helper to write as UTF-8
def write_file(path, content):
    with open(path, 'wb') as f:
        f.write(content.replace('\r\n', '\n').replace('\r', '\n').replace('\n', '\r\n').encode('utf-8'))

print("Updating plan.md and notes_current.md...")

content_plan = read_file(PLAN_PATH)
if not content_plan:
    content_plan = "# План текущих доработок OGlChart\n"

additions = """
- [x] Шаг 28: Перенос математики кубических сплайнов и Безье-интерполяции из `u2DMath.pas`.
- [x] Шаг 29: Реализация вершин Безье (`cBeziePoint`) и сглаживания сплайнами в `cTrend` (`uOglChartTrend.pas`).
- [x] Шаг 30: Хит-тестирование вершин тренда и оси Y при клике левой кнопкой мыши (`uOglChartRenderer.pas`).
- [x] Шаг 31: Поддержка интерактивного перетаскивания (drag-and-drop) вершин тренда в `TChartPanZoomListener` (`uOglChartFrameListener.pas`).
- [x] Шаг 32: Настройка демонстрационного Безье-тренда и интеграция выбора осей с выводом координат в статусбар (`unit1.pas`).
"""

content_plan += additions
write_file(PLAN_PATH, content_plan)
print("plan.md updated.")

notes_content = """# Заметки по текущей итерации доработки OGlChart

## Что было сделано:
1. **Реализация сплайнов cTrend**:
   - В модуль `uOglChartTrend.pas` добавлен вспомогательный класс `cBeziePoint` с координатами опорных точек и типом узла (`TBeziePointType = (bptCorner, bptSmooth, bptNull)`).
   - В класс `cTrend` добавлены методы `AddBeziePoint`, `GenerateSplinePoints` и `UpdateBeziePoint`, а также свойства `ShowPoints` и `Smooth`.
   - В методе `GenerateSplinePoints` реализовано вычисление опорных точек Безье для сглаженных узлов и генерация интерполированных точек с шагом 20 точек на сегмент с использованием кубических формул Безье.
   
2. **Отрисовка и хит-тест вершин cTrend**:
   - В `TOpenGLChartRenderer` реализован метод `DrawTrendPoints`, который рисует вершины Безье в виде квадратов 8x8 пикселей с рамкой (выделенная вершина - красным цветом, обычная - синим).
   - Реализован метод `GetAxisHitAt` для хит-тестирования кликов по вертикальной оси Y с окрестностью 10 пикселей.
   - Метод `XValueToPixel` и `AxisValueToPixel` перемещены в секцию `public` класса `TOpenGLChartRenderer` для поддержки хит-теста и перетаскивания вершин во фрейм-листерах.

3. **Интерактивное редактирование и перетаскивание (Drag & Drop)**:
   - В `TChartSelectListener.MouseDown` добавлен хит-тест осей Y и вершин Безье. При клике на ось или вершину она выделяется (`SelectedObject`), а выделенная ось отрисовывается жирным шрифтом.
   - В `TChartPanZoomListener` добавлена поддержка перетаскивания вершин тренда (mbLeft): при зажатии мыши над вершиной Безье активируется состояние `fIsDraggingPoint`, и при движении мыши координата вершины обновляется в реальном времени с ограничением в границах сетки страницы.

4. **Демонстрация и Интеграция**:
   - В тестовом приложении (`Test_component/unit1.pas`) первая линия `TrendLine` переведена на сглаживание Безье-сплайнами.
   - Обновлен вывод координат мыши в `OglChart1MouseMove` в нижней панели `StatusBar1`: если выделен тренд `cTrend`, координаты выводятся в масштабе связанной с ним оси Y.
   
5. **Сборка проекта**:
   - Исправлена кодировка модуля `uCommonTypes.pas`, добавлен режим `{$mode delphi}` для поддержки `class operator` записей без ключевого слова `static`.
   - Проект успешно собирается компилятором `lazbuild` без единой ошибки и предупреждения.
"""

write_file(NOTES_PATH, notes_content)
print("notes_current.md created.")
