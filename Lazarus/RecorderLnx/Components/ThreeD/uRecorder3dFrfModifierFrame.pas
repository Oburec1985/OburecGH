unit uRecorder3dFrfModifierFrame;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Controls, Forms, Grids, uRecorder3dModel,
  uRecorderImpactHammerContracts;

type
  { Read-only scene-editor projection of the FRF modifiers created by the AKA
    binding editor. Editing remains centralized in that editor. }
  TRecorder3dFrfModifierFrame = class(TFrame)
  published
    fGrid: TStringGrid;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorder3dComponent;
      AMode: TRecorderGeometryBindingMode);
  end;

implementation

uses
  SysUtils;

{$R *.lfm}

constructor TRecorder3dFrfModifierFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fGrid.Cells[0, 0] := 'Источник';
  fGrid.Cells[1, 0] := 'Кривая';
  fGrid.Cells[2, 0] := 'Объект';
  fGrid.Cells[3, 0] := 'Точка';
  fGrid.Cells[4, 0] := 'Подпись';
  fGrid.Cells[5, 0] := 'Коэффициент';
  fGrid.ColWidths[0] := 135;
  fGrid.ColWidths[1] := 70;
  fGrid.ColWidths[2] := 80;
  fGrid.ColWidths[3] := 95;
  fGrid.ColWidths[4] := 110;
  fGrid.ColWidths[5] := 95;
end;

procedure TRecorder3dFrfModifierFrame.Configure(
  AComponent: TRecorder3dComponent; AMode: TRecorderGeometryBindingMode);
var
  I, Row: Integer;
  B: TRecorder3dFrfBinding;
begin
  fGrid.RowCount := 2;
  fGrid.Rows[1].Clear;
  if AComponent = nil then
    Exit;
  Row := 1;
  for I := 0 to AComponent.FrfBindingCount - 1 do
  begin
    B := AComponent.FrfBindings[I];
    if B.Mode <> AMode then
      Continue;
    fGrid.RowCount := Row + 1;
    fGrid.Cells[0, Row] := B.SourceBindingId;
    fGrid.Cells[1, Row] := UIntToStr(B.CurveId);
    fGrid.Cells[2, Row] := UIntToStr(B.ModifierTargetNodeId);
    fGrid.Cells[3, Row] := IntToStr(B.PointNumber);
    fGrid.Cells[4, Row] := B.PointLabel;
    fGrid.Cells[5, Row] := FloatToStr(B.Gain);
    Inc(Row);
  end;
end;

end.
