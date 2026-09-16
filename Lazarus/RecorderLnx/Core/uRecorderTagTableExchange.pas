unit uRecorderTagTableExchange;

{
  Spreadsheet import/export for RecorderLnx tag metadata.

  The unit is intentionally in Core: UI chooses a file and displays the result,
  while matching tags and applying metadata remains independent from forms.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uRecorderSqlDbTypes;

type
  TRecorderTagTableExchangeResult = record
    TotalRows: Integer;
    ExportedTags: Integer;
    UpdatedTags: Integer;
    SkippedRows: Integer;
    MissingTags: Integer;
    RenamedTags: Integer;
    Warnings: TStringList;
  end;

  TRecorderSqlSelectionTableResult = record
    TotalRows: Integer;
    MarkedRows: Integer;
    MatchedRows: Integer;
    MissingRows: Integer;
  end;

procedure RecorderTagTableExchangeResultInit(
  out AResult: TRecorderTagTableExchangeResult);
procedure RecorderTagTableExchangeResultDone(
  var AResult: TRecorderTagTableExchangeResult);

procedure ExportRecorderTagsToTable(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig; const AFileName: string;
  var AResult: TRecorderTagTableExchangeResult);
procedure ImportRecorderTagsFromTable(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig; const AFileName: string;
  var AResult: TRecorderTagTableExchangeResult);
procedure ReadRecorderSqlSelectionFromTable(ARegistry: TRecorderTagRegistry;
  const AFileName: string; ASelectedNames, APresentNames: TStrings;
  out AResult: TRecorderSqlSelectionTableResult);

implementation

uses
  Math, StrUtils,
  fpspreadsheet, fpstypes, fpsopendocument, fpscsv, xlsxooxml,
  uRecorderSdbStore, uRecorderSdbTypes;

const
  CSheetName = 'Recorder_Tags';

  CColName = 0;
  CColDescription = 1;
  CColAddress = 2;
  CColSourceId = 3;
  CColModuleType = 4;
  CColTagId = 5;
  CColUnit = 6;
  CColPollFrequency = 7;
  CColAutoUnit = 8;
  CColAutoRange = 9;
  CColRangeMin = 10;
  CColRangeMax = 11;
  CColIsVirtual = 12;
  CColSqlRecord = 13;
  CColGroupPath = 14;
  CColScales = 15;
  CColumnCount = 16;

  CHeaders: array[0..CColumnCount - 1] of string = (
    'Имя канала',
    'Описание канала',
    'Адрес канала',
    'Источник',
    'Тип канала',
    'ID канала',
    'Ед. изм.',
    'Частота опроса',
    'Авто ед. изм.',
    'Авто диапазон',
    'Мин. шкалы',
    'Макс. шкалы',
    'Виртуальный',
    'Запись SQL',
    'Группа',
    'Scales'
  );

type
  TTagTableColumnMap = array[0..CColumnCount - 1] of Integer;

  TTagImportRow = record
    RowNumber: Integer;
    Name: string;
    Description: string;
    Address: string;
    SourceId: string;
    UnitName: string;
    PollFrequencyHz: Double;
    HasPollFrequencyHz: Boolean;
    AutoUnit: Boolean;
    HasAutoUnit: Boolean;
    AutoRange: Boolean;
    HasAutoRange: Boolean;
    RangeMin: Double;
    HasRangeMin: Boolean;
    RangeMax: Double;
    HasRangeMax: Boolean;
    TagId: TRecorderTagId;
    HasTagId: Boolean;
    SqlRecordEnabled: Boolean;
    HasSqlRecordEnabled: Boolean;
    GroupPath: string;
    HasGroupPath: Boolean;
    Scales: string;
    HasScales: Boolean;
    TargetTag: TRecorderTag;
  end;

  TTagImportRows = array of TTagImportRow;

  TTagImportLookup = class
  private
    fNames: TStringList;
    fAddresses: TStringList;
    procedure AddAddress(const AKey: string; ATag: TRecorderTag);
    function FindAddress(const AKey: string): TRecorderTag;
  public
    constructor Create(ARegistry: TRecorderTagRegistry);
    destructor Destroy; override;
    function Resolve(const ARow: TTagImportRow): TRecorderTag;
  end;

  TScaleLookup = class
  private
    fKeys: TStringList;
    fNames: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function Find(const AName: string; out AKey: string): Boolean;
  end;

constructor TScaleLookup.Create;
var
  I: Integer;
  lInfo: TSdbScaleInfo;
  lName: string;
begin
  inherited Create;
  fKeys := TStringList.Create;
  fNames := TStringList.Create;
  fNames.CaseSensitive := False;
  RecorderSdbListScaleKeys('', fKeys);
  for I := 0 to fKeys.Count - 1 do
    if RecorderSdbTryLoadScale(fKeys[I], lInfo) then
    begin
      lName := Trim(lInfo.Name);
      if lName = '' then
        lName := ExtractFileName(StringReplace(fKeys[I], '\', PathDelim,
          [rfReplaceAll]));
      if fNames.IndexOf(lName) < 0 then
        fNames.AddObject(lName, TObject(PtrInt(I)));
    end;
end;

destructor TScaleLookup.Destroy;
begin
  fNames.Free;
  fKeys.Free;
  inherited Destroy;
end;

function TScaleLookup.Find(const AName: string; out AKey: string): Boolean;
var
  lIndex: Integer;
begin
  AKey := '';
  lIndex := fNames.IndexOf(Trim(AName));
  Result := lIndex >= 0;
  if Result then
    AKey := fKeys[PtrInt(fNames.Objects[lIndex])];
end;

procedure RecorderTagTableExchangeResultInit(
  out AResult: TRecorderTagTableExchangeResult);
begin
  FillChar(AResult, SizeOf(AResult), 0);
  AResult.Warnings := TStringList.Create;
end;

procedure RecorderTagTableExchangeResultDone(
  var AResult: TRecorderTagTableExchangeResult);
begin
  FreeAndNil(AResult.Warnings);
end;

function FormatValue(AValue: Double): string;
var
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lFormat);
end;

