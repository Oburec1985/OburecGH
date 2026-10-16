unit uRecorder3dView;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Live Recorder host for the reusable 3D widget. The visual-control registry
  creates it for TRecorder3dComponent; Configure projects persistent settings
  into the scene and RefreshControl applies cached tag and FRF updates. The
  view owns its adapters and UI controls, while Recorder owns model and tags. }

interface

uses
  Classes, SysUtils, Math, Types, Controls, Graphics, ExtCtrls, StdCtrls, Buttons, Menus, Forms, ComCtrls, ImgList, LMessages, LCLType, Messages,
  uOglChart, u3dCoreTypes, u3dContracts, u3dScene, u3dSceneMath, u3dGeometryMath, u3dInteractionTypes,
  u3dGizmo, u3dLclWidget, u3dMeshTopology, u3dScreenGeometryMath,
  u3dPrimitives, u3dTransforms, u3dSkin,
  uRecorderFormModel, uRecorderTags,
  uRecorderVisualControl, uRecorder3dModel, uRecorder3dBindingAdapter,
  uRecorder3dSceneTreeDialog, uRecorder3dSettingsDialog,
  uRecorderCommandImages, uRcIconIds, u3dMotionContracts, u3dSceneMotionEngine,
  uRecorderFrfContracts, uRecorderFrfMotionAdapter,
  uRecorderFrfIntensityAdapter,
  uRecorder3dInteractionTrace, uRecorderImpactHammerContracts,
  uRecorder3dImpactBindingController, uRecorder3dSkinBindingAdapter,
  uRecorder3dVertexColorAdapter;

type
  TRecorder3dOverlayText = class(TStaticText)
  protected
    procedure WndProc(var Message:TMessage); override;
  end;

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
    fFrfIntensity: TRecorderFrfIntensityAdapter;
    fGeometryDemo:TRecorderFrfIntensityAdapter;
    fGeometryDemoRevision:QWord;
    fIntensityTimer:TTimer;
    fIntensityPlay:TSpeedButton;
    fIntensityPhase:Double;
    fIntensityLastTick:QWord;
    fIntensityFrequency:Double;
    fSkinEngine:T3dSkinEngine;
    fSkinBindings:TRecorder3dSkinBindingAdapter;
    fVertexColors:TRecorder3dVertexColorAdapter;
    fValueLabels:TRecorder3dVertexValueLabels;
    fOverlayCanvas:TControlCanvas;
    fHelperNameLabels:array of TRecorder3dOverlayText;
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
    procedure EditorGeometryChanged(Sender:TObject);
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
    procedure IntensityPlayClick(Sender:TObject);
    procedure IntensityTimerTick(Sender:TObject);
    procedure DrawIntensityMarkers;
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
    procedure DrawHelperLabels;
    procedure DrawPointNumberLabels;
    function ResolveMarkerPosition(var AMarker:TRecorderIntensityMarker):Boolean;
    function SceneLabelFontSize:Integer;
    function FrfPointHasLabel(ANodeId:QWord; APointNumber:Integer):Boolean;
    procedure DrawOverlayLabel(const AText:string;
      const APosition:T3dVector; AFontColor,ABoxColor:TColor;
      AOffsetX,AOffsetY:Integer);
    procedure DrawOverlayText(const AText:string;
      const APosition:T3dVector; AFontColor:TColor; AOffsetX,AOffsetY:Integer);
    procedure ClearValueLabels;
    procedure ApplyComponentConfiguration;
    procedure SetEditMode(AValue:Boolean);
    procedure TraceInteraction(const AMessage:string);
    procedure ImpactBindingsChanged(Sender:TObject);
  protected
    procedure Paint; override;
    procedure DrawFrameOverlay; override;
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
uses gl;

procedure DrawScreenText(const AText:string; X,Y,AWidth,AHeight:Integer;
  AColor:TColor; AFontSize:Integer);
var
  Bitmap:TBitmap;
  Pixels:array of Byte;
  W,H,I,J,K:Integer;
  C,Ink:LongInt;
