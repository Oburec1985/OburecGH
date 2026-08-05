# RecorderLnx: карта исходников оригинального Recorder

Источник: `D:\works\windev-v3.9`.

Назначение файла: держать под рукой карту старого Recorder, чтобы брать проверенные архитектурные идеи и не искать их заново. Это не план прямого переноса C++/COM/MFC-кода. Для RecorderLnx берем понятные механики, имена и жизненные циклы, но строим кроссплатформенную Lazarus/FPC-архитектуру.

## Область анализа

Ядро и близкие к ядру каталоги:

| Каталог | Роль в оригинальном Recorder | Что брать в RecorderLnx |
| --- | --- | --- |
| `recorder` | Пусковой exe: загрузка `rc_core.dll`, выбор UI server, чтение `/cfg:`, логирование, проверка версий, главный message loop. | Разделение launcher/app shell и core; параметр запуска проекта; ранний лог; загрузка UI как отдельного слоя. |
| `rcrl` | Лаунчер/вспомогательный стартовый проект. | Только как справка по запуску, не как архитектурная база. |
| `mr` | Базовая runtime-библиотека: `IRecorder`, `IRecorderPlugin`, теги, группы, плагины, processing manager, targets, буферы. | Основные имена, lifecycle и смысл интерфейсов: `Recorder`, `PluginManager`, `Tag`, `Processing`, `Target`, `Notify`. |
| `mr\iface` | COM-интерфейсы: `IRecorder`, `IRecorderPlugin`, `IVForm`, `IProcessing`, `IProcessingManager`, `ISettingsINI`, `ISettingsStorage`, toolbar API. | Функциональный каталог будущих интерфейсов RecorderLnx. COM не переносить. |
| `rc_core` | Измерительное ядро: состояние, теги измерения, запись кадров, шаблоны каталогов, тревоги, файл/поток записи. | Режимы Stop/View/Record, кадр записи как каталог, нотификации старта/стопа, шаблоны путей, data targets. |
| `rc_guisrv` | UI server: формуляры, менеджер визуализации, мнемосхемы, тулбары, диалоги настройки, пользовательские кнопки. | Менеджер формуляров, вкладки/отцепление форм, toolbar/action registry, фабрики визуальных компонентов. |
| `rc_ctrpn` | Панель управления, статус, ресурсы кнопок/иконок. | UI-ориентир для пульта состояния и команд; ресурсы как пример, не как зависимость. |
| `rc_conui` | Консольный/альтернативный UI слой. | Подтверждает, что UI можно отделять от core. |
| `rc_utils` | Профили/INI, логирование, строки, утилиты, cached profile. | Идея общего слоя утилит; в RecorderLnx заменить переносимыми FPC/Lazarus units. |

Каталоги конкретных устройств, драйверов, `Debug/Release`, MIDL-генерация, старые build-артефакты и vendor-библиотеки в карту не включаются. Их смотреть только как примеры плагинов/устройств по конкретной задаче.

## Навигация по каталогам `windev-v3.9`

Этот раздел отвечает на практический вопрос: в какой каталог идти, если надо понять конкретную часть Recorder.

### `recorder`

