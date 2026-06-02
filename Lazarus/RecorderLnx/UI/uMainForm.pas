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

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, Buttons, ImgList, ComCtrls, Spin, Math,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderFormModel,
  uRecorderCoreServices, uRecorderTags, uRecorderDataSources,
  uRecorderEventQueue, uRecorderTimeSystem, uRecorderUiTestData, uFormPagesDialog,
  uFormEditorController, uRecorderSettingsDialog, uTagSettingsDialog,
  uRecorderCommandImages, uRecorderProjectFiles, uRecorderDigitalPageView,
  uRecorderOglOscillogramView, uRecorderDebugLog;

type
  { TMainForm }

  { Класс главной формы приложения RecorderLnx }
  TMainForm = class(TForm)
    btnAddPage: TButton;                         // Кнопка вызова диалога страниц/формуляров
    btnClearSearch: TButton;                     // Кнопка очистки фильтра поиска тегов
    btnPreview: TSpeedButton;                    // Кнопка запуска просмотра (без записи)
    btnRecord: TSpeedButton;                     // Кнопка запуска записи данных
    btnSaveConfig: TSpeedButton;                 // Кнопка сохранения текущей конфигурации проекта
    btnSettings: TSpeedButton;                   // Кнопка вызова общего диалога настроек
    btnStop: TSpeedButton;                       // Кнопка останова сбора/записи
    btnTrigger: TSpeedButton;                    // Кнопка принудительного старта по выполнению условий
    edTagSearch: TEdit;                          // Поле поиска (фильтрации) тегов
    ilCommandButtons: TImageList;                // Список картинок для кнопок управления
    ilCommandButtons1: TImageList;               // Дополнительный список картинок
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
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnTriggerClick(Sender: TObject);
    procedure edTagSearchChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbTagsClick(Sender: TObject);
    procedure lbTagsDblClick(Sender: TObject);
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
    fPageControl: TPageControl;                   // Визуальный контейнер вкладок формуляров
    fSelectedComponentRow: Integer;               // Номер выбранной строки в таблице формуляра
    fSyncingPages: Boolean;                       // Флаг предотвращения рекурсивного вызова при обновлении вкладок
    
    // Ядро системы рекордера
    fStateMachine: TRecorderStateMachine;         // Конечный автомат состояний сбора
    fRunSettings: TRecorderRunControlSettings;     // Настройки старта/останова записи
    fEventBus: TRecorderEventBus;                 // Локальная шина обмена внутренними событиями
    fTagRegistry: TRecorderTagRegistry;           // Общий реестр тегов и каналов
    fEventQueue: TRecorderEventSnapshotQueue;     // Очередь снимков значений для UI-потока
    fTimeSystem: TRecorderTimeSystem;             // Подсистема контроля времени
    fDataSourceManager: TRecorderDataSourceManager; // Менеджер источников сбора данных
    fLatestTagValues: TStringList;                // Буфер последних текстовых значений тегов для отображения
    fUiUpdateTimer: TTimer;                       // Таймер периодического обновления UI из очереди событий
    fDataSourcesConfigured: Boolean;              // Флаг готовности источников данных
    fProjectConfigDir: string;                    // Каталог конфигурационных файлов проекта
    fRunControlFileName: string;                  // Путь к файлу настроек сбора/записи
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
    procedure AddLog(const AMessage: string);
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
    { Обработчик кнопки добавления осциллограммы на полотне. }
    procedure AddOscillogramClick(Sender: TObject);
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
begin
  Caption := 'RecorderLnx - config/projects/default';
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  fSelectedComponentRow := -1;
  fStateMachine := TRecorderStateMachine.Create;
  fStateMachine.OnStateChanged := @StateMachineStateChanged;

  fRunSettings := TRecorderRunControlSettings.Create;
  fEventBus := TRecorderEventBus.Create;
  fTagRegistry := TRecorderTagRegistry.Create(fEventBus);
  fEventQueue := TRecorderEventSnapshotQueue.Create(fEventBus);
  fTimeSystem := TRecorderTimeSystem.Create;
  fDataSourceManager := TRecorderDataSourceManager.Create;
  fLatestTagValues := TStringList.Create;
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
  fFormManager := TRecorderFormManager.Create;
  fProjectConfigDir := IncludeTrailingPathDelimiter(GetDevProjectDir) +
    CDefaultProjectConfigDir;
  fRunControlFileName := RecorderProjectFileSet(fProjectConfigDir,
    CProjectBaseName).RunControlFileName;

  LoadRecorderCommandImages(ilCommandButtons);
  SetupCommandButtons;
  EnsurePageControl;
  EnsureEditorSurface;
  EnsureBaseToolbar;
  fFormEditor := TFormEditorController.Create(fEditorCanvas, @GetActiveEditorPage,
    fComponentFactory);
  fFormEditor.OnChanged := @FormEditorChanged;
  fFormEditor.SetDataContext(fTagRegistry, fRunSettings.DisplayBufferMs / 1000);
  lbTags.OnClick := @lbTagsClick;
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
  FreeAndNil(fDataSourceManager);
  FreeAndNil(fTimeSystem);
  FreeAndNil(fEventQueue);
  FreeAndNil(fTagRegistry);
  FreeAndNil(fEventBus);
  FreeAndNil(fLatestTagValues);
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

