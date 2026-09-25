unit u2DMath;

interface
uses math, uCommonTypes, classes;

type
  // сплайн 4-о порядка
  CubicSpline = record
    // если создан точками типа c_corner то просто линия
    Smooth:boolean;
    // елси правая точка нулевая интерполяция
    nullPoly:boolean;
    p0,p1,p2,p3:point2;
  end;

  TPointArray = array of point2;
  TPointArrayd = array of point2d;

  TDiameterResult = record
    Point1: point2;
    Point2: point2;
    Index1: Integer;
    Index2: Integer;
    Distance: Double;
  end;

// Определение записи для хранения экстремума
  // Мы будем хранить указатели на динамически созданные записи TExtremum в TList.
  PExtremum = ^TExtremum;
  TExtremum = record
    Index: Integer; // Индекс элемента в исходном массиве Point2D
    Value: Double;  // Значение экстремума (координата Y Point2D)
    Point: Point2D; // Полная точка, соответствующая экстремуму
  end;

  TExtremum1d = record
    Index: Integer; // Индекс элемента в исходном массиве Y
    Value: Double;  // Значение экстремума (найденное Y-значение)
    //BandNum:integer; // в полосе № (-1 если не попал в полосу)
    //NumInBand:integer; // номер экстремума внутри той же полосы
  end;

  TExtremumSearchState = (
    esIdle,           // Состояние ожидания: ждем, пока значение поднимется выше HiLevel
    esAboveHiLevel,   // Состояние "Над HiLevel": значение выше HiLevel, ищем максимум
    esFoundExtremum,  // Состояние "Найден экстремум": значение опустилось ниже LoLevel, экстремум зафиксирован
    esHi   // Состояние "Найден экстремум": значение опустилось ниже LoLevel, экстремум зафиксирован
  );

  PExtremum1d =^TExtremum1d;

  // поиск выпуклой оболочки
  //function GrahamScan(const Points: TPointArray; p_size:integer): TPointArray;
  function GrahamScanWithDiameter(const Points: TPointArray; p_size:integer;
          out Diameter: TDiameterResult): TPointArray;


//px, py — координаты точки, от которой рассчитывается расстояние.
//A, x0, fA, y0 — параметры экспоненциальной кривой y = A * exp(-(x + x0) * fA) + y0.
//XMin, XMax — интервал поиска минимума по оси X.
// расстояние до экспоненты от точки px,py y=A*exp(-fA*(x+x0))+y0
function DistanceToExponential(px, py, A, x0, fA, y0, XMin, XMax: Double): Double;

function NearestPCubicSpline(spline:cubicspline; Ap:point2d):point2d;
function DistPtoCubicSpline(spline:cubicspline; Ap:point2d):double;
// Отыскивает только действительные корни
Function CubicRoot(a, b, c, d: single;var x:array of single):integer;
// находит параметр u сплайна соответствующий x-у
function FindPointOnSpline(spline:CubicSpline;x:single):single;
// Вычисляет точку на кубическом сплайне по известному u
function EvalSplinePoint(u:single; spline:cubicspline):point2;
// Вычисляет точку на прямой
function EvalLineY(x:single; p1,p2:point2):single;
function EvalLineYd(x:double; p1,p2:point2d):double;overload;
function EvalLineYd(x:double; px1,py1, px2, py2:double):double;overload;
function EvalLineX(y:double; p1,p2:point2d):double;
// пересечение двух прямых на плоскости
function EvalIntersectd(LineAP1, LineAP2, LineBP1, LineBP2 : point2d) : point2d;
function EvalIntersect(LineAP1, LineAP2, LineBP1, LineBP2 : point2) : point2;

  // Функция для поиска экстремумов
  // Параметры:
  //   Points: Входной массив записей TPoint2D. Координата Y используется для поиска экстремумов.
  //   StartIndex, EndIndex: Индексы начала и конца поиска в массиве (включительно)
  //   HiLevel, LoLevel: Верхний и нижний уровни для определения экстремума
  //   Extremums: Выходной список, куда будут добавлены найденные экстремумы
  // Возвращает True, если найден хотя бы один экстремум, иначе False.
  function FindExtremumsFromPoints(const Points: TPointArrayd; StartIndex, EndIndex: Integer;
    HiLevel, LoLevel: Double; Extremums: TList): Boolean;
  // Функция для поиска экстремумов в одномерном массиве значений Y
  // Параметры:
  //   Y: Входной массив значений Double.
  //   StartIndex, EndIndex: Индексы начала и конца поиска в массиве (включительно)
  //   HiLevel, LoLevel: Верхний и нижний уровни для определения экстремума
  //   Extremums: Выходной список, куда будут добавлены найденные экстремумы.
  //              Каждый элемент списка - это PExtremum, содержащий Index и Value.
  // Возвращает True, если найден хотя бы один экстремум, иначе False.
  // освобождать экстремумы надо с пом Dispose(Extr)
  function FindExtremumsInY(const Y: array of double; StartIndex, EndIndex: Integer;
    HiLevel, LoLevel: Double; Extremums: TList): Boolean;


