unit uRecorderSqlDbSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Spin, ComCtrls,
  LazUTF8, Math, uRecorderSqlDbTypes, uRecorderSqlDbRepository,
  uRecorderTags;

type
  TRecorderSqlDbSignalsDeletedEvent = procedure(ASignalNames: TStrings) of object;

  TRecorderSqlDbSettingsDialog = class(TForm)
    btnBrowse: TButton;
    btnCancel: TButton;
    btnOk: TButton;
    btnDeleteDbSignals: TButton;
    btnReadDbSignals: TButton;
    btnSweepDb: TButton;
    btnStartFirebird: TButton;
    btnTest: TButton;
    btnTestFirebird: TButton;
    btnSelectAll: TButton;
    btnSelectNone: TButton;
    btnAssignEstimate: TButton;
    cbBackend: TComboBox;
    cbControlTag: TComboBox;
    cbEnabled: TCheckBox;
    cbTls: TCheckBox;
    cbSignalEstimate: TComboBox;
    edDatabase: TEdit;
    edDbSignalSearch: TEdit;
    edHost: TEdit;
    edObjectName: TEdit;
    edObjectType: TEdit;
    edPasswordEnvironment: TEdit;
    edPassword: TEdit;
    edRoot: TEdit;
    edSignalSearch: TEdit;
    edSerial: TEdit;
    edUser: TEdit;
    gbConnection: TGroupBox;
    gbDbChannels: TGroupBox;
    gbObject: TGroupBox;
    gbSignals: TGroupBox;
    lvDbSignals: TListView;
    lblDbSignalSearch: TLabel;
    lvSignals: TListView;
    lblBackend: TLabel;
    lblControlTag: TLabel;
    lblDatabase: TLabel;
    lblHost: TLabel;
    lblObjectName: TLabel;
    lblObjectType: TLabel;
    lblPasswordEnvironment: TLabel;
    lblPassword: TLabel;
    lblPeriod: TLabel;
    lblPort: TLabel;
    lblQueue: TLabel;
    lblRoot: TLabel;
    lblSerial: TLabel;
    lblSignalSearch: TLabel;
    lblSignalEstimate: TLabel;
    lblUser: TLabel;
    sePeriod: TSpinEdit;
    sePort: TSpinEdit;
    seQueue: TSpinEdit;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnDeleteDbSignalsClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnReadDbSignalsClick(Sender: TObject);
    procedure btnSweepDbClick(Sender: TObject);
    procedure btnStartFirebirdClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnTestFirebirdClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
    procedure btnAssignEstimateClick(Sender: TObject);
    procedure cbBackendChange(Sender: TObject);
    procedure edDbSignalSearchChange(Sender: TObject);
    procedure edSignalSearchChange(Sender: TObject);
  private
    fAllSignals: TStringList;
    fCheckedSignals: TStringList;
    fConfig: TRecorderSqlDbConfig;
    fDbSignals: TRecorderSqlDbSignalInfos;
    fFileName: string;
    fChannelPages: TPageControl;
    fWriteSignalsTab: TTabSheet;
    fDbSignalsTab: TTabSheet;
    fOnSignalsDeleted: TRecorderSqlDbSignalsDeletedEvent;
    fRegistry: TRecorderTagRegistry;
    procedure BuildChannelPages;
    procedure LayoutDbChannelControls;
    procedure LayoutWriteSignalControls;
    procedure DbChannelsResize(Sender: TObject);
    procedure WriteSignalsResize(Sender: TObject);
    procedure LoadControls;
    procedure ApplySignalFilter;
    procedure ApplyDbSignalFilter;
    function DbSignalMatchesFilter(const AInfo: TRecorderSqlDbSignalInfo;
      const AFilter: string): Boolean;
    procedure FillDbSignalFallback(var AInfo: TRecorderSqlDbSignalInfo);
    procedure SyncVisibleSignalChecks;
    procedure StoreControls;
    procedure UpdateControls;
    function TryOpenCurrentDatabase(out AMessage: string): Boolean;
    function TryEnsureCurrentDatabase(out AMessage: string): Boolean;
    function TagIsScalar(ATag: TRecorderTag): Boolean;
    function EstimateText(ATag: TRecorderTag;
      AKind: TRecorderTagEstimateKind): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadConfig(const AFileName: string;
      ARegistry: TRecorderTagRegistry;
      AOnSignalsDeleted: TRecorderSqlDbSignalsDeletedEvent = nil);
  end;

function ShowRecorderSqlDbSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry;
  AOnSignalsDeleted: TRecorderSqlDbSignalsDeletedEvent = nil): Boolean;

implementation

uses
  uRecorderSqlDbFirebirdTools, uRecorderSqlDbProjectManager;

{$R *.lfm}

constructor TRecorderSqlDbSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BuildChannelPages;
  fAllSignals := TStringList.Create;
  fAllSignals.CaseSensitive := False;
  fCheckedSignals := TStringList.Create;
  fCheckedSignals.CaseSensitive := False;
  fCheckedSignals.Sorted := True;
  fCheckedSignals.Duplicates := dupIgnore;
end;

procedure TRecorderSqlDbSettingsDialog.BuildChannelPages;
begin
  fChannelPages := TPageControl.Create(Self);
  fChannelPages.Parent := Self;
  fChannelPages.SetBounds(gbSignals.Left, gbSignals.Top, gbSignals.Width,
    btnOk.Top - gbSignals.Top - 8);
  fChannelPages.Anchors := [akTop, akLeft, akRight, akBottom];
  fChannelPages.TabOrder := gbSignals.TabOrder;

  fWriteSignalsTab := TTabSheet.Create(Self);
  fWriteSignalsTab.PageControl := fChannelPages;
  fWriteSignalsTab.Caption := 'Теги для записи';

  fDbSignalsTab := TTabSheet.Create(Self);
  fDbSignalsTab.PageControl := fChannelPages;
  fDbSignalsTab.Caption := 'Каналы в БД';

  gbSignals.Parent := fWriteSignalsTab;
  gbSignals.Align := alClient;
  gbSignals.BorderSpacing.Around := 4;
  gbSignals.TabOrder := 0;
  gbSignals.OnResize := @WriteSignalsResize;
  LayoutWriteSignalControls;

  gbDbChannels.Parent := fDbSignalsTab;
  gbDbChannels.Align := alClient;
  gbDbChannels.BorderSpacing.Around := 4;
  gbDbChannels.TabOrder := 0;
  gbDbChannels.OnResize := @DbChannelsResize;
  LayoutDbChannelControls;

  fChannelPages.ActivePage := fWriteSignalsTab;
end;

procedure TRecorderSqlDbSettingsDialog.LayoutWriteSignalControls;
var
  lBottomTop, lEstimateTop: Integer;
begin
  if gbSignals = nil then Exit;

  cbControlTag.Width := Max(120, gbSignals.ClientWidth - 16);
  edSignalSearch.Width := Max(120, gbSignals.ClientWidth - edSignalSearch.Left - 8);

  lBottomTop := Max(150, gbSignals.ClientHeight - btnSelectAll.Height - 8);
  lEstimateTop := Max(110, lBottomTop - cbSignalEstimate.Height - 28);

  lvSignals.SetBounds(8, lvSignals.Top, Max(120, gbSignals.ClientWidth - 16),
    Max(80, lEstimateTop - lvSignals.Top - 6));
  lvSignals.Anchors := [akTop, akLeft, akRight, akBottom];

  lblSignalEstimate.Top := lEstimateTop + 6;
  cbSignalEstimate.Top := lEstimateTop;
  btnAssignEstimate.Top := lEstimateTop;
  btnAssignEstimate.Left := Max(8, gbSignals.ClientWidth -
    btnAssignEstimate.Width - 8);
  cbSignalEstimate.Width := Max(120,
    btnAssignEstimate.Left - cbSignalEstimate.Left - 8);

  btnSelectAll.Top := lBottomTop;
  btnSelectNone.Top := lBottomTop;
  btnSelectAll.Width := Max(100, (gbSignals.ClientWidth - 24) div 2);
  btnSelectNone.Left := btnSelectAll.Left + btnSelectAll.Width + 8;
  btnSelectNone.Width := Max(100,
    gbSignals.ClientWidth - btnSelectNone.Left - 8);
end;

