unit uRecorderNetworkPathResolver;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function ResolveRecorderNetworkPath(const AStoredPath: string;
  const ASourceHost: string = '';
  const ARegistryDirectory: string = '/etc/recorderlnx/network-shares.d'): string;

implementation

uses
  Classes, SysUtils, IniFiles{$ifdef unix}, BaseUnix{$endif};

function LocalHostName: string;
{$ifdef unix}
var
  lInfo: utsname;
{$endif}
begin
  {$ifdef unix}
  if fpUname(lInfo) = 0 then Exit(StrPas(@lInfo.nodename[0]));
  {$endif}
  Result := GetEnvironmentVariable('COMPUTERNAME');
  if Result = '' then Result := GetEnvironmentVariable('HOSTNAME');
end;

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
var
  lRoot: string;
begin
  lRoot := IncludeTrailingPathDelimiter(ExpandFileName(ARoot));
  Result := ExpandFileName(lRoot + NativePath(ARelative));
  if CompareText(Copy(Result, 1, Length(lRoot)), lRoot) <> 0 then Exit('');
  if not FileExists(Result) then Result := '';
end;

function ResolveFromRegistry(const AHost, AShare, ARelative,
  ARegistryDirectory: string): string;
var
  lSearch: TSearchRec;
  lIni: TIniFile;
  lHost, lHostName, lLocalName, lShare, lMount, lCandidate, lMountRoot: string;
begin
  Result := '';
  { A filename is not a machine identity. Never search all shares for a frame
    number: every recorder can have its own 0001/0001.mera. }
  if Trim(AHost) = '' then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(ARegistryDirectory) + '*.ini', faAnyFile,
    lSearch) <> 0 then Exit;
  try
    repeat
      lIni := TIniFile.Create(IncludeTrailingPathDelimiter(ARegistryDirectory) +
        lSearch.Name);
      try
        lHost := Trim(lIni.ReadString('Share', 'Host', ''));
        lHostName := Trim(lIni.ReadString('Share', 'HostName', ''));
        lLocalName := Trim(lIni.ReadString('Share', 'LocalName', ''));
        lShare := Trim(lIni.ReadString('Share', 'Name', ''));
        lMount := Trim(lIni.ReadString('Share', 'MountPoint', ''));
        if (lMount <> '') and
          (SameText(AHost, lHost) or
           ((lHostName <> '') and SameText(AHost, lHostName)) or
           ((lShare <> '') and SameText(lLocalName, AHost + '-' + lShare))) and
          ((AShare = '') or SameText(AShare, lShare)) then
        begin
          lMountRoot := IncludeTrailingPathDelimiter(ExpandFileName(lMount));
          lCandidate := ExpandFileName(NativePath(ARelative));
          if (CompareText(Copy(lCandidate, 1, Length(lMountRoot)), lMountRoot) = 0)
            and FileExists(lCandidate) then Exit(lCandidate);
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

function ResolveSmbUri(const AUri, ARegistryDirectory: string): string;
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
  Result := ResolveFromRegistry(lHost, lShare, lRelative, ARegistryDirectory);
  {$endif}
end;

function ResolveRecorderNetworkPath(const AStoredPath, ASourceHost,
  ARegistryDirectory: string): string;
var
  lPath, lSuffix: string;
begin
  lPath := Trim(AStoredPath);
  Result := lPath;
  if lPath = '' then Exit;
  if CompareText(Copy(lPath, 1, 6), 'smb://') = 0 then
  begin
    Result := ResolveSmbUri(lPath, ARegistryDirectory);
    { A network URI identifies a specific host and share. Never search other
      mounts by filename: two recorders commonly use the same frame number. }
    if Result = '' then Result := lPath;
    Exit;
  end;
  if FileExists(lPath) then
  begin
    if (Trim(ASourceHost) = '') or SameText(ASourceHost, LocalHostName) then Exit;
    Result := ResolveFromRegistry(ASourceHost, '', lPath, ARegistryDirectory);
    if Result <> '' then Exit;
  end;
  if Trim(ASourceHost) = '' then Exit;
  lSuffix := UsmlSuffix(lPath);
  if lSuffix <> '' then
  begin
    Result := ResolveFromRegistry(ASourceHost, '', lSuffix, ARegistryDirectory);
    if Result <> '' then Exit;
  end;
  lSuffix := MeasurementTail(lPath);
  if lSuffix <> '' then
  begin
    Result := ResolveFromRegistry(ASourceHost, '', lSuffix, ARegistryDirectory);
    if Result <> '' then Exit;
  end;
  if FileExists(lPath) and (Trim(ASourceHost) <> '') and
    not SameText(ASourceHost, LocalHostName) then Result := ''
  else Result := lPath;
end;

end.
