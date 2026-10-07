program ImpactHammerServiceTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Integration harness for the production impact-hammer path. It publishes
  deliberately non-uniform response timestamps through the Recorder EventBus,
  then verifies that view-like and 3D consumers observe one immutable version. }

uses
  Interfaces, Classes, SysUtils, Math, uRecorderCoreServices, uRecorderTags,
  uRecorderStateMachine,
  uRecorderImpactHammerModel, uRecorderImpactHammerContracts,
  uRecorderImpactHammerService, uRecorderFrfContracts,
  uRecorderImpactHammer, uRecorderImpactDsp,
  uRecorderFrfRepository, uRecorderFrfMotionAdapter, u3dCoreTypes, u3dScene,
  u3dMotionContracts, u3dSceneMotionEngine, uRecorder3dModel,
  uRecorder3dImpactBindingController, u3dLegacySceneLoader;

type
  TTrackingProvider = class(TInterfacedObject, IRecorderFrfProvider)
  private
    fSource: IRecorderFrfProvider;
    fLastVersion: QWord;
  public
    constructor Create(const ASource: IRecorderFrfProvider);
    function AcquireSnapshot: IRecorderFrfSampler;
    property LastVersion: QWord read fLastVersion;
  end;

  TRecordingMotionSink = class(TInterfacedObject, I3dMotionSink)
  private
    fRevision: QWord;
    fCommandCount: Integer;
  public
    function Apply(const ACommands: array of T3dMotionCommand): Boolean;
    function Revision: QWord;
    property CommandCount: Integer read fCommandCount;
  end;

  TConcurrentPublishThread = class(TThread)
  private
    fRegistry: TRecorderTagRegistry;
  protected
    procedure Execute; override;
  public
    constructor Create(ARegistry: TRecorderTagRegistry);
  end;

  TPointCatalog = class(TInterfacedObject, IRecorderModelPointCatalog)
  public
    function ResolvePoint(const APointGroup: string; APointNumber: Integer;
      out ATargetNodeId: QWord): Boolean;
  end;

  TPointBindingSink = class(TInterfacedObject, IRecorderModelPointBindingSink)
  public
    Bindings: array of TRecorderModelPointBinding;
    TargetComponentId: string;
    AnimationScale: Double;
    AnimationFrequencyHz: Double;
    AnimationPlaying: Boolean;
    procedure PublishBindings(const ASourceBindingId,
      ATargetComponentId: string;
      const ABindings: array of TRecorderModelPointBinding);
    procedure RemoveBindings(const ASourceBindingId: string);
    procedure ConfigureAnimation(const ASourceBindingId: string;
      AScale, AFrequencyHz: Double);
    procedure PlayAnimation(const ASourceBindingId: string);
    procedure StopAnimation(const ASourceBindingId: string);
  end;

  TBindingFailureInjector = class
  public
    FailIndex: Integer;
    NotificationCount: Integer;
    procedure BeforeCreate(AIndex: Integer);
    procedure BindingsChanged(Sender: TObject);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckNear(AActual, AExpected: Double; const AMessage: string); forward;
procedure WaitForImpactCount(AService: TRecorderImpactHammerService;
  AExpectedCount: Integer); forward;

procedure TestActualObrPointMotionChain;
const
  CFixture = 'D:\works\OburecGH\3d\files\3d\Meshes\Type_001.OBR';
var
  Loader: I3dSceneLoader;
  Scene: T3dScene;
  SceneComponent: TRecorder3dComponent;
  HammerModel: TRecorderImpactHammerComponent;
  Response: TImpactResponseBinding;
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Service: TRecorderImpactHammerService;
  ControllerObject: TRecorder3dImpactBindingController;
  Catalog: IRecorderModelPointCatalog;
  BindingSink: IRecorderModelPointBindingSink;
  NodeId: QWord;
  Node: T3dNode;
  Curve: array[0..0] of TRecorderFrfCurveData;
  RepositoryObject: TRecorderFrfRepository;
  Provider: IRecorderFrfProvider;
  EngineObject: T3dSceneMotionEngine;
  MotionSink: I3dMotionSink;
  MotionBinding: array[0..0] of TRecorderFrfMotionBinding;
  Adapter: TRecorderFrfMotionAdapter;
  Target: array[0..0] of QWord;
  BeforeX: Double;
