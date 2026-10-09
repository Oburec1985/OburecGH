unit uRecorder3dModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Persistent Recorder model for the 3D visual component. Project-file code
  serializes this state, the settings dialog edits it, and TRecorder3dView
  projects it into a live scene. Owned FRF bindings and node overrides live
  exactly as long as their component. }

interface

uses
  Classes, SysUtils, uRecorderFormModel, uRecorderTags, u3dMotionContracts,
  u3dPrimitives, u3dScene, u3dGeometryMath, u3dTransforms, u3dSkin,
  u3dVertexColors;

type
  TRecorder3dBindingSlot = (r3bPointX, r3bPointY, r3bPointZ, r3bColor,
    r3bNormalLength);
  TRecorder3dSkinAxis = (r3sX, r3sY, r3sZ);
  TRecorder3dTagValueMode = (r3tvCurrentValue, r3tvDefaultEstimate);

  TRecorder3dFrfBindingSpec = record
    CurveId: QWord;
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    Gain: Double;
    Enabled: Boolean;
  end;
  TRecorder3dFrfBindingSpecArray = array of TRecorder3dFrfBindingSpec;
  TRecorder3dFrfReplaceHook = procedure(AIndex: Integer) of object;

  { Describes one measured FRF curve mapped onto a scene helper axis. }
  TRecorder3dFrfBinding = class
  public
    SourceBindingId: string;
    CurveId: QWord;
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    AmplitudeTagId, PhaseTagId: TRecorderTagId;
    AmplitudeTagName, PhaseTagName: string;
    Gain: Double;
    Enabled: Boolean;
    constructor Create;
    procedure SetAxisOrdinal(AValue:Integer);
    procedure SetSpaceOrdinal(AValue:Integer);
  end;

  { Optional per-node render flags; absence means use component-wide flags. }
  TRecorder3dNodeRenderOverride = class
  public
    NodeId: QWord;
    DrawFill, DrawWireframe, DrawPoints, DrawNormals: Boolean;
    HasRenderSettings: Boolean;
    HasTransform: Boolean;
    LocalTransform: T3dMatrix;
  end;

  { One durable point-to-helper influence. Repeating PointName and HelperNodeId
    intentionally supports several logical vertices driven by one helper. }
  TRecorder3dSkinBinding = class
  public
    PointName: string;
    MeshNodeId: QWord;
    LogicalVertexId: LongWord;
    VertexIdKind:T3dSkinVertexIdKind;
    HelperNodeId: QWord;
    Weight: Single;
    HelperBindWorld: T3dMatrix;
    constructor Create;
  end;

  { One Skin bone. Influences reference it by HelperNodeId; tag bindings drive
    local X/Y/Z displacement and are resolved once when the view configures. }
  TRecorder3dSkinBone = class
  private
    fTagIds: array[TRecorder3dSkinAxis] of TRecorderTagId;
    fTagNames: array[TRecorder3dSkinAxis] of string;
    fTagValueModes: array[TRecorder3dSkinAxis] of TRecorder3dTagValueMode;
    function GetTagId(AAxis:TRecorder3dSkinAxis):TRecorderTagId;
    function GetTagName(AAxis:TRecorder3dSkinAxis):string;
    procedure SetTagId(AAxis:TRecorder3dSkinAxis; AValue:TRecorderTagId);
    procedure SetTagName(AAxis:TRecorder3dSkinAxis; const AValue:string);
    function GetTagValueMode(AAxis:TRecorder3dSkinAxis):TRecorder3dTagValueMode;
    procedure SetTagValueMode(AAxis:TRecorder3dSkinAxis;
      AValue:TRecorder3dTagValueMode);
  public
    HelperNodeId:QWord;
    OwnerMeshNodeId:QWord;
    Name:string;
    BindLocalTransform:T3dMatrix;
    constructor Create;
    property TagIds[AAxis:TRecorder3dSkinAxis]:TRecorderTagId
      read GetTagId write SetTagId;
    property TagNames[AAxis:TRecorder3dSkinAxis]:string
      read GetTagName write SetTagName;
    property TagValueModes[AAxis:TRecorder3dSkinAxis]:TRecorder3dTagValueMode
      read GetTagValueMode write SetTagValueMode;
  end;

  TRecorder3dGradientStrip=class
  public
    Id:QWord;
    Name:string;
    LeftColor,RightColor:LongInt;
    LeftValue,RightValue:Double;
    constructor Create;
  end;

  TRecorder3dVertexColorAnchor=class
  public
    Id:QWord;
    Name:string;
    MeshNodeId:QWord;
    LogicalVertexId:LongWord;
    VertexIdKind:T3dSkinVertexIdKind;
    Radius,FalloffExponent:Single;
    Falloff:T3dVertexColorFalloff;
    GradientId:QWord;
    TagId:TRecorderTagId;
    TagName:string;
    EstimateKind:TRecorderTagEstimateKind;
    UseDefaultEstimate:Boolean;
    Enabled,ApplyColor,ShowValueLabel:Boolean;
    constructor Create;
  end;

  { Serializable configuration only. Runtime scene, tags, renderer and motion
    services are deliberately owned by TRecorder3dView. }
  TRecorder3dComponent = class(TRecorderVisualComponent)
  private
    fSceneFileName: string;
    fShowAxes: Boolean;
    fBackgroundColor: LongInt;
    fCameraYaw: Double;
    fCameraPitch: Double;
    fCameraDistance: Double;
    fCameraTargetX,fCameraTargetY,fCameraTargetZ:Double;
    fCameraRoll,fCameraFov:Double;
    fDrawFill: Boolean;
    fDrawWireframe: Boolean;
    fDrawPoints: Boolean;
    fPointColor:LongInt;
    fDrawNormals: Boolean;
    fNormalLength: Double;
    fNormalLengthTagId: TRecorderTagId;
    fNormalLengthTagName: string;
    fBindingTargetNodeId: QWord;
    fBindingTagIds: array[TRecorder3dBindingSlot] of TRecorderTagId;
    fBindingTagNames: array[TRecorder3dBindingSlot] of string;
    fFrfBindings: TList;
    fNodeRenderOverrides: TList;
    fSkinBindings: TList;
    fSkinBones:TList;
    fGradientStrips,fVertexColorAnchors:TList;
    fPrimitives: array of T3dPrimitiveSpec;
    fRemovedNodeIds: array of QWord;
    fNextPrimitiveNodeId: QWord;
    fFrfFrequencyHz, fFrfAnimationPhaseRadians: Double;
    fFrfFrequencyTagId, fFrfAnimationPhaseTagId: TRecorderTagId;
    fFrfFrequencyTagName, fFrfAnimationPhaseTagName: string;
    function GetBindingTagId(AIndex:TRecorder3dBindingSlot):TRecorderTagId;
    function GetBindingTagName(AIndex:TRecorder3dBindingSlot):string;
    procedure SetBindingTagId(AIndex:TRecorder3dBindingSlot; AValue:TRecorderTagId);
    procedure SetBindingTagName(AIndex:TRecorder3dBindingSlot; const AValue:string);
    function GetFrfBinding(AIndex:Integer):TRecorder3dFrfBinding;
    function GetFrfBindingCount:Integer;
    function GetNodeRenderOverride(AIndex:Integer):TRecorder3dNodeRenderOverride;
    function GetNodeRenderOverrideCount:Integer;
    function GetPrimitive(AIndex: Integer): T3dPrimitiveSpec;
    function GetPrimitiveCount: Integer;
    function GetRemovedNodeId(AIndex: Integer): QWord;
    function GetRemovedNodeCount: Integer;
    function GetSkinBinding(AIndex:Integer):TRecorder3dSkinBinding;
    function GetSkinBindingCount:Integer;
    function GetSkinBone(AIndex:Integer):TRecorder3dSkinBone;
    function GetSkinBoneCount:Integer;
    function GetGradientStrip(AIndex:Integer):TRecorder3dGradientStrip;
    function GetGradientStripCount:Integer;
    function GetVertexColorAnchor(AIndex:Integer):TRecorder3dVertexColorAnchor;
    function GetVertexColorAnchorCount:Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(ASource:TRecorder3dComponent);
    function AddFrfBinding:TRecorder3dFrfBinding;
    procedure ClearFrfBindings;
    procedure RemoveFrfBindingsBySourceId(const ASourceBindingId: string);
    function ReplaceFrfBindingsBySourceId(const ASourceBindingId: string;
      const ASpecs: array of TRecorder3dFrfBindingSpec;
      ABeforeCreate: TRecorder3dFrfReplaceHook = nil): Boolean;
    function AddNodeRenderOverride:TRecorder3dNodeRenderOverride;
    procedure ClearNodeRenderOverrides;
    function FindNodeRenderOverride(ANodeId:QWord):TRecorder3dNodeRenderOverride;
    function AddSkinBinding:TRecorder3dSkinBinding;
    procedure DeleteSkinBinding(AIndex:Integer);
    procedure ClearSkinBindings;
    procedure BuildSkinInfluences(out AInfluences:T3dSkinInfluences);
    function AddSkinBone:TRecorder3dSkinBone;
    function FindSkinBone(AHelperNodeId:QWord):TRecorder3dSkinBone;
    function EnsureSkinBone(AHelperNodeId:QWord; const AName:string):TRecorder3dSkinBone;
    procedure ClearSkinBones;
    procedure MaterializeSkinHelpers(AScene:T3dScene);
    function AddGradientStrip:TRecorder3dGradientStrip;
    procedure DeleteGradientStrip(AIndex:Integer);
    procedure ClearGradientStrips;
    function FindGradientStrip(AId:QWord):TRecorder3dGradientStrip;
    function AddVertexColorAnchor:TRecorder3dVertexColorAnchor;
    procedure DeleteVertexColorAnchor(AIndex:Integer);
    procedure ClearVertexColorAnchors;
    procedure AddPrimitive(const ASpec: T3dPrimitiveSpec);
    function FindPrimitiveIndex(ANodeId: QWord): Integer;
    function UpdatePrimitiveIterations(ANodeId: QWord;
      AIterations,ACrossSectionIterations: Integer;
      out ASpec: T3dPrimitiveSpec): Boolean;
    function RenamePrimitive(ANodeId:QWord; const AName:string):Boolean;
    function DeletePrimitive(ANodeId: QWord): Boolean;
    procedure MarkNodeRemoved(ANodeId: QWord);
    function IsNodeRemoved(ANodeId: QWord): Boolean;
    procedure ClearSceneEdits;
    procedure RemoveNodeReferences(ANodeId: QWord);
    function AllocatePrimitiveNodeId(AScene: T3dScene): QWord;
    procedure ResolvePrimitiveNodeIdCollisions(AScene: T3dScene);
    property SceneFileName: string read fSceneFileName write fSceneFileName;
    property ShowAxes: Boolean read fShowAxes write fShowAxes;
    property BackgroundColor: LongInt read fBackgroundColor write fBackgroundColor;
    property CameraYaw: Double read fCameraYaw write fCameraYaw;
    property CameraPitch: Double read fCameraPitch write fCameraPitch;
    property CameraDistance: Double read fCameraDistance write fCameraDistance;
    property CameraTargetX:Double read fCameraTargetX write fCameraTargetX;
    property CameraTargetY:Double read fCameraTargetY write fCameraTargetY;
    property CameraTargetZ:Double read fCameraTargetZ write fCameraTargetZ;
    property CameraRoll:Double read fCameraRoll write fCameraRoll;
    property CameraFov:Double read fCameraFov write fCameraFov;
    property DrawFill: Boolean read fDrawFill write fDrawFill;
    property DrawWireframe: Boolean read fDrawWireframe write fDrawWireframe;
    property DrawPoints: Boolean read fDrawPoints write fDrawPoints;
    property PointColor:LongInt read fPointColor write fPointColor;
    property DrawNormals: Boolean read fDrawNormals write fDrawNormals;
    property NormalLength: Double read fNormalLength write fNormalLength;
    property NormalLengthTagId: TRecorderTagId read fNormalLengthTagId
      write fNormalLengthTagId;
    property NormalLengthTagName: string read fNormalLengthTagName
      write fNormalLengthTagName;
    property BindingTargetNodeId: QWord read fBindingTargetNodeId write fBindingTargetNodeId;
    property BindingTagIds[AIndex:TRecorder3dBindingSlot]:TRecorderTagId
      read GetBindingTagId write SetBindingTagId;
    property BindingTagNames[AIndex:TRecorder3dBindingSlot]:string
      read GetBindingTagName write SetBindingTagName;
    property FrfBindingCount:Integer read GetFrfBindingCount;
    property FrfBindings[AIndex:Integer]:TRecorder3dFrfBinding read GetFrfBinding;
    property NodeRenderOverrideCount:Integer read GetNodeRenderOverrideCount;
    property NodeRenderOverrides[AIndex:Integer]:TRecorder3dNodeRenderOverride
      read GetNodeRenderOverride;
    property SkinBindingCount:Integer read GetSkinBindingCount;
    property SkinBindings[AIndex:Integer]:TRecorder3dSkinBinding
      read GetSkinBinding;
    property SkinBoneCount:Integer read GetSkinBoneCount;
    property SkinBones[AIndex:Integer]:TRecorder3dSkinBone read GetSkinBone;
    property GradientStripCount:Integer read GetGradientStripCount;
    property GradientStrips[AIndex:Integer]:TRecorder3dGradientStrip
      read GetGradientStrip;
    property VertexColorAnchorCount:Integer read GetVertexColorAnchorCount;
    property VertexColorAnchors[AIndex:Integer]:TRecorder3dVertexColorAnchor
      read GetVertexColorAnchor;
    property PrimitiveCount: Integer read GetPrimitiveCount;
    property Primitives[AIndex: Integer]: T3dPrimitiveSpec read GetPrimitive;
    property RemovedNodeCount: Integer read GetRemovedNodeCount;
    property RemovedNodeIds[AIndex: Integer]: QWord read GetRemovedNodeId;
    property NextPrimitiveNodeId: QWord read fNextPrimitiveNodeId
      write fNextPrimitiveNodeId;
    property FrfFrequencyHz:Double read fFrfFrequencyHz write fFrfFrequencyHz;
    property FrfAnimationPhaseRadians:Double read fFrfAnimationPhaseRadians write fFrfAnimationPhaseRadians;
    property FrfFrequencyTagId:TRecorderTagId read fFrfFrequencyTagId write fFrfFrequencyTagId;
    property FrfFrequencyTagName:string read fFrfFrequencyTagName write fFrfFrequencyTagName;
    property FrfAnimationPhaseTagId:TRecorderTagId read fFrfAnimationPhaseTagId write fFrfAnimationPhaseTagId;
    property FrfAnimationPhaseTagName:string read fFrfAnimationPhaseTagName write fFrfAnimationPhaseTagName;
  end;

  TRecorder3dFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create;
  end;

