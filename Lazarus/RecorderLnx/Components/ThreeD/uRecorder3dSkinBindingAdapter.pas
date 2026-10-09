unit uRecorder3dSkinBindingAdapter;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Resolves persistent Skin-bone tag bindings during Configure and applies only
  numeric IDs/object references in the refresh loop. Tag values are local
  displacements from the helper's bind translation. }

interface

uses
  Math, u3dCoreTypes, u3dScene, uRecorderTags, uRecorder3dModel;

type
  TRecorder3dSkinRuntimeBinding = record
    Node:T3dNode;
    Tags:array[TRecorder3dSkinAxis] of TRecorderTag;
    ValueModes:array[TRecorder3dSkinAxis] of TRecorder3dTagValueMode;
    LastValues:array[TRecorder3dSkinAxis] of Double;
    BindTranslation:T3dVector;
  end;

  TRecorder3dSkinBindingAdapter=class
  private
    fComponent:TRecorder3dComponent;
    fScene:T3dScene;
    fRegistry:TRecorderTagRegistry;
    fRegistryRevision:QWord;
    fBindings:array of TRecorder3dSkinRuntimeBinding;
    function ResolveTag(ARegistry:TRecorderTagRegistry;
      ABone:TRecorder3dSkinBone; AAxis:TRecorder3dSkinAxis):TRecorderTag;
    function ReadTagValue(ATag:TRecorderTag;
      AMode:TRecorder3dTagValueMode; out AValue:Double):Boolean;
    procedure RefreshTagReferences;
  public
    procedure Configure(AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry);
    procedure AttachScene(AScene:T3dScene);
    function ApplyChanged:Boolean;
  end;

implementation

function TRecorder3dSkinBindingAdapter.ResolveTag(
  ARegistry:TRecorderTagRegistry; ABone:TRecorder3dSkinBone;
  AAxis:TRecorder3dSkinAxis):TRecorderTag;
begin
  if ABone=nil then
    Exit(nil);
  Result:=RecorderResolveTagReference(ARegistry,ABone.TagIds[AAxis],
    ABone.TagNames[AAxis]);
end;

procedure TRecorder3dSkinBindingAdapter.RefreshTagReferences;
var
  I:Integer;
  Axis:TRecorder3dSkinAxis;
begin
  if (fRegistry=nil) or (fComponent=nil) then
    Exit;
  for I:=0 to High(fBindings) do
    for Axis:=Low(Axis) to High(Axis) do
    begin
      fBindings[I].Tags[Axis]:=ResolveTag(fRegistry,
        fComponent.SkinBones[I],Axis);
      fBindings[I].ValueModes[Axis]:=
        fComponent.SkinBones[I].TagValueModes[Axis];
      fBindings[I].LastValues[Axis]:=NaN;
    end;
  fRegistryRevision:=fRegistry.StructureRevision;
end;

function TRecorder3dSkinBindingAdapter.ReadTagValue(ATag:TRecorderTag;
  AMode:TRecorder3dTagValueMode; out AValue:Double):Boolean;
var
  Estimate:TRecorderTagEstimate;
begin
  Result:=False;
  if ATag=nil then
    Exit;
  case AMode of
    r3tvDefaultEstimate:
      begin
        Estimate:=ATag.Estimate(ATag.EstimateSettings.DefaultKind);
        if not Estimate.Valid then
          Exit;
        AValue:=Estimate.Value;
      end;
    else
      begin
        if ATag.SignalBuffer.Count=0 then
          Exit;
        AValue:=ATag.SignalBuffer.LatestValue;
      end;
  end;
  Result:=not IsNan(AValue) and not IsInfinite(AValue);
end;

procedure TRecorder3dSkinBindingAdapter.Configure(
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
var
  I:Integer;
  Axis:TRecorder3dSkinAxis;
begin
  { Configuration can be triggered while the view replaces its owned scene.
    Never resolve nodes through the previously attached scene: it may already
    have been freed by T3dLclWidget.ReplaceScene. The owner explicitly attaches
    the current scene after configuration is complete. }
  AttachScene(nil);
  fComponent:=AComponent;
  fRegistry:=ARegistry;
  if fComponent=nil then
    SetLength(fBindings,0)
  else
    SetLength(fBindings,fComponent.SkinBoneCount);
  for I:=0 to High(fBindings) do
    for Axis:=Low(Axis) to High(Axis) do
    begin
      fBindings[I].Tags[Axis]:=ResolveTag(ARegistry,
        fComponent.SkinBones[I],Axis);
      fBindings[I].ValueModes[Axis]:=
        fComponent.SkinBones[I].TagValueModes[Axis];
      fBindings[I].LastValues[Axis]:=NaN;
    end;
  if fRegistry<>nil then
    fRegistryRevision:=fRegistry.StructureRevision
  else
    fRegistryRevision:=0;
end;

procedure TRecorder3dSkinBindingAdapter.AttachScene(AScene:T3dScene);
var
  I:Integer;
  Node:T3dNode;
begin
  fScene:=AScene;
  for I:=0 to High(fBindings) do
  begin
    Node:=nil;
    if (fScene<>nil) and (fComponent<>nil) then
      Node:=fScene.FindNode(fComponent.SkinBones[I].HelperNodeId);
    fBindings[I].Node:=Node;
    if Node<>nil then
      fBindings[I].BindTranslation:=Vector3d(
        fComponent.SkinBones[I].BindLocalTransform[12],
        fComponent.SkinBones[I].BindLocalTransform[13],
        fComponent.SkinBones[I].BindLocalTransform[14]);
  end;
end;

function TRecorder3dSkinBindingAdapter.ApplyChanged:Boolean;
var
  I,lUpdated:Integer;
  Axis:TRecorder3dSkinAxis;
  Value:Double;
  Node:T3dNode;
begin
  Result:=False;
  if fScene=nil then
    Exit;
  if (fRegistry<>nil) and
    (fRegistryRevision<>fRegistry.StructureRevision) then
    RefreshTagReferences;
  for I:=0 to High(fBindings) do
  begin
    Node:=fBindings[I].Node;
    if Node=nil then
      Continue;
    for Axis:=Low(Axis) to High(Axis) do
    begin
      if not ReadTagValue(fBindings[I].Tags[Axis],
        fBindings[I].ValueModes[Axis],Value) then
        Continue;
      if (not IsNan(fBindings[I].LastValues[Axis])) and
        SameValue(Value,fBindings[I].LastValues[Axis]) then
        Continue;
      fBindings[I].LastValues[Axis]:=Value;
      case Axis of
        r3sX:Node.LocalTransform[12]:=fBindings[I].BindTranslation.X+Value;
        r3sY:Node.LocalTransform[13]:=fBindings[I].BindTranslation.Y+Value;
        r3sZ:Node.LocalTransform[14]:=fBindings[I].BindTranslation.Z+Value;
      end;
      Result:=True;
    end;
  end;
  if Result then
  begin
    fScene.RebuildWorldTransforms(lUpdated);
    fScene.MarkBoundsDirty;
  end;
end;

end.
