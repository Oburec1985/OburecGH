import os

PLAN_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\plan.md"
NOTES_PATH = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\cach\notes_current.md"

# 1. Update plan.md
with open(PLAN_PATH, 'rb') as f:
    raw_p = f.read()
content_p = raw_p.decode('utf-8')

new_step = "- [x] Шаг 44: Реализация интерактивного перетаскивания касательных векторов Безье (зеленые маркеры) с обновлением `UpdateBezieLeft`/`UpdateBezieRight` и логикой следования усов за вершиной в `uOglChartTrend.pas`."
content_p = content_p.strip() + "\n" + new_step + "\n"

with open(PLAN_PATH, 'wb') as f:
    f.write(content_p.encode('utf-8'))

# 2. Update notes_current.md
with open(NOTES_PATH, 'rb') as f:
    raw_n = f.read()
content_n = raw_n.decode('utf-8')

new_note = "11. **Перетаскивание касательных векторов**: Реализован тип `TChartDragPart` и поле `fDragPart` во фрейм-листере. В `MouseDown` добавлена проверка клика по усам-манипуляторам выделенной вершины. При их перетаскивании вызываются методы `UpdateBezieLeft` или `UpdateBezieRight`. Если пользователь перетаскивает саму вершину, усы автоматически смещаются вслед за ней на тот же вектор смещения. Усы отрисовываются ярким зеленым цветом `$FF00D000` и имеют размер 8x8 пикселей с черным контуром."
content_n = content_n.strip() + "\n" + new_note + "\n"

with open(NOTES_PATH, 'wb') as f:
    f.write(content_n.encode('utf-8'))

print("Updated plan and notes successfully.")
