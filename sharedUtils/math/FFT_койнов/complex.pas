﻿unit complex;


 {Модуль Complex содержит описание типа TComplex (Тип комплексных чисел),
 в виде класса, с переопределением (перегрузкой) основных операция над
 числами (+,-,/,*)  см ниже.
 Введены также гиперболические и тригонометрические функции такие как (Cos, Sin,
 Tang,Cotan, Cosh,Sinh,Tangh,Cotanh)
 и обратные им функции (arcCos, ArcSin....)
 Добавлены для удобства такие функции как:
 arg - возвращает аргумент числа Z
 abs - модуль числа Z
 Sopr - возвращает сопряженное число числу Z
 Ln - натуральный логарифм числа Z
 Exp - Экспонента от числа Z
 Multiply_i - функция возвращает число Z умноженное на мнимую еденицу те Z*i
StepenNReal(Stepen:Real):TComplex;// Значение целой положительной степени комплексного аргумента, значение функции f(z) = z^n
StepenNComplex(Stepen:TComplex):TComplex;//Возведение комплексного числа в комплексную степень.
ComplexToStr:String;// строковое предстовление комплексного числа
StrToComplex(S:String):TComplex; //преобразование строки в комплексное число

=============================================================================
  по определению:
 Комплексные числа  С — это пара (a,b) действительных чисел с заданными
 определенным образом операциями умножения и сложения.
 Комплексное число Z записывают как  Z=a+ib,  число a  называется действительной
 частью числа Z,  а число b — мнимой частью числа Z.
 Их обозначают Re Z и Im Z соответственно:

 Зависимости: SysUtils,Math,FormComplex
 SysUtils-используем функции:типы данных и тп (класс исключений)
 Math-используем функции: Power, arcTang2
 FormComplex-используем функции и типы: TFormComplex, TFormComplex.Create(const X: Complex);
 =============================================================================
 Среда разработки: Lazarus
 Компилятор FPC:   FPC v2.2.4
 Автор: Maxizar
 Дата создания: 28.02.2010
 Дата редактирования: 30.04.2011

 ==Модуль для fft анализа урезан
 }
{$H+}

interface

uses
   SysUtils,Math, ucommonmath;


const
  MinComplex_s  =  1.5e-45;
  MaxComplex_s  =  3.4e+38;
  MinComplex_d  =  5.0e-324;
  MaxComplex_d  =  1.7e+308;


