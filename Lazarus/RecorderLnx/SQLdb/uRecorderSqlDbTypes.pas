unit uRecorderSqlDbTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags;

const
  CRecorderSqlDbSchemaVersion = 1;
  CRecorderSqlDbDefaultFileName = 'recorderlnx.sqlite3';
  CRecorderFirebirdDefaultFileName = 'recorderlnx.fdb';
  CRecorderSqlDbControlTagName = 'SqlDbRecordEnabled';

type
  ERecorderSqlDbError = class(Exception);

  TRecorderSqlDbBackend = (rsbSQLite, rsbPostgreSQL, rsbFirebird);
  TRecorderSqlDbRuntimeState = (rsrsDisabled, rsrsReady, rsrsRecording,
    rsrsDegraded, rsrsError);

  TRecorderSqlTrendPoint = record
    SignalName: string;
    TimestampUtc: Double;
    Value: Double;
  end;
  TRecorderSqlTrendPoints = array of TRecorderSqlTrendPoint;

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
    fPort: Word;
    fQueueCapacity: Integer;
    fRecordPeriodMs: Integer;
    fRootDirectory: string;
    fTlsRequired: Boolean;
    fUserName: string;
    function EffectiveRootDirectory: string;
    procedure SetQueueCapacity(AValue: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(ASource: TRecorderSqlDbConfig);
    procedure ResetDefaults;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure RequireValid;
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
begin
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
  fDatabase := CRecorderFirebirdDefaultFileName;
  fControlTagName := '';
  fEnabled := False;
  fHost := '';
  fObjectName := 'Объект мониторинга';
  fObjectType := '';
  fSerialNumber := '';
  fSignalNames.Clear;
  fSignalEstimates.Clear;
  fSignalSelectionConfigured := False;
  fPasswordEnvironment := 'RECORDERLNX_SQLDB_PASSWORD';
  fPort := 3050;
  fQueueCapacity := 8192;
  fRecordPeriodMs := 1000;
  fRootDirectory := RecorderSqlDbDefaultRootDirectory;
  fTlsRequired := False;
  fUserName := 'SYSDBA';
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
    if fPort = 0 then
      raise ERecorderSqlDbError.Create('Remote SQLdb port is zero');
  end;
end;

function TRecorderSqlDbConfig.DatabaseFileName: string;
var
  lName: string;
begin
  if not IsLocalFileDatabase then
    Exit(fDatabase);
  lName := Trim(fDatabase);
  if lName = '' then
    if fBackend = rsbFirebird then
      lName := CRecorderFirebirdDefaultFileName
    else
      lName := CRecorderSqlDbDefaultFileName;
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
  if not FileExists(AFileName) then Exit;
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
  RequireValid;
end;

procedure TRecorderSqlDbConfig.SaveToFile(const AFileName: string);
var
  lIni: TIniFile;
  lIndex: Integer;
begin
  RequireValid;
  if not ForceDirectories(ExtractFileDir(ExpandFileName(AFileName))) then
    raise ERecorderSqlDbError.CreateFmt('Cannot create config directory: %s', [ExtractFileDir(AFileName)]);
  lIni := TIniFile.Create(AFileName);
  try
    lIni.WriteBool('SQLdb', 'Enabled', fEnabled);
    lIni.WriteString('SQLdb', 'Backend', RecorderSqlDbBackendToString(fBackend));
    lIni.WriteString('SQLdb', 'RootDirectory', fRootDirectory);
    lIni.WriteString('SQLdb', 'Database', fDatabase);
    lIni.WriteString('SQLdb', 'ControlTag', fControlTagName);
    lIni.WriteString('SQLdb', 'Host', fHost);
    lIni.WriteString('SQLdb', 'ObjectName', fObjectName);
    lIni.WriteString('SQLdb', 'ObjectType', fObjectType);
    lIni.WriteString('SQLdb', 'SerialNumber', fSerialNumber);
    lIni.WriteInteger('SQLdb', 'Port', fPort);
    lIni.WriteString('SQLdb', 'UserName', fUserName);
    lIni.WriteString('SQLdb', 'PasswordEnvironment', fPasswordEnvironment);
    lIni.WriteBool('SQLdb', 'TlsRequired', fTlsRequired);
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
end;

end.