begin
  Bitmap:=TBitmap.Create;
  try
    Bitmap.Canvas.Font.Name:='Tahoma';
    Bitmap.Canvas.Font.Size:=AFontSize;
    W:=Max(1,Bitmap.Canvas.TextWidth(AText));
    H:=Max(1,Bitmap.Canvas.TextHeight(AText));
    Bitmap.SetSize(W,H);
    Bitmap.Canvas.Brush.Color:=clWhite;
    Bitmap.Canvas.FillRect(Rect(0,0,W,H));
    Bitmap.Canvas.Font.Color:=clBlack;
    Bitmap.Canvas.TextOut(0,0,AText);
    SetLength(Pixels,W*H*4);
    C:=ColorToRGB(AColor);
    for J:=0 to H-1 do
      for I:=0 to W-1 do
      begin
        K:=((H-1-J)*W+I)*4;
        Ink:=ColorToRGB(Bitmap.Canvas.Pixels[I,J]) and $FF;
        Pixels[K]:=C and $FF;
        Pixels[K+1]:=(C shr 8) and $FF;
        Pixels[K+2]:=(C shr 16) and $FF;
        Pixels[K+3]:=255-Ink;
      end;
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    glDisable(GL_DEPTH_TEST); glDisable(GL_LIGHTING);
    glEnable(GL_BLEND); glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    glMatrixMode(GL_PROJECTION); glPushMatrix; glLoadIdentity;
    glOrtho(0,Max(1,AWidth),0,Max(1,AHeight),-1,1);
    glMatrixMode(GL_MODELVIEW); glPushMatrix; glLoadIdentity;
    glRasterPos2i(0,0);
    glBitmap(0,0,0,0,X,AHeight-Y-H,nil);
    glDrawPixels(W,H,GL_RGBA,GL_UNSIGNED_BYTE,@Pixels[0]);
    glPopMatrix;
    glMatrixMode(GL_PROJECTION); glPopMatrix;
    glMatrixMode(GL_MODELVIEW);
    glPopAttrib;
  finally Bitmap.Free end;
end;

procedure TRecorder3dOverlayText.WndProc(var Message:TMessage);
begin
  if Message.Msg=LM_NCHITTEST then
  begin
    Message.Result:=HTTRANSPARENT;
    Exit;
  end;
  inherited WndProc(Message);
end;

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
  fFrfIntensity := TRecorderFrfIntensityAdapter.Create;
  fGeometryDemo := TRecorderFrfIntensityAdapter.Create;
  fIntensityFrequency:=-1;
  fIntensityTimer:=TTimer.Create(Self);
  fIntensityTimer.Interval:=33;
  fIntensityTimer.OnTimer:=@IntensityTimerTick;
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
  fIntensityTimer.Enabled:=False;
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
  fFrfIntensity.Free;
  fGeometryDemo.Free;
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
begin
  if Length(fValueLabels)=0 then
    Exit;
  if fOverlayCanvas=nil then
    Exit;
  fOverlayCanvas.Font.Name:='Tahoma';
  fOverlayCanvas.Font.Size:=SceneLabelFontSize;
  for I:=0 to High(fValueLabels) do
    DrawOverlayLabel(fValueLabels[I].Text,fValueLabels[I].Position,
      clWhite,$00504030,8,0);
end;

procedure TRecorder3dView.DrawHelperLabels;
var
  I:Integer;
  Bone:TRecorder3dSkinBone;
  Node:T3dNode;
  Position:T3dVector;
  ScreenPoint:T3dPoint;
  Viewport:T3dViewport;
  Depth:Single;
  LabelControl:TRecorder3dOverlayText;
  NewLeft,NewTop:Integer;

  procedure HideLabel(AIndex:Integer);
  begin
    if fHelperNameLabels[AIndex].Visible then
      fHelperNameLabels[AIndex].Visible:=False;
  end;
