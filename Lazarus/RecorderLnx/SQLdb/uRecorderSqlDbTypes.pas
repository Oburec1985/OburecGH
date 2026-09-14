unit uRecorderSqlDbTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags;

const
  CRecorderSqlDbSchemaVersion = 5;
  CRecorderSqlDbDefaultFileName = 'recorderlnx.sqlite3';
  CRecorderFirebirdDefaultFileName = 'recorderlnx.fdb';
  CRecorderFirebirdDefaultHost = '192.168.9.66';
  CRecorderFirebirdDefaultDatabase = '/var/opt/mera/SQLdb/recorderlnx.fdb';
  CRecorderFirebirdDefaultUserName = 'SYSDBA';
  CRecorderFirebirdDefaultPassword = '123';
  CRecorderSqlDbControlTagName = 'SqlDbRecordEnabled';

type
  ERecorderSqlDbError = class(Exception);

  TRecorderSqlDbBackend = (rsbSQLite, rsbPostgreSQL, rsbFirebird);
  TRecorderSqlDbRuntimeState = (rsrsDisabled, rsrsReady, rsrsRecording,
    rsrsDegraded, rsrsError);

  TRecorderSqlTrendPoint = record
    RowId: string;
    SignalName: string;
    TimestampUtc: Double;
    Value: Double;
  end;
  TRecorderSqlTrendPoints = array of TRecorderSqlTrendPoint;

  TRecorderSqlDbSignalInfo = record
    Name: string;
    UnitName: string;
    RecorderSourceId: string;
    RecorderAddress: string;
    PointCount: Int64;
  end;
  TRecorderSqlDbSignalInfos = array of TRecorderSqlDbSignalInfo;

  TRecorderSqlDbRecorderInstance = record
    Id: string;
    InstanceKey: string;
    HostName: string;
    DisplayName: string;
    Platform: string;
    LastSeenAtUtc: Double;
  end;

  TRecorderSqlDbMeraRecording = record
    Id: string;
    EventId: string;
    RecorderInstanceId: string;
    RegistrationId: string;
    CorrelationId: string;
    DisplayName: string;
    StartedAtUtc: Double;
    FinishedAtUtc: Double;
    State: string;
    EntryFileId: string;
    ProjectName: string;
    ErrorText: string;
  end;
  TRecorderSqlDbMeraRecordings = array of TRecorderSqlDbMeraRecording;

  TRecorderSqlDbMeraEvent = record
    EventId: string;
    CorrelationId: string;
    DisplayName: string;
    Description: string;
    StartedAtUtc: Double;
    FinishedAtUtc: Double;
    State: string;
    PackageCount: Integer;
    TotalSize: Int64;
  end;
  TRecorderSqlDbMeraEvents = array of TRecorderSqlDbMeraEvent;

  TRecorderSqlDbMeraFile = record
    FileId: string;
    RecordingId: string;
    FileRole: string;
    RelativeName: string;
    Ordinal: Integer;
    StorageKey: string;
    DataFormat: string;
    Size: Int64;
    Checksum: string;
    State: string;
  end;
  TRecorderSqlDbMeraFiles = array of TRecorderSqlDbMeraFile;

  TRecorderSqlDbMeraPackage = record
    Recording: TRecorderSqlDbMeraRecording;
    InstanceKey: string;
    HostName: string;
    FileCount: Integer;
    TotalSize: Int64;
  end;
  TRecorderSqlDbMeraPackages = array of TRecorderSqlDbMeraPackage;

  TRecorderSqlDbFileLocation = record
    Id: string;
    FileId: string;
    RecorderInstanceId: string;
    LocationKind: string;
    PathKey: string;
    State: string;
    CreatedAtUtc: Double;
    VerifiedAtUtc: Double;
    ErrorText: string;
  end;
  TRecorderSqlDbFileLocations = array of TRecorderSqlDbFileLocation;

  TRecorderSqlDbConfig = class
  private
    fBackend: TRecorderSqlDbBackend;
    fDatabase: string;
    fControlTagName: string;
    fEnabled: Boolean;
    fHost: string;
    fObjectName: string;
    fObjectType: string;
    fSerialNumber: string;
    fSignalNames: TStringList;
    fSignalEstimates: TStringList;
    fSignalSelectionConfigured: Boolean;
    fPasswordEnvironment: string;
    fStoredPassword: string;
    fPort: Word;
    fQueueCapacity: Integer;
    fRecordPeriodMs: Integer;
    fRootDirectory: string;
    fTlsRequired: Boolean;
    fUserName: string;
    function EffectiveRootDirectory: string;
    procedure LoadConnectionFromAppConfig;
    procedure SaveConnectionToAppConfig;
    procedure SetQueueCapacity(AValue: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(ASource: TRecorderSqlDbConfig);
    procedure ResetDefaults;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure RequireValid;
    function ConnectionConfigurationReady(out AErrorText: string): Boolean;
    function DatabaseFileName: string;
    function IsLocalFileDatabase: Boolean;
    function DataDirectory: string;
    function Password: string;
    function SignalEnabled(const ATagName: string): Boolean;
    function SignalEstimate(const ATagName: string): TRecorderTagEstimateKind;
    procedure SetSignalEstimate(const ATagName: string;
      AKind: TRecorderTagEstimateKind);
    property Backend: TRecorderSqlDbBackend read fBackend write fBackend;
    property Database: string read fDatabase write fDatabase;
    property ControlTagName: string read fControlTagName write fControlTagName;
    property Enabled: Boolean read fEnabled write fEnabled;
    property Host: string read fHost write fHost;
    property ObjectName: string read fObjectName write fObjectName;
    property ObjectType: string read fObjectType write fObjectType;
    property SerialNumber: string read fSerialNumber write fSerialNumber;
    property SignalNames: TStringList read fSignalNames;
    property SignalEstimates: TStringList read fSignalEstimates;
    property SignalSelectionConfigured: Boolean read fSignalSelectionConfigured
      write fSignalSelectionConfigured;
    property PasswordEnvironment: string read fPasswordEnvironment write fPasswordEnvironment;
    property StoredPassword: string read fStoredPassword write fStoredPassword;
    property Port: Word read fPort write fPort;
    property QueueCapacity: Integer read fQueueCapacity write SetQueueCapacity;
    property RecordPeriodMs: Integer read fRecordPeriodMs write fRecordPeriodMs;
    property RootDirectory: string read fRootDirectory write fRootDirectory;
    property TlsRequired: Boolean read fTlsRequired write fTlsRequired;
    property UserName: string read fUserName write fUserName;
  end;

  TRecorderSqlDbAttachment = class
  public
    Id: string;
    StorageKey: string;
    DataType: string;
    DataFormat: string;
    Size: Int64;
    Checksum: string;
    AnchorTimeUtc: Double;
    TimeFromUtc: Double;
    TimeToUtc: Double;
  end;

function RecorderSqlDbNewId: string;
function RecorderSqlDbBackendToString(AValue: TRecorderSqlDbBackend): string;
function RecorderSqlDbStringToBackend(const AValue: string): TRecorderSqlDbBackend;
function RecorderSqlDbDefaultRootDirectory: string;

implementation

uses
  IniFiles, uRecorderMeraPaths
  {$ifdef unix}, BaseUnix{$endif}
  {$ifdef windows}, Registry, Windows{$endif};

function RecorderSqlDbNewId: string;
var
  lGuid: TGuid;
begin
  if CreateGUID(lGuid) <> 0 then
    raise ERecorderSqlDbError.Create('Cannot create UUID');
  Result := LowerCase(GUIDToString(lGuid));
  Result := StringReplace(Result, '{', '', []);
  Result := StringReplace(Result, '}', '', []);
end;

function RecorderSqlDbBackendToString(AValue: TRecorderSqlDbBackend): string;
begin
  case AValue of
    rsbSQLite: Result := 'sqlite';
    rsbPostgreSQL: Result := 'postgresql';
    rsbFirebird: Result := 'firebird';
  end;
end;

function RecorderSqlDbStringToBackend(const AValue: string): TRecorderSqlDbBackend;
begin
  if SameText(Trim(AValue), 'postgresql') then
    Exit(rsbPostgreSQL);
  if SameText(Trim(AValue), 'firebird') then
    Exit(rsbFirebird);
  Result := rsbSQLite;
end;

function RecorderSqlDbDefaultRootDirectory: string;
var
  lRoot: string;
begin
  lRoot := Trim(SysUtils.GetEnvironmentVariable('RECORDERLNX_SQLDB_ROOT'));
  if lRoot <> '' then
    Exit(ExcludeTrailingPathDelimiter(lRoot));
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'SQLdb';
end;

constructor TRecorderSqlDbConfig.Create;
begin
  inherited Create;
  fSignalNames := TStringList.Create;
  fSignalNames.CaseSensitive := False;
  fSignalNames.Sorted := True;
  fSignalNames.Duplicates := dupIgnore;
  fSignalEstimates := TStringList.Create;
  fSignalEstimates.CaseSensitive := False;
  fSignalEstimates.NameValueSeparator := '=';
  ResetDefaults;
end;

destructor TRecorderSqlDbConfig.Destroy;
begin
  fSignalEstimates.Free;
  fSignalNames.Free;
  inherited Destroy;
end;

procedure TRecorderSqlDbConfig.Assign(ASource: TRecorderSqlDbConfig);
begin
  if ASource = nil then Exit;
  fBackend := ASource.fBackend;
  fDatabase := ASource.fDatabase;
  fControlTagName := ASource.fControlTagName;
  fEnabled := ASource.fEnabled;
  fHost := ASource.fHost;
  fObjectName := ASource.fObjectName;
  fObjectType := ASource.fObjectType;
  fSerialNumber := ASource.fSerialNumber;
  fSignalNames.Assign(ASource.fSignalNames);
  fSignalEstimates.Assign(ASource.fSignalEstimates);
  fSignalSelectionConfigured := ASource.fSignalSelectionConfigured;
  fPasswordEnvironment := ASource.fPasswordEnvironment;
  fStoredPassword := ASource.fStoredPassword;
  fPort := ASource.fPort;
  fQueueCapacity := ASource.fQueueCapacity;
  fRecordPeriodMs := ASource.fRecordPeriodMs;
  fRootDirectory := ASource.fRootDirectory;
  fTlsRequired := ASource.fTlsRequired;
  fUserName := ASource.fUserName;
end;

procedure TRecorderSqlDbConfig.ResetDefaults;
begin
  fBackend := rsbFirebird;
  fDatabase := CRecorderFirebirdDefaultDatabase;
  fControlTagName := '';
  fEnabled := False;
  fHost := CRecorderFirebirdDefaultHost;
  fObjectName := 'Объект мониторинга';
  fObjectType := '';
  fSerialNumber := '';
  fSignalNames.Clear;
  fSignalEstimates.Clear;
  fSignalSelectionConfigured := False;
  fPasswordEnvironment := 'RECORDERLNX_SQLDB_PASSWORD';
  fStoredPassword := CRecorderFirebirdDefaultPassword;
  fPort := 3050;
  fQueueCapacity := 8192;
  fRecordPeriodMs := 1000;
  fRootDirectory := RecorderSqlDbDefaultRootDirectory;
  fTlsRequired := False;
  fUserName := CRecorderFirebirdDefaultUserName;
end;

procedure TRecorderSqlDbConfig.SetQueueCapacity(AValue: Integer);
begin
  if AValue < 128 then AValue := 128;
  if AValue > 1000000 then AValue := 1000000;
  fQueueCapacity := AValue;
end;

function TRecorderSqlDbConfig.EffectiveRootDirectory: string;
var
  lRoot: string;
begin
  lRoot := Trim(fRootDirectory);
  {$ifdef unix}
  { Общий конфиг может содержать абсолютный путь Windows. На Linux такой путь
    нельзя превращать в подкаталог рядом с exe. }
  if (lRoot = '') or
     ((Length(lRoot) >= 2) and (lRoot[2] = ':')) or
     (Pos('\\', lRoot) > 0) then
    lRoot := RecorderSqlDbDefaultRootDirectory;
  if (fBackend = rsbFirebird) and
     ((Trim(fHost) = '') or SameText(Trim(fHost), 'localhost') or
      SameText(Trim(fHost), '127.0.0.1') or SameText(Trim(fHost), '::1')) and
     DirectoryExists('/var/opt/mera/SQLdb') and
     (Pos('/home/', lRoot) = 1) then
    lRoot := '/var/opt/mera/SQLdb';
  {$else}
  if (lRoot = '') or ((lRoot <> '') and (lRoot[1] = '/')) then
    lRoot := RecorderSqlDbDefaultRootDirectory;
  {$endif}
  Result := ExcludeTrailingPathDelimiter(ExpandFileName(lRoot));
end;

procedure TRecorderSqlDbConfig.RequireValid;
begin
  if not fEnabled then Exit;
  if (fBackend = rsbSQLite) or
     ((fBackend = rsbFirebird) and (Trim(fHost) = '')) then
  begin
    if EffectiveRootDirectory = '' then
      raise ERecorderSqlDbError.Create('SQLdb root directory is empty');
  end
  else
  begin
    if Trim(fHost) = '' then
      raise ERecorderSqlDbError.Create('Remote SQLdb host is empty');
    if Trim(fDatabase) = '' then
      raise ERecorderSqlDbError.Create('Remote SQLdb database is empty');
    // Port 0 means: use the database driver's default port.
  end;
end;

function TRecorderSqlDbConfig.ConnectionConfigurationReady(
  out AErrorText: string): Boolean;
begin
  AErrorText := '';
  if ((fBackend = rsbSQLite) or
      ((fBackend = rsbFirebird) and IsLocalFileDatabase)) and
     (EffectiveRootDirectory = '') then
    AErrorText := 'Не задан каталог SQL БД.'
  else if (not IsLocalFileDatabase) and (Trim(fHost) = '') then
    AErrorText := 'Не задан хост SQL БД.'
  else if (not IsLocalFileDatabase) and (Trim(fDatabase) = '') then
    AErrorText := 'Не задан путь или имя SQL БД.'
  else if (fBackend = rsbFirebird) and (Trim(fUserName) = '') then
    AErrorText := 'Не задано имя пользователя Firebird.'
  else if (fBackend = rsbFirebird) and (Password = '') then
    AErrorText := 'Не задан пароль Firebird.';
  Result := AErrorText = '';
end;

function TRecorderSqlDbConfig.DatabaseFileName: string;
var
  lName, lRoot: string;
begin
  lName := Trim(fDatabase);
  if lName = '' then
    if fBackend = rsbFirebird then
      lName := CRecorderFirebirdDefaultFileName
    else
      lName := CRecorderSqlDbDefaultFileName;
  if not IsLocalFileDatabase then
  begin
    lRoot := Trim(fRootDirectory);
    if (lRoot = '') or (ExtractFileDrive(lName) <> '') or
       ((Length(lName) >= 2) and (lName[2] = ':')) or
       ((lName <> '') and (lName[1] = '/')) then
      Exit(lName);
    if Pos('\', lRoot) > 0 then
    begin
      if (lRoot[Length(lRoot)] = '\') or (lRoot[Length(lRoot)] = '/') then
        Exit(lRoot + lName);
      Exit(lRoot + '\' + lName);
    end;
    if Pos('/', lRoot) > 0 then
    begin
      if lRoot[Length(lRoot)] = '/' then
        Exit(lRoot + lName);
      Exit(lRoot + '/' + lName);
    end;
    Exit(lRoot + '/' + lName);
  end;
  {$ifdef unix}
  if ((Length(lName) >= 2) and (lName[2] = ':')) or
     (Pos('\\', lName) > 0) then
    lName := ExtractFileName(StringReplace(lName, '\\', '/', [rfReplaceAll]));
  {$else}
  if (lName <> '') and (lName[1] = '/') then
    lName := ExtractFileName(lName);
  {$endif}
  if ExtractFileDrive(lName) <> '' then Exit(ExpandFileName(lName));
  Result := IncludeTrailingPathDelimiter(EffectiveRootDirectory) + lName;
end;

function TRecorderSqlDbConfig.IsLocalFileDatabase: Boolean;
begin
  Result := (fBackend = rsbSQLite) or
    ((fBackend = rsbFirebird) and
     ((Trim(fHost) = '') or SameText(Trim(fHost), 'localhost') or
      SameText(Trim(fHost), '127.0.0.1') or SameText(Trim(fHost), '::1')));
end;

function TRecorderSqlDbConfig.DataDirectory: string;
begin
  Result := IncludeTrailingPathDelimiter(EffectiveRootDirectory) + 'data';
end;

function TRecorderSqlDbConfig.Password: string;
{$ifdef windows}
var
  lRegistry: TRegistry;
{$endif}
begin
  Result := fStoredPassword;
  if Result <> '' then
    Exit;
  Result := SysUtils.GetEnvironmentVariable(fPasswordEnvironment);
  {$ifdef windows}
  if Result = '' then
  begin
    lRegistry := TRegistry.Create(KEY_READ);
    try
      lRegistry.RootKey := HKEY_CURRENT_USER;
      if lRegistry.OpenKeyReadOnly('Environment') and
         lRegistry.ValueExists(fPasswordEnvironment) then
        Result := lRegistry.ReadString(fPasswordEnvironment);
    finally
      lRegistry.Free;
    end;
  end;
  {$endif}
end;

function TRecorderSqlDbConfig.SignalEnabled(const ATagName: string): Boolean;
begin
  Result := not fSignalSelectionConfigured or
    (fSignalNames.IndexOf(ATagName) >= 0);
end;

function TRecorderSqlDbConfig.SignalEstimate(
  const ATagName: string): TRecorderTagEstimateKind;
var
  lKind: TRecorderTagEstimateKind;
  lValue: string;
begin
  lValue := fSignalEstimates.Values[ATagName];
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    if SameText(lValue, RecorderTagEstimateKindToName(lKind)) then
      Exit(lKind);
  Result := tekMean;
end;

procedure TRecorderSqlDbConfig.SetSignalEstimate(const ATagName: string;
  AKind: TRecorderTagEstimateKind);
begin
  if Trim(ATagName) = '' then Exit;
  fSignalEstimates.Values[ATagName] := RecorderTagEstimateKindToName(AKind);
end;

procedure TRecorderSqlDbConfig.LoadFromFile(const AFileName: string);
var
  lIni: TIniFile;
begin
  ResetDefaults;
  if FileExists(AFileName) then
  begin
    lIni := TIniFile.Create(AFileName);
    try
      fEnabled := lIni.ReadBool('SQLdb', 'Enabled', fEnabled);
      fBackend := RecorderSqlDbStringToBackend(lIni.ReadString('SQLdb', 'Backend', 'firebird'));
      fRootDirectory := lIni.ReadString('SQLdb', 'RootDirectory', fRootDirectory);
      fDatabase := lIni.ReadString('SQLdb', 'Database', fDatabase);
      fControlTagName := lIni.ReadString('SQLdb', 'ControlTag', fControlTagName);
      fHost := lIni.ReadString('SQLdb', 'Host', fHost);
      fObjectName := lIni.ReadString('SQLdb', 'ObjectName', fObjectName);
      fObjectType := lIni.ReadString('SQLdb', 'ObjectType', fObjectType);
      fSerialNumber := lIni.ReadString('SQLdb', 'SerialNumber', fSerialNumber);
      fPort := lIni.ReadInteger('SQLdb', 'Port', fPort);
      fUserName := lIni.ReadString('SQLdb', 'UserName', fUserName);
      fPasswordEnvironment := lIni.ReadString('SQLdb', 'PasswordEnvironment', fPasswordEnvironment);
      fStoredPassword := lIni.ReadString('SQLdb', 'Password', fStoredPassword);
      if (fBackend = rsbFirebird) and (fStoredPassword = '') then
        fStoredPassword := CRecorderFirebirdDefaultPassword;
      fTlsRequired := lIni.ReadBool('SQLdb', 'TlsRequired', fTlsRequired);
      QueueCapacity := lIni.ReadInteger('SQLdb', 'QueueCapacity', fQueueCapacity);
      fRecordPeriodMs := lIni.ReadInteger('SQLdb', 'RecordPeriodMs', fRecordPeriodMs);
      fSignalSelectionConfigured := lIni.ReadBool('SQLdb',
        'SignalSelectionConfigured', fSignalSelectionConfigured);
      lIni.ReadSection('SQLdbSignals', fSignalNames);
      lIni.ReadSectionValues('SQLdbSignalEstimates', fSignalEstimates);
    finally
      lIni.Free;
    end;
  end;
  LoadConnectionFromAppConfig;
  // Firebird credentials are an internal application setting.  A legacy
  // project file may contain empty values and must not erase the defaults
  // after the complete connection configuration has been assembled.
  if fBackend = rsbFirebird then
  begin
    fUserName := CRecorderFirebirdDefaultUserName;
    fStoredPassword := CRecorderFirebirdDefaultPassword;
    fPasswordEnvironment := '';
  end;
  RequireValid;
end;

procedure TRecorderSqlDbConfig.LoadConnectionFromAppConfig;
var
  lFileName: string;
  lIni: TIniFile;
begin
  lFileName := RecorderAppConfigFileName;
  if not FileExists(lFileName) then Exit;
  lIni := TIniFile.Create(lFileName);
  try
    if not lIni.SectionExists('SQLdbConnection') then Exit;
    fBackend := RecorderSqlDbStringToBackend(lIni.ReadString(
      'SQLdbConnection', 'Backend', RecorderSqlDbBackendToString(fBackend)));
    fRootDirectory := lIni.ReadString('SQLdbConnection', 'RootDirectory',
      fRootDirectory);
    fDatabase := lIni.ReadString('SQLdbConnection', 'Database', fDatabase);
    fHost := lIni.ReadString('SQLdbConnection', 'Host', fHost);
    fPort := lIni.ReadInteger('SQLdbConnection', 'Port', fPort);
    fTlsRequired := lIni.ReadBool('SQLdbConnection', 'TlsRequired',
      fTlsRequired);
  finally
    lIni.Free;
  end;
  if fBackend = rsbFirebird then
  begin
    fUserName := CRecorderFirebirdDefaultUserName;
    fStoredPassword := CRecorderFirebirdDefaultPassword;
    fPasswordEnvironment := '';
  end;
end;

procedure TRecorderSqlDbConfig.SaveConnectionToAppConfig;
var
  lFileName: string;
  lIni: TIniFile;
begin
  lFileName := RecorderAppConfigFileName;
  if not ForceDirectories(ExtractFileDir(lFileName)) then
    raise ERecorderSqlDbError.CreateFmt('Cannot create config directory: %s',
      [ExtractFileDir(lFileName)]);
  lIni := TIniFile.Create(lFileName);
  try
    lIni.WriteString('SQLdbConnection', 'Backend',
      RecorderSqlDbBackendToString(fBackend));
    lIni.WriteString('SQLdbConnection', 'RootDirectory', fRootDirectory);
    lIni.WriteString('SQLdbConnection', 'Database', fDatabase);
    lIni.WriteString('SQLdbConnection', 'Host', fHost);
    lIni.WriteInteger('SQLdbConnection', 'Port', fPort);
    lIni.WriteBool('SQLdbConnection', 'TlsRequired', fTlsRequired);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

procedure TRecorderSqlDbConfig.SaveToFile(const AFileName: string);
var
  lIni: TIniFile;
  lIndex: Integer;
  {$ifdef unix}
  lErrorCode: Integer;
  {$endif}
begin
  RequireValid;
  SaveConnectionToAppConfig;
  if not ForceDirectories(ExtractFileDir(ExpandFileName(AFileName))) then
    raise ERecorderSqlDbError.CreateFmt('Cannot create config directory: %s', [ExtractFileDir(AFileName)]);
  lIni := TIniFile.Create(AFileName);
  try
    lIni.WriteBool('SQLdb', 'Enabled', fEnabled);
    lIni.WriteString('SQLdb', 'ControlTag', fControlTagName);
    lIni.WriteString('SQLdb', 'ObjectName', fObjectName);
    lIni.WriteString('SQLdb', 'ObjectType', fObjectType);
    lIni.WriteString('SQLdb', 'SerialNumber', fSerialNumber);
    lIni.DeleteKey('SQLdb', 'Backend');
    lIni.DeleteKey('SQLdb', 'RootDirectory');
    lIni.DeleteKey('SQLdb', 'Database');
    lIni.DeleteKey('SQLdb', 'Host');
    lIni.DeleteKey('SQLdb', 'Port');
    lIni.DeleteKey('SQLdb', 'UserName');
    lIni.DeleteKey('SQLdb', 'PasswordEnvironment');
    lIni.DeleteKey('SQLdb', 'Password');
    lIni.DeleteKey('SQLdb', 'TlsRequired');
    lIni.WriteInteger('SQLdb', 'QueueCapacity', fQueueCapacity);
    lIni.WriteInteger('SQLdb', 'RecordPeriodMs', fRecordPeriodMs);
    lIni.WriteBool('SQLdb', 'SignalSelectionConfigured',
      fSignalSelectionConfigured);
    lIni.EraseSection('SQLdbSignals');
    for lIndex := 0 to fSignalNames.Count - 1 do
      lIni.WriteBool('SQLdbSignals', fSignalNames[lIndex], True);
    lIni.EraseSection('SQLdbSignalEstimates');
    for lIndex := 0 to fSignalEstimates.Count - 1 do
      lIni.WriteString('SQLdbSignalEstimates',
        fSignalEstimates.Names[lIndex], fSignalEstimates.ValueFromIndex[lIndex]);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
  {$ifdef unix}
  if fpChmod(PChar(AFileName), &600) <> 0 then
  begin
    lErrorCode := fpGetErrNo;
    raise ERecorderSqlDbError.CreateFmt(
      'Cannot protect SQLdb config %s: %s (%d)',
      [AFileName, SysErrorMessage(lErrorCode), lErrorCode]);
  end;
  {$endif}
end;

end.
