from html import escape
from pathlib import Path


ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"

TOPICS = [
    ("if_then", "if ... then", "Выполняет блок, когда условие истинно.", "if {Температура}.Value > 80 then\n  logMessage(\"Высокая температура\")\nend", "Стандартные функции Lua/Условия"),
    ("if_else", "if ... then ... else", "Выбирает один из двух блоков по условию.", "if {Давление}.Value > 10 then\n  {Состояние} = 1\nelse\n  {Состояние} = 0\nend", "Стандартные функции Lua/Условия"),
    ("for", "for", "Повторяет блок заданное число раз.", "for i = 1, 5 do\n  logMessage(\"Шаг \" .. tostring(i))\nend", "Стандартные функции Lua/Циклы"),
    ("while", "while", "Повторяет блок, пока условие истинно.", "local i = 1\nwhile i <= 5 do\n  i = i + 1\nend", "Стандартные функции Lua/Циклы"),
    ("repeat_until", "repeat ... until", "Повторяет блок до выполнения условия.", "local i = 1\nrepeat\n  i = i + 1\nuntil i > 5", "Стандартные функции Lua/Циклы"),
    ("local", "local", "Создаёт локальную переменную внутри подпрограммы.", "local сумма = {E1}.Value + {E2}.Value", "Стандартные функции Lua/Переменные"),
    ("math_abs", "math.abs", "Возвращает модуль числа.", "local модуль = math.abs({Сигнал}.Value)", "Стандартные функции Lua/Математика"),
    ("math_min", "math.min", "Возвращает меньшее из переданных чисел.", "local минимум = math.min({E1}.Value, {E2}.Value)", "Стандартные функции Lua/Математика"),
    ("math_max", "math.max", "Возвращает большее из переданных чисел.", "local максимум = math.max({E1}.Value, {E2}.Value)", "Стандартные функции Lua/Математика"),
    ("math_sqrt", "math.sqrt", "Возвращает квадратный корень.", "local корень = math.sqrt({Сигнал}.Value)", "Стандартные функции Lua/Математика"),
    ("tostring", "tostring", "Преобразует значение в строку.", "logMessage(\"Значение: \" .. tostring({E1}.Value))", "Стандартные функции Lua/Строки"),
    ("string_format", "string.format", "Форматирует строку по правилам Lua.", "logMessage(string.format(\"Значение: %.2f\", {E1}.Value))", "Стандартные функции Lua/Строки"),
    ("tag_value", "{Тег}.Value", "Возвращает последнее числовое значение тега.", "local значение = {Температура}.Value", "RecorderLnx/Теги"),
    ("tag_write", "{Тег} = значение", "Записывает значение в существующий виртуальный тег.", "{Расчёт} = {E1}.Value + {E2}.Value", "RecorderLnx/Теги"),
    ("get_value", "getValue", "Возвращает последнее числовое значение тега по имени.", "local значение = getValue(\"Температура\")", "RecorderLnx/Теги"),
    ("set_value", "setValue", "Находит существующий тег по точному имени и записывает значение, если для тега разрешена внешняя запись. Возвращает 1 при успехе и 0 при отказе. При отсутствии тега или запрете записи причина выводится в системный журнал.", "local успешно = setValue(\"Tags_[1]\", 25.5)\nif успешно == 0 then\n  logMessage(\"Значение не записано\")\nend", "RecorderLnx/Теги"),
    ("get_tag_time", "getTagTime", "Возвращает время последнего значения тега в секундах.", "local время = getTagTime(\"Температура\")", "RecorderLnx/Теги"),
    ("get_tag_sample", "getTagSample", "Возвращает два результата: значение и время измерения.", "local значение, время = getTagSample(\"Температура\")", "RecorderLnx/Теги"),
    ("tag_exists", "tagExists", "Возвращает 1, если тег существует, иначе 0.", "if tagExists(\"Температура\") == 1 then\n  logMessage(\"Тег найден\")\nend", "RecorderLnx/Теги"),
    ("get_tag_setpoint", "getTagSetpoint", "Возвращает порог и признак включения уставки (1 или 0). Типы: highAlarm, highWarning, lowWarning, lowAlarm.", "local порог, включена = getTagSetpoint(\"Температура\", \"highAlarm\")", "RecorderLnx/Уставки"),
    ("set_tag_setpoint", "setTagSetpoint", "Меняет порог и состояние уставки. Изменение записывается в конфигурацию при сохранении проекта.", "local успешно = setTagSetpoint(\"Температура\", \"highAlarm\", 100, 1)", "RecorderLnx/Уставки"),
    ("get_tag_alarm_level", "getTagAlarmLevel", "Возвращает 0 — норма, 1 — предупреждение, 2 — авария, -1 — тег или API недоступен.", "local уровень = getTagAlarmLevel(\"Температура\")", "RecorderLnx/Аварии"),
    ("alarm_handling", "Обработка аварии", "Пример обработки предупреждения и аварии тега.", "local уровень = getTagAlarmLevel(\"Температура\")\nif уровень == 2 then\n  logMessage(\"Авария\")\nelseif уровень == 1 then\n  logMessage(\"Предупреждение\")\nend", "RecorderLnx/Аварии"),
    ("log_message", "logMessage", "Добавляет строку в системный журнал RecorderLnx.", "logMessage(\"Расчёт выполнен: \" .. tostring({Результат}.Value))", "RecorderLnx/Система"),
    ("get_recorder_time", "getRecorderTime", "Возвращает текущее время данных RecorderLnx в секундах.", "local время = getRecorderTime()", "RecorderLnx/Система"),
    ("set_tag_value_delayed", "SetTagValue", "Записывает значение в тег из отдельного потока после указанной задержки в секундах.", "SetTagValue(\"Расчёт\", 25.5, 1.0)", "RecorderLnx/Система"),
]


