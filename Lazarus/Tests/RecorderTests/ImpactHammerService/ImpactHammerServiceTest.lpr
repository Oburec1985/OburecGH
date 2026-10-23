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
  uRecorder3dImpactBindingController, u3dLegacySceneLoader,
  uRecorder3dVertexColorAdapter, u3dSkin, uRecorderFrfRoute,
  uRecorderFrfPointStore, uRecorderImpactSessionContracts, uRecorderFrfIntensityAdapter;

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
    function ObjectCount:Integer;
    function ObjectInfo(AIndex:Integer; out AInfo:TRecorderModelObjectInfo):Boolean;
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
    HammerModel.GeometryBindingMode:=rgbmOscillation;
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
    Response.IntensityOnly:=False;
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

function TPointCatalog.ObjectCount:Integer;
begin Result:=0; end;
function TPointCatalog.ObjectInfo(AIndex:Integer;
  out AInfo:TRecorderModelObjectInfo):Boolean;
begin AInfo:=Default(TRecorderModelObjectInfo); Result:=False; end;

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
  raise Exception.CreateFmt('timeout waiting for %d completed impacts (got %d, state %d, %s)',
    [AExpectedCount, Snapshot.ImpactCount, Ord(Snapshot.State), Snapshot.StatusText]);
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
  lWindowSample, lWindowRequest: Integer;
  lWindowResponse: array of Double;
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
    lModel.GeometryBindingMode:=rgbmOscillation;
    lModel.Responses[0].IntensityOnly:=False;
    lModel.Responses[1].IntensityOnly:=False;
    lModel.Responses[0].PointGroup := 'G';
    lModel.Responses[0].PointIncrement := 0;
    lModel.Responses[1].PointGroup := 'G';
    lModel.Responses[1].PointIncrement := 2;
    lModel.Responses[1].PointNumber:=13;
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
      'explicit geometry point mapping');
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
    { Enabled window removes the last-10% baseline (1 from raw peak 16).
      Navigation must show the first stored impact with that same processing. }
    Check((lViewState.ImpactIndex = 0) and
      (Abs(TimeResponsePeak(lViewState) - 15) < 1E-9),
      'filter recalculation blocked navigation to windowed stored time buffers');
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
    lWindowResponse := Copy(lViewState.Results[irtTime].Curves[1].Y);
    lFilterWindow.StartSeconds := 0.15;
    lFilterWindow.EndSeconds := 1;
    Check(lService.TrySetFilterWindow(lFilterWindow, lError), lError);
    WaitForImpactCount(lService, 2);
    lService.FillSnapshot(lViewState);
    for lWindowSample := 0 to High(lWindowResponse) do
      CheckNear(lViewState.Results[irtTime].Curves[1].Y[lWindowSample],
        lWindowResponse[lWindowSample], 'rectangle changed response time tail');
    lStartedAt := GetTickCount64;
    for lWindowRequest := 1 to 30 do
    begin
      lFilterWindow.ExponentialEndLevel := 0.01 + lWindowRequest / 100;
      Check(lService.TrySetFilterWindow(lFilterWindow, lError), lError);
    end;
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
    WriteLn('MEASURE latest-wins 32 window requests ms=', GetTickCount64-lStartedAt);
    if (ParamCount > 0) and (ParamStr(1) = '--window-integration-only') then
    begin
      Check(lService.TrySetFilterWindow(lFilterWindow, lError), lError);
      lService.DeleteCurrentImpact;
      WaitForImpactCount(lService, 1);
      lService.FillSnapshot(lViewState);
      CheckNear(TimeResponsePeak(lViewState), 16,
        'in-flight delete lost remaining raw history');
      Check(lProvider.AcquireSnapshot.TrySample(101, 1, lRestoredMagnitude,
        lPhase), 'in-flight delete lost remaining FRF');
      CheckNear(lRestoredMagnitude, lFirstMagnitude,
        'stale pre-delete window generation replaced current history');
      Exit;
    end;

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

procedure TestIntensityValues;
var lRepo:TRecorderFrfRepository; lProvider:IRecorderFrfProvider;
  lScene:T3dScene; lNode:T3dNode; lAdapter:TRecorderFrfIntensityAdapter;
  lCurves:array[0..1] of TRecorderFrfCurveData;
  lBindings:array[0..1] of TRecorderFrfIntensityBinding; I:Integer;
  lSampler:IRecorderFrfSampler;
  lRange:IRecorderFrfRangeScale;
  lPeak:Double;
begin
  lRepo:=TRecorderFrfRepository.Create; lProvider:=lRepo;
  lScene:=T3dScene.Create; lAdapter:=TRecorderFrfIntensityAdapter.Create;
  try
    lNode:=T3dNode.Create; lNode.Id:=101; lScene.AddNode(lNode);
    for I:=0 to 1 do
    begin
      lCurves[I].Id:=I+1;
      lCurves[I].FrequencyHz:=[10,20];
      lCurves[I].Magnitude:=[2*(I+1),4*(I+1)];
      lCurves[I].PhaseRadians:=[0,0]; lCurves[I].Coherence:=[1,1];
      lBindings[I]:=Default(TRecorderFrfIntensityBinding);
      lBindings[I].CurveId:=I+1; lBindings[I].TargetNodeId:=lNode.Id;
      lBindings[I].Enabled:=True; lBindings[I].ShowIntensityValues:=True;
      lBindings[I].Gain:=1;
      lBindings[I].MarkerSizePixels:=10; lBindings[I].PointLabel:=IntToStr(I+1);
    end;
    Check(lRepo.Publish(lCurves),'intensity curves invalid');
    SetRecorderFrfDisplayRange(10,20);
    lAdapter.Configure(lProvider,lScene,lBindings);
    Check(lAdapter.Update(15),'intensity sampling failed');
    Check((lAdapter.Marker(0).PointLabel='1 = 3') and
      (lAdapter.Marker(1).PointLabel='2 = 6'),'points did not sample own curve at common frequency');
    CheckNear(lAdapter.Marker(1).SizePixels,15,'preset normalized size at 15Hz');
    Check(lAdapter.Update(20),'intensity resampling failed');
    Check(lAdapter.Marker(1).PointLabel='2 = 8','numeric label did not follow frequency');
    CheckNear(lAdapter.Marker(1).SizePixels,20,'preset normalized size at 20Hz');
    lCurves[0].FrequencyHz:=[1,10,15,20,30];
    lCurves[0].Magnitude:=[1E200,2,3,4,1E200];
    lCurves[0].Amplitude:=[1E200,4,6,8,1E200];
    lCurves[0].PhaseRadians:=[0,0,0,0,0];
    lCurves[0].Coherence:=[1,1,1,1,1];
    Check(lRepo.Publish([lCurves[0]]),'range scale fixture invalid');
    lSampler:=lProvider.AcquireSnapshot;
    Check(Supports(lSampler,IRecorderFrfRangeScale,lRange),'range scale API missing');
    Check(lRange.TryGetRangeMaximum(1,12,18,False,False,25,lPeak),'range point maximum unavailable');
    CheckNear(lPeak,3.6,'interpolated preset boundary maximum');
    Check(lRange.TryGetRangeMaximum(1,10,20,False,True,25,lPeak),'band maximum unavailable');
    CheckNear(lPeak,5,'preset band RSS excludes enormous external peaks');
    Check(lRange.TryGetRangeMaximum(1,10,20,True,True,25,lPeak),'amplitude band maximum unavailable');
    CheckNear(lPeak,10,'preset amplitude band RSS');
  finally
    lAdapter.Free; lScene.Free; lProvider:=nil;
  end;
end;

procedure TestRoutePointNavigation;
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lModel: TRecorderImpactHammerComponent;
  lService: TRecorderImpactHammerService;
  lHammer, lX, lY: TRecorderTag;
  lEntry: TRecorderFrfRouteEntry;
  lView: TRecorderImpactHammerSnapshot;
  lStored, lLive: TRecorderImpactSessionSnapshot;
  lError, lDirectory: string;
  lSessionFile: string;
  lInvalidFile: TFileStream;
  lId: TGuid;
  lMapping: TRecorderFrfRouteBinding;
  lCatalog: IRecorderModelPointCatalog;
  lSinkRef: IRecorderModelPointBindingSink;
  lSink: TPointBindingSink;
  lBeforeReview: TRecorderImpactSessionSnapshot;
  lNode: T3dNode;
  lScene: T3dScene;
  lAdapter: TRecorderFrfIntensityAdapter;
  lPreviousSize: Double;
  lSample, lPhase: Double;
  lSampler: IRecorderFrfSampler;
  I, J, K: Integer;

  procedure ConfigurePublishedIntensity;
  var lBindings: array of TRecorderFrfIntensityBinding; N: Integer;
  begin
    SetLength(lBindings,Length(lSink.Bindings));
    for N:=0 to High(lBindings) do
    begin
      Check(lSink.Bindings[N].Mode=rgbmIntensity,'published point is not intensity');
      lBindings[N]:=Default(TRecorderFrfIntensityBinding);
      lBindings[N].CurveId:=lSink.Bindings[N].CurveId;
      lBindings[N].TargetNodeId:=lSink.Bindings[N].TargetNodeId;
      lBindings[N].PointNumber:=lSink.Bindings[N].PointNumber;
      lBindings[N].PointLabel:=lSink.Bindings[N].PointLabel;
      lBindings[N].Gain:=lSink.Bindings[N].Gain;
      lBindings[N].MarkerSizePixels:=20;
      lBindings[N].Enabled:=True;
      lBindings[N].ShowIntensityValues:=lSink.Bindings[N].ShowIntensityValues;
    end;
    lAdapter.Configure(RecorderDefaultFrfProvider,lScene,lBindings);
  end;

  procedure SamplePublished(AExpected: Double; const AContext: string);
  begin
    lSampler:=RecorderDefaultFrfProvider.AcquireSnapshot;
    Check(lSampler.TrySample(lSink.Bindings[0].CurveId,1,lSample,lPhase),
      AContext+': published curve not found');
    CheckNear(lSample,AExpected,AContext+': wrong acquisition source');
    lSampler:=nil;
  end;
