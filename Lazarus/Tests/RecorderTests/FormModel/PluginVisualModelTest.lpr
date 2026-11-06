program PluginVisualModelTest;

{$mode objfpc}{$H+}
{$PACKRECORDS C}
{$codepage utf8}

uses
  Interfaces, Forms, Controls, Classes, SysUtils, IniFiles, Process, SyncObjs,
  {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  uRecorderFormModel, uRecorderPluginRuntime, uRecorderVisualControl,
  uRecorderTags, uRecorderVisualComponentApiV2, uRecorderStateMachine,
  uRecorderPluginApi;

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

  TProbeServicesFn = function(AAfterShutdown:LongInt):LongInt; cdecl;
  TInFlightHarness = class
    Entered, ReleaseLog, ShutdownDone: TEvent;
    Runtime: TRecorderPluginRuntime;
    Probe: TProbeServicesFn;
    Error: string;
    Block, ReentrantChecked: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure LogMessage(const AMessage:string);
  end;
  TShutdownWorker = class(TThread)
    Harness: TInFlightHarness;
    procedure Execute; override;
  end;
  TObserveWorker = class(TThread)
    Harness: TInFlightHarness;
    procedure Execute; override;
  end;

constructor TInFlightHarness.Create;
begin
  inherited Create;
  Entered:=TEvent.Create(nil,True,False,'');
  ReleaseLog:=TEvent.Create(nil,True,False,'');
  ShutdownDone:=TEvent.Create(nil,True,False,'');
end;

destructor TInFlightHarness.Destroy;
begin
  ShutdownDone.Free; ReleaseLog.Free; Entered.Free;
  inherited Destroy;
end;

procedure TInFlightHarness.LogMessage(const AMessage:string);
begin
  ReentrantChecked:=not Runtime.TryBeginShutdown;
  if not Block then Exit;
  Entered.SetEvent;
  if ReleaseLog.WaitFor(10000)<>wrSignaled then
    Error:='blocked callback timed out';
end;

procedure TShutdownWorker.Execute;
begin
  if Harness.Entered.WaitFor(10000)<>wrSignaled then begin
    Harness.Error:='callback did not begin'; Harness.ShutdownDone.SetEvent; Exit;
  end;
  try
    if Harness.Runtime.TryBeginShutdown then
      Harness.Error:='active callback shutdown was accepted'
    else if Harness.Runtime.LoadedCount<>1 then
      Harness.Error:='shutdown refusal damaged runtime';
  except
    on E:Exception do Harness.Error:='shutdown failed: '+E.Message;
  end;
  Harness.ShutdownDone.SetEvent;
end;

procedure TObserveWorker.Execute;
begin
  if Harness.Entered.WaitFor(10000)<>wrSignaled then begin
    Harness.Error:='callback did not begin'; Harness.ReleaseLog.SetEvent; Exit;
  end;
  if Harness.ShutdownDone.WaitFor(8000)<>wrSignaled then
    Harness.Error:='shutdown refusal did not return'
  else if Harness.Probe(0)<>REC_VISUAL_OK then
    Harness.Error:='services unavailable after shutdown refusal';
  Harness.ReleaseLog.SetEvent;
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
  APermanentDetachFailure: Boolean = False; ADestroyStatusFailure:Boolean = False;
  AManagedLifecycle:Boolean = False; AProbePinnedServices:Boolean = False;
  AProbeInFlight:Boolean = False; ACloseRetry:Boolean = False;
  AInitFail:Boolean = False);
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
  TProbeBorrowedServices = function(AAfterShutdown:LongInt):LongInt; cdecl;
var
  lPluginDirectory, lPluginPath, lConfigFileName: string;
  lSuffix: string;
  lGuid: TGUID;
  lCreatedPlugin, lCreatedConfig, lCreatedDirectory: Boolean;
  lIni: TMemIniFile;
  lRegistry: TRecorderComponentFactory;
  lRuntime: TRecorderPluginRuntime;
  lSource, lCopy, lPrefixComponent, lSecond: TRecorderPluginVisualComponent;
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
  lMachine: TRecorderStateMachine;
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
  lProbeBorrowedServices:TProbeBorrowedServices;
  lFinalizePinnedPlugin:TCleanupFailedDestroy;
  lPinnedProbeStatus:LongInt;
  lProbeLogService:TCleanupFailedDestroy;
  lInFlight:TInFlightHarness;
  lShutdownWorker:TShutdownWorker;
  lObserveWorker:TObserveWorker;
  lExternalModule:HMODULE;
  lCloseCount,lPluginDestroyCount,lWorkerStopCount,lWorkerRunning:TNativeViewCount;
  lDestroyBefore:LongWord;
  {$ENDIF}
