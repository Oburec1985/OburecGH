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
    fSqlAppConfigFile: string;
    fBootstrapDefaultSql: string;
    fStorages: TFPList;
    fHosts: TStringList;
    procedure ClearStorages;
  public
    ListenAddress: string;
    Port: Word;
    EventWindowSec: Integer;
    SqlRecordPeriodSec: Integer;
    CreateRecordingEvents: Boolean;
    StartAllOnAnyRecording: Boolean;
    SqlDbConfigFile: string;
    FirebirdHost: string;
    HostAgentPort: Word;
    HostAgentToken: string;
    CoordinatorId: string;
    CoordinatorToken: string;
    ControlIdentityPersistent: Boolean;
    SdbPrimaryHostId: string;
    SdbShareName: string;
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    function AddStorage: TStorageConfig;
    function StorageCount: Integer;
    function Storage(AIndex: Integer): TStorageConfig;
    function TestStorage(AStorage: TStorageConfig; out AMessage: string): Boolean;
    procedure AddHost(const AInstanceId, ADisplayName: string);
    procedure SetHostName(const AInstanceId, AAddress,
      ADisplayName: string);
    procedure RemoveHost(const AInstanceId, AAddress: string);
    function HostCount: Integer;
    function HostId(AIndex: Integer): string;
    function HostName(AIndex: Integer): string;
    property FileName: string read fFileName;
  end;

function IsAbsoluteConfigPath(const AFileName: string): Boolean;

implementation

uses
  uCoordinatorHostStore, uRecorderMeraPaths, uRecorderMachineStorage
  {$IFDEF UNIX}, BaseUnix{$ENDIF}
  {$IFDEF WINDOWS}, Windows{$ENDIF};

const
  LINUX_RECORDER_SQL_CONFIG =
    '/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini';

var
  gBootstrapDefaultSql: string;

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

procedure InitializeSharedRecorderPaths(const ACoordinatorIni: string);
var
  lPathFile, lRoot: string;
  lIni: TIniFile;
begin
  { The installed tools are siblings. Prefer an explicit local paths file or
    MERA_FILES; otherwise use RecorderLnx's existing paths configuration,
    instead of maintaining a second copy for the panel. }
  if (SysUtils.GetEnvironmentVariable('MERA_FILES') <> '') or
    FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(ACoordinatorIni)) +
      'RecorderLnx.paths.ini') then Exit;
  lPathFile := ExpandFileName(IncludeTrailingPathDelimiter(
    ExtractFilePath(ACoordinatorIni)) + '..' + DirectorySeparator +
    'RecorderLnx' + DirectorySeparator + 'RecorderLnx.paths.ini');
  if not FileExists(lPathFile) then Exit;
  lIni := TIniFile.Create(lPathFile);
  try
    lRoot := Trim(lIni.ReadString('Paths', 'MeraFiles', ''));
  finally
    lIni.Free;
  end;
  if lRoot = '' then Exit;
  if not IsAbsoluteConfigPath(lRoot) then
    lRoot := ExpandFileName(IncludeTrailingPathDelimiter(
      ExtractFileDir(lPathFile)) + lRoot);
  if DirectoryExists(lRoot) then SetRecorderMeraFilesPath(lRoot);
end;

function StrictConfigFileExists(const AFileName: string): Boolean;
{$IFDEF UNIX}
var
  lStat: Stat;
  lError: Integer;
begin
  if fpStat(PChar(AFileName), lStat) = 0 then
  begin
    if not FPS_ISREG(lStat.st_mode) then
      raise Exception.Create('Not a regular configuration file: ' + AFileName);
    Exit(True);
  end;
  lError := fpGetErrNo;
  if lError = ESysENOENT then Exit(False);
  raise Exception.CreateFmt('Cannot inspect configuration %s: %d', [AFileName, lError]);
end;
{$ELSE}
var
  lAttributes, lError: DWORD;
