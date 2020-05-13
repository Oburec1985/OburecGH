unit uMatrix;

interface
uses
 opengl,mathfunction,Math,uCommonTypes;


// Получить координаты в которых находится объект из матрицы
Function SetPos(m:matrixgl;pos:point3):matrixgl;overload;
Function SetPos(m:matrixgl;x,y,z:single):matrixgl;overload;
// Получить координаты в которых находится объект из матрицы
Function GetPosFromMatrix(const m:matrixgl):vector3f;
// Получить координаты в которых находится объект из матрицы
Function GetPosFromMatrixP3(const m:matrixgl):point3;
// Получить координаты одной из трех осей (0-x, 1-y;2-z)
Function GetAxisFromMatrix(const m:MatrixGl;i:byte):point3;
// Установить координаты одной из трех осей (0-x, 1-y;2-z)
procedure SetAxisFromMatrix(var m:MatrixGl;i:byte;v:Point3);
//Решает матричное уравнени X*B=C; X = C*(B^-1)
function EvalLeftMatrix(const B:matrixgl;const C:matrixgl):matrixgl;
//---------------- Решает матричное уравнение уравнение A*X=B -------------
function EvalRightMatrix(const A:matrixgl;const B:matrixgl):matrixgl;
//---------------- Инвертирование матрицы 4x4 ---------------
Function InverseMatrix4(const mtrx:MatrixGl):MatrixGl;
// Инвертирование матрицы 4x4 являющейся базисом. Функция оптимизирована
// по сравнению с предыдущей за счет условия, что в случае если матрица 3х3
// является базисом справедливо выражение a^(-1) = a^T
// почему-то не работает )) (в общем случае.)
Function InversOrtMtrx4(const mtrx:MatrixGl):MatrixGl;
//- тоже что и предыдущя функция для случая, когда перемещение =0
Function InversRotMtrx4(const mtrx:MatrixGl):MatrixGl;
//---------------- Транспонирование матрицы 4x4 ---------------
Procedure TransposeMatrix4(var Mtrx:MatrixGl);
//---------------- Отмена вращения матрицы 4x4 ---------------
Function NoRotateMatrix4(const Mtrx:MatrixGl):MatrixGl;
Function NoTranslateMatrix4(const Mtrx:MatrixGl):MatrixGl;
//  Переносит компоненты вращения из второго аргумента в первый и дает рез-т
Function GetRotMatrix4(dst:MatrixGl;const src:MatrixGl):MatrixGl;
//  Переносит компоненты переноса из второго аргумента в первый и дает рез-т
Function GetTranslateMatrix4(m1:MatrixGl;const m2:MatrixGl):MatrixGl;
//---------------- Умножение матриц 4x4 ---------------
// если содержится вращение и перемещение в матрице то равносильно
// умножению вначале на NoRotateMatrix4(m2) потом NoTranslateMatrix4(m2)
Function MultMatrix4(const m1:MatrixGl;const m2:MatrixGl):MatrixGl;
//================ Алгоритмы матриц 3х3 =======================
//---------------- Умножение матрицы 3х3 на вектор
Function MultScalarMtrx3(const Mtrx:Matrix3;const v:Vector3f):Vector3f;
//---------------- Транспонирование матрицы 3x3 ---------------
Procedure TransposeMtrx3(var Mtrx:Matrix3);
//---------------- Детерминант матрицы 3x3 --------------------
Function DetMtrx3(const Mtrx:Matrix3):GlFloat;
//---------------- Умножение матриц 3x3 -----------------------
Function MultMtrx3(const Mtrx1,Mtrx2:Matrix3):Matrix3;
//---------------- детерминант матрицы 2x2 --------------------
Function DetMtrx2(const Mtrx:array of glfloat):GlFloat;
// --------------- Матрицу в углы эйлера x,y,z, - pitch,yaw,roll
function MatrixglToEuler(m:matrixgl):point3;
// --------------- Матрицу в углы эйлера x,y,z, - pitch,yaw,roll
function EulerToMatrixgl(angels:point3):matrixgl;
//---------------- Инвертирование матрицы 4x4 -----------------
Function DetMtrx4(const mtrx:MatrixGl):single;
//---------------- Построение матрицы поворота вокруг оси на заданый угол -----
Function BuildMatrixByAxisAngel(x,y,z,angel:single):matrixgl;overload;
Function BuildMatrixByAxisAngel(axis:point3;angel:single):matrixgl;overload;
Function BuildTransposeMatrix(v:point3):matrixgl;overload;
Function BuildTransposeMatrix(x,y,z:single):matrixgl;overload;
// Умножение вектора на матрицу
Function MultP3byM(m:matrixgl;p3_:point3):point3;
Function MultVbyM(m:matrixgl;v:vector3f):vector3f;
// угол возвращает в радианах
procedure MatrixToAxisAngel(const m:matrixgl; var axis:point3;var a:single);
// интерполяция axisAngel
procedure InterpolateAxisAngle(ax1,ax2:point3;a1,a2,t:single;var ax:point3;var a:single);

