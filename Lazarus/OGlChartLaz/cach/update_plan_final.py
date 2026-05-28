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

print("Updating plan.md and notes_current.md with final changes...")

# Update plan.md
content_plan = read_file(PLAN_PATH)
additions = """
- [x] Шаг 34: Устранение Access Violation в `cBaseObj.GetChildCount` при клике путем своевременной инициализации `lModel` в `TChartSelectListener.MouseDown`.
- [x] Шаг 35: Добавление измерения FPS и времени рендеринга с использованием системного счетчика `QueryPerformanceCounter` в `TOglChart.Paint`.
- [x] Шаг 36: Реализация события `OnAfterRender` в `TOglChart` и интеграция его в `unit1.pas` для отображения FPS в нижней панели `StatusBar1`.
"""
content_plan += additions
write_file(PLAN_PATH, content_plan)

# Update notes_current.md
content_notes = read_file(NOTES_PATH)
notes_addition = """
7. **Устранение Access Violation и измерение FPS**:
   - Локализована и исправлена ошибка Access Violation в `cBaseObj.GetChildCount`: переменная `lModel` в `TChartSelectListener.MouseDown` использовалась до ее фактической инициализации. Теперь инициализация `lModel` перенесена в начало метода.
   - В компонент `TOglChart` добавлено событие `OnAfterRender: TChartAfterRenderEvent` и измерение времени отрисовки через системные функции Windows `QueryPerformanceCounter` и `QueryPerformanceFrequency`.
   - В `unit1.pas` подключена обработка события `OnAfterRender` для вывода FPS и времени рендеринга в статусбаре `StatusBar1` параллельно с выводом координат мыши.
   - Проект успешно перекомпилирован компилятором `lazbuild` без единого предупреждения.
"""
content_notes += notes_addition
write_file(NOTES_PATH, content_notes)

print("Updates saved successfully.")