function TryParseFloatValue(const AText: string; out AValue: Double): Boolean;
var
  lText: string;
begin
  lText := Trim(AText);
  if lText = '' then
    Exit(False);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  Result := TryStrToFloat(lText, AValue);
end;

function ScaleName(AValue: Double): string;
begin
  Result := '__rlnx_scale_' + FormatValue(AValue);
end;

function LineName(AK, AB: Double): string;
begin
  Result := '__rlnx_line_' + FormatValue(AK) + '_' + FormatValue(AB);
end;

function EnsureScale(ARegistry: TRecorderTagRegistry;
  AValue: Double): string;
var
  lScale: TRecorderCalibration;
begin
  Result := ScaleName(AValue);
  lScale := ARegistry.FindCalibrationByName(Result);
  if lScale <> nil then
    Exit;
  lScale := TRecorderCalibration.Create(rckScale);
  lScale.Name := Result;
  lScale.Scale := AValue;
  ARegistry.Calibrations.Add(lScale);
end;

function EnsureLine(ARegistry: TRecorderTagRegistry; AK, AB: Double): string;
var
  lLine: TRecorderCalibration;
begin
  Result := LineName(AK, AB);
  lLine := ARegistry.FindCalibrationByName(Result);
  if lLine <> nil then
    Exit;
  lLine := TRecorderCalibration.Create(rckPiecewiseLinear);
  lLine.Name := Result;
  lLine.Extrapolation := True;
  lLine.AddPoint(0, AB);
  lLine.AddPoint(1, AK + AB);
  ARegistry.Calibrations.Add(lLine);
end;

function TryParseLine(const AText: string; out AK, AB: Double): Boolean;
var
  lPos: Integer;
begin
  lPos := Pos(';', AText);
  Result := (lPos > 1) and (PosEx(';', AText, lPos + 1) = 0) and
    TryParseFloatValue(Copy(AText, 1, lPos - 1), AK) and
    TryParseFloatValue(Copy(AText, lPos + 1, MaxInt), AB);
end;

function TryGetLine(ACalibration: TRecorderCalibration;
  out AK, AB: Double): Boolean;
var
  lA: TRecorderCalibrationPoint;
  lB: TRecorderCalibrationPoint;
begin
  Result := (ACalibration <> nil) and
    (ACalibration.Kind = rckPiecewiseLinear) and
    (ACalibration.PointCount = 2);
  if not Result then
    Exit;
  lA := ACalibration.PointAt(0);
  lB := ACalibration.PointAt(1);
  Result := (lA <> nil) and (lB <> nil) and not SameValue(lA.X, lB.X);
  if Result then
  begin
    AK := (lB.Y - lA.Y) / (lB.X - lA.X);
    AB := lA.Y - AK * lA.X;
  end;
end;

function ExportScales(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ALookup: TScaleLookup): string;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lB: Double;
  lKey: string;
  lK: Double;
  lLines: TStringList;
begin
  Result := '';
  if (ARegistry = nil) or (ATag = nil) or
    (not ATag.ChannelCalibrationEnabled) then
    Exit;
  lLines := TStringList.Create;
  try
    for I := 0 to ATag.CalibrationNames.Count - 1 do
    begin
      lCalibration := ARegistry.FindCalibrationByName(
        ATag.CalibrationNames[I]);
      if lCalibration = nil then
        Continue;
      if ALookup.Find(lCalibration.Name, lKey) then
        lLines.Add(lCalibration.Name)
      else if lCalibration.Kind = rckScale then
        lLines.Add(FormatValue(lCalibration.Scale))
      else if TryGetLine(lCalibration, lK, lB) then
        lLines.Add(FormatValue(lK) + ';' + FormatValue(lB));
    end;
    Result := TrimRight(lLines.Text);
  finally
    lLines.Free;
  end;
