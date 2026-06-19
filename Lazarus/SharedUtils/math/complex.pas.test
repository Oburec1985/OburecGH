unit complex;

{$mode delphi}



 {РњРѕРґСѓР»СЊ Complex СЃРѕРґРµСЂР¶РёС‚ РѕРїРёСЃР°РЅРёРµ С‚РёРїР° TComplex (РўРёРї РєРѕРјРїР»РµРєСЃРЅС‹С… С‡РёСЃРµР»),
 РІ РІРёРґРµ РєР»Р°СЃСЃР°, СЃ РїРµСЂРµРѕРїСЂРµРґРµР»РµРЅРёРµРј (РїРµСЂРµРіСЂСѓР·РєРѕР№) РѕСЃРЅРѕРІРЅС‹С… РѕРїРµСЂР°С†РёСЏ РЅР°Рґ
 С‡РёСЃР»Р°РјРё (+,-,/,*)  СЃРј РЅРёР¶Рµ.
 Р’РІРµРґРµРЅС‹ С‚Р°РєР¶Рµ РіРёРїРµСЂР±РѕР»РёС‡РµСЃРєРёРµ Рё С‚СЂРёРіРѕРЅРѕРјРµС‚СЂРёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё С‚Р°РєРёРµ РєР°Рє (Cos, Sin,
 Tang,Cotan, Cosh,Sinh,Tangh,Cotanh)
 Рё РѕР±СЂР°С‚РЅС‹Рµ РёРј С„СѓРЅРєС†РёРё (arcCos, ArcSin....)
 Р”РѕР±Р°РІР»РµРЅС‹ РґР»СЏ СѓРґРѕР±СЃС‚РІР° С‚Р°РєРёРµ С„СѓРЅРєС†РёРё РєР°Рє:
 arg - РІРѕР·РІСЂР°С‰Р°РµС‚ Р°СЂРіСѓРјРµРЅС‚ С‡РёСЃР»Р° Z
 abs - РјРѕРґСѓР»СЊ С‡РёСЃР»Р° Z
 Sopr - РІРѕР·РІСЂР°С‰Р°РµС‚ СЃРѕРїСЂСЏР¶РµРЅРЅРѕРµ С‡РёСЃР»Рѕ С‡РёСЃР»Сѓ Z
 Ln - РЅР°С‚СѓСЂР°Р»СЊРЅС‹Р№ Р»РѕРіР°СЂРёС„Рј С‡РёСЃР»Р° Z
 Exp - Р­РєСЃРїРѕРЅРµРЅС‚Р° РѕС‚ С‡РёСЃР»Р° Z
 Multiply_i - С„СѓРЅРєС†РёСЏ РІРѕР·РІСЂР°С‰Р°РµС‚ С‡РёСЃР»Рѕ Z СѓРјРЅРѕР¶РµРЅРЅРѕРµ РЅР° РјРЅРёРјСѓСЋ РµРґРµРЅРёС†Сѓ С‚Рµ Z*i
StepenNReal(Stepen:Real):TComplex;// Р—РЅР°С‡РµРЅРёРµ С†РµР»РѕР№ РїРѕР»РѕР¶РёС‚РµР»СЊРЅРѕР№ СЃС‚РµРїРµРЅРё РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ Р°СЂРіСѓРјРµРЅС‚Р°, Р·РЅР°С‡РµРЅРёРµ С„СѓРЅРєС†РёРё f(z) = z^n
StepenNComplex(Stepen:TComplex):TComplex;//Р’РѕР·РІРµРґРµРЅРёРµ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р° РІ РєРѕРјРїР»РµРєСЃРЅСѓСЋ СЃС‚РµРїРµРЅСЊ.
ComplexToStr:String;// СЃС‚СЂРѕРєРѕРІРѕРµ РїСЂРµРґСЃС‚РѕРІР»РµРЅРёРµ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
StrToComplex(S:String):TComplex; //РїСЂРµРѕР±СЂР°Р·РѕРІР°РЅРёРµ СЃС‚СЂРѕРєРё РІ РєРѕРјРїР»РµРєСЃРЅРѕРµ С‡РёСЃР»Рѕ

=============================================================================
  РїРѕ РѕРїСЂРµРґРµР»РµРЅРёСЋ:
 РљРѕРјРїР»РµРєСЃРЅС‹Рµ С‡РёСЃР»Р°  РЎ вЂ” СЌС‚Рѕ РїР°СЂР° (a,b) РґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹С… С‡РёСЃРµР» СЃ Р·Р°РґР°РЅРЅС‹РјРё
 РѕРїСЂРµРґРµР»РµРЅРЅС‹Рј РѕР±СЂР°Р·РѕРј РѕРїРµСЂР°С†РёСЏРјРё СѓРјРЅРѕР¶РµРЅРёСЏ Рё СЃР»РѕР¶РµРЅРёСЏ.
 РљРѕРјРїР»РµРєСЃРЅРѕРµ С‡РёСЃР»Рѕ Z Р·Р°РїРёСЃС‹РІР°СЋС‚ РєР°Рє  Z=a+ib,  С‡РёСЃР»Рѕ a  РЅР°Р·С‹РІР°РµС‚СЃСЏ РґРµР№СЃС‚РІРёС‚РµР»СЊРЅРѕР№
 С‡Р°СЃС‚СЊСЋ С‡РёСЃР»Р° Z,  Р° С‡РёСЃР»Рѕ b вЂ” РјРЅРёРјРѕР№ С‡Р°СЃС‚СЊСЋ С‡РёСЃР»Р° Z.
 пїЅС… РѕР±РѕР·РЅР°С‡Р°СЋС‚ Re Z Рё Im Z СЃРѕРѕС‚РІРµС‚СЃС‚РІРµРЅРЅРѕ:

 Р—Р°РІРёСЃРёРјРѕСЃС‚Рё: SysUtils,Math,FormComplex
 SysUtils-РёСЃРїРѕР»СЊР·СѓРµРј С„СѓРЅРєС†РёРё:С‚РёРїС‹ РґР°РЅРЅС‹С… Рё С‚Рї (РєР»Р°СЃСЃ РёСЃРєР»СЋС‡РµРЅРёР№)
 Math-РёСЃРїРѕР»СЊР·СѓРµРј С„СѓРЅРєС†РёРё: Power, arcTang2
 FormComplex-РёСЃРїРѕР»СЊР·СѓРµРј С„СѓРЅРєС†РёРё Рё С‚РёРїС‹: TFormComplex, TFormComplex.Create(const X: Complex);
 =============================================================================
 РЎСЂРµРґР° СЂР°Р·СЂР°Р±РѕС‚РєРё: Lazarus
 РљРѕРјРїРёР»СЏС‚РѕСЂ FPC:   FPC v2.2.4
 РђРІС‚РѕСЂ: Maxizar
 Р”Р°С‚Р° СЃРѕР·РґР°РЅРёСЏ: 28.02.2010
 Р”Р°С‚Р° СЂРµРґР°РєС‚РёСЂРѕРІР°РЅРёСЏ: 30.04.2011

 ==РњРѕРґСѓР»СЊ РґР»СЏ fft Р°РЅР°Р»РёР·Р° СѓСЂРµР·Р°РЅ
 }
{$H+}

