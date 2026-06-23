unit uRecorderMeraSdbThermocouples;

{
  GOST thermocouple scales from Mera SDB (same tree as original Recorder).

  Original MIC140pp loads IDC_COMBO_TARE from IMeSDB folder
  "ГОСТ\\Термопары" under DEFAULT_SDB_PATH (Mera Files\\sdb\\sdb.xml).
  Each scale is a pair of .xml metadata + .csv points (mV -> degC).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags;

const
  CMeraSdbThermocoupleFolder = 'ГОСТ\Термопары';

function RecorderMeraSdbRootDir: string;
function RecorderMeraThermocoupleDir: string;
function RecorderMeraThermocoupleFolderKey: string;
procedure RecorderMeraResetThermocoupleCache;
procedure RecorderMeraListThermocoupleScales(AItems: TStrings);
function RecorderMeraThermocoupleRelativePath(const ADisplayName: string): string;
function RecorderMeraResolveThermocoupleScaleKey(const ARelativeScalePath,
  ADisplayName: string): string;
function RecorderMeraThermocoupleCsvPath(const ARelativeScalePath: string): string;
function RecorderMeraThermocoupleDisplayName(const ARelativeScalePath: string): string;
function RecorderMeraThermocoupleDstRange(const ARelativeScalePath: string;
  out AMinC, AMaxC: Double): Boolean;
function RecorderMeraLoadThermocoupleCalibration(const ARelativeScalePath,
  ADisplayName: string; ACalibration: TRecorderCalibration): Boolean;

implementation

uses
  FileUtil, LazFileUtils, StrUtils, uRecorderMeraPaths, uRecorderSdbStore,
  uRecorderSdbTypes;

var
  g_MeraThermocoupleDir: string;
  g_MeraThermocoupleFolderKey: string;
  g_LastMeraFilesPath: string;

function RecorderMeraSdbRootDir: string;
begin
  Result := RecorderSdbRootDir;
end;

procedure RecorderMeraResetThermocoupleCache;
begin
  g_MeraThermocoupleDir := '';
  g_MeraThermocoupleFolderKey := '';
  g_LastMeraFilesPath := #0;
end;

function RecorderMeraCountScalePairs(const ADiskDir: string): Integer;
var
  lBasenames: TStringList;
  lBase: string;
  lDirName: string;
  lDiskDir: string;
  SR: TSearchRec;
begin
  Result := 0;
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  if not DirectoryExists(lDiskDir) then
    Exit;
  lDirName := ExtractFileName(ExcludeTrailingPathDelimiter(lDiskDir));
  lBasenames := TStringList.Create;
  try
    lBasenames.Sorted := True;
    lBasenames.Duplicates := dupIgnore;
    if FindFirst(lDiskDir + '*', faAnyFile, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory) <> 0 then
          Continue;
        if not SameText(ExtractFileExt(SR.Name), '.xml') then
          Continue;
        lBase := ChangeFileExt(SR.Name, '');
        if SameText(lBase, lDirName) then
          Continue;
        if FileExistsUTF8(lDiskDir + lBase + '.csv') or
          FileExistsUTF8(lDiskDir + lBase + '.CSV') then
          lBasenames.Add(lBase);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
    Result := lBasenames.Count;
  finally
    lBasenames.Free;
  end;
end;

function RecorderMeraTryThermocoupleDir(const ADiskDir, AFolderKey: string): Boolean;
begin
  Result := RecorderMeraCountScalePairs(ADiskDir) > 0;
  if Result then
  begin
    g_MeraThermocoupleDir := IncludeTrailingPathDelimiter(ADiskDir);
    g_MeraThermocoupleFolderKey := AFolderKey;
  end;
end;

function RecorderMeraIsThermocoupleFolderName(const AName: string): Boolean;
begin
  Result := SameText(AName, 'Термопары') or SameText(AName, 'Thermocouples');
end;

function RecorderMeraScanThermocoupleTree(const ADiskDir, AFolderKey: string;
  ADepth: Integer): Boolean;
var
  SR: TSearchRec;
  lChildDir: string;
  lChildKey: string;
  lDiskDir: string;
begin
  if ADepth < 0 then
    Exit(False);
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  if not DirectoryExists(lDiskDir) then
    Exit(False);
  if RecorderMeraIsThermocoupleFolderName(ExtractFileName(
    ExcludeTrailingPathDelimiter(lDiskDir))) and
    RecorderMeraTryThermocoupleDir(lDiskDir, AFolderKey) then
    Exit(True);
  if FindFirst(lDiskDir + '*', faDirectory, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory) = 0 then
        Continue;
      if SameText(SR.Name, '.') or SameText(SR.Name, '..') then
        Continue;
      lChildDir := lDiskDir + SR.Name;
      if AFolderKey <> '' then
        lChildKey := AFolderKey + '\' + SR.Name
      else
        lChildKey := SR.Name;
      if RecorderMeraScanThermocoupleTree(lChildDir, lChildKey, ADepth - 1) then
        Exit(True);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
  Result := False;
end;

function RecorderMeraResolveThermocoupleLocation: Boolean;
var
  SR: TSearchRec;
  SR2: TSearchRec;
  lGostDir: string;
  lGostKey: string;
  lRoot: string;
  lTcDir: string;
  lTcKey: string;
  lCurrentMeraPath: string;
begin
  lCurrentMeraPath := RecorderMeraFilesPath;
  if lCurrentMeraPath <> g_LastMeraFilesPath then
  begin
    g_LastMeraFilesPath := lCurrentMeraPath;
    RecorderMeraResetThermocoupleCache;
  end;

  if (g_MeraThermocoupleDir <> '') and DirectoryExists(g_MeraThermocoupleDir) and
    (RecorderMeraCountScalePairs(g_MeraThermocoupleDir) > 0) then
    Exit(True);

  RecorderMeraResetThermocoupleCache;

  lRoot := IncludeTrailingPathDelimiter(ExpandFileName(RecorderSdbRootDir));
  if not DirectoryExists(lRoot) then
    Exit(False);

  if RecorderMeraTryThermocoupleDir(lRoot +
    StringReplace(CMeraSdbThermocoupleFolder, '\', PathDelim, [rfReplaceAll]),
    CMeraSdbThermocoupleFolder) then
    Exit(True);

  if FindFirst(lRoot + '*', faDirectory, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory) = 0 then
        Continue;
      if SameText(SR.Name, '.') or SameText(SR.Name, '..') then
        Continue;
      lGostDir := lRoot + SR.Name + PathDelim;
      lGostKey := SR.Name;
      if RecorderMeraTryThermocoupleDir(lGostDir, lGostKey) then
        Exit(True);
      if FindFirst(lGostDir + '*', faDirectory, SR2) = 0 then
      try
        repeat
          if (SR2.Attr and faDirectory) = 0 then
            Continue;
          if SameText(SR2.Name, '.') or SameText(SR2.Name, '..') then
            Continue;
          lTcDir := lGostDir + SR2.Name + PathDelim;
          lTcKey := lGostKey + '\' + SR2.Name;
          if RecorderMeraTryThermocoupleDir(lTcDir, lTcKey) then
            Exit(True);
        until FindNext(SR2) <> 0;
      finally
        FindClose(SR2);
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;

  Result := RecorderMeraScanThermocoupleTree(lRoot, '', 6);
end;

function RecorderMeraThermocoupleDir: string;
begin
  if not RecorderMeraResolveThermocoupleLocation then
    Result := IncludeTrailingPathDelimiter(RecorderMeraSdbRootDir) +
      StringReplace(CMeraSdbThermocoupleFolder, '\', PathDelim, [rfReplaceAll])
  else
    Result := g_MeraThermocoupleDir;
end;

function RecorderMeraThermocoupleFolderKey: string;
begin
  if not RecorderMeraResolveThermocoupleLocation then
    Result := CMeraSdbThermocoupleFolder
  else
    Result := g_MeraThermocoupleFolderKey;
end;

function RecorderMeraThermocoupleCsvPath(const ARelativeScalePath: string): string;
var
  lDiskPath: string;
  lKey: string;
begin
  lKey := Trim(ARelativeScalePath);
  if lKey = '' then
    Exit('');
  if (Pos('\', lKey) = 0) and (Pos(PathDelim, lKey) = 0) then
  begin
    if RecorderMeraResolveThermocoupleLocation then
    begin
      lDiskPath := g_MeraThermocoupleDir + lKey + '.csv';
      if FileExistsUTF8(lDiskPath) then
        Exit(lDiskPath);
      lDiskPath := g_MeraThermocoupleDir + lKey + '.CSV';
      if FileExistsUTF8(lDiskPath) then
        Exit(lDiskPath);
    end;
    lKey := RecorderMeraThermocoupleRelativePath(lKey);
  end;
  Result := RecorderSdbScaleCsvPath(lKey);
end;

function RecorderMeraThermocoupleDisplayName(const ARelativeScalePath: string): string;
var
  lExt: string;
begin
  Result := ExtractFileName(StringReplace(ARelativeScalePath, '\', PathDelim,
    [rfReplaceAll]));
  lExt := LowerCase(ExtractFileExt(Result));
  if (lExt = '.xml') or (lExt = '.csv') then
    Result := ChangeFileExt(Result, '');
end;

function RecorderMeraThermocoupleDstRange(const ARelativeScalePath: string;
  out AMinC, AMaxC: Double): Boolean;
var
  lInfo: TSdbScaleInfo;
  lKey: string;
begin
  Result := False;
  AMinC := 0;
  AMaxC := 0;
  lKey := Trim(ARelativeScalePath);
  if (Pos('\', lKey) = 0) and (Pos(PathDelim, lKey) = 0) then
    lKey := RecorderMeraThermocoupleRelativePath(lKey);
  if not RecorderSdbTryLoadScale(lKey, lInfo) then
    Exit;
  AMinC := lInfo.DstFrom;
  AMaxC := lInfo.DstTo;
  Result := AMinC <> AMaxC;
end;

procedure RecorderMeraCollectScalesInDir(const ADiskDir: string; AItems: TStrings);
var
  lBase: string;
  lBasenames: TStringList;
  lDirName: string;
  lDiskDir: string;
  lI: Integer;
  SR: TSearchRec;
begin
  if AItems = nil then
    Exit;
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  if not DirectoryExists(lDiskDir) then
    Exit;
  lDirName := ExtractFileName(ExcludeTrailingPathDelimiter(lDiskDir));
  lBasenames := TStringList.Create;
  try
    lBasenames.Sorted := True;
    lBasenames.Duplicates := dupIgnore;
    if FindFirst(lDiskDir + '*', faAnyFile, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory) <> 0 then
          Continue;
        if not SameText(ExtractFileExt(SR.Name), '.xml') then
          Continue;
        lBase := ChangeFileExt(SR.Name, '');
        if SameText(lBase, lDirName) then
          Continue;
        if FileExistsUTF8(lDiskDir + lBase + '.csv') or
          FileExistsUTF8(lDiskDir + lBase + '.CSV') then
          lBasenames.Add(lBase);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
    for lI := 0 to lBasenames.Count - 1 do
      if AItems.IndexOf(lBasenames[lI]) < 0 then
        AItems.Add(lBasenames[lI]);
  finally
    lBasenames.Free;
  end;
end;

procedure RecorderMeraListThermocoupleScales(AItems: TStrings);
var
  lFiles: TStringList;
  lI: Integer;
  lName: string;
begin
  if AItems = nil then
    Exit;
  lFiles := TStringList.Create;
  try
    if RecorderMeraResolveThermocoupleLocation then
      RecorderMeraCollectScalesInDir(g_MeraThermocoupleDir, lFiles);
    if lFiles.Count = 0 then
      RecorderSdbListScaleKeys(RecorderMeraThermocoupleFolderKey, lFiles);
    for lI := 0 to lFiles.Count - 1 do
    begin
      lName := ChangeFileExt(ExtractFileName(lFiles[lI]), '');
      if lName = '' then
        Continue;
      if SameText(lName, 'Термопары') or SameText(lName, 'Thermocouples') then
        Continue;
      if AItems.IndexOf(lName) >= 0 then
        Continue;
      AItems.Add(lName);
    end;
  finally
    lFiles.Free;
  end;
end;

function RecorderMeraThermocoupleRelativePath(const ADisplayName: string): string;
begin
  Result := RecorderMeraThermocoupleFolderKey + PathDelim + ADisplayName;
end;

function RecorderMeraThermocoupleScaleKeyExists(const AKey: string): Boolean;
var
  lInfo: TSdbScaleInfo;
begin
  Result := (Trim(AKey) <> '') and RecorderSdbTryLoadScale(AKey, lInfo);
end;

function RecorderMeraFindThermocoupleScaleByPrefix(const AName: string): string;
var
  lBestBase: string;
  lBestKey: string;
  lBestLen: Integer;
  lDiskDir: string;
  lName: string;
  SR: TSearchRec;
begin
  Result := '';
  lName := Trim(AName);
  if lName = '' then
    Exit;
  if not RecorderMeraResolveThermocoupleLocation then
    Exit;
  lDiskDir := IncludeTrailingPathDelimiter(g_MeraThermocoupleDir);
  lBestKey := '';
  lBestLen := -1;
  if FindFirst(lDiskDir + '*.xml', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory) <> 0 then
        Continue;
      lBestBase := ChangeFileExt(SR.Name, '');
      if not (FileExistsUTF8(lDiskDir + lBestBase + '.csv') or
        FileExistsUTF8(lDiskDir + lBestBase + '.CSV')) then
        Continue;
      if SameText(lBestBase, lName) then
        Exit(RecorderMeraThermocoupleRelativePath(lBestBase));
      if StartsText(lBestBase, lName) or StartsText(lName, lBestBase) then
      begin
        if Length(lBestBase) > lBestLen then
        begin
          lBestLen := Length(lBestBase);
          lBestKey := RecorderMeraThermocoupleRelativePath(lBestBase);
        end;
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
  Result := lBestKey;
end;

function RecorderMeraResolveThermocoupleScaleKey(const ARelativeScalePath,
  ADisplayName: string): string;
var
  lCandidates: array[0..2] of string;
  lI: Integer;
  lName: string;
  lPath: string;
begin
  lName := Trim(ADisplayName);
  lPath := Trim(ARelativeScalePath);
  lCandidates[0] := lPath;
  if lName <> '' then
    lCandidates[1] := RecorderMeraThermocoupleRelativePath(lName)
  else
    lCandidates[1] := '';
  lCandidates[2] := '';
  for lI := Low(lCandidates) to High(lCandidates) do
    if RecorderMeraThermocoupleScaleKeyExists(lCandidates[lI]) then
      Exit(lCandidates[lI]);
  if lName <> '' then
  begin
    Result := RecorderMeraFindThermocoupleScaleByPrefix(lName);
    if Result <> '' then
      Exit;
  end;
  if lPath <> '' then
    Exit(lPath);
  if lName <> '' then
    Result := RecorderMeraThermocoupleRelativePath(lName);
end;

function RecorderMeraLoadThermocoupleCalibration(const ARelativeScalePath,
  ADisplayName: string; ACalibration: TRecorderCalibration): Boolean;
var
  lCsvPath: string;
  lKey: string;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  lKey := RecorderMeraResolveThermocoupleScaleKey(ARelativeScalePath, ADisplayName);
  if lKey = '' then
    Exit;
  if RecorderSdbLoadScaleCalibration(lKey, ACalibration) then
    Exit(True);
  lCsvPath := RecorderMeraThermocoupleCsvPath(lKey);
  Result := RecorderSdbLoadScaleCalibrationFromCsv(lCsvPath, lKey, ACalibration);
end;

end.
