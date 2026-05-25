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
  uRecorderUiTestData, uFormPagesDialog, uFormEditorController;

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

    { Перестраивает набор осциллограмм на базовой странице. }
    procedure RebuildBaseOscillograms(ACount: Integer);

    { Создает одну тестовую осциллограмму на базе стандартного TChart. }
    function CreateOscillogramChart(AIndex: Integer): TChart;

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

    { Применяет фильтр поиска к списку тегов-заглушек. }
    procedure RebuildTagList(const AFilter: string);

    { Настраивает командные кнопки правого пульта как кнопки-символы. }
    procedure SetupCommandButtons;

    { Обновляет текстовый индикатор состояния из fStateMachine.State. }
    procedure UpdateStateView;

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
  CRunControlFileName = 'run-control.ini';
  CIconEditForm = 4;
  CIconOscillogram = 5;
  CIconTextLabel = 6;
  CIconSpectrum = 7;
  CIconDigitalIndicator = 8;
  CIconTagTable = 9;
  CIconButton = 10;
  CIconComboBox = 11;

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
  fComponentFactory := TRecorderComponentFactory.Create;
  fComponentFactory.RegisterDefaultComponents;
  fFormFactory := TRecorderFormFactory.Create(fComponentFactory);
  fFormManager := TRecorderFormManager.Create;
  fProjectConfigDir := IncludeTrailingPathDelimiter(GetDevProjectDir) +
    CDefaultProjectConfigDir;
  fRunControlFileName := IncludeTrailingPathDelimiter(fProjectConfigDir) + CRunControlFileName;

  SetupCommandButtons;
  EnsurePageControl;
  EnsureEditorSurface;
  EnsureBaseToolbar;
  fFormEditor := TFormEditorController.Create(fEditorCanvas, @GetActiveEditorPage);
  fFormEditor.OnChanged := @FormEditorChanged;
  InitializeFormPages;
  RebuildTagList('');
  EnsureDevConfig;
  LoadRunSettings;
  UpdateStateView;
  AddLog('RecorderLnx started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fFormEditor);
  FreeAndNil(fFormManager);
  FreeAndNil(fFormFactory);
  FreeAndNil(fComponentFactory);
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
    fFormEditor.ClearSelection;
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
          fFormEditor.ClearSelection;
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
    SaveRunSettings;
    AddLog('Project run-control config saved: ' + fRunControlFileName);
  except
    on E: Exception do
      LogCommandError('Save config', E);
  end;
end;

procedure TMainForm.btnSettingsClick(Sender: TObject);
begin
  AddLog('Settings dialog placeholder: detailed project settings will be added after core models.');
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
begin
  ShowBaseToolbar(False);
  ShowEditorSurface(False);
  sgFormular.Visible := True;
  sgFormular.Align := alClient;
  FillDigitalFormular(sgFormular);
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

function TMainForm.CreateOscillogramChart(AIndex: Integer): TChart;
var
  lSeries: TLineSeries;
  I: Integer;
  lX: Double;
  lName: string;
begin
  lName := Format('%d sensor %s', [AIndex div 3 + 1,
    Chr(Ord('X') + (AIndex mod 3))]);

  Result := TChart.Create(Self);
  Result.BorderStyle := bsSingle;
  Result.Title.Text.Text := lName;
  Result.Title.Visible := True;
  Result.Legend.Visible := False;
  Result.LeftAxis.Grid.Visible := True;
  Result.BottomAxis.Grid.Visible := True;
  Result.BottomAxis.Title.Caption := 'X';
  Result.LeftAxis.Range.UseMin := True;
  Result.LeftAxis.Range.UseMax := True;
  Result.LeftAxis.Range.Min := -32000;
  Result.LeftAxis.Range.Max := 32000;
  Result.BottomAxis.Range.UseMin := True;
  Result.BottomAxis.Range.UseMax := True;
  Result.BottomAxis.Range.Min := 0;
  Result.BottomAxis.Range.Max := 10;

  lSeries := TLineSeries.Create(Result);
  lSeries.SeriesColor := clBlue;
  for I := 0 to 100 do
  begin
    lX := I / 10;
    lSeries.AddXY(lX, Sin((lX + AIndex) * 1.2) * 12000);
  end;
  Result.AddSeries(lSeries);
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
begin
  if FileExists(fRunControlFileName) then
  begin
    fRunSettings.LoadFromFile(fRunControlFileName);
    AddLog('Project run-control config loaded: ' + fRunControlFileName);
  end;
end;

procedure TMainForm.SaveRunSettings;
begin
  ForceDirectories(fProjectConfigDir);
  fRunSettings.SaveToFile(fRunControlFileName);
end;

procedure TMainForm.RebuildTagList(const AFilter: string);
begin
  lbTags.Items.BeginUpdate;
  try
    FillPlaceholderTagList(lbTags.Items, AFilter);
  finally
    lbTags.Items.EndUpdate;
  end;
end;

procedure TMainForm.SetupCommandButtons;
begin
  btnAddPage.Caption := '[]';
  btnAddPage.Hint := 'Formulars';
  btnAddPage.ShowHint := True;

  btnSettings.Caption := '';
  btnSettings.Hint := 'Settings';
  btnSettings.ShowHint := True;

  btnSaveConfig.Caption := 'Save';
  btnSaveConfig.Hint := 'Save current config';
  btnSaveConfig.ShowHint := True;

  btnStop.Caption := '';
  btnStop.Hint := 'Stop';
  btnStop.ShowHint := True;

  btnPreview.Caption := '';
  btnPreview.Hint := 'View';
  btnPreview.ShowHint := True;

  btnRecord.Caption := '';
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
  lbTime.Caption := '00:00:00';

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

procedure TMainForm.LogCommandError(const ACommand: string; E: Exception);
begin
  AddLog(ACommand + ' failed: ' + E.Message);
end;

procedure TMainForm.StateMachineStateChanged(ASender: TObject;
  AOldState, ANewState: TRecorderState);
begin
  UpdateStateView;
  AddLog(Format('State changed: %s -> %s',
    [TRecorderStateMachine.StateToString(AOldState),
     TRecorderStateMachine.StateToString(ANewState)]));
end;

end.
