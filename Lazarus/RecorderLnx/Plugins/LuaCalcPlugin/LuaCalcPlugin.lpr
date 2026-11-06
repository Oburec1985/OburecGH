library LuaCalcPlugin;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderPluginApi, uRecorderPluginFramework, uLuaPluginAdapter;

function GetPluginType: LongInt; cdecl;
begin
  Result := PLUGIN_CLASS;
end;

function GetPluginDescription: PAnsiChar; cdecl;
begin
  Result := 'Lua 5.3 calculation scripts';
end;

procedure GetPluginInfo(var AInfo: TRecorderPluginInfo); cdecl;
begin
  FillChar(AInfo, SizeOf(AInfo), 0);
  StrPLCopy(@AInfo.Name[0], 'LuaCalcPlugin', High(AInfo.Name));
  StrPLCopy(@AInfo.Describe[0], 'Lua calculation scripts', High(AInfo.Describe));
  StrPLCopy(@AInfo.Vendor[0], 'RecorderLnx', High(AInfo.Vendor));
  AInfo.Version := 1;
end;

exports
  GetPluginType, GetPluginDescription, GetPluginInfo,
  CreatePluginClass, DestroyPluginClass, PluginCreate, PluginNotify,
  PluginClose;

begin
  ConfigurePluginFramework(@CreateLuaPlugin);
end.
