unit uOglChartTrend;

{$mode objfpc}{$H+}
{$codepage UTF8}

{
  Модуль uOglChartTrend
  Описание: Содержит классы серий данных и графиков. Реализует структуру данных для хранения
            опорных точек Безье (cBeziePoint), кубическую сплайн-интерполяцию (cTrend)
            и буферизированные одномерные ряды данных (cBuffTrend1d) с оптимизированным
            хранением Y-значений.
}

interface

uses
  Classes, SysUtils, uOglChartTypes, uOglChartDrawObj, uOglChartAxis,
  uSharedQueue;

type
  { TBeziePointType }
  // Тип опорного узла на сплайне Безье
  TBeziePointType = (
    bptCorner,  // Острый излом (касательные прижаты к центральной точке)
    bptSmooth,  // Сглаженный изгиб (две независимые касательные точки слева и справа)
    bptNull     // Пустая точка (разрыв на графике)
  );

  { cBeziePoint }
  // Опорный узел сплайна Безье. Хранит центральную точку и две касательные ("усы") слева и справа.
  cBeziePoint = class(TObject)
  private
    fPoint: TChartPoint;                 // Центральная координата узла
    fLeft: TChartPoint;                  // Левая касательная точка управления сплайном
    fRight: TChartPoint;                 // Правая касательная точка управления сплайном
    fType: TBeziePointType;              // Тип сглаживания узла
    fSelected: Boolean;                  // Флаг выделения узла пользователем
  public
    constructor Create(AX, AY: Double; AType: TBeziePointType = bptCorner);

    property Point: TChartPoint read fPoint write fPoint;
    property Left: TChartPoint read fLeft write fLeft;
    property Right: TChartPoint read fRight write fRight;
    property PointType: TBeziePointType read fType write fType;
    property Selected: Boolean read fSelected write fSelected;
  end;

  { cBaseTrend }
  // Базовый класс для всех серий трендов и линий на графике.
  cBaseTrend = class(cDrawObj)
  private
    fGLListID: Cardinal;                // ID скомпилированного списка OpenGL для кеширования геометрии
    fGLListContextVersion: Cardinal;    // Версия контекста OpenGL для контроля пересоздания списка
  public
    procedure AssignDefaultProperties; override;

    property GLListID: Cardinal read fGLListID write fGLListID;
    property GLListContextVersion: Cardinal read fGLListContextVersion write fGLListContextVersion;
  end;

  { cLineSeries }
  // Серия линий графика, состоящая из набора 2D точек с вещественными координатами.
  cLineSeries = class(cBaseTrend)
  private
    fPoints: array of TChartPoint;       // Внутренний динамический массив точек серии

    function GetPoint(AIndex: Integer): TChartPoint;
    function GetPointCount: Integer;
  public
    procedure AssignDefaultProperties; override;
    // Очищает все точки серии и сбрасывает кэш списка OpenGL
    procedure ClearPoints;
    // Добавление одной точки в конец серии
    procedure AddPoint(AX, AY: Double);
    // Пакетное добавление массива точек
    procedure AddPoints(const APoints: array of TChartPoint);

    property Points[AIndex: Integer]: TChartPoint read GetPoint;
    property PointCount: Integer read GetPointCount;
  end;

  { cTrend }
  // Класс сплайнового тренда, поддерживающий опорные точки Безье и сглаживание.
  cTrend = class(cLineSeries)
  private
    fBeziePoints: array of cBeziePoint;  // Массив опорных точек
    fShowPoints: Boolean;                // Показывать ли маркеры опорных точек
    fSmooth: Boolean;                    // Включена ли сплайн-интерполяция Безье

    function GetBeziePoint(AIndex: Integer): cBeziePoint;
    function GetBeziePointCount: Integer;
  public
    procedure AssignDefaultProperties; override;
    destructor Destroy; override;

    // Полная очистка точек и сплайнов
    procedure Clear;
    // Добавление опорного узла
    procedure AddBeziePoint(AX, AY: Double; AType: TBeziePointType = bptCorner);
    // Генерирует промежуточные точки интерполяции на основе кубической кривой Безье
    procedure GenerateSplinePoints;
    // Обновляет координаты опорного узла и сдвигает за ним касательные "усы"
    procedure UpdateBeziePoint(AIndex: Integer; AX, AY: Double);
    // Обновляет левую касательную точку
    procedure UpdateBezieLeft(AIndex: Integer; AX, AY: Double);
    // Обновляет правую касательную точку
    procedure UpdateBezieRight(AIndex: Integer; AX, AY: Double);
    // Удаляет опорный узел из списка и пересчитывает сплайн
    procedure DeleteBeziePoint(AIndex: Integer);
    // Вставляет опорный узел в правильную позицию по оси X с сортировкой
    procedure InsertBeziePoint(AX, AY: Double; AType: TBeziePointType = bptCorner);

    property BeziePoints[AIndex: Integer]: cBeziePoint read GetBeziePoint;
    property BeziePointCount: Integer read GetBeziePointCount;
    property ShowPoints: Boolean read fShowPoints write fShowPoints;
    property Smooth: Boolean read fSmooth write fSmooth;
  end;

  { cBuffTrend1d }
  // Одномерный буферизованный тренд с равномерным шагом по оси X.
  // Идеален для быстрых непрерывных графиков (осциллограф, телеметрия).
  cBuffTrend1d = class(cBaseTrend)
  private
    fX0: Double;                         // Начальная координата X
    fDX: Double;                        // Шаг по оси X между точками
    fValues: array of Double;           // Массив Y-значений точек

    function GetCount: Integer;
    function GetValue(AIndex: Integer): Double;
  public
    procedure AssignDefaultProperties; override;
    // Очищает буфер значений и сбрасывает OpenGL кэш
    procedure ClearValues;
    // Добавление одиночного Y-значения
    procedure AddValue(AY: Double);
    // Пакетное добавление массива Y-значений
    procedure AddValues(const AValues: array of Double);

    property X0: Double read fX0 write fX0;
    property DX: Double read fDX write fDX;
    property Values[AIndex: Integer]: Double read GetValue;
    property Count: Integer read GetCount;
  end;

  { cBuffTrendQueue }
  // 2D queue trend with preallocated storage for realtime sliding windows.
  cBuffTrendQueue = class(cBaseTrend)
  private
    fPoints: specialize cQueue<TChartPoint>;
    function GetCapacity: Integer;
    function GetCount: Integer;
    function GetPoint(AIndex: Integer): TChartPoint;
    function GetFirstTime: Double;
    function GetLastTime: Double;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AssignDefaultProperties; override;

    procedure Allocate(ACapacity: Integer);
    procedure ClearPoints;
    procedure AddPoint(AX, AY: Double);

    property Capacity: Integer read GetCapacity;
    property Count: Integer read GetCount;
    property Points[AIndex: Integer]: TChartPoint read GetPoint;
    property FirstTime: Double read GetFirstTime;
    property LastTime: Double read GetLastTime;
  end;
  { cBuffTrend2d }
  // Зарезервирован под двумерные карты или растровые графики
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
  // Изначально усы Безье совпадают с центральной точкой
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