procedure TMainForm.lbTagsClick(Sender: TObject);
begin
  UpdateSelectedTagFromList;
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = 'BasePage') then
    RefreshBaseOscillograms
  else if fFormEditor <> nil then
    fFormEditor.Render;
end;

procedure TMainForm.lbTagsDblClick(Sender: TObject);
begin
  UpdateSelectedTagFromList;
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
    if ShowRecorderSettingsDialog(Self, fRunSettings, fTagRegistry, ilCommandButtons) then
    begin
      ApplyDisplayTimingSettings;
      SaveProjectPackage;
      fDataSourceManager.Clear;
      fDataSourcesConfigured := False;
      RebuildTagList(edTagSearch.Text);
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

procedure TMainForm.AddLog(const AMessage: string);
var
  lLine: string;
begin
  lLine := FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AMessage;
  mmLog.Lines.Add(lLine);
  RecorderDebugLog(lLine);
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
    Caption := 'RecorderLnx - config/projects/default';
    Exit;
  end;

  Caption := 'RecorderLnx - config/projects/default - ' + lPage.Title;
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
  fAddTextButton := AddEditMnemoToolBarButton(72, CIconTextLabel, 'Add text label', @btnAddComponentClick);
  fAddSpectrumButton := AddEditMnemoToolBarButton(106, CIconSpectrum, 'Add spectrum', nil, 0, False, False);
  fAddDigitalButton := AddEditMnemoToolBarButton(140, CIconDigitalIndicator, 'Add digital indicator', @AddDigitalIndicatorClick);
  fAddTagTableButton := AddEditMnemoToolBarButton(174, CIconTagTable, 'Add tag table', nil, 0, False, False);
  fAddButtonButton := AddEditMnemoToolBarButton(208, CIconButton, 'Add button', nil, 0, False, False);
  fAddComboBoxButton := AddEditMnemoToolBarButton(242, CIconComboBox, 'Add combo box', nil, 0, False, False);
  fDeleteComponentButton := AddEditMnemoToolBarButton(282, -1, 'Delete selected component', @btnDeleteComponentClick, 0, False, True, '-');

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
  sgFormular.Visible := not AVisible;

  if AVisible then
    fEditorShell.BringToFront
  else
    sgFormular.BringToFront;
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
      fBaseChartsPanel.BringToFront;
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
  RenderRecorderDigitalPage(sgFormular, fTagRegistry);
end;

procedure TMainForm.RenderBasePage;
var
  lCount: Integer;
  lPage: TRecorderFormPage;
begin
  ShowEditorSurface(False);
  ShowBaseToolbar(True);
  sgFormular.Visible := False;

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
    fRunSettings.DisplayBufferMs / 1000);
end;

