unit uCoordinatorSqlEventStore;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, SyncObjs, uCoordinatorModel, uRecorderSqlDbTypes,
  uRecorderSqlDbRepository, uSharedFileLogger;

type
  { SQL persistence boundary for Coordinator-owned recording events.
    RecorderLnx only reports lifecycle messages; it never shares this
    connection or the acquisition SQL runtime with Coordinator. }
  TCoordinatorSqlEventStore = class
  private
    fLock: TCriticalSection;
    fConfig: TRecorderSqlDbConfig;
    fConfigFileName: string;
    fRepository: TRecorderSqlDbRepository;
    fAttachmentName: string;
    fLastError: string;
    fDiagnostics: TStringList;
    procedure AddDiagnosticLocked(const AText: string);
    function EnsureRepository: Boolean;
    function EntryPath(const AInfo: TCoordinatorRecordingLifecycle): string;
    function RelativeEntryName(const AInfo: TCoordinatorRecordingLifecycle): string;
    function StorageKey(const AInfo: TCoordinatorRecordingLifecycle;
      const ARelativeName: string): string;
    procedure VerifyPersistedEvent(const AEventId: string);
    procedure CloseRepository;
    procedure Persist(const AInfo: TCoordinatorRecordingLifecycle);
  public
    constructor Create(const AConfigFileName: string);
    destructor Destroy; override;
    function HandleLifecycle(
      const AInfo: TCoordinatorRecordingLifecycle): string;
    function BackendName: string;
    function ConfigFileName: string;
    function DatabaseDisplay: string;
    function Enabled: Boolean;
    function LastError: string;
    function ServerDisplay: string;
    function UserName: string;
    procedure DrainDiagnostics(ATarget: TStrings);
  end;

implementation

function UriPart(const AValue: string): string;
begin
  Result := Trim(AValue);
  Result := StringReplace(Result, '\', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, ':', '_', [rfReplaceAll]);
  if Result = '' then Result := '_';
end;

function ExistingFileSize(const AFileName: string): Int64;
var
  lStream: TFileStream;
begin
  Result := 0;
  if not FileExists(AFileName) then Exit;
  lStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := lStream.Size;
  finally
    lStream.Free;
  end;
end;

constructor TCoordinatorSqlEventStore.Create(const AConfigFileName: string);
begin
  inherited Create;
  fConfigFileName := ExpandFileName(AConfigFileName);
  fLock := TCriticalSection.Create;
  fDiagnostics := TStringList.Create;
  fConfig := TRecorderSqlDbConfig.Create;
  try
    fConfig.LoadFromFile(AConfigFileName);
  except
    on E: Exception do
    begin
      fLastError := E.Message;
      fConfig.Enabled := False;
    end;
  end;
end;

destructor TCoordinatorSqlEventStore.Destroy;
begin
  CloseRepository;
  fConfig.Free;
  fDiagnostics.Free;
  fLock.Free;
  inherited Destroy;
end;

procedure TCoordinatorSqlEventStore.AddDiagnosticLocked(const AText: string);
begin
  fDiagnostics.Add(AText);
  SharedLogger.Info('Coordinator SQL diagnostic ' + AText);
end;

procedure TCoordinatorSqlEventStore.DrainDiagnostics(ATarget: TStrings);
begin
  if ATarget = nil then Exit;
  fLock.Acquire;
  try
    ATarget.AddStrings(fDiagnostics);
    fDiagnostics.Clear;
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorSqlEventStore.CloseRepository;
begin
  fAttachmentName := '';
  FreeAndNil(fRepository);
end;

function TCoordinatorSqlEventStore.EnsureRepository: Boolean;
begin
  Result := False;
  if not Enabled then Exit;
  if fRepository = nil then
  begin
    fRepository := TRecorderSqlDbRepository.Create(fConfig);
    fAttachmentName := '';
  end;
  fRepository.EnsureDatabase;
  if fAttachmentName = '' then
    fRepository.DatabaseAttachmentName(fAttachmentName);
  Result := True;
end;

function TCoordinatorSqlEventStore.Enabled: Boolean;
begin
  Result := (fConfig <> nil) and fConfig.Enabled;
end;

function TCoordinatorSqlEventStore.BackendName: string;
begin
  Result := RecorderSqlDbBackendToString(fConfig.Backend);
end;

function TCoordinatorSqlEventStore.ConfigFileName: string;
begin
  Result := fConfigFileName;
end;

function TCoordinatorSqlEventStore.DatabaseDisplay: string;
begin
  Result := fConfig.DatabaseFileName;
end;

function TCoordinatorSqlEventStore.ServerDisplay: string;
begin
  Result := Trim(fConfig.Host);
  if Result = '' then Result := 'local';
  if fConfig.Port <> 0 then
    Result := Result + ':' + IntToStr(fConfig.Port);
end;

function TCoordinatorSqlEventStore.UserName: string;
begin
  Result := fConfig.UserName;
end;

function TCoordinatorSqlEventStore.LastError: string;
begin
  fLock.Acquire;
  try
    Result := fLastError;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorSqlEventStore.EntryPath(
  const AInfo: TCoordinatorRecordingLifecycle): string;
begin
  Result := Trim(AInfo.EntryFile);
  if (Result = '') and (Trim(AInfo.LocalPath) <> '') then
    Result := IncludeTrailingPathDelimiter(AInfo.LocalPath) + 'record.mera';
end;

function TCoordinatorSqlEventStore.RelativeEntryName(
  const AInfo: TCoordinatorRecordingLifecycle): string;
begin
  Result := ExtractFileName(EntryPath(AInfo));
  if Result = '' then Result := 'record.mera';
end;

function TCoordinatorSqlEventStore.StorageKey(
  const AInfo: TCoordinatorRecordingLifecycle;
  const ARelativeName: string): string;
begin
  Result := 'recorder://' + UriPart(AInfo.InstanceId) + '/' +
    UriPart(AInfo.RecordingId) + '/' + UriPart(ARelativeName);
end;

procedure TCoordinatorSqlEventStore.VerifyPersistedEvent(const AEventId: string);
var
  lAttachment: string;
  lRecordingCount: Integer;
  lEventUtc, lFirstStartedUtc, lLastFinishedUtc: Double;
begin
  lAttachment := '';
  if not fRepository.GetMeraEventSnapshot(AEventId, lEventUtc,
    lFirstStartedUtc, lLastFinishedUtc, lRecordingCount) then
    raise Exception.CreateFmt(
      'SQL commit completed, but event %s cannot be read back', [AEventId]);
  if not fRepository.DatabaseAttachmentName(lAttachment) then
    lAttachment := '(не определён)';
  AddDiagnosticLocked(Format(
    'SQL event подтверждён чтением: event_id=%s; event_utc=%s; ' +
    'started_utc=%s; finished_utc=%s; замеров=%d; backend=%s; server=%s; ' +
    'database=%s; attachment=%s',
    [AEventId, FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"',
       lEventUtc), FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"',
       lFirstStartedUtc), FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"',
       lLastFinishedUtc), lRecordingCount, BackendName, ServerDisplay,
       DatabaseDisplay, lAttachment]));
