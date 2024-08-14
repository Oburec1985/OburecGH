library Project1;

uses
  SysUtils,
  Classes,
  Consts,
  Windows,
  Registry,
  ComServ;

exports
  dllgetclassobject Name 'DllGetClassObject',
 dllcanunloadnow Name 'DllCanUnloadNow',
 dllregisterserver name 'DllRegisterServer',
 dllunregisterserver Name 'DllUnregisterServer';

{$R *.TLB}

{$R *.RES}

function DllRegisterServer: hresult; stdcall;
var reg: tregistry;
buffer: array[0..255] of char;
begin
 reg := tregistry.Create;
 try
 reg.rootkey := hkey_local_machine;
 getmodulefilename(hinstance, buffer, 255);
 reg.openkey('\Software\MERA\Winpos\COMPlugins', True);
 reg.writestring(string(buffer), 'MyPlugin.MyObject');
 finally
 reg.Free;
 end;
 Result := comserv.dllregisterserver;
end;function DllUnregisterServer: hresult; stdcall;var
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
end;end;