unit uRecorderMeraPaths;

{
  РљР°С‚Р°Р»РѕРіРё Mera Files РґР»СЏ RecorderLnx (РЅРµ SharedUtils).

  Original Recorder (rc_utils/Rcutils.cpp):
    GetSystemDirectory -> drive root + "\Mera Files"
    calibr base = GetMeraFilesPath() + "\Calibr\"
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils;

function RecorderMeraFilesPath: string;
procedure SetRecorderMeraFilesPath(const APath: string);
function RecorderSystemPathsFileName: string;
function RecorderConfigPath: string;
procedure RecorderConfigureAppConfigFromCommandLine;
function RecorderAppConfigFileName: string;
function RecorderPluginsPath: string;
function RecorderBiosPath: string;
function RecorderSysComPath: string;
function RecorderServicePath: string;
function RecorderServiceFileName(const AFileName: string): string;
procedure RecorderEnsureMeraDirectories;
function RecorderMeraCalibrRootDir: string;
procedure RecorderMeraResetThermocoupleCache;
procedure RecorderMeraGetThermocoupleCache(out ADiskDir, AFolderKey: string);
procedure RecorderMeraSetThermocoupleCache(const ADiskDir, AFolderKey: string);
function RecorderMeraThermocoupleLastMeraPath: string;
procedure RecorderMeraSetThermocoupleLastMeraPath(const APath: string);

implementation

uses
  Classes, IniFiles
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

var
  g_SystemPathsLoaded: Boolean;
  g_AppPathsLoaded: Boolean;
  g_AppConfigInitialized: Boolean;
  g_AppConfigIsExplicit: Boolean;
  g_AppConfigFileName: string;
  g_MeraFilesPath: string;
  g_ConfigPath: string;
  g_PluginsPath: string;
  g_BiosPath: string;
  g_SysComPath: string;
  g_MeraThermocoupleDir: string;
  g_MeraThermocoupleFolderKey: string;
  g_MeraThermocoupleLastMeraPath: string;

function IsForeignSystemPath(const AValue: string): Boolean;
var
  lValue: string;
begin
  lValue := Trim(AValue);
  {$ifdef unix}
  Result := ((Length(lValue) >= 2) and (lValue[2] = ':')) or
    (Pos('\\', lValue) > 0);
  {$else}
  Result := (lValue <> '') and (lValue[1] = '/');
  {$endif}
end;

function RecorderSystemPathsFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExpandFileName(
    ExtractFilePath(ParamStr(0)))) + 'RecorderLnx.paths.ini';
end;

