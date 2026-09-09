unit uCoordinatorConfig;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, IniFiles;

type
  TStorageKind = (skLocal, skSmb, skSftp);

  TStorageConfig = class
  public
    Name: string;
    Kind: TStorageKind;
    RootPath: string;
    Host: string;
    UserName: string;
    function KindName: string;
  end;

  TCoordinatorConfig = class
  private
    fFileName: string;
    fStorages: TFPList;
    fHosts: TStringList;
    procedure ClearStorages;
  public
    ListenAddress: string;
    Port: Word;
    EventWindowSec: Integer;
    CreateRecordingEvents: Boolean;
    StartAllOnAnyRecording: Boolean;
    SqlDbConfigFile: string;
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    function AddStorage: TStorageConfig;
    function StorageCount: Integer;
    function Storage(AIndex: Integer): TStorageConfig;
    function TestStorage(AStorage: TStorageConfig; out AMessage: string): Boolean;
    procedure AddHost(const AInstanceId, ADisplayName: string);
    function HostCount: Integer;
    function HostId(AIndex: Integer): string;
    function HostName(AIndex: Integer): string;
    property FileName: string read fFileName;
  end;

function IsAbsoluteConfigPath(const AFileName: string): Boolean;

implementation

const
  LINUX_RECORDER_SQL_CONFIG =
    '/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini';

function IsAbsoluteConfigPath(const AFileName: string): Boolean;
begin
  Result := (AFileName <> '') and
    ((AFileName[1] = '/') or (AFileName[1] = '\\') or
     (ExtractFileDrive(AFileName) <> ''));
end;

function RepairLegacySqlConfigPath(const AFileName: string): string;
var
  lPosition: SizeInt;
begin
  Result := AFileName;
  { Older builds treated a Unix root path as relative and prepended the
    Coordinator directory on every Load/Save cycle. Recover the canonical
    RecorderLnx SQL config from such persisted values. }
  lPosition := Pos(LINUX_RECORDER_SQL_CONFIG, AFileName);
  if lPosition > 0 then
    Result := Copy(AFileName, lPosition, MaxInt);
end;

function StorageKindFromName(const AValue: string): TStorageKind;
begin
  if SameText(AValue, 'smb') then Exit(skSmb);
  if SameText(AValue, 'sftp') then Exit(skSftp);
  Result := skLocal;
end;

function TStorageConfig.KindName: string;
begin
  case Kind of
    skSmb: Result := 'smb';
    skSftp: Result := 'sftp';
  else
    Result := 'local';
  end;
end;

constructor TCoordinatorConfig.Create(const AFileName: string);
begin
  inherited Create;
  fFileName := AFileName;
  fStorages := TFPList.Create;
  fHosts := TStringList.Create;
  fHosts.NameValueSeparator := '=';
  ListenAddress := '0.0.0.0';
  Port := 8765;
  EventWindowSec := 30;
  CreateRecordingEvents := True;
  StartAllOnAnyRecording := False;
  { By default the Coordinator's adjacent INI also contains [SQLdb]. A
    separate SQL config can be selected through events/sql_db_config. }
  {$IFDEF UNIX}
  SqlDbConfigFile := LINUX_RECORDER_SQL_CONFIG;
  {$ELSE}
  SqlDbConfigFile := fFileName;
  {$ENDIF}
end;

destructor TCoordinatorConfig.Destroy;
begin
  ClearStorages;
  fStorages.Free;
  fHosts.Free;
  inherited Destroy;
end;

procedure TCoordinatorConfig.ClearStorages;
var lIndex: Integer;
begin
  for lIndex := 0 to fStorages.Count - 1 do TObject(fStorages[lIndex]).Free;
  fStorages.Clear;
end;

function TCoordinatorConfig.AddStorage: TStorageConfig;
begin
  Result := TStorageConfig.Create;
  Result.Name := 'Новое хранилище';
  Result.Kind := skLocal;
  fStorages.Add(Result);
end;

function TCoordinatorConfig.StorageCount: Integer;
begin
  Result := fStorages.Count;
end;

function TCoordinatorConfig.Storage(AIndex: Integer): TStorageConfig;
begin
  Result := TStorageConfig(fStorages[AIndex]);
end;

procedure TCoordinatorConfig.Load;
var
  lIni: TIniFile;
  lCount, lIndex: Integer;
  lStorage: TStorageConfig;
  lSection, lCandidate, lStoredSqlConfig: string;
  lSqlConfigChanged: Boolean;
