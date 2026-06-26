# План: доработка RecorderLnx

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