begin
  lCreatedPlugin:=False; lCreatedConfig:=False; lCreatedDirectory:=False;
  {$IFDEF MSWINDOWS}
  lExternalModule:=0;
  if ACloseRetry or AInitFail then begin
    if AInitFail then
      Check(SetEnvironmentVariable('RECORDER_CLOSE_PROBE','initfail'),'init failure injection env')
    else
      Check(SetEnvironmentVariable('RECORDER_CLOSE_PROBE','failonce'),'close injection env');
  end;
  {$ENDIF}
  if (APluginFileName = '') or not FileExists(APluginFileName) then
    raise Exception.Create('Runtime smoke plugin file is missing');
  lPluginDirectory := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))) + 'plugins';
  lCreatedDirectory := not DirectoryExists(lPluginDirectory);
  if not ForceDirectories(lPluginDirectory) then
    raise Exception.Create('Could not create runtime smoke plugin directory');
  if CreateGUID(lGuid) <> 0 then
    raise Exception.Create('Could not generate unique fixture name');
  lSuffix := GUIDToString(lGuid);
  lPluginPath := IncludeTrailingPathDelimiter(lPluginDirectory) +
    ChangeFileExt(ExtractFileName(APluginFileName), '') + '-' + lSuffix +
    ExtractFileExt(APluginFileName);
  lConfigFileName := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))) + 'visual-runtime-smoke-' + lSuffix + '.ini';
  if FileExists(lPluginPath) or FileExists(lConfigFileName) then
    raise Exception.Create('Unique fixture path unexpectedly exists');
  CopyFile(APluginFileName, lPluginPath);
  lCreatedPlugin:=True;
  lIni := TMemIniFile.Create(lConfigFileName);
  try
    lIni.WriteInteger('Plugins', 'Count', 1);
    lIni.WriteString('Plugin0', 'FileName', ExtractFileName(lPluginPath));
    lCreatedConfig:=True;
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
    {$IFDEF MSWINDOWS}
    if AInitFail then begin
      Check(lRuntime.LoadedCount=0,'failed plugin counted as loaded');
      Check(not lRegistry.IsComponentRegistered('test.stateful-visual'),
        'failed plugin registered a factory');
      lPinnedModule:=GetModuleHandle(PChar(ExtractFileName(lPluginPath)));
      Check(lPinnedModule<>0,'failed-init DLL was unloaded before worker stop');
      Pointer(lCloseCount):=GetProcAddress(lPinnedModule,'ProbeCloseCount');
      Pointer(lPluginDestroyCount):=GetProcAddress(lPinnedModule,'ProbePluginDestroyCount');
      Pointer(lWorkerStopCount):=GetProcAddress(lPinnedModule,'ProbeWorkerStopCount');
      Pointer(lWorkerRunning):=GetProcAddress(lPinnedModule,'ProbeWorkerRunning');
      Check(Assigned(lCloseCount) and Assigned(lPluginDestroyCount) and
        Assigned(lWorkerStopCount) and Assigned(lWorkerRunning),'initfail fixture exports missing');
      Check((lCloseCount()=1) and (lPluginDestroyCount()=0) and
        (lWorkerRunning()=1) and (lWorkerStopCount()=0),
        'failed init did not preserve worker and plugin after refused close');
      lExternalModule:=Windows.LoadLibrary(PChar(lPluginPath));
      Check(lExternalModule<>0,'cannot hold failed-init fixture for counters');
      Check(lRuntime.TryBeginShutdown,'failed-init quarantine close retry failed');
      Check((lCloseCount()=2) and (lWorkerStopCount()=1) and
        (lWorkerRunning()=0) and (lPluginDestroyCount()=0),
        'failed-init quarantine did not join worker before destruction');
      lRuntime.Free; lRuntime:=nil;
      Check(lPluginDestroyCount()=1,'failed-init plugin was not destroyed after close');
      Check(Windows.FreeLibrary(lExternalModule),'failed-init fixture reference not released');
      lExternalModule:=0;
      Check(GetModuleHandle(PChar(ExtractFileName(lPluginPath)))=0,
        'failed-init plugin was not unloaded');
      WriteLn('RESULT failed PluginCreate quarantine/retry passed');
      Exit;
    end;
    {$ENDIF}
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
    lRuntime.NotifyRunTransition(rstStopToView);
    lRegistry.DoUpdateData;
    if AManagedLifecycle then lRuntime.NotifyAll(PN_UPDATEDATA);
    lRegistry.DoStop;
    lRuntime.NotifyRunTransition(rstViewToStop);
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
    { Проверяем настоящие переходы автомата и отсутствие второго события
      от общего реестра как для старого, так и для нового маршрута V2. }
    if not ADestroyStatusFailure then begin
    lSecond := TRecorderPluginVisualComponent(
      lFactory.CreateComponentForPage(lCreateContext));
    try
      if AManagedLifecycle then begin
        lRuntime.NotifyAll(PN_RCINITIALIZED);
        Check(lFactory.SaveOpaqueComponentState(lSource)=rosSuccess,
          'cannot inspect first initialization order');
        Move(lSource.ConfigBlob[0],lState,SizeOf(lState));
        Check((lState.SurfaceReserved and $80000000)<>0,
          'first instance did not observe catalog before initialization');
        Check(lFactory.SaveOpaqueComponentState(lSecond)=rosSuccess,
          'cannot inspect second initialization order');
        Move(lSecond.ConfigBlob[0],lState,SizeOf(lState));
        Check((lState.SurfaceReserved and $80000000)<>0,
          'second instance did not observe catalog before initialization');
      end;
      lMachine := TRecorderStateMachine.Create;
      try
        lMachine.StartPreview(rscSignalLevel);
        Check((lMachine.State = rsPreviewArmed) and (lMachine.LastTransition = rstNone),
          'Stop to Armed must not start acquisition');
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.Stop;
        Check((lMachine.State = rsStop) and (lMachine.LastTransition = rstNone),
          'Armed to Stop must not emit stop');
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartPreview(rscManual);
        Check(lMachine.LastTransition = rstStopToView, 'Stop to Preview transition');
      lRegistry.DoStart;
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartRecord(rscManual);
        Check(lMachine.LastTransition = rstViewToRecord, 'Preview to Record transition');
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartPreview(rscManual);
        Check(lMachine.LastTransition = rstRecordToView, 'Record to Preview transition');
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.Stop;
        Check(lMachine.LastTransition = rstViewToStop, 'Preview to Stop transition');
      lRegistry.DoStop;
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartPreview(rscManual);
        lRegistry.DoStart;
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartRecord(rscSignalLevel);
        Check((lMachine.State = rsRecordArmed) and (lMachine.LastTransition = rstNone),
          'Preview to RecordArmed must not start recording');
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.Stop;
        Check(lMachine.LastTransition = rstViewToStop,
          'Preview to RecordArmed to Stop must stop preview');
        lRegistry.DoStop;
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartRecord(rscSignalLevel);
        Check((lMachine.State = rsRecordArmed) and (lMachine.LastTransition = rstNone),
          'Stop to RecordArmed must not start acquisition');
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.StartConditionMet;
        Check(lMachine.LastTransition = rstStopToRecord,
          'RecordArmed trigger must start recording');
        lRegistry.DoStart;
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
        lMachine.Stop;
        Check(lMachine.LastTransition = rstRecordToStop, 'Record to Stop transition');
        lRegistry.DoStop;
        lRuntime.NotifyRunTransition(lMachine.LastTransition);
      finally
        lMachine.Free;
      end;
      Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
        'cannot inspect first old V2 transition counters');
      Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
      Check((lState.StartCount = 6) and (lState.StopCount = 4),
        'first instance missed or duplicated transition events');
      if AManagedLifecycle then
        Check(lState.ErrorReserved = $12131323,
          'first instance received wrong start mode or event order');
      Check(lFactory.SaveOpaqueComponentState(lSecond) = rosSuccess,
        'cannot inspect second old V2 transition counters');
      Move(lSecond.ConfigBlob[0], lState, SizeOf(lState));
      Check((lState.StartCount = 5) and (lState.StopCount = 3),
        'second instance missed or duplicated transition events');
      if AManagedLifecycle then
        Check(lState.ErrorReserved = $12131323,
          'second instance received wrong start mode or event order');
    finally
      lFactory.ReleaseComponent(lSecond);
    end;
    Check(lFactory.SaveOpaqueComponentState(lSource) = rosSuccess,
      'cannot restore first instance probe snapshot');
    Move(lSource.ConfigBlob[0], lState, SizeOf(lState));
    end;
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
    if AProbePinnedServices then begin
      lPinnedModule:=GetModuleHandle(PChar(ExtractFileName(lPluginPath)));
      Check(lPinnedModule<>0,'pre-shutdown fixture module absent');
      Pointer(lProbeBorrowedServices):=GetProcAddress(lPinnedModule,'ProbeBorrowedServices');
      Check(Assigned(lProbeBorrowedServices),'borrowed services probe absent');
      Check(lProbeBorrowedServices(0)=REC_VISUAL_OK,
        'borrowed services failed before runtime shutdown');
    end;
    if ADestroyStatusFailure then
      Check(SetEnvironmentVariable('RECORDER_DESTROY_PROBE','error'),'destroy injection env');
    {$ENDIF}
    if AProbeInFlight then begin
      { Нативные окна отсоединены на UI-потоке до teardown worker. }
      Check(lView.Detach=REC_VISUAL_OK,'cannot detach first view for concurrency');
      Check(lSurvivingView.Detach=REC_VISUAL_OK,'cannot detach second view for concurrency');
      Pointer(lProbeLogService):=GetProcAddress(lPinnedModule,'ProbeLogService');
      Check(Assigned(lProbeLogService),'blocking callback probe absent');
      lInFlight:=TInFlightHarness.Create;
      lShutdownWorker:=nil; lObserveWorker:=nil;
      try
        lInFlight.Runtime:=lRuntime; lInFlight.Probe:=lProbeBorrowedServices;
        lRuntime.OnLogMessage:=@lInFlight.LogMessage;
        Check(lProbeLogService()=REC_VISUAL_OK,'reentrant callback probe failed');
        Check(lInFlight.ReentrantChecked,'runtime permits reentrant shutdown');
        Check(lRuntime.CanShutdown,'runtime stayed blocked after callback');
        lInFlight.Block:=True;
        lShutdownWorker:=TShutdownWorker.Create(True);
        lShutdownWorker.FreeOnTerminate:=False; lShutdownWorker.Harness:=lInFlight;
        lObserveWorker:=TObserveWorker.Create(True);
        lObserveWorker.FreeOnTerminate:=False; lObserveWorker.Harness:=lInFlight;
        lShutdownWorker.Start; lObserveWorker.Start;
        Check(lProbeLogService()=REC_VISUAL_OK,'blocking callback probe failed');
        lObserveWorker.WaitFor; lShutdownWorker.WaitFor;
        Check(lInFlight.Error='',lInFlight.Error);
        Check(lInFlight.ShutdownDone.WaitFor(0)=wrSignaled,'shutdown refusal did not finish');
        Check(lRuntime.TryBeginShutdown,'shutdown retry after callback failed');
        lRuntime.Free;
        lRuntime:=nil;
      finally
        lInFlight.ReleaseLog.SetEvent;
        lShutdownWorker.Free; lObserveWorker.Free; lInFlight.Free;
      end;
    end else begin
      {$IFDEF MSWINDOWS}
      if ACloseRetry then begin
        lExternalModule:=Windows.LoadLibrary(PChar(lPluginPath));
        Check(lExternalModule<>0,'cannot hold fixture for teardown counters');
        Pointer(lCloseCount):=GetProcAddress(lExternalModule,'ProbeCloseCount');
        Pointer(lPluginDestroyCount):=GetProcAddress(lExternalModule,'ProbePluginDestroyCount');
        Pointer(lWorkerStopCount):=GetProcAddress(lExternalModule,'ProbeWorkerStopCount');
        Pointer(lWorkerRunning):=GetProcAddress(lExternalModule,'ProbeWorkerRunning');
        Pointer(lVoidDestroyCount):=GetProcAddress(lExternalModule,'ProbeVoidDestroyCount');
        Pointer(lProbeBorrowedServices):=GetProcAddress(lExternalModule,'ProbeBorrowedServices');
        Pointer(lProbeLogService):=GetProcAddress(lExternalModule,'ProbeLogService');
        Check(Assigned(lCloseCount) and Assigned(lPluginDestroyCount) and
          Assigned(lWorkerStopCount) and Assigned(lWorkerRunning) and
          Assigned(lVoidDestroyCount) and Assigned(lProbeBorrowedServices) and
          Assigned(lProbeLogService),'close retry fixture exports missing');
        lInFlight:=TInFlightHarness.Create;
        try
          lInFlight.Runtime:=lRuntime;
          lRuntime.OnLogMessage:=@lInFlight.LogMessage;
          Check(lProbeLogService()=REC_VISUAL_OK,'active callback probe failed');
          Check(lInFlight.ReentrantChecked,'active callback shutdown was not refused');
          Check((lRuntime.LoadedCount=1) and lRegistry.IsComponentRegistered('test.stateful-visual'),
            'active callback refusal destroyed runtime');
        finally
          lRuntime.OnLogMessage:=nil;
          lInFlight.Free;
        end;
        lDestroyBefore:=lVoidDestroyCount();
        Check((lWorkerRunning()=1) and (lWorkerStopCount()=0),'fixture worker not active');
        Check(not lRuntime.TryBeginShutdown,'first plugin close should fail');
        Check((lCloseCount()=1) and (lPluginDestroyCount()=0) and
          (lVoidDestroyCount()=lDestroyBefore) and (lWorkerRunning()=1) and
          (lWorkerStopCount()=0),'close refusal destroyed state or worker');
        Check((lRuntime.LoadedCount=1) and lRegistry.IsComponentRegistered('test.stateful-visual')
          and (lProbeBorrowedServices(0)=REC_VISUAL_OK),'close refusal destroyed host services');
        Check(lRuntime.TryBeginShutdown,'second plugin close should succeed');
        Check((lCloseCount()=2) and (lWorkerStopCount()=1) and (lWorkerRunning()=0) and
          (lPluginDestroyCount()=0) and (lVoidDestroyCount()=lDestroyBefore),
          'successful close did not join worker before destruction');
        Check(lRuntime.TryBeginShutdown and (lCloseCount()=2),
          'successful close was not idempotent');
      end;
      {$ENDIF}
      lRuntime.Free;
      lRuntime := nil;
      {$IFDEF MSWINDOWS}
      if ACloseRetry then begin
        Check((lPluginDestroyCount()=1) and (lVoidDestroyCount()>lDestroyBefore),
          'successful shutdown did not destroy instances/plugin');
        Check(Windows.FreeLibrary(lExternalModule),'external fixture reference not released');
        lExternalModule:=0;
      end;
      {$ENDIF}
    end;
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
      if AProbePinnedServices then begin
        lPinnedProbeStatus:=lProbeBorrowedServices(1);
        Check(lPinnedProbeStatus=REC_VISUAL_OK,
          'pinned services did not safely refuse access after shutdown: '+
          IntToStr(lPinnedProbeStatus));
      end;
      Check(lCleanupFailedDestroy()=REC_VISUAL_OK,'fixture failed-instance cleanup');
      Check(lFailedDestroyCount()=0,'fixture leaked retained instance');
      if AProbePinnedServices and AManagedLifecycle then begin
        Pointer(lFinalizePinnedPlugin):=GetProcAddress(lPinnedModule,'ProbeFinalizePinnedPlugin');
        Check(Assigned(lFinalizePinnedPlugin) and
          (lFinalizePinnedPlugin()=REC_VISUAL_OK),'fixture managed plugin cleanup');
      end;
      Check(Windows.FreeLibrary(lPinnedModule),'fixture destroy-status pin cleanup');
      WriteLn('RESULT PluginVisualModelTest destroy status ERROR pin passed');
    end
    else Check(GetModuleHandle(PChar(ExtractFileName(lPluginPath)))=0,
      'normal/short-prefix destruction pinned module');
    {$ENDIF}
  finally
    {$IFDEF MSWINDOWS} lNativeHost.Free; {$ENDIF}
    {$IFDEF MSWINDOWS} SetEnvironmentVariable('RECORDER_DESTROY_PROBE',nil); {$ENDIF}
    {$IFDEF MSWINDOWS} SetEnvironmentVariable('RECORDER_CLOSE_PROBE',nil); {$ENDIF}
    {$IFDEF MSWINDOWS} if lExternalModule<>0 then Windows.FreeLibrary(lExternalModule); {$ENDIF}
    lRuntime.Free;
    lView.Free;
    lSurvivingView.Free;
    lRegistry.Free;
    lTagRegistry.Free;
    lPage.Free;
    if lCreatedConfig then SysUtils.DeleteFile(lConfigFileName);
    if lCreatedPlugin then SysUtils.DeleteFile(lPluginPath);
    if lCreatedDirectory then RemoveDir(lPluginDirectory);
  end;
  WriteLn('RESULT PluginVisualModelTest runtime cycle passed');