Type
  PComplex_d =^TComplex_d;

  TComplex_d = record
    Re,
    Im:double;
    class operator Add(d:double; c:TComplex_d):TComplex_d;
    class operator Add(c1,c2:TComplex_d):TComplex_d;

    class operator Subtract(c:TComplex_d; r:double):TComplex_d;
    class operator Subtract(r:double; c:TComplex_d):TComplex_d;
    class operator Subtract(c1:TComplex_d; c2:TComplex_d):TComplex_d;
    class operator Negative(c1:TComplex_d):TComplex_d;

    class operator 	Multiply(r: double; c: TComplex_d) : TComplex_d;
    class operator 	Multiply(c: TComplex_d; r: double) : TComplex_d;
    class operator 	Multiply(c1: TComplex_d; c2: TComplex_d) : TComplex_d;

    class operator 	Divide(r: double; c: TComplex_d) : TComplex_d;
    class operator 	Divide(c: TComplex_d; r: double) : TComplex_d;
    class operator 	Divide(c1: TComplex_d; c2: TComplex_d) : TComplex_d;

    class operator 	Equal(r: double; c: TComplex_d) : boolean;
    class operator 	Equal(c: TComplex_d; r: double) : boolean;
    class operator 	Equal(c1: TComplex_d; c2: TComplex_d) : boolean;

    class operator 	Explicit(L : double) : TComplex_d;
    class operator 	Explicit(L : integer) : TComplex_d;

    class operator 	Implicit(L : double) : TComplex_d;
    class operator 	Implicit(L : integer) : TComplex_d;
    class operator 	Implicit(L : TComplex_d) : Extended;
    class operator 	Implicit(L : TComplex_d) : double;
    class operator 	Implicit(L : TComplex_d) : integer;
  end;

  TCmxArray_d    = array of TComplex_d;
  TIndexArray  = array of Integer;

   // Функции чисто  комплексного типа
  function Sopr(const X:TComplex_d):TComplex_d;  //Возвращает сопряженныую величину комплексного числа
  function Multiply_i(const X:TComplex_d):TComplex_d;//умножение на мнимую единицу
  function MultiplyCmpx(c1, c2:TComplex_d):TComplex_d;//умножение на мнимую единицу
  function Flip(const X:TComplex_d):TComplex_d;      // поменять местами Re Im
  // function Arg (const X:TComplex_d):double;    // аргумент комлексного числа
  // Математические функции от комплексного типа
  function abs  (const X:TComplex_d):Real;  //модуль комплексного числа
  function mod2 (const X:TComplex_d):Real; //модуль в квадрате
   //function StepenNReal   (const Basa:TComplex;const Stepen:Real):TComplex;// Значение целой положительной степени комплексного аргумента, значение функции f(z) = z^n
   //function StepenNComplex(const Basa:TComplex; const Stepen:TComplex):TComplex;//Возведение комплексного числа в комплексную степень.
   //function Ln (const X:TComplex):TComplex;//Натуральный логарифм комплексной переменной
   //function Log(const Basa:Real;const X:TComplex):TComplex; //логарифм с базой Basa
  function exp(const X:TComplex_d):TComplex_d;//экспонетна от комплексного числа

  function phase_deg(r1,i1,r2,i2:double):double;
  function phase_rad(r1,i1,r2,i2:double):double;

     //    Тригонометрические функции от комплексного типа
     //function Cos  (const X:TComplex):TComplex;
     //function Sin  (const X:TComplex):TComplex;
     //function Tang (const X:TComplex):TComplex;
     //function Cotan(const X:TComplex):TComplex;
     //
     //    Обратные Тригонометрические функции от комплексного типа
     //function ArcCos  (const X:TComplex):TComplex;
     //function ArcSin  (const X:TComplex):TComplex;
     //function ArcTang (const X:TComplex):TComplex;
     //function ArcCotan(const X:TComplex):TComplex;
     //
     //    Гиперболические функции от комплексного типа
     //function Cosh  (const X:TComplex):TComplex;
     //function Sinh  (const X:TComplex):TComplex;
     //function Tangh (const X:TComplex):TComplex;
     //function Cotanh(const X:TComplex):TComplex;
     //
     //    Обратные Гиперболические функции от комплексного типа
     //function ArcCosh  (const X:TComplex):TComplex;
     //function ArcSinh  (const X:TComplex):TComplex;
     //function ArcTangh (const X:TComplex):TComplex;
     //function ArcCotanh(const X:TComplex):TComplex;

     //  Строковые функции для\От  комплексного типа
     //function ComplexToStr (const X:TComplex):String;// строковое предстовление комплексного числа
     //function ComplexToStrF(const X:TComplex;Const Format: TFloatFormat;
     //                       Const Precision, Digits: Integer):String;
     //function StrToComplex(const S:String):TComplex;}

implementation

const
  c_radtodeg = 57.295779513;
  c_degtorad = 0.01745329251994329576923690768489;
  c_pi_half=c_pi/2;
  c_pi_double=c_pi*2;

//uses FormComplex;

function phase_deg(r1,i1,r2,i2:double):double;
BEGIN
  result:=phase_rad(r1,i1,r2,i2)*c_radtodeg;
END;

function getquad(r,i:double):integer;
begin
  if r>0 then
  begin
    if i>0 then
    begin
      result:=1;
    end
    else
    begin
      result:=4;
    end;
  end
  else
  begin
    if i>0 then
    begin
      result:=2;
    end
    else
    begin
      result:=3;
    end;
  end;
end;

function PhaseCmx_rad(r,i:double):double;
var
  q:integer;
  a:double;
begin
  if r=0 then
  begin
    if i>0 then
      a:=c_pi_half
    else
      a:=c_pi_half;
  end
  else
  begin
    a:=ArcTan(i/r);
  end;
  q:=getquad(r,i);
  case q of
   3:a:=a+c_pi;
   2:a:=a+c_pi_double;
  end;
  result:=a;
end;

function phase_rad(r1,i1,r2,i2:double):double;
var
  a1, a2:double;
begin
  //m1:=sqrt(r1*r1+i1*i1);
  //m2:=sqrt(r2*r2+i2*i2);
  //result:=arccos((r1*r2+i1*i2)/m1*m2);
  a1:=PhaseCmx_rad(r1,i1);
  a2:=PhaseCmx_rad(r2,i2);
  result:=a1-a2;
end;

class operator TComplex_d.Add(d: double; c:TComplex_d): TComplex_d;
begin
  result.re:=c.re+d;
  result.Im:=c.im;
end;

