unit uRecorderSqlTrendCsvExport;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

procedure ExportSqlTrendCsv(const AConfigFileName: string;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  const AOutputFileName: string);

implementation

uses
  uRecorderSqlDbTypes, uRecorderSqlDbRepository;

type
  TPointRange = record
    First, Last, Cursor: Integer;
  end;
  TPointRanges = array of TPointRange;
  TTimestampArray = array of Double;

procedure SortTimestamps(var AItems: TTimestampArray; ALeft, ARight: Integer);
var
  lLeft, lRight: Integer;
  lPivot, lTemp: Double;
begin
  lLeft := ALeft;
  lRight := ARight;
  lPivot := AItems[(ALeft + ARight) div 2];
  repeat
    while AItems[lLeft] < lPivot do Inc(lLeft);
    while AItems[lRight] > lPivot do Dec(lRight);
    if lLeft <= lRight then
    begin
      lTemp := AItems[lLeft];
      AItems[lLeft] := AItems[lRight];
      AItems[lRight] := lTemp;
      Inc(lLeft);
      Dec(lRight);
    end;
  until lLeft > lRight;
  if ALeft < lRight then SortTimestamps(AItems, ALeft, lRight);
  if lLeft < ARight then SortTimestamps(AItems, lLeft, ARight);
end;

function CsvField(const AValue: string): string;
begin
  Result := AValue;
  if (Pos(';', AValue) = 0) and (Pos('"', AValue) = 0) and
    (Pos(#10, AValue) = 0) and (Pos(#13, AValue) = 0) then Exit;
  Result := '"' + StringReplace(AValue, '"', '""', [rfReplaceAll]) + '"';
end;

procedure WriteLine(AStream: TStream; const ALine: string);
const
  CLineEnding = #13#10;
begin
  if ALine <> '' then AStream.WriteBuffer(Pointer(ALine)^, Length(ALine));
  AStream.WriteBuffer(CLineEnding[1], Length(CLineEnding));
end;

function InterpolatedValue(const APoints: TRecorderSqlTrendPoints;
  var ARange: TPointRange; AX: Double; const AFormat: TFormatSettings): string;
var
  lLeft, lRight: TRecorderSqlTrendPoint;
  lValue: Double;
begin
  Result := '-';
  if ARange.First >= ARange.Last then Exit;
  while (ARange.Cursor + 1 < ARange.Last) and
    (APoints[ARange.Cursor + 1].TimestampUtc <= AX) do
    Inc(ARange.Cursor);
  lLeft := APoints[ARange.Cursor];
  if lLeft.TimestampUtc = AX then
    lValue := lLeft.Value
  else
  begin
    if (lLeft.TimestampUtc > AX) or (ARange.Cursor + 1 >= ARange.Last) then
      Exit;
    lRight := APoints[ARange.Cursor + 1];
    if lRight.TimestampUtc <= lLeft.TimestampUtc then Exit;
    lValue := lLeft.Value + (lRight.Value - lLeft.Value) *
      (AX - lLeft.TimestampUtc) /
      (lRight.TimestampUtc - lLeft.TimestampUtc);
  end;
  Result := FloatToStr(lValue, AFormat);
end;

procedure BuildRangesAndAxis(const APoints: TRecorderSqlTrendPoints;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  out ARanges: TPointRanges; out AAxis: TTimestampArray);
var
  lSignal, lPoint, lAxisCount: Integer;
begin
  SetLength(ARanges, ASignalNames.Count);
  SetLength(AAxis, Length(APoints));
  lPoint := 0;
  lAxisCount := 0;
  for lSignal := 0 to ASignalNames.Count - 1 do
  begin
    ARanges[lSignal].First := lPoint;
    ARanges[lSignal].Cursor := lPoint;
    while (lPoint < Length(APoints)) and
      (APoints[lPoint].SignalName = ASignalNames[lSignal]) do
    begin
      if (APoints[lPoint].TimestampUtc >= AFromUtc) and
        (APoints[lPoint].TimestampUtc <= AToUtc) then
      begin
        AAxis[lAxisCount] := APoints[lPoint].TimestampUtc;
        Inc(lAxisCount);
      end;
      Inc(lPoint);
    end;
    ARanges[lSignal].Last := lPoint;
  end;
  SetLength(AAxis, lAxisCount);
  if lAxisCount > 1 then SortTimestamps(AAxis, 0, lAxisCount - 1);
end;

procedure WriteCsv(AStream: TStream; ASignalNames: TStrings;
  const APoints: TRecorderSqlTrendPoints; var ARanges: TPointRanges;
  const AAxis: TTimestampArray);
const
  CUTF8Bom: array[0..2] of Byte = ($EF, $BB, $BF);
var
  lSignal, lRow: Integer;
  lLine: string;
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  AStream.WriteBuffer(CUTF8Bom, SizeOf(CUTF8Bom));
  lLine := 'X';
  for lSignal := 0 to ASignalNames.Count - 1 do
    lLine := lLine + ';' + CsvField(ASignalNames[lSignal]);
  WriteLine(AStream, lLine);
  for lRow := 0 to High(AAxis) do
  begin
    if (lRow > 0) and (AAxis[lRow] = AAxis[lRow - 1]) then Continue;
    lLine := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"', AAxis[lRow]);
    for lSignal := 0 to ASignalNames.Count - 1 do
      lLine := lLine + ';' + InterpolatedValue(APoints,
        ARanges[lSignal], AAxis[lRow], lFormat);
    WriteLine(AStream, lLine);
  end;
end;

procedure ExportSqlTrendCsv(const AConfigFileName: string;
  ASignalNames: TStrings; AFromUtc, AToUtc: TDateTime;
  const AOutputFileName: string);
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lPoints: TRecorderSqlTrendPoints;
  lRanges: TPointRanges;
  lAxis: TTimestampArray;
  lFile: TFileStream;
  lSignal: Integer;
  lError: string;
begin
  if (ASignalNames = nil) or (ASignalNames.Count = 0) then
    raise Exception.Create('No SQL trend channels selected');
  if AToUtc < AFromUtc then
    raise Exception.Create('Invalid SQL trend export interval');
  if Trim(AOutputFileName) = '' then
    raise Exception.Create('CSV file name is empty');
  for lSignal := 0 to ASignalNames.Count - 1 do
    if (Trim(ASignalNames[lSignal]) = '') or
      (ASignalNames.IndexOf(ASignalNames[lSignal]) <> lSignal) then
      raise Exception.Create('SQL trend channel names must be unique and nonempty');
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.LoadFromFile(AConfigFileName);
    if not lConfig.ConnectionConfigurationReady(lError) then
      raise ERecorderSqlDbError.Create(lError);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.ReadAllTrendPoints(ASignalNames, AFromUtc, AToUtc, lPoints);
    finally
      lRepository.Free;
    end;
  finally
    lConfig.Free;
  end;
  BuildRangesAndAxis(lPoints, ASignalNames, AFromUtc, AToUtc, lRanges, lAxis);
  lFile := TFileStream.Create(AOutputFileName, fmCreate);
  try
    WriteCsv(lFile, ASignalNames, lPoints, lRanges, lAxis);
  finally
    lFile.Free;
  end;
end;

end.