end;

{ Рискованный сценарий отказа плагина выполняется только в дочернем процессе:
  авария или зависание callback не повреждают основной процесс тестирования. }
procedure RunPinnedServicesChild(const APluginFileName:string; AManaged:Boolean;
  AInFlight:Boolean=False; AInFlightSuccess:Boolean=False; ACloseRetry:Boolean=False;
  AInitFail:Boolean=False);
var p:TProcess; lDeadline:QWord;
begin
  p:=TProcess.Create(nil);
  try
    p.Executable:=ParamStr(0);
    p.Parameters.Add(APluginFileName);
    if AInitFail then p.Parameters.Add('initfail-child')
    else if ACloseRetry then p.Parameters.Add('close-retry-child')
    else if AInFlightSuccess then p.Parameters.Add('inflight-success-child')
    else if AInFlight then p.Parameters.Add('inflight-child')
    else p.Parameters.Add('pinned-services-child');
    if AManaged then p.Parameters.Add('managed');
    p.Options:=[poNoConsole];
    p.Execute;
    lDeadline:=GetTickCount64+15000;
    while p.Running and (GetTickCount64<lDeadline) do Sleep(10);
    if p.Running then begin
      p.Terminate(1);
      raise Exception.Create('pinned-services child timed out');
    end;
    Check(p.ExitStatus=0,'pinned-services child failed: '+IntToStr(p.ExitStatus));
  finally p.Free; end;
