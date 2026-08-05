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
function RecorderMeraCalibrRootDir: string;
procedure RecorderMeraResetThermocoupleCache;
procedure RecorderMeraGetThermocoupleCache(out ADiskDir, AFolderKey: string);
procedure RecorderMeraSetThermocoupleCache(const ADiskDir, AFolderKey: string);
function RecorderMeraThermocoupleLastMeraPath: string;
procedure RecorderMeraSetThermocoupleLastMeraPath(const APath: string);

implementation

uses
  {$IFDEF MSWINDOWS}
  Windows
  {$ENDIF}
  ;

var
  g_MeraFilesPath: string;
  g_MeraThermocoupleDir: string;
  g_MeraThermocoupleFolderKey: string;
  g_MeraThermocoupleLastMeraPath: string;

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

function RecorderMeraFilesPath: string;
begin
  if g_MeraFilesPath <> '' then
    Result := g_MeraFilesPath
  else
    Result := DefaultRecorderMeraFilesPath;
end;

procedure SetRecorderMeraFilesPath(const APath: string);
begin
  g_MeraFilesPath := ExcludeTrailingPathDelimiter(Trim(APath));
  RecorderMeraResetThermocoupleCache;
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
