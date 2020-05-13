{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для формирования отладочного журнала     }
{ измерительного ПО.                                                  }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit journal;
interface
uses Windows, ComObj, Variants;
{$ALIGN 8}
const
   CLSID_Journal: TGUID = '{95001262-E83C-11d6-9243-00E029288A7F}';
const
   JPROP_DBFILE =       0;
   JPROP_DBWRITE =      1;
   JPROP_PARENTWINDOW = 2;
   JPROP_VISIBLE =      3;
   JPROP_SHOWTITLE =    4;
   JPROP_SIZE =         5;

const
   EVPRIOR_CRITICAL =   0;
   EVPRIOR_ALARM =      1;
   EVPRIOR_WARNING =    2;
   EVPRIOR_NORMAL =     3;

type
   BSTR = PWideChar;          
   JOURNALEVENT = record
      eventtext: BSTR;
      textcolor: longint;
      bkcolor:   longint;
      priority:  longint;
   end;
   PJOURNALEVENT = ^JOURNALEVENT;

   IJournal = interface
   ['{95001261-E83C-11d6-9243-00E029288A7F}']
      function AddEventRecord(var Event: JOURNALEVENT): HRESULT; stdcall;
      function AddEvent(Text: BSTR; const TextColor: longint; const BKColor: longint;
                        const Priority: longint): HRESULT; stdcall;
      function Reset: HRESULT; stdcall;
      function GetProperty(const dwPropID: DWORD; var varProp: OleVariant): HRESULT; stdcall;
      function SetProperty(const dwPropID: DWORD;
                          {const} varProp: OleVariant): HRESULT; stdcall;
   end;
  
implementation
end.