procedure RegisterRecorder3dFactory(AFactory: TRecorderComponentFactory);

implementation

constructor TRecorder3dGradientStrip.Create;
begin
  inherited Create;
  LeftColor:=$000000FF;
  RightColor:=$00FF0000;
  RightValue:=1;
end;

constructor TRecorder3dVertexColorAnchor.Create;
begin
  inherited Create;
  VertexIdKind:=svikLogical;
  Radius:=1;
  FalloffExponent:=1;
  EstimateKind:=tekMean;
  UseDefaultEstimate:=True;
  Enabled:=True;
  ApplyColor:=True;
end;

constructor TRecorder3dSkinBone.Create;
begin
  inherited Create;
  SetIdentity(BindLocalTransform);
end;

function TRecorder3dSkinBone.GetTagValueMode(
  AAxis:TRecorder3dSkinAxis):TRecorder3dTagValueMode;
begin
  Result:=fTagValueModes[AAxis];
end;

procedure TRecorder3dSkinBone.SetTagValueMode(AAxis:TRecorder3dSkinAxis;
  AValue:TRecorder3dTagValueMode);
begin
  fTagValueModes[AAxis]:=AValue;
end;

function TRecorder3dSkinBone.GetTagId(
  AAxis:TRecorder3dSkinAxis):TRecorderTagId;