procedure TRecorderSqlDbSettingsDialog.LayoutDbChannelControls;
var
  lButtonTop: Integer;
begin
  if gbDbChannels = nil then Exit;

  lblDbSignalSearch.SetBounds(12, 20, 50, lblDbSignalSearch.Height);
  edDbSignalSearch.SetBounds(70, 15,
    Max(120, gbDbChannels.ClientWidth - 82), edDbSignalSearch.Height);
  edDbSignalSearch.Anchors := [akTop, akLeft, akRight];

  lButtonTop := Max(56, gbDbChannels.ClientHeight - 40);
  btnReadDbSignals.SetBounds(12, lButtonTop, 150, btnReadDbSignals.Height);
  btnDeleteDbSignals.SetBounds(170, lButtonTop, 150,
    btnDeleteDbSignals.Height);
  btnSweepDb.SetBounds(328, lButtonTop, 150, btnSweepDb.Height);
  btnReadDbSignals.Anchors := [akLeft, akBottom];
  btnDeleteDbSignals.Anchors := [akLeft, akBottom];
  btnSweepDb.Anchors := [akLeft, akBottom];

  lvDbSignals.SetBounds(12, 52, Max(120, gbDbChannels.ClientWidth - 24),
    Max(80, lButtonTop - 62));
  lvDbSignals.Anchors := [akTop, akLeft, akRight, akBottom];
end;

procedure TRecorderSqlDbSettingsDialog.DbChannelsResize(Sender: TObject);
begin
  LayoutDbChannelControls;
end;

procedure TRecorderSqlDbSettingsDialog.WriteSignalsResize(Sender: TObject);
begin
  LayoutWriteSignalControls;
end;

destructor TRecorderSqlDbSettingsDialog.Destroy;
begin
  fCheckedSignals.Free;
  fAllSignals.Free;
  SetLength(fDbSignals, 0);
  fConfig.Free;
  inherited Destroy;
end;

procedure TRecorderSqlDbSettingsDialog.LoadConfig(const AFileName: string;
  ARegistry: TRecorderTagRegistry;
  AOnSignalsDeleted: TRecorderSqlDbSignalsDeletedEvent);
begin
  fFileName := AFileName;
  fRegistry := ARegistry;
  fOnSignalsDeleted := AOnSignalsDeleted;
  FreeAndNil(fConfig);
  fConfig := TRecorderSqlDbConfig.Create;
  fConfig.LoadFromFile(AFileName);
  LoadControls;
end;

procedure TRecorderSqlDbSettingsDialog.LoadControls;
var
  I: Integer;
begin
  cbEnabled.Checked := fConfig.Enabled;
  cbBackend.ItemIndex := Ord(fConfig.Backend);
  if Trim(fConfig.RootDirectory) <> '' then
    edRoot.Text := fConfig.RootDirectory
  else
    edRoot.Text := RecorderSqlDbDefaultRootDirectory;
  edDatabase.Text := fConfig.Database;
  edHost.Text := fConfig.Host;
  sePort.Value := fConfig.Port;
  edUser.Text := fConfig.UserName;
  edPassword.Text := fConfig.StoredPassword;
  edPasswordEnvironment.Text := fConfig.PasswordEnvironment;
  cbTls.Checked := fConfig.TlsRequired;
  seQueue.Value := fConfig.QueueCapacity;
  sePeriod.Value := Max(1, (fConfig.RecordPeriodMs + 999) div 1000);
  edObjectName.Text := fConfig.ObjectName;
  edObjectType.Text := fConfig.ObjectType;
  edSerial.Text := fConfig.SerialNumber;
  cbControlTag.Items.BeginUpdate;
  try
    cbControlTag.Items.Clear;
    cbControlTag.Items.Add('(нет)');
    if fRegistry <> nil then
      for I := 0 to fRegistry.TagCount - 1 do
        cbControlTag.Items.Add(fRegistry.Tags[I].Name);
    cbControlTag.ItemIndex := cbControlTag.Items.IndexOf(fConfig.ControlTagName);
    if cbControlTag.ItemIndex < 0 then cbControlTag.ItemIndex := 0;
  finally
    cbControlTag.Items.EndUpdate;
  end;
  edSignalSearch.Clear;
  cbSignalEstimate.Items.Clear;
  for I := Ord(Low(TRecorderTagEstimateKind)) to
    Ord(High(TRecorderTagEstimateKind)) do
    cbSignalEstimate.Items.Add(RecorderTagEstimateKindToName(
      TRecorderTagEstimateKind(I)));
  cbSignalEstimate.ItemIndex := Ord(tekMean);
  fAllSignals.Clear;
  fCheckedSignals.Clear;
  lvSignals.Clear;
  lvDbSignals.Clear;
  edDbSignalSearch.Clear;
  SetLength(fDbSignals, 0);
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      fAllSignals.AddObject(fRegistry.Tags[I].Name, fRegistry.Tags[I]);
      if not fConfig.SignalSelectionConfigured or
         (fConfig.SignalNames.IndexOf(fRegistry.Tags[I].Name) >= 0) then
        fCheckedSignals.Add(fRegistry.Tags[I].Name);
    end;
  ApplySignalFilter;
  ApplyDbSignalFilter;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.SyncVisibleSignalChecks;
