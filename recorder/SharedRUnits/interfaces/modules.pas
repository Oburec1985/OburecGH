{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для управления аппаратным измерительным  }
{ устройством                                                         }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}
unit modules;
interface
uses Windows;
const
   IID_IModule : TGUID = '{EBD857C1-DF75-11d6-9243-00E029288A7F}';

   //Свойства модуля
   MDPROP_SLOT           =  0; // слот
   MDPROP_TYPE           =  1; // тип
   MDPROP_SERIALNUMBER   =  2; // серийный номер
   MDPROP_VERSIONMAJOR   =  3; // старший номер версии
   MDPROP_VERSIONMINOR   =  4; // младший номер версии
   MDPROP_NAME           =  5; // название
   MDPROP_INFO           =  6; // дополнительная информация
   MDPROP_INITIALIZED    =  7; // Состояние модуля "проинициализирован"
   MDPROP_MAX_CHAN_COUNT =  8; // Максимално возможное число каналов модуля
   MDPROP_HOST_DEVICE    =  9; // Хост девайс [out] VT_UNKNOWN
   MDPROP_LINK_DEVICE    = 10;

type
   IModule = interface
   ['{EBD857C1-DF75-11d6-9243-00E029288A7F}']
      {получить код идентификатор типа модуля}
      function GetType: WORD; stdcall;
      {Получить значение свойства по идентификатору}
      function _GetProperty(const dwPropertyID: DWORD;
                            var Value: OleVariant): HRESULT; stdcall;
      {Установить значение свойства по идентификатору}
      function _SetProperty(const dwPropertyID: DWORD;
                            {const} Value: OleVariant): HRESULT; stdcall;
      function _Reset: ULONG; stdcall;
	    function iCallCommand(const a_nCommand: Integer; const a_nSizeIn: Integer;
                            var pBufIn: PChar; const a_nSizeOut: Integer; var pBufOut: PChar): HRESULT; stdcall;
      //virtual HRESULT STDMETHODCALLTYPE iCallCommand(int a_nCommand, int a_nSizeIn, byte* pBufIn, int a_nSizeOut, byte* pBufOut)= 0;
   end;

implementation

end.
