# CHANGELOG — RecorderLnx

Краткий лог значимых изменений. Подробности — в связанных документах. Новые записи сверху.

---

## 2026-06-23 — MIC-140 КТХС: mV-пайплайн и TIn-калибровка

**Задача:** RecorderLnx ~490 °C vs Recorder ~520 °C.

**Причина:** T_КТХС читался через ГХ термопары AIN-канала; для TIn после аппаратной ГХ значение уже в °C, лишняя `thermo.Eval` занижала T_спая и недокомпенсировала ~30 °C. Не загружалась аппаратная ГХ из `Calibr\hardware\MIC140\snCCCC\TIn\`.

**Сделано:**
- Цепочка КТХС: `код→мВ (аппаратная)` → `+inverse(термопара, T_КТХС)` → `forward(термопара, мВ)`.
- T_КТХС: TIn hardware → °C (или + своя ГХ T-канала, если есть).
- Загрузка `TIn\NN.csv`, привязка к тегам `2-t1`… при старте.
- Сборка OK.

**Файлы:** `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — MIC-140 КТХС: цепочка как в ScanMIC140

**Задача:** Recorder 520 °C, RecorderLnx 495 °C — неполная компенсация холодного спая.

**Причина:** В оригинале (`ScanMIC140::Decommutation`) КТХС: `hardware Eval(code) + tare->EvalInverse(T_junction)` → `tare->Eval`. В RecorderLnx mV КТХС прибавлялись к сырым кодам, инверсия шла через полную цепочку ГХ (аппаратная + термопара).

**Сделано:**
- Раздельные `TransformTagHardwareValue`, `TransformTagThermocoupleValue`, `InvertTagThermocoupleValue`.
- КТХС: аппаратная ГХ → + inverse(термопара, T_КТХС+offset) → forward(термопара).
- T_КТХС: hardware(T-тег) + thermo(кривая канала), как `tar->Eval(tc_->loc_data)`.
- `PublishBlock(..., AValuesAlreadyTransformed)` для готовых °C.
- Сборка OK.

**Файлы:** `Core/uRecorderTags.pas`, `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — SDB термопары: кириллические пути (K_ГОСТ Р 8.585-2001.csv)

**Задача:** `thermocouple curve was not loaded` для `ГОСТ\Термопары\K_ГОСТ Р 8.585-2001` при наличии файла на диске.

**Причина:** `ChangeFileExt` в `RecorderSdbNormalizeKey` воспринимал `.585-2001` в имени `K_ГОСТ Р 8.585-2001` как расширение файла и обрезал ключ до `K_ГОСТ Р 8` → искался несуществующий `K_ГОСТ Р 8.csv`.

**Сделано:**
- `RecorderSdbNormalizeKey` снимает только суффиксы `.xml`/`.csv`.
- То же для `RecorderMeraThermocoupleDisplayName`.
- В лог ошибки добавлен полный путь `csv=...`.

**Сделано:**
- `FileExistsUTF8` в `uRecorderSdbStore`, `uRecorderSdbPropBag`, `uRecorderMeraSdbThermocouples`.
- `RecorderMeraLoadThermocoupleCalibration` — SDB + запасная загрузка CSV.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `SDB/uRecorderSdbStore.pas`, `SDB/uRecorderSdbPropBag.pas`, `Core/uRecorderMeraSdbThermocouples.pas`, `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — MIC-140: исправлен сбой serial=76 (неверный cast IRecorderDevice)

**Задача:** После фикса CCSerNo путь к ГХ стал `sn0076` вместо `sn0164`. В логе Connect: `ccSerNo=164`, сразу после — `ccSerNo=76`.

**Причина:** `TRecorderMic140Device(fDevice)` при `fDevice: IRecorderDevice` в FPC читает не тот объект; firmware на Connect записывалась правильно, `GetDeviceSerial` — из мусора.

**Сделано:**
- Поле `fMic140Device: TRecorderMic140Device` + `fDevice := fMic140Device` (без cast через interface).
- `fHardwareCalibrSerial` кэшируется в `Connect` сразу после `ReadFirmware`.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — Аппаратная ГХ MIC-140: серийник sn0164 (CCSerNo)

**Задача (переформулировка):** КТХС и температурный расчёт не работали: аппаратная ГХ искалась в `sn0115`/`sn0155` вместо `sn0164`; DevSerNo=155 совпадает с последним октетом IP, а не с с/н MIC (CCSerNo=164).

**Сделано:**
- `RecorderMic140HardwareCalibrSerialFromFirmware` — только CCSerNo при известном CCType (как `owner->DeviceInfo.SerialNo` в MC031); DevSerNo для каталога calibr не используется.
- `RecorderMic140DisplaySerialFromFirmware` / `RecorderMic140HostLastOctet` — в UI и диалоге показывается CCSerNo, если DevSerNo = октет IP.
- `ResolveDeviceSerialForTag` и `RebuildMic140SourceConfigsFromTags` игнорируют устаревший `mic140DeviceSerial` = октет IP из конфига.
- Лог при старте: `devSerNo / ccSerNo / ccType -> hardware calibr serial`.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MIC140/uRecorderMic140LegacyProtocol.pas`, `Device/MIC140/uRecorderMic140DataSource.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`, `UI/uRecorderSettingsDialog.pas`

**Документация:** [mic140_protocol.md](Docs/mic140_protocol.md)

---

## 2026-06-22 — КТХС MIC-140: применение компенсации холодного спая

**Задача (переформулировка):** Доработать КТХС для термопарных каналов MIC-140 — при включённой компенсации температура холодного спая не учитывалась в измерении.

**Сделано:**
- Исправлен выбор T-канала КТХС: при `Mic140CjcDefault` и сохранённом `Mic140CjcChannel=0` используется штатная таблица соответствия AIn→TIn (`RecorderMic140TagEffectiveCjcChannel`), а не сырой ноль.
- При старте источника синхронизируется `Mic140CjcChannel` на тегах; для термопарных каналов автоматически включается `Mic140ThermoCompensationEnabled`, если флаг не был сохранён.
- При сохранении MIC-140 КТХС включается автоматически, если хотя бы один выбранный канал использует ГХ термопары.
- В лог добавлен `block tin=` при недоступности TIn в блоке сканирования.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MIC140/uRecorderMic140DataSource.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`

**Документация:** [mic140_protocol.md](Docs/mic140_protocol.md) (раздел «ThermoComp, Default CJC и CJC»)

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
