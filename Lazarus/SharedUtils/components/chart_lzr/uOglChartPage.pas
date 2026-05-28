unit uOglChartPage;

{$mode objfpc}{$H+}

interface

uses
  uOglChartDrawObj, uOglChartAxis;

type
  TChartPageAlign = (cpaNone, cpaAuto, cpaClient, cpaTop, cpaBottom, cpaLeft, cpaRight);

  { cBasePage
    Страница чарта: рамка, фон и полезная область сетки.
    PixelTabSpace задаёт пиксельные отступы от рамки до viewport-а графика. }
  cBasePage = class(cMoveObj)
  private
    fAlign: TChartPageAlign;
    fAlignWeight: Integer;
    fBorderColor: Cardinal;
    fFillColor: Cardinal;
    fBorderWidth: Single;
    fPixelTabSpace: TChartPixelRect;
    fXMinValue: Double;
    fXMaxValue: Double;
    fXScale: TChartAxisScale;
  public
    procedure AssignDefaultProperties; override;

    property Align: TChartPageAlign read fAlign write fAlign;
    property AlignWeight: Integer read fAlignWeight write fAlignWeight;
    property BorderColor: Cardinal read fBorderColor write fBorderColor;
    property FillColor: Cardinal read fFillColor write fFillColor;
    property BorderWidth: Single read fBorderWidth write fBorderWidth;
    property PixelTabSpace: TChartPixelRect read fPixelTabSpace write fPixelTabSpace;
    property XMinValue: Double read fXMinValue write fXMinValue;
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    property XScale: TChartAxisScale read fXScale write fXScale;
  end;

  TChartPage = cBasePage;

implementation

procedure cBasePage.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Page';
  Caption := 'Page';
  fBorderColor := $FF606060;
  fFillColor := $FFFFFFFF;
  fBorderWidth := 2;
  fPixelTabSpace.Left := 42;
  fPixelTabSpace.Top := 34;
  fPixelTabSpace.Right := 12;
  fPixelTabSpace.Bottom := 24;
  fAlign := cpaAuto;
  fAlignWeight := 1;
  SetFloatRect(0.04, 0.06, 0.96, 0.94);
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
end;

end.
