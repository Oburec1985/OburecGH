unit uRecorderFrfIntensityAdapter;
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses Graphics, u3dScene, u3dCoreTypes, u3dMotionContracts,
  uRecorderFrfContracts, uRecorderImpactHammerContracts;
type
  TRecorderFrfIntensityBinding = record
    CurveId, TargetNodeId: QWord;
    PointNumber: Integer;
    Gain, MarkerSizePixels: Double;
    Color: TColor;
    Axis: T3dMotionAxis;
    Visualization: TRecorderPointVisualization;
    IntensitySource: TRecorderIntensitySource;
    BandRms,GradientEnabled:Boolean;
    BandTolerancePercent:Double;
    PointLabel:string;
    HideAnchors:Boolean;
    ShowIntensityValues:Boolean;
    EnvelopeXEnabled,EnvelopeYEnabled,EnvelopeZEnabled:Boolean;
    EnvelopeX,EnvelopeY,EnvelopeZ:Double;
    Enabled: Boolean;
  end;
  TRecorderIntensityMarker = record
    TargetNodeId:QWord;
    PointNumber:Integer;
    Position: T3dVector;
    SizePixels: Double;
    Color: TColor;
    Axis: T3dMotionAxis;
    Visualization: TRecorderPointVisualization;
    Visible: Boolean;
    DrawSymbol:Boolean;
    ShowValue:Boolean;
    PointLabel:string;
  end;
  TRecorderFrfIntensityAdapter = class
  private
    fProvider: IRecorderFrfProvider;
    fScene: T3dScene;
    fBindings: array of TRecorderFrfIntensityBinding;
    fMarkers: array of TRecorderIntensityMarker;
    fValues, fPhases: array of Double;
    fNormalizationSampler: IRecorderFrfSampler;
    fNormalizationVersion: QWord;
    fNormalizationMin, fNormalizationMax, fNormalizationPeak: Double;
    fNormalizationReady: Boolean;
    procedure UpdateNormalization(const ASampler: IRecorderFrfSampler);
    procedure PublishLabels;
    function ResolvePosition(const ABinding: TRecorderFrfIntensityBinding;
      out APosition: T3dVector): Boolean;
  public
    procedure Configure(const AProvider: IRecorderFrfProvider;
      AScene: T3dScene; const ABindings: array of TRecorderFrfIntensityBinding);
    function Update(AFrequencyHz: Double; APhase: Double = 0;
      AAnimating: Boolean = False): Boolean;
    function MarkerCount: Integer;
    function Marker(AIndex: Integer): TRecorderIntensityMarker;
    procedure Demonstrate(AScene: T3dScene;
      const ABinding: TRecorderModelPointBinding);
  end;
implementation
uses Math, SysUtils, u3dGeometryMath;

procedure TRecorderFrfIntensityAdapter.PublishLabels;
var I:Integer; L:T3dSceneLabel; N:T3dNode; P:Integer;
begin
  if fScene=nil then Exit;
  for I:=0 to High(fBindings) do
  begin
    L:=fScene.EnsureLabel(PtrUInt(Self),I);
    L.Text:=fMarkers[I].PointLabel;
    L.Visible:=fBindings[I].Enabled and fMarkers[I].Visible and
      not fMarkers[I].ShowValue and (L.Text<>'');
    L.NodeId:=fBindings[I].TargetNodeId;
    N:=fScene.FindNode(L.NodeId);
    L.AtVertex:=(N<>nil) and (N.Mesh<>nil);
    if L.AtVertex then
    begin
      P:=fBindings[I].PointNumber-1;
      L.Visible:=L.Visible and (P>=0) and (P<Length(N.Mesh.LogicalVertices));
      if L.Visible then L.LogicalVertexId:=N.Mesh.LogicalVertices[P].Id;
    end;
  end;
end;


procedure TRecorderFrfIntensityAdapter.Demonstrate(AScene:T3dScene;
  const ABinding:TRecorderModelPointBinding);