end;

procedure TCoordinatorSqlEventStore.Persist(
  const AInfo: TCoordinatorRecordingLifecycle);
var
  lDbInstanceId: string;
  lEntryPath, lRelativeName: string;
  lFile: TRecorderSqlDbMeraFile;
  lLocation: TRecorderSqlDbFileLocation;
  lExisting, lRecording: TRecorderSqlDbMeraRecording;
  lFinal: Boolean;
begin
  if (Trim(AInfo.RecordingId) = '') or (Trim(AInfo.InstanceId) = '') then
    raise Exception.Create('Recording lifecycle has no recording/instance id');
  if not EnsureRepository then Exit;

  lDbInstanceId := fRepository.UpsertRecorderInstance(AInfo.InstanceId,
    AInfo.HostName, AInfo.DisplayName, {$ifdef windows}'windows'{$else}'linux'{$endif},
    Now);
  lRecording := Default(TRecorderSqlDbMeraRecording);
  lRecording.Id := AInfo.RecordingId;
  lRecording.EventId := AInfo.EventId;
  lRecording.RecorderInstanceId := lDbInstanceId;
  lRecording.CorrelationId := AInfo.CorrelationId;
  lRecording.DisplayName := AInfo.DisplayName;
  lRecording.ProjectName := AInfo.ProjectName;
  lRecording.StartedAtUtc := AInfo.StartedUtc;
  if lRecording.StartedAtUtc = 0 then
    lRecording.StartedAtUtc := LocalTimeToUniversal(Now);
  lFinal := SameText(AInfo.MessageType, 'recording.completed') or
    SameText(AInfo.MessageType, 'recording.failed');
  { A legacy completed notification may omit started_utc. Preserve the value
    already accepted for this host instead of moving the start to completion. }
  if lFinal and fRepository.GetCurrentMeraRecording(lDbInstanceId, lExisting) and
    SameText(lExisting.Id, AInfo.RecordingId) then
    lRecording.StartedAtUtc := lExisting.StartedAtUtc;
  lRecording.State := AInfo.State;
  if lRecording.State = '' then lRecording.State := 'building';
  fRepository.BeginMeraRecording(lRecording);

  lEntryPath := EntryPath(AInfo);
  lRelativeName := RelativeEntryName(AInfo);
  lFile := Default(TRecorderSqlDbMeraFile);
  { One descriptor is currently reported by the client. Reusing recording_id
    as its file id makes retries idempotent until a full manifest is added. }
  lFile.FileId := AInfo.RecordingId;
  lFile.RecordingId := AInfo.RecordingId;
  lFile.FileRole := 'entry-mera';
  lFile.RelativeName := lRelativeName;
  lFile.StorageKey := StorageKey(AInfo, lRelativeName);
  lFile.DataFormat := 'mera';
  if (lEntryPath <> '') and FileExists(lEntryPath) then
    lFile.Size := ExistingFileSize(lEntryPath)
  else
    lFile.Size := 0;
  if lFinal then lFile.State := 'ready' else lFile.State := 'building';
  fRepository.UpsertMeraFile(lFile);

  if lEntryPath <> '' then
  begin
    lLocation := Default(TRecorderSqlDbFileLocation);
    lLocation.FileId := lFile.FileId;
    lLocation.RecorderInstanceId := lDbInstanceId;
    lLocation.LocationKind := 'source-local';
    lLocation.PathKey := lEntryPath;
    { ready means that the source Recorder reported a completed package. The
      Coordinator need not be able to stat a path located on another host. }
    if lFinal then lLocation.State := 'ready' else lLocation.State := 'building';
    lLocation.CreatedAtUtc := lRecording.StartedAtUtc;
    if lFinal then lLocation.VerifiedAtUtc := AInfo.FinishedUtc;
    fRepository.UpsertDataFileLocation(lLocation);
  end;

  if lFinal then
  begin
    if SameText(AInfo.MessageType, 'recording.failed') then
      lRecording.State := 'failed'
    else
      lRecording.State := 'ready-local';
    if AInfo.FinishedUtc = 0 then
      lRecording.FinishedAtUtc := LocalTimeToUniversal(Now)
    else lRecording.FinishedAtUtc := AInfo.FinishedUtc;
    fRepository.CompleteMeraRecording(AInfo.RecordingId, lRecording.State,
      lFile.FileId, '', lRecording.FinishedAtUtc);
  end;