begin
  Check(FileExists(CFixture), 'actual OBR fixture is missing');
  Loader := T3dLegacySceneLoader.Create;
  Scene := Loader.LoadScene(CFixture);
  SceneComponent := TRecorder3dComponent.Create;
  HammerModel := TRecorderImpactHammerComponent.Create;
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Service := TRecorderImpactHammerService.Create;
  Adapter := TRecorderFrfMotionAdapter.Create;
  try
    Check((Scene <> nil) and (Length(Scene.Nodes) > 0),
      'actual OBR produced no scene nodes');
    SceneComponent.Id := 'actual-obr-scene';
    ControllerObject := TRecorder3dImpactBindingController.Create(
      SceneComponent, Scene);
    Catalog := ControllerObject;
    BindingSink := ControllerObject;
    Check(Catalog.ResolvePoint('Dummy00', 1, NodeId),
      'actual OBR helper Dummy001 was not catalogued');
    Node := Scene.FindNode(NodeId);
    Check(Node <> nil, 'catalog returned a missing actual OBR node');

    Registry.CreateTag('fixture-hammer', 16);
    Registry.CreateTag('fixture-response', 16);
    HammerModel.Id := 'actual-obr-hammer';
    HammerModel.HammerTagId := Registry.FindByName('fixture-hammer').Id;
    HammerModel.HammerTagName := 'fixture-hammer';
    HammerModel.Target3dComponentId := SceneComponent.Id;
    HammerModel.BasePointNumber := 0;
    HammerModel.PretriggerSamples := 1;
    HammerModel.CaptureSamples := 8;
    HammerModel.FftSize := 8;
    HammerModel.WelchSegmentSize := 8;
    HammerModel.SampleRateHz := 8;
    Response := HammerModel.AddResponse;
    Response.TagId := Registry.FindByName('fixture-response').Id;
    Response.TagName := 'fixture-response';
    Response.CurveId := 501;
    Response.PointGroup := 'Dummy00';
    Response.Axis := iraX;
    Response.Space := irsWorld;
    Response.Gain := 1;
    Check(Service.Configure(HammerModel, Registry), Service.LastError);
    Service.ConfigurePointBindingTarget(Catalog, BindingSink);
    Service.SavePointBindings;
    Check(SceneComponent.FrfBindingCount = 1,
      'SavePointBindings did not persist the actual OBR helper');
    Check(SceneComponent.FrfBindings[0].TargetNodeId = NodeId,
      'SavePointBindings targeted another OBR node');

    Curve[0].Id := 501;
    Curve[0].FrequencyHz := [4.0, 5.0];
    Curve[0].Magnitude := [2.0, 2.0];
    Curve[0].PhaseRadians := [0.0, 0.0];
    Curve[0].Coherence := [1.0, 1.0];
    RepositoryObject := TRecorderFrfRepository.Create;
    Provider := RepositoryObject;
    Check(RepositoryObject.Publish(Curve),
      'actual OBR FRF snapshot publish failed');
    MotionBinding[0].CurveId := SceneComponent.FrfBindings[0].CurveId;
    MotionBinding[0].TargetNodeId := NodeId;
    MotionBinding[0].Axis := SceneComponent.FrfBindings[0].Axis;
    MotionBinding[0].Space := SceneComponent.FrfBindings[0].Space;
    MotionBinding[0].Gain := SceneComponent.FrfBindings[0].Gain;
    MotionBinding[0].Enabled := True;
    EngineObject := T3dSceneMotionEngine.Create;
    MotionSink := EngineObject;
    Target[0] := NodeId;
    EngineObject.Configure(Scene, Target);
    Adapter.ConfigureProvider(Provider, MotionSink, MotionBinding);
    BeforeX := Node.WorldTransform[12];
    Check(Adapter.Update(4, Pi / 2),
      'actual OBR FRF motion update failed');
    CheckNear(Node.WorldTransform[12], BeforeX + 2,
      'actual OBR helper X did not change through unified chain');
  finally
    MotionSink := nil;
    Provider := nil;
    BindingSink := nil;
    Catalog := nil;
    Adapter.Free;
    Service.Free;
    Registry.Free;
    Bus.Free;
    HammerModel.Free;
    SceneComponent.Free;
    Scene.Free;
    Loader := nil;
  end;
end;

procedure CheckNear(AActual, AExpected: Double; const AMessage: string);
begin
  if Abs(AActual - AExpected) > 1E-4 then
    raise Exception.CreateFmt('%s: expected %.6f, got %.6f',
      [AMessage, AExpected, AActual]);
end;

procedure TestWelchFlagThroughService;
const
  CCapture = 20160;
  CFft = 16384;
  CCount = CCapture + 128;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Binding: TImpactResponseBinding;
  Snapshot: TRecorderImpactHammerSnapshot;
  Dsp: TRecorderImpactDspPipeline;
  Settings: TRecorderImpactDspSettings;
  Moments: TRecorderImpactSpectralMoments;
  Values: TStringList;
  Times, Hammer, Response, Sampled: array of Double;
  Series: TRecorderSampleSeries;
  ErrorText: string;
  Welch: Boolean;
  I, Bin, CurveIndex: Integer;
  Delta, LargestDelta: Double;
  Spectrum: array[Boolean] of array of Double;
