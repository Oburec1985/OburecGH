library WpServicePlg;



uses
  ComServ,
  SysUtils,
  Classes,
  dialogs,
  consts,
  windows,
  registry,
  WPServicePack_TLB in 'WPServicePack_TLB.pas',
  uWpServicePlg in 'units\uWpServicePlg.pas' {ExtPack: CoClass},
  POSBase in 'units\POSBase.pas',
  Winpos_ole_TLB in 'Winpos_ole_TLB.pas',
  uGlobalStrings in '..\..\sharedUtils\utils\uGlobalStrings.pas',
  uVTServices in '..\..\sharedUtils\utils\uVTServices.pas',
  UWPEvents in 'units\UWPEvents.pas',
  uCommonMath in '..\..\sharedUtils\math\uCommonMath.pas',
  u2DMath in '..\..\sharedUtils\math\u2DMath.pas',
  VBScript_RegExp_55_TLB in '..\..\sharedUtils\utils\scripts\VBScript_RegExp_55_TLB.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uExcel in '..\..\sharedUtils\utils\reports\excel\uExcel.pas',
  uWord in '..\..\sharedUtils\utils\reports\msWord\uWord.pas',
  MSScriptControl_TLB in '..\..\sharedUtils\utils\scripts\MSScriptControl_TLB.pas',
  UDirChangeNotifier in '..\..\sharedUtils\utils\PathUtils\UDirChangeNotifier.pas',
  uEventTypes in '..\..\sharedUtils\utils\lists\uEventTypes.pas',
  usetlist in '..\..\sharedUtils\utils\lists\usetlist.pas',
  uPointsList in '..\..\sharedUtils\utils\lists\uPointsList.pas',
  PathUtils in '..\..\sharedUtils\utils\PathUtils\PathUtils.pas',
  uPathMng in '..\..\sharedUtils\utils\uPathMng.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uBinFile in '..\..\sharedUtils\uBinFile.pas',
  uWPservices in '..\SharedWP\uWPservices.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

// ������� ����� ������������� ���������� sharedUnits/utils/ResourceEdit
{$R *.TLB}
{$R *.res}
{$R toolbarExtPack.res}
//{$R WPExtPack.res}


function  DllRegisterServer: hresult; stdcall;
var
  reg:tregistry;
var
  buffer:array[0..255] of char;
begin
  reg :=tregistry.Create;
  try
    reg.rootkey := hkey_local_machine;
    getmodulefilename(hinstance, buffer, 255);
    reg.openkey('\Software\MERA\Winpos\COMPlugins', True);
    reg.writestring(string(buffer),'WPServicePack.WPServicePlg');
    //showmessage(string(buffer));
    // ������ �� ����� ������� � ����� connect �������� ������ .Connect(
    // reg.writestring(string(buffer),'WPExtPack.IEMeraPlg');
    // showmessage(string(buffer));
  finally
    reg.Free;
  end;
  Result := comserv.dllregisterserver;
end;


function dllunregisterserver: hresult; stdcall;
var
  reg: tregistry;
var
  buffer: array[0..255] of char;
begin
  reg := tregistry.Create;
  try
    reg.rootkey := hkey_local_machine;
    getmodulefilename(hinstance, buffer, 255);
    if (reg.openkey('\Software\MERA\Winpos\COMPlugins', False)) then
    begin
      //showmessage('unreg: '+string(buffer));
      reg.DeleteValue(string(buffer));
    end;
  finally
    reg.Free;
   end;
  Result := comserv.dllunregisterserver;
end;


exports dllgetclassobject Name 'DllGetClassObject',
  dllcanunloadnow Name 'DllCanUnloadNow',
  dllregisterserver name 'DllRegisterServer',
  dllunregisterserver Name 'DllUnregisterServer';
begin

end.
