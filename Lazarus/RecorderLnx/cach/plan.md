# План: доработка RecorderLnx

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