var lBinding:TRecorderFrfIntensityBinding;
begin
  lBinding:=Default(TRecorderFrfIntensityBinding);
  lBinding.TargetNodeId:=ABinding.ModifierTargetNodeId;
  lBinding.PointNumber:=ABinding.PointNumber;
  lBinding.Enabled:=True;
  Configure(nil,AScene,[lBinding]);
  fMarkers[0].Visible:=(AScene<>nil) and
    ResolvePosition(lBinding,fMarkers[0].Position);
  fMarkers[0].SizePixels:=ABinding.MarkerSizePixels;
  fMarkers[0].DrawSymbol:=True;
  fMarkers[0].PointLabel:=ABinding.PointLabel;
  fMarkers[0].Color:=ABinding.Color;
  fMarkers[0].Axis:=ABinding.Axis;
  fMarkers[0].Visualization:=ABinding.Visualization;
  PublishLabels;
end;

procedure TRecorderFrfIntensityAdapter.Configure(
  const AProvider: IRecorderFrfProvider; AScene: T3dScene;
  const ABindings: array of TRecorderFrfIntensityBinding);
var lIndex: Integer;
begin
  if fScene<>nil then fScene.RemoveLabels(PtrUInt(Self));
  fProvider:=AProvider;
  fNormalizationReady:=False;
  fNormalizationSampler:=nil;
  fScene:=AScene;
  SetLength(fBindings,Length(ABindings));
  SetLength(fMarkers,Length(ABindings));
  SetLength(fValues,Length(ABindings));
  SetLength(fPhases,Length(ABindings));
  for lIndex:=0 to High(ABindings) do
  begin
    fBindings[lIndex]:=ABindings[lIndex];
    fMarkers[lIndex]:=Default(TRecorderIntensityMarker);
    fMarkers[lIndex].Visible:=(fScene<>nil) and
      ResolvePosition(fBindings[lIndex],fMarkers[lIndex].Position);
    fMarkers[lIndex].DrawSymbol:=True;
    fMarkers[lIndex].PointLabel:=fBindings[lIndex].PointLabel;
  end;
  PublishLabels;
end;

procedure TRecorderFrfIntensityAdapter.UpdateNormalization(
  const ASampler: IRecorderFrfSampler);
var lMin,lMax,lPeak: Double; I: Integer; lRange: IRecorderFrfRangeScale;
begin
  if not GetRecorderFrfDisplayRange(lMin,lMax) then
  begin fNormalizationPeak:=0; Exit end;
  if fNormalizationReady and (fNormalizationSampler=ASampler) and
    (fNormalizationVersion=ASampler.Version) and
    (fNormalizationMin=lMin) and (fNormalizationMax=lMax) then Exit;
  fNormalizationPeak:=0;
  if Supports(ASampler,IRecorderFrfRangeScale,lRange) then
    for I:=0 to High(fBindings) do
      if fBindings[I].Enabled and lRange.TryGetRangeMaximum(fBindings[I].CurveId,
        lMin,lMax,fBindings[I].IntensitySource=risAmplitude,fBindings[I].BandRms,
        fBindings[I].BandTolerancePercent,lPeak) then
      begin
        lPeak:=Abs(lPeak*fBindings[I].Gain);
        if not IsNan(lPeak) and not IsInfinite(lPeak) then
          fNormalizationPeak:=Max(fNormalizationPeak,lPeak);
      end;
  fNormalizationSampler:=ASampler;
  fNormalizationVersion:=ASampler.Version;
  fNormalizationMin:=lMin;
  fNormalizationMax:=lMax;
  fNormalizationReady:=True;
end;

function TRecorderFrfIntensityAdapter.ResolvePosition(
  const ABinding: TRecorderFrfIntensityBinding; out APosition: T3dVector): Boolean;
var lNode:T3dNode; lPoint:Integer;
begin
  Result:=False;
  lNode:=fScene.FindNode(ABinding.TargetNodeId);
  if lNode=nil then Exit;
  lPoint:=ABinding.PointNumber-1;
  if (lNode.Mesh<>nil) and (lPoint>=0) and
    (lPoint<Length(lNode.Mesh.LogicalVertices)) and
    (Length(lNode.Mesh.LogicalVertices[lPoint].CornerIndices)>0) then
    lPoint:=lNode.Mesh.LogicalVertices[lPoint].CornerIndices[0];
  if (lNode.Mesh<>nil) and (lPoint>=0) and
    (lPoint<Length(lNode.Mesh.Positions)) then
    APosition:=TransformPoint(lNode.Mesh.Positions[lPoint],lNode.WorldTransform)
  else if lNode.Mesh=nil then
    APosition:=Vector3d(lNode.WorldTransform[12],lNode.WorldTransform[13],
      lNode.WorldTransform[14])
  else Exit;
  Result:=True;