const
  axisX:point3 = (x:1;y:0;z:0);
  axisY:point3 = (x:0;y:1;z:0);
  axisZ:point3 = (x:0;y:0;z:1);
  axisO:point3 = (x:0;y:0;z:0);
  yellow:point3 = (x:1;y:1;z:0);
  red:point3 = (x:1;y:0;z:0);
  green:point3 = (x:0;y:1;z:0);
  blue:point3 = (x:0;y:0;z:1);
  
implementation

Function MultP3byM(m:matrixgl;p3_:point3):point3;
var pos:point3;
begin
  pos:=GetPosFromMatrixP3(m);
  result.x:=m[0]*p3_.x+m[4]*p3_.y+m[8]*p3_.z;
  result.y:=m[1]*p3_.x+m[5]*p3_.y+m[9]*p3_.z;
  result.z:=m[2]*p3_.x+m[6]*p3_.y+m[10]*p3_.z;
  p3_:=SummVectorP3(result,pos);
  result:=p3_;
end;

Function MultVbyM(m:matrixgl;v:vector3f):vector3f;
var pos:vector3f;
begin
  pos:=GetPosFromMatrix(m);
  result[0]:=m[0]*v[0]+m[4]*v[1]+m[8]*v[2];
  result[1]:=m[1]*v[0]+m[5]*v[1]+m[9]*v[2];
  result[2]:=m[2]*v[0]+m[6]*v[1]+m[10]*v[2];
  v:=SummVector(result,pos);
  result:=v;
end;


//Решает матричное уравнени A*B=C; A = C*(B^-1)
function EvalLeftMatrix(const B:matrixgl;const C:matrixgl):matrixgl;
var inv_tm:matrixgl;
begin
  inv_tm:=inversematrix4(B);
  Result:=multmatrix4(C,inv_tm);
end;

//Решает матричное уравнени A*X=B; X = (A^-1)*B
function EvalRightMatrix(const A:matrixgl;const B:matrixgl):matrixgl;
var inv_tm:matrixgl;
begin
  inv_tm:=inversematrix4(A);
  Result:=multmatrix4(inv_tm,B);
end;

procedure SetAxisFromMatrix(var m:MatrixGl;i:byte;v:Point3);
begin
  case i of
  0:begin m[0]:=v.x; m[1]:=v.y; m[2]:=v.z end;
  1:begin m[4]:=v.x; m[5]:=v.y; m[6]:=v.z end;
  2:begin m[8]:=v.x; m[9]:=v.y; m[10]:=v.z end;
  end;
end;


Function GetAxisFromMatrix(const m:MatrixGl;i:byte):Point3;
Var v:point3;
begin
  case i of
  0:begin v.x:=m[0];v.y:=m[1];v.z:=m[2]end;
  1:begin v.x:=m[4];v.y:=m[5];v.z:=m[6]end;
  2:begin v.x:=m[8];v.y:=m[9];v.z:=m[10]end;
  end;
  Result:=v;
end;

Function InverseMatrix4(const mtrx:MatrixGl):MatrixGl;
var MtrxBuf:MatrixGl;
    MinorMtrx:Matrix3;
    i,j,k,n,count,sign:integer;
    b:boolean;
    det:single;