begin
  if (fOverlayCanvas=nil) or (fComponent=nil) or (Scene=nil) then
    Exit;
  if Length(fHelperNameLabels)<fComponent.SkinBoneCount then
  begin
    SetLength(fHelperNameLabels,fComponent.SkinBoneCount);
    for I:=0 to High(fHelperNameLabels) do
      if fHelperNameLabels[I]=nil then
      begin
        fHelperNameLabels[I]:=TRecorder3dOverlayText.Create(Self);
        fHelperNameLabels[I].Parent:=Self;
        fHelperNameLabels[I].AutoSize:=True;
        fHelperNameLabels[I].BorderStyle:=sbsNone;
        fHelperNameLabels[I].Transparent:=False;
        fHelperNameLabels[I].Color:=$00402A10;
        fHelperNameLabels[I].Font.Name:='Tahoma';
        fHelperNameLabels[I].Font.Size:=SceneLabelFontSize;
        fHelperNameLabels[I].Font.Color:=$0000A5FF;
        fHelperNameLabels[I].ShowAccelChar:=False;
      end;
  end;
  Viewport.Width:=ClientWidth;
  Viewport.Height:=ClientHeight;
  for I:=0 to fComponent.SkinBoneCount-1 do
  begin
    Bone:=fComponent.SkinBones[I];
    if Bone.Name='' then
    begin
      HideLabel(I);
      Continue;
    end;
    Node:=Scene.FindNode(Bone.HelperNodeId);
    if Node=nil then
    begin
      HideLabel(I);
      Continue;
    end;
    Position.X:=Node.WorldTransform[12];
    Position.Y:=Node.WorldTransform[13];
    Position.Z:=Node.WorldTransform[14];
    if not ProjectWorldToScreen(Position,CurrentOrbitCamera,Viewport,
      ScreenPoint,Depth) then
    begin
      HideLabel(I);
      Continue;
    end;
    LabelControl:=fHelperNameLabels[I];
    if LabelControl.Font.Size<>SceneLabelFontSize then
      LabelControl.Font.Size:=SceneLabelFontSize;
    if LabelControl.Caption<>Bone.Name then
      LabelControl.Caption:=Bone.Name;
    NewLeft:=Round(ScreenPoint.X)+10;
    NewTop:=Round(ScreenPoint.Y)-12;
    if (LabelControl.Left<>NewLeft) or (LabelControl.Top<>NewTop) then
      LabelControl.SetBounds(NewLeft,NewTop,LabelControl.Width,
        LabelControl.Height);
    if not LabelControl.Visible then
      LabelControl.Visible:=True;
  end;
  { Do not blanket-hide/re-show these child windows on each OpenGL paint.
    Visibility changes invalidate native children and used to form a repaint
    storm while the parent was still in its Paint handler. }
  for I:=fComponent.SkinBoneCount to High(fHelperNameLabels) do
    if fHelperNameLabels[I].Visible then
      fHelperNameLabels[I].Visible:=False;
end;

function TRecorder3dView.SceneLabelFontSize:Integer;
begin
  Result:=8;
  if fComponent<>nil then Result:=EnsureRange(fComponent.LabelFontSize,4,48);
end;

function TRecorder3dView.FrfPointHasLabel(ANodeId:QWord;
  APointNumber:Integer):Boolean;
var lIndex:Integer; lBinding:TRecorder3dFrfBinding;
begin
  Result:=False;
  if fComponent=nil then Exit;
  for lIndex:=0 to fComponent.FrfBindingCount-1 do
  begin
    lBinding:=fComponent.FrfBindings[lIndex];
    if lBinding.Enabled and (lBinding.ModifierTargetNodeId=ANodeId) and
      (lBinding.PointNumber=APointNumber) then Exit(True);
  end;
end;

procedure TRecorder3dView.DrawPointNumberLabels;
const
  CMaxLabelAttempts=1000;
var
  I,J,CornerIndex,Stride,AttemptCount,Columns,Rows,CellIndex:Integer;
  Spec:T3dPrimitiveSpec;
  Node:T3dNode;
  Mesh:T3dMeshData;
  Point:T3dVector;
  Viewport:T3dViewport;
  ScreenPoint:T3dPoint;
  Depth:Single;
  Occupied:array of Boolean;
  CellWidth,CellHeight:Integer;