end;

procedure ImportScales(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ALookup: TScaleLookup; const AText: string; ARow: Integer;
  AWarnings: TStrings);
var
  I: Integer;
  lKey: string;
  lB: Double;
  lK: Double;
  lName: string;
  lLines: TStringList;
  lValue: Double;
begin
  ATag.CalibrationNames.Clear;
  lLines := TStringList.Create;
  try
    lLines.Text := StringReplace(StringReplace(AText, #13#10, #10,
      [rfReplaceAll]), #13, #10, [rfReplaceAll]);
    for I := 0 to lLines.Count - 1 do
    begin
      lName := Trim(lLines[I]);
      if lName = '' then
        Continue;
      if TryParseLine(lName, lK, lB) then
        ATag.CalibrationNames.Add(EnsureLine(ARegistry, lK, lB))
      else if TryParseFloatValue(lName, lValue) then
        ATag.CalibrationNames.Add(EnsureScale(ARegistry, lValue))
      else if ALookup.Find(lName, lKey) and
        RecorderSdbImportCalibration(ARegistry.Calibrations, lKey, lName) then
        ATag.CalibrationNames.Add(lName)
      else
        AWarnings.Add(Format('Строка %d: ГХ "%s" не найдена в БДГХ',
          [ARow, lName]));
    end;
  finally
    lLines.Free;
  end;
  ATag.ChannelCalibrationEnabled := ATag.CalibrationNames.Count > 0;
end;

function BoolToTableText(AValue: Boolean): string;
begin
  if AValue then
    Result := '1'
  else
    Result := '0';
end;

function TryParseBoolValue(const AText: string; out AValue: Boolean): Boolean;
var
  lText: string;
begin
  lText := LowerCase(Trim(AText));
  Result := True;
  if (lText = '1') or (lText = 'true') or (lText = 'yes') or
    (lText = 'да') or (lText = 'истина') then
    AValue := True
  else if (lText = '0') or (lText = 'false') or (lText = 'no') or
    (lText = 'нет') or (lText = 'ложь') then
    AValue := False
  else
    Result := False;
end;

function TableFormatByFileName(const AFileName: string): TsSpreadsheetFormat;
var
  lExt: string;
begin
  lExt := LowerCase(ExtractFileExt(AFileName));
  if lExt = '.csv' then
    Result := sfCSV
  else if lExt = '.xlsx' then
    Result := sfOOXML
  else
    Result := sfOpenDocument;
end;

procedure WriteCell(ASheet: TsWorksheet; ARow, ACol: Cardinal;
  const AText: string);
begin
  ASheet.WriteUTF8Text(ARow, ACol, AText);
end;

function ReadCell(ASheet: TsWorksheet; ARow, ACol: Cardinal): string;
begin
  Result := Trim(ASheet.ReadAsUTF8Text(ARow, ACol));
end;

function WorksheetLastUsedCol(ASheet: TsWorksheet): Integer;
var
  lLastCol: Cardinal;
begin
  Result := 0;
  if ASheet = nil then
    Exit;
  lLastCol := ASheet.GetLastColIndex(True);
  if (lLastCol = 0) and (Trim(ASheet.ReadAsUTF8Text(0, 0)) = '') and
    (ASheet.GetCellCount = 0) then
    Exit(-1);
  Result := Integer(lLastCol);
end;

function HeaderIndex(ASheet: TsWorksheet; const AHeader: string): Integer;
var
  I: Integer;
  lLastCol: Integer;
begin
  Result := -1;
  if ASheet = nil then
    Exit;
  lLastCol := Max(WorksheetLastUsedCol(ASheet), CColumnCount - 1);
  for I := 0 to lLastCol do
    if SameText(ReadCell(ASheet, 0, I), AHeader) then
      Exit(I);
end;

function SqlRecordHeaderIndex(ASheet: TsWorksheet): Integer;
begin
  Result := HeaderIndex(ASheet, CHeaders[CColSqlRecord]);
  if Result < 0 then Result := HeaderIndex(ASheet, 'SQLdb');
  if Result < 0 then Result := HeaderIndex(ASheet, 'SQL DB');
end;

function ColumnIndex(ASheet: TsWorksheet; ADefaultIndex: Integer;
  const AHeader: string): Integer;
begin
  Result := HeaderIndex(ASheet, AHeader);
  if Result < 0 then
    Result := ADefaultIndex;
end;

procedure BuildColumnMap(ASheet: TsWorksheet; AAllowDefaultColumns: Boolean;
  out AMap: TTagTableColumnMap);
var
  I: Integer;
begin
  for I := 0 to CColumnCount - 1 do
  begin
    AMap[I] := HeaderIndex(ASheet, CHeaders[I]);
    if (AMap[I] < 0) and AAllowDefaultColumns then
      AMap[I] := I;
  end;
  AMap[CColSqlRecord] := SqlRecordHeaderIndex(ASheet);
end;

function NextAppendColumn(ASheet: TsWorksheet): Integer;
var
  lLastCol: Integer;
begin
  lLastCol := WorksheetLastUsedCol(ASheet);
  if lLastCol < 0 then
    Result := 0
  else
    Result := lLastCol + 1;
end;

procedure EnsureExportColumns(ASheet: TsWorksheet;
  var AMap: TTagTableColumnMap; AIncludeGroupPath: Boolean);
var
  I: Integer;
begin
  for I := 0 to CColumnCount - 1 do
  begin
    if (I = CColGroupPath) and (not AIncludeGroupPath) and (AMap[I] < 0) then
      Continue;
    if AMap[I] < 0 then
      AMap[I] := NextAppendColumn(ASheet);
    WriteCell(ASheet, 0, AMap[I], CHeaders[I]);
  end;
end;

procedure WriteMappedCell(ASheet: TsWorksheet; const AMap: TTagTableColumnMap;
  AColumnId: Integer; ARow: Cardinal; const AText: string);
begin
  if (AColumnId < Low(AMap)) or (AColumnId > High(AMap)) then
    Exit;
  if AMap[AColumnId] < 0 then
    Exit;
  WriteCell(ASheet, ARow, AMap[AColumnId], AText);
end;

function ReadMappedCell(ASheet: TsWorksheet; const AMap: TTagTableColumnMap;
  AColumnId: Integer; ARow: Cardinal): string;
begin
  Result := '';
  if (AColumnId < Low(AMap)) or (AColumnId > High(AMap)) then
    Exit;
  if AMap[AColumnId] < 0 then
    Exit;
  Result := ReadCell(ASheet, ARow, AMap[AColumnId]);
end;

function WorkbookTagWorksheet(ABook: TsWorkbook): TsWorksheet;
begin
  Result := nil;
  if ABook = nil then
    Exit;
  Result := ABook.GetWorksheetByName(CSheetName);
  if (Result = nil) and (ABook.GetWorksheetCount > 0) then
    Result := ABook.GetWorksheetByIndex(0);
  if Result = nil then
    Result := ABook.AddWorksheet(CSheetName);
end;

function FindExportRowForTag(ASheet: TsWorksheet; const AMap: TTagTableColumnMap;
  ATag: TRecorderTag): Integer;
var
  lLastRow: Cardinal;
  lRow: Cardinal;
  lTagId: TRecorderTagId;
  lText: string;
begin
  Result := -1;
  if (ASheet = nil) or (ATag = nil) then
    Exit;

  lLastRow := ASheet.GetLastRowIndex(True);
  for lRow := 1 to lLastRow do
  begin
    lText := ReadMappedCell(ASheet, AMap, CColTagId, lRow);
    if TryStrToInt64(lText, lTagId) and (lTagId = ATag.Id) then
      Exit(Integer(lRow));
  end;

  for lRow := 1 to lLastRow do
    if SameText(ReadMappedCell(ASheet, AMap, CColSourceId, lRow),
      ATag.SourceId) and SameText(ReadMappedCell(ASheet, AMap, CColAddress,
      lRow), ATag.Address) then
      Exit(Integer(lRow));

  for lRow := 1 to lLastRow do
    if SameText(ReadMappedCell(ASheet, AMap, CColName, lRow), ATag.Name) then
      Exit(Integer(lRow));
end;

function AppendExportRow(ASheet: TsWorksheet): Integer;
begin
  Result := Integer(ASheet.GetLastRowIndex(True)) + 1;
  if (Result = 1) and (ASheet.GetCellCount = 0) then
    Result := 1;
end;

constructor TTagImportLookup.Create(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  inherited Create;
  fNames := TStringList.Create;
  fAddresses := TStringList.Create;
  fNames.Sorted := True;
  fNames.CaseSensitive := False;
  fAddresses.Sorted := True;
  fAddresses.CaseSensitive := False;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    fNames.AddObject(lTag.Name, lTag);
    if Trim(lTag.Address) <> '' then
    begin
      AddAddress('E' + lTag.SourceId + #1 + lTag.Address, lTag);
      AddAddress('B' + lTag.Address, lTag);
    end;
  end;
end;

destructor TTagImportLookup.Destroy;
begin
  fAddresses.Free;
  fNames.Free;
  inherited Destroy;
end;

procedure TTagImportLookup.AddAddress(const AKey: string; ATag: TRecorderTag);
var
  lIndex: Integer;
begin
  if fAddresses.Find(AKey, lIndex) then
    fAddresses.Objects[lIndex] := nil
  else
    fAddresses.AddObject(AKey, ATag);
end;

function TTagImportLookup.FindAddress(const AKey: string): TRecorderTag;
var
  lIndex: Integer;
begin
  Result := nil;
  if fAddresses.Find(AKey, lIndex) then
    Result := TRecorderTag(fAddresses.Objects[lIndex]);
end;

function TTagImportLookup.Resolve(const ARow: TTagImportRow): TRecorderTag;
var
  lIndex: Integer;
begin
  Result := nil;
  if fNames.Find(ARow.Name, lIndex) then
    Exit(TRecorderTag(fNames.Objects[lIndex]));
  if Trim(ARow.Address) <> '' then
  begin
    if Trim(ARow.SourceId) <> '' then
      Exit(FindAddress('E' + ARow.SourceId + #1 + ARow.Address));
    Exit(FindAddress('B' + ARow.Address));
  end;
end;

function SqlRecordEnabled(ASqlDbConfig: TRecorderSqlDbConfig;
  ATag: TRecorderTag): Boolean;
begin
  Result := True;
  if ATag = nil then
    Exit(False);
  if ASqlDbConfig <> nil then
    Result := ASqlDbConfig.SignalEnabled(ATag.Name);
end;

procedure EnsureExplicitSqlRecordSelection(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig);
var
  I: Integer;
begin
  if (ARegistry = nil) or (ASqlDbConfig = nil) or
    ASqlDbConfig.SignalSelectionConfigured then
    Exit;
  ASqlDbConfig.SignalNames.Clear;
  for I := 0 to ARegistry.TagCount - 1 do
    ASqlDbConfig.SignalNames.Add(ARegistry.Tags[I].Name);
  ASqlDbConfig.SignalSelectionConfigured := True;
end;

procedure SetSqlRecordEnabled(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig; const AOldName, ANewName: string;
  AEnabled: Boolean);
var
  lIndex: Integer;
  lName: string;
  lOldName: string;
begin
  if ASqlDbConfig = nil then
    Exit;
  lName := Trim(ANewName);
  if lName = '' then
    Exit;
  EnsureExplicitSqlRecordSelection(ARegistry, ASqlDbConfig);

  lOldName := Trim(AOldName);
  if (lOldName <> '') and (not SameText(lOldName, lName)) then
  begin
    lIndex := ASqlDbConfig.SignalNames.IndexOf(lOldName);
    if lIndex >= 0 then
      ASqlDbConfig.SignalNames.Delete(lIndex);
  end;

  lIndex := ASqlDbConfig.SignalNames.IndexOf(lName);
  if AEnabled then
  begin
    if lIndex < 0 then
      ASqlDbConfig.SignalNames.Add(lName);
  end
  else if lIndex >= 0 then
    ASqlDbConfig.SignalNames.Delete(lIndex);
end;

function MakeTempTagName(ATag: TRecorderTag): string;
begin
  Result := ATag.Name + '__RecorderLnxImportTmp_' + IntToStr(ATag.Id);
end;

procedure RemoveRowsWithDuplicateNames(var ARows: TTagImportRows;
  var AResult: TRecorderTagTableExchangeResult);
var
  I: Integer;
  lIndex: Integer;
  lCount: Integer;
  lUniqueRows: TTagImportRows;
  lNameCounts: TStringList;
begin
  lNameCounts := TStringList.Create;
  try
    lNameCounts.Sorted := True;
    lNameCounts.CaseSensitive := False;
    for I := 0 to High(ARows) do
    begin
      if lNameCounts.Find(ARows[I].Name, lIndex) then
        lNameCounts.Objects[lIndex] := TObject(
          PtrInt(lNameCounts.Objects[lIndex]) + 1)
      else
        lNameCounts.AddObject(ARows[I].Name, TObject(PtrInt(1)));
    end;
    SetLength(lUniqueRows, Length(ARows));
    lCount := 0;
    for I := 0 to High(ARows) do
    begin
      lNameCounts.Find(ARows[I].Name, lIndex);
      if PtrInt(lNameCounts.Objects[lIndex]) > 1 then
      begin
        Inc(AResult.SkippedRows);
        AResult.Warnings.Add(Format(
          'Строка %d: имя канала "%s" повторяется в таблице; канал не изменён',
          [ARows[I].RowNumber, Trim(ARows[I].Name)]));
        Continue;
      end;
      lUniqueRows[lCount] := ARows[I];
      Inc(lCount);
    end;
    SetLength(lUniqueRows, lCount);
    ARows := lUniqueRows;
  finally
    lNameCounts.Free;
  end;
end;

procedure RenameTargetsToTemporaryNames(ARegistry: TRecorderTagRegistry;
  var ARows: TTagImportRows; var AResult: TRecorderTagTableExchangeResult);
var
  I: Integer;
  lNewName: string;
begin
  for I := 0 to High(ARows) do
  begin
    if ARows[I].TargetTag = nil then
      Continue;
    lNewName := Trim(ARows[I].Name);
    if (lNewName = '') or SameText(lNewName, ARows[I].TargetTag.Name) then
      Continue;
    ARegistry.RenameTag(ARows[I].TargetTag, MakeTempTagName(ARows[I].TargetTag));
    Inc(AResult.RenamedTags);
  end;
end;

procedure ApplyImportRows(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig; ALookup: TScaleLookup;
  const ARows: TTagImportRows; var AResult: TRecorderTagTableExchangeResult);
var
  I: Integer;
  lTag: TRecorderTag;
  lNewName: string;
  lOldName: string;
begin
  for I := 0 to High(ARows) do
  begin
    lTag := ARows[I].TargetTag;
    if lTag = nil then
      Continue;
    lOldName := lTag.Name;
    lNewName := Trim(ARows[I].Name);
    if lNewName <> '' then
      ARegistry.RenameTag(lTag, lNewName);
    lTag.Description := ARows[I].Description;
    if ARows[I].UnitName <> '' then
      lTag.UnitName := ARows[I].UnitName;
    if ARows[I].HasPollFrequencyHz then
      lTag.PollFrequencyHz := ARows[I].PollFrequencyHz;
    if ARows[I].HasAutoUnit then
      lTag.AutoUnit := ARows[I].AutoUnit;
    if ARows[I].HasAutoRange then
      lTag.AutoRange := ARows[I].AutoRange;
    if ARows[I].HasRangeMin then
      lTag.RangeMin := ARows[I].RangeMin;
    if ARows[I].HasRangeMax then
      lTag.RangeMax := ARows[I].RangeMax;
    if ARows[I].HasSqlRecordEnabled then
      SetSqlRecordEnabled(ARegistry, ASqlDbConfig, lOldName, lTag.Name,
        ARows[I].SqlRecordEnabled);
    if ARows[I].HasGroupPath then
    begin
      lTag.GroupPath := ARows[I].GroupPath;
      if Trim(lTag.GroupPath) <> '' then
        ARegistry.TagGroupPaths.Add(Trim(lTag.GroupPath));
    end;
    if ARows[I].HasScales then
      ImportScales(ARegistry, lTag, ALookup, ARows[I].Scales,
        ARows[I].RowNumber, AResult.Warnings);
    Inc(AResult.UpdatedTags);
  end;
end;

function ExportNeedsGroupPath(ARegistry: TRecorderTagRegistry;
  const AMap: TTagTableColumnMap): Boolean;
var
  I: Integer;
begin
  Result := AMap[CColGroupPath] >= 0;
  if Result or (ARegistry = nil) then
    Exit;
  if ARegistry.TagGroupPaths.Count > 0 then
    Exit(True);
  for I := 0 to ARegistry.TagCount - 1 do
    if Trim(ARegistry.Tags[I].GroupPath) <> '' then
      Exit(True);
end;

procedure ExportRecorderTagsToTable(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig; const AFileName: string;
  var AResult: TRecorderTagTableExchangeResult);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  I: Integer;
  lRow: Integer;
  lTag: TRecorderTag;
  lMap: TTagTableColumnMap;
  lIncludeGroupPath: Boolean;
  lLookup: TScaleLookup;
begin
  if ARegistry = nil then
    raise ERecorderTagError.Create('Tag registry is not assigned');

  lBook := TsWorkbook.Create;
  lLookup := TScaleLookup.Create;
  try
    if FileExists(AFileName) then
      lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    lSheet := WorkbookTagWorksheet(lBook);
    BuildColumnMap(lSheet, not FileExists(AFileName), lMap);
    lIncludeGroupPath := ExportNeedsGroupPath(ARegistry, lMap);
    EnsureExportColumns(lSheet, lMap, lIncludeGroupPath);

    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      lRow := FindExportRowForTag(lSheet, lMap, lTag);
      if lRow < 0 then
        lRow := AppendExportRow(lSheet);
      WriteCell(lSheet, lRow, lMap[CColName], lTag.Name);
      WriteCell(lSheet, lRow, lMap[CColDescription], lTag.Description);
      WriteCell(lSheet, lRow, lMap[CColAddress], lTag.Address);
      WriteCell(lSheet, lRow, lMap[CColSourceId], lTag.SourceId);
      WriteCell(lSheet, lRow, lMap[CColModuleType], lTag.ModuleType);
      WriteCell(lSheet, lRow, lMap[CColTagId], IntToStr(lTag.Id));
      WriteCell(lSheet, lRow, lMap[CColUnit], lTag.UnitName);
      WriteCell(lSheet, lRow, lMap[CColPollFrequency],
        FormatValue(lTag.PollFrequencyHz));
      WriteCell(lSheet, lRow, lMap[CColAutoUnit],
        BoolToTableText(lTag.AutoUnit));
      WriteCell(lSheet, lRow, lMap[CColAutoRange],
        BoolToTableText(lTag.AutoRange));
      WriteCell(lSheet, lRow, lMap[CColRangeMin], FormatValue(lTag.RangeMin));
      WriteCell(lSheet, lRow, lMap[CColRangeMax], FormatValue(lTag.RangeMax));
      WriteCell(lSheet, lRow, lMap[CColIsVirtual],
        BoolToTableText(lTag.IsVirtual));
      WriteCell(lSheet, lRow, lMap[CColSqlRecord],
        BoolToTableText(SqlRecordEnabled(ASqlDbConfig, lTag)));
      WriteMappedCell(lSheet, lMap, CColGroupPath, lRow, lTag.GroupPath);
      WriteMappedCell(lSheet, lMap, CColScales, lRow,
        ExportScales(ARegistry, lTag, lLookup));
      Inc(AResult.ExportedTags);
    end;
    AResult.TotalRows := ARegistry.TagCount;
    lBook.WriteToFile(AFileName, TableFormatByFileName(AFileName), True);
  finally
    lLookup.Free;
    lBook.Free;
  end;
end;

procedure ImportRecorderTagsFromTable(ARegistry: TRecorderTagRegistry;
  ASqlDbConfig: TRecorderSqlDbConfig; const AFileName: string;
  var AResult: TRecorderTagTableExchangeResult);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  lLastRow: Cardinal;
  lRowIndex: Cardinal;
  lRows: TTagImportRows;
  lRow: TTagImportRow;
  lMap: TTagTableColumnMap;
  lLookup: TScaleLookup;
  lTagLookup: TTagImportLookup;
  lText: string;
  lMatchCount: Integer;
  lHasScales: Boolean;
begin
  if ARegistry = nil then
    raise ERecorderTagError.Create('Tag registry is not assigned');

  lBook := TsWorkbook.Create;
  lLookup := TScaleLookup.Create;
  lTagLookup := TTagImportLookup.Create(ARegistry);
  try
    lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    if lBook.GetWorksheetCount = 0 then
      raise ERecorderTagError.Create('Spreadsheet does not contain worksheets');
    lSheet := lBook.GetWorksheetByIndex(0);

    BuildColumnMap(lSheet, True, lMap);
    lHasScales := HeaderIndex(lSheet, CHeaders[CColScales]) >= 0;

    lLastRow := lSheet.GetLastRowIndex(True);
    SetLength(lRows, lLastRow);
    lMatchCount := 0;
    for lRowIndex := 1 to lLastRow do
    begin
      lRow := Default(TTagImportRow);
      lRow.RowNumber := lRowIndex + 1;
      lRow.Name := ReadMappedCell(lSheet, lMap, CColName, lRowIndex);
      lRow.Description := ReadMappedCell(lSheet, lMap, CColDescription,
        lRowIndex);
      lRow.Address := ReadMappedCell(lSheet, lMap, CColAddress, lRowIndex);
      lRow.SourceId := ReadMappedCell(lSheet, lMap, CColSourceId, lRowIndex);
      lRow.UnitName := ReadMappedCell(lSheet, lMap, CColUnit, lRowIndex);
      lText := ReadMappedCell(lSheet, lMap, CColTagId, lRowIndex);
      lRow.HasTagId := TryStrToInt64(lText, lRow.TagId);
      lText := ReadMappedCell(lSheet, lMap, CColPollFrequency, lRowIndex);
      lRow.HasPollFrequencyHz := TryParseFloatValue(lText, lRow.PollFrequencyHz);
      lText := ReadMappedCell(lSheet, lMap, CColAutoUnit, lRowIndex);
      lRow.HasAutoUnit := TryParseBoolValue(lText, lRow.AutoUnit);
      lText := ReadMappedCell(lSheet, lMap, CColAutoRange, lRowIndex);
      lRow.HasAutoRange := TryParseBoolValue(lText, lRow.AutoRange);
      lText := ReadMappedCell(lSheet, lMap, CColRangeMin, lRowIndex);
      lRow.HasRangeMin := TryParseFloatValue(lText, lRow.RangeMin);
      lText := ReadMappedCell(lSheet, lMap, CColRangeMax, lRowIndex);
      lRow.HasRangeMax := TryParseFloatValue(lText, lRow.RangeMax);
      lText := ReadMappedCell(lSheet, lMap, CColSqlRecord, lRowIndex);
      lRow.HasSqlRecordEnabled := TryParseBoolValue(lText,
        lRow.SqlRecordEnabled);
      lRow.HasGroupPath := lMap[CColGroupPath] >= 0;
      if lRow.HasGroupPath then
        lRow.GroupPath := ReadMappedCell(lSheet, lMap, CColGroupPath, lRowIndex);
      lRow.HasScales := lHasScales;
      if lRow.HasScales then
        lRow.Scales := ReadMappedCell(lSheet, lMap, CColScales, lRowIndex);

      { An unnamed row in a shared channel table must not change a tag. }
      if lRow.Name = '' then
        Continue;
      Inc(AResult.TotalRows);
      lRow.TargetTag := lTagLookup.Resolve(lRow);
      if lRow.TargetTag = nil then
      begin
        Inc(AResult.SkippedRows);
        { A shared setup table may intentionally contain channels assigned to
          other Recorder hosts. Count those rows, but do not turn each one into
          a warning shown to the operator. }
        Inc(AResult.MissingTags);
        Continue;
      end;
      lRows[lMatchCount] := lRow;
      Inc(lMatchCount);
    end;

    SetLength(lRows, lMatchCount);
    RemoveRowsWithDuplicateNames(lRows, AResult);
    RenameTargetsToTemporaryNames(ARegistry, lRows, AResult);
    ApplyImportRows(ARegistry, ASqlDbConfig, lLookup, lRows, AResult);
  finally
    lTagLookup.Free;
    lLookup.Free;
    lBook.Free;
  end;
end;

procedure ReadRecorderSqlSelectionFromTable(ARegistry: TRecorderTagRegistry;
  const AFileName: string; ASelectedNames, APresentNames: TStrings;
  out AResult: TRecorderSqlSelectionTableResult);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  lMap: TTagTableColumnMap;
  lLastRow, lRowIndex: Cardinal;
  lRow: TTagImportRow;
  lText: string;
  lTagLookup: TTagImportLookup;
begin
  AResult := Default(TRecorderSqlSelectionTableResult);
  if (ARegistry = nil) or (ASelectedNames = nil) or (APresentNames = nil) then
    raise ERecorderTagError.Create('SQL selection import arguments are not assigned');
  ASelectedNames.Clear;
  APresentNames.Clear;

  lBook := TsWorkbook.Create;
  lTagLookup := TTagImportLookup.Create(ARegistry);
  try
    lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    if lBook.GetWorksheetCount = 0 then
      raise ERecorderTagError.Create('Spreadsheet does not contain worksheets');
    lSheet := lBook.GetWorksheetByIndex(0);
    BuildColumnMap(lSheet, False, lMap);
    if lMap[CColSqlRecord] < 0 then
      raise ERecorderTagError.Create(
        'Не найдена колонка SQLdb (или Запись SQL)');
    if (lMap[CColName] < 0) and (lMap[CColTagId] < 0) and
      (lMap[CColAddress] < 0) then
      raise ERecorderTagError.Create('Не найдены колонки идентификации канала');

    lLastRow := lSheet.GetLastRowIndex(True);
    for lRowIndex := 1 to lLastRow do
    begin
      lRow := Default(TTagImportRow);
      lRow.Name := ReadMappedCell(lSheet, lMap, CColName, lRowIndex);
      lRow.Address := ReadMappedCell(lSheet, lMap, CColAddress, lRowIndex);
      lRow.SourceId := ReadMappedCell(lSheet, lMap, CColSourceId, lRowIndex);
      lText := ReadMappedCell(lSheet, lMap, CColTagId, lRowIndex);
      lRow.HasTagId := TryStrToInt64(lText, lRow.TagId);
      if (lRow.Name = '') and (lRow.Address = '') and (not lRow.HasTagId) then
        Continue;
      Inc(AResult.TotalRows);
      lText := ReadMappedCell(lSheet, lMap, CColSqlRecord, lRowIndex);
      lRow.HasSqlRecordEnabled := TryParseBoolValue(lText,
        lRow.SqlRecordEnabled);
      if lRow.HasSqlRecordEnabled and lRow.SqlRecordEnabled then
        Inc(AResult.MarkedRows);
      lRow.TargetTag := lTagLookup.Resolve(lRow);
      if lRow.TargetTag = nil then
      begin
        Inc(AResult.MissingRows);
        Continue;
      end;
      Inc(AResult.MatchedRows);
      APresentNames.Add(lRow.TargetTag.Name);
      if lRow.HasSqlRecordEnabled and lRow.SqlRecordEnabled then
      begin
        ASelectedNames.Add(lRow.TargetTag.Name);
      end;
    end;
  finally
    lTagLookup.Free;
    lBook.Free;
  end;
end;

end.
