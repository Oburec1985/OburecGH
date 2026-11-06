unit uRecorderSqlAtomicStore;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Isolated compare-and-swap for SQL endpoint fields in app.ini. All writers of
  these fields must cooperate with the same stable sidecar lock. A successful
  update replaces the INI atomically; revision discovery/authentication and
  runtime reload are the caller's responsibilities. Not yet used by production. }

interface

uses SysUtils, uRecorderSqlRevision;

type
  TRecorderSqlEndpoint = record
    Backend, RootDirectory, Database, Host: string;
    Port: Word;
    TlsRequired: Boolean;
  end;
  TRecorderSqlBeforeReplace = procedure;
  ERecorderSqlCommitUncertain = class(Exception);

function RecorderSqlAtomicApply(const AFileName, ARevision, ABaseRevision: string;
  AHasBaseRevision: Boolean; const AEndpoint: TRecorderSqlEndpoint;
  ABeforeReplace: TRecorderSqlBeforeReplace = nil;
  ABeforeDirectorySync: TRecorderSqlBeforeReplace = nil): TRecorderSqlRevisionDecision;

implementation

uses Classes, IniFiles
  {$ifdef unix}, BaseUnix, Unix{$endif}
  {$ifdef windows}, Windows{$endif};

const
  CSection = 'SQLdbConnection';
  CLockWaitMs = 5000;

{$ifdef unix}
function flistxattr(AFd: cint; AList: Pointer; ASize: SizeUInt): PtrInt;
  cdecl; external 'c' name 'flistxattr';
{$endif}

{$ifdef windows}
function ReplaceFileA(AReplacedFileName, AReplacementFileName,
  ABackupFileName: PChar; AReplaceFlags: DWORD; AExclude, AReserved: Pointer): BOOL;
  stdcall; external 'kernel32' name 'ReplaceFileA';
{$endif}

procedure AssertSafePath(const AFileName: string; AAllowMissing: Boolean);
var
  lPath, lParent: string;
  lFirst: Boolean;
  {$ifdef unix}
  lStat: Stat;
  {$else}
  lAttributes: DWORD;
  {$endif}
