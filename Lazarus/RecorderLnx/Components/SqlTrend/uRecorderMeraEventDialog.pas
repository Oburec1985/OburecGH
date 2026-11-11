unit uRecorderMeraEventDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Grids,
  Graphics, uRecorderSqlDbTypes;

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
    fSourceHosts: array of string;
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
    procedure btnDeleteEventClick({%H-}Sender: TObject);
    procedure btnOpenAllClick({%H-}Sender: TObject);
    procedure btnOpenSelectedClick({%H-}Sender: TObject);
    procedure btnTransferAllClick({%H-}Sender: TObject);
    procedure btnTransferSelectedClick({%H-}Sender: TObject);
    procedure btnSaveClick({%H-}Sender: TObject);
    procedure grdPackagesDblClick({%H-}Sender: TObject);
    procedure grdPackagesDrawCell({%H-}Sender: TObject; ACol, ARow: Integer;
      ARect: TRect; AState: TGridDrawState);
    procedure grdPackagesSelectCell({%H-}Sender: TObject; ACol, ARow: Integer;
      var {%H-}CanSelect: Boolean);
  private
    fEvent: TRecorderSqlDbMeraEvent;
    fConfigFileName: string;
    fDialogResult: TRecorderMeraEventDialogResult;
    fLoader: TRecorderMeraPackageLoadThread;
    fOnTransferRequest: TRecorderMeraTransferRequestEvent;
    fPackages: TRecorderSqlDbMeraPackages;
    fEntryPaths: array of string;
    fLocationIds: array of string;
    fSourceHosts: array of string;
    fLoadError: string;
    fOpenAllWhenLoaded: Boolean;
    procedure AcceptPackages(AWorker: TRecorderMeraPackageLoadThread);
    procedure FillPackages;
    procedure OpenPackages(ASelectedOnly: Boolean);
    procedure OpenPackage(AIndex: Integer);
    function RepairMissingPaths(const ARootDirectory,
      AHostName: string): Integer;
    procedure RequestTransfer(ASelectedOnly: Boolean);
    function SaveChanges: Boolean;
    procedure UpdateButtons;
    procedure UpdateStatusCaption;
    function UnresolvedRowCount: Integer;
    function RowResolves(AIndex: Integer): Boolean;
    function RowPending(AIndex: Integer): Boolean;
    function ResolvePackagePath(AIndex: Integer; const APath: string): string;
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
  DateUtils, LCLIntf, Dialogs, uRecorderSqlDbRepository,
  uRecorderNetworkPathResolver;

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
  lEntryPath, lFrameDir, lFrameName, lSourceHost: string;
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
      SetLength(fSourceHosts, Length(fPackages));
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
              if (SameText(lLocations[K].State, 'ready') or
                  SameText(lLocations[K].State, 'building')) and
                 (Trim(lLocations[K].PathKey) <> '') then
              begin
                lSourceHost := '';
                if SameText(lLocations[K].LocationKind, 'source-local') then
                  lSourceHost := fPackages[I].HostName;
                lEntryPath := ResolveRecorderNetworkPath(
                  lLocations[K].PathKey, lSourceHost);
                if fEntryPaths[I] = '' then
                begin
                  fEntryPaths[I] := lEntryPath;
                  if fEntryPaths[I] = '' then fEntryPaths[I] := lLocations[K].PathKey;
                  fLocationIds[I] := lLocations[K].Id;
                  fSourceHosts[I] := lSourceHost;
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
                  fSourceHosts[I] := lSourceHost;
                  Break;
                end;
              end;
            Break;
          end;
      end;
    except
      on E: Exception do fErrorText := E.Message;
    end;
    { Deliver only materialized values. UI edit commands must not run while
      this worker retains a database connection/read transaction. }
    FreeAndNil(lRepository);
    FreeAndNil(lConfig);
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
  fSourceHosts := AWorker.fSourceHosts;
  fLoadError := AWorker.fErrorText;
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
      begin
        if fEntryPaths[I] <> Trim(grdPackages.Cells[6, I + 1]) then
          fSourceHosts[I] := ''; { An explicit operator-selected local copy. }
        fEntryPaths[I] := Trim(grdPackages.Cells[6, I + 1]);
      end;
      fDialogResult := medrChanged;
      lblStatus.Caption := 'Изменения сохранены.';
      Result := True;
    except
      on E: Exception do
        MessageDlg(UTF8Encode('Ошибка сохранения события: ') + E.Message,
          mtError, [mbOK], 0);
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
  if MessageDlg(UTF8Encode('Удалить событие «') + edDisplayName.Text +
    UTF8Encode('» от ') + lblEventTime.Caption + '?' + LineEnding + LineEnding +
    UTF8Encode('Будут удалены только записи SQL. Физические MERA-файлы останутся на дисках.'),
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
        MessageDlg(UTF8Encode('Ошибка удаления события: ') + E.Message,
          mtError, [mbOK], 0);
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
end;

function TRecorderMeraEventDialog.ResolvePackagePath(AIndex: Integer;
  const APath: string): string;
var
  lSourceHost: string;
begin
  lSourceHost := '';
  if (AIndex >= 0) and (AIndex <= High(fSourceHosts)) and
    (AIndex <= High(fEntryPaths)) and (Trim(APath) = fEntryPaths[AIndex]) then
    lSourceHost := fSourceHosts[AIndex];
  Result := ResolveRecorderNetworkPath(Trim(APath), lSourceHost);
end;

function TRecorderMeraEventDialog.RowResolves(AIndex: Integer): Boolean;
var
  lPath: string;
begin
  Result := False;
  if (AIndex < 0) or (AIndex > High(fPackages)) or
    (AIndex > High(fEntryPaths)) then Exit;
  lPath := ResolvePackagePath(AIndex, grdPackages.Cells[6, AIndex + 1]);
  Result := (lPath <> '') and FileExists(lPath);
end;

function TRecorderMeraEventDialog.RowPending(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex <= High(fPackages)) and
    SameText(fPackages[AIndex].Recording.State, 'building');
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
    grdPackages.Cells[0, I + 1] := UTF8Encode('Да');
    grdPackages.Cells[1, I + 1] := fPackages[I].Recording.DisplayName;
    grdPackages.Cells[2, I + 1] := fPackages[I].HostName;
    grdPackages.Cells[3, I + 1] := fPackages[I].Recording.State;
    if fPackages[I].FileCount < 0 then grdPackages.Cells[4, I + 1] := '-'
    else grdPackages.Cells[4, I + 1] := IntToStr(fPackages[I].FileCount);
    if fPackages[I].TotalSize < 0 then grdPackages.Cells[5, I + 1] := '-'
    else grdPackages.Cells[5, I + 1] := FormatFloat('#,##0', fPackages[I].TotalSize);
    grdPackages.Cells[6, I + 1] := fEntryPaths[I];
  end;
  UpdateButtons;
  UpdateStatusCaption;
end;

function TRecorderMeraEventDialog.UnresolvedRowCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(fPackages) do
    if not RowPending(I) and not RowResolves(I) then Inc(Result);
end;

procedure TRecorderMeraEventDialog.UpdateStatusCaption;
var
  lUnresolved, lPending, I: Integer;
begin
  if fLoadError <> '' then
  begin
    lblStatus.Caption := UTF8Encode('Ошибка чтения: ') + fLoadError;
    Exit;
  end;
  lUnresolved := UnresolvedRowCount;
  if Length(fPackages) = 0 then
  begin
    { Записи в SQL есть, а пакеты не зарегистрированы — WinПОС открывать
      нечего. Причина чаще всего в неполной публикации mera_recording_files. }
    lblStatus.Caption := UTF8Encode('Замер не найден: ') +
      UTF8Encode('данные записи отсутствуют в SQL БД, WinПОС не сможет ' +
        'открыть это событие.');
    Exit;
  end;
  lblStatus.Caption := Format('Загружено пакетов: %d', [Length(fPackages)]);
  lPending := 0;
  for I := 0 to High(fPackages) do
    if RowPending(I) then Inc(lPending);
  if lPending > 0 then
    lblStatus.Caption := lblStatus.Caption + Format(' | Записывается: %d', [lPending]);
  if lUnresolved > 0 then
    lblStatus.Caption := lblStatus.Caption + ' | ' + UTF8Encode('замер не ' +
      'найден: ') + IntToStr(lUnresolved) + UTF8Encode(' (нет файла на диске)');
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
  if not lReady then
  begin
    btnOpenAll.Hint := UTF8Encode('Данные замера в WinПОС не найдены');
    btnOpenSelected.Hint := btnOpenAll.Hint;
    btnOpenAll.ShowHint := True;
    btnOpenSelected.ShowHint := True;
  end
  else
  begin
    btnOpenAll.Hint := '';
    btnOpenSelected.Hint := '';
    btnOpenAll.ShowHint := False;
    btnOpenSelected.ShowHint := False;
  end;
end;

{
  Ячейки «Замер» и «Путь MERA»: иконкой подписывается замер, который не
  резолвится — файла нет по указанному пути, поэтому ни открыть, ни перенести
  его нельзя. Физическая проверка выполняется на перерисовке; для таблиц
  замера это сотни строк, и файловые вызовы здесь допустимы.
}
procedure TRecorderMeraEventDialog.grdPackagesDrawCell(Sender: TObject;
  ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  lResolved: Boolean;
  lText: string;
  lIconRect: TRect;
  lBitmap: TBitmap;
begin
  if (ARow <= 0) or (ARow > Length(fPackages)) or
    ((ACol <> 1) and (ACol <> 6)) then Exit;
  if RowPending(ARow - 1) then Exit;
  lResolved := RowResolves(ARow - 1);
  lText := grdPackages.Cells[ACol, ARow];
  if not lResolved then
  begin
    grdPackages.Canvas.FillRect(ARect);
    { Мини-иконка «нет данных»: жёлтый квадрат с крестом, без внешних
      ресурсов — одинаково на Windows и Linux. }
    lBitmap := TBitmap.Create;
    try
      lBitmap.SetSize(12, 12);
      lBitmap.Canvas.Brush.Color := clYellow;
      lBitmap.Canvas.FillRect(0, 0, 12, 12);
      lBitmap.Canvas.Pen.Color := clMaroon;
      lBitmap.Canvas.Rectangle(0, 0, 12, 12);
      lBitmap.Canvas.Line(2, 2, 10, 10);
      lBitmap.Canvas.Line(10, 2, 2, 10);
      lIconRect.Left := ARect.Left + 3;
      lIconRect.Top := ARect.Top + Max(2, (ARect.Height - 12) div 2);
      lIconRect.Right := lIconRect.Left + 12;
      lIconRect.Bottom := lIconRect.Top + 12;
      grdPackages.Canvas.Draw(lIconRect.Left, lIconRect.Top, lBitmap);
    finally
      lBitmap.Free;
    end;
    if gdSelected in AState then
      grdPackages.Canvas.Font.Color := clHighlightText
    else
      grdPackages.Canvas.Font.Color := clMaroon;
    grdPackages.Canvas.TextOut(lIconRect.Right + 4, ARect.Top + 3,
      lText);
  end;
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
    if grdPackages.Cells[0, ARow] = UTF8Encode('Да') then
      grdPackages.Cells[0, ARow] := UTF8Encode('Нет')
    else
      grdPackages.Cells[0, ARow] := UTF8Encode('Да');
  end;
end;

procedure TRecorderMeraEventDialog.grdPackagesDblClick(Sender: TObject);
begin
  if grdPackages.Col = 6 then
    grdPackages.EditorMode := True
  else if (grdPackages.Row > 0) and
    (grdPackages.Row <= Length(fPackages)) then
    OpenPackage(grdPackages.Row - 1);
end;

function FindNamedFileRecursive(const ARoot, AFileName: string;
  out AFound: string): Boolean;
var
  lInfo: TSearchRec;
  lPath: string;
begin
  Result := False;
  AFound := '';
  if FindFirst(IncludeTrailingPathDelimiter(ARoot) + '*', faAnyFile,
    lInfo) <> 0 then Exit;
  try
    repeat
      if (lInfo.Name = '.') or (lInfo.Name = '..') then Continue;
      lPath := IncludeTrailingPathDelimiter(ARoot) + lInfo.Name;
      if (lInfo.Attr and faDirectory) <> 0 then
      begin
        if FindNamedFileRecursive(lPath, AFileName, AFound) then Exit(True);
      end
      else if SameText(lInfo.Name, AFileName) then
      begin
        AFound := lPath;
        Exit(True);
      end;
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
end;

function TRecorderMeraEventDialog.RepairMissingPaths(
  const ARootDirectory, AHostName: string): Integer;
var
  I: Integer;
  lConfig: TRecorderSqlDbConfig;
  lExpectedName, lFound, lRawPath, lResolved: string;
  lRepository: TRecorderSqlDbRepository;
begin
  Result := 0;
  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  try
    lConfig.LoadFromFile(fConfigFileName);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    for I := 0 to High(fPackages) do
    begin
      if not SameText(Trim(fPackages[I].HostName), Trim(AHostName)) then Continue;
      lRawPath := Trim(grdPackages.Cells[6, I + 1]);
      lResolved := ResolvePackagePath(I, lRawPath);
      if (lResolved <> '') and FileExists(lResolved) then Continue;
      if (I > High(fLocationIds)) or (fLocationIds[I] = '') then Continue;
      lExpectedName := ExtractFileName(StringReplace(lRawPath, '\', '/',
        [rfReplaceAll]));
      if (lExpectedName = '') or (ExtractFileExt(lExpectedName) = '') then
        lExpectedName := fPackages[I].Recording.DisplayName + '.mera';
      if FindNamedFileRecursive(ARootDirectory, lExpectedName, lFound) and
        lRepository.UpdateDataFileLocationPath(fEvent.EventId,
          fLocationIds[I], lFound) then
      begin
        fEntryPaths[I] := lFound;
        fSourceHosts[I] := '';
        grdPackages.Cells[6, I + 1] := lFound;
        Inc(Result);
      end;
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
end;

procedure TRecorderMeraEventDialog.OpenPackage(AIndex: Integer);
var
  lDirectory, lExpectedName, lFound, lOpenPath, lRawPath: string;
  lRepaired: Integer;
begin
  if (AIndex < 0) or (AIndex > High(fPackages)) then Exit;
  if RowPending(AIndex) then
  begin
    lblStatus.Caption := 'Запись ещё выполняется. Открытие доступно после завершения.';
    Exit;
  end;
  lOpenPath := ResolvePackagePath(AIndex, grdPackages.Cells[6, AIndex + 1]);
  if (lOpenPath <> '') and FileExists(lOpenPath) and OpenDocument(lOpenPath) then
  begin
    lblStatus.Caption := 'Открыт выбранный замер.';
    Exit;
  end;
  lDirectory := '';
  if not SelectDirectory(
    'Сетевой путь недоступен. Укажите каталог, где искать замеры события',
    '', lDirectory) then
  begin
    lblStatus.Caption := 'Путь выбранного замера недоступен.';
    Exit;
  end;
  lRawPath := Trim(grdPackages.Cells[6, AIndex + 1]);
  lExpectedName := ExtractFileName(StringReplace(lRawPath, '\', '/',
    [rfReplaceAll]));
  if (lExpectedName = '') or (ExtractFileExt(lExpectedName) = '') then
    lExpectedName := fPackages[AIndex].Recording.DisplayName + '.mera';
  if not FindNamedFileRecursive(lDirectory, lExpectedName, lFound) then
  begin
    MessageDlg(UTF8Encode('Замер не найден'),
      UTF8Encode('В выбранном каталоге нет файла ') +
      lExpectedName + '. Пути в SQL не изменены.', mtWarning, [mbOK], 0);
    Exit;
  end;
  lRepaired := RepairMissingPaths(lDirectory, fPackages[AIndex].HostName);
  lOpenPath := ResolvePackagePath(AIndex, grdPackages.Cells[6, AIndex + 1]);
  if (lOpenPath <> '') and FileExists(lOpenPath) and OpenDocument(lOpenPath) then
    lblStatus.Caption := Format('Открыт выбранный замер; исправлено путей: %d',
      [lRepaired])
  else
    MessageDlg(UTF8Encode('Замер не найден'),
      UTF8Encode('В выбранном каталоге файл выбранного замера не найден. Исправлено других путей: ') +
      IntToStr(lRepaired), mtWarning, [mbOK], 0);
end;

procedure TRecorderMeraEventDialog.OpenPackages(ASelectedOnly: Boolean);
var
  I, lOpened, lRequested: Integer;
  lOpenPath: string;
begin
  lOpened := 0;
  lRequested := 0;
  for I := 0 to High(fPackages) do
  begin
    if RowPending(I) then Continue;
    if ASelectedOnly and
      (grdPackages.Cells[0, I + 1] <> UTF8Encode('Да')) then Continue;
    Inc(lRequested);
    lOpenPath := ResolvePackagePath(I, grdPackages.Cells[6, I + 1]);
    if (lOpenPath <> '') and FileExists(lOpenPath) and
      OpenDocument(lOpenPath) then
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
    if not RowPending(I) and ((not ASelectedOnly) or
      (grdPackages.Cells[0, I + 1] = UTF8Encode('Да'))) then
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