begin
  for Welch := False to True do
  begin
    Bus := TRecorderEventBus.Create;
    Registry := TRecorderTagRegistry.Create(Bus);
    Model := TRecorderImpactHammerComponent.Create;
    Service := TRecorderImpactHammerService.Create;
    Dsp := TRecorderImpactDspPipeline.Create;
    Values := TStringList.Create;
    try
      Registry.CreateTag('welch-hammer', 32768);
      Registry.CreateTag('welch-response', 32768);
      Model.Id := 'welch-service-test';
      Model.HammerTagId := Registry.FindByName('welch-hammer').Id;
      Model.HammerTagName := 'welch-hammer';
      Model.TriggerThreshold := 1000;
      Model.PretriggerSamples := 2880;
      Model.CaptureSamples := CCapture;
      Model.FftSize := CFft;
      Model.SampleRateHz := 57600;
      Model.WindowKind := iwForce;
      Model.WelchEnabled := Welch;
      Model.WelchSegmentSize := 4096;
      Model.WelchOverlapPercent := 50;
      Binding := Model.AddResponse;
      Binding.TagId := Registry.FindByName('welch-response').Id;
      Binding.TagName := 'welch-response';
      Binding.CurveId := 400;
      Model.SaveToStrings(Values, 'Impact.');
      Model.WelchEnabled := not Welch;
      Check(Model.LoadFromStrings(Values, 'Impact.', ErrorText), ErrorText);
      Check(Model.WelchEnabled = Welch, 'Welch flag lost in persistence');
      Check(Service.Configure(Model, Registry), Service.LastError);
      Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
      SetLength(Times, CCount);
      SetLength(Hammer, CCount);
      SetLength(Response, CCount);
      for I := 0 to CCount - 1 do
      begin
        Times[I] := I / Model.SampleRateHz;
        Hammer[I] := 250 + 0.1 * Sin(I * 0.1);
        if (I >= 2880) and (I < 2940) then
          Hammer[I] := Hammer[I] + 12000 * Sin(Pi * (I - 2880) / 60);
        Response[I] := 0.5 * Hammer[I];
      end;
      Registry.PublishBlock('welch-response', Times, Response, CCount, True);
      Registry.PublishBlock('welch-hammer', Times, Hammer, CCount, True);
      WaitForImpactCount(Service, 1);
      Service.FillSnapshot(Snapshot);
      Check(Length(Snapshot.Results[irtSpectrum].Curves) = 2,
        'service spectrum curves missing');
      Check(Length(Snapshot.Results[irtSpectrum].Curves[0].Y) =
        CFft div 2 + 1, 'service spectrum bins missing');
      Settings := Default(TRecorderImpactDspSettings);
      Settings.SampleRateHz := Model.SampleRateHz;
      Settings.CaptureSamples := CCapture;
      Settings.FftSize := CFft;
      Settings.ResponseCount := 1;
      Settings.WindowKind := iwkForce;
      Settings.ForceWindowFraction := Model.ForceWindowFraction;
      Settings.ExponentialEndFraction := Model.ExponentialEndFraction;
      Settings.ResponseUnitNames := ['V'];
      if Welch then
        Settings.WelchSegmentSamples := Model.WelchSegmentSize;
      Settings.WelchOverlapPercent := Model.WelchOverlapPercent;
      Check(Dsp.Configure(Settings, ErrorText), ErrorText);
      SetLength(Sampled, CCapture);
      for CurveIndex := 0 to 1 do
      begin
        SetLength(Series,
          Length(Snapshot.Results[irtTime].Curves[CurveIndex].X));
        for I := 0 to High(Series) do
        begin
          Series[I].TimeSeconds :=
            Snapshot.Results[irtTime].Curves[CurveIndex].X[I];
          Series[I].Value :=
            Snapshot.Results[irtTime].Curves[CurveIndex].Y[I];
        end;
        Check(ResampleImpactSeries(Series, 0, Model.SampleRateHz,
          CCapture, Sampled), 'service time series could not be resampled');
        for I := 0 to CCapture - 1 do
          Check(Dsp.AddSample(CurveIndex, Sampled[I]),
            'service FFT reference sample add');
      end;
      Check(Dsp.PrepareResponse(0, Moments),
        'service FFT reference prepare');
      if Welch then
        Check(Moments.Metadata.SegmentCount > 1,
          'Welch-on used only one segment')
      else
        Check(Moments.Metadata.SegmentCount = 1,
          'Welch-off split the capture');
      SetLength(Spectrum[Welch], Length(Moments.ExcitationPower));
      for Bin := 0 to High(Moments.ExcitationPower) do
      begin
        Spectrum[Welch][Bin] :=
          Snapshot.Results[irtSpectrum].Curves[0].Y[Bin];
        CheckNear(Spectrum[Welch][Bin],
          Sqrt(Moments.ExcitationPower[Bin]) * Sqrt(2) / CFft,
          'service Welch flag changed before snapshot');
      end;
    finally
      Values.Free;
      Dsp.Free;
      Service.Free;
      Model.Free;
      Registry.Free;
      Bus.Free;
    end;
  end;
  LargestDelta := 0;
  for I := 0 to High(Spectrum[False]) do
  begin
    Delta := Abs(Spectrum[False][I] - Spectrum[True][I]);
    LargestDelta := Max(LargestDelta, Delta);
  end;
  Check(LargestDelta > 0.1,
    'Welch enabled and disabled produced the same spectrum');
end;

procedure TBindingFailureInjector.BeforeCreate(AIndex: Integer);
begin
  if AIndex = FailIndex then
    raise Exception.Create('injected binding allocation failure');
end;

procedure TBindingFailureInjector.BindingsChanged(Sender: TObject);
begin
  Inc(NotificationCount);
end;

constructor TConcurrentPublishThread.Create(ARegistry: TRecorderTagRegistry);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fRegistry := ARegistry;
end;

procedure TConcurrentPublishThread.Execute;
var
  Times: array of Double;
  Values: array of Double;
  I: Integer;
begin
  SetLength(Times, 50000);
  SetLength(Values, Length(Times));
  for I := 0 to High(Times) do
  begin
    Times[I] := 20 + I / 50000;
    Values[I] := I mod 11;
  end;
  fRegistry.PublishBlock('hammer', Times, Values, Length(Times), True);
end;

function TPointCatalog.ResolvePoint(const APointGroup: string;
  APointNumber: Integer; out ATargetNodeId: QWord): Boolean;
begin
  Result := (APointGroup = 'G') and (APointNumber > 0);
  if Result then
    ATargetNodeId := 1000 + APointNumber;
end;

procedure TPointBindingSink.PublishBindings(const ASourceBindingId,
  ATargetComponentId: string;
  const ABindings: array of TRecorderModelPointBinding);
var
  I: Integer;
begin
  TargetComponentId := ATargetComponentId;
  SetLength(Bindings, Length(ABindings));
  for I := 0 to High(ABindings) do
    Bindings[I] := ABindings[I];
end;

procedure TPointBindingSink.RemoveBindings(const ASourceBindingId: string);
begin
  SetLength(Bindings, 0);
end;

procedure TPointBindingSink.ConfigureAnimation(const ASourceBindingId: string;
  AScale, AFrequencyHz: Double);
begin
  AnimationScale := AScale;
  AnimationFrequencyHz := AFrequencyHz;
end;

procedure TPointBindingSink.PlayAnimation(const ASourceBindingId: string);
begin
  AnimationPlaying := True;
end;

procedure TPointBindingSink.StopAnimation(const ASourceBindingId: string);
begin
  AnimationPlaying := False;
end;

procedure WaitForImpactCount(AService: TRecorderImpactHammerService;
  AExpectedCount: Integer);
var
  Snapshot: TRecorderImpactHammerSnapshot;
  Attempt: Integer;
begin
  for Attempt := 1 to 2000 do
  begin
    AService.FillSnapshot(Snapshot);
    if (Snapshot.ImpactCount = AExpectedCount) and
      (Snapshot.State <> ihsRunning) then
      Exit;
    Sleep(1);
  end;
  raise Exception.CreateFmt('timeout waiting for %d completed impacts',
    [AExpectedCount]);
end;

