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
  - [x] Поле fRunSettings.DataUpdateMs связано с ShowTagSettingsDialog в uMainForm.pas
  - [x] Исправлено заполнение fDataUpdateMs (теперь берется из настроек при CreateDialog в uRecorderSettingsDialog.pas)

- [x] Логирование отладки (Windows / Linux)
  - [x] Создан новый модуль uRecorderDebugLog.pas
  - [x] Добавлено раздельное логирование (LogWindows.log / LogLinux.log) на основе ParamStr(0)
  - [x] Подключен к остальным модулям

- [x] Тестирование сборки под Windows и Linux

- [ ] Редактирование узла устройства по двойному клику в дереве оборудования (Промпт: "в RecorderLnx по dblClick сделай редактирование узла")
  - [ ] Изменить fHardwareTreeDblClick в uRecorderSettingsDialog.pas для вызова HardwareEditSourceClick

- [ ] Формирование адресов каналов MIC-140 в формате "2-01"
  - [ ] Обновить uRecorderMic140DataSource.pas (BuildChannels, FindTagBySourceAddress)
  - [ ] Обновить uRecorderSettingsDialog.pas (BuildMic140Signals, RestoreMeraSignalsFromTags, GetMic140SelectedChannels)
  - [ ] Проверить сборку проекта и запустить тесты