begin
 for i:=0 to 3 do
 begin
   for j := 0 to 3 do
   begin
      count:=0;
      for k:=0 to 3 do
      begin
        for n:=0 to 3 do
        begin
           b:=(k=i);
           if b then break;
           b:=(n<>j);
           if b then       // условие вычеркивания строки и столбца
           begin
             MinorMtrx[count]:=mtrx[k*4+n];
             count:=count+1;
           end;
        end;
      end;
      if Frac((i+j)/2)=0 then
        sign:=1
      else
        sign:=-1;
      MtrxBuf[j*4+i]:=DetMtrx3(MinorMtrx)*sign; // присвоение с транспонированием
   end;
 end;
 det:=DetMtrx4(mtrx);
 for i:= 0 to 15 do
  MtrxBuf[i]:=MtrxBuf[i]/det;
 Result:=MtrxBuf;
end;

Function InversOrtMtrx4(const mtrx:MatrixGl):MatrixGl;
var m3,m3notinv:matrix3;
    resm:MatrixGl;
    a12,a21,b12,b21:vector3f;
    a22,b22:single;
    i:integer;
begin
  m3[0]:=mtrx[0]; m3[1]:=mtrx[1]; m3[2]:=mtrx[2];
  m3[3]:=mtrx[4]; m3[4]:=mtrx[5]; m3[5]:=mtrx[6];
  m3[6]:=mtrx[8]; m3[7]:=mtrx[9]; m3[8]:=mtrx[10];
  m3notinv:=m3;
  TransposeMtrx3(m3);
  a12[0]:=mtrx[12];a12[1]:=mtrx[13];a12[2]:=mtrx[14];
  a21[0]:=mtrx[3];a21[1]:=mtrx[7];a21[2]:=mtrx[11];
  a22:=mtrx[15];

  //  по формуле A^(-1) = |      a11^T       -a11^T*(a12/a22)           |
  //                      |-(a21/a22)*a11^T  (1/a22)*a21*a11^T*(a12/a22)|
  b12:= MultScalarMtrx3(m3,a12);
  b21:= MultScalarMtrx3(m3notinv,a21);for i := 0 to 2 do b21[i]:=-b21[i]/a22;
  b22:= (MultScalar(b12,a21) + 1)/a22;
  for i := 0 to 2 do b12[i]:=-b12[i]/a22;

  resm[0]:=m3[0]; resm[1]:=m3[1]; resm[2]:=m3[2];
  resm[4]:=m3[3]; resm[5]:=m3[4]; resm[6]:=m3[5];
  resm[8]:=m3[6]; resm[9]:=m3[7]; resm[10]:=m3[8];

  resm[12]:=b12[0]; resm[13]:=b12[1]; resm[14]:=b12[2];
  resm[3] :=b21[0]; resm[7] :=b21[1]; resm[11]:=b21[2];
  resm[15]:=b22;
  result:=resm;
end;


Function InversRotMtrx4(const mtrx:MatrixGl):MatrixGl;
var m3:matrix3;
    resm:MatrixGl;
    a12,a21,b21:vector3f;
    a22:single;
    i:integer;
begin
  m3[0]:=mtrx[0]; m3[1]:=mtrx[1]; m3[2]:=mtrx[2];
  m3[3]:=mtrx[4]; m3[4]:=mtrx[5]; m3[5]:=mtrx[6];
  m3[6]:=mtrx[8]; m3[7]:=mtrx[9]; m3[8]:=mtrx[10];

  a12[0]:=mtrx[12];a12[1]:=mtrx[13];a12[2]:=mtrx[14];
  a21[0]:=mtrx[3] ;a21[1]:=mtrx[7] ;a21[2]:=mtrx[11];
  a22:=mtrx[15];

  //  по формуле A^(-1) = |      a11^T       -a11^T*(a12/a22)           |
  //                      |-(a21/a22)*a11^T  (1/a22)*a21*a11^T*(a12/a22)|
  b21:= MultScalarMtrx3(m3,a21);for i := 0 to 2 do b21[i]:=-b21[i];
  TransposeMtrx3(m3);

  resm[0]:=m3[0]; resm[1]:=m3[1]; resm[2]:=m3[2];
  resm[4]:=m3[3]; resm[5]:=m3[4]; resm[6]:=m3[5];
  resm[8]:=m3[6]; resm[9]:=m3[7]; resm[10]:=m3[8];

  resm[12]:=a12[0]; resm[13]:=a12[1]; resm[14]:=a12[2];
  resm[3] :=b21[0]; resm[7] :=b21[1]; resm[11]:=b21[2];
  resm[15]:=a22;
  result:=resm;
