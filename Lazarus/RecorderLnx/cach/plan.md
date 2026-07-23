# План: доработка RecorderLnx

- [x] На базовой странице назначать осциллограммам только активные/видимые
  теги, не удаляя сохранённые теги и привязки при временной потере источника.
- [x] Начинать заполнение базовых осциллограмм с выделенного канала и далее
  назначать остальные активные теги со смещением по порядку списка.

- [x] Реализовать единый `TRecorderAlgorithmManager` в `Algs`: строковая
  регистрация runtime/frame, сериализация, `Ready`, lifecycle через `case`,
  явная доставка scalar/block обновлений и адаптер существующего Spectrum.
- [x] Провести аудит EventBus: перевести штатный движок тревог на явный маршрут
  через модели, удалить мёртвые EventBus handlers спектра, оставить подписки
  только для UI, расширений и пассивной очереди снимков.

- [x] Осциллограмма: заменить отдельную UI-опцию «Основной канал» единым
  добавлением каналов; цвета по порядку: синий, зелёный, красный.

- [x] Аппаратная конфигурация MC-032: добавление/редактирование контроллера,
  автопоиск в `192.169.13.0/24` с обязательным `TEST_LOAD`, поиск MC-201 по
  слотам и сохранение источника как `MC-032: host:port`.

- [x] MC bus: перенести проверенный MC-032/MC-201 MDP-протокол в
  `Device/MCbus`, добавить адаптер `TRecorderMcbusDevice`, декоммутацию
  потоковых пакетов и встроенный BIOS MC-201 без изменений MIC-140/MIC-185.

- [x] MC-201 UI: по двойному клику на слоте открывать LFM-диалог
  параметров 4 каналов, коммутации и субмодуля; хранить настройки
  по номеру слота и не стирать их при повторном поиске.

- [x] Исправить наползание элементов на вкладке `Дополнительно` в диалоге настройки тега
  (`UI/uTagSettingsDialog.lfm`): увеличены нижние группы и добавлены вертикальные зазоры.

- [ ] MIC-140 debug stand (`Tests/Mic140ProtocolDebug`): PASS AIn 1–48 ±50 + TIn 1–3
  - [x] Добавлен контролируемый `pktmon`-захват по IP/порту: ETL + PCAPNG +
    CSV/таймлайн с временем, направлением, TCP seq/ack/flags, размерами и hex
    payload; имена дампов начинаются с IP прибора
  - [x] Исправлено падение при connect в GUI: WSAStartup/WSACleanup вынесены в секцию initialization/finalization в uMic140Registration.pas, оптимизирован поиск CDefaultHost
  - [x] `Tests/Mic140ProtocolDebug_Codex`: added `device\MIC140\uMic140Device.pas`
    as a buildable `IRecorderDevice` MIC-140 skeleton with empty programming/read logic
  - [x] `Tests/Mic140ProtocolDebug_Codex`: decoupled form from MIC-140 implementation
    through `device\uRecorderDeviceManager.pas` and `device\MIC140\uMic140Registration.pas`
  - [x] `Tests/Mic140ProtocolDebug_Codex`: moved MIC-140 host/port assignment from
    device constructor into manager search result; added MainForm test configuration hook
  - [x] `Tests/Mic140ProtocolDebug_Codex`: replaced MIC-140 constructor IP binding
    with local registration/search discovery over `192.168.14.*`, keeping form access
    through `IRecorderDevice` and `RecorderDeviceManager`
  - [x] `Tests/Mic140ProtocolDebug_Codex`: cleaned back to a minimal visual
    Lazarus form project; only `.lpi/.lpr/.pas/.lfm` remain in the folder
  - [x] `Tests/Mic140ProtocolDebug_Codex`: merged GUI, auto CLI, numeric CLI,
    and proxy/sniffer into the single `Mic140ProtocolDebug_Codex` Lazarus
    project; removed old separate CLI/example projects
  - [x] Codex defaults switched to Recorder-wire 48+3 mode; stream filter now
    requires full 51-word rows before publishing TIn slots
  - [x] Codex live-dump protocol rewrite: Recorder wire fixed as `chanDump[2]=48`, `fifoStride=51`, `fifoSamples=3`; docs/reference priority updated
  - [x] Live Recorder dump 20260701_153018: original Recorder preview, `msgWords=163`, `stride=51`, `samples=3`, TIn slots 48..50; protocol docs updated
  - [x] `Tests/Mic140ProtocolDebug_Codex`: автономный Codex-стенд без внешних unit-ов, Docs/task+protocol+capture, локальный proxy/sniffer, ETL parser, сборка трех `.lpi` OK
  - [x] Профиль A (fifo=48, tin=0): стабильный поток, CH01–24 PASS
  - [x] Раздельные эталоны stand / recorder-wire
  - [x] TIn вне strict-приёмки при tin=0
  - [x] settle-sec, --recorder-wire, parse_mdp --export-reference
  - [ ] CH25–48: ME048/desc25 vs Recorder programming (proxy PORT=1)
  - [ ] TIn через READMEMDM или wire-профиль с отдельным эталоном