interface

uses
   SysUtils,Math;


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
    {$IFNDEF FPC}
    class operator 	Implicit(L : TComplex_d) : Extended;
{$ENDIF}
    class operator 	Implicit(L : TComplex_d) : double;
    class operator 	Implicit(L : TComplex_d) : integer;
  end;

  TCmxArray_d    = array of TComplex_d;
  TComplex       = TComplex_d;
  TCmxArray      = TCmxArray_d;
  TIndexArray  = array of Integer;

   // Р¤СѓРЅРєС†РёРё С‡РёСЃС‚Рѕ  РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
  function Sopr(const X:TComplex_d):TComplex_d;  //Р’РѕР·РІСЂР°С‰Р°РµС‚ СЃРѕРїСЂСЏР¶РµРЅРЅС‹СѓСЋ РІРµР»РёС‡РёРЅСѓ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
  function Multiply_i(const X:TComplex_d):TComplex_d;//СѓРјРЅРѕР¶РµРЅРёРµ РЅР° РјРЅРёРјСѓСЋ РµРґРёРЅРёС†Сѓ
  function MultiplyCmpx(c1, c2:TComplex_d):TComplex_d;//СѓРјРЅРѕР¶РµРЅРёРµ РЅР° РјРЅРёРјСѓСЋ РµРґРёРЅРёС†Сѓ
  function Flip(const X:TComplex_d):TComplex_d;      // РїРѕРјРµРЅСЏС‚СЊ РјРµСЃС‚Р°РјРё Re Im
  // function Arg (const X:TComplex_d):double;    // Р°СЂРіСѓРјРµРЅС‚ РєРѕРјР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
  // РњР°С‚РµРјР°С‚РёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
  function abs  (const X:TComplex_d):Real;  //РјРѕРґСѓР»СЊ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
  function mod2 (const X:TComplex_d):Real; //РјРѕРґСѓР»СЊ РІ РєРІР°РґСЂР°С‚Рµ
   //function StepenNReal   (const Basa:TComplex;const Stepen:Real):TComplex;// Р—РЅР°С‡РµРЅРёРµ С†РµР»РѕР№ РїРѕР»РѕР¶РёС‚РµР»СЊРЅРѕР№ СЃС‚РµРїРµРЅРё РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ Р°СЂРіСѓРјРµРЅС‚Р°, Р·РЅР°С‡РµРЅРёРµ С„СѓРЅРєС†РёРё f(z) = z^n
   //function StepenNComplex(const Basa:TComplex; const Stepen:TComplex):TComplex;//Р’РѕР·РІРµРґРµРЅРёРµ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р° РІ РєРѕРјРїР»РµРєСЃРЅСѓСЋ СЃС‚РµРїРµРЅСЊ.
   //function Ln (const X:TComplex):TComplex;//РќР°С‚СѓСЂР°Р»СЊРЅС‹Р№ Р»РѕРіР°СЂРёС„Рј РєРѕРјРїР»РµРєСЃРЅРѕР№ РїРµСЂРµРјРµРЅРЅРѕР№
   //function Log(const Basa:Real;const X:TComplex):TComplex; //Р»РѕРіР°СЂРёС„Рј СЃ Р±Р°Р·РѕР№ Basa
  function exp(const X:TComplex_d):TComplex_d;//СЌРєСЃРїРѕРЅРµС‚РЅР° РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°

  function phase_deg(r1,i1,r2,i2:double):double;
  function phase_rad(r1,i1,r2,i2:double):double;

     //    РўСЂРёРіРѕРЅРѕРјРµС‚СЂРёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
     //function Cos  (const X:TComplex):TComplex;
     //function Sin  (const X:TComplex):TComplex;
     //function Tang (const X:TComplex):TComplex;
     //function Cotan(const X:TComplex):TComplex;
     //
     //    РћР±СЂР°С‚РЅС‹Рµ РўСЂРёРіРѕРЅРѕРјРµС‚СЂРёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
     //function ArcCos  (const X:TComplex):TComplex;
     //function ArcSin  (const X:TComplex):TComplex;
     //function ArcTang (const X:TComplex):TComplex;
     //function ArcCotan(const X:TComplex):TComplex;
     //
     //    Р“РёРїРµСЂР±РѕР»РёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
     //function Cosh  (const X:TComplex):TComplex;
     //function Sinh  (const X:TComplex):TComplex;
     //function Tangh (const X:TComplex):TComplex;
     //function Cotanh(const X:TComplex):TComplex;
     //
     //    РћР±СЂР°С‚РЅС‹Рµ Р“РёРїРµСЂР±РѕР»РёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
     //function ArcCosh  (const X:TComplex):TComplex;
     //function ArcSinh  (const X:TComplex):TComplex;
     //function ArcTangh (const X:TComplex):TComplex;
     //function ArcCotanh(const X:TComplex):TComplex;

     //  РЎС‚СЂРѕРєРѕРІС‹Рµ С„СѓРЅРєС†РёРё РґР»СЏ\РћС‚  РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°
     //function ComplexToStr (const X:TComplex):String;// СЃС‚СЂРѕРєРѕРІРѕРµ РїСЂРµРґСЃС‚РѕРІР»РµРЅРёРµ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
     //function ComplexToStrF(const X:TComplex;Const Format: TFloatFormat;
     //                       Const Precision, Digits: Integer):String;
     //function StrToComplex(const S:String):TComplex;}

