{---------------------------------------------------------------------}
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ �������� ����������� ��� ��������������� ������� � ������-   }
{ �����.                                                              }
{ ����������: Borland Delphi 6.0                                      }
{ ��� "��� ����" 2004�.                                               }
{---------------------------------------------------------------------}

unit DevAPI;
interface
uses Windows;
type
   {��������� ��������������� ���������� �������� ������� ������}
   IAnalogOutput = interface
   ['{B8A31A21-6125-11d7-9244-00E029288A7F}']
        {������� �������� � ������ (� ���) ������ ��� ��������}
   	function LoadPlayDACData(const size: DWORD;
                                 var data: WORD): HRESULT; stdcall;
        {������� �������� ��������� �������}
   	function StopPlayDAC: HRESULT; stdcall;
        {������ �������� ��������� �������}
   	function StartPlayDAC(var freq: double): HRESULT; stdcall;

        {��������� ������� ������ ������ (���)}
   	function GetPlayDACDataMaxCount(var count: DWORD): HRESULT; stdcall;
        {��������� ��������� ��� ������������� ������� (� �����)}
   	function GetPlayDACCodeRange(var min: integer;
                                     var max: integer): HRESULT; stdcall;
        {��������� ��������� ��� ������������� ������� (� ������)}
   	function GetPlayDACVoltRange(var min: double;
                                     var max: double): HRESULT; stdcall;
        {��������� ��������� ������� ������������� ��� ������������� �������}
   	function GetPlayDACFreqRange(var min: double;
                                     var max: double): HRESULT; stdcall;
   end;

   IDigitalInput = interface
   ['{CB4C4901-2302-11d7-9243-00E029288A7F}']
        {��������� �������� ����� � ��������� �����}
        function InputWord(var dwValue: DWORD): HRESULT; stdcall;
   end;



   IDigitalOutput = interface
   ['{DA1B4C61-DF78-11d6-9243-00E029288A7F}']
        {����� �������� ����� � ��������� �����}
        function OutputWord(const dwValue: DWORD): HRESULT; stdcall;
   end; 

implementation

end.