- [x] MIC-140 legacy stream: добить стабильность payload scan-блоков
  - [x] Добавить 3-секундный smoke-test в документацию (`Docs/mic140_legacy_scan_stream.md`, раздел 9.1)
  - [x] Убрать ложный рост `mdpResync` при нормальном потреблении MDP-пакетов
  - [x] Зафиксировать стабильный рабочий режим `scanStride=48`, `fifoReadyWords=96` для 10 Hz / 200 ms и ожидаемых ~5 блоков/сек
  - [x] Вернуть `chanDumpCount=48` как в `ModuleMIC140_48::PrepareModuleDescForScan`
  - [x] Не включать TIn/CJC в текущий BIOS stride: вариант 48+3 давал периодические фазовые payload-блоки при валидном MDP
  - [x] Добавить защиту публикации: явно некорректный raw payload заменяется последним хорошим блоком до декоммутации, при этом `num_buff`, `readGaps`, `publishGaps` и `mdpResync` продолжают контролироваться
  - [x] Найти источник оставшегося `corruptRead/corruptPublish` при `readGaps=0`, `publishGaps=0`, `mdpResync=0`
  - [x] Добиться PASS для `Tools/mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0`
  - [x] Рефакторинг тайминга: машина состояний device, один `WaitFor(DataUpdateMs)` на цикл read-thread, без `Sleep`/warmup/settle (см. `Docs/mic140_legacy_scan_stream.md` §3.5)
  - [x] Стабильный PASS `mic140_preview_eval.ps1 -Seconds 40` (`corruptRead=0`) — 25.06.2026 после снятия `fAutoPreviewExtraTicks`
  - [ ] Будущая доработка: вернуть TIn/CJC только после точного совпадения с оригинальным портом, не ломая `scanStride=48` для AIn

- [x] Рефакторинг (очистка) от лишних преобразований строк
  - [x] Удален вызов 'Каналы...' в uMainForm.pas и CP1251ToUTF8
  - [x] В uRecorderSettingsDialog.pas исправлена кодировка и убраны лишние CP1251ToUTF8
  - [x] В uTagSettingsDialog.pas исправлена кодировка и убраны лишние CP1251ToUTF8
  - [x] В uComponentSettingsDialog.pas исправлена кодировка и убраны лишние CP1251ToUTF8

- [x] Настройка частоты опроса/обновления (параметр времени в Recorder)
  - [x] Связан ADataUpdateMs с диалогом ShowTagSettingsDialog и полем fDataUpdateMs в TTagSettingsDialog
  - [x] Настроена подгрузка из настроек LoadFromTags (при PortionLength = 17280)
  - [x] Учтены 17280 в StoreToTags, чтобы данные не перезаписывались некорректно
  - [x] Поле fRunSettings.DataUpdateMs связано с ShowTagSettingsDialog in uMainForm.pas
  - [x] Исправлено заполнение fDataUpdateMs (теперь берется из настроек при CreateDialog в uRecorderSettingsDialog.pas)

- [x] Логирование отладки (Windows / Linux)
  - [x] Создан новый модуль uRecorderDebugLog.pas
  - [x] Добавлено раздельное логирование (LogWindows.log / LogLinux.log) на основе ParamStr(0)
  - [x] Подключен к остальным модулям

- [x] Тестирование сборки под Windows и Linux

- [x] Редактирование узла устройства по двойному клику в дереве оборудования (Промпт: "в RecorderLnx по dblClick сделай редактирование узла")
  - [x] Изменить fHardwareTreeDblClick в uRecorderSettingsDialog.pas для вызова HardwareEditSourceClick

