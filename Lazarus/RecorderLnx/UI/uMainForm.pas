unit uMainForm;

{
  Модуль uMainForm

  Назначение:
    Главная форма приложения RecorderLnx. Реализует графический интерфейс (UI shell)
    рабочего окна рекордера в соответствии с оригинальным дизайном Recorder:
    - Вкладки формуляров отображения в верхней части экрана.
    - Центральная область отображения активного формуляра (таблица или полотно мнемосхемы).
    - Правая панель состояния и команд сбора данных/записи.
    - Боковая панель поиска и быстрого выбора каналов (тегов).
    - Нижнее текстовое окно для ведения логов событий.

  Связь с архитектурой:
    Служит оболочкой (View/Controller уровня приложения), которая координирует работу
    и реагирует на события ядра рекордера:
    - TRecorderStateMachine (автомат состояний сбора данных).
    - TRecorderRunControlSettings (настройки условий старта/останова записи).
    - TRecorderFormManager (управление конфигурацией мнемосхем и экранов).
    - TRecorderTagRegistry (реестр сигналов/тегов).
    - TRecorderDataSourceManager (управление источниками и потоками данных).
    - TRecorderTimeSystem (ведение системного времени и времени записи).
    - TRecorderEventSnapshotQueue (потокобезопасная очередь доставки событий UI).

  Ограничения:
    Центральные графические формуляры мнемосхем редактируются во встроенном режиме конструктора
    посредством TFormEditorController. Изменения сохраняются в файлы проекта (.gui, .ini, .tags).

  Кодировка (2026-06): файл в UTF-8. См. Docs/source-encoding.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, Buttons, ImgList, ComCtrls, Spin, Math, Menus, LConvEncoding, LCLIntf,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderFormModel,
  uRecorderCoreServices, uRecorderTags, uRecorderDataSources, uRecorder,
  uRecorderEventQueue, uRecorderTimeSystem, uRecorderUiTestData, uFormPagesDialog,
  uFormEditorController, uRecorderSettingsDialog, uTagSettingsDialog,
  uRecorderTagRefs,
  uRecorderCommandImages, uRecorderProjectFiles, uRecorderDigitalPageView,
  uRecorderOglOscillogramView, uRecorderDebugLog, uRecorderAlarms, uRecorderDataStorage,
  uRecorderSpectrumRuntime,
  uRecorderRuntimeSourceFactory, uRecorderTagDeviceServices,
  uRecorderHardwareTree,
  uRecorderMeraPaths;

type
  TRecorderLogKind = (rlkSystem, rlkData, rlkAlarm);

  { TMainForm }

  { Класс главной формы приложения RecorderLnx }
  TMainForm = class(TForm)
    btnAddPage: TButton;                         // Кнопка вызова диалога страниц/формуляров
    btnClearSearch: TButton;                     // Кнопка очистки фильтра поиска тегов
    btnPreview: TSpeedButton;                    // Кнопка запуска просмотра (без записи)
    btnRecord: TSpeedButton;                     // Кнопка запуска записи данных
    btnRunWinpos: TSpeedButton;                  // Кнопка запуска Winpos для последнего MERA-файла
    btnSaveConfig: TSpeedButton;
    btnSaveConfigAs: TSpeedButton;                 // Кнопка сохранения текущей конфигурации проекта
    btnSettings: TSpeedButton;                   // Кнопка вызова общего диалога настроек
    btnStop: TSpeedButton;                       // Кнопка останова сбора/записи
    btnTrigger: TSpeedButton;                    // Кнопка принудительного старта по выполнению условий
    edTagSearch: TEdit;                          // Поле поиска (фильтрации) тегов
    ilCommandButtons: TImageList;                // Список картинок для кнопок управления
    ilTagDialogButtons: TImageList;              // Список картинок для кнопок настройки каналов
    lbState: TLabel;                             // Текстовый индикатор текущего состояния автомата
    lbTags: TListView;                           // Список тегов проекта с их текущими значениями
    lbTime: TLabel;                              // Индикатор времени (системного или длительности записи)
    mmLog: TMemo;                                // Поле вывода протокола (лога) работы программы
    pnMain: TPanel;                              // Главная центральная панель (область формуляров)
    pnRight: TPanel;                             // Правая боковая панель
    pnRightCommands: TPanel;                     // Панель кнопок управления сбором
    pnRightStatus: TPanel;                       // Панель индикатора состояния
    pnTagSearch: TPanel;                         // Панель поиска тегов
    pnToolbar: TPanel;                           // Верхняя панель вкладок формуляров
    sgFormular: TStringGrid;                     // Таблица отображения цифровых значений (Digital Form)
    SplitterLog: TSplitter;                      // Разделитель лога

    // Обработчики стандартных действий и событий UI элементов формы
    procedure btnClearSearchClick(Sender: TObject);
    procedure btnAddComponentClick(Sender: TObject);
    procedure btnDeleteComponentClick(Sender: TObject);
    procedure btnFormPagesClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnRecordClick(Sender: TObject);
    procedure btnRunWinposClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnSaveConfigAsClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnTriggerClick(Sender: TObject);
    procedure edTagSearchChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbTagsClick(Sender: TObject);
    procedure lbTagsDblClick(Sender: TObject);
    procedure pnRightCommandsClick(Sender: TObject);
    procedure sgFormularPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure sgFormularSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    // Фабрики и менеджеры управления графическими элементами мнемосхем
    fComponentFactory: TRecorderComponentFactory; // Фабрика регистрации и создания визуальных компонентов
    fFormFactory: TRecorderFormFactory;           // Фабрика создания шаблонов страниц
    fFormManager: TRecorderFormManager;           // Менеджер набора страниц/формуляров проекта
    fNextComponentNo: Integer;                    // Автоинкрементный счетчик для уникальных имен компонентов
    fNextPageNo: Integer;                         // Автоинкрементный счетчик для уникальных имен страниц
    
    // Элементы редактора мнемосхем на форме
    fEditorCanvas: TPanel;                        // Полотно/холст отрисовки компонентов мнемосхемы
    fEditorShell: TPanel;                         // Контейнер редактора (полотно + тулбар)
    fEditorToolbar: TPanel;                       // Панель инструментов редактора
    fFormEditor: TFormEditorController;           // Контроллер логики перетаскивания и редактирования
    fEditModeButton: TSpeedButton;                // Кнопка включения режима конструктора
    fAddOscillogramButton: TSpeedButton;          // Кнопка добавления осциллограммы
    fAddTrendButton: TSpeedButton;                // Кнопка добавления тренда
    fAddTextButton: TSpeedButton;                 // Кнопка добавления текстового поля
    fAddSpectrumButton: TSpeedButton;             // Кнопка добавления графика спектра
    fAddDigitalButton: TSpeedButton;              // Кнопка добавления цифрового индикатора
    fAddTagTableButton: TSpeedButton;             // Кнопка добавления таблицы тегов
    fAddButtonButton: TSpeedButton;               // Кнопка добавления управляющей кнопки
    fAddComboBoxButton: TSpeedButton;             // Кнопка добавления выпадающего списка
    fDeleteComponentButton: TSpeedButton;         // Кнопка удаления выбранного компонента мнемосхемы
    
    // Элементы базового формуляра графиков (Base Page)
    fBaseToolbar: TPanel;                         // Тулбар управления графиками
    fBaseChartsPanel: TPanel;                     // Область размещения графиков TChart
    fOscillogramCountEdit: TSpinEdit;             // Поле количества одновременно отображаемых графиков
    fBaseFpsLabel: TLabel;                        // Отдельный индикатор FPS базовой страницы
    fLogFilterPanel: TPanel;                      // Панель фильтров нижнего журнала
    fLogShowSystemCheck: TCheckBox;               // Показывать системные события
    fLogShowDataCheck: TCheckBox;                 // Показывать диагностические/data события
    fLogShowAlarmsCheck: TCheckBox;               // Показывать события тревог
    fPageControl: TPageControl;                   // Визуальный контейнер вкладок формуляров
    fSelectedComponentRow: Integer;               // Номер выбранной строки в таблице формуляра
    fSyncingPages: Boolean;                       // Флаг предотвращения рекурсивного вызова при обновлении вкладок
    
    // Ядро системы рекордера
    fRecorder: TRecorder;                         // Корневой объект ядра (теги, источники, runtime)
    fLatestTagValues: TStringList;                // Буфер последних текстовых значений тегов для отображения
    fLogLines: TStringList;                       // Полная история нижнего журнала с категориями
    fUiUpdateTimer: TTimer;                       // Таймер периодического обновления UI из очереди событий
    fDataSourcesConfigured: Boolean;              // Флаг готовности источников данных
    fProjectConfigDir: string;                    // Каталог конфигурационных файлов проекта
    fRunControlFileName: string;                  // Путь к файлу настроек сбора/записи
    fConfigPopupMenu: TPopupMenu;                 // Меню операций сохранения/загрузки конфигурации
    fRecordFrameManager: TRecorderRecordFrameManager; // Менеджер каталогов кадров записи
    fMeraWriter: TRecorderMeraTagWriter;          // Writer MERA files of current record
    fDiagLastLogTickMs: QWord;                    // Время последнего диагностического лога
    fDiagUiTicks: Integer;                        // Количество тиков UI за период диагностики
    fDiagDataEvents: Integer;                     // Количество событий данных за период диагностики
    fDiagRenderCount: Integer;                    // Количество отрисовок активной страницы
    fAutoPreviewSeconds: Integer;                 // CLI: --preview-seconds=N headless preview run
    fAutoPreviewExtraTicks: Integer;              // extra 500 ms ticks for MIC-140 warmup
    fAutoPreviewTicks: Integer;
    fAutoPreviewTimer: TTimer;

    { Создает и настраивает кнопку тулбара редактора мнемосхем. }
    function AddEditMnemoToolBarButton(ALeft, AImageIndex: Integer;
      const AHint: string; AOnClick: TNotifyEvent; AGroupIndex: Integer = 0;
      AAllowAllUp: Boolean = False; AEnabled: Boolean = True;
      const ACaption: string = ''; AImageWidth: Integer = 25): TSpeedButton;
    { Добавляет строку в журнал с локальным временем. }
    procedure AddLog(const AMessage: string; AKind: TRecorderLogKind = rlkSystem);
    { Возвращает текущий корневой каталог MERA-записи. }
    function CurrentRecordRootDir: string;
    { Обновляет менеджер каталогов записи из текущих настроек. }
    procedure UpdateRecordFrameManager;
    { Возвращает каталог текущего или следующего MERA-замера. }
    function CurrentMeasureDir: string;
    { Обновляет заголовок главного окна. }
    procedure UpdateMainCaption;
    { Возвращает путь к последнему записанному record.mera. }
    function LastRecordedMeraFileName: string;
    { Создает галочки фильтрации нижнего журнала. }
    procedure EnsureLogFilterPanel;
    { Обработчик изменения фильтров нижнего журнала. }
    procedure LogFilterChanged(Sender: TObject);
    { Перестраивает видимый журнал по текущим галочкам. }
    procedure RefreshLogView;
    { Возвращает True, если категория журнала сейчас видима. }
    function LogKindVisible(AKind: TRecorderLogKind): Boolean;
    { Создает начальную модель формуляров, которой управляет главный экран. }
    procedure InitializeFormPages;
    { Добавляет страницу в модель и делает ее активной, если нужно. }
    function AddPageToModel(const AName, ATitle: string): TRecorderFormPage;
    { Обновляет верхние вкладки формуляров по текущему менеджеру. }
    procedure RefreshPageButtons;
    { Создает верхний PageControl формуляров. }
    procedure EnsurePageControl;
    { Реагирует на выбор вкладки формуляра пользователем. }
    procedure PageControlChange(Sender: TObject);
    { Отображает активную страницу: встроенную таблицу или пользовательскую мнемосхему. }
    procedure RenderActivePage;
    { Создает раннюю область редактора мнемосхемы с тулбаром и пустым полотном. }
    procedure EnsureEditorSurface;
    { Создает тулбар базовой страницы с количеством осциллограмм. }
    procedure EnsureBaseToolbar;
    { Переключает центральную область между таблицей и редактором. }
    procedure ShowEditorSurface(AVisible: Boolean);
    { Показывает или прячет тулбар встроенной базовой страницы. }
    procedure ShowBaseToolbar(AVisible: Boolean);
    { Возвращает True для встроенных страниц, которые не редактируются как мнемосхемы. }
    function IsBuiltInPage(APage: TRecorderFormPage): Boolean;
    { Возвращает True для пользовательских мнемосхем. }
    function IsUserMnemonicPage(APage: TRecorderFormPage): Boolean;
    { Рисует встроенный цифровой формуляр. }
    procedure RenderDigitalPage;
    { Рисует встроенную базовую страницу с осциллограммами. }
    procedure RenderBasePage;
    { Перестраивает набор осциллограмм на базовой странице. }
    procedure RebuildBaseOscillograms(ACount: Integer);
    { Обновляет графики осциллограмм свежими данными }
    procedure RefreshBaseOscillograms;
    { Рисует пользовательскую мнемосхему и включает допустимые команды редактора. }
    procedure RenderMnemonicPage(APage: TRecorderFormPage);
    { Рисует прочую встроенную страницу без тулбара компонентов. }
    procedure RenderBuiltInPage(APage: TRecorderFormPage);
    { Обновляет доступность редактора и его кнопок для текущей страницы. }
    procedure UpdateEditorAvailability(APage: TRecorderFormPage);
    { Обновляет таблицу осциллограмм при изменении спинбатона. }
    procedure OscillogramCountChange(Sender: TObject);
    { Пересчитывает габариты осциллограмм при изменении размера базовой страницы. }
    procedure BaseChartsPanelResize(Sender: TObject);
    { Добавляет на активную страницу тестовую текстовую метку. }
    procedure AddStaticTextComponentToActivePage;
    { Добавляет на активную страницу тестовый цифровой индикатор TagValue. }
    procedure AddTagValueComponentToActivePage;
    { Добавляет на активную страницу осциллограмму OpenGL. }
    procedure AddOscillogramComponentToActivePage;
    { Добавляет на активную страницу компонент тренда. }
    procedure AddTrendComponentToActivePage;
    { Добавляет на активную страницу спектр. }
    procedure AddSpectrumComponentToActivePage;
    { Обработчик кнопки добавления осциллограммы на полотне. }
    procedure AddOscillogramClick(Sender: TObject);
    { Обработчик кнопки добавления тренда на полотне. }
    procedure AddTrendClick(Sender: TObject);
    { Обработчик кнопки добавления спектра на полотне. }
    procedure AddSpectrumClick(Sender: TObject);
    { Обработчик кнопки добавления цифрового индикатора на полотне. }
    procedure AddDigitalIndicatorClick(Sender: TObject);
    { Переключает режим редактирования мнемосхемы. }
    procedure EditModeClick(Sender: TObject);
    { Создает dev-структуру config/projects/default и дефолтный run-control.ini. }
    procedure EnsureDevConfig;
    { Возвращает базовый каталог проекта для dev-конфигурации. }
    function GetDevProjectDir: string;
    { Возвращает активную страницу для контроллера редактора мнемосхем. }
    function GetActiveEditorPage: TRecorderFormPage;
    { Вызывается контроллером после изменения layout активной мнемосхемы. }
    procedure FormEditorChanged;
    { Загружает настройки запуска/остановки из проектного каталога. }
    procedure LoadRunSettings;
    { Сохраняет настройки запуска/остановки в проектный каталог. }
    procedure SaveRunSettings;
    { Применяет периоды обновления отображения из настроек запуска. }
    procedure ApplyDisplayTimingSettings;
    // Загрузка/сохранение конфигураций проекта
    procedure LoadProjectPackage;
    procedure SaveProjectPackage;
    { Переназначает текущий каталог пакета конфигурации проекта. }
    procedure SetProjectConfigDir(const ADirectoryName: string);
    { Создает popup-меню кнопки конфигурации с Save/Load/Save As. }
    procedure EnsureConfigPopupMenu;
    { Показывает popup-меню операций конфигурации. }
    procedure ShowConfigPopupMenu;
    { Команды popup-меню конфигурации. }
    procedure SaveCurrentConfigClick(Sender: TObject);
    procedure SaveConfigAsClick(Sender: TObject);
    procedure LoadConfigFromClick(Sender: TObject);
    { Открывает/закрывает MERA-запись текущего сеанса Record. }
    procedure OpenRecordFrame;
    procedure CloseRecordFrame;
    { Пересчитывает автоинкрементные счетчики на основе загруженной структуры gui }
    procedure ResetProjectCounters;
    { Применяет фильтр поиска к списку тегов. }
    function TagListItemName(const AItemText: string): string;
    function FindRegistryTagForListObject(AObj: TObject): TRecorderTag;
    function CurrentTagListSelectionName: string;
    // отобразить список тегов
    procedure RebuildTagList(const AFilter: string);
    { Собирает выбранные в списке TListBox теги }
    procedure CollectSelectedTags(ATags: TList);
    { Синхронизирует выбранный в UI тег с ядром Recorder. }
    procedure UpdateSelectedTagFromList;
    { Открывает диалог настройки выбранных тегов }
    procedure OpenSelectedTagSettings;
    { Создает отладочный источник MemTag и подключает его к общему registry. }
    procedure EnsureRuntimeDataSources;
    { Расширяет кольцевые буферы тегов под отображаемое окно истории. }
    procedure EnsureTagSignalBufferCapacities;
    { Запускает worker-thread источников данных для режимов View/Record. }
    procedure StartDataSources;
    { Останавливает worker-thread источников данных и дочитывает очередь. }
    procedure StopDataSources;
    { Вычитывает очередь снимков событий в UI thread и обновляет отображение. }
    procedure DrainUiEventQueue(Sender: TObject);
    { Пишет агрегированную диагностику частот UI/data/render. }
    procedure LogUpdateDiagnostics;
    { Применяет один снимок события обновления тега к UI-модели значений. }
    procedure ApplyTagEventSnapshot(ASnapshot: TRecorderEventSnapshot);
    { Настраивает командные кнопки правого пульта как кнопки-символы. }
    procedure SetupCommandButtons;
    procedure SetupStatusBanner;
    { Обновляет текстовый индикатор состояния из fRecorder.StateMachine.State. }
    procedure UpdateStateView;
    { Обновляет текстовый индикатор времени из подсистемы. }
    procedure UpdateTimeView;
    { Единая обработка ошибок команд UI. }
    procedure LogCommandError(const ACommand: string; E: Exception);
    { CLI automation: start preview, stop and quit after N seconds. }
    procedure AutoPreviewTimer(Sender: TObject);
    procedure ParseAutoPreviewCommandLine;
    procedure ScheduleCommandLineDeviceTests;
    function DeviceTestDataSourcesRunning: Boolean;
    procedure DeviceTestStartPreview;
    procedure DeviceTestLog(const AMessage: string);
    procedure DeviceTestFinished(Sender: TObject);
    { Обработчик события ядра: фиксирует переход состояния в журнале и на форме. }
    procedure StateMachineStateChanged(ASender: TObject;
      AOldState, ANewState: TRecorderState);
    procedure StateMachineStateChanging(ASender: TObject;
      AOldState, ANewState: TRecorderState;
      ATransition: TRecorderStateTransition);
    procedure PrepareRuntimeForConfiguration;
    procedure OnMenuEditSelectedTags(Sender: TObject);
    procedure TagHardwareSourceSetup(Sender: TObject; ATag: TRecorderTag);
    procedure TagZeroBalance(Sender: TObject; ARegistry: TRecorderTagRegistry;
      ATags: TList);
    procedure UpdateActiveSourceIds;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

const
  CDefaultProjectConfigDir = 'config' + DirectorySeparator + 'projects' +
    DirectorySeparator + 'default';
  CProjectBaseName = 'default';
  COldRunControlFileName = 'run-control.ini';
  CDeviceHealthProbeTimeoutMs = 1000;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  lPopupMenu: TPopupMenu;
  lMenuItem: TMenuItem;
begin
  RegisterThreadName(GetThreadID, 'UIThread');
  Caption := 'RecorderLnx';
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  fSelectedComponentRow := -1;
  fRecorder := TRecorder.Create;
  fRecorder.StateMachine.OnStateChanging := @StateMachineStateChanging;
  fRecorder.StateMachine.OnStateChanged := @StateMachineStateChanged;

  fLatestTagValues := TStringList.Create;
  fLogLines := TStringList.Create;
  fLatestTagValues.CaseSensitive := False;
  fLatestTagValues.Sorted := False;
  fLatestTagValues.Duplicates := dupAccept;
  fDiagLastLogTickMs := GetTickCount64;
  fUiUpdateTimer := TTimer.Create(Self);
  fUiUpdateTimer.Enabled := False;
  fUiUpdateTimer.Interval := fRecorder.TimeSystem.DisplayUpdateMs;
  fUiUpdateTimer.OnTimer := @DrainUiEventQueue;

  fComponentFactory := TRecorderComponentFactory.Create;
  fComponentFactory.RegisterDefaultComponents;
  fFormFactory := TRecorderFormFactory.Create(fComponentFactory);
  sgFormular.OnPrepareCanvas := @sgFormularPrepareCanvas;
  fFormManager := TRecorderFormManager.Create;
  SetProjectConfigDir(IncludeTrailingPathDelimiter(GetDevProjectDir) +
    CDefaultProjectConfigDir);

  LoadRecorderCommandImages(ilCommandButtons);
  SetupStatusBanner;
  SetupCommandButtons;
  EnsureLogFilterPanel;
  EnsurePageControl;
  EnsureEditorSurface;
  EnsureBaseToolbar;
  fFormEditor := TFormEditorController.Create(fEditorCanvas, @GetActiveEditorPage,
    fComponentFactory);
  fFormEditor.OnChanged := @FormEditorChanged;
  fFormEditor.SetDataContext(fRecorder.TagRegistry, fRecorder.AlarmEngine, fRecorder.RunSettings.DisplayBufferMs / 1000);
  lbTags.OnClick := @lbTagsClick;
  UpdateActiveSourceIds;
  
  // Создание контекстного меню для настройки каналов
  lPopupMenu := TPopupMenu.Create(Self);
  lMenuItem := TMenuItem.Create(lPopupMenu);
  lMenuItem.Caption := 'Настроить выделенные каналы...';
  lMenuItem.OnClick := @OnMenuEditSelectedTags;
  lPopupMenu.Items.Add(lMenuItem);
  lbTags.PopupMenu := lPopupMenu;

  EnsureDevConfig;
  InitializeFormPages;
  LoadRunSettings;
  ApplyDisplayTimingSettings;
  LoadProjectPackage;
  { Источники создаются сразу при загрузке проекта; подготовка оборудования не
    должна откладываться до первого нажатия Preview. }
  EnsureRuntimeDataSources;
  PrepareRuntimeForConfiguration;
  { rstInit — только начальная отметка автомата состояний. Явная нотификация
    отправляется после загрузки проекта, создания форм и источников, а также
    конфигурирования доступного оборудования. }
  if fRecorder.EventBus <> nil then
    fRecorder.EventBus.Publish(TRecorderEventBus.MakeEvent(rceInitialized,
      Self, 'Initialized'));
  UpdateActiveSourceIds;
  RebuildTagList('');
  UpdateStateView;
  RenderActivePage;
  AddLog('RecorderLnx started.');
  ParseAutoPreviewCommandLine;
  ScheduleCommandLineDeviceTests;

end;

procedure TMainForm.ParseAutoPreviewCommandLine;
var
  I: Integer;
  lArg: string;
  lValue: string;
  lSeconds: Integer;
begin
  fAutoPreviewSeconds := 0;
  for I := 1 to ParamCount do
  begin
    lArg := ParamStr(I);
    if SameText(lArg, '--preview-seconds') then
    begin
      if I < ParamCount then
        TryStrToInt(ParamStr(I + 1), fAutoPreviewSeconds);
      Break;
    end;
    if Pos('--preview-seconds=', LowerCase(lArg)) = 1 then
    begin
      lValue := Copy(lArg, Length('--preview-seconds=') + 1, MaxInt);
      if TryStrToInt(lValue, lSeconds) then
        fAutoPreviewSeconds := lSeconds;
      Break;
    end;
  end;
  if fAutoPreviewSeconds <= 0 then
    Exit;

  fAutoPreviewTicks := 0;
  // The CLI acceptance run measures published acquisition blocks, while MIC-140
  // starts producing data a little after the UI enters preview state.
  fAutoPreviewExtraTicks := 2;
  fAutoPreviewTimer := TTimer.Create(Self);
  fAutoPreviewTimer.Interval := 500;
  fAutoPreviewTimer.OnTimer := @AutoPreviewTimer;
  fAutoPreviewTimer.Enabled := True;
  AddLog(Format('Auto preview: %d s then stop/quit (MIC-140 debug).',
    [fAutoPreviewSeconds]));
end;

procedure TMainForm.AutoPreviewTimer(Sender: TObject);
begin
  if fAutoPreviewTimer = nil then
    Exit;
  if fRecorder.StateMachine.State = rsStop then
  begin
    btnPreviewClick(nil);
    Exit;
  end;
  if fRecorder.StateMachine.State <> rsPreview then
    Exit;
  Inc(fAutoPreviewTicks);
  if fAutoPreviewTicks < fAutoPreviewSeconds * 2 + fAutoPreviewExtraTicks then
    Exit;
  fAutoPreviewTimer.Enabled := False;
  AddLog(Format('Auto preview finished after %d s, stopping.', [fAutoPreviewSeconds]));
  btnStopClick(nil);
  Application.Terminate;
end;

procedure TMainForm.ScheduleCommandLineDeviceTests;
begin
  RecorderScheduleCommandLineDeviceTests(Self, fRecorder, ilCommandButtons,
    ilTagDialogButtons, @DeviceTestStartPreview, @DeviceTestDataSourcesRunning,
    @DeviceTestLog, @DeviceTestFinished);
end;

function TMainForm.DeviceTestDataSourcesRunning: Boolean;
begin
  Result := (fRecorder <> nil) and fRecorder.DataSources.Running;
end;

procedure TMainForm.DeviceTestStartPreview;
begin
  btnPreviewClick(nil);
end;

procedure TMainForm.DeviceTestLog(const AMessage: string);
begin
  AddLog(AMessage);
end;

procedure TMainForm.DeviceTestFinished(Sender: TObject);
begin
  RecorderReleaseDeviceTest(Sender);
  Application.Terminate;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if fUiUpdateTimer <> nil then
    fUiUpdateTimer.Enabled := False;
  StopDataSources;
  FreeAndNil(fFormEditor);
  FreeAndNil(fFormManager);
  FreeAndNil(fFormFactory);
  FreeAndNil(fComponentFactory);
  CloseRecordFrame;
  FreeAndNil(fMeraWriter);
  FreeAndNil(fRecordFrameManager);
  FreeAndNil(fLatestTagValues);
  FreeAndNil(fLogLines);
  FreeAndNil(fRecorder);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fFormEditor <> nil then
    fFormEditor.HandleKeyDown(Key, Shift);
end;

procedure TMainForm.sgFormularSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if aRow > 0 then
    fSelectedComponentRow := aRow
  else
    fSelectedComponentRow := -1;
end;

procedure TMainForm.sgFormularPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var
  lTagName: string;
  lUnit: string;
  lTag: TRecorderTag;
  lColor: LongInt;
  lRowIdx: Integer;
begin
  if (aRow > 0) and (gdSelected in aState) then Exit;
  if aRow <= 0 then
    Exit;

  { Единица «код» — серый фон ячейки Unit. }
  lUnit := Trim(sgFormular.Cells[3, aRow]);
  if (aCol = 3) and
    (SameText(lUnit, 'код') or SameText(lUnit, 'code')) then
  begin
    sgFormular.Canvas.Brush.Color := clSilver;
    sgFormular.Canvas.Font.Color := clBlack;
    Exit;
  end;

  if (fRecorder.TagRegistry <> nil) and (fRecorder.AlarmEngine <> nil) then
  begin
    lRowIdx := aRow;
    while (lRowIdx > 0) and (sgFormular.Cells[0, lRowIdx] = '') do
      Dec(lRowIdx);
    if lRowIdx > 0 then
    begin
      lTagName := sgFormular.Cells[0, lRowIdx];
      lTag := fRecorder.TagRegistry.FindByName(lTagName);
      if lTag <> nil then
      begin
        lColor := fRecorder.AlarmEngine.GetTagAlarmColor(lTag);
        if lColor <> 0 then
        begin
          sgFormular.Canvas.Brush.Color := TColor(lColor);
          sgFormular.Canvas.Font.Color := clBlack;
        end;
      end;
    end;
  end;
end;

procedure TMainForm.lbTagsClick(Sender: TObject);
begin
  UpdateSelectedTagFromList;
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = 'BasePage') then
    RefreshBaseOscillograms
  else if (fFormEditor <> nil) and fFormEditor.Enabled then
    fFormEditor.Render;
