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
    btnAllowedDbSignals: TButton;
    btnEnableAllDbSignals: TButton;
    btnToggleSelectedDbSignals: TButton;
    btnReadDbSignals: TButton;
    btnSweepDb: TButton;
    btnStartFirebird: TButton;
    btnTest: TButton;
    btnTestFirebird: TButton;
    btnSelectAll: TButton;
    btnSelectNone: TButton;
    btnImportSqlSelection: TButton;
    btnCreateSqlSource: TButton;
    btnAssignEstimate: TButton;
    btnToggleAlarmEvent: TButton;
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
    procedure btnAllowedDbSignalsClick(Sender: TObject);
    procedure btnEnableAllDbSignalsClick(Sender: TObject);
    procedure btnToggleSelectedDbSignalsClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnReadDbSignalsClick(Sender: TObject);
    procedure btnSweepDbClick(Sender: TObject);
    procedure btnStartFirebirdClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnTestFirebirdClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
    procedure btnImportSqlSelectionClick(Sender: TObject);
    procedure btnCreateSqlSourceClick(Sender: TObject);
    procedure btnAssignEstimateClick(Sender: TObject);
    procedure btnToggleAlarmEventClick(Sender: TObject);
    procedure cbBackendChange(Sender: TObject);
    procedure edRootChange(Sender: TObject);
    procedure edHostChange(Sender: TObject);
    procedure edDbSignalSearchChange(Sender: TObject);
    procedure edSignalSearchChange(Sender: TObject);
  private
    fAllSignals: TStringList;
    fCheckedSignals: TStringList;
    fSqlSourceSignals: TStringList;
    fAlarmSignals: TStringList;
    fConfig: TRecorderSqlDbConfig;
    fDbSignals: TRecorderSqlDbSignalInfos;
    fFileName: string;
    fChannelPages: TPageControl;
    fWriteSignalsTab: TTabSheet;
    fDbSignalsTab: TTabSheet;
    fOnSignalsDeleted: TRecorderSqlDbSignalsDeletedEvent;
    fRegistry: TRecorderTagRegistry;
    fLocalDatabaseDraft: string;
    fRemoteDatabaseDraft: string;
    fRemoteDatabaseDrafts: TStringList;
    fDatabaseHost: string;
    fDatabaseModeLocal: Boolean;
    fLoadingDatabaseControls: Boolean;
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
    procedure SyncVisibleDbSignalChecks;
    procedure StoreControls;
    procedure UpdateControls;
    function TryReadDbSignals(out AError: string): Boolean;
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
function ShowRecorderSqlDataSourceSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry;
  out AConnectionError: string): Boolean;

implementation

uses
  uRecorderSqlDbFirebirdTools, uRecorderSqlDbProjectManager,
  uRecorderSqlDbRuntime,
  uRecorderTagTableExchange, uRecorderSqlSelectionImportDialog,
  uRecorderSqlAllowedSignalsDialog, fpjson, jsonparser, fphttpclient,
  uRecorderConfiguredDataSources, uRecorderSqlDataSource;

{$R *.lfm}

function TryDiscoverServerDatabase(const AHost: string; out APath, AError: string): Boolean; forward;

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
  fSqlSourceSignals := TStringList.Create;
  fSqlSourceSignals.CaseSensitive := False;
  fSqlSourceSignals.Sorted := True;
  fSqlSourceSignals.Duplicates := dupIgnore;
  fAlarmSignals := TStringList.Create;
  fRemoteDatabaseDrafts := TStringList.Create;
  fAlarmSignals.CaseSensitive := False;
  fAlarmSignals.Sorted := True;
  fAlarmSignals.Duplicates := dupIgnore;
end;

procedure TRecorderSqlDbSettingsDialog.btnCreateSqlSourceClick(Sender: TObject);
var
  I, J: Integer;
  lArray: TJSONArray;
  lInfo: TRecorderSqlDbSignalInfo;
  lRepository: TRecorderSqlDbRepository;
  lSource: TRecorderConfiguredDataSource;
  lTag: TRecorderTag;
  lBaseTagName, lTagName: string;
  lSuffix: Integer;
