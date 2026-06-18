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
}

{$mode objfpc}{$H+}
{$codepage cp1251}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, Buttons, ImgList, ComCtrls, Spin, Math, Menus, LConvEncoding, LCLIntf,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderFormModel,
  uRecorderCoreServices, uRecorderTags, uRecorderDataSources,
  uRecorderEventQueue, uRecorderTimeSystem, uRecorderUiTestData, uFormPagesDialog,
  uFormEditorController, uRecorderSettingsDialog, uTagSettingsDialog,
  uRecorderCommandImages, uRecorderProjectFiles, uRecorderDigitalPageView,
  uRecorderOglOscillogramView, uRecorderDebugLog, uRecorderAlarms, uRecorderDataStorage,
  uRecorderSpectrumRuntime, uRecorderMic140DataSource;

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
    lbTags: TListBox;                            // Список тегов проекта с их текущими значениями
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
    fStateMachine: TRecorderStateMachine;         // Конечный автомат состояний сбора
    fRunSettings: TRecorderRunControlSettings;     // Настройки старта/останова записи
    fEventBus: TRecorderEventBus;                 // Локальная шина обмена внутренними событиями
    fTagRegistry: TRecorderTagRegistry;           // Общий реестр тегов и каналов
    fEventQueue: TRecorderEventSnapshotQueue;     // Очередь снимков значений для UI-потока
    fAlarmEngine: IRecorderAlarmEngine;           // Движок тревог/уставок для отображающих компонентов
    fSpectrumManager: TRecorderSpectrumRuntimeManager;
    fTimeSystem: TRecorderTimeSystem;             // Подсистема контроля времени
    fDataSourceManager: TRecorderDataSourceManager; // Менеджер источников сбора данных
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
    procedure RebuildTagList(const AFilter: string);
    { Собирает выбранные в списке TListBox теги }
    procedure CollectSelectedTags(ATags: TList);
    { Синхронизирует выбранный в UI тег с ядром Recorder. }
    procedure UpdateSelectedTagFromList;
    { Открывает диалог настройки выбранных тегов }
    procedure OpenSelectedTagSettings;
    { Создает отладочный источник MemTag и подключает его к общему registry. }
    procedure EnsureDemoDataSources;
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
    { Обновляет текстовый индикатор состояния из fStateMachine.State. }
    procedure UpdateStateView;
    { Обновляет текстовый индикатор времени из подсистемы. }
    procedure UpdateTimeView;
    { Единая обработка ошибок команд UI. }
    procedure LogCommandError(const ACommand: string; E: Exception);
    { Обработчик события ядра: фиксирует переход состояния в журнале и на форме. }
    procedure StateMachineStateChanged(ASender: TObject;
      AOldState, ANewState: TRecorderState);
    procedure OnMenuEditSelectedTags(Sender: TObject);
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
  fStateMachine := TRecorderStateMachine.Create;
  fStateMachine.OnStateChanged := @StateMachineStateChanged;

  fRunSettings := TRecorderRunControlSettings.Create;
  fEventBus := TRecorderEventBus.Create;
  fTagRegistry := TRecorderTagRegistry.Create(fEventBus);
  fEventQueue := TRecorderEventSnapshotQueue.Create(fEventBus);
  fAlarmEngine := TRecorderAlarmEngine.Create(fEventBus) as IRecorderAlarmEngine;
  fSpectrumManager := TRecorderSpectrumRuntimeManager.Create(fEventBus, fTagRegistry);
  fTimeSystem := TRecorderTimeSystem.Create;
  fDataSourceManager := TRecorderDataSourceManager.Create;
  fLatestTagValues := TStringList.Create;
  fLogLines := TStringList.Create;
  fLatestTagValues.CaseSensitive := False;
  fLatestTagValues.Sorted := False;
  fLatestTagValues.Duplicates := dupAccept;
  fDiagLastLogTickMs := GetTickCount64;
  fUiUpdateTimer := TTimer.Create(Self);
  fUiUpdateTimer.Enabled := False;
  fUiUpdateTimer.Interval := fTimeSystem.DisplayUpdateMs;
  fUiUpdateTimer.OnTimer := @DrainUiEventQueue;

  fComponentFactory := TRecorderComponentFactory.Create;
  fComponentFactory.RegisterDefaultComponents;
  fFormFactory := TRecorderFormFactory.Create(fComponentFactory);
  sgFormular.OnPrepareCanvas := @sgFormularPrepareCanvas;
  fFormManager := TRecorderFormManager.Create;
  SetProjectConfigDir(IncludeTrailingPathDelimiter(GetDevProjectDir) +
    CDefaultProjectConfigDir);

  LoadRecorderCommandImages(ilCommandButtons);
  SetupCommandButtons;
  EnsureLogFilterPanel;
  EnsurePageControl;
  EnsureEditorSurface;
  EnsureBaseToolbar;
  fFormEditor := TFormEditorController.Create(fEditorCanvas, @GetActiveEditorPage,
    fComponentFactory);
  fFormEditor.OnChanged := @FormEditorChanged;
  fFormEditor.SetDataContext(fTagRegistry, fAlarmEngine, fRunSettings.DisplayBufferMs / 1000);
  lbTags.OnClick := @lbTagsClick;
  UpdateActiveSourceIds;
  
  // Создание контекстного меню для настройки каналов
  lPopupMenu := TPopupMenu.Create(Self);
  lMenuItem := TMenuItem.Create(lPopupMenu);
  lMenuItem.Caption := CP1251ToUTF8('Настроить выделенные каналы...');
  lMenuItem.OnClick := @OnMenuEditSelectedTags;
  lPopupMenu.Items.Add(lMenuItem);
  lbTags.PopupMenu := lPopupMenu;

  EnsureDevConfig;
  InitializeFormPages;
  LoadRunSettings;
  ApplyDisplayTimingSettings;
  LoadProjectPackage;
  if fTagRegistry.TagCount = 0 then
    EnsureDemoDataSources;
  RebuildTagList('');
  UpdateStateView;
  AddLog('RecorderLnx started.');

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
  FreeAndNil(fDataSourceManager);
  FreeAndNil(fTimeSystem);
  fAlarmEngine := nil;
  FreeAndNil(fSpectrumManager);
  FreeAndNil(fEventQueue);
  FreeAndNil(fTagRegistry);
  FreeAndNil(fEventBus);
  FreeAndNil(fLatestTagValues);
  FreeAndNil(fLogLines);
  FreeAndNil(fRunSettings);
  FreeAndNil(fStateMachine);
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
  lTag: TRecorderTag;
  lColor: LongInt;
  lRowIdx: Integer;
