unit uRecorder3dSettingsDialog;
{$mode objfpc}{$H+}
{$codepage UTF8}

{ Designer-editable editor for TRecorder3dComponent. The component settings
  dispatcher calls ShowRecorder3dSettingsDialog; CreateDialog injects the model
  and tag registry only after the LFM has created the visual controls. }

interface
uses Classes,SysUtils,Forms,Controls,StdCtrls,ExtCtrls,ComCtrls,Dialogs,Grids,
  Graphics,Spin,ColorBox,uRecorder3dModel,uRecorderTags,u3dScene,u3dMeshTopology,
  uRecorder3dSkinModifierFrame, uRecorder3dVertexColorModifierFrame;

type
  TRecorder3dCornerIndices = array of LongWord;
  TRecorder3dNodeSelectedEvent = procedure(ANodeId: QWord) of object;
  TRecorder3dVertexSelectedEvent = procedure(ANodeId: QWord;
    const APrimaryCorners, AAdjacentCorners: array of LongWord) of object;

  { TRecorder3dSettingsDialog }

  TRecorder3dSettingsDialog=class(TForm)
  published
    btnBrowse: TButton;
    cbBindColor: TComboBox;
    cbBindNormalLength: TComboBox;
    cbBindX: TComboBox;
    cbBindY: TComboBox;
    cbBindZ: TComboBox;
    chkObjectFill: TCheckBox;
    chkObjectNormals: TCheckBox;
    chkObjectPoints: TCheckBox;
    chkObjectWireframe: TCheckBox;
    chkShowAxes: TCheckBox;
    cbPointColor:TColorBox;
    edNormalLength: TEdit;
    edSceneFile: TEdit;
    edTagSearch: TEdit;
    lblBindColor: TLabel;
    lblBindNormalLength: TLabel;
    lblBindX: TLabel;
    lblBindY: TLabel;
    lblBindZ: TLabel;
    lblNormalLength: TLabel;
    lblPointColor:TLabel;
    lblSelectedObjectSettings: TLabel;
    lblSceneFile: TLabel;
    lblTagSearch: TLabel;
    Panel1: TPanel;
    pnlActions:TPanel;
    pnlDetailsBottom:TPanel;
    tvScene:TTreeView;
    pcDetails:TPageControl;
    tsVertices:TTabSheet;
    sgVertices:TStringGrid;
    pnlMain,pnlModifiers,pnlModifierList,pnlModifierHost:TPanel;
    splDetailsBottom,splModifiers,splModifierEditor:TSplitter;
    lblModifiers:TLabel;
    lbModifiers:TListBox;
    btnOk:TButton;
    btnCancel:TButton;
    procedure BrowseClick(Sender:TObject);
    procedure SearchEditChange(Sender:TObject);
    procedure BindingComboChange(Sender:TObject);
    procedure ObjectRenderSettingsChange(Sender:TObject);
    procedure PointColorSelect(Sender:TObject);
    procedure SceneTreeSelectionChanged(Sender:TObject);
    procedure VerticesSelectCell(Sender:TObject; ACol,ARow:Integer;
      var CanSelect:Boolean);
    procedure VerticesPrepareCanvas(Sender:TObject; ACol,ARow:Integer;
      AState:TGridDrawState);
    procedure FormClose(Sender:TObject; var CloseAction:TCloseAction);
    procedure FormResize(Sender:TObject);
    procedure OkClick(Sender:TObject);
    procedure CancelClick(Sender:TObject);
    procedure ModifierSelectionChange(Sender:TObject);
  private
    fComponent:TRecorder3dComponent;
    fRegistry:TRecorderTagRegistry;
    fScene:T3dScene;
    fSelectedNode:T3dNode;
    fTopology:T3dMeshTopology;
    fRelations:T3dTopologyRelations;
    { LCL Items.Objects and TreeNode.Data carry stable numeric IDs through
      PtrUInt. Zero is reserved for “not selected”; IDs must fit PtrUInt. }
    fSelectedTagIds:array[TRecorder3dBindingSlot] of TRecorderTagId;
    fPopulating:Boolean;
    fInitialSelectedNodeId:QWord;
    fModeless:Boolean;
    fOwnsScene:Boolean;
    fSnapshot:TRecorder3dComponent;
    fSnapshotSelectedNodeId:QWord;
    fOnNodeSelected:TRecorder3dNodeSelectedEvent;
    fOnVertexSelected:TRecorder3dVertexSelectedEvent;
    fOnSettingsApplied:TNotifyEvent;
    fOnSkinChanged:TNotifyEvent;
    fOnVertexColorChanged:TNotifyEvent;
    fSynchronizingSelection:Boolean;
    fSkinFrame:TRecorder3dSkinModifierFrame;
    fVertexColorFrame:TRecorder3dVertexColorModifierFrame;
    fModifierScroll:TScrollBox;
    fOnAddSkinHelper:TRecorder3dAddSkinBoneEvent;
    fOnDeleteSkinHelper:TRecorder3dDeleteSkinBoneEvent;
    fOnResetSkinHelpers:TNotifyEvent;
    fOnRenameSkinHelper:TRecorder3dRenameSkinBoneEvent;
    fOnSetSkinInfluence:TRecorder3dSetSkinInfluenceEvent;
    fOnRemoveSkinInfluence:TRecorder3dRemoveSkinInfluenceEvent;
    function SelectedLogicalVertexId:LongWord;
    procedure CreateModifierFrames;
    procedure ShowSelectedModifier;
    procedure SkinFrameChanged(Sender:TObject);
    procedure VertexColorFrameChanged(Sender:TObject);
    procedure SyncSkinFrame;
    function BindingCombo(ASlot:TRecorder3dBindingSlot):TComboBox;
    function ObjectRenderCheck(AIndex:Integer):TCheckBox;
    procedure PopulateBinding(ASlot:TRecorder3dBindingSlot;
      const AFilter:string);
    procedure ReloadTree;
    procedure PopulateBindings(const AFilter:string);
    procedure ApplyNodeOverrides;
    procedure BuildSceneTree;
    procedure RestoreTreeSelection;
    procedure LoadModel;
    procedure SaveModel;
    procedure SaveSelectedNode;
    procedure SaveGlobalSettings;
    procedure SaveBindings;
    procedure SaveNodeOverrides;
    procedure LoadSelectedNode;
    procedure FillVertexGrid;
    procedure NotifyVertexSelection(ALogicalVertex:Integer);
    procedure SelectTreeNode(ANodeId:QWord);
    procedure ClearLiveHighlight;
    procedure RollbackLiveDraft;
    procedure ReleaseScene;
    procedure RebuildTreeFromCurrentScene;
    procedure CaptureSnapshot(ASelectedNodeId:QWord);
    function ResolveMesh(ANode:T3dNode):T3dMeshData;
    function Matches(ATag:TRecorderTag; const AFilter:string):Boolean;
  public
    constructor CreateDialog(AOwner:TComponent; AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry; ASelectedNodeId:QWord=0);
    destructor Destroy; override;
    procedure ShowEditor(ASelectedNodeId:QWord);
    procedure AttachLiveScene(AScene:T3dScene; ASelectedNodeId:QWord);
    procedure UpdateContext(AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry);
    procedure SelectNodeFromView(ANodeId:QWord);
    procedure SelectVertexFromView(ANodeId:QWord; ALogicalVertex:Integer);
    property OnNodeSelected:TRecorder3dNodeSelectedEvent
      read fOnNodeSelected write fOnNodeSelected;
    property OnVertexSelected:TRecorder3dVertexSelectedEvent
      read fOnVertexSelected write fOnVertexSelected;
    property OnSettingsApplied:TNotifyEvent read fOnSettingsApplied
      write fOnSettingsApplied;
    property OnSkinChanged:TNotifyEvent read fOnSkinChanged
      write fOnSkinChanged;
    property OnVertexColorChanged:TNotifyEvent read fOnVertexColorChanged
      write fOnVertexColorChanged;
    property OnAddSkinHelper:TRecorder3dAddSkinBoneEvent
      read fOnAddSkinHelper write fOnAddSkinHelper;
    property OnDeleteSkinHelper:TRecorder3dDeleteSkinBoneEvent
      read fOnDeleteSkinHelper write fOnDeleteSkinHelper;
    property OnResetSkinHelpers:TNotifyEvent
      read fOnResetSkinHelpers write fOnResetSkinHelpers;
    property OnRenameSkinHelper:TRecorder3dRenameSkinBoneEvent
      read fOnRenameSkinHelper write fOnRenameSkinHelper;
    property OnSetSkinInfluence:TRecorder3dSetSkinInfluenceEvent
      read fOnSetSkinInfluence write fOnSetSkinInfluence;
    property OnRemoveSkinInfluence:TRecorder3dRemoveSkinInfluenceEvent
      read fOnRemoveSkinInfluence write fOnRemoveSkinInfluence;
  end;

