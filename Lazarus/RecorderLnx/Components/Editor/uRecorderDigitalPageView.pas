unit uRecorderDigitalPageView;

{$mode objfpc}{$H+}

interface

uses
  Grids,
  uRecorderTags,
  uRecorderAlarms,
  uComponentServices;

procedure RenderRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine);
procedure UpdateRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine);

implementation

uses
  Math, SysUtils;

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
  const AAlarmEngine: IRecorderAlarmEngine; AStatic: Boolean);
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
begin
  if ATagRegistry = nil then
    Exit;
  if AStatic then
  begin
    lRow := 1;
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
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
          SetCell(AGrid, 6, lRow, LclText(lTag.Description));
        end
        else
        begin
          SetCell(AGrid, 0, lRow, '');
          SetCell(AGrid, 2, lRow, '');
          SetCell(AGrid, 6, lRow, '');
        end;
        SetCell(AGrid, 1, lRow, RecorderTagEstimateKindToShortName(J));
        SetCell(AGrid, 3, lRow, LclText(lTag.UnitName));
        AGrid.Objects[0, lRow] := lTag;
        AGrid.Objects[1, lRow] := TObject(PtrInt(Ord(J) + 1));
        if lFirstTagRow then
        begin
          if AAlarmEngine <> nil then
            SetCell(AGrid, 5, lRow,
              LclText(AAlarmEngine.GetTagAlarmText(lTag)))
          else
            SetCell(AGrid, 5, lRow, '-');
        end
        else
          SetCell(AGrid, 5, lRow, '');
        SetCell(AGrid, 4, lRow, FormatTagEstimate(lTag, J));
        lFirstTagRow := False;
        Inc(lRow);
      end;
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
    if AGrid.Cells[0, lRow] <> '' then
    begin
      if AAlarmEngine <> nil then
        lAlarmText := LclText(AAlarmEngine.GetTagAlarmText(lTag))
      else
        lAlarmText := '-';
      if AGrid.Cells[5, lRow] <> lAlarmText then
      begin
        AGrid.Cells[5, lRow] := lAlarmText;
        InvalidateVisibleTagRows(AGrid, lTag, lFirstVisibleRow,
          lVisibleBottom);
      end;
    end;
  end;
end;

procedure RenderRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine);
var
  I: Integer;
  lRowCount: Integer;
  lTag: TRecorderTag;
begin
  if AGrid = nil then
    Exit;

  lRowCount := 1;
  if ATagRegistry <> nil then
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
      if not RecorderTagSourceIsVisible(ATagRegistry, lTag) then
        Continue;
      Inc(lRowCount, EnabledEstimateCount(lTag));
    end;
  if lRowCount < 2 then
    lRowCount := 2;

  AGrid.ColCount := 7;
  AGrid.RowCount := lRowCount;
  AGrid.FixedCols := 0;
  AGrid.FixedRows := 1;
  AGrid.Cells[0, 0] := 'Name';
  AGrid.Cells[1, 0] := 'Estimate';
  AGrid.Cells[2, 0] := 'Address';
  AGrid.Cells[3, 0] := 'Unit';
  AGrid.Cells[4, 0] := 'Value';
  AGrid.Cells[5, 0] := 'Alarm';
  AGrid.Cells[6, 0] := 'Description';

  if ATagRegistry = nil then
    Exit;

  AGrid.BeginUpdate;
  try
    FillRows(AGrid, ATagRegistry, AAlarmEngine, True);
  finally
    AGrid.EndUpdate;
  end;
  SGChange(AGrid);
end;

procedure UpdateRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry; const AAlarmEngine: IRecorderAlarmEngine);
begin
  if (AGrid = nil) or (ATagRegistry = nil) then
    Exit;
  FillRows(AGrid, ATagRegistry, AAlarmEngine, False);
end;

end.