begin
  Result:=fTagIds[AAxis];
end;

function TRecorder3dSkinBone.GetTagName(AAxis:TRecorder3dSkinAxis):string;
begin
  Result:=fTagNames[AAxis];
end;

procedure TRecorder3dSkinBone.SetTagId(AAxis:TRecorder3dSkinAxis;
  AValue:TRecorderTagId);
begin
  fTagIds[AAxis]:=AValue;
end;

procedure TRecorder3dSkinBone.SetTagName(AAxis:TRecorder3dSkinAxis;
  const AValue:string);
begin
  fTagNames[AAxis]:=AValue;
end;

constructor TRecorder3dSkinBinding.Create;
begin
  inherited Create;
  VertexIdKind:=svikLogical;
  Weight := 1;
  SetIdentity(HelperBindWorld);
end;

constructor TRecorder3dFrfBinding.Create;
begin
  inherited Create;
  Axis := maxisX;
  Space := msHelperLocal;
  Gain := 1;
  Enabled := True;
end;

procedure TRecorder3dFrfBinding.SetAxisOrdinal(AValue: Integer);
begin
  if AValue < Ord(Low(T3dMotionAxis)) then
    AValue := Ord(Low(T3dMotionAxis));
  if AValue > Ord(High(T3dMotionAxis)) then
    AValue := Ord(High(T3dMotionAxis));
  Axis := T3dMotionAxis(AValue);
end;

procedure TRecorder3dFrfBinding.SetSpaceOrdinal(AValue: Integer);
begin
  if AValue < Ord(Low(T3dMotionSpace)) then
    AValue := Ord(Low(T3dMotionSpace));
  if AValue > Ord(High(T3dMotionSpace)) then
    AValue := Ord(High(T3dMotionSpace));
  Space := T3dMotionSpace(AValue);
end;

function TRecorder3dComponent.GetBindingTagId(
  AIndex: TRecorder3dBindingSlot): TRecorderTagId;
begin
  Result := fBindingTagIds[AIndex];
end;

function TRecorder3dComponent.GetBindingTagName(
  AIndex: TRecorder3dBindingSlot): string;
begin
  Result := fBindingTagNames[AIndex];
end;

procedure TRecorder3dComponent.SetBindingTagId(
  AIndex: TRecorder3dBindingSlot; AValue: TRecorderTagId);
begin
  fBindingTagIds[AIndex] := AValue;
end;

procedure TRecorder3dComponent.SetBindingTagName(
  AIndex: TRecorder3dBindingSlot; const AValue: string);
begin
  fBindingTagNames[AIndex] := AValue;
end;

class function TRecorder3dComponent.GetTypeId: string;
begin
  Result := 'ThreeDView';
end;