implementation
const
  //GR = (1 + Sqrt(5))/2; // Золотое сечение
  GR = 1.618033988749895 ;

type
  TFunc = function(x, px, py, A, x0, fA, y0: Double): Double;


function SquareDistance(x, px, py, A, x0, fA, y0: Double): Double;
begin
  Result := Sqr(x - px) + Sqr(A * Exp(-(x + x0) * fA) + y0 - py);
end;

function GoldenSectionSearch(a, b, Tolerance: Double; Func: TFunc; px, py, Ay, x0, fA, y0: Double): Double;
var
  c, d, fc, fd: Double;
begin
  c := b - (b - a) / GR;
  d := a + (b - a) / GR;

  while (b - a) > Tolerance do
  begin
    fc := Func(c, px, py, Ay, x0, fA, y0);
    fd := Func(d, px, py, Ay, x0, fA, y0);

    if fc < fd then
    begin
      b := d;
      d := c;
      c := b - (b - a) / GR;
    end
    else
    begin
      a := c;
      c := d;
      d := a + (b - a) / GR;
    end;
  end;
  Result := (a + b) / 2;
end;

function DistanceToExponential(px, py, A, x0, fA, y0, XMin, XMax: Double): Double;
var
  MinX: Double;
begin
  // Находим X, соответствующий минимальному расстоянию
  MinX := GoldenSectionSearch(
    XMin, XMax, 1e-6,
    @SquareDistance,
    px, py, A, x0, fA, y0
  );
  // Вычисляем минимальное расстояние
  Result := Sqrt(SquareDistance(MinX, px, py, A, x0, fA, y0));
end;

// Вычисляет точку на кубическом сплайне по известному u
function EvalSplinePoint(u:single;spline:cubicspline):point2;
var
  u2,u3,
  B0,B1,B2,B3:single;
begin
  u2:=u*u;u3:=u2*u;
  B0:=1-3*u+3*u2-u3;
  B1:=3*u-6*u2+3*u3;
  B2:=3*u2-3*u3;
  B3:=u3;
  result.x:=B0*spline.p0.x+B1*spline.p1.x+B2*spline.p2.x+B3*spline.p3.x;
  result.y:=B0*spline.p0.y+B1*spline.p1.y+B2*spline.p2.y+B3*spline.p3.y;
end;


// находит параметр по u по известному x
function FindPointOnSpline(spline:CubicSpline;x:single):single;
var a,b,c,d:single;
    roots:array[0..2] of single;
    rootCount,i:integer;
begin
  a:=3*spline.p1.x-spline.p0.x-3*spline.p2.x+spline.p3.x;
  b:=3*spline.p0.x+3*spline.p2.x-6*spline.p1.x;
  c:=-3*spline.p0.x+3*spline.p1.x;
  d:=spline.p0.x;
  rootCount:=CubicRoot(a, b, c, d-x, roots);
  for i := 0 to rootCount - 1 do
  begin
    if ((roots[i]>=0) and (roots[i]<=1)) then
    begin
      Result:=roots[i];
      break;
    end;
  end;
end;

// Отыскивает только действительные корни
Function CubicRoot(a, b, c, d: single;var x:array of single):integer;
var
  p,q:single;
  Ak,Bk,Qk,Rk,t:single;
  Q3,R2:single;
