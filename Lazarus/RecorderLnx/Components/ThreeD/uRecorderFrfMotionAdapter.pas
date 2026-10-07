unit uRecorderFrfMotionAdapter;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Recorder-side FRF-to-motion adapter. The 3D view configures it after scene
  load and calls Update from the display refresh; sampler and sink interfaces
  remain externally owned and are retained only for the configured lifetime. }

interface

uses
  u3dMotionContracts, uRecorderFrfContracts;

type
  TRecorderFrfMotionBinding = record
    CurveId: QWord;
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    Gain: Double;
    Enabled: Boolean;
  end;

  { Converts measured magnitude/phase into one batched helper displacement.
    Configure must precede Update; the adapter owns only its copied bindings
    and reusable command buffer. }
  TRecorderFrfMotionAdapter = class
  private
    fSampler: IRecorderFrfSampler;
    fProvider: IRecorderFrfProvider;
    fSink: I3dMotionSink;
    fBindings: array of TRecorderFrfMotionBinding;
    fCommands: array of T3dMotionCommand;
  public
    procedure Configure(const ASampler: IRecorderFrfSampler;
      const ASink: I3dMotionSink;
      const ABindings: array of TRecorderFrfMotionBinding);
    procedure ConfigureProvider(const AProvider: IRecorderFrfProvider;
      const ASink: I3dMotionSink;
      const ABindings: array of TRecorderFrfMotionBinding);
    function Update(AFrequencyHz, AAnimationPhaseRadians: Double): Boolean;
  end;

implementation

uses
  Math;

procedure TRecorderFrfMotionAdapter.Configure(
  const ASampler: IRecorderFrfSampler; const ASink: I3dMotionSink;
  const ABindings: array of TRecorderFrfMotionBinding);
var
  lIndex: Integer;
begin
  fProvider := nil;
  fSampler := ASampler;
  fSink := ASink;
  SetLength(fBindings, Length(ABindings));
  SetLength(fCommands, Length(ABindings));
  for lIndex := 0 to High(ABindings) do
    fBindings[lIndex] := ABindings[lIndex];
end;

procedure TRecorderFrfMotionAdapter.ConfigureProvider(
  const AProvider: IRecorderFrfProvider; const ASink: I3dMotionSink;
  const ABindings: array of TRecorderFrfMotionBinding);
var
  lIndex: Integer;
begin
  fSampler := nil;
  fProvider := AProvider;
  fSink := ASink;
  SetLength(fBindings, Length(ABindings));
  SetLength(fCommands, Length(ABindings));
  for lIndex := 0 to High(ABindings) do
    fBindings[lIndex] := ABindings[lIndex];
end;

function TRecorderFrfMotionAdapter.Update(AFrequencyHz,
  AAnimationPhaseRadians: Double): Boolean;
var
  lBinding, lCount: Integer;
  lMagnitude, lPhase: Double;
  lSampler: IRecorderFrfSampler;
begin
  Result := False;
  lSampler := fSampler;
  if fProvider <> nil then
    lSampler := fProvider.AcquireSnapshot;
  if (lSampler = nil) or (fSink = nil) or IsNan(AAnimationPhaseRadians) or
    IsInfinite(AAnimationPhaseRadians) then
    Exit;
  lCount := 0;
  for lBinding := 0 to High(fBindings) do
    if fBindings[lBinding].Enabled and
      lSampler.TrySample(fBindings[lBinding].CurveId, AFrequencyHz,
        lMagnitude, lPhase) then
    begin
      fCommands[lCount].TargetNodeId := fBindings[lBinding].TargetNodeId;
      fCommands[lCount].Axis := fBindings[lBinding].Axis;
      fCommands[lCount].Space := fBindings[lBinding].Space;
      fCommands[lCount].Offset := fBindings[lBinding].Gain * lMagnitude *
        Sin(lPhase + AAnimationPhaseRadians);
      Inc(lCount);
    end;
  if lCount > 0 then
    Result := fSink.Apply(Slice(fCommands, lCount));
end;

end.