begin
  ClearStorages;
  fHosts.Clear;
  if not FileExists(fFileName) then
  begin
    lStorage := AddStorage;
    lStorage.Name := 'Локальный архив';
    lStorage.RootPath := IncludeTrailingPathDelimiter(ExtractFilePath(fFileName)) + 'archive';
    Exit;
  end;
  lIni := TIniFile.Create(fFileName);
  try
    ListenAddress := lIni.ReadString('service', 'listen', ListenAddress);
    Port := lIni.ReadInteger('service', 'port', Port);
    EventWindowSec := lIni.ReadInteger('service', 'event_window_sec', EventWindowSec);
    CreateRecordingEvents := lIni.ReadBool('events', 'create_recording_events',
      CreateRecordingEvents);
    StartAllOnAnyRecording := lIni.ReadBool('commands',
      'start_all_on_any_recording', StartAllOnAnyRecording);
    lStoredSqlConfig := Trim(lIni.ReadString('events', 'sql_db_config',
      SqlDbConfigFile));
    SqlDbConfigFile := RepairLegacySqlConfigPath(lStoredSqlConfig);
    if (Trim(SqlDbConfigFile) <> '') and
      (not IsAbsoluteConfigPath(SqlDbConfigFile)) then
      SqlDbConfigFile := ExpandFileName(IncludeTrailingPathDelimiter(
        ExtractFilePath(fFileName)) + SqlDbConfigFile);
    lSqlConfigChanged := SqlDbConfigFile <> lStoredSqlConfig;
    if SameFileName(SqlDbConfigFile, fFileName) and
      (not lIni.SectionExists('SQLdb')) then
    begin
      lCandidate := IncludeTrailingPathDelimiter(ExtractFilePath(fFileName)) +
        'sql-db.ini';
      if FileExists(lCandidate) then
        SqlDbConfigFile := lCandidate
      else
      begin
        { Development tree: Coordinator/lib/<platform> is beside RecorderLnx. }
        lCandidate := ExpandFileName(IncludeTrailingPathDelimiter(
          ExtractFilePath(fFileName)) + '..' + DirectorySeparator + '..' +
          DirectorySeparator + '..' + DirectorySeparator + 'RecorderLnx' +
          DirectorySeparator + 'config' + DirectorySeparator + 'projects' +
          DirectorySeparator + 'default' + DirectorySeparator + 'sql-db.ini');
        if FileExists(lCandidate) then SqlDbConfigFile := lCandidate;
      end;
    end;
    { A legacy malformed or moved config must not permanently disable event
      creation. Prefer an existing adjacent config, then the installed Linux
      RecorderLnx config, then the development-tree config. }
    if (not FileExists(SqlDbConfigFile)) or
      (SameFileName(SqlDbConfigFile, fFileName) and
       (not lIni.SectionExists('SQLdb'))) then
    begin
      lCandidate := IncludeTrailingPathDelimiter(ExtractFilePath(fFileName)) +
        'sql-db.ini';
      if FileExists(lCandidate) then
        SqlDbConfigFile := ExpandFileName(lCandidate)
      else if FileExists(LINUX_RECORDER_SQL_CONFIG) then
        SqlDbConfigFile := LINUX_RECORDER_SQL_CONFIG
      else
      begin
        lCandidate := ExpandFileName(IncludeTrailingPathDelimiter(
          ExtractFilePath(fFileName)) + '..' + DirectorySeparator + '..' +
          DirectorySeparator + '..' + DirectorySeparator + 'RecorderLnx' +
          DirectorySeparator + 'config' + DirectorySeparator + 'projects' +
          DirectorySeparator + 'default' + DirectorySeparator + 'sql-db.ini');
        if FileExists(lCandidate) then SqlDbConfigFile := lCandidate;
      end;
    end;
    lSqlConfigChanged := lSqlConfigChanged or
      (SqlDbConfigFile <> lStoredSqlConfig);
    if lSqlConfigChanged then
    begin
      lIni.WriteString('events', 'sql_db_config', SqlDbConfigFile);
      lIni.UpdateFile;
    end;
    lCount := lIni.ReadInteger('hosts', 'count', 0);
    for lIndex := 0 to lCount - 1 do
      AddHost(lIni.ReadString('host.' + IntToStr(lIndex), 'id', ''),
        lIni.ReadString('host.' + IntToStr(lIndex), 'name', ''));
    lCount := lIni.ReadInteger('storages', 'count', 0);
    for lIndex := 0 to lCount - 1 do
    begin
      lSection := 'storage.' + IntToStr(lIndex);
      lStorage := AddStorage;
      lStorage.Name := lIni.ReadString(lSection, 'name', lStorage.Name);
      lStorage.Kind := StorageKindFromName(lIni.ReadString(lSection, 'kind', 'local'));
      lStorage.RootPath := lIni.ReadString(lSection, 'root', '');
      lStorage.Host := lIni.ReadString(lSection, 'host', '');
      lStorage.UserName := lIni.ReadString(lSection, 'user', '');
    end;
  finally
    lIni.Free;
  end;