implementation

const
  c_pi = 3.14159265358979323846;
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
{$IFDEF FPC}
begin
  result.re:=c1.re+c2.re;
  result.Im:=c1.im+c2.im;
end;
{$ELSE}
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
{$ENDIF}

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
{$IFDEF FPC}
begin
  result.Re:=c1.Re-c2.Re;
  result.Im:=c1.Im-c2.Im;
end;
{$ELSE}
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
{$ENDIF}

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

// РїРѕС‡РµРјСѓ С‚Рѕ РјРµРґР»РµРЅРЅРµРµ С‡РµРј РїСЂРѕС†РµРґСѓСЂР° РІС‹С€Рµ!!!
function MultiplyCmpx(c1, c2:TComplex_d):TComplex_d;//пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
{$IFDEF FPC}
begin
  result.Re:=(c1.Re*c2.Re)-(c1.Im*c2.Im);
  result.Im:=(c1.Re*c2.Im)+(c2.Re*c1.Im);
end;
{$ELSE}
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
{$ENDIF}

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
  begin //РґРµР»РµРЅРёРµ РЅР° РЅРѕР»СЊ РїРѕ РёРґРµРµ Р±РµСЃРєРѕРЅРµС‡РЅРѕСЃС‚СЊ (РјР°РєСЃРёРјР°Р»СЊРЅРѕРµ Р·РЅР°С‡РµРЅРёРµ РїРµСЂРµРјРµРЅРЅРѕР№)
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
  begin //РґРµР»РµРЅРёРµ РЅР° РЅРѕР»СЊ РїРѕ РёРґРµРµ Р±РµСЃРєРѕРЅРµС‡РЅРѕСЃС‚СЊ (РјР°РєСЃРёРјР°Р»СЊРЅРѕРµ Р·РЅР°С‡РµРЅРёРµ РїРµСЂРµРјРµРЅРЅРѕР№)
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

