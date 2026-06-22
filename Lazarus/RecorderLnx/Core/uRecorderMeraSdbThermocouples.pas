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
  Classes, SysUtils;

const
  CMeraSdbThermocoupleFolder = 'ГОСТ\Термопары';

function RecorderMeraSdbRootDir: string;
function RecorderMeraThermocoupleDir: string;
procedure RecorderMeraListThermocoupleScales(AItems: TStrings);
function RecorderMeraThermocoupleRelativePath(const ADisplayName: string): string;
function RecorderMeraThermocoupleCsvPath(const ARelativeScalePath: string): string;
function RecorderMeraThermocoupleDisplayName(const ARelativeScalePath: string): string;
function RecorderMeraThermocoupleDstRange(const ARelativeScalePath: string;
  out AMinC, AMaxC: Double): Boolean;

implementation

uses
  uRecorderMeraPaths, uRecorderSdbStore, uRecorderSdbTypes;

function RecorderMeraSdbRootDir: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraFilesPath) + 'sdb' + PathDelim;
end;

function RecorderMeraThermocoupleDir: string;
begin
  Result := IncludeTrailingPathDelimiter(RecorderMeraSdbRootDir) +
    CMeraSdbThermocoupleFolder + PathDelim;
end;

function RecorderMeraThermocoupleCsvPath(const ARelativeScalePath: string): string;
begin
  if Pos('\\', ARelativeScalePath) = 0 then
    Result := RecorderSdbScaleCsvPath(RecorderMeraThermocoupleRelativePath(
      ARelativeScalePath))
  else
    Result := RecorderSdbScaleCsvPath(ARelativeScalePath);
end;

function RecorderMeraThermocoupleDisplayName(const ARelativeScalePath: string): string;
begin
  Result := ExtractFileName(StringReplace(ARelativeScalePath, '\', PathDelim,
    [rfReplaceAll]));
  Result := ChangeFileExt(Result, '');
end;

function RecorderMeraReadXmlProperty(const AFileName, APropertyName: string): string;
var
  lLines: TStringList;
  lMarker: string;
  lPos: Integer;
  I: Integer;
begin
  Result := '';
  if not FileExists(AFileName) then
    Exit;
  lMarker := 'pty n="' + APropertyName + '"';
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(AFileName);
    for I := 0 to lLines.Count - 1 do
    begin
      if Pos(lMarker, lLines[I]) <= 0 then
        Continue;
      if I + 2 >= lLines.Count then
        Break;
      Result := Trim(lLines[I + 2]);
      if (Length(Result) >= 13) and (Copy(Result, 1, 9) = '<![CDATA[') and
        (Copy(Result, Length(Result) - 2, 3) = ']]>') then
        Result := Copy(Result, 10, Length(Result) - 12);
      Break;
    end;
  finally
    lLines.Free;
  end;
end;

function RecorderMeraThermocoupleDstRange(const ARelativeScalePath: string;
  out AMinC, AMaxC: Double): Boolean;
var
  lInfo: TSdbScaleInfo;
begin
  Result := False;
  AMinC := 0;
  AMaxC := 0;
  if not RecorderSdbTryLoadScale(ARelativeScalePath, lInfo) then
    Exit;
  AMinC := lInfo.DstFrom;
  AMaxC := lInfo.DstTo;
  Result := AMinC <> AMaxC;
end;

procedure RecorderMeraListThermocoupleScales(AItems: TStrings);
var
  lFiles: TStringList;
  lI: Integer;
  lName: string;
  lPath: string;
begin
  if AItems = nil then
    Exit;
  AItems.Clear;
  lFiles := TStringList.Create;
  try
    RecorderSdbListScaleKeys(CMeraSdbThermocoupleFolder, lFiles);
    for lI := 0 to lFiles.Count - 1 do
    begin
      if SameText(ExtractFileName(lFiles[lI]), 'Термопары.xml') then
        Continue;
      lName := ChangeFileExt(ExtractFileName(lFiles[lI]), '');
      lPath := RecorderMeraThermocoupleRelativePath(lName);
      if not FileExists(RecorderMeraThermocoupleCsvPath(lPath)) then
        Continue;
      AItems.Add(lName);
    end;
  finally
    lFiles.Free;
  end;
end;

function RecorderMeraThermocoupleRelativePath(const ADisplayName: string): string;
begin
  Result := CMeraSdbThermocoupleFolder + PathDelim + ADisplayName;
end;

end.
