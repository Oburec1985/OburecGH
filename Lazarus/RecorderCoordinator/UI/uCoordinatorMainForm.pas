unit uCoordinatorMainForm;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons, ComCtrls,
  Menus,
  ExtCtrls, Grids, DateTimePicker, Spin, fpjson, uCoordinatorModel,
  uCoordinatorConfig, uCoordinatorHttpServer, uCoordinatorSqlEventStore,
  uRecorderSqlDbTypes, uCoordinatorHostAgentClient, uCoordinatorBackup;

type

  { TCoordinatorMainForm }

  TCoordinatorMainForm = class(TForm)
    btnAddStorage: TButton;
    btnAddHost: TButton;
    btnDeleteHost: TButton;
    btnCommandStart: TBitBtn;
    btnCommandStartAll: TSpeedButton;
    btnCommandPreview: TBitBtn;
    btnCommandPreviewAll: TSpeedButton;
    btnCommandStop: TBitBtn;
    btnCommandStopAll: TSpeedButton;
    btnLaunchAll: TBitBtn;
    btnShutdownAll: TBitBtn;
    btnShutdownSelected: TBitBtn;
    btnSyncSdb: TButton;
    btnSyncSqlChannels: TButton;
    btnSetSqlPeriodAll: TButton;
    btnWakeAll: TBitBtn;
    btnWakeSelected: TBitBtn;
    btnDeleteEvent: TButton;
    btnSetDatabaseForAll: TButton;
    btnSetPrimarySdb: TButton;
    btnEditEvent: TButton;
    btnOpenEvent: TButton;
    btnRefreshEvents: TButton;
    btnRefresh: TSpeedButton;
    btnSave: TButton;
    btnTestStorage: TButton;
    btnLaunchSelected: TBitBtn;
    btnClaimRecorder: TButton;
    btnReleaseRecorder: TButton;
    cbCreateRecordingEvents: TCheckBox;
    cbSqlRecordingAll: TCheckBox;
    cbStartAllOnAnyRecording: TCheckBox;
    cbStorageKind: TComboBox;
    seSqlRecordPeriod: TSpinEdit;
    dtpEventsFrom: TDateTimePicker;
    dtpEventsTo: TDateTimePicker;
    edtEventWindow: TEdit;
    edtHostName: TEdit;
    edtDatabaseHost: TEdit;
    edtSelectedHost: TEdit;
    edtStorageHost: TEdit;
    edtStorageName: TEdit;
    edtStoragePath: TEdit;
    edtStorageUser: TEdit;
    gridEvents: TStringGrid;
    gridHosts: TStringGrid;
    gridStorages: TStringGrid;
    ilCommandButtons: TImageList;
    lblEventWindow: TLabel;
    lblEventsFrom: TLabel;
    lblEventsTo: TLabel;
    lblHostName: TLabel;
    lblDatabaseHost: TLabel;
    lblSelectedHost: TLabel;
    lblStorageHost: TLabel;
    lblStorageKind: TLabel;
    lblStorageName: TLabel;
    lblStoragePath: TLabel;
    lblStorageUser: TLabel;
    lblSqlRecordPeriod: TLabel;
    memoLog: TMemo;
    pageMain: TPageControl;
    pnlHostActions: TPanel;
    pnlHostCommands: TPanel;
    pnlEventFilter: TPanel;
    pnlService: TPanel;
    tabEvents: TTabSheet;
    tabHosts: TTabSheet;
    tabLog: TTabSheet;
    tabStorages: TTabSheet;
    timerRefresh: TTimer;
    procedure btnAddStorageClick(Sender: TObject);
    procedure btnAddHostClick(Sender: TObject);
    procedure AddHostMenuItemClick(Sender: TObject);
    procedure btnDeleteHostClick(Sender: TObject);
    procedure btnCommandStartClick(Sender: TObject);
    procedure btnCommandStartAllClick(Sender: TObject);
    procedure btnCommandPreviewClick(Sender: TObject);
    procedure btnCommandPreviewAllClick(Sender: TObject);
    procedure btnCommandStopClick(Sender: TObject);
    procedure btnCommandStopAllClick(Sender: TObject);
    procedure btnLaunchAllClick(Sender: TObject);
    procedure btnLaunchSelected_Click(Sender: TObject);
    procedure btnClaimRecorderClick(Sender: TObject);
    procedure btnReleaseRecorderClick(Sender: TObject);
    procedure btnShutdownAllClick(Sender: TObject);
    procedure btnShutdownSelectedClick(Sender: TObject);
    procedure btnWakeAllClick(Sender: TObject);
    procedure btnWakeSelectedClick(Sender: TObject);
    procedure btnDeleteEventClick(Sender: TObject);
    procedure btnSetDatabaseForAllClick(Sender: TObject);
    procedure btnSetPrimarySdbClick(Sender: TObject);
    procedure btnSyncSdbClick(Sender: TObject);
    procedure btnSyncSqlChannelsClick(Sender: TObject);
    procedure btnSetSqlPeriodAllClick(Sender: TObject);
    procedure btnEditEventClick(Sender: TObject);
    procedure btnOpenEventClick(Sender: TObject);
    procedure btnRefreshEventsClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnTestStorageClick(Sender: TObject);
    procedure cbCreateRecordingEventsChange(Sender: TObject);
    procedure cbSqlRecordingAllChange(Sender: TObject);
    procedure cbStartAllOnAnyRecordingChange(Sender: TObject);
    procedure dtpEventsToChange(Sender: TObject);
    procedure edtSelectedHostChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gridHostsDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridHostsDblClick(Sender: TObject);
    procedure gridHostsSelection(Sender: TObject; aCol, aRow: Integer);
    procedure gridEventsSelection(Sender: TObject; aCol, aRow: Integer);
    procedure gridStoragesSelection(Sender: TObject; aCol, aRow: Integer);
    procedure timerRefreshTimer(Sender: TObject);
  private
    fModel: TCoordinatorModel;
    fConfig: TCoordinatorConfig;
    fServer: TCoordinatorHttpServer;
    fSqlEventStore: TCoordinatorSqlEventStore;
    fLoading: Boolean;
    fRefreshingHosts: Boolean;
    fHostEditorDirty: Boolean;
    fSqlEvents: TRecorderSqlDbMeraEvents;
    fEventsToFollowsNow: Boolean;
    fEditorHostId: string;
    fSdbSyncRunning: Boolean;
    fBackupRunning: Boolean;
    fBackupButton: TButton;
    fSdbConfigRequestPending: Boolean;
    fSdbConfigResponsesReady: Boolean;
    fSdbConfigRequestedAt: QWord;
    fSqlAllowedGetCommandId: string;
    fSqlAllowedStopCorrelation: string;
    fPendingSqlAllowedNames: TStringList;
    procedure AddLog(const AText: string);
    procedure CreateHostContextMenu;
    procedure DrainBackgroundDiagnostics;
    procedure ApplyServiceSettings;
    procedure ApplyStorageEditor;
    procedure LoadStorageEditor;
    procedure RefreshEvents;
    procedure RefreshHosts;
    procedure RefreshStorages;
    procedure SendCommand(const AName: string);
    procedure SendCommandTo(const AHostId, AName: string;
      const APayloadJson: string = '');
    function EnqueueCommandTo(const AHostId, AName: string;
      const APayloadJson: string = ''): string;
    procedure AdvanceSqlAllowedSync;
    procedure SynchronizeAllowedSqlChannels(AAllowedNames: TStrings);
    procedure FinishAllowedSqlChannelSync;
    procedure StartHostAction(const AAddress: string;
      AAction: TCoordinatorHostAgentAction);
    function ClaimHost(AHost: TJSONObject): Boolean;
    procedure HostActionCompleted(Sender: TObject;
      AAction: TCoordinatorHostAgentAction;
      const AHost, AResponse: string; AHttpStatus: Integer;
      const AError: string);
    procedure StartAllHostActions(AAction: TCoordinatorHostAgentAction);
    function WakeHost(AHost: TJSONObject): Boolean;
    function DefaultFirebirdHost: string;
    procedure UpdateSelectedHost;
    procedure UpdateHostEditorMode;
    function EditorHost: TJSONObject;
    function StoreRecordingLifecycle(
      const AInfo: TCoordinatorRecordingLifecycle): string;
    function TryStartService(out AError: string): Boolean;
    function SelectedHostId: string;
    function SelectedEventIndex: Integer;
    function SelectedStorage: TStorageConfig;
    procedure ShowSelectedEvent;
    procedure SdbSyncCompleted(Sender: TObject; const AReport, AError: string);
    procedure BackupButtonClick(Sender: TObject);
    procedure BackupCompleted(Sender: TObject; const AReport, AError: string);
    procedure BackupCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SetSelectedHostAsSdbPrimary;
    procedure UpdateEventButtons;
  end;

var
  CoordinatorMainForm: TCoordinatorMainForm;

implementation

{$R *.lfm}

uses
  DateUtils, IniFiles, uRecorderSqlDbRepository, uRecorderMeraEventDialog,
  uRecorderNetworkBinding, uSharedFileLogger, uCoordinatorWakeOnLan,
  uCoordinatorVersion, uCoordinatorSdbSync, uCoordinatorBackupDialog;

function TCoordinatorMainForm.DefaultFirebirdHost: string;
var
  lSqlConfig: TRecorderSqlDbConfig;
begin
  Result := Trim(fConfig.FirebirdHost);
  if Result <> '' then Exit;
  lSqlConfig := TRecorderSqlDbConfig.Create;
  try
    lSqlConfig.LoadFromFile(fConfig.SqlDbConfigFile);
    Result := Trim(lSqlConfig.Host);
  finally
    lSqlConfig.Free;
  end;
  if Result <> '' then Exit;
  Result := CRecorderFirebirdDefaultHost;
end;

