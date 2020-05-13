{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ���������� ��� ��������� ���������� ������          }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}

unit signal;
interface
uses Windows;
const
   //S_CHARACT
   SC_NORMAL =  0;
   SC_SPECTR =  1;
   SC_LOGSPEC = 2;

   // ���� �� (TT=Tannsformer Type)
   //S_TTYPE
   TT_NULL =    0;
   TT_TRANSF =  1;
   TT_MULTI =   2;
   TT_KOEF =    3;
   TT_XYNODE =  4;

   // ������� (D=Details) ����� ����� ��� ���� = TT_TRANSF
   //S_TTYPED
   TTD_LINE =      $10;
   TTD_TRANSF1 =   $20;
   TTD_TRANSF2 =   $30;
   TTD_TRANSFN =   $40;
   TTD_TRANSFINT = $50;

type
   PNOTIFY = procedure(const i: integer); 

   ISignal = interface
       (*virtual ~ISignal() {}; - ��� ����������� ����������, � �������� �� �������
       �� � vtbl ����� ���������� � �������� -1*)
      function GetX(const i: integer): double; stdcall;
      function GetY(const i: integer; const Tare: boolean): double; stdcall;
      function GetYX(const x: double; const pow: integer): double; stdcall;
      procedure SetX(const i: integer; const x: double); stdcall;
      procedure SetY(const i: integer; const y: double; const Tare: boolean); stdcall;

      function GetSize: integer; stdcall;
      procedure Resize(const size: integer); stdcall;
      function GetTransformerType: integer; stdcall;

      // ������ - ������� �� �����������...
      function GetTransformer: pointer; stdcall;
      // ������ - ������� �� �����������...
      procedure SetTransformer(const newtr: pointer); stdcall;

      // ���������� ��� ������ �������: VT_I2, VT_R4, VT_R8 � �.�.
      function GetDataType: integer; stdcall;

      // ������������� (� ��������), �� ����� ������ ��� ������������� X
      function GetDeltaX: double; stdcall;
      // ������������� ������������� (� ��������), �� ����� ������ ��� ������������� X
      procedure SetDeltaX(const deltaX: double); stdcall;

      // ���������� ����� ������ (� ��������), �� ����� ������ ��� ������������� X
      function GetStartX: double; stdcall;
      // ������������� ����� ������ (� ��������), �� ����� ������ ��� ������������� X
      procedure SetStartX(const startX: double); stdcall;
      // ���������� ����� ������ (���������), ����� ����� ������ (�����:)
      procedure GetStartTime( var lpStartTime: SYSTEMTIME); stdcall;

      // ���������� ����� ������ ������� � ��������, ��������� ��� �������������
      function GetTimeCounter: DWORD; stdcall;

      // ���������� ������� �������� �������, ����� ����� ��� ����� X
      // (��. ����� GetStartX, GetDeltaX)
      procedure GetRangeX(var minX: double; var maxX: double); stdcall;
      // ���������� �����. � ������. �������� �������
      function GetMinMax(var min: double; var max: double;
                         const fnNotify: PNOTIFY): integer; stdcall;
      function SearchMinMax(const fnNotify: PNOTIFY): integer; stdcall;

      function IsMinMaxCalculated: boolean; stdcall;

      // ���������� ������������ ��������� ��������������
      procedure GetK1K0(var k1: double; var k0: double); stdcall;
      // ������ ������������ ��������� ��������������
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

      // ���� ��������� ������� ��� ������ ������ ��������� ��������.
      // � �������� ���� y=y(i) ���������� ��������� ������ ����� ��� �����
      // ������������ ������.
      function IndexOf(const x: double): integer; stdcall;

      // ������ �����������/�������������
      function lockdata: integer; stdcall;
      function unlockdata: integer; stdcall;
      function lockcount: integer; stdcall;
   end;

implementation
end.


