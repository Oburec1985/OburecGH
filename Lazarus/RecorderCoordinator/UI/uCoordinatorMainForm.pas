unit uCoordinatorMainForm;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons, ComCtrls,
  ExtCtrls, Grids, DateTimePicker, fpjson, uCoordinatorModel,
  uCoordinatorConfig, uCoordinatorHttpServer, uCoordinatorSqlEventStore,
  uRecorderSqlDbTypes, uCoordinatorHostAgentClient;

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
    cbCreateRecordingEvents: TCheckBox;
    cbStartAllOnAnyRecording: TCheckBox;
    cbStorageKind: TComboBox;
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
    procedure btnDeleteHostClick(Sender: TObject);
    procedure btnCommandStartClick(Sender: TObject);
    procedure btnCommandStartAllClick(Sender: TObject);
    procedure btnCommandPreviewClick(Sender: TObject);
    procedure btnCommandPreviewAllClick(Sender: TObject);
    procedure btnCommandStopClick(Sender: TObject);
    procedure btnCommandStopAllClick(Sender: TObject);
    procedure btnLaunchAllClick(Sender: TObject);
    procedure btnLaunchSelected_Click(Sender: TObject);
    procedure btnShutdownAllClick(Sender: TObject);
    procedure btnShutdownSelectedClick(Sender: TObject);
    procedure btnWakeAllClick(Sender: TObject);
    procedure btnWakeSelectedClick(Sender: TObject);
    procedure btnDeleteEventClick(Sender: TObject);
    procedure btnSetDatabaseForAllClick(Sender: TObject);
    procedure btnSetPrimarySdbClick(Sender: TObject);
    procedure btnSyncSdbClick(Sender: TObject);
    procedure btnEditEventClick(Sender: TObject);
    procedure btnOpenEventClick(Sender: TObject);
    procedure btnRefreshEventsClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnTestStorageClick(Sender: TObject);
    procedure cbCreateRecordingEventsChange(Sender: TObject);
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
    fSqlEvents: TRecorderSqlDbMeraEvents;
    fEventsToFollowsNow: Boolean;
    fEditorHostId: string;
    fSdbSyncRunning: Boolean;
    fSdbConfigRequestPending: Boolean;
    fSdbConfigResponsesReady: Boolean;
    fSdbConfigRequestedAt: QWord;
    procedure AddLog(const AText: string);
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
    procedure StartHostAction(const AAddress: string;
      AAction: TCoordinatorHostAgentAction);
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
    procedure SetSelectedHostAsSdbPrimary;
    procedure UpdateEventButtons;
  end;

var
  CoordinatorMainForm: TCoordinatorMainForm;

implementation

{$R *.lfm}

uses
  DateUtils, uRecorderSqlDbRepository, uRecorderMeraEventDialog,
  uRecorderNetworkBinding, uSharedFileLogger, uCoordinatorWakeOnLan,
  uCoordinatorVersion, uCoordinatorSdbSync;

function TCoordinatorMainForm.DefaultFirebirdHost: string;
begin
  Result := CRecorderFirebirdDefaultHost;
end;

function TCoordinatorMainForm.TryStartService(out AError: string): Boolean;
begin
  fServer.Start(fConfig.ListenAddress, fConfig.Port);
  AError := Trim(fServer.LastError);
  Result := AError = '';
end;

procedure TCoordinatorMainForm.FormCreate(Sender: TObject);
var
  lIndex: Integer;
  lHost, lResult: TJSONObject;
  lError: string;
