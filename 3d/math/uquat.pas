unit uQuat;

interface
uses
 mathfunction,Math,uMatrix,uCommonTypes;

type
//Нужны же кватернионы для представления и интерполяции поворотов. Поворот
//относительно оси (x,y,z) (иными словами, поворот вокруг вектора (x,y,z),
//проведенного из начала координат) на угол angle представляется кватернионом
//q, лежащим на единичной 4D-сфере (то есть, 4D-вектором длины 1):
//s = cos(angle/2),
//v = (x,y,z) * sin(angle/2) / |(x,y,z)|,
//q = [s,v].
  tQuat = record
   axis:point3;
   w:single;
   offset:point3;
  end;
  //
  cQuat = class
  public
    q:tquat;
  public
    // Повернуть вектор кватернионом
    function GetLength:single;
    // Повернуть вектор кватернионом
    function rotatevector(v:point3):point3;
    // нормализовать кватернион
    procedure normalize;
    // Получить матрицу из кватерниона
    function GetMatrix:matrixgl;
    // Получить кватернион из оси вращения и угла вращения вокруг нее(в градусах)
    procedure FromAxisAngel(axis:point3;angel:single);
    // Получить кватернион из матрицы
    procedure frommatrix(m:matrixgl);
    // Преобразовать кватернион в углы эйлера
    function geteuler:point3;
    // Получить кватернион из углов эйлера
    procedure fromeuler(p3:point3);
    // Заменяет member q на произведение полученное из q1*q2 эквивалентно m2*m1
    // где m2 и m1 матрицы состояния объекта
    procedure GetMultQuat(q1,q2:cquat);
    // Повернуть кватернион с помощью оси и угла
    procedure RotateByAxisAngel(axis:point3;angel:single);overload;
    procedure RotateByAxisAngel(x,y,z:single;angel:single);overload;
    // получить инверсный кватернион
    function GetInverse:tquat;
  end;
  // работает быстрее чем QuaternionToMatrix
  function Quattomatrix(q:tquat):matrixgl;
  function QuaternionToMatrix(quat : tquat) : matrixgl;
  function multquat(q1,q2:tquat):tquat;
  function multquatNoOffset(q1,q2:tquat):tquat;
  // из уравнения q2*q1 = q находим q1 = invq2*resq
  function getQuat1(q2,resq:tquat):tquat;
  // из уравнения q2*q1 = q находим q2 = resq*invq2
  function getQuat2(q1,resq:tquat):tquat;
  function QuatFromAxisAngle(axis:point3;angle:single):tquat;
  // работает быстрее чем QuaternionFromMatrix
  function matrixtoquat(m:matrixgl):tquat;
  function QuaternionFromMatrix(const mat : matrixgl) : tquat;
  function rotatevectorbyquat(p:point3;q:tquat):point3;
  function identquat:tquat;
  procedure normalizequat(var q:tquat);
  function QuaternionSlerp(const QStart, QEnd: TQuat; Spin: Integer; t: Single): TQuat; overload;
  function QuaternionSlerp(const source, dest: TQuat; const t : Single) : TQuat; overload;


  const

  EPSILON  : Single = 1e-40;
  EPSILON2 : Single = 1e-30;


implementation

function identquat:tquat;
begin
  result.axis:=axiso;
  result.w:=1;
  result.offset:=axiso;
end;

// суммирует кватернионы
// Результирующий кватернион представляет собой
// промежуточное состояние между q1 и q2
function SummQuat(q1,q2:tquat):tquat;
begin
  result.axis.x:=q1.axis.x + q2.axis.x;
  result.axis.y:=q1.axis.y + q2.axis.y;
  result.axis.z:=q1.axis.z + q2.axis.z;
  result.w:=q1.w+q2.w;
end;
// вычитает кватернионы
function SubdivQuat(q1,q2:tquat):tquat;
begin
  result.axis.x:=q1.axis.x - q2.axis.x;
  result.axis.y:=q1.axis.y - q2.axis.y;
  result.axis.z:=q1.axis.z - q2.axis.z;
  result.w:=q1.w - q2.w;
end;
// умножить кватернион на константу. не меняет состояние вращения.
function scaleQuat(s:single;q:tquat):tquat;
begin
  result.axis.x:=s*q.axis.x;
  result.axis.y:=s*q.axis.y;
  result.axis.z:=s*q.axis.z;
  result.w:=s*q.w;