begin
  if (aRow > 0) and (gdSelected in aState) then Exit;
  if (aRow > 0) and (fTagRegistry <> nil) and (fAlarmEngine <> nil) then
  begin
    lRowIdx := aRow;
    while (lRowIdx > 0) and (sgFormular.Cells[0, lRowIdx] = '') do
      Dec(lRowIdx);
    if lRowIdx > 0 then
    begin
      lTagName := sgFormular.Cells[0, lRowIdx];
      lTag := fTagRegistry.FindByName(lTagName);
      if lTag <> nil then
      begin
        lColor := fAlarmEngine.GetTagAlarmColor(lTag);
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
  lTag: TRecorderTag;
const
  CMeraSourcePrefix = 'Mera file: ';
begin
  if fTagRegistry = nil then Exit;
  fTagRegistry.ClearActiveSources;
  fTagRegistry.RegisterActiveSource('manual');
  fTagRegistry.RegisterActiveSource('debug.diagnostics');
  
  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if Pos(CMeraSourcePrefix, lTag.SourceId) = 1 then
      fTagRegistry.RegisterActiveSource(lTag.SourceId);
  end;
end;

procedure TMainForm.OnMenuEditSelectedTags(Sender: TObject);
begin
  OpenSelectedTagSettings;
end;

procedure TMainForm.PageControlChange(Sender: TObject);
var
  lPageIndex: Integer;
begin
  if fSyncingPages or (fPageControl = nil) then
    Exit;

  lPageIndex := fPageControl.ActivePageIndex;
  if (lPageIndex < 0) or (lPageIndex >= fFormManager.PageCount) then
    Exit;

  fFormManager.SetActivePageById(fFormManager.Pages[lPageIndex].Id);
  if fFormEditor <> nil then
  begin
    fFormEditor.ClearSelection;
    fFormEditor.ClearUndoHistory;
  end;
  RenderActivePage;
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
    if fStateMachine.State = rsPreview then
      Exit;
    fStateMachine.StartPreview(rscManual);
  except
    on E: Exception do
      LogCommandError('Preview', E);
  end;
