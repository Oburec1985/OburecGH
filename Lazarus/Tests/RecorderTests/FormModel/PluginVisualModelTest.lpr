program PluginVisualModelTest;

{$mode objfpc}{$H+}
{$PACKRECORDS C}
{$codepage utf8}

uses
  Interfaces, Forms, Controls, Classes, SysUtils, IniFiles,
  {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  uRecorderFormModel, uRecorderPluginRuntime, uRecorderVisualControl,
  uRecorderTags, uRecorderVisualComponentApiV2;

type
  TTestPluginVisualComponent = class(TRecorderPluginVisualComponent)
  public
    StartCount: Integer;
    StopCount: Integer;
    UpdateCount: Integer;
    procedure DoStart; override;
    procedure DoStop; override;
    procedure DoUpdateData; override;
  end;

  TTestPluginVisualFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create;
  end;

procedure TTestPluginVisualComponent.DoStart;
begin
  Inc(StartCount);
end;

procedure TTestPluginVisualComponent.DoStop;
begin
  Inc(StopCount);
end;

procedure TTestPluginVisualComponent.DoUpdateData;
begin
  Inc(UpdateCount);
end;

constructor TTestPluginVisualFactory.Create;
begin
  inherited Create(TRecorderPluginVisualComponent.TypeId,
    'Test plugin visual', TTestPluginVisualComponent, 120, 80, False);
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure RunTests;
var
  lSource, lCopy: TTestPluginVisualComponent;
  lFactory: TTestPluginVisualFactory;
  lInput, lOutput: TRecorderPluginConfigBytes;
begin
  lSource := TTestPluginVisualComponent.Create;
  lCopy := TTestPluginVisualComponent.Create;
  lFactory := TTestPluginVisualFactory.Create;
  try
    lSource.PluginTypeId := 'org.example.test-view';
    lSource.ConfigSchemaId := 'org.example.test-view.state';
    lSource.ConfigSchemaVersion := 7;
    lSource.Id := 'component-1';
    lSource.Name := 'Example';
    lSource.TagName := 'Signal';
    lSource.TagId := 42;
    lSource.SetBounds(10, 20, 120, 80);
    SetLength(lInput, 3);
    lInput[0] := 1;
    lInput[1] := 2;
    lInput[2] := 255;
    lSource.ConfigBlob := lInput;
    lInput[0] := 99;
    lOutput := lSource.ConfigBlob;
    Check(lOutput[0] = 1, 'setter must copy input bytes');
    lOutput[1] := 88;
    Check(lSource.ConfigBlob[1] = 2, 'getter must return isolated bytes');

    lCopy.AssignPluginVisual(lSource);
    Check(lCopy.PluginTypeId = lSource.PluginTypeId, 'plugin type assign');
    Check(lCopy.ConfigSchemaId = lSource.ConfigSchemaId, 'schema id assign');
    Check(lCopy.ConfigSchemaVersion = 7, 'schema version assign');
    Check(lCopy.Id = lSource.Id, 'common id assign');
    Check(lCopy.TagId = lSource.TagId, 'common tag assign');
    Check(lCopy.Bounds.Width = lSource.Bounds.Width, 'common bounds assign');
    lOutput := lCopy.ConfigBlob;
    Check((Length(lOutput) = 3) and (lOutput[0] = 1) and
      (lOutput[1] = 2) and (lOutput[2] = 255), 'payload assign is deep copy');
    lOutput[2] := 17;
    Check(lSource.ConfigBlob[2] = 255, 'assigned payload is independent');

    lFactory.Free;
    lFactory := TTestPluginVisualFactory.Create;
    lSource.Free;
    lSource := TTestPluginVisualComponent(
      lFactory.CreateComponent);
    Check(lFactory.ChildCount = 1, 'factory tracks created component');
    lSource.DoStart;
    lSource.DoUpdateData;
    lSource.DoStop;
    Check((lSource.StartCount = 1) and (lSource.UpdateCount = 1) and
      (lSource.StopCount = 1), 'component lifecycle callbacks');
    lSource.Free;
    lSource := nil;
    Check(lFactory.ChildCount = 0, 'destroyed component leaves factory');
  finally
    lSource.Free;
    lCopy.Free;
    lFactory.Free;
  end;
end;

procedure CopyFile(const ASourceFileName, ADestinationFileName: string);
var
  lSource, lDestination: TFileStream;
begin
  lSource := TFileStream.Create(ASourceFileName, fmOpenRead or fmShareDenyNone);
  try
    lDestination := TFileStream.Create(ADestinationFileName, fmCreate);
    try
      lDestination.CopyFrom(lSource, 0);
    finally
      lDestination.Free;
    end;
  finally
    lSource.Free;
  end;
end;

procedure RunRuntimeTests(const APluginFileName: string;
  APermanentDetachFailure: Boolean = False; ADestroyStatusFailure:Boolean = False);
type
  TProbeState = record
    Magic: QWord;
    Value: Int64;
    ObservedTagId: QWord;
    ObservedHistoryCount: LongWord;
    Reserved: LongWord;
    ObservedLatestValue: Double;
    ObservedRevision: QWord;
    ObservedTagInfo: TRecorderVisualTagInfoV2;
    ConfiguredContext: TRecorderVisualCreateContextV2;
    StartCount, UpdateCount, StopCount: LongWord;
    ServiceChecks: LongWord;
    AttachCount, DetachCount, ResizeCount, ModeCount: LongWord;
    LiveViews, SurfaceReserved: LongWord;
    LastSurface: TRecorderVisualSurfaceV2;
    FailNextDetach, FailNextResize, FailNextMode, ErrorReserved: LongWord;
    MouseInputCount, KeyInputCount: LongWord;
  end;
  TNativeViewCount = function: LongWord; cdecl;
  TCleanupFailedDestroy = function: LongInt; cdecl;
var
  lPluginDirectory, lPluginPath, lConfigFileName: string;
  lIni: TMemIniFile;
  lRegistry: TRecorderComponentFactory;
  lRuntime: TRecorderPluginRuntime;
  lSource, lCopy, lPrefixComponent: TRecorderPluginVisualComponent;
  lFactory: TRecorderComponentFactoryBase;
  lState: TProbeState;
  lBytes: TRecorderPluginConfigBytes;
  lTagRegistry: TRecorderTagRegistry;
  lTag, lEmptyTag: TRecorderTag;
  lCreateContext: TRecorderComponentCreateContext;
  lPage: TRecorderFormPage;
  lEditRequest: TRecorderVisualEditRequestV2;
  lView, lSurvivingView: TRecorderPluginViewSession;
  lSurface: TRecorderVisualSurfaceV2;
  lEstimateSettings: TRecorderTagEstimateSettings;
  lEstimateKind: TRecorderTagEstimateKind;
  {$IFDEF MSWINDOWS}
  lNativeHost: TRecorderPluginVisualHostControl;
  lNativeChild, lOldNativeChild: HWND;
  lNativeRect: TRect;
  lNativePoint: TPoint;
  lDC: HDC;
  lPinnedModule: HMODULE;
  lNativeViewCount: TNativeViewCount;
  lFailedDestroyCount,lVoidDestroyCount:TNativeViewCount;
  lCleanupFailedDestroy:TCleanupFailedDestroy;
  {$ENDIF}
begin
  if (APluginFileName = '') or not FileExists(APluginFileName) then
    raise Exception.Create('Runtime smoke plugin file is missing');
  lPluginDirectory := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))) + 'plugins';
  if not ForceDirectories(lPluginDirectory) then
    raise Exception.Create('Could not create runtime smoke plugin directory');
  lPluginPath := IncludeTrailingPathDelimiter(lPluginDirectory) +
    ExtractFileName(APluginFileName);
  lConfigFileName := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))) + 'visual-runtime-smoke.ini';
  CopyFile(APluginFileName, lPluginPath);
  lIni := TMemIniFile.Create(lConfigFileName);
  try
    lIni.WriteInteger('Plugins', 'Count', 1);
    lIni.WriteString('Plugin0', 'FileName', ExtractFileName(APluginFileName));
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;

  lRegistry := TRecorderComponentFactory.Create;
  lTagRegistry := TRecorderTagRegistry.Create(nil);
  lTag := lTagRegistry.CreateTag('Датчик', 16, True);
  lTag.UnitName := 'm/s2';
  lTag.Address := 'virtual/test';
  lTag.Description := 'История канала';
  lTag.PollFrequencyHz := 1000;
  lTag.RangeMin := -10;
  lTag.RangeMax := 10;
  lTag.AutoRange := True;
  lTagRegistry.SelectedTagName := lTag.Name;
  lEstimateSettings := lTag.EstimateSettings;
  for lEstimateKind := Low(lEstimateKind) to High(lEstimateKind) do
    lEstimateSettings.EnabledKinds[lEstimateKind] := False;
  lEstimateSettings.EnabledKinds[tekMean] := True;
  lEstimateSettings.EnabledKinds[tekRmsValue] := True;
  lEstimateSettings.DefaultKind := tekMean;
  lEstimateSettings.PortionLength := 4;
  lEstimateSettings.SmoothingEnabled := False;
  lTag.EstimateSettings := lEstimateSettings;
  lTag.AddSamples([1.0, 2.0, 3.0, 4.0], [10.0, 20.0, 30.0, 40.0], 4);
  lEmptyTag := lTagRegistry.CreateTag('Empty', 16, False);
  lRuntime := TRecorderPluginRuntime.Create(lRegistry, lTagRegistry);
  lPage := TRecorderFormPage.Create('probe', 'Probe', 'Probe');
  lView := nil;
  lSurvivingView := nil;
  {$IFDEF MSWINDOWS} lNativeHost := nil; {$ENDIF}
  try
    lRuntime.LoadConfigured(lConfigFileName);
    Check(lRuntime.LoadedCount = 1, 'V2 plugin was not loaded by runtime');
    Check(lRegistry.IsComponentRegistered('test.stateful-visual'),
      'V2 descriptor factory was not registered');
    Check(lRegistry.IsComponentRegistered('test.empty-state-visual'),
      'second V2 descriptor factory was not registered');
    lPrefixComponent := TRecorderPluginVisualComponent(
      lRegistry.CreateComponent('test.empty-state-visual'));
    try
      lEditRequest := Default(TRecorderVisualEditRequestV2);
      Check(RecorderPluginVisualEdit(lPrefixComponent,lEditRequest) = REC_VISUAL_NOT_HANDLED,
        'short descriptor invoked poisoned editor callback');
      Check(RecorderPluginVisualOpenView(lPrefixComponent) = nil,
        'short descriptor exposed poisoned view callback');
    finally lPrefixComponent.Free; end;
    lFactory := lRegistry.FindFactory('test.stateful-visual');
    FillChar(lCreateContext, SizeOf(lCreateContext), 0);
    lCreateContext.Page := lPage;
    lCreateContext.ComponentNo := 23;
    lCreateContext.SelectedTag := lTag;
    lCreateContext.DefaultTag := lEmptyTag;
    lSource := TRecorderPluginVisualComponent(
      lFactory.CreateComponentForPage(lCreateContext));
    lRegistry.DoStart;
    lRegistry.DoUpdateData;
    lRegistry.DoStop;
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not inspect plugin host-service observations');
    Check(Length(lSource.ConfigBlob) = SizeOf(lState), 'probe state ABI size');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    Check(lState.ObservedTagId = lTag.Id, 'host services delivered wrong tag');
    Check(lState.Reserved = 2, 'tag enumeration did not terminate after two tags');
    Check(lState.ObservedHistoryCount = 2, 'history window count');
    Check(lState.ObservedLatestValue = 40, 'history values did not cross ABI');
    Check(lState.ObservedRevision = lTag.SignalRevision, 'history revision');
    Check(StrPas(@lState.ObservedTagInfo.Name[0]) = UTF8String('Датчик'),
      'UTF-8 tag name metadata');
    Check(StrPas(@lState.ObservedTagInfo.Description[0]) =
      UTF8String('История канала'), 'UTF-8 tag description metadata');
    Check(StrPas(@lState.ObservedTagInfo.UnitName[0]) = 'm/s2', 'tag units');
    Check(StrPas(@lState.ObservedTagInfo.Address[0]) = 'virtual/test', 'tag address');
    Check(lState.ObservedTagInfo.Flags =
      (REC_VISUAL_TAG_FLAG_VIRTUAL or REC_VISUAL_TAG_FLAG_VECTOR or
      REC_VISUAL_TAG_FLAG_AUTO_RANGE or REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE), 'tag flags');
    Check((lState.ObservedTagInfo.PollFrequencyHz = 1000) and
      (lState.ObservedTagInfo.RangeMin = -10) and
      (lState.ObservedTagInfo.RangeMax = 10), 'tag frequency and ranges');
    Check((lState.ConfiguredContext.ComponentNo = 23) and
      (lState.ConfiguredContext.SelectedTagId = lTag.Id) and
      (lState.ConfiguredContext.DefaultTagId = lEmptyTag.Id),
      'palette configure context did not reach plugin');
    Check((lState.StartCount = 1) and (lState.UpdateCount = 1) and
      (lState.StopCount = 1), 'production lifecycle did not reach plugin');
    Check(lState.ServiceChecks = 17, 'plugin service edge checks were skipped');
    lState.Magic := QWord($56495355414C5632);
    lState.Value := 735;
    SetLength(lBytes, SizeOf(lState));
    Move(lState, lBytes[0], SizeOf(lState));
    lSource.ConfigBlob := lBytes;
    lSource.ConfigStatePresent := True;
    Check(lFactory.LoadOpaqueComponentState(lSource) = rosSuccess,
      'production factory did not restore state');
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'production factory did not save state');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    Check(lState.Value = 735, 'production factory changed opaque state');

    lTag.AddSample(5, 50);
    lCopy := TRecorderPluginVisualComponent(
      lRegistry.CreateComponent('test.stateful-visual'));
    Check(lFactory.SaveOpaqueComponentState(lCopy) = rosSuccess,
      'could not read new history revision through services');
    Move(lCopy.ConfigBlob[0], lState, SizeOf(lState));
    Check((lState.ObservedLatestValue = 50) and
      (lState.ObservedRevision = lTag.SignalRevision),
      'plugin service snapshot did not advance after producer update');
    lCopy.AssignPluginVisual(lSource);
    Check(Length(lCopy.ConfigBlob) = SizeOf(lState),
      'copy did not receive state bytes');
    Move(lCopy.ConfigBlob[0], lState, SizeOf(lState));
    Check(lState.Value = 735, 'copy did not restore the plugin runtime state');

    FillChar(lEditRequest, SizeOf(lEditRequest), 0);
    lEditRequest.Header.Size := SizeOf(lEditRequest);
    lEditRequest.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    lEditRequest.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
    lEditRequest.Dpi := 96;
    Check(RecorderPluginVisualEdit(lSource, lEditRequest) = REC_VISUAL_OK,
      'generic editor acceptance did not reach plugin');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    Check(lState.Value = 736, 'accepted editor state was not saved');
    Check(RecorderPluginVisualEdit(lSource, lEditRequest) = REC_VISUAL_CANCELLED,
      'generic editor cancellation was not delivered');
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not read runtime state after cancellation');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    Check(lState.Value = 736, 'cancelled editor mutated plugin runtime state');

    FillChar(lSurface, SizeOf(lSurface), 0);
    lSurface.Header.Size := SizeOf(lSurface);
    lSurface.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    lSurface.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
    lSurface.Dpi := 144;
    lSurface.Width := 320;
    lSurface.Height := 180;
    lSurface.Flags := REC_VISUAL_VIEW_INTERACTIVE;
    lView := RecorderPluginVisualOpenView(lSource);
    Check(lView <> nil, 'generic view session creation');
    Check(lView.Attach(lSurface) = REC_VISUAL_OK, 'plugin view attachment');
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not configure surface failure fixture');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    lState.FailNextDetach := 1;
    lState.FailNextResize := 1;
    lState.FailNextMode := 1;
    Move(lState, lBytes[0], SizeOf(lState));
    lSource.ConfigBlob := lBytes;
    Check(lFactory.LoadOpaqueComponentState(lSource) = rosSuccess,
      'could not inject plugin surface failure');
    Check((lView.Attach(lSurface) = REC_VISUAL_ERROR) and lView.Attached,
      'failed detach allowed a second attach');
    Check(lView.Resize(lSurface) = REC_VISUAL_ERROR,
      'resize failure was hidden');
    Check(lView.SetMode(lSurface) = REC_VISUAL_ERROR,
      'view mode failure was hidden');
    lSurface.Width := 640;
    lSurface.Height := 360;
    Check(lView.Resize(lSurface) = REC_VISUAL_OK, 'view resize');
    lSurface.Flags := 0;
    Check(lView.SetMode(lSurface) = REC_VISUAL_OK, 'view edit mode');
    Check(lView.Detach = REC_VISUAL_OK, 'view detach');
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not inspect surface observations');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    Check((lState.AttachCount = 1) and (lState.DetachCount = 1) and
      (lState.ResizeCount = 1) and (lState.ModeCount = 1),
      'generic surface lifecycle was not delivered exactly once');
    Check((lState.LastSurface.Width = 640) and
      (lState.LastSurface.Height = 360) and
      (lState.LastSurface.Dpi = 144) and (lState.LastSurface.Flags = 0),
      'resize/DPI/edit mode payload');
    {$IFDEF MSWINDOWS}
    Check(TRecorderVisualControlRegistry.GetControlClass(
      TRecorderPluginVisualComponent) = TRecorderPluginVisualHostControl,
      'generic plugin model has no registered host surface');
    lNativeHost := TRecorderPluginVisualHostControl.Create(nil);
    lNativeHost.ParentWindow := GetDesktopWindow;
    lNativeHost.SetBounds(10, 10, 320, 180);
    lNativeHost.Configure(lSource, lTagRegistry);
    lNativeHost.Show;
    Application.ProcessMessages;
    lNativeChild := FindWindowEx(lNativeHost.Handle, 0, nil, 'ABI native probe');
    Check(lNativeChild <> 0, 'DLL did not create its native child view');
    Check(GetParent(lNativeChild) = lNativeHost.Handle,
      'plugin view was not embedded in the generic host surface');
    UpdateWindow(lNativeChild);
    lDC := GetDC(lNativeChild);
    try
      Check(GetPixel(lDC, 5, 40) = RGB(255, 0, 255),
        'plugin-owned view did not render its pixel pattern');
    finally
      ReleaseDC(lNativeChild, lDC);
    end;
    SendMessage(lNativeChild, WM_LBUTTONDOWN, MK_LBUTTON, (40 shl 16) or 10);
    SendMessage(lNativeChild, WM_LBUTTONUP, 0, (40 shl 16) or 10);
    SendMessage(lNativeChild, WM_KEYDOWN, VK_HOME, 0);
    lNativeHost.SetBounds(10, 10, 480, 260);
    Application.ProcessMessages;
    GetClientRect(lNativeChild, lNativeRect);
    Check((lNativeRect.Right = lNativeHost.ClientWidth) and
      (lNativeRect.Bottom = lNativeHost.ClientHeight), 'plugin child resize');
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not configure native mode failure');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    lState.FailNextMode := 1;
    Move(lState, lBytes[0], SizeOf(lState));
    lSource.ConfigBlob := lBytes;
    Check(lFactory.LoadOpaqueComponentState(lSource) = rosSuccess,
      'native mode failure injection');
    lNativeHost.EditMode := True;
    Check(not lNativeHost.EditMode and IsWindowEnabled(lNativeChild),
      'failed mode update committed host mode');
    lNativeHost.EditMode := True;
    Check(not IsWindowEnabled(lNativeChild), 'plugin view steals editor input');
    lNativePoint.X := 10;
    lNativePoint.Y := 40;
    ClientToScreen(lNativeChild, lNativePoint);
    Check(WindowFromPoint(lNativePoint) <> lNativeChild,
      'disabled plugin child still owns editor hit testing');
    lNativeHost.EditMode := False;
    Check(IsWindowEnabled(lNativeChild), 'plugin view input was not restored');
    lOldNativeChild := lNativeChild;
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not configure native parent detach failure');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    lState.FailNextDetach := 1;
    Move(lState, lBytes[0], SizeOf(lState));
    lSource.ConfigBlob := lBytes;
    Check(lFactory.LoadOpaqueComponentState(lSource) = rosSuccess,
      'parent recreation detach failure injection');
    RecreateWnd(lNativeHost);
    Application.ProcessMessages;
    Check(not IsWindow(lOldNativeChild), 'old plugin child survived parent recreation');
    lNativeChild := FindWindowEx(lNativeHost.Handle, 0, nil, 'ABI native probe');
    Check(lNativeChild <> 0, 'plugin child was not recreated with native parent');
    if APermanentDetachFailure then
    begin
      Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
        'could not configure permanent detach failure');
      Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
      lState.FailNextDetach := High(LongWord);
      Move(lState, lBytes[0], SizeOf(lState));
      lSource.ConfigBlob := lBytes;
      Check(lFactory.LoadOpaqueComponentState(lSource) = rosSuccess,
        'permanent detach failure injection');
      FreeAndNil(lNativeHost);
      lRuntime.Free;
      lRuntime := nil;
      lPinnedModule := GetModuleHandle(PChar(ExtractFileName(lPluginPath)));
      Check(lPinnedModule <> 0, 'unsafe native plugin was unloaded');
      Pointer(lNativeViewCount) := GetProcAddress(lPinnedModule, 'ProbeNativeViewCount');
      Check(Assigned(lNativeViewCount) and (lNativeViewCount() = 0),
        'final instance destruction did not close orphan native forms');
      Check(not IsWindow(lNativeChild), 'native window survived fallback teardown');
      { Fixture-only cleanup: all plugin objects/windows have been proven gone.
        Release the reference deliberately pinned by production error handling. }
      Check(Windows.FreeLibrary(lPinnedModule), 'fixture pin cleanup failed');
      WriteLn('RESULT PluginVisualModelTest pinned fallback passed');
      Exit;
    end;
    FreeAndNil(lNativeHost);
    Check(not IsWindow(lNativeChild), 'plugin child survived host surface destruction');
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'could not inspect native view observations');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    Check((lState.MouseInputCount = 1) and (lState.KeyInputCount = 1),
      'mouse/keyboard events did not reach plugin-owned view handlers');
    Check(lState.LiveViews = 0, 'native views leaked after host surface destruction');
    {$ENDIF}
    lSurvivingView := RecorderPluginVisualOpenView(lSource);
    Check(lSurvivingView.Attach(lSurface) = REC_VISUAL_OK,
      'second view session attachment');

    { Runtime teardown must unregister factories, destroy their instances, and
      only then unload the containing library. Keep both controls alive here. }
    {$IFDEF MSWINDOWS}
    if ADestroyStatusFailure then
      Check(SetEnvironmentVariable('RECORDER_DESTROY_PROBE','error'),'destroy injection env');
    {$ENDIF}
    lRuntime.Free;
    lRuntime := nil;
    Check(not lView.Active and not lSurvivingView.Active and
      not lSurvivingView.Attached, 'view sessions survived DLL unload');
    lSurvivingView.Resize(lSurface);
    lSurvivingView.Detach;
    Check(not lRegistry.IsComponentRegistered('test.stateful-visual'),
      'runtime teardown left the V2 factory registered');
    Check(not lRegistry.IsComponentRegistered('test.empty-state-visual'),
      'runtime teardown left the second V2 factory registered');
    {$IFDEF MSWINDOWS}
    if ADestroyStatusFailure then
    begin
      SetEnvironmentVariable('RECORDER_DESTROY_PROBE',nil);
      lPinnedModule:=GetModuleHandle(PChar(ExtractFileName(lPluginPath)));
      Check(lPinnedModule<>0,'destroy ERROR unloaded native callback module');
      Pointer(lFailedDestroyCount):=GetProcAddress(lPinnedModule,'ProbeFailedDestroyCount');
      Pointer(lVoidDestroyCount):=GetProcAddress(lPinnedModule,'ProbeVoidDestroyCount');
      Pointer(lCleanupFailedDestroy):=GetProcAddress(lPinnedModule,'ProbeCleanupFailedDestroy');
      Pointer(lNativeViewCount):=GetProcAddress(lPinnedModule,'ProbeNativeViewCount');
      Check(Assigned(lFailedDestroyCount) and Assigned(lVoidDestroyCount) and
        Assigned(lCleanupFailedDestroy) and Assigned(lNativeViewCount),'destroy diagnostics missing');
      Check(lFailedDestroyCount()>0,'destroy failure did not retain allocated instance');
      Check(lVoidDestroyCount()=0,'host called void destruction after status ERROR');
      Check(lNativeViewCount()=0,'successful detach left native views during destroy ERROR');
      Check(lCleanupFailedDestroy()=REC_VISUAL_OK,'fixture failed-instance cleanup');
      Check(lFailedDestroyCount()=0,'fixture leaked retained instance');
      Check(Windows.FreeLibrary(lPinnedModule),'fixture destroy-status pin cleanup');
      WriteLn('RESULT PluginVisualModelTest destroy status ERROR pin passed');
    end
    else Check(GetModuleHandle(PChar(ExtractFileName(lPluginPath)))=0,
      'normal/short-prefix destruction pinned module');
    {$ENDIF}
  finally
    {$IFDEF MSWINDOWS} lNativeHost.Free; {$ENDIF}
    {$IFDEF MSWINDOWS} SetEnvironmentVariable('RECORDER_DESTROY_PROBE',nil); {$ENDIF}
    lRuntime.Free;
    lView.Free;
    lSurvivingView.Free;
    lRegistry.Free;
    lTagRegistry.Free;
    lPage.Free;
    SysUtils.DeleteFile(lConfigFileName);
    SysUtils.DeleteFile(lPluginPath);
    RemoveDir(lPluginDirectory);
  end;
  WriteLn('RESULT PluginVisualModelTest runtime cycle passed');
end;

begin
  try
    if ParamCount > 0 then
    begin
      Application.Initialize;
      Application.ShowMainForm := False;
    end;
    RunTests;
    if ParamCount > 0 then
    begin
      RunRuntimeTests(ParamStr(1));
      RunRuntimeTests(ParamStr(1));
      {$IFDEF MSWINDOWS} RunRuntimeTests(ParamStr(1), True); {$ENDIF}
      {$IFDEF MSWINDOWS} RunRuntimeTests(ParamStr(1),False,True); {$ENDIF}
      WriteLn('RESULT PluginVisualModelTest runtime passed');
    end
    else
      WriteLn('RESULT PluginVisualModelTest model-only passed; runtime not requested');
  except
    on E: Exception do
    begin
      WriteLn('RESULT PluginVisualModelTest failed: ', E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
