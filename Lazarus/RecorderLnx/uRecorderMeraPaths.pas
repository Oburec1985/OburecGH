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
function RecorderPluginsPath: string;
function RecorderBiosPath: string;
function RecorderSysComPath: string;
function RecorderMeraCalibrRootDir: string;
procedure RecorderMeraResetThermocoupleCache;
procedure RecorderMeraGetThermocoupleCache(out ADiskDir, AFolderKey: string);
procedure RecorderMeraSetThermocoupleCache(const ADiskDir, AFolderKey: string);
function RecorderMeraThermocoupleLastMeraPath: string;
procedure RecorderMeraSetThermocoupleLastMeraPath(const APath: string);

implementation

uses
  IniFiles
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

var
  g_SystemPathsLoaded: Boolean;
  g_MeraFilesPath: string;
  g_ConfigPath: string;
  g_PluginsPath: string;
  g_BiosPath: string;
  g_SysComPath: string;
  g_MeraThermocoupleDir: string;
  g_MeraThermocoupleFolderKey: string;
  g_MeraThermocoupleLastMeraPath: string;

function RecorderSystemPathsFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExpandFileName(
    ExtractFilePath(ParamStr(0)))) + 'RecorderLnx.paths.ini';
end;

function ResolveSystemPath(const AValue, ADefaultRelativePath: string): string;
var
  lValue: string;
begin
  lValue := Trim(AValue);
  if lValue = '' then
    lValue := ADefaultRelativePath;
  if (lValue <> '') and not ((Length(lValue) >= 2) and (lValue[2] = ':')) and
    not ((Length(lValue) >= 2) and (lValue[1] = '\') and
      (lValue[2] = '\')) and (lValue[1] <> PathDelim) then
    lValue := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      lValue;
  Result := ExcludeTrailingPathDelimiter(ExpandFileName(lValue));
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
    g_MeraFilesPath := ResolveSystemPath(
      lIni.ReadString('Paths', 'MeraFiles', g_MeraFilesPath), '');
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
  g_MeraFilesPath := ExcludeTrailingPathDelimiter(Trim(APath));
  RecorderMeraResetThermocoupleCache;
end;

function RecorderConfigPath: string;
begin
  EnsureRecorderSystemPathsLoaded;
  Result := g_ConfigPath;
end;

function RecorderPluginsPath: string;
begin
  EnsureRecorderSystemPathsLoaded;
  Result := g_PluginsPath;
end;

function RecorderBiosPath: string;
begin
  EnsureRecorderSystemPathsLoaded;
  Result := g_BiosPath;
end;

function RecorderSysComPath: string;
begin
  EnsureRecorderSystemPathsLoaded;
  Result := g_SysComPath;
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
