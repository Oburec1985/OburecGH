program ThreeDFrfMotionTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Classes, SysUtils, Math, u3dCoreTypes, u3dScene, u3dMotionContracts,
  u3dSceneMotionEngine, uRecorderFrfContracts, uRecorderFrfRepository,
  uRecorderFrfMotionAdapter;

type
  TRepositoryWorker = class(TThread)
  private
    fRepository: TRecorderFrfRepository;
    fPublish: Boolean;
    fDone: LongInt;
  protected
    procedure Execute; override;
  public
    constructor Create(ARepository: TRecorderFrfRepository;
      APublish: Boolean);
    function IsDone: Boolean;
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure CheckNear(AActual, AExpected: Double; const AMessage: string);
begin
  if Abs(AActual-AExpected) > 1.0e-4 then
    raise Exception.CreateFmt('%s: expected %.6f, got %.6f',
      [AMessage, AExpected, AActual]);
end;

constructor TRepositoryWorker.Create(ARepository: TRecorderFrfRepository;
  APublish: Boolean);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fRepository := ARepository;
  fPublish := APublish;
end;

procedure TRepositoryWorker.Execute;
var
  lCurve: TRecorderFrfCurveData;
  lIteration: Integer;
begin
  lCurve.Id := 101;
  lCurve.FrequencyHz := [10.0, 20.0];
  lCurve.Magnitude := [1.0, 2.0];
  lCurve.PhaseRadians := [0.0, 0.0];
  lCurve.Coherence := [1.0, 1.0];
  for lIteration := 1 to 1000 do
    if fPublish then
      fRepository.Publish([lCurve])
    else
      fRepository.Clear;
  InterlockedExchange(fDone, 1);
end;

function TRepositoryWorker.IsDone: Boolean;
begin
  Result := InterlockedCompareExchange(fDone, 0, 0) <> 0;
end;

procedure TestAggregateProviderLifecycle;
var
  lOwnerA, lOwnerB: TObject;
  lRepositoryA, lRepositoryB: TRecorderFrfRepository;
  lProviderA, lProviderB: IRecorderFrfProvider;
  lSnapshot: IRecorderFrfSampler;
  lCachedSnapshot: IRecorderFrfSampler;
  lCurve: TRecorderFrfCurveData;
  lMagnitude, lPhase: Double;
  lVersion: QWord;
begin
  lOwnerA := TObject.Create;
  lOwnerB := TObject.Create;
  lRepositoryA := TRecorderFrfRepository.Create;
  lRepositoryB := TRecorderFrfRepository.Create;
  lProviderA := lRepositoryA;
  lProviderB := lRepositoryB;
  try
    lCurve.Id := 11;
    lCurve.FrequencyHz := [10.0, 20.0];
    lCurve.Magnitude := [1.0, 3.0];
    lCurve.PhaseRadians := [0.0, 0.0];
    lCurve.Coherence := [1.0, 1.0];
    Check(lRepositoryA.Publish([lCurve]), 'first aggregate source publish');
    lCurve.Id := 22;
    lCurve.Magnitude := [4.0, 6.0];
    Check(lRepositoryB.Publish([lCurve]), 'second aggregate source publish');

    RegisterRecorderFrfProvider(lOwnerA, lProviderA);
    RegisterRecorderFrfProvider(lOwnerB, lProviderB);
    lSnapshot := RecorderDefaultFrfProvider.AcquireSnapshot;
    Check(lSnapshot <> nil, 'aggregate snapshot unavailable');
    Check(lSnapshot.TrySample(11, 15, lMagnitude, lPhase),
      'first aggregate curve unavailable');
    CheckNear(lMagnitude, 2, 'first aggregate curve magnitude');
    Check(lSnapshot.TrySample(22, 15, lMagnitude, lPhase),
      'second aggregate curve unavailable');
    CheckNear(lMagnitude, 5, 'second aggregate curve magnitude');
    lVersion := lSnapshot.Version;
    lCachedSnapshot := RecorderDefaultFrfProvider.AcquireSnapshot;
    Check(lCachedSnapshot = lSnapshot,
      'unchanged aggregate AcquireSnapshot rebuilt its immutable cache');

    lCurve.Id := 11;
    lCurve.Magnitude := [2.0, 4.0];
    Check(lRepositoryA.Publish([lCurve]), 'registered source republish');
    lSnapshot := RecorderDefaultFrfProvider.AcquireSnapshot;
    Check(lSnapshot.Version > lVersion,
      'producer notification did not refresh aggregate cache');
    Check(lSnapshot.TrySample(11, 15, lMagnitude, lPhase),
      'republished aggregate curve unavailable');
    CheckNear(lMagnitude, 3, 'republished aggregate curve magnitude');
    lVersion := lSnapshot.Version;

    UnregisterRecorderFrfProvider(lOwnerB);
    lSnapshot := RecorderDefaultFrfProvider.AcquireSnapshot;
    Check(lSnapshot.Version > lVersion, 'unregister version did not advance');
    Check(lSnapshot.TrySample(11, 15, lMagnitude, lPhase),
      'unregister discarded remaining provider');
    Check(not lSnapshot.TrySample(22, 15, lMagnitude, lPhase),
      'unregistered provider remains visible');
  finally
    UnregisterRecorderFrfProvider(lOwnerA);
    UnregisterRecorderFrfProvider(lOwnerB);
    lProviderA := nil;
    lProviderB := nil;
    lOwnerA.Free;
    lOwnerB.Free;
  end;
