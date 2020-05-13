unit sdbview;
interface
uses Windows;

const
  CLSID_MeSDBViewer     : TGUID = '{360092C6-9A3B-49C6-9319-31EC36B708A1}';
  CLSID_MeSdbRootNode   : TGUID = '{D7D5627B-72C0-4780-A8D8-7BE4A01D90AA}';
  CLSID_MeSdbFolderNode : TGUID = '{5657C6BB-3A7A-400D-8595-1C408A228C4E}';
  CLSID_MeSdbScaleNode  : TGUID = '{304E4017-707C-48CB-9014-5031C338FD3C}';
  CLSID_MeSdbFolderPP   : TGUID = '{E563A718-73ED-4DF1-ACE8-3015FB9A20B0}';
  CLSID_MeSdbRootPP     : TGUID = '{82FCAB67-BAEE-4F73-8453-57C9291750CC}';

type
    MESDBVIEWERSTYLE = (
      MESV_NOBUTTONS  	= 0,
      MESV_CLOSEBUTTON	= $1,
      MESV_SELECTCANCEL	= $2,
      MESV_BUTTONBITS  	= $f,
      MESV_SEL_SCALE  	= $10,
      MESV_SEL_SENSOR   = $20,
      MESV_SEL_FOLDER   = $40,
      MESV_SEL_ROOT     = $80
      );

   IMeSDBViewer = interface
   ['{D95F4D06-8DAA-42F5-900E-F8F067A4BF58}']
      function Execute(hWnd : HWND; szFile : LPCWSTR; dwStyle : DWORD; const bReadOnly : BOOL) : HRESULT; stdcall;
      function GetSelected(var pszKey : LPWSTR) : HRESULT; stdcall;
      function SetSelected(szKey : LPCWSTR) : HRESULT; stdcall;
   end;

   IMeSdbRootNode = interface
   ['{D7D23F08-920E-4EF1-A7DF-253600FA02E5}']
      function get_Selected(var pVal: LPCWSTR) : HRESULT; stdcall;
      function put_Selected(newVal : LPCWSTR) : HRESULT; stdcall;
      function get_Dsc(var pVal : LPCWSTR) : HRESULT; stdcall;
      function put_Dsc(newVal : LPCWSTR) : HRESULT; stdcall;
      function get_Path(var pVal : LPCWSTR) : HRESULT; stdcall;
      function get_PathFile(var pVal : LPCWSTR) : HRESULT; stdcall;
   end;

   IMeSdbFolderNode = interface
   ['{5515DF01-E405-4E2C-B51E-BB652BC9BAC9}']
      function get_Name(var pVal : LPCWSTR) : HRESULT; stdcall;
      function put_Name(newVal : LPCWSTR) : HRESULT; stdcall;
      function get_Dsc(var pVal : LPCWSTR) : HRESULT; stdcall;
      function put_Dsc(newVal : LPCWSTR) : HRESULT; stdcall;
      function get_Objects(var pVal : VARIANT) : HRESULT; stdcall;
   end;

   IMeSdbScaleNode = interface
   ['{5FE695B4-9154-431D-A0F0-696469E80278}']
      function get_Name(var pVal : LPCWSTR) : HRESULT; stdcall;
      function put_Name(newVal : LPCWSTR) : HRESULT; stdcall;
      function get_Path(var pVal : LPCWSTR) : HRESULT; stdcall;
      function get_PathFile(var pVal : LPCWSTR) : HRESULT; stdcall;
      function GetScaleObject(var pScale : IUnknown) : HRESULT; stdcall;
   end;


implementation
end.