constructor TRecorder3dComponent.Create;
begin
  inherited Create;
  fFrfBindings := TList.Create;
  fNodeRenderOverrides := TList.Create;
  fSkinBindings := TList.Create;
  fSkinBones:=TList.Create;
  fGradientStrips:=TList.Create;
  fVertexColorAnchors:=TList.Create;
  fShowAxes := True;
  fBackgroundColor := $0033291F;
  fCameraYaw := 35;
  fCameraPitch := -25;
  fCameraDistance := 6;
  fCameraTargetX := 0;
  fCameraTargetY := 0;
  fCameraTargetZ := 0;
  fCameraRoll := 0;
  fCameraFov := 45;
  fDrawFill := True;
  fDrawWireframe := False;
  fDrawPoints := True;
  fPointColor := $001080FF;
  fDrawNormals := False;
  fNormalLength := 0.25;
  fFrfFrequencyHz := 100;
  fFrfAnimationPhaseRadians := 0;
  fNextPrimitiveNodeId := QWord(1) shl 62;
end;

destructor TRecorder3dComponent.Destroy;
begin
  ClearVertexColorAnchors;
  fVertexColorAnchors.Free;
  ClearGradientStrips;
  fGradientStrips.Free;
  ClearSkinBones;
  fSkinBones.Free;
  ClearSkinBindings;
  fSkinBindings.Free;
  ClearNodeRenderOverrides;
  fNodeRenderOverrides.Free;
  ClearFrfBindings;
  fFrfBindings.Free;
  inherited Destroy;
end;

procedure TRecorder3dComponent.Assign(ASource:TRecorder3dComponent);
var
  Slot:TRecorder3dBindingSlot;
  BoneAxis:TRecorder3dSkinAxis;
  I:Integer;
  SourceFrf:TRecorder3dFrfBinding;
  TargetFrf:TRecorder3dFrfBinding;
  SourceOverride:TRecorder3dNodeRenderOverride;
  TargetOverride:TRecorder3dNodeRenderOverride;
  SourceSkin,TargetSkin:TRecorder3dSkinBinding;
  SourceBone,TargetBone:TRecorder3dSkinBone;
  SourceGradient,TargetGradient:TRecorder3dGradientStrip;
  SourceAnchor,TargetAnchor:TRecorder3dVertexColorAnchor;
begin
  if ASource=nil then
    Exit;
  fSceneFileName:=ASource.fSceneFileName;
  fShowAxes:=ASource.fShowAxes;
  fBackgroundColor:=ASource.fBackgroundColor;
  fCameraYaw:=ASource.fCameraYaw;
  fCameraPitch:=ASource.fCameraPitch;
  fCameraDistance:=ASource.fCameraDistance;
  fCameraTargetX:=ASource.fCameraTargetX;
  fCameraTargetY:=ASource.fCameraTargetY;
  fCameraTargetZ:=ASource.fCameraTargetZ;
  fCameraRoll:=ASource.fCameraRoll;
  fCameraFov:=ASource.fCameraFov;
  fDrawFill:=ASource.fDrawFill;
  fDrawWireframe:=ASource.fDrawWireframe;
  fDrawPoints:=ASource.fDrawPoints;
  fPointColor:=ASource.fPointColor;
  fDrawNormals:=ASource.fDrawNormals;
  fNormalLength:=ASource.fNormalLength;
  fNormalLengthTagId:=ASource.fNormalLengthTagId;
  fNormalLengthTagName:=ASource.fNormalLengthTagName;
  fBindingTargetNodeId:=ASource.fBindingTargetNodeId;
  for Slot:=Low(Slot) to High(Slot) do
  begin
    fBindingTagIds[Slot]:=ASource.fBindingTagIds[Slot];
    fBindingTagNames[Slot]:=ASource.fBindingTagNames[Slot];
  end;
  fFrfFrequencyHz:=ASource.fFrfFrequencyHz;
  fFrfAnimationPhaseRadians:=ASource.fFrfAnimationPhaseRadians;
  fFrfFrequencyTagId:=ASource.fFrfFrequencyTagId;
  fFrfAnimationPhaseTagId:=ASource.fFrfAnimationPhaseTagId;
  fFrfFrequencyTagName:=ASource.fFrfFrequencyTagName;
  fFrfAnimationPhaseTagName:=ASource.fFrfAnimationPhaseTagName;
  ClearFrfBindings;
  for I:=0 to ASource.FrfBindingCount-1 do
  begin
    SourceFrf:=ASource.FrfBindings[I];
    TargetFrf:=AddFrfBinding;
    TargetFrf.SourceBindingId:=SourceFrf.SourceBindingId;
    TargetFrf.CurveId:=SourceFrf.CurveId;
    TargetFrf.TargetNodeId:=SourceFrf.TargetNodeId;
    TargetFrf.Axis:=SourceFrf.Axis;
    TargetFrf.Space:=SourceFrf.Space;
    TargetFrf.AmplitudeTagId:=SourceFrf.AmplitudeTagId;
    TargetFrf.PhaseTagId:=SourceFrf.PhaseTagId;
    TargetFrf.AmplitudeTagName:=SourceFrf.AmplitudeTagName;
    TargetFrf.PhaseTagName:=SourceFrf.PhaseTagName;
    TargetFrf.Gain:=SourceFrf.Gain;
    TargetFrf.Enabled:=SourceFrf.Enabled;
  end;
  ClearNodeRenderOverrides;
  for I:=0 to ASource.NodeRenderOverrideCount-1 do
  begin
    SourceOverride:=ASource.NodeRenderOverrides[I];
    TargetOverride:=AddNodeRenderOverride;
    TargetOverride.NodeId:=SourceOverride.NodeId;
    TargetOverride.DrawFill:=SourceOverride.DrawFill;
    TargetOverride.DrawWireframe:=SourceOverride.DrawWireframe;
    TargetOverride.DrawPoints:=SourceOverride.DrawPoints;
    TargetOverride.DrawNormals:=SourceOverride.DrawNormals;
    TargetOverride.HasRenderSettings:=SourceOverride.HasRenderSettings;
    TargetOverride.HasTransform:=SourceOverride.HasTransform;
    TargetOverride.LocalTransform:=SourceOverride.LocalTransform;
  end;
  fPrimitives := Copy(ASource.fPrimitives);
  fRemovedNodeIds := Copy(ASource.fRemovedNodeIds);
  fNextPrimitiveNodeId := ASource.fNextPrimitiveNodeId;
  ClearSkinBindings;
  for I:=0 to ASource.SkinBindingCount-1 do
  begin
    SourceSkin:=ASource.SkinBindings[I];
    TargetSkin:=AddSkinBinding;
    TargetSkin.PointName:=SourceSkin.PointName;
    TargetSkin.MeshNodeId:=SourceSkin.MeshNodeId;
    TargetSkin.LogicalVertexId:=SourceSkin.LogicalVertexId;
    TargetSkin.VertexIdKind:=SourceSkin.VertexIdKind;
    TargetSkin.HelperNodeId:=SourceSkin.HelperNodeId;
    TargetSkin.Weight:=SourceSkin.Weight;
    TargetSkin.HelperBindWorld:=SourceSkin.HelperBindWorld;
  end;
  ClearSkinBones;
  for I:=0 to ASource.SkinBoneCount-1 do
  begin
    SourceBone:=ASource.SkinBones[I];
    TargetBone:=AddSkinBone;
    TargetBone.HelperNodeId:=SourceBone.HelperNodeId;
    TargetBone.OwnerMeshNodeId:=SourceBone.OwnerMeshNodeId;
    TargetBone.Name:=SourceBone.Name;
    TargetBone.BindLocalTransform:=SourceBone.BindLocalTransform;
    for BoneAxis:=Low(BoneAxis) to High(BoneAxis) do
    begin
      TargetBone.TagIds[BoneAxis]:=SourceBone.TagIds[BoneAxis];
      TargetBone.TagNames[BoneAxis]:=SourceBone.TagNames[BoneAxis];
      TargetBone.TagValueModes[BoneAxis]:=SourceBone.TagValueModes[BoneAxis];
    end;
  end;
  ClearGradientStrips;
  for I:=0 to ASource.GradientStripCount-1 do
  begin
    SourceGradient:=ASource.GradientStrips[I];
    TargetGradient:=AddGradientStrip;
    TargetGradient.Id:=SourceGradient.Id; TargetGradient.Name:=SourceGradient.Name;
    TargetGradient.LeftColor:=SourceGradient.LeftColor;
    TargetGradient.RightColor:=SourceGradient.RightColor;
    TargetGradient.LeftValue:=SourceGradient.LeftValue;
    TargetGradient.RightValue:=SourceGradient.RightValue;
  end;
  ClearVertexColorAnchors;
  for I:=0 to ASource.VertexColorAnchorCount-1 do
  begin
    SourceAnchor:=ASource.VertexColorAnchors[I];
    TargetAnchor:=AddVertexColorAnchor;
    TargetAnchor.Id:=SourceAnchor.Id; TargetAnchor.Name:=SourceAnchor.Name;
    TargetAnchor.MeshNodeId:=SourceAnchor.MeshNodeId;
    TargetAnchor.LogicalVertexId:=SourceAnchor.LogicalVertexId;
    TargetAnchor.VertexIdKind:=SourceAnchor.VertexIdKind;
    TargetAnchor.Radius:=SourceAnchor.Radius;
    TargetAnchor.FalloffExponent:=SourceAnchor.FalloffExponent;
    TargetAnchor.Falloff:=SourceAnchor.Falloff;
    TargetAnchor.GradientId:=SourceAnchor.GradientId;
    TargetAnchor.TagId:=SourceAnchor.TagId; TargetAnchor.TagName:=SourceAnchor.TagName;
    TargetAnchor.EstimateKind:=SourceAnchor.EstimateKind;
    TargetAnchor.UseDefaultEstimate:=SourceAnchor.UseDefaultEstimate;
    TargetAnchor.Enabled:=SourceAnchor.Enabled;
    TargetAnchor.ApplyColor:=SourceAnchor.ApplyColor;
    TargetAnchor.ShowValueLabel:=SourceAnchor.ShowValueLabel;
  end;
