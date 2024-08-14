library WpOperPlg;

uses
  SysUtils,
  Classes,
  Consts,
  Windows,
  Registry,
  ComServ,
  Winpos_ole_TLB in 'iface\Winpos_ole_TLB.pas',
  uOperPack in 'units\uOperPack.pas',
  POSBase in 'iface\POSBase.pas',
  WpOperPlg_TLB in 'WpOperPlg_TLB.pas',
  uIRGraphFrm in 'forms\uIRGraphFrm.pas' {IRGraphFrm},
  uWPservices in 'units\uWPservices.pas',
  UWPEvents in 'units\UWPEvents.pas',
  u2DMath in '..\..\..\oburec\OburecGH\sharedUtils\math\u2DMath.pas';

exports
  dllgetclassobject Name 'DllGetClassObject',
 dllcanunloadnow Name 'DllCanUnloadNow',
 dllregisterserver name 'DllRegisterServer',
 dllunregisterserver Name 'DllUnregisterServer';

{$R *.TLB}

{$R *.RES}
// ресурсы можно редактировать программой sharedUnits/utils/ResourceEdit
{$R *.TLB}
{$R *.res}
{$R toolbarExtPack.res}

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
    reg.writestring(string(buffer),'WpOperPlg.OperPack');
    // showmessage(string(buffer));
    // делаем не через кокласс а через connect главного класса .Connect(
    // reg.writestring(string(buffer),'WPExtPack.IEMeraPlg');
    // showmessage(string(buffer));
  finally
    reg.Free;
  end;
  Result := comserv.dllregisterserver;
end;

function DllUnregisterServer: hresult; stdcall;var
 reg: tregistry;
var
 buffer: array[0..255] of char;
begin
  reg := tregistry.Create;
  try
    reg.rootkey := hkey_local_machine;
    getmodulefilename(hinstance, buffer, 255);
    if (reg.openkey('\Software\MERA\Winpos\COMPlugins',False)) then
    reg.DeleteValue(string(buffer));
  finally
    reg.Free;
  end;
  Result := comserv.dllunregisterserver;
end;exports
  dllgetclassobject Name 'DllGetClassObject',
  dllcanunloadnow Name 'DllCanUnloadNow',
  dllregisterserver name 'DllRegisterServer',
  dllunregisterserver Name 'DllUnregisterServer';

beginend.