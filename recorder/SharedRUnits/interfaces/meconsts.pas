unit meconsts;
interface
uses Windows;

const
  CLSID_MeSDBViewer     : TGUID = '{360092C6-9A3B-49C6-9319-31EC36B708A1}';
  CLSID_MeSdbRootNode   : TGUID = '{D7D5627B-72C0-4780-A8D8-7BE4A01D90AA}';
  CLSID_MeSdbFolderNode : TGUID = '{5657C6BB-3A7A-400D-8595-1C408A228C4E}';
  CLSID_MeSdbScaleNode  : TGUID = '{304E4017-707C-48CB-9014-5031C338FD3C}';
  CLSID_MeSdbFolderPP   : TGUID = '{E563A718-73ED-4DF1-ACE8-3015FB9A20B0}';
  CLSID_MeSdbRootPP     : TGUID = '{82FCAB67-BAEE-4F73-8453-57C9291750CC}';

  // MEBASEOPENFLAGS
  MEF_CREATE     	= 0;
  MEF_OPEN	      = 1;
  MEF_OPEN_ALWAYS	= 2;
  MEF_OPEN_READ	  = 3;

  //MEBASEEXPORTFLAGS
  MEF_EXPORT_MOVE	= 0;
  MEF_EXPORT_COPY	= 1;
  MEF_EXPORT_LINK	= 21;

  //MEBASEPROCESSERRORCODES
  MEC_FILE_EXIST      = 0;
  MEC_CONFIRM_IMPORT	= 1;
  MEC_CONFIRM_CANCEL	= 2;

type

   IMeProcessNotifySink = interface
   ['{8A9CFB3A-5791-4EA7-A016-FEA0E9389A55}']
      function OnError(nCode : Integer; szInfo : LPCWSTR) : HRESULT; stdcall;
      function OnProcessing(nPercents : Integer; szInfo : LPCWSTR) : HRESULT; stdcall;
   end;

implementation
end.