constructor TTrackingProvider.Create(const ASource: IRecorderFrfProvider);
begin
  inherited Create;
  fSource := ASource;
end;

function TTrackingProvider.AcquireSnapshot: IRecorderFrfSampler;
begin
  Result := fSource.AcquireSnapshot;
  if Result <> nil then
    fLastVersion := Result.Version;
end;

function TRecordingMotionSink.Apply(
  const ACommands: array of T3dMotionCommand): Boolean;
begin
  fCommandCount := Length(ACommands);
  Result := fCommandCount > 0;
  if Result then
    Inc(fRevision);
end;

function TRecordingMotionSink.Revision: QWord;
begin
  Result := fRevision;
end;

procedure ConfigureModel(AModel: TRecorderImpactHammerComponent;
  AHammer, AResponseX, AResponseY: TRecorderTag);
var
  lBinding: TImpactResponseBinding;
begin
  AModel.Id := 'hammer-main';
  AModel.HammerTagId := AHammer.Id;
  AModel.HammerTagName := AHammer.Name;
  AModel.TriggerThreshold := 5;
  AModel.TriggerHysteresis := 1;
  AModel.PretriggerSamples := 1;
  AModel.CaptureSamples := 8;
  AModel.ImpactCapacity := 4;
  AModel.FftSize := 8;
  AModel.ZeroPadFactor := 1;
  AModel.WindowKind := iwRectangular;
  AModel.WelchSegmentSize := 8;
  AModel.WelchOverlapPercent := 0;
  AModel.SampleRateHz := 8;
  AModel.CoherenceThreshold := 0;
  AModel.ExcitationUnitName := 'N';
  AModel.BasePointNumber := 10;
  AModel.Target3dComponentId := '3d-main';
  AModel.AnimationScale := 2.5;
  AModel.AnimationFrequencyHz := 12.5;
  AModel.ClearResponses;
  lBinding := AModel.AddResponse;
  lBinding.TagId := AResponseX.Id;
  lBinding.TagName := AResponseX.Name;
  lBinding.CurveId := 101;
  lBinding.ResponseUnitName := 'm/s2';
  lBinding := AModel.AddResponse;
  lBinding.TagId := AResponseY.Id;
  lBinding.TagName := AResponseY.Name;
  lBinding.CurveId := 202;
  lBinding.Axis := iraY;
  lBinding.ResponseUnitName := 'm/s2';
end;

procedure PublishImpact(ARegistry: TRecorderTagRegistry; ABaseTime,
  AResponseScale: Double);
const
  CResponseXOffsets: array[0..7] of Double =
    (-0.125, 0.020, 0.160, 0.310, 0.470, 0.620, 0.770, 0.875);
  CResponseYOffsets: array[0..7] of Double =
    (-0.125, 0.050, 0.200, 0.360, 0.510, 0.660, 0.800, 0.875);
  CForceValues: array[0..7] of Double = (0, 8, 3, 1, -1, 2, -2, 0.5);
var
  lTimes: array[0..7] of Double;
  lValues: array[0..7] of Double;
  I: Integer;
begin
  ARegistry.PublishValue('hammer', ABaseTime - 0.125, CForceValues[0]);
  ARegistry.PublishValue('hammer', ABaseTime, CForceValues[1]);
  for I := 0 to 7 do
  begin
    lTimes[I] := ABaseTime + CResponseXOffsets[I];
    lValues[I] := AResponseScale * CForceValues[I];
  end;
  ARegistry.PublishBlock('response-x', lTimes, lValues, Length(lTimes), True);
  for I := 0 to 7 do
  begin
    lTimes[I] := ABaseTime + CResponseYOffsets[I];
    lValues[I] := (AResponseScale + 1) * CForceValues[I];
  end;
  ARegistry.PublishBlock('response-y', lTimes, lValues, Length(lTimes), True);

  for I := 2 to 7 do
    if I < 7 then
      ARegistry.PublishValue('hammer', ABaseTime + (I - 1) * 0.125,
        CForceValues[I])
    else
      ARegistry.PublishValue('hammer', ABaseTime + 0.875, CForceValues[I]);
end;

function TimeResponsePeak(const ASnapshot: TRecorderImpactHammerSnapshot): Double;
var
  lIndex: Integer;
begin
  Result := -Infinity;
  for lIndex := 0 to High(ASnapshot.Results[irtTime].Curves[1].Y) do
    Result := Max(Result,
      ASnapshot.Results[irtTime].Curves[1].Y[lIndex]);
end;

procedure CheckConsumersShareVersion(const AProvider: IRecorderFrfProvider;
  AExpectedVersion: QWord);
var
  lViewSnapshot: IRecorderFrfSampler;
  lTrackingObject: TTrackingProvider;
  lTrackingProvider: IRecorderFrfProvider;
  lSinkObject: TRecordingMotionSink;
  lSink: I3dMotionSink;
  lAdapter: TRecorderFrfMotionAdapter;
  lBinding: array[0..0] of TRecorderFrfMotionBinding;
  lMagnitude: Double;
  lPhase: Double;
begin
  lViewSnapshot := AProvider.AcquireSnapshot;
  Check(lViewSnapshot <> nil, 'view-like consumer received nil snapshot');
  Check(lViewSnapshot.Version = AExpectedVersion, 'view-like version mismatch');
  Check(lViewSnapshot.TrySample(101, 1, lMagnitude, lPhase),
    'first response curve unavailable');
  Check(lViewSnapshot.TrySample(202, 1, lMagnitude, lPhase),
    'second response curve unavailable');

  lTrackingObject := TTrackingProvider.Create(AProvider);
  lTrackingProvider := lTrackingObject;
  lSinkObject := TRecordingMotionSink.Create;
  lSink := lSinkObject;
  lAdapter := TRecorderFrfMotionAdapter.Create;
  try
    lBinding[0].CurveId := 101;
    lBinding[0].TargetNodeId := 77;
    lBinding[0].Axis := maxisX;
    lBinding[0].Space := msHelperLocal;
    lBinding[0].Gain := 1;
    lBinding[0].Enabled := True;
    lAdapter.ConfigureProvider(lTrackingProvider, lSink, lBinding);
    Check(lAdapter.Update(1, Pi / 2), '3D adapter did not apply FRF motion');
    Check(lTrackingObject.LastVersion = lViewSnapshot.Version,
      '3D adapter acquired a different sampler version');
    Check(lSinkObject.CommandCount = 1, '3D adapter command count');
  finally
    lAdapter.Free;
    lSink := nil;
    lTrackingProvider := nil;
  end;