end;

procedure TMainForm.lbTagsDblClick(Sender: TObject);
begin
  UpdateSelectedTagFromList;
  OpenSelectedTagSettings;
end;

procedure TMainForm.pnRightCommandsClick(Sender: TObject);
begin

end;

procedure TMainForm.UpdateActiveSourceIds;
var
  I: Integer;
  lSourceId: string;
  lSources: TStringList;
  lTag: TRecorderTag;
begin
  if fRecorder.TagRegistry = nil then
    Exit;

  fRecorder.TagRegistry.RefreshActiveSourcesFromTags;

  lSources := TStringList.Create;
  try
    lSources.CaseSensitive := False;
    lSources.Sorted := False;
    for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
    begin
      lTag := fRecorder.TagRegistry.Tags[I];
      if (lTag = nil) or RecorderIsDetachedTagSource(lTag.SourceId) then
        Continue;
      lSourceId := RecorderNormalizeTagSourceId(lTag.SourceId);
      if lSourceId = '' then
        Continue;
      if not (RecorderIsHardwareTagSource(lSourceId) or
        RecorderIsVirtualTagSource(lSourceId)) then
        Continue;
      if lSources.IndexOf(lSourceId) < 0 then
        lSources.Add(lSourceId);
    end;

    for I := 0 to lSources.Count - 1 do
    begin
      lSourceId := lSources[I];
      if RecorderHardwareSourceLinkOk(lSourceId) then
        fRecorder.TagRegistry.RegisterActiveSource(lSourceId)
      else
        fRecorder.TagRegistry.UnregisterActiveSource(lSourceId);
    end;
  finally
    lSources.Free;
  end;