end;

function TRecorder3dComponent.GetGradientStrip(AIndex:Integer):TRecorder3dGradientStrip;
begin Result:=TRecorder3dGradientStrip(fGradientStrips[AIndex]); end;
function TRecorder3dComponent.GetGradientStripCount:Integer;
begin Result:=fGradientStrips.Count; end;
function TRecorder3dComponent.GetVertexColorAnchor(AIndex:Integer):TRecorder3dVertexColorAnchor;
begin Result:=TRecorder3dVertexColorAnchor(fVertexColorAnchors[AIndex]); end;
function TRecorder3dComponent.GetVertexColorAnchorCount:Integer;
begin Result:=fVertexColorAnchors.Count; end;
function TRecorder3dComponent.AddGradientStrip:TRecorder3dGradientStrip;
begin Result:=TRecorder3dGradientStrip.Create; fGradientStrips.Add(Result); end;
procedure TRecorder3dComponent.DeleteGradientStrip(AIndex:Integer);
begin if (AIndex>=0) and (AIndex<fGradientStrips.Count) then begin TObject(fGradientStrips[AIndex]).Free; fGradientStrips.Delete(AIndex); end; end;
procedure TRecorder3dComponent.ClearGradientStrips;
begin while fGradientStrips.Count>0 do begin TObject(fGradientStrips.Last).Free; fGradientStrips.Delete(fGradientStrips.Count-1); end; end;
function TRecorder3dComponent.FindGradientStrip(AId:QWord):TRecorder3dGradientStrip;
var I:Integer;
begin for I:=0 to fGradientStrips.Count-1 do if GradientStrips[I].Id=AId then Exit(GradientStrips[I]); Result:=nil; end;
function TRecorder3dComponent.AddVertexColorAnchor:TRecorder3dVertexColorAnchor;
begin Result:=TRecorder3dVertexColorAnchor.Create; fVertexColorAnchors.Add(Result); end;
procedure TRecorder3dComponent.DeleteVertexColorAnchor(AIndex:Integer);
begin if (AIndex>=0) and (AIndex<fVertexColorAnchors.Count) then begin TObject(fVertexColorAnchors[AIndex]).Free; fVertexColorAnchors.Delete(AIndex); end; end;
procedure TRecorder3dComponent.ClearVertexColorAnchors;
begin while fVertexColorAnchors.Count>0 do begin TObject(fVertexColorAnchors.Last).Free; fVertexColorAnchors.Delete(fVertexColorAnchors.Count-1); end; end;