end;
 // Норма кватерниона N(q)
function normaquat(q1:tquat):single;
begin
  result:=q1.axis.x*q1.axis.x + q1.axis.y*q1.axis.y + q1.axis.z*q1.axis.z +
          q1.w*q1.w;
end;
// Длина кватерниона |q|
function Lengthquat(q1:tquat):single;
begin
  result:=sqrt(normaquat(q1));
end;
// Сопряжение кватерниона. Задает вращение обратное исходному.
// Вращение обратное исходному можно также получить поменяв знак w компонента
// conjugate(q) = [-v, w]
function conjugatequat(q1:tquat):tquat;
begin
  result.axis.x:=-q1.axis.x;
  result.axis.y:=-q1.axis.y;
  result.axis.z:=-q1.axis.z;
  result.w:=q1.w;
end;
// нормализовать кватернион
procedure normalizequat(var q:tquat);
var len:single;
begin
  len := Lengthquat(q);
  q.axis.x := q.axis.x/len;
  q.axis.y := q.axis.y/len;
  q.axis.z := q.axis.z/len;
  q.w := q.w/len;
end;
// Скалярное произведение (inner product).
// q•q' = x*x' + y*y' + z*z' + w*w'
// Скалярное произведение полезно тем, что дает косинус половины угла
// между двумя кватернионами умноженную на их длину. Соответственно скалярное
// произведение двух единичных кватернионов даст косинус половины угла между
// двумя ориентациями. Угол между кватернионами это угол поворота из q  в  q'
// (по кратчайшей дуге).
function Dotquat(q1,q2:tquat):single;
begin
  result:=multscalarp3(q1.axis,q2.axis) +q1.w*q2.w;
end;
// преобразует кватернион в матрицу, при этом 4-й столбец не инициализируется
function Quattomatrix(q:tquat):matrixgl;
var s,wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2:single;
begin
// Конвертирование кватерниона
  s  := 2/normaquat(q);
  x2 := q.axis.x * s;    y2 := q.axis.y * s;    z2 := q.axis.z * s;
  xx := q.axis.x * x2;   xy := q.axis.x * y2;   xz := q.axis.x * z2;
  yy := q.axis.y * y2;   yz := q.axis.y * z2;   zz := q.axis.z * z2;
  wx := q.w * x2;        wy := q.w * y2;        wz := q.w * z2;

  result[0] := 1 - (yy + zz);
  result[1] := xy - wz;
  result[2] := xz + wy;
  result[3] := 0;

  result[4] := xy + wz;
  result[5] := 1 - (xx + zz);
  result[6] := yz - wx;
  result[7] := 0;

  result[8] := xz - wy;
  result[9] := yz + wx;
  result[10] := 1 - (xx + yy);
  result[11] := 0;

  //result[12]:=0;
  //result[13]:=0;
  //result[14]:=0;
  //result[15]:=1;
  //m:=identmatrix4;
  //m[12]:=q.offset.x;
  //m[13]:=q.offset.y;
  //m[14]:=q.offset.z;
  //result:=multmatrix4(result,m);
  result[12]:=q.offset.x;
  result[13]:=q.offset.y;
  result[14]:=q.offset.z;
  result[15]:=1;
end;
// Преобразовать ось + угол в кватернион
function QuatFromAxisAngle(axis:point3;angle:single):tquat;
var sinAngle:single;
begin
  angle :=angle*pi/360;
  NormalizeVectorp3(axis);
  sinAngle := sin(angle);
  result.axis.x := (axis.x * sinAngle);
  result.axis.y := (axis.y * sinAngle);
  result.axis.z := (axis.z * sinAngle);
  result.w := cos(angle);
end;
// кватернион преобразовать в ось и угол вращение вокруг оси
procedure QuaternionToAxisAngle(q:tquat;var axis:point3;var angle:single);
var  sinAngle:single;
begin
  Normalizequat(q);
  sinAngle := sqrt(1 - (q.w * q.w));
  if (abs(sinAngle) < 0.0005) then sinAngle := 1;
  axis.x := (q.axis.x / sinAngle);
  axis.y := (q.axis.y / sinAngle);
  axis.z := (q.axis.z / sinAngle);
  angle := (ArcCos(q.w) * 2);
