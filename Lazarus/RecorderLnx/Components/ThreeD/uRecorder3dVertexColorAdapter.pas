unit uRecorder3dVertexColorAdapter;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Resolves persistent color anchors once per scene/configuration. The core
  engine caches bind-pose neighbourhood weights; the refresh path only reads
  already resolved tags, updates values and reapplies affected mesh colors. }

interface

uses
  SysUtils, Math, u3dCoreTypes, u3dScene, u3dGeometryMath, u3dSkin, u3dVertexColors,
  uRecorderTags, uRecorder3dModel;

type
  TRecorder3dVertexValueLabel=record
    Position:T3dVector;
    Text:string;
  end;
  TRecorder3dVertexValueLabels=array of TRecorder3dVertexValueLabel;

  TRecorder3dVertexColorGroup=class
  public
    Engine:T3dVertexColorEngine;
    Tags:array of TRecorderTag;
    TagIds:array of TRecorderTagId;
    TagNames:array of string;
    EstimateKinds:array of TRecorderTagEstimateKind;
    UseDefaultEstimates:array of Boolean;
    LastValues:array of Double;
    ConfigEnabled,LastActive,ActiveInitialized:array of Boolean;
    ShowLabels:array of Boolean;
    Names:array of string;
    LogicalIndices:array of Integer;
    Node:T3dNode;
    constructor Create;
    destructor Destroy; override;
  end;

  TRecorder3dVertexColorAdapter=class
  private
    fComponent:TRecorder3dComponent;
    fRegistry:TRecorderTagRegistry;
    fRegistryRevision:QWord;
    fScene:T3dScene;
    fGroups:array of TRecorder3dVertexColorGroup;
    procedure ClearGroups;
    function ResolveTag(AAnchor:TRecorder3dVertexColorAnchor):TRecorderTag;
    function FindGradientIndex(AId:QWord):Integer;
    procedure RefreshTagReferences;
  public
    destructor Destroy; override;
    procedure Configure(AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry);
    procedure AttachScene(AScene:T3dScene);
    function ApplyChanged:Boolean;
    procedure BuildValueLabels(out ALabels:TRecorder3dVertexValueLabels);
  end;

implementation

constructor TRecorder3dVertexColorGroup.Create;
begin
  inherited Create;
  Engine:=T3dVertexColorEngine.Create;
end;

destructor TRecorder3dVertexColorGroup.Destroy;
begin
  Engine.Free;
  inherited Destroy;
end;

destructor TRecorder3dVertexColorAdapter.Destroy;
begin
  ClearGroups;
  inherited Destroy;
end;

procedure TRecorder3dVertexColorAdapter.ClearGroups;
var I:Integer;
begin
  for I:=0 to High(fGroups) do fGroups[I].Free;
  SetLength(fGroups,0);
end;

function TRecorder3dVertexColorAdapter.ResolveTag(
  AAnchor:TRecorder3dVertexColorAnchor):TRecorderTag;
begin
  if AAnchor=nil then Exit(nil);
  Result:=RecorderResolveTagReference(fRegistry,AAnchor.TagId,AAnchor.TagName);
end;

procedure TRecorder3dVertexColorAdapter.RefreshTagReferences;
var I,J:Integer;
begin
  if (fRegistry=nil) or (fComponent=nil) then Exit;
  for I:=0 to High(fGroups) do
    for J:=0 to High(fGroups[I].Tags) do
    begin
      fGroups[I].Tags[J]:=RecorderResolveTagReference(fRegistry,
        fGroups[I].TagIds[J],fGroups[I].TagNames[J]);
      fGroups[I].LastValues[J]:=NaN;
    end;
  fRegistryRevision:=fRegistry.StructureRevision;
end;

function TRecorder3dVertexColorAdapter.FindGradientIndex(AId:QWord):Integer;
begin
  if fComponent<>nil then
    for Result:=0 to fComponent.GradientStripCount-1 do
      if fComponent.GradientStrips[Result].Id=AId then Exit;
  Result:=-1;
end;

