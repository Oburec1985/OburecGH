unit uOglChartTrend;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uOglChartTypes,
  //uCommonTypes,
  uOglChartDrawObj, uOglChartAxis;

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
  /// <summary>
  /// Базовый класс для всех серий трендов и линий на графике.
  /// </summary>
  cBaseTrend = class(cDrawObj)
  private
    fGLListID: Cardinal;                // ID скомпилированного списка OpenGL
    fGLListContextVersion: Cardinal;    // Версия контекста OpenGL для списка
  public
    procedure AssignDefaultProperties; override;
    /// <summary> Идентификатор списка OpenGL для ускоренной отрисовки. </summary>
    property GLListID: Cardinal read fGLListID write fGLListID;
    /// <summary> Версия контекста для контроля пересоздания окна. </summary>
    property GLListContextVersion: Cardinal read fGLListContextVersion write fGLListContextVersion;
  end;

  { cLineSeries }
  /// <summary>
  /// Серия линий графика, состоящая из набора 2D точек с вещественными координатами.
  /// </summary>
  cLineSeries = class(cBaseTrend)
  private
    fPoints: array of TChartPoint;       // Внутренний динамический массив точек

    function GetPoint(AIndex: Integer): TChartPoint;
    function GetPointCount: Integer;
  public
    procedure AssignDefaultProperties; override;
    /// <summary> Полная очистка точек серии. </summary>
    procedure ClearPoints;
    /// <summary> Добавление одной точки в конец серии. </summary>
    procedure AddPoint(AX, AY: Double);
    /// <summary> Пакетное (быстрое) добавление массива точек. </summary>
    procedure AddPoints(const APoints: array of TChartPoint);

    /// <summary> Доступ к точкам по индексу. </summary>
    property Points[AIndex: Integer]: TChartPoint read GetPoint;
    /// <summary> Общее количество точек в серии. </summary>
    property PointCount: Integer read GetPointCount;
  end;

  { cTrend }
  /// <summary>
  /// Класс сплайнового тренда, поддерживающий опорные точки Безье и сглаживание.
  /// </summary>
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
    procedure UpdateBezieLeft(AIndex: Integer; AX, AY: Double);
    procedure UpdateBezieRight(AIndex: Integer; AX, AY: Double);
    procedure DeleteBeziePoint(AIndex: Integer);
    procedure InsertBeziePoint(AX, AY: Double; AType: TBeziePointType = bptCorner);

    property BeziePoints[AIndex: Integer]: cBeziePoint read GetBeziePoint;
    property BeziePointCount: Integer read GetBeziePointCount;
    property ShowPoints: Boolean read fShowPoints write fShowPoints;
    property Smooth: Boolean read fSmooth write fSmooth;
  end;

  { cBuffTrend1d }
  /// <summary>
  /// Одномерный буферизованный тренд с равномерным шагом по оси X.
  /// </summary>
  cBuffTrend1d = class(cBaseTrend)
  private
    fX0: Double;                         // Начальная координата X
    fDX: Double;                        // Шаг по оси X между точками
    fValues: array of Double;           // Массив Y-значений точек

    function GetCount: Integer;
    function GetValue(AIndex: Integer): Double;
  public
    procedure AssignDefaultProperties; override;
    /// <summary> Очистка буфера значений. </summary>
    procedure ClearValues;
    /// <summary> Добавление одиночного Y-значения. </summary>
    procedure AddValue(AY: Double);
    /// <summary> Пакетное (быстрое) добавление массива Y-значений. </summary>
    procedure AddValues(const AValues: array of Double);

    /// <summary> Начальная точка на оси X. </summary>
    property X0: Double read fX0 write fX0;
    /// <summary> Шаг точек на оси X. </summary>
    property DX: Double read fDX write fDX;
    /// <summary> Доступ к Y-значениям по индексу. </summary>
    property Values[AIndex: Integer]: Double read GetValue;
    /// <summary> Количество точек в буфере. </summary>
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
  GLListID := 0;
end;

procedure cLineSeries.AddPoint(AX, AY: Double);
var
  lIndex: Integer;
begin
  lIndex := Length(fPoints);
  SetLength(fPoints, lIndex + 1);
  fPoints[lIndex].X := AX;
  fPoints[lIndex].Y := AY;
  GLListID := 0;
end;

procedure cLineSeries.AddPoints(const APoints: array of TChartPoint);
var
  lOldLen, lNewLen, i: Integer;
