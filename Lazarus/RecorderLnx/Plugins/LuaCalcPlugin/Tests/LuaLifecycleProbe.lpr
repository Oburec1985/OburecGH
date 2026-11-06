program LuaLifecycleProbe;

{$mode objfpc}{$H+}

{ Проверка общего ABI Lua-плагина без реального проекта и записи в теги. }
uses SysUtils, DynLibs, uRecorderPluginApi;

var
  lLibrary: TLibHandle;
  lCreateClass: TRecorderPluginCreateClass;
  lDestroyClass: TRecorderPluginDestroyClass;
  lCreate: TRecorderPluginCreate;
  lNotify: TRecorderPluginNotify;
  lClose: TRecorderPluginClose;
  lApi: TRecorderPluginHostApi;
  lPlugin: Pointer;
  I: Integer;
begin
  if ParamCount <> 1 then Halt(1);
  lLibrary := LoadLibrary(ParamStr(1));
  if lLibrary = NilHandle then Halt(2);
  Pointer(lCreateClass) := GetProcedureAddress(lLibrary, 'CreatePluginClass');
  Pointer(lDestroyClass) := GetProcedureAddress(lLibrary, 'DestroyPluginClass');
  Pointer(lCreate) := GetProcedureAddress(lLibrary, 'PluginCreate');
  Pointer(lNotify) := GetProcedureAddress(lLibrary, 'PluginNotify');
  Pointer(lClose) := GetProcedureAddress(lLibrary, 'PluginClose');
  if not Assigned(lCreateClass) or not Assigned(lDestroyClass) or
    not Assigned(lCreate) or not Assigned(lNotify) or not Assigned(lClose) then Halt(3);
  for I := 1 to 2 do
  begin
    lPlugin := lCreateClass();
    if lPlugin = nil then Halt(4);
    lApi := Default(TRecorderPluginHostApi);
    lApi.Size := PtrUInt(@lApi.LogMessage) - PtrUInt(@lApi) + SizeOf(lApi.LogMessage);
    if not lCreate(lPlugin, @lApi) then Halt(5);
    if not lNotify(lPlugin, PN_RCLOADCONFIG, nil) or
      not lNotify(lPlugin, PN_UPDATEDATA, nil) then Halt(6);
    if not lClose(lPlugin) or (lDestroyClass(lPlugin) <> 0) then Halt(7);
  end;
  UnloadLibrary(lLibrary);
  WriteLn('RESULT Lua short host API and two lifecycle cycles passed');
end.