function TRecorder3dComponent.GetSkinBone(AIndex:Integer):TRecorder3dSkinBone;
begin
  Result:=TRecorder3dSkinBone(fSkinBones[AIndex]);
end;

function TRecorder3dComponent.GetSkinBoneCount:Integer;
begin
  Result:=fSkinBones.Count;
end;

function TRecorder3dComponent.AddSkinBone:TRecorder3dSkinBone;
begin
  Result:=TRecorder3dSkinBone.Create;
  fSkinBones.Add(Result);
end;

function TRecorder3dComponent.FindSkinBone(
  AHelperNodeId:QWord):TRecorder3dSkinBone;
var
  I:Integer;
begin
  Result:=nil;
  for I:=0 to fSkinBones.Count-1 do
    if TRecorder3dSkinBone(fSkinBones[I]).HelperNodeId=AHelperNodeId then
      Exit(TRecorder3dSkinBone(fSkinBones[I]));
end;

function TRecorder3dComponent.EnsureSkinBone(AHelperNodeId:QWord;
  const AName:string):TRecorder3dSkinBone;
begin
  Result:=FindSkinBone(AHelperNodeId);
  if Result<>nil then
    Exit;
  Result:=AddSkinBone;
  Result.HelperNodeId:=AHelperNodeId;
  Result.Name:=AName;
end;

procedure TRecorder3dComponent.ClearSkinBones;
begin
  while fSkinBones.Count>0 do
  begin
    TObject(fSkinBones.Last).Free;
    fSkinBones.Delete(fSkinBones.Count-1);
  end;
end;

function TRecorder3dComponent.GetSkinBinding(AIndex:Integer):TRecorder3dSkinBinding;
begin
  Result:=TRecorder3dSkinBinding(fSkinBindings[AIndex]);
end;

function TRecorder3dComponent.GetSkinBindingCount:Integer;
begin
  Result:=fSkinBindings.Count;
end;

function TRecorder3dComponent.AddSkinBinding:TRecorder3dSkinBinding;
begin
  Result:=TRecorder3dSkinBinding.Create;
  fSkinBindings.Add(Result);
end;

procedure TRecorder3dComponent.DeleteSkinBinding(AIndex:Integer);
begin
  if (AIndex<0) or (AIndex>=fSkinBindings.Count) then
    Exit;
  TObject(fSkinBindings[AIndex]).Free;
  fSkinBindings.Delete(AIndex);
end;

procedure TRecorder3dComponent.ClearSkinBindings;
begin
  while fSkinBindings.Count>0 do
  begin
    TObject(fSkinBindings.Last).Free;
    fSkinBindings.Delete(fSkinBindings.Count-1);
  end;
end;

procedure TRecorder3dComponent.BuildSkinInfluences(
  out AInfluences:T3dSkinInfluences);
var
  I:Integer;
  Binding:TRecorder3dSkinBinding;
begin
  SetLength(AInfluences,fSkinBindings.Count);
  for I:=0 to fSkinBindings.Count-1 do
  begin
    Binding:=TRecorder3dSkinBinding(fSkinBindings[I]);
    AInfluences[I].MeshNodeId:=Binding.MeshNodeId;
    AInfluences[I].LogicalVertexId:=Binding.LogicalVertexId;
    AInfluences[I].VertexIdKind:=Binding.VertexIdKind;
    AInfluences[I].HelperNodeId:=Binding.HelperNodeId;
    AInfluences[I].Weight:=Binding.Weight;
    AInfluences[I].HelperBindWorld:=Binding.HelperBindWorld;
  end;
end;

procedure TRecorder3dComponent.MaterializeSkinHelpers(AScene:T3dScene);
var
  I,J:Integer;
  Bone:TRecorder3dSkinBone;
  Node,Owner:T3dNode;
  InferredOwner:QWord;
  IsLegacy:Boolean;
begin
  if AScene=nil then
    Exit;
  for I:=0 to fSkinBones.Count-1 do
  begin
    Bone:=TRecorder3dSkinBone(fSkinBones[I]);
    if Bone.HelperNodeId=0 then
      Continue;
    IsLegacy:=Bone.OwnerMeshNodeId=0;
    if IsLegacy then
    begin
      InferredOwner:=0;
      for J:=0 to fSkinBindings.Count-1 do
        if SkinBindings[J].HelperNodeId=Bone.HelperNodeId then
          if InferredOwner=0 then InferredOwner:=SkinBindings[J].MeshNodeId
          else if InferredOwner<>SkinBindings[J].MeshNodeId then
          begin InferredOwner:=0; Break; end;
      Bone.OwnerMeshNodeId:=InferredOwner;
    end;
    Owner:=AScene.FindNode(Bone.OwnerMeshNodeId);
    { A non-zero durable owner must resolve. Silently treating a dangling
      parent as a root changes the helper coordinate space and corrupts Skin. }
    if (Bone.OwnerMeshNodeId<>0) and (Owner=nil) then
      Continue;
    Node:=AScene.FindNode(Bone.HelperNodeId);
    if Node=nil then
    begin
      Node:=T3dNode.Create;
      Node.Id:=Bone.HelperNodeId;
      Node.ParentId:=Bone.OwnerMeshNodeId;
      Node.LocalTransform:=Bone.BindLocalTransform;
      Node.WorldTransform:=Bone.BindLocalTransform;
      AScene.AddNode(Node);
    end;
    if (Owner<>nil) and IsLegacy and (Node.ParentId<>Owner.Id) then
    begin
      if ReparentNode(AScene,Node.Id,Owner.Id,True) then
        Bone.BindLocalTransform:=Node.LocalTransform;
    end;
    Node.Kind:=nkDummy;
    FreeAndNil(Node.Mesh);
    SetLength(Node.ShapeLines,0);
    Node.Bounds.Valid:=False;
    if Bone.Name<>'' then
      Node.Name:=Bone.Name;
    { Cube helpers from the previous format are now represented by SkinBone. }
    DeletePrimitive(Bone.HelperNodeId);
  end;
end;

function TRecorder3dComponent.GetPrimitive(AIndex: Integer): T3dPrimitiveSpec;
begin
  Result := fPrimitives[AIndex];
end;

function TRecorder3dComponent.GetPrimitiveCount: Integer;
begin
  Result := Length(fPrimitives);
end;

function TRecorder3dComponent.GetRemovedNodeId(AIndex: Integer): QWord;
begin
  Result := fRemovedNodeIds[AIndex];
