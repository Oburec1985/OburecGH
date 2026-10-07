unit u3dVertexColors;

{$mode objfpc}{$H+}

{ Prepared bind-pose soft selection and normalized vertex-color blending. }

interface

uses
  Math, u3dCoreTypes, u3dScene;

type
  T3dVertexColorFalloff=(vcfLinear,vcfSmooth,vcfExponent);

  T3dGradientStrip=record
    Id:QWord;
    Name:string;
    LeftColor,RightColor:T3dColor;
    LeftValue,RightValue:Double;
  end;
  T3dGradientStrips=array of T3dGradientStrip;

  T3dVertexColorAnchorEval=record
    LogicalIndex:Integer;
    Radius,FalloffExponent:Single;
    Falloff:T3dVertexColorFalloff;
    GradientIndex:Integer;
    Value:Double;
    Enabled,ApplyColor:Boolean;
  end;
  T3dVertexColorAnchorEvals=array of T3dVertexColorAnchorEval;

  T3dVertexColorWeightRow=array of Single;
  T3dVertexColorWeightRows=array of T3dVertexColorWeightRow;

  T3dVertexColorEngine=class
  private
    fMesh:T3dMeshData;
    fGradients:T3dGradientStrips;
    fAnchors:T3dVertexColorAnchorEvals;
    fWeights:T3dVertexColorWeightRows;
    function LogicalPosition(AIndex:Integer):T3dVector;
    function Weight(ADistance,ARadius,AExponent:Single;
      AFalloff:T3dVertexColorFalloff):Single;
  public
    procedure Configure(AMesh:T3dMeshData;
      const AGradients:T3dGradientStrips;
      const AAnchors:T3dVertexColorAnchorEvals);
    procedure SetAnchorValue(AIndex:Integer; AValue:Double);
    procedure SetAnchorEnabled(AIndex:Integer; AEnabled:Boolean);
    procedure Apply;
  end;

function GradientColor(const AGradient:T3dGradientStrip;
  AValue:Double):T3dColor;

implementation

function ClampByte(AValue:Double):Byte;
begin
  Result:=Round(EnsureRange(AValue,0,255));
end;

function GradientColor(const AGradient:T3dGradientStrip;
  AValue:Double):T3dColor;
var T:Double;
begin
  if SameValue(AGradient.LeftValue,AGradient.RightValue) then
    T:=0
  else
    T:=EnsureRange((AValue-AGradient.LeftValue)/
      (AGradient.RightValue-AGradient.LeftValue),0,1);
  Result.R:=ClampByte(AGradient.LeftColor.R+
    (AGradient.RightColor.R-AGradient.LeftColor.R)*T);
  Result.G:=ClampByte(AGradient.LeftColor.G+
    (AGradient.RightColor.G-AGradient.LeftColor.G)*T);
  Result.B:=ClampByte(AGradient.LeftColor.B+
    (AGradient.RightColor.B-AGradient.LeftColor.B)*T);
end;

function T3dVertexColorEngine.LogicalPosition(AIndex:Integer):T3dVector;
var Corner:LongWord;
begin
  Result:=Vector3d(0,0,0);
  if (fMesh=nil) or (AIndex<0) or
     (AIndex>High(fMesh.LogicalVertices)) or
     (Length(fMesh.LogicalVertices[AIndex].CornerIndices)=0) then Exit;
  Corner:=fMesh.LogicalVertices[AIndex].CornerIndices[0];
  if Corner<LongWord(Length(fMesh.BasePositions)) then
    Result:=fMesh.BasePositions[Corner]
  else if Corner<LongWord(Length(fMesh.Positions)) then
    Result:=fMesh.Positions[Corner];
end;

function T3dVertexColorEngine.Weight(ADistance,ARadius,AExponent:Single;
  AFalloff:T3dVertexColorFalloff):Single;