begin
  lAttributes := GetFileAttributesW(PWideChar(UTF8Decode(AFileName)));
  if lAttributes <> INVALID_FILE_ATTRIBUTES then
  begin
    if (lAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      raise Exception.Create('Not a regular configuration file: ' + AFileName);
    Exit(True);
  end;
  lError := GetLastError;
  if (lError = ERROR_FILE_NOT_FOUND) or (lError = ERROR_PATH_NOT_FOUND) then Exit(False);
  raise Exception.CreateFmt('Cannot inspect configuration %s: %d', [AFileName, lError]);
end;
{$ENDIF}

function ProjectSqlForAppConfig(const AFileName: string): string;
var
  lIni: TIniFile;
  lProjectDir, lCandidate: string;
begin
  Result := '';
  if not SameText(ExtractFileName(AFileName), 'app.ini') or
    not FileExists(AFileName) then Exit;
  lIni := TIniFile.Create(AFileName);
  try
    { Never reinterpret an explicit SQL project file merely named app.ini. }
    if lIni.SectionExists('SQLdb') then Exit;
    lProjectDir := Trim(lIni.ReadString('Application',
      'DefaultProjectConfigDir', ''));
  finally
    lIni.Free;
  end;
  if lProjectDir = '' then
    lProjectDir := 'config' + DirectorySeparator + 'projects' +
      DirectorySeparator + 'default';
  if not IsAbsoluteConfigPath(lProjectDir) then
    lProjectDir := IncludeTrailingPathDelimiter(ExtractFileDir(AFileName)) +
      lProjectDir;
  lCandidate := ExpandFileName(IncludeTrailingPathDelimiter(lProjectDir) +
    'sql-db.ini');
  { If the project file does not exist yet, still return its intended name.
    Never fall through to app.ini as a writable project configuration. }
  Result := lCandidate;
end;

procedure ApplyLegacyMachineMeraPath(const AAppFile, ADefaultSql: string);
var
  lIni: TIniFile;
  lStream: TFileStream;
  lProjectDir, lLegacyFile, lPath: string;
begin
  { Until RecorderLnx has migrated its machine setting, its selected project
    supplies the old [Mera] FilesPath. Read it without creating any files. }
  lProjectDir := ExtractFileDir(ADefaultSql);
  if StrictConfigFileExists(AAppFile) then
  begin
    lStream := TFileStream.Create(AAppFile, fmOpenRead or fmShareDenyNone);
    try
      lIni := TIniFile.Create(lStream);
      try
        lPath := Trim(lIni.ReadString('Application', 'DefaultProjectConfigDir', ''));
      finally
        lIni.Free;
      end;
    finally
      lStream.Free;
    end;
    if lPath <> '' then
    begin
      if IsAbsoluteConfigPath(lPath) then lProjectDir := lPath
      else lProjectDir := ExpandFileName(IncludeTrailingPathDelimiter(
        ExtractFileDir(AAppFile)) + lPath);
    end;
  end;
  lLegacyFile := IncludeTrailingPathDelimiter(lProjectDir) + 'default.run-control.ini';
  if not StrictConfigFileExists(lLegacyFile) then
    lLegacyFile := IncludeTrailingPathDelimiter(lProjectDir) + 'run-control.ini';
  if not StrictConfigFileExists(lLegacyFile) then Exit;
  lStream := TFileStream.Create(lLegacyFile, fmOpenRead or fmShareDenyNone);
  try
    lIni := TIniFile.Create(lStream);
    try
      if not lIni.ValueExists('Mera', 'FilesPath') then Exit;
      lPath := lIni.ReadString('Mera', 'FilesPath', '');
    finally
      lIni.Free;
    end;
  finally
    lStream.Free;
  end;
  SetRecorderMeraFilesPath(lPath);
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
var
  lId: TGUID;
begin
  inherited Create;
  fFileName := AFileName;
  InitializeSharedRecorderPaths(AFileName);
  { Cache the installation's bootstrap locations before applying the
    machine's independent runtime Mera Files directory. }
  if gBootstrapDefaultSql = '' then
    gBootstrapDefaultSql := RecorderProjectSqlConfigFileName(
      RecorderDefaultProjectConfigDir);
  fBootstrapDefaultSql := gBootstrapDefaultSql;
  RecorderAppConfigFileName;
  if TryLoadExistingRecorderMachineStorage then
    SetRecorderMeraFilesPath(RecorderMachineMeraPath)
  else
    ApplyLegacyMachineMeraPath(RecorderAppConfigFileName, fBootstrapDefaultSql);
  CreateGUID(lId);
  CoordinatorId := GUIDToString(lId);
  fStorages := TFPList.Create;
  fHosts := TStringList.Create;
  fHosts.NameValueSeparator := '=';
  ListenAddress := '0.0.0.0';
  Port := 8765;
  EventWindowSec := 30;
  SqlRecordPeriodSec := 1;
  CreateRecordingEvents := True;
  StartAllOnAnyRecording := False;
  HostAgentPort := 8766;
  HostAgentToken := '';
  SdbPrimaryHostId := '';
  SdbShareName := 'MeraFiles';
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
  if fStorages = nil then Exit;
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
  lAgentPort, lCount, lIndex: Integer;
  lStorage: TStorageConfig;
  lSection, lCandidate, lStoredSqlConfig: string;
  lSqlConfigChanged, lProjectFromApp: Boolean;
begin
  ClearStorages;
  fHosts.Clear;
  fSqlAppConfigFile := '';
  if not FileExists(fFileName) then
  begin
    lStorage := AddStorage;
    lStorage.Name := 'Локальный архив';
    lStorage.RootPath := IncludeTrailingPathDelimiter(ExtractFilePath(fFileName)) + 'archive';
    lIni := TIniFile.Create(fFileName);
    try
      try
        lIni.WriteString('coordinator', 'instance_id', CoordinatorId);
        ControlIdentityPersistent := True;
      except
        { A read-only installation must still be able to start. The GUI
          reports that the generated session identity could not be saved. }
        ControlIdentityPersistent := False;
      end;
    finally
      lIni.Free;
    end;
    Exit;
  end;
  BeginCoordinatorConfigAccess;
  lIni := TIniFile.Create(fFileName);
  try
    ListenAddress := lIni.ReadString('service', 'listen', ListenAddress);
    Port := lIni.ReadInteger('service', 'port', Port);
    EventWindowSec := lIni.ReadInteger('service', 'event_window_sec', EventWindowSec);
    SqlRecordPeriodSec := lIni.ReadInteger('commands',
      'sql_record_period_sec', SqlRecordPeriodSec);
    if SqlRecordPeriodSec < 1 then SqlRecordPeriodSec := 1;
    if SqlRecordPeriodSec > 86400 then SqlRecordPeriodSec := 86400;
    CreateRecordingEvents := lIni.ReadBool('events', 'create_recording_events',
      CreateRecordingEvents);
    FirebirdHost := Trim(lIni.ReadString('events', 'firebird_host', FirebirdHost));
    StartAllOnAnyRecording := lIni.ReadBool('commands',
      'start_all_on_any_recording', StartAllOnAnyRecording);
    lAgentPort := lIni.ReadInteger('host_agent', 'port', HostAgentPort);
    if (lAgentPort >= 1) and (lAgentPort <= High(Word)) then
      HostAgentPort := lAgentPort;
    HostAgentToken := lIni.ReadString('host_agent', 'token', HostAgentToken);
    lCandidate := Trim(lIni.ReadString('coordinator', 'instance_id', ''));
    if lCandidate <> '' then
    begin
      CoordinatorId := lCandidate;
      ControlIdentityPersistent := True;
    end;
    CoordinatorToken := lIni.ReadString('coordinator', 'auth_token', '');
    if lCandidate = '' then
    begin
      try
        lIni.WriteString('coordinator', 'instance_id', CoordinatorId);
        ControlIdentityPersistent := True;
      except
        ControlIdentityPersistent := False;
      end;
    end;
    SdbPrimaryHostId := lIni.ReadString('sdb_sync', 'primary_host_id',
      SdbPrimaryHostId);
    SdbShareName := Trim(lIni.ReadString('sdb_sync', 'share_name',
      SdbShareName));
    if SdbShareName = '' then SdbShareName := 'MeraFiles';
    lStoredSqlConfig := Trim(lIni.ReadString('events', 'sql_db_config',
      SqlDbConfigFile));
    SqlDbConfigFile := RepairLegacySqlConfigPath(lStoredSqlConfig);
    if (Trim(SqlDbConfigFile) <> '') and
      (not IsAbsoluteConfigPath(SqlDbConfigFile)) then
      SqlDbConfigFile := ExpandFileName(IncludeTrailingPathDelimiter(
        ExtractFilePath(fFileName)) + SqlDbConfigFile);
    { Older releases saved their automatically selected default-project SQL
      file as though it were a fixed user choice. Only that exact default is
      migrated; arbitrary explicit project paths remain untouched. }
    if SameFileName(ExpandFileName(SqlDbConfigFile),
       ExpandFileName(fBootstrapDefaultSql)) and
       FileExists(RecorderAppConfigFileName) and
       (ProjectSqlForAppConfig(RecorderAppConfigFileName) <> '') then
      SqlDbConfigFile := RecorderAppConfigFileName;
    lCandidate := ProjectSqlForAppConfig(SqlDbConfigFile);
    lProjectFromApp := lCandidate <> '';
    if lProjectFromApp then
    begin
      { Persist the app pointer, not a copied project path. Switching the
        default project must be reflected on the next panel start. }
      fSqlAppConfigFile := SqlDbConfigFile;
      SqlDbConfigFile := lCandidate;
      lSqlConfigChanged := fSqlAppConfigFile <> lStoredSqlConfig;
    end
    else
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
    if (not lProjectFromApp) and ((not FileExists(SqlDbConfigFile)) or
      (SameFileName(SqlDbConfigFile, fFileName) and
       (not lIni.SectionExists('SQLdb')))) then
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
    if not lProjectFromApp then
      lSqlConfigChanged := lSqlConfigChanged or
        (SqlDbConfigFile <> lStoredSqlConfig);
    if lSqlConfigChanged then
    begin
      if lProjectFromApp then
        lIni.WriteString('events', 'sql_db_config', fSqlAppConfigFile)
      else
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
    EndCoordinatorConfigAccess;
  end;
end;

procedure TCoordinatorConfig.Save;
var
  lIni: TIniFile;
  lIndex: Integer;
  lStorage: TStorageConfig;
  lSection: string;
begin
  BeginCoordinatorConfigAccess;
  lIni := TIniFile.Create(fFileName);
  try
    lIni.WriteString('service', 'listen', ListenAddress);
    lIni.WriteInteger('service', 'port', Port);
    lIni.WriteInteger('service', 'event_window_sec', EventWindowSec);
    lIni.WriteBool('events', 'create_recording_events', CreateRecordingEvents);
    lIni.WriteBool('commands', 'start_all_on_any_recording',
      StartAllOnAnyRecording);
    lIni.WriteInteger('commands', 'sql_record_period_sec',
      SqlRecordPeriodSec);
    lIni.WriteInteger('host_agent', 'port', HostAgentPort);
    lIni.WriteString('host_agent', 'token', HostAgentToken);
    lIni.WriteString('events', 'firebird_host', FirebirdHost);
    lIni.WriteString('coordinator', 'instance_id', CoordinatorId);
    lIni.WriteString('coordinator', 'auth_token', CoordinatorToken);
    lIni.WriteString('sdb_sync', 'primary_host_id', SdbPrimaryHostId);
    lIni.WriteString('sdb_sync', 'share_name', SdbShareName);
    if fSqlAppConfigFile <> '' then
      lIni.WriteString('events', 'sql_db_config', fSqlAppConfigFile)
    else
      lIni.WriteString('events', 'sql_db_config', SqlDbConfigFile);
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
    EndCoordinatorConfigAccess;
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

procedure TCoordinatorConfig.SetHostName(const AInstanceId, AAddress,
  ADisplayName: string);
var
  lIndex, lInstanceIndex: Integer;
begin
  lInstanceIndex := fHosts.IndexOfName(AInstanceId);
  if lInstanceIndex < 0 then
  begin
    AddHost(AInstanceId, ADisplayName);
    lInstanceIndex := fHosts.IndexOfName(AInstanceId);
  end;
  if lInstanceIndex >= 0 then
    fHosts.ValueFromIndex[lInstanceIndex] := ADisplayName;

  { A manually configured IP is an alias of the selected Recorder UUID.
    Keeping both keys recreates the duplicate during the next config load. }
  if SameText(AInstanceId, AAddress) then Exit;
  for lIndex := fHosts.Count - 1 downto 0 do
    if SameText(fHosts.Names[lIndex], AAddress) then
      fHosts.Delete(lIndex);
end;

procedure TCoordinatorConfig.RemoveHost(const AInstanceId, AAddress: string);
var
  lIndex: Integer;
begin
  for lIndex := fHosts.Count - 1 downto 0 do
    if SameText(fHosts.Names[lIndex], AInstanceId) or
      SameText(fHosts.Names[lIndex], AAddress) then
      fHosts.Delete(lIndex);
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
    SysUtils.DeleteFile(lTestFile);
    AMessage := 'Чтение и запись доступны: ' + AStorage.RootPath;
    Result := True;
  except
    on E: Exception do AMessage := E.Message;
  end;
end;

end.
