program RecorderDacLifecycleTest;

{ Runs the real DAC factory/runtime/provider/worker with a counting wrapper
  around the null backend. No native audio driver or hardware is opened. }

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, Forms, Classes, SysUtils, Math, uRecorderTags, uRecorderBlockClock,
  uRecorderDacTypes, uRecorderDacContracts, uRecorderNullDacBackend,
  uRecorderDacComponentModel;

type
  TBackendCounts = record
    Connects, Initializes, Configures, Starts, Stops, Disconnects: Integer;
    ZeroBlocks, SignalBlocks, RisingEdges: Integer;
    ConfiguredRate: Double;
  end;

  TBackendProbe = class
  private
    fLock: TRTLCriticalSection;
    fCounts: TBackendCounts;
    fPreviousValue: Double;
    fRegistry: TRecorderTagRegistry;
    fFeedback: TRecorderTag;
    fNextFeedbackTime: Double;
    procedure PublishFeedback(ABuffer: PDouble; ACount: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure NoteStage(AStage: TRecorderDacStage);
    procedure NoteBlock(ABuffer: PDouble; ACount: Integer);
    procedure NoteRate(ARate: Double);
    function Snapshot: TBackendCounts;
    procedure AttachFeedback(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
    procedure PublishQuietFeedback;
  end;

  TCountingBackend = class(TInterfacedObject, IRecorderDacBackend)
  private
    fInner: IRecorderDacBackend;
    fProbe: TBackendProbe;
  public
    constructor Create(AProbe: TBackendProbe);
    function BackendId: string;
    function Endpoint: string;
    function State: TRecorderDacState;
    function Connect(out AResult: TRecorderDacResult): Boolean;
    function Initialize(out AResult: TRecorderDacResult): Boolean;
    function ReadProperties(out AResult: TRecorderDacResult): Boolean;
    function SampleRateHz: Double;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function Start(out AResult: TRecorderDacResult): Boolean;
    function SubmitBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function Stop(out AResult: TRecorderDacResult): Boolean;
    procedure Abort;
    function Disconnect(out AResult: TRecorderDacResult): Boolean;
  end;

  TCountingFactory = class(TRecorderDacBackendFactory)
  private
    fProbe: TBackendProbe;
  public
    constructor Create(AProbe: TBackendProbe);
    function BackendId: string; override;
    function DiscoverEndpoints(out AEndpoints: TRecorderDacEndpoints;
      out AResult: TRecorderDacResult): Boolean; override;
    function CreateBackend(const AEndpoint: string): IRecorderDacBackend; override;
  end;

  TFixture = class
  public
    Probe: TBackendProbe;
    Factory: TRecorderDacComponentFactory;
    Registry: TRecorderTagRegistry;
    Model: TRecorderDacComponent;
    Runtime: IRecorderDacComponentRuntime;
    constructor Create(AStartOnPreview: Boolean);
    destructor Destroy; override;
    procedure PumpFor(AMilliseconds: QWord);
    procedure AwaitBlocks(AZeroBlocks, ASignalBlocks: Integer);
    procedure AwaitClosed;
    procedure EnableFeedback(AMode: TRecorderDacPhaseCalibrationMode);
    procedure AwaitCalibration(APlaying: Boolean);
  end;

var
  gLog: TStringList;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
  gLog.Add('PASS ' + AMessage);
end;

constructor TBackendProbe.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
end;

destructor TBackendProbe.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

procedure TBackendProbe.NoteStage(AStage: TRecorderDacStage);
begin
  EnterCriticalSection(fLock);
  try
    case AStage of
      rdsgConnect: Inc(fCounts.Connects);
      rdsgInitialize: Inc(fCounts.Initializes);
      rdsgConfigure: Inc(fCounts.Configures);
      rdsgStart: Inc(fCounts.Starts);
      rdsgStop: Inc(fCounts.Stops);
      rdsgDisconnect: Inc(fCounts.Disconnects);
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TBackendProbe.NoteBlock(ABuffer: PDouble; ACount: Integer);
var
  lIndex: Integer;
  lNonzero: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    lNonzero := False;
    for lIndex := 0 to ACount - 1 do
    begin
      if Abs(ABuffer[lIndex]) > 1E-9 then lNonzero := True;
      if (fPreviousValue <= 0) and (ABuffer[lIndex] > 0) then Inc(fCounts.RisingEdges);
      fPreviousValue := ABuffer[lIndex];
    end;
    if lNonzero then Inc(fCounts.SignalBlocks) else Inc(fCounts.ZeroBlocks);
    PublishFeedback(ABuffer, ACount);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TBackendProbe.AttachFeedback(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag);
begin
  EnterCriticalSection(fLock);
  try
    fRegistry := ARegistry;
    fFeedback := ATag;
    fNextFeedbackTime := RecorderClockSeconds;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TBackendProbe.PublishFeedback(ABuffer: PDouble; ACount: Integer);
var
  lTimes, lValues: array[0..19] of Double;
  I: Integer;
begin
  if (fFeedback = nil) or (fRegistry = nil) then Exit;
  if (ACount < 1) or (ACount > Length(lTimes)) then
    raise Exception.Create('Synthetic feedback expects at most twenty frames');
  for I := 0 to ACount - 1 do
  begin
    lTimes[I] := fNextFeedbackTime;
    { Exact synthetic loopback of the production waveform: raised-cosine
      calibration bells, then the selected work signal. No independent marker
      shape or threshold is reproduced in this fixture. }
    lValues[I] := ABuffer[I];
    fNextFeedbackTime := fNextFeedbackTime + 1 / fFeedback.PollFrequencyHz;
  end;
  fRegistry.AddBlockSamples(fFeedback, lTimes, lValues, ACount, True);
end;

procedure TBackendProbe.PublishQuietFeedback;
var
  lZeros: array[0..19] of Double;
begin
  EnterCriticalSection(fLock);
  try
    if fCounts.Starts > fCounts.Stops then Exit;
    FillChar(lZeros, SizeOf(lZeros), 0);
    PublishFeedback(@lZeros[0], Length(lZeros));
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TBackendProbe.Snapshot: TBackendCounts;
begin
  EnterCriticalSection(fLock);
  try Result := fCounts;
  finally LeaveCriticalSection(fLock) end;
end;

procedure TBackendProbe.NoteRate(ARate: Double);
begin
  EnterCriticalSection(fLock);
  try fCounts.ConfiguredRate := ARate;
  finally LeaveCriticalSection(fLock) end;
end;

constructor TCountingBackend.Create(AProbe: TBackendProbe);
begin
  inherited Create;
  fProbe := AProbe;
  fInner := TRecorderNullDacBackend.Create('counting-null');
end;

function TCountingBackend.BackendId: string;
begin Result := 'test.lifecycle'; end;
function TCountingBackend.Endpoint: string;
begin Result := 'counting-null'; end;
function TCountingBackend.State: TRecorderDacState;
begin Result := fInner.State; end;
function TCountingBackend.SampleRateHz: Double;
begin Result := fInner.SampleRateHz; end;
function TCountingBackend.ReadProperties(out AResult: TRecorderDacResult): Boolean;
begin Result := fInner.ReadProperties(AResult); end;
function TCountingBackend.Connect(out AResult: TRecorderDacResult): Boolean;
begin Result := fInner.Connect(AResult); if Result then fProbe.NoteStage(rdsgConnect); end;
function TCountingBackend.Initialize(out AResult: TRecorderDacResult): Boolean;
begin Result := fInner.Initialize(AResult); if Result then fProbe.NoteStage(rdsgInitialize); end;
function TCountingBackend.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := fInner.Configure(AConfig, AResult);
  if Result then
  begin
    fProbe.NoteStage(rdsgConfigure);
    fProbe.NoteRate(AConfig.SampleRateHz);
  end;
end;
function TCountingBackend.Start(out AResult: TRecorderDacResult): Boolean;
begin Result := fInner.Start(AResult); if Result then fProbe.NoteStage(rdsgStart); end;
function TCountingBackend.SubmitBlock(ABuffer: PDouble; AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := fInner.SubmitBlock(ABuffer, AFrameCount, AResult);
  if Result then fProbe.NoteBlock(ABuffer, AFrameCount);
  { Simulate the native blocking write of a 20 ms hardware block. }
  Sleep(20);
end;
function TCountingBackend.Stop(out AResult: TRecorderDacResult): Boolean;
begin Result := fInner.Stop(AResult); if Result then fProbe.NoteStage(rdsgStop); end;
procedure TCountingBackend.Abort;
begin fInner.Abort; end;
function TCountingBackend.Disconnect(out AResult: TRecorderDacResult): Boolean;
begin Result := fInner.Disconnect(AResult); if Result then fProbe.NoteStage(rdsgDisconnect); end;

constructor TCountingFactory.Create(AProbe: TBackendProbe);
begin inherited Create; fProbe := AProbe; end;
function TCountingFactory.BackendId: string;
begin Result := 'test.lifecycle'; end;
function TCountingFactory.DiscoverEndpoints(out AEndpoints: TRecorderDacEndpoints;
  out AResult: TRecorderDacResult): Boolean;
begin
  SetLength(AEndpoints, 1);
  AEndpoints[0].BackendId := BackendId;
  AEndpoints[0].Endpoint := 'counting-null';
  AEndpoints[0].DisplayName := 'Synthetic physical DAC';
  AEndpoints[0].SampleRateHz := 1000;
  AResult := RecorderDacOk;
  Result := True;
end;
function TCountingFactory.CreateBackend(const AEndpoint: string): IRecorderDacBackend;
begin Result := TCountingBackend.Create(fProbe); end;

constructor TFixture.Create(AStartOnPreview: Boolean);
begin
  inherited Create;
  Probe := TBackendProbe.Create;
  Registry := TRecorderTagRegistry.Create;
  Factory := TRecorderDacComponentFactory.Create;
  Factory.RegisterBackend(TCountingFactory.Create(Probe));
  Model := TRecorderDacComponent(Factory.CreateComponent);
  Model.Name := 'LifecycleDac';
  Model.BackendId := 'test.lifecycle';
  Model.Endpoint := 'counting-null';
  Model.SampleRateHz := 1000;
  Model.FramesPerBlock := 20;
  Model.FrequencyHz := 10;
  Model.Amplitude := 0.05;
  Model.SourceMode := rdsmSine;
  Model.SynchronizeByFeedback := False;
  Model.StartStreamOnPreview := AStartOnPreview;
  Model.MirrorEnabled := True;
  Factory.SetTagRegistry(Registry);
  Runtime := Factory.RuntimeFor(Model);
end;

destructor TFixture.Destroy;
begin
  if Runtime <> nil then
  begin
    Runtime.LeavePreview;
    PumpFor(100);
  end;
  Runtime := nil;
  Factory.Free;
  Registry.Free;
  Probe.Free;
  inherited Destroy;
end;

procedure TFixture.PumpFor(AMilliseconds: QWord);
var
  lDeadline: QWord;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lDeadline := GetTickCount64 + AMilliseconds;
  repeat
    Probe.PublishQuietFeedback;
    Application.ProcessMessages;
    lSnapshot := Runtime.Snapshot;
    Sleep(5);
  until GetTickCount64 >= lDeadline;
end;

procedure TFixture.EnableFeedback(AMode: TRecorderDacPhaseCalibrationMode);
var
  lTag: TRecorderTag;
begin
  lTag := Registry.CreateTag('Synthetic AI', 12000, False);
  lTag.PollFrequencyHz := 1000;
  lTag.BlockTimeDomain := btRecorderMonotonic;
  lTag.SignalBuffer.ConfigureBlockRing(20, 16);
  Probe.AttachFeedback(Registry, lTag);
  Probe.PublishQuietFeedback;
  Model.FeedbackTagId := lTag.Id;
  Model.FeedbackTagName := lTag.Name;
  Model.SynchronizeByFeedback := True;
  Model.PhaseCalibrationMode := AMode;
  Model.FeedbackCalibrationDurationSec := 0.8;
  Model.FeedbackTimeoutSec := 3;
end;

procedure TFixture.AwaitCalibration(APlaying: Boolean);
var
  lDeadline: QWord;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lDeadline := GetTickCount64 + 4000;
  repeat
    PumpFor(10);
    lSnapshot := Runtime.Snapshot;
    if lSnapshot.CalibrationValid and not lSnapshot.CalibrationRunning and
      (lSnapshot.OutputPlaying = APlaying) then
    begin
      Check(Abs(lSnapshot.CalibrationEdgeSec - lSnapshot.CalibrationStartSec - 0.11) < 1E-6,
        'Synthetic loopback aligns DAC sample zero from the bell peak at 110 ms');
      Check(Abs(lSnapshot.CalibrationSecondEdgeSec - lSnapshot.CalibrationEdgeSec - 0.4) < 1E-6,
        'Synthetic loopback measures the interval between the two bell maxima');
      Check(Abs(lSnapshot.CalibrationSampleRateHz - 1000) < 0.001,
        'Bell maxima preserve effective sample rate in the runtime loopback');
      Check(Abs(lSnapshot.CalibrationRateFactor -
        lSnapshot.CalibrationSampleRateHz / 1000) < 1E-9,
        'Visible calibration k equals effective rate divided by nominal backend rate');
      Check(Abs(lSnapshot.CalibrationRateFactor -
        (1 + lSnapshot.CalibrationDriftPpm * 1E-6)) < 1E-12,
        'Visible calibration k agrees with the measured clock drift');
      Check((lSnapshot.CalibrationCorrelationFirst > 0.99) and
        (lSnapshot.CalibrationCorrelationSecond > 0.99),
        'Runtime exposes normalized shape correlation for both loopback bells');
      Exit;
    end;
    if not (lSnapshot.LastResult.Error in [rdeNone, rdeCompleted]) then
      raise Exception.Create('Calibration lifecycle failed: ' + lSnapshot.LastResult.Text);
  until GetTickCount64 >= lDeadline;
  raise Exception.CreateFmt('Calibration lifecycle timed out: state=%s peaks=%d error=%s',
    [lSnapshot.CalibrationStateText, lSnapshot.CalibrationDetectedEdges,
      lSnapshot.LastResult.Text]);
end;

procedure TFixture.AwaitBlocks(AZeroBlocks, ASignalBlocks: Integer);
var
  lDeadline: QWord;
  lCounts: TBackendCounts;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lDeadline := GetTickCount64 + 3000;
  repeat
    PumpFor(10);
    lCounts := Probe.Snapshot;
    if (lCounts.ZeroBlocks >= AZeroBlocks) and (lCounts.SignalBlocks >= ASignalBlocks) then Exit;
  until GetTickCount64 >= lDeadline;
  lSnapshot := Runtime.Snapshot;
  raise Exception.CreateFmt('Timed out waiting for blocks zero=%d/%d signal=%d/%d: %s',
    [lCounts.ZeroBlocks, AZeroBlocks, lCounts.SignalBlocks, ASignalBlocks, lSnapshot.LastResult.Text]);
end;

procedure TFixture.AwaitClosed;
var
  lDeadline: QWord;
  lCounts: TBackendCounts;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lDeadline := GetTickCount64 + 3000;
  repeat
    PumpFor(10);
    lCounts := Probe.Snapshot;
    lSnapshot := Runtime.Snapshot;
    if (lCounts.Stops >= 1) and (lCounts.Disconnects >= 1) and
      (lSnapshot.State = rdsClosed) then Exit;
  until GetTickCount64 >= lDeadline;
  raise Exception.CreateFmt('LeavePreview did not close stream: stops=%d disconnects=%d state=%d',
    [lCounts.Stops, lCounts.Disconnects, Ord(lSnapshot.State)]);
end;

procedure TestPersistentPreviewStream;
var
  lFixture: TFixture;
  lCounts, lBefore: TBackendCounts;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.Factory.EnterPreview;
    lFixture.AwaitBlocks(3, 0);
    lCounts := lFixture.Probe.Snapshot;
    lSnapshot := lFixture.Runtime.Snapshot;
    Check((lCounts.Connects = 1) and (lCounts.Initializes = 1) and
      (lCounts.Configures = 1) and (lCounts.Starts = 1), 'Preview opens/initializes/configures/starts once');
    Check((lCounts.SignalBlocks = 0) and not lSnapshot.OutputPlaying,
      'Preview stream submits silence and does not claim playback');
    lFixture.Factory.DoStart;
    lFixture.Factory.DoStop;
    lFixture.PumpFor(80);
    lCounts := lFixture.Probe.Snapshot;
    Check((lCounts.Starts = 1) and (lCounts.Stops = 0) and (lCounts.Disconnects = 0),
      'Record transitions leave the Preview stream untouched');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(3, 3);
    Check(lFixture.Runtime.Snapshot.OutputPlaying, 'Play enables output on the existing stream');
    lBefore := lFixture.Probe.Snapshot;
    lFixture.Runtime.StopOutput;
    lFixture.AwaitBlocks(lBefore.ZeroBlocks + 3, lBefore.SignalBlocks);
    lCounts := lFixture.Probe.Snapshot;
    Check(not lFixture.Runtime.Snapshot.OutputPlaying, 'Stop mutes the signal');
    Check((lCounts.Starts = 1) and (lCounts.Stops = 0) and (lCounts.Disconnects = 0),
      'Stop sends zeros without stopping/closing the backend');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(lCounts.ZeroBlocks, lCounts.SignalBlocks + 3);
    Check(lFixture.Probe.Snapshot.Starts = 1, 'Second Play does not restart the backend');
    lFixture.Model.FrequencyHz := 50;
    lBefore := lFixture.Probe.Snapshot;
    lFixture.Runtime.ApplyOutputSettings;
    lFixture.PumpFor(350);
    lCounts := lFixture.Probe.Snapshot;
    Check((lCounts.Starts = 1) and (lCounts.Configures = 1) and (lCounts.Stops = 0),
      'Frequency edit replaces provider without driver reconfigure/restart');
    Check(lCounts.RisingEdges - lBefore.RisingEdges >= 8,
      'Replacement provider produces the faster waveform');
    lFixture.Factory.LeavePreview;
    lFixture.AwaitClosed;
    lSnapshot := lFixture.Runtime.Snapshot;
    Check(not lSnapshot.OutputPlaying and not lSnapshot.CalibrationValid,
      'LeavePreview closes stream and invalidates output/calibration state');
  finally
    lFixture.Free;
  end;
end;

procedure TestPlayStartedStream;
var
  lFixture: TFixture;
  lCounts: TBackendCounts;
begin
  lFixture := TFixture.Create(False);
  try
    lFixture.Factory.EnterPreview;
    lFixture.PumpFor(150);
    lCounts := lFixture.Probe.Snapshot;
    Check((lCounts.Connects = 0) and (lCounts.Starts = 0),
      'Play-start mode does not open a stream on EnterPreview');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(0, 3);
    Check(lFixture.Probe.Snapshot.Starts = 1, 'Play-start mode opens the stream on Play');
    lFixture.Factory.LeavePreview;
    lFixture.AwaitClosed;
    Check(not lFixture.Runtime.Snapshot.OutputPlaying,
      'Play-start mode closes on LeavePreview');
  finally
    lFixture.Free;
  end;
end;

procedure TestStopCancelsPendingFeedback;
var
  lFixture: TFixture;
  lFeedback: TRecorderTag;
  lTime, lValue: array[0..19] of Double;
  lIndex: Integer;
  lNow: Double;
begin
  lFixture := TFixture.Create(True);
  try
    lFeedback := lFixture.Registry.CreateTag('Feedback', 4096, False);
    lFeedback.PollFrequencyHz := 1000;
    lFeedback.BlockTimeDomain := btRecorderMonotonic;
    lFeedback.SignalBuffer.ConfigureBlockRing(20, 8);
    lFixture.Model.FeedbackTagId := lFeedback.Id;
    lFixture.Model.FeedbackTagName := lFeedback.Name;
    lFixture.Model.SynchronizeByFeedback := True;
    lFixture.Factory.EnterPreview;
    lFixture.PumpFor(80);
    Check(lFixture.Runtime.Snapshot.CalibrationRunning,
      'Synced Preview waits for fresh feedback before opening the backend');
    Check(lFixture.Probe.Snapshot.Starts = 0, 'Pending feedback has not started the backend');
    lFixture.Runtime.StopOutput;
    lNow := RecorderClockSeconds;
    for lIndex := 0 to High(lTime) do
    begin
      lTime[lIndex] := lNow + lIndex / 1000.0;
      lValue[lIndex] := 0;
    end;
    lFixture.Registry.AddBlockSamples(lFeedback, lTime, lValue, Length(lTime), True);
    lFixture.Registry.PublishBlockNotifications(lFeedback, lTime, lValue, Length(lTime));
    lFixture.PumpFor(180);
    Check((lFixture.Probe.Snapshot.Starts = 0) and
      (lFixture.Probe.Snapshot.Connects = 0),
      'Stop cancels the pending timer: later fresh feedback cannot start DAC');
    Check(not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Canceled feedback wait leaves no hidden calibration request');
    lFixture.Runtime.StartOutput;
    lFixture.PumpFor(120);
    Check((lFixture.Probe.Snapshot.Starts = 0) and
      not lFixture.Runtime.Snapshot.CalibrationRunning and
      (lFixture.Runtime.Snapshot.LastResult.Error = rdeInvalidState),
      'Measurement-start mode Play cannot implicitly recalibrate after cancellation');
  finally
    lFixture.Free;
  end;
end;

procedure TestCalibrationRejectedAfterLeavePreview;
var
  lFixture: TFixture;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.Factory.EnterPreview;
    lFixture.AwaitBlocks(3, 0);
    lFixture.Factory.LeavePreview;
    { Intentionally do not wait for the old runner to finish. }
    lFixture.Runtime.StartCalibration;
    lFixture.AwaitClosed;
    lSnapshot := lFixture.Runtime.Snapshot;
    Check(lFixture.Probe.Snapshot.Starts = 1,
      'Calibration after LeavePreview cannot queue a new stream behind a stopping runner');
    Check(not lSnapshot.CalibrationRunning,
      'Calibration outside Preview leaves no pending request after cleanup');
    Check(lSnapshot.LastResult.Error = rdeInvalidState,
      'Cleanup preserves the calibration-outside-Preview diagnostic');
  finally
    lFixture.Free;
  end;
end;

procedure TestMutedConfigurationChange;
var
  lFixture: TFixture;
  lCounts: TBackendCounts;
  lSnapshot: TRecorderDacRuntimeSnapshot;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.Factory.EnterPreview;
    lFixture.AwaitBlocks(3, 0);
    Check(not lFixture.Runtime.Snapshot.OutputPlaying,
      'Configuration test starts from a muted persistent stream');
    lFixture.Model.SampleRateHz := 2000;
    lSnapshot := lFixture.Runtime.Snapshot;
    Check(not lSnapshot.CalibrationValid and not lSnapshot.OutputPlaying,
      'Device configuration change immediately invalidates calibration/output');
    Check(lSnapshot.LastResult.Error = rdeInvalidConfig,
      'Cleanup preserves the muted-configuration-change diagnostic');
    lFixture.AwaitClosed;
    lCounts := lFixture.Probe.Snapshot;
    Check((lCounts.Starts = 1) and (lCounts.Disconnects = 1),
      'Muted stream is closed rather than silently retaining obsolete driver settings');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(lCounts.ZeroBlocks, lCounts.SignalBlocks + 3);
    lCounts := lFixture.Probe.Snapshot;
    Check((lCounts.Starts = 2) and (lCounts.Configures = 2) and
      (Abs(lCounts.ConfiguredRate - 2000) < 1E-9),
      'Next Play creates one new stream with the changed sampling configuration');
    lFixture.Factory.LeavePreview;
    lFixture.AwaitClosed;
  finally
    lFixture.Free;
  end;
end;

procedure TestDisableCancelsPendingFeedback;
var
  lFixture: TFixture;
  lFeedback: TRecorderTag;
  lTime, lValue: array[0..19] of Double;
  lIndex: Integer;
  lNow: Double;
begin
  lFixture := TFixture.Create(True);
  try
    lFeedback := lFixture.Registry.CreateTag('DisableFeedback', 4096, False);
    lFeedback.PollFrequencyHz := 1000;
    lFeedback.BlockTimeDomain := btRecorderMonotonic;
    lFeedback.SignalBuffer.ConfigureBlockRing(20, 8);
    lFixture.Model.FeedbackTagId := lFeedback.Id;
    lFixture.Model.FeedbackTagName := lFeedback.Name;
    lFixture.Model.SynchronizeByFeedback := True;
    lFixture.Factory.EnterPreview;
    lFixture.PumpFor(80);
    Check(lFixture.Runtime.Snapshot.CalibrationRunning,
      'Disable test starts with the synced Preview timer pending');
    lFixture.Model.Enabled := False;
    lNow := RecorderClockSeconds;
    for lIndex := 0 to High(lTime) do
    begin
      lTime[lIndex] := lNow + lIndex / 1000.0;
      lValue[lIndex] := 0;
    end;
    lFixture.Registry.AddBlockSamples(lFeedback, lTime, lValue, Length(lTime), True);
    lFixture.Registry.PublishBlockNotifications(lFeedback, lTime, lValue, Length(lTime));
    lFixture.PumpFor(180);
    Check((lFixture.Probe.Snapshot.Starts = 0) and
      (lFixture.Probe.Snapshot.Connects = 0),
      'Disabling while pending prevents fresh feedback from opening DAC');
    Check(not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Disabled component has no pending calibration timer');
  finally
    lFixture.Free;
  end;
end;

procedure TestHiddenMutedConfigurationChange;
var
  lFixture: TFixture;
  lDeadline: QWord;
  lCounts: TBackendCounts;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.Factory.EnterPreview;
    lFixture.AwaitBlocks(3, 0);
    lFixture.Model.SampleRateHz := 2000;
    lDeadline := GetTickCount64 + 1500;
    repeat
      { A hidden component does not call Runtime.Snapshot. Only the existing
        production lifecycle timer may notice and retire this old stream. }
      Application.ProcessMessages;
      Sleep(5);
      lCounts := lFixture.Probe.Snapshot;
      if (lCounts.Stops = 1) and (lCounts.Disconnects = 1) then Break;
    until GetTickCount64 >= lDeadline;
    Check((lCounts.Stops = 1) and (lCounts.Disconnects = 1),
      'Hidden muted stream retires obsolete settings through its timer without snapshots');
  finally
    lFixture.Free;
  end;
end;

procedure TestMeasurementCalibrationMode;
var
  lFixture: TFixture;
  lBefore: TBackendCounts;
begin
  lFixture := TFixture.Create(False);
  try
    lFixture.EnableFeedback(rdpcmMeasurementStart);
    lFixture.Factory.EnterPreview;
    Check(lFixture.Runtime.Snapshot.CalibrationRunning,
      'Measurement-start mode automatically requests phase calibration');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitCalibration(True);
    Check(lFixture.Probe.Snapshot.Starts = 1,
      'Play queued during measurement-start calibration keeps one native/calibration run');
    lBefore := lFixture.Probe.Snapshot;
    lFixture.Factory.DoStart;
    lFixture.Factory.DoStop;
    lFixture.PumpFor(100);
    Check(lFixture.Probe.Snapshot.Starts = lBefore.Starts,
      'Record and Preview transitions inside acquisition do not recalibrate');
    lFixture.Runtime.StopOutput;
    lFixture.PumpFor(100);
    lFixture.Runtime.StartOutput;
    lFixture.PumpFor(100);
    Check(lFixture.Probe.Snapshot.Starts = 1,
      'Measurement-start mode later Play uses the calibrated stream immediately');
  finally
    lFixture.Free;
  end;
end;

procedure TestPlayCalibrationMode;
var
  lFixture: TFixture;
  lBefore: TBackendCounts;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.EnableFeedback(rdpcmPlay);
    lFixture.Factory.EnterPreview;
    lFixture.PumpFor(100);
    Check((lFixture.Probe.Snapshot.Starts = 0) and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'On-Play mode does not start calibration or native output in Preview');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitCalibration(True);
    Check(lFixture.Probe.Snapshot.Starts = 1, 'First actual Play starts one calibrated native run');
    lFixture.Runtime.StopOutput;
    lFixture.PumpFor(100);
    lFixture.Runtime.StartOutput;
    lFixture.AwaitCalibration(True);
    Check((lFixture.Probe.Snapshot.Starts = 2) and (lFixture.Probe.Snapshot.Stops = 1),
      'Second actual Play requests a fresh calibration and native run');
    lBefore := lFixture.Probe.Snapshot;
    lFixture.Model.FrequencyHz := 50;
    lFixture.Runtime.ApplyOutputSettings;
    lFixture.PumpFor(300);
    Check((lFixture.Probe.Snapshot.Starts = lBefore.Starts) and
      (lFixture.Probe.Snapshot.Configures = lBefore.Configures) and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Frequency edits in On-Play mode do not impersonate a new Play/calibration gesture');
    Check(lFixture.Probe.Snapshot.RisingEdges - lBefore.RisingEdges >= 8,
      'On-Play parameter edit applies the prepared replacement waveform');
  finally
    lFixture.Free;
  end;
end;

procedure TestManualCalibrationMode;
var
  lFixture: TFixture;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.EnableFeedback(rdpcmButton);
    lFixture.Factory.EnterPreview;
    lFixture.PumpFor(100);
    Check(lFixture.Probe.Snapshot.Starts = 0, 'Manual mode never auto-starts in Preview');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(0, 3);
    Check(not lFixture.Runtime.Snapshot.CalibrationValid and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Manual Play before the calibration button uses the nominal clock');
    lFixture.Runtime.StartCalibration;
    lFixture.AwaitCalibration(True);
    Check(lFixture.Probe.Snapshot.Starts = 2,
      'Explicit manual calibration while playing restarts and resumes playback');
    lFixture.Runtime.StopOutput;
    lFixture.PumpFor(100);
    lFixture.Runtime.StartOutput;
    lFixture.PumpFor(100);
    Check(lFixture.Probe.Snapshot.Starts = 2,
      'Manual Play after calibration reuses its measured clock');
    lFixture.Runtime.StopOutput;
    lFixture.PumpFor(100);
    lFixture.Runtime.StartCalibration;
    lFixture.AwaitCalibration(False);
    Check((lFixture.Probe.Snapshot.Starts = 3) and
      not lFixture.Runtime.Snapshot.OutputPlaying,
      'Explicit manual calibration while muted remains muted after completion');
  finally
    lFixture.Free;
  end;
end;

procedure TestManualNominalWithoutFeedback;
var
  lFixture: TFixture;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.Model.SynchronizeByFeedback := True;
    lFixture.Model.PhaseCalibrationMode := rdpcmButton;
    lFixture.Factory.EnterPreview;
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(0, 3);
    Check((lFixture.Probe.Snapshot.Starts = 1) and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Manual nominal Play is allowed without a feedback tag despite Sync checkbox');
  finally
    lFixture.Free;
  end;
end;

procedure TestModeChangeCancelsPendingCalibration;
var
  lFixture: TFixture;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.EnableFeedback(rdpcmMeasurementStart);
    lFixture.Factory.EnterPreview;
    lFixture.Model.PhaseCalibrationMode := rdpcmButton;
    lFixture.Runtime.ApplyOutputSettings;
    lFixture.PumpFor(100);
    Check((lFixture.Probe.Snapshot.Starts = 0) and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Changing the radio mode cancels an obsolete pending calibration');
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(0, 3);
    Check((lFixture.Probe.Snapshot.Starts = 1) and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'New manual Play after pending-mode change starts nominally');
  finally
    lFixture.Free;
  end;
end;

procedure TestManualRateFactor;
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacRuntimeSnapshot;
  lBefore: TBackendCounts;
  lDeadline: QWord;
  lMirrorTag: TRecorderTag;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.EnableFeedback(rdpcmPlay);
    lFixture.Factory.EnterPreview;
    lFixture.Runtime.StartOutput;
    lFixture.AwaitCalibration(True);
    lBefore := lFixture.Probe.Snapshot;
    Check(lFixture.Runtime.SetRateFactor(1.002, lResult), 'Manual k command accepted for calibrated stream');
    lDeadline := GetTickCount64 + 2000;
    repeat
      lFixture.PumpFor(10);
      lSnapshot := lFixture.Runtime.Snapshot;
    until (not lSnapshot.CalibrationRatePending and lSnapshot.CalibrationManualRate) or
      (GetTickCount64 >= lDeadline);
    Check(lSnapshot.CalibrationManualRate and not lSnapshot.CalibrationRatePending and
      (Abs(lSnapshot.CalibrationRateFactor - 1.002) < 1E-9),
      'Publisher acknowledges manual k instead of displaying a pending request as committed');
    Check(Abs(lSnapshot.CalibrationSampleRateHz - 1002) < 1E-6,
      'Manual k changes effective rate while hardware stays nominal');
    lMirrorTag := lFixture.Registry.FindById(lFixture.Model.MirrorTagId);
    Check((lMirrorTag <> nil) and (Abs(lMirrorTag.RecordingPollFrequencyHz - 1002) < 1E-6),
      'Manual effective clock reaches recording metadata');
    lFixture.Model.FrequencyHz := 25;
    lFixture.Runtime.ApplyOutputSettings;
    lFixture.PumpFor(150);
    Check((lFixture.Probe.Snapshot.Starts = lBefore.Starts) and
      (lFixture.Probe.Snapshot.Configures = lBefore.Configures) and
      (lFixture.Model.SampleRateHz = 1000) and
      (Abs(lFixture.Runtime.Snapshot.CalibrationRateFactor - 1.002) < 1E-9),
      'Manual k survives waveform edits without native reset or nominal-rate mutation');
    Check(not lFixture.Runtime.SetRateFactor(1.02, lResult), 'Out-of-range manual k rejected before mutation');
    Check(Abs(lFixture.Runtime.Snapshot.CalibrationRateFactor - 1.002) < 1E-9,
      'Rejected manual k preserves committed correction');
    lFixture.Runtime.StartCalibration;
    { The old stream retires asynchronously; its rejected-input diagnostic
      remains visible until the accepted new session has been configured. }
    lFixture.PumpFor(200);
    lFixture.AwaitCalibration(True);
    Check(not lFixture.Runtime.Snapshot.CalibrationManualRate,
      'Fresh automatic calibration replaces the previous manual correction');
  finally
    lFixture.Free;
  end;
end;

procedure TestPendingFeedbackToConstant;
var
  lFixture: TFixture;
begin
  lFixture := TFixture.Create(True);
  try
    lFixture.Model.SynchronizeByFeedback := True;
    lFixture.Model.PhaseCalibrationMode := rdpcmMeasurementStart;
    lFixture.Factory.EnterPreview;
    Check(lFixture.Runtime.Snapshot.CalibrationRunning,
      'Measurement sine waits for missing feedback before DC selection');
    lFixture.Model.SourceMode := rdsmConstant;
    lFixture.Runtime.StartOutput;
    lFixture.AwaitBlocks(0, 3);
    Check((lFixture.Probe.Snapshot.Starts = 1) and
      not lFixture.Runtime.Snapshot.CalibrationRunning,
      'Constant Play replaces an obsolete pending feedback request without ADC data');
  finally
    lFixture.Free;
  end;
end;

procedure TestConstantBypassesFeedback;
var
  lFixture: TFixture;
  lMode: TRecorderDacPhaseCalibrationMode;
  lSnapshot: TRecorderDacRuntimeSnapshot;
  lStarts: Integer;
begin
  for lMode := Low(TRecorderDacPhaseCalibrationMode) to High(TRecorderDacPhaseCalibrationMode) do
  begin
    lFixture := TFixture.Create(True);
    try
      lFixture.Model.SourceMode := rdsmConstant;
      lFixture.Model.Amplitude := -0.05;
      lFixture.Model.SynchronizeByFeedback := True;
      lFixture.Model.PhaseCalibrationMode := lMode;
      { Deliberately no feedback tag or ADC data. }
      lFixture.Factory.EnterPreview;
      lFixture.PumpFor(100);
      lSnapshot := lFixture.Runtime.Snapshot;
      Check((lFixture.Probe.Snapshot.Starts = 0) and not lSnapshot.CalibrationRunning,
        'Constant Preview does not start automatic phase calibration mode=' + IntToStr(Ord(lMode)));
      lFixture.Runtime.StartOutput;
      lFixture.AwaitBlocks(0, 3);
      lSnapshot := lFixture.Runtime.Snapshot;
      Check(lSnapshot.OutputPlaying and not lSnapshot.CalibrationRunning and
        (lFixture.Probe.Snapshot.Starts = 1),
        'Constant Play bypasses missing feedback and saved phase policy mode=' + IntToStr(Ord(lMode)));
      lStarts := lFixture.Probe.Snapshot.Starts;
      lFixture.Model.SourceMode := rdsmSine;
      lFixture.Runtime.ApplyOutputSettings;
      lFixture.PumpFor(150);
      Check(not lFixture.Runtime.Snapshot.OutputPlaying,
        'Switching DC to sine retires bypass stream mode=' + IntToStr(Ord(lMode)));
      if lMode <> rdpcmButton then
      begin
        lFixture.Runtime.StartOutput;
        lFixture.PumpFor(150);
        lSnapshot := lFixture.Runtime.Snapshot;
        Check((lFixture.Probe.Snapshot.Starts = lStarts) and
          ((lMode = rdpcmMeasurementStart) or lSnapshot.CalibrationRunning),
          'Sine cannot reuse DC bypass without required feedback mode=' + IntToStr(Ord(lMode)));
      end;
    finally
      lFixture.Free;
    end;
  end;
end;

begin
  gLog := TStringList.Create;
  try
    Application.Initialize;
    try
      TestPersistentPreviewStream;
      TestPlayStartedStream;
      TestStopCancelsPendingFeedback;
      TestCalibrationRejectedAfterLeavePreview;
      TestMutedConfigurationChange;
      TestDisableCancelsPendingFeedback;
      TestHiddenMutedConfigurationChange;
      TestMeasurementCalibrationMode;
      TestPlayCalibrationMode;
      TestManualCalibrationMode;
      TestManualNominalWithoutFeedback;
      TestModeChangeCancelsPendingCalibration;
      TestConstantBypassesFeedback;
      TestPendingFeedbackToConstant;
      TestManualRateFactor;
      gLog.Add('RESULT RecorderDacLifecycleTest passed');
    except
      on E: Exception do
      begin
        gLog.Add('RESULT RecorderDacLifecycleTest failed: ' + E.Message);
        ExitCode := 1;
      end;
    end;
    Writeln(gLog.Text);
    gLog.SaveToFile(ChangeFileExt(ParamStr(0), '.log'));
  finally
    gLog.Free;
  end;
end.