var T:Single;
begin
  if ARadius<=0 then
  begin
    if ADistance<=1.0e-6 then Exit(1);
    Exit(0);
  end;
  T:=EnsureRange(1-ADistance/ARadius,0,1);
  case AFalloff of
    vcfSmooth:Result:=T*T*(3-2*T);
    vcfExponent:Result:=Power(T,Max(0.01,AExponent));
    else Result:=T;
  end;
end;

procedure T3dVertexColorEngine.Configure(AMesh:T3dMeshData;
  const AGradients:T3dGradientStrips;
  const AAnchors:T3dVertexColorAnchorEvals);
var A,L:Integer; P,E:T3dVector; D:Single;
begin
  fMesh:=AMesh;
  fGradients:=Copy(AGradients);
  fAnchors:=Copy(AAnchors);
  SetLength(fWeights,Length(fAnchors));
  if fMesh=nil then Exit;
  for A:=0 to High(fAnchors) do
  begin
    SetLength(fWeights[A],Length(fMesh.LogicalVertices));
    if (not fAnchors[A].Enabled) or (not fAnchors[A].ApplyColor) or
       (fAnchors[A].LogicalIndex<0) or
       (fAnchors[A].LogicalIndex>High(fMesh.LogicalVertices)) then Continue;
    E:=LogicalPosition(fAnchors[A].LogicalIndex);
    for L:=0 to High(fMesh.LogicalVertices) do
    begin
      P:=LogicalPosition(L);
      D:=Sqrt(Sqr(P.X-E.X)+Sqr(P.Y-E.Y)+Sqr(P.Z-E.Z));
      fWeights[A][L]:=Weight(D,fAnchors[A].Radius,
        fAnchors[A].FalloffExponent,fAnchors[A].Falloff);
    end;
  end;
end;

procedure T3dVertexColorEngine.SetAnchorValue(AIndex:Integer; AValue:Double);
begin
  if (AIndex>=0) and (AIndex<=High(fAnchors)) then
    fAnchors[AIndex].Value:=AValue;
end;

procedure T3dVertexColorEngine.SetAnchorEnabled(AIndex:Integer;
  AEnabled:Boolean);
begin
  if (AIndex>=0) and (AIndex<=High(fAnchors)) then
    fAnchors[AIndex].Enabled:=AEnabled;
end;

procedure T3dVertexColorEngine.Apply;
var L,A,C:Integer; Sum,W:Double; Color:T3dColor;
  R,G,B:Double; Corner:LongWord;
begin
  if fMesh=nil then Exit;
  SetLength(fMesh.VertexColors,Length(fMesh.Positions));
  for C:=0 to High(fMesh.VertexColors) do fMesh.VertexColors[C]:=fMesh.Color;
  for L:=0 to High(fMesh.LogicalVertices) do
  begin
    Sum:=0; R:=0; G:=0; B:=0;
    for A:=0 to High(fAnchors) do
      if fAnchors[A].Enabled and fAnchors[A].ApplyColor and
         (fAnchors[A].GradientIndex>=0) and
         (fAnchors[A].GradientIndex<=High(fGradients)) then
      begin
        W:=fWeights[A][L];
        if W<=0 then Continue;
        Color:=GradientColor(fGradients[fAnchors[A].GradientIndex],
          fAnchors[A].Value);
        Sum:=Sum+W;
        R:=R+Color.R*W; G:=G+Color.G*W; B:=B+Color.B*W;
      end;
    if Sum<=0 then Continue;
    Color.R:=ClampByte(R/Sum); Color.G:=ClampByte(G/Sum);
    Color.B:=ClampByte(B/Sum);
    for C:=0 to High(fMesh.LogicalVertices[L].CornerIndices) do
    begin
      Corner:=fMesh.LogicalVertices[L].CornerIndices[C];
      if Corner<LongWord(Length(fMesh.VertexColors)) then
        fMesh.VertexColors[Corner]:=Color;
    end;
  end;
end;

end.