procedure TCoordinatorMainForm.BackupCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not fBackupRunning;
  if not CanClose then
    MessageDlg('Резервное копирование',
      'Дождитесь окончания резервного копирования.', mtInformation, [mbOK], 0);
end;

procedure TCoordinatorMainForm.BackupCompleted(Sender: TObject;
  const AReport, AError: string);
begin
  fBackupRunning := False;
  fBackupButton.Enabled := True;
  fBackupButton.Caption := 'Резервная копия';
  AddLog('Резервное копирование: ' + AReport);
  if AError = '' then
    MessageDlg('Резервное копирование', AReport, mtInformation, [mbOK], 0)
  else
    MessageDlg('Резервное копирование', AError + LineEnding + AReport,
      mtError, [mbOK], 0);
end;

procedure TCoordinatorMainForm.BackupButtonClick(Sender: TObject);
const
  CConfigRemote = '/srv/recorderlnx/MeraFiles/RecorderLnx';
  CShareNames: array[0..3] of string =
    ('config', 'RecorderProjects', 'Calibr', 'SDB');
  CDestNames: array[0..3] of string = ('app-config', 'projects', 'Calibr', 'SDB');
var
  lData: TJSONArray;
  lItem: TJSONObject;
  lVisible: TCoordinatorBackupHostArray;
  lHosts: TBackupHosts;
  lSelection: TStringList;
  lDialogOptions: TCoordinatorBackupOptions;
  lOptions: TBackupOptions;
  lAddress, lBase, lId: string;
  I, J, K: Integer;