begin
  CreateGuid(lId);
  lDirectory := IncludeTrailingPathDelimiter(GetTempDir) + 'frf-route-' + GuidToString(lId);
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lModel := TRecorderImpactHammerComponent.Create;
  lService := TRecorderImpactHammerService.Create;
  lScene:=T3dScene.Create;
  lAdapter:=TRecorderFrfIntensityAdapter.Create;
  lNode:=T3dNode.Create; lNode.Id:=100;
  FillChar(lNode.WorldTransform,SizeOf(lNode.WorldTransform),0);
  for I:=0 to 3 do lNode.WorldTransform[I*5]:=1;
  lNode.Mesh:=T3dMeshData.Create;
  SetLength(lNode.Mesh.Positions,10);
  for I:=0 to 9 do lNode.Mesh.Positions[I]:=Vector3d(I,0,0);
  lScene.AddNode(lNode);
  try
    lHammer := lRegistry.CreateTag('hammer', 64);
    lX := lRegistry.CreateTag('response-x', 64);
    lY := lRegistry.CreateTag('response-y', 64);
    ConfigureModel(lModel, lHammer, lX, lY);
    lModel.ScenarioEnabled := True;
    lModel.GeometryBindingMode := rgbmOscillation;
    lModel.Responses[0].IntensityOnly := True;
    lModel.Target3dComponentId := 'route-scene';
    lCatalog := TPointCatalog.Create;
    lSink := TPointBindingSink.Create;
    lSinkRef := lSink;
    RegisterRecorderModelPointTarget('route-scene', lCatalog, lSinkRef);
    Check(lService.Configure(lModel, lRegistry), lService.LastError);
    lEntry := Default(TRecorderFrfRouteEntry);
    lEntry.ChannelIndex := 0;
    lEntry.PointNumber := 1;
    lEntry.PointLabel := 'one';
    lService.Route.Add(lEntry);
    lMapping := Default(TRecorderFrfRouteBinding);
    lMapping.ChannelIndex := 0; lMapping.PointNumber := 7;
    lMapping.TargetNodeId := 100; lMapping.PointLabel := 'A';
    lMapping.SceneComponentId := 'route-scene';
    lService.Route.AddBinding(0, lMapping);
    lMapping.ChannelIndex := 1; lMapping.PointNumber := 8;
    lMapping.PointLabel := 'B';
    lService.Route.AddBinding(0, lMapping);
    lEntry.PointNumber := 2;
    lEntry.PointLabel := 'two';
    lService.Route.Add(lEntry);
    lService.Route.Save(lDirectory);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    PublishImpact(lRegistry, 1, 2);
    WaitForImpactCount(lService, 1);
    Check(lService.SelectRoutePoint(0, lError), lError);
    Check((Length(lSink.Bindings) = 2) and (lSink.Bindings[1].PointNumber = 8),
      'step mappings did not publish both channels');
    Check(lSink.Bindings[0].IntensityOnly and
      (lSink.Bindings[0].Mode=rgbmIntensity),
      'Route intensity-only response must publish an intensity circle, not motion');
    ForceDirectories(lService.Route.PointDirectory(0));
    lInvalidFile := TFileStream.Create(IncludeTrailingPathDelimiter(
      lService.Route.PointDirectory(0)) + 'curve.frf', fmCreate);
    lInvalidFile.Free;
    Check(lService.SaveRoutePoint(lError), lError);
    Check(lService.Route.CurrentIndex = 0, 'save advanced selected route point');
    Check(lService.RoutePointHasData, 'point session was not saved');
    Check(FileExists(IncludeTrailingPathDelimiter(lService.Route.PointDirectory(0)) +
      'frf' + PathDelim + 'session.mera'), 'route must save in frf/session.mera');
    Check(not FileExists(IncludeTrailingPathDelimiter(lService.Route.PointDirectory(0)) +
      'curve.frf'), 'obsolete curve.frf was written');
    Check(not DirectoryExists(IncludeTrailingPathDelimiter(lService.Route.PointDirectory(0)) +
      'aka'), 'new save created obsolete aka directory');
    Check(TRecorderFrfPointStore.Load(lService.Route.PointDirectory(0), lStored, lError), lError);
    Check((Length(lStored.Curves) = 2) and
      (Length(lStored.Impacts[0].Responses) = 2), 'point did not save all sensors');
    lStored.Curves[0].Magnitude[1]:=123;
    Check(TRecorderFrfPointStore.Save(lService.Route.PointDirectory(0),lStored,lError),lError);
    Check(lService.SelectRoutePoint(1, lError), lError);
    Check(Length(lSink.Bindings) = 0, 'empty step retained previous step geometry');
    lService.FillSnapshot(lView);
    Check(Length(lView.Results[irtTime].Curves) = 3,
      'missing point lost configured channel identities');
    Check((Length(lView.Results[irtTime].Curves[0].X) = 0) and
      (Length(lView.Results[irtTime].Curves[1].X) = 0) and
      (Length(lView.Results[irtTime].Curves[2].X) = 0),
      'missing point retained previous time samples');
    Check(lService.SelectRoutePoint(0, lError), lError);
    SamplePublished(123,'selected stored step before new impact');
    lService.FillSnapshot(lView);
    Check((Length(lView.Results[irtTime].Curves) = 3) and
      (Length(lView.Results[irtSpectrum].Curves) = 3) and
      (Length(lView.Results[irtFrfMagnitude].Curves) = 2), 'saved full presentation missing');
    Check(Abs(TimeResponsePeak(lView) - 16) < 1E-9, 'saved time data was not restored');
    PublishImpact(lRegistry, 4, 4);
    WaitForImpactCount(lService, 2);
    lService.BuildSessionSnapshot(lLive);
    SamplePublished(lLive.Curves[0].Magnitude[1],
      'fresh impact after saved step without reselection');
    Check(lService.SelectRoutePoint(0, lError), lError);
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 32) < 1E-9, 'stored point overwrote unsaved current time data');
    Check(lService.SelectRoutePoint(1, lError), lError);
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 32) < 1E-9, 'empty point discarded current acquisition');
    lMapping.ChannelIndex:=0; lMapping.PointNumber:=10; lMapping.PointLabel:='D';
    lService.Route.AddBinding(1,lMapping);
    Check(lService.SaveRoutePoint(lError), lError);
    Check(lService.Route.CurrentIndex = 1, 'save advanced second point');
    Check(lService.ShowSavedRoute(lError), lError);
    Check((Length(lSink.Bindings) = 3) and
      (lSink.Bindings[0].PointNumber = 7) and (lSink.Bindings[1].PointNumber = 8),
      'saved assembly did not use all step mappings');
    Check(lService.SelectRoutePoint(0, lError), lError);
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 16) < 1E-9, 'first saved point not restored');
    PublishImpact(lRegistry, 6, 6);
    WaitForImpactCount(lService, 3);
    lService.BuildSessionSnapshot(lBeforeReview);
    // Distinct saved curves prove both source identity and cursor-dependent
    // normalization; acquisition fixture alone has proportional responses.
    for I:=0 to 1 do
    begin
      Check(TRecorderFrfPointStore.Load(lService.Route.PointDirectory(I),lStored,lError),lError);
      for J:=0 to High(lStored.Curves) do
      begin
        lStored.Curves[J].FrequencyHz:=[0,1,2,3,4];
        for K:=0 to High(lStored.Curves[J].Magnitude) do
          lStored.Curves[J].Magnitude[K]:=2+I+J;
        lStored.Curves[J].Magnitude[2]:=8-I-J;
      end;
      Check(TRecorderFrfPointStore.Save(lService.Route.PointDirectory(I),lStored,lError),lError);
    end;
    // A partially measured route is reviewable; absent sessions must not add
    // empty curves or replace the runtime acquisition with disk data.
    lEntry.PointNumber := 3;
    lEntry.PointLabel := 'unsaved';
    lService.Route.Add(lEntry);
    lMapping.PointNumber := 9;
    lMapping.PointLabel := 'C';
    lService.Route.AddBinding(2, lMapping);
    Check(not lService.Route.AllComplete, 'partial route fixture is complete');
    Check(lService.SetResultReview(True, True, lError), lError);
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 16) < 1E-9,
      'review must display selected disk step despite unsaved acquisition');
    Check((Length(lSink.Bindings) = 3) and lSink.Bindings[0].ShowIntensityValues,
      'review did not publish all saved points with numeric labels');
    SamplePublished(2,'review saved first step');
    SetRecorderFrfDisplayRange(1,2);
    ConfigurePublishedIntensity;
    SetRecorderSelectedFrfFrequency(1);
    Check(lAdapter.Update(RecorderSelectedFrfFrequency),'review intensity update failed');
    Check(lAdapter.MarkerCount=3,'review intensity omitted saved point');
    lPreviousSize:=lAdapter.Marker(0).SizePixels;
    CheckNear(lPreviousSize,10,'review preset normalization at first frequency');
    Check(lAdapter.Marker(2).PointNumber=10,'second saved step point omitted');
    CheckNear(lAdapter.Marker(0).Position.X,6,'saved first point position');
    CheckNear(lAdapter.Marker(1).Position.X,7,'saved second point position');
    CheckNear(lAdapter.Marker(2).Position.X,9,'saved second step point position');
    Check(lAdapter.Marker(2).PointLabel='D = 3','second step sampled another point curve');
    for I:=0 to 2 do
      Check(lAdapter.Marker(I).Visible and (lAdapter.Marker(I).SizePixels>0) and
        lAdapter.Marker(I).ShowValue,'review point invisible or numeric value absent');
    SetRecorderSelectedFrfFrequency(2);
    Check(lAdapter.Update(RecorderSelectedFrfFrequency),'cursor update failed');
    Check(Abs(lPreviousSize-lAdapter.Marker(0).SizePixels)>1E-6,
      'normalized intensity did not change with cursor');
    CheckNear(lAdapter.Marker(0).SizePixels,40,'review normalization at second frequency');
    lModel.MarkerColor:=$002040FF;
    lService.SavePointBindings;
    Check((Length(lSink.Bindings)=3) and
      (lSink.Bindings[2].Color=$002040FF),'Display settings must update all saved review points');
    Check(lService.SelectRoutePoint(1, lError), lError);
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 32) < 1E-9,
      'review step did not load its own time realization');
    Check(Length(lSink.Bindings) = 3, 'review selection discarded all-step bindings');
    Check(lService.SelectRoutePoint(2, lError), lError);
    lService.FillSnapshot(lView);
    Check((Length(lView.Results[irtTime].Curves) = 3) and
      (Length(lView.Results[irtTime].Curves[0].X) = 0) and
      (Length(lView.Results[irtTime].Curves[1].X) = 0) and
      (Length(lView.Results[irtTime].Curves[2].X) = 0),
      'unsaved review step displayed unrelated time realization');
    Check(Length(lSink.Bindings) = 3,
      'unsaved review step discarded saved points');
    Check(lService.SetResultReview(False, False, lError), lError);
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 48) < 1E-9,
      'leaving review did not restore unsaved runtime acquisition');
    lService.BuildSessionSnapshot(lLive);
    Check(Length(lLive.Impacts) = 3, 'disk navigation mutated runtime history');
    for I:=0 to High(lBeforeReview.Impacts) do
    begin
      Check(lLive.Impacts[I].Sequence=lBeforeReview.Impacts[I].Sequence,
        'review changed impact identity');
      for K:=0 to High(lBeforeReview.Impacts[I].Excitation.Samples) do
      begin
        CheckNear(lLive.Impacts[I].Excitation.Samples[K].Value,
          lBeforeReview.Impacts[I].Excitation.Samples[K].Value,'review changed RAM excitation');
        CheckNear(lLive.Impacts[I].Excitation.Samples[K].TimeSeconds,
          lBeforeReview.Impacts[I].Excitation.Samples[K].TimeSeconds,'review changed RAM excitation time');
      end;
      for J:=0 to High(lBeforeReview.Impacts[I].Responses) do
        for K:=0 to High(lBeforeReview.Impacts[I].Responses[J].Samples) do
        begin
          CheckNear(lLive.Impacts[I].Responses[J].Samples[K].Value,
            lBeforeReview.Impacts[I].Responses[J].Samples[K].Value,'review changed RAM sample');
          CheckNear(lLive.Impacts[I].Responses[J].Samples[K].TimeSeconds,
            lBeforeReview.Impacts[I].Responses[J].Samples[K].TimeSeconds,'review changed RAM time');
        end;
    end;
    for I:=0 to High(lBeforeReview.Curves) do
      for K:=0 to High(lBeforeReview.Curves[I].Magnitude) do
      begin
        CheckNear(lLive.Curves[I].Magnitude[K],lBeforeReview.Curves[I].Magnitude[K],
          'review changed RAM FRF');
        CheckNear(lLive.Curves[I].ResponseSpectrum[K],lBeforeReview.Curves[I].ResponseSpectrum[K],
          'review changed RAM spectrum');
      end;
    Check(lService.SetResultReview(True, True, lError), lError);
    Check(lService.Route.SetDirectory(lDirectory + '-empty'), 'directory switch ignored');
    Check(not lService.Route[0].Captured and not lService.Route[1].Captured,
      'new object retained old saved flags');
    Check(not FileExists(lDirectory + '-empty' + PathDelim + 'route.ini'),
      'directory binding unexpectedly wrote route');
    lService.Revision;
    lService.FillSnapshot(lView);
    CheckNear(TimeResponsePeak(lView),48,'object switch lost unsaved RAM');
    Check(not lService.RoutePointHasData,'new object retained saved session');
    Check(not lService.SetResultReview(True,True,lError),'empty object reviewed old data');
    Check(lService.Route.SetDirectory(lDirectory), 'return directory switch ignored');
    Check(lService.Route[0].Captured and lService.Route[1].Captured,
      'return to saved object failed to rediscover sessions');
    lService.Revision;
    Check(lService.SetResultReview(True,True,lError),lError);
    Check(Length(lSink.Bindings)=3,'return to object failed to restore saved points');
    Check(lService.SetResultReview(False,False,lError),lError);
    lService.BuildSessionSnapshot(lLive);
    Check(Length(lLive.Impacts)=3,'object switches discarded runtime history');
    lSessionFile := TRecorderFrfPointStore.SessionFileName(lService.Route.PointDirectory(0));
    Check(RenameFile(lSessionFile, lSessionFile + '.test-backup'),
      'could not prepare corrupt session fixture');
    try
      lInvalidFile := TFileStream.Create(lSessionFile, fmCreate);
      lInvalidFile.Free;
      Check(not lService.SetResultReview(True, True, lError),
        'corrupt saved session was silently treated as an unsaved step');
      Check(lError <> '', 'corrupt session returned no diagnostic');
      lService.FillSnapshot(lView);
      Check(Abs(TimeResponsePeak(lView) - 48) < 1E-9,
        'failed review replaced unsaved runtime presentation');
    finally
      DeleteFile(lSessionFile);
      Check(RenameFile(lSessionFile + '.test-backup', lSessionFile),
        'could not restore saved session fixture');
    end;
    lService.UseLiveRoute;
    lService.FillSnapshot(lView);
    Check(Abs(TimeResponsePeak(lView) - 48) < 1E-9, 'live history not retained after disk navigation');
  finally
    UnregisterRecorderModelPointTarget('route-scene');
    lAdapter.Free;
    lScene.Free;
    lService.Free;
    lModel.Free;
    lRegistry.Free;
    lBus.Free;
  end;
