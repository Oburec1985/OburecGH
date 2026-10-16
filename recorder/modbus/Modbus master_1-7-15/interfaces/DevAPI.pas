{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейсов для низкоуровневого доступа к устрой-   }
{ ствам.                                                              }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit DevAPI;
interface
uses Windows;
type
   {Интерфейс низкоуровневого управления выходным каналом модуля}
   IAnalogOutput = interface
   ['{B8A31A21-6125-11d7-9244-00E029288A7F}']
        {Функция загрузки в модуль (в ЦАП) данных для гнерации}
   	function LoadPlayDACData(const size: DWORD;
                                 var data: WORD): HRESULT; stdcall;
        {Останов процесса генерации сигнала}
   	function StopPlayDAC: HRESULT; stdcall;
        {Запуск процесса генерации сигнала}
   	function StartPlayDAC(var freq: double): HRESULT; stdcall;

        {Получение размера буфера модуля (ЦАП)}
   	function GetPlayDACDataMaxCount(var count: DWORD): HRESULT; stdcall;
        {Получение даиапзона для генерируемого сигнала (в кодах)}
   	function GetPlayDACCodeRange(var min: integer;
                                     var max: integer): HRESULT; stdcall;
        {Получение даиапзона для генерируемого сигнала (в вльтах)}
   	function GetPlayDACVoltRange(var min: double;
                                     var max: double): HRESULT; stdcall;
        {Получение даиапзона частоты дискретизации для генерируемого сигнала}
   	function GetPlayDACFreqRange(var min: double;
                                     var max: double): HRESULT; stdcall;
   end;

   IDigitalInput = interface
   ['{CB4C4901-2302-11d7-9243-00E029288A7F}']
        {Получение битового слова с цифрового входа}
        function InputWord(var dwValue: DWORD): HRESULT; stdcall;
   end;



   IDigitalOutput = interface
   ['{DA1B4C61-DF78-11d6-9243-00E029288A7F}']
        {Вывод битового слова в цифрового выход}
        function OutputWord(const dwValue: DWORD): HRESULT; stdcall;
   end; 

implementation

end.
