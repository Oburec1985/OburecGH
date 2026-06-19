# Кодировка исходников RecorderLnx

Маркер правила: `RLNX_SOURCE_ENCODING_2026_06`.

## Проблема

В `.pas`-модулях с `{$codepage cp1251}` и обёрткой `CP1251ToUTF8(...)` кириллица в IDE
отображалась как `` или квадраты, а часть литералов была безвозвратно заменена на
U+FFFD при неверной перекодировке файла.

**Mojibake в LCL** (например `РќР°СЃС‚СЂРѕР№РєР°` вместо «Настройка»): файл сохранён
как **UTF-8**, но в шапке стоит `{$codepage cp1251}` и строки обёрнуты в
`CP1251ToUTF8`. Компилятор читает UTF-8 байты как CP1251, затем LCL получает
двойную перекодировку. Лечение — перевод модуля на `{$codepage UTF8}` и **снятие**
`CP1251ToUTF8` с литералов (см. `cach/_fix_oscillogram_settings_encoding.py`).

Отдельный сценарий поломки (2026-06): файл в git хранился в **CP1251**, но редактор
(Cursor/IDE) сохранял его как UTF-8 без перекодировки — комментарии превращались в
`???`. Повторная правка через diff-инструменты без указания кодировки снова ломала файл.

Файлы `.lfm` при этом уже хранятся в UTF-8 и читаются нормально.

## Рабочий метод (пилот 2026-06)

Эталон: `Core/uRecorderAlarms.pas`.

1. Сохранить модуль **в UTF-8** (CRLF, без BOM).
2. В начале модуля: `{$codepage UTF8}` вместо `{$codepage cp1251}`.
3. Строки для LCL (`Caption`, `MessageDlg`, `Hint`, `Items.Add` и т.д.) — **обычные**
   UTF-8 литералы, **без** `CP1251ToUTF8`.
4. Убрать `LConvEncoding` из `uses`, если модуль больше не вызывает `CP1251ToUTF8`.
5. Hex-константы `RawByteString` + `SharedCp1251BytesToUtf8` — только если литерал
   уже испорчен и восстановить текст иначе нельзя.

LCL в Lazarus 2.x ожидает UTF-8 в `string`; при `{$codepage UTF8}` компилятор FPC
формирует корректные UTF-8 строки на этапе компиляции.

## Восстановление испорченных комментариев

Если в файле уже `???`, текст **не восстановить** из самого файла — нужен источник с
корректными байтами.

### Источник: git (CP1251)

Исторические коммиты RecorderLnx хранят `.pas` в Windows-1251:

```powershell
python cach/_fix_umainform_encoding.py
```

Скрипт:
1. Читает blob `origin/master` как **CP1251**;
2. Сохраняет рабочий файл в **UTF-8** с `{$codepage UTF8}`;
3. Повторно применяет актуальные правки кода (uses, новые процедуры).

Проверка после восстановления:

```powershell
python -c "t=open('UI/uMainForm.pas',encoding='utf-8').read(); print('???', t.count('???'))"
```

Ожидается `??? 0`.

### Mojibake в UI (UTF-8 файл + cp1251 + CP1251ToUTF8)

Симптом: в работающем приложении подписи кнопок/меток — «кракозябры» (`РќР°…`).

Скрипт для новых UI-модулей, созданных AI с неверным шаблоном:

```powershell
python cach/_fix_oscillogram_settings_encoding.py
```

Шаблон правки (можно повторить для другого `.pas`):

1. `{$codepage UTF8}` вместо `{$codepage cp1251}`.
2. Убрать `LConvEncoding` из `uses`.
3. Заменить `CP1251ToUTF8('…')` на `'…'` (литерал уже в UTF-8).
4. Сохранить файл UTF-8, CRLF, без BOM; `lazbuild -B`.

### Ручная проверка байтов

Кириллица в UTF-8 начинается с `D0`/`D1`:

```powershell
python -c "b=open('UI/uMainForm.pas','rb').read(); print(b.find('Модуль'.encode('utf-8')))"
```

Индекс `>= 0` — файл в UTF-8.

## Как не портить кодировку снова

| Действие | Рекомендация |
|---|---|
| Редактирование `.pas` с кириллицой | **Lazarus IDE** или редактор с явным UTF-8 |
| Массовые правки / AI diff | Только через Python: `encoding='utf-8'`, `newline='\r\n'`; **не** `write_text` поверх CP1251 |
| Смешение codepage | Не держать `{$codepage cp1251}` в UTF-8 файле и наоборот |
| `git show … > file.pas` | Опасно: shell перекодирует; использовать Python `decode('cp1251')` |
| После автоправки | Открыть файл в IDE, проверить комментарии; `lazbuild -B` |
| Cursor / внешний diff | Для модулей с кириллицей — точечные правки без перезаписи всего файла; при сомнении — скрипт восстановления |

Маркер правила: `RLNX_UTF8_PAS_EDIT_2026_06` — UI-модули RecorderLnx с русскими
комментариями редактировать только в UTF-8; восстановление — через `cach/_fix_umainform_encoding.py`.

## Модули на UTF-8

| Модуль | Статус |
|---|---|
| `UI/uTagSettingsDialog.pas` | UTF-8 (2026-06) |
| `UI/uMainForm.pas` | UTF-8 (2026-06), комментарии из git CP1251 |
| `UI/uRecorderOscillogramSettingsDialog.pas` | UTF-8 (2026-06), из cp1251+CP1251ToUTF8 через `cach/_fix_oscillogram_settings_encoding.py` |

Остальные UI-модули — по мере миграции (см. `development-rules.md`).

## Данные CP1251 из MERA/INI

MERA-дескрипторы и legacy-файлы по-прежнему в CP1251:

- `uMeraFile` — `CP1251ToUTF8` при чтении INI;
- `uComponentServices.LclText` — если в `string` попали байты CP1251.

Это не относится к исходным литералам в `.pas`.

## Связанные материалы

- `Docs/development-rules.md` — раздел «Кодировки»
- AGrav: `20_Проекты/Разработка_Delphi/Lazarus/RecorderLnx/Docs/10_Кодировка_Исходников.md`
- AGrav: `00_Система/Инструменты/RecorderLnxUtf8Restore/Tool.md`
