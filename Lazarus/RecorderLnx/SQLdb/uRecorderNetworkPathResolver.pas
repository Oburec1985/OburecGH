unit uRecorderNetworkPathResolver;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function ResolveRecorderNetworkPath(const AStoredPath: string): string;

implementation

uses
  Classes, SysUtils, IniFiles;

const
  CRegistryDir = '/etc/recorderlnx/network-shares.d';

function NativePath(const AValue: string): string;
begin
  Result := StringReplace(AValue, '/', DirectorySeparator, [rfReplaceAll]);
  Result := StringReplace(Result, '\', DirectorySeparator, [rfReplaceAll]);
end;

function DecodeSimpleUri(const AValue: string): string;
begin
  Result := StringReplace(AValue, '%20', ' ', [rfReplaceAll, rfIgnoreCase]);
end;

function UsmlSuffix(const APath: string): string;
var
  lPath, lLower: string;
  lAt: SizeInt;
begin
  lPath := StringReplace(APath, '\', '/', [rfReplaceAll]);
  lLower := LowerCase(lPath);
  lAt := Pos('/usml/', lLower);
  if lAt = 0 then
  begin
    if Copy(lLower, 1, 5) = 'usml/' then lAt := 1 else Exit('');
  end
  else
    Inc(lAt);
  Result := Copy(lPath, lAt, MaxInt);
end;

function MeasurementTail(const APath: string): string;
var
  lPath, lDir, lParentName, lFileName: string;
begin
  lPath := NativePath(APath);
  lFileName := ExtractFileName(lPath);
  lDir := ExtractFileDir(lPath);
  lParentName := ExtractFileName(ExcludeTrailingPathDelimiter(lDir));
  if (lParentName = '') or (lFileName = '') then Exit('');
  Result := lParentName + DirectorySeparator + lFileName;
end;

function CandidateFile(const ARoot, ARelative: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ExcludeTrailingPathDelimiter(ARoot)) +
    NativePath(ARelative);
  if not FileExists(Result) then Result := '';
end;

function ResolveFromRegistry(const AHost, AShare, ARelative: string): string;
var
  lSearch: TSearchRec;
  lIni: TIniFile;
  lHost, lShare, lMount, lCandidate: string;
begin
  Result := '';
  if FindFirst(IncludeTrailingPathDelimiter(CRegistryDir) + '*.ini', faAnyFile,
    lSearch) <> 0 then Exit;
  try
    repeat
      lIni := TIniFile.Create(IncludeTrailingPathDelimiter(CRegistryDir) +
        lSearch.Name);
      try
        lHost := Trim(lIni.ReadString('Share', 'Host', ''));
        lShare := Trim(lIni.ReadString('Share', 'Name', ''));
        lMount := Trim(lIni.ReadString('Share', 'MountPoint', ''));
        if (lMount <> '') and
          ((AHost = '') or SameText(AHost, lHost)) and
          ((AShare = '') or SameText(AShare, lShare)) then
        begin
          lCandidate := CandidateFile(lMount, ARelative);
          if lCandidate <> '' then Exit(lCandidate);
        end;
      finally
        lIni.Free;
      end;
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

function ResolveSmbUri(const AUri: string): string;
var
  lValue, lHost, lShare, lRelative: string;
  lAt: SizeInt;
begin
  Result := '';
  lValue := DecodeSimpleUri(Copy(AUri, 7, MaxInt));
  lAt := Pos('/', lValue);
  if lAt = 0 then Exit;
  lHost := Copy(lValue, 1, lAt - 1);
  Delete(lValue, 1, lAt);
  lAt := Pos('/', lValue);
  if lAt = 0 then
  begin
    lShare := lValue;
    lRelative := '';
  end
  else
  begin
    lShare := Copy(lValue, 1, lAt - 1);
    lRelative := Copy(lValue, lAt + 1, MaxInt);
  end;
  {$ifdef windows}
  Result := '\\' + lHost + '\' + lShare;
  if lRelative <> '' then
    Result := IncludeTrailingPathDelimiter(Result) + NativePath(lRelative);
  if not FileExists(Result) then Result := '';
  {$else}
  Result := ResolveFromRegistry(lHost, lShare, lRelative);
  {$endif}
end;

function ResolveRecorderNetworkPath(const AStoredPath: string): string;
var
  lPath, lSuffix: string;
begin
  lPath := Trim(AStoredPath);
  Result := lPath;
  if (lPath = '') or FileExists(lPath) then Exit;
  if CompareText(Copy(lPath, 1, 6), 'smb://') = 0 then
  begin
    Result := ResolveSmbUri(lPath);
    if Result <> '' then Exit;
  end;
  lSuffix := UsmlSuffix(lPath);
  if lSuffix <> '' then
  begin
    Result := ResolveFromRegistry('', '', lSuffix);
    if Result <> '' then Exit;
  end;
  lSuffix := MeasurementTail(lPath);
  if lSuffix <> '' then
  begin
    Result := ResolveFromRegistry('', '', lSuffix);
    if Result <> '' then Exit;
  end;
  Result := lPath;
end;

end.