function ShowRecorder3dSettingsDialog(AOwner:TComponent;
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry):Boolean;
implementation
uses Math,LazUTF8,u3dLegacySceneLoader,u3dPrimitives;

{$R *.lfm}

constructor TRecorder3dSettingsDialog.CreateDialog(AOwner:TComponent;
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry;
  ASelectedNodeId:QWord);
begin
  inherited Create(AOwner);
  fComponent:=AComponent;
  fRegistry:=ARegistry;
  fInitialSelectedNodeId:=ASelectedNodeId;
  cbBindX.Tag:=Ord(r3bPointX);
  cbBindY.Tag:=Ord(r3bPointY);
  cbBindZ.Tag:=Ord(r3bPointZ);
  cbBindColor.Tag:=Ord(r3bColor);
  cbBindNormalLength.Tag:=Ord(r3bNormalLength);
  sgVertices.Cells[0,0]:='№';
  sgVertices.Cells[1,0]:='ID вершины';
  sgVertices.Cells[2,0]:='X';
  sgVertices.Cells[3,0]:='Y';
  sgVertices.Cells[4,0]:='Z';
  sgVertices.Cells[5,0]:='Копий';
  sgVertices.Cells[6,0]:='Полигоны';
  sgVertices.ColWidths[0]:=42;
  sgVertices.ColWidths[1]:=85;
  sgVertices.ColWidths[2]:=75;
  sgVertices.ColWidths[3]:=75;
  sgVertices.ColWidths[4]:=75;
  sgVertices.ColWidths[5]:=55;
  sgVertices.ColWidths[6]:=190;
  { The modifier dock owns the full right side. In LCL the back-most aligned
    controls reserve their edge first, so the legacy bottom vertex panel then
    receives only the remaining center width and cannot cover the editor. }
  splModifiers.SendToBack;
  pnlModifiers.SendToBack;
  CreateModifierFrames;
  LoadModel;
