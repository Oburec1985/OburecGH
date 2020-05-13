{---------------------------------------------------------------------}
{ Проект (Модуль) реализации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для управления окном сообщений ожидания  }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit waitwnd;
interface
uses Windows;
const
   PICID_DEFAULT =                 1000;
   PICID_SOFTSETUP=PICID_DEFAULT = 1001;
   PICID_ATOM =                    1002;
   PICID_HARDWARE =                1003;
   PICID_HARDWAREFAILD =           1004;
   PICID_PHYSIC =                  1005;
   PICID_ZBALANCE =                1006;

   WWO_PROGRESSBAR     = 1;
   WWO_EXTERNALIMAGE   = 2;
   WWO_FINALIZENODELAY = 4;

   CLSID_WaitingWindow: TGUID  = '{2CE95502-E1F3-11d6-9243-00E029288A7F}';
type

   IWaitingWindow = interface
   ['{2CE95502-E1F3-11d6-9243-00E029288A7F}']
      function Init(const pchTitle: LPCSTR; const pchMessage: LPCSTR;
                    const dwPictureID: DWORD; const dwOptions: DWORD;
                    const hParent: HWND): HRESULT; stdcall;
      function Show: HRESULT; stdcall;
      function Hide: HRESULT; stdcall;
      function SetMessageText(const pchMessage: LPCSTR): HRESULT; stdcall;
      function SetProgressPos(const nPos: integer ): HRESULT; stdcall;
      function FinalizeProgress: HRESULT; stdcall;
   end;

implementation
end.