begin
  if (fOverlayCanvas=nil) or (fComponent=nil) or (Scene=nil) or
    (ClientWidth<=0) or (ClientHeight<=0) then Exit;
  for I:=0 to fComponent.FrfBindingCount-1 do
    if fComponent.FrfBindings[I].Enabled and
      fComponent.FrfBindings[I].OnlySensors then Exit;
  CellWidth:=Max(28,SceneLabelFontSize*4);
  CellHeight:=Max(20,SceneLabelFontSize*2+4);
  Columns:=(ClientWidth+CellWidth-1) div CellWidth;
  Rows:=(ClientHeight+CellHeight-1) div CellHeight;
  SetLength(Occupied,Columns*Rows);
  Viewport.Width:=ClientWidth;
  Viewport.Height:=ClientHeight;
  fOverlayCanvas.Font.Name:='Tahoma';
  fOverlayCanvas.Font.Size:=SceneLabelFontSize;
  for I:=0 to fComponent.PrimitiveCount-1 do
  begin
    Spec:=fComponent.Primitives[I];
    if (Spec.Kind<>pkPointCloud) or not Spec.DrawPointNumbers then Continue;
    Node:=Scene.FindNode(Spec.NodeId);
    if (Node=nil) or (Node.Mesh=nil) then Continue;
    Mesh:=Node.Mesh;
    Stride:=Max(1,(Length(Mesh.LogicalVertices)+CMaxLabelAttempts-1) div
      CMaxLabelAttempts);
    AttemptCount:=0;
    J:=0;
    while (AttemptCount<CMaxLabelAttempts) and
      (J<Length(Mesh.LogicalVertices)) do
    begin
      if Length(Mesh.LogicalVertices[J].CornerIndices)>0 then
      begin
        CornerIndex:=Mesh.LogicalVertices[J].CornerIndices[0];
        if CornerIndex<Length(Mesh.Positions) then
        begin
          Point:=TransformPoint(Mesh.Positions[CornerIndex],Node.WorldTransform);
          if ProjectWorldToScreen(Point,CurrentOrbitCamera,Viewport,ScreenPoint,
            Depth) and (ScreenPoint.X>=0) and (ScreenPoint.X<ClientWidth) and
            (ScreenPoint.Y>=0) and (ScreenPoint.Y<ClientHeight) then
          begin
            CellIndex:=(Trunc(ScreenPoint.Y) div CellHeight)*Columns+
              (Trunc(ScreenPoint.X) div CellWidth);
            if not Occupied[CellIndex] then
            begin
              Occupied[CellIndex]:=True;
              if not FrfPointHasLabel(Node.Id,J+1) then
                DrawOverlayText(IntToStr(J+1),Point,clBlack,8,-8);
            end;
          end;
        end;
      end;
      Inc(AttemptCount);
      Inc(J,Stride);
    end;
  end;
end;

procedure TRecorder3dView.DrawOverlayText(const AText:string;
  const APosition:T3dVector; AFontColor:TColor; AOffsetX,AOffsetY:Integer);
var
  Viewport:T3dViewport;
  ScreenPoint:T3dPoint;
  Depth:Single;
  X,Y:Integer;
begin
  if (fOverlayCanvas=nil) or (AText='') then Exit;
  Viewport.Width:=ClientWidth;
  Viewport.Height:=ClientHeight;
  if not ProjectWorldToScreen(APosition,CurrentOrbitCamera,Viewport,
    ScreenPoint,Depth) then Exit;
  X:=Round(ScreenPoint.X)+AOffsetX;
  Y:=Round(ScreenPoint.Y)+AOffsetY;
  DrawScreenText(AText,X+1,Y+1,ClientWidth,ClientHeight,clWhite,SceneLabelFontSize);
  DrawScreenText(AText,X,Y,ClientWidth,ClientHeight,AFontColor,SceneLabelFontSize);
end;

procedure TRecorder3dView.DrawOverlayLabel(const AText:string;
  const APosition:T3dVector; AFontColor,ABoxColor:TColor;
  AOffsetX,AOffsetY:Integer);
var
  Viewport:T3dViewport;
  ScreenPoint:T3dPoint;
  Depth:Single;
  TextSize:TSize;
  X,Y:Integer;
begin
  if (fOverlayCanvas=nil) or (AText='') then
    Exit;
  Viewport.Width:=ClientWidth;
  Viewport.Height:=ClientHeight;
  if not ProjectWorldToScreen(APosition,CurrentOrbitCamera,Viewport,
    ScreenPoint,Depth) then
    Exit;
  TextSize:=fOverlayCanvas.TextExtent(AText);
  X:=Round(ScreenPoint.X)+AOffsetX;
  Y:=Round(ScreenPoint.Y)-TextSize.cy div 2+AOffsetY;
  DrawScreenText(AText,X,Y,ClientWidth,ClientHeight,AFontColor,SceneLabelFontSize);
end;

procedure TRecorder3dView.Paint;
begin
  inherited Paint;
  { Graphic LCL children are erased by SwapBuffers on TOpenGLControl. Draw the
    fixed-pixel overlays on the same front surface after the 3D frame. }
  DrawHelperLabels;
end;