end;

procedure TMainForm.OnMenuEditSelectedTags(Sender: TObject);
begin
  OpenSelectedTagSettings;
end;

procedure TMainForm.PageControlChange(Sender: TObject);
var
  lPageIndex: Integer;
  lStarted: QWord;
begin
  if fSyncingPages or (fPageControl = nil) then
    Exit;

  lPageIndex := fPageControl.ActivePageIndex;
  if (lPageIndex < 0) or (lPageIndex >= fFormManager.PageCount) then
    Exit;

  lStarted := GetTickCount64;
  fFormManager.SetActivePageById(fFormManager.Pages[lPageIndex].Id);
  if fFormEditor <> nil then
  begin
    fFormEditor.ClearSelection;
    fFormEditor.ClearUndoHistory;
  end;
  RenderActivePage;
  RecorderDebugLog(Format('[MNEMO-PERF] tab-change page=%s total=%dms',
    [fFormManager.Pages[lPageIndex].Id, GetTickCount64 - lStarted]));
end;

procedure TMainForm.btnFormPagesClick(Sender: TObject);
var
  lDialog: TFormPagesDialog;
begin
  try
    lDialog := TFormPagesDialog.CreateDialog(Self, fFormManager, fFormFactory,
      fNextPageNo);
    try
      if lDialog.ShowModal in [mrOk, mrCancel] then
      begin
        fNextPageNo := lDialog.NextPageNo;
        if fFormEditor <> nil then
        begin
          fFormEditor.ClearSelection;
          fFormEditor.ClearUndoHistory;
        end;
        RefreshPageButtons;
        RenderActivePage;
        AddLog('Form pages dialog closed.');
      end;
    finally
      lDialog.Free;
    end;
  except
    on E: Exception do
      LogCommandError('Form pages', E);
  end;
end;

procedure TMainForm.btnAddComponentClick(Sender: TObject);
begin
  try
    AddStaticTextComponentToActivePage;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Add text label', E);
  end;
end;

procedure TMainForm.btnDeleteComponentClick(Sender: TObject);
begin
  try
    if fFormEditor <> nil then
      fFormEditor.DeleteSelected;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Delete component', E);
  end;
end;

procedure TMainForm.btnPreviewClick(Sender: TObject);
begin
  try
    if fRecorder.StateMachine.State = rsPreview then
      Exit;
    fRecorder.StateMachine.StartPreview(rscManual);
  except
    on E: Exception do
      LogCommandError('Preview', E);
  end;
end;

procedure TMainForm.btnRecordClick(Sender: TObject);
begin
  try
    fRecorder.RunSettings.RequireValid;
    fRecorder.StateMachine.StartRecord(fRecorder.RunSettings.StartCondition);
  except
    on E: Exception do
      LogCommandError('Record', E);
  end;
end;

procedure TMainForm.btnTriggerClick(Sender: TObject);
begin
  try
    fRecorder.StateMachine.StartConditionMet;
  except
    on E: Exception do
      LogCommandError('Trigger', E);
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  try
    fRecorder.StateMachine.Stop;
  except
    on E: Exception do
      LogCommandError('Stop', E);
  end;
end;

procedure TMainForm.btnSaveConfigAsClick(Sender: TObject);
begin
  try
    SaveConfigAsClick(Sender);
  except
    on E: Exception do
      LogCommandError('Save config as', E);
  end;
end;


procedure TMainForm.btnRunWinposClick(Sender: TObject);
var
  lMeraFileName: string;
begin
  lMeraFileName := LastRecordedMeraFileName;
  if lMeraFileName = '' then
    Exit;

  OpenDocument(lMeraFileName);
end;
procedure TMainForm.btnSaveConfigClick(Sender: TObject);
begin
  try
    SaveProjectPackage;
  except
    on E: Exception do
      LogCommandError('Save config', E);
  end;
end;

procedure TMainForm.btnSettingsClick(Sender: TObject);
begin
  try
    if fRecorder.StateMachine.State = rsRecord then
    begin
      fRecorder.StateMachine.Stop;
      AddLog('Configuration mode requested: recording stopped before settings.');
    end;

    AddLog('Configuration mode: settings dialog opened.');
    if ShowRecorderSettingsDialog(Self, fRecorder, ilCommandButtons, ilTagDialogButtons) then
    begin
      ApplyDisplayTimingSettings;
      UpdateRecordFrameManager;
      UpdateActiveSourceIds;
      fRecorder.DataSources.Clear;
      fDataSourcesConfigured := False;
      EnsureRuntimeDataSources;
      PrepareRuntimeForConfiguration;
      AddLog('Project settings applied.');
    end
    else
      AddLog('Configuration mode: settings dialog closed without applying OK.');

    { Внутренняя и общая кнопки «Применить» изменяют реестр ещё до закрытия
      диалога. Поэтому список тегов надо перечитать и после «Закрыть», а не
      только после OK. При чистой отмене это безопасное обновление представления. }
    RebuildTagList(edTagSearch.Text);
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Settings', E);
  end;
end;

procedure TMainForm.btnClearSearchClick(Sender: TObject);
begin
  edTagSearch.Text := '';
end;

procedure TMainForm.edTagSearchChange(Sender: TObject);
begin
  RebuildTagList(edTagSearch.Text);
end;


function TMainForm.CurrentRecordRootDir: string;
begin
  Result := '';
  if fRecorder.RunSettings <> nil then
    Result := Trim(fRecorder.RunSettings.RecordRootDir);
  if Result = '' then
    Result := IncludeTrailingPathDelimiter(fProjectConfigDir) + 'records';
  Result := IncludeTrailingPathDelimiter(ExpandFileName(Result));
end;

procedure TMainForm.UpdateRecordFrameManager;
var
  lRootDir: string;
begin
  lRootDir := CurrentRecordRootDir;
  if (fRecordFrameManager <> nil) and SameText(fRecordFrameManager.RootDir, lRootDir) then
  begin
    UpdateMainCaption;
    Exit;
  end;

  FreeAndNil(fRecordFrameManager);
  fRecordFrameManager := TRecorderRecordFrameManager.Create(lRootDir);
  UpdateMainCaption;
end;

function TMainForm.CurrentMeasureDir: string;
var
  lFrameNo: Integer;
begin
  Result := '';
  if fRecordFrameManager = nil then
    Exit;

  if fRecordFrameManager.Recording and
    (fRecordFrameManager.CurrentFrameDir <> '') then
  begin
    Result := IncludeTrailingPathDelimiter(fRecordFrameManager.CurrentFrameDir);
    Exit;
  end;

  lFrameNo := fRecordFrameManager.FindLastFrameNo + 1;
  Result := IncludeTrailingPathDelimiter(fRecordFrameManager.RootDir) +
    TRecorderRecordFrameManager.FormatFrameName(lFrameNo);
  Result := IncludeTrailingPathDelimiter(Result);