end;

procedure TestFrfVertexColorModifier;
var lScene:T3dScene; lNode:T3dNode; lComponent,lClone:TRecorder3dComponent;
  lController:TRecorder3dImpactBindingController;
  lSink:IRecorderModelPointBindingSink;
  lBindings:array[0..1] of TRecorderModelPointBinding;
  lCurves:array[0..1] of TRecorderFrfCurveData;
  lRepo:TRecorderFrfRepository; lProvider:IRecorderFrfProvider;
  lAdapter:TRecorder3dVertexColorAdapter; lIndex:Integer;
begin
  lScene:=T3dScene.Create;
  lComponent:=TRecorder3dComponent.Create;
  lClone:=TRecorder3dComponent.Create;
  lAdapter:=TRecorder3dVertexColorAdapter.Create;
  lRepo:=TRecorderFrfRepository.Create;
  lProvider:=lRepo;
  try
    lComponent.Id:='scene-color';
    lNode:=T3dNode.Create; lNode.Id:=77;
    SetIdentity(lNode.WorldTransform);
    lNode.Mesh:=T3dMeshData.Create;
    SetLength(lNode.Mesh.Positions,2);
    lNode.Mesh.Positions[0]:=Vector3d(0,0,0);
    lNode.Mesh.Positions[1]:=Vector3d(10,0,0);
    lNode.Mesh.BasePositions:=Copy(lNode.Mesh.Positions);
    SetLength(lNode.Mesh.LogicalVertices,2);
    for lIndex:=0 to 1 do
    begin
      lNode.Mesh.LogicalVertices[lIndex].Id:=lIndex;
      SetLength(lNode.Mesh.LogicalVertices[lIndex].CornerIndices,1);
      lNode.Mesh.LogicalVertices[lIndex].CornerIndices[0]:=lIndex;
      lBindings[lIndex]:=Default(TRecorderModelPointBinding);
      lBindings[lIndex].CurveId:=lIndex+1;
      lBindings[lIndex].TargetNodeId:=77;
      lBindings[lIndex].ModifierTargetNodeId:=77;
      lBindings[lIndex].PointNumber:=lIndex+1;
      lBindings[lIndex].PointLabel:='route-'+IntToStr(lIndex+1);
      lBindings[lIndex].Gain:=1;
      lBindings[lIndex].Enabled:=True;
      lBindings[lIndex].CreateColorModifier:=True;
      lBindings[lIndex].GradientEnabled:=True;
      lBindings[lIndex].HideAnchors:=True;
      lBindings[lIndex].EnvelopeXEnabled:=True;
      lBindings[lIndex].EnvelopeX:=2;
      lCurves[lIndex].Id:=lIndex+1;
      lCurves[lIndex].FrequencyHz:=[100.0,200.0];
      lCurves[lIndex].Magnitude:=[Double(lIndex+1),Double(2-lIndex)];
      lCurves[lIndex].Amplitude:=[Double(2-lIndex),Double(lIndex+1)];
      lCurves[lIndex].PhaseRadians:=[0.0,0.0];
      lCurves[lIndex].Coherence:=[1.0,1.0];
    end;
    lScene.AddNode(lNode);
    lController:=TRecorder3dImpactBindingController.Create(lComponent,lScene);
    lSink:=lController;
    lSink.PublishBindings('frf-color','scene-color',lBindings);
    Check(lComponent.VertexColorAnchorCount=2,'FRF creates color anchors');
    Check(lComponent.GradientStripCount=1,'FRF creates shared CAD gradient');
    Check(lComponent.VertexColorAnchors[0].Name='route-1','anchor route label');
    Check(not lComponent.VertexColorAnchors[0].ShowValueLabel,'FRF anchors hidden');
    Check(lComponent.VertexColorAnchors[1].LogicalVertexId=1,'point mapped to logical index');
    lSink.PublishBindings('frf-color','scene-color',lBindings);
    Check((lComponent.VertexColorAnchorCount=2) and
      (lComponent.GradientStripCount=1),'republishing creates no duplicate modifier');
    lClone.Assign(lComponent);
    Check((lClone.FrfBindings[0].PointLabel='route-1') and
      lClone.FrfBindings[0].CreateColorModifier and
      lClone.VertexColorAnchors[0].EnvelopeXEnabled and
      (lClone.VertexColorAnchors[0].FrfCurveId=1) and
      lClone.GradientStrips[0].CadGradient,'modifier copy preserves source and envelope');
    Check(lRepo.Publish(lCurves),'publish color FRF');
    lAdapter.Configure(lComponent,nil);
    lAdapter.ConfigureFrfProvider(lProvider);
    SetRecorderSelectedFrfFrequency(100);
    lAdapter.AttachScene(lScene);
    Check((lNode.Mesh.VertexColors[0].R=255) and
      (lNode.Mesh.VertexColors[0].G=255),'half maximum FRF maps yellow');
    Check((lNode.Mesh.VertexColors[1].R=255) and
      (lNode.Mesh.VertexColors[1].G=0),'maximum FRF maps red');
    SetRecorderSelectedFrfFrequency(200);
    Check(lAdapter.ApplyChanged,'pinned cursor frequency updates colors');
    Check((lNode.Mesh.VertexColors[0].G=0) and
      (lNode.Mesh.VertexColors[1].G=255),'frequency changes swap color intensities');
    for lIndex:=0 to 1 do lBindings[lIndex].IntensitySource:=risAmplitude;
    lSink.PublishBindings('frf-color','scene-color',lBindings);
    lAdapter.AttachScene(lScene);
    Check((lNode.Mesh.VertexColors[0].G=255) and
      (lNode.Mesh.VertexColors[1].G=0),'amplitude source independent of FRF');
    lBindings[0].CreateColorModifier:=False;
    lSink.PublishBindings('frf-color','scene-color',lBindings);
    Check(lComponent.VertexColorAnchorCount=1,'disabling modifier removes obsolete anchors');
    lSink.RemoveBindings('frf-color');
    Check(lComponent.VertexColorAnchorCount=0,'removing source removes generated anchors');
    lAdapter.AttachScene(lScene);
    Check(Length(lNode.Mesh.VertexColors)=0,'removing last modifier restores mesh colors');
  finally
    lAdapter.Free;
    lSink:=nil;
    lProvider:=nil;
    lClone.Free; lComponent.Free; lScene.Free;
  end;
end;