end;
// Повернуть вектор с помощью кватерниона
function rotatevectorbyquat(p:point3;q:tquat):point3;
var l_inversequat,l_pointquat,l_q:tquat;
  function inverseq(q:tquat):tquat;
  begin
    result:=scalequat(1/normaquat(q),conjugatequat(q));
  end;
begin
  l_pointquat.axis:=p;
  l_pointquat.w:=0;
  l_inversequat:=inverseq(q);
  l_q:=multquatNoOffset(l_inversequat,l_pointquat);
  l_q:=multquatNoOffset(l_q,q);
  result:=l_q.axis;
end;
// Инверсный (inverse) кватернион.
// Существует такой кватернион, при умножении на который произведение
// дает нулевое вращение и соответствующее тождественному кватерниону
// (identity quaternion), и определяется как:
// q–1 = conjugate(q)/N(q)
// Тождественный кватернион записывается как q[0, 0, 0, 1]. Он описывает
// нулевой поворот (по аналогии с единичной матрицей), и не изменяет
// другой кватернион при умножении.
function inversequat(q:tquat):tquat;
  function invq(q:tquat):tquat;
  begin
    result:=scalequat(1/normaquat(q),conjugatequat(q));
    result.offset:=q.offset;
  end;
begin
  result:=scalequat(1/normaquat(q),conjugatequat(q));
  q:=invq(q);
  q.offset:=rotatevectorbyquat(q.offset,q);
  q.offset:=scalevectorp3(-1,q.offset);
  result.offset:=q.offset;
end;

function multquatNoOffset(q1,q2:tquat):tquat;
begin
  // Выше приведен книжный алгоритм. Почему-то не всегда работает
  result.axis.x:= q1.w*q2.axis.x + q1.axis.x*q2.w + q1.axis.y*q2.axis.z - q1.axis.z*q2.axis.y;
  result.axis.y:= q1.w*q2.axis.y + q1.axis.y*q2.w + q1.axis.z*q2.axis.x - q1.axis.x*q2.axis.z;
  result.axis.z:= q1.w*q2.axis.z + q1.axis.z*q2.w + q1.axis.x*q2.axis.y - q1.axis.y*q2.axis.x;
  result.w:= q1.w*q2.w - q1.axis.x*q2.axis.x - q1.axis.y*q2.axis.y - q1.axis.z*q2.axis.z;
  result.offset:=q2.offset;
end;
// Умножение двух кватернионов можно записать в виде:
// qq' = [ vv' + wv' + w'v, ww – v•v' ]
// где vv' — векторное произведение, v•v' — скалярное произведение векторов.
// аналогично умножению двух матриц поворота. Итоговый кватернион представляет
// собой комбинацию вращений — объект повернули на q' а затем
// на q (если смотреть из глобальной системы координат).
function multquat(q1,q2:tquat):tquat;
begin
//  p1:=multvectorp3(q1.axis,q2.axis);
//  p2:=scalevectorp3(q1.w,q2.axis);
//  p3:=scalevectorp3(q2.w,q1.axis);
//  p1:=summvectorp3(p1,p2);
//  result.axis:=summvectorp3(p1,p3);
//  result.w:=q1.w*q2.w - multscalarp3(q1.axis,q2.axis);
  // Выше приведен книжный алгоритм. Почему-то не всегда работает
  result.axis.x:= q1.w*q2.axis.x + q1.axis.x*q2.w + q1.axis.y*q2.axis.z - q1.axis.z*q2.axis.y;
  result.axis.y:= q1.w*q2.axis.y + q1.axis.y*q2.w + q1.axis.z*q2.axis.x - q1.axis.x*q2.axis.z;
  result.axis.z:= q1.w*q2.axis.z + q1.axis.z*q2.w + q1.axis.x*q2.axis.y - q1.axis.y*q2.axis.x;
  result.w:= q1.w*q2.w - q1.axis.x*q2.axis.x - q1.axis.y*q2.axis.y - q1.axis.z*q2.axis.z;
  q1.offset:=rotatevectorbyquat(q1.offset,q2);
  result.offset:=SummVectorP3(q1.offset,q2.offset);
end;

// из уравнения q2*q1 = q находим q1 = invq2*resq
function getQuat1(q2,resq:tquat):tquat;
begin
  result:=multquat(inversequat(q2),resq);