{$IFNDEF FPC}
class operator 	TComplex_d.Implicit(L : TComplex_d) : Extended;
begin
  result:=L.Re;
end;
{$ENDIF}

class operator 	TComplex_d.Implicit(L : TComplex_d) : double;
begin
  result:=L.Re;
end;

class operator 	TComplex_d.Implicit(L : TComplex_d) : integer;
begin
  result:=Round(L.Re);
end;

{===================  Р¤СѓРЅРєС†РёРё С‡РёСЃС‚Рѕ  РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°   begin   =============}
 //--------------------------------------------------------------------------//

function Sopr(const X:TComplex_d): TComplex_d; //Р’РѕР·РІСЂР°С‰Р°РµС‚ СЃРѕРїСЂСЏР¶РµРЅРЅС‹СѓСЋ РІРµР»РёС‡РёРЅСѓ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
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

function Flip(const X:TComplex_d): TComplex_d;  // РїРѕРјРµРЅСЏС‚СЊ РјРµСЃС‚Р°РјРё Re Рё Im
begin
  Result.Re:= X.Im;
  Result.Im:= X.Re;
end;
{===================  Р¤СѓРЅРєС†РёРё С‡РёСЃС‚Рѕ  РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°   END   ===============}
//---------------------------------------------------------------------------//


{================= РњР°С‚РµРјР°С‚РёС‡РµСЃРєРёРµ С„СѓРЅРєС†РёРё РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‚РёРїР°  begin =========}
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

function exp(const X:TComplex_d): TComplex_d; //СЌРєСЃРїРѕРЅРµС‚РЅР° РѕС‚ РєРѕРјРїР»РµРєСЃРЅРѕРіРѕ С‡РёСЃР»Р°
//Р•СЃР»Рё z = x + i*y = r (cos(j) + i*sin(j) ), С‚Рѕ Р·РЅР°С‡РµРЅРёСЏ С„СѓРЅРєС†РёРё f(z) = exp(z) РІС‹С‡РёСЃР»СЏСЋС‚СЃСЏ РїРѕ С„РѕСЂРјСѓР»Рµ
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