procedure TestTriggerModeLifecycle;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  ErrorText: string;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 1024),
      Registry.CreateTag('response-x', 1024), Registry.CreateTag('response-y', 1024));
    Check(Service.Configure(Model, Registry), Service.LastError);
    Service.SetTriggerEnabled(False);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter, nil,
      '', '', 0, nil, rstStopToView));
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.TriggerEnabled and (Snapshot.State = ihsIdle),
      'Preview armed despite disabled trigger mode');
    PublishImpact(Registry, 1, 2);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.ImpactCount = 0, 'disabled trigger captured an impact');

    Service.SetTriggerEnabled(True);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.TriggerEnabled and (Snapshot.State = ihsArmed),
      'enabling trigger during Preview did not arm');
    PublishImpact(Registry, 3, 2);
    WaitForImpactCount(Service, 1);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.TriggerEnabled and (Snapshot.State = ihsArmed),
      'trigger did not rearm after first impact');
    PublishImpact(Registry, 5, 2);
    WaitForImpactCount(Service, 2);

    Service.SetTriggerEnabled(False);
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.TriggerEnabled and (Snapshot.State = ihsIdle),
      'disabling trigger did not stop waiting');
    PublishImpact(Registry, 7, 2);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.ImpactCount = 2, 'disabled trigger added an impact');

    Bus.Publish(TRecorderEventBus.MakeEvent(rceStopped));
    Service.SetTriggerEnabled(True);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.TriggerEnabled and (Snapshot.State = ihsIdle),
      'selecting trigger before Preview started acquisition');
    Bus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter, nil,
      '', '', 0, nil, rstStopToView));
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.TriggerEnabled and (Snapshot.State = ihsArmed),
      'Preview did not arm the previously selected trigger');
    Check(Service.Configure(Model, Registry), Service.LastError);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.TriggerEnabled and (Snapshot.State = ihsArmed),
      'reconfigure while Preview active lost trigger arming');
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.TriggerEnabled and not Snapshot.CanCapturePortion,
      'manual portion did not exclusively replace trigger mode');
    Bus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter, nil,
      '', '', 0, nil, rstViewToStop));
    Service.FillSnapshot(Snapshot);
    Check((Snapshot.State = ihsIdle) and not Snapshot.CanCapturePortion,
      'Preview stop did not cancel pending manual portion');
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    PublishImpact(Registry, 9, 2);
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.TriggerEnabled and (Snapshot.ImpactCount = 0) and
      Snapshot.CanCapturePortion, 'cancelled portion resumed after Preview restart');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestRouteAutomation;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  AtPoint, NextStep, PointTag: TRecorderTag;
  Entry: TRecorderFrfRouteEntry;
  Stored: TRecorderImpactSessionSnapshot;
  Snapshot: TRecorderImpactHammerSnapshot;
  Times, Values: array[0..7] of Double;
  Directory, ErrorText: string;
  Id: TGuid;
  Cursor, Deadline: QWord;
  Value: Double;
  I: Integer;
  BlockingFile: TFileStream;

  procedure PublishRings(AScale: Double);
  const Names: array[0..2] of string = ('hammer', 'response-x', 'response-y');
  var Channel, SampleIndex: Integer;
  begin
    for Channel := 0 to 2 do
    begin
      for SampleIndex := 0 to 7 do
      begin
        Times[SampleIndex] := 1 + SampleIndex / 8;
        Values[SampleIndex] := AScale * (Channel + 1) * (2 + Sin(SampleIndex));
      end;
      Registry.PublishBlock(Names[Channel], Times, Values, 8, True);
    end;
  end;

  procedure WaitCommand(AValue: Double);
  var UntilTick: QWord; Got: Boolean; CommandValue: Double;
  begin
    UntilTick := GetTickCount64 + 4000;
    repeat
      Got := NextStep.ReadExternalWrite(Cursor, CommandValue);
      if Got then
      begin CheckNear(CommandValue, AValue, 'auto command ordering'); Exit end;
      Sleep(5);
    until GetTickCount64 >= UntilTick;
    Service.FillSnapshot(Snapshot);
    raise Exception.Create('auto command timed out: ' + Snapshot.StatusText);
  end;

begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  Cursor := 0;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 16),
      Registry.CreateTag('response-x', 16), Registry.CreateTag('response-y', 16));
    for I := 0 to 2 do Registry.Tags[I].PollFrequencyHz := 8;
    AtPoint := Registry.CreateTag('at-point', 16);
    NextStep := Registry.CreateTag('next-step', 16);
    NextStep.ExternalWriteAllowed := True;
    PointTag := Registry.CreateTag('point-number', 16);
    Model.ScenarioEnabled := True;
    Model.RouteAtPointTagId := AtPoint.Id;
    Model.RouteNextStepTagId := NextStep.Id;
    Model.RoutePointTagId := PointTag.Id;
    Model.RouteNextStepPulseMs := 100;
    Check(Service.Configure(Model, Registry), Service.LastError);
    Entry := Default(TRecorderFrfRouteEntry);
    Entry.PointLabel := 'auto-one'; Entry.PointNumber := 1; Service.Route.Add(Entry);
    Entry.PointLabel := 'auto-two'; Entry.PointNumber := 2; Service.Route.Add(Entry);
    CreateGuid(Id);
    Directory := IncludeTrailingPathDelimiter(GetTempDir) + 'frf-auto-' + GuidToString(Id);
    Service.Route.Save(Directory);
    Service.SetTriggerEnabled(False);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    Registry.PublishValue(PointTag, 0, 1);
    Registry.PublishValue(AtPoint, 0, 0);
    PublishRings(2);
    Service.SetRouteAutoMode(True);
    Registry.PublishValue(AtPoint, 1, 1);
    WaitCommand(1);
    Check(TRecorderFrfPointStore.Load(Service.Route.PointDirectory(0), Stored, ErrorText), ErrorText);
    CheckNear(Stored.Impacts[0].Excitation.Samples[0].Value, 4,
      'auto pulse preceded complete MERA save');
    WaitCommand(0);
    Sleep(150);
    Check(not NextStep.ReadExternalWrite(Cursor, Value), 'held AtPoint repeated capture');
    Service.SetRouteAutoMode(True);
    Sleep(150);
    Check(not NextStep.ReadExternalWrite(Cursor, Value), 'repeated enabling reset latch');
    // The saved point is skipped without replacing the current RAM rings.
    PublishRings(9);
    Registry.PublishValue(AtPoint, 2, 0); Sleep(60);
    Registry.PublishValue(AtPoint, 3, 1);
    WaitCommand(1); WaitCommand(0);
    Check(TRecorderFrfPointStore.Load(Service.Route.PointDirectory(0), Stored, ErrorText), ErrorText);
    CheckNear(Stored.Impacts[0].Excitation.Samples[0].Value, 4,
      'auto skip overwrote saved data');
    Model.RouteAutoOverwrite := True;
    Registry.PublishValue(AtPoint, 4, 0); Sleep(60);
    Registry.PublishValue(AtPoint, 5, 1);
    WaitCommand(1); WaitCommand(0);
    Check(TRecorderFrfPointStore.Load(Service.Route.PointDirectory(0), Stored, ErrorText), ErrorText);
    CheckNear(Stored.Impacts[0].Excitation.Samples[0].Value, 18,
      'auto overwrite did not replace saved data');
    // No UI refresh or PollRouteTagSync: service must track the step itself.
    Service.SetRouteTagSync(True);
    Registry.PublishValue(AtPoint, 6, 0);
    Registry.PublishValue(PointTag, 6, 2);
    Sleep(80);
    Registry.PublishValue(AtPoint, 7, 1);
    WaitCommand(1);
    Check(TRecorderFrfPointStore.Exists(Service.Route.PointDirectory(1)),
      'hidden-widget automation saved wrong step');
    Service.SetRouteAutoMode(False);
    WaitCommand(0);
    CheckNear(NextStep.SignalBuffer.LatestValue, 0, 'manual cancel left command high');
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.RouteAutoMode, 'manual cancel left auto enabled');
    NextStep.ExternalWriteAllowed := False;
    Service.SetRouteAutoMode(True);
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.RouteAutoMode, 'readonly command allowed auto');
    NextStep.ExternalWriteAllowed := True;
    Service.SetRouteAutoMode(True);
    WaitCommand(1);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStopped));
    WaitCommand(0);
    Deadline := GetTickCount64 + 150;
    repeat Sleep(5) until GetTickCount64 >= Deadline;
    Check(not NextStep.ReadExternalWrite(Cursor, Value), 'stopped auto issued another command');
    // A file in place of the destination directory must prevent motion.
    Service.Route.Save(Directory + '-failure');
    ForceDirectories(Service.Route.Directory);
    BlockingFile := TFileStream.Create(Service.Route.PointDirectory(1), fmCreate);
    BlockingFile.Free;
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    Registry.PublishValue(AtPoint, 8, 0);
    Service.SetRouteAutoMode(True);
    Registry.PublishValue(AtPoint, 9, 1);
    Deadline := GetTickCount64 + 4000;
    repeat
      Sleep(10); Service.FillSnapshot(Snapshot);
      if not Snapshot.RouteAutoMode then Break;
    until GetTickCount64 >= Deadline;
    Check(not Snapshot.RouteAutoMode, 'save failure did not disable automation');
    Check(not NextStep.ReadExternalWrite(Cursor, Value), 'save failure issued next-step pulse');
    // Destruction must restore zero without a UI tick.
    Service.Route.SetDirectory(Directory);
    Service.SetRouteAutoMode(True);
    WaitCommand(1);
    FreeAndNil(Service);
    WaitCommand(0);
    Writeln('RESULT RouteAutomation capture/save/skip/overwrite/latch/pulse/hidden/cancel passed');
  finally
    Service.Free; Model.Free; Registry.Free; Bus.Free;
  end;
end;