end;

procedure TMainForm.btnRecordClick(Sender: TObject);
begin
  try
    fRunSettings.RequireValid;
    fStateMachine.StartRecord(fRunSettings.StartCondition);
  except
    on E: Exception do
      LogCommandError('Record', E);
  end;
end;

procedure TMainForm.btnTriggerClick(Sender: TObject);
begin
  try
    fStateMachine.StartConditionMet;
  except
    on E: Exception do
      LogCommandError('Trigger', E);
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  try
    fStateMachine.Stop;
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
    if fStateMachine.State <> rsStop then
    begin
      fStateMachine.Stop;
      AddLog('Configuration mode requested: Recorder stopped before settings.');
    end;

    AddLog('Configuration mode: settings dialog opened.');
    if ShowRecorderSettingsDialog(Self, fRunSettings, fTagRegistry, ilCommandButtons, ilTagDialogButtons) then
    begin
      ApplyDisplayTimingSettings;
      UpdateRecordFrameManager;
      fDataSourceManager.Clear;
      fDataSourcesConfigured := False;
      RebuildTagList(edTagSearch.Text);
      RenderActivePage;
      AddLog('Project settings applied.');
    end
    else
      AddLog('Configuration mode: settings dialog closed without applying OK.');
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
  if fRunSettings <> nil then
    Result := Trim(fRunSettings.RecordRootDir);
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
    if (fTagRegistry <> nil) and (fTagRegistry.SelectedTag <> nil) then
      lComponent.TagName := fTagRegistry.SelectedTag.Name;
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
    if fTagRegistry <> nil then
    begin
      lTag := fTagRegistry.SelectedTag;
      if (lTag = nil) and (fTagRegistry.TagCount > 0) then
        lTag := fTagRegistry.Tags[0];
    end;

    if lTag <> nil then
    begin
      lComponent.TagName := lTag.Name;
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
      lLine.Name := lTag.Name;
      lLine.TagName := lTag.Name;
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
    if fTagRegistry <> nil then
    begin
      lTag := fTagRegistry.SelectedTag;
      if (lTag = nil) and (fTagRegistry.TagCount > 0) then
        lTag := fTagRegistry.Tags[0];
    end;

    if lTag <> nil then
      lComponent.TagNames.Add(lTag.Name);

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
  RenderRecorderDigitalPage(sgFormular, fTagRegistry, fAlarmEngine);
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
  RebuildRecorderOglOscillograms(Self, fBaseChartsPanel, fTagRegistry, ACount,
    fRunSettings.DisplayBufferMs / 1000);
end;

procedure TMainForm.RefreshBaseOscillograms;
begin
  RefreshRecorderOglOscillograms(fBaseChartsPanel, fTagRegistry,
    fRunSettings.DisplayBufferMs / 1000, fStateMachine.State = rsPreview);
  if fBaseFpsLabel <> nil then
    fBaseFpsLabel.Caption := RecorderOglOscillogramsFpsText(fBaseChartsPanel);
end;

procedure TMainForm.RenderMnemonicPage(APage: TRecorderFormPage);
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(True);
  if fFormEditor <> nil then
  begin
    fFormEditor.SetDataContext(fTagRegistry, fAlarmEngine, fRunSettings.DisplayBufferMs / 1000);
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
    fRunSettings.SaveToFile(fRunControlFileName);
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
end;

{ Чтение условий запуска/останова записи из ini }
procedure TMainForm.LoadRunSettings;
var
  lOldFileName: string;
begin
  if FileExists(fRunControlFileName) then
  begin
    fRunSettings.LoadFromFile(fRunControlFileName);
    AddLog('Project run-control config loaded: ' + fRunControlFileName);
  end;
  lOldFileName := IncludeTrailingPathDelimiter(fProjectConfigDir) +
    COldRunControlFileName;
  if (not FileExists(fRunControlFileName)) and FileExists(lOldFileName) then
  begin
    fRunSettings.LoadFromFile(lOldFileName);
    AddLog('Legacy run-control config loaded: ' + lOldFileName);
  end;
  UpdateRecordFrameManager;