var
  I, lCheckedIndex: Integer;
begin
  for I := 0 to lvSignals.Items.Count - 1 do
    if lvSignals.Items[I].Checked then
    begin
      if fCheckedSignals.IndexOf(lvSignals.Items[I].Caption) < 0 then
        fCheckedSignals.Add(lvSignals.Items[I].Caption);
    end
    else
    begin
      lCheckedIndex := fCheckedSignals.IndexOf(lvSignals.Items[I].Caption);
      if lCheckedIndex >= 0 then
        fCheckedSignals.Delete(lCheckedIndex);
    end;
end;

procedure TRecorderSqlDbSettingsDialog.ApplySignalFilter;
var
  I: Integer;
  lFilter, lName: string;
  lItem: TListItem;
  lTag: TRecorderTag;
  lKind: TRecorderTagEstimateKind;
begin
  lFilter := UTF8LowerCase(Trim(edSignalSearch.Text));
  lvSignals.Items.BeginUpdate;
  try
    lvSignals.Clear;
    for I := 0 to fAllSignals.Count - 1 do
    begin
      lName := fAllSignals[I];
      if (lFilter <> '') and
         (Pos(lFilter, UTF8LowerCase(lName)) = 0) then
        Continue;
      lTag := TRecorderTag(fAllSignals.Objects[I]);
      lKind := fConfig.SignalEstimate(lName);
      if TagIsScalar(lTag) then lKind := tekMean;
      lItem := lvSignals.Items.Add;
      lItem.Caption := lName;
      lItem.Data := lTag;
      lItem.Checked := fCheckedSignals.IndexOf(lName) >= 0;
      lItem.SubItems.Add(EstimateText(lTag, lKind));
    end;
  finally
    lvSignals.Items.EndUpdate;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.edSignalSearchChange(Sender: TObject);
begin
  SyncVisibleSignalChecks;
  ApplySignalFilter;
end;

function TRecorderSqlDbSettingsDialog.DbSignalMatchesFilter(
  const AInfo: TRecorderSqlDbSignalInfo; const AFilter: string): Boolean;
var
  lFilter: string;
begin
  lFilter := UTF8LowerCase(Trim(AFilter));
  Result := (lFilter = '') or
    (Pos(lFilter, UTF8LowerCase(AInfo.Name)) > 0) or
    (Pos(lFilter, UTF8LowerCase(AInfo.UnitName)) > 0) or
    (Pos(lFilter, UTF8LowerCase(AInfo.RecorderAddress)) > 0) or
    (Pos(lFilter, UTF8LowerCase(AInfo.RecorderSourceId)) > 0);
end;

procedure TRecorderSqlDbSettingsDialog.FillDbSignalFallback(
  var AInfo: TRecorderSqlDbSignalInfo);
var
  lTag: TRecorderTag;
begin
  if (fRegistry = nil) or (Trim(AInfo.Name) = '') then Exit;
  if (Trim(AInfo.UnitName) <> '') and (Trim(AInfo.RecorderAddress) <> '') and
    (Trim(AInfo.RecorderSourceId) <> '') then
    Exit;
  lTag := fRegistry.FindByName(AInfo.Name);
  if lTag = nil then Exit;
  if Trim(AInfo.UnitName) = '' then
    AInfo.UnitName := lTag.UnitName;
  if Trim(AInfo.RecorderAddress) = '' then
    AInfo.RecorderAddress := lTag.Address;
  if Trim(AInfo.RecorderSourceId) = '' then
    AInfo.RecorderSourceId := lTag.SourceId;
