unit uRecorderMeraEventDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Grids,
  uRecorderSqlDbTypes;

type
  TRecorderMeraRecordingIds = array of string;
  TRecorderMeraEventDialogResult = (medrUnchanged, medrChanged, medrDeleted);
  TRecorderMeraTransferRequestEvent = procedure(Sender: TObject;
    const ARecordingIds: TRecorderMeraRecordingIds) of object;

  TRecorderMeraEventDialog = class;

  TRecorderMeraPackageLoadThread = class(TThread)
  private
    fConfigFileName: string;
    fEventId: string;
    fErrorText: string;
    fOwner: TRecorderMeraEventDialog;
    fPackages: TRecorderSqlDbMeraPackages;
    fEntryPaths: array of string;
    fLocationIds: array of string;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderMeraEventDialog;
      const AConfigFileName, AEventId: string);
  end;

  TRecorderMeraEventDialog = class(TForm)
    btnClose: TButton;
    btnDeleteEvent: TButton;
    btnOpenAll: TButton;
    btnOpenSelected: TButton;
    btnTransferAll: TButton;
    btnTransferSelected: TButton;
    btnSave: TButton;
    edDisplayName: TEdit;
    grdPackages: TStringGrid;
    lblDescription: TLabel;
    lblDisplayName: TLabel;
    lblEventTime: TLabel;
    lblEventTimeTitle: TLabel;
    lblStatus: TLabel;
    memDescription: TMemo;
    pnlEvent: TPanel;
    procedure btnDeleteEventClick(Sender: TObject);
    procedure btnOpenAllClick(Sender: TObject);
    procedure btnOpenSelectedClick(Sender: TObject);
    procedure btnTransferAllClick(Sender: TObject);
    procedure btnTransferSelectedClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure grdPackagesDblClick(Sender: TObject);
    procedure grdPackagesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    fEvent: TRecorderSqlDbMeraEvent;
    fConfigFileName: string;
    fDialogResult: TRecorderMeraEventDialogResult;
    fLoader: TRecorderMeraPackageLoadThread;
    fOnTransferRequest: TRecorderMeraTransferRequestEvent;
    fPackages: TRecorderSqlDbMeraPackages;
    fEntryPaths: array of string;
    fLocationIds: array of string;
    fOpenAllWhenLoaded: Boolean;
    procedure AcceptPackages(AWorker: TRecorderMeraPackageLoadThread);
    procedure FillPackages;
    procedure OpenPackages(ASelectedOnly: Boolean);
    procedure RequestTransfer(ASelectedOnly: Boolean);
    function SaveChanges: Boolean;
    procedure UpdateButtons;
  public
    constructor CreateDialog(AOwner: TComponent; const AConfigFileName: string;
      const AEvent: TRecorderSqlDbMeraEvent;
      AOnTransferRequest: TRecorderMeraTransferRequestEvent = nil;
      AOpenAllWhenLoaded: Boolean = False); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderMeraEventDialog(AOwner: TComponent;
  const AConfigFileName: string; const AEvent: TRecorderSqlDbMeraEvent;
  AOnTransferRequest: TRecorderMeraTransferRequestEvent = nil;
  AOpenAllWhenLoaded: Boolean = False):
  TRecorderMeraEventDialogResult;

implementation

{$R *.lfm}

uses
  DateUtils, LCLIntf, Dialogs, uRecorderSqlDbRepository;

function ShowRecorderMeraEventDialog(AOwner: TComponent;
  const AConfigFileName: string; const AEvent: TRecorderSqlDbMeraEvent;
  AOnTransferRequest: TRecorderMeraTransferRequestEvent;
  AOpenAllWhenLoaded: Boolean):
  TRecorderMeraEventDialogResult;
var
  lDialog: TRecorderMeraEventDialog;
begin
  lDialog := TRecorderMeraEventDialog.CreateDialog(AOwner, AConfigFileName,
    AEvent, AOnTransferRequest, AOpenAllWhenLoaded);
  try
    lDialog.ShowModal;
    Result := lDialog.fDialogResult;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderMeraPackageLoadThread.Create(
  AOwner: TRecorderMeraEventDialog; const AConfigFileName, AEventId: string);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fConfigFileName := AConfigFileName;
  fEventId := AEventId;