/// <summary>
/// Основной алгоритм интерполяции сплайна Безье.
/// Проходит по всем опорным узлам Безье, автоматически вычисляет "усы" управления,
/// если они еще не были перетащены пользователем вручную, а затем рассчитывает кубическую интерполяцию
/// для 20 шагов между каждой парой опорных точек и добавляет полученные вершины в плоский список fPoints.
/// </summary>
procedure cTrend.GenerateSplinePoints;
var
  I, J: Integer;
  bp, lp, rp: cBeziePoint;
  t: Double;
  p0, p1, p2, p3: TChartPoint;
  lSteps: Integer;
begin
  // Шаг 1. Автоматическая расстановка усов управления для сглаженных точек (если они равны центру)
  for I := 0 to High(fBeziePoints) do
  begin
    bp := fBeziePoints[I];
    if bp.PointType = bptSmooth then
    begin
      // Авто-левый ус: сдвинут к предыдущей точке на 25% расстояния
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

      // Авто-правый ус: сдвинут к следующей точке на 25% расстояния
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
      // Для ломаных углов (Corner) или разрывов усы совпадают с центром
      bp.fLeft := bp.Point;
      bp.fRight := bp.Point;
    end;
  end;

  ClearPoints;

  if Length(fBeziePoints) = 0 then Exit;

  // Если сглаживание отключено или точек меньше двух - просто выводим ломаную линию по опорным точкам
  if not fSmooth or (Length(fBeziePoints) < 2) then
  begin
    for I := 0 to High(fBeziePoints) do
      AddPoint(fBeziePoints[I].Point.X, fBeziePoints[I].Point.Y);
    Exit;
  end;

  lSteps := 20; // Шагов разбиения сегмента
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

    // Если следующий узел является типом разрыва (Null) - рисуем ступеньку вместо кубического сплайна
    if rp.PointType = bptNull then
    begin
      AddPoint(p0.X, p0.Y);
      AddPoint(p3.X, p0.Y);
    end
    else
    begin
      // Вычисление полинома Безье третьей степени по четырем точкам p0, p1, p2, p3
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

  // Добавляем финальную точку сплайна
  AddPoint(fBeziePoints[High(fBeziePoints)].Point.X, fBeziePoints[High(fBeziePoints)].Point.Y);
