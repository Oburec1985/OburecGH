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
  SysUtils;

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

procedure FillRows(AGrid: TStringGrid; ATagRegistry: TRecorderTagRegistry;
  const AAlarmEngine: IRecorderAlarmEngine; AStatic: Boolean);
var
  I: Integer;
  J: TRecorderTagEstimateKind;
  lFirstTagRow: Boolean;
  lRow: Integer;
  lTag: TRecorderTag;
  lVisibleBottom: Integer;
  lVisibleRow: Boolean;
begin
  if ATagRegistry = nil then
    Exit;
  lRow := 1;
  lVisibleBottom := AGrid.TopRow +
    (AGrid.ClientHeight div AGrid.DefaultRowHeight) + 2;
  for I := 0 to ATagRegistry.TagCount - 1 do
  begin
    lTag := ATagRegistry.Tags[I];
    if not RecorderTagSourceIsVisible(ATagRegistry, lTag) then
      Continue;
    lFirstTagRow := True;
    for J := tekMean to tekPeakToPeakByRmsDeviation do
    begin
      if not lTag.EstimateSettings.EnabledKinds[J] then
        Continue;
      if lRow >= AGrid.RowCount then
        Exit;
      lVisibleRow := AStatic or
        ((lRow >= AGrid.TopRow) and (lRow <= lVisibleBottom));

      if AStatic then
      begin
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
      end;

      if lFirstTagRow then
      begin
        if lVisibleRow then
          if AAlarmEngine <> nil then
            SetCell(AGrid, 5, lRow,
              LclText(AAlarmEngine.GetTagAlarmText(lTag)))
          else
            SetCell(AGrid, 5, lRow, '-');
        lFirstTagRow := False;
      end
      else if AStatic then
        SetCell(AGrid, 5, lRow, '');
      if lVisibleRow then
        SetCell(AGrid, 4, lRow, FormatTagEstimate(lTag, J));
      Inc(lRow);
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
  AGrid.BeginUpdate;
  try
    FillRows(AGrid, ATagRegistry, AAlarmEngine, False);
  finally
    AGrid.EndUpdate;
  end;
end;

end.