begin
  if fRegistry = nil then Exit;
  StoreControls;
  lRepository := TRecorderSqlDbRepository.Create(fConfig);
  lArray := TJSONArray.Create;
  try
    lRepository.ListSignalInfos(fDbSignals, False);
    SyncVisibleDbSignalChecks;
    for I := 0 to fSqlSourceSignals.Count - 1 do
      for J := 0 to High(fDbSignals) do
        if SameText(fDbSignals[J].Name, fSqlSourceSignals[I]) then
        begin
          lInfo := fDbSignals[J];
          lTagName := lInfo.Name;
          { A database signal has one canonical imported tag.  Reuse it by
            source address before resolving a name conflict; otherwise a
            repeated import of an already renamed tag would create _sql2,
            _sql3 and so on. }
          lTag := nil;
          for lSuffix := 0 to fRegistry.TagCount - 1 do
            if SameText(fRegistry.Tags[lSuffix].SourceId,
              CRecorderSqlSourceId) and
              SameText(fRegistry.Tags[lSuffix].Address, lInfo.Name) then
            begin
              lTag := fRegistry.Tags[lSuffix];
              lTagName := lTag.Name;
              Break;
            end;
          if lTag <> nil then
          begin
            lTag.ModuleType := CRecorderSqlSourceModuleType;
            lTag.UnitName := lInfo.UnitName;
            RecorderSqlSourceAddBinding(lArray, lInfo.Name, lTagName,
              lInfo.UnitName);
            Break;
          end;
          lTag := fRegistry.FindByName(lTagName);
          if (lTag <> nil) and
            (not SameText(lTag.SourceId, CRecorderSqlSourceId)) then
          begin
            if MessageDlg('Конфликт имени', Format(
              'Тег "%s" уже существует. Импортировать как "%s_sql"?',
              [lTagName, lTagName]), mtWarning, [mbYes, mbNo], 0) <> mrYes then
              Continue;
            lBaseTagName := lTagName + '_sql';
            lTagName := lBaseTagName;
            lSuffix := 2;
            while fRegistry.FindByName(lTagName) <> nil do
            begin
              lTagName := lBaseTagName + IntToStr(lSuffix);
              Inc(lSuffix);
            end;
          end;
          lTag := fRegistry.FindByName(lTagName);
          if lTag = nil then lTag := fRegistry.CreateTag(lTagName, 4096);
          lTag.SourceId := CRecorderSqlSourceId;
          lTag.ModuleType := CRecorderSqlSourceModuleType;
          lTag.Address := lInfo.Name;
          lTag.UnitName := lInfo.UnitName;
          RecorderSqlSourceAddBinding(lArray, lInfo.Name, lTagName,
            lInfo.UnitName);
          Break;
        end;
    lSource := RecorderConfiguredDataSourcesEnsure(fRegistry,
      CRecorderSqlSourceId, CRecorderSqlSourceModuleType, 1);
    lSource.SpecificConfigText := lArray.AsJSON;
    fRegistry.RegisterActiveSource(CRecorderSqlSourceId);
    MessageDlg('SQL источник', Format('Импортировано каналов: %d',
      [lArray.Count]), mtInformation, [mbOK], 0);
  finally
    lArray.Free;
    lRepository.Free;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.BuildChannelPages;
begin
  lvDbSignals.CheckBoxes := True;
  lvDbSignals.MultiSelect := True;
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
  lBottomTop, lAlarmTop, lEstimateTop: Integer;
begin
  if gbSignals = nil then Exit;

  cbControlTag.Width := Max(120, gbSignals.ClientWidth - 16);
  edSignalSearch.Width := Max(120, gbSignals.ClientWidth - edSignalSearch.Left - 8);

  lBottomTop := Max(150, gbSignals.ClientHeight - btnSelectAll.Height - 8);
  lAlarmTop := lBottomTop - btnToggleAlarmEvent.Height - 8;
  lEstimateTop := Max(110, lAlarmTop - cbSignalEstimate.Height - 8);

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

  btnToggleAlarmEvent.SetBounds(Max(8, gbSignals.ClientWidth -
    btnToggleAlarmEvent.Width - 8), lAlarmTop,
    btnToggleAlarmEvent.Width, btnToggleAlarmEvent.Height);

  btnCreateSqlSource.SetBounds(8,
    lBottomTop - btnCreateSqlSource.Height - 8,
    Min(270, gbSignals.ClientWidth - 16), btnCreateSqlSource.Height);
  btnCreateSqlSource.Anchors := [akLeft, akBottom];

  btnSelectAll.Top := lBottomTop;
  btnSelectNone.Top := lBottomTop;
  btnSelectAll.Width := Max(90, (gbSignals.ClientWidth - 32) div 3);
  btnSelectNone.Left := btnSelectAll.Left + btnSelectAll.Width + 8;
  btnSelectNone.Width := btnSelectAll.Width;
  btnImportSqlSelection.Top := lBottomTop;
  btnImportSqlSelection.Left := btnSelectNone.Left + btnSelectNone.Width + 8;
  btnImportSqlSelection.Width := Max(90,
    gbSignals.ClientWidth - btnImportSqlSelection.Left - 8);
end;

procedure TRecorderSqlDbSettingsDialog.LayoutDbChannelControls;
var
  lButtonTop, lButtonWidth: Integer;