end;

// из уравнения q2*q1 = q находим q2 = resq*invq2
function getQuat2(q1,resq:tquat):tquat;
begin
  result:=multquat(resq,inversequat(q1));
end;

// Повернуть кватернион вокруг оси axis на угол angle
function QuaternionRotate(q:tquat;axis:point3;angle:single):tquat;
begin
  result := QuatFromAxisAngle(axis, angle);
  result := multquat(result,q);
end;
// 0 4 8  12
// 1 5 9  13
// 2 6 10 14
// 3 7 11 15
function matrixtoquat(m:matrixgl):tquat;
var
  q:tquat;
  p3:point3;
  trace,s:single;
  i,j,k:integer;
  nxt:array[0..2] of integer;
  ar:array [0..4] of single;
  function convertindex(i,j:integer):integer;
  begin
     result:= j*4 + i;
  end;
begin
  nxt[0]:=1;nxt[1]:=2;nxt[2]:=0;
  trace := m[0] + m[5] + m[10]; // trace of martix
  if (trace > 0) then
  begin
    s:=sqrt(trace+1);
    result.w:=s/2;
    s:=0.5/s;
    result.axis.x:=(m[9]-m[6])*s;
    result.axis.y:=(m[2]-m[8])*s;
    result.axis.z:=(m[4]-m[1])*s;
  end
  else
  begin
    i := 0;j:=0;
    if (m[5] > m[0]) then
    begin
     i := 1;j:=5;
    end;
    if (m[10] > m[j]) then i := 2;
    j := nxt[i];
    k := nxt[j];
    s := sqrt ((m[convertindex(i,i)] - (m[convertindex(j,j)] +
               m[convertindex(k,k)])) + 1.0);
    ar[i] := s * 0.5;
    if (s <> 0) then s := 0.5 / s;
    ar[3] := (m[convertindex(j,k)] - m[convertindex(k,j)]) * s;
    ar[j] := (m[convertindex(i,j)] + m[convertindex(j,i)]) * s;
    ar[k] := (m[convertindex(i,k)] + m[convertindex(k,i)]) * s;
    result.axis.x := ar[0];
    result.axis.y := ar[1];
    result.axis.z := ar[2];
    result.w := ar[3];
  end;
  p3:=vtop3(getposfrommatrix(m));
  result.offset:=p3;
  Normalizequat(Result);
end;
// Преобразует кватернион в углы эйлера pitch,yaw,roll - x,y,z
function ToEuler(q:tquat):point3;
var sqw,sqx,sqy,sqz:single;
begin
  sqW := q.w * q.w;
  sqX := q.axis.x * q.axis.x;
  sqY := q.axis.y * q.axis.y;
  sqZ := q.axis.z * q.axis.z;
  result.z := RADTODEG(arctan( 2.0 * (q.axis.x * q.axis.y + q.axis.z * q.w) / ( sqX - sqY - sqZ + sqW)));
  result.x := RADTODEG(arctan( 2.0 * (q.axis.y * q.axis.z + q.axis.x * q.w) / (-sqX - sqY + sqZ + sqW)));
  result.y := RADTODEG(arcsin(-2.0 * (q.axis.x * q.axis.z - q.axis.y * q.w)));
end;
// Перевести кватернион в углы эйлера. Не проверял функцию
function quatFromEuler(Euler:point3):tquat;
var ex,ey,ez,cr,cp,cy,sr,sp,sy,cpcy,spsy:single;
begin
  ex := degtorad(Euler.x) / 2.0;
  ey := degtorad(Euler.y)   / 2.0;
  ez := degtorad(Euler.z)  / 2.0;
  cr := cos(ex);
  cp := cos(ey);
  cy := cos(ez);
  sr := sin(ex);
  sp := sin(ey);
  sy := sin(ez);
  cpcy := cp * cy;
  spsy := sp * sy;
  result.w := (cr * cpcy + sr * spsy);
  result.axis.x := (sr * cpcy - cr * spsy);
  result.axis.y := (cr * sp * cy + sr * cp * sy);
  result.axis.z := (cr * cp * sy - sr * sp * cy);
  normalizequat(result);
end;
// Нормализовать кватернион.
procedure cQuat.normalize;
begin
  normalizequat(q);
