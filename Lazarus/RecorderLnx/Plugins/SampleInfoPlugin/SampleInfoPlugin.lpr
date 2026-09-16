library SampleInfoPlugin;

{$mode objfpc}{$H+}

uses
  SysUtils, uRecorderPluginApi, PluginClass;

const
  PluginDescription: PAnsiChar = 'Cross-platform RecorderLnx oscillogram sample';

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
  StrPLCopy(@AInfo.name[0], 'SampleInfoPlugin', High(AInfo.name));
  StrPLCopy(@AInfo.describe[0], PluginDescription, High(AInfo.describe));
  StrPLCopy(@AInfo.vendor[0], 'Mera', High(AInfo.vendor));
  AInfo.version := 1;
end;

function CreatePluginClass: Pointer; cdecl;
begin
  Result := TPluginClass.Create;
end;

function DestroyPluginClass(AInstance: Pointer): LongInt; cdecl;
begin
  TPluginClass(AInstance).Free;
  Result := 0;
end;

function PluginCreate(AInstance: Pointer;
  AHostApi: PRecorderPluginHostApi): LongBool; cdecl;
begin
  Result := (AInstance <> nil) and TPluginClass(AInstance)._Create(AHostApi);
end;

function PluginNotify(AInstance: Pointer; AEvent: LongInt;
  AData: Pointer): LongBool; cdecl;
begin
  Result := (AInstance <> nil) and TPluginClass(AInstance).Notify(AEvent, AData);
end;

function PluginClose(AInstance: Pointer): LongBool; cdecl;
begin
  Result := (AInstance <> nil) and TPluginClass(AInstance).Close;
end;

exports
  GetPluginType name 'GetPluginType',
  GetPluginDescription name 'GetPluginDescription',
  GetPluginInfo name 'GetPluginInfo',
  CreatePluginClass name 'CreatePluginClass',
  DestroyPluginClass name 'DestroyPluginClass',
  PluginCreate name 'PluginCreate',
  PluginNotify name 'PluginNotify',
  PluginClose name 'PluginClose';

begin
end.
