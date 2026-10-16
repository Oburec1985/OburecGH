{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для управления специализированными       }
{ вычислителями градуировочных функций                                }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit transformers;
interface
uses Windows;
const
   CLSID_ScaleTransformer: TGUID =       '{5B40FDE0-DC62-11d6-9243-00E029288A7F}';
   CLSID_InterpolateTransformer: TGUID = '{5B40FDE1-DC62-11d6-9243-00E029288A7F}';
   CLSID_LinearTransformer: TGUID =      '{863D3122-8564-11d7-9244-00E029288A7F}';
   CLSID_PolynomialTransformer: TGUID =  '{2ACAF762-FF20-11d7-9244-00E029288A7F}';

type
   {Масштабная градуировочная функция f(x) = a*x, где a - масштабный коэффициент}
   IScale = interface
   ['{509B9201-DC77-11d6-9243-00E029288A7F}']
      function PutScale(const dblValue: double): HRESULT; stdcall;
      function GetScale(var pdblValue: double): HRESULT; stdcall;
   end;

   {Градуировочная функция - Таблица интеполяции полиномом первой степени}
   IInterpolate = interface
   ['{509B9202-DC77-11d6-9243-00E029288A7F}']
      function SetNode(const dblValX: double; const dblValY: double;
                       const nIndex: integer): HRESULT; stdcall;
      function GetNode(var pdblValX: double; var pdblValY: double;
                       const nIndex: integer): HRESULT; stdcall;
      function GetNodesCounter: ULONG; stdcall;
      function SetExtrapolateMode(const fExtrapolate: boolean): HRESULT; stdcall;
      function GetExtrapolateMode: boolean; stdcall;
   end;

   {Градуировочная функция - полином первого порядка f(x) = ax + b}
   ILinear = interface
   ['{863D3121-8564-11d7-9244-00E029288A7F}']
      function PutA(const dblA: double): HRESULT; stdcall;
      function PutB(const dblB: double): HRESULT; stdcall;
      function GetA(var a_pdblA: double): HRESULT; stdcall;
      function GetB(var a_pdblB: double): HRESULT; stdcall;
   end;

   {Градуировочная функция - полином n-го порядка}
   IPolynomial = interface
   ['{2ACAF761-FF20-11d7-9244-00E029288A7F}']
      function SetPower(const nPower: ULONG): HRESULT; stdcall;
      function GetPower: ULONG; stdcall;
      function PutCoefficient(const dblCoefficient: double;
                              const nIndex:  integer): HRESULT; stdcall;
      function GetCoefficient(var pdblCoefficient: double;
                              const nIndex: integer): HRESULT; stdcall;
   end;

implementation
end.
