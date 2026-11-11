program RecorderNetworkPathIsolationTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Classes, SysUtils, IniFiles, uRecorderNetworkPathResolver;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure WriteFile(const AFileName, AText: string);
var
  lText: TStringList;
begin
  ForceDirectories(ExtractFileDir(AFileName));
  lText := TStringList.Create;
  try
    lText.Text := AText;
    lText.SaveToFile(AFileName);
  finally
    lText.Free;
  end;
end;

procedure WriteShare(const ARegistry, AName, AHost, AMount: string);
var
  lIni: TIniFile;
begin
  lIni := TIniFile.Create(IncludeTrailingPathDelimiter(ARegistry) + AName + '.ini');
  try
    lIni.WriteString('Share', 'Host', AHost);
    lIni.WriteString('Share', 'Name', 'USML');
    lIni.WriteString('Share', 'LocalName', AName);
    lIni.WriteString('Share', 'MountPoint', AMount);
  finally
    lIni.Free;
  end;
end;

var
  lRoot, lRegistry, lKip1, lKip4, lRelative, lLegacy, lUri, lResolved: string;
  lGuid: TGuid;
begin
  CreateGUID(lGuid);
  lRoot := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderPathIsolation-' + GUIDToString(lGuid);
  lRegistry := IncludeTrailingPathDelimiter(lRoot) + 'registry';
  ForceDirectories(lRegistry);
  lKip1 := IncludeTrailingPathDelimiter(lRoot) + 'KIP-1';
  lKip4 := IncludeTrailingPathDelimiter(lRoot) + 'KIP-4';
  lRelative := '0001' + DirectorySeparator + '0001.mera';
  WriteFile(IncludeTrailingPathDelimiter(lKip4) + lRelative, 'KIP4 data');
  WriteFile(IncludeTrailingPathDelimiter(lKip1) + lRelative, 'KIP1 data');
  WriteShare(lRegistry, 'KIP-4-USML', '192.0.2.4', lKip4);
  WriteShare(lRegistry, 'KIP-1-USML', '192.0.2.1', lKip1);
  try
    lLegacy := '/missing-on-source/USML/0001/0001.mera';
    lResolved := ResolveRecorderNetworkPath(lLegacy, 'KIP-1', lRegistry);
    Check(lResolved = IncludeTrailingPathDelimiter(lKip1) + lRelative,
      'Legacy source-host path must select KIP1, never first matching KIP4');
    Check(ResolveRecorderNetworkPath(lLegacy, '192.0.2.4', lRegistry) =
      IncludeTrailingPathDelimiter(lKip4) + lRelative, 'Source IP lookup failed');
    Check(ResolveRecorderNetworkPath(lLegacy, '', lRegistry) = lLegacy,
      'Unknown host must not guess a recorder from the frame number');
    Check(ResolveRecorderNetworkPath(IncludeTrailingPathDelimiter(lKip4) +
      lRelative, 'KIP-1', lRegistry) = IncludeTrailingPathDelimiter(lKip1) + lRelative,
      'An existing foreign local file must not override the known source host');
    Check(ResolveRecorderNetworkPath(IncludeTrailingPathDelimiter(lKip4) +
      lRelative, 'missing-source', lRegistry) = '',
      'A missing owner must not resolve to another host local file');
    Check(ResolveRecorderNetworkPath(IncludeTrailingPathDelimiter(lKip4) +
      lRelative, '', lRegistry) = IncludeTrailingPathDelimiter(lKip4) + lRelative,
      'An explicitly selected local copy must remain usable');
    lUri := 'smb://missing-host/USML/0001/0001.mera';
    Check(ResolveRecorderNetworkPath(lUri, 'KIP-1', lRegistry) = lUri,
      'An explicit unavailable SMB host must not fall back to another host');
    {$ifdef unix}
    Check(ResolveRecorderNetworkPath('smb://KIP-1/USML/0001/0001.mera', '',
      lRegistry) = IncludeTrailingPathDelimiter(lKip1) + lRelative,
      'SMB hostname alias did not select KIP1');
    Check(ResolveRecorderNetworkPath('smb://192.0.2.4/USML/0001/0001.mera', '',
      lRegistry) = IncludeTrailingPathDelimiter(lKip4) + lRelative,
      'Explicit SMB address did not select KIP4');
    {$endif}
    WriteLn('RESULT RecorderNetworkPathIsolationTest passed');
  finally
    DeleteFile(IncludeTrailingPathDelimiter(lKip1) + lRelative);
    DeleteFile(IncludeTrailingPathDelimiter(lKip4) + lRelative);
    RemoveDir(IncludeTrailingPathDelimiter(lKip1) + '0001');
    RemoveDir(IncludeTrailingPathDelimiter(lKip4) + '0001');
    RemoveDir(lKip1); RemoveDir(lKip4);
    DeleteFile(IncludeTrailingPathDelimiter(lRegistry) + 'KIP-1-USML.ini');
    DeleteFile(IncludeTrailingPathDelimiter(lRegistry) + 'KIP-4-USML.ini');
    RemoveDir(lRegistry); RemoveDir(lRoot);
  end;
end.
