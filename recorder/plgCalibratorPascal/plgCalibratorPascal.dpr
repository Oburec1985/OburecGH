library plgCalibratorPascal;

uses
  Windows,
  Themes,
  SysUtils,
  Classes,
  uLogFile in '..\..\sharedUtils\utils\uLogFile.pas',
  uComponentServises in '..\..\sharedUtils\utils\uComponentServises.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  uCalibratorPluginClass in 'units\uCalibratorPluginClass.pas',
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
  uFrmSettings in 'forms\uFrmSettings.pas' {FrmSettings},
  uCalibratorThread in 'units\uCalibratorThread.pas',
  uFrmSync in '..\SharedRUnits\uFrmSync.pas' {FrmSync};

{$R toolbarExtPack.res}

procedure DllEntryPoint(Reason: integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
    begin
    end;
    DLL_PROCESS_DETACH:
    begin
      ThemeServices.Free;
    end;
  end;
end;

function GetPluginType: integer; cdecl;
begin
  Result:= PLUGIN_CLASS;
end;

function CreatePluginClass: pointer; cdecl;
begin
  GPluginInstance := TCalPascalPlg.Create;
  result := pointer(GPluginInstance);
  GPluginInstance._AddRef;
end;

function DestroyPluginClass(piPlg: IRecorderPlugin): integer; cdecl;
begin
  Result := RCERROR_NOERROR;
  TCalPascalPlg(piPlg).destroyForms;
  GPluginInstance:=NIL;
  piPlg._release;
end;

function GetPluginDescription: LPCSTR; cdecl;
begin
   Result := LPCSTR(GPluginInfo.Dsc);
end;

procedure GetPluginInfo(var lpPluginInfo: PLUGININFO); cdecl;
begin
  StrCopy( @lpPluginInfo.name,LPCSTR(GPluginInfo.Name));
  StrCopy( @lpPluginInfo.describe,LPCSTR(GPluginInfo.Dsc));
  StrCopy( @lpPluginInfo.vendor,LPCSTR(GPluginInfo.Vendor));
  lpPluginInfo.version := GPluginInfo.Version;
  lpPluginInfo.subversion := GPluginInfo.SubVertion;
end;

exports GetPluginType        name 'GetPluginType';
exports CreatePluginClass    name 'CreatePluginClass';
exports DestroyPluginClass   name 'DestroyPluginClass';
exports GetPluginDescription name 'GetPluginDescription';
exports GetPluginInfo        name 'GetPluginInfo';

begin
  if not Assigned(DLLProc) then
    DLLProc:= @DllEntryPoint;
  DllEntryPoint(DLL_PROCESS_ATTACH);
end.