end;

function TRecorder3dComponent.GetRemovedNodeCount: Integer;
begin
  Result := Length(fRemovedNodeIds);
end;

procedure TRecorder3dComponent.AddPrimitive(const ASpec: T3dPrimitiveSpec);
var
  Spec: T3dPrimitiveSpec;
begin
  Spec := ASpec;
  if not NormalizePrimitiveSpec(Spec) then
    Exit;
  SetLength(fPrimitives, Length(fPrimitives) + 1);
  fPrimitives[High(fPrimitives)] := Spec;
  if (Spec.NodeId >= fNextPrimitiveNodeId) and (Spec.NodeId < High(QWord)) then
    fNextPrimitiveNodeId := Spec.NodeId + 1;
end;

function TRecorder3dComponent.FindPrimitiveIndex(ANodeId: QWord): Integer;
begin
  for Result := 0 to High(fPrimitives) do
    if fPrimitives[Result].NodeId = ANodeId then
      Exit;
  Result := -1;
end;

function TRecorder3dComponent.UpdatePrimitiveIterations(ANodeId: QWord;
  AIterations,ACrossSectionIterations: Integer;
  out ASpec: T3dPrimitiveSpec): Boolean;
var
  Index: Integer;
begin
  Index := FindPrimitiveIndex(ANodeId);
  Result := Index >= 0;
  if not Result then
    Exit;
  ASpec := fPrimitives[Index];
  ASpec.Iterations := AIterations;
  ASpec.CrossSectionIterations:=ACrossSectionIterations;
  NormalizePrimitiveSpec(ASpec);
  fPrimitives[Index] := ASpec;
end;

function TRecorder3dComponent.RenamePrimitive(ANodeId:QWord;
  const AName:string):Boolean;
var Index:Integer;
begin
  Index:=FindPrimitiveIndex(ANodeId);
  Result:=Index>=0;
  if Result then
    fPrimitives[Index].Name:=AName;
end;

function TRecorder3dComponent.AllocatePrimitiveNodeId(
  AScene: T3dScene): QWord;
begin
  if fNextPrimitiveNodeId < (QWord(1) shl 62) then
    fNextPrimitiveNodeId := QWord(1) shl 62;
  while ((AScene <> nil) and (AScene.FindNode(fNextPrimitiveNodeId) <> nil)) or
        IsNodeRemoved(fNextPrimitiveNodeId) do
    Inc(fNextPrimitiveNodeId);
  Result := fNextPrimitiveNodeId;
  Inc(fNextPrimitiveNodeId);
end;

procedure TRecorder3dComponent.ResolvePrimitiveNodeIdCollisions(
  AScene: T3dScene);
var
  I, J: Integer;
  OldId, NewId: QWord;
begin
  if AScene = nil then
    Exit;
  for I := 0 to High(fPrimitives) do
    if AScene.FindNode(fPrimitives[I].NodeId) <> nil then
    begin
      OldId := fPrimitives[I].NodeId;
      NewId := AllocatePrimitiveNodeId(AScene);
      fPrimitives[I].NodeId := NewId;
      if fBindingTargetNodeId = OldId then
        fBindingTargetNodeId := NewId;
      for J := 0 to fFrfBindings.Count - 1 do
        if TRecorder3dFrfBinding(fFrfBindings[J]).TargetNodeId = OldId then
          TRecorder3dFrfBinding(fFrfBindings[J]).TargetNodeId := NewId;
      for J := 0 to fNodeRenderOverrides.Count - 1 do
        if TRecorder3dNodeRenderOverride(fNodeRenderOverrides[J]).NodeId = OldId then
          TRecorder3dNodeRenderOverride(fNodeRenderOverrides[J]).NodeId := NewId;
      for J := 0 to fSkinBindings.Count - 1 do
      begin
        if TRecorder3dSkinBinding(fSkinBindings[J]).MeshNodeId = OldId then
          TRecorder3dSkinBinding(fSkinBindings[J]).MeshNodeId := NewId;
        if TRecorder3dSkinBinding(fSkinBindings[J]).HelperNodeId = OldId then
          TRecorder3dSkinBinding(fSkinBindings[J]).HelperNodeId := NewId;
      end;
      for J:=0 to fSkinBones.Count-1 do
        if TRecorder3dSkinBone(fSkinBones[J]).HelperNodeId=OldId then
          TRecorder3dSkinBone(fSkinBones[J]).HelperNodeId:=NewId;
    end;
end;

function TRecorder3dComponent.DeletePrimitive(ANodeId: QWord): Boolean;
var
  I, WriteIndex: Integer;
begin
  Result := False;
  WriteIndex := 0;
  for I := 0 to High(fPrimitives) do
    if fPrimitives[I].NodeId = ANodeId then
      Result := True
    else
    begin
      fPrimitives[WriteIndex] := fPrimitives[I];
      Inc(WriteIndex);
    end;
  SetLength(fPrimitives, WriteIndex);
end;

function TRecorder3dComponent.IsNodeRemoved(ANodeId: QWord): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(fRemovedNodeIds) do
    if fRemovedNodeIds[I] = ANodeId then
      Exit(True);
  Result := False;
end;

procedure TRecorder3dComponent.MarkNodeRemoved(ANodeId: QWord);
begin
  if (ANodeId = 0) or IsNodeRemoved(ANodeId) then
    Exit;
  SetLength(fRemovedNodeIds, Length(fRemovedNodeIds) + 1);
  fRemovedNodeIds[High(fRemovedNodeIds)] := ANodeId;
end;

procedure TRecorder3dComponent.ClearSceneEdits;
begin
  SetLength(fPrimitives, 0);
  SetLength(fRemovedNodeIds, 0);
end;

procedure TRecorder3dComponent.RemoveNodeReferences(ANodeId: QWord);
var
  I: Integer;