end;

procedure TMainForm.SaveRunSettings;
begin
  ForceDirectories(fProjectConfigDir);
  fRunSettings.SaveToFile(fRunControlFileName);
end;

procedure TMainForm.ApplyDisplayTimingSettings;
begin
  if (fRunSettings = nil) or (fTimeSystem = nil) then
    Exit;

  fTimeSystem.DisplayUpdateMs := fRunSettings.ScreenUpdateMs;
  if fUiUpdateTimer <> nil then
    fUiUpdateTimer.Interval := fTimeSystem.DisplayUpdateMs;
  AddLog(Format('Update settings applied: screenUpdate=%d ms dataUpdate=%d ms historyWindow=%d ms',
    [fRunSettings.ScreenUpdateMs, fRunSettings.DataUpdateMs,
    fRunSettings.DisplayBufferMs]));
end;

{ Комплексная загрузка всего пакета настроек проекта (теги, формы, gui, ini) }
procedure TMainForm.LoadProjectPackage;
var
  lFiles: TRecorderProjectFileSet;
begin
  lFiles := RecorderProjectFileSet(fProjectConfigDir, CProjectBaseName);

  LoadRecorderProjectConfig(lFiles.MainConfigFileName, fTagRegistry);
  if fAlarmEngine <> nil then
    fAlarmEngine.Reset;
  if FileExists(lFiles.MainConfigFileName) then
    AddLog('Project main config loaded: ' + lFiles.MainConfigFileName);

  LoadRecorderGuiConfig(lFiles.GuiFileName, fFormManager, fComponentFactory);
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
  SaveRecorderProjectConfig(lFiles.MainConfigFileName, fTagRegistry);
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
  lMenuItem.Caption := CP1251ToUTF8('Сохранить текущую конфигурацию');
  lMenuItem.OnClick := @SaveCurrentConfigClick;
  fConfigPopupMenu.Items.Add(lMenuItem);

  lMenuItem := TMenuItem.Create(fConfigPopupMenu);
  lMenuItem.Caption := CP1251ToUTF8('Сохранить конфигурацию в каталог...');
  lMenuItem.OnClick := @SaveConfigAsClick;
  fConfigPopupMenu.Items.Add(lMenuItem);

  lMenuItem := TMenuItem.Create(fConfigPopupMenu);
  lMenuItem.Caption := CP1251ToUTF8('Загрузить конфигурацию из каталога...');
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
  if not SelectDirectory(CP1251ToUTF8('Выберите каталог для сохранения конфигурации'), '', lDir) then
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
  if not SelectDirectory(CP1251ToUTF8('Выберите каталог конфигурации для загрузки'), '', lDir) then
    Exit;

  if fStateMachine.State <> rsStop then
    fStateMachine.Stop;
  SetProjectConfigDir(lDir);
  LoadRunSettings;
  ApplyDisplayTimingSettings;
  LoadProjectPackage;
  fDataSourceManager.Clear;
  fDataSourcesConfigured := False;
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
procedure TMainForm.RebuildTagList(const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lFrequencyText: string;
  lTag: TRecorderTag;
begin
  lbTags.Items.BeginUpdate;
  try
    lbTags.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));

    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if (lFilter <> '') and
        (Pos(lFilter, LowerCase(lTag.Name + ' ' + lTag.Address + ' ' +
        lTag.Description)) = 0) then
        Continue;

      if lTag.PollFrequencyHz > 0 then
        lFrequencyText := FormatFloat('0.######', lTag.PollFrequencyHz) + ' Hz'
      else
        lFrequencyText := '-';

      lbTags.Items.AddObject(Format('%s     %s', [lTag.Name, lFrequencyText]), lTag);
    end;
  finally
    lbTags.Items.EndUpdate;
  end;
end;

procedure TMainForm.CollectSelectedTags(ATags: TList);
var
  I: Integer;
begin
  if ATags = nil then
    Exit;
  ATags.Clear;

  for I := 0 to lbTags.Items.Count - 1 do
    if lbTags.Selected[I] and (lbTags.Items.Objects[I] is TRecorderTag) then
      ATags.Add(lbTags.Items.Objects[I]);

  if (ATags.Count = 0) and (lbTags.ItemIndex >= 0) and
    (lbTags.Items.Objects[lbTags.ItemIndex] is TRecorderTag) then
    ATags.Add(lbTags.Items.Objects[lbTags.ItemIndex]);
