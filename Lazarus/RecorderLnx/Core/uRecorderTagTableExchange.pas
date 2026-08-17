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
  uRecorderTags;

type
  TRecorderTagTableExchangeResult = record
    TotalRows: Integer;
    ExportedTags: Integer;
    UpdatedTags: Integer;
    SkippedRows: Integer;
    RenamedTags: Integer;
    Warnings: TStringList;
  end;

procedure RecorderTagTableExchangeResultInit(
  out AResult: TRecorderTagTableExchangeResult);
procedure RecorderTagTableExchangeResultDone(
  var AResult: TRecorderTagTableExchangeResult);

procedure ExportRecorderTagsToTable(ARegistry: TRecorderTagRegistry;
  const AFileName: string; var AResult: TRecorderTagTableExchangeResult);
procedure ImportRecorderTagsFromTable(ARegistry: TRecorderTagRegistry;
  const AFileName: string; var AResult: TRecorderTagTableExchangeResult);

implementation

uses
  Math, StrUtils,
  fpspreadsheet, fpstypes, fpsopendocument, fpscsv;

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
  CColumnCount = 13;

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
    'Виртуальный'
  );

type
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
    TargetTag: TRecorderTag;
  end;

  TTagImportRows = array of TTagImportRow;

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

function HeaderIndex(ASheet: TsWorksheet; const AHeader: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to CColumnCount - 1 do
    if SameText(ReadCell(ASheet, 0, I), AHeader) then
      Exit(I);
end;

function ColumnIndex(ASheet: TsWorksheet; ADefaultIndex: Integer;
  const AHeader: string): Integer;
begin
  Result := HeaderIndex(ASheet, AHeader);
  if Result < 0 then
    Result := ADefaultIndex;
end;

function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if (ARegistry = nil) or (Trim(AAddress) = '') then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.Address, AAddress) and
      ((Trim(ASourceId) = '') or SameText(lTag.SourceId, ASourceId)) then
    begin
      if Result <> nil then
        Exit(nil);
      Result := lTag;
    end;
  end;
end;

function ResolveImportTarget(ARegistry: TRecorderTagRegistry;
  const ARow: TTagImportRow): TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  if ARow.HasTagId then
    Result := ARegistry.FindById(ARow.TagId);
  if Result = nil then
    Result := FindTagBySourceAddress(ARegistry, ARow.SourceId, ARow.Address);
  if (Result = nil) and (ARow.Name <> '') then
    Result := ARegistry.FindByName(ARow.Name);
end;

function MakeTempTagName(ATag: TRecorderTag): string;
begin
  Result := ATag.Name + '__RecorderLnxImportTmp_' + IntToStr(ATag.Id);
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
  const ARows: TTagImportRows; var AResult: TRecorderTagTableExchangeResult);
var
  I: Integer;
  lTag: TRecorderTag;
  lNewName: string;
begin
  for I := 0 to High(ARows) do
  begin
    lTag := ARows[I].TargetTag;
    if lTag = nil then
      Continue;
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
    Inc(AResult.UpdatedTags);
  end;
end;

procedure ExportRecorderTagsToTable(ARegistry: TRecorderTagRegistry;
  const AFileName: string; var AResult: TRecorderTagTableExchangeResult);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  I: Integer;
  lRow: Integer;
  lTag: TRecorderTag;
begin
  if ARegistry = nil then
    raise ERecorderTagError.Create('Tag registry is not assigned');

  lBook := TsWorkbook.Create;
  try
    lSheet := lBook.AddWorksheet(CSheetName);
    for I := 0 to CColumnCount - 1 do
      WriteCell(lSheet, 0, I, CHeaders[I]);

    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      lRow := I + 1;
      WriteCell(lSheet, lRow, CColName, lTag.Name);
      WriteCell(lSheet, lRow, CColDescription, lTag.Description);
      WriteCell(lSheet, lRow, CColAddress, lTag.Address);
      WriteCell(lSheet, lRow, CColSourceId, lTag.SourceId);
      WriteCell(lSheet, lRow, CColModuleType, lTag.ModuleType);
      WriteCell(lSheet, lRow, CColTagId, IntToStr(lTag.Id));
      WriteCell(lSheet, lRow, CColUnit, lTag.UnitName);
      WriteCell(lSheet, lRow, CColPollFrequency, FormatValue(lTag.PollFrequencyHz));
      WriteCell(lSheet, lRow, CColAutoUnit, BoolToTableText(lTag.AutoUnit));
      WriteCell(lSheet, lRow, CColAutoRange, BoolToTableText(lTag.AutoRange));
      WriteCell(lSheet, lRow, CColRangeMin, FormatValue(lTag.RangeMin));
      WriteCell(lSheet, lRow, CColRangeMax, FormatValue(lTag.RangeMax));
      WriteCell(lSheet, lRow, CColIsVirtual, BoolToTableText(lTag.IsVirtual));
      Inc(AResult.ExportedTags);
    end;
    AResult.TotalRows := ARegistry.TagCount;
    lBook.WriteToFile(AFileName, TableFormatByFileName(AFileName), True);
  finally
    lBook.Free;
  end;
