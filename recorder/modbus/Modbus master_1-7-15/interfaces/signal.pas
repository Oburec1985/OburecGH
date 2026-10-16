{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для получения измеренных данных          }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit signal;
interface
uses Windows;
const
   //S_CHARACT
   SC_NORMAL =  0;
   SC_SPECTR =  1;
   SC_LOGSPEC = 2;

   // типы ТХ (TT=Tannsformer Type)
   //S_TTYPE
   TT_NULL =    0;
   TT_TRANSF =  1;
   TT_MULTI =   2;
   TT_KOEF =    3;
   TT_XYNODE =  4;

   // подтипы (D=Details) имеют смысл при типе = TT_TRANSF
   //S_TTYPED
   TTD_LINE =      $10;
   TTD_TRANSF1 =   $20;
   TTD_TRANSF2 =   $30;
   TTD_TRANSFN =   $40;
   TTD_TRANSFINT = $50;

type
   PNOTIFY = procedure(const i: integer); 

   ISignal = interface
       (*virtual ~ISignal() {}; - это виртуальный деструктор, в описании он вначале
       но в vtbl может находиться с индексом -1*)
      function GetX(const i: integer): double; stdcall;
      function GetY(const i: integer; const Tare: boolean): double; stdcall;
      function GetYX(const x: double; const pow: integer): double; stdcall;
      procedure SetX(const i: integer; const x: double); stdcall;
      procedure SetY(const i: integer; const y: double; const Tare: boolean); stdcall;

      function GetSize: integer; stdcall;
      procedure Resize(const size: integer); stdcall;
      function GetTransformerType: integer; stdcall;

      // Резерв - функцию не использвать...
      function GetTransformer: pointer; stdcall;
      // Резерв - функцию не использвать...
      procedure SetTransformer(const newtr: pointer); stdcall;

      // возвращает тип данных сигнала: VT_I2, VT_R4, VT_R8 и т.п.
      function GetDataType: integer; stdcall;

      // дискретизация (в секундах), не имеет смысла при неравномерном X
      function GetDeltaX: double; stdcall;
      // устанавливает дискретизацию (в секундах), не имеет смысла при неравномерном X
      procedure SetDeltaX(const deltaX: double); stdcall;

      // возвращает время начала (в секундах), не имеет смысла при неравномерном X
      function GetStartX: double; stdcall;
      // устанавливает время начала (в секундах), не имеет смысла при неравномерном X
      procedure SetStartX(const startX: double); stdcall;
      // возвращает время начала (ЛОКАЛЬНОЕ), имеет смысл всегда (почти:)
      procedure GetStartTime( var lpStartTime: SYSTEMTIME); stdcall;

      // возвращает время начала сигнала в отсчетах, требуется для синхронизации
      function GetTimeCounter: DWORD; stdcall;

      // возвращает иксовый диапазон сигнала, имеет смысл при любом X
      // (см. также GetStartX, GetDeltaX)
      procedure GetRangeX(var minX: double; var maxX: double); stdcall;
      // возвращает миним. и максим. значения сигнала
      function GetMinMax(var min: double; var max: double;
                         const fnNotify: PNOTIFY): integer; stdcall;
      function SearchMinMax(const fnNotify: PNOTIFY): integer; stdcall;

      function IsMinMaxCalculated: boolean; stdcall;

      // возвращает коэффициенты линейного преобразования
      procedure GetK1K0(var k1: double; var k0: double); stdcall;
      // задает коэффициенты линейного преобразования
      procedure SetK1K0(const k1: double; const k0: double); stdcall;

      // *** SignalInfo ***
      function GetSName: LPCSTR; stdcall;
      procedure SetSName(const newSName: LPCSTR); stdcall;

      function GetNameX: LPCSTR; stdcall;
      procedure SetNameX(const newNameX: LPCSTR); stdcall;

      function GetNameY: LPCSTR; stdcall;
      procedure SetNameY(const newNameY: LPCSTR); stdcall;

      function GetComment: LPCSTR; stdcall;
      procedure SetComment(const newComment: LPCSTR); stdcall;

      function GetCharacteristic: word; stdcall;
      procedure SetCharacteristic(const newCharacteristic: word); stdcall;

      // ищет ближайший меньший или точный индекс заданного элемента.
      // В векторах типа y=y(i) необходимо перекрыть данный метод для более
      // оптимального поиска.
      function IndexOf(const x: double): integer; stdcall;

      // Методы локирования/анлокирования
      function lockdata: integer; stdcall;
      function unlockdata: integer; stdcall;
      function lockcount: integer; stdcall;
   end;

implementation
end.


