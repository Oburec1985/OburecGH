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
  Grids, Buttons, ImgList, ComCtrls,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderFormModel,
  uRecorderUiTestData, uFormPagesDialog;

type
  { TMainForm }

  TMainForm = class(TForm)
    btnActiveForm: TButton;
    btnAddComponent: TButton;
    btnAddPage: TButton;
    btnAutoForm: TButton;
    btnBaseForm: TButton;
    btnClearSearch: TButton;
    btnDeleteComponent: TButton;
    btnPreview: TSpeedButton;
    btnRecord: TSpeedButton;
    btnSaveConfig: TSpeedButton;
    btnSettings: TSpeedButton;
    btnStop: TSpeedButton;
    btnTrigger: TSpeedButton;
    edTagSearch: TEdit;
    ilCommandButtons: TImageList;
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
    procedure btnPageClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnRecordClick(Sender: TObject);
    procedure btnSaveConfigClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnTriggerClick(Sender: TObject);
    procedure edTagSearchChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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

    { Создает верхний PageControl формуляров. Фиксированные кнопки .lfm остаются
      только как ранняя дизайнерская заготовка и скрываются при запуске. }
    procedure EnsurePageControl;

    { Реагирует на выбор вкладки формуляра пользователем. }
    procedure PageControlChange(Sender: TObject);

    { Отображает компоненты активной страницы в центральной таблице. }
    procedure RenderActivePage;

    { Создает раннюю область редактора мнемосхемы с тулбаром и пустым полотном. }
    procedure EnsureEditorSurface;

    { Переключает центральную область между табличным просмотром модели и
      заготовкой редактора мнемосхемы. }
    procedure ShowEditorSurface(AVisible: Boolean);

    { Добавляет на активную страницу модельный компонент TagValue. }
    procedure AddTagValueComponentToActivePage;

    { Создает dev-структуру config/projects/default и дефолтный run-control.ini. }
    procedure EnsureDevConfig;

    { Возвращает базовый каталог проекта для dev-конфигурации.

      При запуске из Lazarus рабочий каталог обычно равен каталогу проекта.
      При запуске exe из lib/x86_64-win64 поднимаемся на два уровня выше.
    }
    function GetDevProjectDir: string;

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

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'RecorderLnx - config/projects/default';

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
  InitializeFormPages;
  RebuildTagList('');
  EnsureDevConfig;
  LoadRunSettings;
  UpdateStateView;
  AddLog('RecorderLnx started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fFormManager);
  FreeAndNil(fFormFactory);
  FreeAndNil(fComponentFactory);
  FreeAndNil(fRunSettings);
  FreeAndNil(fStateMachine);
end;

procedure TMainForm.sgFormularSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if aRow > 0 then
    fSelectedComponentRow := aRow
  else
    fSelectedComponentRow := -1;
end;

procedure TMainForm.btnPageClick(Sender: TObject);
var
  lPageIndex: Integer;
begin
  if not (Sender is TButton) then
    Exit;

  lPageIndex := TButton(Sender).Tag;
  if (lPageIndex < 0) or (lPageIndex >= fFormManager.PageCount) then
    Exit;

  fFormManager.SetActivePageById(fFormManager.Pages[lPageIndex].Id);
  RefreshPageButtons;
  RenderActivePage;
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
    AddTagValueComponentToActivePage;
    RenderActivePage;
  except
    on E: Exception do
      LogCommandError('Add component', E);
  end;
end;

procedure TMainForm.btnDeleteComponentClick(Sender: TObject);
var
  lPage: TRecorderFormPage;
  lComponentIndex: Integer;
  lComponentId: string;
begin
  try
    lPage := fFormManager.ActivePage;
    if lPage = nil then
      Exit;

    lComponentIndex := fSelectedComponentRow - 1;
    if (lComponentIndex < 0) or (lComponentIndex >= lPage.ComponentCount) then
      Exit;

    lComponentId := lPage.Components[lComponentIndex].Id;
    lPage.DeleteComponent(lComponentIndex);
    fSelectedComponentRow := -1;
    AddLog('Form component deleted: ' + lComponentId);
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
  AddTagValueComponentToActivePage;

  Inc(fNextPageNo);
  AddPageToModel('BasePage', 'Base page');

  Inc(fNextPageNo);
  AddPageToModel('Automatic', 'Automatic');

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

  btnActiveForm.Visible := False;
  btnBaseForm.Visible := False;
  btnAutoForm.Visible := False;

  fPageControl := TPageControl.Create(Self);
  fPageControl.Parent := pnToolbar;
  fPageControl.Left := 66;
  fPageControl.Top := 4;
  fPageControl.Width := 390;
  fPageControl.Height := 38;
  fPageControl.Anchors := [akLeft, akTop, akRight];
  fPageControl.TabOrder := 0;
  fPageControl.OnChange := @PageControlChange;

  btnAddComponent.Left := fPageControl.Left + fPageControl.Width + 28;
  btnDeleteComponent.Left := btnAddComponent.Left + btnAddComponent.Width + 6;
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

  btnAddComponent.Enabled := fFormManager.ActivePage <> nil;
  btnDeleteComponent.Enabled := (fFormManager.ActivePage <> nil) and
    (fFormManager.ActivePage.ComponentCount > 0);
end;

procedure TMainForm.RenderActivePage;
var
  lPage: TRecorderFormPage;
  I: Integer;
  lComponent: TRecorderVisualComponent;
  lBounds: TRecorderRect;
begin
  lPage := fFormManager.ActivePage;
  fSelectedComponentRow := -1;

  sgFormular.ColCount := 6;
  sgFormular.FixedRows := 1;
  sgFormular.Cells[0, 0] := 'Type';
  sgFormular.Cells[1, 0] := 'Id';
  sgFormular.Cells[2, 0] := 'Name';
  sgFormular.Cells[3, 0] := 'Tag';
  sgFormular.Cells[4, 0] := 'Bounds';
  sgFormular.Cells[5, 0] := 'Text/Format';

  if lPage = nil then
  begin
    ShowEditorSurface(False);
    sgFormular.RowCount := 1;
    Caption := 'RecorderLnx - config/projects/default';
    Exit;
  end;

  Caption := 'RecorderLnx - config/projects/default - ' + lPage.Title;
  ShowEditorSurface(lPage.ComponentCount = 0);
  if fEditorShell.Visible then
  begin
    RefreshPageButtons;
    Exit;
  end;

  sgFormular.RowCount := lPage.ComponentCount + 1;

  for I := 0 to lPage.ComponentCount - 1 do
  begin
    lComponent := lPage.Components[I];
    lBounds := lComponent.Bounds;
    sgFormular.Cells[0, I + 1] := lComponent.TypeId;
    sgFormular.Cells[1, I + 1] := lComponent.Id;
    sgFormular.Cells[2, I + 1] := lComponent.Name;
    sgFormular.Cells[3, I + 1] := lComponent.TagName;
    sgFormular.Cells[4, I + 1] := Format('%d,%d %dx%d',
      [lBounds.Left, lBounds.Top, lBounds.Width, lBounds.Height]);

    if lComponent is TRecorderStaticTextComponent then
      sgFormular.Cells[5, I + 1] := TRecorderStaticTextComponent(lComponent).Text
    else if lComponent is TRecorderTagValueComponent then
      sgFormular.Cells[5, I + 1] := TRecorderTagValueComponent(lComponent).DisplayFormat
    else
      sgFormular.Cells[5, I + 1] := '';
  end;

  RefreshPageButtons;
end;

procedure TMainForm.AddTagValueComponentToActivePage;
var
  lPage: TRecorderFormPage;
  lComponent: TRecorderTagValueComponent;
begin
  lPage := fFormManager.ActivePage;
  if lPage = nil then
    raise ERecorderFormError.Create('Cannot add component without active page');

  Inc(fNextComponentNo);
  lComponent := TRecorderTagValueComponent(
    fComponentFactory.CreateComponent(TRecorderTagValueComponent.TypeId));
  try
    lComponent.Id := Format('%s.component%d', [lPage.Id, fNextComponentNo]);
    lComponent.Name := Format('TagValue%d', [fNextComponentNo]);
    lComponent.TagName := 'MemTag';
    lComponent.SetBounds(8, 8 + lPage.ComponentCount * 28, 160, 24);
    lPage.AddComponent(lComponent);
  except
    lComponent.Free;
    raise;
  end;

  AddLog('Form component added: ' + lComponent.Id);
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
  lButton.Width := 24;
  lButton.Height := 24;
  lButton.Caption := '\';
  lButton.Hint := 'Edit mnemonic';
  lButton.ShowHint := True;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 34;
  lButton.Top := 4;
  lButton.Width := 24;
  lButton.Height := 24;
  lButton.Caption := '+';
  lButton.Hint := 'Add component';
  lButton.ShowHint := True;
  lButton.OnClick := @btnAddComponentClick;

  lButton := TSpeedButton.Create(Self);
  lButton.Parent := fEditorToolbar;
  lButton.Left := 64;
  lButton.Top := 4;
  lButton.Width := 24;
  lButton.Height := 24;
  lButton.Caption := '-';
  lButton.Hint := 'Delete selected component';
  lButton.ShowHint := True;
  lButton.OnClick := @btnDeleteComponentClick;

  fEditorCanvas := TPanel.Create(Self);
  fEditorCanvas.Parent := fEditorShell;
  fEditorCanvas.Align := alClient;
  fEditorCanvas.BevelOuter := bvNone;
  fEditorCanvas.Color := clWhite;
  fEditorCanvas.ParentBackground := False;
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