begin
  if fBackupRunning then Exit;
  lData := fModel.HostsJson;
  lSelection := TStringList.Create;
  try
    SetLength(lVisible, 0);
    for I := 0 to lData.Count - 1 do
    begin
      lItem := lData.Objects[I];
      lAddress := Trim(lItem.Get('address', ''));
      lId := Trim(lItem.Get('instance_id', ''));
      if (lAddress = '') or (lId = '') or (Pos('/', lAddress) > 0) or
        (Pos('\', lAddress) > 0) or (Pos('..', lAddress) > 0) then Continue;
      {$IFDEF UNIX}
      lBase := IncludeTrailingPathDelimiter(GetUserDir) +
        '.local/share/rcpanel-backup-sources/' + lAddress;
      {$ENDIF}
      J := Length(lVisible);
      SetLength(lVisible, J + 1);
      lVisible[J].InstanceId := lId;
      lVisible[J].Address := lAddress;
      {$IFDEF UNIX}
      lVisible[J].Prepared := DirectoryExists(lBase);
      {$ELSE}
      lVisible[J].Prepared := True;
      {$ENDIF}
      lVisible[J].DisplayName := Trim(lItem.Get('host_name', ''));
      if lVisible[J].DisplayName = '' then lVisible[J].DisplayName := lAddress;
    end;
    if Length(lVisible) = 0 then
    begin
      MessageDlg('Резервное копирование',
        'Нет рабочих мест с настроенными источниками резервного копирования.',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    if not ShowCoordinatorBackupDialog(Self, lVisible, lDialogOptions,
      lSelection) then Exit;
    lOptions := [];
    if lDialogOptions.IncludeConfigs then Include(lOptions, boConfigurations);
    if lDialogOptions.IncludeCalibrations then Include(lOptions, boCalibrations);
    SetLength(lHosts, 0);
    for I := 0 to High(lVisible) do
    begin
      if lSelection.IndexOf(lVisible[I].InstanceId) < 0 then Continue;
      J := Length(lHosts);
      SetLength(lHosts, J + 1);
      lHosts[J].DisplayName := lVisible[I].DisplayName;
      lHosts[J].Address := lVisible[I].Address;
      lHosts[J].AgentPort := fConfig.HostAgentPort;
      lHosts[J].AgentToken := fConfig.HostAgentToken;
      {$IFDEF UNIX}
      lBase := IncludeTrailingPathDelimiter(GetUserDir) +
        '.local/share/rcpanel-backup-sources/' + lHosts[J].Address;
      lHosts[J].ConfigRoot := lBase + '/MeraFiles/RecorderLnx';
      lHosts[J].ProgramRoot := lBase + '/RecorderProgram';
      {$ELSE}
      lBase := '\\' + lHosts[J].Address;
      lHosts[J].ConfigRoot := lBase + '\MeraFiles\RecorderLnx';
      lHosts[J].ProgramRoot := lBase + '\RecorderProgram';
      {$ENDIF}
      lHosts[J].ConfigRootRemote := CConfigRemote;
      SetLength(lHosts[J].ConfigRoots, Length(CShareNames));
      for K := 0 to High(CShareNames) do
      begin
        lHosts[J].ConfigRoots[K].DestinationName := CDestNames[K];
        if K = 0 then
          lHosts[J].ConfigRoots[K].SourcePath :=
            IncludeTrailingPathDelimiter(lHosts[J].ConfigRoot) + 'config'
        else
          lHosts[J].ConfigRoots[K].SourcePath :=
            IncludeTrailingPathDelimiter(lBase) + CShareNames[K];
        lHosts[J].ConfigRoots[K].RemotePath := '';
      end;
    end;
    fBackupRunning := True;
    fBackupButton.Enabled := False;
    fBackupButton.Caption := 'Копирование...';
    try
      StartCoordinatorBackup(lDialogOptions.Destination, lHosts, lOptions,
        @BackupCompleted);
      AddLog('Резервное копирование запущено: ' + lDialogOptions.Destination);
    except
      fBackupRunning := False;
      fBackupButton.Enabled := True;
      fBackupButton.Caption := 'Резервная копия';
      raise;
    end;
  finally
    lSelection.Free;
    lData.Free;
  end;
end;

function TCoordinatorMainForm.TryStartService(out AError: string): Boolean;
begin
  fServer.Start(fConfig.ListenAddress, fConfig.Port);
  AError := Trim(fServer.LastError);
  Result := AError = '';
end;

procedure TCoordinatorMainForm.FormCreate(Sender: TObject);
var
  lError: string;
begin
  Caption := CoordinatorWindowCaption;
  fBackupButton := TButton.Create(Self);
  fBackupButton.Parent := pnlService;
  fBackupButton.SetBounds(pnlService.ClientWidth - 170, 9, 158, 28);
  fBackupButton.Anchors := [akTop, akRight];
  fBackupButton.Caption := 'Резервная копия';
  fBackupButton.OnClick := @BackupButtonClick;
  OnCloseQuery := @BackupCloseQuery;
  fModel := TCoordinatorModel.Create;
  fPendingSqlAllowedNames := TStringList.Create;
  fPendingSqlAllowedNames.CaseSensitive := False;
  fPendingSqlAllowedNames.Sorted := True;
  fPendingSqlAllowedNames.Duplicates := dupIgnore;
  fConfig := TCoordinatorConfig.Create(ChangeFileExt(Application.ExeName, '.ini'));
  fConfig.Load;
  if not fConfig.ControlIdentityPersistent then
    AddLog('Не удалось сохранить идентификатор RCPanel в INI. ' +
      'Проверьте права записи к файлу настроек; текущий сеанс доступен.');
  fModel.EventWindowSec := fConfig.EventWindowSec;
  fModel.CreateRecordingEvents := fConfig.CreateRecordingEvents;
  fModel.StartAllOnAnyRecording := fConfig.StartAllOnAnyRecording;
  fSqlEventStore := TCoordinatorSqlEventStore.Create(fConfig.SqlDbConfigFile);
  fModel.OnRecordingLifecycle := @StoreRecordingLifecycle;
  fServer := TCoordinatorHttpServer.Create(fModel, fConfig.HostAgentPort,
    fConfig.HostAgentToken);
  fServer.ConfigureControl(fConfig.CoordinatorId, fConfig.CoordinatorToken);
  CreateHostContextMenu;
  edtEventWindow.Text := IntToStr(fConfig.EventWindowSec);
  edtDatabaseHost.Text := DefaultFirebirdHost;
  fLoading := True;
  cbCreateRecordingEvents.Checked := fConfig.CreateRecordingEvents;
  cbStartAllOnAnyRecording.Checked := fConfig.StartAllOnAnyRecording;
  fLoading := False;
  cbCreateRecordingEvents.Hint := 'SQL: ' + fConfig.SqlDbConfigFile;
  fLoading := True;
  dtpEventsFrom.DateTime := Now - 1;
  dtpEventsTo.DateTime := Now;
  fEventsToFollowsNow := True;
  fLoading := False;
  btnEditEvent.Enabled := False;
  btnOpenEvent.Enabled := False;
  btnDeleteEvent.Enabled := False;
  RefreshStorages;
  if TryStartService(lError) then
    AddLog('Запуск HTTP API: ' + fConfig.ListenAddress + ':' + IntToStr(fConfig.Port))
  else
  begin
    AddLog('Не удалось запустить HTTP API: ' + lError);
    MessageDlg('Сервис Recorder Coordinator',
      'Не удалось открыть ' + fConfig.ListenAddress + ':' +
      IntToStr(fConfig.Port) + LineEnding + lError,
      mtError, [mbOK], 0);
  end;
end;

procedure TCoordinatorMainForm.FormDestroy(Sender: TObject);
begin
  fPendingSqlAllowedNames.Free;
  fServer.Free;
  fModel.OnRecordingLifecycle := nil;
  fSqlEventStore.Free;
  fConfig.Free;
  fModel.Free;
end;

function TCoordinatorMainForm.StoreRecordingLifecycle(
  const AInfo: TCoordinatorRecordingLifecycle): string;
begin
  Result := fSqlEventStore.HandleLifecycle(AInfo);
end;

procedure TCoordinatorMainForm.AddLog(const AText: string);
begin
  SharedLogger.Info('GUI ' + AText);
  memoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' ' + AText);
end;

procedure TCoordinatorMainForm.DrainBackgroundDiagnostics;
var
  lIndex: Integer;
  lItems: TStringList;
  lRefreshEvents: Boolean;
begin
  lRefreshEvents := False;
  lItems := TStringList.Create;
  try
    fModel.DrainDiagnostics(lItems);
    fSqlEventStore.DrainDiagnostics(lItems);
    for lIndex := 0 to lItems.Count - 1 do
    begin
      AddLog(lItems[lIndex]);
      if Pos('SQL event подтверждён чтением:', lItems[lIndex]) > 0 then
        lRefreshEvents := True;
    end;
  finally
    lItems.Free;
  end;
  if lRefreshEvents and (pageMain.ActivePage = tabEvents) then RefreshEvents;
end;

procedure TCoordinatorMainForm.ApplyServiceSettings;
begin
  fConfig.FirebirdHost := Trim(edtDatabaseHost.Text);
  fConfig.CreateRecordingEvents := cbCreateRecordingEvents.Checked;
  fConfig.StartAllOnAnyRecording := cbStartAllOnAnyRecording.Checked;
  fConfig.EventWindowSec := StrToIntDef(edtEventWindow.Text, 30);
  if fConfig.EventWindowSec < 1 then fConfig.EventWindowSec := 1;
  edtEventWindow.Text := IntToStr(fConfig.EventWindowSec);
  fModel.EventWindowSec := fConfig.EventWindowSec;
  fModel.CreateRecordingEvents := fConfig.CreateRecordingEvents;
  fModel.StartAllOnAnyRecording := fConfig.StartAllOnAnyRecording;
end;

procedure TCoordinatorMainForm.cbStartAllOnAnyRecordingChange(Sender: TObject);
begin
  if fLoading or (fConfig = nil) then Exit;
  fConfig.StartAllOnAnyRecording := cbStartAllOnAnyRecording.Checked;
  fModel.StartAllOnAnyRecording := fConfig.StartAllOnAnyRecording;
  fConfig.Save;
  if cbStartAllOnAnyRecording.Checked then
    AddLog('Автозапуск остальных RecorderLnx включён')
  else
    AddLog('Автозапуск остальных RecorderLnx выключен');
end;

procedure TCoordinatorMainForm.cbCreateRecordingEventsChange(Sender: TObject);
begin
  if fLoading or (fConfig = nil) or (fModel = nil) then Exit;
  ApplyServiceSettings;
  fConfig.Save;
  if cbCreateRecordingEvents.Checked then
    AddLog('Создание SQL-событий записи включено')
  else
    AddLog('Создание SQL-событий записи выключено');
end;

function PcConnectionCaption(const AState: string): string;
begin
  if SameText(AState, 'checking') then
    Result := 'проверка...'
  else if SameText(AState, 'reachable') then
    Result := 'доступен'
  else if SameText(AState, 'unreachable') then
    Result := 'нет связи'
  else
    Result := 'не проверено';
end;

function AgentConnectionCaption(const AState: string): string;
begin
  if SameText(AState, 'checking') then
    Result := 'проверка...'
  else if SameText(AState, 'reachable') then
    Result := 'доступен'
  else if SameText(AState, 'unreachable') then
    Result := 'нет связи'
  else
    Result := 'не проверен';
end;

function CommandResultCaption(AItem: TJSONObject): string;
var
  lName, lState, lCode: string;
begin
  lName := AItem.Get('last_command', '');
  if lName = '' then Exit('нет команды');
  if SameText(lName, 'config.sql_database.set') then lName := 'База данных'
  else if SameText(lName, 'config.sql_recording.set') then lName := 'SQL-запись'
  else if SameText(lName, 'config.sql_allowed_channels.get') then
    lName := 'Чтение SQL-каналов'
  else if SameText(lName, 'config.sql_allowed_channels.set') then
    lName := 'Разрешённые SQL-каналы'
  else if SameText(lName, 'recording.start') then lName := 'Запуск записи'
  else if SameText(lName, 'recording.stop') then lName := 'Остановка записи'
  else if SameText(lName, 'recording.preview') then lName := 'Просмотр';
  lState := AItem.Get('last_command_state', '');
  lCode := AItem.Get('last_command_result', '');
  if SameText(lState, 'accepted') and SameText(lCode, 'notReady') then
    Result := 'ожидает готовности'
  else if SameText(lState, 'pending') then
    Result := 'ожидает доставки'
  else if SameText(lState, 'accepted') then
    Result := 'выполняется'
  else if SameText(lCode, 'noError') and SameText(lState, 'completed') then
    Result := 'выполнена'
  else if lCode <> '' then
    Result := 'ошибка: ' + lCode
  else
    Result := 'нет подтверждения';
  Result := lName + ': ' + Result;
end;

procedure TCoordinatorMainForm.RefreshHosts;
var
  lData: TJSONArray;
  lItem: TJSONObject;
  lIndex: Integer;
begin
  lData := fModel.HostsJson;
  fRefreshingHosts := True;
  try
    gridHosts.RowCount := lData.Count + 1;
    for lIndex := 0 to lData.Count - 1 do
    begin
      lItem := lData.Objects[lIndex];
      gridHosts.Cells[1, lIndex + 1] := lItem.Get('instance_id', '');
      gridHosts.Cells[2, lIndex + 1] := lItem.Get('address', '');
      gridHosts.Cells[3, lIndex + 1] := lItem.Get('host_name', '');
      gridHosts.Cells[6, lIndex + 1] := lItem.Get('mac_address', '');
      gridHosts.Cells[7, lIndex + 1] := PcConnectionCaption(
        lItem.Get('pc_connection_state', 'unknown'));
      gridHosts.Cells[8, lIndex + 1] := AgentConnectionCaption(
        lItem.Get('agent_connection_state', 'unknown'));
      gridHosts.Cells[9, lIndex + 1] := lItem.Get('state', '');
      gridHosts.Cells[10, lIndex + 1] := lItem.Get('measurement_path', '');
      gridHosts.Cells[11, lIndex + 1] := lItem.Get('last_seen_utc', '');
      gridHosts.Cells[12, lIndex + 1] := lItem.Get('mera_files_path', '');
      if (lItem.Get('control_owner', '') <> '') and
         (lItem.Get('control_owner', '') <> fServer.ControlId) then
        gridHosts.Cells[4, lIndex + 1] := 'другая панель'
      else if lItem.Get('recorder_reachable', False) then
        gridHosts.Cells[4, lIndex + 1] := 'подключён'
      else if lItem.Get('control_owner', '') = '' then
        gridHosts.Cells[4, lIndex + 1] := 'не захвачен'
      else
        gridHosts.Cells[4, lIndex + 1] := 'нет связи';
      gridHosts.Cells[5, lIndex + 1] := CommandResultCaption(lItem);
      if SameText(lItem.Get('instance_id', ''), fConfig.SdbPrimaryHostId) then
        gridHosts.Cells[13, lIndex + 1] := '●'
      else
        gridHosts.Cells[13, lIndex + 1] := '';
      gridHosts.Cells[0, lIndex + 1] := '';
      gridHosts.InvalidateCell(0, lIndex + 1);
    end;
    gridHosts.Update;
  finally
    fRefreshingHosts := False;
    lData.Free;
  end;
  UpdateSelectedHost;
end;

procedure TCoordinatorMainForm.RefreshEvents;
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lFromUtc, lToUtc: TDateTime;
  lIndex: Integer;
begin
  if fEventsToFollowsNow then
  begin
    fLoading := True;
    try
      dtpEventsTo.DateTime := Now;
    finally
      fLoading := False;
    end;
  end;
  lFromUtc := LocalTimeToUniversal(dtpEventsFrom.DateTime);
  lToUtc := LocalTimeToUniversal(dtpEventsTo.DateTime);
  AddLog(Format(
    'Обновление событий: config=%s; local=%s .. %s; UTC=%s .. %s',
    [fConfig.SqlDbConfigFile,
     FormatDateTime('yyyy-mm-dd hh:nn:ss', dtpEventsFrom.DateTime),
     FormatDateTime('yyyy-mm-dd hh:nn:ss', dtpEventsTo.DateTime),
     JsonDateTime(lFromUtc), JsonDateTime(lToUtc)]));
  if lFromUtc > lToUtc then
  begin
    MessageDlg('События записи',
      'Начало интервала должно быть раньше его окончания.',
      mtWarning, [mbOK], 0);
    Exit;
  end;

  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  try
    try
      lConfig.LoadFromFile(fConfig.SqlDbConfigFile);
      lRepository := TRecorderSqlDbRepository.Create(lConfig);
      lRepository.ListMeraRecordingEvents(lFromUtc, lToUtc, fSqlEvents);
      AddLog(Format('Обновление событий: найдено %d; backend=%s; server=%s; database=%s',
        [Length(fSqlEvents), RecorderSqlDbBackendToString(lConfig.Backend),
         lConfig.Host, lConfig.DatabaseFileName]));
      for lIndex := 0 to High(fSqlEvents) do
        AddLog(Format('SQL event row: id=%s; UTC=%s; замеров=%d; state=%s',
          [fSqlEvents[lIndex].EventId,
           JsonDateTime(fSqlEvents[lIndex].StartedAtUtc),
           fSqlEvents[lIndex].PackageCount, fSqlEvents[lIndex].State]));
    except
      on E: Exception do
      begin
        SetLength(fSqlEvents, 0);
        AddLog('Обновление событий ERROR: ' + E.ClassName + ': ' + E.Message);
        MessageDlg('События записи', 'Ошибка чтения SQL БД:' + LineEnding +
          E.Message, mtError, [mbOK], 0);
      end;
    end;

    gridEvents.RowCount := Length(fSqlEvents) + 1;
    for lIndex := 0 to High(fSqlEvents) do
    begin
      gridEvents.Cells[0, lIndex + 1] := fSqlEvents[lIndex].DisplayName;
      gridEvents.Cells[1, lIndex + 1] := FormatDateTime('dd.mm.yyyy hh:nn:ss',
        UniversalTimeToLocal(fSqlEvents[lIndex].StartedAtUtc));
      gridEvents.Cells[2, lIndex + 1] := fSqlEvents[lIndex].State;
      gridEvents.Cells[3, lIndex + 1] := IntToStr(fSqlEvents[lIndex].PackageCount);
      gridEvents.Cells[4, lIndex + 1] :=
        FormatFloat('#,##0', fSqlEvents[lIndex].TotalSize);
      gridEvents.Cells[5, lIndex + 1] := fSqlEvents[lIndex].EventId;
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
  UpdateEventButtons;
end;

procedure TCoordinatorMainForm.dtpEventsToChange(Sender: TObject);
begin
  if not fLoading then fEventsToFollowsNow := False;
end;

function TCoordinatorMainForm.SelectedEventIndex: Integer;
begin
  Result := gridEvents.Row - 1;
  if (Result < 0) or (Result > High(fSqlEvents)) then Result := -1;
end;

procedure TCoordinatorMainForm.gridEventsSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
  UpdateEventButtons;
end;

procedure TCoordinatorMainForm.UpdateEventButtons;
var
  lHasSelection, lCanDelete: Boolean;
begin
  lHasSelection := SelectedEventIndex >= 0;
  lCanDelete := lHasSelection and
    (not SameText(fSqlEvents[SelectedEventIndex].State, 'building'));
  btnEditEvent.Enabled := lHasSelection;
  btnOpenEvent.Enabled := lHasSelection;
  btnDeleteEvent.Enabled := lCanDelete;
  if lHasSelection and (not lCanDelete) then
    btnDeleteEvent.Hint := 'Дождитесь завершения записи перед удалением события.'
  else
    btnDeleteEvent.Hint := '';
  btnDeleteEvent.ShowHint := btnDeleteEvent.Hint <> '';
end;

procedure TCoordinatorMainForm.btnRefreshEventsClick(Sender: TObject);
begin
  RefreshEvents;
end;

procedure TCoordinatorMainForm.btnEditEventClick(Sender: TObject);
begin
  ShowSelectedEvent;
end;

procedure TCoordinatorMainForm.btnOpenEventClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := SelectedEventIndex;
  if lIndex < 0 then Exit;
  AddLog('Открытие замеров события ' + fSqlEvents[lIndex].EventId);
  ShowRecorderMeraEventDialog(Self, fConfig.SqlDbConfigFile,
    fSqlEvents[lIndex], nil, True);
  RefreshEvents;
end;

procedure TCoordinatorMainForm.ShowSelectedEvent;
var
  lIndex: Integer;
begin
  lIndex := SelectedEventIndex;
  if lIndex < 0 then Exit;
  ShowRecorderMeraEventDialog(Self, fConfig.SqlDbConfigFile, fSqlEvents[lIndex]);
  RefreshEvents;
end;

procedure TCoordinatorMainForm.btnDeleteEventClick(Sender: TObject);
var
  lConfig: TRecorderSqlDbConfig;
  lEvent: TRecorderSqlDbMeraEvent;
  lDeletedFiles, lDeletedPackages, lIndex: Integer;
  lRepository: TRecorderSqlDbRepository;
begin
  lIndex := SelectedEventIndex;
  if lIndex < 0 then Exit;
  lEvent := fSqlEvents[lIndex];
  if SameText(lEvent.State, 'building') then
  begin
    MessageDlg('Удаление события',
      'Событие ещё записывается. Дождитесь завершения записи перед удалением.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Удалить событие «' + lEvent.DisplayName + '» от ' +
    FormatDateTime('dd.mm.yyyy hh:nn:ss',
      UniversalTimeToLocal(lEvent.StartedAtUtc)) + '?' + LineEnding + LineEnding +
    'Будут удалены только записи SQL. Физические MERA-файлы останутся на дисках.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  try
    try
      lConfig.LoadFromFile(fConfig.SqlDbConfigFile);
      lRepository := TRecorderSqlDbRepository.Create(lConfig);
      AddLog('Запрошено удаление SQL-события ' + lEvent.EventId);
      if not lRepository.DeleteMeraEvent(lEvent.EventId,
        lDeletedPackages, lDeletedFiles) then
        raise Exception.Create('Событие не найдено или уже удалено.');
      AddLog(Format('Удалено SQL-событие %s; пакетов: %d; файлов: %d',
        [lEvent.EventId, lDeletedPackages, lDeletedFiles]));
      RefreshEvents;
    except
      on E: Exception do
      begin
        AddLog('Ошибка удаления SQL-события ' + lEvent.EventId + ': ' +
          E.ClassName + ': ' + E.Message);
        MessageDlg('Ошибка удаления события: ' + E.Message,
          mtError, [mbOK], 0);
      end;
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
end;

procedure TCoordinatorMainForm.RefreshStorages;
var
  lIndex: Integer;
  lStorage: TStorageConfig;
begin
  gridStorages.RowCount := fConfig.StorageCount + 2;
  gridStorages.Cells[0, 1] := 'База событий SQL';
  gridStorages.Cells[1, 1] := fSqlEventStore.BackendName;
  gridStorages.Cells[2, 1] := fSqlEventStore.DatabaseDisplay;
  gridStorages.Cells[3, 1] := fSqlEventStore.ServerDisplay;
  gridStorages.Hint := 'SQL config: ' + fSqlEventStore.ConfigFileName;
  gridStorages.ShowHint := True;
  for lIndex := 0 to fConfig.StorageCount - 1 do
  begin
    lStorage := fConfig.Storage(lIndex);
    gridStorages.Cells[0, lIndex + 2] := lStorage.Name;
    gridStorages.Cells[1, lIndex + 2] := lStorage.KindName;
    gridStorages.Cells[2, lIndex + 2] := lStorage.RootPath;
    gridStorages.Cells[3, lIndex + 2] := lStorage.Host;
  end;
  LoadStorageEditor;
end;

function TCoordinatorMainForm.SelectedStorage: TStorageConfig;
begin
  Result := nil;
  if (gridStorages.Row > 1) and
    (gridStorages.Row <= fConfig.StorageCount + 1) then
    Result := fConfig.Storage(gridStorages.Row - 2);
end;

procedure TCoordinatorMainForm.LoadStorageEditor;
var
  lBackendIndex: Integer;
  lStorage: TStorageConfig;
begin
  lStorage := SelectedStorage;
  edtStorageName.Enabled := lStorage <> nil;
  cbStorageKind.Enabled := lStorage <> nil;
  edtStoragePath.Enabled := lStorage <> nil;
  edtStorageHost.Enabled := lStorage <> nil;
  edtStorageUser.Enabled := lStorage <> nil;
  btnTestStorage.Enabled := lStorage <> nil;
  if lStorage = nil then
  begin
    if gridStorages.Row = 1 then
    begin
      edtStorageName.Text := 'База событий SQL';
      lBackendIndex := cbStorageKind.Items.IndexOf(fSqlEventStore.BackendName);
      if lBackendIndex < 0 then
        lBackendIndex := cbStorageKind.Items.Add(fSqlEventStore.BackendName);
      cbStorageKind.ItemIndex := lBackendIndex;
      edtStoragePath.Text := fSqlEventStore.DatabaseDisplay;
      edtStorageHost.Text := fSqlEventStore.ServerDisplay;
      edtStorageUser.Text := fSqlEventStore.UserName;
      edtStoragePath.Hint := 'SQL config: ' + fSqlEventStore.ConfigFileName;
      edtStoragePath.ShowHint := True;
    end
    else
    begin
      edtStorageName.Clear;
      cbStorageKind.ItemIndex := -1;
      edtStoragePath.Clear;
      edtStorageHost.Clear;
      edtStorageUser.Clear;
    end;
    Exit;
  end;
  edtStoragePath.Hint := '';
  edtStorageName.Text := lStorage.Name;
  cbStorageKind.ItemIndex := Ord(lStorage.Kind);
  edtStoragePath.Text := lStorage.RootPath;
  edtStorageHost.Text := lStorage.Host;
  edtStorageUser.Text := lStorage.UserName;
end;

procedure TCoordinatorMainForm.ApplyStorageEditor;
var lStorage: TStorageConfig;
begin
  lStorage := SelectedStorage;
  if lStorage = nil then Exit;
  lStorage.Name := Trim(edtStorageName.Text);
  if cbStorageKind.ItemIndex >= 0 then lStorage.Kind := TStorageKind(cbStorageKind.ItemIndex);
  lStorage.RootPath := Trim(edtStoragePath.Text);
  lStorage.Host := Trim(edtStorageHost.Text);
  lStorage.UserName := Trim(edtStorageUser.Text);
end;

procedure TCoordinatorMainForm.btnAddStorageClick(Sender: TObject);
begin
  fConfig.AddStorage;
  RefreshStorages;
  gridStorages.Row := fConfig.StorageCount + 1;
  LoadStorageEditor;
end;

procedure TCoordinatorMainForm.btnAddHostClick(Sender: TObject);
var
  lInput, lResult: TJSONObject;
  lHostId, lStoredId, lStoredName, lStoredAddress, lName: string;
  lPayload: TJSONObject;
begin
  lHostId := Trim(edtSelectedHost.Text);
  if lHostId = '' then
  begin
    MessageDlg('Добавление RecorderLnx',
      'Укажите стабильный Instance ID или сетевой адрес хоста.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lResult := EditorHost;
  try
    lStoredId := lResult.Get('instance_id', '');
    lStoredName := lResult.Get('host_name', '');
    lStoredAddress := lResult.Get('address', '');
  finally
    lResult.Free;
  end;
  if lStoredId <> '' then
  begin
    lName := Trim(edtHostName.Text);
    if lName <> lStoredName then
    begin
      if (lName = '') or (lHostId <> lStoredAddress) then
      begin
        MessageDlg('Имя АРМ',
          'Укажите непустое имя. Если меняется IP, сначала сохраните адрес.',
          mtWarning, [mbOK], 0);
        Exit;
      end;
      lInput := TJSONObject.Create;
      try
        lInput.Add('address', lStoredAddress);
        lInput.Add('command', 'workstation.name.set');
        lPayload := TJSONObject.Create;
        lInput.Add('payload', lPayload);
        lPayload.Add('name', lName);
        lPayload.Add('use_computer_name', False);
        lResult := fModel.EnqueueCommand(lInput);
        try
          if lResult.Get('command_id', '') = '' then
          begin
            MessageDlg('Имя АРМ', 'Захватите RecorderLnx на выбранном ПК и повторите.',
              mtWarning, [mbOK], 0);
            Exit;
          end;
          AddLog('Запрошена смена имени АРМ ' + lStoredAddress + ' на ' + lName);
        finally
          lResult.Free;
        end;
      finally
        lInput.Free;
      end;
      fHostEditorDirty := False;
      RefreshHosts;
      Exit;
    end;
    if not fModel.SetHostAddress(lStoredId, lHostId) then
    begin
      MessageDlg('Редактирование RecorderLnx',
        'Не удалось сохранить адрес выбранного хоста.',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    AddLog('RecorderLnx изменён: ' + lStoredId);
  end
  else
  begin
    fModel.RestoreIgnoredHost(lHostId, lHostId, '');
    lInput := TJSONObject.Create;
    try
      lInput.Add('instance_id', lHostId);
      lInput.Add('host_name', Trim(edtHostName.Text));
      lInput.Add('state', 'configured');
      lResult := fModel.RegisterHello(lInput);
      try
        if SameText(lResult.Get('result_code', ''), 'ignored') then
        begin
          MessageDlg('Добавление RecorderLnx',
            'Хост остался в списке игнорируемых и не был добавлен.',
            mtWarning, [mbOK], 0);
          Exit;
        end;
        AddLog('RecorderLnx добавлен: ' + lHostId);
      finally
        lResult.Free;
      end;
    finally
      lInput.Free;
    end;
  end;
  fHostEditorDirty := False;
  RefreshHosts;
end;

procedure TCoordinatorMainForm.btnDeleteHostClick(Sender: TObject);
var
  lAddress, lHostId, lHostName: string;
begin
  lHostId := SelectedHostId;
  if lHostId = '' then Exit;
  lAddress := gridHosts.Cells[2, gridHosts.Row];
  lHostName := gridHosts.Cells[3, gridHosts.Row];
  if MessageDlg('Удаление хоста',
    'Удалить и больше не обнаруживать хост «' + lHostName + '» (' +
    lAddress + ')?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  if not fModel.IgnoreHost(lHostId) then
  begin
    MessageDlg('Удаление хоста', 'Выбранный хост уже отсутствует.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  fEditorHostId := '';
  edtSelectedHost.Clear;
  edtHostName.Clear;
  fHostEditorDirty := False;
  RefreshHosts;
  AddLog('Хост удалён и добавлен в [ignored_hosts]: ' + lHostId);
end;

function TCoordinatorMainForm.EditorHost: TJSONObject;
var
  lHostKey: string;
begin
  if fEditorHostId <> '' then
  begin
    Result := fModel.HostByIdJson(fEditorHostId);
    if Result.Get('instance_id', '') <> '' then Exit;
    Result.Free;
  end;
  lHostKey := Trim(edtSelectedHost.Text);
  Result := fModel.HostByIdJson(lHostKey);
  if Result.Get('instance_id', '') <> '' then Exit;
  Result.Free;
  Result := fModel.HostByAddressJson(lHostKey);
end;

procedure TCoordinatorMainForm.UpdateHostEditorMode;
var
  lHost: TJSONObject;
begin
  if fLoading or (fModel = nil) then Exit;
  lHost := EditorHost;
  try
    if lHost.Get('instance_id', '') <> '' then
      btnAddHost.Caption := 'Редактировать'
    else
      btnAddHost.Caption := 'Добавить хост';
  finally
    lHost.Free;
  end;
end;

procedure TCoordinatorMainForm.edtSelectedHostChange(Sender: TObject);
begin
  if not fLoading then fHostEditorDirty := True;
  UpdateHostEditorMode;
end;

procedure TCoordinatorMainForm.btnSaveClick(Sender: TObject);
begin
  ApplyServiceSettings;
  ApplyStorageEditor;
  fConfig.Save;
  RefreshStorages;
  AddLog('Настройки сохранены: ' + fConfig.FileName);
end;

procedure TCoordinatorMainForm.btnTestStorageClick(Sender: TObject);
var lMessage: string;
begin
  ApplyStorageEditor;
  if fConfig.TestStorage(SelectedStorage, lMessage) then
    ShowMessage('Проверка успешна' + LineEnding + lMessage)
  else
    MessageDlg('Проверка не пройдена', lMessage, mtWarning, [mbOK], 0);
end;

function TCoordinatorMainForm.SelectedHostId: string;
begin
  if gridHosts.Row > 0 then Result := gridHosts.Cells[1, gridHosts.Row] else Result := '';
end;

procedure TCoordinatorMainForm.SendCommand(const AName: string);
begin
  SendCommandTo(SelectedHostId, AName);
end;

procedure TCoordinatorMainForm.SendCommandTo(const AHostId, AName: string;
  const APayloadJson: string);
begin
  EnqueueCommandTo(AHostId, AName, APayloadJson);
end;

function TCoordinatorMainForm.EnqueueCommandTo(const AHostId, AName: string;
  const APayloadJson: string): string;
var
  lInput, lResult: TJSONObject;
  lPayload: TJSONData;
  lId: TGuid;
  lCorrelation: string;
begin
  Result := '';
  if AHostId = '' then Exit;
  lInput := TJSONObject.Create;
  try
    lInput.Add('instance_id', AHostId);
    lInput.Add('command', AName);
    if Trim(APayloadJson) <> '' then
    begin
      lPayload := GetJSON(APayloadJson);
      lInput.Add('payload', lPayload);
    end;
    if SameText(AName, 'recording.start') then
    begin
      CreateGUID(lId);
      lCorrelation := GUIDToString(lId);
      lCorrelation := StringReplace(lCorrelation, '{', '', []);
      lCorrelation := StringReplace(lCorrelation, '}', '', []);
      lInput.Add('correlation_id', lCorrelation);
    end;
    lResult := fModel.EnqueueCommand(lInput);
    try
      Result := lResult.Get('command_id', '');
      if Result = '' then Result := lResult.Get('correlation_id', '');
      AddLog('Команда поставлена: ' + lResult.AsJSON);
    finally
      lResult.Free;
    end;
  finally lInput.Free; end;
end;

procedure TCoordinatorMainForm.btnSetDatabaseForAllClick(Sender: TObject);
var
  lHost: string;
  lPayload, lServer: TJSONObject;
  lSqlConfig: TRecorderSqlDbConfig;
begin
  lHost := Trim(edtDatabaseHost.Text);
  if lHost = '' then
  begin
    MessageDlg('Настройка Firebird',
      'Укажите LAN IPv4 компьютера, на котором работает Firebird.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lServer := fModel.HostByAddressJson(lHost);
  try
    if Trim(lServer.Get('sql_local_database', '')) = '' then
      AddLog('Путь БД сервера пока неизвестен. Подключите его Recorder к панели ' +
        'и повторите настройку.');
  finally
    lServer.Free;
  end;
  lSqlConfig := TRecorderSqlDbConfig.Create;
  try
    lSqlConfig.LoadFromFile(fConfig.SqlDbConfigFile);
    lPayload := TJSONObject.Create;
    try
      lPayload.Add('host', lHost);
      lPayload.Add('port', lSqlConfig.Port);
      fConfig.FirebirdHost := lHost;
      fConfig.Save;
      SendCommandTo('*', 'config.sql_database.set', lPayload.AsJSON);
    finally
      lPayload.Free;
    end;
  finally
    lSqlConfig.Free;
  end;
end;

procedure TCoordinatorMainForm.SetSelectedHostAsSdbPrimary;
var
  lHostId: string;
begin
  lHostId := SelectedHostId;
  if lHostId = '' then Exit;
  fConfig.SdbPrimaryHostId := lHostId;
  fConfig.Save;
  RefreshHosts;
  AddLog('Основной RecorderLnx для SDB: ' + gridHosts.Cells[2, gridHosts.Row]);
end;

procedure TCoordinatorMainForm.btnSetPrimarySdbClick(Sender: TObject);
begin
  SetSelectedHostAsSdbPrimary;
end;

procedure TCoordinatorMainForm.btnSyncSdbClick(Sender: TObject);
var
  lHosts: TJSONArray;
  lHost: TJSONObject;
  lRequest, lRequestResult, lRequestPayload: TJSONObject;
  lTargets, lMissingPaths: TStringList;
  lIndex: Integer;
  lPrimaryAddress, lPrimaryMeraFilesPath, lAddress, lMeraFilesPath: string;
begin
  if fSdbSyncRunning then Exit;
  if not fSdbConfigResponsesReady then
  begin
    fModel.ClearHostMeraFilesPaths;
    lRequest := TJSONObject.Create;
    lRequestPayload := TJSONObject.Create;
    try
      lRequest.Add('instance_id', '*');
      lRequest.Add('command', 'config.get');
      lRequest.Add('payload', lRequestPayload);
      lRequestPayload := nil;
      lRequestResult := fModel.EnqueueCommand(lRequest);
      try
        AddLog('Запрошены конфигурации RecorderLnx: ' +
          lRequestResult.AsJSON);
      finally
        lRequestResult.Free;
      end;
    finally
      lRequestPayload.Free;
      lRequest.Free;
    end;
    fSdbConfigRequestPending := True;
    fSdbConfigRequestedAt := GetTickCount64;
    btnSyncSdb.Enabled := False;
    Exit;
  end;
  fSdbConfigResponsesReady := False;
  if Trim(fConfig.SdbPrimaryHostId) = '' then
  begin
    MessageDlg('Синхронизация SDB',
      'Выберите основной RecorderLnx в таблице.', mtWarning, [mbOK], 0);
    Exit;
  end;
  lTargets := TStringList.Create;
  lMissingPaths := TStringList.Create;
  lHosts := fModel.HostsJson;
  try
    lTargets.CaseSensitive := False;
    lTargets.Sorted := True;
    lTargets.Duplicates := dupIgnore;
    for lIndex := 0 to lHosts.Count - 1 do
    begin
      lHost := lHosts.Objects[lIndex];
      if SameText(lHost.Get('instance_id', ''), fConfig.SdbPrimaryHostId) then
      begin
        lPrimaryAddress := Trim(lHost.Get('address', ''));
        lPrimaryMeraFilesPath := Trim(lHost.Get('mera_files_path', ''));
      end;
    end;
    for lIndex := 0 to lHosts.Count - 1 do
    begin
      lHost := lHosts.Objects[lIndex];
      lAddress := Trim(lHost.Get('address', ''));
      if (lAddress <> '') and (not SameText(lAddress, lPrimaryAddress)) then
      begin
        lMeraFilesPath := Trim(lHost.Get('mera_files_path', ''));
        if lMeraFilesPath = '' then
          lMissingPaths.Add(lAddress)
        else
          lTargets.Add(lAddress);
      end;
    end;
    if lPrimaryAddress = '' then
    begin
      MessageDlg('Синхронизация SDB',
        'У основного RecorderLnx не задан сетевой адрес.', mtWarning,
        [mbOK], 0);
      Exit;
    end;
    if lPrimaryMeraFilesPath = '' then
    begin
      MessageDlg('Синхронизация SDB',
        'Основной RecorderLnx ещё не передал каталог Mera Files через API.',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    if lMissingPaths.Count > 0 then
    begin
      MessageDlg('Синхронизация SDB',
        'Каталог Mera Files не получен от хостов: ' +
        StringReplace(Trim(lMissingPaths.CommaText), ',', ', ', [rfReplaceAll]) +
        '. Обновите и запустите RecorderLnx на этих ПК.', mtWarning,
        [mbOK], 0);
      Exit;
    end;
    if lTargets.Count = 0 then
    begin
      MessageDlg('Синхронизация SDB', 'Нет соседних хостов для копирования.',
        mtInformation, [mbOK], 0);
      Exit;
    end;
    if MessageDlg('Синхронизация SDB',
      Format('Скопировать SDB из каталога "%s" хоста %s на %d соседних ПК?',
        [lPrimaryMeraFilesPath, lPrimaryAddress, lTargets.Count]), mtConfirmation,
        [mbYes, mbNo], 0) <> mrYes then Exit;
    fSdbSyncRunning := True;
    btnSyncSdb.Enabled := False;
    AddLog('Запущена синхронизация SDB с ' + lPrimaryAddress);
    StartCoordinatorSdbSync(lPrimaryAddress, fConfig.SdbShareName,
      lTargets, @SdbSyncCompleted);
  finally
    lHosts.Free;
    lMissingPaths.Free;
    lTargets.Free;
  end;
end;

procedure TCoordinatorMainForm.btnSyncSqlChannelsClick(Sender: TObject);
var
  lDialog: TOpenDialog;
  lNames, lLines: TStringList;
  lIni: TIniFile;
  lIndex: Integer;
  lName: string;
begin
  if (fSqlAllowedGetCommandId <> '') or (fSqlAllowedStopCorrelation <> '') then Exit;
  lDialog := TOpenDialog.Create(Self);
  lNames := TStringList.Create;
  lLines := TStringList.Create;
  try
   try
    lDialog.Title := 'Выберите файл разрешённых SQL-каналов';
    lDialog.Filter := 'Список каналов (*.txt;*.ini)|*.txt;*.ini|Все файлы|*';
    lDialog.Options := lDialog.Options + [ofFileMustExist];
    if not lDialog.Execute then Exit;
    lNames.CaseSensitive := False;
    lNames.Sorted := True;
    lNames.Duplicates := dupIgnore;
    if SameText(ExtractFileExt(lDialog.FileName), '.ini') then
    begin
      lIni := TIniFile.Create(lDialog.FileName);
      try
        if not lIni.ReadBool('SQLdb', 'AllowedSignalSelectionConfigured', False) then
          raise Exception.Create('В файле не настроен список разрешённых SQL-каналов.');
        lIni.ReadSection('SQLdbAllowedSignals', lNames);
      finally
        lIni.Free;
      end;
    end
    else
    begin
      lLines.LoadFromFile(lDialog.FileName);
      for lIndex := 0 to lLines.Count - 1 do
      begin
        lName := Trim(lLines[lIndex]);
        if (lIndex = 0) and (Copy(lName, 1, 3) = #$EF#$BB#$BF) then
          Delete(lName, 1, 3);
        if (lName <> '') and (lName[1] <> '#') then lNames.Add(lName);
      end;
    end;
    if lNames.Count = 0 then
      raise Exception.Create('Список пуст. Выберите файл с названиями каналов.');
    AddLog(Format('Загружен файл разрешённых SQL-каналов: %s (%d)',
      [lDialog.FileName, lNames.Count]));
    SynchronizeAllowedSqlChannels(lNames);
  except
    on E: Exception do
      MessageDlg('SQL-каналы', E.Message, mtError, [mbOK], 0);
   end;
  finally
    lLines.Free;
    lNames.Free;
    lDialog.Free;
  end;
end;

procedure TCoordinatorMainForm.AdvanceSqlAllowedSync;
var
  lStatus, lResult, lGroupStatus: TJSONObject;
  lData: TJSONData;
  lAllowed: TStringList;
  lIndex, lTotal, lCompleted, lFailed: Integer;
begin
  if fSqlAllowedStopCorrelation <> '' then
  begin
    lGroupStatus := fModel.CommandGroupStatus(fSqlAllowedStopCorrelation);
    try
      lTotal := lGroupStatus.Get('total', 0);
      lCompleted := lGroupStatus.Get('completed', 0);
      lFailed := lGroupStatus.Get('failed', 0);
    finally
      lGroupStatus.Free;
    end;
    if lTotal = 0 then
      raise Exception.Create('Нет управляемых RecorderLnx для синхронизации');
    if lCompleted < lTotal then Exit;
    if lFailed > 0 then
      raise Exception.CreateFmt(
        'Не удалось остановить RecorderLnx: %d из %d. Список не применён.',
        [lFailed, lTotal]);
    fSqlAllowedStopCorrelation := '';
    FinishAllowedSqlChannelSync;
    Exit;
  end;
  if fSqlAllowedGetCommandId = '' then Exit;
  lStatus := fModel.WorkstationCommandStatus(fSqlAllowedGetCommandId);
  if not SameText(lStatus.Get('state', ''), 'completed') then
  begin
    lStatus.Free;
    Exit;
  end;
  try
    if not SameText(lStatus.Get('result_code', ''), 'noError') then
    begin
      MessageDlg('SQL-каналы', lStatus.Get('result_text',
        'RecorderLnx не вернул список разрешённых каналов.'),
        mtError, [mbOK], 0);
      Exit;
    end;
    lResult := TJSONObject(lStatus.Find('result'));
    if lResult = nil then
      raise Exception.Create('Ответ не содержит список разрешённых каналов');
    if not lResult.Get('configured', False) then
    begin
      MessageDlg('SQL-каналы',
        'На выбранном RecorderLnx список разрешённых каналов ещё не настроен.',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    lData := lResult.Find('allowed_channels');
    if not (lData is TJSONArray) then
      raise Exception.Create('Ответ allowed_channels имеет неверный формат');
    lAllowed := TStringList.Create;
    try
      lAllowed.CaseSensitive := False;
      lAllowed.Sorted := True;
      lAllowed.Duplicates := dupIgnore;
      for lIndex := 0 to TJSONArray(lData).Count - 1 do
        lAllowed.Add(TJSONArray(lData).Strings[lIndex]);
      SynchronizeAllowedSqlChannels(lAllowed);
    finally
      lAllowed.Free;
    end;
  finally
    fSqlAllowedGetCommandId := '';
    btnSyncSqlChannels.Enabled := fSqlAllowedStopCorrelation = '';
    lStatus.Free;
  end;
end;

procedure TCoordinatorMainForm.SynchronizeAllowedSqlChannels(
  AAllowedNames: TStrings);
var
  lPreview: string;
  lIndex: Integer;
begin
  lPreview := '';
  for lIndex := 0 to AAllowedNames.Count - 1 do
  begin
    if lIndex >= 20 then
    begin
      lPreview := lPreview + LineEnding + '...';
      Break;
    end;
    if lPreview <> '' then lPreview := lPreview + LineEnding;
    lPreview := lPreview + AAllowedNames[lIndex];
  end;
  if MessageDlg('Синхронизация SQL-каналов', Format(
    'Загружено каналов: %d' + LineEnding + '%s' + LineEnding + LineEnding +
    'Остановить все RecorderLnx и применить этот список?',
    [AAllowedNames.Count, lPreview]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  fPendingSqlAllowedNames.Assign(AAllowedNames);
  fSqlAllowedStopCorrelation := EnqueueCommandTo('*', 'recording.stop');
  if fSqlAllowedStopCorrelation = '' then
  begin
    fPendingSqlAllowedNames.Clear;
    raise Exception.Create('Не удалось поставить остановку RecorderLnx в очередь');
  end;
  btnSyncSqlChannels.Enabled := False;
  AddLog('Остановка всех RecorderLnx перед синхронизацией SQL-каналов');
end;

procedure TCoordinatorMainForm.FinishAllowedSqlChannelSync;
var
  lPayload: TJSONObject;
  lArray: TJSONArray;
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lInfos: TRecorderSqlDbSignalInfos;
  lDeleteNames: TStringList;
  lSignalsDeleted, lValuesDeleted: Int64;
  lIndex: Integer;
begin
  lPayload := TJSONObject.Create;
  try
    lArray := TJSONArray.Create;
    for lIndex := 0 to fPendingSqlAllowedNames.Count - 1 do
      lArray.Add(fPendingSqlAllowedNames[lIndex]);
    lPayload.Add('allowed_channels', lArray);
    SendCommandTo('*', 'config.sql_allowed_channels.set', lPayload.AsJSON);
  finally
    lPayload.Free;
  end;
  AddLog(Format('Всем RecorderLnx отправлен список разрешённых SQL-каналов: %d',
    [fPendingSqlAllowedNames.Count]));

  lDeleteNames := TStringList.Create;
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lDeleteNames.CaseSensitive := False;
    lDeleteNames.Sorted := True;
    lDeleteNames.Duplicates := dupIgnore;
    lConfig.LoadFromFile(fConfig.SqlDbConfigFile);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.ListSignalInfos(lInfos, False);
      for lIndex := 0 to High(lInfos) do
        if fPendingSqlAllowedNames.IndexOf(lInfos[lIndex].Name) < 0 then
          lDeleteNames.Add(lInfos[lIndex].Name);
      if (lDeleteNames.Count > 0) and
        (MessageDlg('Очистка общей SQL БД', Format(
          'В общей БД найдено неразрешённых каналов: %d.' + LineEnding +
          'Удалить их однократно из RCPanel?', [lDeleteNames.Count]),
          mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
      begin
        lRepository.DeleteSignalsByName(lDeleteNames, lSignalsDeleted,
          lValuesDeleted);
        AddLog(Format(
          'Однократная очистка SQL БД: удалено каналов %d, точек %d',
          [lSignalsDeleted, lValuesDeleted]));
        MessageDlg('Очистка общей SQL БД', Format(
          'Удалено каналов: %d. Удалено точек: %d.',
          [lSignalsDeleted, lValuesDeleted]), mtInformation, [mbOK], 0);
      end;
    finally
      lRepository.Free;
    end;
  finally
    lConfig.Free;
    lDeleteNames.Free;
    fPendingSqlAllowedNames.Clear;
    btnSyncSqlChannels.Enabled := True;
  end;
end;

procedure TCoordinatorMainForm.SdbSyncCompleted(Sender: TObject;
  const AReport, AError: string);
begin
  fSdbSyncRunning := False;
  btnSyncSdb.Enabled := True;
  if AError <> '' then
  begin
    AddLog('Ошибка синхронизации SDB: ' + AError);
    MessageDlg('Синхронизация SDB', AError, mtError, [mbOK], 0);
  end
  else
  begin
    AddLog(AReport);
    ShowMessage(AReport);
  end;
end;

procedure TCoordinatorMainForm.btnCommandStartClick(Sender: TObject);
begin SendCommand('recording.start'); end;

procedure TCoordinatorMainForm.btnCommandStartAllClick(Sender: TObject);
begin
  SendCommandTo('*', 'recording.start');
end;

procedure TCoordinatorMainForm.btnCommandStopAllClick(Sender: TObject);
begin SendCommandTo('*', 'recording.stop'); end;

procedure TCoordinatorMainForm.btnCommandPreviewAllClick(Sender: TObject);
begin SendCommandTo('*', 'recording.preview'); end;

procedure TCoordinatorMainForm.btnCommandPreviewClick(Sender: TObject);
begin SendCommand('recording.preview'); end;

procedure TCoordinatorMainForm.btnCommandStopClick(Sender: TObject);
begin SendCommand('recording.stop'); end;

procedure TCoordinatorMainForm.cbSqlRecordingAllChange(Sender: TObject);
var
  lPayload: TJSONObject;
begin
  if fLoading then Exit;
  lPayload := TJSONObject.Create;
  try
    lPayload.Add('enabled', cbSqlRecordingAll.Checked);
    lPayload.Add('record_period_ms', seSqlRecordPeriod.Value * 1000);
    SendCommandTo('*', 'config.sql_recording.set', lPayload.AsJSON);
    if cbSqlRecordingAll.Checked then
      AddLog('Всем RecorderLnx отправлено включение SQL-записи')
    else
      AddLog('Всем RecorderLnx отправлено выключение SQL-записи');
  finally
    lPayload.Free;
  end;
end;

procedure TCoordinatorMainForm.CreateHostContextMenu;
var
  lMenu: TPopupMenu;
  lAddHostItem: TMenuItem;
begin
  lMenu := TPopupMenu.Create(Self);
  lAddHostItem := TMenuItem.Create(lMenu);
  lAddHostItem.Caption := 'Добавить хост';
  lAddHostItem.OnClick := @AddHostMenuItemClick;
  lMenu.Items.Add(lAddHostItem);
  gridHosts.PopupMenu := lMenu;
end;

procedure TCoordinatorMainForm.AddHostMenuItemClick(Sender: TObject);
var
  lAddress, lHostName: string;
begin
  lAddress := '';
  if not InputQuery('Добавление RecorderLnx',
    'Адрес хоста или Instance ID:', lAddress) then Exit;
  lAddress := Trim(lAddress);
  if lAddress = '' then Exit;
  lHostName := '';
  if not InputQuery('Добавление RecorderLnx',
    'Имя хоста (можно оставить пустым):', lHostName) then Exit;
  fEditorHostId := '';
  edtSelectedHost.Text := lAddress;
  edtHostName.Text := Trim(lHostName);
  btnAddHostClick(Sender);
end;

procedure TCoordinatorMainForm.btnSetSqlPeriodAllClick(Sender: TObject);
var
  lPayload: TJSONObject;
begin
  lPayload := TJSONObject.Create;
  try
    lPayload.Add('enabled', cbSqlRecordingAll.Checked);
    lPayload.Add('record_period_ms', seSqlRecordPeriod.Value * 1000);
    SendCommandTo('*', 'config.sql_recording.set', lPayload.AsJSON);
    AddLog(Format('Всем RecorderLnx отправлен период SQL-записи %d с',
      [seSqlRecordPeriod.Value]));
  finally
    lPayload.Free;
  end;
end;

procedure TCoordinatorMainForm.StartHostAction(const AAddress: string;
  AAction: TCoordinatorHostAgentAction);
var
  lHost: TJSONObject;
begin
  if Trim(AAddress) = '' then Exit;
  if AAction = haaStartRecorder then
  begin
    lHost := fModel.HostByAddressJson(Trim(AAddress));
    try
      if lHost.Find('instance_id') = nil then
      begin
        lHost.Add('instance_id', Trim(AAddress));
        lHost.Add('address', Trim(AAddress));
      end;
      if not ClaimHost(lHost) then Exit;
    finally
      lHost.Free;
    end;
  end;
  fModel.MarkAgentReachabilityChecking(Trim(AAddress));
  StartHostAgentRequest(Trim(AAddress), fConfig.HostAgentPort,
    fConfig.HostAgentToken, AAction, @HostActionCompleted);
end;

function TCoordinatorMainForm.ClaimHost(AHost: TJSONObject): Boolean;
var
  lOwner, lAddress, lRequest: string;
  lForce: Boolean;
begin
  Result := False;
  lAddress := AHost.Get('address', '');
  if lAddress = '' then Exit;
  lOwner := AHost.Get('control_owner', '');
  if (lOwner = fServer.ControlId) and
     (AHost.Get('control_claim', '') <> '') and
     AHost.Get('recorder_reachable', False) then Exit(True);
  lForce := (lOwner <> '') and (lOwner <> fServer.ControlId);
  if lForce and (MessageDlg('Перехват управления',
    'Recorder на ' + lAddress + ' захвачен другой панелью.' + LineEnding +
    'Перехватить управление? Предыдущая панель больше не сможет им управлять.',
    mtWarning, [mbYes, mbNo], 0) <> mrYes) then Exit;
  lRequest := fServer.ClaimRecorder(lAddress, AHost.Get('instance_id', ''), lForce);
  Result := lRequest <> '';
  if Result then AddLog('Запрошен захват Recorder: ' + lAddress +
    '. Подключение подтвердится ответом Recorder.');
end;

procedure TCoordinatorMainForm.btnClaimRecorderClick(Sender: TObject);
var
  lHost: TJSONObject;
begin
  lHost := fModel.HostByIdJson(SelectedHostId);
  try
    ClaimHost(lHost);
  finally
    lHost.Free;
  end;
end;

procedure TCoordinatorMainForm.btnReleaseRecorderClick(Sender: TObject);
var
  lHost: TJSONObject;
begin
  lHost := fModel.HostByIdJson(SelectedHostId);
  try
    if lHost.Get('control_owner', '') <> fServer.ControlId then Exit;
    fServer.ReleaseRecorder(lHost.Get('address', ''),
      lHost.Get('instance_id', ''), lHost.Get('control_claim', ''));
    AddLog('Запрошено освобождение Recorder: ' + lHost.Get('address', ''));
  finally
    lHost.Free;
  end;
end;

procedure TCoordinatorMainForm.HostActionCompleted(Sender: TObject;
  AAction: TCoordinatorHostAgentAction;
  const AHost, AResponse: string; AHttpStatus: Integer;
  const AError: string);
const
  ACTION_NAMES: array[TCoordinatorHostAgentAction] of string =
    ('опрос', 'запуск RecorderLnx', 'выключение ПК');
var
  lResponseDetails: string;
begin
  if AError <> '' then
  begin
    fModel.ApplyAgentReachability(AHost, False, Now);
    AddLog(ACTION_NAMES[AAction] + ' ' + AHost + ': ' + AError)
  end
  else
  begin
    fModel.ApplyAgentReachability(AHost, True, Now);
    lResponseDetails := Trim(AResponse);
    if lResponseDetails <> '' then
      lResponseDetails := ': ' + lResponseDetails;
    if (AHttpStatus >= 200) and (AHttpStatus < 300) then
      AddLog(ACTION_NAMES[AAction] + ' ' + AHost + ': команда принята' +
        ' (HTTP ' + IntToStr(AHttpStatus) + ')' + lResponseDetails)
    else
      AddLog(ACTION_NAMES[AAction] + ' ' + AHost + ': отказ launcher' +
        ' (HTTP ' + IntToStr(AHttpStatus) + ')' + lResponseDetails);
  end;
  RefreshHosts;
end;

procedure TCoordinatorMainForm.StartAllHostActions(
  AAction: TCoordinatorHostAgentAction);
var
  lHosts: TJSONArray;
  lIndex: Integer;
  lHost: TJSONObject;
begin
  lHosts := fModel.HostsJson;
  try
    for lIndex := 0 to lHosts.Count - 1 do
    begin
      lHost := TJSONObject(lHosts.Items[lIndex]);
      StartHostAction(lHost.Get('address', ''), AAction);
    end;
  finally
    lHosts.Free;
  end;
end;

function TCoordinatorMainForm.WakeHost(AHost: TJSONObject): Boolean;
var
  lAddress, lMacAddress, lMessage, lBroadcast, lError: string;
begin
  lAddress := AHost.Get('address', '');
  lMacAddress := AHost.Get('mac_address', '');
  if not IsValidWakeOnLanMac(lMacAddress) then
  begin
    lMessage := 'Wake-on-LAN для ' + lAddress +
      ' не выполнен: RecorderLnx не передал корректный MAC-адрес.';
    AddLog(lMessage);
    MessageDlg('Wake-on-LAN', lMessage, mtWarning, [mbOK], 0);
    Exit(False);
  end;

  lBroadcast := WakeOnLanBroadcast(lAddress);
  Result := SendWakeOnLanDetailed(lMacAddress, lBroadcast, 9, lError);
  if Result then
    AddLog('Wake-on-LAN отправлен: хост=' + lAddress + '; MAC=' +
      lMacAddress + '; broadcast=' + lBroadcast + ':9')
  else
  begin
    lMessage := 'Wake-on-LAN для ' + lAddress +
      ' не отправлен: UDP ' + lBroadcast + ':9 (' + lError + ').';
    AddLog(lMessage);
    MessageDlg('Wake-on-LAN', lMessage, mtWarning, [mbOK], 0);
  end;
end;

procedure TCoordinatorMainForm.btnLaunchSelected_Click(Sender: TObject);
begin
  StartHostAction(edtSelectedHost.Text, haaStartRecorder);
end;

procedure TCoordinatorMainForm.btnLaunchAllClick(Sender: TObject);
begin
  StartAllHostActions(haaStartRecorder);
end;

procedure TCoordinatorMainForm.btnShutdownSelectedClick(Sender: TObject);
begin
  if MessageDlg('Выключение ПК', 'Выключить выбранный компьютер?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    StartHostAction(edtSelectedHost.Text, haaShutdown);
end;

procedure TCoordinatorMainForm.btnShutdownAllClick(Sender: TObject);
begin
  if MessageDlg('Выключение ПК', 'Выключить все доступные компьютеры?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    StartAllHostActions(haaShutdown);
end;

procedure TCoordinatorMainForm.btnWakeSelectedClick(Sender: TObject);
var
  lHost: TJSONObject;
begin
  lHost := fModel.HostByIdJson(SelectedHostId);
  try
    WakeHost(lHost);
  finally
    lHost.Free;
  end;
end;

procedure TCoordinatorMainForm.btnWakeAllClick(Sender: TObject);
var
  lHosts: TJSONArray;
  lIndex: Integer;
begin
  lHosts := fModel.HostsJson;
  try
    for lIndex := 0 to lHosts.Count - 1 do
      WakeHost(TJSONObject(lHosts.Items[lIndex]));
  finally
    lHosts.Free;
  end;
end;

procedure TCoordinatorMainForm.UpdateSelectedHost;
var
  lSelectedId: string;
  lHost: TJSONObject;
  lOurs: Boolean;
begin
  lSelectedId := SelectedHostId;
  // Polling refreshes status, not a user's unsaved address/name draft.
  if not fHostEditorDirty then
  begin
    fLoading := True;
    try
      if gridHosts.Row > 0 then
      begin
        if not SameText(fEditorHostId, lSelectedId) then
        begin
          fEditorHostId := lSelectedId;
          edtSelectedHost.Text := gridHosts.Cells[2, gridHosts.Row];
          if edtSelectedHost.Text = '' then
            edtSelectedHost.Text := lSelectedId;
          edtHostName.Text := gridHosts.Cells[3, gridHosts.Row];
        end;
      end
      else if fEditorHostId <> '' then
      begin
        fEditorHostId := '';
        edtSelectedHost.Clear;
        edtHostName.Clear;
      end;
      if edtSelectedHost.Text = '' then
        edtSelectedHost.Text := SelectedHostId;
    finally
      fLoading := False;
    end;
  end;
  UpdateHostEditorMode;
  btnCommandStop.Enabled := edtSelectedHost.Text <> '';
  btnCommandPreview.Enabled := edtSelectedHost.Text <> '';
  btnCommandStart.Enabled := edtSelectedHost.Text <> '';
  btnLaunchSelected.Enabled := edtSelectedHost.Text <> '';
  btnShutdownSelected.Enabled := edtSelectedHost.Text <> '';
  btnWakeSelected.Enabled := SelectedHostId <> '';
  btnDeleteHost.Enabled := SelectedHostId <> '';
  btnSetPrimarySdb.Enabled := SelectedHostId <> '';
  lHost := fModel.HostByIdJson(lSelectedId);
  try
    lOurs := (lHost.Get('control_owner', '') = fServer.ControlId) and
      lHost.Get('recorder_reachable', False);
    btnClaimRecorder.Enabled := lSelectedId <> '';
    if (lHost.Get('control_owner', '') <> '') and
       (lHost.Get('control_owner', '') <> fServer.ControlId) then
      btnClaimRecorder.Caption := 'Перехватить'
    else btnClaimRecorder.Caption := 'Захватить';
    btnReleaseRecorder.Enabled :=
      lHost.Get('control_owner', '') = fServer.ControlId;
    btnCommandStop.Enabled := lOurs;
    btnCommandPreview.Enabled := lOurs;
    btnCommandStart.Enabled := lOurs;
  finally
    lHost.Free;
  end;
end;

procedure TCoordinatorMainForm.gridHostsSelection(Sender: TObject;
  aCol, aRow: Integer);
begin
  if fRefreshingHosts then Exit;
  fHostEditorDirty := False;
  UpdateSelectedHost;
end;

procedure TCoordinatorMainForm.gridHostsDblClick(Sender: TObject);
begin
  if (gridHosts.Row > 0) and (gridHosts.Col = 13) then
    SetSelectedHostAsSdbPrimary;
end;

procedure TCoordinatorMainForm.gridHostsDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  lColor: TColor;
  lState: string;
begin
  if aRow = 0 then Exit;
  if (aCol = 4) or (aCol = 8) then
  begin
    lState := LowerCase(Trim(gridHosts.Cells[aCol, aRow]));
    if SameText(lState, 'доступен') or SameText(lState, 'подключён') then
      lColor := clGreen
    else if SameText(lState, 'нет связи') then
      lColor := clRed
    else if SameText(lState, 'проверка...') then
      lColor := clYellow
    else
      lColor := clGray;
    gridHosts.Canvas.Brush.Color := lColor;
    gridHosts.Canvas.FillRect(aRect);
    gridHosts.Canvas.TextOut(aRect.Left + 2, aRect.Top + 2,
      gridHosts.Cells[aCol, aRow]);
    Exit;
  end;
  if aCol <> 0 then Exit;
  lState := LowerCase(Trim(gridHosts.Cells[9, aRow]));
  if Pos('record', lState) > 0 then
    lColor := clGreen
  else if Pos('preview', lState) > 0 then
    lColor := clYellow
  else if (Pos('stop', lState) > 0) or (Pos('idle', lState) > 0) or
    (Pos('ready', lState) > 0) then
    lColor := clGray
  else
    lColor := clBlack;
  gridHosts.Canvas.Brush.Style := bsSolid;
  gridHosts.Canvas.Brush.Color := lColor;
  gridHosts.Canvas.Pen.Color := clGray;
  gridHosts.Canvas.Rectangle(aRect.Left + 12, aRect.Top + 5,
    aRect.Left + 24, aRect.Top + 17);
end;

procedure TCoordinatorMainForm.btnRefreshClick(Sender: TObject);
begin
  fServer.SearchRecorders;
  RefreshHosts;
  AddLog('Поиск RecorderLnx в локальной сети запущен');
end;

procedure TCoordinatorMainForm.timerRefreshTimer(Sender: TObject);
begin
  try
    AdvanceSqlAllowedSync;
  except
    on E: Exception do
    begin
      fSqlAllowedGetCommandId := '';
      fSqlAllowedStopCorrelation := '';
      fPendingSqlAllowedNames.Clear;
      btnSyncSqlChannels.Enabled := True;
      AddLog('Ошибка синхронизации SQL-каналов: ' + E.Message);
      MessageDlg('SQL-каналы', E.Message, mtError, [mbOK], 0);
    end;
  end;
  fServer.RetryControlRequests;
  DrainBackgroundDiagnostics;
  RefreshHosts;
  if fSdbConfigRequestPending and
    (GetTickCount64 - fSdbConfigRequestedAt >= 4000) then
  begin
    fSdbConfigRequestPending := False;
    fSdbConfigResponsesReady := True;
    btnSyncSdb.Enabled := True;
    btnSyncSdbClick(nil);
  end;
end;

procedure TCoordinatorMainForm.gridStoragesSelection(Sender: TObject; aCol, aRow: Integer);
begin LoadStorageEditor; end;

end.
