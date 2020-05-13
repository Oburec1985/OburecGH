unit u2DMath;

interface
uses math, uCommonTypes;

type
  // сплайн 4-о порядка
  CubicSpline = record
    // если создан точками типа c_corner то просто линия
    Smooth:boolean;
    // елси правая точка нулевая интерполяция
    nullPoly:boolean;
    p0,p1,p2,p3:point2;
  end;

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

implementation

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


end.