begin
  if gbDbChannels = nil then Exit;

  lblDbSignalSearch.SetBounds(12, 20, 50, lblDbSignalSearch.Height);
  edDbSignalSearch.SetBounds(70, 15,
    Max(120, gbDbChannels.ClientWidth - 82), edDbSignalSearch.Height);
  edDbSignalSearch.Anchors := [akTop, akLeft, akRight];

  lButtonTop := Max(90, gbDbChannels.ClientHeight - 108);
  lButtonWidth := Max(120, (gbDbChannels.ClientWidth - 36) div 2);
  btnReadDbSignals.SetBounds(12, lButtonTop, lButtonWidth,
    btnReadDbSignals.Height);
  btnDeleteDbSignals.SetBounds(20 + lButtonWidth, lButtonTop, lButtonWidth,
    btnDeleteDbSignals.Height);
  btnEnableAllDbSignals.SetBounds(12, lButtonTop + 34, lButtonWidth,
    btnEnableAllDbSignals.Height);
  btnToggleSelectedDbSignals.SetBounds(20 + lButtonWidth, lButtonTop + 34,
    lButtonWidth, btnToggleSelectedDbSignals.Height);
  btnAllowedDbSignals.SetBounds(12, lButtonTop + 68, lButtonWidth,
    btnAllowedDbSignals.Height);
  btnSweepDb.SetBounds(20 + lButtonWidth, lButtonTop + 68, lButtonWidth,
    btnSweepDb.Height);
  btnReadDbSignals.Anchors := [akLeft, akBottom];
  btnDeleteDbSignals.Anchors := [akLeft, akBottom];
  btnSweepDb.Anchors := [akLeft, akBottom];
  btnAllowedDbSignals.Anchors := [akLeft, akBottom];
  btnEnableAllDbSignals.Anchors := [akLeft, akBottom];
  btnToggleSelectedDbSignals.Anchors := [akLeft, akBottom];

  lvDbSignals.SetBounds(12, 52, Max(120, gbDbChannels.ClientWidth - 24),
    Max(80, lButtonTop - 62));
  lvDbSignals.Anchors := [akTop, akLeft, akRight, akBottom];
end;

procedure TRecorderSqlDbSettingsDialog.btnEnableAllDbSignalsClick(
  Sender: TObject);
var
  I: Integer;
begin
  SyncVisibleDbSignalChecks;
  for I := 0 to High(fDbSignals) do
    if (Trim(fDbSignals[I].Name) <> '') and
      (fSqlSourceSignals.IndexOf(fDbSignals[I].Name) < 0) then
      fSqlSourceSignals.Add(fDbSignals[I].Name);
  ApplyDbSignalFilter;
end;

procedure TRecorderSqlDbSettingsDialog.btnToggleSelectedDbSignalsClick(
  Sender: TObject);
var
  I, lIndex: Integer;
  lEnable: Boolean;
  lName: string;
begin
  SyncVisibleDbSignalChecks;
  lEnable := False;
  for I := 0 to lvDbSignals.Items.Count - 1 do
    if lvDbSignals.Items[I].Selected and
      (fSqlSourceSignals.IndexOf(lvDbSignals.Items[I].Caption) < 0) then
    begin
      lEnable := True;
      Break;
    end;

  for I := 0 to lvDbSignals.Items.Count - 1 do
    if lvDbSignals.Items[I].Selected then
    begin
      { Caption is the canonical database signal name and remains stable when
        the filtered list is rebuilt. }
      lName := lvDbSignals.Items[I].Caption;
      lIndex := fSqlSourceSignals.IndexOf(lName);
      if lEnable then
      begin
        if lIndex < 0 then fSqlSourceSignals.Add(lName);
      end
      else if lIndex >= 0 then
        fSqlSourceSignals.Delete(lIndex);
    end;
  ApplyDbSignalFilter;
end;

procedure TRecorderSqlDbSettingsDialog.btnAllowedDbSignalsClick(
  Sender: TObject);
var
  lAllowed, lDeleteNames: TStringList;
  lIndex: Integer;
  lRepository: TRecorderSqlDbRepository;
  lSignalsDeleted, lValuesDeleted: Int64;