end;

procedure TestClearPublishSerialization;
var
  lRepository: TRecorderFrfRepository;
  lProvider: IRecorderFrfProvider;
  lPublisher, lClearer: TRepositoryWorker;
  lSnapshot: IRecorderFrfSampler;
  lCurve: TRecorderFrfCurveData;
  lLastVersion: QWord;
begin
  lRepository := TRecorderFrfRepository.Create;
  lProvider := lRepository;
  lPublisher := TRepositoryWorker.Create(lRepository, True);
  lClearer := TRepositoryWorker.Create(lRepository, False);
  try
    lLastVersion := 0;
    lPublisher.Start;
    lClearer.Start;
    while not lPublisher.IsDone or not lClearer.IsDone do
    begin
      lSnapshot := lProvider.AcquireSnapshot;
      if lSnapshot <> nil then
      begin
        Check(lSnapshot.Version >= lLastVersion,
          'repository version regressed during Clear/Publish race');
        lLastVersion := lSnapshot.Version;
      end;
      Sleep(0);
    end;
    lPublisher.WaitFor;
    lClearer.WaitFor;

    lRepository.Clear;
    Check(lProvider.AcquireSnapshot = nil,
      'final Clear did not remove snapshot');
    lCurve.Id := 101;
    lCurve.FrequencyHz := [10.0, 20.0];
    lCurve.Magnitude := [1.0, 2.0];
    lCurve.PhaseRadians := [0.0, 0.0];
    lCurve.Coherence := [1.0, 1.0];
    Check(lRepository.Publish([lCurve]), 'final Publish failed');
    lSnapshot := lProvider.AcquireSnapshot;
    Check(lSnapshot.Version > lLastVersion,
      'final Publish version is not monotonic');
    lLastVersion := lSnapshot.Version;
    lRepository.Clear;
    Check(lProvider.AcquireSnapshot = nil,
      'second final Clear did not remove snapshot');
    Check(lRepository.Publish([lCurve]), 'second final Publish failed');
    Check(lProvider.AcquireSnapshot.Version > lLastVersion,
      'second final Publish version is not monotonic');
  finally
    lPublisher.Free;
    lClearer.Free;
    lProvider := nil;
  end;
end;

procedure TestInterpolation;
var
  lRepositoryObject: TRecorderFrfRepository;
  lProvider: IRecorderFrfProvider;
  lSampler: IRecorderFrfSampler;
  lCurves: array[0..1] of TRecorderFrfCurveData;
  lMagnitude, lPhase: Double;
begin
  lRepositoryObject := TRecorderFrfRepository.Create;
  lProvider := lRepositoryObject;
  lCurves[0].Id := 1;
  lCurves[0].FrequencyHz := [10.0, 20.0];
  lCurves[0].Magnitude := [2.0, 4.0];
  lCurves[0].PhaseRadians := [DegToRad(170), DegToRad(-170)];
  lCurves[0].Coherence := [1.0, 1.0];
  lCurves[1].Id := 2;
  lCurves[1].FrequencyHz := [10.0, 20.0];
  lCurves[1].Magnitude := [5.0, 7.0];
  lCurves[1].PhaseRadians := [0.0, 0.0];
  lCurves[1].Coherence := [0.8, 0.9];
  Check(lRepositoryObject.Publish(lCurves), 'multi-curve publish');
  lSampler := lProvider.AcquireSnapshot;
  Check(lSampler.TrySample(1, 15, lMagnitude, lPhase), 'sample midpoint');
  CheckNear(lMagnitude, 3, 'magnitude interpolation');
  CheckNear(Abs(lPhase), Pi, 'phase follows shortest arc');
  Check(not lSampler.TrySample(1, 5, lMagnitude, lPhase), 'outside range');
  Check(lSampler.TrySample(2, 15, lMagnitude, lPhase), 'second curve midpoint');
  CheckNear(lMagnitude, 6, 'second curve interpolation');
  Check(lSampler.Version = 1, 'snapshot version');
  lCurves[0].Magnitude := [20.0, 40.0];
  Check(lRepositoryObject.Publish(lCurves), 'replacement publish');
  Check(lSampler.TrySample(1, 15, lMagnitude, lPhase),
    'retained old snapshot unavailable');
  CheckNear(lMagnitude, 3, 'old snapshot mutated after publication');
  Check(lProvider.AcquireSnapshot.TrySample(1, 15, lMagnitude, lPhase),
    'new snapshot unavailable');
  CheckNear(lMagnitude, 30, 'new snapshot interpolation');
  lCurves[1].Id := 1;
  Check(not lRepositoryObject.Publish(lCurves), 'duplicate curve publish accepted');
  Check(lProvider.AcquireSnapshot.TrySample(1, 15, lMagnitude, lPhase),
    'snapshot lost after rejected publication');
  CheckNear(lMagnitude, 30, 'rejected publication partially replaced snapshot');