end;


Function GetTranslateMatrix4(m1:MatrixGl;const m2:MatrixGl):MatrixGl;
begin
  m1[12]:=m2[12];
  m1[13]:=m2[13];
  m1[14]:=m2[14];
  result:=m1;
end;

Function GetRotMatrix4(dst:MatrixGl;const src:MatrixGl):MatrixGl;
begin
  dst[0]:=src[0];dst[4]:=src[4];dst[8]:=src[8];
  dst[1]:=src[1];dst[5]:=src[5];dst[9]:=src[9];
  dst[2]:=src[2];dst[6]:=src[6];dst[10]:=src[10];
  result:=dst;
end;

procedure TransposeMtrx3(var Mtrx:Matrix3);
var MtrxBuf:Matrix3;
begin
  MtrxBuf[0]:=Mtrx[0];MtrxBuf[1]:=Mtrx[3];MtrxBuf[2]:=Mtrx[6];
  MtrxBuf[3]:=Mtrx[1];MtrxBuf[4]:=Mtrx[4];MtrxBuf[5]:=Mtrx[7];
  MtrxBuf[6]:=Mtrx[2];MtrxBuf[7]:=Mtrx[5];MtrxBuf[8]:=Mtrx[8];
  Mtrx:=MtrxBuf;
end;

function MultMtrx3(const Mtrx1,Mtrx2:Matrix3):Matrix3;
var MtrxBuf:Matrix3;
begin
  MtrxBuf[0]:= Mtrx1[0]*Mtrx2[0] + Mtrx1[3]*Mtrx2[1] + Mtrx1[6]*Mtrx2[2];
  MtrxBuf[1]:= Mtrx1[0]*Mtrx2[3] + Mtrx1[3]*Mtrx2[4] + Mtrx1[6]*Mtrx2[5];
  MtrxBuf[2]:= Mtrx1[0]*Mtrx2[6] + Mtrx1[3]*Mtrx2[7] + Mtrx1[6]*Mtrx2[8];

  MtrxBuf[3]:= Mtrx1[1]*Mtrx2[0] + Mtrx1[4]*Mtrx2[1] + Mtrx1[7]*Mtrx2[2];
  MtrxBuf[4]:= Mtrx1[1]*Mtrx2[3] + Mtrx1[4]*Mtrx2[4] + Mtrx1[7]*Mtrx2[5];
  MtrxBuf[5]:= Mtrx1[1]*Mtrx2[6] + Mtrx1[4]*Mtrx2[7] + Mtrx1[7]*Mtrx2[8];

  MtrxBuf[6]:= Mtrx1[2]*Mtrx2[0] + Mtrx1[5]*Mtrx2[1] + Mtrx1[8]*Mtrx2[2];
  MtrxBuf[7]:= Mtrx1[2]*Mtrx2[3] + Mtrx1[5]*Mtrx2[4] + Mtrx1[8]*Mtrx2[5];
  MtrxBuf[8]:= Mtrx1[2]*Mtrx2[6] + Mtrx1[5]*Mtrx2[7] + Mtrx1[8]*Mtrx2[8];
  Result:=MtrxBuf;
end;

function DetMtrx3(const Mtrx:Matrix3):GlFloat;
begin
 Result:=
 Mtrx[0]*Mtrx[4]*Mtrx[8]+Mtrx[1]*Mtrx[5]*Mtrx[6]+Mtrx[3]*Mtrx[7]*Mtrx[2] - Mtrx[2]*Mtrx[4]*Mtrx[6]-Mtrx[5]*Mtrx[7]*Mtrx[0]-Mtrx[1]*Mtrx[3]*Mtrx[8];
end;

function MultScalarMtrx3(const Mtrx:Matrix3;const v:Vector3f):Vector3f;
var i:integer;
    resV:Vector3f;
  j: Integer;
begin
  for i := 0 to 2 do
    resV[i]:=0;
  for i := 0 to 2 do
  begin
    for j := 0 to 2 do
      resV[i]:=resV[i] + Mtrx[j*3+i]*v[j];
  end;
  Result:=resV;
