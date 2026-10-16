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
   //Свойства модуля
   MDPROP_SLOT =          0; // слот
   MDPROP_TYPE =          1; // тип
   MDPROP_SERIALNUMBER =  2; // серийный номер
   MDPROP_VERSIONMAJOR =  3; // старший номер версии
   MDPROP_VERSIONMINOR =  4; // младший номер версии

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
   end;

implementation

end.
