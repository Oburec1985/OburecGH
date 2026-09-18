library LuaCalcPlugin;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderPluginApi, uLuaCalcEngine, uLuaCalcPlugin;

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

function CreatePluginClass: Pointer; cdecl;
begin
  Result := TLuaCalcPlugin.Create;
end;

function DestroyPluginClass(AInstance: Pointer): LongInt; cdecl;
begin
  TLuaCalcPlugin(AInstance).Free;
  Result := 0;
end;

function PluginCreate(AInstance: Pointer;
  AHostApi: PRecorderPluginHostApi): LongBool; cdecl;
begin
  Result := (AInstance <> nil) and TLuaCalcPlugin(AInstance).Initialize(AHostApi);
end;

function PluginNotify(AInstance: Pointer; AEvent: LongInt;
  AData: Pointer): LongBool; cdecl;
begin
  Result := (AInstance <> nil) and TLuaCalcPlugin(AInstance).Notify(AEvent);
end;

function PluginClose(AInstance: Pointer): LongBool; cdecl;
begin
  Result := (AInstance <> nil);
  if Result then TLuaCalcPlugin(AInstance).Close;
end;

exports
  GetPluginType, GetPluginDescription, GetPluginInfo,
  CreatePluginClass, DestroyPluginClass, PluginCreate, PluginNotify,
  PluginClose;

begin
end.
