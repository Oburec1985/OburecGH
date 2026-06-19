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
function RecorderMeraCalibrRootDir: string;

implementation

{$IFDEF MSWINDOWS}
uses
  Windows;
{$ENDIF}

function RecorderMeraFilesPath: string;
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
  ForceDirectories(Result);
end;

function RecorderMeraCalibrRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'Calibr' + PathDelim;
  ForceDirectories(Result);
end;

end.