end;
procedure TMainForm.UpdateMainCaption;
var
  lCaption: string;
begin
  lCaption := 'RecorderLnx - ' + fProjectConfigDir + ' - MERA: ' + CurrentMeasureDir;
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) then
    lCaption := lCaption + ' - ' + fFormManager.ActivePage.Title;
  Caption := lCaption;
end;

function TMainForm.LastRecordedMeraFileName: string;
var
  lFrameNo: Integer;
  lFrameDir: string;
begin
  Result := '';
  if fRecordFrameManager = nil then
    Exit;

  lFrameNo := fRecordFrameManager.FindLastFrameNo;
  if lFrameNo <= 0 then
    Exit;

  lFrameDir := IncludeTrailingPathDelimiter(fRecordFrameManager.RootDir) +
    TRecorderRecordFrameManager.FormatFrameName(lFrameNo);
  Result := IncludeTrailingPathDelimiter(lFrameDir) +
    ExtractFileName(ExcludeTrailingPathDelimiter(lFrameDir)) + '.mera';
  if not FileExists(Result) then
    Result := '';
end;
procedure TMainForm.AddLog(const AMessage: string; AKind: TRecorderLogKind);
var
  lLine: string;
begin
  lLine := FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AMessage;
  if fLogLines <> nil then
    fLogLines.AddObject(lLine, TObject(PtrInt(Ord(AKind))));
  if (mmLog <> nil) and LogKindVisible(AKind) then
    mmLog.Lines.Add(lLine);
  RecorderDebugLog(lLine);
end;

procedure TMainForm.EnsureLogFilterPanel;
begin
  if fLogFilterPanel <> nil then
    Exit;

  fLogFilterPanel := TPanel.Create(Self);
  fLogFilterPanel.Parent := pnMain;
  fLogFilterPanel.Align := alBottom;
  fLogFilterPanel.Height := 26;
  fLogFilterPanel.BevelOuter := bvNone;

  fLogShowSystemCheck := TCheckBox.Create(Self);
  fLogShowSystemCheck.Parent := fLogFilterPanel;
  fLogShowSystemCheck.SetBounds(8, 3, 86, 20);
  fLogShowSystemCheck.Caption := #$D0#$A1#$D0#$B8#$D1#$81#$D1#$82#$D0#$B5#$D0#$BC#$D0#$B0;
  fLogShowSystemCheck.Checked := True;
  fLogShowSystemCheck.OnChange := @LogFilterChanged;

  fLogShowDataCheck := TCheckBox.Create(Self);
  fLogShowDataCheck.Parent := fLogFilterPanel;
  fLogShowDataCheck.SetBounds(102, 3, 74, 20);
  fLogShowDataCheck.Caption := #$D0#$94#$D0#$B0#$D0#$BD#$D0#$BD#$D1#$8B#$D0#$B5;
  fLogShowDataCheck.Checked := True;
  fLogShowDataCheck.OnChange := @LogFilterChanged;

  fLogShowAlarmsCheck := TCheckBox.Create(Self);
  fLogShowAlarmsCheck.Parent := fLogFilterPanel;
  fLogShowAlarmsCheck.SetBounds(184, 3, 82, 20);
  fLogShowAlarmsCheck.Caption := #$D0#$A2#$D1#$80#$D0#$B5#$D0#$B2#$D0#$BE#$D0#$B3#$D0#$B8;
  fLogShowAlarmsCheck.Checked := True;
  fLogShowAlarmsCheck.OnChange := @LogFilterChanged;
end;

procedure TMainForm.LogFilterChanged(Sender: TObject);
begin
  RefreshLogView;
end;

procedure TMainForm.RefreshLogView;
var
  I: Integer;
  lKind: TRecorderLogKind;
begin
  if (mmLog = nil) or (fLogLines = nil) then
    Exit;

  mmLog.Lines.BeginUpdate;
  try
    mmLog.Lines.Clear;
    for I := 0 to fLogLines.Count - 1 do
    begin
      lKind := TRecorderLogKind(PtrInt(fLogLines.Objects[I]));
      if LogKindVisible(lKind) then
        mmLog.Lines.Add(fLogLines[I]);
    end;
  finally
    mmLog.Lines.EndUpdate;
  end;
end;

function TMainForm.LogKindVisible(AKind: TRecorderLogKind): Boolean;
begin
  case AKind of
    rlkSystem:
      Result := (fLogShowSystemCheck = nil) or fLogShowSystemCheck.Checked;
    rlkData:
      Result := (fLogShowDataCheck = nil) or fLogShowDataCheck.Checked;
    rlkAlarm:
      Result := (fLogShowAlarmsCheck = nil) or fLogShowAlarmsCheck.Checked;
  else
    Result := True;
  end;
end;

procedure TMainForm.InitializeFormPages;
var
  lPage: TRecorderFormPage;
begin
  fNextPageNo := 0;
  fNextComponentNo := 0;

  Inc(fNextPageNo);
  lPage := AddPageToModel('DigitalForm', 'Digital form');
  fFormManager.SetActivePageById(lPage.Id);

  Inc(fNextPageNo);
  AddPageToModel('BasePage', 'Base page');

  RefreshPageButtons;
  RenderActivePage;
end;

function TMainForm.AddPageToModel(const AName,
  ATitle: string): TRecorderFormPage;
