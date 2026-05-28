import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

# 1. Update plan.md
with open(PLAN_PATH, 'rb') as f:
    raw_p = f.read()
content_p = raw_p.decode('utf-8')

new_step = """
- [x] Шаг 45: Реализация методов `InsertBeziePoint` (поиск правильного индекса по X для сохранения сортировки) и `DeleteBeziePoint` в `cTrend` (`uOglChartTrend.pas`).
- [x] Шаг 46: Переопределение `KeyDown` в `TChartSelectListener` (`uOglChartFrameListener.pas`) для вставки новых вершин (по клавише Insert) под курсором мыши и удаления выделенной вершины (по клавише Delete).
"""

content_p = content_p.strip() + "\n" + new_step.strip() + "\n"

with open(PLAN_PATH, 'wb') as f:
    f.write(content_p.encode('utf-8'))

# 2. Update notes_current.md
with open(NOTES_PATH, 'rb') as f:
    raw_n = f.read()
content_n = raw_n.decode('utf-8')

new_note = """
12. **Вставка и удаление вершин клавиатурой**:
    - В `cTrend` добавлены методы `InsertBeziePoint` и `DeleteBeziePoint`. Метод вставки автоматически ищет правильную позицию по оси X, сохраняя упорядоченность массива, и выделяет новую вершину. Метод удаления безопасно уничтожает объект вершины, сдвигает массив и автоматически выделяет соседнюю вершину для быстрого продолжения редактирования.
    - В `TChartSelectListener` добавлено отслеживание координат курсора (`fLastMouseX`, `fLastMouseY`) в `MouseMove` и переопределен метод `KeyDown`:
      - Клавиша `Delete` (код 46) удаляет текущую выделенную вершину Безье в активном тренде.
      - Клавиша `Insert` (код 45) вставляет новую вершину (по умолчанию `bptCorner`) в текущих экранных координатах мыши, пересчитанных в масштабные координаты графика.
"""

content_n = content_n.strip() + "\n" + new_note.strip() + "\n"

with open(NOTES_PATH, 'wb') as f:
    f.write(content_n.encode('utf-8'))

print("Updated plan and notes successfully.")
