unit iuisrv;

interface

uses Windows, tags, plugin;

const
    IID_IUIServer   : TGUID = '{12920205-4119-4a7f-8709-136594FD9528}';
    CLSID_IUIServer : TGUID = '{EAD4F9B6-C015-4d28-9579-481D784BC1DA}';

    UISH_SHOW = 0;
	  UISH_HIDE = 1;

    // событи€
    UISN_ENABLESETUP       =  0;
    UISN_UPDATETITLE       =  1;
    UISN_UPDATESTATUSBAR   =  2;
    UISN_UPDATECURRTAGINFO =  3;
    UISN_ENABLE            =  4;
    UISN_RCSAVECONFIG      =  5;
    UISN_RCLOADCONFIG      =  6;
    UISN_ENTERRCCONFIG     =  7;
    UISN_LEAVERCCONFIG     =  8;
    UISN_BROADCAST         =  9;
    UISN_UPDATE_DATA       = 10;
    UISN_RCSTART           = 11;
    UISN_RCSTOP            = 12;
    UISN_RCPLAY            = 13;
    UISN_UPDATE_FORMS      = 14;
    UISN_BEFORE_RCSTART    = 15;
    UISN_BEFORE_RCSTOP     = 16;

    UISN_INTERNAL             = $8000;
    UISN_REFLECT_PRETRANSLATE = $8001;
    UISN_RESET_CONFIG         = $8002;
    UISN_ON_LINK_TO_RC_CORE   = $8003;

    // свойства
    UISP_RECORDERLINK     = 0;
    UISP_TAGS_FILTER      = 1;
    UISP_MNEMOFORMS_FLAGS = 2;

    //  оды типов окон диалогов настройки
    // дл€ функции OpenSettingsDialog
    OSDC_MAIN      = 0;
    OSDC_TAG       = 1;
    OSDC_VFORMS    = 2;
    OSDC_MULTITARE = 3;

type

   IUIServer = interface
   ['{12920205-4119-4a7f-8709-136594FD9528}']
      function Init(const a_ulParam : ULONG) : HRESULT; stdcall;
      function Close : HRESULT; stdcall;
      function Show(const a_ulFlags : ULONG) : HRESULT; stdcall;
      function Notify(const a_ulCommand : ULONG; const a_ulParam : ULONG; const a_nIndex : Integer = -1) : HRESULT; stdcall;
      function GetWindowDescriptor : ULONG; stdcall;

      // ”становить свойство UI сервера
	    function SetProperty(const a_dwPropertyID : DWORD; a_Value : OleVariant;
                           a_lSubPropertyIndex : Integer; a_dwReserved : DWORD = 0) : HRESULT; stdcall;

	    // ѕолучить свойство UI сервера
	    function GetProperty(const a_dwPropertyID : DWORD;  var a_Value: OleVariant;
                           const a_lSubPropertyIndex : Integer = 0; a_dwReserved : DWORD = 0) : HRESULT; stdcall;

	    function GetSelectedTagsCount : ULONG; stdcall;
	    function GetSelectedTag(const a_nIndex : Integer) : ITag; stdcall;

      // ќткрыть окно редактировани€ настроек
      function OpenSettingsDialog(
          const unDialogCode : ULONG;      // a_unDialogCode - код диалога OSDC_XXX
          const unPageIndex : ULONG;       // a_unPageIndex - номер страницы свойств
          const unFlags : ULONG;           // a_unFlags - дополнительные флаги reserved, must be 0
          var pvboolRetCode : VARIANT_BOOL // a_pvboolRetCode - адрес переменной дл€ возврата кода закрыти
        ) : HRESULT; stdcall;

      // ѕослать плагину сообщение PN_ON_SWITCH_TO_UI_THREAD в контексте своего треда
      // since v2.7.0.17
      function PostSwitchThreadNotification(pPlugin : IRecorderPlugin) : HRESULT; stdcall;

      // ѕолучить глобальный номер выбранного канала по индексу
      // since v2.7.3
      function GetSelectedTagIndex(nIndex : Integer): ULONG; stdcall;
   end;

implementation

end.
