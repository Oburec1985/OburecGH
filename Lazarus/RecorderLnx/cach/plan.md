# План: доработка RecorderLnx

- [x] Исправить наползание элементов на вкладке `Дополнительно` в диалоге настройки тега
  (`UI/uTagSettingsDialog.lfm`): увеличены нижние группы и добавлены вертикальные зазоры.

- [ ] MIC-140 debug stand (`Tests/Mic140ProtocolDebug`): PASS AIn 1–48 ±50 + TIn 1–3
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
