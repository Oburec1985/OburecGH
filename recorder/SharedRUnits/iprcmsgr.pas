unit iprcmsgr;
(*
  TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_UISERVERLINK, a_varValue);

  punk := a_varValue; // получение из интерфейса IUnknown необходимого IPropertyAccess
  punk.QueryInterface(IUIServer, m_pUIServerLink);

  m_pUIServerLink.QueryInterface(IProgressMessager, pPM));

  pPM.wm_Show('Балансировка',
              'Производится балансировка нуля'#13#10'Пожалуйста подождите ...', 0, PMO_PROGRESSBAR, Handle);

  pPM.wm_SetProgressPos(50);
  pPM.wm_Hide;
*)

interface

uses Windows;

const
    IID_IProgressMessager : TGUID = '{76154E58-87AA-480d-BED0-C09F40FD31F6}';

    PMO_PROGRESSBAR     = $0001;
    PMO_EXTERNALIMAGE   = $0002;
    PMO_FINALIZENODELAY = $0004;
    PMO_STARTUPMODE     = $0008;

    PICID_DEFAULT       = 1000; // часы
    PICID_SOFTSETUP     = PICID_DEFAULT;
    PICID_ATOM          = 1001; // шестеренки, так же = 0
    PICID_HARDWARE      = 1002; // плата
    PICID_HARDWAREFAILD = 1003; // шестеренки
    PICID_PHYSIC        = 1004; // шестеренки
    PICID_ZBALANCE      = 1005; // шестеренки
    PICID_FLOPPY        = 1006; // дискета

type
    IProgressMessager = interface
    ['{76154E58-87AA-480d-BED0-C09F40FD31F6}']
        function wm_Show(const a_pchTitle: LPCSTR; a_pchMessage: LPCSTR;
                         a_dwPictureID: DWORD; a_dwOptions: DWORD = 0; hTopWnd: HWND = 0) : HRESULT; stdcall;
        function wm_Hide : HRESULT; stdcall;
        function wm_SetMessageText(const a_pchMessage: LPCSTR) : HRESULT; stdcall;
        function wm_SetProgressPos(a_nPos: Integer) : HRESULT; stdcall;
        function wm_FinalizeProgress : HRESULT; stdcall;
        function wm_GetCancelState(var a_pfCanceled: VARIANT_BOOL) : HRESULT; stdcall;
        function wm_SetMessageTextFontSize(a_nPoint: Integer) : HRESULT; stdcall;
    end;

implementation

end.
