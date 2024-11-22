unit iwaitwnd;

interface

uses Windows;

const
  CLSID_WaitingWindow : TGUID = '{2CE95502-E1F3-11d6-9243-00E029288A7F}';
  IID_IWaitingWindow  : TGUID = '{2CE95501-E1F3-11d6-9243-00E029288A7F}';

  WWO_PROGRESSBAR     = $0001;
	WWO_EXTERNALIMAGE   = $0002;
	WWO_FINALIZENODELAY = $0004;
	WWO_STARTUPMODE     = $0008;
	WWO_ABORTBUTTON			= $0010;

type
  IWaitingWindow = interface
  ['{2CE95501-E1F3-11d6-9243-00E029288A7F}']
    function Init(const a_pchTitle: LPCWSTR; a_pchMessage : LPCWSTR;
                  a_dwPictureID : DWORD; a_dwOptions : DWORD = 0; a_hParent : HWND = 0) : HRESULT; stdcall;
    function Show : HRESULT; stdcall;
    function Hide : HRESULT; stdcall;
    function SetMessageText(const a_pchMessage : LPCWSTR) : HRESULT; stdcall;
    function SetProgressPos(const a_nPos : Integer) : HRESULT; stdcall;
    function FinalizeProgress : HRESULT; stdcall;
    function SetAdditionalText(const a_pchMessage: LPCWSTR; a_nIndex : Integer) : HRESULT; stdcall;
    // Возвращает S_OK или S_FALSE
    function Aborted : HRESULT; stdcall;

    // Размер шрифта текстового сообщения
    function SetMessageTextFontSize(const a_nPoints : Integer) : HRESULT; stdcall;
  end;

  PIWaitingWindow = ^IWaitingWindow;

implementation

end.
