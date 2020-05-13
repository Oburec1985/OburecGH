library Project1;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  consts,
  windows,
  comserv,
  registry,
  Project1_TLB in 'Project1_TLB.pas',
  Unit1 in 'Unit1.pas' {TSampleWPPlugIn: CoClass},
  Unit2 in 'Unit2.pas' {Form1},
  Winpos_ole_TLB in 'Winpos_ole_TLB.pas';

{$R *.TLB}

{$R *.res}

{$R toolbar.res}

function dllregisterserver: hresult; stdcall;
var  
  reg: tregistry;
var
  buffer: array[0..255] of char;
begin 
  reg := tregistry.Create;
  try
    reg.rootkey := hkey_local_machine;
    getmodulefilename(hinstance, buffer, 255);
    reg.openkey('\Software\MERA\Winpos\COMPlugins', True);
    reg.writestring(string(buffer),
      'Project1.TSampleWPPlugIn');
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
      reg.DeleteValue(string(buffer));
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