procedure TRecorder3dView.DrawFrameOverlay;
var I:Integer; P:T3dVector; S:T3dPoint; D:Single; V:T3dViewport;
begin
  DrawIntensityMarkers;
  if Scene<>nil then
  begin
    V.Width:=ClientWidth; V.Height:=ClientHeight;
    for I:=0 to Scene.LabelCount-1 do
      if Scene.ResolveLabelPosition(Scene.Labels[I],P) and
         ProjectWorldToScreen(P,CurrentOrbitCamera,V,S,D) then
        DrawScreenText(Scene.Labels[I].Text,Round(S.X)+8,Round(S.Y)-8,
          ClientWidth,ClientHeight,clBlack,SceneLabelFontSize);
  end;
  DrawValueLabels;
  DrawPointNumberLabels;
end;

procedure TRecorder3dView.ImpactBindingsChanged(Sender:TObject);
begin
  ConfigureFrf;
  if fVertexColors<>nil then
  begin
    fVertexColors.Configure(fComponent,fRegistry);
    fVertexColors.AttachScene(Scene);
    fVertexColors.ConfigureFrfProvider(fFrfProvider);
    fVertexColors.ApplyChanged;
  end;
  MarkDirty;
end;

procedure TRecorder3dView.IntensityPlayClick(Sender:TObject);
begin
  fIntensityLastTick:=GetTickCount64;
  fIntensityFrequency:=-1;
  IntensityTimerTick(Self);
end;

procedure TRecorder3dView.IntensityTimerTick(Sender:TObject);
var lNow:QWord; lFrequency:Double;
  lDemo:TRecorderModelPointBinding;
  lRevision:QWord;
  lHasDemo:Boolean;
begin
  if (fComponent=nil) or (fFrfIntensity=nil) or (fIntensityPlay=nil) then Exit;
  lHasDemo:=GetRecorderGeometryPreview(fComponent.Id,lDemo,lRevision);
  if lRevision<>fGeometryDemoRevision then
  begin
    fGeometryDemoRevision:=lRevision;
    if lHasDemo then fGeometryDemo.Demonstrate(Scene,lDemo)
    else fGeometryDemo.Configure(nil,nil,[]);
    MarkDirty;
  end;
  lFrequency:=RecorderSelectedFrfFrequency;
  lNow:=GetTickCount64;
  if fIntensityPlay.Down then
  begin
    if fIntensityLastTick<>0 then
      fIntensityPhase:=Frac((fIntensityPhase+
        (lNow-fIntensityLastTick)*2*Pi/1000)/(2*Pi))*2*Pi;
  end
  else if lFrequency=fIntensityFrequency then Exit;
  fIntensityLastTick:=lNow;
  fIntensityFrequency:=lFrequency;
  if fFrfIntensity.Update(lFrequency,fIntensityPhase,fIntensityPlay.Down) then
    MarkDirty;
end;

function TRecorder3dView.ResolveMarkerPosition(
  var AMarker:TRecorderIntensityMarker):Boolean;
var
  lNode:T3dNode;
  lPoint:Integer;
begin
  Result:=False;
  if Scene=nil then Exit;
  lNode:=Scene.FindNode(AMarker.TargetNodeId);
  if lNode=nil then Exit;
  if lNode.Mesh=nil then
    AMarker.Position:=Vector3d(lNode.WorldTransform[12],
      lNode.WorldTransform[13],lNode.WorldTransform[14])
  else
  begin
    lPoint:=AMarker.PointNumber-1;
    if (lPoint<0) or (lPoint>=Length(lNode.Mesh.LogicalVertices)) then Exit;
    if Length(lNode.Mesh.LogicalVertices[lPoint].CornerIndices)=0 then Exit;
    lPoint:=lNode.Mesh.LogicalVertices[lPoint].CornerIndices[0];
    if lPoint>=Length(lNode.Mesh.Positions) then Exit;
    AMarker.Position:=TransformPoint(lNode.Mesh.Positions[lPoint],
      lNode.WorldTransform);
  end;
  Result:=True;
end;

procedure TRecorder3dView.DrawIntensityMarkers;
var lIndex,lSegment:Integer; lMarker:TRecorderIntensityMarker;
  lViewport:T3dViewport; lPoint,lEnd:T3dPoint; lDepth:Single;
  lWorldEnd:T3dVector; lRadius,lAngle,lDx,lDy,lLength:Double;