end;

function DetMtrx2(const Mtrx:array of glFloat):GlFloat;
begin
 Result:=Mtrx[0]*Mtrx[3]-Mtrx[1]*Mtrx[2];
end;

procedure TransposeMatrix4(var Mtrx:MatrixGl);
var MtrxBuf:MatrixGl;
begin
  MtrxBuf[1]:=Mtrx[4];MtrxBuf[4]:=Mtrx[1];
  MtrxBuf[2]:=Mtrx[8];MtrxBuf[8]:=Mtrx[2];
  MtrxBuf[3]:=Mtrx[12];MtrxBuf[12]:=Mtrx[3];
  MtrxBuf[6]:=Mtrx[9];MtrxBuf[9]:=Mtrx[6];
  MtrxBuf[7]:=Mtrx[13];MtrxBuf[13]:=Mtrx[7];
  MtrxBuf[11]:=Mtrx[14];MtrxBuf[14]:=Mtrx[11];

  MtrxBuf[5]:=Mtrx[5];MtrxBuf[10]:=Mtrx[10];
  MtrxBuf[15]:=Mtrx[15];MtrxBuf[0]:=Mtrx[0];
  Mtrx:=MtrxBuf;
end;


Function NoRotateMatrix4(const Mtrx:MatrixGl):MatrixGl;
var m:MatrixGl;
begin
 m:=Mtrx;
 m[0]:=1; m[1]:=0; m[2]:=0;m[3]:=0;
 m[4]:=0; m[5]:=1; m[6]:=0;m[7]:=0;
 m[8]:=0; m[9]:=0; m[10]:=1;m[11]:=0;
 Result:=m;
end;

Function NoTranslateMatrix4(const Mtrx:MatrixGl):MatrixGl;
var m:MatrixGl;
begin
 m:=Mtrx;
 m[14]:=0; m[13]:=0; m[12]:=0;
 Result:=m;
end;

Function DetMtrx4(const mtrx:MatrixGl):single;
var i,j,k,count:integer;
    MinorMtrx:Matrix3;
    b:boolean;
    AddLine1:array[0..3] of single;
    res:single;
begin
  for i := 0 to  3 do
  begin
    count:=0;
    for j := 0 to 3 do
    begin
        for k := 1 to 3 do
        begin
          b:=i<>j;
          if b then
          begin
              MinorMtrx[count]:=mtrx[j*4+k];
              count:=count+1;
          end
          else
              break;
        end;
    end;
    AddLine1[i]:=DetMtrx3(MinorMtrx);
  end;
  res:=0;
  for i := 0 to 3 do
  begin
    if Frac(i/2)<>0 then
        j:=-1
    else
        j:=1;
    res:=res+AddLine1[i]*mtrx[i*4]*j;
  end;
  Result:=res;
end;

Function MultMatrix4(const m1:MatrixGl;const m2:MatrixGl):MatrixGl;
var i,j,k,count:integer;
    m:MatrixGl;
    res:single;
begin
 // Инициализация массива
 count:=0;
 for i:= 0 to 15 do
   m[i]:=0;
 // Пробег по строка и столбцам
 for i := 0 to 3 do //строки
  for k:=0 to 3 do  //столбы
    begin
     res:=0;
      for j:=0 to 3 do  //столбы
        res:=m1[j*4+i]*m2[j+k*4]+res;
      m[count]:=res;
      count:=count+1;
    end;
  TransposeMatrix4(m);
  Result:=m;
end;

// --------------- Матрицу в углы эйлера x,y,z, - pitch,yaw,roll
function EulerToMatrixgl(angels:point3):matrixgl;
var TMtype:GLUInt;
    m:matrixgl;
begin
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadidentity;
  glrotate(angels.x,1,0,0);
  glrotate(angels.y,0,1,0);
  glrotate(angels.z,0,0,1);
  glgetfloatv(Gl_MODELVIEW_MATRIX,@m);
  result:=m;
  if TMType = GL_MODELVIEW then
   glMatrixMode(GL_MODELVIEW);
  if TMType = GL_PROJECTION then
   glMatrixMode(GL_PROJECTION);
  glpopmatrix;
end;

//     |  0  4  8 12 |
//M =  |  1  5  9 13 |
//     |  2  6 10 14 |
//     |  3  7 11 15 |

