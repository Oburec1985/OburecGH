program ThreeDFrfMotionTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Math, u3dCoreTypes, u3dScene, u3dMotionContracts,
  u3dSceneMotionEngine, uRecorderFrfSnapshot, uRecorderFrfMotionAdapter;

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

function Point(AFrequency, AMagnitude, APhase: Double): TRecorderFrfPoint;
begin
  Result.FrequencyHz := AFrequency;
  Result.Magnitude := AMagnitude;
  Result.PhaseRadians := APhase;
end;

procedure TestInterpolation;
var
  lSnapshot: TRecorderFrfSnapshot;
  lSampler: IRecorderFrfSampler;
  lPoints: array[0..1] of TRecorderFrfPoint;
  lMagnitude, lPhase: Double;
begin
  lSnapshot := TRecorderFrfSnapshot.Create(7);
  lSampler := lSnapshot;
  lPoints[0] := Point(10, 2, DegToRad(170));
  lPoints[1] := Point(20, 4, DegToRad(-170));
  lSnapshot.AddCurve(1, lPoints);
  Check(lSampler.TrySample(1, 15, lMagnitude, lPhase), 'sample midpoint');
  CheckNear(lMagnitude, 3, 'magnitude interpolation');
  CheckNear(Abs(lPhase), Pi, 'phase follows shortest arc');
  Check(not lSampler.TrySample(1, 5, lMagnitude, lPhase), 'outside range');
  Check(lSampler.Version = 7, 'snapshot version');
end;

procedure TestAdapterAndSceneEngine;
var
  lScene: T3dScene;
  lNode: T3dNode;
  lSnapshot: TRecorderFrfSnapshot;
  lSampler: IRecorderFrfSampler;
  lEngineObject: T3dSceneMotionEngine;
  lSink: I3dMotionSink;
  lAdapter: TRecorderFrfMotionAdapter;
  lPoints: array[0..1] of TRecorderFrfPoint;
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
    lNode.WorldTransform[0] := 0; lNode.WorldTransform[1] := 1;
    lNode.WorldTransform[4] := -1; lNode.WorldTransform[5] := 0;
    lNode.LocalTransform := lNode.WorldTransform;
    lScene.AddNode(lNode);

    lSnapshot := TRecorderFrfSnapshot.Create(1);
    lSampler := lSnapshot;
    lPoints[0] := Point(10, 2, 0);
    lPoints[1] := Point(20, 4, 0);
    lSnapshot.AddCurve(9, lPoints);

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
    lAdapter.Configure(lSampler, lSink, lBindings);
    Check(lAdapter.Update(15, Pi/2), 'adapter applies displacement');
    CheckNear(lNode.WorldTransform[12], 0, 'local X world X');
    CheckNear(lNode.WorldTransform[13], 6, 'gain*magnitude on local X');
    CheckNear(lNode.WorldTransform[14], 0, 'disabled axis');
    Check(lSink.Revision = 1, 'motion revision');

    Check(lAdapter.Update(15, 0), 'adapter returns to base pose');
    CheckNear(lNode.WorldTransform[13], 0, 'absolute harmonic offset');
  finally
    lAdapter.Free;
    lSampler := nil;
    lSink := nil;
    lScene.Free;
  end;
end;

begin
  try
    TestInterpolation;
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