function IsAbsolutePath(const APath: string): Boolean;
begin
  Result := (APath <> '') and
    (((Length(APath) >= 2) and (APath[2] = ':')) or
     (APath[1] = PathDelim) or
     ((Length(APath) >= 2) and (APath[1] = '\') and (APath[2] = '\')));
end;

function DefaultRecorderMeraFilesPath: string; forward;

function ResolveSystemPath(const AValue, ADefaultRelativePath: string): string;
var
  lValue: string;
begin
  lValue := Trim(AValue);
  if IsForeignSystemPath(lValue) then
    lValue := ADefaultRelativePath;
  if lValue = '' then
    lValue := ADefaultRelativePath;
  if (lValue <> '') and not ((Length(lValue) >= 2) and (lValue[2] = ':')) and
    not ((Length(lValue) >= 2) and (lValue[1] = '\') and
      (lValue[2] = '\')) and (lValue[1] <> PathDelim) then
    lValue := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      lValue;
  Result := ExcludeTrailingPathDelimiter(ExpandFileName(lValue));
end;

function ResolveMeraFilesPath(const AValue: string): string;
begin
  if (Trim(AValue) = '') or IsForeignSystemPath(AValue) then
    Exit(ExcludeTrailingPathDelimiter(DefaultRecorderMeraFilesPath));
  Result := ResolveSystemPath(AValue, '');
end;

function DefaultRecorderMeraFilesPath: string;

  function HasSdbSubdir(const ABase: string): Boolean;
  begin
    Result := DirectoryExists(IncludeTrailingPathDelimiter(ABase) + 'sdb') or
      DirectoryExists(IncludeTrailingPathDelimiter(ABase) + 'SDB');
  end;

  function FirstExistingMeraRoot(const ACandidates: array of string): string;
  var
    lI: Integer;
  begin
    Result := '';
    for lI := Low(ACandidates) to High(ACandidates) do
      if (ACandidates[lI] <> '') and DirectoryExists(ACandidates[lI]) and
        HasSdbSubdir(ACandidates[lI]) then
        Exit(ExcludeTrailingPathDelimiter(ACandidates[lI]));
  end;

{$IFDEF MSWINDOWS}
var
  lDriveRoot: string;
  lSystemDir: array[0..MAX_PATH] of Char;
  lSystemRoot: string;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := FirstExistingMeraRoot([
    'C:\Mera Files',
    IncludeTrailingPathDelimiter(SysUtils.GetEnvironmentVariable('SystemDrive')) + 'Mera Files',
    IncludeTrailingPathDelimiter(SysUtils.GetEnvironmentVariable('ProgramData')) + 'Mera Files'
  ]);
  if Result <> '' then
    Exit;

  FillChar(lSystemDir, SizeOf(lSystemDir), 0);
  if GetSystemDirectory(lSystemDir, MAX_PATH) > 0 then
  begin
    lSystemRoot := IncludeTrailingPathDelimiter(string(lSystemDir)) + 'Mera Files';
    if DirectoryExists(lSystemRoot) and HasSdbSubdir(lSystemRoot) then
      Exit(ExcludeTrailingPathDelimiter(lSystemRoot));
    lSystemDir[2] := #0;
    lSystemRoot := IncludeTrailingPathDelimiter(string(lSystemDir)) + 'Mera Files';
    if DirectoryExists(lSystemRoot) and HasSdbSubdir(lSystemRoot) then
      Exit(ExcludeTrailingPathDelimiter(lSystemRoot));
  end;

  lDriveRoot := IncludeTrailingPathDelimiter(SysUtils.GetEnvironmentVariable('SystemDrive')) + 'Mera Files';
  if DirectoryExists(lDriveRoot) then
    Exit(ExcludeTrailingPathDelimiter(lDriveRoot));

  if GetSystemDirectory(lSystemDir, MAX_PATH) = 0 then
    Result := 'C:' + PathDelim + 'Mera Files'
  else
  begin
    lSystemDir[2] := #0;
    Result := IncludeTrailingPathDelimiter(string(lSystemDir)) + 'Mera Files';
  end;
{$ELSE}
  if SysUtils.GetEnvironmentVariable('MERA_FILES') <> '' then
    Result := SysUtils.GetEnvironmentVariable('MERA_FILES')
  else
    Result := IncludeTrailingPathDelimiter(GetUserDir) + 'Mera Files';
{$ENDIF}
end;

procedure EnsureRecorderSystemPathsLoaded;
var
  lFileName: string;
  lIni: TIniFile;
begin
  if g_SystemPathsLoaded then
    Exit;
  g_SystemPathsLoaded := True;

  g_MeraFilesPath := DefaultRecorderMeraFilesPath;
  g_ConfigPath := '';
  g_PluginsPath := ResolveSystemPath('', 'plugins');
  g_BiosPath := ResolveSystemPath('', 'bios');
  g_SysComPath := ResolveSystemPath('', 'syscom');

  lFileName := RecorderSystemPathsFileName;
  if not FileExists(lFileName) then
    Exit;

  lIni := TIniFile.Create(lFileName);
  try
    g_MeraFilesPath := ResolveMeraFilesPath(
      lIni.ReadString('Paths', 'MeraFiles', g_MeraFilesPath));
    g_ConfigPath := ResolveSystemPath(
      lIni.ReadString('Paths', 'Config', ''), '');
    g_PluginsPath := ResolveSystemPath(
      lIni.ReadString('Paths', 'Plugins', 'plugins'), 'plugins');
    g_BiosPath := ResolveSystemPath(
      lIni.ReadString('Paths', 'Bios', 'bios'), 'bios');
    g_SysComPath := ResolveSystemPath(
      lIni.ReadString('Paths', 'SysCom', 'syscom'), 'syscom');
  finally
    lIni.Free;
  end;
end;

function RecorderMeraFilesPath: string;
begin
  EnsureRecorderSystemPathsLoaded;
  Result := g_MeraFilesPath;
end;

procedure SetRecorderMeraFilesPath(const APath: string);
begin
  EnsureRecorderSystemPathsLoaded;
  g_MeraFilesPath := ResolveMeraFilesPath(APath);
  RecorderMeraResetThermocoupleCache;
end;

function CommandLineAppConfigValue: string;
var
  lArgument: string;
  lIndex: Integer;
begin
  Result := '';
  for lIndex := 1 to ParamCount do
  begin
    lArgument := ParamStr(lIndex);
    if SameText(Copy(lArgument, 1, 5), '/cfg:') or
      SameText(Copy(lArgument, 1, 5), '/cfg=') then
      Exit(Trim(Copy(lArgument, 6, MaxInt)));
  end;
end;

procedure RecorderConfigureAppConfigFromCommandLine;
var
  lConfiguredFileName: string;
begin
  if g_AppConfigInitialized then
    Exit;

  g_AppConfigInitialized := True;
  lConfiguredFileName := CommandLineAppConfigValue;
  g_AppConfigIsExplicit := lConfiguredFileName <> '';
  if not g_AppConfigIsExplicit then
    g_AppConfigFileName := RecorderServiceFileName('app.ini')
  else if IsAbsolutePath(lConfiguredFileName) then
    g_AppConfigFileName := ExpandFileName(lConfiguredFileName)
  else
    g_AppConfigFileName := ExpandFileName(RecorderServiceFileName(
      lConfiguredFileName));
end;

procedure EnsureRecorderAppPathsLoaded;
var
  lIni: TIniFile;
begin
  EnsureRecorderSystemPathsLoaded;
  RecorderConfigureAppConfigFromCommandLine;
  if g_AppPathsLoaded then
    Exit;
  g_AppPathsLoaded := True;
  if not FileExists(g_AppConfigFileName) then
    Exit;

  lIni := TIniFile.Create(g_AppConfigFileName);
  try
    if lIni.ValueExists('Paths', 'Config') then
      g_ConfigPath := ResolveSystemPath(
        lIni.ReadString('Paths', 'Config', ''), '');
    if lIni.ValueExists('Paths', 'Plugins') then
      g_PluginsPath := ResolveSystemPath(
        lIni.ReadString('Paths', 'Plugins', ''), 'plugins');
    if lIni.ValueExists('Paths', 'Bios') then
      g_BiosPath := ResolveSystemPath(
        lIni.ReadString('Paths', 'Bios', ''), 'bios');
    if lIni.ValueExists('Paths', 'SysCom') then
      g_SysComPath := ResolveSystemPath(
        lIni.ReadString('Paths', 'SysCom', ''), 'syscom');
  finally
    lIni.Free;
  end;
end;

function RecorderConfigPath: string;
begin
  EnsureRecorderAppPathsLoaded;
  Result := g_ConfigPath;
end;

function RecorderAppConfigFileName: string;
begin
  RecorderConfigureAppConfigFromCommandLine;
  Result := g_AppConfigFileName;
end;

function RecorderPluginsPath: string;
begin
  EnsureRecorderAppPathsLoaded;
  Result := g_PluginsPath;
end;

function RecorderBiosPath: string;
begin
  EnsureRecorderAppPathsLoaded;
  Result := g_BiosPath;
end;

function RecorderSysComPath: string;
begin
  EnsureRecorderAppPathsLoaded;
  Result := g_SysComPath;
end;

function RecorderServicePath: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'RecorderLnx';
  ForceDirectories(Result);
end;

function RecorderServiceFileName(const AFileName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderServicePath) + AFileName;
end;

procedure RecorderEnsureMeraDirectories;
var
  lDestinationStream: TFileStream;
  lIni: TIniFile;
  lLegacyAppConfigFileName: string;
  lMeraPath: string;
  lProjectConfigDir: string;
  lServicePath: string;
  lSourceStream: TFileStream;
begin
  lMeraPath := IncludeTrailingPathDelimiter(RecorderMeraFilesPath);
  lServicePath := IncludeTrailingPathDelimiter(RecorderServicePath);
  ForceDirectories(lServicePath + 'config');
  ForceDirectories(lServicePath + 'config' + PathDelim + 'projects');
  ForceDirectories(lServicePath + 'config' + PathDelim + 'projects' +
    PathDelim + 'default');
  ForceDirectories(lMeraPath + 'Calibr');
  ForceDirectories(lMeraPath + 'Resources');
  ForceDirectories(lMeraPath + 'SDB');

  RecorderConfigureAppConfigFromCommandLine;
  lLegacyAppConfigFileName := lServicePath + 'config' + PathDelim + 'app.ini';
  if (not g_AppConfigIsExplicit) and (not FileExists(g_AppConfigFileName)) and
    FileExists(lLegacyAppConfigFileName) then
  begin
    try
      lSourceStream := TFileStream.Create(lLegacyAppConfigFileName, fmOpenRead or
        fmShareDenyWrite);
      try
        lDestinationStream := TFileStream.Create(g_AppConfigFileName, fmCreate);
        try
          lDestinationStream.CopyFrom(lSourceStream, 0);
        finally
          lDestinationStream.Free;
        end;
      finally
        lSourceStream.Free;
      end;

      lIni := TIniFile.Create(g_AppConfigFileName);
      try
        lProjectConfigDir := Trim(lIni.ReadString('Application',
          'DefaultProjectConfigDir', ''));
        if (lProjectConfigDir <> '') and not IsAbsolutePath(lProjectConfigDir) then
          lIni.WriteString('Application', 'DefaultProjectConfigDir',
            'config' + PathDelim + lProjectConfigDir);
      finally
        lIni.Free;
      end;
    except
      on E: Exception do
        raise Exception.CreateFmt(
          'RecorderLnx не может создать системную конфигурацию "%s". '+
          'Причина: %s. В Linux откройте «Настройка Linux» → '+
          '«Пользователи и права» → «RecorderLnx…» и исправьте права '+
          'для текущего пользователя.', [g_AppConfigFileName, E.Message]);
    end;
    g_AppPathsLoaded := False;
  end;
end;

procedure RecorderMeraResetThermocoupleCache;
begin
  g_MeraThermocoupleDir := '';
  g_MeraThermocoupleFolderKey := '';
  g_MeraThermocoupleLastMeraPath := #0;
end;

procedure RecorderMeraGetThermocoupleCache(out ADiskDir, AFolderKey: string);
begin
  ADiskDir := g_MeraThermocoupleDir;
  AFolderKey := g_MeraThermocoupleFolderKey;
end;

procedure RecorderMeraSetThermocoupleCache(const ADiskDir, AFolderKey: string);
begin
  g_MeraThermocoupleDir := ADiskDir;
  g_MeraThermocoupleFolderKey := AFolderKey;
end;

function RecorderMeraThermocoupleLastMeraPath: string;
begin
  Result := g_MeraThermocoupleLastMeraPath;
end;

procedure RecorderMeraSetThermocoupleLastMeraPath(const APath: string);
begin
  g_MeraThermocoupleLastMeraPath := APath;
end;

function RecorderMeraCalibrRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'Calibr' + PathDelim;
  ForceDirectories(Result);
end;

end.
