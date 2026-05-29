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

print("Updating plan.md and notes_current.md with directory reorganization details...")

# Update plan.md
content_plan = read_file(PLAN_PATH)
additions = "\n- [x] Шаг 33: Перенос `u2DMath.pas` в специализированный каталог `math` (`SharedUtils\\math\\u2DMath.pas`) и обновление путей поиска в `project1.lpi`."
content_plan += additions
write_file(PLAN_PATH, content_plan)

# Update notes_current.md
content_notes = read_file(NOTES_PATH)
notes_addition = """
6. **Организация структуры каталогов**:
   - Математический модуль `u2DMath.pas` перемещен в подкаталог `Lazarus\\SharedUtils\\math\\`.
   - В файле проекта `project1.lpi` пути поиска (`OtherUnitFiles`) обновлены: добавлен путь `..\\..\\SharedUtils\\math`.
   - Проект полностью перекомпилирован и собирается без ошибок.
"""
content_notes += notes_addition
write_file(NOTES_PATH, content_notes)

print("Updates saved successfully.")
