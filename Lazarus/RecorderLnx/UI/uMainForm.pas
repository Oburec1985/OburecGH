unit uMainForm;

{
  Модуль uMainForm

  Назначение:
    Главная форма RecorderLnx на раннем этапе разработки. Компоновка следует
    рабочему окну Recorder: сверху активные формуляры, в центре область
    формуляра, справа пульт состояния/команд, поиск и список тегов.

  Место в архитектуре:
    UI shell. Форма вызывает готовые core-модели TRecorderStateMachine и
    TRecorderRunControlSettings, но не содержит логики сбора данных, каналов,
    устройств, плагинов или записи.

  Ограничения:
    Список тегов и центральный формуляр пока являются заглушками. Подробная
    настройка открывается отдельной командой и будет расширяться после появления
    следующих core-моделей.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, Buttons, ImgList, ComCtrls, Spin, Math, TAGraph, TASeries,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderFormModel,
  uRecorderCoreServices, uRecorderTags, uRecorderDataSources,
  uRecorderEventQueue, uRecorderTimeSystem, uRecorderUiTestData, uFormPagesDialog,
  uFormEditorController, uRecorderSettingsDialog, uTagSettingsDialog,
  uRecorderCommandImages, uRecorderProjectFiles;

type
  { TMainForm }

  TMainForm = class(TForm)
    btnAddPage: TButton;
    btnClearSearch: TButton;
    btnPreview: TSpeedButton;
    btnRecord: TSpeedButton;
    btnSaveConfig: TSpeedButton;
    btnSettings: TSpeedButton;
    btnStop: TSpeedButton;
    btnTrigger: TSpeedButton;
    edTagSearch: TEdit;
    ilCommandButtons: TImageList;
    ilCommandButtons1: TImageList;
    ilTagDialogButtons: TImageList;
    lbState: TLabel;
    lbTags: TListBox;
    lbTime: TLabel;
    mmLog: TMemo;
    pnMain: TPanel;
    pnRight: TPanel;
    pnRightCommands: TPanel;
    pnRightStatus: TPanel;
    pnTagSearch: TPanel;
    pnToolbar: TPanel;
    sgFormular: TStringGrid;
    SplitterLog: TSplitter;
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
    procedure lbTagsDblClick(Sender: TObject);
    procedure sgFormularSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    fComponentFactory: TRecorderComponentFactory;
    fFormFactory: TRecorderFormFactory;
    fFormManager: TRecorderFormManager;
    fNextComponentNo: Integer;
    fNextPageNo: Integer;
    fEditorCanvas: TPanel;
    fEditorShell: TPanel;
    fEditorToolbar: TPanel;
    fFormEditor: TFormEditorController;
    fEditModeButton: TSpeedButton;
    fAddOscillogramButton: TSpeedButton;
    fAddTextButton: TSpeedButton;
    fAddSpectrumButton: TSpeedButton;
    fAddDigitalButton: TSpeedButton;
    fAddTagTableButton: TSpeedButton;
    fAddButtonButton: TSpeedButton;
    fAddComboBoxButton: TSpeedButton;
    fDeleteComponentButton: TSpeedButton;
    fBaseToolbar: TPanel;
    fBaseChartsPanel: TPanel;
    fOscillogramCountEdit: TSpinEdit;
    fPageControl: TPageControl;
    fSelectedComponentRow: Integer;
    fSyncingPages: Boolean;
    fStateMachine: TRecorderStateMachine;
    fRunSettings: TRecorderRunControlSettings;
    fEventBus: TRecorderEventBus;
    fTagRegistry: TRecorderTagRegistry;
    fEventQueue: TRecorderEventSnapshotQueue;
    fTimeSystem: TRecorderTimeSystem;
    fDataSourceManager: TRecorderDataSourceManager;
    fLatestTagValues: TStringList;
    fUiUpdateTimer: TTimer;
    fDataSourcesConfigured: Boolean;
    fProjectConfigDir: string;
    fRunControlFileName: string;

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

    { Рисует встроенную базовую страницу с таблицей осциллограмм. }
    procedure RenderBasePage;
    function FormatTagEstimate(ATag: TRecorderTag;
      AKind: TRecorderTagEstimateKind): string;

    { Перестраивает набор осциллограмм на базовой странице. }
    procedure RebuildBaseOscillograms(ACount: Integer);
    procedure RefreshBaseOscillograms;

    { Создает одну тестовую осциллограмму на базе стандартного TChart. }
    function CreateOscillogramChart(AIndex: Integer): TChart;
    procedure FillOscillogramChart(AChart: TChart; ATag: TRecorderTag);

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

    { Обработчик кнопки добавления цифрового индикатора на полотне. }
    procedure AddDigitalIndicatorClick(Sender: TObject);

    { Переключает режим редактирования мнемосхемы. }
    procedure EditModeClick(Sender: TObject);

    { Создает dev-структуру config/projects/default и дефолтный run-control.ini. }
    procedure EnsureDevConfig;

    { Возвращает базовый каталог проекта для dev-конфигурации.

      При запуске из Lazarus рабочий каталог обычно равен каталогу проекта.
      При запуске exe из lib/x86_64-win64 поднимаемся на два уровня выше.
    }
    function GetDevProjectDir: string;

    { Возвращает активную страницу для контроллера редактора мнемосхем. }
    function GetActiveEditorPage: TRecorderFormPage;

    { Вызывается контроллером после изменения layout активной мнемосхемы. }
    procedure FormEditorChanged;

    { Заполняет центральный формуляр и список тегов временными демонстрационными данными. }
    { Загружает настройки запуска/остановки из проектного каталога. }
    procedure LoadRunSettings;

    { Сохраняет настройки запуска/остановки в проектный каталог. }
    procedure SaveRunSettings;
    procedure LoadProjectPackage;
    procedure SaveProjectPackage;
    procedure ResetProjectCounters;

    { Применяет фильтр поиска к списку тегов-заглушек. }
    procedure RebuildTagList(const AFilter: string);
    procedure CollectSelectedTags(ATags: TList);
    procedure OpenSelectedTagSettings;

    { Создает отладочный источник MemTag и подключает его к общему registry.

      Источник нужен как первый живой канал данных: worker-thread пишет в тег,
      а UI получает обновления через очередь снимков событий. }
    procedure EnsureDemoDataSources;

    { Запускает worker-thread источников данных для режимов View/Record. }
    procedure StartDataSources;

    { Останавливает worker-thread источников данных и дочитывает очередь. }
    procedure StopDataSources;

    { Вычитывает очередь снимков событий в UI thread и обновляет отображение. }
    procedure DrainUiEventQueue(Sender: TObject);

    { Применяет один снимок события обновления тега к UI-модели значений. }
    procedure ApplyTagEventSnapshot(ASnapshot: TRecorderEventSnapshot);

    { Настраивает командные кнопки правого пульта как кнопки-символы. }
    procedure SetupCommandButtons;

    { Обновляет текстовый индикатор состояния из fStateMachine.State. }
    procedure UpdateStateView;

    { Updates the status-display time text from TRecorderTimeSystem. }
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
  EnsureDevConfig;
  InitializeFormPages;
  LoadRunSettings;
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

procedure TMainForm.lbTagsDblClick(Sender: TObject);
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
begin
  mmLog.Lines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AMessage);
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

