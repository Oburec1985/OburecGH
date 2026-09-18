unit uRecorderSqlTrendMeraExport;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

{ Creates a WinPOS-compatible MERA bundle: <name>/<name>.mera with binary
  channel data and explicit X files. Existing bundles are never overwritten. }
procedure ExportSqlTrendMera(const AConfigFileName: string;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  const AOutputFileName: string);

implementation

uses
  DateUtils, uRecorderSqlDbTypes, uRecorderSqlDbRepository,
  uRecorderDataStorage;

function SignalUnit(const AName: string;
  const AInfos: TRecorderSqlDbSignalInfos): string;
var
  lIndex: Integer;
begin
  Result := '';
  for lIndex := 0 to High(AInfos) do
    if AInfos[lIndex].Name = AName then
      Exit(AInfos[lIndex].UnitName);
end;

procedure ValidateRequest(ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  const AOutputFileName: string);
var
  lIndex: Integer;
begin
  if (ASignalNames = nil) or (ASignalNames.Count = 0) then
    raise ERecorderSqlDbError.Create('No SQL trend channels selected');
  if AToUtc < AFromUtc then
    raise ERecorderSqlDbError.Create('Invalid SQL trend export interval');
  if (Trim(AOutputFileName) = '') or
    (not SameText(ExtractFileExt(AOutputFileName), '.mera')) then
    raise ERecorderSqlDbError.Create('MERA output file must have .mera extension');
  for lIndex := 0 to ASignalNames.Count - 1 do
    if (Trim(ASignalNames[lIndex]) = '') or
      (ASignalNames.IndexOf(ASignalNames[lIndex]) <> lIndex) then
      raise ERecorderSqlDbError.Create(
        'SQL trend channel names must be unique and nonempty');
end;

procedure ReadExportData(const AConfigFileName: string;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  out APoints: TRecorderSqlTrendPoints;
  out AInfos: TRecorderSqlDbSignalInfos);
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lError: string;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.LoadFromFile(AConfigFileName);
    if not lConfig.ConnectionConfigurationReady(lError) then
      raise ERecorderSqlDbError.Create(lError);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.ListSignalInfos(AInfos, False);
      lRepository.ReadAllTrendPoints(ASignalNames, AFromUtc, AToUtc, APoints);
    finally
      lRepository.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure WriteSignals(AWriter: TRecorderMeraTagWriter;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  const APoints: TRecorderSqlTrendPoints;
  const AInfos: TRecorderSqlDbSignalInfos);
var
  lSignal, lPoint, lFirst, lCount, lIndex: Integer;
  lTimes, lValues: array of Double;
  lName: string;
begin
  lPoint := 0;
  for lSignal := 0 to ASignalNames.Count - 1 do
  begin
    lName := ASignalNames[lSignal];
    lFirst := lPoint;
    while (lPoint < Length(APoints)) and (APoints[lPoint].SignalName = lName) do
      Inc(lPoint);
    SetLength(lTimes, lPoint - lFirst);
    SetLength(lValues, lPoint - lFirst);
    lCount := 0;
    for lIndex := lFirst to lPoint - 1 do
      if (APoints[lIndex].TimestampUtc >= AFromUtc) and
        (APoints[lIndex].TimestampUtc <= AToUtc) then
      begin
        lTimes[lCount] := (APoints[lIndex].TimestampUtc - AFromUtc) * SecsPerDay;
        lValues[lCount] := APoints[lIndex].Value;
        Inc(lCount);
      end;
    if lCount > 0 then
      AWriter.WriteBlock(lName, SignalUnit(lName, AInfos), '', '', '',
        lTimes, lValues, lCount, 0, True);
  end;
end;

procedure ExportSqlTrendMera(const AConfigFileName: string;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  const AOutputFileName: string);
var
  lPoints: TRecorderSqlTrendPoints;
  lInfos: TRecorderSqlDbSignalInfos;
  lBundleDir: string;
  lWriter: TRecorderMeraTagWriter;
  lIndex: Integer;
  lHasData: Boolean;
begin
  ValidateRequest(ASignalNames, AFromUtc, AToUtc, AOutputFileName);
  lBundleDir := ChangeFileExt(AOutputFileName, '');
  if FileExists(AOutputFileName) or DirectoryExists(lBundleDir) then
    raise ERecorderSqlDbError.Create('MERA output already exists: ' +
      AOutputFileName);
  ReadExportData(AConfigFileName, ASignalNames, AFromUtc, AToUtc,
    lPoints, lInfos);
  lHasData := False;
  for lIndex := 0 to High(lPoints) do
    if (lPoints[lIndex].TimestampUtc >= AFromUtc) and
      (lPoints[lIndex].TimestampUtc <= AToUtc) then
    begin
      lHasData := True;
      Break;
    end;
  if not lHasData then
    raise ERecorderSqlDbError.Create(
      'No SQL trend points in the selected interval for MERA export');

  lWriter := TRecorderMeraTagWriter.Create;
  try
    { SQL timestamps are UTC TDateTime values. MERA descriptor stores local
      start time, while each explicit X stores seconds since that same instant. }
    lWriter.Open(lBundleDir, UniversalTimeToLocal(AFromUtc));
    WriteSignals(lWriter, ASignalNames, AFromUtc, AToUtc, lPoints, lInfos);
    lWriter.Close;
  finally
    lWriter.Free;
  end;
end;

end.
