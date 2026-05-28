import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartTrend.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")

code_content = """unit uOglChartTrend;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uOglChartTypes, uCommonTypes, uOglChartDrawObj, uOglChartAxis;

type
  TBeziePointType = (bptCorner, bptSmooth, bptNull);

  { cBeziePoint }
  cBeziePoint = class(TObject)
  private
    fPoint: TChartPoint;
    fLeft: TChartPoint;
    fRight: TChartPoint;
    fType: TBeziePointType;
    fSelected: Boolean;
  public
    constructor Create(AX, AY: Double; AType: TBeziePointType = bptCorner);

    property Point: TChartPoint read fPoint write fPoint;
    property Left: TChartPoint read fLeft write fLeft;
    property Right: TChartPoint read fRight write fRight;
    property PointType: TBeziePointType read fType write fType;
    property Selected: Boolean read fSelected write fSelected;
  end;

  { cBaseTrend }
  cBaseTrend = class(cDrawObj)
  public
    procedure AssignDefaultProperties; override;
  end;

  { cLineSeries }
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

  { cTrend }
  cTrend = class(cLineSeries)
  private
    fBeziePoints: array of cBeziePoint;
    fShowPoints: Boolean;
    fSmooth: Boolean;

    function GetBeziePoint(AIndex: Integer): cBeziePoint;
    function GetBeziePointCount: Integer;
  public
    procedure AssignDefaultProperties; override;
    destructor Destroy; override;

    procedure Clear;
    procedure AddBeziePoint(AX, AY: Double; AType: TBeziePointType = bptCorner);
    procedure GenerateSplinePoints;
    procedure UpdateBeziePoint(AIndex: Integer; AX, AY: Double);

    property BeziePoints[AIndex: Integer]: cBeziePoint read GetBeziePoint;
    property BeziePointCount: Integer read GetBeziePointCount;
    property ShowPoints: Boolean read fShowPoints write fShowPoints;
    property Smooth: Boolean read fSmooth write fSmooth;
  end;

  { cBuffTrend1d }
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

  { cBuffTrend2d }
  cBuffTrend2d = class(cLineSeries)
  public
    procedure AssignDefaultProperties; override;
  end;

  TChartSeries = cBaseTrend;
  TChartLineSeries = cLineSeries;
  cSeries = cBaseTrend;

implementation

{ cBeziePoint }

constructor cBeziePoint.Create(AX, AY: Double; AType: TBeziePointType);
begin
  inherited Create;
  fPoint.X := AX;
  fPoint.Y := AY;
  fLeft := fPoint;
  fRight := fPoint;
  fType := AType;
  fSelected := False;
end;

{ cBaseTrend }

procedure cBaseTrend.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Series';
  Caption := 'Series';
end;

{ cLineSeries }

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

{ cTrend }

procedure cTrend.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Trend';
  Caption := 'Trend';
  fShowPoints := True;
  fSmooth := True;
  SetLength(fBeziePoints, 0);
end;

destructor cTrend.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure cTrend.Clear;
var
  I: Integer;
begin
  for I := 0 to High(fBeziePoints) do
    fBeziePoints[I].Free;
  SetLength(fBeziePoints, 0);
  ClearPoints;
end;

function cTrend.GetBeziePoint(AIndex: Integer): cBeziePoint;
begin
  Result := fBeziePoints[AIndex];
end;

function cTrend.GetBeziePointCount: Integer;
begin
  Result := Length(fBeziePoints);
end;

procedure cTrend.AddBeziePoint(AX, AY: Double; AType: TBeziePointType);
var
  lIndex: Integer;
begin
  lIndex := Length(fBeziePoints);
  SetLength(fBeziePoints, lIndex + 1);
  fBeziePoints[lIndex] := cBeziePoint.Create(AX, AY, AType);
end;

procedure cTrend.GenerateSplinePoints;
var
  I, J: Integer;
  bp, lp, rp: cBeziePoint;
  t: Double;
  p0, p1, p2, p3: TChartPoint;
  lSteps: Integer;
begin
  for I := 0 to High(fBeziePoints) do
  begin
    bp := fBeziePoints[I];
    if bp.PointType = bptSmooth then
    begin
      if I > 0 then
      begin
        lp := fBeziePoints[I - 1];
        bp.fLeft.X := bp.Point.X - (bp.Point.X - lp.Point.X) * 0.25;
        bp.fLeft.Y := bp.Point.Y - (bp.Point.Y - lp.Point.Y) * 0.25;
      end
      else
        bp.fLeft := bp.Point;

      if I < High(fBeziePoints) then
      begin
        rp := fBeziePoints[I + 1];
        bp.fRight.X := bp.Point.X + (rp.Point.X - bp.Point.X) * 0.25;
        bp.fRight.Y := bp.Point.Y + (rp.Point.Y - bp.Point.Y) * 0.25;
      end
      else
        bp.fRight := bp.Point;
    end
    else
    begin
      bp.fLeft := bp.Point;
      bp.fRight := bp.Point;
    end;
  end;

  ClearPoints;

  if Length(fBeziePoints) = 0 then Exit;

  if not fSmooth or (Length(fBeziePoints) < 2) then
  begin
    for I := 0 to High(fBeziePoints) do
      AddPoint(fBeziePoints[I].Point.X, fBeziePoints[I].Point.Y);
    Exit;
  end;

  lSteps := 20;
  for I := 0 to High(fBeziePoints) - 1 do
  begin
    bp := fBeziePoints[I];
    rp := fBeziePoints[I + 1];

    p0 := bp.Point;
    if bp.PointType = bptSmooth then
      p1 := bp.Right
    else
      p1 := p0;

    if rp.PointType = bptSmooth then
      p2 := rp.Left
    else
      p2 := rp.Point;

    p3 := rp.Point;

    if rp.PointType = bptNull then
    begin
      AddPoint(p0.X, p0.Y);
      AddPoint(p3.X, p0.Y);
    end
    else
    begin
      for J := 0 to lSteps - 1 do
      begin
        t := J / lSteps;
        AddPoint(
          (1-t)*(1-t)*(1-t) * p0.X + 3*(1-t)*(1-t)*t * p1.X + 3*(1-t)*t*t * p2.X + t*t*t * p3.X,
          (1-t)*(1-t)*(1-t) * p0.Y + 3*(1-t)*(1-t)*t * p1.Y + 3*(1-t)*t*t * p2.Y + t*t*t * p3.Y
        );
      end;
    end;
  end;

  AddPoint(fBeziePoints[High(fBeziePoints)].Point.X, fBeziePoints[High(fBeziePoints)].Point.Y);
end;

procedure cTrend.UpdateBeziePoint(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fPoint.X := AX;
    fBeziePoints[AIndex].fPoint.Y := AY;
    GenerateSplinePoints;
  end;
end;

{ cBuffTrend1d }

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

{ cBuffTrend2d }

procedure cBuffTrend2d.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'BuffTrend2d';
  Caption := 'Buffer trend 2D';
end;

end.
"""

with open(FILE_PATH, 'wb') as f:
    f.write(code_content.encode('cp1251'))

print("File updated successfully.")