class operator TComplex_d.Add(c1,c2:TComplex_d): TComplex_d;
asm
  FLD   TComplex_d.Re [EAX]
  FLD   TComplex_d.Re [EDX]
  FADD
  FSTP  TComplex_d.Re [ECX]
  FLD   TComplex_d.Im [EAX]
  FLD   TComplex_d.Im [EDX]
  FADD
  FSTP  TComplex_d.Im [ECX]
  //result.re:=c1.re+c2.re;
  //result.Im:=c1.im+c2.im;
end;

class operator TComplex_d.Subtract(c:TComplex_d; r:double):TComplex_d;
begin
  result.Re:=c.Re-r;
  result.Im:=c.Im;
end;

class operator TComplex_d.Subtract(r:double; c:TComplex_d):TComplex_d;
begin
  result.Re:=r-c.Re;
  result.Im:=-c.Im;
end;

class operator TComplex_d.Subtract(c1:TComplex_d; c2:TComplex_d):TComplex_d;
asm
  FLD   TComplex_d.Re [EAX]
  FLD   TComplex_d.Re [EDX]
  FSUB
  FSTP  TComplex_d.Re [ECX]
  FLD   TComplex_d.Im [EAX]
  FLD   TComplex_d.Im [EDX]
  FSUB
  FSTP  TComplex_d.Im [ECX]
  //begin
  //    z.Re:=L.Re-R.Re;
  //    z.Im:=L.Im-R.Im;
end;

class operator TComplex_d.Negative(c1:TComplex_d):TComplex_d;
begin
  result.re:=-c1.re;
  result.im:=-c1.im;
end;

class operator 	TComplex_d.Multiply(r: double; c: TComplex_d) : TComplex_d;
begin
  try
    result.Re:=c.Re*r;
    result.Im:=c.Im*r;
  except
    result.Re:=MaxComplex_d;
    result.Im:=MaxComplex_d;
  end;
end;

class operator 	TComplex_d.Multiply(c: TComplex_d; r: double) : TComplex_d;
begin
  result:=r*c;
end;

class operator 	TComplex_d.Multiply(c1: TComplex_d; c2: TComplex_d) : TComplex_d;
begin
  //  MOVaPD    xmm0, [EDX]       //xmm0 = [L.Re, L.Im]
  //  MOVDDUP   xmm1, [EBX]       //xmm1 = [R.Re, R.Re]
  //  MOVDDUP   xmm2, [EBX+8]     //xmm2 = [R.Im, R.Im]
  //  MULPD     xmm2, xmm0        //xmm2 = [L.Re*R.Im, L.Im*R.Im]
  //  MULPD     xmm1, xmm0        //xmm1 = [L.Re*R.Re, L.Im*R.Re]
  //  SHUFPD    xmm2, xmm2, 1     //xmm2 = [L.Im*R.Im, L.Re*R.Im]
  //  ADDSUBPD  xmm1, xmm2        //xmm1 = [L.Re*R.Re-L.Im*R.Im; L.Im*R.Re+L.Re*R.Im]
  result.Re:=(c1.Re*c2.Re)-(c1.Im*c2.Im);
  result.Im:=(c1.Re*c2.Im)+(c2.Re*c1.Im);
end;

// почему то медленнее чем процедура выше!!!
function MultiplyCmpx(c1, c2:TComplex_d):TComplex_d;//умнажение на мнимую единицу
asm
  MOVuPD    xmm0, [EDX]       //xmm0 = [L.Re, L.Im]
  MOVDDUP   xmm1, [EBX]       //xmm1 = [R.Re, R.Re]
  MOVDDUP   xmm2, [EBX+8]     //xmm2 = [R.Im, R.Im]
  MULPD     xmm2, xmm0        //xmm2 = [L.Re*R.Im, L.Im*R.Im]
  MULPD     xmm1, xmm0        //xmm1 = [L.Re*R.Re, L.Im*R.Re]
  SHUFPD    xmm2, xmm2, 1     //xmm2 = [L.Im*R.Im, L.Re*R.Im]
  ADDSUBPD  xmm1, xmm2        //xmm1 = [L.Re*R.Re-L.Im*R.Im; L.Im*R.Re+L.Re*R.Im]
  MOVuPD    [EAX], xmm1       //xmm0 = [L.Re, L.Im]
end;

class operator 	TComplex_d.Divide(r: double; c: TComplex_d) : TComplex_d;
var
  Temp:TComplex_d;
begin
  Temp.Re:=r;
  Temp.Im:=0;
  result:=Temp/R;
end;

