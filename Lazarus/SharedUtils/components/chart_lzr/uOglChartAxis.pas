unit uOglChartAxis;

{$mode objfpc}{$H+}

interface

uses
  uOglChartDrawObj;

type
  TChartAxisOrientation = (caoX, caoY);
  TChartAxisScale = (casLinear, casLog10);

  { cAxis
    Ось задаёт систему координат для дочерних графиков.
    Y-ось обычно владеет сериями, X-ось может быть общей от страницы
    или индивидуальной для серии. }
  cAxis = class(cDrawObj)
  private
    fOrientation: TChartAxisOrientation;
    fScale: TChartAxisScale;
    fMinValue: Double;
    fMaxValue: Double;
  public
    procedure AssignDefaultProperties; override;

    property Orientation: TChartAxisOrientation read fOrientation write fOrientation;
    property Scale: TChartAxisScale read fScale write fScale;
    property MinValue: Double read fMinValue write fMinValue;
    property MaxValue: Double read fMaxValue write fMaxValue;
  end;

  TChartAxis = cAxis;

implementation

procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fOrientation := caoY;
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
end;

end.