begin
  if fFrfIntensity=nil then Exit;
  lViewport.Width:=ClientWidth;
  lViewport.Height:=ClientHeight;
  glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_LINE_BIT or GL_COLOR_BUFFER_BIT);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  glDisable(GL_TEXTURE_2D);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;
  glOrtho(0,ClientWidth,ClientHeight,0,-1,1);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
  for lIndex:=0 to fFrfIntensity.MarkerCount+fGeometryDemo.MarkerCount-1 do
  begin
    if lIndex<fFrfIntensity.MarkerCount then
      lMarker:=fFrfIntensity.Marker(lIndex)
    else lMarker:=fGeometryDemo.Marker(lIndex-fFrfIntensity.MarkerCount);
    if not lMarker.Visible then Continue;
    if not ResolveMarkerPosition(lMarker) then Continue;
    if not ProjectWorldToScreen(lMarker.Position,CurrentOrbitCamera,lViewport,
      lPoint,lDepth) then Continue;
    if not lMarker.DrawSymbol or (lMarker.SizePixels<0.5) then Continue;
    glColor3ub(lMarker.Color and $FF,(lMarker.Color shr 8) and $FF,
      (lMarker.Color shr 16) and $FF);
    if lMarker.Visualization=rpvSphere then
    begin
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
      glColor4f((lMarker.Color and $FF)/255,
        ((lMarker.Color shr 8) and $FF)/255,
        ((lMarker.Color shr 16) and $FF)/255,0.5);
      lRadius:=lMarker.SizePixels*0.5;
      glBegin(GL_TRIANGLE_FAN);
      glVertex2f(lPoint.X,lPoint.Y);
      for lSegment:=0 to 32 do
      begin
        lAngle:=lSegment*2*Pi/32;
        glVertex2f(lPoint.X+Cos(lAngle)*lRadius,
          lPoint.Y+Sin(lAngle)*lRadius);
      end;
      glEnd;
      glDisable(GL_BLEND);
    end
    else
    begin
      lWorldEnd:=lMarker.Position;
      case lMarker.Axis of
        maxisX:lWorldEnd.X:=lWorldEnd.X+1;
        maxisY:lWorldEnd.Y:=lWorldEnd.Y+1;
        maxisZ:lWorldEnd.Z:=lWorldEnd.Z+1;
      end;
      if not ProjectWorldToScreen(lWorldEnd,CurrentOrbitCamera,lViewport,
        lEnd,lDepth) then Continue;
      lDx:=lEnd.X-lPoint.X; lDy:=lEnd.Y-lPoint.Y;
      lLength:=Sqrt(Sqr(lDx)+Sqr(lDy));
      if lLength<0.001 then Continue;
      lDx:=lDx/lLength; lDy:=lDy/lLength;
      lEnd.X:=lPoint.X+lDx*lMarker.SizePixels;
      lEnd.Y:=lPoint.Y+lDy*lMarker.SizePixels;
      glLineWidth(2);
      glBegin(GL_LINES);
      glVertex2f(lPoint.X,lPoint.Y); glVertex2f(lEnd.X,lEnd.Y);
      glVertex2f(lEnd.X,lEnd.Y);
      glVertex2f(lEnd.X-lDx*4+lDy*3,lEnd.Y-lDy*4-lDx*3);
      glVertex2f(lEnd.X,lEnd.Y);
      glVertex2f(lEnd.X-lDx*4-lDy*3,lEnd.Y-lDy*4+lDx*3);
      glEnd;
    end;
  end;
  glPopMatrix;
  glMatrixMode(GL_PROJECTION);
  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glPopAttrib;
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
  fIntensityPlay:=TSpeedButton.Create(fToolbar);
  fIntensityPlay.Name:='btnIntensityAnimation';
  fIntensityPlay.Parent:=fToolbar;
  fIntensityPlay.SetBounds(238,3,44,42);
  fIntensityPlay.Images:=Images;
  fIntensityPlay.ImageIndex:=CIconRunWp;
  fIntensityPlay.ShowHint:=True;
  fIntensityPlay.Hint:='Анимация интенсивности на выбранной частоте';
  fIntensityPlay.GroupIndex:=19;
  fIntensityPlay.AllowAllUp:=True;
  fIntensityPlay.OnClick:=@IntensityPlayClick;
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
    fSceneEditor.OnGeometryChanged:=@EditorGeometryChanged;
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