class operator 	TComplex_d.Divide(c: TComplex_d; r: double) : TComplex_d;
begin
  if R<>0 then
  begin
    result.Re:=c.Re/R;
    result.Im:=c.Im/R;
  end
  else
  begin //деление на ноль по идее бесконечность (максимальное значение переменной)
    result.Re:=MaxComplex_d;
    result.Im:=MaxComplex_d;
  end;
end;

class operator 	TComplex_d.Divide(c1: TComplex_d; c2: TComplex_d) : TComplex_d;
var
  delitel:Extended;
begin
  if (c2.Im<>0) or (c2.Re<>0) then
  begin
    delitel:=sqr(c2.Re)+sqr(c2.Im);
    result.Re:=((c1.Re*c2.Re)+(c1.Im*c2.Im))/delitel;
    result.Im:=((c2.Re*c1.Im)-(c1.Re*c2.Im))/delitel;
  end
  else
  begin //деление на ноль по идее бесконечность (максимальное значение переменной)
    result.Re:=MaxComplex_d;
    result.Im:=MaxComplex_d;
  end;
end;

class operator 	TComplex_d.Equal(r: double; c: TComplex_d) : boolean;
begin
  result:=(r=c.Re) and (c.Im=0);
end;

class operator 	TComplex_d.Equal(c: TComplex_d; r: double) : boolean;
begin
  result:= (R=c.Re) and (c.Im=0);
end;

class operator 	TComplex_d.Equal(c1: TComplex_d; c2: TComplex_d) : boolean;
begin
  result:=(c1.Re=c2.Re) and (c1.Im=c2.Im);
end;

class operator TComplex_d.Explicit(L: integer): TComplex_d;
begin
  result.re:=l;
  result.Im:=0;
end;

class operator TComplex_d.Implicit(L: integer): TComplex_d;
begin
  result.Re:=L;
  result.Im:=0;
end;

class operator TComplex_d.Explicit(L: double): TComplex_d;
begin
  result.Re:=L;
  result.Im:=0;
end;

class operator 	TComplex_d.Implicit(L : double) : TComplex_d;
begin
  result.Re:=L;
  result.Im:=0;
end;

class operator 	TComplex_d.Implicit(L : TComplex_d) : Extended;
begin
  result:=L.Re;
end;

class operator 	TComplex_d.Implicit(L : TComplex_d) : double;
begin
  result:=L.Re;
end;

class operator 	TComplex_d.Implicit(L : TComplex_d) : integer;
begin
  result:=Round(L.Re);
end;

{===================  Функции чисто  комплексного типа   begin   =============}
 //--------------------------------------------------------------------------//

function Sopr(const X:TComplex_d): TComplex_d; //Возвращает сопряженныую величину комплексного числа
begin
  Result.Re:=   X.Re;
  Result.Im:=  -X.Im;
end;
//------------------------------------------------------------------//

function Multiply_i(const X:TComplex_d): TComplex_d;// Result = i*X
begin
  Result.Re:= -X.Im;
  Result.Im:=  X.Re;
end;
//------------------------------------------------------------------//

function Flip(const X:TComplex_d): TComplex_d;  // поменять местами Re и Im
begin
  Result.Re:= X.Im;
  Result.Im:= X.Re;
end;
{===================  Функции чисто  комплексного типа   END   ===============}
//---------------------------------------------------------------------------//


{================= Математические функции от комплексного типа  begin =========}
//----------------------------------------------------------------------------//
function abs(const X:TComplex_d):Real; // |z| = (Re^2 + Im^2)^0.5
begin
 try
  Result:=sqrt(sqr(X.Re)+sqr(X.Im))
 except
   Result:=MaxComplex_d;
 end;
end;

//------------------------------------------------------------------//
function mod2(const X:TComplex_d): Real; // |z|^2
var TempABS:Real;
begin
 TempABS:=abs(X); // |z|
  try
     Result:= TempABS*TempABS;// |z|^2
   except
     Result:=MaxComplex_d;
    end;
end;
//------------------------------------------------------------------//

function exp(const X:TComplex_d): TComplex_d; //экспонетна от комплексного числа
//Если z = x + i*y = r (cos(j) + i*sin(j) ), то значения функции f(z) = exp(z) вычисляются по формуле
//f(z) = e^z = e^(x+iy) = e^x * e^iy = e^x (cos(y) + i*sin(y)).
var TempExp:Real;
    ImCos,ImSin:extended;
begin
  TempExp:=System.Exp(X.Re);
  SinCos(X.Im,ImSin,ImCos);
  Result.Re:=TempExp*ImCos;
  Result.Im:=TempExp*ImSin;
end;

end.