begin
  Caption := CoordinatorWindowCaption;
  fModel := TCoordinatorModel.Create;
  fConfig := TCoordinatorConfig.Create(ChangeFileExt(Application.ExeName, '.ini'));
  fConfig.Load;
  fModel.EventWindowSec := fConfig.EventWindowSec;
  fModel.CreateRecordingEvents := fConfig.CreateRecordingEvents;
  fModel.StartAllOnAnyRecording := fConfig.StartAllOnAnyRecording;
  fSqlEventStore := TCoordinatorSqlEventStore.Create(fConfig.SqlDbConfigFile);
  fModel.OnRecordingLifecycle := @StoreRecordingLifecycle;
  fServer := TCoordinatorHttpServer.Create(fModel);
  for lIndex := 0 to fConfig.HostCount - 1 do
  begin
    lHost := TJSONObject.Create;
    try
      lHost.Add('instance_id', fConfig.HostId(lIndex));
      lHost.Add('host_name', fConfig.HostName(lIndex));
      lHost.Add('state', 'configured');
      lHost.Add('managed', True);
      lResult := fModel.RegisterHello(lHost);
      lResult.Free;
    finally
      lHost.Free;
    end;
  end;
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

procedure TCoordinatorMainForm.RefreshHosts;
var
  lData: TJSONArray;
  lItem: TJSONObject;
  lIndex: Integer;