end;

function TCoordinatorSqlEventStore.HandleLifecycle(
  const AInfo: TCoordinatorRecordingLifecycle): string;
begin
  Result := '';
  if not Enabled then
  begin
    fLock.Acquire;
    try
      AddDiagnosticLocked(Format(
        'SQL event store пропущен: disabled; event_id=%s; config=%s',
        [AInfo.EventId, fConfigFileName]));
    finally
      fLock.Release;
    end;
    Exit;
  end;
  SharedLogger.Info(Format(
    'SQL lifecycle begin recording=%s event=%s path=%s message=%s',
    [AInfo.RecordingId, AInfo.EventId, EntryPath(AInfo), AInfo.MessageType]));
  fLock.Acquire;
  try
    try
      Persist(AInfo);
      VerifyPersistedEvent(AInfo.EventId);
      fLastError := '';
      AddDiagnosticLocked(Format(
        'SQL event store OK: event_id=%s; recording=%s; message=%s; ' +
        'backend=%s; server=%s; database=%s; attachment=%s; config=%s',
        [AInfo.EventId, AInfo.RecordingId, AInfo.MessageType, BackendName,
         ServerDisplay, DatabaseDisplay, fAttachmentName, fConfigFileName]));
      SharedLogger.Info(Format(
        'SQL lifecycle success recording=%s event=%s path=%s message=%s',
        [AInfo.RecordingId, AInfo.EventId, EntryPath(AInfo), AInfo.MessageType]));
    except
      on E: Exception do
      begin
        fLastError := E.Message;
        Result := fLastError;
        AddDiagnosticLocked(Format(
          'SQL event store ERROR: event_id=%s; %s: %s',
          [AInfo.EventId, E.ClassName, E.Message]));
        SharedLogger.Error(Format(
          'SQL lifecycle error recording=%s event=%s path=%s class=%s message=%s',
          [AInfo.RecordingId, AInfo.EventId, EntryPath(AInfo), E.ClassName,
           E.Message]));
        { A broken connection/transaction is not reused. The next lifecycle
          message retries from idempotent database keys. }
        try
          CloseRepository;
        except
          { Preserve the original SQL error. Cleanup must not replace it or
            escape from the optional persistence boundary. }
        end;
      end;
    end;
  finally
    fLock.Release;
  end;
end;

end.
