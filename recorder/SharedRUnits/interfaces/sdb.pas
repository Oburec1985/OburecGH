unit sdb;
interface
uses Windows;

const
  CLSID_MeSDBBase           : TGUID = '{4AA4D4E0-350F-46B6-BBF5-2695C486A17D}';
  CLSID_MeSDBFolder         : TGUID = '{29A6151D-7D65-41D9-8525-61D7CB734384}';
  CLSID_MeSDBScale          : TGUID = '{0CB74E39-C544-491D-8160-6810BC242409}';

  IID_IMeSDBBase      : TGUID = '{0F753623-34E3-4A5C-8DEB-F0D0D06132F3}';
  IID_IMeSDBObjectMgr : TGUID = '{C7313BB3-72EE-4A9C-AD1C-2FEA1843188B}';
  IID_IMeSDBFolder    : TGUID = '{010D8538-F86A-4464-B934-5F681B6764DC}';
  IID_IMeSDBScale     : TGUID = '{73C6546C-E8C4-435C-8E48-436850A929F2}';
  LIBID_SDBLib        : TGUID = '{32E8C1F6-7D64-4963-85B0-E2C9D6735D83}';

  IID_IEnumUnknown    : TGUID = '{00000100-0000-0000-C000-000000000046}';

  DEFAULT_SDB_PATH = PWideChar(nil);

  //MESDB_DBITEMSTATES
  MESDB_DBIST_NORMAL = 0;
  MESDB_DBIST_LINK   = 1;
  MESDB_DBIST_FIXED	 = 2;

type
  PIMeSDBScale = ^IMeSDBScale;

   IMeProcessNotifySink = interface
   ['{8A9CFB3A-5791-4EA7-A016-FEA0E9389A55}']
      procedure OnError(nCode : Integer; szInfo : LPCWSTR); stdcall;
      procedure OnProcessing(nPercents : Integer; szInfo : LPCWSTR); stdcall;
   end;

   IMeSDBBase = interface
   ['{0F753623-34E3-4A5C-8DEB-F0D0D06132F3}']
      function Open(szPathFile : LPCWSTR; dwFlags : DWORD) : HRESULT; stdcall;
      function Close : HRESULT; stdcall;
      function Flush : HRESULT; stdcall;
      function GetPath(var pszPath : LPWSTR) : HRESULT; stdcall;
      function GetFileName(var pszPathFile : LPWSTR) : HRESULT; stdcall;
      function GetName(var pszName : LPWSTR) : HRESULT; stdcall;
      function SetName(const szName : LPCWSTR) : HRESULT; stdcall;
      function GetDsc(var pszDsc : LPWSTR) : HRESULT; stdcall;
      function SetDsc(const szDsc : LPCWSTR) : HRESULT; stdcall;
      function GetCreationTime(var pftDateTime : FILETIME) : HRESULT; stdcall;
      function Import(const szPath : LPCWSTR; pNotify : IMeProcessNotifySink) : HRESULT; stdcall;
      function Refresh : HRESULT; stdcall;
   end;

   IMeSDBScale = interface
   ['{73C6546C-E8C4-435C-8E48-436850A929F2}']
      function GetPath(var pszPath : LPWSTR) : HRESULT; stdcall;
      function GetFileName(var pszPathFile : LPWSTR) : HRESULT; stdcall;
      function Open(szPathFile : LPCWSTR; dwFlags : DWORD) : HRESULT; stdcall;
      function Close() : HRESULT; stdcall;
      function Flush() : HRESULT; stdcall;
      function GetName(var pszName : LPWSTR) : HRESULT; stdcall;
      function SetName(szName : LPCWSTR) : HRESULT; stdcall;
      function GetScaleObject(out pScale) : HRESULT; stdcall;
      function SetScaleObject(pScale : IUnknown) : HRESULT; stdcall;
   end;

   IMeSDBFolder = interface
   ['{010D8538-F86A-4464-B934-5F681B6764DC}']
      function GetPath(var pszPath : LPWSTR) : HRESULT; stdcall;
      function GetFileName(var pszPathFile : LPWSTR) : HRESULT; stdcall;
      function Open(szPathFile : LPCWSTR; dwFlags : DWORD) : HRESULT; stdcall;
      function Close : HRESULT; stdcall;
      function GetName(var pszName : LPWSTR) : HRESULT; stdcall;
      function SetName(szName : LPCWSTR) : HRESULT; stdcall;
      function GetDsc(var pszDsc : LPWSTR) : HRESULT; stdcall;
      function SetDsc(szDsc : LPCWSTR) : HRESULT; stdcall;
      function Export(var szDstPath : LPCWSTR; dwFlags : DWORD; szDsc : LPCWSTR; szLinkDsc : LPCWSTR; pNotify : IMeProcessNotifySink) : HRESULT; stdcall;
   end;

   IMeSDBObjectMgr = interface
   ['{C7313BB3-72EE-4A9C-AD1C-2FEA1843188B}']
     function CreateEnumerator(const riid : TGUID; out ppUnk) : HRESULT; stdcall;
     function AddObject(const szName : LPCWSTR; szDsc : LPCWSTR; bFolder : BOOL; const riid : TGUID; out ppUnk) : HRESULT; stdcall;
     function AddScale(pScale : IUnknown; var ppUnk : IUnknown) : HRESULT; stdcall;
     function RemoveObject(szName : LPCWSTR) : HRESULT; stdcall;
     function GetObjectByName(const szName : LPCWSTR; const riid : TGUID; out ppUnk) : HRESULT; stdcall;
   end;

implementation
end.