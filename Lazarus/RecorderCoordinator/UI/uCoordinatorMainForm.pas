unit uCoordinatorMainForm;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Grids, DateTimePicker, fpjson, uCoordinatorModel,
  uCoordinatorConfig, uCoordinatorHttpServer, uCoordinatorSqlEventStore,
  uRecorderSqlDbTypes;

type
  TCoordinatorMainForm = class(TForm)
    btnAddStorage: TButton;
    btnAddHost: TButton;
    btnCommandStart: TButton;
    btnCommandStartAll: TButton;
    btnCommandPreview: TButton;
    btnCommandStop: TButton;
    btnCommandStopAll: TButton;
    btnDeleteEvent: TButton;
    btnSetDatabaseForAll: TButton;
    btnEditEvent: TButton;
    btnOpenEvent: TButton;
    btnRefreshEvents: TButton;
    btnRefresh: TButton;
    btnSave: TButton;
    btnService: TButton;
    btnTestStorage: TButton;
    cbCreateRecordingEvents: TCheckBox;
    cbStartAllOnAnyRecording: TCheckBox;
    cbStorageKind: TComboBox;
    dtpEventsFrom: TDateTimePicker;
    dtpEventsTo: TDateTimePicker;
    edtListen: TEdit;
    edtEventWindow: TEdit;
    edtHostId: TEdit;
    edtHostName: TEdit;
    edtDatabaseHost: TEdit;
    edtPort: TEdit;
    edtSelectedHost: TEdit;
    edtStorageHost: TEdit;
    edtStorageName: TEdit;
    edtStoragePath: TEdit;
    edtStorageUser: TEdit;
    gridEvents: TStringGrid;
    gridHosts: TStringGrid;
    gridStorages: TStringGrid;
    lblListen: TLabel;
    lblEventWindow: TLabel;
    lblEventsFrom: TLabel;
    lblEventsTo: TLabel;
    lblHostId: TLabel;
    lblHostName: TLabel;
    lblDatabaseHost: TLabel;
    lblPort: TLabel;
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
    procedure btnCommandStartClick(Sender: TObject);
    procedure btnCommandStartAllClick(Sender: TObject);
    procedure btnCommandPreviewClick(Sender: TObject);
    procedure btnCommandStopClick(Sender: TObject);
    procedure btnCommandStopAllClick(Sender: TObject);
    procedure btnDeleteEventClick(Sender: TObject);
    procedure btnSetDatabaseForAllClick(Sender: TObject);
    procedure btnEditEventClick(Sender: TObject);
    procedure btnOpenEventClick(Sender: TObject);
    procedure btnRefreshEventsClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnServiceClick(Sender: TObject);
    procedure btnTestStorageClick(Sender: TObject);
    procedure cbCreateRecordingEventsChange(Sender: TObject);
    procedure cbStartAllOnAnyRecordingChange(Sender: TObject);
    procedure dtpEventsToChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gridHostsDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridHostsSelection(Sender: TObject; aCol, aRow: Integer);
    procedure gridEventsSelection(Sender: TObject; aCol, aRow: Integer);
    procedure gridStoragesSelection(Sender: TObject; aCol, aRow: Integer);
    procedure timerRefreshTimer(Sender: TObject);
  private
    fModel: TCoordinatorModel;
    fConfig: TCoordinatorConfig;
    fServer: TCoordinatorHttpServer;
    fSqlEventStore: TCoordinatorSqlEventStore;
    fStopLogPending: Boolean;
    fLoading: Boolean;
    fSqlEvents: TRecorderSqlDbMeraEvents;
    fEventsToFollowsNow: Boolean;
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
    function DefaultFirebirdHost: string;
    procedure UpdateSelectedHost;
    function StoreRecordingLifecycle(
      const AInfo: TCoordinatorRecordingLifecycle): string;
    function TryStartService(out AError: string): Boolean;
    function SelectedHostId: string;
    function SelectedEventIndex: Integer;
    function SelectedStorage: TStorageConfig;
    procedure ShowSelectedEvent;
    procedure UpdateEventButtons;
    procedure UpdateServiceButton;
  end;

var
  CoordinatorMainForm: TCoordinatorMainForm;

implementation

{$R *.lfm}

uses
  DateUtils, uRecorderSqlDbRepository, uRecorderMeraEventDialog,
  uRecorderNetworkBinding, uSharedFileLogger;

function TCoordinatorMainForm.DefaultFirebirdHost: string;
var
  lAddresses: TStringList;
  lAddress: string;
  lIndex: Integer;
begin
  Result := '';
  lAddresses := TStringList.Create;
  try
    RecorderEnumerateLocalIPv4(lAddresses);
    for lIndex := 0 to lAddresses.Count - 1 do
    begin
      lAddress := RecorderNetworkAddressFromDisplay(lAddresses[lIndex]);
      if (lAddress <> '') and (Pos('127.', lAddress) <> 1) and
        (Pos('169.254.', lAddress) <> 1) then
        Exit(lAddress);
    end;
  finally
    lAddresses.Free;
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
  lIndex: Integer;
  lHost, lResult: TJSONObject;
  lError: string;