begin
  // Приводим к виду  x3+p*x2+q*x+d=0, разделив на a.
  p:=b/a; q:=c/a; d:=d/a;
  // Вспомогательные вычисления
  Qk:=(p*p-3*q)/9;Rk:=(2*p*p*p-9*p*q+27*d)/54;
  R2:=(Rk*Rk);
  Q3:= (Qk*Qk*Qk);
  if (R2<Q3 ) then
  begin
    t:=ArcCos(Rk/sqrt(Q3))/3;
    x[0]:=-2*sqrt(Qk)*cos(t)-p/3;
    x[1]:=-2*sqrt(Qk)*cos(t+(2*pi/3))-p/3;
    x[2]:=-2*sqrt(Qk)*cos(t-(2*pi/3))-p/3;
    Result:=3;
    exit;
  end
  else
  begin
    Ak:=-sign(Rk)*Power(abs(Rk)+sqrt(R2-Q3),1/3);
    if(Ak<>0) then  Bk:=Qk/Ak
    else Bk:=Ak;
    x[0]:=(Ak+Bk) - p/3;
    // Случай вырождения комплексных корней
    if Ak=Bk then
    begin
     x[1]:=-Ak - p/3;
     Result:=2;
    end
    else
     Result:=1;
  end;
end;

// прямая задается уравнением k(x-x1)+y1, где k=(y2-y1)/(x2-x1)
function EvalLineX(y:double; p1,p2:point2d):double;
var
 k:single;
 maxy:point2d;
begin
  if p1.y>p2.y then
  begin
    maxy.y:=p1.y;
    maxy.x:=p1.x;
  end
  else
  begin
    maxy.y:=p2.y;
    maxy.x:=p2.x;
  end;
  if y>=maxy.y then
  begin
    result:=maxy.x;
    exit;
  end;
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=(y - p1.y+k*p1.x)/k;
end;

// прямая задается уравнением k(x-x1)+y1, где k=(y2-y1)/(x2-x1)
// x - 0..1
function EvalLineY(x:single; p1,p2:point2):single;
var k:single;
begin
  if x>=p2.x then
  begin
    result:=p2.y;
    exit;
  end;
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=k*(x-p1.x)+p1.y;
end;

function EvalLineYd(x:double; p1,p2:point2d):double;
var k:double;
begin
  if x>=p2.x then
  begin
    result:=p2.y;
    exit;
  end;
  k:=(p2.y-p1.y)/(p2.x-p1.x);
  result:=k*(x-p1.x)+p1.y;
end;

function EvalLineYd(x:double; px1,py1, px2, py2:double):double;overload;
var
  k:double;
begin
  if x>=px2 then
  begin
    result:=py2;
    exit;
  end;
  k:=(py2-py1)/(px2-px1);
  result:=k*(x-px1)+py1;
end;

function TwoPDist(A:point2d; B:point2d):double;
begin
  // расстояние между двумя точками
  result:=sqrt(Power((A.x - B.x),2) + Power((A.y - B.y),2));
end;
// t=0..1
function BezierFunc(P:cubicspline; t:double):point2d;
var
  //вычисляем координаты х и у точки на кривой Безье по значению параметра t
  x, y: double;
begin
  x := t * t * t * (P.p3.x - 3 *(P.p2.x - P.p1.x) - P.p0.x) +
      3 * t * t * (P.p2.x - 2 * P.p1.x + P.p0.x) + 3 * t * (P.p1.x - P.p0.x) + P.p0.x;
  y := t * t * t * (P.p3.y - 3 *(P.p2.y - P.p1.y) - P.p0.y) +
      3 * t * t * (P.p2.y - 2 * P.p1.y + P.p0.y) + 3 * t * (P.p1.y - P.p0.y) + P.p0.y;
  result:=p2d(x,y);
end;

function New_Raf(P:cubicspline; G:point2d; t:double):double;
var
  Npoly,
  i,k,n:integer;
  //Функция и производная, кэфы:
  t0, f, df, Ax, Bx, Cx, Dx, Ay, By, Cy, Dy:double;
  //Массив коэффициентов полинома-функции:
  a,
  //Массив коэффициентов полинома-производной:
  b:array of double;
