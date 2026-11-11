unit uRecorderDigitalPageView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Grids,
  uRecorderTags,
  uRecorderAlarms,
  uComponentServices;

procedure RenderRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine;
  AShowRawCodes: Boolean = False);
procedure UpdateRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine;
  AShowRawCodes: Boolean = False);

implementation

uses
  Math, SysUtils, Classes;

function FormatTagEstimate(ATag: TRecorderTag;
  AKind: TRecorderTagEstimateKind): string;
var
  lEstimate: TRecorderTagEstimate;
begin
  Result := '-';
  if ATag = nil then
    Exit;

  lEstimate := ATag.Estimate(AKind);
  if lEstimate.Valid then
    Result := FormatFloat('0.000', lEstimate.Value);
end;

function FormatRawCode(ATag: TRecorderTag): string;
var
  lValue: Double;
begin
  Result := '-';
  if (ATag <> nil) and ATag.HardwareCalibrationEnabled and
    ATag.TryGetRawValue(lValue) then
    Result := FormatFloat('0.########', lValue);
end;

function EnabledEstimateCount(ATag: TRecorderTag): Integer;
var
  lKind: TRecorderTagEstimateKind;
begin
  Result := 0;
  if ATag = nil then
    Exit;

  for lKind := tekMean to tekPeakToPeakByRmsDeviation do
    if ATag.EstimateSettings.EnabledKinds[lKind] then
      Inc(Result);
end;

procedure SetCell(AGrid: TStringGrid; ACol, ARow: Integer;
  const AValue: string);
begin
  if AGrid.Cells[ACol, ARow] <> AValue then
    AGrid.Cells[ACol, ARow] := AValue;
end;

procedure InvalidateVisibleTagRows(AGrid: TStringGrid; ATag: TRecorderTag;
  AFirstRow, ALastRow: Integer);
var
  lRow: Integer;
begin
  if AFirstRow < 1 then AFirstRow := 1;
  if ALastRow >= AGrid.RowCount then ALastRow := AGrid.RowCount - 1;
  for lRow := AFirstRow to ALastRow do
    if AGrid.Objects[0, lRow] = ATag then
      AGrid.InvalidateRow(lRow);
end;

procedure FillRows(AGrid: TStringGrid; ATagRegistry: TRecorderTagRegistry;
  const AAlarmEngine: IRecorderAlarmEngine; AStatic, AShowRawCodes: Boolean);
var
  I: Integer;
  J: TRecorderTagEstimateKind;
  lFirstTagRow: Boolean;
  lRow: Integer;
  lTag: TRecorderTag;
  lVisibleBottom: Integer;
  lFirstVisibleRow: Integer;
  lRowKind: TRecorderTagEstimateKind;
  lAlarmText: string;
  lAlarmCol, lDescriptionCol: Integer;
  lDisplayTags: TList;
begin
  if ATagRegistry = nil then
    Exit;
  lAlarmCol := 5 + Ord(AShowRawCodes);
  lDescriptionCol := 6 + Ord(AShowRawCodes);
  if AStatic then
  begin
    lDisplayTags := TList.Create;
    try
    ATagRegistry.GetDisplayTags(lDisplayTags);
    lRow := 1;
    for I := 0 to lDisplayTags.Count - 1 do
    begin
      lTag := TRecorderTag(lDisplayTags[I]);
      if not RecorderTagSourceIsVisible(ATagRegistry, lTag) then
        Continue;
      lFirstTagRow := True;
      for J := tekMean to tekPeakToPeakByRmsDeviation do
      begin
        if not lTag.EstimateSettings.EnabledKinds[J] then Continue;
        if lRow >= AGrid.RowCount then Exit;
        if lFirstTagRow then
        begin
          SetCell(AGrid, 0, lRow, LclText(lTag.Name));
          SetCell(AGrid, 2, lRow, LclText(lTag.Address));
          SetCell(AGrid, lDescriptionCol, lRow, LclText(lTag.Description));
        end
        else
        begin
          SetCell(AGrid, 0, lRow, '');
          SetCell(AGrid, 2, lRow, '');
          SetCell(AGrid, lDescriptionCol, lRow, '');
        end;
        SetCell(AGrid, 1, lRow, RecorderTagEstimateKindToShortName(J));
        SetCell(AGrid, 3, lRow, LclText(lTag.GetUnits));
        AGrid.Objects[0, lRow] := lTag;
        AGrid.Objects[1, lRow] := TObject(PtrInt(Ord(J) + 1));
        if lFirstTagRow then
        begin
          if lTag.CalibrationWarning <> '' then
            SetCell(AGrid, lAlarmCol, lRow, LclText(lTag.CalibrationWarning))
          else if AAlarmEngine <> nil then
            SetCell(AGrid, lAlarmCol, lRow,
              LclText(AAlarmEngine.GetTagAlarmText(lTag)))
          else
            SetCell(AGrid, lAlarmCol, lRow, '-');
        end
        else
          SetCell(AGrid, lAlarmCol, lRow, '');
        if AShowRawCodes then
          if lFirstTagRow then SetCell(AGrid, 5, lRow, FormatRawCode(lTag))
          else SetCell(AGrid, 5, lRow, '');
        SetCell(AGrid, 4, lRow, FormatTagEstimate(lTag, J));
        lFirstTagRow := False;
        Inc(lRow);
      end;
    end;
    finally
      lDisplayTags.Free;
    end;
    Exit;
  end;

  lFirstVisibleRow := AGrid.TopRow;
  lVisibleBottom := lFirstVisibleRow +
    (AGrid.ClientHeight div Max(1, AGrid.DefaultRowHeight)) + 2;
  if lFirstVisibleRow < 1 then lFirstVisibleRow := 1;
  if lVisibleBottom >= AGrid.RowCount then lVisibleBottom := AGrid.RowCount - 1;
  for lRow := lFirstVisibleRow to lVisibleBottom do
  begin
    lTag := TRecorderTag(AGrid.Objects[0, lRow]);
    if lTag = nil then Continue;
    lRowKind := TRecorderTagEstimateKind(PtrInt(AGrid.Objects[1, lRow]) - 1);
    SetCell(AGrid, 4, lRow, FormatTagEstimate(lTag, lRowKind));
    if AShowRawCodes then
      if AGrid.Cells[0, lRow] <> '' then
        SetCell(AGrid, 5, lRow, FormatRawCode(lTag))
      else SetCell(AGrid, 5, lRow, '');
    if AGrid.Cells[0, lRow] <> '' then
    begin
      if lTag.CalibrationWarning <> '' then
        lAlarmText := LclText(lTag.CalibrationWarning)
      else if AAlarmEngine <> nil then
        lAlarmText := LclText(AAlarmEngine.GetTagAlarmText(lTag))
      else
        lAlarmText := '-';
      if AGrid.Cells[lAlarmCol, lRow] <> lAlarmText then
      begin
        AGrid.Cells[lAlarmCol, lRow] := lAlarmText;
        InvalidateVisibleTagRows(AGrid, lTag, lFirstVisibleRow,
          lVisibleBottom);
      end;
    end;
  end;