procedure TMainForm.EnsureEditorSurface;
var
  lButton: TSpeedButton;
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

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 4;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconEditForm;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Edit mnemonic';
  lButton.ShowHint := True;
  lButton.GroupIndex := 1;
  lButton.AllowAllUp := True;
  lButton.OnClick := @EditModeClick;
  fEditModeButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 38;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconOscillogram;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add oscillogram';
  lButton.ShowHint := True;
  lButton.Enabled := False;
  fAddOscillogramButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 72;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconTextLabel;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add text label';
  lButton.ShowHint := True;
  lButton.OnClick := @btnAddComponentClick;
  fAddTextButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 106;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconSpectrum;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add spectrum';
  lButton.ShowHint := True;
  lButton.Enabled := False;
  fAddSpectrumButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 140;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconDigitalIndicator;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add digital indicator';
  lButton.ShowHint := True;
  lButton.OnClick := @AddDigitalIndicatorClick;
  fAddDigitalButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 174;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconTagTable;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add tag table';
  lButton.ShowHint := True;
  lButton.Enabled := False;
  fAddTagTableButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 208;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconButton;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add button';
  lButton.ShowHint := True;
  lButton.Enabled := False;
  fAddButtonButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 242;
  lButton.Top := 4;
  lButton.Width := 30;
  lButton.Height := 24;
  lButton.Caption := '';
  lButton.Images := ilCommandButtons;
  lButton.ImageIndex := CIconComboBox;
  lButton.ImageWidth := 20;
  lButton.Hint := 'Add combo box';
  lButton.ShowHint := True;
  lButton.Enabled := False;
  fAddComboBoxButton := lButton;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 282;
  lButton.Top := 4;
  lButton.Width := 24;
  lButton.Height := 24;
  lButton.Caption := '-';
  lButton.Hint := 'Delete selected component';
  lButton.ShowHint := True;
  lButton.OnClick := @btnDeleteComponentClick;
  fDeleteComponentButton := lButton;

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

