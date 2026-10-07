unit uRecorder3dView;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Live Recorder host for the reusable 3D widget. The visual-control registry
  creates it for TRecorder3dComponent; Configure projects persistent settings
  into the scene and RefreshControl applies cached tag and FRF updates. The
  view owns its adapters and UI controls, while Recorder owns model and tags. }

interface

uses
  Classes, SysUtils, Math, Types, Controls, Graphics, ExtCtrls, StdCtrls, Buttons, Menus, Forms, ComCtrls, ImgList,
  uOglChart, u3dCoreTypes, u3dContracts, u3dScene, u3dSceneMath, u3dGeometryMath, u3dInteractionTypes,
  u3dGizmo, u3dLclWidget, u3dMeshTopology, u3dScreenGeometryMath,
  u3dPrimitives, u3dTransforms, u3dSkin,
  uRecorderFormModel, uRecorderTags,
  uRecorderVisualControl, uRecorder3dModel, uRecorder3dBindingAdapter,
  uRecorder3dSceneTreeDialog, uRecorder3dSettingsDialog,
  uRecorderCommandImages, uRcIconIds, u3dMotionContracts, u3dSceneMotionEngine,
  uRecorderFrfContracts, uRecorderFrfMotionAdapter,
  uRecorder3dInteractionTrace, uRecorderImpactHammerContracts,
  uRecorder3dImpactBindingController, uRecorder3dSkinBindingAdapter,
  uRecorder3dVertexColorAdapter;