procedure TestRingPortionIndependentEpochs;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  Stored: TRecorderImpactSessionSnapshot;
  Entry: TRecorderFrfRouteEntry;
  ErrorText, Directory: string;
  Id: TGuid;
  I: Integer;
  Deadline: QWord;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 8),
      Registry.CreateTag('response-x', 8), Registry.CreateTag('response-y', 8));
    Registry.FindByName('hammer').PollFrequencyHz := 8;
    Registry.FindByName('response-x').PollFrequencyHz := 8;
    Registry.FindByName('response-y').PollFrequencyHz := 8;
    Model.ScenarioEnabled := True;
    Check(Service.Configure(Model, Registry), Service.LastError);
    Entry := Default(TRecorderFrfRouteEntry);
    Entry.PointNumber := 1;
    Entry.PointLabel := 'ring';
    Service.Route.Add(Entry);
    CreateGuid(Id);
    Directory := IncludeTrailingPathDelimiter(GetTempDir) + 'frf-ring-' + GuidToString(Id);
    Service.Route.Save(Directory);
    Service.SetTriggerEnabled(False);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    for I := 0 to 7 do
      Registry.PublishValue('hammer', 3.46 + I / 8, 10 + I);
    for I := 0 to 2 do
    begin
      Registry.PublishValue('response-x', 11.22 + I / 8, 20 + I);
      Registry.PublishValue('response-y', 11.22 + I / 8, 30 + I);
    end;
    Registry.FindByName('hammer').PollFrequencyHz := 8;
    Registry.FindByName('response-x').PollFrequencyHz := 8;
    Registry.FindByName('response-y').PollFrequencyHz := 8;
    Check(Service.TryCaptureRingPortion(ErrorText), ErrorText);
    Service.FillSnapshot(Snapshot);
    Check((Length(Snapshot.Results[irtTime].Curves[0].X) = 8) and
      (Length(Snapshot.Results[irtTime].Curves[1].X) = 3),
      'partial independent rings were hidden or padded to full duration');
    CheckNear(Snapshot.Results[irtTime].Curves[1].Y[0], 20,
      'partial response samples were replaced');
    Deadline := GetTickCount64 + 3000;
    repeat
      Service.FillSnapshot(Snapshot);
      if Snapshot.CanCapturePortion then Break;
      Sleep(10);
    until GetTickCount64 >= Deadline;
    Check(Length(Snapshot.Results[irtPhase].Curves) = 0,
      'independent epochs fabricated a phase response');
    Check(Service.SaveRoutePoint(ErrorText), ErrorText);
    Check(TRecorderFrfPointStore.Load(Service.Route.PointDirectory(0),
      Stored, ErrorText), ErrorText);
    Check((Length(Stored.Impacts) = 1) and
      (Length(Stored.Impacts[0].Excitation.Samples) = 8) and
      (Length(Stored.Impacts[0].Responses[0].Samples) = 3),
      'Save did not use the displayed partial ring');
    CheckNear(Stored.Impacts[0].Excitation.Samples[0].TimeSeconds, 3.46,
      'Save changed excitation epoch');
    CheckNear(Stored.Impacts[0].Responses[0].Samples[0].TimeSeconds, 11.22,
      'Save changed response epoch');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestRingLastBlockFallback;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  Session: TRecorderImpactSessionSnapshot;
  Times, Values: array[0..7] of Double;
  Names: array[0..2] of string;
  ErrorText: string;
  Channel, I: Integer;
  Deadline: QWord;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 32),
      Registry.CreateTag('response-x', 32), Registry.CreateTag('response-y', 32));
    Check(Service.Configure(Model, Registry), Service.LastError);
    Service.SetTriggerEnabled(False);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    Names[0] := 'hammer'; Names[1] := 'response-x'; Names[2] := 'response-y';
    for Channel := 0 to 2 do
    begin
      for I := 0 to 7 do
      begin Times[I] := 1 + Channel * 30 + I / 8; Values[I] := -100 end;
      Registry.PublishBlock(Names[Channel], Times, Values, 8, True);
      for I := 0 to 7 do
      begin Times[I] := 10 + Channel * 30 + I / 8; Values[I] := 2 + Channel + Sin(I) end;
      Registry.PublishBlock(Names[Channel], Times, Values, 8, True);
    end;
    Check(Service.TryCaptureRingPortion(ErrorText), ErrorText);
    for Channel := 0 to 2 do
    begin
      for I := 0 to 7 do
      begin Times[I] := 20 + Channel * 30 + I / 8; Values[I] := 999 end;
      Registry.PublishBlock(Names[Channel], Times, Values, 8, True);
    end;
    Deadline := GetTickCount64 + 3000;
    repeat
      Service.FillSnapshot(Snapshot);
      if Snapshot.CanCapturePortion then Break;
      Sleep(10);
    until GetTickCount64 >= Deadline;
    Check(Pos('Последние блоки без синхронизации', Snapshot.StatusText) > 0,
      'Unsynchronized last-block fallback lacks explicit status: ' + Snapshot.StatusText);
    Check(Length(Snapshot.Results[irtFrfMagnitude].Curves) = 2,
      'Last-block fallback did not calculate both FRFs: ' + Snapshot.StatusText);
    for Channel := 0 to 2 do
    begin
      Check(Length(Snapshot.Results[irtTime].Curves[Channel].Y) = 8,
        'Fallback did not select the latest block only');
      CheckNear(Snapshot.Results[irtTime].Curves[Channel].Y[0], 2 + Channel,
        'Fallback read a newer block after the click');
    end;
    Service.BuildSessionSnapshot(Session);
    CheckNear(Session.Impacts[0].Excitation.Samples[0].TimeSeconds, 10,
      'Fallback destroyed original excitation time');
    CheckNear(Session.Impacts[0].Responses[0].Samples[0].TimeSeconds, 40,
      'Fallback destroyed original response time');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestRingPortionImmediate;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  ErrorText: string;
  I: Integer;
  Deadline: QWord;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 8),
      Registry.CreateTag('response-x', 8), Registry.CreateTag('response-y', 8));
    Registry.FindByName('hammer').PollFrequencyHz := 8;
    Registry.FindByName('response-x').PollFrequencyHz := 8;
    Registry.FindByName('response-y').PollFrequencyHz := 8;
    Check(Service.Configure(Model, Registry), Service.LastError);
    Service.SetTriggerEnabled(False);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    for I := 0 to 7 do
    begin
      Registry.PublishValue('hammer', 1 + I / 8, 1 + Sin(I));
      Registry.PublishValue('response-x', 1 + I / 8, 2 + Sin(I));
      Registry.PublishValue('response-y', 1 + I / 8, 3 + Sin(I));
    end;
    Registry.FindByName('hammer').PollFrequencyHz := 8;
    Registry.FindByName('response-x').PollFrequencyHz := 8;
    Registry.FindByName('response-y').PollFrequencyHz := 8;
    Check(Service.TryCaptureRingPortion(ErrorText), ErrorText);
    Service.FillSnapshot(Snapshot);
    Check(Length(Snapshot.Results[irtTime].Curves) = 3,
      'ring portion did not immediately publish channel identities');
    for I := 0 to 2 do
      Check(Length(Snapshot.Results[irtTime].Curves[I].X) = 8,
        'exact Fs times one second required an extra endpoint sample');
    CheckNear(Snapshot.Results[irtTime].Curves[0].X[7], 0.875,
      'ring capture changed raw sample spacing');
    Deadline := GetTickCount64 + 3000;
    repeat
      Service.FillSnapshot(Snapshot);
      if Snapshot.CanCapturePortion then Break;
      Sleep(10);
    until GetTickCount64 >= Deadline;
    Check(Snapshot.CanCapturePortion, 'ring DSP did not finish');
    Check(Length(Snapshot.Results[irtFrfMagnitude].Curves) = 2,
      'exact N-sample ring did not calculate both FRFs: ' + Snapshot.StatusText);
    for I := 8 to 19 do
    begin
      Registry.PublishValue('hammer', 1 + I / 8, I);
      Registry.PublishValue('response-x', 1 + I / 8, 2 * I);
      Registry.PublishValue('response-y', 1 + I / 8, 3 * I);
    end;
    Registry.FindByName('hammer').PollFrequencyHz := 8;
    Registry.FindByName('response-x').PollFrequencyHz := 8;
    Registry.FindByName('response-y').PollFrequencyHz := 8;
    Check(Service.TryCaptureRingPortion(ErrorText), ErrorText);
    Service.FillSnapshot(Snapshot);
    Check(Length(Snapshot.Results[irtTime].Curves[0].Y) = 8,
      'second ring capture lost wrapped samples');
    for I := 0 to 7 do
      CheckNear(Snapshot.Results[irtTime].Curves[0].Y[I], 12 + I,
        'wrapped ring is not chronological or second capture reused first');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestManualPortionTimeoutRetry;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  Session: TRecorderImpactSessionSnapshot;
  ErrorText: string;
  I: Integer;
  T: Double;
  Deadline, RevisionBefore: QWord;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 1024),
      Registry.CreateTag('response-x', 1024), Registry.CreateTag('response-y', 1024));
    Check(Service.Configure(Model, Registry), Service.LastError);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    PublishImpact(Registry, 1, 2);
    WaitForImpactCount(Service, 1);
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    Registry.PublishValue('hammer', 3, 1);
    Registry.PublishValue('response-x', 3, 2);
    RevisionBefore := Service.Revision;
    Deadline := GetTickCount64 + 6500;
    { Exercise the actual UI polling entry, not a private deadline hook. The
      missing response-y must time out without deleting the completed impact. }
    repeat
      Sleep(25);
    until (Service.Revision <> RevisionBefore) or (GetTickCount64 >= Deadline);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.CanCapturePortion and (Snapshot.ImpactCount = 1),
      'incomplete manual portion did not time out or erased previous impact');
    Check(Pos('response-y', Service.LastError) > 0,
      'timeout did not identify the channel with no post-click data');
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    Check(Service.LastError = '', 'accepted retry retained timeout error');
    for I := 0 to 10 do
    begin
      T := 5 + I / 8;
      Registry.PublishValue('response-x', T, 2);
      Registry.PublishValue('response-y', T, 3);
      Registry.PublishValue('hammer', T, 1);
    end;
    WaitForImpactCount(Service, 2);
    Service.BuildSessionSnapshot(Session);
    CheckNear(Session.Impacts[0].Excitation.Samples[0].TimeSeconds,
      0.875, 'timeout/retry changed previous excitation');
    CheckNear(Session.Impacts[1].Excitation.Samples[0].TimeSeconds,
      5, 'retry reused data from timed-out acquisition');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestManualPortion;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  Session: TRecorderImpactSessionSnapshot;
  ErrorText: string;
  I, Channel: Integer;
  T: Double;
  Times, Values: array[0..12] of Double;
  Names: array[0..2] of string;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 1024),
      Registry.CreateTag('response-x', 1024), Registry.CreateTag('response-y', 1024));
    Check(Service.Configure(Model, Registry), Service.LastError);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    for I := 0 to 8 do
    begin
      T := I / 8;
      Registry.PublishValue('response-x', T, 2);
      Registry.PublishValue('response-y', T, 3);
      Registry.PublishValue('hammer', T, 1);
    end;
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.CanCapturePortion, 'manual portion unavailable while armed');
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    Check(not Service.TryCapturePortion(ErrorText), 'duplicate portion accepted');
    Service.FillSnapshot(Snapshot);
    Check(not Snapshot.CanCapturePortion, 'busy portion button remains enabled');
    for I := 9 to 18 do
    begin
      T := I / 8;
      Registry.PublishValue('response-x', T, 2 + Sin(T));
      Registry.PublishValue('response-y', T, 3 + Sin(T));
      Registry.PublishValue('hammer', T, 1 + Sin(T));
    end;
    WaitForImpactCount(Service, 1);
    Service.BuildSessionSnapshot(Session);
    CheckNear(Session.Impacts[0].Excitation.Samples[0].TimeSeconds,
      9 / 8, 'portion included pre-click excitation');
    Check(Session.Impacts[0].Responses[0].Samples[0].TimeSeconds > 1,
      'portion included pre-click response');
    Check(Length(Session.Impacts[0].Responses) = 2, 'portion lost response channel');
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.CanCapturePortion, 'completed portion did not return idle');
    PublishImpact(Registry, 4, 2);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.ImpactCount = 1, 'one-shot retriggered automatically');
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    Service.StopMeasurement;
    PublishImpact(Registry, 6, 2);
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.ImpactCount = 1, 'stop did not cancel pending portion');
    Service.ArmMeasurement;
    PublishImpact(Registry, 8, 2);
    WaitForImpactCount(Service, 2);
    Service.BuildSessionSnapshot(Session);
    Check(Length(Session.Impacts) = 2, 'normal trigger lost previous portion');
    Service.StopMeasurement;
    Registry.FindByName('response-x').PollFrequencyHz := 4;
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    Registry.PublishValue('hammer', 10, 1);
    Registry.PublishValue('response-x', 10.05, 2);
    Registry.PublishValue('response-y', 10.0625, 3);
    for I := 1 to 12 do
    begin
      if I mod 2 = 0 then
        Registry.PublishValue('response-x', 10.05 + I / 8, 2);
      Registry.PublishValue('response-y', 10.0625 + I / 8, 3);
      Registry.PublishValue('hammer', 10 + I / 8, 1);
    end;
    WaitForImpactCount(Service, 3);
    Service.BuildSessionSnapshot(Session);
    CheckNear(Session.Impacts[2].Excitation.Samples[0].TimeSeconds,
      10.125, 'mixed-Fs portion did not wait for new response coverage');
    CheckNear(Session.Impacts[2].Responses[0].Samples[0].TimeSeconds,
      10.05, 'mixed-Fs portion lost post-click interpolation boundary');
    Names[0] := 'hammer'; Names[1] := 'response-x'; Names[2] := 'response-y';
    for Channel := 2 downto 0 do
    begin
      for I := 0 to 12 do
      begin
        Times[I] := 12 + I / 8;
        Values[I] := Channel + 1;
      end;
      Registry.PublishBlock(Names[Channel], Times, Values, Length(Times), True);
    end;
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    for Channel := 2 downto 0 do
    begin
      for I := 0 to 12 do
      begin
        Times[I] := 14 + I / 8;
        Values[I] := Channel + 1;
      end;
      Registry.PublishBlock(Names[Channel], Times, Values, Length(Times), True);
    end;
    WaitForImpactCount(Service, 4);
    Service.BuildSessionSnapshot(Session);
    CheckNear(Session.Impacts[3].Excitation.Samples[0].TimeSeconds,
      14, 'portion replayed already published block');
    CheckNear(Session.Impacts[3].Responses[0].Samples[0].TimeSeconds,
      14, 'portion preloaded a pre-click response block');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestManualPortionResponseAhead;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  Session: TRecorderImpactSessionSnapshot;
  ErrorText: string;
  I: Integer;
  T: Double;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  Service := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(Model, Registry.CreateTag('hammer', 1024),
      Registry.CreateTag('response-x', 1024), Registry.CreateTag('response-y', 1024));
    Check(Service.Configure(Model, Registry), Service.LastError);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    Registry.PublishValue('hammer', 1, 1);
    Registry.PublishValue('response-x', 1.5, 22);
    Registry.PublishValue('response-y', 1.75, 33);
    Check(Service.TryCapturePortion(ErrorText), ErrorText);
    { These force samples are delivered after the click but their timestamps
      precede the response data already present at the click. They must not
      create a capture that depends on pre-click response history. }
    Registry.PublishValue('hammer', 1.25, 100);
    Registry.PublishValue('hammer', 1.5, 100);
    Registry.PublishValue('hammer', 1.75, 100);
    Service.FillSnapshot(Snapshot);
    Check((Snapshot.ImpactCount = 0) and not Snapshot.CanCapturePortion,
      'queued pre-boundary force started or completed the portion');
    Registry.PublishValue('hammer', 1.875, 1);
    Registry.PublishValue('response-x', 1.9, 2);
    Registry.PublishValue('response-y', 2, 3);
    Registry.PublishValue('hammer', 2, 1);
    for I := 1 to 10 do
    begin
      T := 2 + I / 8;
      Registry.PublishValue('response-x', T, 2);
      Registry.PublishValue('response-y', T, 3);
      Registry.PublishValue('hammer', T, 1);
    end;
    WaitForImpactCount(Service, 1);
    Service.BuildSessionSnapshot(Session);
    CheckNear(Session.Impacts[0].Excitation.Samples[0].TimeSeconds,
      2, 'response-ahead capture used a stale force timestamp');
    CheckNear(Session.Impacts[0].Responses[0].Samples[0].TimeSeconds,
      1.9, 'response-ahead capture used pre-click response-x');
    CheckNear(Session.Impacts[0].Responses[1].Samples[0].TimeSeconds,
      2, 'response-ahead capture used pre-click response-y');
    Service.FillSnapshot(Snapshot);
    Check(Snapshot.CanCapturePortion, 'response-ahead capture did not finish');
    Check(Length(Snapshot.Results[irtFrfMagnitude].Curves) = 2,
      'response-ahead capture did not calculate both FRF curves');
  finally
    Service.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure TestResponseSamplingRates;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Service: TRecorderImpactHammerService;
  Snapshot: TRecorderImpactHammerSnapshot;
  Session: TRecorderImpactSessionSnapshot;
  Filter: TRecorderImpactFilterWindow;
  ErrorText: string;
  Times, Values: array of Double;
  Rates: array[0..2] of Double;
  Names: array[0..2] of string;
  CaseIndex, Channel, I: Integer;
  T: Double;
