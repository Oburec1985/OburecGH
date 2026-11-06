unit uCoordinatorBackup;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils;

type
  TBackupOption = (boProgram, boPlugins, boConfigurations, boCalibrations);
  TBackupOptions = set of TBackupOption;
  TBackupConfigRoot = record
    SourcePath: string;
    RemotePath: string;
    DestinationName: string;
  end;
  TBackupConfigRoots = array of TBackupConfigRoot;
  TBackupHost = record
    DisplayName: string;
    Address: string;
    ConfigRoot: string;
    ConfigRootRemote: string;
    ConfigRoots: TBackupConfigRoots;
    ProgramRoot: string;
    AgentPort: Word;
    AgentToken: string;
  end;
  TBackupHosts = array of TBackupHost;
  TBackupCompleteEvent = procedure(Sender: TObject;
    const AReport, AError: string) of object;

function BackupRecorderHost(const ADestinationRoot: string;
  const AHost: TBackupHost; AOptions: TBackupOptions; out AReport: string): Boolean;
procedure StartCoordinatorBackup(const ADestinationRoot: string;
  const AHosts: TBackupHosts; AOptions: TBackupOptions;
  AOnComplete: TBackupCompleteEvent);

{$IFDEF BACKUP_TEST_HOOKS}
var BackupTestBeforeFinalCheck: procedure;
    BackupTestBeforeExportRetry: procedure;
{$ENDIF}

implementation

uses IniFiles, fphttpclient, fpjson, jsonparser
  {$IFDEF UNIX}, BaseUnix, Unix{$ENDIF}
  {$IFDEF WINDOWS}, Windows{$ENDIF};

{$IFDEF UNIX}
function RecorderFchmod(AFileDescriptor: cint; AMode: Cardinal): cint;
  cdecl; external 'c' name 'fchmod';
{$ENDIF}

type
  EStaleBackupExport = class(Exception);
  TCoordinatorBackupTask = class(TThread)
  private
    fDestinationRoot: string;
    fHosts: TBackupHosts;
    fOptions: TBackupOptions;
    fReport, fError: string;
    fOnComplete: TBackupCompleteEvent;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(const ADestinationRoot: string; const AHosts: TBackupHosts;
      AOptions: TBackupOptions; AOnComplete: TBackupCompleteEvent);
  end;

function SafeComponent(const AValue: string): string;
var
  I: Integer;