- [x] Формирование адресов каналов MIC-140 в формате "2-01"
  - [x] Обновить uRecorderMic140DataSource.pas (BuildChannels, FindTagBySourceAddress)
  - [x] Обновить uRecorderSettingsDialog.pas (BuildMic140Signals, RestoreMeraSignalsFromTags, GetMic140SelectedChannels)
  - [x] Проверить сборку проекта и запустить тесты

- [x] Исправления по MIC-140 (удаление каналов, частота опроса, каналы температуры T1..T3)
  - [x] Исправить ранний выход в MarkSignalsFromRegistry в uRecorderSettingsDialog.pas при отсутствии MERA-файла
  - [x] Добавить вызов MarkSignalsFromRegistry в ToggleHardwareSignal для MIC-140 в uRecorderSettingsDialog.pas
  - [x] Добавить вызов RenderActivePage в btnSettingsClick в uMainForm.pas для мгновенного обновления окон при закрытии диалога по OK
  - [x] Успешно скомпилировать и прогнать автоматические тесты
  - [x] Собрать основной исполняемый файл RecorderLnx

- [x] Динамическое обновление частоты опроса и буферизации MIC-140
  - [x] Добавлен параметр fUpdateTimeMs в конструктор и класс TRecorderMic140Device в uRecorderMic140DataSource.pas
  - [x] Реализован динамический расчет размера FIFO блока (lReadyWordsPerChannel) на основе частоты опроса и периода обновления
  - [x] В uMainForm.pas добавлена перезагрузка/перезапуск запущенных источников данных при закрытии Tag Settings по OK
  - [x] Добавлен модульный тест TestMic140ReadyWordsPacing в RecorderDataSourcesTest.lpr для проверки расчета размера блока
  - [x] Успешно собраны и пройдены все тесты, проект пересобран

- [x] Осушение TCP сокета MIC-140 в цикле (дренирование)
  - [x] Выделена логика публикации в локальную процедуру ProcessAndPublishBlock в uRecorderMic140DataSource.pas
  - [x] Внедрен цикл while fDevice.ReadBlock(0, lBlock) do ... в DoTick для вычитывания всех накопленных блоков
  - [x] Успешно пересобран проект и запущены тесты
- [x] MIC-185: программирование каналов как в оригинальном Recorder без
  изменения `TRecorderDevice` и без вмешательства в поток чтения
  - [x] Добавлен MIC185-специфичный record настроек канала и сборка
    `ProgramDeviceBin` из массива настроек (`uMic185MebiusTypes.pas`)
  - [x] Добавлен `TRecorderMic185Device.ApplyChannelProgramSettings`; базовый
    `TRecorderDevice` не менялся
  - [x] `uRecorderMic185DataSource.pas` читает `mic185:` настройки из тегов и
    применяет их перед `Connect/ProgramDevice`
  - [x] Все 64 измерительных канала оставлены `Connected=True`, чтобы не менять
    размер/порядок кадра в текущем потоке чтения
  - [x] Диалог канала MIC185 сохраняет диапазон, коммутацию, схему включения,
    шунт, баланс, чувствительность и сопротивление в `SourceValueMode`
  - [x] Сборка `RecorderLnx.lpi` через `lazbuild -B` успешна
 
- [x] MIC-185 settings dialog buttons and source persistence
  - [x] `Select all` creates/links all 70 MIC183/185 rows as tags and refreshes the grid
  - [x] `Properties` creates a tag for the selected channel if missing and opens MIC185 channel settings
  - [x] `Apply` stores the configured MIC185 data source without closing the dialog
  - [x] `OK` stores the configured MIC185 data source before closing
  - [x] `Balance` and `Metrology` are wired and explicitly report that the functions are not implemented yet
  - [x] Project save/load calls MIC185-specific data-source config hooks; `dataSources[].mic185.tagLinks[]` records tag links, addresses, channel modes and poll rates
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded

- [x] MIC-185 settings multi-select and programming trace
  - [x] `Select all` now also sets the visible grid selection rectangle
  - [x] `Properties` applies edited MIC185 channel settings to all selected measurement rows
  - [x] Temperature and UTS rows are excluded from group application of measurement-channel properties
  - [x] MIC185 project load restores `dataSources[].mic185.tagLinks[]` into tags
  - [x] Programming preparation logs channel/range/commutation/block settings to `LogWindows.log`
  - [x] Re-checked original MIC185V2 range indices and programming command order against `windev-v3.9`
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded
  - [x] Fixed startup crash after saving MIC185 config: MIC185 `tagLinks[]` load now runs after generic `tags[]` load to avoid duplicate tag IDs
  - [x] Moved MIC185 hardware channel settings out of tags: tags keep only source/channel binding, while source node saves hardware ranges and switching in `dataSources[].mic185.channels[]`
  - [x] `Apply` and `OK` now store MIC185 source settings and immediately call device programming; `OK` stays open if programming fails
  - [x] Source-level MIC185 module current is saved as `dataSources[].mic185.powerMaCode` and sent in `ProgramDeviceBin`