begin
  Names[0] := 'hammer'; Names[1] := 'response-x'; Names[2] := 'response-y';
  for CaseIndex := 0 to 2 do
  begin
    Bus := TRecorderEventBus.Create;
    Registry := TRecorderTagRegistry.Create(Bus);
    Model := TRecorderImpactHammerComponent.Create;
    Service := TRecorderImpactHammerService.Create;
    try
      Rates[0] := 64;
      if CaseIndex=0 then begin Rates[1]:=32; Rates[2]:=128; end
      else if CaseIndex=1 then begin Rates[1]:=128; Rates[2]:=32; end
      else begin Rates[1]:=64; Rates[2]:=64; end;
      for Channel:=0 to 2 do
        Registry.CreateTag(Names[Channel],1024).PollFrequencyHz:=Rates[Channel];
      ConfigureModel(Model,Registry.FindByName(Names[0]),
        Registry.FindByName(Names[1]),Registry.FindByName(Names[2]));
      Model.SampleRateHz:=64; Model.CaptureSamples:=64;
      Model.PretriggerSamples:=8; Model.FftSize:=64;
      Model.WelchSegmentSize:=32;
      Check(Service.Configure(Model,Registry),Service.LastError);
      Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
      // Publish native response timelines first; their prehistory must survive
      // the trigger and a higher-rate response must not be decimated by capture.
      for Channel:=2 downto 0 do
      begin
        SetLength(Times,Round(2*Rates[Channel])+1);
        SetLength(Values,Length(Times));
        for I:=0 to High(Times) do
        begin
          T:=-0.25+I/Rates[Channel]; Times[I]:=T+1;
          if T<0 then Values[I]:=0
          else Values[I]:=8*Exp(-10*T)*Max(1,Channel+1);
        end;
        Registry.PublishBlock(Names[Channel],Times,Values,Length(Times),True);
      end;
      WaitForImpactCount(Service,1);
      Service.FillSnapshot(Snapshot);
      Service.BuildSessionSnapshot(Session);
      Check(Length(Session.Impacts)=1,'native capture missing');
      for Channel:=0 to 1 do
      begin
        Check(Length(Session.Impacts[0].Responses[Channel].Samples)>=
          Round(Rates[Channel+1]),'native higher-rate samples were decimated');
        CheckNear(Session.Impacts[0].Responses[Channel].Samples[1].TimeSeconds-
          Session.Impacts[0].Responses[Channel].Samples[0].TimeSeconds,
          1/Rates[Channel+1],'native response sample spacing changed');
      end;
      Check(Length(Snapshot.Results[irtFrfMagnitude].Curves)=2,'different Fs FRF missing');
      for Channel:=0 to 1 do
      begin
        I:=High(Snapshot.Results[irtFrfMagnitude].Curves[Channel].X);
        Check(I>=0,'empty FRF response: '+Service.LastError+' '+Snapshot.StatusText);
        CheckNear(Snapshot.Results[irtFrfMagnitude].Curves[Channel].X[I],
          Rates[Channel+1]/2,'FRF axis must use individual response Fs');
        Check(Abs(Snapshot.Results[irtFrfMagnitude].Curves[Channel].Y[0] /
          (Channel+2)-1)<0.1,'DC transfer gain across resampling');
      end;
      Filter:=Snapshot.FilterWindow;
      Filter.Enabled:=True;
      Filter.EndSeconds:=0.9;
      Filter.ExponentialEndSeconds:=0.9;
      Check(Service.TrySetFilterWindow(Filter,ErrorText),ErrorText);
      WaitForImpactCount(Service,1);
      Service.FillSnapshot(Snapshot);
      for Channel:=0 to 1 do
      begin
        I:=High(Snapshot.Results[irtFrfMagnitude].Curves[Channel].X);
        Check(I>=0,'recalculated FRF empty');
        CheckNear(Snapshot.Results[irtFrfMagnitude].Curves[Channel].X[I],
          Rates[Channel+1]/2,'recalculation changed response sampling rate');
      end;
    finally
      Service.Free; Model.Free; Registry.Free; Bus.Free;
    end;
  end;
end;

procedure TestRectangularEpochAndRate;
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lModel: TRecorderImpactHammerComponent;
  lService: TRecorderImpactHammerService;
  lSnapshot, lBaseline: TRecorderImpactHammerSnapshot;
  lWindow: TRecorderImpactFilterWindow;
  lTimes, lValues: array of Double;
  lNames: array[0..2] of string;
  lRates: array[0..2] of Integer;
  lMode, lChannel, lI, lAttempt: Integer;
  lError: string;
  lExpected: Double;
  lEntry: TRecorderFrfRouteEntry;
  lDirectory: string;
  lId: TGuid;
  lStored: TRecorderImpactSessionSnapshot;
