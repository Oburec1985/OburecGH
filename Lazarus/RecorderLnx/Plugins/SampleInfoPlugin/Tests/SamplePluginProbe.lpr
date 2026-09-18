program SamplePluginProbe;

{$mode objfpc}{$H+}

uses
  SysUtils, DynLibs, uRecorderPluginApi;

var
  g_RegisterCount: Integer;
  g_ComponentContext: Pointer;
  g_ComponentClose: TRecorderPluginOscillogramClose;

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
  lFrame: TRecorderPluginOscillogramFrame;
  lValues: array[0..2] of Double;
begin
  Check(AHostContext = Pointer(1), 'wrong host context');
  Check(StrPas(ATypeId) = 'sample.oscillogram', 'wrong type id');
  Check(StrPas(ACaption) = 'Sample oscillogram', 'wrong caption');
  Check(StrPas(AGroupId) = 'charts', 'wrong toolbar group');
  Check(Assigned(ACreate), 'missing factory callback');
  FillChar(lSpec, SizeOf(lSpec), 0);
  lSpec.Size := SizeOf(lSpec);
  Check(ACreate(APluginContext, @lSpec), 'factory callback failed');
  Check((lSpec.Width = 650) and (lSpec.Height = 350), 'wrong component size');
  Check(lSpec.ComponentContext <> nil, 'missing component context');
  Check(Assigned(lSpec.DoRepaint) and Assigned(lSpec.DoClose),
    'missing visual lifecycle callbacks');
  lValues[0] := -3;
  lValues[1] := 0;
  lValues[2] := 4;
  lFrame := Default(TRecorderPluginOscillogramFrame);
  lFrame.Size := SizeOf(lFrame);
  lFrame.SampleCount := Length(lValues);
  lFrame.Values := @lValues[0];
  Check(lSpec.DoRepaint(lSpec.ComponentContext, @lFrame), 'doRepaint failed');
  Check((lFrame.MinValue = -3) and (lFrame.MaxValue = 4) and
    (Abs(lFrame.RmsValue - Sqrt(25 / 3)) < 1E-9),
    'wrong Peak/RMS calculations');
  g_ComponentContext := lSpec.ComponentContext;
  g_ComponentClose := lSpec.DoClose;
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
    Check((lInfo.Version = 1) and (lInfo.SubVersion = 1),
      'wrong plugin version');

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
      g_ComponentClose(g_ComponentContext);
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