begin
  Result := Trim(AValue);
  if (Result = '') or (Result = '.') or (Result = '..') then
    raise Exception.Create('Не задано имя папки резервной копии');
  for I := 1 to Length(Result) do
    if (Result[I] < #32) or (Result[I] in ['/', '\', ':', '*', '?', '"', '<', '>', '|']) then
      raise Exception.Create('Недопустимый символ в имени папки: ' + Result);
  if (Result[Length(Result)] = '.') or (Result[Length(Result)] = ' ') then
    raise Exception.Create('Недопустимое окончание имени папки: ' + Result);
end;

procedure CheckNotLink(const APath: string);
{$IFDEF UNIX}
var lStat: Stat;
{$ENDIF}
{$IFDEF WINDOWS}
var lAttributes: DWORD;
{$ENDIF}
begin
  {$IFDEF UNIX}
  if fpLStat(PChar(APath), lStat) <> 0 then
    raise Exception.Create('Не удалось проверить путь: ' + APath);
  if FPS_ISLNK(lStat.st_mode) then
    raise Exception.Create('Символическая ссылка не копируется: ' + APath);
  if not (FPS_ISDIR(lStat.st_mode) or FPS_ISREG(lStat.st_mode)) then
    raise Exception.Create('Неподдерживаемый тип файла: ' + APath);
  {$ELSE}
  lAttributes := GetFileAttributesW(PWideChar(UTF8Decode(APath)));
  if lAttributes = INVALID_FILE_ATTRIBUTES then
    raise Exception.Create('Не удалось проверить путь: ' + APath);
  if (lAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0 then
    raise Exception.Create('Ссылка или точка повторного разбора не копируется: ' + APath);
  {$ENDIF}
end;

function OptionalFileExists(const APath: string): Boolean;
{$IFDEF UNIX}
var lStat: Stat; lError: cint;
{$ELSE}
var lAttributes, lError: DWORD;
{$ENDIF}
begin
  {$IFDEF UNIX}
  if fpLStat(PChar(APath), lStat) = 0 then
  begin
    if not FPS_ISREG(lStat.st_mode) then
      raise Exception.Create('Путь не является обычным файлом: ' + APath);
    Exit(True);
  end;
  lError := fpGetErrNo;
  if lError = ESysENOENT then Exit(False);
  raise Exception.CreateFmt('Ошибка проверки файла %s: %d', [APath, lError]);
  {$ELSE}
  lAttributes := GetFileAttributesW(PWideChar(UTF8Decode(APath)));
  if lAttributes <> INVALID_FILE_ATTRIBUTES then
  begin
    if (lAttributes and (FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_REPARSE_POINT)) <> 0 then
      raise Exception.Create('Путь не является обычным файлом: ' + APath);
    Exit(True);
  end;
  lError := GetLastError;
  if (lError = ERROR_FILE_NOT_FOUND) or (lError = ERROR_PATH_NOT_FOUND) then Exit(False);
  raise Exception.CreateFmt('Ошибка проверки файла %s: %d', [APath, lError]);
  {$ENDIF}
end;

function FileSystemManagesPermissions(const APath: string): Boolean;
{$IFDEF LINUX}
var
  lMounts, lFields: TStringList;
  lPath, lLine, lLeft, lRight, lMount, lType, lBestType: string;
  I, lSeparator, lSpace, lBestLength: Integer;
  lMountFile: TextFile;
begin
  Result := False;
  lPath := ExpandFileName(APath);
  lBestLength := -1;
  lBestType := '';
  lMounts := TStringList.Create;
  lFields := TStringList.Create;
  try
    try
      { procfs reports length zero; stream it instead of relying on FileSize. }
      AssignFile(lMountFile, '/proc/self/mountinfo');
      Reset(lMountFile);
      try
        while not EOF(lMountFile) do
        begin
          ReadLn(lMountFile, lLine);
          lMounts.Add(lLine);
        end;
      finally
        CloseFile(lMountFile);
      end;
      lFields.StrictDelimiter := True;
      lFields.Delimiter := ' ';
      for I := 0 to lMounts.Count - 1 do
      begin
        lLine := lMounts[I];
        lSeparator := Pos(' - ', lLine);
        if lSeparator = 0 then Continue;
        lLeft := Copy(lLine, 1, lSeparator - 1);
        lRight := Copy(lLine, lSeparator + 3, MaxInt);
        lFields.DelimitedText := lLeft;
        if lFields.Count < 5 then Continue;
        lMount := StringReplace(lFields[4], '\040', ' ', [rfReplaceAll]);
        lMount := StringReplace(lMount, '\011', #9, [rfReplaceAll]);
        lMount := StringReplace(lMount, '\012', #10, [rfReplaceAll]);
        lMount := StringReplace(lMount, '\134', '\', [rfReplaceAll]);
        lSpace := Pos(' ', lRight);
        if lSpace = 0 then Continue;
        lType := Copy(lRight, 1, lSpace - 1);
        if ((lMount = '/') or (lPath = lMount) or
           (Copy(lPath, 1, Length(lMount) + 1) = lMount + '/')) and
           (Length(lMount) >= lBestLength) then
        begin
          lBestLength := Length(lMount);
          lBestType := lType;
        end;
      end;
      Result := SameText(lBestType, 'fuseblk') or SameText(lBestType, 'ntfs3') or
        SameText(lBestType, 'ntfs') or SameText(lBestType, 'fuse.ntfs-3g') or
        SameText(lBestType, 'cifs') or SameText(lBestType, 'smb3') or
        SameText(lBestType, 'fuse.smb3');
    except
      { On an unknown filesystem retain the stricter POSIX permission check. }
      Result := False;
    end;
  finally
    lFields.Free;
    lMounts.Free;
  end;
end;
{$ELSE}
begin
  Result := False;
end;
{$ENDIF}

procedure CreatePrivateDirectory(const APath: string;
  AFileSystemManagedPermissions: Boolean);
{$IFDEF UNIX}
var lStat: Stat;
{$ENDIF}
begin
  if not CreateDir(APath) then
    raise Exception.Create('Не удалось создать новый каталог: ' + APath);
  {$IFDEF UNIX}
  if not AFileSystemManagedPermissions then
    fpChmod(PChar(APath), &700);
  if (fpStat(PChar(APath), lStat) <> 0) or
     ((not AFileSystemManagedPermissions) and
      ((lStat.st_uid <> fpGetEUID) or ((lStat.st_mode and &077) <> 0))) then
    raise Exception.Create('Файловая система не позволяет защитить каталог резервной копии: ' + APath);
  {$ENDIF}
end;

procedure CheckPrivateDirectory(const APath: string;
  AFileSystemManagedPermissions: Boolean);
{$IFDEF UNIX}
var lStat: Stat;
{$ENDIF}
begin
  CheckNotLink(APath);
  if not DirectoryExists(APath) then
    raise Exception.Create('Не является каталогом: ' + APath);
  {$IFDEF UNIX}
  if (fpStat(PChar(APath), lStat) <> 0) or
     ((not AFileSystemManagedPermissions) and
      ((lStat.st_uid <> fpGetEUID) or ((lStat.st_mode and &022) <> 0))) then
    raise Exception.Create('Существующий каталог не защищён: ' + APath);
  {$ENDIF}
end;

procedure CopyRegularFile(const ASource, ATarget: string; AExecutable,
  AFileSystemManagedPermissions: Boolean);
var
  lInput: TStream;
  lOutput: TStream;
  lBeforeSize, lBeforeAge: Int64;
  {$IFDEF UNIX} lHandle, lOutputHandle: cint; lStat: Stat; {$ENDIF}
begin
  CheckNotLink(ASource);
  if DirectoryExists(ASource) then raise Exception.Create('Ожидался файл: ' + ASource);
  if FileExists(ATarget) or DirectoryExists(ATarget) then
    raise Exception.Create('Файл назначения уже существует: ' + ATarget);
  lBeforeAge := FileAge(ASource);
  {$IFDEF UNIX}
  lHandle := fpOpen(PChar(ASource), O_RDONLY or O_NOFOLLOW);
  if lHandle < 0 then raise Exception.Create('Не удалось открыть файл: ' + ASource);
  lInput := THandleStream.Create(lHandle);
  {$ELSE}
  lInput := TFileStream.Create(ASource, fmOpenRead or fmShareDenyNone);
  {$ENDIF}
  try
    lBeforeSize := lInput.Size;
    {$IFDEF UNIX}
    { A newly-created snapshot may live on an NTFS or CIFS volume with
      inherited writable modes. Never follow or overwrite an existing target. }
    lOutputHandle := fpOpen(PChar(ATarget), O_WRONLY or O_CREAT or O_EXCL or
      O_NOFOLLOW, &600);
    if lOutputHandle < 0 then
      raise Exception.Create('Не удалось безопасно создать файл назначения: ' + ATarget);
    lOutput := THandleStream.Create(lOutputHandle);
    {$ELSE}
    lOutput := TFileStream.Create(ATarget, fmCreate);
    {$ENDIF}
    try
      {$IFDEF UNIX}
      if not AFileSystemManagedPermissions then
        if AExecutable then RecorderFchmod(lOutputHandle, &700)
        else RecorderFchmod(lOutputHandle, &600);
      if (fpFStat(lOutputHandle, lStat) <> 0) or not FPS_ISREG(lStat.st_mode) or
         ((not AFileSystemManagedPermissions) and
          ((lStat.st_uid <> fpGetEUID) or ((lStat.st_mode and &077) <> 0))) then
        raise Exception.Create('Файловая система не позволяет защитить файл резервной копии: ' + ATarget);
      {$ENDIF}
      lOutput.CopyFrom(lInput, 0);
      if (lOutput.Size <> lBeforeSize) or (lInput.Size <> lBeforeSize) or
         (FileAge(ASource) <> lBeforeAge) then
        raise Exception.Create('Файл изменился во время копирования: ' + ASource);
    finally
      lOutput.Free;
      {$IFDEF UNIX} fpClose(lOutputHandle); {$ENDIF}
    end;
  finally
    lInput.Free;
    {$IFDEF UNIX} fpClose(lHandle); {$ENDIF}
  end;
end;

function IsExportMarker(const AName: string): Boolean;
const Prefix = '.recorder-backup-export-';
var I: Integer;
begin
  Result := False;
  if (Length(AName) <> Length(Prefix) + 32) or
     (Copy(AName, 1, Length(Prefix)) <> Prefix) then Exit;
  for I := Length(Prefix) + 1 to Length(AName) do
    if not (AName[I] in ['0'..'9', 'a'..'f']) then Exit;
  Result := True;
end;

procedure CopyDirectoryTree(const ASource, ATarget: string;
  AFileSystemManagedPermissions: Boolean);
var
  lSearch: TSearchRec;
  lSource, lTarget: string;
  lCode, lError: Integer;
begin
  CheckNotLink(ASource);
  if not DirectoryExists(ASource) then
    raise Exception.Create('Каталог источника недоступен: ' + ASource);
  CreatePrivateDirectory(ATarget, AFileSystemManagedPermissions);
  lCode := FindFirst(IncludeTrailingPathDelimiter(ASource) + '*', faAnyFile, lSearch);
  if lCode <> 0 then
    raise Exception.Create('Не удалось перечислить каталог источника: ' + ASource);
  try
    repeat
      if (lSearch.Name <> '.') and (lSearch.Name <> '..') and
         not IsExportMarker(lSearch.Name) then
      begin
        if lSearch.Name = '.backup-incomplete' then
          raise Exception.Create('Источник содержит незавершённую резервную копию или совпадает с назначением: ' + ASource);
        lSource := IncludeTrailingPathDelimiter(ASource) + lSearch.Name;
        lTarget := IncludeTrailingPathDelimiter(ATarget) + lSearch.Name;
        CheckNotLink(lSource);
        if (lSearch.Attr and faDirectory) <> 0 then
          CopyDirectoryTree(lSource, lTarget, AFileSystemManagedPermissions)
        else
          CopyRegularFile(lSource, lTarget, False, AFileSystemManagedPermissions);
      end;
      {$IFDEF UNIX} fpSetErrNo(0); {$ELSE} SetLastError(0); {$ENDIF}
      lCode := FindNext(lSearch);
      {$IFDEF UNIX} lError := fpGetErrNo; {$ELSE} lError := GetLastError; {$ENDIF}
      if lCode <> 0 then
      begin
        {$IFDEF UNIX}
        if lError <> 0 then
        {$ELSE}
        if (lError <> 0) and (lError <> ERROR_NO_MORE_FILES) then
        {$ENDIF}
          raise Exception.CreateFmt('Ошибка чтения каталога %s: %d', [ASource, lError]);
        Break;
      end;
    until False;
  finally
    SysUtils.FindClose(lSearch);
  end;
end;

function NormalRemote(const APath: string): string;
begin
  Result := StringReplace(Trim(APath), '\', '/', [rfReplaceAll]);
  while (Length(Result) > 1) and (Result[Length(Result)] = '/') do
    Delete(Result, Length(Result), 1);
  if (Pos('/../', Result + '/') > 0) or (Pos('/./', Result + '/') > 0) then
    raise Exception.Create('Путь проекта содержит переходы между каталогами');
end;

procedure CheckDestinationOutsideSource(const ASource, ADestination: string);
var lSource, lDestination: string;
begin
  lSource := IncludeTrailingPathDelimiter(ExpandFileName(ASource));
  lDestination := IncludeTrailingPathDelimiter(ExpandFileName(ADestination));
  {$IFDEF WINDOWS}
  if SameText(Copy(lDestination, 1, Length(lSource)), lSource) then
  {$ELSE}
  if Copy(lDestination, 1, Length(lSource)) = lSource then
  {$ENDIF}
    raise Exception.Create('Каталог назначения находится внутри источника: ' + ASource);
end;

function VerifyActiveProject(const AHost: TBackupHost): string;
var
  lIni: TIniFile;
  lProject, lRoot, lRelative, lCandidate: string;
  I: Integer;
begin
  if not FileExists(IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'app.ini') then
    raise Exception.Create('Не найден app.ini, активный проект неизвестен');
  CheckNotLink(IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'app.ini');
  lIni := TIniFile.Create(IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'app.ini');
  try
    lProject := Trim(lIni.ReadString('Application', 'DefaultProjectConfigDir', ''));
  finally lIni.Free; end;
  if lProject = '' then lProject := 'config/projects/default';
  lProject := NormalRemote(lProject);
  if (lProject = '') or ((lProject[1] <> '/') and
    not ((Length(lProject) > 1) and (lProject[2] = ':'))) then
    lProject := NormalRemote(AHost.ConfigRootRemote + '/' + lProject);
  for I := 0 to High(AHost.ConfigRoots) do
  begin
    if not SameText(AHost.ConfigRoots[I].DestinationName, 'projects') then Continue;
    lRoot := NormalRemote(AHost.ConfigRoots[I].RemotePath);
    if (lRoot = '') or ((lProject <> lRoot) and
       (Copy(lProject, 1, Length(lRoot) + 1) <> lRoot + '/')) then Continue;
    lRelative := Copy(lProject, Length(lRoot) + 1, MaxInt);
    while (lRelative <> '') and (lRelative[1] = '/') do Delete(lRelative, 1, 1);
    lCandidate := IncludeTrailingPathDelimiter(AHost.ConfigRoots[I].SourcePath) +
      StringReplace(lRelative, '/', DirectorySeparator, [rfReplaceAll]);
    if DirectoryExists(lCandidate) and
      (FileExists(IncludeTrailingPathDelimiter(lCandidate) + 'config.json') or
       FileExists(IncludeTrailingPathDelimiter(lCandidate) + 'default.config.json')) then
      Exit(ExcludeTrailingPathDelimiter(lCandidate));
  end;
  raise Exception.Create('Активный проект отсутствует в доступных источниках: ' + lProject);
end;

procedure ResolveAndVerifyExports(var AHost: TBackupHost);
var
  lIni: TIniFile;
  lMetadata, lProjectRoot, lCalibrRoot, lSdbRoot, lProgramRoot,
    lMeraRoot, lDefaultMera, lActualMera, lFile, lProjectDir,
    lGeneration, lField, lMarkerData: string;
  lStream: TFileStream;
  I: Integer;
  lFound: set of (bfApp, bfProject, bfCalibr, bfSdb);
begin
  lMetadata := IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'backup-export-info.ini';
  CheckNotLink(lMetadata);
  lIni := TIniFile.Create(lMetadata);
  try
    if lIni.ReadString('BackupExport', 'State', '') <> 'ready' then
      raise Exception.Create('Источники резервного копирования не готовы');
    for I := 0 to High(AHost.ConfigRoots) do
    begin
      lField := '';
      if SameText(AHost.ConfigRoots[I].DestinationName, 'projects') then lField := 'ProjectsGeneration'
      else if (AHost.AgentPort = 0) and SameText(AHost.ConfigRoots[I].DestinationName, 'Calibr') then lField := 'CalibrGeneration'
      else if (AHost.AgentPort = 0) and SameText(AHost.ConfigRoots[I].DestinationName, 'SDB') then lField := 'SdbGeneration';
      if lField = '' then Continue;
      lGeneration := lIni.ReadString('BackupExport', lField, '');
      if not IsExportMarker('.recorder-backup-export-' + lGeneration) then
        raise Exception.Create('Отсутствует идентификатор опубликованного источника: ' + lField);
      lFile := IncludeTrailingPathDelimiter(AHost.ConfigRoots[I].SourcePath) +
        '.recorder-backup-export-' + lGeneration;
      if not OptionalFileExists(lFile) then
        raise EStaleBackupExport.Create('Не найдена отметка актуального источника: ' + lField);
      CheckNotLink(lFile);
      try
        lStream := TFileStream.Create(lFile, fmOpenRead or fmShareDenyNone);
      except
        on E: EFOpenError do
          raise EStaleBackupExport.Create('Не найдена отметка актуального источника: ' + lField);
      end;
      try
        if lStream.Size <> Length(lGeneration) + 1 then
          raise EStaleBackupExport.Create('Неверная отметка опубликованного источника: ' + lField);
        SetLength(lMarkerData, lStream.Size);
        lStream.ReadBuffer(lMarkerData[1], Length(lMarkerData));
      finally lStream.Free; end;
      if lMarkerData <> lGeneration + #10 then
        raise EStaleBackupExport.Create('Подключён устаревший источник: ' + lField);
    end;
    lProjectRoot := NormalRemote(lIni.ReadString('BackupExport', 'ProjectsRoot', ''));
    lCalibrRoot := NormalRemote(lIni.ReadString('BackupExport', 'CalibrRoot', ''));
    lSdbRoot := NormalRemote(lIni.ReadString('BackupExport', 'SdbRoot', ''));
    lProgramRoot := NormalRemote(lIni.ReadString('BackupExport', 'ProgramRoot', ''));
    lMeraRoot := NormalRemote(lIni.ReadString('BackupExport', 'RuntimeMeraRoot', ''));
    lDefaultMera := NormalRemote(lIni.ReadString('BackupExport', 'DefaultMeraRoot', ''));
  finally lIni.Free; end;
  if AHost.AgentPort <> 0 then
  begin
    lCalibrRoot := lMeraRoot + '/Calibr';
    lSdbRoot := lMeraRoot + '/SDB';
  end;
  if (lProjectRoot = '') or (lCalibrRoot = '') or (lSdbRoot = '') or
     (lProgramRoot <> '/opt/mera/RecorderLnx') or (lMeraRoot = '') then
    raise Exception.Create('Описание опубликованных каталогов неполно: ' + lMetadata);
  if (lCalibrRoot <> lMeraRoot + '/Calibr') or (lSdbRoot <> lMeraRoot + '/SDB') then
    raise Exception.Create('Каталоги Calibr/SDB не соответствуют Mera Files');
  lFound := [];
  for I := 0 to High(AHost.ConfigRoots) do
  begin
    if SameText(AHost.ConfigRoots[I].DestinationName, 'app-config') then
    begin AHost.ConfigRoots[I].RemotePath := NormalRemote(AHost.ConfigRootRemote + '/config'); Include(lFound, bfApp); end
    else if SameText(AHost.ConfigRoots[I].DestinationName, 'projects') then
    begin AHost.ConfigRoots[I].RemotePath := lProjectRoot; Include(lFound, bfProject); end
    else if SameText(AHost.ConfigRoots[I].DestinationName, 'Calibr') then
    begin AHost.ConfigRoots[I].RemotePath := lCalibrRoot; Include(lFound, bfCalibr); end
    else if SameText(AHost.ConfigRoots[I].DestinationName, 'SDB') then
    begin AHost.ConfigRoots[I].RemotePath := lSdbRoot; Include(lFound, bfSdb); end;
  end;
  if lFound <> [bfApp, bfProject, bfCalibr, bfSdb] then
    raise Exception.Create('Не заданы все опубликованные каталоги конфигурации');
  lProjectDir := VerifyActiveProject(AHost);
  lFile := IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'storage.ini';
  if OptionalFileExists(lFile) then
  begin
    CheckNotLink(lFile);
    lIni := TIniFile.Create(lFile);
    try
      if not lIni.ValueExists('Storage', 'MeraFilesPath') then
        raise Exception.Create('storage.ini не содержит MeraFilesPath');
      lActualMera := Trim(lIni.ReadString('Storage', 'MeraFilesPath', ''));
    finally lIni.Free; end;
  end
  else
  begin
    lFile := IncludeTrailingPathDelimiter(lProjectDir) + 'default.run-control.ini';
    if not OptionalFileExists(lFile) then
      lFile := IncludeTrailingPathDelimiter(lProjectDir) + 'run-control.ini';
    if not OptionalFileExists(lFile) then
      raise Exception.Create('Не найден run-control активного проекта для проверки Mera Files');
    CheckNotLink(lFile);
    lIni := TIniFile.Create(lFile);
    try lActualMera := Trim(lIni.ReadString('Mera', 'FilesPath', ''));
    finally lIni.Free; end;
    if (lActualMera = '') or (Pos('\', lActualMera) > 0) or
       ((Length(lActualMera) > 1) and (lActualMera[2] = ':')) then
    begin
      if lDefaultMera = '' then
        raise Exception.Create('Невозможно подтвердить стандартный путь Mera Files активного проекта');
      lActualMera := lDefaultMera;
    end;
  end;
  if NormalRemote(lActualMera) <> lMeraRoot then
    raise Exception.Create('Опубликованный Mera Files не совпадает с настройками программы');
end;

function SourceState(const AHost: TBackupHost): string;
var lFiles: array[0..4] of string; lProject: string; lStream: TFileStream;
  I: Integer; lData: string;
begin
  lProject := VerifyActiveProject(AHost);
  lFiles[0] := IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'backup-export-info.ini';
  lFiles[1] := IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'app.ini';
  lFiles[2] := IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'storage.ini';
  lFiles[3] := IncludeTrailingPathDelimiter(lProject) + 'default.run-control.ini';
  lFiles[4] := IncludeTrailingPathDelimiter(lProject) + 'run-control.ini';
  Result := lProject + #0;
  for I := 0 to High(lFiles) do
  begin
    Result := Result + lFiles[I] + #0;
    if not OptionalFileExists(lFiles[I]) then begin Result := Result + '-' + #0; Continue; end;
    CheckNotLink(lFiles[I]);
    lStream := TFileStream.Create(lFiles[I], fmOpenRead or fmShareDenyNone);
    try
      if lStream.Size > 16 * 1024 * 1024 then raise Exception.Create('Слишком большой файл настройки: ' + lFiles[I]);
      SetLength(lData, lStream.Size);
      if Length(lData) > 0 then lStream.ReadBuffer(lData[1], Length(lData));
    finally lStream.Free; end;
    Result := Result + IntToStr(Length(lData)) + ':' + lData;
  end;
end;

function AgentPost(const AHost: TBackupHost; const APath, ABody: string): TJSONData;
var lClient: TFPHTTPClient; lInput: TStringStream; lResponse: string;
begin
  Result := nil;
  lClient := TFPHTTPClient.Create(nil);
  lInput := TStringStream.Create(ABody);
  try
    lClient.ConnectTimeout := 5000;
    lClient.IOTimeout := 120000;
    lClient.AddHeader('Content-Type', 'application/json');
    if AHost.AgentToken <> '' then
      lClient.AddHeader('Authorization', 'Bearer ' + AHost.AgentToken);
    lClient.RequestBody := lInput;
    lResponse := lClient.Post('http://' + AHost.Address + ':' +
      IntToStr(AHost.AgentPort) + APath);
    Result := GetJSON(lResponse);
    if (Result.JSONType <> jtObject) or
       (TJSONObject(Result).Get('result_code', '') <> 'noError') then
    begin
      FreeAndNil(Result);
      raise Exception.Create('HostAgent не подтвердил подготовку резервной копии');
    end;
  finally
    lClient.RequestBody := nil;
    lInput.Free;
    lClient.Free;
  end;
end;

procedure PrepareAgentBackup(var AHost: TBackupHost; AOptions: TBackupOptions;
  out ASnapshotId, AProjectName: string);
var lJson: TJSONData; lId, lRel, lStage, lBody: string; lGuid: TGuid;
begin
  lBody := '{"layout":"active-project-v1","configurations":true' +
    ',"calibrations":' + LowerCase(BoolToStr(boCalibrations in AOptions, True)) + '}';
  lJson := AgentPost(AHost, '/api/v1/backup/prepare', lBody);
  try
    lId := TJSONObject(lJson).Get('snapshot_id', '');
    if (Length(lId) <> 36) or not TryStringToGUID('{' + lId + '}', lGuid) then
      raise Exception.Create('HostAgent вернул неверный идентификатор снимка');
    ASnapshotId := lId;
    lRel := TJSONObject(lJson).Get('relative_path', '');
    if lRel <> 'RecorderLnx/cach/backup-staging/' + lId then
      raise Exception.Create('HostAgent вернул неверный путь снимка');
    lStage := IncludeTrailingPathDelimiter(AHost.ConfigRoot) + 'cach' + DirectorySeparator +
      'backup-staging' + DirectorySeparator + lId;
    AHost.ProgramRoot := lStage;
    if boConfigurations in AOptions then
    begin
      if TJSONObject(lJson).Get('layout', '') <> 'active-project-v1' then
        raise Exception.Create('HostAgent не поддерживает копирование только активного проекта');
      AProjectName := SafeComponent(TJSONObject(lJson).Get('project_name', ''));
      AHost.ConfigRoot := IncludeTrailingPathDelimiter(lStage) + 'bootstrap';
    end;
  finally lJson.Free; end;
end;

procedure VerifyAgentBackup(const AHost: TBackupHost; const AId: string);
var lJson: TJSONData;
begin
  lJson := AgentPost(AHost, '/api/v1/backup/verify', '{"snapshot_id":"' + AId + '"}');
  lJson.Free;
end;

procedure CleanupAgentBackup(const AHost: TBackupHost; const AId: string);
var lJson: TJSONData;
begin
  lJson := AgentPost(AHost, '/api/v1/backup/cleanup', '{"snapshot_id":"' + AId + '"}');
  lJson.Free;
end;

function BackupRecorderHost(const ADestinationRoot: string;
  const AHost: TBackupHost; AOptions: TBackupOptions; out AReport: string): Boolean;
var
  lHostDir, lSnapshotDir, lConfigDir, lName, lMarker, lProgress, lSourceState, lAgentSnapshot: string;
  lProjectSource, lProjectName, lCalibrSource, lProjectsDir: string;
  lManifest: TIniFile;
  {$IFDEF UNIX}
  lMarkerHandle, lManifestHandle: cint;
  lManifestStream: THandleStream;
  {$ELSE}
  lMarkerStream: TFileStream;
  {$ENDIF}
  lHost: TBackupHost;
  lGuid: TGuid;
  lFileSystemManagedPermissions: Boolean;
  I: Integer;
begin
  Result := False;
  AReport := '';
  lAgentSnapshot := '';
  try
    lHost := AHost;
    lHost.ConfigRoots := Copy(AHost.ConfigRoots);
    if not (boConfigurations in AOptions) or ((AOptions * [boProgram, boPlugins]) <> []) then
      raise Exception.Create('Резервное копирование поддерживает только настройки RecorderLnx');
    if not DirectoryExists(ADestinationRoot) then
      raise Exception.Create('Каталог назначения недоступен: ' + ADestinationRoot);
    lFileSystemManagedPermissions := FileSystemManagesPermissions(ADestinationRoot);
    lName := SafeComponent(AHost.DisplayName);
    lHostDir := IncludeTrailingPathDelimiter(ADestinationRoot) + lName;
    if lHost.AgentPort <> 0 then
    begin
      PrepareAgentBackup(lHost, AOptions, lAgentSnapshot, lProjectName);
      lProjectSource := IncludeTrailingPathDelimiter(lHost.ProgramRoot) + 'project';
      if boCalibrations in AOptions then
        lCalibrSource := IncludeTrailingPathDelimiter(lHost.ProgramRoot) + 'Calibr';
    end
    else
    begin
      if Length(AHost.ConfigRoots) = 0 then
        raise Exception.Create('Не задан ни один каталог проектов');
      CheckNotLink(lHost.ConfigRoot);
      try
        ResolveAndVerifyExports(lHost);
      except
        on E: EStaleBackupExport do
        begin
          { No source access during this pause: systemd can unmount an idle CIFS share. }
          {$IFDEF BACKUP_TEST_HOOKS}
          if Assigned(BackupTestBeforeExportRetry) then BackupTestBeforeExportRetry
          else
          {$ENDIF}
            Sleep(25000);
          try
            ResolveAndVerifyExports(lHost);
          except
            on RetryError: EStaleBackupExport do
              raise Exception.Create('Не удалось обновить подключение к источнику после ожидания: ' + RetryError.Message);
          end;
        end;
      end;
      lSourceState := SourceState(lHost);
      ResolveAndVerifyExports(lHost);
      if lSourceState <> SourceState(lHost) then
        raise Exception.Create('Настройки источника изменились при проверке');
      lProjectSource := VerifyActiveProject(lHost);
      lProjectName := SafeComponent(ExtractFileName(lProjectSource));
      if boCalibrations in AOptions then
        for I := 0 to High(lHost.ConfigRoots) do
          if SameText(lHost.ConfigRoots[I].DestinationName, 'Calibr') then
            lCalibrSource := lHost.ConfigRoots[I].SourcePath;
    end;
    CheckNotLink(lHost.ConfigRoot);
    CheckNotLink(lProjectSource);
    if not (FileExists(IncludeTrailingPathDelimiter(lProjectSource) + 'config.json') or
      FileExists(IncludeTrailingPathDelimiter(lProjectSource) + 'default.config.json')) then
      raise Exception.Create('В снимке отсутствует конфигурация активного проекта');
    CheckDestinationOutsideSource(AHost.ConfigRoot, lHostDir);
    CheckDestinationOutsideSource(lProjectSource, lHostDir);
    if boCalibrations in AOptions then
    begin
      CheckNotLink(lCalibrSource);
      CheckDestinationOutsideSource(lCalibrSource, lHostDir);
    end;
    if DirectoryExists(lHostDir) then
      CheckPrivateDirectory(lHostDir, lFileSystemManagedPermissions)
    else CreatePrivateDirectory(lHostDir, lFileSystemManagedPermissions);
    if CreateGUID(lGuid) <> 0 then raise Exception.Create('Не удалось создать имя снимка');
    lSnapshotDir := IncludeTrailingPathDelimiter(lHostDir) +
      FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '-' +
      StringReplace(StringReplace(GUIDToString(lGuid), '{', '', []), '}', '', []);
    CreatePrivateDirectory(lSnapshotDir, lFileSystemManagedPermissions);
    lMarker := IncludeTrailingPathDelimiter(lSnapshotDir) + '.backup-incomplete';
    {$IFDEF UNIX}
    lMarkerHandle := fpOpen(PChar(lMarker), O_WRONLY or O_CREAT or O_EXCL or
      O_NOFOLLOW, &600);
    if lMarkerHandle < 0 then
      raise Exception.Create('Не удалось безопасно создать отметку снимка: ' + lMarker);
    fpClose(lMarkerHandle);
    {$ELSE}
    lMarkerStream := TFileStream.Create(lMarker, fmCreate);
    lMarkerStream.Free;
    {$ENDIF}
    lProgress := '';
    if boConfigurations in AOptions then
    begin
      lConfigDir := IncludeTrailingPathDelimiter(lSnapshotDir) + 'configurations';
      CreatePrivateDirectory(lConfigDir, lFileSystemManagedPermissions);
      CopyRegularFile(IncludeTrailingPathDelimiter(lHost.ConfigRoot) + 'app.ini',
        IncludeTrailingPathDelimiter(lConfigDir) + 'app.ini', False,
        lFileSystemManagedPermissions);
      lProjectsDir := IncludeTrailingPathDelimiter(lConfigDir) + 'projects';
      CreatePrivateDirectory(lProjectsDir, lFileSystemManagedPermissions);
      CopyDirectoryTree(lProjectSource, IncludeTrailingPathDelimiter(lProjectsDir) +
        lProjectName, lFileSystemManagedPermissions);
      if boCalibrations in AOptions then
        CopyDirectoryTree(lCalibrSource, IncludeTrailingPathDelimiter(lConfigDir) +
          'Calibr', lFileSystemManagedPermissions);
      lProgress := 'настройки';
    end;
    {$IFDEF UNIX}
    lManifestHandle := fpOpen(PChar(IncludeTrailingPathDelimiter(lSnapshotDir) +
      'backup-info.ini'), O_RDWR or O_CREAT or O_EXCL or O_NOFOLLOW, &600);
    if lManifestHandle < 0 then
      raise Exception.Create('Не удалось безопасно создать описание снимка');
    lManifestStream := THandleStream.Create(lManifestHandle);
    try
      if not lFileSystemManagedPermissions then
        if RecorderFchmod(lManifestHandle, &600) <> 0 then
          raise Exception.Create('Не удалось защитить описание резервной копии');
      lManifest := TIniFile.Create(lManifestStream);
    {$ELSE}
    lManifest := TIniFile.Create(IncludeTrailingPathDelimiter(lSnapshotDir) + 'backup-info.ini');
    {$ENDIF}
    try
      lManifest.CacheUpdates := True;
      lManifest.WriteString('Backup', 'Workstation', AHost.DisplayName);
      lManifest.WriteString('Backup', 'Address', AHost.Address);
      lManifest.WriteDateTime('Backup', 'Created', Now);
      lManifest.WriteBool('Backup', 'Configurations', boConfigurations in AOptions);
      lManifest.WriteBool('Backup', 'Calibrations', boCalibrations in AOptions);
      if lFileSystemManagedPermissions then
        lManifest.WriteString('Backup', 'AccessProtection', 'filesystem-managed');
      lManifest.WriteString('Sources', 'Project', lProjectName);
      lManifest.UpdateFile;
    finally lManifest.Free; end;
    {$IFDEF UNIX}
    finally
      lManifestStream.Free;
      fpClose(lManifestHandle);
    end;
    {$ENDIF}
    if boConfigurations in AOptions then
    begin
      {$IFDEF BACKUP_TEST_HOOKS}
      if Assigned(BackupTestBeforeFinalCheck) then BackupTestBeforeFinalCheck;
      {$ENDIF}
      if lAgentSnapshot <> '' then
        VerifyAgentBackup(AHost, lAgentSnapshot)
      else
      begin
        ResolveAndVerifyExports(lHost);
        if lSourceState <> SourceState(lHost) then
          raise Exception.Create('Настройки источника изменились во время копирования');
      end;
    end;
    if not SysUtils.DeleteFile(lMarker) then
      raise Exception.Create('Не удалось завершить отметку резервной копии: ' + lMarker);
    Result := True;
    AReport := AHost.DisplayName + ': успешно (' + Trim(lProgress) + '), ' + lSnapshotDir;
    if lFileSystemManagedPermissions then
      AReport := AReport + LineEnding +
        'Внимание: файлы могут быть доступны другим пользователям в зависимости от настроек диска или сети.';
  except
    on E: Exception do AReport := AHost.DisplayName + ': ОШИБКА: ' + E.Message;
  end;
  if lAgentSnapshot <> '' then
    try CleanupAgentBackup(AHost, lAgentSnapshot);
    except on E: Exception do
      AReport := AReport + LineEnding + 'Не удалось удалить временную копию HostAgent: ' + E.Message;
    end;
end;

constructor TCoordinatorBackupTask.Create(const ADestinationRoot: string;
  const AHosts: TBackupHosts; AOptions: TBackupOptions;
  AOnComplete: TBackupCompleteEvent);
var I, J: Integer;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  fDestinationRoot := ADestinationRoot;
  fOptions := AOptions;
  fOnComplete := AOnComplete;
  SetLength(fHosts, Length(AHosts));
  for I := 0 to High(AHosts) do
  begin
    fHosts[I] := AHosts[I];
    SetLength(fHosts[I].ConfigRoots, Length(AHosts[I].ConfigRoots));
    for J := 0 to High(AHosts[I].ConfigRoots) do
      fHosts[I].ConfigRoots[J] := AHosts[I].ConfigRoots[J];
  end;
end;

procedure TCoordinatorBackupTask.Execute;
var I, lErrors: Integer; lLine, lName: string; lNames: TStringList;
begin
  lErrors := 0;
  try
    if Length(fHosts) = 0 then raise Exception.Create('Нет выбранных рабочих мест');
    lNames := TStringList.Create;
    try
      lNames.CaseSensitive := False;
      for I := 0 to High(fHosts) do
      begin
        lName := SafeComponent(fHosts[I].DisplayName);
        if lNames.IndexOf(lName) >= 0 then
          raise Exception.Create('Одинаковые имена рабочих мест: ' + lName);
        lNames.Add(lName);
      end;
    finally lNames.Free; end;
    for I := 0 to High(fHosts) do
    begin
      if not BackupRecorderHost(fDestinationRoot, fHosts[I], fOptions, lLine) then
        Inc(lErrors);
      if fReport <> '' then fReport := fReport + LineEnding;
      fReport := fReport + lLine;
    end;
    if lErrors > 0 then
      fError := Format('Не удалось полностью скопировать рабочих мест: %d', [lErrors]);
  except on E: Exception do fError := E.Message; end;
  Synchronize(@Deliver);
end;

procedure TCoordinatorBackupTask.Deliver;
begin
  if Assigned(fOnComplete) then fOnComplete(Self, fReport, fError);
end;

procedure StartCoordinatorBackup(const ADestinationRoot: string;
  const AHosts: TBackupHosts; AOptions: TBackupOptions;
  AOnComplete: TBackupCompleteEvent);
var lTask: TCoordinatorBackupTask;
begin
  lTask := TCoordinatorBackupTask.Create(ADestinationRoot, AHosts, AOptions, AOnComplete);
  lTask.Start;
end;

end.