- [x] MIC-185 settings packet table and TKC/reference-channel comparison
  - [x] Added `Docs/devices/mic185/settings_packet_table.md` with byte offsets,
    field sizes, original Recorder/Mebius behavior, and current RecorderLnx behavior
  - [x] Confirmed likely reference-channel gap: original `MEPROPCH_MIC185V2_CHANTC`
    writes `GroupAddition_[group]`, while RecorderLnx currently sends all
    `GroupAddition[] = MOD_ADD_OFF`; original `MEPROP_TERMO_COMP` writes `bTKC_`,
    while RecorderLnx currently sends `TemperatureCompensation=False`
  - [x] Checked `windev-v3.9\examples\mebius.daq`: useful as a portable MIC185
    Mebius DAQ example and programming-order confirmation, but base packet
    layout comes from the shared `Mebius\MebiusDAQDevices\mic185v2` sources

- [x] MIC-185 TKC/reference-channel programming parity
  - [x] Added `TMic185GroupAdditionArray` and default `groupAddition=[0,4,4,4]`
    (`CMic185ModAdd1` for channels 1..16, other groups off)
  - [x] `Mic185BuildSettingsEx` now writes configured `GroupAddition[]` and
    `TemperatureCompensation` instead of hard-coded off/false
  - [x] MIC185 source config saves/loads `dataSources[].mic185.groupAddition[]`
    and `dataSources[].mic185.temperatureCompensation`; old projects get the
    same defaults automatically
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded

- [x] MIC-185 physical units and tag dialog parity
  - [x] Added MIC185 source-level helpers for effective range and sample value
    conversion without changing MIC185 protocol units
  - [x] MIC185 tags now keep selected units (`mV`, `Ohm`, `microstrain`,
    `mV(tenzo)`) and `PublishMeasurementBlock` converts values before pushing
    samples into tags
  - [x] MIC185 channel dialog recalculates actual range when range/unit/current,
    sensor scheme, sensitivity, or resistance changes
  - [x] Tag settings dialog now exposes hardware-source setup and zero-balance
    actions for MIC185, and uses command icon 57 for hardware-curve read
  - [x] Added `Docs/devices/mic185/value_units_conversion.md` with original
    source references and RecorderLnx behavior
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded; data-source
    regression test passed

- [x] MIC-185 nominal-code units, hardware-GX message, comments, and UI encoding
  - [x] MIC185 tag values are converted in the data source from raw codes using
    nominal fallback `32768 -> 100%` of the selected range, then into the
    selected tag unit (`mV`, `Ohm`, `microstrain`, `mV(tenzo)`)
  - [x] MIC185 tag creation/linking preserves the selected unit and recalculates
    the displayed range in that unit
  - [x] Hardware-GX download button no longer reports "no MIC-140 channels" for
    MIC185; it reports that MIC185 memory read is not implemented without
    protocol work
  - [x] Added comments/codepage markers across MIC185 constants and exported
    functions; documented the nominal fallback in `Docs/devices/mic185/value_units_conversion.md`
  - [x] Cleaned dynamic UTF-8 UI strings in menus/dialogs and fixed detected
    mojibake in calibration properties and MIC185 source probe strings
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded; data-source
    regression test passed

- [x] MIC-185 explicit hardware-GX read and tag-dialog button split
  - [x] Added MIC185 hardware-GX reader using `IOCTL_CMD_GET_CALIBR_KOEF`
    from the original Recorder/Mebius device-level path
  - [x] Stored read `k,b` as a two-point hardware `TRecorderCalibration`
    implementing `k * (code - b)` and assigned it to the tag
  - [x] MIC185 source conversion now applies assigned tag hardware GX before
    unit conversion; nominal `32768 -> 100%` fallback remains when no GX exists
  - [x] Hardware-GX view/select opens the calibration list/properties dialog,
    edit opens properties for any assigned hardware GX, and read-GX dispatches
    to MIC140 or MIC185 by source type
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded after stopping a
    running `RecorderLnx.exe`; data-source regression test passed