end;

procedure TCoordinatorConfig.Save;
var
  lIni: TIniFile;
  lIndex: Integer;
  lStorage: TStorageConfig;
  lSection: string;
begin
  lIni := TIniFile.Create(fFileName);
  try
    lIni.WriteString('service', 'listen', ListenAddress);
    lIni.WriteInteger('service', 'port', Port);
    lIni.WriteInteger('service', 'event_window_sec', EventWindowSec);
    lIni.WriteBool('events', 'create_recording_events', CreateRecordingEvents);
    lIni.WriteBool('commands', 'start_all_on_any_recording',
      StartAllOnAnyRecording);
    lIni.WriteString('events', 'sql_db_config', SqlDbConfigFile);
    lIni.WriteInteger('hosts', 'count', HostCount);
    for lIndex := 0 to HostCount - 1 do
    begin
      lSection := 'host.' + IntToStr(lIndex);
      lIni.WriteString(lSection, 'id', HostId(lIndex));
      lIni.WriteString(lSection, 'name', HostName(lIndex));
    end;
    lIni.WriteInteger('storages', 'count', StorageCount);
    for lIndex := 0 to StorageCount - 1 do
    begin
      lStorage := Storage(lIndex);
      lSection := 'storage.' + IntToStr(lIndex);
      lIni.WriteString(lSection, 'name', lStorage.Name);
      lIni.WriteString(lSection, 'kind', lStorage.KindName);
      lIni.WriteString(lSection, 'root', lStorage.RootPath);
      lIni.WriteString(lSection, 'host', lStorage.Host);
      lIni.WriteString(lSection, 'user', lStorage.UserName);
    end;
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

procedure TCoordinatorConfig.AddHost(const AInstanceId, ADisplayName: string);
var
  lIndex: Integer;
begin
  if Trim(AInstanceId) = '' then Exit;
  lIndex := fHosts.IndexOfName(AInstanceId);
  if lIndex < 0 then
    fHosts.Add(AInstanceId + '=' + ADisplayName)
  else
    fHosts.ValueFromIndex[lIndex] := ADisplayName;
end;

function TCoordinatorConfig.HostCount: Integer;
begin
  Result := fHosts.Count;
end;

function TCoordinatorConfig.HostId(AIndex: Integer): string;
begin
  Result := fHosts.Names[AIndex];
end;

function TCoordinatorConfig.HostName(AIndex: Integer): string;
begin
  Result := fHosts.ValueFromIndex[AIndex];
end;

function TCoordinatorConfig.TestStorage(AStorage: TStorageConfig; out AMessage: string): Boolean;
var
  lTestFile: string;
  lStream: TFileStream;
begin
  Result := False;
  if AStorage = nil then
  begin
    AMessage := 'Хранилище не выбрано';
    Exit;
  end;
  if AStorage.Kind = skSftp then
  begin
    AMessage := 'SFTP сохранён в конфигурации; для проверки требуется SFTP-адаптер';
    Exit;
  end;
  if AStorage.RootPath = '' then
  begin
    AMessage := 'Не задан путь';
    Exit;
  end;
  try
    if not DirectoryExists(AStorage.RootPath) then ForceDirectories(AStorage.RootPath);
    lTestFile := IncludeTrailingPathDelimiter(AStorage.RootPath) + '.recorder-coordinator-test.tmp';
    lStream := TFileStream.Create(lTestFile, fmCreate);
    lStream.Free;
    DeleteFile(lTestFile);
    AMessage := 'Чтение и запись доступны: ' + AStorage.RootPath;
    Result := True;
  except
    on E: Exception do AMessage := E.Message;
  end;
end;

end.
