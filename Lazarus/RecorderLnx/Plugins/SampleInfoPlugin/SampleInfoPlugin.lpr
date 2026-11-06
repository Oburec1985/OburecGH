library SampleInfoPlugin;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, SysUtils, uRecorderPluginApi,
  uRecorderPluginFramework, uCreateComponents;

const
  PluginDescription: PAnsiChar = 'Self-contained Oscillograph, visual ABI 2.8';

function GetPluginType: LongInt; cdecl;
begin
  Result := PLUGIN_CLASS;
end;

function GetPluginDescription: PAnsiChar; cdecl;
begin
  Result := PluginDescription;
end;

procedure GetPluginInfo(var AInfo: TRecorderPluginInfo); cdecl;
begin
  FillChar(AInfo, SizeOf(AInfo), 0);
  StrPLCopy(@AInfo.name[0], UTF8Encode('Осциллограф'), High(AInfo.name));
  StrPLCopy(@AInfo.describe[0], PluginDescription, High(AInfo.describe));
  StrPLCopy(@AInfo.vendor[0], 'Mera', High(AInfo.vendor));
  AInfo.version := 1;
  AInfo.SubVersion := 3;
end;

exports
  RecorderVisualGetDescriptorV2,
  RecorderVisualUsesPluginNotifications,
  CreatePluginClass, DestroyPluginClass, PluginCreate, PluginNotify, PluginClose,
  GetPluginType name 'GetPluginType',
  GetPluginDescription name 'GetPluginDescription',
  GetPluginInfo name 'GetPluginInfo';

begin
  ConfigureFramework(@CreateComponents);
  Application.Initialize;
  Application.ShowMainForm := False;
end.