begin
  fModel := TCoordinatorModel.Create;
  fConfig := TCoordinatorConfig.Create(ChangeFileExt(Application.ExeName, '.ini'));
  fConfig.Load;
  fModel.EventWindowSec := fConfig.EventWindowSec;
  fModel.CreateRecordingEvents := fConfig.CreateRecordingEvents;
  fModel.StartAllOnAnyRecording := fConfig.StartAllOnAnyRecording;
  fSqlEventStore := TCoordinatorSqlEventStore.Create(fConfig.SqlDbConfigFile);
  fModel.OnRecordingLifecycle := @StoreRecordingLifecycle;
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
  fServer := TCoordinatorHttpServer.Create(fModel);
  edtListen.Text := fConfig.ListenAddress;
  edtPort.Text := IntToStr(fConfig.Port);
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
  UpdateServiceButton;
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
  fConfig.ListenAddress := Trim(edtListen.Text);
  fConfig.Port := StrToIntDef(edtPort.Text, 8765);
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

procedure TCoordinatorMainForm.UpdateServiceButton;
var
  lActive, lStopping: Boolean;
begin
  lStopping := fServer.Stopping;
  lActive := fServer.Active;

  if lStopping then
  begin
    btnService.Caption := 'Останавливается...';
    btnService.Enabled := False;
  end
  else
  begin
    btnService.Enabled := True;
    if lActive then
      btnService.Caption := 'Остановить сервис'
    else
      btnService.Caption := 'Запустить сервис';
  end;

  if fStopLogPending and (not lStopping) and (not lActive) then
  begin
    AddLog('HTTP API остановлен');
    fStopLogPending := False;
  end;
end;

procedure TCoordinatorMainForm.btnServiceClick(Sender: TObject);
var
  lError: string;
begin
  if fServer.Stopping then Exit;
  if not fServer.Active then
  begin
    ApplyServiceSettings;
    if TryStartService(lError) then
      AddLog('Запуск HTTP API')
    else
    begin
      AddLog('Ошибка запуска: ' + lError);
      MessageDlg('Сервис Recorder Coordinator',
        'Не удалось открыть ' + fConfig.ListenAddress + ':' +
        IntToStr(fConfig.Port) + LineEnding + lError,
        mtError, [mbOK], 0);
    end;
  end
  else
  begin
    fStopLogPending := True;
    btnService.Caption := 'Останавливается...';
    btnService.Enabled := False;
    fServer.Stop;
  end;
  UpdateServiceButton;
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
      gridHosts.Cells[4, lIndex + 1] := lItem.Get('state', '');
      gridHosts.Cells[5, lIndex + 1] := lItem.Get('measurement_path', '');
      gridHosts.Cells[6, lIndex + 1] := lItem.Get('last_seen_utc', '');
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
  lHostId: string;
begin
  lHostId := Trim(edtHostId.Text);
  if lHostId = '' then
  begin
    MessageDlg('Добавление RecorderLnx',
      'Укажите стабильный Instance ID или сетевой адрес хоста.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
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
  fConfig.Save;
  RefreshHosts;
  edtHostId.Clear;
  edtHostName.Clear;
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
  lPayload := TJSONObject.Create;
  try
    lPayload.Add('host', lHost);
    SendCommandTo('*', 'config.sql_database.set', lPayload.AsJSON);
  finally
    lPayload.Free;
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

procedure TCoordinatorMainForm.btnCommandPreviewClick(Sender: TObject);
begin SendCommand('recording.preview'); end;

procedure TCoordinatorMainForm.btnCommandStopClick(Sender: TObject);
begin SendCommand('recording.stop'); end;

procedure TCoordinatorMainForm.UpdateSelectedHost;
begin
  if gridHosts.Row > 0 then
    edtSelectedHost.Text := gridHosts.Cells[2, gridHosts.Row]
  else
    edtSelectedHost.Clear;
  if edtSelectedHost.Text = '' then
    edtSelectedHost.Text := SelectedHostId;
  btnCommandStop.Enabled := edtSelectedHost.Text <> '';
  btnCommandPreview.Enabled := edtSelectedHost.Text <> '';
  btnCommandStart.Enabled := edtSelectedHost.Text <> '';
end;

procedure TCoordinatorMainForm.gridHostsSelection(Sender: TObject;
  aCol, aRow: Integer);
begin
  UpdateSelectedHost;
end;

procedure TCoordinatorMainForm.gridHostsDrawCell(Sender: TObject;
  aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  lColor: TColor;
  lState: string;
begin
  if (aRow = 0) or (aCol <> 0) then Exit;
  lState := LowerCase(Trim(gridHosts.Cells[4, aRow]));
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
begin RefreshHosts; end;

procedure TCoordinatorMainForm.timerRefreshTimer(Sender: TObject);
begin
  DrainBackgroundDiagnostics;
  RefreshHosts;
  UpdateServiceButton;
end;

procedure TCoordinatorMainForm.gridStoragesSelection(Sender: TObject; aCol, aRow: Integer);
begin LoadStorageEditor; end;

end.