begin
  //Порядок полинома:
  Npoly:=5;
  //Индексные переменные и число итераций:
  n:=10;
  setlength(a, npoly+1);
  setlength(b, npoly+1);

  t0 := t;

  Ax := P.p3.x - 3*(P.p2.x - P.p1.x) - P.p0.x;
  Bx := 3*(P.p2.x - 2 * P.p1.x + P.p0.x);
  Cx := 3*(P.p1.x - P.p0.x);
  Dx := P.p0.x - G.x;
  Ay := P.p3.y - 3*(P.p2.y - P.p1.y) - P.p0.y;
  By := 3*(P.p2.y - 2 * P.p1.y + P.p0.y);
  Cy := 3*(P.p1.y - P.p0.y);
  Dy := P.p0.y - G.y;
  //Ввод коэффициентов функции-полинома:
  a[5] := 3*(Ax*Ax + Ay*Ay);
  a[4] := 5*(Ax*Bx + Ay*By);
  a[3] := 4*(Ax*Cx + Ay*Cy) + 2*(Bx*Bx + By*By);
  a[2] := 3*(Bx*Cx + By*Cy) + 3*(Ax*Dx + Ay*Dy);
  a[1] := Cx*Cx + Cy*Cy + 2*(Bx*Dx + By*Dy);
  a[0] := Cx*Dx + Cy*Dy;
  //Вычисление коэффициентов для производной:
  b[4] := a[5]*5;
  b[3] := a[4]*4;
  b[2] := a[3]*3;
  b[1] := a[2]*2;
  b[0] := a[1];
  //Последовательные итерации:
  for k:= 1 to n do
  begin
    f := a[0];
    df := 0;
    for i:=1 to NPoly do
    begin
        f := a[i]*power(t0,i)+f;
        df := b[i-1]*power(t0,i-1)+df;
    end;
    t0 := t0-f/df;
  end;
  result:=t0;
end;


function NearestPCubicSpline(spline:cubicspline; Ap:point2d):point2d;
var
  a, b, c,c2, la, lb, lc1, lc2, eps:double;
begin
  a := 0;
  b := 1;
  c := a + (b - a)/2;
  eps := 0.001;
  while(abs(a-b) >= eps) do
  begin
    la := TwoPDist(Ap, BezierFunc(spline,a));
    lb := TwoPDist(Ap, BezierFunc(spline,b));
    if (la < lb) then
    begin
      b := c;
      c := a + (b - a)/2;
    end
    else
    begin
      a := c;
      c := a + (b - a)/2;
    end;
  end;
  lc1 := TwoPDist(Ap, BezierFunc(spline,c));
  c2 := New_Raf(spline,Ap,c);
  lc2:= TwoPDist(Ap, BezierFunc(spline,c2));
  if lc1<lc2 then
    result:= BezierFunc(spline,c)
  else
  begin
    result:= BezierFunc(spline,c2)
  end;
end;

function DistPtoCubicSpline(spline:cubicspline; Ap:point2d):double;
var
  a, b, c,c2, la, lb, lc1, lc2, eps:double;
begin
  a := 0;
  b := 1;
  c := a + (b - a)/2;
  eps := 0.001;
  while(abs(a-b) >= eps) do
  begin
    la := TwoPDist(Ap, BezierFunc(spline,a));
    lb := TwoPDist(Ap, BezierFunc(spline,b));
    if (la < lb) then
    begin
      b := c;
      c := a + (b - a)/2;
    end
    else
    begin
      a := c;
      c := a + (b - a)/2;
    end;
  end;
  lc1 := TwoPDist(Ap, BezierFunc(spline,c));
  c2 := New_Raf(spline,Ap,c);
  lc2:= TwoPDist(Ap, BezierFunc(spline,c2));
  if lc1<lc2 then
    result:= lc1
  else
  begin
    result:= lc2;
  end;
end;

function Subtractd(AVec1, AVec2 : point2d) : point2d;
begin
  Result.X := AVec1.X - AVec2.X;
  Result.Y := AVec1.Y - AVec2.Y;
end;

function LinesCrossd(LineAP1, LineAP2, LineBP1, LineBP2 : point2d) : boolean;
Var
  diffLA, diffLB : point2d;
  CompareA, CompareB : double;
begin
  Result := False;
  diffLA := Subtractd(LineAP2, LineAP1);
  diffLB := Subtractd(LineBP2, LineBP1);
  CompareA := diffLA.X*LineAP1.Y - diffLA.Y*LineAP1.X;
  CompareB := diffLB.X*LineBP1.Y - diffLB.Y*LineBP1.X;
  if ( ((diffLA.X*LineBP1.Y - diffLA.Y*LineBP1.X) < CompareA) xor
       ((diffLA.X*LineBP2.Y - diffLA.Y*LineBP2.X) < CompareA) ) and
     ( ((diffLB.X*LineAP1.Y - diffLB.Y*LineAP1.X) < CompareB) xor
       ((diffLB.X*LineAP2.Y - diffLB.Y*LineAP2.X) < CompareB) ) then
    Result := True;
