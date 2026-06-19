# Статус проекта RecorderLnx

## Последние изменения (19.06.2026)

### SharedUtils: утилиты и видимость в инспекторе проекта
- Служебные функции вынесены в SharedUtils (см. `Docs/development-rules.md`, раздел `RLNX_SHAREDUTILS_LAYOUT_2026_06`).
- `ParseMic140ChannelNumber` / `SameMic140Address` в `Device/MIC140/uRecorderMic140Utils.pas` (ранее — interface `uRecorderMic140DataSource` и дубликат в `uRecorderSettingsDialog`).
- Кодировки CP1251 hex-констант — `SharedUtils/uSharedStringEncoding.pas`.
- Модули SharedUtils добавлены в `RecorderLnx.lpi` для инспектора проекта Lazarus.

## Последние изменения (18.06.2026)

### 1. Формирование адресов каналов MIC-140 в формате "2-01"
- **Промпт:** Доделать задачу по формированию адресов каналов MIC-140 в формате `2-01`, `2-02` ... `2-48`, обновить диалог настроек и добавить тесты. Запрет на использование Python скриптов для редактирования .pas-файлов во избежание проблем с кодировкой Windows-1251.
- **Решение:**
  - В `Device/MIC140/uRecorderMic140Utils.pas` функции `ParseMic140ChannelNumber` и `SameMic140Address` (2026-06 вынесены из DataSource).
  - В [uRecorderSettingsDialog.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/UI/uRecorderSettingsDialog.pas) метод `BuildMic140Signals` переведен на формирование адресов в формате `Format('2-%2.2d', [I])` и проверку статуса каналов через `IsChannelEnabled`.
  - В методах `RestoreMic140SignalsFromTags` и `ConfigureMic140Source` вызовы `TryStrToInt` заменены на `ParseMic140ChannelNumber` для поддержки адресов с текстовым префиксом.
  - Файл `uRecorderSettingsDialog.pas` нормализован (удалены лишние пустые строки `CRCRLF` -> `CRLF`). Кодировка `cp1251` полностью сохранена.
  - В [RecorderDataSourcesTest.lpr](file:///d:/works/OburecGH/Lazarus/Tests/RecorderTests/DataSources/RecorderDataSourcesTest.lpr) добавлены тесты `TestMic140AddressHelpers` для проверки корректности разбора адресов.

### 2. Исправления по MIC-140 (удаление каналов, частота опроса, каналы температуры T1..T3)
- **Промпт:** Исправления по MIC-140:
  1. Если удалить каналы в конфигурационном диалоге и нажать Ok, то список каналов в окне визуально не обновится.
  2. В диалоге выбора частоты опроса не подсовываются правильные варианты для MIC-140 (было просто 100 Гц).
  3. Каналы температуры T1...T3 не появляются в списке доступных каналов, добавление/удаление должно быть аналогично обычным.
- **Решение:**
  - В [uRecorderSettingsDialog.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/UI/uRecorderSettingsDialog.pas) исправлена процедура `MarkSignalsFromRegistry` — убран ранний выход при `fMeraSignals = nil`. Теперь состояния `Selected` для MIC-140 и температурных каналов обновляются корректно, что решает проблему с невозможностью их удаления и непоявлением в доступных каналах.
  - Добавлен пропущенный вызов `MarkSignalsFromRegistry` в `ToggleHardwareSignal` при удалении каналов MIC-140.
  - В [uMainForm.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/UI/uMainForm.pas) в метод `btnSettingsClick` после закрытия диалога настроек по OK добавлен вызов `RenderActivePage` для мгновенного визуального обновления графиков, формуляров и окон на экране.
  - Подтверждена работа 8 частот опроса MIC-140 через расширенный массив `CMic140Frequencies`.
  - Успешно собраны и пройдены все тесты, проект пересобран без ошибок.

## Текущий статус
- Проект успешно собирается под Windows с помощью `lazbuild`.
- Все тесты `RecorderTests` проходят успешно.
- Рабочая среда Cursor/Codex: skill `recorderlnx` (`C:\Users\User\.codex\skills\recorderlnx\SKILL.md`) — пути, сборка, сравнение с `D:\works\windev-v3.9`, правила из `Docs/development-rules.md` и AGrav.
- Проверка сборки 18.06.2026: `lazbuild -B RecorderLnx.lpi` и `RecorderDataSourcesTest.lpi` — OK (hints/warnings без ошибок).

### 4. Загрузка аппаратной ГХ MIC-140 из calibr/hardware (18.06.2026)
- **Промпт:** Реализовать для MIC-140 загрузку ГХ из аппаратных характеристик по аналогии с оригинальным Recorder.
- **Решение:**
  - Путь CSV как в `CChannelMIC140::GetCalibrGroupDir` + `GetTransDir` + `GetTransFileName`: `../calibr/hardware/MIC140/sn####/{range}/{channel}.csv`.
  - Новые поля тега: `HardwareCalibrationName`, `HardwareCalibrationEnabled`, `Mic140DeviceSerial`.
  - `TransformTagValue` сначала применяет аппаратную ГХ, затем канальную цепочку.
  - Автозагрузка после connect в `TRecorderMic140DataSource.Start`; ручная — кнопка аппаратной ГХ в `uTagSettingsDialog`.
  - Тест `TestMic140HardwareCalibrationLoad` в `RecorderDataSourcesTest.lpr`.
  - Документация: `Docs/mic140_protocol.md` (раздел «Аппаратная ГХ из каталога calibr»).


### 3. Динамическое обновление частоты опроса и буферизации MIC-140 (18.06.2026)
- **Промпт:** при смене частоты опроса и записи сперва остается предыдущая частота. а вот при перезапуске уже получается та частота которую выставил. Еще - я поставил частоту опроса 10 Гц, стали реже приходить буфера, по идее за 0,2 сек которые в конфиге должно приходить по 2 точки, такое ощущение что он продолжает копить по 20 точек и только тогда отправляет.
- **Решение:**
  - В [uRecorderMic140DataSource.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/Device/MIC140/uRecorderMic140DataSource.pas) добавлен параметр `AUpdateTimeMs` в конструктор `TRecorderMic140Device` и сохраняется в поле `fUpdateTimeMs`.
  - В методе `LegacyCalcFifoReadyWords` реализован динамический расчет размера блока FIFO на основе частоты опроса (`fPollFrequencyHz`) и интервала обновления (`fUpdateTimeMs` / `200` ms). Теперь размер блока на канал рассчитывается как `Round(fPollFrequencyHz * lUpdateTimeMs / 1000.0)` (например, 2 точки на канал для 10 Гц при 0.2 сек) и ограничивается сверху двойной буферизацией FIFO (максимум 7 точек). Это устраняет задержки сбора и накопления избыточных точек при низких частотах опроса.
  - В [uMainForm.pas](file:///d:/works/OburecGH/Lazarus/RecorderLnx/UI/uMainForm.pas) в процедуре `OpenSelectedTagSettings` при сохранении настроек тегов добавлена принудительная очистка и переконфигурация источников данных (`fDataSourceManager.Clear`, `fDataSourcesConfigured := False`) с автоматическим перезапуском, если они были запущены. Это позволяет изменениям частоты/режима вступать в силу немедленно без перезапуска программы.
  - Добавлены модульные тесты `TestMic140ReadyWordsPacing` в [RecorderDataSourcesTest.lpr](file:///d:/works/OburecGH/Lazarus/Tests/RecorderTests/DataSources/RecorderDataSourcesTest.lpr) для проверки корректности расчета размера блоков для разных режимов (100 Гц при 0.2 сек, 10 Гц при 0.2 сек, 10 Гц при 0.5 сек).
  - Успешно собраны тесты и основной исполняемый файл `RecorderLnx.exe`.

  - В методе `TRecorderMic140DataSource.DoTick` логика разбора и публикации точек вынесена во внутреннюю процедуру `ProcessAndPublishBlock`.
  - Организован цикл `while fDevice.ReadBlock(0, lBlock) do`, вычитывающий все накопившиеся в TCP-сокете блоки данных за один тик таймера. Первый блок читается с блокирующим таймаутом, последующие — с нулевым таймаутом без задержек. Это решает проблему накопления отставания (backlog) при высокой частоте опроса (на 100 Гц за 3 секунды теперь записываются ровно все 300 точек).