end;

procedure TRecorderMeraPackageLoadThread.Execute;
var
  I, J, K: Integer;
  lEntryPath, lFrameDir, lFrameName: string;
  lConfig: TRecorderSqlDbConfig;
  lFiles: TRecorderSqlDbMeraFiles;
  lLocations: TRecorderSqlDbFileLocations;
  lRepository: TRecorderSqlDbRepository;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  try
    try
      lConfig.LoadFromFile(fConfigFileName);
      lRepository := TRecorderSqlDbRepository.Create(lConfig);
      lRepository.ListMeraPackages(fEventId, fPackages);
      SetLength(fEntryPaths, Length(fPackages));
      SetLength(fLocationIds, Length(fPackages));
      for I := 0 to High(fPackages) do
      begin
        if Terminated then Exit;
        lRepository.ListMeraFiles(fPackages[I].Recording.Id, lFiles);
        for J := 0 to High(lFiles) do
          if SameText(lFiles[J].FileRole, 'entry-mera') then
          begin
            { StorageKey identifies an object in the file store and is not a
              filesystem name.  Only a published location may be opened. }
            lRepository.ListDataFileLocations(lFiles[J].FileId, lLocations);
            for K := 0 to High(lLocations) do
              if SameText(lLocations[K].State, 'ready') and
                 (Trim(lLocations[K].PathKey) <> '') then
              begin
                lEntryPath := lLocations[K].PathKey;
                if fEntryPaths[I] = '' then
                begin
                  fEntryPaths[I] := lEntryPath;
                  fLocationIds[I] := lLocations[K].Id;
                end;
                { Совместимость с событиями, записанными старым клиентом:
                  он публиковал несуществующий record.mera, хотя writer создаёт
                  <имя-каталога-кадра>.mera. }
                if not FileExists(lEntryPath) then
                begin
                  lFrameDir := ExtractFileDir(lEntryPath);
                  lFrameName := ExtractFileName(
                    ExcludeTrailingPathDelimiter(lFrameDir));
                  if lFrameName <> '' then
                    lEntryPath := IncludeTrailingPathDelimiter(lFrameDir) +
                      lFrameName + '.mera';
                end;
                if FileExists(lEntryPath) then
                begin
                  fEntryPaths[I] := lEntryPath;
                  fLocationIds[I] := lLocations[K].Id;
                  Break;
                end;
              end;
            Break;
          end;
      end;
    except
      on E: Exception do fErrorText := E.Message;
    end;
    if not Terminated then Synchronize(@Deliver);
  finally
    lRepository.Free;
    lConfig.Free;
  end;
end;

procedure TRecorderMeraPackageLoadThread.Deliver;
begin
  if (not Terminated) and (fOwner <> nil) then fOwner.AcceptPackages(Self);
end;

constructor TRecorderMeraEventDialog.CreateDialog(AOwner: TComponent;
  const AConfigFileName: string; const AEvent: TRecorderSqlDbMeraEvent;
  AOnTransferRequest: TRecorderMeraTransferRequestEvent;
  AOpenAllWhenLoaded: Boolean);
begin
  inherited Create(AOwner);
  fEvent := AEvent;
  fConfigFileName := AConfigFileName;
  fDialogResult := medrUnchanged;
  fOnTransferRequest := AOnTransferRequest;
  fOpenAllWhenLoaded := AOpenAllWhenLoaded;
  lblEventTime.Caption := FormatDateTime('dd.mm.yyyy hh:nn:ss',
    UniversalTimeToLocal(AEvent.StartedAtUtc));
  edDisplayName.Text := AEvent.DisplayName;
  memDescription.Text := AEvent.Description;
  lblStatus.Caption := 'Загрузка пакетов из SQL БД...';
  UpdateButtons;
  fLoader := TRecorderMeraPackageLoadThread.Create(Self, AConfigFileName,
    AEvent.EventId);
  fLoader.Start;