end;

procedure TMainForm.UpdateSelectedTagFromList;
var
  lTag: TRecorderTag;
begin
  if (fTagRegistry = nil) or (lbTags = nil) then
    Exit;

  if (lbTags.ItemIndex >= 0) and
    (lbTags.Items.Objects[lbTags.ItemIndex] is TRecorderTag) then
  begin
    lTag := TRecorderTag(lbTags.Items.Objects[lbTags.ItemIndex]);
    fTagRegistry.SelectedTagName := lTag.Name;
  end;
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

    if ShowTagSettingsDialog(Self, fTagRegistry, lTags, ilTagDialogButtons, fRunSettings.DataUpdateMs) then
    begin
      if fAlarmEngine <> nil then
        fAlarmEngine.Reset;

      lWasRunning := (fDataSourceManager <> nil) and fDataSourceManager.Running;
      if lWasRunning then
        StopDataSources;

      fDataSourceManager.Clear;
      fDataSourcesConfigured := False;

      if lWasRunning then
        StartDataSources;

      RebuildTagList(edTagSearch.Text);
      AddLog(Format('Tag settings updated: %d channel(s).', [lTags.Count]));
    end;
  except
    on E: Exception do
      LogCommandError('Tag settings', E);
  end;
  lTags.Free;
end;

{ Инициализация демонстрационных отладочных источников данных (MemTag и Mera-файлы) }
procedure TMainForm.EnsureDemoDataSources;
var
  I: Integer;
  lChannelCount: Integer;
  lChannelNumber: Integer;
  lFileIndex: Integer;
  lFileName: string;
  lFiles: TStringList;
  lMicHost: string;
  lMicPort: Word;
  lMicOutputMode: TRecorderMic140OutputMode;
  lMicSources: TStringList;
  lPollFrequencyHz: Double;
  lSource: IRecorderDataSource;
  lTag: TRecorderTag;
  lTagNames: TStringList;
  lDataUpdateMs: Cardinal;
const
  CMeraSourcePrefix = 'Mera file: ';