end;
// Перевести кватернион в матрицу
function cQuat.GetMatrix;
begin
  result:=Quattomatrix(q);
end;
// Получить кватернион из оси, угла
procedure cQuat.FromAxisAngel(axis:point3;angel:single);
begin
  q:=QuatFromAxisAngle(axis,angel);
end;
// Получить кватернион из матрицы
procedure cQuat.FromMatrix(m:matrixgl);
begin
  q:=matrixtoquat(m);
end;
// Получить углы эйлера из кватерниона
function cquat.geteuler:point3;
var m:matrixgl;
begin
  m := quattomatrix(q);
  result:=MatrixglToEuler(m);
end;
// Получить кватернион из углов эйлера
procedure cquat.fromeuler(p3:point3);
begin
  q:=quatFromEuler(p3);
end;
// Получить кватернион из умножения двух других кватернионов
procedure cquat.GetMultQuat(q1,q2:cquat);
begin
 q:=multquat(q1.q,q2.q);
end;
// повернуть кватернион осью/ углом
procedure cquat.RotateByAxisAngel(axis:point3;angel:single);
begin
  q:=QuaternionRotate(q,axis,angel);
end;

// Повернуть кватернион с помощью оси и угла
procedure cquat.RotateByAxisAngel(x,y,z:single;angel:single);
var p3:point3;
begin
  p3.x:=x; p3.y:=y; p3.z:=z;
  q:=QuaternionRotate(q,p3,angel);
  normalizequat(q);
end;

// повернуть вектор кватернионом
function cquat.rotatevector(v:point3):point3;
begin
  result:=rotatevectorbyquat(v,q);
end;
// Повернуть вектор кватернионом
function cquat.GetLength:single;
begin
  result:=Lengthquat(q);
end;

function cquat.GetInverse:tquat;
begin
  result:=inversequat(q);
end;

function QuaternionFromMatrix(const mat : matrixgl) : tquat;
// the matrix must be a rotation matrix!
var
   traceMat, s, invS : single;
   p3:point3;
begin
   traceMat := 1 + mat[0] + mat[5] + mat[10];
   if traceMat>EPSILON2 then begin
      s:=Sqrt(traceMat)*2;
      invS:=1/s;
      Result.axis.x:=(mat[6]-mat[9])*invS;
      Result.axis.y:=(mat[8]-mat[2])*invS;
      Result.axis.z:=(mat[1]-mat[4])*invS;
      Result.w:=0.25*s;
   end else if (mat[0]>mat[5]) and (mat[0]>mat[10]) then begin  // Row 0:
      s:=Sqrt(MaxFloat(EPSILON2, cOne+mat[0]-mat[5]-mat[10]))*2;
      invS:=1/s;
      Result.axis.x:=0.25*s;
      Result.axis.y:=(mat[1]+mat[4])*invS;
      Result.axis.z:=(mat[8]+mat[2])*invS;
      Result.w   :=(mat[6]-mat[9])*invS;
   end else if (mat[5]>mat[10]) then begin  // Row 1:
      s:=Sqrt(MaxFloat(EPSILON2, cOne+mat[5]-mat[0]-mat[10]))*2;
      invS:=1/s;
      Result.axis.x:=(mat[1]+mat[4])*invS;
      Result.axis.y:=0.25*s;
      Result.axis.z:=(mat[6]+mat[9])*invS;
      Result.w   :=(mat[8]-mat[2])*invS;
   end else begin  // Row 2:
      s:=Sqrt(MaxFloat(EPSILON2, cOne+mat[10]-mat[0]-mat[5]))*2;
      invS:=1/s;
      Result.axis.x:=(mat[8]+mat[2])*invS;
      Result.axis.y:=(mat[6]+mat[9])*invS;
      Result.axis.z:=0.25*s;
      Result.w   :=(mat[1]-mat[4])*invS;
   end;
   p3:=vtop3(getposfrommatrix(mat));
   result.offset:=p3;
   Normalizequat(Result);
end;

function QuaternionToMatrix(quat : tquat) : matrixgl;
var
   w, x, y, z, xx, xy, xz, xw, yy, yz, yw, zz, zw: Single;