procedure TMainForm.RenderDigitalPage;
var
  I: Integer;
  J: TRecorderTagEstimateKind;
  lFirstTagRow: Boolean;
  lRow: Integer;
  lRowCount: Integer;
  lTag: TRecorderTag;

  function EnabledEstimateCount(ATag: TRecorderTag): Integer;
  var
    lKind: TRecorderTagEstimateKind;
  begin
    Result := 0;
    if ATag = nil then
      Exit;

    for lKind := tekMean to tekPeakToPeakByRmsDeviation do
      if ATag.EstimateSettings.EnabledKinds[lKind] then
        Inc(Result);
  end;
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(False);
  sgFormular.Visible := True;
  sgFormular.Align := alClient;

  { Digital form follows per-tag estimate settings: one grid row is created
    only for each estimate enabled on the tag's "Additional" tab. }
  lRowCount := 1;
  for I := 0 to fTagRegistry.TagCount - 1 do
    Inc(lRowCount, EnabledEstimateCount(fTagRegistry.Tags[I]));
  if lRowCount < 2 then
    lRowCount := 2;

  sgFormular.ColCount := 6;
  sgFormular.RowCount := lRowCount;
  sgFormular.FixedCols := 0;
  sgFormular.FixedRows := 1;
  sgFormular.Cells[0, 0] := 'Name';
  sgFormular.Cells[1, 0] := 'Estimate';
  sgFormular.Cells[2, 0] := 'Address';
  sgFormular.Cells[3, 0] := 'Unit';
  sgFormular.Cells[4, 0] := 'Value';
  sgFormular.Cells[5, 0] := 'Description';

  lRow := 1;

  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    lFirstTagRow := True;
    for J := tekMean to tekPeakToPeakByRmsDeviation do
    begin
      if not lTag.EstimateSettings.EnabledKinds[J] then
        Continue;

      if lFirstTagRow then
      begin
        sgFormular.Cells[0, lRow] := lTag.Name;
        sgFormular.Cells[2, lRow] := lTag.Address;
        sgFormular.Cells[5, lRow] := lTag.Description;
        lFirstTagRow := False;
      end
      else
      begin
        sgFormular.Cells[0, lRow] := '';
        sgFormular.Cells[2, lRow] := '';
        sgFormular.Cells[5, lRow] := '';
      end;

      sgFormular.Cells[1, lRow] := RecorderTagEstimateKindToShortName(J);
      sgFormular.Cells[3, lRow] := lTag.UnitName;
      sgFormular.Cells[4, lRow] := FormatTagEstimate(lTag, J);
      Inc(lRow);
    end;
  end;
end;

function TMainForm.FormatTagEstimate(ATag: TRecorderTag;
  AKind: TRecorderTagEstimateKind): string;
var
  lEstimate: TRecorderTagEstimate;
begin
  Result := '-';
  if ATag = nil then
    Exit;

  lEstimate := ATag.Estimate(AKind);
  if lEstimate.Valid then
    Result := FormatFloat('0.000', lEstimate.Value);
end;

procedure TMainForm.RenderBasePage;
var
  lCount: Integer;
begin
  ShowEditorSurface(False);
  ShowBaseToolbar(True);
  sgFormular.Visible := False;

  if fOscillogramCountEdit <> nil then
    lCount := fOscillogramCountEdit.Value
  else
    lCount := 1;

  RebuildBaseOscillograms(lCount);
end;

procedure TMainForm.RebuildBaseOscillograms(ACount: Integer);
var
  I: Integer;
  lChart: TChart;
  lRow: Integer;
  lCol: Integer;
  lRows: Integer;
  lCols: Integer;
  lLeft: Integer;
  lTop: Integer;
  lWidth: Integer;
  lHeight: Integer;
  lCellHeight: Integer;
  lItemsInRow: Integer;
  lRowCellWidth: Integer;
begin
  EnsureBaseToolbar;
  if ACount < 1 then
    ACount := 1;

  while fBaseChartsPanel.ControlCount > 0 do
    fBaseChartsPanel.Controls[0].Free;

  lRows := Max(1, Round(Sqrt(ACount)));
  lCols := Ceil(ACount / lRows);
  lCellHeight := Max(1, fBaseChartsPanel.ClientHeight div lRows);

  for I := 0 to ACount - 1 do
  begin
    lRow := I div lCols;
    lCol := I mod lCols;
    lItemsInRow := Min(lCols, ACount - lRow * lCols);
    lRowCellWidth := Max(1, fBaseChartsPanel.ClientWidth div lItemsInRow);
    lLeft := lCol * lRowCellWidth;
    lTop := lRow * lCellHeight;
    lWidth := lRowCellWidth;
    lHeight := lCellHeight;

    if lCol = lItemsInRow - 1 then
      lWidth := fBaseChartsPanel.ClientWidth - lLeft;
    if lRow = lRows - 1 then
      lHeight := fBaseChartsPanel.ClientHeight - lTop;

    lChart := CreateOscillogramChart(I);
    lChart.Parent := fBaseChartsPanel;
    lChart.SetBounds(lLeft, lTop, lWidth, lHeight);
    lChart.Anchors := [akLeft, akTop];
  end;
end;

procedure TMainForm.RefreshBaseOscillograms;
var
  I: Integer;
  lChart: TChart;
  lTag: TRecorderTag;
begin
  if (fBaseChartsPanel = nil) or (fTagRegistry = nil) then
    Exit;

  for I := 0 to fBaseChartsPanel.ControlCount - 1 do
    if fBaseChartsPanel.Controls[I] is TChart then
    begin
      lChart := TChart(fBaseChartsPanel.Controls[I]);
      if fTagRegistry.TagCount > 0 then
        lTag := fTagRegistry.Tags[I mod fTagRegistry.TagCount]
      else
        lTag := nil;
      FillOscillogramChart(lChart, lTag);
    end;
end;

function TMainForm.CreateOscillogramChart(AIndex: Integer): TChart;
var
  lSeries: TLineSeries;
  lTag: TRecorderTag;
begin
  Result := TChart.Create(Self);
  Result.BorderStyle := bsSingle;
  Result.Title.Visible := True;
  Result.Legend.Visible := False;
  Result.LeftAxis.Grid.Visible := True;
  Result.BottomAxis.Grid.Visible := True;
  Result.BottomAxis.Title.Caption := 't, s';
  Result.LeftAxis.Range.UseMin := True;
  Result.LeftAxis.Range.UseMax := True;
  Result.BottomAxis.Range.UseMin := True;
  Result.BottomAxis.Range.UseMax := True;

  lSeries := TLineSeries.Create(Result);
  lSeries.SeriesColor := clBlue;
  Result.AddSeries(lSeries);

  if fTagRegistry.TagCount > 0 then
    lTag := fTagRegistry.Tags[AIndex mod fTagRegistry.TagCount]
  else
    lTag := nil;
  FillOscillogramChart(Result, lTag);
end;

procedure TMainForm.FillOscillogramChart(AChart: TChart; ATag: TRecorderTag);
var
  I: Integer;
  lMaxValue: Double;
  lMinValue: Double;
  lSeries: TLineSeries;
  lSnapshot: TRecorderSignalSnapshot;
begin
  if AChart = nil then
    Exit;

  if AChart.SeriesCount = 0 then
  begin
    lSeries := TLineSeries.Create(AChart);
    AChart.AddSeries(lSeries);
  end
  else
    lSeries := TLineSeries(AChart.Series[0]);

  lSeries.Clear;
  if ATag = nil then
  begin
    AChart.Title.Text.Text := 'No tag';
    AChart.BottomAxis.Range.Min := 0;
    AChart.BottomAxis.Range.Max := 1;
    AChart.LeftAxis.Range.Min := -1;
    AChart.LeftAxis.Range.Max := 1;
    Exit;
  end;

  lSnapshot := ATag.Snapshot;
  AChart.Title.Text.Text := ATag.Name;
  if lSnapshot.Count = 0 then
  begin
    AChart.BottomAxis.Range.Min := 0;
    AChart.BottomAxis.Range.Max := 1;
    AChart.LeftAxis.Range.Min := -1;
    AChart.LeftAxis.Range.Max := 1;
    Exit;
  end;

  lMinValue := lSnapshot.Values[0];
  lMaxValue := lSnapshot.Values[0];
  for I := 0 to lSnapshot.Count - 1 do
  begin
    lSeries.AddXY(lSnapshot.Times[I], lSnapshot.Values[I]);
    if lSnapshot.Values[I] < lMinValue then
      lMinValue := lSnapshot.Values[I];
    if lSnapshot.Values[I] > lMaxValue then
      lMaxValue := lSnapshot.Values[I];
  end;

  AChart.BottomAxis.Range.Min := lSnapshot.Times[0];
  AChart.BottomAxis.Range.Max := lSnapshot.Times[lSnapshot.Count - 1];
  if AChart.BottomAxis.Range.Min = AChart.BottomAxis.Range.Max then
    AChart.BottomAxis.Range.Max := AChart.BottomAxis.Range.Min + 1.0;

  if lMinValue = lMaxValue then
  begin
    AChart.LeftAxis.Range.Min := lMinValue - 1.0;
    AChart.LeftAxis.Range.Max := lMaxValue + 1.0;
  end
  else
  begin
    AChart.LeftAxis.Range.Min := lMinValue - Abs(lMaxValue - lMinValue) * 0.05;
    AChart.LeftAxis.Range.Max := lMaxValue + Abs(lMaxValue - lMinValue) * 0.05;
  end;
end;

procedure TMainForm.RenderMnemonicPage(APage: TRecorderFormPage);
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(True);
  if fFormEditor <> nil then
    fFormEditor.Render;
end;

procedure TMainForm.RenderBuiltInPage(APage: TRecorderFormPage);
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(False);
  sgFormular.Visible := True;
  sgFormular.Align := alClient;
  FillPlaceholderFormular(sgFormular);
end;

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
    RenderBasePage;
end;

procedure TMainForm.BaseChartsPanelResize(Sender: TObject);
begin
  if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.Id = 'BasePage') and
    (fOscillogramCountEdit <> nil) then
    RebuildBaseOscillograms(fOscillogramCountEdit.Value);