end;

function EvalIntersectd(LineAP1, LineAP2, LineBP1, LineBP2 : point2d) : point2d;
Var
  LDetLineA, LDetLineB, LDetDivInv : Real;
  LDiffLA, LDiffLB : point2d;
begin
  LDetLineA := LineAP1.X*LineAP2.Y - LineAP1.Y*LineAP2.X;
  LDetLineB := LineBP1.X*LineBP2.Y - LineBP1.Y*LineBP2.X;
  LDiffLA := Subtractd(LineAP1, LineAP2);
  LDiffLB := Subtractd(LineBP1, LineBP2);
  LDetDivInv := 1 / ((LDiffLA.X*LDiffLB.Y) - (LDiffLA.Y*LDiffLB.X));
  Result.X := ((LDetLineA*LDiffLB.X) - (LDiffLA.X*LDetLineB)) * LDetDivInv;
  Result.Y := ((LDetLineA*LDiffLB.Y) - (LDiffLA.Y*LDetLineB)) * LDetDivInv;
end;


function Subtract(AVec1, AVec2 : point2) : point2;
begin
  Result.X := AVec1.X - AVec2.X;
  Result.Y := AVec1.Y - AVec2.Y;
end;

function LinesCross(LineAP1, LineAP2, LineBP1, LineBP2 : point2) : boolean;
Var
  diffLA, diffLB : point2;
  CompareA, CompareB : single;
begin
  Result := False;
  diffLA := Subtract(LineAP2, LineAP1);
  diffLB := Subtract(LineBP2, LineBP1);
  CompareA := diffLA.X*LineAP1.Y - diffLA.Y*LineAP1.X;
  CompareB := diffLB.X*LineBP1.Y - diffLB.Y*LineBP1.X;
  if ( ((diffLA.X*LineBP1.Y - diffLA.Y*LineBP1.X) < CompareA) xor
       ((diffLA.X*LineBP2.Y - diffLA.Y*LineBP2.X) < CompareA) ) and
     ( ((diffLB.X*LineAP1.Y - diffLB.Y*LineAP1.X) < CompareB) xor
       ((diffLB.X*LineAP2.Y - diffLB.Y*LineAP2.X) < CompareB) ) then
    Result := True;
end;

function EvalIntersect(LineAP1, LineAP2, LineBP1, LineBP2 : point2) : point2;
Var
  LDetLineA, LDetLineB, LDetDivInv : single;
  LDiffLA, LDiffLB : point2;
begin
  LDetLineA := LineAP1.X*LineAP2.Y - LineAP1.Y*LineAP2.X;
  LDetLineB := LineBP1.X*LineBP2.Y - LineBP1.Y*LineBP2.X;
  LDiffLA := Subtract(LineAP1, LineAP2);
  LDiffLB := Subtract(LineBP1, LineBP2);
  LDetDivInv := 1 / ((LDiffLA.X*LDiffLB.Y) - (LDiffLA.Y*LDiffLB.X));
  Result.X := ((LDetLineA*LDiffLB.X) - (LDiffLA.X*LDetLineB)) * LDetDivInv;
  Result.Y := ((LDetLineA*LDiffLB.Y) - (LDiffLA.Y*LDetLineB)) * LDetDivInv;
end;


function GrahamScan(const Points: TPointArray; p_size:integer): TPointArray;
var
  SortedPoints, UniquePoints, Hull: TPointArray;
  PointCount, UniqueCount, HullCount, I: Integer;

  function ComparePoints(const Left, Right: point2): Integer;
  begin
    if Left.X < Right.X then
      Exit(-1);
    if Left.X > Right.X then
      Exit(1);
    if Left.Y < Right.Y then
      Exit(-1);
    if Left.Y > Right.Y then
      Exit(1);
    Result := 0;
  end;

  procedure QuickSortPoints(var Values: TPointArray; Left, Right: Integer);
  var
    L, R: Integer;
    Pivot, Temp: point2;
  begin
    L := Left;
    R := Right;
    Pivot := Values[(Left + Right) div 2];
    repeat
      while ComparePoints(Values[L], Pivot) < 0 do
        Inc(L);
      while ComparePoints(Values[R], Pivot) > 0 do
        Dec(R);
      if L <= R then
      begin
        Temp := Values[L];
        Values[L] := Values[R];
        Values[R] := Temp;
        Inc(L);
        Dec(R);
      end;
    until L > R;
    if Left < R then
      QuickSortPoints(Values, Left, R);
    if L < Right then
      QuickSortPoints(Values, L, Right);
  end;

  function Cross(const Origin, A, B: point2): Double;
  begin
    Result := (Double(A.X) - Origin.X) * (Double(B.Y) - Origin.Y) -
      (Double(A.Y) - Origin.Y) * (Double(B.X) - Origin.X);
  end;