end;

procedure RenderRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine;
  AShowRawCodes: Boolean);
var
  I: Integer;
  lRowCount: Integer;
  lTag: TRecorderTag;
  lSelectedTag, lSelectedEstimate: TObject;
  lSelectedColumn, lRestoreRow: Integer;
  lEmptyView: Boolean;
begin
  if AGrid = nil then
    Exit;
  lSelectedTag := nil;
  lSelectedEstimate := nil;
  lSelectedColumn := AGrid.Col;
  if (AGrid.ColCount > 1) and (AGrid.Row > 0) and
    (AGrid.Row < AGrid.RowCount) then
  begin
    lSelectedTag := AGrid.Objects[0, AGrid.Row];
    lSelectedEstimate := AGrid.Objects[1, AGrid.Row];
  end;

  lRowCount := 1;
  if ATagRegistry <> nil then
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
      if not RecorderTagSourceIsVisible(ATagRegistry, lTag) then
        Continue;
      Inc(lRowCount, EnabledEstimateCount(lTag));
    end;
  lEmptyView := lRowCount < 2;
  if lEmptyView then
    lRowCount := 2;

  AGrid.ColCount := 7 + Ord(AShowRawCodes);
  AGrid.RowCount := lRowCount;
  AGrid.FixedCols := 0;
  AGrid.FixedRows := 1;
  AGrid.Cells[0, 0] := 'Name';
  AGrid.Cells[1, 0] := 'Estimate';
  AGrid.Cells[2, 0] := 'Address';
  AGrid.Cells[3, 0] := 'Unit';
  AGrid.Cells[4, 0] := 'Value';
  if AShowRawCodes then AGrid.Cells[5, 0] := 'Коды (последний)';
  AGrid.Cells[5 + Ord(AShowRawCodes), 0] := 'Alarm';
  AGrid.Cells[6 + Ord(AShowRawCodes), 0] := 'Description';

  if ATagRegistry = nil then
    Exit;

  AGrid.BeginUpdate;
  try
    if lEmptyView then
      for I := 0 to AGrid.ColCount - 1 do
      begin
        AGrid.Cells[I, 1] := '';
        AGrid.Objects[I, 1] := nil;
      end
    else FillRows(AGrid, ATagRegistry, AAlarmEngine, True, AShowRawCodes);
    lRestoreRow := 0;
    if lSelectedTag <> nil then
      for I := 1 to AGrid.RowCount - 1 do
        if AGrid.Objects[0, I] = lSelectedTag then
        begin
          if lRestoreRow = 0 then lRestoreRow := I;
          if AGrid.Objects[1, I] = lSelectedEstimate then
          begin
            lRestoreRow := I;
            Break;
          end;
        end;
    if lRestoreRow > 0 then
    begin
      AGrid.Col := Min(lSelectedColumn, AGrid.ColCount - 1);
      AGrid.Row := lRestoreRow;
    end;
  finally
    AGrid.EndUpdate;
  end;
  SGChange(AGrid);
end;

procedure UpdateRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine;
  AShowRawCodes: Boolean);
begin
  if (AGrid = nil) or (ATagRegistry = nil) then
    Exit;
  FillRows(AGrid, ATagRegistry, AAlarmEngine, False, AShowRawCodes);
end;

end.