begin
  if fDataSourcesConfigured then
    Exit;

  fDataSourceManager.Clear;

  lDataUpdateMs := fRunSettings.DataUpdateMs;
  if lDataUpdateMs = 0 then
    lDataUpdateMs := 300;

  lSource := TRecorderDiagnosticsDataSource.Create('debug.diagnostics', lDataUpdateMs,
    'MemTag', 'CpuUsage');
  fDataSourceManager.AddSource(lSource);

  lFiles := TStringList.Create;
  lMicSources := TStringList.Create;
  try
    lFiles.CaseSensitive := False;
    lFiles.Sorted := False;
    lMicSources.CaseSensitive := False;
    lMicSources.Sorted := False;
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if Pos(CMeraSourcePrefix, lTag.SourceId) = 1 then
      begin
        lFileName := Trim(Copy(lTag.SourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
        if lFileName = '' then
          Continue;

        lFileIndex := lFiles.IndexOf(lFileName);
        if lFileIndex < 0 then
        begin
          lTagNames := TStringList.Create;
          lTagNames.CaseSensitive := False;
          lFileIndex := lFiles.AddObject(lFileName, lTagNames);
        end
        else
          lTagNames := TStringList(lFiles.Objects[lFileIndex]);

        if lTagNames.IndexOf(lTag.Address) < 0 then
          lTagNames.Add(lTag.Address);
      end
      else if TryParseRecorderMic140SourceId(lTag.SourceId, lMicHost, lMicPort) then
      begin
        lFileIndex := lMicSources.IndexOf(lTag.SourceId);
        if lFileIndex < 0 then
        begin
          lTagNames := TStringList.Create;
          lTagNames.CaseSensitive := False;
          lFileIndex := lMicSources.AddObject(lTag.SourceId, lTagNames);
        end
        else
          lTagNames := TStringList(lMicSources.Objects[lFileIndex]);

        if (lTag.Address <> '') and (lTagNames.IndexOf(lTag.Address) < 0) then
          lTagNames.Add(lTag.Address);
        if (lTag.Name <> '') and (lTagNames.IndexOf(lTag.Name) < 0) then
          lTagNames.Add(lTag.Name);
      end;
    end;

    for I := 0 to lFiles.Count - 1 do
    begin
      lTagNames := TStringList(lFiles.Objects[I]);
      lSource := TRecorderMeraFileDataSource.Create('mera.file.' + IntToStr(I + 1),
        lFiles[I], lDataUpdateMs, lTagNames, 0);
      fDataSourceManager.AddSource(lSource);
      AddLog(Format('MERA playback source configured: %s (%d channels).',
        [ExtractFileName(lFiles[I]), lTagNames.Count]));
    end;

    for I := 0 to lMicSources.Count - 1 do
    begin
      if not TryParseRecorderMic140SourceId(lMicSources[I], lMicHost, lMicPort) then
        Continue;
      lTagNames := TStringList(lMicSources.Objects[I]);
      lChannelCount := MIC140DefaultChannelCount;
      lPollFrequencyHz := MIC140DefaultPollFrequencyHz;
      lMicOutputMode := momMillivolts;
      for lFileIndex := 0 to lTagNames.Count - 1 do
        if TryStrToInt(lTagNames[lFileIndex], lChannelNumber) and
          (lChannelNumber > lChannelCount) then
          lChannelCount := MIC140MaxChannelCount;
      for lFileIndex := 0 to fTagRegistry.TagCount - 1 do
      begin
        lTag := fTagRegistry.Tags[lFileIndex];
        if SameText(lTag.SourceId, lMicSources[I]) and (lTag.PollFrequencyHz > 0) then
        begin
          lPollFrequencyHz := lTag.PollFrequencyHz;
          if Trim(lTag.SourceValueMode) <> '' then
            lMicOutputMode := RecorderMic140ConfigNameToOutputMode(lTag.SourceValueMode);
          Break;
        end;
      end;
      lSource := TRecorderMic140DataSource.Create(lMicSources[I], lMicHost, lMicPort,
        lChannelCount, lPollFrequencyHz, lDataUpdateMs, lTagNames, lMicOutputMode);
      fDataSourceManager.AddSource(lSource);
      AddLog(Format('MIC-140 source configured: %s:%d (%d channels).',
        [lMicHost, lMicPort, lChannelCount]));
    end;
  finally
    for I := 0 to lFiles.Count - 1 do
      lFiles.Objects[I].Free;
    lFiles.Free;
    for I := 0 to lMicSources.Count - 1 do
      lMicSources.Objects[I].Free;
    lMicSources.Free;
  end;
  fDataSourceManager.ConfigureTagsAll(fTagRegistry);
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
  if (fTagRegistry = nil) or (fRunSettings = nil) then
    Exit;

  lDisplaySeconds := fRunSettings.DisplayBufferMs / 1000.0;
  if lDisplaySeconds <= 0 then
    lDisplaySeconds := 1.0;

  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    lPortionLength := lTag.EstimateSettings.PortionLength;
    if lPortionLength < 1 then
      lPortionLength := 1;

    lCapacity := 4096;
    if lTag.PollFrequencyHz > 0 then
    begin
      lRequired := Ceil(lTag.PollFrequencyHz * lDisplaySeconds) + 1;
      lBlockSamples := Ceil(lTag.PollFrequencyHz * fRunSettings.DataUpdateMs / 1000.0) + 1;
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
  EnsureDemoDataSources;
  if not fDataSourceManager.Running then
  begin
    fDataSourceManager.StartAll;
    fUiUpdateTimer.Enabled := True;
    AddLog('Data sources started.');
  end;
end;

procedure TMainForm.StopDataSources;
begin
  if fUiUpdateTimer <> nil then
    fUiUpdateTimer.Enabled := False;

  if (fDataSourceManager <> nil) and fDataSourceManager.Running then
  begin
    fDataSourceManager.StopAll;
    DrainUiEventQueue(nil);
    AddLog('Data sources stopped.');
  end;
end;

{ Разбор приходящей из worker-thread очереди снимков значений тегов в UI-поток }
procedure TMainForm.DrainUiEventQueue(Sender: TObject);
var
  lChanged: Boolean;
  lSnapshot: TRecorderEventSnapshot;
  lStart: QWord;
  lCount: Integer;
begin
  lStart := GetTickCount64;
  lCount := 0;
  Inc(fDiagUiTicks);
  lChanged := False;
  repeat
    lSnapshot := fEventQueue.Pop;
    if lSnapshot = nil then
      Break;
    try
      ApplyTagEventSnapshot(lSnapshot);
      Inc(fDiagDataEvents);
      Inc(lCount);
      lChanged := True;
    finally
      lSnapshot.Free;
    end;
  until False;

  if lChanged then
    RebuildTagList(edTagSearch.Text);

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
    RecorderDebugLog(Format('[UI] DrainUiEventQueue: Count=%d, Time=%d ms, ThreadID=%d',
      [lCount, GetTickCount64 - lStart, PtrUInt(GetThreadID)]));
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

  AddLog(Format('Update diag: elapsed=%d ms uiTicks=%d dataEvents=%d renders=%d screenTimer=%d ms dataUpdate=%d ms',
    [lElapsedMs, fDiagUiTicks, fDiagDataEvents, fDiagRenderCount,
    fUiUpdateTimer.Interval, fRunSettings.DataUpdateMs]), rlkData);
  fDiagLastLogTickMs := lNowMs;
  fDiagUiTicks := 0;
  fDiagDataEvents := 0;
  fDiagRenderCount := 0;
end;

procedure TMainForm.ApplyTagEventSnapshot(ASnapshot: TRecorderEventSnapshot);
var
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
  fTimeSystem.UpdateFromTagSample(ASnapshot.TimeSec);

  if (fStateMachine <> nil) and (fStateMachine.State = rsRecord) and
    (fMeraWriter <> nil) and fMeraWriter.FileOpen then
  begin
    lTag := fTagRegistry.FindByName(ASnapshot.TagName);
    if lTag <> nil then
      fMeraWriter.WriteBlock(ASnapshot.TagName, lTag.UnitName,
        lTag.Description, lTag.SensorCalibrationName,
        lTag.AmplifierCalibrationName, ASnapshot.Times, ASnapshot.Values,
        ASnapshot.SampleCount, lTag.PollFrequencyHz)
    else
      fMeraWriter.WriteBlock(ASnapshot.TagName, '', '', '', '',
        ASnapshot.Times, ASnapshot.Values, ASnapshot.SampleCount, 0);
  end;
end;

{ Инициализация графических кнопок панели управления сбором }
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
  btnSaveConfigAs.ImageIndex := CIconSaveConfig;
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
  btnClearSearch.Hint := 'Clear tag search';
  btnClearSearch.ShowHint := True;
end;

{ Обновление индикатора автомата состояний и цвета панели статуса }
procedure TMainForm.UpdateStateView;
begin
  lbState.Caption := TRecorderStateMachine.StateToString(fStateMachine.State);
  UpdateTimeView;

  case fStateMachine.State of
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
  if fTimeSystem <> nil then
    lbTime.Caption := fTimeSystem.Snapshot.DisplayText
  else
    lbTime.Caption := '00:00:00';
end;

procedure TMainForm.LogCommandError(const ACommand: string; E: Exception);
begin
  AddLog(ACommand + ' failed: ' + E.Message);
end;

{ Реакция на смену состояний сбора данных }
procedure TMainForm.StateMachineStateChanged(ASender: TObject;
  AOldState, ANewState: TRecorderState);
begin
  if (ANewState = rsRecord) and (AOldState <> rsRecord) then
    OpenRecordFrame;

  case ANewState of
    rsPreview, rsRecord:
      begin
        if not (AOldState in [rsPreview, rsRecord]) then
        begin
          fTimeSystem.Start;
          if fSpectrumManager <> nil then
            fSpectrumManager.RebuildChannels;
        end;
        StartDataSources;
      end;
    rsStop:
      begin
        StopDataSources;
        CloseRecordFrame;
        fTimeSystem.Stop;
        if fSpectrumManager <> nil then
          fSpectrumManager.ClearChannels;
      end;
  end;

  if (AOldState = rsRecord) and (ANewState <> rsRecord) and (ANewState <> rsStop) then
    CloseRecordFrame;

  UpdateStateView;
  AddLog(Format('State changed: %s -> %s',
    [TRecorderStateMachine.StateToString(AOldState),
     TRecorderStateMachine.StateToString(ANewState)]));
end;

end.