procedure TMainForm.RenderMnemonicPage(APage: TRecorderFormPage);
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(True);
  if fFormEditor <> nil then
  begin
    fFormEditor.SetDataContext(fTagRegistry, fRunSettings.DisplayBufferMs / 1000);
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
  lTag: TRecorderTag;
  lValue: string;
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

      lValue := fLatestTagValues.Values[lTag.Name];
      if lValue = '' then
        lValue := lTag.TextValue;
      if lValue = '' then
        lValue := '-';

      lbTags.Items.AddObject(Format('%s     %s', [lTag.Name, lValue]), lTag);
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
begin
  lTags := TList.Create;
  try
    CollectSelectedTags(lTags);
    if lTags.Count = 0 then
      Exit;

    if ShowTagSettingsDialog(Self, fTagRegistry, lTags, ilTagDialogButtons) then
    begin
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
  lFileIndex: Integer;
  lFileName: string;
  lFiles: TStringList;
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
  try
    lFiles.CaseSensitive := False;
    lFiles.Sorted := False;
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if Pos(CMeraSourcePrefix, lTag.SourceId) <> 1 then
        Continue;

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

      if lTagNames.IndexOf(lTag.Name) < 0 then
        lTagNames.Add(lTag.Name);
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
  finally
    for I := 0 to lFiles.Count - 1 do
      lFiles.Objects[I].Free;
    lFiles.Free;
  end;

  fDataSourceManager.ConfigureTagsAll(fTagRegistry);
  EnsureTagSignalBufferCapacities;
  fDataSourcesConfigured := True;
  AddLog('Diagnostics data source configured: MemTag, CpuUsage.');
end;

procedure TMainForm.EnsureTagSignalBufferCapacities;
var
  I: Integer;
  lBlockSamples: Integer;
  lCapacity: Integer;
  lDisplaySeconds: Double;
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
    lCapacity := 4096;
    if lTag.PollFrequencyHz > 0 then
    begin
      lRequired := Ceil(lTag.PollFrequencyHz * lDisplaySeconds) + 1;
      lBlockSamples := Ceil(lTag.PollFrequencyHz * fRunSettings.DataUpdateMs / 1000.0) + 1;
      lRequired := lRequired + lBlockSamples;
      if lRequired > lCapacity then
        lCapacity := lRequired;
    end;
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
begin
  Inc(fDiagUiTicks);
  lChanged := False;
  repeat
    lSnapshot := fEventQueue.Pop;
    if lSnapshot = nil then
      Break;
    try
      ApplyTagEventSnapshot(lSnapshot);
      Inc(fDiagDataEvents);
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
    end;
  end;

  UpdateTimeView;
  LogUpdateDiagnostics;
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
    fUiUpdateTimer.Interval, fRunSettings.DataUpdateMs]));
  fDiagLastLogTickMs := lNowMs;
  fDiagUiTicks := 0;
  fDiagDataEvents := 0;
  fDiagRenderCount := 0;
end;

procedure TMainForm.ApplyTagEventSnapshot(ASnapshot: TRecorderEventSnapshot);
begin
  if (ASnapshot = nil) or (not ASnapshot.HasTagData) then
    Exit;

  fLatestTagValues.Values[ASnapshot.TagName] :=
    FormatFloat('0.000', ASnapshot.Value);
  fTimeSystem.UpdateFromTagSample(ASnapshot.TimeSec);
end;

{ Инициализация графических кнопок панели управления сбором }
procedure TMainForm.SetupCommandButtons;
begin
  btnAddPage.Caption := '[]';
  btnAddPage.Hint := 'Formulars';
  btnAddPage.ShowHint := True;

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
  btnSaveConfig.ShowHint := True;

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
  case ANewState of
    rsPreview, rsRecord:
      begin
        if not (AOldState in [rsPreview, rsRecord]) then
          fTimeSystem.Start;
        StartDataSources;
      end;
    rsStop:
      begin
        StopDataSources;
        fTimeSystem.Stop;
      end;
  end;

  UpdateStateView;
  AddLog(Format('State changed: %s -> %s',
    [TRecorderStateMachine.StateToString(AOldState),
     TRecorderStateMachine.StateToString(ANewState)]));
end;

end.
