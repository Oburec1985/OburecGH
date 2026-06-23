# CHANGELOG — RecorderLnx

Краткий лог значимых изменений. Подробности — в связанных документах. Новые записи сверху.

---

## 2026-06-22 — Глубина тренда 100 с и плавное обновление

**Задача (переформулировка):** При настройке глубины тренда 100 с накапливалось ~30 с истории, затем интерфейс заедал; нужно корректное окно по `DurationSec` и стабильный refresh.

**Сделано:**
- Скалярные теги (MemTag, CpuUsage) добавляют точку не чаще `UpdatePeriodSec`, а не на каждый тик данных (~0,3 с).
- Ёмкость `cBuffTrendQueue` пересчитана: `DurationSec / UpdatePeriodSec` с запасом.
- Обрезка точек старше окна: `TrimBeforeTime` в `cBuffTrendQueue`, `PopFront` в `uSharedQueue`.
- Лимит catch-up: не более 64 порций за один кадр для векторных каналов.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `UI/uRecorderTrendView.pas`, `SharedUtils/.../uOglChartTrend.pas`, `SharedUtils/.../uSharedQueue.pas`

**Документация:** [original-recorder-trend-component.md](Docs/original-recorder-trend-component.md), [notes_trend.md](cach/notes_trend.md) (план миграции на TOglChart)

---

## 2026-06-22 — Краш и кодировка в настройках тренда

**Задача (переформулировка):** В диалоге настроек тренда — кракозябры в подписях; после правки подписей падение при открытии (access violation на `fLineTagCombo`).

**Сделано:**
- Убрана лишняя `CP1251ToUTF8()` при `{$codepage UTF8}` — устранена двойная перекодировка подписей.
- Восстановлено `fLineTagCombo := TComboBox.Create(Self)` (случайно удалено при смене подписи «Линии» → «Тег»).
- Удалён неиспользуемый `LConvEncoding` из uses.

**Файлы:** `UI/uRecorderTrendSettingsDialog.pas`

**Документация:** [source-encoding.md](Docs/source-encoding.md), [notes_encoding_fix.md](cach/notes_encoding_fix.md)

---

## 2026-06-22 — MIC-140: combobox ГХ термопар из SDB

**Задача (переформулировка):** Заполнить combobox «ГХ термопары» шкалами из `Mera Files\sdb\ГОСТ\Термопары`; исправить пустой список, массовое назначение только выделенным каналам и сохранение настроек между открытиями MIC-140.

**Сделано:**
- Модуль `Core/uRecorderMeraSdbThermocouples.pas`: поиск папки термопар через `FindFirst`, кэш, рекурсивный fallback.
- Путь Mera Files: приоритет `C:\Mera Files`, `SyncMeraFilesPathFromUi` в настройках рекордера.
- Диалог канала MIC-140: список ГХ, кнопки SDB и сброс; bulk-edit по выделению строк grid (не по галочкам «канал используется»).
- `fMic140SourceConfigs` — сохранение channel settings в сессии settings dialog; restore из тегов.
- Кнопка аппаратной настройки в `uTagSettingsDialog`; исправлен dblclick Mera vs MIC-140 в дереве устройств.
- Сборка — OK (исправлен конфликт `GetEnvironmentVariable` с модулем `Windows`).

**Файлы:** `Core/uRecorderMeraSdbThermocouples.pas`, `Core/uRecorderMeraPaths.pas`, `Device/MIC140/UI/uRecorderMic140ChannelDialog.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`, `UI/uRecorderSettingsDialog.pas`, `UI/uTagSettingsDialog.pas`

**Документация:** [sdb.md](Docs/sdb.md), [mic140_protocol.md](Docs/mic140_protocol.md), [settings_dialog.md](Docs/settings_dialog.md)

---

## Ранее

Подробный архив до введения этого файла — в [cach/notes_last_state.md](cach/notes_last_state.md) (записи от 18–19.06.2026).