end;

procedure ImportRecorderTagsFromTable(ARegistry: TRecorderTagRegistry;
  const AFileName: string; var AResult: TRecorderTagTableExchangeResult);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  lLastRow: Cardinal;
  lRowIndex: Cardinal;
  lRows: TTagImportRows;
  lRow: TTagImportRow;
  lColName: Integer;
  lColDescription: Integer;
  lColAddress: Integer;
  lColSourceId: Integer;
  lColTagId: Integer;
  lColUnit: Integer;
  lColPollFrequency: Integer;
  lColAutoUnit: Integer;
  lColAutoRange: Integer;
  lColRangeMin: Integer;
  lColRangeMax: Integer;
  lText: string;
begin
  if ARegistry = nil then
    raise ERecorderTagError.Create('Tag registry is not assigned');

  lBook := TsWorkbook.Create;
  try
    lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    if lBook.GetWorksheetCount = 0 then
      raise ERecorderTagError.Create('Spreadsheet does not contain worksheets');
    lSheet := lBook.GetWorksheetByIndex(0);

    lColName := ColumnIndex(lSheet, CColName, CHeaders[CColName]);
    lColDescription := ColumnIndex(lSheet, CColDescription,
      CHeaders[CColDescription]);
    lColAddress := ColumnIndex(lSheet, CColAddress, CHeaders[CColAddress]);
    lColSourceId := ColumnIndex(lSheet, CColSourceId, CHeaders[CColSourceId]);
    lColTagId := ColumnIndex(lSheet, CColTagId, CHeaders[CColTagId]);
    lColUnit := ColumnIndex(lSheet, CColUnit, CHeaders[CColUnit]);
    lColPollFrequency := ColumnIndex(lSheet, CColPollFrequency,
      CHeaders[CColPollFrequency]);
    lColAutoUnit := ColumnIndex(lSheet, CColAutoUnit, CHeaders[CColAutoUnit]);
    lColAutoRange := ColumnIndex(lSheet, CColAutoRange, CHeaders[CColAutoRange]);
    lColRangeMin := ColumnIndex(lSheet, CColRangeMin, CHeaders[CColRangeMin]);
    lColRangeMax := ColumnIndex(lSheet, CColRangeMax, CHeaders[CColRangeMax]);

    lLastRow := lSheet.GetLastRowIndex(True);
    SetLength(lRows, 0);
    for lRowIndex := 1 to lLastRow do
    begin
      lRow := Default(TTagImportRow);
      lRow.RowNumber := lRowIndex + 1;
      lRow.Name := ReadCell(lSheet, lRowIndex, lColName);
      lRow.Description := ReadCell(lSheet, lRowIndex, lColDescription);
      lRow.Address := ReadCell(lSheet, lRowIndex, lColAddress);
      lRow.SourceId := ReadCell(lSheet, lRowIndex, lColSourceId);
      lRow.UnitName := ReadCell(lSheet, lRowIndex, lColUnit);
      lText := ReadCell(lSheet, lRowIndex, lColTagId);
      lRow.HasTagId := TryStrToInt64(lText, lRow.TagId);
      lText := ReadCell(lSheet, lRowIndex, lColPollFrequency);
      lRow.HasPollFrequencyHz := TryParseFloatValue(lText, lRow.PollFrequencyHz);
      lText := ReadCell(lSheet, lRowIndex, lColAutoUnit);
      lRow.HasAutoUnit := TryParseBoolValue(lText, lRow.AutoUnit);
      lText := ReadCell(lSheet, lRowIndex, lColAutoRange);
      lRow.HasAutoRange := TryParseBoolValue(lText, lRow.AutoRange);
      lText := ReadCell(lSheet, lRowIndex, lColRangeMin);
      lRow.HasRangeMin := TryParseFloatValue(lText, lRow.RangeMin);
      lText := ReadCell(lSheet, lRowIndex, lColRangeMax);
      lRow.HasRangeMax := TryParseFloatValue(lText, lRow.RangeMax);

      if (lRow.Name = '') and (lRow.Address = '') and (not lRow.HasTagId) then
        Continue;
      Inc(AResult.TotalRows);
      lRow.TargetTag := ResolveImportTarget(ARegistry, lRow);
      if lRow.TargetTag = nil then
      begin
        Inc(AResult.SkippedRows);
        AResult.Warnings.Add(Format('Строка %d: тег не найден', [lRow.RowNumber]));
        Continue;
      end;
      SetLength(lRows, Length(lRows) + 1);
      lRows[High(lRows)] := lRow;
    end;

    RenameTargetsToTemporaryNames(ARegistry, lRows, AResult);
    ApplyImportRows(ARegistry, lRows, AResult);
  finally
    lBook.Free;
  end;
end;

end.
