program SamplePluginProbe;

{$mode objfpc}{$H+}

uses
  SysUtils, DynLibs, uRecorderPluginApi;

var
  g_RegisterCount: Integer;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function RegisterOscillogram(AHostContext: Pointer;
  ATypeId, ACaption, AGroupId: PAnsiChar;
  ACreate: TRecorderPluginCreateComponent;
  APluginContext: Pointer): LongBool; cdecl;
var
  lSpec: TRecorderPluginComponentSpec;
begin
  Check(AHostContext = Pointer(1), 'wrong host context');
  Check(StrPas(ATypeId) = 'sample.oscillogram', 'wrong type id');
  Check(StrPas(ACaption) = 'Sample oscillogram', 'wrong caption');
  Check(StrPas(AGroupId) = 'charts', 'wrong toolbar group');
  Check(Assigned(ACreate), 'missing factory callback');
  FillChar(lSpec, SizeOf(lSpec), 0);
  lSpec.Size := SizeOf(lSpec);
  Check(ACreate(APluginContext, @lSpec), 'factory callback failed');
  Check((lSpec.Width = 480) and (lSpec.Height = 260), 'wrong component size');
  Check(StrPas(@lSpec.Name[0]) = 'Sample oscillogram', 'wrong component name');
  Inc(g_RegisterCount);
  Result := True;
end;

procedure RunProbe(const ALibraryPath: string);
var
  lLibrary: TLibHandle;
  lGetType: TRecorderPluginGetType;
  lGetInfo: TRecorderPluginGetInfo;
  lCreateClass: TRecorderPluginCreateClass;
  lDestroyClass: TRecorderPluginDestroyClass;
  lCreate: TRecorderPluginCreate;
  lNotify: TRecorderPluginNotify;
  lClose: TRecorderPluginClose;
  lInfo: TRecorderPluginInfo;
  lHostApi: TRecorderPluginHostApi;
  lInstance: Pointer;
begin
  lLibrary := LoadLibrary(ALibraryPath);
  Check(lLibrary <> NilHandle, 'cannot load ' + ALibraryPath);
  try
    lGetType := TRecorderPluginGetType(GetProcedureAddress(lLibrary, 'GetPluginType'));
    lGetInfo := TRecorderPluginGetInfo(GetProcedureAddress(lLibrary, 'GetPluginInfo'));
    lCreateClass := TRecorderPluginCreateClass(GetProcedureAddress(lLibrary, 'CreatePluginClass'));
    lDestroyClass := TRecorderPluginDestroyClass(GetProcedureAddress(lLibrary, 'DestroyPluginClass'));
    lCreate := TRecorderPluginCreate(GetProcedureAddress(lLibrary, 'PluginCreate'));
    lNotify := TRecorderPluginNotify(GetProcedureAddress(lLibrary, 'PluginNotify'));
    lClose := TRecorderPluginClose(GetProcedureAddress(lLibrary, 'PluginClose'));
    Check(Assigned(lGetType) and Assigned(lGetInfo) and
      Assigned(lCreateClass) and Assigned(lDestroyClass) and
      Assigned(lCreate) and Assigned(lNotify) and Assigned(lClose),
      'required export missing');
    Check(SizeOf(lInfo) = 512, 'PLUGININFO ABI size differs from C++');
    Check(lGetType() = PLUGIN_CLASS, 'wrong plugin type');
    FillChar(lInfo, SizeOf(lInfo), 0);
    lGetInfo(lInfo);
    Check(StrPas(@lInfo.Name[0]) = 'SampleInfoPlugin', 'wrong plugin name');

    FillChar(lHostApi, SizeOf(lHostApi), 0);
    lHostApi.Size := SizeOf(lHostApi);
    lHostApi.HostContext := Pointer(1);
    lHostApi.RegisterOscillogramFactory := @RegisterOscillogram;
    lInstance := lCreateClass();
    Check(lInstance <> nil, 'CreatePluginClass failed');
    try
      Check(lCreate(lInstance, @lHostApi), 'PluginCreate failed');
      Check(g_RegisterCount = 1, 'factory was not registered once');
      Check(lNotify(lInstance, 42, nil), 'PluginNotify failed');
      Check(lClose(lInstance), 'PluginClose failed');
    finally
      Check(lDestroyClass(lInstance) = 0, 'DestroyPluginClass failed');
    end;
  finally
    UnloadLibrary(lLibrary);
  end;
end;

begin
  try
    Check(ParamCount = 1, 'usage: SamplePluginProbe <dll-or-so-path>');
    RunProbe(ParamStr(1));
    WriteLn('RESULT sample-plugin passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT sample-plugin failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