- [x] MIC-185 hardware-GX display and read result cleanup
  - [x] Hardware-GX view button now opens the assigned calibration properties
    directly instead of the common MIC140-style calibration/source list
  - [x] MIC185 hardware-GX field displays the extracted `k,b` pair, while the
    internal `HardwareCalibrationName` remains the stable registry key
  - [x] Read-GX success message lists MIC185 `k,b` for each read tag
  - [x] Bulk read-GX success dialog now shows only the first read channel
    result and `...`, instead of a tall message box with every selected channel.
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded; data-source
    regression test passed

- [x] Active hardware source regression after tag settings OK
  - [x] `TTagSettingsDialog.CreateDialog` no longer refreshes active sources
    from the tag set.
  - [x] `TRecorderTagRegistry.RefreshActiveSourcesFromTags` no longer marks
    MIC140/MIC185 sources active only because tags exist; it keeps only always
    visible virtual/manual/debug/MERA sources.
  - [x] `TMainForm.UpdateActiveSourceIds` now registers hardware sources as
    active only when `RecorderHardwareSourceLinkOk` passes, and unregisters
    them otherwise.
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded; data-source
    regression test passed.

- [x] MIC-185 hardware-GX checkbox controls published units
  - [x] With hardware GX unchecked, MIC185 measurement tags publish raw ADC
    codes even if a calibration name exists.
  - [x] With hardware GX checked, MIC185 applies assigned GX when available;
    otherwise it keeps the nominal `32768 -> 100% range` fallback and converts
    to the selected tag unit.
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded after stopping
    a running `RecorderLnx.exe`; data-source regression test passed.

- [x] MIC-185 hardware-GX assignment persistence in tag dialog
  - [x] Project JSON now saves/loads each tag's `HardwareCalibrationName` and
    `HardwareCalibrationEnabled`.
  - [x] Tag settings OK no longer clears MIC185 `HardwareCalibrationName` /
    `HardwareCalibrationEnabled` through the MIC140 legacy cleanup helper.
  - [x] MIC185 `tagLinks[]` also saves/loads the hardware-GX assignment fields.
  - [x] The tag dialog no longer blanks MIC185 hardware-GX display after a
    multi-tag read/OK/reopen cycle.
  - [x] For MIC185 the hardware-GX field displays stored `k,b` when the
    calibration exists; if the calibration object is missing, it shows the
    stored name/alias instead of an empty field.
  - [x] Multi-select with different hardware-GX assignments shows
    `<разные аппаратные ГХ>` and keeps the checkbox grayed, so OK does not
    overwrite per-channel assignments.
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded after stopping
    a running `RecorderLnx.exe`; data-source regression test passed.

- [x] MIC-185 hardware-GX disk cache
  - [x] Hardware GX read now uses disk cache before device read:
    `C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`.
  - [x] Successful device reads save the two-point CSV equivalent of
    `y = k * (code - b)` and assign a stable name
    `MIC185 snXXXX rangeN chCC`.
  - [x] Reopening a MIC185 tag dialog can restore a saved GX object from disk
    when the project still has only the persisted GX name.
  - [x] MIC185 runtime publication lazily restores the saved GX from disk
    before falling back to nominal conversion after project reload.
  - [x] Added `Docs/devices/mic185/hardware_calibration_cache.md` with sources,
    file format and original Recorder comparison.
  - [x] Rebuild `RecorderLnx.lpi` via `lazbuild -B` succeeded; data-source
    regression test passed.
- [x] Подключить MC-032/MC-201 к runtime режима просмотра
  - [x] Создать `IRecorderDataSource`-обёртку над `TRecorderMcbusDevice`.
  - [x] Добавить источник в фабрику главной формы по выбранным MC-032 тегам.
  - [x] Сопоставить tree-indexed адреса тегов с нативными `slot-channel`.
  - [x] Добавить lifecycle/block/timeout диагностику `[MCBUS]`.
  - [x] Зафиксировать ошибку и правило полного runtime-среза устройства.
- [x] MCbus: smoke-тест Preview и безопасная остановка
  - [x] Проверить production `TRecorderMcbusDevice` на реальном MC-032.
  - [x] Подтвердить 5 блоков/с при периоде 200 мс.
  - [x] Не выбрасывать исключение при fallback-отключении после таймаута STOPSCANMAIN.
  - [x] Зафиксировать lifecycle-правило и журнал расследования.