end;

procedure TRecorder3dSettingsDialog.CreateModifierFrames;
begin
  lbModifiers.Items.Clear;
  lbModifiers.Items.Add('Skin');
  lbModifiers.Items.Add('Цвета вершин');
  lbModifiers.ItemIndex:=0;
  fSkinFrame:=TRecorder3dSkinModifierFrame.Create(Self);
  fVertexColorFrame:=TRecorder3dVertexColorModifierFrame.Create(Self);
  fModifierScroll:=TScrollBox.Create(Self);
  fModifierScroll.Parent:=pnlModifierHost;
  fModifierScroll.Align:=alClient;
  fModifierScroll.BorderStyle:=bsNone;
  fModifierScroll.AutoScroll:=True;
  fSkinFrame.Parent:=fModifierScroll;
  fSkinFrame.Align:=alTop;
  fSkinFrame.Width:=fModifierScroll.ClientWidth;
  fSkinFrame.OnChanged:=@SkinFrameChanged;
  fSkinFrame.OnAddBone:=fOnAddSkinHelper;
  fSkinFrame.OnDeleteBone:=fOnDeleteSkinHelper;
  fSkinFrame.OnResetBones:=fOnResetSkinHelpers;
  fSkinFrame.OnRenameBone:=fOnRenameSkinHelper;
  fSkinFrame.OnSetInfluence:=fOnSetSkinInfluence;
  fSkinFrame.OnRemoveInfluence:=fOnRemoveSkinInfluence;
  fSkinFrame.Configure(fComponent,fRegistry);
  fVertexColorFrame.Parent:=fModifierScroll;
  fVertexColorFrame.Align:=alTop;
  fVertexColorFrame.Width:=fModifierScroll.ClientWidth;
  fVertexColorFrame.OnChanged:=@VertexColorFrameChanged;
  fVertexColorFrame.Configure(fComponent,fRegistry);
  ShowSelectedModifier;
end;

procedure TRecorder3dSettingsDialog.ShowSelectedModifier;
begin
  if fSkinFrame=nil then
    Exit;
  fSkinFrame.Visible:=lbModifiers.ItemIndex=0;
  if fVertexColorFrame<>nil then
    fVertexColorFrame.Visible:=lbModifiers.ItemIndex=1;
end;

procedure TRecorder3dSettingsDialog.VertexColorFrameChanged(Sender:TObject);
begin
  if Assigned(fOnVertexColorChanged) then fOnVertexColorChanged(Self);
end;

procedure TRecorder3dSettingsDialog.ModifierSelectionChange(Sender:TObject);
begin
  ShowSelectedModifier;
end;

procedure TRecorder3dSettingsDialog.SkinFrameChanged(Sender:TObject);
begin
  { Skin callbacks already mutate the live helper/model. Rebuilding the whole
    scene here is both wasteful and unsafe inside a button handler; only the
    lightweight skin/tag cache needs refreshing. }
  if Assigned(fOnSkinChanged) then
    fOnSkinChanged(Self);
end;

procedure TRecorder3dSettingsDialog.ShowEditor(ASelectedNodeId:QWord);
begin
  fModeless:=True;
  FormStyle:=fsStayOnTop;
  CaptureSnapshot(ASelectedNodeId);
  SyncSkinFrame;
  { Recreate the editing draft on every opening so Cancel cannot leak prior
    hidden changes into a later OK. }
  LoadModel;
  SelectTreeNode(ASelectedNodeId);
  if fSkinFrame<>nil then
    fSkinFrame.Reload;
  if fVertexColorFrame<>nil then
    fVertexColorFrame.Reload;
  Show;
  BringToFront;
  if (tvScene<>nil) and tvScene.CanFocus then
  begin
    if tvScene.Selected<>nil then
      tvScene.Selected.MakeVisible;
    tvScene.SetFocus;
  end;
end;

procedure TRecorder3dSettingsDialog.SyncSkinFrame;
begin
  if fSkinFrame=nil then
    Exit;
  fSkinFrame.OnAddBone:=fOnAddSkinHelper;
  fSkinFrame.OnDeleteBone:=fOnDeleteSkinHelper;
  fSkinFrame.OnResetBones:=fOnResetSkinHelpers;
  fSkinFrame.OnRenameBone:=fOnRenameSkinHelper;
  fSkinFrame.OnSetInfluence:=fOnSetSkinInfluence;
  fSkinFrame.OnRemoveInfluence:=fOnRemoveSkinInfluence;
  fSkinFrame.Configure(fComponent,fRegistry);
  if fVertexColorFrame<>nil then
    fVertexColorFrame.Configure(fComponent,fRegistry);
