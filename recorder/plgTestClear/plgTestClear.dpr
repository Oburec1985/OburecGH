library plgTestClear;

uses
  fastmm4,
  Windows,
  Themes,
  SysUtils,
  Classes,
  uExtFrm in 'forms\uExtFrm.pas' {ExtFrm},
  uLogFile in '..\..\sharedUtils\utils\uLogFile.pas',
  usetlist in '..\..\sharedUtils\utils\lists\usetlist.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uListMath in '..\..\sharedUtils\math\uListMath.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uGlFrm in 'forms\uGlFrm.pas' {GLScene},
  uGlTurbine in '..\..\3d\3dComponents\components\Asutp\uGlTurbine.pas',
  uTrfrmToolsFrame in '..\..\3d\forms\uTrfrmToolsFrame.pas' {TrfrmToolsFrame: TFrame},
  uObjCtrFrame in '..\..\3d\forms\uObjCtrFrame.pas' {CtrlViewFrame: TFrame},
  uMatrix in '..\..\sharedUtils\math\uMatrix.pas',
  uGLFrmEdit in 'forms\uGLFrmEdit.pas' {glFrmEdit},
  PluginClass in '..\SharedRUnits\PluginClass.pas',
  uCompMng in '..\SharedRUnits\uCompMng.pas',
  uFrmSync in '..\..\sharedUtils\forms\uFrmSync.pas' {FrmSync},
  uRecBasicFactory in '..\SharedRUnits\uRecBasicFactory.pas',
  uRecorderEvents in '..\SharedRUnits\uRecorderEvents.pas',
  uCreateComponents in 'units\uCreateComponents.pas',
  blaccess in '..\SharedRUnits\interfaces\blaccess.pas',
  CFREG in '..\SharedRUnits\interfaces\CFREG.PAS',
  DevAPI in '..\SharedRUnits\interfaces\DevAPI.pas',
  device in '..\SharedRUnits\interfaces\device.pas',
  journal in '..\SharedRUnits\interfaces\journal.pas',
  modules in '..\SharedRUnits\interfaces\modules.pas',
  plugin in '..\SharedRUnits\interfaces\plugin.pas',
  rcPlugin in '..\SharedRUnits\interfaces\rcPlugin.pas',
  recorder in '..\SharedRUnits\interfaces\recorder.pas',
  signal in '..\SharedRUnits\interfaces\signal.pas',
  tags in '..\SharedRUnits\interfaces\tags.pas',
  transf in '..\SharedRUnits\interfaces\transf.pas',
  transformers in '..\SharedRUnits\interfaces\transformers.pas',
  waitwnd in '..\SharedRUnits\interfaces\waitwnd.pas',
  uRecFactory in 'units\uRecFactory.pas',
  uSyncThread in '..\..\wp\WPExtPack\units\uSyncThread.pas';

//rcPlugin in 'interfaces\rcPlugin.pas';

{$R toolbarExtPack.res}

{-----------------------------------------------��������� - ����� ����� � dll}
{���������� ��� �������� � �������� dll}
procedure DllEntryPoint(Reason: integer);
begin
  case Reason of{��������� �� ���� ������� ������}
    DLL_PROCESS_ATTACH:
    begin

    end;
    DLL_PROCESS_DETACH:
    begin
      // �������� �������� ���������� ������� ���������� ������ ����
      ThemeServices.Free;
    end;
    DLL_THREAD_ATTACH:
    begin

    end;
    DLL_THREAD_DETACH:
    begin

    end;
  end;
end;


//----------------------------�������������� �������}
//{���� ������� � ����������� ���� �������, ������� ������ ��������������}
//���������� plug-in`� ��� Recorder`�}

//��������� ���� �������, �������������� � ���������}
function GetPluginType: integer; cdecl;
begin
  Result:= PLUGIN_CLASS; {� ������ ������, ��� ��� ������� plug-in`�}
end;
//������� �������� ���������� plug-in`�.
//������� ��������� ����� �������, ��� ����� ��� ���������� �� ���������,
//� ���������. ������� ������ ���������� ���������� � ��������� ��������.
function CreatePluginClass: pointer{IRecorderPlugin}; cdecl;
begin
  GPluginInstance := TExtRecorderPack.Create;
  //�������� ������ ����������� ���������� plug-in`�}
  result := pointer(GPluginInstance);
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // ��� �������� ������� ��� �������� DELPHI �� �������� ���������� ������!!!!!
  GPluginInstance._AddRef;
end;

{������� �������� plug-in`�.}
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  //��� ��� ������ ���� � ����������, �� �� ����� �� ���������.
  //������ plug-in`� ������� ���� ��� (��� ����� COM ������),
  //���� ������� ������ ��� ����������� ������ ����� ����.
  Result := RCERROR_NOERROR;
  TExtRecorderPack(piPlg).destroyForms;
  GPluginInstance:=NIL;
  piPlg._release;
end;
{������� ��������� ������ �������� plug-in`�}
function GetPluginDescription: LPCSTR; cdecl;
begin
   //�������� ����������� �� ���������� ������������ ���������}
   //Result := LPCSTR(GPluginInfo.Dsc);
   Result := LPCSTR('������ ��� ����� (������)');
end;
{������� ��������� ������� �������� plug-in`�}
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
begin
  //�������� ����������� �� ���������� ������������ ���������
  //����������� ����� ������������ ������ ��������� StrCopy()
  // ��-�� ����, ��� ��������� �������� plug-in`� �������
  // � ����� C++}
  StrCopy( @lpPluginInfo.name,LPCSTR(GPluginInfo.Name));
  StrCopy( @lpPluginInfo.describe,LPCSTR(GPluginInfo.Dsc));
  StrCopy( @lpPluginInfo.vendor,LPCSTR(GPluginInfo.Vendor));
  lpPluginInfo.version := GPluginInfo.Version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{---------------------���������� �������������� ��������----------------------}
{���������� ��������� ���� �������������� �������}
exports GetPluginType        name 'GetPluginType';
exports CreatePluginClass    name 'CreatePluginClass';
exports DestroyPluginClass   name 'DestroyPluginClass';
exports GetPluginDescription name 'GetPluginDescription';
exports GetPluginInfo        name 'GetPluginInfo';

begin
 //����������� ����� ������� DllEntryPoint, ����� �������
 //����� ������� DllEntryPoint ���������� �����������
 //������������ ��������� � �������� ����������
  if not Assigned(DLLProc) then
    DLLProc:= @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);

end.