end;

destructor TRecorderMeraEventDialog.Destroy;
begin
  if fLoader <> nil then
  begin
    fLoader.Terminate;
    fLoader.WaitFor;
    fLoader.Free;
  end;
  inherited Destroy;
end;

procedure TRecorderMeraEventDialog.AcceptPackages(
  AWorker: TRecorderMeraPackageLoadThread);
begin
  if AWorker <> fLoader then Exit;
  fPackages := AWorker.fPackages;
  fEntryPaths := AWorker.fEntryPaths;
  fLocationIds := AWorker.fLocationIds;
  if AWorker.fErrorText <> '' then
    lblStatus.Caption := 'Ошибка чтения: ' + AWorker.fErrorText
  else
    lblStatus.Caption := Format('Загружено пакетов: %d', [Length(fPackages)]);
  FillPackages;
  if fOpenAllWhenLoaded then
  begin
    fOpenAllWhenLoaded := False;
    OpenPackages(False);
  end;
end;

function TRecorderMeraEventDialog.SaveChanges: Boolean;
var
  I: Integer;
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
begin
  Result := False;
  if Trim(edDisplayName.Text) = '' then
  begin
    MessageDlg('Имя события не может быть пустым.', mtWarning, [mbOK], 0);
    edDisplayName.SetFocus;
    Exit;
  end;
  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  try
    try
      lConfig.LoadFromFile(fConfigFileName);
      lRepository := TRecorderSqlDbRepository.Create(lConfig);
      if not lRepository.UpdateMeraEvent(fEvent.EventId,
        Trim(edDisplayName.Text), Trim(memDescription.Text)) then
        raise Exception.Create('Событие не найдено или уже удалено.');
      for I := 0 to High(fPackages) do
        if (I <= High(fLocationIds)) and (fLocationIds[I] <> '') and
          (Trim(grdPackages.Cells[6, I + 1]) <> fEntryPaths[I]) then
          if not lRepository.UpdateDataFileLocationPath(fEvent.EventId,
            fLocationIds[I], Trim(grdPackages.Cells[6, I + 1])) then
            raise Exception.CreateFmt('Не удалось изменить путь для хоста %s.',
              [fPackages[I].HostName]);
      fEvent.DisplayName := Trim(edDisplayName.Text);
      fEvent.Description := Trim(memDescription.Text);
      for I := 0 to High(fEntryPaths) do
        fEntryPaths[I] := Trim(grdPackages.Cells[6, I + 1]);
      fDialogResult := medrChanged;
      lblStatus.Caption := 'Изменения сохранены.';
      Result := True;
    except
      on E: Exception do
        MessageDlg('Ошибка сохранения события: ' + E.Message, mtError, [mbOK], 0);
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
end;

procedure TRecorderMeraEventDialog.btnSaveClick(Sender: TObject);
begin
  SaveChanges;
end;