begin
  Result := nil;
  SortedPoints := nil;
  UniquePoints := nil;
  Hull := nil;
  PointCount := p_size;
  if PointCount < 0 then
    PointCount := 0;
  if PointCount > Length(Points) then
    PointCount := Length(Points);
  if PointCount = 0 then
    Exit;

  SortedPoints := Copy(Points, 0, PointCount);
  if PointCount > 1 then
    QuickSortPoints(SortedPoints, 0, PointCount - 1);

  SetLength(UniquePoints, PointCount);
  UniqueCount := 0;
  for I := 0 to PointCount - 1 do
  begin
    if (UniqueCount = 0) or
       (ComparePoints(UniquePoints[UniqueCount - 1], SortedPoints[I]) <> 0) then
    begin
      UniquePoints[UniqueCount] := SortedPoints[I];
      Inc(UniqueCount);
    end;
  end;
  SetLength(UniquePoints, UniqueCount);
  if UniqueCount <= 2 then
  begin
    Result := UniquePoints;
    Exit;
  end;

  SetLength(Hull, UniqueCount * 2);
  HullCount := 0;
  for I := 0 to UniqueCount - 1 do
  begin
    while (HullCount >= 2) and
      (Cross(Hull[HullCount - 2], Hull[HullCount - 1], UniquePoints[I]) <= 0) do
      Dec(HullCount);
    Hull[HullCount] := UniquePoints[I];
    Inc(HullCount);
  end;

  PointCount := HullCount + 1;
  for I := UniqueCount - 2 downto 0 do
  begin
    while (HullCount >= PointCount) and
      (Cross(Hull[HullCount - 2], Hull[HullCount - 1], UniquePoints[I]) <= 0) do
      Dec(HullCount);
    Hull[HullCount] := UniquePoints[I];
    Inc(HullCount);
  end;

  Dec(HullCount); // The first point is repeated by the upper chain.
  SetLength(Hull, HullCount);
  Result := Hull;
end;

procedure FindDiameter(const Hull: TPointArray; var Result: TDiameterResult);
var
  I, J: Integer;
  DistanceSquared, MaxDistanceSquared: Double;
begin
  Result.Point1.X := 0;
  Result.Point1.Y := 0;
  Result.Point2 := Result.Point1;
  Result.Index1 := -1;
  Result.Index2 := -1;
  Result.Distance := 0;

  if Length(Hull) = 0 then
    Exit;
  Result.Point1 := Hull[0];
  Result.Point2 := Hull[0];
  Result.Index1 := 0;
  Result.Index2 := 0;
  if Length(Hull) = 1 then
    Exit;

  MaxDistanceSquared := -1;
  for I := 0 to High(Hull) - 1 do
  begin
    for J := I + 1 to High(Hull) do
    begin
      DistanceSquared := Sqr(Double(Hull[I].X) - Hull[J].X) +
        Sqr(Double(Hull[I].Y) - Hull[J].Y);
      if DistanceSquared > MaxDistanceSquared then
      begin
        MaxDistanceSquared := DistanceSquared;
        Result.Point1 := Hull[I];
        Result.Point2 := Hull[J];
        Result.Index1 := I;
        Result.Index2 := J;
      end;
    end;
  end;
  Result.Distance := Sqrt(MaxDistanceSquared);
end;

function GrahamScanWithDiameter(const Points: TPointArray;
                                p_size:integer;
                                 out Diameter: TDiameterResult): TPointArray;
begin
  FillChar(Diameter, SizeOf(Diameter), 0);
  Diameter.Index1 := -1;
  Diameter.Index2 := -1;
  Result := GrahamScan(Points, p_size);
  FindDiameter(Result, Diameter);