begin
  lNames[0] := 'hammer'; lNames[1] := 'response-x'; lNames[2] := 'response-y';
  lRates[0] := 8; lRates[1] := 16; lRates[2] := 32;
  for lMode := 0 to 1 do
  begin
    lBus := TRecorderEventBus.Create;
    lRegistry := TRecorderTagRegistry.Create(lBus);
    lModel := TRecorderImpactHammerComponent.Create;
    lService := TRecorderImpactHammerService.Create;
    try
      ConfigureModel(lModel, lRegistry.CreateTag('hammer', 128),
        lRegistry.CreateTag('response-x', 128), lRegistry.CreateTag('response-y', 128));
      for lChannel := 0 to 2 do
        lRegistry.FindByName(lNames[lChannel]).PollFrequencyHz := lRates[lChannel];
      Check(lService.Configure(lModel, lRegistry), lService.LastError);
      lEntry := Default(TRecorderFrfRouteEntry);
      lEntry.PointNumber := 1;
      lEntry.PointLabel := '1';
      lService.Route.Add(lEntry);
      CreateGuid(lId);
      lDirectory := IncludeTrailingPathDelimiter(GetTempDir) +
        'frf-left-' + GuidToString(lId);
      lService.Route.Save(lDirectory);
      lService.SetTriggerEnabled(False);
      lBus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
      if lMode = 0 then Check(lService.TryCapturePortion(lError), lError);
      for lChannel := 2 downto 0 do
      begin
        SetLength(lTimes, lRates[lChannel] + Ord(lMode = 0));
        SetLength(lValues, Length(lTimes));
        for lI := 0 to High(lTimes) do
        begin
          lTimes[lI] := 37.5 + lI / lRates[lChannel];
          if lI / lRates[lChannel] < 0.75 then lValues[lI] := lI + 1
          else lValues[lI] := 0;
        end;
        lRegistry.PublishBlock(lNames[lChannel], lTimes, lValues, Length(lTimes), True);
      end;
      if lMode = 1 then Check(lService.TryCaptureRingPortion(lError), lError);
      WaitForImpactCount(lService, 1);
      for lAttempt := 1 to 2000 do
      begin
        lService.FillSnapshot(lBaseline);
        if lBaseline.CanCapturePortion then Break;
        Sleep(1);
      end;
      Check(lBaseline.CanCapturePortion, 'epoch/rate baseline did not finish');
      lWindow := lBaseline.FilterWindow;
      lWindow.Enabled := True;
      lWindow.StartSeconds := 0.13;
      lWindow.EndSeconds := 0.6;
      lWindow.ExponentialEndLevel := 1;
      Check(lService.TrySetFilterWindow(lWindow, lError), lError);
      WaitForImpactCount(lService, 1);
      lService.FillSnapshot(lSnapshot);
      CheckNear(lSnapshot.Results[irtTime].Curves[0].X[0], 0,
        'nonzero source epoch shifted the left cursor reference');
      for lChannel := 0 to 2 do
        for lI := 0 to High(lSnapshot.Results[irtTime].Curves[lChannel].Y) do
        begin
          lExpected := lBaseline.Results[irtTime].Curves[lChannel].Y[lI];
          if (lChannel = 0) and
            ((lSnapshot.Results[irtTime].Curves[0].X[lI] < 0.13) or
             (lSnapshot.Results[irtTime].Curves[0].X[lI] >= 0.6)) then lExpected := 0;
          CheckNear(lSnapshot.Results[irtTime].Curves[lChannel].Y[lI], lExpected,
            'physical rectangular mask/response isolation with nonzero epoch and different Fs');
        end;
      Check(lSnapshot.Results[irtTime].Curves[0].Y[1] = 0,
        'left cursor retained nonzero excitation sample before 0.13s');
      if lMode = 0 then
      begin
      Check((Length(lSnapshot.Results[irtSpectrum].Curves) > 0) and
        (Length(lSnapshot.Results[irtSpectrum].Curves[0].Y) > 0),
        'windowed spectrum missing: ' + lSnapshot.StatusText + ' / ' + lService.LastError);
      Check((Length(lBaseline.Results[irtSpectrum].Curves) > 0) and
        (Length(lBaseline.Results[irtSpectrum].Curves[0].Y) > 0),
        'baseline spectrum missing: ' + lBaseline.StatusText);
      Check(Abs(lSnapshot.Results[irtSpectrum].Curves[0].Y[0] -
        lBaseline.Results[irtSpectrum].Curves[0].Y[0]) > 1E-4,
        'rectangle changed time but left excitation spectrum stale');
      CheckNear(lSnapshot.Results[irtSpectrum].Curves[1].Y[0],
        lBaseline.Results[irtSpectrum].Curves[1].Y[0],
        'rectangle changed independent response spectrum');
      if (Length(lSnapshot.Results[irtFrfMagnitude].Curves) > 0) and
        (Length(lSnapshot.Results[irtFrfMagnitude].Curves[0].Y) > 0) and
        (Length(lBaseline.Results[irtFrfMagnitude].Curves) > 0) and
        (Length(lBaseline.Results[irtFrfMagnitude].Curves[0].Y) > 0) then
        Check(Abs(lSnapshot.Results[irtFrfMagnitude].Curves[0].Y[0] -
          lBaseline.Results[irtFrfMagnitude].Curves[0].Y[0]) > 1E-4,
          'rectangle changed excitation but left FRF stale')
      else Check(lService.LastError <> '', 'unavailable FRF needs an explicit status');
      end;
      Check(lService.SaveRoutePoint(lError), lError);
      Check(lService.SelectRoutePoint(0, lError), lError);
      WaitForImpactCount(lService, 1);
      lService.FillSnapshot(lSnapshot);
      CheckNear(lSnapshot.Results[irtTime].Curves[0].Y[1], 0,
        'saved left cursor did not cut nonzero early excitation');
      CheckNear(lSnapshot.Results[irtTime].Curves[0].Y[2], 3,
        'saved left cursor cut a retained excitation sample');
      CheckNear(lSnapshot.Results[irtTime].Curves[0].Y[5], 0,
        'saved right cursor did not cut late excitation');
      Check(TRecorderFrfPointStore.Load(lService.Route.PointDirectory(0), lStored, lError), lError);
      CheckNear(lStored.Impacts[0].Excitation.Samples[0].TimeSeconds, 37.5,
        'rectangular processing shifted saved raw epoch');
      CheckNear(lStored.Impacts[0].Excitation.Samples[1].Value, 2,
        'left cursor changed raw acquisition instead of presentation');
      WriteLn('RESULT RectangularEpochRate workspace=', lMode, ' left/right masks passed');
    finally lService.Free; lModel.Free; lRegistry.Free; lBus.Free end;
  end;
end;

procedure TestWindowSpectralNullDoesNotFreezeSpectrum;
const
  CInput: array[0..7] of Double = (1, 0, 0, 0, 1, 0, 3, 0);
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lModel: TRecorderImpactHammerComponent;
  lService: TRecorderImpactHammerService;
  lSnapshot: TRecorderImpactHammerSnapshot;
  lWindow: TRecorderImpactFilterWindow;
  lEntry: TRecorderFrfRouteEntry;
  lError, lDirectory: string;
  lId: TGuid;
  lMode, lI, lAttempt: Integer;
  lOldSpectrum: Double;
begin
  for lMode := 0 to 2 do
  begin
    lBus := TRecorderEventBus.Create;
    lRegistry := TRecorderTagRegistry.Create(lBus);
    lModel := TRecorderImpactHammerComponent.Create;
    lService := TRecorderImpactHammerService.Create;
    try
      ConfigureModel(lModel, lRegistry.CreateTag('hammer', 64),
        lRegistry.CreateTag('response-x', 64), lRegistry.CreateTag('response-y', 64));
      lRegistry.FindByName('hammer').PollFrequencyHz := 8;
      lRegistry.FindByName('response-x').PollFrequencyHz := 8;
      lRegistry.FindByName('response-y').PollFrequencyHz := 8;
      Check(lService.Configure(lModel, lRegistry), lService.LastError);
      lEntry := Default(TRecorderFrfRouteEntry); lEntry.PointNumber := 1;
      lEntry.PointLabel := '1'; lService.Route.Add(lEntry);
      CreateGuid(lId);
      lDirectory := IncludeTrailingPathDelimiter(GetTempDir) + 'frf-null-' + GuidToString(lId);
      lService.Route.Save(lDirectory);
      lService.SetTriggerEnabled(False);
      lBus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
      if lMode = 0 then Check(lService.TryCapturePortion(lError), lError);
      for lI := 0 to 7 + Ord(lMode = 0) do
      begin
        lRegistry.PublishValue('response-x', 17.5 + lI / 8, 2 * CInput[lI mod 8]);
        lRegistry.PublishValue('response-y', 17.5 + lI / 8, 3 * CInput[lI mod 8]);
        lRegistry.PublishValue('hammer', 17.5 + lI / 8, CInput[lI mod 8]);
      end;
      if lMode <> 0 then Check(lService.TryCaptureRingPortion(lError), lError);
      for lAttempt := 1 to 2000 do
      begin
        lService.FillSnapshot(lSnapshot);
        if lSnapshot.CanCapturePortion then Break;
        Sleep(1);
      end;
      Check(lSnapshot.CanCapturePortion, 'notch baseline capture timed out');
      Check(Length(lSnapshot.Results[irtFrfMagnitude].Curves) = 2,
        'notch baseline FRF missing: ' + lSnapshot.StatusText);
      if lMode = 2 then
      begin
        Check(lService.SaveRoutePoint(lError), lError);
        Check(lService.SelectRoutePoint(0, lError), lError);
        lService.FillSnapshot(lSnapshot);
      end;
      lOldSpectrum := lSnapshot.Results[irtSpectrum].Curves[0].Y[0];
      lWindow := lSnapshot.FilterWindow;
      lWindow.Enabled := True;
      lWindow.EndSeconds := 0.75;
      lWindow.ExponentialEndLevel := 1;
      Check(lService.TrySetFilterWindow(lWindow, lError), lError);
      WaitForImpactCount(lService, 1);
      lService.FillSnapshot(lSnapshot);
      CheckNear(lSnapshot.Results[irtSpectrum].Curves[0].Y[0],
        2 * Sqrt(2) / 8, 'spectral-null window retained old excitation spectrum');
      Check(Abs(lSnapshot.Results[irtSpectrum].Curves[0].Y[0] - lOldSpectrum) > 0.1,
        'window did not change spectral-null SPM');
      Check((Length(lSnapshot.Results[irtFrfMagnitude].Curves) = 0) or
        (Length(lSnapshot.Results[irtFrfMagnitude].Curves[0].Y) = 0),
        'unsupported FRF bins retained the old curve or fabricated zero values');
      Check(Pos('FRF', lSnapshot.StatusText) > 0, 'unsupported FRF lacks explicit status');
      lWindow.Enabled := False;
      Check(lService.TrySetFilterWindow(lWindow, lError), lError);
      WaitForImpactCount(lService, 1);
      lService.FillSnapshot(lSnapshot);
      CheckNear(lSnapshot.Results[irtSpectrum].Curves[0].Y[0], lOldSpectrum,
        'disabling spectral-null window did not restore SPM');
      Check(Length(lSnapshot.Results[irtFrfMagnitude].Curves) = 2,
        'disabling spectral-null window did not restore FRF');
      WriteLn('RESULT SpectralNullFreshSpectrum workspace=', lMode, ' passed');
    finally lService.Free; lModel.Free; lRegistry.Free; lBus.Free end;
  end;