procedure TRecorderMeraEventDialog.btnDeleteEventClick(Sender: TObject);
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
begin
  if MessageDlg('Удалить событие «' + edDisplayName.Text + '» от ' +
    lblEventTime.Caption + '?' + LineEnding + LineEnding +
    'Будут удалены только записи SQL. Физические MERA-файлы останутся на дисках.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  try
    try
      lConfig.LoadFromFile(fConfigFileName);
      lRepository := TRecorderSqlDbRepository.Create(lConfig);
      if not lRepository.DeleteMeraEvent(fEvent.EventId) then
        raise Exception.Create('Событие не найдено или уже удалено.');
      fDialogResult := medrDeleted;
      ModalResult := mrOK;
    except
      on E: Exception do
        MessageDlg('Ошибка удаления события: ' + E.Message, mtError, [mbOK], 0);
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
end;

procedure TRecorderMeraEventDialog.FillPackages;
var
  I: Integer;
begin
  grdPackages.RowCount := Max(2, Length(fPackages) + 1);
  for I := 1 to grdPackages.RowCount - 1 do
    grdPackages.Rows[I].Clear;
  for I := 0 to High(fPackages) do
  begin
    grdPackages.Cells[0, I + 1] := 'Да';
    grdPackages.Cells[1, I + 1] := fPackages[I].Recording.DisplayName;
    grdPackages.Cells[2, I + 1] := fPackages[I].HostName;
    grdPackages.Cells[3, I + 1] := fPackages[I].Recording.State;
    grdPackages.Cells[4, I + 1] := IntToStr(fPackages[I].FileCount);
    grdPackages.Cells[5, I + 1] := FormatFloat('#,##0', fPackages[I].TotalSize);
    grdPackages.Cells[6, I + 1] := fEntryPaths[I];
  end;
  UpdateButtons;
end;

procedure TRecorderMeraEventDialog.UpdateButtons;
var
  lReady: Boolean;
begin
  lReady := Length(fPackages) > 0;
  btnOpenAll.Enabled := lReady;
  btnOpenSelected.Enabled := lReady;
  btnTransferAll.Enabled := lReady;
  btnTransferSelected.Enabled := lReady;
end;

procedure TRecorderMeraEventDialog.grdPackagesSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if ACol = 6 then
    grdPackages.Options := grdPackages.Options + [goEditing]
  else
    grdPackages.Options := grdPackages.Options - [goEditing];
  if (ACol = 0) and (ARow > 0) and (ARow <= Length(fPackages)) then
  begin
    if grdPackages.Cells[0, ARow] = 'Да' then
      grdPackages.Cells[0, ARow] := 'Нет'
    else
      grdPackages.Cells[0, ARow] := 'Да';
  end;
end;

procedure TRecorderMeraEventDialog.grdPackagesDblClick(Sender: TObject);
begin
  if grdPackages.Col = 6 then
    grdPackages.EditorMode := True
  else
    OpenPackages(True);
end;

procedure TRecorderMeraEventDialog.OpenPackages(ASelectedOnly: Boolean);
var
  I, lOpened, lRequested: Integer;
begin
  lOpened := 0;
  lRequested := 0;
  for I := 0 to High(fPackages) do
  begin
    if ASelectedOnly and (grdPackages.Cells[0, I + 1] <> 'Да') then Continue;
    Inc(lRequested);
    if (Trim(grdPackages.Cells[6, I + 1]) <> '') and
      FileExists(Trim(grdPackages.Cells[6, I + 1])) and
      OpenDocument(Trim(grdPackages.Cells[6, I + 1])) then
      Inc(lOpened);
  end;
  lblStatus.Caption := Format('Открыто в WinПОС: %d; недоступно: %d',
    [lOpened, lRequested - lOpened]);
end;

procedure TRecorderMeraEventDialog.RequestTransfer(ASelectedOnly: Boolean);
var
  I, lCount: Integer;
  lIds: TRecorderMeraRecordingIds;
begin
  lCount := 0;
  SetLength(lIds, Length(fPackages));
  for I := 0 to High(fPackages) do
    if (not ASelectedOnly) or (grdPackages.Cells[0, I + 1] = 'Да') then
    begin
      lIds[lCount] := fPackages[I].Recording.Id;
      Inc(lCount);
    end;
  SetLength(lIds, lCount);
  if lCount = 0 then
    lblStatus.Caption := 'Не выбраны пакеты для переноса.'
  else if Assigned(fOnTransferRequest) then
  begin
    fOnTransferRequest(Self, lIds);
    lblStatus.Caption := Format('В очередь переноса передано: %d', [lCount]);
  end
  else
    lblStatus.Caption := 'Сервис переноса не подключён; запрос не отправлен.';
end;

procedure TRecorderMeraEventDialog.btnOpenSelectedClick(Sender: TObject);
begin
  OpenPackages(True);
end;

procedure TRecorderMeraEventDialog.btnOpenAllClick(Sender: TObject);
begin
  OpenPackages(False);
end;

procedure TRecorderMeraEventDialog.btnTransferSelectedClick(Sender: TObject);
begin
  RequestTransfer(True);
end;

procedure TRecorderMeraEventDialog.btnTransferAllClick(Sender: TObject);
begin
  RequestTransfer(False);
end;

end.