begin
   Normalizequat(quat);
   w := quat.w;
   x := quat.axis.x;
   y := quat.axis.y;
   z := quat.axis.z;;
   xx := x * x;
   xy := x * y;
   xz := x * z;
   xw := x * w;
   yy := y * y;
   yz := y * z;
   yw := y * w;
   zz := z * z;
   zw := z * w;
   Result[0] := 1 - 2 * ( yy + zz );
   Result[4] :=     2 * ( xy - zw );
   Result[8] :=     2 * ( xz + yw );
   Result[12] := 0;
   Result[1] :=     2 * ( xy + zw );
   Result[5] := 1 - 2 * ( xx + zz );
   Result[9] :=     2 * ( yz - xw );
   Result[13] := 0;
   Result[2] :=     2 * ( xz - yw );
   Result[6] :=     2 * ( yz + xw );
   Result[10] := 1 - 2 * ( xx + yy );
   Result[14] := 0;
   Result[3] := 0;
   Result[7] := 0;
   Result[11] := 0;
   Result[15] := 1;
end;

function QuaternionSlerp(const QStart, QEnd: TQuat; Spin: Integer; t: Single): TQuat;
var
    beta,                   // complementary interp parameter
    theta,                  // Angle between A and B
    sint, cost,             // sine, cosine of theta
    phi: Single;            // theta plus spins
    bflip: Boolean;         // use negativ t?
begin
  // cosine theta
  cost:=VectorCos(QStart.axis, QEnd.axis);
  // if QEnd is on opposite hemisphere from QStart, use -QEnd instead
  if cost < 0 then
  begin
    cost:=-cost;
    bflip:=True;
  end
  else
    bflip:=False;
  // if QEnd is (within precision limits) the same as QStart,
  // just linear interpolate between QStart and QEnd.
  // Can't do spins, since we don't know what direction to spin.
  if (1 - cost) < EPSILON then
    beta:=1 - t
  else
  begin
    // normal case
    theta:=arccos(cost);
    phi:=theta + Spin * Pi;
    sint:=sin(theta);
    beta:=sin(theta - t * phi) / sint;
    t:=sin(t * phi) / sint;
  end;
  if bflip then t:=-t;
  // interpolate
  Result.axis.X:=beta * QStart.axis.X + t * QEnd.axis.X;
  Result.axis.y:=beta * QStart.axis.y + t * QEnd.axis.y;
  Result.axis.z:=beta * QStart.axis.z + t * QEnd.axis.z;
  Result.w:=beta * QStart.w + t * QEnd.w;
  result.offset:=InterpolateP3(QStart.offset,QEnd.offset,t);
end;

function QuaternionSlerp(const source, dest: TQuat; const t : Single) : TQuat;
var
   to1: array[0..4] of Single;
   omega, cosom, sinom, scale0, scale1: Extended;
// t goes from 0 to 1
// absolute rotations
begin
   // calc cosine
   cosom:= source.axis.x*dest.axis.x
          +source.axis.y*dest.axis.y
          +source.axis.z*dest.axis.z
	       +source.w   *dest.w;
   // adjust signs (if necessary)
   if cosom<0 then begin
      cosom := -cosom;
      to1[0] := - dest.axis.x;
      to1[1] := - dest.axis.y;
      to1[2] := - dest.axis.z;
      to1[3] := - dest.w;
   end else begin
      to1[0] := dest.axis.x;
      to1[1] := dest.axis.y;
      to1[2] := dest.axis.z;
      to1[3] := dest.w;
   end;
   // calculate coefficients
   if ((1.0-cosom)>EPSILON2) then begin // standard case (slerp)
      omega:=ArcCos(cosom);
      sinom:=1/Sin(omega);
      scale0:=Sin((1.0-t)*omega)*sinom;
      scale1:=Sin(t*omega)*sinom;
   end else begin // "from" and "to" quaternions are very close
	          //  ... so we can do a linear interpolation
      scale0:=1.0-t;
      scale1:=t;
   end;
   // calculate final values
   Result.axis.x := scale0 * source.axis.x + scale1 * to1[0];
   Result.axis.y := scale0 * source.axis.y + scale1 * to1[1];
   Result.axis.z := scale0 * source.axis.z + scale1 * to1[2];
   Result.w := scale0 * source.w + scale1 * to1[3];
   NormalizeQuat(Result);
   result.offset:=InterpolateP3(source.offset,dest.offset,t);
end;

end.