end;

procedure TestWindowSavedAndRingWorkspaces;
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lModel: TRecorderImpactHammerComponent;
  lService: TRecorderImpactHammerService;
  lSnapshot: TRecorderImpactHammerSnapshot;
  lStored: TRecorderImpactSessionSnapshot;
  lWindow: TRecorderImpactFilterWindow;
  lEntry: TRecorderFrfRouteEntry;
  lDirectory, lError: string;
  lId: TGuid;
  lI: Integer;
  lMagnitude, lPeak: Double;
  lBaseline: TRecorderImpactHammerSnapshot;
  lType: TRecorderImpactResultType;
  lCurve: Integer;

  procedure CheckWindowDisabled(const AWorkspace: string);
  var
    lResultType: TRecorderImpactResultType;
    lCurveIndex, lSample: Integer;
  begin
    lWindow.Enabled := False;
    Check(lService.TrySetFilterWindow(lWindow, lError), lError);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lSnapshot);
    Check(not lSnapshot.FilterWindow.Enabled, AWorkspace + ' window stayed enabled');
    for lResultType := Low(TRecorderImpactResultType) to High(TRecorderImpactResultType) do
    begin
      Check(Length(lSnapshot.Results[lResultType].Curves) =
        Length(lBaseline.Results[lResultType].Curves), AWorkspace + ' curve count changed');
      for lCurveIndex := 0 to High(lBaseline.Results[lResultType].Curves) do
      begin
        Check(Length(lSnapshot.Results[lResultType].Curves[lCurveIndex].Y) =
          Length(lBaseline.Results[lResultType].Curves[lCurveIndex].Y),
          AWorkspace + ' sample count changed');
        for lSample := 0 to High(lBaseline.Results[lResultType].Curves[lCurveIndex].Y) do
          CheckNear(lSnapshot.Results[lResultType].Curves[lCurveIndex].Y[lSample],
            lBaseline.Results[lResultType].Curves[lCurveIndex].Y[lSample],
            AWorkspace + ' disabled window did not restore unwindowed data');
      end;
    end;
    WriteLn('RESULT WindowDisabled ', AWorkspace, ' time/spectra/FRF/phase/coherence restored');
  end;
begin
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lModel := TRecorderImpactHammerComponent.Create;
  lService := TRecorderImpactHammerService.Create;
  try
    ConfigureModel(lModel, lRegistry.CreateTag('hammer', 8),
      lRegistry.CreateTag('response-x', 8), lRegistry.CreateTag('response-y', 8));
    lRegistry.FindByName('hammer').PollFrequencyHz := 8;
    lRegistry.FindByName('response-x').PollFrequencyHz := 8;
    lRegistry.FindByName('response-y').PollFrequencyHz := 8;
    Check(lService.Configure(lModel, lRegistry), lService.LastError);
    lEntry := Default(TRecorderFrfRouteEntry);
    lEntry.PointNumber := 1;
    lEntry.PointLabel := '1';
    lService.Route.Add(lEntry);
    lEntry.PointNumber := 2;
    lEntry.PointLabel := '2';
    lService.Route.Add(lEntry);
    CreateGuid(lId);
    lDirectory := IncludeTrailingPathDelimiter(GetTempDir) + 'frf-window-' + GuidToString(lId);
    lService.Route.Save(lDirectory);
    lService.SetTriggerEnabled(False);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    for lI := 0 to 7 do
    begin
      lRegistry.PublishValue('hammer', 1 + lI / 8, Ord(lI = 2) * 8);
      lRegistry.PublishValue('response-x', 1 + lI / 8,
        Ord(lI = 2) * 8 + Ord(lI = 5) * 4);
      lRegistry.PublishValue('response-y', 1 + lI / 8,
        Ord(lI = 2) * 4 + Ord(lI = 5) * 2);
    end;
    Check(lService.TryCaptureRingPortion(lError), lError);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lSnapshot);
    for lI := 1 to 2000 do
    begin
      if lSnapshot.CanCapturePortion then Break;
      Sleep(1);
      lService.FillSnapshot(lSnapshot);
    end;
    Check(lSnapshot.CanCapturePortion, 'baseline manual ring did not finish');
    lBaseline := lSnapshot;
    for lType := Low(TRecorderImpactResultType) to High(TRecorderImpactResultType) do
    begin
      lBaseline.Results[lType].Curves := Copy(lSnapshot.Results[lType].Curves);
      for lCurve := 0 to High(lBaseline.Results[lType].Curves) do
        lBaseline.Results[lType].Curves[lCurve].Y :=
          Copy(lSnapshot.Results[lType].Curves[lCurve].Y);
    end;
    lWindow := lSnapshot.FilterWindow;
    lWindow.Enabled := True;
    lWindow.EndSeconds := 0.5;
    lWindow.ExponentialStartSeconds := 0;
    lWindow.ExponentialEndSeconds := 1;
    lWindow.ExponentialEndLevel := 0.5;
    Check(lService.TrySetFilterWindow(lWindow, lError), lError);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lSnapshot);
    Check(Length(lSnapshot.Results[irtFrfMagnitude].Curves) = 2,
      'windowed ring lost FRF curves');
    lMagnitude := lSnapshot.Results[irtFrfMagnitude].Curves[0].Y[0];
    lPeak := TimeResponsePeak(lSnapshot);
    Check(lService.SaveRoutePoint(lError), lError);
    Check(TRecorderFrfPointStore.Load(lService.Route.PointDirectory(0), lStored, lError), lError);
    CheckNear(lStored.Impacts[0].Responses[0].Samples[2].Value, 8,
      'window processing mutated saved raw response');
    lWindow.ExponentialEndLevel := 0.01;
    Check(lService.TrySetFilterWindow(lWindow, lError), lError);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lSnapshot);
    Check(Abs(lSnapshot.Results[irtFrfMagnitude].Curves[0].Y[0] - lMagnitude) > 0.01,
      'manual ring FRF remained stale after window change');
    Check(Abs(TimeResponsePeak(lSnapshot) - lPeak) > 0.01,
      'manual ring time remained stale after window change');
    CheckWindowDisabled('manual-ring');
    lWindow.Enabled := True;
    Check(lService.TrySetFilterWindow(lWindow, lError), lError);
    WaitForImpactCount(lService, 1);
    Check(lService.SelectRoutePoint(0, lError), lError);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lSnapshot);
    lMagnitude := lSnapshot.Results[irtFrfMagnitude].Curves[0].Y[0];
    lWindow.ExponentialEndLevel := 0.5;
    Check(lService.TrySetFilterWindow(lWindow, lError), lError);
    WaitForImpactCount(lService, 1);
    lService.FillSnapshot(lSnapshot);
    Check(Abs(lSnapshot.Results[irtFrfMagnitude].Curves[0].Y[0] - lMagnitude) > 0.01,
      'saved workspace FRF remained stale after window change');
    CheckWindowDisabled('saved-step');
    lWindow.Enabled := True;
    // Switching to an empty saved step invalidates an in-flight source result.
    lWindow.ExponentialEndLevel := 0.1;
    Check(lService.TrySetFilterWindow(lWindow, lError), lError);
    Check(lService.SelectRoutePoint(1, lError), lError);
    WaitForImpactCount(lService, 0);
    lService.FillSnapshot(lSnapshot);
    Check(Length(lSnapshot.Results[irtFrfMagnitude].Curves[0].Y) = 0,
      'old source window result replaced newly selected empty step');
    Check(TRecorderFrfPointStore.Load(lService.Route.PointDirectory(0), lStored, lError), lError);
    CheckNear(lStored.Impacts[0].Responses[0].Samples[2].Value, 8,
      'saved raw changed while browsing windowed points');
    WriteLn('RESULT WindowSavedRingWorkspaces passed');
  finally
    lService.Free; lModel.Free; lRegistry.Free; lBus.Free;
  end;
end;

begin
  try
    if (ParamCount > 0) and (ParamStr(1) = '--window-workspaces-only') then
    begin
      TestRectangularEpochAndRate;
      TestWindowSpectralNullDoesNotFreezeSpectrum;
      TestWindowSavedAndRingWorkspaces;
      Halt(0);
    end;
    if (ParamCount > 0) and (ParamStr(1) = '--window-integration-only') then
    begin
      RunIntegration;
      WriteLn('RESULT WindowIntegration passed');
      Halt(0);
    end;
    if (ParamCount > 0) and (ParamStr(1) = '--route-auto-only') then
    begin TestRouteAutomation; Halt(0) end;
    if (ParamCount > 0) and (ParamStr(1) = '--manual-portion-only') then
    begin
      TestTriggerModeLifecycle;
      TestRingPortionImmediate;
      TestRingLastBlockFallback;
      TestRingPortionIndependentEpochs;
      TestManualPortionTimeoutRetry;
      TestManualPortion;
      TestManualPortionResponseAhead;
      WriteLn('RESULT ManualPortion passed');
      Halt(0);
    end;
    if (ParamCount > 0) and (ParamStr(1) = '--response-fs-only') then
    begin
      TestResponseSamplingRates;
      WriteLn('RESULT ResponseSamplingRates passed');
      Halt(0);
    end;
    if (ParamCount > 0) and (ParamStr(1) = '--route-point-only') then
    begin
      TestRoutePointNavigation;
      TestIntensityValues;
      WriteLn('RESULT FrfRoutePointNavigation passed');
      Halt(0);
    end;
    TestFrfVertexColorModifier;
    if (ParamCount>0) and (ParamStr(1)='--frf-vertex-color-only') then
    begin
      WriteLn('RESULT FrfVertexColorModifier passed');
      Halt(0);
    end;
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