begin
  Result := fFormFactory.CreateBlankPage(AName, AName, ATitle);
  try
    fFormManager.AddPage(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TMainForm.EnsurePageControl;
begin
  if fPageControl <> nil then
    Exit;

  fPageControl := TPageControl.Create(Self);
  fPageControl.Parent := pnToolbar;
  fPageControl.Left := btnAddPage.Left + btnAddPage.Width + 8;
  fPageControl.Top := 4;
  fPageControl.Width := pnToolbar.ClientWidth - fPageControl.Left - 8;
  fPageControl.Height := pnToolbar.ClientHeight - 8;
  fPageControl.Anchors := [akLeft, akTop, akRight];
  fPageControl.TabOrder := 0;
  fPageControl.OnChange := @PageControlChange;
end;

procedure TMainForm.RefreshPageButtons;
var
  I: Integer;
  lPage: TRecorderFormPage;
  lTab: TTabSheet;
  lActiveIndex: Integer;
begin
  EnsurePageControl;

  fSyncingPages := True;
  try
    while fPageControl.PageCount < fFormManager.PageCount do
    begin
      lTab := TTabSheet.Create(fPageControl);
      lTab.PageControl := fPageControl;
    end;

    while fPageControl.PageCount > fFormManager.PageCount do
      fPageControl.Pages[fPageControl.PageCount - 1].Free;

    lActiveIndex := -1;
    for I := 0 to fFormManager.PageCount - 1 do
    begin
      lPage := fFormManager.Pages[I];
      fPageControl.Pages[I].Caption := lPage.Title;
      fPageControl.Pages[I].Tag := I;

      if lPage = fFormManager.ActivePage then
        lActiveIndex := I;
    end;

    if lActiveIndex >= 0 then
      fPageControl.ActivePageIndex := lActiveIndex
    else if fPageControl.PageCount > 0 then
      fPageControl.ActivePageIndex := 0;
  finally
    fSyncingPages := False;
  end;
end;

procedure TMainForm.RenderActivePage;
var
  lPage: TRecorderFormPage;
begin
  lPage := fFormManager.ActivePage;

  if lPage = nil then
  begin
    ShowEditorSurface(False);
    ShowBaseToolbar(False);
    UpdateEditorAvailability(nil);
    UpdateMainCaption;
    Exit;
  end;

  UpdateMainCaption;
  UpdateEditorAvailability(lPage);

  if lPage.Id = 'DigitalForm' then
    RenderDigitalPage
  else if lPage.Id = 'BasePage' then
    RenderBasePage
  else if IsUserMnemonicPage(lPage) then
    RenderMnemonicPage(lPage)
  else
    RenderBuiltInPage(lPage);

  RefreshPageButtons;
end;

procedure TMainForm.AddStaticTextComponentToActivePage;
var
  lPage: TRecorderFormPage;
  lComponent: TRecorderStaticTextComponent;
begin
  lPage := fFormManager.ActivePage;
  if lPage = nil then
    raise ERecorderFormError.Create('Cannot add component without active page');
  if not IsUserMnemonicPage(lPage) then
    raise ERecorderFormError.Create('Components can be added only to user mnemonic pages');

  if fFormEditor <> nil then
    fFormEditor.RememberUndoStep;

  Inc(fNextComponentNo);
  lComponent := TRecorderStaticTextComponent(
    fComponentFactory.CreateComponent(TRecorderStaticTextComponent.TypeId));
  try
    lComponent.Id := Format('%s.component%d', [lPage.Id, fNextComponentNo]);
    lComponent.Name := Format('TextLabel%d', [fNextComponentNo]);
    lComponent.Text := 'Text label';
    lComponent.SetBounds(16, 16 + lPage.ComponentCount * 36, 180, 28);
    lPage.AddComponent(lComponent);
  except
    lComponent.Free;
    raise;
  end;

  AddLog('Form component added: ' + lComponent.Id);
end;

procedure TMainForm.AddOscillogramClick(Sender: TObject);
begin
  try
    AddOscillogramComponentToActivePage;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Add oscillogram', E);
  end;
end;

procedure TMainForm.AddOscillogramComponentToActivePage;
var
  lPage: TRecorderFormPage;
  lComponent: TRecorderOscillogramComponent;
begin
  lPage := fFormManager.ActivePage;
  if lPage = nil then
    raise ERecorderFormError.Create('Cannot add component without active page');
  if not IsUserMnemonicPage(lPage) then
    raise ERecorderFormError.Create('Components can be added only to user mnemonic pages');

  if fFormEditor <> nil then
    fFormEditor.RememberUndoStep;

  Inc(fNextComponentNo);
  lComponent := TRecorderOscillogramComponent(
    fComponentFactory.CreateComponent(TRecorderOscillogramComponent.TypeId));
  try
    lComponent.Id := Format('%s.component%d', [lPage.Id, fNextComponentNo]);
    lComponent.Name := Format('Oscillogram%d', [fNextComponentNo]);
    if (fRecorder.TagRegistry <> nil) and (fRecorder.TagRegistry.SelectedTag <> nil) then
      RecorderBindComponentTag(lComponent, fRecorder.TagRegistry.SelectedTag);
    lComponent.BindingMode := rtbmRelativeSelectedTag;
    lComponent.TagOffset := 0;
    lComponent.SetBounds(16, 16 + lPage.ComponentCount * 36, 360, 220);
    lPage.AddComponent(lComponent);
  except
    lComponent.Free;
    raise;
  end;

  AddLog('Form component added: ' + lComponent.Id);
end;

procedure TMainForm.AddTrendClick(Sender: TObject);
begin
  try
    AddTrendComponentToActivePage;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Add trend', E);
  end;
end;

procedure TMainForm.AddTrendComponentToActivePage;
var
  lAxis: TRecorderTrendAxis;
  lLine: TRecorderTrendLine;
  lPage: TRecorderFormPage;
  lComponent: TRecorderTrendComponent;
  lTag: TRecorderTag;
begin
  lPage := fFormManager.ActivePage;
  if lPage = nil then
    raise ERecorderFormError.Create('Cannot add component without active page');
  if not IsUserMnemonicPage(lPage) then
    raise ERecorderFormError.Create('Components can be added only to user mnemonic pages');

  if fFormEditor <> nil then
    fFormEditor.RememberUndoStep;

  Inc(fNextComponentNo);
  lComponent := TRecorderTrendComponent(
    fComponentFactory.CreateComponent(TRecorderTrendComponent.TypeId));
  try
    lComponent.Id := Format('%s.component%d', [lPage.Id, fNextComponentNo]);
    lComponent.Name := Format('Trend%d', [fNextComponentNo]);
    lComponent.SetBounds(16, 16 + lPage.ComponentCount * 36, 400, 300);

    lTag := nil;
    if fRecorder.TagRegistry <> nil then
    begin
      lTag := fRecorder.TagRegistry.SelectedTag;
      if (lTag = nil) and (fRecorder.TagRegistry.TagCount > 0) then
        lTag := fRecorder.TagRegistry.Tags[0];
    end;

    if lTag <> nil then
    begin
      RecorderBindComponentTag(lComponent, lTag);
      if lComponent.AxisCount > 0 then
      begin
        lAxis := lComponent.Axes[0];
        lAxis.Name := lTag.UnitName;
        if lAxis.Name = '' then
          lAxis.Name := 'Y';
        if lTag.RangeMax > lTag.RangeMin then
        begin
          lAxis.RangeMin := lTag.RangeMin;
          lAxis.RangeMax := lTag.RangeMax;
        end;
      end;
      lLine := lComponent.AddLine;
      RecorderBindTrendLineTag(lLine, lTag);
      lLine.EstimateKind := tekMean;
      lLine.AxisIndex := 0;
    end;

    lPage.AddComponent(lComponent);
  except
    lComponent.Free;
    raise;
  end;

  AddLog('Form component added: ' + lComponent.Id);
end;

procedure TMainForm.AddSpectrumClick(Sender: TObject);
begin
  try
    AddSpectrumComponentToActivePage;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Add spectrum', E);
  end;
end;

procedure TMainForm.AddSpectrumComponentToActivePage;
var
  lPage: TRecorderFormPage;
  lComponent: TRecorderSpectrumComponent;
  lTag: TRecorderTag;
begin
  lPage := fFormManager.ActivePage;
  if lPage = nil then
    raise ERecorderFormError.Create('Cannot add component without active page');
  if not IsUserMnemonicPage(lPage) then
    raise ERecorderFormError.Create('Components can be added only to user mnemonic pages');

  if fFormEditor <> nil then
    fFormEditor.RememberUndoStep;

  Inc(fNextComponentNo);
  lComponent := TRecorderSpectrumComponent(
    fComponentFactory.CreateComponent(TRecorderSpectrumComponent.TypeId));
  try
    lComponent.Id := Format('%s.component%d', [lPage.Id, fNextComponentNo]);
    lComponent.Name := Format('Spectrum%d', [fNextComponentNo]);
    lComponent.SetBounds(16, 16 + lPage.ComponentCount * 36, 400, 300);

    lTag := nil;
    if fRecorder.TagRegistry <> nil then
    begin
      lTag := fRecorder.TagRegistry.SelectedTag;
      if (lTag = nil) and (fRecorder.TagRegistry.TagCount > 0) then
        lTag := fRecorder.TagRegistry.Tags[0];
    end;

    if lTag <> nil then
      lComponent.SetTagRefAt(lComponent.TagNames.Count, lTag);

    lPage.AddComponent(lComponent);
  except
    lComponent.Free;
    raise;
  end;

  AddLog('Form component added: ' + lComponent.Id);
end;

procedure TMainForm.AddDigitalIndicatorClick(Sender: TObject);
begin
  try
    AddTagValueComponentToActivePage;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Add digital indicator', E);
  end;
end;

procedure TMainForm.AddTagValueComponentToActivePage;
var
  lPage: TRecorderFormPage;
  lComponent: TRecorderTagValueComponent;
begin
  lPage := fFormManager.ActivePage;
  if lPage = nil then
    raise ERecorderFormError.Create('Cannot add component without active page');
  if not IsUserMnemonicPage(lPage) then
    raise ERecorderFormError.Create('Components can be added only to user mnemonic pages');

  if fFormEditor <> nil then
    fFormEditor.RememberUndoStep;

  Inc(fNextComponentNo);
  lComponent := TRecorderTagValueComponent(
    fComponentFactory.CreateComponent(TRecorderTagValueComponent.TypeId));
  try
    lComponent.Id := Format('%s.component%d', [lPage.Id, fNextComponentNo]);
    lComponent.Name := Format('DigitalIndicator%d', [fNextComponentNo]);
    lComponent.TagName := 'MemTag';
    lComponent.DisplayFormat := '0.0';
    lComponent.SetBounds(16, 16 + lPage.ComponentCount * 36, 180, 32);
    lPage.AddComponent(lComponent);
  except
    lComponent.Free;
    raise;
  end;

  AddLog('Form component added: ' + lComponent.Id);
end;

procedure TMainForm.EditModeClick(Sender: TObject);
begin
  if fFormEditor <> nil then
    fFormEditor.Enabled := (fEditModeButton <> nil) and fEditModeButton.Down and
      IsUserMnemonicPage(fFormManager.ActivePage);
end;

function TMainForm.AddEditMnemoToolBarButton(ALeft, AImageIndex: Integer;
  const AHint: string; AOnClick: TNotifyEvent; AGroupIndex: Integer;
  AAllowAllUp: Boolean; AEnabled: Boolean; const ACaption: string;
  AImageWidth: Integer): TSpeedButton;
begin
  Result := TSpeedButton.Create(Self);
  Result.Parent := fEditorToolbar;
  Result.Left := ALeft;
  Result.Top := 4;
  if AImageIndex >= 0 then
  begin
    Result.Width := 30;
    Result.Height := 24;
    Result.Caption := '';
    Result.Images := ilCommandButtons;
    Result.ImageIndex := AImageIndex;
    Result.ImageWidth := AImageWidth;
  end
  else
  begin
    Result.Width := 24;
    Result.Height := 24;
    Result.Caption := ACaption;
  end;
  Result.Hint := AHint;
  Result.ShowHint := True;
  Result.GroupIndex := AGroupIndex;
  Result.AllowAllUp := AAllowAllUp;
  Result.Enabled := AEnabled;
  Result.OnClick := AOnClick;
end;

procedure TMainForm.EnsureEditorSurface;
begin
  if fEditorShell <> nil then
    Exit;

  fEditorShell := TPanel.Create(Self);
  fEditorShell.Parent := pnMain;
  fEditorShell.Align := alClient;
  fEditorShell.BevelOuter := bvNone;
  fEditorShell.Visible := False;

  fEditorToolbar := TPanel.Create(Self);
  fEditorToolbar.Parent := fEditorShell;
  fEditorToolbar.Align := alTop;
  fEditorToolbar.Height := 32;
  fEditorToolbar.BevelOuter := bvLowered;

  fEditModeButton := AddEditMnemoToolBarButton(4, CIconEditForm, 'Edit mnemonic', @EditModeClick, 1, True);
  fAddOscillogramButton := AddEditMnemoToolBarButton(38, CIconOscillogram, 'Add oscillogram', @AddOscillogramClick);
  fAddTrendButton := AddEditMnemoToolBarButton(72, CIconTrends, 'Add trend', @AddTrendClick);
  fAddTextButton := AddEditMnemoToolBarButton(106, CIconTextLabel, 'Add text label', @btnAddComponentClick);
  fAddSpectrumButton := AddEditMnemoToolBarButton(140, CIconSpectrum, 'Add spectrum', @AddSpectrumClick);
  fAddDigitalButton := AddEditMnemoToolBarButton(174, CIconDigitalIndicator, 'Add digital indicator', @AddDigitalIndicatorClick);
  fAddTagTableButton := AddEditMnemoToolBarButton(208, CIconTagTable, 'Add tag table', nil, 0, False, False);
  fAddButtonButton := AddEditMnemoToolBarButton(242, CIconButton, 'Add button', nil, 0, False, False);
  fAddComboBoxButton := AddEditMnemoToolBarButton(276, CIconComboBox, 'Add combo box', nil, 0, False, False);
  fDeleteComponentButton := AddEditMnemoToolBarButton(316, -1, 'Delete selected component', @btnDeleteComponentClick, 0, False, True, '-');

  fEditorCanvas := TPanel.Create(Self);
  fEditorCanvas.Parent := fEditorShell;
  fEditorCanvas.Align := alClient;
  fEditorCanvas.BevelOuter := bvNone;
  fEditorCanvas.Color := clWhite;
  fEditorCanvas.ParentBackground := False;
end;

procedure TMainForm.EnsureBaseToolbar;
var
  lLabel: TLabel;
begin
  if fBaseToolbar <> nil then
    Exit;

  fBaseToolbar := TPanel.Create(Self);
  fBaseToolbar.Parent := pnMain;
  fBaseToolbar.Align := alTop;
  fBaseToolbar.Height := 36;
  fBaseToolbar.BevelOuter := bvLowered;
  fBaseToolbar.Visible := False;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := fBaseToolbar;
  lLabel.Left := 8;
  lLabel.Top := 9;
  lLabel.Caption := 'Oscillogram count';

  fOscillogramCountEdit := TSpinEdit.Create(Self);
  fOscillogramCountEdit.Parent := fBaseToolbar;
  fOscillogramCountEdit.Left := 128;
  fOscillogramCountEdit.Top := 4;
  fOscillogramCountEdit.Width := 64;
  fOscillogramCountEdit.MinValue := 1;
  fOscillogramCountEdit.MaxValue := 16;
  fOscillogramCountEdit.Value := 2;
  fOscillogramCountEdit.OnChange := @OscillogramCountChange;

  fBaseFpsLabel := TLabel.Create(Self);
  fBaseFpsLabel.Parent := fBaseToolbar;
  fBaseFpsLabel.Left := 208;
  fBaseFpsLabel.Top := 9;
  fBaseFpsLabel.AutoSize := True;
  fBaseFpsLabel.Caption := 'FPS -';

  fBaseChartsPanel := TPanel.Create(Self);
  fBaseChartsPanel.Parent := pnMain;
  fBaseChartsPanel.Align := alClient;
  fBaseChartsPanel.BevelOuter := bvNone;
  fBaseChartsPanel.Color := clWhite;
  fBaseChartsPanel.ParentBackground := False;
  fBaseChartsPanel.Visible := False;
  fBaseChartsPanel.OnResize := @BaseChartsPanelResize;
end;

procedure TMainForm.ShowEditorSurface(AVisible: Boolean);
begin
  EnsureEditorSurface;
  fEditorShell.Visible := AVisible;

  { The editor shell and the built-in digital grid share pnMain with the base
    oscillogram surface. When the editor is hidden we send it back explicitly so
    stale child-window pixels cannot stay above OpenGL charts until the next
    external repaint message. }
  if AVisible then
  begin
    sgFormular.Visible := False;
    fEditorShell.BringToFront;
  end
  else
  begin
    fEditorShell.SendToBack;
    sgFormular.Visible := True;
    sgFormular.BringToFront;
  end;
end;

procedure TMainForm.ShowBaseToolbar(AVisible: Boolean);
begin
  EnsureBaseToolbar;
  fBaseToolbar.Visible := AVisible;
  if fBaseChartsPanel <> nil then
    fBaseChartsPanel.Visible := AVisible;
  if AVisible then
  begin
    if fBaseChartsPanel <> nil then
    begin
      fBaseChartsPanel.BringToFront;
      fBaseChartsPanel.Invalidate;
    end;
    fBaseToolbar.BringToFront;
  end;
end;

function TMainForm.IsBuiltInPage(APage: TRecorderFormPage): Boolean;
begin
  Result := (APage <> nil) and
    ((APage.Id = 'DigitalForm') or (APage.Id = 'BasePage'));
end;

function TMainForm.IsUserMnemonicPage(APage: TRecorderFormPage): Boolean;
begin
  Result := (APage <> nil) and (not IsBuiltInPage(APage));
end;

{ Отрисовка цифрового формуляра со списком рассчитанных оценок }
procedure TMainForm.RenderDigitalPage;
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(False);
  sgFormular.Visible := True;
  sgFormular.Align := alClient;
  RenderRecorderDigitalPage(sgFormular, fRecorder.TagRegistry, fRecorder.AlarmEngine);
end;

procedure TMainForm.RenderBasePage;
var
  lCount: Integer;
  lPage: TRecorderFormPage;
begin
  ShowEditorSurface(False);
  sgFormular.Visible := False;
  ShowBaseToolbar(True);

  lPage := nil;
  if fFormManager <> nil then
    lPage := fFormManager.ActivePage;

  if (lPage <> nil) and (lPage.Id = 'BasePage') then
    lCount := lPage.BaseOscillogramCount
  else
    lCount := 2;
  if lCount < 1 then
    lCount := 1;
  if lCount > 16 then
    lCount := 16;

  if fOscillogramCountEdit <> nil then
  begin
    fOscillogramCountEdit.OnChange := nil;
    try
      fOscillogramCountEdit.Value := lCount;
    finally
      fOscillogramCountEdit.OnChange := @OscillogramCountChange;
    end;
  end;

  RebuildBaseOscillograms(lCount);
  RefreshBaseOscillograms;
  RepaintRecorderOglOscillograms(fBaseChartsPanel);
end;

procedure TMainForm.RebuildBaseOscillograms(ACount: Integer);
begin
  EnsureBaseToolbar;
  RebuildRecorderOglOscillograms(Self, fBaseChartsPanel, fRecorder.TagRegistry, ACount,
    fRecorder.RunSettings.DisplayBufferMs / 1000);
end;

procedure TMainForm.RefreshBaseOscillograms;
begin
  RefreshRecorderOglOscillograms(fBaseChartsPanel, fRecorder.TagRegistry,
    fRecorder.RunSettings.DisplayBufferMs / 1000, fRecorder.StateMachine.State = rsPreview);
  if fBaseFpsLabel <> nil then
    fBaseFpsLabel.Caption := RecorderOglOscillogramsFpsText(fBaseChartsPanel);
end;

procedure TMainForm.RenderMnemonicPage(APage: TRecorderFormPage);
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(True);
  if fFormEditor <> nil then
  begin
    fFormEditor.SetDataContext(fRecorder.TagRegistry, fRecorder.AlarmEngine, fRecorder.RunSettings.DisplayBufferMs / 1000);
    fFormEditor.Render;
  end;
end;

procedure TMainForm.RenderBuiltInPage(APage: TRecorderFormPage);
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(False);
  sgFormular.Visible := True;
  sgFormular.Align := alClient;
  FillPlaceholderFormular(sgFormular);
end;

{ Контроль доступности действий редактирования в зависимости от типа активного формуляра }
procedure TMainForm.UpdateEditorAvailability(APage: TRecorderFormPage);
var
  lCanEdit: Boolean;
begin
  lCanEdit := IsUserMnemonicPage(APage);

  if fEditModeButton <> nil then
  begin
    fEditModeButton.Visible := lCanEdit;
    if not lCanEdit then
      fEditModeButton.Down := False;
  end;

  if fAddOscillogramButton <> nil then
    fAddOscillogramButton.Visible := lCanEdit;
  if fAddTrendButton <> nil then
    fAddTrendButton.Visible := lCanEdit;
  if fAddTextButton <> nil then
    fAddTextButton.Visible := lCanEdit;
  if fAddSpectrumButton <> nil then
    fAddSpectrumButton.Visible := lCanEdit;
  if fAddDigitalButton <> nil then
    fAddDigitalButton.Visible := lCanEdit;
  if fAddTagTableButton <> nil then
    fAddTagTableButton.Visible := lCanEdit;
  if fAddButtonButton <> nil then
    fAddButtonButton.Visible := lCanEdit;
  if fAddComboBoxButton <> nil then
    fAddComboBoxButton.Visible := lCanEdit;
  if fDeleteComponentButton <> nil then
    fDeleteComponentButton.Visible := lCanEdit;

  if fEditorToolbar <> nil then
    fEditorToolbar.Visible := lCanEdit;
  if fFormEditor <> nil then
    fFormEditor.Enabled := lCanEdit and (fEditModeButton <> nil) and
      fEditModeButton.Down;
end;

procedure TMainForm.OscillogramCountChange(Sender: TObject);
begin
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = 'BasePage') then
  begin
    if fOscillogramCountEdit <> nil then
      fFormManager.ActivePage.BaseOscillogramCount := fOscillogramCountEdit.Value;
    RenderBasePage;
  end;