end;

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
  { Layout already lives in the active TRecorderFormPage model. }
end;

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

procedure TMainForm.EnsureDemoDataSources;
var
  I: Integer;
  lFileIndex: Integer;
  lFileName: string;
  lFiles: TStringList;
  lSource: IRecorderDataSource;
  lTag: TRecorderTag;
  lTagNames: TStringList;
const
  CMeraSourcePrefix = 'Mera file: ';
begin
  if fDataSourcesConfigured then
    Exit;

  fDataSourceManager.Clear;

  lSource := TMockSineDataSource.Create('debug.memtag', 'MemTag', 250,
    100.0, 0.25);
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
        lFiles[I], 100, lTagNames);
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
  fDataSourcesConfigured := True;
  AddLog('Demo data source configured: debug.memtag -> MemTag.');
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

procedure TMainForm.DrainUiEventQueue(Sender: TObject);
var
  lChanged: Boolean;
  lSnapshot: TRecorderEventSnapshot;
begin
  lChanged := False;
  repeat
    lSnapshot := fEventQueue.Pop;
    if lSnapshot = nil then
      Break;
    try
      ApplyTagEventSnapshot(lSnapshot);
      lChanged := True;
    finally
      lSnapshot.Free;
    end;
  until False;

  if lChanged then
  begin
    RebuildTagList(edTagSearch.Text);
    if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
      (fFormManager.ActivePage.Id = 'DigitalForm') then
      RenderDigitalPage
    else if (fFormManager <> nil) and (fFormManager.ActivePage <> nil) and
      (fFormManager.ActivePage.Id = 'BasePage') then
      RefreshBaseOscillograms;
  end;

  UpdateTimeView;
end;

procedure TMainForm.ApplyTagEventSnapshot(ASnapshot: TRecorderEventSnapshot);
begin
  if (ASnapshot = nil) or (not ASnapshot.HasTagData) then
    Exit;

  fLatestTagValues.Values[ASnapshot.TagName] :=
    FormatFloat('0.000', ASnapshot.Value);
  fTimeSystem.UpdateFromTagSample(ASnapshot.TimeSec);
end;

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
