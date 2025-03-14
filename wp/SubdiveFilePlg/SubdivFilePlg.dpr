library SubdivFilePlg;

uses
  ComServ,
  SysUtils,
  Classes,
  dialogs,
  consts,
  windows,
  registry,
  SubdivFilePlg_TLB in 'SubdivFilePlg_TLB.pas',
  uSubdivePlg in 'uSubdivePlg.pas' {SubdivePlgClass: CoClass},
  POSBase in '..\SharedWP\POSBase.pas',
  Winpos_ole_TLB in '..\SharedWP\Winpos_ole_TLB.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}
{$R *.RES}
{$R SubdivFilePlg.res}

// ������� �������� ��������
// 1) ������� ���� .ridl � IDE. � ������ �������� �������� CoClass
// 2) �� ������� implements �������� ��������� IWPExtOper
// 3) ������� ������� ���� � ���������� ������� � ����������� ���� ����� ������� �� ������� (������ ���������� ��� safecall)
// 4) �������� ������ initialization ��� � ���� �����
// 5) ��������� � DllRegisterServer reg.writestring(string(buffer), 'SubdivFilePlg.SubdivePlgClass');
// ��� SubdivFilePlg - ���������� ����� (���� ridll)  IEMeraPlg - ��� CoClass �� ����������

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
    reg.writestring(string(buffer),'SubdivFilePlg.SubdivePlgClass');
    // showmessage(string(buffer));
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
