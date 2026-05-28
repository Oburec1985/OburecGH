unit uOglChartAxis;

{$mode objfpc}{$H+}

interface

uses
  uOglChartDrawObj;

type
  TChartAxisScale = (casLinear, casLog10);

  { cAxis
    Ось задаёт систему координат для дочерних графиков.
    Y-ось обычно владеет сериями, X-ось может быть общей от страницы
    или индивидуальной для серии. }
  cAxis = class(cMoveObj)
  private
    fScale: TChartAxisScale;
    fMinValue: Double;
    fMaxValue: Double;
    fUseOwnX: Boolean;
    fXMinValue: Double;
    fXMaxValue: Double;
    fXScale: TChartAxisScale;
  public
    procedure AssignDefaultProperties; override;

    property Scale: TChartAxisScale read fScale write fScale;
    property MinValue: Double read fMinValue write fMinValue;
    property MaxValue: Double read fMaxValue write fMaxValue;
    property UseOwnX: Boolean read fUseOwnX write fUseOwnX;
    property XMinValue: Double read fXMinValue write fXMinValue;
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    property XScale: TChartAxisScale read fXScale write fXScale;
  end;

  TChartAxis = cAxis;

implementation

procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
  fUseOwnX := False;
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
end;

end.
