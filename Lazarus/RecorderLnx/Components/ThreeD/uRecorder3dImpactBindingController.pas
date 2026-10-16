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
    procedure SynchronizeColorAnchors(const ASourceBindingId:string);
  public
    constructor Create(AComponent: TRecorder3dComponent; AScene: T3dScene);
    function ResolvePoint(const APointGroup: string; APointNumber: Integer;
      out ATargetNodeId: QWord): Boolean;
    function ObjectCount: Integer;
    function ObjectInfo(AIndex: Integer;
      out AInfo: TRecorderModelObjectInfo): Boolean;
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

function TRecorder3dImpactBindingController.ObjectCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if fScene = nil then
    Exit;
  for I := 0 to High(fScene.Nodes) do
    if fScene.Nodes[I].Mesh <> nil then
      Inc(Result);
end;

function TRecorder3dImpactBindingController.ObjectInfo(AIndex: Integer;
  out AInfo: TRecorderModelObjectInfo): Boolean;
var
  I: Integer;
begin
  AInfo.NodeId := 0;
  AInfo.Name := '';
  Result := False;
  if (fScene = nil) or (AIndex < 0) then
    Exit;
  for I := 0 to High(fScene.Nodes) do
    if fScene.Nodes[I].Mesh <> nil then
    begin
      if AIndex = 0 then
      begin
        AInfo.NodeId := fScene.Nodes[I].Id;
        AInfo.Name := fScene.Nodes[I].Name;
        Exit(True);
      end;
      Dec(AIndex);
    end;
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
    Specs[I].Mode := ABindings[I].Mode;
    Specs[I].ModifierTargetNodeId := ABindings[I].ModifierTargetNodeId;
    Specs[I].IntensityOnly := ABindings[I].IntensityOnly;
    Specs[I].Visualization := ABindings[I].Visualization;
    Specs[I].PointNumber := ABindings[I].PointNumber;
    Specs[I].MarkerSizePixels := ABindings[I].MarkerSizePixels;
    Specs[I].IntensitySource := ABindings[I].IntensitySource;
    Specs[I].BandRms := ABindings[I].BandRms;
    Specs[I].BandTolerancePercent := ABindings[I].BandTolerancePercent;
    Specs[I].GradientEnabled := ABindings[I].GradientEnabled;
    Specs[I].Color := ABindings[I].Color;
    Specs[I].PointLabel:=ABindings[I].PointLabel;
    Specs[I].CreateColorModifier:=ABindings[I].CreateColorModifier;
    Specs[I].HideAnchors:=ABindings[I].HideAnchors;
    Specs[I].OnlySensors:=ABindings[I].OnlySensors;
    Specs[I].EnvelopeXEnabled:=ABindings[I].EnvelopeXEnabled;
    Specs[I].EnvelopeYEnabled:=ABindings[I].EnvelopeYEnabled;
    Specs[I].EnvelopeZEnabled:=ABindings[I].EnvelopeZEnabled;
    Specs[I].EnvelopeX:=ABindings[I].EnvelopeX;
    Specs[I].EnvelopeY:=ABindings[I].EnvelopeY;
    Specs[I].EnvelopeZ:=ABindings[I].EnvelopeZ;
  end;
  if fComponent.ReplaceFrfBindingsBySourceId(ASourceBindingId, Specs,
    fBeforeBindingCreate) then
  begin
    SynchronizeColorAnchors(ASourceBindingId);
    if Assigned(fOnBindingsChanged) then fOnBindingsChanged(Self);
  end;
end;

procedure TRecorder3dImpactBindingController.SynchronizeColorAnchors(
  const ASourceBindingId:string);
var lIndex,lOther:Integer; lBinding:TRecorder3dFrfBinding;
  lAnchor:TRecorder3dVertexColorAnchor; lGradient:TRecorder3dGradientStrip;
  lGradientId,lNextId:QWord;
  lSourceGradient:TRecorder3dGradientStrip;
