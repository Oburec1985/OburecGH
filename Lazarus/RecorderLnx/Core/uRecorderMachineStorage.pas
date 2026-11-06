unit uRecorderMachineStorage;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses SysUtils;

type
  ERecorderMachineStorageCommitUncertain = class(Exception);

{$IFDEF RECORDER_STORAGE_TEST}
var RecorderMachineStorageTestHook: procedure(const AStage: string);
{$ENDIF}

function RecorderMachineStorageFileName: string;
function RecorderMachineStorageExists: Boolean;
function RecorderMachineStorageInitialized: Boolean;
function RecorderMachineStorageCommitUncertain: Boolean;
function TryLoadExistingRecorderMachineStorage: Boolean;
procedure InitializeRecorderMachineStorage(const ALegacyMeraPath: string);
procedure SaveRecorderMachineStorage(const AMeraPath: string);
function RecorderMachineMeraPath: string;

implementation

uses Classes, IniFiles, uRecorderMeraPaths
  {$IFDEF UNIX}, BaseUnix, Unix{$ENDIF}
  {$IFDEF WINDOWS}, Windows{$ENDIF};

var
  gInitialized, gCommitUncertain: Boolean;
  gFileName, gMeraPath: string;

function RecorderMachineStorageFileName: string;
begin
  if gFileName = '' then
    gFileName := IncludeTrailingPathDelimiter(
      ExtractFileDir(RecorderAppConfigFileName)) + 'storage.ini';
  Result := gFileName;
end;

function RecorderMachineStorageExists: Boolean;
{$IFDEF UNIX}
var lStat: Stat; lError: cint;
{$ELSE}
var lAttributes, lError: DWORD;
{$ENDIF}
begin
  {$IFDEF UNIX}
  if fpLStat(PChar(RecorderMachineStorageFileName), lStat) = 0 then
  begin
    if not FPS_ISREG(lStat.st_mode) then
      raise Exception.Create('Machine storage is not a regular file');
    Exit(True);
  end;
  lError := fpGetErrNo;
  if lError = ESysENOENT then Exit(False);
  raise Exception.CreateFmt('Cannot inspect machine storage: %d', [lError]);
  {$ELSE}
  lAttributes := GetFileAttributesW(PWideChar(UTF8Decode(RecorderMachineStorageFileName)));
  if lAttributes <> INVALID_FILE_ATTRIBUTES then
  begin
    if (lAttributes and (FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_REPARSE_POINT)) <> 0 then
      raise Exception.Create('Machine storage is not a regular file');
    Exit(True);
  end;
  lError := GetLastError;
  if (lError = ERROR_FILE_NOT_FOUND) or (lError = ERROR_PATH_NOT_FOUND) then Exit(False);
  raise Exception.CreateFmt('Cannot inspect machine storage: %d', [lError]);
  {$ENDIF}
end;

function RecorderMachineStorageInitialized: Boolean;
begin
  Result := gInitialized;
end;

function RecorderMachineStorageCommitUncertain: Boolean;
begin
  Result := gCommitUncertain;
end;