Пусковой проект Recorder. Здесь не ядро измерений, а приложение-оболочка, которое поднимает окружение.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Как выбирается проект при запуске | `Recapp.cpp`, поиск `CFG_PREFIX`, `/cfg:` |
| Как грузится ядро | `Recapp.cpp`, `LoadLibrary("rc_core.dll")`, `GetRecorderCoreClassObject` |
| Как грузится UI server | `Recapp.cpp`, чтение секции `recorder`, параметр `uiserver`, загрузка `rc_guisrv.dll` |
| Как устроен главный цикл сообщений | `CRecorderApp::Run` |
| Как закрывается приложение | `CRecorderApp::ExitInstance` |
| Логи и обработка аварий | `ExceptionHandler.*`, `Logger`, `rclog_init`, `rc_error_filter` |
| Ресурсы стартового приложения | `Recorder.rc`, `res\` |

В RecorderLnx этот слой соответствует будущему `ApplicationShell`: параметры запуска, выбор проекта, создание core/UI, ранний лог и порядок shutdown.

### `rcrl`

Небольшой launcher/служебный стартовый проект. Для архитектуры RecorderLnx вторичен.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Вспомогательная логика запуска | `rcrl.cpp` |
| Ресурсы launch-окна | `rcrl.rc`, `res\` |

Использовать только как справку, если потребуется понять старую цепочку запуска.

### `mr`

Базовый runtime Recorder. Это один из главных каталогов для понимания архитектуры. Здесь лежат абстракции, которыми пользуются core, UI и плагины.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Главный объект Recorder | `rcmain.h`, `rcmain.cpp` |
| Плагины и автозагрузка | `pluginsman.h`, `pluginsman.cpp` |
| Базовый тег | `basetag.h`, `Basetag.cpp` |
| Буферы/векторы данных | `DataVector.*`, `dfvector.*`, `Fifo.*`, `PlainBuffer.*`, `BufferSupportTag.*` |
| Группы тегов | `tagsgroup.*` |
| Data targets/pipeline | `Target.*`, `TargetsList.*`, `itarget.h` |
| Processing manager | `ProcessingManager.*`, `CommonProcessingFactory.h` |
| Трансформеры/пересчеты | `Transformer.*` |
| Единицы измерения | `meUnits.h` |
| COM/API интерфейсы | `iface\` |

Подкаталог `mr\iface` — особенно важный. Там лежит контрактная карта Recorder:

| Файл | Назначение |
| --- | --- |
| `IRecorder.h` | главный фасад, состояния `RS_*`, команды `RCN_*`, свойства `RCPROP_*` |
| `rcplugin.h` | `IRecorderPlugin`, `PN_*`, `PLUGININFO`, `STARTCTRL`, `RCDATAPLACEMENT` |
| `ivform.h` | интерфейс формуляра `IVForm` |
| `cb_toolbar.h` | интерфейс пользовательских toolbar-кнопок |
| `IProcessing.h`, `IProcessingManager.h` | обработчики данных и их фабрики |
| `itag.h`, `ITagsManager.h`, `ITagsList.h`, `itaggrp.h` | теги, списки и группы |
| `settingsini.h` | INI-сохранение настроек |
| `IDataFolderTemplate.h` | шаблоны каталогов данных |
| `ITimeMashine.h` | машина времени |
| `iuisrv.h` | UI server API |
| `uAlarms`-семейство (`ialarm.h`, `IAlarmSet.h`, `alrmctrl.h`) | тревоги/уставки |

`mr\Debug` и `mr\Release` — артефакты сборки, как источник архитектуры не использовать.

### `rc_core`

Измерительное ядро Recorder. Здесь смотреть фактическую реализацию режимов, записи, тегов измерения, кадра записи, тревог и шаблонов каталогов.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Главный core-класс | `rc_core.h`, `Rc_core.cpp` |
| Режимы Stop/View/Record и нотификации | `Rc_core.cpp`, поиск `PN_BEFORE_RCSTART`, `PN_RCSTART`, `PN_RCSTOP`, `PN_UPDATEDATA` |
| Кадр записи и имя каталога | `Rc_core.cpp`, методы `GetDataFrameName`, `GetSignalFrameName`, `SetSignalFrameName` |
| Инкремент имени кадра | `Rc_core.cpp`, участок вокруг изменения `m_strDataFrameName` |
| Теги измерения | `MeasurementTag.h`, `MeasurementTag.cpp`, `MeasurementTag.inl` |
| Запись в файлы | `CycleFile.h`, `CycleFile.cpp`, `MeraFileWriter*` |
| Шаблон каталога данных | `DataFolderTemplate.h`, `DataFolderTemplate.cpp`, `DftBaseItem.h`, `DftFactoryImpl.h` |
| Тревоги/уставки | `Alarm.*`, `AlarmSet.*`, `alarmtarget.*` |
| Машина времени | `TimeMashine.*` |
| Служебные tags update sets | `TagsUpdateSet.*` |
| Оценки/targets | `estimatortarget.*`, `RecTarget.*` |

Подкаталог `dev_wrap` связан с обертками устройств. Его смотреть позже, когда дойдем до реальных источников данных.

`rc_core_enu` — локализация/английские ресурсы для `rc_core`, не основная логика.

### `rc_guisrv`

UI server Recorder. Главный каталог для формуляров, мнемосхем, toolbar-ов, визуальных компонентов и диалогов настройки. Здесь много Windows/MFC-кода, но очень полезна механика.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Менеджер формуляров | `visual\visman.h`, `visual\visman.cpp` |
| Диалог управления формулярами | `visual\vismnpp.h`, `visual\vismnpp.cpp` |
| Импорт/экспорт/доп. управление формулярами | `visual\vismnxpp.*` |
| Верхний toolbar с вкладками | `visual\RcMainToolBar.*`, `FormsTabCtrl.*` |
| Плавающие окна формуляров | `visual\VFormHolder.*`, методы attach/detach в `visman.*` |
| Мнемосхемы | `mnemo\`, частично `visual\` |
| Визуальные компоненты | `visual\RcOscill.*`, `visual\Rcline.*`, `visual\RcTrckRect.*`, `visual\of_ctrl.*`, индикаторы в `ind_wrap\` |
| Пользовательские кнопки toolbar | `CustomButtonsToolBar.*`, `CustomButtonsMainToolBar.*`, `visual\CustomButtonsPanel.*` |
| Диалоги настройки Recorder | `setup\` |
| Ресурсы и иконки UI | `res\` |
| Утилиты UI | `utils\` |
| Дополнительные interface-defs | `Interfaces\meObjectDev_def.h`, `Interfaces\meObjectPlacement_def.h` |

`rc_guisrv_enu` — локализация/английские ресурсы для UI server.

### `rc_ctrpn`

Панель управления Recorder: состояние, кнопки, ресурсы, меню. Полезна как ориентир по внешнему виду и поведению пульта, но не как core.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Статусная панель | `statusbar.*` |
| Меню/команды панели | `XMenu.*` |
| Кнопки и ресурсы пульта | `res\`, особенно `res\v3\` |
| Project/resource wiring | `*.rc`, `*.vcxproj` |

`rc_ctrpn_eng` — английская/ресурсная версия. Базовую механику смотреть в `rc_ctrpn`.

### `rc_conui`

Альтернативный/консольный UI слой. Важен как подтверждение, что core может жить отдельно от конкретного GUI.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| Минимальная UI-обвязка | `rc_conui.h`, `rc_conui.cpp` |
| Сборка слоя | `*.vcxproj`, `*.sln` |

### `rc_utils`

Общие утилиты Recorder.

Что искать:

| Что нужно понять | Куда смотреть |
| --- | --- |
| INI/profile API | `profile.*`, `cached_profile.*` |
| Логирование | `Logger.*`, `meLogger.*`, `logprint.*` |
| GUID/строки/общие helpers | `Guid.*`, `rcutils.*`, `zstring`-использование |
| Property pages/helpers | `PropertyPageImpl.*` |
| Шкалы/служебные interfaces | `scales.h`, `strms.h`, `estim_ctrl.*` |

В RecorderLnx этот слой должен быть заменен переносимыми units в `Lazarus\SharedUtils` или локальными core-utils без Windows-only зависимостей.

### `rc_backup_enu`, `rc_core_enu`, `rc_guisrv_enu`, `rc_ctrpn_eng`

Это в основном локализация, ресурсы или альтернативные языковые сборки. Для анализа архитектуры смотреть после основного каталога и только если нужен текст ресурсов/иконок/диалогов.

## Быстрый указатель: где искать задачу

| Задача | Первый каталог | Второй каталог |
| --- | --- | --- |
| Плагин, lifecycle, автозагрузка | `mr\pluginsman.*` | `mr\iface\rcplugin.h`, `rc_guisrv\setup\alpc.*` |
| Команды и состояния Recorder | `mr\iface\IRecorder.h` | `rc_core\Rc_core.cpp` |
| Старт/останов просмотра и записи | `rc_core\Rc_core.cpp` | `mr\iface\rcplugin.h` |
| Кадры записи и каталоги данных | `rc_core\Rc_core.cpp` | `rc_core\DataFolderTemplate.*` |
| Теги и буферы | `mr\iface\itag.h` | `rc_core\MeasurementTag.*`, `mr\basetag.*` |
| Формуляры и вкладки | `rc_guisrv\visual\visman.*` | `mr\iface\ivform.h` |
| Мнемосхемы и компоненты | `rc_guisrv\mnemo\` | `rc_guisrv\visual\`, `ind_wrap\` |
| Toolbar-ы и кнопки плагинов | `mr\iface\cb_toolbar.h` | `rc_guisrv\CustomButtonsToolBar.*` |
| Processing/обработка данных | `mr\iface\IProcessing*.h` | `mr\ProcessingManager.*`, `mr\TargetsList.*` |
| Сериализация настроек | `include\ISettingsStorage.h` | `mr\iface\settingsini.h`, `rc_utils\profile.*` |
| Внешний вид пульта | `rc_ctrpn\res\` | `rc_ctrpn\statusbar.*` |
| Запуск приложения | `recorder\Recapp.cpp` | `rcrl\` |

## Ключевые файлы

| Файл | Смысл | Что полезно |
| --- | --- | --- |
| `recorder\Recapp.cpp` | Старт приложения: лог, путь проекта, загрузка `rc_core.dll` и `rc_guisrv.dll`, message loop, graceful exit. | Для RecorderLnx: явный `ApplicationShell`, чтение параметра проекта, загрузка core/UI, shutdown-порядок. |
| `mr\iface\IRecorder.h` | Главный фасад Recorder: состояния `RS_*`, команды `RCN_*`, свойства `RCPROP_*`, доступ к тегам/формам/устройствам. | Называть аналог `IRecorderHost`/`TRecorderCore` похоже, но разделить на узкие сервисы. |
| `mr\iface\rcplugin.h` | `IRecorderPlugin`, `PLUGININFO`, события `PN_*`, `STARTCTRL`, `RCDATAPLACEMENT`. | Основа новой plugin API: lifecycle, typed notify, управление стартом/стопом, смена каталога кадра. |
| `mr\pluginsman.h/.cpp` | Загрузка плагинов через DLL, `GetPluginType`, `CreatePluginClass`, `DestroyPluginClass`, `GetPluginInfo`, автозагрузка, `NotifyPlugins`, защита от падений. | Для RecorderLnx: `TRecorderPluginManager`, контекст плагина, автозагрузка, ошибки плагина не должны валить ядро. |
| `mr\iface\ivform.h` | `IVForm`: `init`, `prepare`, `update`, `repaint`, `activate`, `deactivate`, `edit`, `notify`. | Основа `IRecorderForm` и событий формуляров без HWND в core. |
| `rc_guisrv\visual\visman.h/.cpp` | `CVisualizationManager`: список форм, активная форма, attach/detach, save/load, register/unregister. | Менеджер формуляров с вкладками и плавающими окнами. |
| `rc_guisrv\visual\vismnpp.h/.cpp` | Диалог управления формулярами: добавить мнемосхему, удалить, активировать, отцепить, импорт/экспорт. | UI-сценарий диалога формуляров RecorderLnx. |
| `rc_guisrv\visual\RcMainToolBar.h/.cpp` | Верхний toolbar формуляров, вкладки и кнопка списка форм. | Верхняя панель `PageControl` + кнопка управления формулярами. |
| `mr\iface\cb_toolbar.h`, `rc_guisrv\CustomButtonsToolBar.*` | Пользовательские toolbar-кнопки, owner, id, mode, enable, click/query state через `PN_CUSTOM_BUTTON_*`. | `TRecorderActionRegistry` и `TRecorderToolbarRegistry`: плагины добавляют действия, UI отображает их. |
| `mr\iface\IProcessing.h`, `IProcessingManager.h`, `mr\ProcessingManager.*` | Фабрики обработок, экземпляры processing, settings pages, `Program/Start/Stop/OnUpdateData`. | Отдельный registry обработчиков данных, привязка входов/выходов к тегам, страницы настройки. |
| `mr\TargetsList.h/.cpp`, `mr\Target.h` | Список targets на теге: prepare/start/exec/stop/finish. | Потоковая обработка данных на уровне канала/буфера как pipeline. |
| `include\ISettingsStorage.h`, `mr\iface\settingsini.h` | Структурированное чтение/запись именованных параметров, subnodes, buffers. | Единый serializer API для модулей вместо разрозненных INI-записей. |
| `rc_core\DataFolderTemplate.*` | Фабрики элементов шаблона пути, генерация каталога кадра, `OnStart/OnStop`, сериализация. | Проектный сервис `TRecorderFramePathTemplate` с расширяемыми элементами. |
| `rc_core\CycleFile.*` | Циклическая/потоковая запись данных в файлы. | Идея writer-слоя; реализацию проектировать заново под кроссплатформенность. |
| `rc_core\MeasurementTag.*` | Тег измерения: буферы, targets, запись, оценки, связь с источником. | Разделить в RecorderLnx на `TTag`, `TSignalBuffer`, `TTagWriter`, `TTagProcessor`. |

## Что не копируем

- COM/ATL/MFC как основу архитектуры.
- `HWND`, `IPicture`, `BSTR`, `VARIANT` в ядре RecorderLnx.
- Windows-only загрузку и SEH как единственный механизм устойчивости.
- Глобальные переменные ядра как основной способ связи.
- Старый бинарный формат конфигурации без отдельного решения о совместимости.
- Device-specific проекты и драйверные библиотеки как часть базового ядра.

## Полезные идеи оригинального Recorder

1. `IRecorder` как центральный фасад удобен для плагинов, но внутри RecorderLnx фасад должен быть набором сервисов: `Tags`, `Events`, `Actions`, `Forms`, `Config`, `Storage`, `Log`, `DataSources`, `Processing`.
2. Плагины имеют lifecycle: `create/config/edit/execute/suspend/resume/notify/canclose/close`. В RecorderLnx сохранить смысл методов, но сделать Object Pascal API и отдельный C ABI слой для внешних библиотек.
3. `PN_*` уведомления покрывают не только данные, но и UI, конфиг, кадры записи, безопасность, hotkeys. В RecorderLnx нужны типизированные события с похожими именами и назначением.
4. UI расширяется через реестры: формуляры, toolbar-кнопки, custom forms, pages. В RecorderLnx это должны быть registry-сервисы, доступные плагинам.
5. Формуляр может быть вкладкой или отцепленным окном. Это уже есть в `CVisualizationManager::DetachForm/AttachForm`; в RecorderLnx проектируем `TRecorderFormHost` без привязки к главной форме.
6. Обработка данных отделена фабриками `IProcessingFactory` и менеджером `IProcessingManager`; это лучше, чем зашивать обработку в теги или UI.
7. Каталог кадра записи и его имя могут формироваться шаблоном; плагины могут реагировать на смену data placement.
8. Настройки модулей лучше сохранять через общий storage API, а не через случайные секции в одном файле.

## Предлагаемая модель расширяемости RecorderLnx

На уровне ядра:

- `TRecorderExtensionManager` — менеджер расширений и их контекстов.
- `IRecorderExtension` — базовый интерфейс статического/динамического модуля.
- `TRecorderHostApi` — набор сервисов, который получает расширение.
- `TRecorderEventBus` — типизированная событийная шина.
- `TRecorderActionRegistry` — команды/действия, которые UI может показать как кнопки/меню/hotkeys.
- `TRecorderToolbarRegistry` — группировка действий в toolbar-ы.
- `TRecorderVisualFactoryRegistry` — фабрики компонентов формуляров и мнемосхем.
- `TRecorderFormRegistry` — фабрики формуляров/страниц.
- `TRecorderConfigRegistry` — страницы настройки и сериализаторы.
- `TRecorderProcessingRegistry` — фабрики обработчиков данных.
- `TRecorderDataSourceRegistry` — фабрики источников данных.
- `TRecorderStorageRegistry` — writers/readers форматов данных.

Минимальный Object Pascal lifecycle:

```pascal
type
  IRecorderExtension = interface
    function GetInfo: TRecorderExtensionInfo;
    procedure Initialize(const AHost: IRecorderHost);
    procedure RegisterServices(const ARegistry: IRecorderExtensionRegistry);
    procedure Configure;
    procedure Start;
    procedure Stop;
    function CanClose: Boolean;
    procedure Close;
    procedure Notify(const AEvent: TRecorderEvent);
  end;