begin
  lPath := ExpandFileName(AFileName);
  lFirst := True;
  repeat
    {$ifdef unix}
    if fpLStat(PChar(lPath), lStat) <> 0 then
    begin
      if not (lFirst and AAllowMissing and (fpGetErrNo = ESysENOENT)) then
        raise Exception.Create('Cannot inspect SQL configuration path');
    end
    else if lFirst then
    begin
      if (not FPS_ISREG(lStat.st_mode)) or (lStat.st_nlink <> 1) then
        raise Exception.Create('SQL configuration path must be a regular, unlinked file');
    end
    else if not FPS_ISDIR(lStat.st_mode) then
      raise Exception.Create('SQL configuration path has a symlink or non-directory parent');
    {$else}
    lAttributes := GetFileAttributes(PChar(lPath));
    if lAttributes = INVALID_FILE_ATTRIBUTES then
    begin
      if not (lFirst and AAllowMissing and (GetLastError = ERROR_FILE_NOT_FOUND)) then
        raise Exception.Create('Cannot inspect SQL configuration path');
    end
    else
    begin
      if (lAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then
        raise Exception.Create('SQL configuration path contains a reparse point');
      if lFirst and ((lAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        raise Exception.Create('SQL configuration path is a directory');
      if (not lFirst) and ((lAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0) then
        raise Exception.Create('SQL configuration parent is not a directory');
    end;
    {$endif}
    lParent := ExtractFileDir(ExcludeTrailingPathDelimiter(lPath));
    if (lParent = '') or (lParent = lPath) then Break;
    lPath := lParent;
    lFirst := False;
  until False;
end;

function AcquireLock(const AFileName: string): THandle;
var
  lStart: QWord;
  {$ifdef unix}
  lHandleStat, lPathStat: Stat;
  {$else}
  lInfo: TByHandleFileInformation;
  {$endif}
begin
  lStart := GetTickCount64;
  repeat
    {$ifdef unix}
    Result := fpOpen(PChar(AFileName), O_CREAT or O_RDWR or O_NOFOLLOW, &600);
    if Result >= 0 then
    begin
      if (fpFStat(Result, lHandleStat) <> 0) or
         (not FPS_ISREG(lHandleStat.st_mode)) or (lHandleStat.st_nlink <> 1) or
         (fpLStat(PChar(AFileName), lPathStat) <> 0) or
         (lHandleStat.st_dev <> lPathStat.st_dev) or
         (lHandleStat.st_ino <> lPathStat.st_ino) then
      begin
        fpClose(Result);
        raise Exception.Create('SQL lock path is not a safe regular file');
      end;
      if fpFlock(Result, LOCK_EX or LOCK_NB) = 0 then Exit;
      fpClose(Result);
    end;
    {$else}
    Result := CreateFile(PChar(AFileName), GENERIC_READ or GENERIC_WRITE, 0,
      nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL or $00200000 { OPEN_REPARSE_POINT }, 0);
    if Result <> INVALID_HANDLE_VALUE then
    begin
      if (not GetFileInformationByHandle(Result, lInfo)) or
         ((lInfo.dwFileAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) or
         (lInfo.nNumberOfLinks <> 1) then
      begin
        CloseHandle(Result);
        raise Exception.Create('SQL lock path is not a safe regular file');
      end;
      Exit;
    end;
    {$endif}
    Sleep(25);
  until GetTickCount64 - lStart >= CLockWaitMs;
  raise Exception.Create('Cannot acquire SQL endpoint configuration lock');
end;

procedure ReleaseLock(AHandle: THandle);
begin
  {$ifdef unix}
  fpFlock(AHandle, LOCK_UN);
  fpClose(AHandle);
  {$else}
  CloseHandle(AHandle);
  {$endif}
end;

procedure VerifyHeldLock(AHandle: THandle; const AFileName: string);
{$ifdef unix}
var
  lHandleStat, lPathStat: Stat;
begin
  if (fpFStat(AHandle, lHandleStat) <> 0) or
     (fpLStat(PChar(AFileName), lPathStat) <> 0) or
     (not FPS_ISREG(lPathStat.st_mode)) or (lHandleStat.st_nlink <> 1) or
     (lHandleStat.st_dev <> lPathStat.st_dev) or
     (lHandleStat.st_ino <> lPathStat.st_ino) then
    raise Exception.Create('SQL lock identity changed while in use');
end;
{$else}
begin
  { The Windows lock handle was opened without FILE_SHARE_DELETE, so a second
    process cannot replace its path while that handle is held. }
end;
{$endif}

function EndpointMatches(AIni: TCustomIniFile;
  const AEndpoint: TRecorderSqlEndpoint): Boolean;
begin
  Result :=
    (AIni.ReadString(CSection, 'Backend', '') = AEndpoint.Backend) and
    (AIni.ReadString(CSection, 'RootDirectory', '') = AEndpoint.RootDirectory) and
    (AIni.ReadString(CSection, 'Database', '') = AEndpoint.Database) and
    (AIni.ReadString(CSection, 'Host', '') = AEndpoint.Host) and
    (AIni.ReadInteger(CSection, 'Port', -1) = AEndpoint.Port) and
    (AIni.ReadBool(CSection, 'TlsRequired', False) = AEndpoint.TlsRequired);
end;

procedure WriteEndpoint(AIni: TCustomIniFile; const ARevision: string;
  const AEndpoint: TRecorderSqlEndpoint);
begin
  AIni.WriteString(CSection, 'Backend', AEndpoint.Backend);
  AIni.WriteString(CSection, 'RootDirectory', AEndpoint.RootDirectory);
  AIni.WriteString(CSection, 'Database', AEndpoint.Database);
  AIni.WriteString(CSection, 'Host', AEndpoint.Host);
  AIni.WriteInteger(CSection, 'Port', AEndpoint.Port);
  AIni.WriteBool(CSection, 'TlsRequired', AEndpoint.TlsRequired);
  AIni.WriteString(CSection, 'Revision', ARevision);
end;

procedure FlushFile(const AFileName: string);
var
  lStream: TFileStream;
begin
  lStream := TFileStream.Create(AFileName, fmOpenReadWrite or fmShareExclusive);
  try
    {$ifdef unix}
    if fpFsync(lStream.Handle) <> 0 then
      raise Exception.Create('Cannot flush SQL endpoint temporary file');
    {$else}
    if not FlushFileBuffers(lStream.Handle) then
      raise Exception.Create('Cannot flush SQL endpoint temporary file');
    {$endif}
  finally
    lStream.Free;
  end;
end;

procedure AtomicReplace(const ATempName, AFileName: string);
begin
  {$ifdef unix}
  if fpRename(PChar(ATempName), PChar(AFileName)) <> 0 then
    raise Exception.Create('Cannot replace SQL endpoint configuration');
  {$else}
  { Do not suppress security-descriptor merge failures. ReplaceFile preserves
    the destination DACL and other attributes, unlike MoveFileEx. }
  if not ReplaceFileA(PChar(AFileName), PChar(ATempName), nil, 0, nil, nil) then
    raise Exception.Create('Cannot replace SQL endpoint configuration');
  {$endif}
end;

procedure SyncContainingDirectory(const ADirectory: string);
{$ifdef unix}
var
  lHandle: cint;
begin
  lHandle := fpOpen(PChar(ADirectory), O_RDONLY or O_DIRECTORY or O_NOFOLLOW);
  if lHandle < 0 then
    raise ERecorderSqlCommitUncertain.Create('SQL update committed but directory cannot be opened for sync');
  try
    if fpFsync(lHandle) <> 0 then
      raise ERecorderSqlCommitUncertain.Create('SQL update committed but directory sync failed');
  finally
    fpClose(lHandle);
  end;
end;
{$else}
begin
  { FlushFileBuffers before ReplaceFile provides the documented Windows path.
    Crash/power-loss durability of the directory entry is not asserted here. }
end;
{$endif}

{$ifdef unix}
procedure InspectUnixFile(const AFileName: string; out AStat: Stat);
var
  lHandle: cint;
  lOpened: Stat;
  lXattrs: PtrInt;
begin
  lHandle := fpOpen(PChar(AFileName), O_RDONLY or O_NOFOLLOW);
  if lHandle < 0 then raise Exception.Create('Cannot open SQL configuration safely');
  try
    if (fpFStat(lHandle, lOpened) <> 0) or
       (fpLStat(PChar(AFileName), AStat) <> 0) or
       (not FPS_ISREG(lOpened.st_mode)) or (lOpened.st_nlink <> 1) or
       (lOpened.st_dev <> AStat.st_dev) or (lOpened.st_ino <> AStat.st_ino) then
      raise Exception.Create('SQL configuration identity changed or is not a regular file');
    lXattrs := flistxattr(lHandle, nil, 0);
    if lXattrs <> 0 then
      raise Exception.Create('SQL configuration has unsupported or unreadable extended attributes');
  finally
    fpClose(lHandle);
  end;
end;

procedure PreserveUnixMetadata(const AFileName: string; const ASource: Stat);
var
  lTemp: Stat;
begin
  InspectUnixFile(AFileName, lTemp);
  if (lTemp.st_uid <> ASource.st_uid) or (lTemp.st_gid <> ASource.st_gid) then
    if fpChown(PChar(AFileName), ASource.st_uid, ASource.st_gid) <> 0 then
      raise Exception.Create('Cannot preserve SQL configuration owner and group');
  if fpChmod(PChar(AFileName), ASource.st_mode and &7777) <> 0 then
    raise Exception.Create('Cannot preserve SQL configuration permissions');
  InspectUnixFile(AFileName, lTemp);
  if (lTemp.st_uid <> ASource.st_uid) or (lTemp.st_gid <> ASource.st_gid) or
     ((lTemp.st_mode and &7777) <> (ASource.st_mode and &7777)) then
    raise Exception.Create('SQL configuration metadata was not preserved');
end;
{$else}
procedure InspectWindowsFile(const AFileName: string;
  out AInfo: TByHandleFileInformation);
var
  lHandle: THandle;
begin
  lHandle := CreateFile(PChar(AFileName), GENERIC_READ,
    FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil, OPEN_EXISTING,
    $00200000 { FILE_FLAG_OPEN_REPARSE_POINT }, 0);
  if lHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Cannot open SQL configuration safely');
  try
    if (GetFileType(lHandle) <> FILE_TYPE_DISK) or
       (not GetFileInformationByHandle(lHandle, AInfo)) or
       ((AInfo.dwFileAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) or
       ((AInfo.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) or
       (AInfo.nNumberOfLinks <> 1) then
      raise Exception.Create('SQL configuration is not a safe regular file');
  finally
    CloseHandle(lHandle);
  end;
end;

procedure PreserveWindowsSecurity(const ASource, ATarget: string);
const
  CSecurityInfo = OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or
    DACL_SECURITY_INFORMATION;
  CProtectedDacl = $80000000;
  CUnprotectedDacl = $20000000;
  CSeDaclProtected = $1000;
var
  lNeeded, lRevision, lFlags: DWORD;
  lControl: SECURITY_DESCRIPTOR_CONTROL;
  lSecurity: array of Byte;
begin
  lNeeded := 0;
  GetFileSecurity(PChar(ASource), CSecurityInfo, nil, 0, @lNeeded);
  if (lNeeded = 0) or (GetLastError <> ERROR_INSUFFICIENT_BUFFER) then
    raise Exception.Create('Cannot query SQL configuration security');
  SetLength(lSecurity, lNeeded);
  if not GetFileSecurity(PChar(ASource), CSecurityInfo,
    PSecurityDescriptor(@lSecurity[0]), lNeeded, @lNeeded) then
    raise Exception.Create('Cannot read SQL configuration security');
  if not GetSecurityDescriptorControl(PSecurityDescriptor(@lSecurity[0]),
    @lControl, @lRevision) then
    raise Exception.Create('Cannot inspect SQL configuration security control');
  lFlags := CSecurityInfo;
  if (lControl and CSeDaclProtected) <> 0 then
    lFlags := lFlags or CProtectedDacl
  else
    lFlags := lFlags or CUnprotectedDacl;
  if not SetFileSecurity(PChar(ATarget), lFlags,
    PSecurityDescriptor(@lSecurity[0])) then
    raise Exception.Create('Cannot preserve SQL configuration security');
end;
{$endif}

procedure CreateTemporaryFile(const AFileName: string);
var
  lHandle: THandle;
begin
  {$ifdef unix}
  { The temporary INI contains all existing sections, which may include
    sensitive values. Do not create it world-readable even briefly. }
  lHandle := fpOpen(PChar(AFileName), O_CREAT or O_EXCL or O_WRONLY, &600);
  if lHandle < 0 then raise Exception.Create('Cannot create SQL temporary file');
  fpClose(lHandle);
  {$else}
  lHandle := CreateFile(PChar(AFileName), GENERIC_WRITE, 0, nil, CREATE_NEW,
    FILE_ATTRIBUTE_NORMAL, 0);
  if lHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Cannot create SQL temporary file');
  CloseHandle(lHandle);
  {$endif}
end;

function RecorderSqlAtomicApply(const AFileName, ARevision, ABaseRevision: string;
  AHasBaseRevision: Boolean; const AEndpoint: TRecorderSqlEndpoint;
  ABeforeReplace, ABeforeDirectorySync: TRecorderSqlBeforeReplace):
  TRecorderSqlRevisionDecision;
var
  lLock: THandle;
  lIni: TMemIniFile;
  lId: TGUID;
  lTemp, lRevision, lDirectory: string;
  {$ifdef unix}
  lStat, lCurrentStat: Stat;
  {$else}
  lInfo, lCurrentInfo: TByHandleFileInformation;
  {$endif}
begin
  if (Trim(AFileName) = '') or (not FileExists(AFileName)) then
    raise Exception.Create('Existing SQL configuration file is required');
  AssertSafePath(AFileName, False);
  AssertSafePath(AFileName + '.sql-lock', True);
  lDirectory := ExtractFileDir(ExpandFileName(AFileName));
  lLock := AcquireLock(AFileName + '.sql-lock');
  try
    AssertSafePath(AFileName, False);
    AssertSafePath(AFileName + '.sql-lock', False);
    VerifyHeldLock(lLock, AFileName + '.sql-lock');
    {$ifdef unix}
    InspectUnixFile(AFileName, lStat);
    {$else}
    InspectWindowsFile(AFileName, lInfo);
    {$endif}
    lIni := TMemIniFile.Create(AFileName);
    try
      lRevision := lIni.ReadString(CSection, 'Revision', '');
      Result := RecorderSqlRevisionDecision(lRevision, ARevision, ABaseRevision,
        AHasBaseRevision, EndpointMatches(lIni, AEndpoint));
      if Result <> srdApply then Exit;
      if CreateGUID(lId) <> 0 then
        raise Exception.Create('Cannot create temporary file identifier');
      lTemp := IncludeTrailingPathDelimiter(lDirectory) +
        '.sql-config-' + GUIDToString(lId) + '.tmp';
      try
        CreateTemporaryFile(lTemp);
        {$ifdef windows}
        { Apply the original descriptor before writing any data into temp. }
        PreserveWindowsSecurity(AFileName, lTemp);
        {$endif}
        lIni.Rename(lTemp, False);
        WriteEndpoint(lIni, ARevision, AEndpoint);
        lIni.UpdateFile;
        {$ifdef unix}
        PreserveUnixMetadata(lTemp, lStat);
        {$endif}
        FlushFile(lTemp);
        if Assigned(ABeforeReplace) then ABeforeReplace;
        AssertSafePath(AFileName, False);
        AssertSafePath(AFileName + '.sql-lock', False);
        VerifyHeldLock(lLock, AFileName + '.sql-lock');
        {$ifdef unix}
        InspectUnixFile(AFileName, lCurrentStat);
        if (lStat.st_dev <> lCurrentStat.st_dev) or
           (lStat.st_ino <> lCurrentStat.st_ino) or
           (lStat.st_size <> lCurrentStat.st_size) or
           (lStat.st_mtime <> lCurrentStat.st_mtime) or
           (lStat.st_mtime_nsec <> lCurrentStat.st_mtime_nsec) or
           (lStat.st_ctime <> lCurrentStat.st_ctime) or
           (lStat.st_ctime_nsec <> lCurrentStat.st_ctime_nsec) then
          raise Exception.Create('SQL configuration changed while preparing update');
        {$else}
        InspectWindowsFile(AFileName, lCurrentInfo);
        if (lInfo.dwVolumeSerialNumber <> lCurrentInfo.dwVolumeSerialNumber) or
           (lInfo.nFileIndexHigh <> lCurrentInfo.nFileIndexHigh) or
           (lInfo.nFileIndexLow <> lCurrentInfo.nFileIndexLow) or
           (lInfo.nFileSizeHigh <> lCurrentInfo.nFileSizeHigh) or
           (lInfo.nFileSizeLow <> lCurrentInfo.nFileSizeLow) or
           (lInfo.ftLastWriteTime.dwHighDateTime <> lCurrentInfo.ftLastWriteTime.dwHighDateTime) or
           (lInfo.ftLastWriteTime.dwLowDateTime <> lCurrentInfo.ftLastWriteTime.dwLowDateTime) then
          raise Exception.Create('SQL configuration changed while preparing update');
        {$endif}
        AtomicReplace(lTemp, AFileName);
        try
          if Assigned(ABeforeDirectorySync) then ABeforeDirectorySync;
          SyncContainingDirectory(lDirectory);
        except
          on E: ERecorderSqlCommitUncertain do raise;
          on E: Exception do
            raise ERecorderSqlCommitUncertain.Create(
              'SQL update committed but directory sync could not be confirmed');
        end;
      finally
        if FileExists(lTemp) then SysUtils.DeleteFile(lTemp);
      end;
    finally
      lIni.Free;
    end;
  finally
    ReleaseLock(lLock);
  end;
end;

end.