end;

function TRecorderFrfIntensityAdapter.Update(AFrequencyHz, APhase: Double;
  AAnimating: Boolean): Boolean;
var lSampler:IRecorderFrfSampler; lAmplitude:IRecorderAmplitudeSampler;
  lBand:IRecorderFrfBandSampler;
  lIndex:Integer; lMaximum,lValue,lPhase,lSize,lPulse:Double;
  lMarker:TRecorderIntensityMarker;
begin
  Result:=False;
  if (fProvider=nil) or (fScene=nil) then Exit;
  lSampler:=fProvider.AcquireSnapshot;
  if lSampler=nil then Exit;
  UpdateNormalization(lSampler);
  lMaximum:=0;
  Supports(lSampler,IRecorderAmplitudeSampler,lAmplitude);
  Supports(lSampler,IRecorderFrfBandSampler,lBand);
  for lIndex:=0 to High(fBindings) do
  begin
    fValues[lIndex]:=-1;
    if not fBindings[lIndex].Enabled then Continue;
    if fBindings[lIndex].BandRms then
    begin
      if (lBand=nil) or not lBand.TrySampleBand(fBindings[lIndex].CurveId,
        AFrequencyHz,fBindings[lIndex].BandTolerancePercent,
        fBindings[lIndex].IntensitySource=risAmplitude,lValue,lPhase) then Continue;
    end
    else if fBindings[lIndex].IntensitySource=risAmplitude then
    begin
      if (lAmplitude=nil) or not lAmplitude.TrySampleAmplitude(
        fBindings[lIndex].CurveId,AFrequencyHz,lValue,lPhase) then Continue;
    end
    else if not lSampler.TrySample(fBindings[lIndex].CurveId,AFrequencyHz,
      lValue,lPhase) then Continue;
    lValue:=Abs(lValue*fBindings[lIndex].Gain);
    if IsNan(lValue) or IsInfinite(lValue) then Continue;
    fValues[lIndex]:=lValue;
    fPhases[lIndex]:=lPhase;
    lMaximum:=Max(lMaximum,lValue);
  end;
  for lIndex:=0 to High(fBindings) do
  begin
    lMarker:=Default(TRecorderIntensityMarker);
    lMarker.Visible:=ResolvePosition(fBindings[lIndex],lMarker.Position);
    lMarker.DrawSymbol:=True;
    lMarker.PointLabel:=fBindings[lIndex].PointLabel;
    if fBindings[lIndex].ShowIntensityValues and (fValues[lIndex]>=0) then
    begin
      lMarker.ShowValue:=True;
      lMarker.PointLabel:=lMarker.PointLabel+' = '+FloatToStrF(fValues[lIndex],ffGeneral,5,0);
    end;
    lSize:=0;
    { Preset range reference stays fixed while the frequency cursor moves. }
    if fNormalizationPeak>0 then lMaximum:=fNormalizationPeak;
    if (lMaximum>0) and lMarker.Visible and (fValues[lIndex]>=0) then
      lSize:=2*fBindings[lIndex].MarkerSizePixels*fValues[lIndex]/lMaximum;
    lPulse:=1;
    if AAnimating then lPulse:=Abs(Sin(APhase+fPhases[lIndex]));
    lMarker.SizePixels:=lSize*lPulse;
    lMarker.Color:=fBindings[lIndex].Color;
    lMarker.Axis:=fBindings[lIndex].Axis;
    lMarker.Visualization:=fBindings[lIndex].Visualization;
    fMarkers[lIndex]:=lMarker;
  end;
  PublishLabels;
  Result:=Length(fMarkers)>0;
end;

function TRecorderFrfIntensityAdapter.MarkerCount:Integer;
begin Result:=Length(fMarkers); end;
function TRecorderFrfIntensityAdapter.Marker(AIndex:Integer):TRecorderIntensityMarker;
begin
  Result:=fMarkers[AIndex];
  { Bind the presentation to scene identity, not to a sampled world position.
    The scene host resolves the current mesh and world matrix each frame. }
  Result.TargetNodeId:=fBindings[AIndex].TargetNodeId;
  Result.PointNumber:=fBindings[AIndex].PointNumber;
end;
end.