end;

procedure TRecorderSqlDbSettingsDialog.ApplyDbSignalFilter;
var
  I: Integer;
  lInfo: TRecorderSqlDbSignalInfo;
  lItem: TListItem;
begin
  lvDbSignals.Items.BeginUpdate;
  try
    lvDbSignals.Clear;
    for I := 0 to High(fDbSignals) do
    begin
      lInfo := fDbSignals[I];
      FillDbSignalFallback(lInfo);
      if not DbSignalMatchesFilter(lInfo, edDbSignalSearch.Text) then
        Continue;
      lItem := lvDbSignals.Items.Add;
      lItem.Caption := lInfo.Name;
      if lInfo.PointCount > 0 then
        lItem.SubItems.Add(IntToStr(lInfo.PointCount))
      else
        lItem.SubItems.Add('-');
      lItem.SubItems.Add(lInfo.UnitName);
      lItem.SubItems.Add(lInfo.RecorderAddress);
    end;
  finally
    lvDbSignals.Items.EndUpdate;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.edDbSignalSearchChange(Sender: TObject);
begin
  ApplyDbSignalFilter;
end;

procedure TRecorderSqlDbSettingsDialog.StoreControls;
var
  I: Integer;
begin
  SyncVisibleSignalChecks;
  fConfig.Enabled := cbEnabled.Checked;
  if cbBackend.ItemIndex >= 0 then
    fConfig.Backend := TRecorderSqlDbBackend(cbBackend.ItemIndex);
  fConfig.RootDirectory := Trim(edRoot.Text);
  fConfig.Database := Trim(edDatabase.Text);
  fConfig.Host := Trim(edHost.Text);
  fConfig.Port := sePort.Value;
  fConfig.UserName := Trim(edUser.Text);
  fConfig.StoredPassword := edPassword.Text;
  fConfig.PasswordEnvironment := Trim(edPasswordEnvironment.Text);
  fConfig.TlsRequired := cbTls.Checked;
  fConfig.QueueCapacity := seQueue.Value;
  fConfig.RecordPeriodMs := sePeriod.Value * 1000;
  fConfig.ObjectName := Trim(edObjectName.Text);
  fConfig.ObjectType := Trim(edObjectType.Text);
  fConfig.SerialNumber := Trim(edSerial.Text);
  if cbControlTag.ItemIndex > 0 then
    fConfig.ControlTagName := cbControlTag.Text
  else
    fConfig.ControlTagName := '';
  fConfig.SignalNames.Clear;
  fConfig.SignalSelectionConfigured := True;
  for I := 0 to fCheckedSignals.Count - 1 do
    fConfig.SignalNames.Add(fCheckedSignals[I]);
  fConfig.RequireValid;
end;

procedure TRecorderSqlDbSettingsDialog.UpdateControls;
var
  lFirebird, lRemote: Boolean;
begin
  lFirebird := cbBackend.ItemIndex = Ord(rsbFirebird);
  lRemote := (cbBackend.ItemIndex <> Ord(rsbSQLite)) and
    (Trim(edHost.Text) <> '');
  edHost.Enabled := cbBackend.ItemIndex <> Ord(rsbSQLite);
  sePort.Enabled := edHost.Enabled;
  edUser.Enabled := edHost.Enabled;
  edPassword.Enabled := edHost.Enabled;
  edPasswordEnvironment.Enabled := edHost.Enabled;
  cbTls.Enabled := lRemote;
  btnTestFirebird.Enabled := lFirebird;
  btnStartFirebird.Enabled := lFirebird and
    RecorderSqlDbFirebirdHostIsLocal(edHost.Text);
  btnSweepDb.Enabled := lFirebird;
  if edHost.Enabled then
    lblHost.Caption := 'Хост БД (пусто = локально)'
  else
    lblHost.Caption := 'Хост БД';
end;

