unit uOglChartTrend;

{$mode objfpc}{$H+}

interface

uses
  uOglChartDrawObj, uOglChartAxis;

type
  { cBaseTrend
    Общая база линий и буферных трендов. Владеющая Y-ось задаёт вертикальную
    проекцию, XAxis задаёт горизонтальную проекцию, если она отличается от страницы. }
  cBaseTrend = class(cDrawObj)
  private
    fXAxis: cAxis;
  public
    procedure AssignDefaultProperties; override;
    property XAxis: cAxis read fXAxis write fXAxis;
  end;

  { cLineSeries
    Набор точек X/Y. Используется как база для редактируемого cTrend
    и двухмерных буферов. }
  cLineSeries = class(cBaseTrend)
  private
    fPoints: array of TChartPoint;

    function GetPoint(AIndex: Integer): TChartPoint;
    function GetPointCount: Integer;
  public
    procedure AssignDefaultProperties; override;
    procedure ClearPoints;
    procedure AddPoint(AX, AY: Double);

    property Points[AIndex: Integer]: TChartPoint read GetPoint;
    property PointCount: Integer read GetPointCount;
  end;

  { cTrend
    Редактируемая ломаная/тренд. Позже сюда переедут сплайны и узлы редактирования. }
  cTrend = class(cLineSeries)
  public
    procedure AssignDefaultProperties; override;
  end;

  { cBuffTrend1d
    Одномерный равномерный буфер: X вычисляется как X0 + Index * DX. }
  cBuffTrend1d = class(cBaseTrend)
  private
    fX0: Double;
    fDX: Double;
    fValues: array of Double;

    function GetCount: Integer;
    function GetValue(AIndex: Integer): Double;
  public
    procedure AssignDefaultProperties; override;
    procedure ClearValues;
    procedure AddValue(AY: Double);

    property X0: Double read fX0 write fX0;
    property DX: Double read fDX write fDX;
    property Values[AIndex: Integer]: Double read GetValue;
    property Count: Integer read GetCount;
  end;

  { cBuffTrend2d
    Буфер X/Y. Пока использует хранение cLineSeries, позже можно добавить
    специализированное хранение без лишних копий. }
  cBuffTrend2d = class(cLineSeries)
  public
    procedure AssignDefaultProperties; override;
  end;

  TChartSeries = cBaseTrend;
  TChartLineSeries = cLineSeries;
  cSeries = cBaseTrend;

implementation

procedure cBaseTrend.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Series';
  Caption := 'Series';
  fXAxis := nil;
end;

procedure cLineSeries.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'LineSeries';
  Caption := 'Line series';
  Color := $FFFF0000;
  SetLength(fPoints, 0);
end;

function cLineSeries.GetPoint(AIndex: Integer): TChartPoint;
begin
  Result := fPoints[AIndex];
end;

function cLineSeries.GetPointCount: Integer;
begin
  Result := Length(fPoints);
end;

procedure cLineSeries.ClearPoints;
begin
  SetLength(fPoints, 0);
end;

procedure cLineSeries.AddPoint(AX, AY: Double);
var
  lIndex: Integer;
begin
  lIndex := Length(fPoints);
  SetLength(fPoints, lIndex + 1);
  fPoints[lIndex].X := AX;
  fPoints[lIndex].Y := AY;
end;

procedure cTrend.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Trend';
  Caption := 'Trend';
end;

procedure cBuffTrend1d.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'BuffTrend1d';
  Caption := 'Buffer trend 1D';
  fX0 := 0;
  fDX := 1;
  Color := $FF0090FF;
  SetLength(fValues, 0);
end;

function cBuffTrend1d.GetCount: Integer;
begin
  Result := Length(fValues);
end;

function cBuffTrend1d.GetValue(AIndex: Integer): Double;
begin
  Result := fValues[AIndex];
end;

procedure cBuffTrend1d.ClearValues;
begin
  SetLength(fValues, 0);
end;

procedure cBuffTrend1d.AddValue(AY: Double);
var
  lIndex: Integer;
begin
  lIndex := Length(fValues);
  SetLength(fValues, lIndex + 1);
  fValues[lIndex] := AY;
end;

procedure cBuffTrend2d.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'BuffTrend2d';
  Caption := 'Buffer trend 2D';
end;

end.