begin
  lData := fModel.HostsJson;
  try
    gridHosts.RowCount := lData.Count + 1;
    for lIndex := 0 to lData.Count - 1 do
    begin
      lItem := lData.Objects[lIndex];
      gridHosts.Cells[1, lIndex + 1] := lItem.Get('instance_id', '');
      gridHosts.Cells[2, lIndex + 1] := lItem.Get('address', '');
      gridHosts.Cells[3, lIndex + 1] := lItem.Get('host_name', '');
      gridHosts.Cells[4, lIndex + 1] := lItem.Get('mac_address', '');
      gridHosts.Cells[5, lIndex + 1] := PcConnectionCaption(
        lItem.Get('pc_connection_state', 'unknown'));
      gridHosts.Cells[6, lIndex + 1] := AgentConnectionCaption(
        lItem.Get('agent_connection_state', 'unknown'));
      gridHosts.Cells[7, lIndex + 1] := lItem.Get('state', '');
      gridHosts.Cells[8, lIndex + 1] := lItem.Get('measurement_path', '');
      gridHosts.Cells[9, lIndex + 1] := lItem.Get('last_seen_utc', '');
      gridHosts.Cells[10, lIndex + 1] := lItem.Get('mera_files_path', '');
      if SameText(lItem.Get('instance_id', ''), fConfig.SdbPrimaryHostId) then
        gridHosts.Cells[11, lIndex + 1] := '●'
      else
        gridHosts.Cells[11, lIndex + 1] := '';
      gridHosts.Cells[0, lIndex + 1] := '';
      gridHosts.InvalidateCell(0, lIndex + 1);
    end;
    gridHosts.Update;
  finally
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
  lHostId, lStoredId: string;
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
  finally
    lResult.Free;
  end;
  if lStoredId <> '' then
  begin
    if not fModel.SetHostAddress(lStoredId, lHostId) then
    begin
      MessageDlg('Редактирование RecorderLnx',
        'Не удалось сохранить адрес выбранного хоста.',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    fModel.SetHostDisplayName(lStoredId, Trim(edtHostName.Text));
    fConfig.SetHostName(lStoredId, lHostId, Trim(edtHostName.Text));
    AddLog('RecorderLnx изменён: ' + lStoredId);
  end
  else
  begin
    lInput := TJSONObject.Create;
    try
      lInput.Add('instance_id', lHostId);
      lInput.Add('host_name', Trim(edtHostName.Text));
      lInput.Add('state', 'configured');
      lResult := fModel.RegisterHello(lInput);
      try
        AddLog('RecorderLnx добавлен: ' + lHostId);
      finally
        lResult.Free;
      end;
    finally
      lInput.Free;
    end;
    fConfig.AddHost(lHostId, Trim(edtHostName.Text));
  end;
  fConfig.Save;
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
  fConfig.RemoveHost(lHostId, lAddress);
  fConfig.Save;
  fEditorHostId := '';
  edtSelectedHost.Clear;
  edtHostName.Clear;
  RefreshHosts;
  AddLog('Хост удалён и добавлен в ignored-hosts.ini: ' + lHostId);
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
var
  lInput, lResult: TJSONObject;
  lPayload: TJSONData;
  lId: TGuid;
  lCorrelation: string;
begin
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
    try AddLog('Команда поставлена: ' + lResult.AsJSON); finally lResult.Free; end;
  finally lInput.Free; end;
end;

procedure TCoordinatorMainForm.btnSetDatabaseForAllClick(Sender: TObject);
var
  lHost: string;
  lPayload: TJSONObject;
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
  if MessageDlg('Настройка Firebird',
    'Установить всем RecorderLnx сервер Firebird ' + lHost + '?' +
    LineEnding + LineEnding +
    'Команда будет применена к подключённым управляемым RecorderLnx.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  lSqlConfig := TRecorderSqlDbConfig.Create;
  try
    lSqlConfig.LoadFromFile(fConfig.SqlDbConfigFile);
    if lSqlConfig.Password = '' then
    begin
      MessageDlg('Настройка Firebird',
        'В ' + fConfig.SqlDbConfigFile + ' не задан пароль Firebird.',
        mtError, [mbOK], 0);
      Exit;
    end;
    lPayload := TJSONObject.Create;
    try
      lPayload.Add('host', lHost);
      lPayload.Add('port', lSqlConfig.Port);
      lPayload.Add('database', lSqlConfig.Database);
      lPayload.Add('username', lSqlConfig.UserName);
      lPayload.Add('password', lSqlConfig.Password);
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

procedure TCoordinatorMainForm.StartHostAction(const AAddress: string;
  AAction: TCoordinatorHostAgentAction);
begin
  if Trim(AAddress) = '' then Exit;
  fModel.MarkAgentReachabilityChecking(Trim(AAddress));
  StartHostAgentRequest(Trim(AAddress), fConfig.HostAgentPort,
    fConfig.HostAgentToken, AAction, @HostActionCompleted);
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
const
  BROADCAST_ADDRESS = '255.255.255.255';
var
  lAddress, lMacAddress, lMessage: string;
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

  Result := SendWakeOnLan(lMacAddress, BROADCAST_ADDRESS);
  if Result then
    AddLog('Wake-on-LAN отправлен: хост=' + lAddress + '; MAC=' +
      lMacAddress + '; broadcast=' + BROADCAST_ADDRESS + ':9')
  else
  begin
    lMessage := 'Wake-on-LAN для ' + lAddress +
      ' не отправлен: ошибка UDP broadcast ' + BROADCAST_ADDRESS + ':9.';
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
begin
  lSelectedId := SelectedHostId;
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
    else
    begin
      edtSelectedHost.Clear;
      if fEditorHostId <> '' then
      begin
        fEditorHostId := '';
        edtSelectedHost.Clear;
        edtHostName.Clear;
      end;
    end;
    if edtSelectedHost.Text = '' then
      edtSelectedHost.Text := SelectedHostId;
  finally
    fLoading := False;
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
end;

procedure TCoordinatorMainForm.gridHostsSelection(Sender: TObject;
  aCol, aRow: Integer);
begin
  UpdateSelectedHost;
end;

procedure TCoordinatorMainForm.gridHostsDblClick(Sender: TObject);
begin
  if (gridHosts.Row > 0) and (gridHosts.Col = 11) then
    SetSelectedHostAsSdbPrimary;
end;

procedure TCoordinatorMainForm.gridHostsDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  lColor: TColor;
  lState: string;
begin
  if aRow = 0 then Exit;
  if aCol = 6 then
  begin
    lState := LowerCase(Trim(gridHosts.Cells[6, aRow]));
    if SameText(lState, 'доступен') then
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
  lState := LowerCase(Trim(gridHosts.Cells[7, aRow]));
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