begin
  lOldLen := Length(fPoints);
  lNewLen := lOldLen + Length(APoints);
  SetLength(fPoints, lNewLen);
  for i := 0 to High(APoints) do
    fPoints[lOldLen + i] := APoints[i];
  GLListID := 0;
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
      // Инициализируем left и right только если они равны point (т.е. не были перетащены вручную)
      if (bp.fLeft.X = bp.Point.X) and (bp.fLeft.Y = bp.Point.Y) then
      begin
        if I > 0 then
        begin
          lp := fBeziePoints[I - 1];
          bp.fLeft.X := bp.Point.X - (bp.Point.X - lp.Point.X) * 0.25;
          bp.fLeft.Y := bp.Point.Y - (bp.Point.Y - lp.Point.Y) * 0.25;
        end
        else
          bp.fLeft := bp.Point;
      end;

      if (bp.fRight.X = bp.Point.X) and (bp.fRight.Y = bp.Point.Y) then
      begin
        if I < High(fBeziePoints) then
        begin
          rp := fBeziePoints[I + 1];
          bp.fRight.X := bp.Point.X + (rp.Point.X - bp.Point.X) * 0.25;
          bp.fRight.Y := bp.Point.Y + (rp.Point.Y - bp.Point.Y) * 0.25;
        end
        else
          bp.fRight := bp.Point;
      end;
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
var
  lDiffX, lDiffY: Double;
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    lDiffX := AX - fBeziePoints[AIndex].fPoint.X;
    lDiffY := AY - fBeziePoints[AIndex].fPoint.Y;

    fBeziePoints[AIndex].fPoint.X := AX;
    fBeziePoints[AIndex].fPoint.Y := AY;

    // Смещаем касательные усы вслед за центральной точкой
    fBeziePoints[AIndex].fLeft.X := fBeziePoints[AIndex].fLeft.X + lDiffX;
    fBeziePoints[AIndex].fLeft.Y := fBeziePoints[AIndex].fLeft.Y + lDiffY;
    fBeziePoints[AIndex].fRight.X := fBeziePoints[AIndex].fRight.X + lDiffX;
    fBeziePoints[AIndex].fRight.Y := fBeziePoints[AIndex].fRight.Y + lDiffY;

    GenerateSplinePoints;
  end;
end;

procedure cTrend.UpdateBezieLeft(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fLeft.X := AX;
    fBeziePoints[AIndex].fLeft.Y := AY;
    GenerateSplinePoints;
  end;
end;

procedure cTrend.UpdateBezieRight(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fRight.X := AX;
    fBeziePoints[AIndex].fRight.Y := AY;
    GenerateSplinePoints;
  end;
end;

procedure cTrend.DeleteBeziePoint(AIndex: Integer);
var
  I: Integer;
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].Free;
    for I := AIndex to Length(fBeziePoints) - 2 do
      fBeziePoints[I] := fBeziePoints[I + 1];
    SetLength(fBeziePoints, Length(fBeziePoints) - 1);
    GenerateSplinePoints;
  end;
end;

procedure cTrend.InsertBeziePoint(AX, AY: Double; AType: TBeziePointType);
var
  I, J, lInsertIdx: Integer;
  bp: cBeziePoint;
begin
  lInsertIdx := Length(fBeziePoints);
  for I := 0 to High(fBeziePoints) do
  begin
    if fBeziePoints[I].Point.X > AX then
    begin
      lInsertIdx := I;
      Break;
    end;
  end;

  SetLength(fBeziePoints, Length(fBeziePoints) + 1);
  for J := Length(fBeziePoints) - 1 downto lInsertIdx + 1 do
    fBeziePoints[J] := fBeziePoints[J - 1];

  bp := cBeziePoint.Create(AX, AY, AType);
  bp.Selected := True;
  fBeziePoints[lInsertIdx] := bp;

  for J := 0 to Length(fBeziePoints) - 1 do
    if J <> lInsertIdx then
      fBeziePoints[J].Selected := False;

  GenerateSplinePoints;
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
  GLListID := 0;
end;

procedure cBuffTrend1d.AddValue(AY: Double);
var
  lIndex: Integer;
begin
  lIndex := Length(fValues);
  SetLength(fValues, lIndex + 1);
  fValues[lIndex] := AY;
  GLListID := 0;
end;

procedure cBuffTrend1d.AddValues(const AValues: array of Double);
var
  lOldLen, lNewLen, i: Integer;
begin
  lOldLen := Length(fValues);
  lNewLen := lOldLen + Length(AValues);
  SetLength(fValues, lNewLen);
  for i := 0 to High(AValues) do
    fValues[lOldLen + i] := AValues[i];
  GLListID := 0;
end;

{ cBuffTrend2d }

procedure cBuffTrend2d.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'BuffTrend2d';
  Caption := 'Buffer trend 2D';
end;

end.
