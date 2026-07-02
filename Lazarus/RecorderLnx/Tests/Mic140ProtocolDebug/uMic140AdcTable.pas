unit uMic140AdcTable;

{
  Таблица сравнения сырых кодов: измерение vs эталон Recorder.

  Строки: CH01..CH48 (из TRecorderDeviceSampleBlock) + T1..T3 (из AAux).
  Колонки grid/лога: Chan | Raw | Ref | Delta | OK (Y/N).

  Mic140AdcTableFillGrid  — обновление sgAdc на форме (каждый блок, даже при FAIL).
  Mic140AdcTableAppendLog — текстовая таблица в mic140_protocol_debug.log
  Mic140AdcTableCountGood — число строк с OK для stand-good=M/N в логе
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Grids,
  uRecorderDeviceInterfaces,
  uRecorderAcquisitionTypes,
  uRecorderMic140v2WireTypes,
  uMic140DebugReference;

type
  TMic140AdcTableRow = record
    LabelText: string;
    Raw: Integer;
    Ref: Integer;
    Delta: Integer;
    Ok: Boolean;
    HasRef: Boolean;
  end;

  TMic140AdcTableRows = array of TMic140AdcTableRow;

procedure Mic140AdcTableFillGrid(AGrid: TStringGrid; const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock);
procedure Mic140AdcTableAppendLog(ALines: TStrings; const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer; ACheckTin: Boolean = True);
function Mic140AdcTableCountGood(const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; ACheckTin: Boolean = True): Integer;
procedure Mic140AdcTablePrepareCanvas(Sender: TObject; ACol, ARow: Integer;
  AState: TGridDrawState);

implementation

procedure Mic140BuildRows(const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; out ARows: TMic140AdcTableRows);
var
  lI, lCode, lRef, lCnt: Integer;
  lRow: TMic140AdcTableRow;
begin
  lCnt := CMic140StandAinCount + CMic140StandTinCount;
  SetLength(ARows, lCnt);
  for lI := 0 to CMic140StandAinCount - 1 do
  begin
    lRow.LabelText := Format('CH%2.2d', [lI + 1]);
    lRow.Raw := 0;
    if (lI < Length(ABlock.Values)) and (Length(ABlock.Values[lI]) > 0) then
      lRow.Raw := Trunc(ABlock.Values[lI][0]);
    lRow.HasRef := Mic140StandAinReference(lI, lRef);
    lRow.Ref := lRef;
    if lRow.HasRef then
    begin
      lRow.Delta := lRow.Raw - lRef;
      lRow.Ok := Mic140StandAinCodeOk(lRow.Raw, lI);
    end
    else
    begin
      lRow.Delta := 0;
      lRow.Ok := False;
    end;
    ARows[lI] := lRow;
  end;
  for lI := 0 to CMic140StandTinCount - 1 do
  begin
    lRow.LabelText := Format('T%d', [lI + 1]);
    lCode := 0;
    if (lI < AAux.ChannelCount) and (lI < Length(AAux.Values)) and
       (Length(AAux.Values[lI]) > 0) then
      lCode := Round(AAux.Values[lI][0]);
    lRow.Raw := lCode;
    lRow.HasRef := Mic140StandTinReference(lI, lRef);
    lRow.Ref := lRef;
    if lRow.HasRef then
    begin
      lRow.Delta := lRow.Raw - lRef;
      lRow.Ok := Mic140StandTinCodeOk(lRow.Raw, lI);
    end
    else
    begin
      lRow.Delta := 0;
      lRow.Ok := False;
    end;
    ARows[CMic140StandAinCount + lI] := lRow;
  end;
end;

procedure Mic140AdcTableFillGrid(AGrid: TStringGrid; const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock);
var
  lRows: TMic140AdcTableRows;
  lI: Integer;
begin
  if AGrid = nil then
    Exit;
  Mic140BuildRows(ABlock, AAux, lRows);
  AGrid.RowCount := Length(lRows) + 1;
  if AGrid.ColCount < 5 then
    AGrid.ColCount := 5;
  AGrid.Cells[0, 0] := 'Chan';
  AGrid.Cells[1, 0] := 'Raw';
  AGrid.Cells[2, 0] := 'Ref';
  AGrid.Cells[3, 0] := 'Delta';
  AGrid.Cells[4, 0] := 'OK';
  for lI := 0 to High(lRows) do
  begin
    AGrid.Cells[0, lI + 1] := lRows[lI].LabelText;
    AGrid.Cells[1, lI + 1] := IntToStr(lRows[lI].Raw);
    if lRows[lI].HasRef then
    begin
      AGrid.Cells[2, lI + 1] := IntToStr(lRows[lI].Ref);
      AGrid.Cells[3, lI + 1] := IntToStr(lRows[lI].Delta);
      if lRows[lI].Ok then
        AGrid.Cells[4, lI + 1] := 'Y'
      else
        AGrid.Cells[4, lI + 1] := 'N';
      if lRows[lI].Ok and lRows[lI].HasRef then
        AGrid.Objects[0, lI + 1] := TObject(PtrUInt(1))
      else
        AGrid.Objects[0, lI + 1] := nil;
    end
    else
    begin
      AGrid.Cells[2, lI + 1] := '-';
      AGrid.Cells[3, lI + 1] := '-';
      AGrid.Cells[4, lI + 1] := '-';
    end;
  end;
end;

procedure Mic140AdcTableAppendLog(ALines: TStrings; const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer; ACheckTin: Boolean);
var
  lRows: TMic140AdcTableRows;
  lI, lGood, lTotal: Integer;
  lLine, lOk: string;
begin
  if ALines = nil then
    Exit;
  Mic140BuildRows(ABlock, AAux, lRows);
  lGood := Mic140AdcTableCountGood(ABlock, AAux, ACheckTin);
  lTotal := CMic140StandAinCount;
  if ACheckTin then
    Inc(lTotal, CMic140StandTinCount);
  ALines.Add(Format('--- ADC table block %d good=%d/%d ---', [ABlockNo, lGood, lTotal]));
  ALines.Add('Chan    Raw      Ref   Delta  OK');
  for lI := 0 to High(lRows) do
  begin
    if lRows[lI].HasRef then
    begin
      if lRows[lI].Ok then
        lOk := 'Y'
      else
        lOk := 'N';
      lLine := Format('%-6s %8d %8d %6d %s', [
        lRows[lI].LabelText, lRows[lI].Raw, lRows[lI].Ref, lRows[lI].Delta, lOk]);
    end
    else
      lLine := Format('%-6s %8d', [lRows[lI].LabelText, lRows[lI].Raw]);
    ALines.Add(lLine);
  end;
end;

function Mic140AdcTableCountGood(const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; ACheckTin: Boolean): Integer;
var
  lRows: TMic140AdcTableRows;
  lI, lLimit: Integer;
begin
  Result := 0;
  Mic140BuildRows(ABlock, AAux, lRows);
  lLimit := CMic140StandAinCount - 1;
  if ACheckTin then
    lLimit := High(lRows);
  for lI := 0 to lLimit do
    if lRows[lI].Ok then
      Inc(Result);
end;

procedure Mic140AdcTablePrepareCanvas(Sender: TObject; ACol, ARow: Integer;
  AState: TGridDrawState);
var
  lGrid: TStringGrid;
begin
  lGrid := TStringGrid(Sender);
  if (ARow < 1) or (lGrid.Objects[0, ARow] = nil) then
    Exit;
  lGrid.Canvas.Brush.Color := $00E0FFE0;
end;

end.