- [x] MC-201: исправить payload и обеспечить полный поток 57,6 кГц
  - [x] Разделять агрегированный MDP payload на BIOS-сообщения по длине.
  - [x] Исключить десятисловный заголовок из данных канала.
  - [x] Программировать ADSP FIFO 256 на канал, как в оригинале.
  - [x] Накапливать ровно 11 520 отсчётов/канал на блок 200 мс.
  - [x] Подтвердить 288 000 отсчётов/канал за 5 секунд на стенде.
- [x] Восстановить полный перечень диапазонов MC-201 по `ranges_MC201`.
- [x] Сделать второй цвет общей палитры тёмным травяным и проверить индексные назначения.
# Выполнено 2026-07-16

- [x] Зафиксировать ТЗ единого менеджера алгоритмов и результаты сверки с `plgControlCyclogram`.
- [x] Переименовать спектральный тег частоты максимума `fmax` в `f1` с миграцией существующего `TagId`.
- [ ] Реализовать единый `TRecorderAlgorithmManager` по `Docs/algorithm-manager-requirements.md` поэтапно, сохранив работающий spectrum runtime.
- [x] Цифровой индикатор: автоматический перенос длинного имени, режим без имени и сохранение `ShowNameMode`.

- [x] Вынести математические юниты спектров в `Algs`.
- [x] Добавить включаемые оценки по частотным полосам: СКЗ, максимум, частота максимума.
- [x] Применять те же оценки к итоговому спектру после включённого интегрирования x1/x2.
- [x] Добавить в диалог флаги оценок и записи в теги.
- [x] Создавать и заполнять производные теги для настроенных каналов.
- [x] Проверить сборкой RecorderLnx и спектральным тестовым стендом.
- [x] Добавить в выбранные каналы фильтры «Скрыть неактивные» и «Только виртуальные» без изменения реестра тегов.

## 2026-07-16 — единый выбор канала осциллограммы

- [x] Удалить из диалога нижний дублирующий выбор `Тег`.
- [x] Оставить единый selector `Канал` и синхронизировать его с выбранной строкой списка.
- [x] Сохранить добавление/удаление линий, цвет, видимость, сериализацию и ограничение одним `SourceId`.
- [x] Выполнить полную сборку `RecorderLnx.lpi` (`lazbuild -B`, exit code 0).

## 2026-07-16 — выбранная линия спектра и диапазоны MC-201

- [x] Связать выбор строки легенды с `SelectedObject` графика.
- [x] При Shift выбирать ближайший к указателю локальный минимум/максимум выбранной линии; Ctrl+Shift оставляет явный минимум.
- [x] В одномлинейном режиме показывать Y выбранной линии и учитывать её ось, включая логарифмическую.
- [x] Передать `SpecificConfigText` MCbus из конфигурации проекта в runtime-драйвер.
- [x] Формировать регистр диапазонов MC-201 по оригинальным `SetRange`, `SetControlRegV5` и `SetControlReg`.
- [x] Выполнить полную сборку `RecorderLnx.lpi` (`lazbuild -B`, exit code 0).

## 2026-07-16 — ICP/IEPE MC-201

- [x] Сверить программирование ICP с `mtc/Mc201.cpp`.
- [x] Читать `b8..b11`, входной режим и тип субмодуля из `SpecificConfigText`.
- [x] Перенести `CMD_SET_PROPERTY`, `CMD_GET_OBJECT` и `CMD_SEND_CONTROL_WORD` MM202.
- [x] Повторить UI-логику оригинала: ICP включает недифференциальный режим и блокирует его выбор; снятие ICP возвращает дифференциальный режим.
- [x] Выполнить полную сборку `RecorderLnx.lpi` (`lazbuild -B`, exit code 0).
- [ ] Подтвердить включение питания IEPE электрически на подключённом датчике.

## 2026-07-16 — частотная сетка аппаратного модуля

- [x] Добавить общий реестр частотных сеток без зависимостей от устройств в UI.
- [x] Зарегистрировать 16 частот MC-201 по оригинальной `ModuleMC201::IndexToFreq`.
- [x] Заполнять список частот диалога тега по `SourceId` аппаратного модуля.
- [x] Добавить выбор кварца MC-032: 14,7456 МГц и специсполнение 16,384 МГц.
- [x] Сохранять кварц в конфигурации и использовать его одновременно в сетке UI
  и при программировании `FreqIndex/GridCode` MC-201.
