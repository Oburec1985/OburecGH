library plgGORN;

uses
  Windows,
  Themes,
  SysUtils,
  Classes,
  PluginClass in '..\SharedRUnits\PluginClass.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uCompMng in '..\SharedRUnits\uCompMng.pas',
  uRecBasicFactory in '..\SharedRUnits\uRecBasicFactory.pas',
  uMainFrm in 'forms\uMainFrm.pas' { MainFrm },
  uRecorderEvents in '..\SharedRUnits\uRecorderEvents.pas',
  uFrmSync in '..\SharedRUnits\uFrmSync.pas' { FrmSync },
  uCreateComponents in 'units\uCreateComponents.pas',
  uCreateNotifyProcess in 'units\uCreateNotifyProcess.pas',
  DevAPI in '..\SharedRUnits\interfaces\DevAPI.pas',
  device in '..\SharedRUnits\interfaces\device.pas',
  journal in '..\SharedRUnits\interfaces\journal.pas',
  modules in '..\SharedRUnits\interfaces\modules.pas',
  plugin in '..\SharedRUnits\interfaces\plugin.pas',
  rcPlugin in '..\SharedRUnits\interfaces\rcPlugin.pas',
  recorder in '..\SharedRUnits\interfaces\recorder.pas',
  signal in '..\SharedRUnits\interfaces\signal.pas',
  tags in '..\SharedRUnits\interfaces\tags.pas',
  scales in '..\SharedRUnits\interfaces\scales.pas',
  uAlarms in '..\SharedRUnits\interfaces\uAlarms.pas',
  uRCFunc in '..\SharedRUnits\uRCFunc.pas',
  uMyErrorMessages in '..\SharedRUnits\Sergey\uMyErrorMessages.pas',
  uMyRecorderUtils in '..\SharedRUnits\Sergey\uMyRecorderUtils.pas',
  uSettingsFrm in 'forms\uSettingsFrm.pas' {SettingsFrm},
  uSelectChannelFrm in '..\SharedRUnits\Sergey\uSelectChannelFrm.pas' {SelectChannelFrm},
  upidreg in 'units\upidreg.pas',
  TimerThread in 'units\TimerThread.pas',
  PerformanceTime in '..\..\sharedUtils\utils\PerformanceTime.pas';

{$R toolbarExtPack.res}
{$R *.res}

{ -----------------------------------------------��������� - ����� ����� � dll }
{ ���������� ��� �������� � �������� dll }
procedure DllEntryPoint(Reason: integer);
begin
  case Reason of { ��������� �� ���� ������� ������ }
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


// ----------------------------�������������� �������}
// {���� ������� � ����������� ���� �������, ������� ������ ��������������}
// ���������� plug-in`� ��� Recorder`�}

// ��������� ���� �������, �������������� � ���������}
function GetPluginType: integer; cdecl;
begin
  Result := PLUGIN_CLASS; { � ������ ������, ��� ��� ������� plug-in`� }
end;

// ������� �������� ���������� plug-in`�.
// ������� ��������� ����� �������, ��� ����� ��� ���������� �� ���������,
// � ���������. ������� ������ ���������� ���������� � ��������� ��������.
function CreatePluginClass: pointer { IRecorderPlugin } ; cdecl;
begin
  GPluginInstance := TExtRecorderPack.Create;
  // �������� ������ ����������� ���������� plug-in`�}
  Result := pointer(GPluginInstance);
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // ��� �������� ������� ��� �������� DELPHI �� �������� ���������� ������!!!!!
  GPluginInstance._AddRef;
end;

{ ������� �������� plug-in`�. }
function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  // ��� ��� ������ ���� � ����������, �� �� ����� �� ���������.
  // ������ plug-in`� ������� ���� ��� (��� ����� COM ������),
  // ���� ������� ������ ��� ����������� ������ ����� ����.
  Result := RCERROR_NOERROR;
  TExtRecorderPack(GPluginInstance).destroyForms;
  GPluginInstance._release;
  GPluginInstance := NIL;
end;

{ ������� ��������� ������ �������� plug-in`� }
function GetPluginDescription: LPCSTR; cdecl;
begin
  // �������� ����������� �� ���������� ������������ ���������}
  Result := LPCSTR(GPluginInfo.Dsc);
  // Result := LPCSTR('������ ��� ����� (������)');
end;

{ ������� ��������� ������� �������� plug-in`� }
procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
begin
  // �������� ����������� �� ���������� ������������ ���������
  // ����������� ����� ������������ ������ ��������� StrCopy()
  // ��-�� ����, ��� ��������� �������� plug-in`� �������
  // � ����� C++}
  StrCopy(@lpPluginInfo.name, LPCSTR(GPluginInfo.Name));
  StrCopy(@lpPluginInfo.describe, LPCSTR(GPluginInfo.Dsc));
  StrCopy(@lpPluginInfo.vendor, LPCSTR(GPluginInfo.vendor));
  lpPluginInfo.version := GPluginInfo.version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

{ ---------------------���������� �������������� ��������---------------------- }
{ ���������� ��������� ���� �������������� ������� }
exports GetPluginType name 'GetPluginType';

exports CreatePluginClass name 'CreatePluginClass';

exports DestroyPluginClass name 'DestroyPluginClass';

exports GetPluginDescription name 'GetPluginDescription';

exports GetPluginInfo name 'GetPluginInfo';

begin
  // ����������� ����� ������� DllEntryPoint, ����� �������
  // ����� ������� DllEntryPoint ���������� �����������
  // ������������ ��������� � �������� ����������
  if not Assigned(DLLProc) then
    DLLProc := @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);

end.