end;

/// <summary>
/// Обновляет координаты опорного узла и смещает управляющие "усы" Безье вслед за ним
/// на величину смещения (чтобы сохранить форму изгиба при перемещении узла).
/// </summary>
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
    // Сдвиг массива при удалении элемента
    for I := AIndex to Length(fBeziePoints) - 2 do
      fBeziePoints[I] := fBeziePoints[I + 1];
    SetLength(fBeziePoints, Length(fBeziePoints) - 1);
    GenerateSplinePoints;
  end;
end;

/// <summary>
/// Вставка новой опорной точки Безье на график.
/// Находит правильный индекс на основе X-координаты для сохранения упорядоченности ряда данных.
/// После вставки автоматически выделяет добавленную точку и пересчитывает интерполяцию.
/// </summary>
procedure cTrend.InsertBeziePoint(AX, AY: Double; AType: TBeziePointType);
var
  I, J, lInsertIdx: Integer;
  bp: cBeziePoint;
begin
  lInsertIdx := Length(fBeziePoints);
  // Линейный поиск позиции для сохранения сортировки по X
  for I := 0 to High(fBeziePoints) do
  begin
    if fBeziePoints[I].Point.X > AX then
    begin
      lInsertIdx := I;
      Break;
    end;
  end;

  SetLength(fBeziePoints, Length(fBeziePoints) + 1);
  // Сдвиг элементов для освобождения места
  for J := Length(fBeziePoints) - 1 downto lInsertIdx + 1 do
    fBeziePoints[J] := fBeziePoints[J - 1];

  bp := cBeziePoint.Create(AX, AY, AType);
  bp.Selected := True;
  fBeziePoints[lInsertIdx] := bp;

  // Снимаем выделение со всех остальных точек тренда
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
  Color := $FF0090FF; // Голубой цвет
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

{ cBuffTrendQueue }

constructor cBuffTrendQueue.Create;
begin
  inherited Create;
  fPoints := specialize cQueue<TChartPoint>.Create;
end;

destructor cBuffTrendQueue.Destroy;
begin
  fPoints.Free;
  inherited Destroy;
end;

procedure cBuffTrendQueue.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'BuffTrendQueue';
  Caption := 'Buffer trend queue';
  Color := $FFFF0000;
end;

function cBuffTrendQueue.GetCapacity: Integer;
begin
  if fPoints = nil then
    Result := 0
  else
    Result := fPoints.Capacity;
end;

function cBuffTrendQueue.GetCount: Integer;
begin
  if fPoints = nil then
    Result := 0
  else
    Result := fPoints.Count;
end;

function cBuffTrendQueue.GetPoint(AIndex: Integer): TChartPoint;
begin
  Result := fPoints[AIndex];
end;

function cBuffTrendQueue.GetFirstTime: Double;
begin
  if Count <= 0 then
    Result := 0
  else
    Result := Points[0].X;
end;

function cBuffTrendQueue.GetLastTime: Double;
begin
  if Count <= 0 then
    Result := 0
  else
    Result := Points[Count - 1].X;
end;

procedure cBuffTrendQueue.Allocate(ACapacity: Integer);
begin
  fPoints.SetCapacity(ACapacity);
  GLListID := 0;
end;

procedure cBuffTrendQueue.ClearPoints;
begin
  if fPoints <> nil then
    fPoints.Clear;
  GLListID := 0;
end;

procedure cBuffTrendQueue.AddPoint(AX, AY: Double);
var
  lPoint: TChartPoint;
begin
  lPoint.X := AX;
  lPoint.Y := AY;
  fPoints.PushBack(lPoint);
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
