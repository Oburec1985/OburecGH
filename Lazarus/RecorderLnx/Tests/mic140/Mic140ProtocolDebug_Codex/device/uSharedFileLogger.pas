unit uSharedFileLogger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs;

type
  TSharedLogLevel = (sllDebug, sllInfo, sllWarning, sllError, sllCritical);

  { TSharedFileLogger
    Thread-safe file logger for diagnostics shared by several Lazarus projects.
    It uses a process-local lock and TFileStream append writes, not TextFile Append. }
  TSharedFileLogger = class
  private
    fEnabled: Boolean;
    fFileName: string;
    fLock: TCriticalSection;
    fMaxBytes: Int64;
    fMaxFiles: Integer;
    fThreadNames: TStringList;
    function LevelToString(ALevel: TSharedLogLevel): string;
    procedure RotateIfNeeded;
    procedure WriteLineUnlocked(const ALine: string);
  public
    constructor Create(const AFileName: string = ''; AMaxBytes: Int64 = 10 * 1024 * 1024;
      AMaxFiles: Integer = 5);
    destructor Destroy; override;

    procedure Configure(const AFileName: string; AMaxBytes: Int64 = 10 * 1024 * 1024;
      AMaxFiles: Integer = 5);
    procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
    procedure Log(ALevel: TSharedLogLevel; const AMessage: string);
    procedure Debug(const AMessage: string);
    procedure Info(const AMessage: string);
    procedure Warning(const AMessage: string);
    procedure Error(const AMessage: string);
    procedure Critical(const AMessage: string);

    property Enabled: Boolean read fEnabled write fEnabled;
    property FileName: string read fFileName;
    property MaxBytes: Int64 read fMaxBytes;
    property MaxFiles: Integer read fMaxFiles;
  end;

function SharedLogger: TSharedFileLogger;
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

implementation

var
  gSharedLogger: TSharedFileLogger = nil;

function TSharedFileLogger.LevelToString(ALevel: TSharedLogLevel): string;
begin
  case ALevel of
    sllDebug: Result := 'DEBUG';
    sllInfo: Result := 'INFO';
    sllWarning: Result := 'WARNING';
    sllError: Result := 'ERROR';
    sllCritical: Result := 'CRITICAL';
  else
    Result := 'INFO';
  end;
end;

constructor TSharedFileLogger.Create(const AFileName: string; AMaxBytes: Int64;
  AMaxFiles: Integer);
begin
  inherited Create;
  fLock := TCriticalSection.Create;
  fThreadNames := TStringList.Create;
  fEnabled := True;
  Configure(AFileName, AMaxBytes, AMaxFiles);
end;

destructor TSharedFileLogger.Destroy;
begin
  fThreadNames.Free;
  fLock.Free;
  inherited Destroy;
end;

procedure TSharedFileLogger.Configure(const AFileName: string; AMaxBytes: Int64;
  AMaxFiles: Integer);
begin
  fLock.Enter;
  try
    fFileName := AFileName;
    fMaxBytes := AMaxBytes;
    if fMaxBytes < 0 then
      fMaxBytes := 0;
    fMaxFiles := AMaxFiles;
    if fMaxFiles < 0 then
      fMaxFiles := 0;
  finally
    fLock.Leave;
  end;
end;

procedure TSharedFileLogger.RotateIfNeeded;
var
  I: Integer;
  lBaseName: string;
  lExt: string;
  lNewName: string;
  lOldName: string;
  lStream: TFileStream;
begin
  if (fMaxBytes <= 0) or (fMaxFiles <= 0) or (fFileName = '') or
    (not FileExists(fFileName)) then
    Exit;

  lStream := nil;
  try
    lStream := TFileStream.Create(fFileName, fmOpenRead or fmShareDenyNone);
    if lStream.Size < fMaxBytes then
      Exit;
  finally
    lStream.Free;
  end;

  lBaseName := ChangeFileExt(fFileName, '');
  lExt := ExtractFileExt(fFileName);
  lOldName := lBaseName + '.' + IntToStr(fMaxFiles) + lExt;
  if FileExists(lOldName) then
    DeleteFile(lOldName);

  for I := fMaxFiles - 1 downto 1 do
  begin
    lOldName := lBaseName + '.' + IntToStr(I) + lExt;
    if FileExists(lOldName) then
    begin
      lNewName := lBaseName + '.' + IntToStr(I + 1) + lExt;
      RenameFile(lOldName, lNewName);
    end;
  end;

  lNewName := lBaseName + '.1' + lExt;
  RenameFile(fFileName, lNewName);
end;

procedure TSharedFileLogger.WriteLineUnlocked(const ALine: string);
var
  lDir: string;
  lLine: string;
  lStream: TFileStream;
begin
  if fFileName = '' then
    Exit;

  lDir := ExtractFileDir(fFileName);
  if lDir <> '' then
    ForceDirectories(lDir);

  RotateIfNeeded;
  if FileExists(fFileName) then
    lStream := TFileStream.Create(fFileName, fmOpenReadWrite or fmShareDenyNone)
  else
    lStream := TFileStream.Create(fFileName, fmCreate or fmShareDenyNone);
  try
    lStream.Seek(0, soEnd);
    lLine := ALine + LineEnding;
    if lLine <> '' then
      lStream.WriteBuffer(Pointer(lLine)^, Length(lLine));
  finally
    lStream.Free;
  end;
end;

procedure TSharedFileLogger.RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  fLock.Enter;
  try
    fThreadNames.Values[IntToStr(AThreadID)] := AName;
  finally
    fLock.Leave;
  end;
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  SharedLogger.RegisterThreadName(AThreadID, AName);
end;

procedure TSharedFileLogger.Log(ALevel: TSharedLogLevel; const AMessage: string);
var
  lLine: string;
  lThreadID: TThreadID;
  lThreadName: string;
begin
  if not fEnabled then
    Exit;

  lThreadID := GetThreadID;
  lThreadName := '';
  fLock.Enter;
  try
    if fThreadNames <> nil then
      lThreadName := fThreadNames.Values[IntToStr(lThreadID)];
  finally
    fLock.Leave;
  end;

  if lThreadName <> '' then
    lLine := Format('%s [%s] [TID:%d|%s] %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
      LevelToString(ALevel), PtrUInt(lThreadID), lThreadName, AMessage])
  else
    lLine := Format('%s [%s] [TID:%d] %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
      LevelToString(ALevel), PtrUInt(lThreadID), AMessage]);

  fLock.Enter;
  try
    try
      WriteLineUnlocked(lLine);
    except
      { Diagnostics must not affect application timing or data flow. }
    end;
  finally
    fLock.Leave;
  end;
end;

procedure TSharedFileLogger.Debug(const AMessage: string);
begin
  Log(sllDebug, AMessage);
end;

procedure TSharedFileLogger.Info(const AMessage: string);
begin
  Log(sllInfo, AMessage);
end;

procedure TSharedFileLogger.Warning(const AMessage: string);
begin
  Log(sllWarning, AMessage);
end;

procedure TSharedFileLogger.Error(const AMessage: string);
begin
  Log(sllError, AMessage);
end;

procedure TSharedFileLogger.Critical(const AMessage: string);
begin
  Log(sllCritical, AMessage);
end;

function SharedLogger: TSharedFileLogger;
begin
  if gSharedLogger = nil then
    gSharedLogger := TSharedFileLogger.Create;
  Result := gSharedLogger;
end;

initialization
  gSharedLogger := TSharedFileLogger.Create;

finalization
  FreeAndNil(gSharedLogger);

end.