function TRecorderSqlDbSettingsDialog.TryOpenCurrentDatabase(
  out AMessage: string): Boolean;
var
  R: TRecorderSqlDbRepository;
begin
  Result := False;
  try
    StoreControls;
    R := TRecorderSqlDbRepository.Create(fConfig);
    try
      R.Open;
      AMessage := 'Подключение к SQL БД успешно открыто.';
      Result := True;
    finally
      R.Free;
    end;
  except
    on E: Exception do
      AMessage := E.Message;
  end;
end;

function TRecorderSqlDbSettingsDialog.TryEnsureCurrentDatabase(
  out AMessage: string): Boolean;
var
  R: TRecorderSqlDbRepository;
begin
  Result := False;
  try
    StoreControls;
    R := TRecorderSqlDbRepository.Create(fConfig);
    try
      R.EnsureDatabase;
      AMessage := 'Подключение успешно. Схема создана/проверена.';
      Result := True;
    finally
      R.Free;
    end;
  except
    on E: Exception do
      AMessage := E.Message;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnReadDbSignalsClick(Sender: TObject);
var
  lInfos: TRecorderSqlDbSignalInfos;
  lRepository: TRecorderSqlDbRepository;
begin
  try
    StoreControls;
    lRepository := TRecorderSqlDbRepository.Create(fConfig);
    try
      lRepository.ListSignalInfos(lInfos, False);
      fDbSignals := lInfos;
      ApplyDbSignalFilter;
    finally
      lRepository.Free;
    end;
  except
    on E: Exception do
      MessageDlg('Ошибка SQL БД', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnDeleteDbSignalsClick(Sender: TObject);
var
  I: Integer;
  lNames: TStringList;
  lSyncResult: TRecorderSqlDbProjectSyncResult;
  lSignalsDeleted, lValuesDeleted: Int64;
  lRepository: TRecorderSqlDbRepository;
begin
  lNames := TStringList.Create;
  try
    for I := 0 to lvDbSignals.Items.Count - 1 do
      if lvDbSignals.Items[I].Selected then
        lNames.Add(lvDbSignals.Items[I].Caption);
    if lNames.Count = 0 then Exit;
    if MessageDlg('SQL БД',
      Format('Удалить выбранные каналы из БД: %d?', [lNames.Count]),
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;
    StoreControls;
    lRepository := TRecorderSqlDbRepository.Create(fConfig);
    try
      lRepository.DeleteSignalsByName(lNames, lSignalsDeleted, lValuesDeleted);
    finally
      lRepository.Free;
    end;
    MessageDlg('SQL БД',
      Format('Удалено каналов: %d. Удалено точек: %d.',
        [lSignalsDeleted, lValuesDeleted]), mtInformation, [mbOK], 0);
    lSyncResult := TRecorderSqlDbProjectManager.RemoveSignals(fConfig, nil,
      lNames);
    if lSyncResult.ConfigSignalCount > 0 then
    begin
      fConfig.SaveToFile(fFileName);
      fCheckedSignals.Assign(fConfig.SignalNames);
      SyncVisibleSignalChecks;
    end;
    if Assigned(fOnSignalsDeleted) then
      fOnSignalsDeleted(lNames);
    btnReadDbSignalsClick(nil);
  finally
    lNames.Free;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnSweepDbClick(Sender: TObject);
var
  lMessage: string;
begin
  try
    StoreControls;
    if RecorderSqlDbRunFirebirdSweep(fConfig, lMessage) then
      MessageDlg('SQL БД', lMessage, mtInformation, [mbOK], 0)
    else
      MessageDlg('SQL БД', lMessage, mtWarning, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Ошибка SQL БД', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.cbBackendChange(Sender: TObject);
begin
  if cbBackend.ItemIndex = Ord(rsbFirebird) then
  begin
    if edDatabase.Text = CRecorderSqlDbDefaultFileName then
      edDatabase.Text := CRecorderFirebirdDefaultFileName;
    if sePort.Value = 0 then sePort.Value := 3050;
  end;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.btnTestFirebirdClick(Sender: TObject);
var
  lPort: Word;
  lDetails, lMessage: string;
begin
  lPort := sePort.Value;
  if lPort = 0 then
    lPort := 3050;
  if RecorderSqlDbFirebirdTcpAvailable(edHost.Text, lPort, 1200,
    lMessage) then
    MessageDlg('Firebird', lMessage, mtInformation, [mbOK], 0)
  else
  begin
    if RecorderSqlDbFirebirdHostIsLocal(edHost.Text) then
      lDetails := LineEnding + LineEnding +
        RecorderSqlDbDescribeLocalFirebird(lPort)
    else
      lDetails := '';
    MessageDlg('Firebird',
      lMessage + LineEnding +
      'Для локального сервера можно попробовать кнопку "Запустить Firebird".' +
      lDetails,
      mtWarning, [mbOK], 0);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnStartFirebirdClick(Sender: TObject);
var
  I: Integer;
  lPort: Word;
  lMessage, lProbeMessage: string;
begin
  if not RecorderSqlDbFirebirdHostIsLocal(edHost.Text) then
  begin
    MessageDlg('Firebird',
      'Запуск поддержан только для локального Firebird. Для удаленного host ' +
      'службу нужно запускать на сервере БД.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lPort := sePort.Value;
  if lPort = 0 then
    lPort := 3050;
  if RecorderSqlDbStartLocalFirebird(lMessage) then
  begin
    for I := 0 to 9 do
    begin
      if RecorderSqlDbFirebirdTcpAvailable(edHost.Text, lPort, 700,
        lProbeMessage) then
      begin
        MessageDlg('Firebird', lProbeMessage, mtInformation, [mbOK], 0);
        Exit;
      end;
      Sleep(500);
      Application.ProcessMessages;
    end;
  end;
  if RecorderSqlDbFirebirdTcpAvailable(edHost.Text, lPort, 1500,
    lProbeMessage) then
    MessageDlg('Firebird', lProbeMessage, mtInformation, [mbOK], 0)
  else
    MessageDlg('Firebird', lMessage + LineEnding + LineEnding +
      RecorderSqlDbDescribeLocalFirebird(lPort),
      mtWarning, [mbOK], 0);
end;

procedure TRecorderSqlDbSettingsDialog.btnBrowseClick(Sender: TObject);
var D: string;
begin
  D := edRoot.Text;
  if Trim(D) = '' then
    D := RecorderSqlDbDefaultRootDirectory;
  if SelectDirectory('Каталог SQL БД и файлов данных', '', D) then edRoot.Text := D;
end;

procedure TRecorderSqlDbSettingsDialog.btnTestClick(Sender: TObject);
var
  I: Integer;
  lFirstError, lMessage: string;
  lPort: Word;
begin
  if TryEnsureCurrentDatabase(lMessage) then
  begin
    MessageDlg('SQL БД', lMessage, mtInformation, [mbOK], 0);
    Exit;
  end;
  lFirstError := lMessage;
  if (fConfig.Backend = rsbFirebird) and
    RecorderSqlDbFirebirdHostIsLocal(fConfig.Host) then
  begin
    lPort := fConfig.Port;
    if lPort = 0 then
      lPort := 3050;
    if Trim(fConfig.Host) <> '' then
    begin
      if not RecorderSqlDbFirebirdTcpAvailable(fConfig.Host, lPort, 500,
        lMessage) then
        RecorderSqlDbStartLocalFirebird(lMessage);
    end
    else
      RecorderSqlDbStartLocalFirebird(lMessage);
    for I := 0 to 9 do
    begin
      if TryEnsureCurrentDatabase(lMessage) then
      begin
        MessageDlg('SQL БД', lMessage, mtInformation, [mbOK], 0);
        Exit;
      end;
      Sleep(500);
      Application.ProcessMessages;
    end;
  end;
  MessageDlg('Ошибка SQL БД',
    lFirstError + LineEnding + LineEnding + 'После попытки запуска Firebird:' +
    LineEnding + lMessage,
    mtError, [mbOK], 0);
end;

procedure TRecorderSqlDbSettingsDialog.btnSelectAllClick(Sender: TObject);
var I: Integer;
begin
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lvSignals.Items[I].Checked := True;
    if fCheckedSignals.IndexOf(lvSignals.Items[I].Caption) < 0 then
      fCheckedSignals.Add(lvSignals.Items[I].Caption);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnSelectNoneClick(Sender: TObject);
var
  I: Integer;
  lCheckedIndex: Integer;
  lFirstSelected: TListItem;
  lItem: TListItem;
  lSelectedNames: TStringList;
  lTargetChecked: Boolean;
begin
  lSelectedNames := TStringList.Create;
  try
    lSelectedNames.CaseSensitive := False;
    lSelectedNames.Sorted := True;
    lSelectedNames.Duplicates := dupIgnore;
    lTargetChecked := False;
    for I := 0 to lvSignals.Items.Count - 1 do
    begin
      lItem := lvSignals.Items[I];
      if not lItem.Selected then Continue;
      lSelectedNames.Add(lItem.Caption);
      if not lItem.Checked then
        lTargetChecked := True;
    end;
    if lSelectedNames.Count = 0 then Exit;
    lvSignals.Items.BeginUpdate;
    try
      for I := 0 to lvSignals.Items.Count - 1 do
      begin
        lItem := lvSignals.Items[I];
        if lSelectedNames.IndexOf(lItem.Caption) < 0 then Continue;
        lItem.Checked := lTargetChecked;
        lCheckedIndex := fCheckedSignals.IndexOf(lItem.Caption);
        if lTargetChecked then
        begin
          if lCheckedIndex < 0 then
            fCheckedSignals.Add(lItem.Caption);
        end
        else if lCheckedIndex >= 0 then
          fCheckedSignals.Delete(lCheckedIndex);
      end;
      lFirstSelected := nil;
      for I := 0 to lvSignals.Items.Count - 1 do
      begin
        lItem := lvSignals.Items[I];
        lItem.Selected := lSelectedNames.IndexOf(lItem.Caption) >= 0;
        if lItem.Selected and (lFirstSelected = nil) then
          lFirstSelected := lItem;
      end;
    finally
      lvSignals.Items.EndUpdate;
    end;
    if lFirstSelected <> nil then
    begin
      if lvSignals.CanFocus then
        lvSignals.SetFocus;
      lFirstSelected.Focused := True;
      lFirstSelected.MakeVisible(False);
    end;
  finally
    lSelectedNames.Free;
  end;
end;

function TRecorderSqlDbSettingsDialog.TagIsScalar(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag = nil) or (ATag.PollFrequencyHz <= 0) or
    (ATag.IsVirtual and (not ATag.IsVector));
end;

function TRecorderSqlDbSettingsDialog.EstimateText(ATag: TRecorderTag;
  AKind: TRecorderTagEstimateKind): string;
begin
  if TagIsScalar(ATag) then
    Result := RecorderTagEstimateKindToName(tekMean) + ' (scalar)'
  else
    Result := RecorderTagEstimateKindToName(AKind);
end;

procedure TRecorderSqlDbSettingsDialog.btnAssignEstimateClick(Sender: TObject);
var
  I: Integer;
  lItem: TListItem;
  lTag: TRecorderTag;
  lKind: TRecorderTagEstimateKind;
begin
  if cbSignalEstimate.ItemIndex < 0 then Exit;
  lKind := TRecorderTagEstimateKind(cbSignalEstimate.ItemIndex);
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lItem := lvSignals.Items[I];
    if not lItem.Selected then Continue;
    lTag := TRecorderTag(lItem.Data);
    if TagIsScalar(lTag) then
      fConfig.SetSignalEstimate(lItem.Caption, tekMean)
    else
      fConfig.SetSignalEstimate(lItem.Caption, lKind);
    lItem.SubItems[0] := EstimateText(lTag,
      fConfig.SignalEstimate(lItem.Caption));
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnOkClick(Sender: TObject);
begin
  StoreControls;
  fConfig.SaveToFile(fFileName);
  ModalResult := mrOk;
end;

function ShowRecorderSqlDbSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry;
  AOnSignalsDeleted: TRecorderSqlDbSignalsDeletedEvent): Boolean;
var D: TRecorderSqlDbSettingsDialog;
begin
  D := TRecorderSqlDbSettingsDialog.Create(AOwner);
  try
    D.LoadConfig(AFileName, ARegistry, AOnSignalsDeleted);
    Result := D.ShowModal = mrOk;
  finally D.Free; end;
end;

end.