end;

procedure TMainForm.BaseChartsPanelResize(Sender: TObject);
begin
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = 'BasePage') and
    (fOscillogramCountEdit <> nil) then
    RebuildBaseOscillograms(fOscillogramCountEdit.Value);
end;

{ Автогенерация базовой директории и дефолтных ini-файлов конфигурации }
procedure TMainForm.EnsureDevConfig;
var
  lAppConfigDir: string;
  lAppConfigFileName: string;
  lAppConfig: TStringList;
begin
  ForceDirectories(fProjectConfigDir);

  lAppConfigDir := IncludeTrailingPathDelimiter(GetDevProjectDir) + 'config';
  ForceDirectories(lAppConfigDir);
  lAppConfigFileName := IncludeTrailingPathDelimiter(lAppConfigDir) + 'app.ini';

  if not FileExists(lAppConfigFileName) then
  begin
    lAppConfig := TStringList.Create;
    try
      lAppConfig.Add('[Application]');
      lAppConfig.Add('DefaultProjectConfigDir=projects/default');
      lAppConfig.Add('TimeSource=PC');
      lAppConfig.Add('');
      lAppConfig.Add('[Plugins]');
      lAppConfig.Add('; Plugin list will be added later');
      lAppConfig.SaveToFile(lAppConfigFileName);
    finally
      lAppConfig.Free;
    end;
  end;

  if not FileExists(fRunControlFileName) then
    fRecorder.RunSettings.SaveToFile(fRunControlFileName);
end;

function TMainForm.GetDevProjectDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetCurrentDir);

  if FileExists(Result + 'RecorderLnx.lpi') then
    Exit;

  Result := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    '..' + DirectorySeparator + '..');
  Result := IncludeTrailingPathDelimiter(Result);
end;

function TMainForm.GetActiveEditorPage: TRecorderFormPage;
begin
  if IsUserMnemonicPage(fFormManager.ActivePage) then
    Result := fFormManager.ActivePage
  else
    Result := nil;
end;

procedure TMainForm.FormEditorChanged;
begin
  { Макет мнемосхемы автоматически обновляется в TRecorderFormPage. }
  // The component settings dialog invokes this callback after it stores a
  // spectrum configuration. Prepare a newly selected FFT size while stopped,
  // never from the MIC-140 acquisition callback.
  if (fRecorder.StateMachine <> nil) and (fRecorder.StateMachine.State = rsStop) then
    PrepareRuntimeForConfiguration;
end;

{ Чтение условий запуска/останова записи из ini }
procedure TMainForm.LoadRunSettings;
var
  lOldFileName: string;
begin
  if FileExists(fRunControlFileName) then
  begin
    fRecorder.RunSettings.LoadFromFile(fRunControlFileName);
    AddLog('Project run-control config loaded: ' + fRunControlFileName);
  end;
  lOldFileName := IncludeTrailingPathDelimiter(fProjectConfigDir) +
    COldRunControlFileName;
  if (not FileExists(fRunControlFileName)) and FileExists(lOldFileName) then
  begin
    fRecorder.RunSettings.LoadFromFile(lOldFileName);
    AddLog('Legacy run-control config loaded: ' + lOldFileName);
  end;
  SetRecorderMeraFilesPath(fRecorder.RunSettings.MeraFilesPath);
  UpdateRecordFrameManager;
end;

procedure TMainForm.SaveRunSettings;
begin
  ForceDirectories(fProjectConfigDir);
  fRecorder.RunSettings.SaveToFile(fRunControlFileName);
end;

procedure TMainForm.ApplyDisplayTimingSettings;
begin
  if (fRecorder.RunSettings = nil) or (fRecorder.TimeSystem = nil) then
    Exit;

  fRecorder.TimeSystem.DisplayUpdateMs := fRecorder.RunSettings.ScreenUpdateMs;
  if fUiUpdateTimer <> nil then
    fUiUpdateTimer.Interval := fRecorder.TimeSystem.DisplayUpdateMs;
  AddLog(Format('Update settings applied: screenUpdate=%d ms dataUpdate=%d ms historyWindow=%d ms',
    [fRecorder.RunSettings.ScreenUpdateMs, fRecorder.RunSettings.DataUpdateMs,
    fRecorder.RunSettings.DisplayBufferMs]));
end;

{ Комплексная загрузка всего пакета настроек проекта (теги, формы, gui, ini) }
procedure TMainForm.LoadProjectPackage;
var
  lFiles: TRecorderProjectFileSet;
begin
  lFiles := RecorderProjectFileSet(fProjectConfigDir, CProjectBaseName);

  LoadRecorderProjectConfig(lFiles.MainConfigFileName, fRecorder.TagRegistry);
  if fRecorder.AlarmEngine <> nil then
    fRecorder.AlarmEngine.Reset;
  if FileExists(lFiles.MainConfigFileName) then
    AddLog('Project main config loaded: ' + lFiles.MainConfigFileName);

  LoadRecorderGuiConfig(lFiles.GuiFileName, fFormManager, fComponentFactory);
  RecorderResolveTagIdsInManager(fRecorder.TagRegistry, fFormManager);
  RecorderSyncTagNamesInManager(fRecorder.TagRegistry, fFormManager);
  if FileExists(lFiles.GuiFileName) then
  begin
    ResetProjectCounters;
    if fFormEditor <> nil then
    begin
      fFormEditor.ClearSelection;
      fFormEditor.ClearUndoHistory;
    end;
    RefreshPageButtons;
    RenderActivePage;
    AddLog('Project GUI config loaded: ' + lFiles.GuiFileName);
  end;
end;

{ Сохранение всего пакета файлов текущего проекта }
procedure TMainForm.SaveProjectPackage;
var
  lFiles: TRecorderProjectFileSet;
begin
  lFiles := RecorderProjectFileSet(fProjectConfigDir, CProjectBaseName);
  ForceDirectories(lFiles.DirectoryName);

  SaveRunSettings;
  SaveRecorderProjectConfig(lFiles.MainConfigFileName, fRecorder.TagRegistry);
  SaveRecorderGuiConfig(lFiles.GuiFileName, fFormManager);

  AddLog('Project package saved: ' + lFiles.BaseName);
  AddLog('  main config: ' + lFiles.MainConfigFileName);
  AddLog('  GUI config: ' + lFiles.GuiFileName);
  AddLog('  run-control: ' + lFiles.RunControlFileName);
end;

procedure TMainForm.SetProjectConfigDir(const ADirectoryName: string);
var
  lFiles: TRecorderProjectFileSet;
begin
  fProjectConfigDir := IncludeTrailingPathDelimiter(ExpandFileName(ADirectoryName));
  lFiles := RecorderProjectFileSet(fProjectConfigDir, CProjectBaseName);
  fRunControlFileName := lFiles.RunControlFileName;

  UpdateRecordFrameManager;
end;

procedure TMainForm.EnsureConfigPopupMenu;
var
  lMenuItem: TMenuItem;
begin
  if fConfigPopupMenu <> nil then
    Exit;

  fConfigPopupMenu := TPopupMenu.Create(Self);

  lMenuItem := TMenuItem.Create(fConfigPopupMenu);
  lMenuItem.Caption := 'Сохранить текущую конфигурацию';
  lMenuItem.OnClick := @SaveCurrentConfigClick;
  fConfigPopupMenu.Items.Add(lMenuItem);

  lMenuItem := TMenuItem.Create(fConfigPopupMenu);
  lMenuItem.Caption := 'Сохранить конфигурацию в каталог...';
  lMenuItem.OnClick := @SaveConfigAsClick;
  fConfigPopupMenu.Items.Add(lMenuItem);

  lMenuItem := TMenuItem.Create(fConfigPopupMenu);
  lMenuItem.Caption := 'Загрузить конфигурацию из каталога...';
  lMenuItem.OnClick := @LoadConfigFromClick;
  fConfigPopupMenu.Items.Add(lMenuItem);
end;

procedure TMainForm.ShowConfigPopupMenu;
var
  lPoint: TPoint;
begin
  EnsureConfigPopupMenu;
  lPoint := btnSaveConfig.ClientToScreen(Point(0, btnSaveConfig.Height));
  fConfigPopupMenu.PopUp(lPoint.X, lPoint.Y);
end;

procedure TMainForm.SaveCurrentConfigClick(Sender: TObject);
begin
  try
    SaveProjectPackage;
  except
    on E: Exception do
      LogCommandError('Save config', E);
  end;
end;

procedure TMainForm.SaveConfigAsClick(Sender: TObject);
var
  lDir: string;
begin
  lDir := fProjectConfigDir;
  if not SelectDirectory('Выберите каталог для сохранения конфигурации', '', lDir) then
    Exit;

  SetProjectConfigDir(lDir);
  SaveProjectPackage;
  AddLog('Project config directory changed: ' + fProjectConfigDir);
end;

procedure TMainForm.LoadConfigFromClick(Sender: TObject);
var
  lDir: string;
begin
  lDir := fProjectConfigDir;
  if not SelectDirectory('Выберите каталог конфигурации для загрузки', '', lDir) then
    Exit;

  if fRecorder.StateMachine.State <> rsStop then
    fRecorder.StateMachine.Stop;
  SetProjectConfigDir(lDir);
  LoadRunSettings;
  ApplyDisplayTimingSettings;
  LoadProjectPackage;
  fRecorder.DataSources.Clear;
  fDataSourcesConfigured := False;
  EnsureRuntimeDataSources;
  PrepareRuntimeForConfiguration;
  RebuildTagList(edTagSearch.Text);
  RenderActivePage;
  AddLog('Project config loaded from directory: ' + fProjectConfigDir);
