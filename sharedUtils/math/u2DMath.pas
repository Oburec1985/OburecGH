unit u2DMath;

interface
uses math, uCommonTypes;

type
  // ������ 4-� �������
  CubicSpline = record
    // ���� ������ ������� ���� c_corner �� ������ �����
    Smooth:boolean;
    // ���� ������ ����� ������� ������������
    nullPoly:boolean;
    p0,p1,p2,p3:point2;
  end;

  TPointArray = array of point2;

  TDiameterResult = record
    Point1: point2;
    Point2: point2;
    Index1: Integer;
    Index2: Integer;
    Distance: Double;
  end;

  // ����� �������� ��������
  function GrahamScan(const Points: TPointArray; p_size:integer): TPointArray;
  function GrahamScanWithDiameter(const Points: TPointArray; p_size:integer;
          out Diameter: TDiameterResult): TPointArray;


//px, py � ���������� �����, �� ������� �������������� ����������.
//A, x0, fA, y0 � ��������� ���������������� ������ y = A * exp(-(x + x0) * fA) + y0.
//XMin, XMax � �������� ������ �������� �� ��� X.
// ���������� �� ���������� �� ����� px,py y=A*exp(-fA*(x+x0))+y0
function DistanceToExponential(px, py, A, x0, fA, y0, XMin, XMax: Double): Double;

function NearestPCubicSpline(spline:cubicspline; Ap:point2d):point2d;
function DistPtoCubicSpline(spline:cubicspline; Ap:point2d):double;
// ���������� ������ �������������� �����
Function CubicRoot(a, b, c, d: single;var x:array of single):integer;
// ������� �������� u ������� ��������������� x-�
function FindPointOnSpline(spline:CubicSpline;x:single):single;
// ��������� ����� �� ���������� ������� �� ���������� u
function EvalSplinePoint(u:single; spline:cubicspline):point2;
// ��������� ����� �� ������
function EvalLineY(x:single; p1,p2:point2):single;
function EvalLineYd(x:double; p1,p2:point2d):double;overload;
function EvalLineYd(x:double; px1,py1, px2, py2:double):double;overload;
function EvalLineX(y:double; p1,p2:point2d):double;
// ����������� ���� ������ �� ���������
function EvalIntersectd(LineAP1, LineAP2, LineBP1, LineBP2 : point2d) : point2d;
function EvalIntersect(LineAP1, LineAP2, LineBP1, LineBP2 : point2) : point2;



implementation
const
  //GR = (1 + Sqrt(5))/2; // ������� �������
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
    fc := Func(c, px, py, A, x0, fA, y0);
    fd := Func(d, px, py, A, x0, fA, y0);

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
  // ������� X, ��������������� ������������ ����������
  MinX := GoldenSectionSearch(
    XMin, XMax, 1e-6,
    SquareDistance,
    px, py, A, x0, fA, y0
  );
  // ��������� ����������� ����������
  Result := Sqrt(SquareDistance(MinX, px, py, A, x0, fA, y0));
end;

// ��������� ����� �� ���������� ������� �� ���������� u
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


// ������� �������� �� u �� ���������� x
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

// ���������� ������ �������������� �����
Function CubicRoot(a, b, c, d: single;var x:array of single):integer;
var
  p,q:single;
  Ak,Bk,Qk,Rk,t:single;
  Q3,R2:single;
begin
  // �������� � ����  x3+p*x2+q*x+d=0, �������� �� a.
  p:=b/a; q:=c/a; d:=d/a;
  // ��������������� ����������
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
    // ������ ���������� ����������� ������
    if Ak=Bk then
    begin
     x[1]:=-Ak - p/3;
     Result:=2;
    end
    else
     Result:=1;
  end;
end;

// ������ �������� ���������� k(x-x1)+y1, ��� k=(y2-y1)/(x2-x1)
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