end;

// Вспомогательная функция для вычисления расстояния
function PointDistance(const P1, P2: point2): Double;
begin
  Result := Sqrt(Sqr(P1.X - P2.X) + Sqr(P1.Y - P2.Y));
end;


function FindExtremumsFromPoints(const Points: TPointArrayd; StartIndex, EndIndex: Integer;
  HiLevel, LoLevel: Double; Extremums: TList): Boolean;
var
  i: Integer;
  Searching: Boolean;        // Флаг, указывающий, находимся ли мы в режиме поиска экстремума
  CurrentMax: Double;        // Текущий максимальный найденный максимум в зоне поиска
  CurrentMaxIndex: Integer;  // Индекс текущего максимального значения
  NewExtremum: PExtremum;    // Указатель на новую запись экстремума для добавления в TList
begin
  Result := False; // Изначально предполагаем, что экстремумы не найдены
  Extremums.Clear; // Очищаем выходной список перед началом поиска

  // Проверка корректности диапазона поиска и размера массива
  if (Length(Points) = 0) or (StartIndex < Low(Points)) or (EndIndex > High(Points)) or (StartIndex > EndIndex) then
  begin
    Exit; // Некорректный диапазон поиска или пустой массив
  end;

  Searching := False;
  CurrentMax := -MaxDouble; // Инициализируем текущий максимум наименьшим возможным значением double
  CurrentMaxIndex := -1;    // Инициализируем индекс максимума

  // Перебор элементов массива Points в заданном диапазоне
  for i := StartIndex to EndIndex do
  begin
    // Используем Y-координату текущей точки для анализа
    if not Searching then
    begin
      // Если мы не в режиме поиска экстремума, ищем пересечение верхнего уровня (HiLevel) по Y-координате
      if Points[i].Y > HiLevel then
      begin
        Searching := True;        // Начинаем поиск экстремума
        CurrentMax := Points[i].Y;  // Текущее Y-значение становится первым кандидатом на максимум
        CurrentMaxIndex := i;     // Запоминаем его индекс
      end;
    end
    else // Мы находимся в режиме поиска экстремума (Y-координата Points[i] > HiLevel где-то ранее)
    begin
      // Обновляем текущий максимум, если найдено большее Y-значение
      if Points[i].Y > CurrentMax then
      begin
        CurrentMax := Points[i].Y;
        CurrentMaxIndex := i;
      end;

      // Проверяем пересечение нижнего уровня (LoLevel) по Y-координате для завершения поиска экстремума
      if Points[i].Y < LoLevel then
      begin
        // Если мы нашли максимум в этой зоне (CurrentMaxIndex не -1)
        if CurrentMaxIndex <> -1 then
        begin
          // Создаем новую запись TExtremum динамически
          New(NewExtremum);
          NewExtremum^.Index := CurrentMaxIndex;
          NewExtremum^.Value := CurrentMax;
          // Добавляем полную точку (X и Y) соответствующую экстремуму
          NewExtremum^.Point := Points[CurrentMaxIndex];
          // Добавляем указатель на эту запись в TList
          Extremums.Add(NewExtremum);
          Result := True; // Устанавливаем флаг, что экстремум найден
        end;
        Searching := False;       // Завершаем текущий поиск экстремума
        CurrentMax := -MaxDouble; // Сбрасываем текущий максимум
        CurrentMaxIndex := -1;    // Сбрасываем индекс максимума
      end;
    end;
  end;
end;

function FindExtremumsInY(const Y: array of double; StartIndex, EndIndex: Integer;
  HiLevel, LoLevel: Double; Extremums: TList): Boolean;
var
  i: Integer;
  CurrentState: TExtremumSearchState; // Текущее состояние конечного автомата
  CurrentMax: Double;        // Текущий максимальный найденный максимум в зоне поиска
  CurrentMaxIndex: Integer;  // Индекс текущего максимального значения в массиве Y
  NewExtremum: PExtremum1d;    // Указатель на новую запись экстремума для добавления в TList
