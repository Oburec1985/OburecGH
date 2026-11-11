unit uRecorderMeraPackageManifest;

{ Completed recording metadata is measured on its owning Recorder, after the
  writer closes. Coordinator validates this manifest; it never stats remote
  SMB URIs. No file content, connection, or acquisition operation belongs here. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, fpjson;

type
  TRecorderMeraManifestFile = record
    RelativeName: string;
    Size: Int64;
  end;
  TRecorderMeraPackageManifest = record
    Complete: Boolean;
    EntryRelativeName: string;
    Files: array of TRecorderMeraManifestFile;
    ErrorText: string;
  end;

function RecorderBuildMeraManifest(const ADirectory, AEntryFile: string): TJSONObject;
function RecorderReadMeraManifest(AData: TJSONData): TRecorderMeraPackageManifest;

implementation

function SafeRelativeName(const AName: string): Boolean;
var
  lPart: string;
  I, lStart: Integer;
begin
  Result := False;
  if (AName = '') or (AName[1] = '/') or (Pos('\', AName) > 0) or
    (Pos(':', AName) > 0) or (Pos(#0, AName) > 0) then Exit;
  lStart := 1;
  for I := 1 to Length(AName) + 1 do
    if (I > Length(AName)) or (AName[I] = '/') then
    begin
      lPart := Copy(AName, lStart, I - lStart);
      if (lPart = '') or (lPart = '.') or (lPart = '..') then Exit;
      lStart := I + 1;
    end
    else if Ord(AName[I]) < 32 then Exit;
  Result := True;
end;

function RecorderReadMeraManifest(AData: TJSONData): TRecorderMeraPackageManifest;
var
  lRoot, lFile: TJSONObject;
  lFiles: TJSONArray;
  lNames: TStringList;
  I: Integer;
  lHasEntry: Boolean;
  lTotal: Int64;
begin
  Result := Default(TRecorderMeraPackageManifest);
  try
  if AData = nil then Exit;
  Result.ErrorText := 'Invalid recording package manifest';
  if not (AData is TJSONObject) then Exit;
  lRoot := TJSONObject(AData);
  if not lRoot.Get('complete', False) then
  begin
    Result.ErrorText := lRoot.Get('error', 'Package manifest is incomplete');
    Exit;
  end;
  Result.EntryRelativeName := lRoot.Get('entry', '');
  if not SafeRelativeName(Result.EntryRelativeName) or
    (Pos('/', Result.EntryRelativeName) > 0) or
    not SameText(ExtractFileExt(Result.EntryRelativeName), '.mera') then Exit;
  if not (lRoot.Find('files') is TJSONArray) then Exit;
  lFiles := TJSONArray(lRoot.Find('files'));
  if (lFiles.Count = 0) or (lFiles.Count > 100000) then Exit;
  lNames := TStringList.Create;
  try
    lNames.CaseSensitive := True;
    lNames.Sorted := True;
    lHasEntry := False;
    lTotal := 0;
    SetLength(Result.Files, lFiles.Count);
    for I := 0 to lFiles.Count - 1 do
    begin
      if not (lFiles[I] is TJSONObject) then Exit;
      lFile := TJSONObject(lFiles[I]);
      Result.Files[I].RelativeName := lFile.Get('relative_name', '');
      if not SafeRelativeName(Result.Files[I].RelativeName) or
        (lNames.IndexOf(Result.Files[I].RelativeName) >= 0) then Exit;
      lNames.Add(Result.Files[I].RelativeName);
      if (lFile.Find('size') = nil) or (lFile.Find('size').JSONType <> jtNumber) then Exit;
      if not TryStrToInt64(lFile.Find('size').AsJSON, Result.Files[I].Size) or
        (Result.Files[I].Size < 0) or
        (Result.Files[I].Size > High(Int64) - lTotal) then Exit;
      Inc(lTotal, Result.Files[I].Size);
      if Result.Files[I].RelativeName = Result.EntryRelativeName then
      begin
        if Result.Files[I].Size = 0 then Exit;
        lHasEntry := True;
      end;
    end;
    if not lHasEntry then Exit;
    Result.Complete := True;
    Result.ErrorText := '';
  finally
    lNames.Free;
  end;
  except
    on E: Exception do
    begin
      Result.Complete := False;
      Result.ErrorText := 'Invalid recording package manifest: ' + E.Message;
    end;
  end;
end;

function RecorderBuildMeraManifest(const ADirectory, AEntryFile: string): TJSONObject;
var
  lRoot, lEntry: string;
  lNames: TStringList;
  lFiles: TJSONArray;
  lFile: TJSONObject;
  lCheck: TRecorderMeraPackageManifest;

  procedure Scan(const ARelative: string);
  var
    lInfo: TSearchRec;
    lName, lRelative, lPath: string;
    lCode: Integer;
  begin
    lCode := FindFirst(lRoot + StringReplace(ARelative, '/', DirectorySeparator,
      [rfReplaceAll]) + '*', faAnyFile, lInfo);
    if lCode <> 0 then
      raise Exception.Create('Cannot enumerate recording package directory: ' + ARelative);
    try
      repeat
        lName := lInfo.Name;
        if (lName = '.') or (lName = '..') then Continue;
        lRelative := ARelative + lName;
        if not SafeRelativeName(lRelative) then
          raise Exception.Create('Unsafe recording package filename');
        if (lInfo.Attr and faSymLink) <> 0 then
          raise Exception.Create('Recording package contains a symbolic link');
        if (lInfo.Attr and faDirectory) <> 0 then Scan(lRelative + '/')
        else
        begin
          lPath := IntToStr(lInfo.Size);
          lNames.Add(lRelative + #9 + lPath);
          if lNames.Count > 100000 then raise Exception.Create('Recording package manifest is too large');
        end;
      until FindNext(lInfo) <> 0;
    finally
      FindClose(lInfo);
    end;
  end;

var
  I, lTab: Integer;
begin
  Result := TJSONObject.Create;
  lNames := TStringList.Create;
  try
    try
      lRoot := IncludeTrailingPathDelimiter(ExpandFileName(ADirectory));
      lEntry := ExpandFileName(AEntryFile);
      if (Trim(ADirectory) = '') or not DirectoryExists(lRoot) or
        (ExtractFileDir(lEntry) <> ExcludeTrailingPathDelimiter(lRoot)) or
        not FileExists(lEntry) then
        raise Exception.Create('Recording package entry is not available in its source directory');
      lNames.CaseSensitive := True;
      lNames.Sorted := True;
      Scan('');
      Result.Add('complete', True);
      Result.Add('entry', ExtractFileName(lEntry));
      lFiles := TJSONArray.Create;
      Result.Add('files', lFiles);
      for I := 0 to lNames.Count - 1 do
      begin
        lTab := Pos(#9, lNames[I]);
        lFile := TJSONObject.Create;
        lFile.Add('relative_name', Copy(lNames[I], 1, lTab - 1));
        lFile.Add('size', StrToInt64(Copy(lNames[I], lTab + 1, MaxInt)));
        lFiles.Add(lFile);
      end;
      lCheck := RecorderReadMeraManifest(Result);
      if not lCheck.Complete then raise Exception.Create(lCheck.ErrorText);
    except
      on E: Exception do
      begin
        Result.Clear;
        Result.Add('complete', False);
        Result.Add('error', E.Message);
      end;
    end;
  finally
    lNames.Free;
  end;
end;

end.