end;

procedure TestAdapterAndSceneEngine;
var
  lScene: T3dScene;
  lNode: T3dNode;
  lRepositoryObject: TRecorderFrfRepository;
  lProvider: IRecorderFrfProvider;
  lEngineObject: T3dSceneMotionEngine;
  lSink: I3dMotionSink;
  lAdapter: TRecorderFrfMotionAdapter;
  lCurves: array[0..0] of TRecorderFrfCurveData;
  lBindings: array[0..1] of TRecorderFrfMotionBinding;
  lTargets: array[0..0] of QWord;
begin
  lScene := T3dScene.Create;
  lAdapter := TRecorderFrfMotionAdapter.Create;
  try
    lNode := T3dNode.Create;
    lNode.Id := 42;
    SetIdentity(lNode.LocalTransform);
    SetIdentity(lNode.WorldTransform);
    { Local X points along world Y. }
    lNode.WorldTransform[0] := 0;
    lNode.WorldTransform[1] := 1;
    lNode.WorldTransform[4] := -1;
    lNode.WorldTransform[5] := 0;
    lNode.LocalTransform := lNode.WorldTransform;
    lScene.AddNode(lNode);

    lRepositoryObject := TRecorderFrfRepository.Create;
    lProvider := lRepositoryObject;
    lCurves[0].Id := 9;
    lCurves[0].FrequencyHz := [10.0, 20.0];
    lCurves[0].Magnitude := [2.0, 4.0];
    lCurves[0].PhaseRadians := [0.0, 0.0];
    lCurves[0].Coherence := [1.0, 1.0];
    Check(lRepositoryObject.Publish(lCurves), 'adapter source publish');

    lEngineObject := T3dSceneMotionEngine.Create;
    lSink := lEngineObject;
    lTargets[0] := 42;
    lEngineObject.Configure(lScene, lTargets);

    FillChar(lBindings, SizeOf(lBindings), 0);
    lBindings[0].CurveId := 9;
    lBindings[0].TargetNodeId := 42;
    lBindings[0].Axis := maxisX;
    lBindings[0].Space := msHelperLocal;
    lBindings[0].Gain := 2;
    lBindings[0].Enabled := True;
    { A disabled binding must not affect the batch. }
    lBindings[1] := lBindings[0];
    lBindings[1].Axis := maxisZ;
    lBindings[1].Enabled := False;
    lAdapter.ConfigureProvider(lProvider, lSink, lBindings);
    Check(lAdapter.Update(15, Pi/2), 'adapter applies displacement');
    CheckNear(lNode.WorldTransform[12], 0, 'local X world X');
    CheckNear(lNode.WorldTransform[13], 6, 'gain*magnitude on local X');
    CheckNear(lNode.WorldTransform[14], 0, 'disabled axis');
    Check(lSink.Revision = 1, 'motion revision');

    Check(lAdapter.Update(15, 0), 'adapter returns to base pose');
    CheckNear(lNode.WorldTransform[13], 0, 'absolute harmonic offset');

    { Editor Apply must rebuild runtime bindings even when the scene object is
      unchanged. Reconfigure twice to model Apply followed by Cancel. }
    lBindings[0].Gain := 4;
    lAdapter.ConfigureProvider(lProvider, lSink, lBindings);
    Check(lAdapter.Update(15, Pi/2), 'edited FRF binding is applied');
    CheckNear(lNode.WorldTransform[13], 12, 'edited FRF gain');
    lBindings[0].Gain := 2;
    lAdapter.ConfigureProvider(lProvider, lSink, lBindings);
    Check(lAdapter.Update(15, Pi/2), 'restored FRF binding is applied');
    CheckNear(lNode.WorldTransform[13], 6, 'cancel restores FRF gain');
  finally
    lAdapter.Free;
    lProvider := nil;
    lSink := nil;
    lScene.Free;
  end;
end;

begin
  try
    TestInterpolation;
    TestAggregateProviderLifecycle;
    TestClearPublishSerialization;
    TestAdapterAndSceneEngine;
    Writeln('RESULT ThreeDFrfMotion passed');
  except
    on E: Exception do
    begin
      Writeln('RESULT ThreeDFrfMotion failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