procedure CheckValue(const AValue, AName: string);
begin
  if (Pos(#10, AValue) <> 0) or (Pos(#13, AValue) <> 0) then
    raise Exception.Create('Invalid machine storage ' + AName);
end;

function AcquireLock(const AFileName: string): THandle;
begin
  {$IFDEF UNIX}
  Result := fpOpen(PChar(AFileName), O_CREAT or O_RDWR or O_NOFOLLOW, &600);
  if Result < 0 then
    raise Exception.Create('Cannot open machine storage lock');
  if fpFlock(Result, LOCK_EX or LOCK_NB) <> 0 then
  begin
    fpClose(Result);
    raise Exception.Create('Machine storage is locked by another process');
  end;
  {$ELSE}
  Result := CreateFileW(PWideChar(UTF8Decode(AFileName)), GENERIC_READ or
    GENERIC_WRITE, 0, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if Result = INVALID_HANDLE_VALUE then
    raise Exception.Create('Cannot acquire machine storage lock');
  {$ENDIF}
end;

procedure ReleaseLock(AHandle: THandle);
begin
  {$IFDEF UNIX}
  fpFlock(AHandle, LOCK_UN);
  fpClose(AHandle);
  {$ELSE}
  CloseHandle(AHandle);
  {$ENDIF}
end;

procedure ReadStorage(out AMeraPath: string);
var
  lIni: TIniFile;
begin
  {$IFDEF RECORDER_STORAGE_TEST}
  if Assigned(RecorderMachineStorageTestHook) then
    RecorderMachineStorageTestHook('read');
  {$ENDIF}
  lIni := TIniFile.Create(RecorderMachineStorageFileName);
  try
    if not lIni.ValueExists('Storage', 'MeraFilesPath') then
      raise Exception.Create('Machine storage configuration is incomplete');
    AMeraPath := lIni.ReadString('Storage', 'MeraFilesPath', '');
    CheckValue(AMeraPath, 'MeraFilesPath');
  finally
    lIni.Free;
  end;
end;

function TryLoadExistingRecorderMachineStorage: Boolean;
var
  lLock: THandle;
  lMeraPath: string;
begin
  if gInitialized then Exit(True);
  Result := False;
  if not RecorderMachineStorageExists then Exit;
  lLock := AcquireLock(RecorderMachineStorageFileName + '.lock');
  try
    if not RecorderMachineStorageExists then
      raise Exception.Create('Machine storage disappeared while acquiring lock');
    ReadStorage(lMeraPath);
    gMeraPath := lMeraPath;
    gInitialized := True;
    Result := True;
  finally
    ReleaseLock(lLock);
  end;
end;

procedure WriteStorage(const AMeraPath: string);
var
  lIni: TMemIniFile;
  lStrings: TStringList;
  lTemp: string;
  lGuid: TGuid;
  {$IFDEF UNIX}
  lFd: cint;
  {$ENDIF}
begin
  CheckValue(AMeraPath, 'MeraFilesPath');
  if CreateGUID(lGuid) <> 0 then raise Exception.Create('Cannot create storage temporary name');
  lTemp := RecorderMachineStorageFileName + '.' + GUIDToString(lGuid) + '.tmp';
  { FPC TMemIniFile flushes dirty data from Destroy. Bind it exclusively to
    the staging name; binding it to the live file would overwrite that file
    on an exception before the atomic rename. }
  lIni := TMemIniFile.Create(lTemp);
  lStrings := TStringList.Create;
  try
    if FileExists(RecorderMachineStorageFileName) then
    begin
      lStrings.LoadFromFile(RecorderMachineStorageFileName);
      lIni.SetStrings(lStrings);
    end;
    lIni.WriteString('Storage', 'MeraFilesPath', AMeraPath);
    lIni.UpdateFile;
    FreeAndNil(lIni);
    {$IFDEF UNIX}
    if fpChmod(PChar(lTemp), &600) <> 0 then
      raise Exception.Create('Cannot protect machine storage temporary file');
    lFd := fpOpen(PChar(lTemp), O_RDONLY or O_NOFOLLOW);
    if lFd < 0 then raise Exception.Create('Cannot open machine storage temporary file');
    try
      if fpFsync(lFd) <> 0 then
        raise Exception.Create('Cannot sync machine storage temporary file');
    finally
      fpClose(lFd);
    end;
    if fpRename(PChar(lTemp), PChar(RecorderMachineStorageFileName)) <> 0 then
      raise Exception.Create('Cannot replace machine storage file');
    {$IFDEF RECORDER_STORAGE_TEST}
    if Assigned(RecorderMachineStorageTestHook) then
      RecorderMachineStorageTestHook('after-rename');
    {$ENDIF}
    lFd := fpOpen(PChar(ExtractFileDir(RecorderMachineStorageFileName)), O_RDONLY);
    if lFd < 0 then
      raise ERecorderMachineStorageCommitUncertain.Create(
        'Machine storage replaced, but its directory could not be opened for sync');
    try
      if fpFsync(lFd) <> 0 then
        raise ERecorderMachineStorageCommitUncertain.Create(
          'Machine storage replaced, but directory sync failed');
    finally
      fpClose(lFd);
    end;
    {$ELSE}
    if not MoveFileExW(PWideChar(UTF8Decode(lTemp)),
      PWideChar(UTF8Decode(RecorderMachineStorageFileName)),
      MOVEFILE_REPLACE_EXISTING or $8 { MOVEFILE_WRITE_THROUGH }) then
      raise Exception.Create('Cannot replace machine storage file');
    {$ENDIF}
  finally
    lIni.Free;
    if FileExists(lTemp) then SysUtils.DeleteFile(lTemp);
    lStrings.Free;
  end;
end;

procedure InitializeRecorderMachineStorage(const ALegacyMeraPath: string);
var
  lLock: THandle;
  lMeraPath: string;
begin
  if gInitialized then Exit;
  if not ForceDirectories(ExtractFileDir(RecorderMachineStorageFileName)) then
    raise Exception.Create('Cannot create machine storage directory');
  lLock := AcquireLock(RecorderMachineStorageFileName + '.lock');
  try
    if RecorderMachineStorageExists then
      ReadStorage(lMeraPath)
    else
    begin
      lMeraPath := ALegacyMeraPath;
      WriteStorage(lMeraPath);
    end;
    gMeraPath := lMeraPath;
    gInitialized := True;
  finally
    ReleaseLock(lLock);
  end;
end;

procedure SaveRecorderMachineStorage(const AMeraPath: string);
var
  lLock: THandle;
  lCurrentMeraPath: string;
begin
  if not gInitialized then raise Exception.Create('Machine storage is not initialized');
  if gCommitUncertain then
    raise ERecorderMachineStorageCommitUncertain.Create(
      'Machine storage commit could not be verified; restart required');
  lLock := AcquireLock(RecorderMachineStorageFileName + '.lock');
  try
    if not RecorderMachineStorageExists then
      raise Exception.Create('Machine storage was removed during this session');
    ReadStorage(lCurrentMeraPath);
    if lCurrentMeraPath <> gMeraPath then
      raise Exception.Create('Machine storage was changed by another process');
    try
      WriteStorage(AMeraPath);
      gMeraPath := AMeraPath;
    except
      on E: ERecorderMachineStorageCommitUncertain do
      begin
        { The rename happened: keep the live value consistent with the file,
          while reporting that survival of a sudden power loss is uncertain. }
        try
          ReadStorage(lCurrentMeraPath);
          if lCurrentMeraPath = AMeraPath then
            gMeraPath := AMeraPath
          else
            gCommitUncertain := True;
        except
          gCommitUncertain := True;
        end;
        raise;
      end;
    end;
  finally
    ReleaseLock(lLock);
  end;
end;

function RecorderMachineMeraPath: string;
begin
  if not gInitialized then raise Exception.Create('Machine storage is not initialized');
  if gCommitUncertain then
    raise ERecorderMachineStorageCommitUncertain.Create(
      'Machine storage commit could not be verified; restart required');
  Result := gMeraPath;
end;

end.