begin
  Result := False; // Изначально предполагаем, что экстремумы не найдены
  for I := 0 to Extremums.Count - 1 do
  begin
    NewExtremum:=Extremums[i];
    dispose(NewExtremum);
  end;
  Extremums.Clear; // Очищаем выходной список перед началом поиска
  // Проверка корректности диапазона поиска и размера массива
  if (Length(Y) = 0) or (StartIndex < Low(Y)) or (EndIndex > High(Y)) or (StartIndex > EndIndex) then
  begin
    Exit; // Некорректный диапазон поиска или пустой массив
  end;
  CurrentMax := -MaxDouble; // Инициализируем текущий максимум
  CurrentMaxIndex := -1;    // Инициализируем индекс максимума
  if y[StartIndex]>HiLevel then
  begin
    if y[StartIndex-1]>=y[StartIndex] then
      CurrentState := esHi
    else
    begin
      CurrentState := esAboveHiLevel;
      CurrentMax := y[StartIndex];
      CurrentMaxIndex := StartIndex;
    end;
  end
  else
  begin
    CurrentState := esHi; // Начинаем с состояния ожидания
  end;
  // Перебор элементов массива Y в заданном диапазоне
  for i := StartIndex to EndIndex do
  begin
    case CurrentState of
      esHi: // Состояние ожидания: ждем, пока значение поднимется выше HiLevel
        begin
          // Условие для перехода в состояние esAboveHiLevel:
          // Текущее значение должно быть выше HiLevel.
          // (Дополнительная проверка, что предыдущее было ниже HiLevel,
          //  обеспечивается самим фактом нахождения в esIdle и затем перехода)
          if Y[i] < HiLevel then
          begin
            // разрешаем поиск
            CurrentState := esIdle; // Переход в состояние поиска максимума
          end;
        end;
      esIdle: // Состояние ожидания: ждем, пока значение поднимется выше HiLevel
        begin
          if Y[i] > HiLevel then
          begin
            CurrentState := esAboveHiLevel; // Переход в состояние поиска максимума
            CurrentMax := Y[i];             // Инициализируем текущий максимум
            CurrentMaxIndex := i;           // Запоминаем индекс
          end;
        end;
      esAboveHiLevel: // Состояние "Над HiLevel": значение выше HiLevel, ищем максимум
        begin
          // Обновляем текущий максимум, если найдено большее значение
          if Y[i] > CurrentMax then
          begin
            CurrentMax := Y[i];
            CurrentMaxIndex := i;
          end;

          // Условие для перехода в состояние esFoundExtremum:
          // Текущее значение должно опуститься ниже LoLevel.
          if Y[i] < LoLevel then
          begin
            CurrentState := esFoundExtremum; // Переход в состояние фиксации экстремума
            // Здесь мы не сбрасываем CurrentMax/Index сразу,
            // потому что они нужны для добавления в список.
          end;
        end;
      esFoundExtremum: // Состояние "Найден экстремум": значение опустилось ниже LoLevel
        begin
          // Этот блок выполняется, когда мы уже обнаружили экстремум
          // и значение опустилось ниже LoLevel.
          // Мы добавляем найденный экстремум в список.
          if CurrentMaxIndex <> -1 then // Проверяем, что максимум был найден
          begin
            New(NewExtremum);
            NewExtremum^.Index := CurrentMaxIndex; // Индекс вершины
            NewExtremum^.Value := CurrentMax;      // Значение вершины
            Extremums.Add(NewExtremum);
            Result := True; // Устанавливаем флаг, что экстремум найден
          end;

          // После добавления экстремума, сбрасываем параметры и возвращаемся в esIdle
          CurrentMax := -MaxDouble; // Сбрасываем текущий максимум
          CurrentMaxIndex := -1;    // Сбрасываем индекс максимума
          CurrentState := esIdle;   // Возвращаемся в состояние ожидания для нового экстремума

          // Важный момент: текущая точка (Y[i]) уже ниже LoLevel,
          // поэтому она не может быть началом нового поиска.
          // Если бы мы хотели, чтобы она потенциально могла быть началом,
          // нужно было бы добавить проверку Y[i] > HiLevel здесь,
          // но это противоречило бы логике "пересечения снизу вверх".
        end;
    end; // end case CurrentState
  end; // end for loop

  // Важный момент после цикла:
  // Если цикл завершился, а мы находились в состоянии esAboveHiLevel,
  // это означает, что мы нашли пик, но он так и не опустился ниже LoLevel
  // до конца анализируемого диапазона. В этом случае экстремум не считается завершенным
  // по вашим правилам (не пересекся LoLevel).
end;



end.