end;

procedure TMainForm.OpenRecordFrame;
var
  lFrameDir: string;
begin
  if fMeraWriter = nil then
    fMeraWriter := TRecorderMeraTagWriter.Create;
  if fMeraWriter.FileOpen then
    Exit;
  if fRecordFrameManager = nil then
    SetProjectConfigDir(fProjectConfigDir);

  lFrameDir := fRecordFrameManager.OpenNextFrame;
  fRecordFrameManager.WriteFrameInfo(CProjectBaseName, 'RecorderLnx MERA record');
  fMeraWriter.Open(lFrameDir);
  UpdateMainCaption;
  AddLog('MERA recording opened: ' + lFrameDir);
end;

procedure TMainForm.CloseRecordFrame;
begin
  if fMeraWriter <> nil then
    fMeraWriter.Close;
  if fRecordFrameManager <> nil then
    fRecordFrameManager.CloseFrame;
  UpdateMainCaption;
end;
procedure TMainForm.ResetProjectCounters;
var
  I: Integer;
  J: Integer;
  lNumber: Integer;
  lPage: TRecorderFormPage;

  function TrailingNumber(const AText: string): Integer;
  var
    K: Integer;
    lDigits: string;
  begin
    lDigits := '';
    for K := Length(AText) downto 1 do
      if AText[K] in ['0'..'9'] then
        lDigits := AText[K] + lDigits
      else if lDigits <> '' then
        Break;
    Result := StrToIntDef(lDigits, 0);
  end;
begin
  fNextPageNo := fFormManager.PageCount;
  fNextComponentNo := 0;
  for I := 0 to fFormManager.PageCount - 1 do
  begin
    lPage := fFormManager.Pages[I];
    lNumber := TrailingNumber(lPage.Id);
    if lNumber > fNextPageNo then
      fNextPageNo := lNumber;

    for J := 0 to lPage.ComponentCount - 1 do
    begin
      lNumber := TrailingNumber(lPage.Components[J].Id);
      if lNumber > fNextComponentNo then
        fNextComponentNo := lNumber;
    end;
  end;
end;

{ Фильтрация отображаемых в боковой панели тегов }
function TMainForm.TagListItemName(const AItemText: string): string;
var
  lSepPos: Integer;
begin
  // New format: "<name><TAB><freq>"
  lSepPos := Pos(#9, AItemText);
  if lSepPos > 0 then
    Exit(Copy(AItemText, 1, lSepPos - 1));

  // Backward compatible fallback (old format used fixed spaces).
  lSepPos := Pos('     ', AItemText);
  if lSepPos > 0 then
    Result := Copy(AItemText, 1, lSepPos - 1)
  else
    Result := Trim(AItemText);
end;

function TMainForm.FindRegistryTagForListObject(AObj: TObject): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  if (AObj = nil) or (fRecorder.TagRegistry = nil) then
    Exit;
  for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
    if fRecorder.TagRegistry.Tags[I] = AObj then
      Exit(fRecorder.TagRegistry.Tags[I]);
end;

function TMainForm.CurrentTagListSelectionName: string;
var
  lItem: TListItem;
  lTag: TRecorderTag;
begin
  Result := '';
  if (fRecorder.TagRegistry = nil) or (lbTags = nil) then
    Exit;

  { Выделенная пользователем строка имеет приоритет над прежним состоянием
    реестра. Иначе старый SelectedTagName не даёт клику выбрать новый канал. }
  lItem := lbTags.Selected;
  if lItem <> nil then
  begin
    lTag := FindRegistryTagForListObject(TObject(lItem.Data));
    if lTag <> nil then
      Exit(lTag.Name);
    Result := Trim(lItem.Caption);
    if fRecorder.TagRegistry.FindByName(Result) <> nil then
      Exit;
  end;

  Result := Trim(fRecorder.TagRegistry.SelectedTagName);
  if fRecorder.TagRegistry.FindByName(Result) = nil then
    Result := '';
end;

procedure TMainForm.RebuildTagList(const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lFrequencyText: string;
  lItem: TListItem;
  lSelectedName: string;
  lSelectedTag: TRecorderTag;
  lTag: TRecorderTag;
  lTopIndex: Integer;
begin
  lTopIndex := 0;
  if lbTags.TopItem <> nil then
    lTopIndex := lbTags.TopItem.Index;
  lSelectedName := CurrentTagListSelectionName;
  lSelectedTag := nil;
  if lSelectedName <> '' then
    lSelectedTag := fRecorder.TagRegistry.FindByName(lSelectedName);

  lbTags.Items.BeginUpdate;
  try
    lbTags.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));

    for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
    begin
      lTag := fRecorder.TagRegistry.Tags[I];
      if not RecorderTagSourceIsVisible(fRecorder.TagRegistry, lTag) then
        Continue;
      if (lFilter <> '') and
        (Pos(lFilter, LowerCase(lTag.Name + ' ' + lTag.Address + ' ' +
        lTag.Description)) = 0) then
        Continue;

      if lTag.PollFrequencyHz > 0 then
        lFrequencyText := FormatFloat('0.######', lTag.PollFrequencyHz) + ' Hz'
      else
        lFrequencyText := '-';

      lItem := lbTags.Items.Add;
      lItem.Caption := lTag.Name;
      lItem.SubItems.Add(lFrequencyText);
      lItem.Data := lTag;
    end;

    if lSelectedTag <> nil then
      for I := 0 to lbTags.Items.Count - 1 do
        if TObject(lbTags.Items[I].Data) = lSelectedTag then
        begin
          lbTags.Items[I].Selected := True;
          lbTags.Items[I].Focused := True;
          Break;
        end;
    if (lbTags.Items.Count > 0) and (lTopIndex >= 0) and (lTopIndex < lbTags.Items.Count) then
      lbTags.Items[lTopIndex].MakeVisible(False);
  finally
    lbTags.Items.EndUpdate;
  end;
end;

procedure TMainForm.CollectSelectedTags(ATags: TList);
var
  I: Integer;
  lItem: TListItem;
  lTag: TRecorderTag;
begin
  if ATags = nil then
    Exit;
  ATags.Clear;

  for I := 0 to lbTags.Items.Count - 1 do
  begin
    lItem := lbTags.Items[I];
    if (lItem = nil) or not lItem.Selected then
      Continue;
    lTag := FindRegistryTagForListObject(TObject(lItem.Data));
    if lTag = nil then
      lTag := fRecorder.TagRegistry.FindByName(Trim(lItem.Caption));
    if lTag <> nil then
      ATags.Add(lTag);
  end;

  if ATags.Count = 0 then
  begin
    lTag := fRecorder.TagRegistry.FindByName(CurrentTagListSelectionName);
    if lTag <> nil then
      ATags.Add(lTag);
  end;
end;

procedure TMainForm.UpdateSelectedTagFromList;
var
  lTag: TRecorderTag;
begin
  if (fRecorder.TagRegistry = nil) or (lbTags = nil) then
    Exit;

  lTag := fRecorder.TagRegistry.FindByName(CurrentTagListSelectionName);
  if lTag <> nil then
    fRecorder.TagRegistry.SelectedTagName := lTag.Name;
end;
procedure TMainForm.OpenSelectedTagSettings;
var
  lTags: TList;
  lWasRunning: Boolean;
begin
  lTags := TList.Create;
  try
    CollectSelectedTags(lTags);
    if lTags.Count = 0 then
      Exit;

    if ShowTagSettingsDialog(Self, fRecorder.TagRegistry, lTags, ilTagDialogButtons,
      fRecorder.RunSettings.DataUpdateMs, @TagHardwareSourceSetup, @TagZeroBalance,
      ilCommandButtons) then
    begin
      if fRecorder.AlarmEngine <> nil then
        fRecorder.AlarmEngine.Reset;

      lWasRunning := (fRecorder.DataSources <> nil) and fRecorder.DataSources.Running;
      if lWasRunning then
        StopDataSources;

      fRecorder.DataSources.Clear;
      fDataSourcesConfigured := False;

      { Память источников перевыделяется при изменении конфигурации тегов. }
      EnsureRuntimeDataSources;
      PrepareRuntimeForConfiguration;

      if lWasRunning then
        StartDataSources;

      RecorderSyncTagNamesInManager(fRecorder.TagRegistry, fFormManager);
      RebuildTagList(edTagSearch.Text);
      if fFormEditor <> nil then
        fFormEditor.RefreshLive;
      RefreshBaseOscillograms;
      AddLog(Format('Tag settings updated: %d channel(s).', [lTags.Count]));
    end;
  except
    on E: Exception do
      LogCommandError('Tag settings', E);
  end;
  lTags.Free;
end;

procedure TMainForm.TagHardwareSourceSetup(Sender: TObject; ATag: TRecorderTag);
begin
  RecorderEditTagDevice(Self, fRecorder, ATag, ilCommandButtons,
    ilTagDialogButtons, @DeviceTestLog);
end;

procedure TMainForm.TagZeroBalance(Sender: TObject; ARegistry: TRecorderTagRegistry;
  ATags: TList);
begin
  RecorderBalanceTagDevices(Self, fRecorder, ARegistry, ATags);
end;

{ Инициализация демонстрационных отладочных источников данных (MemTag и Mera-файлы) }
procedure TMainForm.EnsureRuntimeDataSources;
begin
  if fDataSourcesConfigured then
    Exit;
  RecorderBuildRuntimeSources(fRecorder, fRecorder.RunSettings.DataUpdateMs,
    @DeviceTestLog);
  EnsureTagSignalBufferCapacities;
  fDataSourcesConfigured := True;
  AddLog('Diagnostics data source configured: MemTag, CpuUsage.');
  UpdateActiveSourceIds;
end;

procedure TMainForm.EnsureTagSignalBufferCapacities;
var
  I: Integer;
  lBlockSamples: Integer;
  lCapacity: Integer;
  lDisplaySeconds: Double;
  lPortionLength: Integer;
  lRequired: Integer;
  lTag: TRecorderTag;
begin
  if (fRecorder.TagRegistry = nil) or (fRecorder.RunSettings = nil) then
    Exit;

  lDisplaySeconds := fRecorder.RunSettings.DisplayBufferMs / 1000.0;
  if lDisplaySeconds <= 0 then
    lDisplaySeconds := 1.0;

  for I := 0 to fRecorder.TagRegistry.TagCount - 1 do
  begin
    lTag := fRecorder.TagRegistry.Tags[I];
    lPortionLength := lTag.EstimateSettings.PortionLength;
    if lPortionLength < 1 then
      lPortionLength := 1;

    lCapacity := 4096;
    if lTag.PollFrequencyHz > 0 then
    begin
      lRequired := Ceil(lTag.PollFrequencyHz * lDisplaySeconds) + 1;
      lBlockSamples := Ceil(lTag.PollFrequencyHz * fRecorder.RunSettings.DataUpdateMs / 1000.0) + 1;
      lRequired := lRequired + lBlockSamples;
      if lRequired > lCapacity then
        lCapacity := lRequired;
    end;
    if lPortionLength + 1 > lCapacity then
      lCapacity := lPortionLength + 1;
    lTag.EnsureBufferCapacity(lCapacity);
  end;
end;
procedure TMainForm.StartDataSources;
begin
  EnsureRuntimeDataSources;
  if not fRecorder.DataSources.Running then
  begin
    fRecorder.DataSources.StartAll;
    fUiUpdateTimer.Enabled := True;
    AddLog('Data sources started.');
  end;
end;

procedure TMainForm.StopDataSources;
begin
  if fUiUpdateTimer <> nil then
    fUiUpdateTimer.Enabled := False;

  if (fRecorder.DataSources <> nil) and fRecorder.DataSources.Running then
  begin
    fRecorder.DataSources.StopAll;
    DrainUiEventQueue(nil);
    AddLog('Data sources stopped.');
  end;
end;

{ Разбор приходящей из worker-thread очереди снимков значений тегов в UI-поток }
procedure TMainForm.DrainUiEventQueue(Sender: TObject);
var
  lSnapshot: TRecorderEventSnapshot;
  lStart: QWord;
  lCount: Integer;
