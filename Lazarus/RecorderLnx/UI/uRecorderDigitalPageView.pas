unit uRecorderDigitalPageView;

{$mode objfpc}{$H+}

interface

uses
  Grids,
  uRecorderTags;

procedure RenderRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry);

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

procedure RenderRecorderDigitalPage(AGrid: TStringGrid;
  ATagRegistry: TRecorderTagRegistry);
var
  I: Integer;
  J: TRecorderTagEstimateKind;
  lFirstTagRow: Boolean;
  lRow: Integer;
  lRowCount: Integer;
  lTag: TRecorderTag;
begin
  if AGrid = nil then
    Exit;

  lRowCount := 1;
  if ATagRegistry <> nil then
    for I := 0 to ATagRegistry.TagCount - 1 do
      Inc(lRowCount, EnabledEstimateCount(ATagRegistry.Tags[I]));
  if lRowCount < 2 then
    lRowCount := 2;

  AGrid.ColCount := 6;
  AGrid.RowCount := lRowCount;
  AGrid.FixedCols := 0;
  AGrid.FixedRows := 1;
  AGrid.Cells[0, 0] := 'Name';
  AGrid.Cells[1, 0] := 'Estimate';
  AGrid.Cells[2, 0] := 'Address';
  AGrid.Cells[3, 0] := 'Unit';
  AGrid.Cells[4, 0] := 'Value';
  AGrid.Cells[5, 0] := 'Description';

  if ATagRegistry = nil then
    Exit;

  lRow := 1;
  for I := 0 to ATagRegistry.TagCount - 1 do
  begin
    lTag := ATagRegistry.Tags[I];
    lFirstTagRow := True;
    for J := tekMean to tekPeakToPeakByRmsDeviation do
    begin
      if not lTag.EstimateSettings.EnabledKinds[J] then
        Continue;

      if lFirstTagRow then
      begin
        AGrid.Cells[0, lRow] := lTag.Name;
        AGrid.Cells[2, lRow] := lTag.Address;
        AGrid.Cells[5, lRow] := lTag.Description;
        lFirstTagRow := False;
      end
      else
      begin
        AGrid.Cells[0, lRow] := '';
        AGrid.Cells[2, lRow] := '';
        AGrid.Cells[5, lRow] := '';
      end;

      AGrid.Cells[1, lRow] := RecorderTagEstimateKindToShortName(J);
      AGrid.Cells[3, lRow] := lTag.UnitName;
      AGrid.Cells[4, lRow] := FormatTagEstimate(lTag, J);
      Inc(lRow);
    end;
  end;
end;

end.