end;

procedure TRecorder3dSettingsDialog.FormClose(Sender:TObject;
  var CloseAction:TCloseAction);
begin
  if fModeless then
  begin
    RollbackLiveDraft;
    ClearLiveHighlight;
    CloseAction:=caHide;
  end;
end;

procedure TRecorder3dSettingsDialog.FormResize(Sender:TObject);
const
  CMinimumTopHeight=370;
  CMinimumDetailsHeight=200;
var
  AvailableDetailsHeight:Integer;
begin
  if (pnlMain=nil) or (pnlDetailsBottom=nil) or (splDetailsBottom=nil) then
    Exit;
  AvailableDetailsHeight:=pnlMain.ClientHeight-CMinimumTopHeight-
    splDetailsBottom.Height;
  if pnlDetailsBottom.Height>AvailableDetailsHeight then
    pnlDetailsBottom.Height:=Max(CMinimumDetailsHeight,AvailableDetailsHeight);
end;

procedure TRecorder3dSettingsDialog.OkClick(Sender:TObject);
begin
  if fModeless then
  begin
    SaveModel;
    if Assigned(fOnSettingsApplied) then
      fOnSettingsApplied(Self);
    ClearLiveHighlight;
    Hide;
  end
  else
    ModalResult:=mrOk;
end;

procedure TRecorder3dSettingsDialog.CancelClick(Sender:TObject);
begin
  if fModeless then
  begin
    RollbackLiveDraft;
    ClearLiveHighlight;
    Hide;
  end
  else
    ModalResult:=mrCancel;
end;

procedure TRecorder3dSettingsDialog.RollbackLiveDraft;
begin
  if fSnapshot<>nil then
    fComponent.Assign(fSnapshot);
  if Assigned(fOnSettingsApplied) then
    fOnSettingsApplied(Self);
  if Assigned(fOnNodeSelected) then
    fOnNodeSelected(fSnapshotSelectedNodeId);
end;

destructor TRecorder3dSettingsDialog.Destroy;
begin
  ReleaseScene;
  fSnapshot.Free;
  inherited Destroy;
end;

procedure TRecorder3dSettingsDialog.CaptureSnapshot(ASelectedNodeId:QWord);
begin
  if fSnapshot=nil then
    fSnapshot:=TRecorder3dComponent.Create;
  fSnapshot.Assign(fComponent);
  fSnapshotSelectedNodeId:=ASelectedNodeId;
end;