begin
  lStart := GetTickCount64;
  lCount := 0;
  Inc(fDiagUiTicks);
  repeat
    lSnapshot := fRecorder.EventQueue.Pop;
    if lSnapshot = nil then
      Break;
    try
      ApplyTagEventSnapshot(lSnapshot);
      Inc(fDiagDataEvents);
      Inc(lCount);
    finally
      lSnapshot.Free;
    end;
  until False;

  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) then
  begin
    if fFormManager.ActivePage.Id = 'DigitalForm' then
    begin
      RenderDigitalPage;
      Inc(fDiagRenderCount);
    end
    else if fFormManager.ActivePage.Id = 'BasePage' then
    begin
      RefreshBaseOscillograms;
      Inc(fDiagRenderCount);
    end
    else if IsUserMnemonicPage(fFormManager.ActivePage) then
    begin
      if fFormEditor <> nil then
        fFormEditor.RefreshLive;
      Inc(fDiagRenderCount);
    end;
  end;

  UpdateTimeView;
  LogUpdateDiagnostics;
  if GetTickCount64 - lStart > 10 then
    { MIC-140 stream debug: UI queue drain timing suppressed.
    RecorderDebugLog(Format('[UI] DrainUiEventQueue: Count=%d, Time=%d ms, ThreadID=%d',
      [lCount, GetTickCount64 - lStart, PtrUInt(GetThreadID)])); }
end;

procedure TMainForm.LogUpdateDiagnostics;
var
  lElapsedMs: QWord;
  lNowMs: QWord;
begin
  lNowMs := GetTickCount64;
  if fDiagLastLogTickMs = 0 then
    fDiagLastLogTickMs := lNowMs;
  lElapsedMs := lNowMs - fDiagLastLogTickMs;
  if lElapsedMs < 1000 then
    Exit;

  { MIC-140 stream debug: periodic UI update diag suppressed.
  AddLog(Format('Update diag: elapsed=%d ms uiTicks=%d dataEvents=%d renders=%d screenTimer=%d ms dataUpdate=%d ms',
    [lElapsedMs, fDiagUiTicks, fDiagDataEvents, fDiagRenderCount,
    fUiUpdateTimer.Interval, fRecorder.RunSettings.DataUpdateMs]), rlkData); }
  fDiagLastLogTickMs := lNowMs;
  fDiagUiTicks := 0;
  fDiagDataEvents := 0;
  fDiagRenderCount := 0;
end;

procedure TMainForm.ApplyTagEventSnapshot(ASnapshot: TRecorderEventSnapshot);
var
  lBlock: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
begin
  if ASnapshot = nil then
    Exit;

  if ASnapshot.HasAlarmData then
  begin
    if ASnapshot.AlarmActive then
      AddLog('[ALARM] ' + ASnapshot.Text, rlkAlarm)
    else
      AddLog('[ALARM RESET] ' + ASnapshot.Text, rlkAlarm);
    Exit;
  end;

  if not ASnapshot.HasTagData then
    Exit;

  fLatestTagValues.Values[ASnapshot.TagName] :=
    FormatFloat('0.000', ASnapshot.Value);
  fRecorder.TimeSystem.UpdateFromTagSample(ASnapshot.TimeSec);

  if (fRecorder.StateMachine <> nil) and (fRecorder.StateMachine.State = rsRecord) and
    (fMeraWriter <> nil) and fMeraWriter.FileOpen then
  begin
    lTag := fRecorder.TagRegistry.FindByName(ASnapshot.TagName);
    if lTag <> nil then
    begin
      lBlock := lTag.LastBlockSnapshot;
      if lBlock.Count > 0 then
        fMeraWriter.WriteBlock(ASnapshot.TagName, lTag.UnitName,
          lTag.Description, lTag.SensorCalibrationName,
          lTag.AmplifierCalibrationName, lBlock.Times, lBlock.Values,
          lBlock.Count, lTag.PollFrequencyHz)
      else
        fMeraWriter.WriteBlock(ASnapshot.TagName, lTag.UnitName,
          lTag.Description, lTag.SensorCalibrationName,
          lTag.AmplifierCalibrationName, ASnapshot.Times, ASnapshot.Values,
          ASnapshot.SampleCount, lTag.PollFrequencyHz);
    end
    else
      fMeraWriter.WriteBlock(ASnapshot.TagName, '', '', '', '',
        ASnapshot.Times, ASnapshot.Values, ASnapshot.SampleCount, 0);
  end;
end;

{ Настройка шрифтов баннера состояния/времени под высоту pnRightStatus }
procedure TMainForm.SetupStatusBanner;
var
  lHalf, lStateSize, lTimeSize: Integer;
begin
  lHalf := pnRightStatus.ClientHeight div 2;
  if lHalf < 24 then
    lHalf := 24;

  lStateSize := Max(12, pnRightStatus.ClientHeight div 5);
  lTimeSize := Max(14, pnRightStatus.ClientHeight div 4);

  lbState.AutoSize := False;
  lbState.Align := alTop;
  lbState.Height := lHalf;
  lbState.Layout := tlCenter;
  lbState.Font.Name := Font.Name;
  lbState.Font.Size := lStateSize;
  lbState.Font.Style := [fsBold];

  lbTime.AutoSize := False;
  lbTime.Align := alClient;
  lbTime.Layout := tlCenter;
  lbTime.Font.Name := Font.Name;
  lbTime.Font.Size := lTimeSize;
  lbTime.Font.Style := [fsBold];
end;

procedure TMainForm.SetupCommandButtons;
begin
  btnAddPage.Caption := '[]';
  btnAddPage.Hint := 'Formulars';
  btnAddPage.ShowHint := True;

  btnSettings.SetBounds(8, 8, 40, 42);
  btnSaveConfig.SetBounds(54, 8, 40, 42);
  btnSaveConfigAs.SetBounds(100, 8, 40, 42);
  btnRunWinpos.SetBounds(146, 8, 40, 42);
  btnStop.SetBounds(16, 58, 42, 42);
  btnPreview.SetBounds(66, 58, 42, 42);
  btnRecord.SetBounds(116, 58, 42, 42);
  btnTrigger.SetBounds(16, 108, 142, 32);

  btnSettings.Caption := '';
  btnSettings.Images := ilCommandButtons;
  btnSettings.ImageIndex := CIconSettings;
  btnSettings.ImageWidth := 32;
  btnSettings.Hint := 'Settings';
  btnSettings.ShowHint := True;

  btnSaveConfig.Caption := '';
  btnSaveConfig.Images := ilCommandButtons;
  btnSaveConfig.ImageIndex := CIconSaveConfig;
  btnSaveConfig.ImageWidth := 32;
  btnSaveConfig.Hint := 'Save current config';
  
  btnSaveConfigAs.Caption := '';
  btnSaveConfigAs.Images := ilCommandButtons;
  btnSaveConfigAs.ImageIndex := CIconSaveConfigAs;
  btnSaveConfigAs.ImageWidth := 32;
  btnSaveConfigAs.Hint := 'Save config as...';
  btnSaveConfigAs.ShowHint := True;
  btnSaveConfig.ShowHint := True;

  btnRunWinpos.Caption := '';
  btnRunWinpos.Images := ilCommandButtons;
  btnRunWinpos.ImageIndex := CIconRunWp;
  btnRunWinpos.ImageWidth := 32;
  btnRunWinpos.Hint := 'Run Winpos';
  btnRunWinpos.ShowHint := True;

  btnStop.Caption := '';
  btnStop.Images := ilCommandButtons;
  btnStop.ImageIndex := CIconStop;
  btnStop.ImageWidth := 32;
  btnStop.Hint := 'Stop';
  btnStop.ShowHint := True;

  btnPreview.Caption := '';
  btnPreview.Images := ilCommandButtons;
  btnPreview.ImageIndex := CIconView;
  btnPreview.ImageWidth := 32;
  btnPreview.Hint := 'View';
  btnPreview.ShowHint := True;

  btnRecord.Caption := '';
  btnRecord.Images := ilCommandButtons;
  btnRecord.ImageIndex := CIconRecord;
  btnRecord.ImageWidth := 32;
  btnRecord.Hint := 'Record';
  btnRecord.ShowHint := True;

  btnTrigger.Caption := 'Trigger';
  btnTrigger.Hint := 'Trigger / condition met';
  btnTrigger.ShowHint := True;

  btnClearSearch.Caption := 'X';
  btnClearSearch.Hint := ' Очистка поиска тегов';
  btnClearSearch.ShowHint := True;
end;

{ Обновление индикатора автомата состояний и цвета панели статуса }
procedure TMainForm.UpdateStateView;
begin
  lbState.Caption := TRecorderStateMachine.StateToString(fRecorder.StateMachine.State);
  UpdateTimeView;

  case fRecorder.StateMachine.State of
    rsStop:
      pnRightStatus.Color := clSilver;
    rsPreviewArmed, rsPreview, rsRecordArmed:
      pnRightStatus.Color := clYellow;
    rsRecord:
      pnRightStatus.Color := clLime;
  end;

  lbState.Font.Color := clBlack;
  lbState.ParentColor := True;
  lbTime.Font.Color := clBlack;
  lbTime.ParentColor := True;
end;

procedure TMainForm.UpdateTimeView;
begin
  if fRecorder.TimeSystem <> nil then
    lbTime.Caption := fRecorder.TimeSystem.Snapshot.DisplayText
  else
    lbTime.Caption := '00:00:00';
end;

procedure TMainForm.LogCommandError(const ACommand: string; E: Exception);
begin
  AddLog(ACommand + ' failed: ' + E.Message);
end;

{ Реакция на смену состояний сбора данных }
procedure TMainForm.PrepareRuntimeForConfiguration;
begin
  if fRecorder.AlgorithmManager <> nil then
    fRecorder.AlgorithmManager.PrepareConfiguration;

  { Источники и теги к этому моменту уже созданы. Подключение, программирование
    модулей и выделение аппаратных буферов выполняются здесь, а не при Preview. }
  if (fRecorder.DataSources <> nil) and fDataSourcesConfigured then
    try
      fRecorder.DataSources.PrepareHardwareAll;
    except
      on E: Exception do
        { Проект можно открыть без подключённого стенда. StartAll повторит
          подготовку оборудования при запуске просмотра. }
        AddLog('Hardware preparation deferred: ' + E.Message);
    end;

  if fRecorder.EventBus <> nil then
    fRecorder.EventBus.Publish(TRecorderEventBus.MakeEvent(rceConfigurationPrepared,
      Self, 'ConfigurationPrepared'));
end;

procedure TMainForm.StateMachineStateChanging(ASender: TObject;
  AOldState, ANewState: TRecorderState;
  ATransition: TRecorderStateTransition);
begin
  if ATransition = rstNone then
    Exit;

  { No allocation, FFT benchmark or channel creation is permitted here.
    A configuration must have prepared the spectrum runtime while stopped. }
  if fRecorder.AlgorithmManager <> nil then
    fRecorder.AlgorithmManager.ValidateStateTransition(ATransition);

  if fRecorder.EventBus <> nil then
    fRecorder.EventBus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionBefore,
      Self, TRecorderStateMachine.TransitionToString(ATransition), '', 0, nil,
      ATransition));
end;

procedure TMainForm.StateMachineStateChanged(ASender: TObject;
  AOldState, ANewState: TRecorderState);
var
  lTransition: TRecorderStateTransition;
begin
  lTransition := TRecorderStateMachine(ASender).LastTransition;

  if (ANewState = rsRecord) and (AOldState <> rsRecord) then
    OpenRecordFrame;

  case ANewState of
    rsPreview, rsRecord:
      begin
        if lTransition in [rstStopToView, rstStopToRecord] then
        begin
          if fRecorder.AlgorithmManager <> nil then
            fRecorder.AlgorithmManager.HandleStateTransition(lTransition);
          fRecorder.TimeSystem.Start;
          StartDataSources;
        end;
      end;
    rsStop:
      begin
        if lTransition in [rstViewToStop, rstRecordToStop] then
        begin
          StopDataSources;
          CloseRecordFrame;
          fRecorder.TimeSystem.Stop;
          if fRecorder.AlgorithmManager <> nil then
            fRecorder.AlgorithmManager.HandleStateTransition(lTransition);
        end;
      end;
  end;

  if (AOldState = rsRecord) and (ANewState <> rsRecord) and (ANewState <> rsStop) then
    CloseRecordFrame;

  UpdateStateView;
  if (lTransition <> rstNone) and (fRecorder.EventBus <> nil) then
    fRecorder.EventBus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter,
      Self, TRecorderStateMachine.TransitionToString(lTransition), '', 0, nil,
      lTransition));
  AddLog(Format('State changed: %s -> %s',
    [TRecorderStateMachine.StateToString(AOldState),
     TRecorderStateMachine.StateToString(ANewState)]));
end;

end.