procedure TRecorder3dView.EditorGeometryChanged(Sender:TObject);
begin
  { The editor replaced only mesh data. Refresh evaluators which cache that
    data without reattaching the scene or rebuilding its selection tree. }
  ConfigureSkin;
  fVertexColors.Configure(fComponent,fRegistry);
  fVertexColors.AttachScene(Scene);
  UpdateValueLabels;
  MarkDirty;
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
    SetView(Camera.Distance,
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
  fComponent.CameraDistance := Camera.Distance;
  fComponent.CameraTargetX:=Camera.Target.X;
  fComponent.CameraTargetY:=Camera.Target.Y;
  fComponent.CameraTargetZ:=Camera.Target.Z;
  fComponent.CameraForwardX:=Camera.Forward.X;
  fComponent.CameraForwardY:=Camera.Forward.Y;
  fComponent.CameraForwardZ:=Camera.Forward.Z;
  fComponent.CameraRightX:=Camera.Right.X;
  fComponent.CameraRightY:=Camera.Right.Y;
  fComponent.CameraRightZ:=Camera.Right.Z;
  fComponent.CameraUpX:=Camera.Up.X;
  fComponent.CameraUpY:=Camera.Up.Y;
  fComponent.CameraUpZ:=Camera.Up.Z;
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
  C.Distance:=fComponent.CameraDistance;
  C.Target:=Vector3d(fComponent.CameraTargetX,fComponent.CameraTargetY,fComponent.CameraTargetZ);
  C.Forward:=Vector3d(fComponent.CameraForwardX,fComponent.CameraForwardY,
    fComponent.CameraForwardZ);
  C.Right:=Vector3d(fComponent.CameraRightX,fComponent.CameraRightY,
    fComponent.CameraRightZ);
  C.Up:=Vector3d(fComponent.CameraUpX,fComponent.CameraUpY,
    fComponent.CameraUpZ);
  C.VerticalFovDegrees:=fComponent.CameraFov;
  SetCameraState(C);
  SetView(C.Distance,
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
  fFrfIntensity.Configure(nil,nil,[]);
  fGeometryDemo.Configure(nil,nil,[]);
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
  I,lUpdated,PrimitiveIndex:Integer;
  R:TRecorder3dNodeRenderOverride;
  N:T3dNode;
  Spec:T3dPrimitiveSpec;
begin
  if (Scene=nil) or (fComponent=nil) then
    Exit;
  for I:=0 to High(Scene.Nodes) do
  begin
    N:=Scene.Nodes[I];
    N.HasRenderOverride:=False;
    PrimitiveIndex:=fComponent.FindPrimitiveIndex(N.Id);
    if PrimitiveIndex>=0 then
    begin
      Spec:=fComponent.Primitives[PrimitiveIndex];
      if Spec.Kind=pkPointCloud then
      begin
        N.HasRenderOverride:=True;
        N.DrawFillOverride:=False;
        N.DrawWireframeOverride:=True;
        N.DrawPointsOverride:=True;
        N.DrawNormalsOverride:=False;
        N.DrawBoundsOverride:=True;
        N.HasColorOverride:=True;
        N.ColorOverride.R:=Byte(fComponent.PointColor and $FF);
        N.ColorOverride.G:=Byte((fComponent.PointColor shr 8) and $FF);
        N.ColorOverride.B:=Byte((fComponent.PointColor shr 16) and $FF);
      end;
    end;
  end;
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
  IntensityBindings:array of TRecorderFrfIntensityBinding;
  Targets:array of QWord;
  I,MotionCount,IntensityCount:Integer;
  F:TRecorder3dFrfBinding;
begin
  fIntensityFrequency:=-1;
  fFrfAdapter.Configure(nil,nil,[]);
  fFrfIntensity.Configure(nil,nil,[]);
  fFrfSink:=nil;
  if fFrfProvider=nil then
    fFrfProvider:=RecorderDefaultFrfProvider;
  if fVertexColors<>nil then fVertexColors.ConfigureFrfProvider(fFrfProvider);
  fFrfFrequencyTag:=ResolveTag(fRegistry,fComponent.FrfFrequencyTagId,fComponent.FrfFrequencyTagName);
  fFrfAnimationPhaseTag:=ResolveTag(fRegistry,fComponent.FrfAnimationPhaseTagId,fComponent.FrfAnimationPhaseTagName);
  if (Scene=nil) or (fComponent.FrfBindingCount=0) or
    (fFrfProvider=nil) then
    Exit;
  SetLength(Targets,fComponent.FrfBindingCount);
  SetLength(Bindings,fComponent.FrfBindingCount);
  SetLength(IntensityBindings,fComponent.FrfBindingCount);
  MotionCount:=0;
  IntensityCount:=0;
  for I:=0 to fComponent.FrfBindingCount-1 do
  begin
    F:=fComponent.FrfBindings[I];
    if F.Mode=rgbmIntensity then
    begin
      IntensityBindings[IntensityCount].CurveId:=F.CurveId;
      IntensityBindings[IntensityCount].TargetNodeId:=F.ModifierTargetNodeId;
      IntensityBindings[IntensityCount].Gain:=F.Gain;
      IntensityBindings[IntensityCount].Color:=F.Color;
      IntensityBindings[IntensityCount].PointNumber:=F.PointNumber;
      IntensityBindings[IntensityCount].MarkerSizePixels:=F.MarkerSizePixels;
      IntensityBindings[IntensityCount].IntensitySource:=F.IntensitySource;
      IntensityBindings[IntensityCount].Visualization:=F.Visualization;
      IntensityBindings[IntensityCount].Axis:=F.Axis;
      IntensityBindings[IntensityCount].BandRms:=F.BandRms;
      IntensityBindings[IntensityCount].BandTolerancePercent:=F.BandTolerancePercent;
      IntensityBindings[IntensityCount].GradientEnabled:=F.GradientEnabled;
      IntensityBindings[IntensityCount].PointLabel:=F.PointLabel;
      if IntensityBindings[IntensityCount].PointLabel='' then
        IntensityBindings[IntensityCount].PointLabel:=IntToStr(F.PointNumber);
      IntensityBindings[IntensityCount].HideAnchors:=F.HideAnchors;
      IntensityBindings[IntensityCount].EnvelopeXEnabled:=F.EnvelopeXEnabled;
      IntensityBindings[IntensityCount].EnvelopeYEnabled:=F.EnvelopeYEnabled;
      IntensityBindings[IntensityCount].EnvelopeZEnabled:=F.EnvelopeZEnabled;
      IntensityBindings[IntensityCount].EnvelopeX:=F.EnvelopeX;
      IntensityBindings[IntensityCount].EnvelopeY:=F.EnvelopeY;
      IntensityBindings[IntensityCount].EnvelopeZ:=F.EnvelopeZ;
      IntensityBindings[IntensityCount].Enabled:=F.Enabled and
        (F.ModifierTargetNodeId<>0);
      Inc(IntensityCount);
    end
    else if not F.IntensityOnly then
    begin
      Targets[MotionCount]:=F.TargetNodeId;
      Bindings[MotionCount].CurveId:=F.CurveId;
      Bindings[MotionCount].TargetNodeId:=F.TargetNodeId;
      Bindings[MotionCount].Axis:=F.Axis;
      Bindings[MotionCount].Space:=F.Space;
      Bindings[MotionCount].Gain:=F.Gain;
      if (fImpactBindingController<>nil) and
        (F.SourceBindingId=fImpactBindingController.ActiveSourceBindingId) then
        Bindings[MotionCount].Gain:=Bindings[MotionCount].Gain *
          fImpactBindingController.AnimationScale;
      Bindings[MotionCount].Enabled:=F.Enabled;
      Inc(MotionCount);
    end;
  end;
  SetLength(Targets,MotionCount);
  SetLength(Bindings,MotionCount);
  SetLength(IntensityBindings,IntensityCount);
  if MotionCount>0 then
  begin
    Engine:=T3dSceneMotionEngine.Create;
    Engine.Configure(Scene,Targets);
    fFrfSink:=Engine;
    fFrfAdapter.ConfigureProvider(fFrfProvider,fFrfSink,Bindings);
  end;
  fFrfIntensity.Configure(fFrfProvider,Scene,IntensityBindings);
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
      RecorderTryReadScalarValue(fFrfFrequencyTag,True,tekMean,lFrequency);
    if fFrfAnimationPhaseTag<>nil then
      RecorderTryReadScalarValue(fFrfAnimationPhaseTag,True,tekMean,lPhase);
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
    if (fFrfIntensity<>nil) and fFrfIntensity.Update(
      RecorderSelectedFrfFrequency,fIntensityPhase,fIntensityPlay.Down) then
    begin
      UpdateValueLabels;
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