// ������ �������� ���������� k(x-x1)+y1, ��� k=(y2-y1)/(x2-x1)
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
  // ���������� ����� ����� �������
  result:=sqrt(Power((A.x - B.x),2) + Power((A.y - B.y),2));
end;
// t=0..1
function BezierFunc(P:cubicspline; t:double):point2d;
var
  //��������� ���������� � � � ����� �� ������ ����� �� �������� ��������� t
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
  //������� � �����������, ����:
  t0, f, df, Ax, Bx, Cx, Dx, Ay, By, Cy, Dy:double;
  //������ ������������� ��������-�������:
  a,
  //������ ������������� ��������-�����������:
  b:array of double;
begin
  //������� ��������:
  Npoly:=5;
  //��������� ���������� � ����� ��������:
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
  //���� ������������� �������-��������:
  a[5] := 3*(Ax*Ax + Ay*Ay);
  a[4] := 5*(Ax*Bx + Ay*By);
  a[3] := 4*(Ax*Cx + Ay*Cy) + 2*(Bx*Bx + By*By);
  a[2] := 3*(Bx*Cx + By*Cy) + 3*(Ax*Dx + Ay*Dy);
  a[1] := Cx*Cx + Cy*Cy + 2*(Bx*Dx + By*Dy);
  a[0] := Cx*Dx + Cy*Dy;
  //���������� ������������� ��� �����������:
  b[4] := a[5]*5;
  b[3] := a[4]*4;
  b[2] := a[3]*3;
  b[1] := a[2]*2;
  b[0] := a[1];
  //���������������� ��������:
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
  P0: point2;
  SortedPoints: TPointArray;
  Stack: TPointArray;
  i, j, minIndex: Integer;

  // ������� ��� ���������� ����������
  function Orientation(p, q, r: point2): single;
  begin
    Result := (q.X - p.X) * (r.Y - p.Y) - (q.Y - p.Y) * (r.X - p.X);
  end;

  // ������ ���������� ����� �� ��������� ����
  procedure SortPoints;
  var
    i, j: Integer;
    temp: point2;
  begin
    for i := 1 to High(SortedPoints) - 1 do
    //for i := 1 to length(SortedPoints) - 1 do
      for j := i + 1 to High(SortedPoints) do
      begin
        if (Orientation(P0, SortedPoints[i], SortedPoints[j]) < 0) or
           ((Orientation(P0, SortedPoints[i], SortedPoints[j]) = 0) and
           (Sqr(SortedPoints[i].X - P0.X) + Sqr(SortedPoints[i].Y - P0.Y) >
           Sqr(SortedPoints[j].X - P0.X) + Sqr(SortedPoints[j].Y - P0.Y))) then
        begin
          temp := SortedPoints[i];
          SortedPoints[i] := SortedPoints[j];
          SortedPoints[j] := temp;
        end;
      end;
  end;