- [x] Применять частоту дискретизации MC-201 ко всем четырём каналам выбранного
  слота, сохраняя независимые частоты соседних слотов в runtime и записи.
- [x] Реализовать аппаратную балансировку MC-201 через `SEND_BALANCE_CC`,
  служебные 60-мс сборы и сохранение кода ЦАП по каналу/диапазону.
- [x] Выполнить полную сборку `RecorderLnx.lpi` (`lazbuild -B`, exit code 0).

## 2026-07-16 — обратный zoom осциллограмм

- [x] На базовой странице сбрасывать Y-масштаб по минимуму/максимуму текущего кадра с запасом 20%.
- [x] Применить то же поведение к компоненту осциллограммы на редактируемой странице.

## 2026-07-16 — выбранный канал базовых осциллограмм

- [x] Передавать фактически выделенный справа канал в `TagRegistry.SelectedTagName`.
- [x] Немедленно ставить выбранный канал в первую осциллограмму базовой страницы.
- [x] Выводить для базовой осциллограммы все включённые оценки тем же общим форматтером, что и в редактируемом компоненте.

## 2026-07-16 — немедленная смена канала линии

- [x] При выборе канала сразу перепривязывать выделенную линию осциллограммы.
- [x] Не допускать назначения одного канала двум линиям.
- [x] Сохранить добавление новых линий через следующий свободный канал.

## 2026-07-16 — сервисные кнопки MC-201

- [x] Показать для каналов MC-201 балансировку, аппаратную настройку и чтение аппаратной калибровки.
- [x] Вынести сервисные действия в полиморфный контракт базового устройства.
- [x] Открывать аппаратные свойства выбранного слота MC-201.
- [x] Подключить балансировку MC-201 через источник данных и драйвер MCbus.
- [x] Зафиксировать ограничение чтения заводской flash-калибровки и правило предотвращения регрессии.
- [x] Выполнить полную сборку `RecorderLnx.lpi` (`lazbuild -B`, exit code 0).

## 2026-07-16 — контрастная палитра графиков

- [x] Сверить источник общей палитры с использованием `ColorArray` в `plgControlCyclogram`.
- [x] Перенести полный исходный `ColorArray[0..17]` из `uCommonTypes` без чёрного цвета.
- [x] Выполнить полную сборку `RecorderLnx.lpi` (`lazbuild -B`, exit code 0).

## 2026-07-21 — Расширенное техническое задание на модуль калибровки и поверки

**Промпт**: Дополнить ТЗ модуля калибровки/поверки следующими режимами: контрольная точка (мат.ожидание, шум, АЧХ, фаза), проход Up/Down, гистерезис, многопроходность, динамический эталон (сличение), размер порции, настройка вычисляемых оценок расчетов, канальные мультипликаторы (шунты/емкости), многоканальность (параллельно/последовательно с коммутацией), стадийность (проверка диапазонов 1, 2 и т.д.), индивидуальные настройки приборов (эталон, измеритель, коммутатор, усилитель) для каждой КТ, с учетом опыта модулей поверки Recorder (Codelator/AutoCalib).

- [x] Расширено и создано подробное ТЗ в `Docs/calibration_module_tz.md`.
- [x] Описана стадийность процесса поверки (Stages) с разбивкой по поддиапазонам измерителя.
- [x] Описано профилирование настроек приборов (генератор/эталон, измеритель, коммутатор, усилитель) для каждой КТ.
- [x] Описана настройка вычисляемых оценок (мат. ожидание, СКЗ, Peak-to-Peak, гармоника БПФ, фазовый сдвиг, THD, медиана).
- [x] Описаны канальные мультипликаторы $K_{ch}$ и смещения $B_{ch}$ (для учета шунтов, емкостей, делителей).
- [x] Описан механизм полок, проходов Up/Down, расчета гистерезиса и многопроходной циклической поверки.
- [x] Описан динамический эталон с канала обратной связи (сличение в реальном времени).
- [x] Описано конфигурирование порций данных (время выдержки Settling Time, размер в сек/отсчетах/по стабильности).
- [x] Описана многоканальная параллельная/последовательная обработка с авто/ручной коммутацией.
- [x] Обновлена заметка `cach/notes_calibration_tz.md` со сводкой всех 9 требований.