//     |  0  1  2  3 |
//M =  |  4  5  6  7 |
//     |  8  9 10 11 |
//     | 12 13 14 15 |
// Преобразует матрицу в углы эйлера.порядок поворотов X,Y,Z
function MatrixglToEuler(m:matrixgl):point3;
var p,y,r:single;
    i:integer;
function CheckAngels(p,y,r:single):integer;
begin
  if getCosSign(y)*getCosSign(r)=sign_(m[0]) then
  begin
    if getCosSign(y)*getSinSign(r)*(-1)=sign_(m[4]) then
    begin
       if -1*getCosSign(y)*getSinSign(p)=sign_(m[9]) then
       begin
         result:=0;
       end
       else
       begin
         result:=1;  // r
       end;
    end
    else
    begin
      result:=2; // y
    end;
  end
  else
  begin
    result:=3; // p
  end;
end;
begin
  p:=(180/pi)*arctan(-1*m[9]/m[10]);
  r:=(180/pi)*arctan(-1*m[4]/m[0]);
  y:=(180/pi)*arcsin(m[8]);
  // Определение квадрантов в которых находятся углы эйлера
  case CheckAngels(p,y,r) of
  0:begin
     result.x:=p;result.y:=y;result.z:=r;
     exit;
    end;
  end;
  for i := 0 to 6 do
  begin
    case i of
    0:begin
        if CheckAngels(p+180,y,r)=0 then
        begin
          result.x:=p+180;
          result.y:=y;
          result.z:=r;
          exit;
        end;
      end;
    1:begin
        if CheckAngels(p+180,180-y,r)=0 then
        begin
          result.x:=p+180;
          result.y:=180-y;
          result.z:=r;
          exit;
        end;
      end;
    2:begin
        if CheckAngels(p+180,y,r+180)=0 then
        begin
          result.x:=p+180;
          result.y:=y;
          result.z:=r+180;
          exit;
        end;
      end;
    3:begin
        if CheckAngels(p+180,180-y,r+180)=0 then
        begin
          result.x:=p+180;
          result.y:=180-y;
          result.z:=r+180;
          exit;
        end;
      end;
    4:begin
        if CheckAngels(p,180-y,r)=0 then
        begin
          result.x:=p;
          result.y:=180-y;
          result.z:=r;
          exit;
        end;
      end;
    5:begin
        if CheckAngels(p,180-y,r+180)=0 then
        begin
          result.x:=p;
          result.y:=180-y;
          result.z:=r+180;
          exit;
        end;
      end;
    6:begin
        if CheckAngels(p,y,r+180)=0 then
        begin
          result.x:=p;
          result.y:=y;
          result.z:=r+180;
          exit;
        end;
      end;
    end;
  end;
end;

Function GetPosFromMatrixP3(const m:matrixgl):point3;
begin
  result.z:=m[14];
  result.y:=m[13];
  result.x:=m[12];
end;

Function getPosFromMatrix(const m:matrixgl):vector3f;
begin
  result[2]:=m[14];
  result[1]:=m[13];
  result[0]:=m[12];
end;

Function BuildMatrixByAxisAngel(x,y,z,angel:single):matrixgl;
var tm:matrixgl;
    TMtype:GLUInt;
    i:integer;
begin
  // Узнаем какая матрица активна
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glpushmatrix;
  glloadidentity;
  glrotate(angel,x,y,z);
  glGetFloatv(Gl_MODELVIEW_MATRIX,@tm);
  glpopmatrix;
  if TMType = GL_MODELVIEW then
   glMatrixMode(GL_MODELVIEW);
  if TMType = GL_PROJECTION then
   glMatrixMode(GL_PROJECTION);  
  result:=tm;
end;

Function BuildMatrixByAxisAngel(axis:point3;angel:single):matrixgl;
begin
  result:=BuildMatrixByAxisAngel(axis.x,axis.y,axis.z,angel);
end;

Function SetPos(m:matrixgl;x,y,z:single):matrixgl;
begin
  m[12]:=x;
  m[13]:=y;
  m[14]:=z;
  result:=m;
end;

Function SetPos(m:matrixgl;pos:point3):matrixgl;
begin
  result:=setpos(m,pos.x,pos.y,pos.z);