procedure TRecorder3dVertexColorAdapter.Configure(
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
begin
  AttachScene(nil);
  fComponent:=AComponent;
  fRegistry:=ARegistry;
  if fRegistry<>nil then fRegistryRevision:=fRegistry.StructureRevision
  else fRegistryRevision:=0;
end;

procedure TRecorder3dVertexColorAdapter.AttachScene(AScene:T3dScene);
var
  Gradients:T3dGradientStrips;
  Evals:T3dVertexColorAnchorEvals;
  MeshIds:array of QWord;
  I,J,GroupIndex,Count:Integer;
  Anchor:TRecorder3dVertexColorAnchor;
  Gradient:TRecorder3dGradientStrip;
  Node:T3dNode;
begin
  ClearGroups;
  fScene:=AScene;
  if (fScene=nil) or (fComponent=nil) then Exit;

  SetLength(Gradients,fComponent.GradientStripCount);
  for I:=0 to High(Gradients) do
  begin
    Gradient:=fComponent.GradientStrips[I];
    Gradients[I].Id:=Gradient.Id;
    Gradients[I].Name:=Gradient.Name;
    Gradients[I].LeftColor.R:=Byte(Gradient.LeftColor and $FF);
    Gradients[I].LeftColor.G:=Byte((Gradient.LeftColor shr 8) and $FF);
    Gradients[I].LeftColor.B:=Byte((Gradient.LeftColor shr 16) and $FF);
    Gradients[I].RightColor.R:=Byte(Gradient.RightColor and $FF);
    Gradients[I].RightColor.G:=Byte((Gradient.RightColor shr 8) and $FF);
    Gradients[I].RightColor.B:=Byte((Gradient.RightColor shr 16) and $FF);
    Gradients[I].LeftValue:=Gradient.LeftValue;
    Gradients[I].RightValue:=Gradient.RightValue;
  end;

  SetLength(MeshIds,0);
  for I:=0 to fComponent.VertexColorAnchorCount-1 do
  begin
    Anchor:=fComponent.VertexColorAnchors[I];
    GroupIndex:=-1;
    for J:=0 to High(MeshIds) do
      if MeshIds[J]=Anchor.MeshNodeId then begin GroupIndex:=J; Break; end;
    if GroupIndex<0 then
    begin
      GroupIndex:=Length(MeshIds);
      SetLength(MeshIds,GroupIndex+1);
      SetLength(fGroups,GroupIndex+1);
      MeshIds[GroupIndex]:=Anchor.MeshNodeId;
      fGroups[GroupIndex]:=TRecorder3dVertexColorGroup.Create;
    end;
  end;

  for GroupIndex:=0 to High(fGroups) do
  begin
    Count:=0;
    for I:=0 to fComponent.VertexColorAnchorCount-1 do
      if fComponent.VertexColorAnchors[I].MeshNodeId=MeshIds[GroupIndex] then
        Inc(Count);
    SetLength(Evals,Count);
    SetLength(fGroups[GroupIndex].Tags,Count);
    SetLength(fGroups[GroupIndex].TagIds,Count);
    SetLength(fGroups[GroupIndex].TagNames,Count);
    SetLength(fGroups[GroupIndex].EstimateKinds,Count);
    SetLength(fGroups[GroupIndex].UseDefaultEstimates,Count);
    SetLength(fGroups[GroupIndex].LastValues,Count);
    SetLength(fGroups[GroupIndex].ConfigEnabled,Count);
    SetLength(fGroups[GroupIndex].LastActive,Count);
    SetLength(fGroups[GroupIndex].ActiveInitialized,Count);
    SetLength(fGroups[GroupIndex].ShowLabels,Count);
    SetLength(fGroups[GroupIndex].Names,Count);
    SetLength(fGroups[GroupIndex].LogicalIndices,Count);
    Count:=0;
    for I:=0 to fComponent.VertexColorAnchorCount-1 do
    begin
      Anchor:=fComponent.VertexColorAnchors[I];
      if Anchor.MeshNodeId<>MeshIds[GroupIndex] then Continue;
      Evals[Count].LogicalIndex:=-1;
      Node:=fScene.FindNode(Anchor.MeshNodeId);
      if (Node<>nil) and (Node.Mesh<>nil) then
        Evals[Count].LogicalIndex:=ResolveLogicalVertexIndex(Node.Mesh,
          Anchor.LogicalVertexId,Anchor.VertexIdKind);
      Evals[Count].Radius:=Anchor.Radius;
      Evals[Count].FalloffExponent:=Anchor.FalloffExponent;
      Evals[Count].Falloff:=Anchor.Falloff;
      Evals[Count].GradientIndex:=FindGradientIndex(Anchor.GradientId);
      Evals[Count].Value:=0;
      Evals[Count].Enabled:=Anchor.Enabled;
      Evals[Count].ApplyColor:=Anchor.ApplyColor;
      fGroups[GroupIndex].Tags[Count]:=ResolveTag(Anchor);
      fGroups[GroupIndex].TagIds[Count]:=Anchor.TagId;
      fGroups[GroupIndex].TagNames[Count]:=Anchor.TagName;
      fGroups[GroupIndex].EstimateKinds[Count]:=Anchor.EstimateKind;
      fGroups[GroupIndex].UseDefaultEstimates[Count]:=Anchor.UseDefaultEstimate;
      fGroups[GroupIndex].ConfigEnabled[Count]:=Anchor.Enabled;
      fGroups[GroupIndex].ShowLabels[Count]:=Anchor.ShowValueLabel;
      fGroups[GroupIndex].Names[Count]:=Anchor.Name;
      fGroups[GroupIndex].LogicalIndices[Count]:=Evals[Count].LogicalIndex;
      fGroups[GroupIndex].LastValues[Count]:=NaN;
      Inc(Count);
    end;
    Node:=fScene.FindNode(MeshIds[GroupIndex]);
    fGroups[GroupIndex].Node:=Node;
    if (Node<>nil) and (Node.Mesh<>nil) then
      fGroups[GroupIndex].Engine.Configure(Node.Mesh,Gradients,Evals)
    else
      fGroups[GroupIndex].Engine.Configure(nil,Gradients,Evals);
  end;
  ApplyChanged;
end;

procedure TRecorder3dVertexColorAdapter.BuildValueLabels(
  out ALabels:TRecorder3dVertexValueLabels);
var I,J,L,Corner:Integer; P:T3dVector; Mesh:T3dMeshData;
begin
  SetLength(ALabels,0);
  for I:=0 to High(fGroups) do
  begin
    if (fGroups[I].Node=nil) or (fGroups[I].Node.Mesh=nil) then Continue;
    Mesh:=fGroups[I].Node.Mesh;
    for J:=0 to High(fGroups[I].ShowLabels) do
    begin
      if not fGroups[I].ShowLabels[J] or not fGroups[I].LastActive[J] then Continue;
      L:=fGroups[I].LogicalIndices[J];
      if (L<0) or (L>High(Mesh.LogicalVertices)) or
         (Length(Mesh.LogicalVertices[L].CornerIndices)=0) then Continue;
      Corner:=Mesh.LogicalVertices[L].CornerIndices[0];
      if Corner>High(Mesh.Positions) then Continue;
      P:=u3dGeometryMath.TransformPoint(Mesh.Positions[Corner],
        fGroups[I].Node.WorldTransform);
      SetLength(ALabels,Length(ALabels)+1);
      ALabels[High(ALabels)].Position:=P;
      ALabels[High(ALabels)].Text:=fGroups[I].Names[J]+' = '+
        FormatFloat('0.###',fGroups[I].LastValues[J]);
    end;
  end;
end;

function TRecorder3dVertexColorAdapter.ApplyChanged:Boolean;
var I,J:Integer; Value:Double; Changed,Active:Boolean;
begin
  Result:=False;
  if (fRegistry<>nil) and
    (fRegistryRevision<>fRegistry.StructureRevision) then
    RefreshTagReferences;
  for I:=0 to High(fGroups) do
  begin
    Changed:=False;
    for J:=0 to High(fGroups[I].Tags) do
    begin
      Active:=False;
      Value:=NaN;
      if RecorderTryReadScalarValue(fGroups[I].Tags[J],
        fGroups[I].UseDefaultEstimates[J],fGroups[I].EstimateKinds[J],Value) then
        Active:=fGroups[I].ConfigEnabled[J];
      if (not fGroups[I].ActiveInitialized[J]) or
         (Active<>fGroups[I].LastActive[J]) then
      begin
        fGroups[I].ActiveInitialized[J]:=True;
        fGroups[I].LastActive[J]:=Active;
        fGroups[I].Engine.SetAnchorEnabled(J,Active);
        Changed:=True;
      end;
      if not Active then Continue;
      if IsNan(fGroups[I].LastValues[J]) or
         (not SameValue(Value,fGroups[I].LastValues[J])) then
      begin
        fGroups[I].LastValues[J]:=Value;
        fGroups[I].Engine.SetAnchorValue(J,Value);
        Changed:=True;
      end;
    end;
    if Changed then
    begin
      fGroups[I].Engine.Apply;
      Result:=True;
    end;
  end;
end;

end.