end;

procedure TestConcrete3dPointTarget;
var
  lScene: T3dScene;
  lNode: T3dNode;
  lComponent: TRecorder3dComponent;
  lControllerObject: TRecorder3dImpactBindingController;
  lCatalog: IRecorderModelPointCatalog;
  lBindingSink: IRecorderModelPointBindingSink;
  lPointBindings: array[0..2] of TRecorderModelPointBinding;
  lMotionBindings: array[0..2] of TRecorderFrfMotionBinding;
  lCurves: array[0..2] of TRecorderFrfCurveData;
  lRepositoryObject: TRecorderFrfRepository;
  lProvider: IRecorderFrfProvider;
  lEngineObject: T3dSceneMotionEngine;
  lMotionSink: I3dMotionSink;
  lAdapter: TRecorderFrfMotionAdapter;
  lTargets: array[0..0] of QWord;
  lNodeId: QWord;
  lManualBinding: TRecorder3dFrfBinding;
  lFailureInjector: TBindingFailureInjector;
  I: Integer;
begin
  lScene := T3dScene.Create;
  lComponent := TRecorder3dComponent.Create;
  lAdapter := TRecorderFrfMotionAdapter.Create;
  lFailureInjector := TBindingFailureInjector.Create;
  try
    lComponent.Id := 'scene-main';
    lNode := T3dNode.Create;
    lNode.Id := 7001;
    lNode.Name := 'Blade.11';
    SetIdentity(lNode.LocalTransform);
    SetIdentity(lNode.WorldTransform);
    lScene.AddNode(lNode);
    lControllerObject := TRecorder3dImpactBindingController.Create(
      lComponent, lScene);
    lCatalog := lControllerObject;
    lBindingSink := lControllerObject;
    Check(lCatalog.ResolvePoint('Blade', 11, lNodeId) and
      (lNodeId = 7001), 'stable helper lookup');
    Check(not lCatalog.ResolvePoint('Missing', 11, lNodeId),
      'missing helper lookup was accepted');

    FillChar(lPointBindings, SizeOf(lPointBindings), 0);
    for I := 0 to High(lPointBindings) do
    begin
      lPointBindings[I].CurveId := 101 + I;
      lPointBindings[I].PointGroup := 'Blade';
      lPointBindings[I].PointNumber := 11;
      lPointBindings[I].TargetNodeId := 7001;
      lPointBindings[I].Axis := T3dMotionAxis(I);
      lPointBindings[I].Space := msWorld;
      lPointBindings[I].Gain := I + 1;
      lPointBindings[I].Enabled := True;
    end;
    lManualBinding := lComponent.AddFrfBinding;
    lManualBinding.SourceBindingId := 'other-mechanic';
    lManualBinding.CurveId := 999;
    lBindingSink.ConfigureAnimation('hammer-main', 2, 4);
    lBindingSink.PublishBindings('hammer-main', 'another-scene',
      lPointBindings);
    Check(lComponent.FrfBindingCount = 1,
      'binding sink accepted another explicit 3D component id');
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check(lComponent.FrfBindingCount = 4,
      'Save Points did not upsert all XYZ bindings in 3D model');
    for I := 0 to 2 do
    begin
      Check(lComponent.FrfBindings[I + 1].CurveId = 101 + QWord(I),
        'stable curve id was not persisted in 3D binding');
      CheckNear(lComponent.FrfBindings[I + 1].Gain, I + 1,
        'runtime animation scale was baked into persistent model binding');
      lMotionBindings[I].CurveId := lComponent.FrfBindings[I + 1].CurveId;
      lMotionBindings[I].TargetNodeId :=
        lComponent.FrfBindings[I + 1].TargetNodeId;
      lMotionBindings[I].Axis := lComponent.FrfBindings[I + 1].Axis;
      lMotionBindings[I].Space := lComponent.FrfBindings[I + 1].Space;
      lMotionBindings[I].Gain := lComponent.FrfBindings[I + 1].Gain *
        lControllerObject.AnimationScale;
      lMotionBindings[I].Enabled := lComponent.FrfBindings[I + 1].Enabled;
      lCurves[I].Id := 101 + I;
      lCurves[I].FrequencyHz := [4.0, 5.0];
      lCurves[I].Magnitude := [1.0, 1.0];
      lCurves[I].PhaseRadians := [0.0, 0.0];
      lCurves[I].Coherence := [1.0, 1.0];
    end;

    lRepositoryObject := TRecorderFrfRepository.Create;
    lProvider := lRepositoryObject;
    Check(lRepositoryObject.Publish(lCurves), 'XYZ curve publish');
    lEngineObject := T3dSceneMotionEngine.Create;
    lMotionSink := lEngineObject;
    lTargets[0] := 7001;
    lEngineObject.Configure(lScene, lTargets);
    lAdapter.ConfigureProvider(lProvider, lMotionSink, lMotionBindings);
    Check(lAdapter.Update(4, Pi / 2), 'XYZ motion apply');
    CheckNear(lNode.WorldTransform[12], 2, 'X point motion');
    CheckNear(lNode.WorldTransform[13], 4, 'Y point motion');
    CheckNear(lNode.WorldTransform[14], 6, 'Z point motion');

    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[0].CurveId = 999),
      'owner-scoped upsert removed another mechanism or duplicated bindings');
    lFailureInjector.FailIndex := 1;
    lControllerObject.BeforeBindingCreate := @lFailureInjector.BeforeCreate;
    lControllerObject.OnBindingsChanged := @lFailureInjector.BindingsChanged;
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[0].CurveId = 999) and
      (lComponent.FrfBindings[1].CurveId = 101) and
      (lFailureInjector.NotificationCount = 0),
      'injected creation failure partially committed or notified');
    lControllerObject.BeforeBindingCreate := nil;
    lControllerObject.OnBindingsChanged := nil;
    lPointBindings[0].CurveId := 0;
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[1].CurveId = 101),
      'invalid zero CurveId replaced prior owner bindings');
    lPointBindings[0].CurveId := 102;
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[1].CurveId = 101),
      'duplicate CurveId replaced prior owner bindings');
    lPointBindings[0].CurveId := 101;
    lPointBindings[0].TargetNodeId := 999999;
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[1].TargetNodeId = 7001),
      'missing target node replaced prior owner bindings');
    lPointBindings[0].TargetNodeId := 7001;
    lPointBindings[0].Gain := NaN;
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      not IsNan(lComponent.FrfBindings[1].Gain),
      'non-finite gain replaced prior owner bindings');
    lPointBindings[0].Gain := 1;
    lPointBindings[0].Axis := T3dMotionAxis(99);
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[1].Axis = maxisX),
      'invalid axis replaced prior owner bindings');
    lPointBindings[0].Axis := maxisX;
    lPointBindings[0].Space := T3dMotionSpace(99);
    lBindingSink.PublishBindings('hammer-main', 'scene-main', lPointBindings);
    Check((lComponent.FrfBindingCount = 4) and
      (lComponent.FrfBindings[1].Space = msWorld),
      'invalid space replaced prior owner bindings');
    lPointBindings[0].Space := msWorld;
    lBindingSink.PlayAnimation('hammer-main');
    Check(lControllerObject.AnimationPlaying, 'animation play state');
    lControllerObject.Advance(0.03125);
    CheckNear(lControllerObject.AnimationPhase, Pi / 4,
      'animation frequency phase advance');
    lBindingSink.ConfigureAnimation('hammer-main', 3, 8);
    CheckNear(lControllerObject.AnimationScale, 3,
      'runtime scale update after Save Points');
    CheckNear(lControllerObject.AnimationFrequencyHz, 8,
      'runtime frequency update after Save Points');
    lBindingSink.ConfigureAnimation('hammer-main', NaN, 0);
    CheckNear(lControllerObject.AnimationScale, 3,
      'invalid animation scale mutated playback state');
    CheckNear(lControllerObject.AnimationFrequencyHz, 8,
      'invalid animation frequency mutated playback state');
    lBindingSink.StopAnimation('hammer-main');
    Check(not lControllerObject.AnimationPlaying,
      'animation stop state');
    CheckNear(lControllerObject.AnimationPhase, 0,
      'animation stop resets phase');
    lBindingSink.RemoveBindings('hammer-main');
    Check((lComponent.FrfBindingCount = 1) and
      (lComponent.FrfBindings[0].CurveId = 999),
      'owner-scoped remove damaged another mechanism');
  finally
    lFailureInjector.Free;
    lAdapter.Free;
    lMotionSink := nil;
    lProvider := nil;
    lBindingSink := nil;
    lCatalog := nil;
    lComponent.Free;
    lScene.Free;
  end;