begin
  for lIndex:=fComponent.VertexColorAnchorCount-1 downto 0 do
    if fComponent.VertexColorAnchors[lIndex].SourceBindingId=ASourceBindingId then
      fComponent.DeleteVertexColorAnchor(lIndex);
  lGradientId:=0; lNextId:=1;
  lSourceGradient:=nil;
  for lIndex:=0 to fComponent.GradientStripCount-1 do
  begin
    lGradient:=fComponent.GradientStrips[lIndex];
    if lGradient.Name='FRF '+ASourceBindingId then
    begin lGradientId:=lGradient.Id; lSourceGradient:=lGradient; end;
    if lGradient.Id>=lNextId then lNextId:=lGradient.Id+1;
  end;
  for lIndex:=0 to fComponent.FrfBindingCount-1 do
  begin
    lBinding:=fComponent.FrfBindings[lIndex];
    if (lBinding.SourceBindingId<>ASourceBindingId) or
      not lBinding.CreateColorModifier or (lBinding.PointNumber<1) then Continue;
    if lGradientId=0 then
    begin
      lGradient:=fComponent.AddGradientStrip;
      lGradientId:=lNextId; lGradient.Id:=lGradientId;
      lGradient.Name:='FRF '+ASourceBindingId;
      lSourceGradient:=lGradient;
      lGradient.LeftValue:=0; lGradient.RightValue:=1;
    end;
    lSourceGradient.CadGradient:=lBinding.GradientEnabled;
    if lBinding.GradientEnabled then
    begin
      lSourceGradient.LeftColor:=$0000FF00;
      lSourceGradient.RightColor:=$000000FF;
    end
    else
    begin
      lSourceGradient.LeftColor:=lBinding.Color;
      lSourceGradient.RightColor:=lBinding.Color;
    end;
    lAnchor:=fComponent.AddVertexColorAnchor;
    lNextId:=1;
    for lOther:=0 to fComponent.VertexColorAnchorCount-2 do
      if fComponent.VertexColorAnchors[lOther].Id>=lNextId then
        lNextId:=fComponent.VertexColorAnchors[lOther].Id+1;
    lAnchor.Id:=lNextId;
    lAnchor.SourceBindingId:=ASourceBindingId;
    lAnchor.Name:=lBinding.PointLabel;
    if lAnchor.Name='' then lAnchor.Name:=IntToStr(lBinding.PointNumber);
    lAnchor.MeshNodeId:=lBinding.ModifierTargetNodeId;
    lAnchor.LogicalVertexId:=lBinding.PointNumber-1;
    lAnchor.FrfCurveId:=lBinding.CurveId;
    lAnchor.FrfIntensitySource:=lBinding.IntensitySource;
    lAnchor.FrfBandRms:=lBinding.BandRms;
    lAnchor.FrfBandTolerancePercent:=lBinding.BandTolerancePercent;
    lAnchor.FrfGain:=lBinding.Gain;
    lAnchor.GradientId:=lGradientId;
    lAnchor.Enabled:=lBinding.Enabled;
    lAnchor.ShowValueLabel:=False;
    lAnchor.EnvelopeXEnabled:=lBinding.EnvelopeXEnabled;
    lAnchor.EnvelopeYEnabled:=lBinding.EnvelopeYEnabled;
    lAnchor.EnvelopeZEnabled:=lBinding.EnvelopeZEnabled;
    lAnchor.EnvelopeX:=lBinding.EnvelopeX;
    lAnchor.EnvelopeY:=lBinding.EnvelopeY;
    lAnchor.EnvelopeZ:=lBinding.EnvelopeZ;
  end;
end;

procedure TRecorder3dImpactBindingController.RemoveBindings(
  const ASourceBindingId: string);
begin
  if fComponent <> nil then
  begin
    fComponent.RemoveFrfBindingsBySourceId(ASourceBindingId);
    SynchronizeColorAnchors(ASourceBindingId);
  end;
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
