# Безопасные скрипты для .pas с кириллицей

Маркер: `ENCODING_SAFE_SCRIPTS_2026_06`.

**Правило:** для массовых правок `.pas` с русскими комментариями и строками использовать **только** скрипты из этой папки. Старые скрипты в `*/cach/` — черновики; многие пишут CP1251 и ломают UTF-8.

Общая библиотека: `lib/pas_io.py` — чтение UTF-8, запись UTF-8+CRLF без BOM.

Документация проекта: `RecorderLnx/Docs/source-encoding.md`.

---

## Обязательная проверка после массовой замены

```powershell
python D:\works\OburecGH\Lazarus\Scripts\encoding-safe\verify_russian_comments.py path\to\file.pas
# или каталог:
python D:\works\OburecGH\Lazarus\Scripts\encoding-safe\verify_russian_comments.py D:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr
```

Код выхода `0` — OK, `1` — найдены `???`, U+FFFD, mojibake (`РќР°…`), несовпадение codepage.

---

## Каталог скриптов

| Скрипт | Область применения | Когда использовать |
|--------|-------------------|-------------------|
| **verify_russian_comments.py** | Проверка после любых правок | После каждой массовой замены, patch-скрипта, AI diff по `.pas` с кириллицей |
| **fix_double_spacing.py** | Лишние пустые строки (каждая строка через blank) | Файл «раздулся» в 2× по строкам; пробелы между процедурами; **не** трогает текст комментариев |
| **fix_mojibake.py** | Кракозябры в комментариях (`РќР°СЃ…` → «Нас…») | UTF-8 файл ошибочно интерпретировали как CP1251; комментарии в `{…}` и `//` |
| **fix_mojibake_and_spacing.py** | Mojibake + двойные пробелы за один проход | Пакетная правка chart_lzr / math после некорректного редактирования |
| **fix_string_literal_mojibake.py** | Кракозябры в `'строках'` Pascal | UI: `Caption`, `MessageDlg`, константы `sGhDownloadTitle = '…'` |
| **convert_cp1251_wrappers_to_utf8.py** | Миграция модуля на UTF-8 | В шапке `{$codepage cp1251}` + `CP1251ToUTF8('…')`, файл уже сохранён как UTF-8 |
| **restore_pas_from_git.py** | Восстановление комментариев из git (CP1251) | В файле `???` или комментарии безвозвратно исправнены; нужен blob из git |

---

## Примеры

```powershell
cd D:\works\OburecGH\Lazarus\Scripts\encoding-safe

# 1. После bulk-replace — проверка
python verify_russian_comments.py ..\SharedUtils\components\chart_lzr\uOglChartRenderer.pas

# 2. Двойные пустые строки
python fix_double_spacing.py ..\SharedUtils\math\uHardwareMath.pas

# 3. Кракозябры в комментариях
python fix_mojibake.py ..\SharedUtils\components\chart_lzr\uOglChartAxis.pas

# 4. Комментарии + пробелы
python fix_mojibake_and_spacing.py ..\SharedUtils\components\chart_lzr\uOglChartCursor.pas ..\SharedUtils\math\complex.pas

# 5. Строковые литералы UI
python fix_string_literal_mojibake.py ..\RecorderLnx\UI\uTagSettingsDialog.pas

# 6. cp1251 + CP1251ToUTF8 -> UTF8
python convert_cp1251_wrappers_to_utf8.py ..\RecorderLnx\UI\uRecorderOscillogramSettingsDialog.pas

# 7. Восстановление из git (комментарии были ???)
python restore_pas_from_git.py Lazarus/RecorderLnx/UI/uMainForm.pas
```

После `restore_pas_from_git.py` повторно примените актуальные правки кода (uses, новые процедуры) — скрипт восстанавливает только текст из git.

---

## Что НЕ использовать

| Путь | Почему опасно |
|------|----------------|
| `chart_lzr/cach/smart_fix_spacing.py` | Пишет **CP1251** |
| `chart_lzr/cach/write_and_verify.py` | Пишет **CP1251** |
| `chart_lzr/cach/perfect_spacing.py` | Старые абсолютные пути, CP1251 |
| Cursor `StrReplace` / diff на весь `.pas` с кириллицей | Риск `???` и смешения codepage |
| `git show … > file.pas` в PowerShell | Shell перекодирует вывод |

Новые одноразовые patch-скрипты класть в `*/cach/`; после проверки на 2–3 файлах переносить логику сюда и добавлять строку в таблицу выше.

---

## Добавление нового скрипта в каталог

1. Импортировать `read_pas` / `write_utf8_crlf` из `lib/pas_io.py`.
2. Прогнать на файле с кириллицей до/после + `verify_russian_comments.py`.
3. Добавить строку в таблицу «Каталог скриптов».
4. Указать в `SKILL.md` (`.cursor/skills/pascal-russian-encoding/`).