end;

Function BuildTransposeMatrix(x,y,z:single):matrixgl;
begin
  result:=setpos(identmatrix4,x,y,z);
end;

Function BuildTransposeMatrix(v:point3):matrixgl;
begin
  result:=buildtransposematrix(v.x,v.y,v.z);
end;

//angle = acos(( m00 + m11 + m22 - 1)/2)
//x = (m21 - m12)/√((m21 - m12)2+(m02 - m20)2+(m10 - m01)2)
//y = (m02 - m20)/√((m21 - m12)2+(m02 - m20)2+(m10 - m01)2)
//z = (m10 - m01)/√((m21 - m12)2+(m02 - m20)2+(m10 - m01)2)
procedure MatrixToAxisAngel(const m:matrixgl; var axis:point3;var a:single);
var epsilon,// margin to allow for rounding errors
    epsilon2, // margin to distinguish between 0 and 180 degrees
    angle,x,y,z:single;
    xx,yy,zz,xy,xz,yz,s:single;
begin
  epsilon:= 0.01;
	epsilon2:= 0.1;
	if ((abs(m[4]-m[1])< epsilon)and(abs(m[8]-m[2])< epsilon)
	    and (abs(m[9]-m[6])< epsilon)) then
  begin
		// singularity found
		// first check for identity matrix which must have +1 for all terms
		//  in leading diagonaland zero in other terms
		if ((abs(m[4]+m[1]) < epsilon2)
		  and (abs(m[8]+m[2]) < epsilon2)
		  and (abs(m[9]+m[6]) < epsilon2)
		  and (abs(m[0]+m[5]+m[10]-3) < epsilon2)) then
    begin
			// this singularity is identity matrix so angle = 0
			axis:=axisX;
      a:=0;
      exit;
		end;
		// otherwise this singularity is angle = 180
		angle := Pi;
		xx := (m[0]+1)/2;
		yy := (m[5]+1)/2;
		zz := (m[10]+1)/2;
		xy := (m[4]+m[1])/4;
		xz := (m[8]+m[2])/4;
		yz := (m[9]+m[6])/4;
		if ((xx > yy) and (xx > zz)) then
    begin
      // m[0][0] is the largest diagonal term
			if (xx< epsilon) then
      begin
				x := 0;
				y := 0.7071;
				z := 0.7071;
			end
      else
      begin
				x := sqrt(xx);
				y := xy/x;
				z := xz/x;
			end;
    end
		else
    begin
      if (yy > zz) then
      begin
        // m[1][1] is the largest diagonal term
        if (yy< epsilon) then
        begin
          x := 0.7071;
          y := 0;
          z := 0.7071;
        end
        else
        begin
          y := sqrt(yy);
          x := xy/y;
          z := yz/y;
        end;
      end
      else  // m[2][2] is the largest diagonal term so base result on this
			if (zz< epsilon) then
      begin
				x := 0.7071;
				y := 0.7071;
				z := 0;
			end
      else
      begin
				z := sqrt(zz);
				x := xz/z;
				y := yz/z;
			end;
		end;
    axis.x:=x;axis.y:=y;axis.z:=z;a:=angle;
    exit;
  end;
	// as we have reached here there are no singularities so we can handle normally
	s:= sqrt((m[6] - m[9])*(m[6] - m[9])
		+(m[8] - m[2])*(m[8] - m[2])
		+(m[1] - m[4])*(m[1] - m[4])); // used to normalise
	if (abs(s) < 0.001) then s:=1;
		// prevent divide by zero, should not happen if matrix is orthogonal and should be
		// caught by singularity test above, but I've left it in just in case
	angle := arccos(( m[0] + m[5] + m[10] - 1)/2);
	x := (m[6] - m[9])/s;
	y := (m[8] - m[2])/s;
	z := (m[1] - m[4])/s;
  axis.x:=x;axis.y:=y;axis.z:=z;a:=angle;
end;

procedure InterpolateAxisAngle(ax1,ax2:point3;a1,a2,t:single;var ax:point3;var a:single);
var crossax:point3;
    alfa:single;
begin
  crossax:=MultVectorP3(ax1,ax2);
  // в радианах
  alfa:=GetAngel(ax1,ax2,true);

end;

end.