begin
  if p_size <= 3 then
  begin
    Result := Copy(Points, 0, p_size);
    Exit;
  end;

  // ��� 1: ������� ����� P0 � ������������ ������������
  minIndex := 0;
  for i := 1 to p_size-1 do
    if (Points[i].Y < Points[minIndex].Y) or
      ((Points[i].Y = Points[minIndex].Y) and (Points[i].X < Points[minIndex].X)) then
      minIndex := i;

  // ���������� P0 � ������ �������
  SetLength(SortedPoints, p_size);
  SortedPoints[0] := Points[minIndex];
  j := 1;
  for i := 0 to p_size-1 do
    if i <> minIndex then
    begin
      SortedPoints[j] := Points[i];
      Inc(j);
    end;

  // ��� 2: ���������� �� ��������� ����
  P0 := SortedPoints[0];
  SortPoints;

  // ��� 3: �������� ������������ �����
  j := 1;
  for i := 2 to p_size-1 do
  begin
    while (j >= 1) and (Orientation(SortedPoints[0], SortedPoints[j], SortedPoints[i]) = 0) do
    begin
      if (Sqr(SortedPoints[i].X - P0.X) + Sqr(SortedPoints[i].Y - P0.Y) >
         Sqr(SortedPoints[j].X - P0.X) + Sqr(SortedPoints[j].Y - P0.Y)) then
        SortedPoints[j] := SortedPoints[i];
      Dec(j);
    end;
    Inc(j);
    if j < i then
      SortedPoints[j] := SortedPoints[i];
  end;
  SetLength(SortedPoints, j + 1);

  if Length(SortedPoints) < 3 then
  begin
    Result := SortedPoints;
    Exit;
  end;

  // ��� 4: ���������� �������� ��������
  SetLength(Stack, 3);
  Stack[0] := SortedPoints[0];
  Stack[1] := SortedPoints[1];
  Stack[2] := SortedPoints[2];

  for i := 3 to p_size-1 do
  begin
    while (Length(Stack) > 1) and
      (Orientation(Stack[High(Stack)-2],
        Stack[High(Stack)-1],
        SortedPoints[i]) <= 0) do
      SetLength(Stack, Length(Stack)-1);
    SetLength(Stack, Length(Stack)+1);
    Stack[High(Stack)] := SortedPoints[i];
  end;
  Result := Stack;
end;

procedure FindDiameter(const Hull: TPointArray; var Result: TDiameterResult);
var
  n, i, j, nextI, nextJ: Integer;
  maxDist, currentDist: Double;
  vecI, vecJ: point2;
  crossProduct: single;
begin
  n := Length(Hull);
  if n < 2 then
  begin
    Result.Distance := 0;
    Exit;
  end;
  maxDist := 0;
  j := 1;

  // ����� ����������� ���������
  for i := 0 to n-1 do
  begin
    nextI := (i + 1) mod n;
    nextJ := (j + 1) mod n;

    // ������� ��������� ���������� �����
    vecI.X := Hull[nextI].X - Hull[i].X;
    vecI.Y := Hull[nextI].Y - Hull[i].Y;

    vecJ.X := Hull[nextJ].X - Hull[j].X;
    vecJ.Y := Hull[nextJ].Y - Hull[j].Y;

    crossProduct := vecI.X * vecJ.Y - vecI.Y * vecJ.X;

    while (crossProduct > 0) and (j < n + i) do
    begin
      j := (j + 1) mod n;
      nextJ := (j + 1) mod n;
      vecJ.X := Hull[nextJ].X - Hull[j].X;
      vecJ.Y := Hull[nextJ].Y - Hull[j].Y;
      crossProduct := vecI.X * vecJ.Y - vecI.Y * vecJ.X;
    end;

    // ��������� ������� ����������
    currentDist := Sqrt(Sqr(Hull[i].X - Hull[j].X) + Sqr(Hull[i].Y - Hull[j].Y));
    if currentDist > maxDist then
    begin
      maxDist := currentDist;
      Result.Point1 := Hull[i];
      Result.Point2 := Hull[j];
      Result.Index1 := i;
      Result.Index2 := j;
      Result.Distance := maxDist;
    end;
  end;
end;

function GrahamScanWithDiameter(const Points: TPointArray;
                                p_size:integer;
                                 out Diameter: TDiameterResult): TPointArray;
begin
  // �������� ������������ �������� �������
  Result := GrahamScan(Points,p_size );

  // ������� ������� ��� ���������� ��������
  if Length(Result) >= 2 then
    FindDiameter(Result, Diameter)
  else
  begin
    Diameter.Distance := 0;
    Diameter.Index1 := -1;
    Diameter.Index2 := -1;
  end;
end;

// ��������������� ������� ��� ���������� ����������
function PointDistance(const P1, P2: point2): Double;
begin
  Result := Sqrt(Sqr(P1.X - P2.X) + Sqr(P1.Y - P2.Y));
end;

end.