def page(topic):
    slug, title, description, example, group = topic
    return f"""<!doctype html>
<html lang="ru"><head><meta charset="utf-8"><title>{escape(title)}</title>
<link rel="stylesheet" href="style.css"></head><body>
<div class="path">{escape(group)}</div><h1>{escape(title)}</h1>
<p>{escape(description)}</p><h2>Пример использования</h2>
<pre><code>{escape(example)}</code></pre>
<p class="note">Двойной щелчок по функции в редакторе вставляет заготовку кода.</p>
</body></html>"""


def contents():
    groups = {}
    for topic in TOPICS:
        groups.setdefault(topic[4], []).append(topic)
    lines = ['<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">', '<HTML><BODY><UL>']
    for group, topics in groups.items():
        lines += ['<LI><OBJECT type="text/sitemap">', f'<param name="Name" value="{escape(group)}">', '</OBJECT><UL>']
        for slug, title, *_ in topics:
            lines += ['<LI><OBJECT type="text/sitemap">', f'<param name="Name" value="{escape(title)}">', f'<param name="Local" value="topics/{slug}.html">', '</OBJECT>']
        lines.append('</UL>')
    lines += ['</UL></BODY></HTML>']
    return "\n".join(lines)


def main():
    topics_dir = SRC / "topics"
    topics_dir.mkdir(parents=True, exist_ok=True)
    style = "body{font:10pt Segoe UI,Arial;margin:24px;color:#202124}h1{color:#174a7e}h2{margin-top:24px}pre{background:#f3f5f7;border-left:4px solid #2878b5;padding:12px;white-space:pre-wrap}.path,.note{color:#5f6368}"
    (SRC / "style.css").write_text(style, encoding="utf-8")
    (topics_dir / "style.css").write_text(style, encoding="utf-8")
    for topic in TOPICS:
        (topics_dir / f"{topic[0]}.html").write_text(page(topic), encoding="utf-8")
    (SRC / "index.html").write_text(page(("index", "Lua в RecorderLnx", "Справочник стандартных конструкций Lua и функций RecorderLnx для расчётных скриптов.", "function lua_main()\n  {Результат} = {E1}.Value + {E2}.Value\nend", "Справка")), encoding="utf-8")
    (SRC / "RecorderLnxLua.hhc").write_text(contents(), encoding="utf-8")
    files = ["index.html", "style.css", "topics/style.css", "RecorderLnxLua.hhc"] + [f"topics/{t[0]}.html" for t in TOPICS]
    hhp = "[OPTIONS]\nCompatibility=1.1 or later\nCompiled file=../RecorderLnxLua.chm\nContents file=RecorderLnxLua.hhc\nDefault topic=index.html\nDisplay compile progress=No\nLanguage=0x419 Russian\nTitle=RecorderLnx: справка Lua\n\n[FILES]\n" + "\n".join(files) + "\n"
    (SRC / "RecorderLnxLua.hhp").write_text(hhp, encoding="utf-8")


if __name__ == "__main__":
    main()