begin
  if Length(fDbSignals) = 0 then
    btnReadDbSignalsClick(nil);
  if Length(fDbSignals) = 0 then Exit;
  lAllowed := TStringList.Create;
  lDeleteNames := TStringList.Create;
  try
    lAllowed.CaseSensitive := False;
    lAllowed.Sorted := True;
    lAllowed.Duplicates := dupIgnore;
    lDeleteNames.CaseSensitive := False;
    lDeleteNames.Sorted := True;
    lDeleteNames.Duplicates := dupIgnore;
    if fConfig.AllowedSignalSelectionConfigured then
      lAllowed.Assign(fConfig.AllowedSignalNames)
    else
      lAllowed.Assign(fCheckedSignals);
    if not EditRecorderSqlAllowedSignals(Self, fDbSignals, lAllowed) then Exit;

    fConfig.AllowedSignalNames.Assign(lAllowed);
    fConfig.AllowedSignalSelectionConfigured := True;
    fCheckedSignals.Clear;
    for lIndex := 0 to fAllSignals.Count - 1 do
      if lAllowed.IndexOf(fAllSignals[lIndex]) >= 0 then
        fCheckedSignals.Add(fAllSignals[lIndex]);
    ApplySignalFilter;

    for lIndex := 0 to High(fDbSignals) do
      if lAllowed.IndexOf(fDbSignals[lIndex].Name) < 0 then
        lDeleteNames.Add(fDbSignals[lIndex].Name);
    if (lDeleteNames.Count > 0) and
      (MessageDlg('SQL БД', Format(
        'В БД найдено неразрешённых каналов: %d. Удалить их сейчас один раз?',
        [lDeleteNames.Count]), mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      StoreControls;
      fConfig.SaveToFile(fFileName);
      lRepository := TRecorderSqlDbRepository.Create(fConfig);
      try
        lRepository.DeleteSignalsByName(lDeleteNames, lSignalsDeleted,
          lValuesDeleted);
      finally
        lRepository.Free;
      end;
      if Assigned(fOnSignalsDeleted) then fOnSignalsDeleted(lDeleteNames);
      MessageDlg('SQL БД', Format(
        'Удалено каналов: %d. Удалено точек: %d.',
        [lSignalsDeleted, lValuesDeleted]), mtInformation, [mbOK], 0);
      btnReadDbSignalsClick(nil);
    end;
  finally
    lDeleteNames.Free;
    lAllowed.Free;
  end;
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
  fRemoteDatabaseDrafts.Free;
  fAlarmSignals.Free;
  fSqlSourceSignals.Free;
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
  lTag: TRecorderTag;
  lData: TJSONData;
  lSourceConfig: string;
  lRemoteConfig: TRecorderSqlDbConfig;
begin
  fLoadingDatabaseControls := True;
  cbEnabled.Checked := fConfig.Enabled;
  cbBackend.ItemIndex := Ord(fConfig.Backend);
  if Trim(fConfig.RootDirectory) <> '' then
    edRoot.Text := fConfig.RootDirectory
  else
    edRoot.Text := RecorderSqlDbDefaultRootDirectory;
  fLocalDatabaseDraft := fConfig.LocalDatabase;
  fRemoteDatabaseDraft := fConfig.RemoteDatabase;
  fRemoteDatabaseDrafts.Clear;
  lRemoteConfig := TRecorderSqlDbConfig.Create;
  try
    lRemoteConfig.Assign(fConfig);
    lRemoteConfig.Host := fConfig.RemoteDatabaseHost;
    fRemoteDatabaseDrafts.Values[LowerCase(Trim(fConfig.RemoteDatabaseHost))] :=
      lRemoteConfig.RemoteDatabase;
  finally
    lRemoteConfig.Free;
  end;
  fDatabaseHost := LowerCase(Trim(fConfig.Host));
  fDatabaseModeLocal := (fConfig.Backend = rsbSQLite) or
    RecorderSqlDbHostIsLocal(fConfig.Host);
  edDatabase.Text := fConfig.Database;
  edHost.Text := fConfig.Host;
  edRoot.OnChange := @edRootChange;
  edHost.OnChange := @edHostChange;
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
  fSqlSourceSignals.Clear;
  fAlarmSignals.Clear;
  lvSignals.Clear;
  lvDbSignals.Clear;
  edDbSignalSearch.Clear;
  SetLength(fDbSignals, 0);
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lTag := fRegistry.Tags[I];
      if RecorderTagIsSqlMirror(lTag) then
      begin
        fSqlSourceSignals.Add(lTag.Address);
        Continue;
      end;
      fAllSignals.AddObject(lTag.Name, lTag);
      if not fConfig.SignalSelectionConfigured or
         (fConfig.SignalNames.IndexOf(lTag.Name) >= 0) then
        fCheckedSignals.Add(lTag.Name);
      if fConfig.AlarmEventEnabled(lTag.Name) then
        fAlarmSignals.Add(lTag.Name);
    end;
  { The configured source is authoritative.  SQL tags can still be referenced
    by forms after a channel is unchecked, so deriving the selection from all
    registry tags would silently re-enable a deselected channel next time. }
  lSourceConfig := RecorderSqlSourceConfig(fRegistry);
  if Trim(lSourceConfig) <> '' then
  begin
    lData := nil;
    try
      lData := GetJSON(lSourceConfig);
      if lData is TJSONArray then
      begin
        fSqlSourceSignals.Clear;
        for I := 0 to TJSONArray(lData).Count - 1 do
          if TJSONArray(lData)[I] is TJSONObject then
            fSqlSourceSignals.Add(TJSONObject(TJSONArray(lData)[I]).Get(
              'signal', ''));
      end;
    except
      { Keep the tag-derived fallback when an old project contains malformed
        source JSON; the editor can then save a repaired canonical selection. }
    end;
    lData.Free;
  end;
  ApplySignalFilter;
  ApplyDbSignalFilter;
  fLoadingDatabaseControls := False;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.SyncVisibleDbSignalChecks;
var
  I, lIndex: Integer;
begin
  for I := 0 to lvDbSignals.Items.Count - 1 do
    if lvDbSignals.Items[I].Checked then
    begin
      if fSqlSourceSignals.IndexOf(lvDbSignals.Items[I].Caption) < 0 then
        fSqlSourceSignals.Add(lvDbSignals.Items[I].Caption);
    end
    else
    begin
      lIndex := fSqlSourceSignals.IndexOf(lvDbSignals.Items[I].Caption);
      if lIndex >= 0 then fSqlSourceSignals.Delete(lIndex);
    end;
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
      if fAlarmSignals.IndexOf(lName) >= 0 then
        lItem.SubItems.Add('Да')
      else
        lItem.SubItems.Add('Нет');
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
      lItem.Checked := fSqlSourceSignals.IndexOf(lInfo.Name) >= 0;
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
  SyncVisibleDbSignalChecks;
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
  if (fConfig.Backend = rsbSQLite) or RecorderSqlDbHostIsLocal(edHost.Text) then
    fConfig.RootDirectory := Trim(edRoot.Text);
  fConfig.Host := Trim(edHost.Text);
  if fDatabaseModeLocal then
    fLocalDatabaseDraft := Trim(edDatabase.Text)
  else
    fRemoteDatabaseDraft := Trim(edDatabase.Text);
  fConfig.LocalDatabase := fLocalDatabaseDraft;
  if not fDatabaseModeLocal then
    fConfig.RemoteDatabase := fRemoteDatabaseDraft;
  fConfig.Port := sePort.Value;
  if fConfig.Backend = rsbFirebird then
    fConfig.UserName := CRecorderFirebirdDefaultUserName
  else
  if fConfig.Backend = rsbFirebird then
    fConfig.UserName := CRecorderFirebirdDefaultUserName
  else
    fConfig.UserName := Trim(edUser.Text);
  if fConfig.Backend = rsbFirebird then
    fConfig.StoredPassword := CRecorderFirebirdDefaultPassword
  else
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
  fConfig.AlarmSignalNames.Assign(fAlarmSignals);
  fConfig.AlarmSignalSelectionConfigured := True;
  fConfig.RequireValid;
end;

procedure TRecorderSqlDbSettingsDialog.UpdateControls;
var
  lFirebird, lRemote, lLocal: Boolean;
  lHost: string;
begin
  if fLoadingDatabaseControls then Exit;
  lFirebird := cbBackend.ItemIndex = Ord(rsbFirebird);
  lRemote := (cbBackend.ItemIndex <> Ord(rsbSQLite)) and
    not RecorderSqlDbHostIsLocal(edHost.Text);
  lLocal := not lRemote;
  lHost := LowerCase(Trim(edHost.Text));
  if (lLocal <> fDatabaseModeLocal) or
    (lRemote and (lHost <> fDatabaseHost)) then
  begin
    if fDatabaseModeLocal then
      fLocalDatabaseDraft := edDatabase.Text
    else
    begin
      fRemoteDatabaseDraft := edDatabase.Text;
      fRemoteDatabaseDrafts.Values[fDatabaseHost] := fRemoteDatabaseDraft;
    end;
    fDatabaseModeLocal := lLocal;
    if lLocal then edDatabase.Text := fLocalDatabaseDraft
    else
    begin
      fRemoteDatabaseDraft := fRemoteDatabaseDrafts.Values[lHost];
      edDatabase.Text := fRemoteDatabaseDraft;
    end;
  end;
  fDatabaseHost := lHost;
  edHost.Enabled := cbBackend.ItemIndex <> Ord(rsbSQLite);
  sePort.Enabled := edHost.Enabled;
  edUser.Enabled := edHost.Enabled;
  edPassword.Enabled := edHost.Enabled;
  edPasswordEnvironment.Enabled := edHost.Enabled;
  cbTls.Enabled := lRemote;
  lblRoot.Visible := not lRemote;
  edRoot.Visible := not lRemote;
  btnBrowse.Visible := not lRemote;
  lblPassword.Visible := not lFirebird;
  edPassword.Visible := not lFirebird;
  lblPasswordEnvironment.Visible := not lFirebird;
  edPasswordEnvironment.Visible := not lFirebird;
  lblUser.Visible := not lFirebird;
  edUser.Visible := not lFirebird;
  lblUser.Visible := not lFirebird;
  edUser.Visible := not lFirebird;
  if lRemote then
    lblDatabase.Caption := 'Путь БД на сервере'
  else
    lblDatabase.Caption := 'Путь локальной БД';
  btnTestFirebird.Enabled := lFirebird;
  btnStartFirebird.Enabled := lFirebird and
    RecorderSqlDbHostIsLocal(edHost.Text);
  btnSweepDb.Enabled := lFirebird;
  if edHost.Enabled then
    lblHost.Caption := 'Хост БД (пусто = локально)'
  else
    lblHost.Caption := 'Хост БД';
end;

procedure TRecorderSqlDbSettingsDialog.edHostChange(Sender: TObject);
begin
  UpdateControls;
end;

function TRecorderSqlDbSettingsDialog.TryOpenCurrentDatabase(
  out AMessage: string): Boolean;
var
  R: TRecorderSqlDbRepository;
begin
  Result := False;
  try
    StoreControls;
    if not fConfig.ConnectionConfigurationReady(AMessage) then
      Exit;
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
    if not fConfig.ConnectionConfigurationReady(AMessage) then
      Exit;
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
  lError: string;
begin
  if not TryReadDbSignals(lError) then
    MessageDlg('Ошибка SQL БД', lError, mtError, [mbOK], 0);
end;

function TRecorderSqlDbSettingsDialog.TryReadDbSignals(
  out AError: string): Boolean;
var
  lInfos: TRecorderSqlDbSignalInfos;
  lRepository: TRecorderSqlDbRepository;
begin
  Result := False;
  AError := '';
  try
    StoreControls;
    if not fConfig.ConnectionConfigurationReady(AError) then Exit;
    if not RecorderSqlServerAvailable(fConfig, AError) then Exit;
    lRepository := TRecorderSqlDbRepository.Create(fConfig);
    try
      lRepository.ListSignalInfos(lInfos, False);
      fDbSignals := lInfos;
      ApplyDbSignalFilter;
      Result := True;
    finally
      lRepository.Free;
    end;
  except
    on E: Exception do
      AError := E.Message;
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
  UpdateControls;
  if cbBackend.ItemIndex = Ord(rsbFirebird) then
  begin
    if fDatabaseModeLocal and
      (edDatabase.Text = CRecorderSqlDbDefaultFileName) then
      edDatabase.Text := CRecorderFirebirdDefaultFileName;
    if sePort.Value = 0 then sePort.Value := 3050;
  end;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.btnTestFirebirdClick(Sender: TObject);
var
  lPort: Word;
  lDetails, lMessage, lPath: string;
begin
  if (cbBackend.ItemIndex = Ord(rsbFirebird)) and
     (not RecorderSqlDbHostIsLocal(Trim(edHost.Text))) and
     (Trim(edDatabase.Text) = '') then
  begin
    if not TryDiscoverServerDatabase(Trim(edHost.Text), lPath, lMessage) then
    begin
      MessageDlg('Firebird', 'Не удалось получить путь базы с сервера: ' + lMessage,
        mtWarning, [mbOK], 0);
      Exit;
    end;
    edDatabase.Text := lPath;
    if TryOpenCurrentDatabase(lMessage) then
      MessageDlg('Firebird', 'Путь базы: ' + lPath + LineEnding + lMessage,
        mtInformation, [mbOK], 0)
    else
      MessageDlg('Firebird', 'Путь базы: ' + lPath + LineEnding + lMessage,
        mtError, [mbOK], 0);
    Exit;
  end;
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
      lMessage + LineEnding + UTF8Encode(
      'Для локального сервера можно попробовать кнопку "Запустить Firebird".') +
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

procedure TRecorderSqlDbSettingsDialog.edRootChange(Sender: TObject);
var
  lRoot, lName: string;
  lIndex: Integer;
begin
  if fLoadingDatabaseControls or not fDatabaseModeLocal then Exit;
  lRoot := Trim(edRoot.Text);
  if lRoot = '' then Exit;
  lName := StringReplace(Trim(edDatabase.Text), '\', '/', [rfReplaceAll]);
  lIndex := LastDelimiter('/', lName);
  if lIndex > 0 then Delete(lName, 1, lIndex);
  if lName = '' then Exit;
  if (lRoot[Length(lRoot)] = '/') or (lRoot[Length(lRoot)] = '\') then
    edDatabase.Text := lRoot + lName
  else if Pos('\', lRoot) > 0 then
    edDatabase.Text := lRoot + '\' + lName
  else
    edDatabase.Text := lRoot + '/' + lName;
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
    lFirstError + LineEnding + LineEnding +
      UTF8Encode('После попытки запуска Firebird:') +
    LineEnding + lMessage,
    mtError, [mbOK], 0);
end;

procedure TRecorderSqlDbSettingsDialog.btnImportSqlSelectionClick(
  Sender: TObject);
var
  I, lIndex: Integer;
  lFileName, lInitialDir: string;
  lDisableUnmarked, lDeleteUnmarked: Boolean;
  lSelected, lPresent, lDeleteNames: TStringList;
  lDbSelected, lDbPresent: TStringList;
  lResult, lDbResult: TRecorderSqlSelectionTableResult;
  lInfos: TRecorderSqlDbSignalInfos;
  lRepository: TRecorderSqlDbRepository;
  lSignalsDeleted, lValuesDeleted: Int64;
begin
  with TOpenDialog.Create(Self) do
  try
    Filter := 'Таблицы (*.xlsx;*.ods;*.csv)|*.xlsx;*.ods;*.csv|Все файлы|*.*';
    lInitialDir := ExtractFileDir(ExcludeTrailingPathDelimiter(
      ExtractFileDir(fFileName)));
    InitialDir := lInitialDir;
    if not Execute then Exit;
    lFileName := FileName;
  finally
    Free;
  end;
  if not ShowRecorderSqlSelectionImportDialog(Self, lDisableUnmarked,
    lDeleteUnmarked) then Exit;

  lSelected := TStringList.Create;
  lPresent := TStringList.Create;
  lDeleteNames := TStringList.Create;
  lDbSelected := TStringList.Create;
  lDbPresent := TStringList.Create;
  try
    lSelected.CaseSensitive := False;
    lSelected.Sorted := True;
    lSelected.Duplicates := dupIgnore;
    lPresent.CaseSensitive := False;
    lPresent.Sorted := True;
    lPresent.Duplicates := dupIgnore;
    lDeleteNames.CaseSensitive := False;
    lDeleteNames.Sorted := True;
    lDeleteNames.Duplicates := dupIgnore;
    lDbSelected.CaseSensitive := False;
    lDbSelected.Sorted := True;
    lDbSelected.Duplicates := dupIgnore;
    lDbPresent.CaseSensitive := False;
    lDbPresent.Sorted := True;
    lDbPresent.Duplicates := dupIgnore;

    ReadRecorderSqlSelectionFromTable(fRegistry, lFileName, lSelected,
      lPresent, lResult);
    ReadRecorderSqlSignalNamesFromTable(lFileName, lDbSelected, lDbPresent,
      lDbResult);
    SyncVisibleSignalChecks;
    for I := 0 to lSelected.Count - 1 do
      if (fAllSignals.IndexOf(lSelected[I]) >= 0) and
         (fCheckedSignals.IndexOf(lSelected[I]) < 0) then
        fCheckedSignals.Add(lSelected[I]);
    if lDisableUnmarked then
      for I := 0 to lPresent.Count - 1 do
        if lSelected.IndexOf(lPresent[I]) < 0 then
        begin
          lIndex := fCheckedSignals.IndexOf(lPresent[I]);
          if lIndex >= 0 then fCheckedSignals.Delete(lIndex);
        end;
    ApplySignalFilter;

    SyncVisibleDbSignalChecks;
    for I := 0 to lDbSelected.Count - 1 do
      if fSqlSourceSignals.IndexOf(lDbSelected[I]) < 0 then
        fSqlSourceSignals.Add(lDbSelected[I]);
    if lDisableUnmarked then
      for I := 0 to lDbPresent.Count - 1 do
        if lDbSelected.IndexOf(lDbPresent[I]) < 0 then
        begin
          lIndex := fSqlSourceSignals.IndexOf(lDbPresent[I]);
          if lIndex >= 0 then fSqlSourceSignals.Delete(lIndex);
        end;
    ApplyDbSignalFilter;

    lSignalsDeleted := 0;
    lValuesDeleted := 0;
    if lDeleteUnmarked then
    begin
      StoreControls;
      lRepository := TRecorderSqlDbRepository.Create(fConfig);
      try
        lRepository.ListSignalInfos(lInfos, False);
        for I := 0 to High(lInfos) do
          if (lPresent.IndexOf(lInfos[I].Name) >= 0) and
            (lSelected.IndexOf(lInfos[I].Name) < 0) then
            lDeleteNames.Add(lInfos[I].Name);
        if (lDeleteNames.Count > 0) and
          (MessageDlg('SQL БД', Format(
            'Удалить из БД невыбранные каналы таблицы: %d?',
            [lDeleteNames.Count]), mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
          lRepository.DeleteSignalsByName(lDeleteNames, lSignalsDeleted,
            lValuesDeleted)
        else
          lDeleteNames.Clear;
      finally
        lRepository.Free;
      end;
      if lDeleteNames.Count > 0 then
      begin
        TRecorderSqlDbProjectManager.RemoveSignals(fConfig, nil, lDeleteNames);
        fConfig.SaveToFile(fFileName);
        if Assigned(fOnSignalsDeleted) then fOnSignalsDeleted(lDeleteNames);
        btnReadDbSignalsClick(nil);
      end;
    end;

    MessageDlg('Импорт SQL', Format(
      'Строк: %d; найдено каналов: %d; отмечено SQLdb: %d; '+
      'не найдено на этом Recorder: %d.%sУдалено из БД каналов: %d, точек: %d.',
      [lResult.TotalRows, lResult.MatchedRows, lResult.MarkedRows,
       lResult.MissingRows, LineEnding, lSignalsDeleted, lValuesDeleted]),
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Ошибка импорта SQL', E.Message, mtError, [mbOK], 0);
  end;
  lDbPresent.Free;
  lDbSelected.Free;
  lDeleteNames.Free;
  lPresent.Free;
  lSelected.Free;
end;

procedure TRecorderSqlDbSettingsDialog.btnSelectAllClick(Sender: TObject);
var I, lIndex: Integer; lSelect: Boolean;
begin
  lSelect := False;
  for I := 0 to lvSignals.Items.Count - 1 do
    if not lvSignals.Items[I].Checked then
    begin
      lSelect := True;
      Break;
    end;
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lvSignals.Items[I].Checked := lSelect;
    lIndex := fCheckedSignals.IndexOf(lvSignals.Items[I].Caption);
    if lSelect and (lIndex < 0) then
      fCheckedSignals.Add(lvSignals.Items[I].Caption)
    else if (not lSelect) and (lIndex >= 0) then
      fCheckedSignals.Delete(lIndex);
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

procedure TRecorderSqlDbSettingsDialog.btnToggleAlarmEventClick(
  Sender: TObject);
var
  I, lIndex: Integer;
  lEnable: Boolean;
  lItem: TListItem;
begin
  lEnable := False;
  for I := 0 to lvSignals.Items.Count - 1 do
    if lvSignals.Items[I].Selected and
      (fAlarmSignals.IndexOf(lvSignals.Items[I].Caption) < 0) then
    begin
      lEnable := True;
      Break;
    end;
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lItem := lvSignals.Items[I];
    if not lItem.Selected then Continue;
    lIndex := fAlarmSignals.IndexOf(lItem.Caption);
    if lEnable then
    begin
      if lIndex < 0 then fAlarmSignals.Add(lItem.Caption);
      lItem.SubItems[1] := 'Да';
    end
    else
    begin
      if lIndex >= 0 then fAlarmSignals.Delete(lIndex);
      lItem.SubItems[1] := 'Нет';
    end;
  end;
end;

function TryDiscoverServerDatabase(const AHost: string; out APath, AError: string): Boolean;
var
  C: TFPHTTPClient;
  Data: TJSONData;
  I: Integer;
begin
  Result := False;
  APath := '';
  AError := '';
  for I := 1 to Length(AHost) do
    if not (AHost[I] in ['a'..'z', 'A'..'Z', '0'..'9', '.', '-']) then
    begin AError := 'Некорректный адрес сервера.'; Exit; end;
  C := TFPHTTPClient.Create(nil);
  try
    C.ConnectTimeout := 2000;
    C.IOTimeout := 2000;
    try
      Data := GetJSON(C.Get('http://' + AHost + ':8766/api/v1/status'));
      try
        if Data is TJSONObject then
          APath := Trim(TJSONObject(Data).Get('sql_local_database', ''));
      finally
        Data.Free;
      end;
      Result := APath <> '';
      if not Result then AError := 'Сервер не сообщил путь своей базы.';
    except
      on E: Exception do AError := E.Message;
    end;
  finally
    C.Free;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnOkClick(Sender: TObject);
var
  lPath, lError: string;
begin
  if (cbBackend.ItemIndex = Ord(rsbFirebird)) and
    (not RecorderSqlDbHostIsLocal(Trim(edHost.Text))) and
    (Trim(edDatabase.Text) = '') then
  begin
    if TryDiscoverServerDatabase(Trim(edHost.Text), lPath, lError) then
    begin
      edDatabase.Text := lPath;
      if not TryOpenCurrentDatabase(lError) then
      begin
        MessageDlg('SQL БД', 'Путь получен: ' + lPath + LineEnding +
          'Не удалось подключиться к базе: ' + lError, mtError, [mbOK], 0);
        Exit;
      end;
    end
    else begin
    MessageDlg('SQL БД', 'Не удалось получить путь базы с сервера: ' + lError + LineEnding +
      'Укажите путь к файлу базы на выбранном сервере. ' +
      'Это путь на сервере, например /mnt/sda1/base/firebird/recorderlnx.fdb. ' +
      'Если путь неизвестен, задайте сервер через RCPanel, когда сервер и RecorderLnx доступны.',
      mtWarning, [mbOK], 0);
    edDatabase.SetFocus;
    Exit;
    end;
  end;
  try
    StoreControls;
    fConfig.SaveToFile(fFileName);
    ModalResult := mrOk;
  except
    on E: Exception do MessageDlg('SQL БД', E.Message, mtError, [mbOK], 0);
  end;
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

function ShowRecorderSqlDataSourceSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry;
  out AConnectionError: string): Boolean;
var
  D: TRecorderSqlDbSettingsDialog;
begin
  AConnectionError := '';
  D := TRecorderSqlDbSettingsDialog.Create(AOwner);
  try
    D.LoadConfig(AFileName, ARegistry);
    { Initial loading is a status probe, not a user command.  Keep an
      unavailable SQL source editable and report its state to the device tree
      instead of opening a modal error dialog. }
    D.TryReadDbSignals(AConnectionError);
    D.fChannelPages.ActivePage := D.fDbSignalsTab;
    Result := D.ShowModal = mrOk;
    if Result then D.btnCreateSqlSourceClick(nil);
  finally
    D.Free;
  end;
end;

end.
