program Test3dMotion;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Math,
  u3dCoreTypes in '..\core\u3dCoreTypes.pas',
  u3dContracts in '..\contracts\u3dContracts.pas',
  u3dHelperMotionEngine in '..\animation\u3dHelperMotionEngine.pas',
  u3dFrfDisplacementSource in '..\animation\u3dFrfDisplacementSource.pas',
  u3dFrfAnimationComponent in '..\animation\u3dFrfAnimationComponent.pas',
  u3dLegacySceneLoader in '..\legacy\u3dLegacySceneLoader.pas';

type
  TTarget = class(TInterfacedObject, I3dTransformTarget)
  public
    Value: T3dVector3;
    function BindingId: Integer;
    procedure SetLocalDisplacement(const AValue: T3dVector3);
  end;

  TInvalidation = class(TInterfacedObject, I3dInvalidationSink)
  public
    Count: Integer;
    procedure InvalidateGeometry;
  end;

  TTimeSource = class(TInterfacedObject, I3dDisplacementSource)
  public
    function PointCount: Integer;
    function TryReadDisplacement(const APointIndex: Integer;
      const ATime: Double; out AValue: T3dVector3;
      out AVersion: Cardinal): Boolean;
  end;

function TTarget.BindingId: Integer;
begin
  Result := 1;
end;

procedure TTarget.SetLocalDisplacement(const AValue: T3dVector3);
begin
  Value := AValue;
end;

procedure TInvalidation.InvalidateGeometry;
begin
  Inc(Count);
end;

function TTimeSource.PointCount: Integer;
begin
  Result := 1;
end;

function TTimeSource.TryReadDisplacement(const APointIndex: Integer;
  const ATime: Double; out AValue: T3dVector3;
  out AVersion: Cardinal): Boolean;
begin
  Result := APointIndex = 0;
  AValue := Vector3(ATime, 0, 0);
  AVersion := 1;
end;

procedure Check(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure Run;
var
  lBinding: T3dHelperBinding;
  lEngine: T3dHelperMotionEngine;
  lFrf: T3dFrfDisplacementSource;
  lInvalidationObject: TInvalidation;
  lPoint: T3dFrfPointSeries;
  lSource: I3dDisplacementSource;
  lTarget: I3dTransformTarget;
  lTargetObject: TTarget;
  lInvalidation: I3dInvalidationSink;
  lInvalidPoint: T3dFrfPointSeries;
  lRaised: Boolean;
  lValue: T3dVector3;
  lVersion: Cardinal;
  lWrapPoint: T3dFrfPointSeries;
begin
  SetLength(lPoint.X.Amplitude, 2);
  SetLength(lPoint.X.PhaseDegrees, 2);
  lPoint.X.Amplitude[0] := 1;
  lPoint.X.Amplitude[1] := 3;
  lPoint.X.PhaseDegrees[0] := 0;
  lPoint.X.PhaseDegrees[1] := 0;

  lFrf := T3dFrfDisplacementSource.Create;
  lSource := lFrf;
  lFrf.Configure(10, [lPoint]);
  lFrf.SetFrame(5, Pi / 2, 7);

  lTargetObject := TTarget.Create;
  lTarget := lTargetObject;
  lInvalidationObject := TInvalidation.Create;
  lInvalidation := lInvalidationObject;
  lBinding.PointIndex := 0;
  lBinding.Frame := IdentityAxisFrame;
  lBinding.Frame.XAxis := Vector3(0, 1, 0);
  lBinding.Scale := 2;
  lBinding.BasePosition := Vector3(10, 20, 30);
  lBinding.Source := lSource;
  lBinding.Target := lTarget;

  lEngine := T3dHelperMotionEngine.Create;
  try
    lEngine.Configure([lBinding], lInvalidation);
    Check(lEngine.Update(0), 'First frame was not applied');
    Check(Abs(lTargetObject.Value.Y - 24) < 1E-9,
      'FRF interpolation or helper axis mapping failed');
    Check(not lEngine.Update(0), 'Unchanged version was applied twice');
    Check(lInvalidationObject.Count = 1, 'Unexpected invalidation count');

    SetLength(lWrapPoint.X.Amplitude, 2);
    SetLength(lWrapPoint.X.PhaseDegrees, 2);
    lWrapPoint.X.Amplitude[0] := 1;
    lWrapPoint.X.Amplitude[1] := 1;
    lWrapPoint.X.PhaseDegrees[0] := 359;
    lWrapPoint.X.PhaseDegrees[1] := 1;
    lFrf.Configure(10, [lWrapPoint]);
    lFrf.SetFrame(5, Pi / 2, 8);
    Check(lFrf.TryReadDisplacement(0, 0, lValue, lVersion),
      'Wrapped phase sample is unavailable');
    Check(Abs(lValue.X - 1) < 1E-9,
      'Phase interpolation did not use the shortest arc');

    SetLength(lInvalidPoint.Y.Amplitude, 1);
    lRaised := False;
    try
      lFrf.Configure(10, [lInvalidPoint]);
    except
      on EArgumentException do
        lRaised := True;
    end;
    Check(lRaised, 'Invalid FRF configuration was accepted');
    Check(lFrf.PointCount = 1, 'Invalid configure replaced valid state');
    Check(lFrf.TryReadDisplacement(0, 0, lValue, lVersion),
      'Valid FRF state was lost after invalid configure');
  finally
    lEngine.Free;
  end;
end;

procedure RunTimeDependentSource;
var
  lBinding: T3dHelperBinding;
  lEngine: T3dHelperMotionEngine;
  lSource: I3dDisplacementSource;
  lTarget: I3dTransformTarget;
  lTargetObject: TTarget;
begin
  lSource := TTimeSource.Create;
  lTargetObject := TTarget.Create;
  lTarget := lTargetObject;
  lBinding.PointIndex := 0;
  lBinding.Frame := IdentityAxisFrame;
  lBinding.Scale := 1;
  lBinding.BasePosition := Vector3(0, 0, 0);
  lBinding.Source := lSource;
  lBinding.Target := lTarget;
  lEngine := T3dHelperMotionEngine.Create;
  try
    lEngine.Configure([lBinding], nil);
    Check(lEngine.Update(0), 'Initial time frame was not applied');
    Check(lEngine.Update(1), 'New time with the same version was skipped');
    Check(Abs(lTargetObject.Value.X - 1) < 1E-9,
      'Time-dependent displacement was not applied');
  finally
    lEngine.Free;
  end;
end;

begin
  try
    Run;
    RunTimeDependentSource;
    Writeln('OK');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