end;

procedure RunIntegration;
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lHammer: TRecorderTag;
  lResponseX: TRecorderTag;
  lResponseY: TRecorderTag;
  lModel: TRecorderImpactHammerComponent;
  lService: TRecorderImpactHammerService;
  lProvider: IRecorderFrfProvider;
  lDefaultProvider: IRecorderFrfProvider;
  lSnapshot: IRecorderFrfSampler;
  lViewState: TRecorderImpactHammerSnapshot;
  lVersionAfterFirst: QWord;
  lVersionAfterSecond: QWord;
  lFirstMagnitude: Double;
  lAverageMagnitude: Double;
  lRestoredMagnitude: Double;
  lPhase: Double;
  lPublishThread: TConcurrentPublishThread;
  lCatalog: IRecorderModelPointCatalog;
  lSinkIntf: IRecorderModelPointBindingSink;
  lPointSink: TPointBindingSink;
  lError: string;
  lProcessing: TRecorderImpactProcessingSettings;
  lFilterWindow: TRecorderImpactFilterWindow;
  lStartedAt: QWord;
begin
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lModel := TRecorderImpactHammerComponent.Create;
  lService := TRecorderImpactHammerService.Create;
  try
    lHammer := lRegistry.CreateTag('hammer', 64);
    lResponseX := lRegistry.CreateTag('response-x', 64);
    lResponseY := lRegistry.CreateTag('response-y', 64);
    ConfigureModel(lModel, lHammer, lResponseX, lResponseY);
    lModel.Responses[0].PointGroup := 'G';
    lModel.Responses[0].PointIncrement := 0;
    lModel.Responses[1].PointGroup := 'G';
    lModel.Responses[1].PointIncrement := 2;
    Check(lService.Configure(lModel, lRegistry), lService.LastError);
    lProcessing.Estimator := Ord(ifeH2);
    lProcessing.WindowKind := Ord(iwHann);
    lProcessing.WelchSegmentSize := 4;
    lProcessing.WelchOverlapPercent := 25;
    Check(lService.TryUpdateProcessingSettings(lProcessing, lError), lError);
    Check((lModel.Estimator = ifeH2) and (lModel.WindowKind = iwHann) and
      (lModel.WelchSegmentSize = 4) and
      (lModel.WelchOverlapPercent = 25),
      'runtime processing settings were not committed');
    lPointSink := TPointBindingSink.Create;
    lSinkIntf := lPointSink;
    lCatalog := TPointCatalog.Create;
    lService.ConfigurePointBindingTarget(lCatalog, lSinkIntf);
    lService.SavePointBindings;
    Check(lService.LastError = '', lService.LastError);
    Check((Length(lPointSink.Bindings) = 2) and
      (lPointSink.Bindings[0].PointNumber = 11) and
      (lPointSink.Bindings[1].PointNumber = 13),
      'legacy base point plus group increment mapping');
    Check((lPointSink.Bindings[0].Axis = maxisX) and
      (lPointSink.Bindings[1].Axis = maxisY),
      'response axis mapping');
    Check(lPointSink.TargetComponentId = '3d-main',
      'Save Points lost explicit 3D component id');
    Check((Abs(lPointSink.AnimationScale - 2.5) < 1E-9) and
      (Abs(lPointSink.AnimationFrequencyHz - 12.5) < 1E-9),
      'Save Points did not configure animation controls');
    lService.PlayModelAnimation;
    Check(lPointSink.AnimationPlaying,
      'Play command did not reach configured motion target');
    lService.StopModelAnimation;
    Check(not lPointSink.AnimationPlaying,
      'Stop command did not reach configured motion target');
    lModel.Responses[1].PointGroup := 'missing';
    Check(not lService.PublishPointBindings(10, lCatalog, lSinkIntf,
      lError), 'missing helper was accepted');
    lModel.Responses[1].PointGroup := 'G';
    lProvider := lService.Provider;
    lDefaultProvider := RecorderDefaultFrfProvider;
    Check(lProvider <> nil, 'service provider missing');
    Check(lDefaultProvider <> nil, 'default provider missing');
    Check((lProvider.AcquireSnapshot = nil) and
      (lDefaultProvider.AcquireSnapshot = nil),
      'service/default provider initial states differ');

    lService.FillSnapshot(lViewState);
    Check(not lViewState.CanStart and not lViewState.CanArm and
      not lViewState.CanStop,
      'measurement commands enabled while Recorder is stopped');

    lBus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter, nil,
      '', '', 0, nil, rstStopToView));
    lService.FillSnapshot(lViewState);
    Check(lViewState.State = ihsArmed,
      'Recorder active transition did not arm impact service');
    lProcessing.Estimator := Ord(ifeH0);
    Check(not lService.TryUpdateProcessingSettings(lProcessing, lError),
      'processing settings changed while armed');
    Check(not lViewState.CanStart and not lViewState.CanArm and
      lViewState.CanStop,
      'active Recorder command policy mismatch');
    lBus.Publish(TRecorderEventBus.MakeEvent(rceStopped));
    lService.FillSnapshot(lViewState);
    Check(lViewState.State = ihsIdle,
      'Recorder stop event did not stop impact service');
    Check(not lViewState.CanStart and not lViewState.CanArm and
      not lViewState.CanStop,
      'Recorder stop did not disable measurement commands');

    lModel.Enabled := False;
    Check(lService.Configure(lModel, lRegistry), lService.LastError);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    lService.FillSnapshot(lViewState);
    Check((lViewState.State = ihsIdle) and not lViewState.CanStart and
      not lViewState.CanArm and not lViewState.CanStop,
      'disabled component armed from Recorder start');
    lModel.Enabled := True;
    lModel.TriggerThreshold := -1;
    Check(not lService.Configure(lModel, lRegistry),
      'invalid component configuration was accepted');
    lService.FillSnapshot(lViewState);
    Check((lViewState.State = ihsFault) and not lViewState.CanStart and
      not lViewState.CanArm and not lViewState.CanStop,
      'faulted component exposed measurement commands');
    lModel.TriggerThreshold := 5;
    Check(lService.Configure(lModel, lRegistry), lService.LastError);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    lService.FillSnapshot(lViewState);
    Check((lViewState.State = ihsArmed) and lViewState.CanStop,
      'enabled component did not recover on Recorder start');

    lService.ArmMeasurement;
    PublishImpact(lRegistry, 1, 2);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lViewState);
    Check(lViewState.ImpactCount = 1, 'first EventBus impact not captured');
    lSnapshot := lProvider.AcquireSnapshot;
    lVersionAfterFirst := lSnapshot.Version;
    Check(lVersionAfterFirst > 0, 'first impact was not published');
    Check(lSnapshot.TrySample(101, 1, lFirstMagnitude, lPhase),
      'first impact magnitude unavailable');
    CheckConsumersShareVersion(lProvider, lVersionAfterFirst);

    PublishImpact(lRegistry, 4, 4);
    WaitForImpactCount(lService, 2);
    lService.FillSnapshot(lViewState);
    Check(lViewState.ImpactCount = 2, 'second EventBus impact not captured');
    Check((lViewState.ImpactIndex = 1) and
      (Length(lViewState.Results[irtTime].Curves) = 3) and
      (Abs(TimeResponsePeak(lViewState) - 32) < 1E-9),
      'latest impact time buffers unavailable');
    lService.NavigateToPreviousImpact;
    lService.FillSnapshot(lViewState);
    Check((lViewState.ImpactIndex = 0) and
      lViewState.CanNavigateNext and
      (Abs(TimeResponsePeak(lViewState) - 16) < 1E-9),
      'previous impact did not restore its own time buffers');
    lService.NavigateToNextImpact;
    lService.FillSnapshot(lViewState);
    Check((lViewState.ImpactIndex = 1) and
      (Abs(TimeResponsePeak(lViewState) - 32) < 1E-9),
      'next impact did not restore its own time buffers');
    lVersionAfterSecond := lProvider.AcquireSnapshot.Version;
    Check(lVersionAfterSecond > lVersionAfterFirst,
      'second accepted impact did not republish averaged FRF');
    Check(lProvider.AcquireSnapshot.TrySample(101, 1, lAverageMagnitude,
      lPhase), 'averaged magnitude unavailable');
    Check(Abs(lAverageMagnitude - lFirstMagnitude) > 1E-6,
      'second impact did not change the averaged FRF');
    CheckConsumersShareVersion(lDefaultProvider,
      lDefaultProvider.AcquireSnapshot.Version);

    lFilterWindow := lViewState.FilterWindow;
    lFilterWindow.Enabled := True;
    lFilterWindow.StartSeconds := 0;
    lFilterWindow.EndSeconds := 0.75 * lViewState.CaptureDurationSeconds;
    lFilterWindow.ExponentialStartSeconds :=
      0.25 * lViewState.CaptureDurationSeconds;
    lFilterWindow.ExponentialEndSeconds := lFilterWindow.EndSeconds;
    lFilterWindow.ExponentialEndLevel := 0.001;
    lStartedAt := GetTickCount64;
    Check(lService.TrySetFilterWindow(lFilterWindow, lError), lError);
    lService.NavigateToPreviousImpact;
    lService.FillSnapshot(lViewState);
    Check((lViewState.ImpactIndex = 0) and
      (Abs(TimeResponsePeak(lViewState) - 16) < 1E-9),
      'filter recalculation blocked navigation to stored time buffers');
    lService.NavigateToNextImpact;
    Check(GetTickCount64 - lStartedAt < 500,
      'live filter command blocked on DSP recalculation');
    WaitForImpactCount(lService, 2);
    lService.FillSnapshot(lViewState);
    Check((lViewState.ImpactCount = 2) and (lViewState.ImpactIndex = 1),
      'interactive filter window lost impact selection or history');
    Check(lViewState.FilterWindow.Enabled and
      (Abs(lViewState.FilterWindow.EndSeconds -
       lFilterWindow.EndSeconds) < 1E-9),
      'interactive filter window was not published');
    lFilterWindow.Enabled := False;
    Check(lService.TrySetFilterWindow(lFilterWindow, lError), lError);
    lFilterWindow.EndSeconds := lViewState.CaptureDurationSeconds;
    lFilterWindow.ExponentialEndSeconds := lFilterWindow.EndSeconds;
    Check(lService.TrySetFilterWindow(lFilterWindow, lError), lError);
    WaitForImpactCount(lService, 2);
    lService.FillSnapshot(lViewState);
    Check(not lViewState.FilterWindow.Enabled and
      (Abs(lViewState.FilterWindow.EndSeconds -
      lFilterWindow.EndSeconds) < 1E-9),
      'stale filter result replaced the latest request');
    Check(lProvider.AcquireSnapshot.TrySample(101, 1, lRestoredMagnitude,
      lPhase), 'filter-disabled magnitude unavailable');
    Check(Abs(lRestoredMagnitude - lAverageMagnitude) < 1E-9,
      'filter-disabled DSP changed the legacy output');

    lStartedAt := GetTickCount64;
    lService.SetCurrentImpactHidden(True);
    Check(GetTickCount64 - lStartedAt < 500,
      'hide command blocked on FRF recomputation');
    WaitForImpactCount(lService, 2);
    lService.FillSnapshot(lViewState);
    Check(lViewState.ImpactHidden, 'current impact was not hidden');
    Check(lProvider.AcquireSnapshot.Version > lVersionAfterSecond,
      'hide did not republish accepted visible set');
    Check(lProvider.AcquireSnapshot.TrySample(101, 1, lRestoredMagnitude,
      lPhase), 'hidden-set magnitude unavailable');
    Check(Abs(lRestoredMagnitude - lFirstMagnitude) < 1E-9,
      'hide did not restore the first-impact FRF');
    lVersionAfterSecond := lProvider.AcquireSnapshot.Version;

    lStartedAt := GetTickCount64;
    lService.DeleteCurrentImpact;
    Check(GetTickCount64 - lStartedAt < 500,
      'delete command blocked on FRF recomputation');
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lViewState);
    Check(lViewState.ImpactCount = 1, 'delete did not remove current impact');
    Check(lProvider.AcquireSnapshot.Version > lVersionAfterSecond,
      'delete did not republish remaining impact');
    Check(lProvider.AcquireSnapshot.TrySample(101, 1, lRestoredMagnitude,
      lPhase), 'post-delete magnitude unavailable');
    Check(Abs(lRestoredMagnitude - lFirstMagnitude) < 1E-9,
      'delete did not retain the expected first-impact FRF');
    CheckConsumersShareVersion(RecorderDefaultFrfProvider,
      RecorderDefaultFrfProvider.AcquireSnapshot.Version);

    lService.ArmMeasurement;
    PublishImpact(lRegistry, 8, 3);
    lService.StopMeasurement;
    WaitForImpactCount(lService, 2);
    lService.FillSnapshot(lViewState);
    Check(lViewState.State = ihsIdle,
      'deferred stop was lost while completion was pending');
    lService.ArmMeasurement;
    PublishImpact(lRegistry, 12, 3);
    Check(lService.Configure(lModel, lRegistry),
      'reconfigure while completion is queued: ' + lService.LastError);
    lService.FillSnapshot(lViewState);
    Check(lViewState.ImpactCount = 0,
      'reconfigure did not replace the completed runtime state');

    lPublishThread := TConcurrentPublishThread.Create(lRegistry);
    try
      lPublishThread.Start;
      Sleep(1);
      lService.Free;
      lService := nil;
      lPublishThread.WaitFor;
    finally
      lPublishThread.Free;
    end;
  finally
    lProvider := nil;
    lDefaultProvider := nil;
    lService.Free;
    lModel.Free;
    lRegistry.Free;
    lBus.Free;
  end;
end;

begin
  try
    TestActualObrPointMotionChain;
    TestConcrete3dPointTarget;
    TestWelchFlagThroughService;
    RunIntegration;
    WriteLn('RESULT ImpactHammerService passed');
  except
    on E: Exception do
    begin
      WriteLn(StdErr, 'RESULT ImpactHammerService failed: ', E.Message);
      WriteLn(StdErr, BackTraceStrFunc(ExceptAddr));
      DumpExceptionBackTrace(StdErr);
      Halt(1);
    end;
  end;
end.