procedure TRecorder3dSettingsDialog.UpdateContext(
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
begin
  fComponent:=AComponent;
  fRegistry:=ARegistry;
  if fSkinFrame<>nil then
    fSkinFrame.Configure(fComponent,fRegistry);
end;

procedure TRecorder3dSettingsDialog.ReleaseScene;
begin
  if fOwnsScene then
    fScene.Free;
  fScene:=nil;
  fOwnsScene:=False;
end;

procedure TRecorder3dSettingsDialog.AttachLiveScene(AScene:T3dScene;
  ASelectedNodeId:QWord);
begin
  ReleaseScene;
  fScene:=AScene;
  fInitialSelectedNodeId:=ASelectedNodeId;
  RebuildTreeFromCurrentScene;
  SelectTreeNode(ASelectedNodeId);
end;

procedure TRecorder3dSettingsDialog.RebuildTreeFromCurrentScene;
begin
  fSelectedNode:=nil;
  tvScene.Items.Clear;
  if fScene=nil then
  begin
    FillVertexGrid;
    Exit;
  end;
  BuildSceneTree;
  RestoreTreeSelection;
  SceneTreeSelectionChanged(tvScene);
end;

function TRecorder3dSettingsDialog.BindingCombo(
  ASlot:TRecorder3dBindingSlot):TComboBox;
begin
  case ASlot of
    r3bPointX: Result:=cbBindX;
    r3bPointY: Result:=cbBindY;
    r3bPointZ: Result:=cbBindZ;
    r3bColor: Result:=cbBindColor;
  else
    Result:=cbBindNormalLength;
  end;
end;

function TRecorder3dSettingsDialog.ObjectRenderCheck(AIndex:Integer):TCheckBox;
begin
  case AIndex of
    0: Result:=chkObjectFill;
    1: Result:=chkObjectWireframe;
    2: Result:=chkObjectPoints;
  else
    Result:=chkObjectNormals;
  end;
end;

function TRecorder3dSettingsDialog.Matches(ATag:TRecorderTag; const AFilter:string):Boolean;
var
  F:string;
begin
  F:=UTF8LowerCase(Trim(AFilter));
  Result:=(F='') or
    (Pos(F,UTF8LowerCase(ATag.Name))>0) or
    (Pos(F,UTF8LowerCase(ATag.Address))>0) or
    (Pos(F,UTF8LowerCase(ATag.Description))>0);
end;

procedure TRecorder3dSettingsDialog.PopulateBinding(
  ASlot:TRecorder3dBindingSlot; const AFilter:string);
var
  Combo:TComboBox;
  I:Integer;
  SelectedIndex:Integer;
  TagItem:TRecorderTag;
begin
  Combo:=BindingCombo(ASlot);
  Combo.Clear;
  Combo.Items.AddObject('(нет)',nil);
  if fRegistry<>nil then
    for I:=0 to fRegistry.TagCount-1 do
    begin
      TagItem:=fRegistry.Tags[I];
      if Matches(TagItem,AFilter) then
        Combo.Items.AddObject(TagItem.Name+' ['+TagItem.Address+']',
          TObject(PtrUInt(TagItem.Id)));
    end;

  SelectedIndex:=0;
  for I:=1 to Combo.Items.Count-1 do
    if TRecorderTagId(PtrUInt(Combo.Items.Objects[I]))=
      fSelectedTagIds[ASlot] then
    begin
      SelectedIndex:=I;
      Break;
    end;
  Combo.ItemIndex:=SelectedIndex;
end;

procedure TRecorder3dSettingsDialog.PopulateBindings(const AFilter:string);
var
  Slot:TRecorder3dBindingSlot;
begin
  fPopulating:=True;
  try
    for Slot:=Low(Slot) to High(Slot) do
      PopulateBinding(Slot,AFilter);
  finally
    fPopulating:=False;
  end;
end;

procedure TRecorder3dSettingsDialog.BindingComboChange(Sender:TObject);
var
  Combo:TComboBox;
begin
  if fPopulating then Exit;
  Combo:=TComboBox(Sender);
  if Combo.ItemIndex>=0 then
    fSelectedTagIds[TRecorder3dBindingSlot(Combo.Tag)]:=
      TRecorderTagId(PtrUInt(Combo.Items.Objects[Combo.ItemIndex]));
end;

procedure TRecorder3dSettingsDialog.ObjectRenderSettingsChange(Sender:TObject);
begin
  if fPopulating or (fSelectedNode=nil) then
    Exit;
  { The editor exposes one render row and it always belongs to the selected
    scene node. The first user change turns that row into a node override. }
  fSelectedNode.HasRenderOverride:=True;
  fSelectedNode.DrawFillOverride:=chkObjectFill.Checked;
  fSelectedNode.DrawWireframeOverride:=chkObjectWireframe.Checked;
  fSelectedNode.DrawPointsOverride:=chkObjectPoints.Checked;
  fSelectedNode.DrawNormalsOverride:=chkObjectNormals.Checked;
  SaveNodeOverrides;
  if Assigned(fOnSettingsApplied) then
    fOnSettingsApplied(Self);
end;

procedure TRecorder3dSettingsDialog.PointColorSelect(Sender:TObject);
begin
  if fPopulating or (fComponent=nil) then
    Exit;
  fComponent.PointColor:=LongInt(cbPointColor.Selected);
  if Assigned(fOnSettingsApplied) then
    fOnSettingsApplied(Self);
end;

procedure TRecorder3dSettingsDialog.SearchEditChange(Sender:TObject);
begin
  PopulateBindings(edTagSearch.Text);
end;

procedure TRecorder3dSettingsDialog.BrowseClick(Sender:TObject);
var
  Dialog:TOpenDialog;
begin
  Dialog:=TOpenDialog.Create(Self);
  try
    Dialog.Filter:='Сцены OBR|*.obr;*.OBR|Все файлы|*.*';
    if not Dialog.Execute then Exit;
    edSceneFile.Text:=Dialog.FileName;
    if fModeless then
    begin
      SaveModel;
      if Assigned(fOnSettingsApplied) then
        fOnSettingsApplied(Self);
      Exit;
    end;
    try
      ReloadTree;
    except
      on E:Exception do
        MessageDlg('Ошибка сцены',E.Message,mtError,[mbOK],0);
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TRecorder3dSettingsDialog.ReloadTree;
var
  Loader:I3dSceneLoader;
begin
  SaveSelectedNode;
  ReleaseScene;
  if not FileExists(edSceneFile.Text) then
    fScene:=CreateDefaultCubeScene
  else
  begin
    Loader:=T3dLegacySceneLoader.Create;
    fScene:=Loader.LoadScene(edSceneFile.Text);
  end;
  fOwnsScene:=True;
  ApplyNodeOverrides;
  RebuildTreeFromCurrentScene;
end;

procedure TRecorder3dSettingsDialog.ApplyNodeOverrides;
var
  I,lUpdated:Integer;
  Node:T3dNode;
  OverrideItem:TRecorder3dNodeRenderOverride;
begin
  for I:=0 to fComponent.NodeRenderOverrideCount-1 do
  begin
    OverrideItem:=fComponent.NodeRenderOverrides[I];
    Node:=fScene.FindNode(OverrideItem.NodeId);
    if Node=nil then Continue;
    if OverrideItem.HasTransform then
      Node.LocalTransform:=OverrideItem.LocalTransform;
    if OverrideItem.HasRenderSettings then
    begin
      Node.HasRenderOverride:=True;
      Node.DrawFillOverride:=OverrideItem.DrawFill;
      Node.DrawWireframeOverride:=OverrideItem.DrawWireframe;
      Node.DrawPointsOverride:=OverrideItem.DrawPoints;
      Node.DrawNormalsOverride:=OverrideItem.DrawNormals;
    end;
  end;
  fScene.RebuildWorldTransforms(lUpdated);
  fScene.MarkBoundsDirty;
end;

procedure TRecorder3dSettingsDialog.BuildSceneTree;
var
  I:Integer;
  J:Integer;
  ParentNode:TTreeNode;
  TreeNode:TTreeNode;
begin
  for I:=0 to High(fScene.Nodes) do
  begin
    ParentNode:=nil;
    for J:=0 to tvScene.Items.Count-1 do
      if PtrUInt(tvScene.Items[J].Data)=fScene.Nodes[I].ParentId then
      begin
        ParentNode:=tvScene.Items[J];
        Break;
      end;
    TreeNode:=tvScene.Items.AddChild(ParentNode,fScene.Nodes[I].Name);
    TreeNode.Data:=Pointer(PtrUInt(fScene.Nodes[I].Id));
    if ((fInitialSelectedNodeId<>0) and
      (fScene.Nodes[I].Id=fInitialSelectedNodeId)) or
      ((fInitialSelectedNodeId=0) and
      (fScene.Nodes[I].Id=fComponent.BindingTargetNodeId)) then
      tvScene.Selected:=TreeNode;
  end;
end;

procedure TRecorder3dSettingsDialog.RestoreTreeSelection;
begin
  if (tvScene.Selected=nil) and (tvScene.Items.Count>0) then
    tvScene.Selected:=tvScene.Items[0];
end;

procedure TRecorder3dSettingsDialog.SelectTreeNode(ANodeId:QWord);
var
  I:Integer;
begin
  for I:=0 to tvScene.Items.Count-1 do
    if QWord(PtrUInt(tvScene.Items[I].Data))=ANodeId then
    begin
      tvScene.Selected:=tvScene.Items[I];
      tvScene.Selected.MakeVisible;
      Exit;
    end;
end;

procedure TRecorder3dSettingsDialog.ClearLiveHighlight;
var
  Empty:TRecorder3dCornerIndices;
begin
  if Assigned(fOnVertexSelected) then
    fOnVertexSelected(0,Empty,Empty);
end;

procedure TRecorder3dSettingsDialog.SaveSelectedNode;
begin
  if fSelectedNode=nil then
    Exit;
  fSelectedNode.HasRenderOverride:=True;
  fSelectedNode.DrawFillOverride:=chkObjectFill.Checked;
  fSelectedNode.DrawWireframeOverride:=chkObjectWireframe.Checked;
  fSelectedNode.DrawPointsOverride:=chkObjectPoints.Checked;
  fSelectedNode.DrawNormalsOverride:=chkObjectNormals.Checked;
end;

procedure TRecorder3dSettingsDialog.LoadSelectedNode;
var
  I:Integer;
  lWasPopulating:Boolean;
begin
  lWasPopulating:=fPopulating;
  fPopulating:=True;
  try
  for I:=0 to 3 do
    ObjectRenderCheck(I).Enabled:=fSelectedNode<>nil;
  if fSelectedNode=nil then Exit;
  if fSelectedNode.HasRenderOverride then
  begin
    chkObjectFill.Checked:=fSelectedNode.DrawFillOverride;
    chkObjectWireframe.Checked:=fSelectedNode.DrawWireframeOverride;
    chkObjectPoints.Checked:=fSelectedNode.DrawPointsOverride;
    chkObjectNormals.Checked:=fSelectedNode.DrawNormalsOverride;
  end
  else
  begin
    chkObjectFill.Checked:=fComponent.DrawFill;
    chkObjectWireframe.Checked:=fComponent.DrawWireframe;
    chkObjectPoints.Checked:=fComponent.DrawPoints;
    chkObjectNormals.Checked:=fComponent.DrawNormals;
  end;
  finally
    fPopulating:=lWasPopulating;
  end;
end;

procedure TRecorder3dSettingsDialog.SceneTreeSelectionChanged(Sender:TObject);
begin
  SaveSelectedNode;
  fSelectedNode:=nil;
  if (fScene<>nil) and (tvScene.Selected<>nil) then
    fSelectedNode:=fScene.FindNode(QWord(PtrUInt(tvScene.Selected.Data)));
  if not fSynchronizingSelection and Assigned(fOnNodeSelected) and
    (fSelectedNode<>nil) then
    fOnNodeSelected(fSelectedNode.Id);
  LoadSelectedNode;
  FillVertexGrid;
  if fSkinFrame<>nil then
    fSkinFrame.SetSelectedVertex(0,0,False);
  if fVertexColorFrame<>nil then
    fVertexColorFrame.SetSelectedVertex(0,0,False);
end;

procedure TRecorder3dSettingsDialog.SelectNodeFromView(ANodeId:QWord);
begin
  fSynchronizingSelection:=True;
  try
    SelectTreeNode(ANodeId);
  finally
    fSynchronizingSelection:=False;
  end;
end;

procedure TRecorder3dSettingsDialog.SelectVertexFromView(ANodeId:QWord;
  ALogicalVertex:Integer);
var
  CanSelect:Boolean;
begin
  fSynchronizingSelection:=True;
  try
    SelectTreeNode(ANodeId);
    if (ALogicalVertex<0) or (ALogicalVertex>=Length(fTopology.Vertices)) then
      Exit;
    CanSelect:=True;
    sgVertices.Row:=ALogicalVertex+1;
    VerticesSelectCell(sgVertices,sgVertices.Col,sgVertices.Row,CanSelect);
    sgVertices.TopRow:=Max(1,sgVertices.Row-2);
  finally
    fSynchronizingSelection:=False;
  end;
end;

function TRecorder3dSettingsDialog.ResolveMesh(ANode:T3dNode):T3dMeshData;
var
  SourceNode:T3dNode;
begin
  Result:=nil;
  if ANode=nil then
    Exit;
  Result:=ANode.Mesh;
  { Legacy scene instances keep geometry in SourceNodeId instead of duplicating
    the source mesh; the editor must show the shared logical vertices. }
  if (Result<>nil) and (Length(Result.Positions)=0) and
    (Result.SourceNodeId<>0) then
  begin
    SourceNode:=fScene.FindNode(Result.SourceNodeId);
    if SourceNode<>nil then
      Result:=SourceNode.Mesh;
  end;
end;

function IndexesText(const A:T3dIndexArray):string;
var
  I:Integer;
begin
  Result:='';
  for I:=0 to High(A) do
  begin
    if Result<>'' then
      Result:=Result+', ';
    Result:=Result+IntToStr(A[I]);
  end;
end;

procedure TRecorder3dSettingsDialog.FillVertexGrid;
var
  Mesh:T3dMeshData;
  I:Integer;
  Vertex:T3dLogicalVertexInfo;
begin
  Mesh:=ResolveMesh(fSelectedNode);
  fTopology:=BuildMeshTopology(Mesh);
  SetLength(fRelations,0);
  sgVertices.RowCount:=Max(1,Length(fTopology.Vertices)+1);
  for I:=0 to High(fTopology.Vertices) do
  begin
    Vertex:=fTopology.Vertices[I];
    sgVertices.Cells[0,I+1]:=IntToStr(I);
    sgVertices.Cells[1,I+1]:=IntToStr(Vertex.StableId);
    sgVertices.Cells[2,I+1]:=FloatToStr(Vertex.Position.X);
    sgVertices.Cells[3,I+1]:=FloatToStr(Vertex.Position.Y);
    sgVertices.Cells[4,I+1]:=FloatToStr(Vertex.Position.Z);
    sgVertices.Cells[5,I+1]:=IntToStr(Vertex.CornerCount);
    sgVertices.Cells[6,I+1]:=IndexesText(Vertex.FaceIndexes);
  end;
  sgVertices.Invalidate;
end;

procedure TRecorder3dSettingsDialog.VerticesSelectCell(Sender:TObject; ACol,ARow:Integer; var CanSelect:Boolean);
begin
  if ARow>0 then
    fRelations:=ClassifyLogicalVertices(fTopology,ARow-1)
  else
    SetLength(fRelations,0);
  sgVertices.Invalidate;
  if not fSynchronizingSelection then
    NotifyVertexSelection(ARow-1);
  if fSkinFrame<>nil then
    if (fSelectedNode<>nil) and (ARow>0) and
      (ARow-1<=High(fTopology.Vertices)) then
      fSkinFrame.SetSelectedVertex(fSelectedNode.Id,
        fTopology.Vertices[ARow-1].StableId,True)
    else
      fSkinFrame.SetSelectedVertex(0,0,False);
  if fVertexColorFrame<>nil then
    if (fSelectedNode<>nil) and (ARow>0) and
      (ARow-1<=High(fTopology.Vertices)) then
      fVertexColorFrame.SetSelectedVertex(fSelectedNode.Id,
        fTopology.Vertices[ARow-1].StableId,True)
    else
      fVertexColorFrame.SetSelectedVertex(0,0,False);
end;

function TRecorder3dSettingsDialog.SelectedLogicalVertexId:LongWord;
begin
  Result:=0;
  if (sgVertices.Row<=0) or
     (sgVertices.Row-1>High(fTopology.Vertices)) then
    Exit;
  Result:=fTopology.Vertices[sgVertices.Row-1].StableId;
end;

procedure AppendCorners(var ADestination:TRecorder3dCornerIndices;
  const ASource:T3dIndexArray);
var
  I:Integer;
  Offset:Integer;
begin
  Offset:=Length(ADestination);
  SetLength(ADestination,Offset+Length(ASource));
  for I:=0 to High(ASource) do
    ADestination[Offset+I]:=LongWord(ASource[I]);
end;

procedure TRecorder3dSettingsDialog.NotifyVertexSelection(
  ALogicalVertex:Integer);
var
  I:Integer;
  PrimaryCorners:TRecorder3dCornerIndices;
  AdjacentCorners:TRecorder3dCornerIndices;
begin
  if not Assigned(fOnVertexSelected) or (fSelectedNode=nil) then
    Exit;
  if (ALogicalVertex<0) or
    (ALogicalVertex>High(fTopology.LogicalToCorners)) then
  begin
    fOnVertexSelected(fSelectedNode.Id,PrimaryCorners,AdjacentCorners);
    Exit;
  end;
  AppendCorners(PrimaryCorners,fTopology.LogicalToCorners[ALogicalVertex]);
  for I:=0 to High(fTopology.Neighbors[ALogicalVertex]) do
    AppendCorners(AdjacentCorners,
      fTopology.LogicalToCorners[fTopology.Neighbors[ALogicalVertex][I]]);
  fOnVertexSelected(fSelectedNode.Id,PrimaryCorners,AdjacentCorners);
end;

procedure TRecorder3dSettingsDialog.VerticesPrepareCanvas(Sender:TObject; ACol,ARow:Integer; AState:TGridDrawState);
begin
  if (ARow<=0) or (ARow-1>High(fRelations)) then Exit;
  case fRelations[ARow-1] of
    trPrimary:sgVertices.Canvas.Brush.Color:=$0080E8FF;
    trAdjacent:sgVertices.Canvas.Brush.Color:=$00D0FFD0;
  end;
end;

procedure TRecorder3dSettingsDialog.LoadModel;
var
  Slot:TRecorder3dBindingSlot;
begin
  edSceneFile.Text:=fComponent.SceneFileName;
  chkShowAxes.Checked:=fComponent.ShowAxes;
  edNormalLength.Text:=FloatToStr(fComponent.NormalLength);
  cbPointColor.Selected:=TColor(fComponent.PointColor);
  for Slot:=Low(Slot) to High(Slot) do
    fSelectedTagIds[Slot]:=fComponent.BindingTagIds[Slot];
  if fSelectedTagIds[r3bNormalLength]=0 then
    fSelectedTagIds[r3bNormalLength]:=fComponent.NormalLengthTagId;
  PopulateBindings('');
  try
    if fModeless and (fScene<>nil) then
      RebuildTreeFromCurrentScene
    else
      ReloadTree;
  except
    on E:Exception do
      MessageDlg('Сцена не загружена',E.Message,mtWarning,[mbOK],0);
  end;
end;

procedure TRecorder3dSettingsDialog.SaveModel;
begin
  SaveSelectedNode;
  SaveGlobalSettings;
  SaveBindings;
  SaveNodeOverrides;
end;

procedure TRecorder3dSettingsDialog.SaveGlobalSettings;
begin
  fComponent.SceneFileName:=edSceneFile.Text;
  fComponent.ShowAxes:=chkShowAxes.Checked;
  fComponent.NormalLength:=StrToFloatDef(edNormalLength.Text,0.25);
  fComponent.PointColor:=LongInt(cbPointColor.Selected);
  if tvScene.Selected<>nil then
    fComponent.BindingTargetNodeId:=QWord(PtrUInt(tvScene.Selected.Data));
end;

procedure TRecorder3dSettingsDialog.SaveBindings;
var
  Slot:TRecorder3dBindingSlot;
  TagId:TRecorderTagId;
  TagItem:TRecorderTag;
begin
  for Slot:=Low(Slot) to High(Slot) do
  begin
    TagId:=fSelectedTagIds[Slot];
    fComponent.BindingTagIds[Slot]:=TagId;
    TagItem:=nil;
    if (fRegistry<>nil) and (TagId<>0) then
      TagItem:=fRegistry.FindById(TagId);
    if TagItem=nil then
      fComponent.BindingTagNames[Slot]:=''
    else
      fComponent.BindingTagNames[Slot]:=TagItem.Name;
  end;
  fComponent.NormalLengthTagId:=fComponent.BindingTagIds[r3bNormalLength];
  fComponent.NormalLengthTagName:=fComponent.BindingTagNames[r3bNormalLength];
end;

procedure TRecorder3dSettingsDialog.SaveNodeOverrides;
var
  I:Integer;
  OverrideItem:TRecorder3dNodeRenderOverride;
begin
  if fScene=nil then
    Exit;
  for I:=0 to High(fScene.Nodes) do
  begin
    if not fScene.Nodes[I].HasRenderOverride then
      Continue;
    OverrideItem:=fComponent.FindNodeRenderOverride(fScene.Nodes[I].Id);
    if OverrideItem=nil then
      OverrideItem:=fComponent.AddNodeRenderOverride;
    OverrideItem.NodeId:=fScene.Nodes[I].Id;
    OverrideItem.HasRenderSettings:=True;
    OverrideItem.DrawFill:=fScene.Nodes[I].DrawFillOverride;
    OverrideItem.DrawWireframe:=fScene.Nodes[I].DrawWireframeOverride;
    OverrideItem.DrawPoints:=fScene.Nodes[I].DrawPointsOverride;
    OverrideItem.DrawNormals:=fScene.Nodes[I].DrawNormalsOverride;
  end;
end;

function ShowRecorder3dSettingsDialog(AOwner:TComponent; AComponent:TRecorder3dComponent;
  ARegistry:TRecorderTagRegistry):Boolean;
var
  Dialog:TRecorder3dSettingsDialog;
begin
  Dialog:=TRecorder3dSettingsDialog.CreateDialog(AOwner,AComponent,ARegistry);
  try
    Result:=Dialog.ShowModal=mrOk;
    if Result then
      Dialog.SaveModel;
  finally
    Dialog.Free;
  end;
end;
end.