end;

begin
  try
    if ParamCount > 0 then
    begin
      Application.Initialize;
      Application.ShowMainForm := False;
    end;
    if (ParamCount>1) and (ParamStr(2)='pinned-services-child') then begin
      RunRuntimeTests(ParamStr(1),False,True,
        (ParamCount>2) and (ParamStr(3)='managed'),True);
      WriteLn('RESULT pinned services child passed');
      Exit;
    end;
    if (ParamCount>1) and (ParamStr(2)='inflight-child') then begin
      RunRuntimeTests(ParamStr(1),False,True,True,True,True);
      WriteLn('RESULT inflight gateway child passed');
      Exit;
    end;
    if (ParamCount>1) and (ParamStr(2)='inflight-success-child') then begin
      RunRuntimeTests(ParamStr(1),False,False,True,True,True);
      WriteLn('RESULT inflight successful unload child passed');
      Exit;
    end;
    if (ParamCount>1) and (ParamStr(2)='close-retry-child') then begin
      RunRuntimeTests(ParamStr(1),False,False,True,False,False,True);
      WriteLn('RESULT PluginClose refusal/retry and worker join passed');
      Exit;
    end;
    if (ParamCount>1) and (ParamStr(2)='initfail-child') then begin
      RunRuntimeTests(ParamStr(1),False,False,True,False,False,False,True);
      Exit;
    end;
    RunTests;
    if ParamCount > 0 then
    begin
      if (ParamCount > 1) and (ParamStr(2) = 'managed') then
      begin
        RunRuntimeTests(ParamStr(1),False,False,True);
        {$IFDEF MSWINDOWS} RunPinnedServicesChild(ParamStr(1),True); {$ENDIF}
        {$IFDEF MSWINDOWS} RunPinnedServicesChild(ParamStr(1),True,True); {$ENDIF}
        {$IFDEF MSWINDOWS} RunPinnedServicesChild(ParamStr(1),True,True,True); {$ENDIF}
        {$IFDEF MSWINDOWS} RunPinnedServicesChild(ParamStr(1),True,False,False,True); {$ENDIF}
        {$IFDEF MSWINDOWS} RunPinnedServicesChild(ParamStr(1),True,False,False,False,True); {$ENDIF}
      end
      else begin
        RunRuntimeTests(ParamStr(1));
        RunRuntimeTests(ParamStr(1));
        {$IFDEF MSWINDOWS} RunRuntimeTests(ParamStr(1), True); {$ENDIF}
        {$IFDEF MSWINDOWS} RunRuntimeTests(ParamStr(1),False,True); {$ENDIF}
        {$IFDEF MSWINDOWS} RunPinnedServicesChild(ParamStr(1),False); {$ENDIF}
      end;
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
