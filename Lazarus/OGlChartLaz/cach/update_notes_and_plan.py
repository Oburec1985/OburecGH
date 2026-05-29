import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

# 1. Update plan.md
if os.path.exists(PLAN_PATH):
    with open(PLAN_PATH, 'rb') as f:
        plan_content = f.read().decode('utf-8')
    
    # Let's add the steps 47, 48, 49, 50
    addition = """- [x] Шаг 47: Перевод получения координат мыши для клавиши `Insert` в `KeyDown` на системный вызов `Mouse.CursorPos` с трансляцией через `ScreenToClient` для обеспечения 100% точности.
- [x] Шаг 48: Умное поведение клика по пустому месту в `TChartSelectListener.MouseDown` — снятие выделения со всех вершин выделенного тренда с сохранением выделения самого тренда, чтобы позволить вставку в любом месте.
- [x] Шаг 49: Вывод имени и Caption выделенного объекта графика в панель статуса `StatusBar1` тестового приложения в `UpdateStatusBar` (`unit1.pas`).
- [x] Шаг 50: Интеграция локальных процедур логирования `LogToFile` в `uOglChartFrameListener.pas` и `uoglchart.pas` для вывода событий мыши и клавиатуры в файл `chart_events.log`.
"""
    
    plan_content_lf = plan_content.replace('\r\n', '\n')
    if addition not in plan_content_lf:
        # insert before the end
        lines = plan_content_lf.split('\n')
        for idx in range(len(lines) - 1, -1, -1):
            if lines[idx].strip().startswith("- [x] Шаг 46"):
                lines.insert(idx + 1, addition.strip('\n'))
                break
        plan_content_lf = '\n'.join(lines)
        
    with open(PLAN_PATH, 'wb') as f:
        f.write(plan_content_lf.replace('\n', '\r\n').encode('utf-8'))
    print("Updated plan.md.")

# 2. Update notes_current.md
if os.path.exists(NOTES_PATH):
    with open(NOTES_PATH, 'rb') as f:
        notes_content = f.read().decode('utf-8')
        
    notes_content_lf = notes_content.replace('\r\n', '\n')
    
    notes_addition = """
13. **Улучшение интерактивности клавиатурного ввода (Insert/Delete)**:
    - Заменили механизм кэширования координат `fLastMouseX`/`fLastMouseY` из события `MouseMove` на системный опрос позиции курсора `Mouse.CursorPos` прямо в момент нажатия `Insert` с переводом в координаты чарта через `TControl(ASender).ScreenToClient`. Это полностью решило проблему неработоспособности вставки вершины из-за перехвата движения мыши другими слушателями.
    - Переработан клик по свободному месту в `TChartSelectListener.MouseDown`. Если до этого был выделен тренд, содержащий выделенные вершины Безье, клик по пустому месту теперь сбрасывает выделение только с этих вершин, оставляя сам тренд в `SelectedObject`. Это позволяет переносить курсор и нажимать `Insert` для добавления точек в выбранный тренд без лишних визуальных выделений вершин. Повторный клик по пустому месту полностью сбрасывает выделение с тренда.
14. **Информативность и Логирование**:
    - В нижней панели (`StatusBar1` тестового приложения) выводится имя и Caption выделенного в данный момент объекта графика (или `Selected: None`).
    - Во все ключевые методы обработки ввода компонентов добавлен вывод событий в текстовый лог-файл `chart_events.log` (путь рассчитывается динамически относительно исполняемого файла проекта).
"""
    if "13. **Улучшение интерактивности клавиатурного ввода" not in notes_content_lf:
        notes_content_lf = notes_content_lf.rstrip('\n') + "\n" + notes_addition
        
    with open(NOTES_PATH, 'wb') as f:
        f.write(notes_content_lf.replace('\n', '\r\n').encode('utf-8'))
    print("Updated notes_current.md.")