begin
  if fBindingTargetNodeId = ANodeId then
    fBindingTargetNodeId := 0;
  for I := fFrfBindings.Count - 1 downto 0 do
    if TRecorder3dFrfBinding(fFrfBindings[I]).TargetNodeId = ANodeId then
    begin
      TObject(fFrfBindings[I]).Free;
      fFrfBindings.Delete(I);
    end;
  for I := fNodeRenderOverrides.Count - 1 downto 0 do
    if TRecorder3dNodeRenderOverride(fNodeRenderOverrides[I]).NodeId = ANodeId then
    begin
      TObject(fNodeRenderOverrides[I]).Free;
      fNodeRenderOverrides.Delete(I);
    end;
  for I := fSkinBindings.Count - 1 downto 0 do
    if (TRecorder3dSkinBinding(fSkinBindings[I]).MeshNodeId = ANodeId) or
       (TRecorder3dSkinBinding(fSkinBindings[I]).HelperNodeId = ANodeId) then
    begin
      TObject(fSkinBindings[I]).Free;
      fSkinBindings.Delete(I);
    end;
  for I:=fSkinBones.Count-1 downto 0 do
    if TRecorder3dSkinBone(fSkinBones[I]).HelperNodeId=ANodeId then
    begin
      TObject(fSkinBones[I]).Free;
      fSkinBones.Delete(I);
    end;
end;

function TRecorder3dComponent.AddFrfBinding: TRecorder3dFrfBinding;
begin
  Result := TRecorder3dFrfBinding.Create;
  Result.CurveId := fFrfBindings.Count + 1;
  fFrfBindings.Add(Result);
end;

procedure TRecorder3dComponent.ClearFrfBindings;
begin
  while fFrfBindings.Count > 0 do
  begin
    TObject(fFrfBindings.Last).Free;
    fFrfBindings.Delete(fFrfBindings.Count - 1);
  end;
end;

procedure TRecorder3dComponent.RemoveFrfBindingsBySourceId(
  const ASourceBindingId: string);
var
  I: Integer;
begin
  for I := fFrfBindings.Count - 1 downto 0 do
    if TRecorder3dFrfBinding(fFrfBindings[I]).SourceBindingId =
      ASourceBindingId then
    begin
      TObject(fFrfBindings[I]).Free;
      fFrfBindings.Delete(I);
    end;
end;

function TRecorder3dComponent.ReplaceFrfBindingsBySourceId(
  const ASourceBindingId: string;
  const ASpecs: array of TRecorder3dFrfBindingSpec;
  ABeforeCreate: TRecorder3dFrfReplaceHook): Boolean;
var
  NewBindings: TList;
  Replacement: TList;
  OldBindings: TList;
  Binding: TRecorder3dFrfBinding;
  I: Integer;
begin
  Result := False;
  if ASourceBindingId = '' then
    Exit;
  NewBindings := TList.Create;
  Replacement := TList.Create;
  try
    NewBindings.Capacity := Length(ASpecs);
    for I := 0 to High(ASpecs) do
    begin
      if Assigned(ABeforeCreate) then
        ABeforeCreate(I);
      Binding := TRecorder3dFrfBinding.Create;
      try
        NewBindings.Add(Binding);
      except
        Binding.Free;
        raise;
      end;
      Binding.SourceBindingId := ASourceBindingId;
      Binding.CurveId := ASpecs[I].CurveId;
      Binding.TargetNodeId := ASpecs[I].TargetNodeId;
      Binding.Axis := ASpecs[I].Axis;
      Binding.Space := ASpecs[I].Space;
      Binding.Gain := ASpecs[I].Gain;
      Binding.Enabled := ASpecs[I].Enabled;
    end;
    Replacement.Capacity := fFrfBindings.Count + NewBindings.Count;
    for I := 0 to fFrfBindings.Count - 1 do
    begin
      Binding := TRecorder3dFrfBinding(fFrfBindings[I]);
      if Binding.SourceBindingId <> ASourceBindingId then
        Replacement.Add(Binding);
    end;
    for I := 0 to NewBindings.Count - 1 do
      Replacement.Add(NewBindings[I]);

    OldBindings := fFrfBindings;
    fFrfBindings := Replacement;
    Replacement := nil;
    NewBindings.Clear;
    for I := OldBindings.Count - 1 downto 0 do
      if TRecorder3dFrfBinding(OldBindings[I]).SourceBindingId =
        ASourceBindingId then
        TObject(OldBindings[I]).Free;
    OldBindings.Free;
    Result := True;
  except
    Result := False;
  end;
  for I := NewBindings.Count - 1 downto 0 do
    TObject(NewBindings[I]).Free;
  NewBindings.Free;
  Replacement.Free;
end;

function TRecorder3dComponent.GetFrfBinding(
  AIndex: Integer): TRecorder3dFrfBinding;
begin
  Result := TRecorder3dFrfBinding(fFrfBindings[AIndex]);
end;

function TRecorder3dComponent.GetFrfBindingCount: Integer;
begin
  Result := fFrfBindings.Count;
end;

function TRecorder3dComponent.AddNodeRenderOverride:
  TRecorder3dNodeRenderOverride;
begin
  Result := TRecorder3dNodeRenderOverride.Create;
  fNodeRenderOverrides.Add(Result);
end;

procedure TRecorder3dComponent.ClearNodeRenderOverrides;
begin
  while fNodeRenderOverrides.Count > 0 do
  begin
    TObject(fNodeRenderOverrides.Last).Free;
    fNodeRenderOverrides.Delete(fNodeRenderOverrides.Count - 1);
  end;
end;

function TRecorder3dComponent.FindNodeRenderOverride(
  ANodeId: QWord): TRecorder3dNodeRenderOverride;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fNodeRenderOverrides.Count - 1 do
    if TRecorder3dNodeRenderOverride(fNodeRenderOverrides[I]).NodeId =
      ANodeId then
      Exit(TRecorder3dNodeRenderOverride(fNodeRenderOverrides[I]));
end;

function TRecorder3dComponent.GetNodeRenderOverride(
  AIndex: Integer): TRecorder3dNodeRenderOverride;
begin
  Result := TRecorder3dNodeRenderOverride(fNodeRenderOverrides[AIndex]);
end;

function TRecorder3dComponent.GetNodeRenderOverrideCount: Integer;
begin
  Result := fNodeRenderOverrides.Count;
end;

constructor TRecorder3dFactory.Create;
begin
  inherited Create(TRecorder3dComponent.TypeId, '3D-сцена',
    TRecorder3dComponent, 480, 320, False);
  ConfigurePalette('3D', 'Добавить интерактивную 3D-сцену', '3d-view', 31,
    rppGroup, CRecorderPaletteGroupImages);
end;

procedure TRecorder3dFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('ThreeDView%d', [AContext.ComponentNo]);
end;

procedure RegisterRecorder3dFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorder3dComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorder3dFactory.Create);
end;

end.
