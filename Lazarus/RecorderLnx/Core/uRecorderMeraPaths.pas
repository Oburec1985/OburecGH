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

implementation

{$IFDEF MSWINDOWS}
uses
  Windows;
{$ENDIF}

var
  g_MeraFilesPath: string;

function DefaultRecorderMeraFilesPath: string;
{$IFDEF MSWINDOWS}
var
  lSystemDir: array[0..MAX_PATH] of Char;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  FillChar(lSystemDir, SizeOf(lSystemDir), 0);
  if GetSystemDirectory(lSystemDir, MAX_PATH) = 0 then
    Result := 'C:' + PathDelim + 'Mera Files'
  else
  begin
    lSystemDir[2] := #0;
    Result := IncludeTrailingPathDelimiter(string(lSystemDir)) + 'Mera Files';
  end;
{$ELSE}
  if GetEnvironmentVariable('MERA_FILES') <> '' then
    Result := GetEnvironmentVariable('MERA_FILES')
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
end;

function RecorderMeraCalibrRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'Calibr' + PathDelim;
  ForceDirectories(Result);
end;

end.
