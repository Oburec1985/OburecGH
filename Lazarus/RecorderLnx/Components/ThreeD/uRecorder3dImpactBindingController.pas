unit uRecorder3dImpactBindingController;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Recorder composition boundary for impact point bindings. It resolves stable
  scene helpers and updates only the persistent 3D model; rendering remains a
  consumer of the normal model -> motion-engine configuration flow. }

interface

uses
  Classes, SysUtils, Math, u3dScene, u3dMotionContracts, uRecorder3dModel,
  uRecorderImpactHammerContracts;

type
  TRecorder3dImpactBindingController = class(TInterfacedObject,
    IRecorderModelPointCatalog, IRecorderModelPointBindingSink)
  private
    fComponent: TRecorder3dComponent;
    fScene: T3dScene;
    fAnimationPlaying: Boolean;
    fAnimationScale: Double;
    fAnimationFrequencyHz: Double;
    fAnimationPhase: Double;
    fActiveSourceBindingId: string;
    fOnBindingsChanged: TNotifyEvent;
    fBeforeBindingCreate: TRecorder3dFrfReplaceHook;
    function BindingsAreValid(
      const ABindings: array of TRecorderModelPointBinding): Boolean;
  public
    constructor Create(AComponent: TRecorder3dComponent; AScene: T3dScene);
    function ResolvePoint(const APointGroup: string; APointNumber: Integer;
      out ATargetNodeId: QWord): Boolean;
    procedure PublishBindings(const ASourceBindingId,
      ATargetComponentId: string;
      const ABindings: array of TRecorderModelPointBinding);
    procedure RemoveBindings(const ASourceBindingId: string);
    procedure ConfigureAnimation(const ASourceBindingId: string;
      AScale, AFrequencyHz: Double);
    procedure PlayAnimation(const ASourceBindingId: string);
    procedure StopAnimation(const ASourceBindingId: string);
    procedure Play;
    procedure Stop;
    procedure Advance(ADeltaSeconds: Double);
    property AnimationPlaying: Boolean read fAnimationPlaying;
    property AnimationScale: Double read fAnimationScale write fAnimationScale;
    property AnimationFrequencyHz: Double read fAnimationFrequencyHz
      write fAnimationFrequencyHz;
    property AnimationPhase: Double read fAnimationPhase;
    property ActiveSourceBindingId: string read fActiveSourceBindingId;
    property OnBindingsChanged: TNotifyEvent read fOnBindingsChanged
      write fOnBindingsChanged;
    property BeforeBindingCreate: TRecorder3dFrfReplaceHook
      read fBeforeBindingCreate write fBeforeBindingCreate;
  end;

implementation

function TRecorder3dImpactBindingController.BindingsAreValid(
  const ABindings: array of TRecorderModelPointBinding): Boolean;
var
  I: Integer;
  J: Integer;
begin
  Result := False;
  if (fScene = nil) or (Length(ABindings) = 0) then
    Exit;
  for I := 0 to High(ABindings) do
  begin
    if (ABindings[I].CurveId = 0) or
      (fScene.FindNode(ABindings[I].TargetNodeId) = nil) or
      (Ord(ABindings[I].Axis) < Ord(Low(T3dMotionAxis))) or
      (Ord(ABindings[I].Axis) > Ord(High(T3dMotionAxis))) or
      (Ord(ABindings[I].Space) < Ord(Low(T3dMotionSpace))) or
      (Ord(ABindings[I].Space) > Ord(High(T3dMotionSpace))) or
      IsNan(ABindings[I].Gain) or IsInfinite(ABindings[I].Gain) then
      Exit;
    for J := 0 to I - 1 do
      if ABindings[J].CurveId = ABindings[I].CurveId then
        Exit;
  end;
  Result := True;
end;

constructor TRecorder3dImpactBindingController.Create(
  AComponent: TRecorder3dComponent; AScene: T3dScene);
begin
  inherited Create;
  fComponent := AComponent;
  fScene := AScene;
  fAnimationScale := 1;
  fAnimationFrequencyHz := 1;
end;