```

Для внешних `.dll/.so` позже использовать C ABI без FPC-строк и объектов на границе:

- `RecorderPlugin_GetApiVersion`
- `RecorderPlugin_GetInfo`
- `RecorderPlugin_Create`
- `RecorderPlugin_Destroy`
- `RecorderPlugin_Register`
- `RecorderPlugin_Notify`

В первой фазе можно реализовать статические расширения как классы Lazarus/FPC. Главное: не строить код так, чтобы потом нельзя было вынести модуль в `.dll/.so`.

## События RecorderLnx по аналогии с PN/RCN

| Recorder | RecorderLnx | Назначение |
| --- | --- | --- |
| `PN_BEFORE_RCSTART` | `rceBeforeStart` | Модули могут проверить готовность и отменить старт через control object. |
| `PN_RCSTART` | `rceStarted` | Сбор/просмотр начат. |
| `PN_ON_REC_MODE` | `rceRecordModeEntered` | Перешли в запись, открыт кадр. |
| `PN_RCSTOP` / `PN_AFTER_RCSTOP` | `rceStopped` / `rceAfterStop` | Останов потоков/записи и финальная уборка. |
| `PN_UPDATEDATA` | `rceDataUpdated` | Обновлены теги/источники; основной hook плагинов обработки. |
| `PN_RCSAVECONFIG` / `PN_RCLOADCONFIG` | `rceSaveConfig` / `rceLoadConfig` | Сохранение/загрузка проектной конфигурации. |
| `PN_IMPORTSETTINGS` / `PN_EXPORTSETTINGS` | `rceImportSettings` / `rceExportSettings` | Обмен настройками модулей. |
| `PN_ON_CHANGE_DATAPLACEMENT` | `rceDataPlacementChanged` | Сменился каталог/кадр записи. |
| `PN_CUSTOM_BUTTON_CLICK` | `rceActionExecute` | UI выполнил действие, зарегистрированное модулем. |
| `PN_ON_CHANGE_FORMS` | `rceFormsChanged` | Изменились формуляры, активная вкладка, attach/detach. |

## Relationships

- [Архитектура приложения](./01_Архитектура.md)
- [Карта интерфейсов Windows Recorder](./03_Карта_Интерфейсов.md)
- [Архитектурные решения](./05_Архитектурные_Решения.md)