type
  { Connects Recorder lifecycle/events to scene loading, interaction, bindings
    and FRF motion without moving those concerns into the renderer. }
  TRecorder3dView = class(T3dLclWidget, IVForm)
  private
    fComponent: TRecorder3dComponent;
    fRegistry: TRecorderTagRegistry;
    fBindings: TRecorder3dBindingAdapter;
    fFrfProvider: IRecorderFrfProvider;
    fFrfSink: I3dMotionSink;
    fFrfAdapter: TRecorderFrfMotionAdapter;
    fSkinEngine:T3dSkinEngine;
    fSkinBindings:TRecorder3dSkinBindingAdapter;
    fVertexColors:TRecorder3dVertexColorAdapter;
    fValueLabels:TRecorder3dVertexValueLabels;
    fOverlayCanvas:TControlCanvas;
    fFrfFrequencyTag:TRecorderTag;
    fFrfAnimationPhaseTag:TRecorderTag;
    fLoadedFileName: string;
    fToolbar: TPanel;
    fCurrentMode: T3dInputMode;
    fEditMode:Boolean;
    fPopup: TPopupMenu;
    fSceneTreeDialog:TRecorder3dSceneTreeDialog;
    fSceneEditor:TRecorder3dSettingsDialog;
    fImpactBindingController:TRecorder3dImpactBindingController;
    fImpactPointCatalog:IRecorderModelPointCatalog;
    fImpactBindingSink:IRecorderModelPointBindingSink;
    fRegisteredPointTargetId:string;
    fAnimationTick:QWord;
    fModeButtons:array[T3dInputMode] of TSpeedButton;
    fModePanels:array[T3dInputMode] of TPanel;
    fViewPanel:TPanel;
    fViewButtons:array[T3dStandardView] of TSpeedButton;
    procedure UpdateModeButtons;
    procedure ApplyModel;
    procedure ViewChanged(Sender: TObject);
    procedure ToolClick(Sender: TObject);
    procedure FitClick(Sender: TObject);
    procedure SceneTreeClick(Sender: TObject);
    procedure SceneTreeChanged(Sender: TObject);
    procedure SceneTreeNodeSelected(ANodeId:QWord);
    procedure SceneTreeOpenObjectEditor(ANodeId:QWord);
    procedure SceneEditorClick(Sender:TObject);
    procedure EditorNodeSelected(ANodeId:QWord);
    procedure EditorVertexSelected(ANodeId:QWord;
      const APrimaryCorners,AAdjacentCorners:array of LongWord);
    procedure EditorSettingsApplied(Sender:TObject);
    procedure EditorSkinChanged(Sender:TObject);
    procedure EditorVertexColorChanged(Sender:TObject);
    procedure EditorAddSkinHelper(AMeshNodeId:QWord;
      ALogicalVertexId:LongWord; const AName:string; AWeight:Single;
      out AHelperNodeId:QWord);
    procedure EditorDeleteSkinHelper(AHelperNodeId:QWord);
    procedure EditorResetSkinHelpers(Sender:TObject);
    procedure EditorRenameSkinHelper(AHelperNodeId:QWord; const AName:string);
    procedure EditorSetSkinInfluence(AHelperNodeId,AMeshNodeId:QWord;
      ALogicalVertexId:LongWord; AWeight:Single);
    procedure EditorRemoveSkinInfluence(AHelperNodeId,AMeshNodeId:QWord;
      ALogicalVertexId:LongWord);
    procedure SceneSelectionChanged(Sender:TObject);
    procedure SceneVertexPicked(Sender:TObject; ANodeId:QWord;
      ALogicalVertex:Integer);
    procedure NodeTransformChanged(Sender:TObject; ANodeId:QWord);
    procedure HighlightLogicalVertex(ANodeId:QWord; ALogicalVertex:Integer);
    procedure BuildToolbar;
    procedure BuildViewSelector;
    procedure ViewPresetClick(Sender:TObject);
    procedure ApplyViewPreset(AView:T3dStandardView);
    procedure LoadConfiguredScene;
    procedure ApplySceneEdits;
    procedure ApplyNodeRenderOverrides;
    procedure ConfigureFrf;
    procedure ConfigureSkin;
    procedure UpdateSelectedHelperOverlay;
    procedure UpdateValueLabels;
    procedure DrawValueLabels;
    procedure ClearValueLabels;
    procedure ApplyComponentConfiguration;
    procedure SetEditMode(AValue:Boolean);
    procedure TraceInteraction(const AMessage:string);
    procedure ImpactBindingsChanged(Sender:TObject);
  protected
    procedure Paint; override;
    procedure KeyDown(var Key:Word; Shift:TShiftState); override;
    procedure MouseDown(Button:TMouseButton; Shift:TShiftState;
      X,Y:Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    procedure SetFrfProvider(const AProvider: IRecorderFrfProvider);
    function GetChartControl: TOglChart;
    property EditMode:Boolean read fEditMode write SetEditMode;
  end;

implementation

function ResolveTag(ARegistry:TRecorderTagRegistry; AId:TRecorderTagId;
  const AName:string):TRecorderTag;
begin
  Result:=nil;
  if ARegistry=nil then
    Exit;
  if AId<>0 then
    Result:=ARegistry.FindById(AId);
  if (Result=nil) and (AName<>'') then
    Result:=ARegistry.FindByName(AName);
end;

constructor TRecorder3dView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if Recorder3dInteractionTraceEnabled then
    OnInteractionTrace:=@TraceInteraction;
  fBindings := TRecorder3dBindingAdapter.Create;
  fFrfAdapter := TRecorderFrfMotionAdapter.Create;
  fSkinEngine := T3dSkinEngine.Create;
  fSkinBindings:=TRecorder3dSkinBindingAdapter.Create;
  fVertexColors:=TRecorder3dVertexColorAdapter.Create;
  fOverlayCanvas:=TControlCanvas.Create;
  fOverlayCanvas.Control:=Self;
  OnViewChanged := @ViewChanged;
  OnSelectionChanged := @SceneSelectionChanged;
  OnVertexPicked := @SceneVertexPicked;
  OnNodeTransformChanged := @NodeTransformChanged;
  BuildToolbar;
  BuildViewSelector;
  TabStop:=True;
end;

procedure TRecorder3dView.BuildViewSelector;
const
  CCaptions:array[T3dStandardView] of string=('3D','TOP','FRONT','BOT');
  CColors:array[T3dStandardView] of TColor=(clWhite,$00FF6060,$0060FF60,$006060FF);
var
  V:T3dStandardView;
  B:TSpeedButton;
begin
  fViewPanel:=TPanel.Create(Self);
  fViewPanel.Parent:=Self;
  fViewPanel.SetBounds(8,8,190,28);
  fViewPanel.BevelOuter:=bvNone;
  fViewPanel.ParentColor:=False;
  fViewPanel.Color:=$0033291F;
  for V:=Low(V) to High(V) do
  begin
    B:=TSpeedButton.Create(fViewPanel);
    B.Parent:=fViewPanel;
    B.SetBounds(Ord(V)*47,0,46,26);
    B.Caption:=CCaptions[V];
    B.Font.Color:=CColors[V];
    B.Tag:=Ord(V);
    B.GroupIndex:=29;
    B.OnClick:=@ViewPresetClick;
    fViewButtons[V]:=B;
  end;
  fViewButtons[svCamera].Down:=True;
  fViewPanel.BringToFront;
end;

procedure TRecorder3dView.ApplyViewPreset(AView:T3dStandardView);
begin
  SetStandardView(AView);
  fViewButtons[AView].Down:=True;
  fModeButtons[imRotate].Enabled:=AView=svCamera;
  if AView<>svCamera then
  begin
    fCurrentMode:=imPan;
    SetInputMode(imPan);
    UpdateModeButtons;
  end;
  SetFocus;
end;

procedure TRecorder3dView.ViewPresetClick(Sender:TObject);
begin
  ApplyViewPreset(T3dStandardView(TControl(Sender).Tag));
end;

procedure TRecorder3dView.KeyDown(var Key:Word; Shift:TShiftState);
begin
  inherited KeyDown(Key,Shift);
  case Key of
    Ord('T'):ApplyViewPreset(svTop);
    Ord('F'):ApplyViewPreset(svFront);
    Ord('B'):ApplyViewPreset(svBottom);
    Ord('C'):ApplyViewPreset(svCamera);
    else Exit;
  end;
  Key:=0;
end;

procedure TRecorder3dView.SceneSelectionChanged(Sender:TObject);
begin
  UpdateSelectedHelperOverlay;
  ClearVertexHighlight;
  if fSceneTreeDialog<>nil then
    fSceneTreeDialog.SelectNodeFromView(SelectedNodeId);
  if (fSceneEditor<>nil) and fSceneEditor.Visible then
    fSceneEditor.SelectNodeFromView(SelectedNodeId);
end;

procedure TRecorder3dView.MouseDown(Button:TMouseButton; Shift:TShiftState;
  X,Y:Integer);
var
  ScreenPoint:TPoint;
begin
  if (Button=mbRight) and (fPopup<>nil) then
  begin
    ScreenPoint:=ClientToScreen(Point(X,Y));
    fPopup.PopUp(ScreenPoint.X,ScreenPoint.Y);
    Exit;
  end;
  inherited MouseDown(Button,Shift,X,Y);
end;

procedure TRecorder3dView.UpdateSelectedHelperOverlay;
begin
  if (fComponent<>nil) and
     (fComponent.FindSkinBone(SelectedNodeId)<>nil) then
    SetOverlayNodeId(SelectedNodeId)
  else
    SetOverlayNodeId(0);
end;

procedure TRecorder3dView.NodeTransformChanged(Sender:TObject; ANodeId:QWord);
var
  Node:T3dNode;
  OverrideItem:TRecorder3dNodeRenderOverride;
begin
  if (fComponent=nil) or (Scene=nil) then
    Exit;
  Node:=Scene.FindNode(ANodeId);
  if Node=nil then
    Exit;
  OverrideItem:=fComponent.FindNodeRenderOverride(ANodeId);
  if OverrideItem=nil then
    OverrideItem:=fComponent.AddNodeRenderOverride;
  OverrideItem.NodeId:=ANodeId;
  OverrideItem.HasTransform:=True;
  OverrideItem.LocalTransform:=Node.LocalTransform;
  if (fSkinEngine<>nil) and (fComponent.SkinBindingCount>0) then
  begin
    { Drag already rebuilt world transforms. Reuse the prepared skin bindings;
      ConfigureSkin here would redefine work and bind state on every mouse move. }
    fSkinEngine.Apply;
    UpdateValueLabels;
    MarkDirty;
  end;
  if fSceneTreeDialog<>nil then
    fSceneTreeDialog.SelectNodeFromView(ANodeId);
end;

procedure TRecorder3dView.SceneVertexPicked(Sender:TObject; ANodeId:QWord;
  ALogicalVertex:Integer);
begin
  HighlightLogicalVertex(ANodeId,ALogicalVertex);
  if (fSceneEditor<>nil) and fSceneEditor.Visible then
    fSceneEditor.SelectVertexFromView(ANodeId,ALogicalVertex);
end;

procedure TRecorder3dView.HighlightLogicalVertex(ANodeId:QWord;
  ALogicalVertex:Integer);
var
  Node,SourceNode:T3dNode;
  Mesh:T3dMeshData;
  Topology:T3dMeshTopology;
  Relations:T3dTopologyRelations;
  Primary,Adjacent:array of LongWord;
  I,J,Offset:Integer;
begin
  if Scene=nil then
    Exit;
  Node:=Scene.FindNode(ANodeId);
  if Node=nil then
    Exit;
  Mesh:=Node.Mesh;
  if (Mesh<>nil) and (Length(Mesh.Positions)=0) and
    (Mesh.SourceNodeId<>0) then
  begin
    SourceNode:=Scene.FindNode(Mesh.SourceNodeId);
    if SourceNode<>nil then
      Mesh:=SourceNode.Mesh;
  end;
  Topology:=BuildMeshTopology(Mesh);
  if (ALogicalVertex<0) or
    (ALogicalVertex>High(Topology.LogicalToCorners)) then
    Exit;
  SetLength(Primary,Length(Topology.LogicalToCorners[ALogicalVertex]));
  SetLength(Adjacent,0);
  for I:=0 to High(Primary) do
    Primary[I]:=Topology.LogicalToCorners[ALogicalVertex][I];
  Relations:=ClassifyLogicalVertices(Topology,ALogicalVertex);
  for I:=0 to High(Relations) do
    if Relations[I]=trAdjacent then
    begin
      Offset:=Length(Adjacent);
      SetLength(Adjacent,Offset+Length(Topology.LogicalToCorners[I]));
      for J:=0 to High(Topology.LogicalToCorners[I]) do
        Adjacent[Offset+J]:=Topology.LogicalToCorners[I][J];
    end;
  SetVertexHighlight(ANodeId,Primary,Adjacent);
end;

procedure TRecorder3dView.TraceInteraction(const AMessage:string);
begin
  Recorder3dInteractionTrace(AMessage);
end;

destructor TRecorder3dView.Destroy;
begin
  ClearValueLabels;
  FreeAndNil(fOverlayCanvas);
  fVertexColors.Free;
  fSkinEngine.Free;
  fSkinBindings.Free;
  if fRegisteredPointTargetId<>'' then
    UnregisterRecorderModelPointTarget(fRegisteredPointTargetId);
  fImpactPointCatalog:=nil;
  fImpactBindingSink:=nil;
  FreeAndNil(fSceneTreeDialog);
  fSceneEditor.Free;
  fBindings.Free;
  fFrfAdapter.Free;
  fFrfProvider:=nil;
  fFrfSink:=nil;
  inherited Destroy;
end;

procedure TRecorder3dView.ClearValueLabels;
begin
  SetLength(fValueLabels,0);
end;

procedure TRecorder3dView.UpdateValueLabels;
begin
  SetLength(fValueLabels,0);
  if (fVertexColors=nil) or (Scene=nil) then
    Exit;
  fVertexColors.BuildValueLabels(fValueLabels);
end;

procedure TRecorder3dView.DrawValueLabels;
var
  I:Integer;
  V:T3dViewport;
  Screen:T3dPoint;
  Depth:Single;
  TextSize:TSize;
  X,Y:Integer;
begin
  if Length(fValueLabels)=0 then
    Exit;
  V.Width:=ClientWidth; V.Height:=ClientHeight;
  if fOverlayCanvas=nil then
    Exit;
  fOverlayCanvas.Font.Name:='Tahoma';
  fOverlayCanvas.Font.Size:=9;
  fOverlayCanvas.Font.Color:=clWhite;
  fOverlayCanvas.Brush.Style:=bsSolid;
  fOverlayCanvas.Brush.Color:=$00504030;
  for I:=0 to High(fValueLabels) do
    if ProjectWorldToScreen(fValueLabels[I].Position,CurrentOrbitCamera,V,
      Screen,Depth) then
    begin
      TextSize:=fOverlayCanvas.TextExtent(fValueLabels[I].Text);
      X:=Round(Screen.X)+8;
      Y:=Round(Screen.Y)-TextSize.cy div 2;
      fOverlayCanvas.FillRect(Rect(X-3,Y-2,X+TextSize.cx+3,Y+TextSize.cy+2));
      fOverlayCanvas.TextOut(X,Y,fValueLabels[I].Text);
    end;
end;

procedure TRecorder3dView.Paint;
begin
  inherited Paint;
  { Graphic LCL children are erased by SwapBuffers on TOpenGLControl. Draw the
    fixed-pixel value overlay on the same front surface after the 3D frame. }
  DrawValueLabels;
end;

procedure TRecorder3dView.ImpactBindingsChanged(Sender:TObject);
begin
  ConfigureFrf;
end;

procedure TRecorder3dView.SetEditMode(AValue:Boolean);
begin
  if fEditMode=AValue then
    Exit;
  fEditMode:=AValue;
  InteractionEnabled:=not fEditMode;
  fToolbar.Enabled:=not fEditMode;
  if fEditMode then
  begin
    CancelInteraction;
    Cursor:=crDefault;
  end;
  if Recorder3dInteractionTraceEnabled then
    Recorder3dInteractionTrace(Format('EditMode=%s toolbarEnabled=%s',
      [BoolToStr(fEditMode,True),BoolToStr(fToolbar.Enabled,True)]));
end;

procedure TRecorder3dView.BuildToolbar;
const
  CImageIndex:array[0..4] of Integer=(CIcon3dSelect,CIcon3dPan,
    CIcon3dCameraRotate,CIcon3dZoom,CIcon3dFitScene);
  CHint:array[0..4] of string=('Выбор и перемещение','Панорама',
    'Вращение камеры; Ctrl — вращение выбранного объекта',
    'Масштаб','Показать всю сцену');
var
  I:Integer;
  B:TSpeedButton;
  P:TPanel;
  Item:TMenuItem;
  Images:TCustomImageList;
  C:TComponent;
begin
  Images:=nil;
  if Application.MainForm<>nil then
  begin
    C:=Application.MainForm.FindComponent('ilCommandButtons');
    if C is TCustomImageList then
      Images:=TCustomImageList(C);
  end;
  fToolbar:=TPanel.Create(Self);
  fToolbar.Parent:=Self;
  fToolbar.Align:=alBottom;
  fToolbar.Height:=48;
  fToolbar.BevelOuter:=bvNone;
  for I:=0 to 4 do
  begin
    P:=nil;
    if I<4 then
    begin
      P:=TPanel.Create(fToolbar);
      P.Parent:=fToolbar;
      P.SetBounds(4+I*46,3,44,42);
      P.BevelOuter:=bvNone;
      P.ParentColor:=False;
      fModePanels[T3dInputMode(I)]:=P;
    end;
    B:=TSpeedButton.Create(fToolbar);
    if P<>nil then
    begin
      B.Parent:=P;
      B.SetBounds(3,3,38,36);
    end
    else
    begin
      B.Parent:=fToolbar;
      B.SetBounds(4+I*46,3,44,42);
    end;
    B.Images:=Images;
    B.ImageIndex:=CImageIndex[I];
    B.Tag:=I;
    B.ShowHint:=True;
    B.Flat:=False;
    if I<4 then
    begin
      B.Hint:=CHint[I];
      B.GroupIndex:=17;
      B.AllowAllUp:=False;
      B.OnClick:=@ToolClick;
      fModeButtons[T3dInputMode(I)]:=B;
    end
    else
    begin
      B.Hint:=CHint[I];
      B.OnClick:=@FitClick;
    end;
    if I=0 then
      B.Down:=True;
  end;
  fCurrentMode:=imSelect;
  UpdateModeButtons;
  fPopup:=TPopupMenu.Create(Self);
  fPopup.AutoPopup:=False;
  Item:=TMenuItem.Create(fPopup);
  Item.Caption:='Редактор сцены...';
  Item.OnClick:=@SceneEditorClick;
  fPopup.Items.Add(Item);
  Item:=TMenuItem.Create(fPopup);
  Item.Caption:='Дерево сцены...';
  Item.OnClick:=@SceneTreeClick;
  fPopup.Items.Add(Item);
  PopupMenu:=fPopup;
end;

procedure TRecorder3dView.SceneEditorClick(Sender:TObject);
begin
  if fComponent=nil then
    Exit;
  if fSceneEditor=nil then
  begin
    fSceneEditor:=TRecorder3dSettingsDialog.CreateDialog(Self,fComponent,
      fRegistry,SelectedNodeId);
    fSceneEditor.OnNodeSelected:=@EditorNodeSelected;
    fSceneEditor.OnVertexSelected:=@EditorVertexSelected;
    fSceneEditor.OnSettingsApplied:=@EditorSettingsApplied;
    fSceneEditor.OnSkinChanged:=@EditorSkinChanged;
    fSceneEditor.OnVertexColorChanged:=@EditorVertexColorChanged;
    fSceneEditor.OnAddSkinHelper:=@EditorAddSkinHelper;
    fSceneEditor.OnDeleteSkinHelper:=@EditorDeleteSkinHelper;
    fSceneEditor.OnResetSkinHelpers:=@EditorResetSkinHelpers;
    fSceneEditor.OnRenameSkinHelper:=@EditorRenameSkinHelper;
    fSceneEditor.OnSetSkinInfluence:=@EditorSetSkinInfluence;
    fSceneEditor.OnRemoveSkinInfluence:=@EditorRemoveSkinInfluence;
  end;
  fSceneEditor.AttachLiveScene(Scene,SelectedNodeId);
  fSceneEditor.ShowEditor(SelectedNodeId);
end;

procedure TRecorder3dView.EditorAddSkinHelper(AMeshNodeId:QWord;
  ALogicalVertexId:LongWord; const AName:string; AWeight:Single;
  out AHelperNodeId:QWord);
var MeshNode,Helper:T3dNode;
  OverrideItem:TRecorder3dNodeRenderOverride;
  I,Corner:Integer;
  LocalPoint,WorldPoint:T3dVector;
begin
  AHelperNodeId:=0;
  if (Scene=nil) or (fComponent=nil) then Exit;
  MeshNode:=Scene.FindNode(AMeshNodeId);
  if (MeshNode=nil) or (MeshNode.Mesh=nil) then Exit;
  if Length(MeshNode.Mesh.BasePositions)=0 then
    MeshNode.Mesh.BasePositions:=Copy(MeshNode.Mesh.Positions);
  Corner:=-1;
  if Length(MeshNode.Mesh.LogicalVertices)=0 then
    Corner:=Integer(ALogicalVertexId)
  else
    for I:=0 to High(MeshNode.Mesh.LogicalVertices) do
      if MeshNode.Mesh.LogicalVertices[I].Id=ALogicalVertexId then
      begin
        if Length(MeshNode.Mesh.LogicalVertices[I].CornerIndices)>0 then
          Corner:=MeshNode.Mesh.LogicalVertices[I].CornerIndices[0];
        Break;
      end;
  if (Corner<0) or (Corner>High(MeshNode.Mesh.BasePositions)) then Exit;
  LocalPoint:=MeshNode.Mesh.BasePositions[Corner];
  WorldPoint:=TransformPoint(LocalPoint,MeshNode.WorldTransform);
  Helper:=T3dNode.Create;
  Helper.Id:=fComponent.AllocatePrimitiveNodeId(Scene);
  Helper.Kind:=nkDummy;
  Helper.Name:=AName;
  SetIdentity(Helper.LocalTransform);
  Helper.LocalTransform[12]:=WorldPoint.X;
  Helper.LocalTransform[13]:=WorldPoint.Y;
  Helper.LocalTransform[14]:=WorldPoint.Z;
  Helper.WorldTransform:=Helper.LocalTransform;
  Scene.AddNode(Helper);
  if not ReparentNode(Scene,Helper.Id,MeshNode.Id,True) then
  begin
    Scene.RemoveNode(Helper.Id);
    Exit;
  end;
  OverrideItem:=fComponent.AddNodeRenderOverride;
  OverrideItem.NodeId:=Helper.Id;
  OverrideItem.HasTransform:=True;
  OverrideItem.LocalTransform:=Helper.LocalTransform;
  Helper.LocalTransform:=OverrideItem.LocalTransform;
  Scene.RebuildWorldTransforms(I);
  AHelperNodeId:=Helper.Id;
  with fComponent.EnsureSkinBone(AHelperNodeId,AName) do
  begin
    OwnerMeshNodeId:=AMeshNodeId;
    BindLocalTransform:=Helper.LocalTransform;
  end;
  EditorSetSkinInfluence(AHelperNodeId,AMeshNodeId,ALogicalVertexId,AWeight);
  if fSceneEditor<>nil then
    fSceneEditor.AttachLiveScene(Scene,AHelperNodeId);
  if fSceneTreeDialog<>nil then
    fSceneTreeDialog.SelectNodeFromView(AHelperNodeId);
  SelectNode(AHelperNodeId);
  MarkDirty;
end;

procedure TRecorder3dView.EditorDeleteSkinHelper(AHelperNodeId:QWord);
var
  Bone:TRecorder3dSkinBone;
  NextSelection:QWord;
begin
  if (fComponent=nil) or (AHelperNodeId=0) then Exit;
  NextSelection:=0;
  Bone:=fComponent.FindSkinBone(AHelperNodeId);
  if Bone<>nil then
    NextSelection:=Bone.OwnerMeshNodeId;
  fComponent.DeletePrimitive(AHelperNodeId);
  fComponent.RemoveNodeReferences(AHelperNodeId);
  if Scene<>nil then Scene.RemoveNode(AHelperNodeId);
  ConfigureSkin;
  if fSceneEditor<>nil then
    fSceneEditor.AttachLiveScene(Scene,NextSelection);
  if fSceneTreeDialog<>nil then
    fSceneTreeDialog.SelectNodeFromView(NextSelection);
  SelectNode(NextSelection);
  MarkDirty;
end;

procedure TRecorder3dView.EditorResetSkinHelpers(Sender:TObject);
var
  I,lUpdated:Integer;
  Bone:TRecorder3dSkinBone;
  Node:T3dNode;
  OverrideItem:TRecorder3dNodeRenderOverride;
begin
  if (Scene=nil) or (fComponent=nil) then
    Exit;
  for I:=0 to fComponent.SkinBoneCount-1 do
  begin
    Bone:=fComponent.SkinBones[I];
    Node:=Scene.FindNode(Bone.HelperNodeId);
    if Node=nil then
      Continue;
    Node.LocalTransform:=Bone.BindLocalTransform;
    OverrideItem:=fComponent.FindNodeRenderOverride(Node.Id);
    if OverrideItem=nil then
      OverrideItem:=fComponent.AddNodeRenderOverride;
    OverrideItem.NodeId:=Node.Id;
    OverrideItem.HasTransform:=True;
    OverrideItem.LocalTransform:=Node.LocalTransform;
  end;
  Scene.RebuildWorldTransforms(lUpdated);
  if fSkinEngine<>nil then
    fSkinEngine.Apply;
  MarkDirty;
  if fSceneTreeDialog<>nil then
    fSceneTreeDialog.SelectNodeFromView(SelectedNodeId);
end;

procedure TRecorder3dView.EditorRenameSkinHelper(AHelperNodeId:QWord;
  const AName:string);
var I:Integer; N:T3dNode;
begin
  if fComponent=nil then Exit;
  fComponent.RenamePrimitive(AHelperNodeId,AName);
  if fComponent.FindSkinBone(AHelperNodeId)<>nil then
    fComponent.FindSkinBone(AHelperNodeId).Name:=AName;
  for I:=0 to fComponent.SkinBindingCount-1 do
    if fComponent.SkinBindings[I].HelperNodeId=AHelperNodeId then
      fComponent.SkinBindings[I].PointName:=AName;
  if Scene<>nil then
  begin
    N:=Scene.FindNode(AHelperNodeId);
    if N<>nil then N.Name:=AName;
  end;
  MarkDirty;
end;

procedure TRecorder3dView.EditorRemoveSkinInfluence(AHelperNodeId,
  AMeshNodeId:QWord; ALogicalVertexId:LongWord);
var
  I:Integer;
begin
  if fComponent=nil then
    Exit;
  for I:=fComponent.SkinBindingCount-1 downto 0 do
    if (fComponent.SkinBindings[I].HelperNodeId=AHelperNodeId) and
      (fComponent.SkinBindings[I].MeshNodeId=AMeshNodeId) and
      (fComponent.SkinBindings[I].LogicalVertexId=ALogicalVertexId) then
    begin
      fComponent.DeleteSkinBinding(I);
      Break;
    end;
  ConfigureSkin;
  MarkDirty;
end;

procedure TRecorder3dView.EditorSetSkinInfluence(AHelperNodeId,AMeshNodeId:QWord;
  ALogicalVertexId:LongWord; AWeight:Single);
var I:Integer; B:TRecorder3dSkinBinding; Helper,OwnerNode:T3dNode;
  Bone:TRecorder3dSkinBone;
begin
  if (fComponent=nil) or (Scene=nil) then Exit;
  B:=nil;
  for I:=0 to fComponent.SkinBindingCount-1 do
    if (fComponent.SkinBindings[I].HelperNodeId=AHelperNodeId) and
       (fComponent.SkinBindings[I].MeshNodeId=AMeshNodeId) and
       (fComponent.SkinBindings[I].LogicalVertexId=ALogicalVertexId) then
      B:=fComponent.SkinBindings[I];
  if B=nil then B:=fComponent.AddSkinBinding;
  B.HelperNodeId:=AHelperNodeId;
  B.MeshNodeId:=AMeshNodeId;
  B.LogicalVertexId:=ALogicalVertexId;
  B.Weight:=EnsureRange(AWeight,0,1);
  Helper:=Scene.FindNode(AHelperNodeId);
  Bone:=fComponent.FindSkinBone(AHelperNodeId);
  if Helper<>nil then
  begin
    B.PointName:=Helper.Name;
    if Bone<>nil then
    begin
      OwnerNode:=Scene.FindNode(Bone.OwnerMeshNodeId);
      if OwnerNode<>nil then
        ComposeMatrices(OwnerNode.WorldTransform,Bone.BindLocalTransform,
          B.HelperBindWorld)
      else
        B.HelperBindWorld:=Helper.WorldTransform;
    end
    else
      B.HelperBindWorld:=Helper.WorldTransform;
  end;
  ConfigureSkin;
  MarkDirty;
end;

procedure TRecorder3dView.EditorSettingsApplied(Sender:TObject);
begin
  ApplyComponentConfiguration;
end;

procedure TRecorder3dView.EditorSkinChanged(Sender:TObject);
begin
  ConfigureSkin;
  MarkDirty;
end;

procedure TRecorder3dView.EditorVertexColorChanged(Sender:TObject);
begin
  if fVertexColors=nil then Exit;
  fVertexColors.Configure(fComponent,fRegistry);
  fVertexColors.AttachScene(Scene);
  UpdateValueLabels;
  MarkDirty;
end;

procedure TRecorder3dView.EditorNodeSelected(ANodeId:QWord);
begin
  ClearVertexHighlight;
  SelectNode(ANodeId);
end;

procedure TRecorder3dView.EditorVertexSelected(ANodeId:QWord;
  const APrimaryCorners,AAdjacentCorners:array of LongWord);
begin
  if (Length(APrimaryCorners)=0) and (Length(AAdjacentCorners)=0) then
    ClearVertexHighlight
  else
    SetVertexHighlight(ANodeId,APrimaryCorners,AAdjacentCorners);
end;

procedure TRecorder3dView.ToolClick(Sender:TObject);
begin
  fCurrentMode:=T3dInputMode(TSpeedButton(Sender).Tag);
  if (fCurrentMode=imRotate) and
     (Camera.ProjectionKind=pkOrthographic) then
    fCurrentMode:=imPan;
  UpdateModeButtons;
  if Recorder3dInteractionTraceEnabled then
    Recorder3dInteractionTrace(Format(
      'toolbar name=%s tag=%d mode=%d edit=%s interaction=%s',
      [TSpeedButton(Sender).Name,TSpeedButton(Sender).Tag,Ord(fCurrentMode),
      BoolToStr(fEditMode,True),BoolToStr(InteractionEnabled,True)]));
  SetInputMode(fCurrentMode);
end;

procedure TRecorder3dView.UpdateModeButtons;
var M:T3dInputMode;
begin
  for M:=Low(T3dInputMode) to High(T3dInputMode) do
    if fModeButtons[M]<>nil then
    begin
      fModeButtons[M].Down:=M=fCurrentMode;
      if fModePanels[M]<>nil then
        if M=fCurrentMode then
          fModePanels[M].Color:=$00A8D8FF
        else
          fModePanels[M].Color:=clBtnFace;
    end;
end;

procedure TRecorder3dView.FitClick(Sender:TObject);
begin
  FitScene;
end;

procedure TRecorder3dView.SceneTreeClick(Sender:TObject);
begin
  if (Scene=nil) or (fComponent=nil) then Exit;
  if fSceneTreeDialog=nil then
  begin
    fSceneTreeDialog:=TRecorder3dSceneTreeDialog.Create(Self);
    fSceneTreeDialog.OnSceneChanged:=@SceneTreeChanged;
    fSceneTreeDialog.OnNodeSelected:=@SceneTreeNodeSelected;
    fSceneTreeDialog.OnOpenObjectEditor:=@SceneTreeOpenObjectEditor;
  end;
  fSceneTreeDialog.ShowEditor(Scene,fComponent,SelectedNodeId);
end;

procedure TRecorder3dView.SceneTreeNodeSelected(ANodeId:QWord);
begin
  if ANodeId<>0 then SelectNode(ANodeId);
end;

procedure TRecorder3dView.SceneTreeOpenObjectEditor(ANodeId:QWord);
begin
  if ANodeId<>0 then SelectNode(ANodeId);
  SceneEditorClick(Self);
end;

procedure TRecorder3dView.SceneTreeChanged(Sender: TObject);
begin
  if fComponent<>nil then
    SetView(Camera.YawDegrees,Camera.PitchDegrees,Camera.Distance,
      fComponent.ShowAxes,LongWord(fComponent.BackgroundColor));
  ApplyNodeRenderOverrides;
  fBindings.AttachScene(Scene);
  ConfigureFrf;
  MarkDirty;
  Invalidate;
end;

procedure TRecorder3dView.ViewChanged(Sender: TObject);
begin
  if fComponent = nil then
    Exit;
  UpdateValueLabels;
  fComponent.CameraYaw := Camera.YawDegrees;
  fComponent.CameraPitch := Camera.PitchDegrees;
  fComponent.CameraDistance := Camera.Distance;
  fComponent.CameraTargetX:=Camera.Target.X;
  fComponent.CameraTargetY:=Camera.Target.Y;
  fComponent.CameraTargetZ:=Camera.Target.Z;
  fComponent.CameraRoll:=Camera.RollDegrees;
  fComponent.CameraFov:=Camera.VerticalFovDegrees;
end;

procedure TRecorder3dView.ApplyModel;
var
  O:T3dRenderOptions;
  C:T3dCamera;
begin
  if fComponent = nil then
    Exit;
  FillChar(C,SizeOf(C),0);
  C.YawDegrees:=fComponent.CameraYaw;
  C.PitchDegrees:=fComponent.CameraPitch;
  C.Distance:=fComponent.CameraDistance;
  C.Target:=Vector3d(fComponent.CameraTargetX,fComponent.CameraTargetY,fComponent.CameraTargetZ);
  C.RollDegrees:=fComponent.CameraRoll;
  C.VerticalFovDegrees:=fComponent.CameraFov;
  SetCameraState(C);
  SetView(C.YawDegrees,C.PitchDegrees,C.Distance,
    fComponent.ShowAxes,LongWord(fComponent.BackgroundColor));
  FillChar(O,SizeOf(O),0);
  O.ShowAxes:=fComponent.ShowAxes;
  O.DrawFill:=fComponent.DrawFill;
  O.DrawWireframe:=fComponent.DrawWireframe;
  O.DrawPoints:=fComponent.DrawPoints;
  O.DrawNormals:=fComponent.DrawNormals;
  O.NormalLength:=fComponent.NormalLength;
  O.BackgroundColor:=LongWord(fComponent.BackgroundColor);
  O.PointColor.R:=Byte(fComponent.PointColor and $FF);
  O.PointColor.G:=Byte((fComponent.PointColor shr 8) and $FF);
  O.PointColor.B:=Byte((fComponent.PointColor shr 16) and $FF);
  { Until a persisted scene-light adapter is attached, use the renderer's
    neutral legacy-compatible light so imported meshes remain readable. }
  O.UseDefaultLighting := True;
  O.DefaultAmbient := 0.35;
  O.DefaultDiffuse := 0.75;
  O.DefaultLightDirection := Vector3d(0.35, 0.65, 1);
  SetRenderOptions(O);
  LoadConfiguredScene;
  ApplySceneEdits;
end;

procedure TRecorder3dView.ApplySceneEdits;
var
  I, lUpdated: Integer;
  Spec: T3dPrimitiveSpec;
begin
  if (Scene=nil) or (fComponent=nil) then
    Exit;
  for I := 0 to fComponent.RemovedNodeCount - 1 do
    Scene.RemoveNode(fComponent.RemovedNodeIds[I]);
  fComponent.ResolvePrimitiveNodeIdCollisions(Scene);
  for I := 0 to fComponent.PrimitiveCount - 1 do
  begin
    Spec := fComponent.Primitives[I];
    if Scene.FindNode(Spec.NodeId)=nil then
      Scene.AddNode(CreatePrimitiveNode(Spec));
  end;
  fComponent.MaterializeSkinHelpers(Scene);
  Scene.RebuildWorldTransforms(lUpdated);
  Scene.MarkBoundsDirty;
  MarkDirty;
end;

procedure TRecorder3dView.LoadConfiguredScene;
var N:string;
begin
  N:=ExpandFileName(fComponent.SceneFileName);
  if SameFileName(N,fLoadedFileName) then
    Exit;
  if (N='') or not FileExists(N) then
  begin
    ResetToDefaultScene;
    fLoadedFileName := '';
    if Recorder3dInteractionTraceEnabled then
      Recorder3dInteractionTrace(Format(
        'scene default reason=missing configured=%s active=%p',
        [N, Pointer(Scene)]));
    Exit;
  end;
  try
    LoadScene(N);
    fLoadedFileName:=N;
  except
    on E:Exception do
    begin
      { Transactional loader keeps the previous live scene on failure. }
      if Recorder3dInteractionTraceEnabled then
        Recorder3dInteractionTrace(Format(
          'scene load failed file=%s active=%p error=%s',
          [N, Pointer(Scene), E.Message]));
      Exit;
    end;
  end;
end;

procedure TRecorder3dView.ApplyComponentConfiguration;
var
  SceneTreeWasVisible:Boolean;
begin
  if (fComponent=nil) or (fBindings=nil) or (fFrfAdapter=nil) then
    Exit;
  if fSceneEditor<>nil then
    fSceneEditor.AttachLiveScene(nil,0);
  SceneTreeWasVisible:=(fSceneTreeDialog<>nil) and fSceneTreeDialog.Visible;
  if fSceneTreeDialog<>nil then
    fSceneTreeDialog.DetachScene;
  fFrfAdapter.Configure(nil,nil,[]);
  fFrfSink:=nil;
  { ApplyModel may replace and free the widget-owned scene. Detach every
    non-owning scene client before that lifetime boundary. }
  fSkinEngine.Configure(nil,[]);
  fSkinBindings.AttachScene(nil);
  fVertexColors.AttachScene(nil);
  fBindings.Configure(fComponent,fRegistry);
  fBindings.AttachScene(nil);
  ApplyModel;
  if fRegisteredPointTargetId<>'' then
    UnregisterRecorderModelPointTarget(fRegisteredPointTargetId);
  fImpactPointCatalog:=nil;
  fImpactBindingSink:=nil;
  fImpactBindingController:=nil;
  if (Scene<>nil) and (fComponent.Id<>'') then
  begin
    fImpactBindingController:=TRecorder3dImpactBindingController.Create(
      fComponent,Scene);
    fImpactBindingController.OnBindingsChanged:=@ImpactBindingsChanged;
    fImpactPointCatalog:=fImpactBindingController;
    fImpactBindingSink:=fImpactBindingController;
    fRegisteredPointTargetId:=fComponent.Id;
    RegisterRecorderModelPointTarget(fRegisteredPointTargetId,
      fImpactPointCatalog,fImpactBindingSink);
  end
  else
    fRegisteredPointTargetId:='';
  ApplyNodeRenderOverrides;
  ConfigureSkin;
  fVertexColors.Configure(fComponent,fRegistry);
  fVertexColors.AttachScene(Scene);
  UpdateValueLabels;
  fBindings.AttachScene(Scene);
  ConfigureFrf;
  if fSceneEditor<>nil then
    fSceneEditor.AttachLiveScene(Scene,SelectedNodeId);
  if SceneTreeWasVisible then
    fSceneTreeDialog.ShowEditor(Scene,fComponent,SelectedNodeId);
end;

procedure TRecorder3dView.ConfigureSkin;
var
  Influences:T3dSkinInfluences;
  I:Integer;
  Bone:TRecorder3dSkinBone;
  OwnerNode:T3dNode;
begin
  if fSkinEngine=nil then
    Exit;
  if (Scene=nil) or (fComponent=nil) then
  begin
    fSkinEngine.Configure(nil,[]);
    fSkinBindings.Configure(nil,nil);
    fSkinBindings.AttachScene(nil);
    Exit;
  end;
  fComponent.BuildSkinInfluences(Influences);
  for I:=0 to High(Influences) do
  begin
    Bone:=fComponent.FindSkinBone(Influences[I].HelperNodeId);
    if Bone=nil then Continue;
    OwnerNode:=Scene.FindNode(Bone.OwnerMeshNodeId);
    if OwnerNode<>nil then
      ComposeMatrices(OwnerNode.WorldTransform,Bone.BindLocalTransform,
        Influences[I].HelperBindWorld);
  end;
  fSkinEngine.Configure(Scene,Influences);
  fSkinBindings.Configure(fComponent,fRegistry);
  fSkinBindings.AttachScene(Scene);
  fSkinEngine.Apply;
  UpdateSelectedHelperOverlay;
end;

procedure TRecorder3dView.ApplyNodeRenderOverrides;
var
  I,lUpdated:Integer;
  R:TRecorder3dNodeRenderOverride;
  N:T3dNode;
begin
  if (Scene=nil) or (fComponent=nil) then
    Exit;
  for I:=0 to High(Scene.Nodes) do
    Scene.Nodes[I].HasRenderOverride:=False;
  for I:=0 to fComponent.NodeRenderOverrideCount-1 do
  begin
    R:=fComponent.NodeRenderOverrides[I];
    N:=Scene.FindNode(R.NodeId);
    if N=nil then
      Continue;
    if R.HasTransform then
      N.LocalTransform:=R.LocalTransform;
    if R.HasRenderSettings then
    begin
      N.HasRenderOverride:=True;
      N.DrawFillOverride:=R.DrawFill;
      N.DrawWireframeOverride:=R.DrawWireframe;
      N.DrawPointsOverride:=R.DrawPoints;
      N.DrawNormalsOverride:=R.DrawNormals;
    end;
  end;
  Scene.RebuildWorldTransforms(lUpdated);
  Scene.MarkBoundsDirty;
end;

procedure TRecorder3dView.ConfigureFrf;
var
  Engine:T3dSceneMotionEngine;
  Bindings:array of TRecorderFrfMotionBinding;
  Targets:array of QWord;
  I:Integer;
  F:TRecorder3dFrfBinding;
begin
  fFrfAdapter.Configure(nil,nil,[]);
  fFrfSink:=nil;
  if fFrfProvider=nil then
    fFrfProvider:=RecorderDefaultFrfProvider;
  fFrfFrequencyTag:=ResolveTag(fRegistry,fComponent.FrfFrequencyTagId,fComponent.FrfFrequencyTagName);
  fFrfAnimationPhaseTag:=ResolveTag(fRegistry,fComponent.FrfAnimationPhaseTagId,fComponent.FrfAnimationPhaseTagName);
  if (Scene=nil) or (fComponent.FrfBindingCount=0) or
    (fFrfProvider=nil) then
    Exit;
  Engine:=T3dSceneMotionEngine.Create;
  SetLength(Targets,fComponent.FrfBindingCount);
  SetLength(Bindings,fComponent.FrfBindingCount);
  for I:=0 to fComponent.FrfBindingCount-1 do
  begin
    F:=fComponent.FrfBindings[I];
    Targets[I]:=F.TargetNodeId;
    Bindings[I].CurveId:=F.CurveId;
    Bindings[I].TargetNodeId:=F.TargetNodeId;
    Bindings[I].Axis:=F.Axis;
    Bindings[I].Space:=F.Space;
    Bindings[I].Gain:=F.Gain;
    if (fImpactBindingController<>nil) and
      (F.SourceBindingId=fImpactBindingController.ActiveSourceBindingId) then
      Bindings[I].Gain:=Bindings[I].Gain *
        fImpactBindingController.AnimationScale;
    Bindings[I].Enabled:=F.Enabled;
  end;
  Engine.Configure(Scene,Targets);
  fFrfSink:=Engine;
  fFrfAdapter.ConfigureProvider(fFrfProvider,fFrfSink,Bindings);
end;

procedure TRecorder3dView.SetFrfProvider(
  const AProvider: IRecorderFrfProvider);
begin
  if fFrfProvider = AProvider then
    Exit;
  fFrfProvider := AProvider;
  if (fComponent <> nil) and (fFrfAdapter <> nil) then
    ConfigureFrf;
end;

procedure TRecorder3dView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  if not (AComponent is TRecorder3dComponent) then
    Exit;
  if (fComponent<>nil) and (fComponent<>AComponent) then
  begin
    FreeAndNil(fSceneTreeDialog);
    FreeAndNil(fSceneEditor);
  end;
  fComponent := TRecorder3dComponent(AComponent);
  fRegistry := ATagRegistry;
  if fSceneEditor<>nil then
    fSceneEditor.UpdateContext(fComponent,fRegistry);
  ApplyComponentConfiguration;
end;

procedure TRecorder3dView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lBatch: TRecorder3dUpdateBatch;
  lMask: T3dPositionComponents;
  lFrequency:Double;
  lPhase:Double;
  lHasBatch,lSkinChanged:Boolean;
  lColorChanged:Boolean;
  lNow:QWord;
begin
  if ATagRegistry<>fRegistry then
  begin
    Configure(fComponent,ATagRegistry);
    Exit;
  end;
  lHasBatch:=fBindings.Collect(lBatch);
  lSkinChanged:=(fSkinBindings<>nil) and fSkinBindings.ApplyChanged;
  lColorChanged:=(fVertexColors<>nil) and fVertexColors.ApplyChanged;
  if lColorChanged then
  begin
    UpdateValueLabels;
    MarkDirty;
  end;
  if lHasBatch and (lBatch.TranslationMask <> []) then
  begin
    lMask := [];
    if r3aX in lBatch.TranslationMask then
      Include(lMask, pcX);
    if r3aY in lBatch.TranslationMask then
      Include(lMask, pcY);
    if r3aZ in lBatch.TranslationMask then
      Include(lMask, pcZ);
    SetNodeTranslation(lBatch.TargetNodeId, lBatch.Translation, lMask);
    lSkinChanged:=lSkinChanged or (fComponent.SkinBindingCount>0);
  end;
  if lHasBatch and lBatch.HasColor and (fBindings.TargetNode <> nil) then
  begin
    fBindings.TargetNode.HasColorOverride := True;
    fBindings.TargetNode.ColorOverride := lBatch.Color;
    MarkDirty;
  end;
  if lHasBatch and lBatch.HasNormalLength then
    SetRuntimeNormalLength(lBatch.NormalLength);
  if fFrfProvider<>nil then
  begin
    lFrequency:=fComponent.FrfFrequencyHz;
    lPhase:=fComponent.FrfAnimationPhaseRadians;
    if fFrfFrequencyTag<>nil then
      lFrequency:=fFrfFrequencyTag.SignalBuffer.LatestValue;
    if fFrfAnimationPhaseTag<>nil then
      lPhase:=fFrfAnimationPhaseTag.SignalBuffer.LatestValue;
    if (fImpactBindingController<>nil) and
      fImpactBindingController.AnimationPlaying then
    begin
      lNow:=GetTickCount64;
      if fAnimationTick<>0 then
        fImpactBindingController.Advance((lNow-fAnimationTick)/1000);
      fAnimationTick:=lNow;
      lFrequency:=fImpactBindingController.AnimationFrequencyHz;
      lPhase:=fImpactBindingController.AnimationPhase;
    end
    else
      fAnimationTick:=0;
    if not IsNan(lFrequency) and not IsInfinite(lFrequency) and
      not IsNan(lPhase) and not IsInfinite(lPhase) and
      fFrfAdapter.Update(lFrequency,lPhase) then
    begin
      lSkinChanged:=lSkinChanged or (fComponent.SkinBindingCount>0);
      MarkDirty;
    end;
  end;
  if lSkinChanged and (fSkinEngine<>nil) and (fComponent<>nil) and
    (fComponent.SkinBindingCount>0) then
  begin
    fSkinEngine.Apply;
    UpdateValueLabels;
    MarkDirty;
  end;
end;

function TRecorder3dView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorder3dComponent,
    TRecorder3dView);

end.