function TRecorder3dImpactBindingController.ResolvePoint(
  const APointGroup: string; APointNumber: Integer;
  out ATargetNodeId: QWord): Boolean;
var
  I: Integer;
  PointText: string;
  Name: string;
begin
  Result := False;
  ATargetNodeId := 0;
  if fScene = nil then
    Exit;
  PointText := IntToStr(APointNumber);
  for I := 0 to High(fScene.Nodes) do
  begin
    Name := fScene.Nodes[I].Name;
    if (Name = PointText) or (Name = APointGroup + PointText) or
      (Name = APointGroup + '.' + PointText) or
      (Name = APointGroup + ':' + PointText) then
    begin
      ATargetNodeId := fScene.Nodes[I].Id;
      Exit(True);
    end;
  end;
end;

procedure TRecorder3dImpactBindingController.PublishBindings(
  const ASourceBindingId, ATargetComponentId: string;
  const ABindings: array of TRecorderModelPointBinding);
var
  Specs: TRecorder3dFrfBindingSpecArray;
  I: Integer;
begin
  if (fComponent = nil) or (ASourceBindingId = '') or
    (ATargetComponentId = '') or
    (fComponent.Id <> ATargetComponentId) or
    not BindingsAreValid(ABindings) then
    Exit;
  SetLength(Specs, Length(ABindings));
  for I := 0 to High(ABindings) do
  begin
    Specs[I].CurveId := ABindings[I].CurveId;
    Specs[I].TargetNodeId := ABindings[I].TargetNodeId;
    Specs[I].Axis := ABindings[I].Axis;
    Specs[I].Space := ABindings[I].Space;
    Specs[I].Gain := ABindings[I].Gain;
    Specs[I].Enabled := ABindings[I].Enabled;
  end;
  if fComponent.ReplaceFrfBindingsBySourceId(ASourceBindingId, Specs,
    fBeforeBindingCreate) and Assigned(fOnBindingsChanged) then
    fOnBindingsChanged(Self);
end;

procedure TRecorder3dImpactBindingController.RemoveBindings(
  const ASourceBindingId: string);
begin
  if fComponent <> nil then
    fComponent.RemoveFrfBindingsBySourceId(ASourceBindingId);
  if Assigned(fOnBindingsChanged) then
    fOnBindingsChanged(Self);
end;

procedure TRecorder3dImpactBindingController.Play;
begin
  fAnimationPlaying := True;
end;

procedure TRecorder3dImpactBindingController.ConfigureAnimation(
  const ASourceBindingId: string; AScale, AFrequencyHz: Double);
begin
  if (ASourceBindingId = '') or IsNan(AScale) or IsInfinite(AScale) or
    (AScale <= 0) or IsNan(AFrequencyHz) or IsInfinite(AFrequencyHz) or
    (AFrequencyHz <= 0) then
    Exit;
  fActiveSourceBindingId := ASourceBindingId;
  fAnimationScale := AScale;
  fAnimationFrequencyHz := AFrequencyHz;
  if Assigned(fOnBindingsChanged) then
    fOnBindingsChanged(Self);
end;

procedure TRecorder3dImpactBindingController.PlayAnimation(
  const ASourceBindingId: string);
begin
  fActiveSourceBindingId := ASourceBindingId;
  Play;
end;

procedure TRecorder3dImpactBindingController.StopAnimation(
  const ASourceBindingId: string);
begin
  if fActiveSourceBindingId <> ASourceBindingId then
    Exit;
  Stop;
end;

procedure TRecorder3dImpactBindingController.Stop;
begin
  fAnimationPlaying := False;
  fAnimationPhase := 0;
end;

procedure TRecorder3dImpactBindingController.Advance(ADeltaSeconds: Double);
begin
  if not fAnimationPlaying or IsNan(ADeltaSeconds) or
    IsInfinite(ADeltaSeconds) or (ADeltaSeconds <= 0) then
    Exit;
  fAnimationPhase := fAnimationPhase +
    2 * Pi * fAnimationFrequencyHz * ADeltaSeconds;
  fAnimationPhase := fAnimationPhase -
    Floor(fAnimationPhase / (2 * Pi)) * 2 * Pi;
end;

end.
