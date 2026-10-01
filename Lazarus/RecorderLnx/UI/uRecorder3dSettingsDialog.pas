unit uRecorder3dSettingsDialog;
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses Classes,SysUtils,Forms,Controls,StdCtrls,ExtCtrls,ComCtrls,Dialogs,Grids,
  Graphics,uRecorder3dModel,uRecorderTags;
function ShowRecorder3dSettingsDialog(AOwner:TComponent;
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry):Boolean;
implementation
uses Math,LazUTF8,u3dScene,u3dMeshTopology,u3dLegacySceneLoader;
type
  TRecorder3dSettingsDialog=class(TForm)
  private
    fComponent:TRecorder3dComponent; fRegistry:TRecorderTagRegistry;
    fScene:T3dScene; fSelectedNode:T3dNode; fTopology:T3dMeshTopology;
    fRelations:T3dTopologyRelations;
    fFileEdit,fSearchEdit,fNormalLengthEdit:TEdit; fTree:TTreeView;
    fChecks:array[0..4] of TCheckBox;
    fUseObjectSettings:TCheckBox; fObjectChecks:array[0..3] of TCheckBox;
    fBindings:array[TRecorder3dBindingSlot] of TComboBox;
    fSelectedTagIds:array[TRecorder3dBindingSlot] of TRecorderTagId;
    fGrid:TStringGrid; fPopulating:Boolean;
    procedure Browse(Sender:TObject); procedure SearchChanged(Sender:TObject);
    procedure BindingChanged(Sender:TObject); procedure TreeChanged(Sender:TObject);
    procedure GridSelect(Sender:TObject; ACol,ARow:Integer; var CanSelect:Boolean);
    procedure GridPrepare(Sender:TObject; ACol,ARow:Integer; AState:TGridDrawState);
    procedure ReloadTree; procedure PopulateBindings(const AFilter:string);
    procedure LoadModel; procedure SaveModel; procedure SaveSelectedNode;
    procedure LoadSelectedNode; procedure FillVertexGrid;
    function ResolveMesh(ANode:T3dNode):T3dMeshData;
    function Matches(ATag:TRecorderTag; const AFilter:string):Boolean;
  public
    constructor CreateDialog(AOwner:TComponent; AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry); destructor Destroy; override;
  end;

constructor TRecorder3dSettingsDialog.CreateDialog(AOwner:TComponent;
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
const Names:array[TRecorder3dBindingSlot] of string=('Координата X:','Координата Y:',
  'Координата Z:','Цвет:','Длина нормалей:');
      ObjNames:array[0..3] of string=('Полигоны','Сетка','Точки','Нормали');
var L:TLabel; B:TButton; C:TRecorder3dBindingSlot; I,Y:Integer; Pages:TPageControl; Tab:TTabSheet;
begin inherited CreateNew(AOwner,1); fComponent:=AComponent; fRegistry:=ARegistry;
  Caption:='Редактор 3D-сцены'; Position:=poOwnerFormCenter; SetBounds(0,0,1040,780);
  L:=TLabel.Create(Self); L.Parent:=Self; L.SetBounds(12,14,90,20); L.Caption:='Файл сцены:';
  fFileEdit:=TEdit.Create(Self); fFileEdit.Parent:=Self; fFileEdit.SetBounds(105,10,700,25);
  B:=TButton.Create(Self); B.Parent:=Self; B.SetBounds(815,9,90,27); B.Caption:='Обзор...'; B.OnClick:=@Browse;
  fTree:=TTreeView.Create(Self); fTree.Parent:=Self; fTree.SetBounds(12,48,320,650); fTree.OnSelectionChanged:=@TreeChanged;
  for I:=0 to 4 do begin fChecks[I]:=TCheckBox.Create(Self); fChecks[I].Parent:=Self;
    fChecks[I].SetBounds(350+I*120,48,115,24); end;
  fChecks[0].Caption:='Полигоны'; fChecks[1].Caption:='Сетка'; fChecks[2].Caption:='Точки';
  fChecks[3].Caption:='Нормали'; fChecks[4].Caption:='Оси сцены';
  L:=TLabel.Create(Self); L.Parent:=Self; L.SetBounds(350,82,155,20); L.Caption:='Длина нормалей:';
  fNormalLengthEdit:=TEdit.Create(Self); fNormalLengthEdit.Parent:=Self; fNormalLengthEdit.SetBounds(505,78,90,25);
  fUseObjectSettings:=TCheckBox.Create(Self); fUseObjectSettings.Parent:=Self;
  fUseObjectSettings.SetBounds(350,112,220,24); fUseObjectSettings.Caption:='Настройки выбранного объекта';
  for I:=0 to 3 do begin fObjectChecks[I]:=TCheckBox.Create(Self); fObjectChecks[I].Parent:=Self;
    fObjectChecks[I].SetBounds(350+I*120,140,115,24); fObjectChecks[I].Caption:=ObjNames[I]; end;
  L:=TLabel.Create(Self); L.Parent:=Self; L.SetBounds(350,176,100,20); L.Caption:='Поиск тега:';
  fSearchEdit:=TEdit.Create(Self); fSearchEdit.Parent:=Self; fSearchEdit.SetBounds(450,172,455,25); fSearchEdit.OnChange:=@SearchChanged;
  Y:=204; for C:=Low(C) to High(C) do begin L:=TLabel.Create(Self); L.Parent:=Self;
    L.SetBounds(350,Y+4,145,20); L.Caption:=Names[C]; fBindings[C]:=TComboBox.Create(Self);
    fBindings[C].Parent:=Self; fBindings[C].Style:=csDropDownList; fBindings[C].Tag:=Ord(C);
    fBindings[C].OnChange:=@BindingChanged; fBindings[C].SetBounds(495,Y,410,25); Inc(Y,32); end;
  Pages:=TPageControl.Create(Self); Pages.Parent:=Self; Pages.SetBounds(350,372,660,326);
  Tab:=TTabSheet.Create(Pages); Tab.PageControl:=Pages; Tab.Caption:='Вершины';
  fGrid:=TStringGrid.Create(Tab); fGrid.Parent:=Tab; fGrid.Align:=alClient; fGrid.FixedRows:=1;
  fGrid.ColCount:=7; fGrid.RowCount:=1; fGrid.Options:=fGrid.Options+[goRowSelect];
  fGrid.Cells[0,0]:='№'; fGrid.Cells[1,0]:='ID вершины'; fGrid.Cells[2,0]:='X';
  fGrid.Cells[3,0]:='Y'; fGrid.Cells[4,0]:='Z'; fGrid.Cells[5,0]:='Копий'; fGrid.Cells[6,0]:='Полигоны';
  fGrid.ColWidths[0]:=42; fGrid.ColWidths[1]:=85; fGrid.ColWidths[2]:=75;
  fGrid.ColWidths[3]:=75; fGrid.ColWidths[4]:=75; fGrid.ColWidths[5]:=55; fGrid.ColWidths[6]:=190;
  fGrid.OnSelectCell:=@GridSelect; fGrid.OnPrepareCanvas:=@GridPrepare;
  B:=TButton.Create(Self); B.Parent:=Self; B.SetBounds(830,715,80,30); B.Caption:='OK'; B.ModalResult:=mrOk;
  B:=TButton.Create(Self); B.Parent:=Self; B.SetBounds(920,715,80,30); B.Caption:='Отмена'; B.ModalResult:=mrCancel;
  LoadModel;
end;

destructor TRecorder3dSettingsDialog.Destroy;
begin fScene.Free; inherited Destroy; end;
function TRecorder3dSettingsDialog.Matches(ATag:TRecorderTag; const AFilter:string):Boolean;
var F:string; begin F:=UTF8LowerCase(Trim(AFilter)); Result:=(F='') or
  (Pos(F,UTF8LowerCase(ATag.Name))>0) or (Pos(F,UTF8LowerCase(ATag.Address))>0) or
  (Pos(F,UTF8LowerCase(ATag.Description))>0); end;
procedure TRecorder3dSettingsDialog.PopulateBindings(const AFilter:string);
var C:TRecorder3dBindingSlot; I,Sel:Integer; T:TRecorderTag;
begin fPopulating:=True; try for C:=Low(C) to High(C) do begin fBindings[C].Clear;
    fBindings[C].Items.AddObject('(нет)',nil); if fRegistry<>nil then for I:=0 to fRegistry.TagCount-1 do begin
      T:=fRegistry.Tags[I]; if Matches(T,AFilter) then
        fBindings[C].Items.AddObject(T.Name+' ['+T.Address+']',TObject(PtrUInt(T.Id))); end;
    Sel:=0; for I:=1 to fBindings[C].Items.Count-1 do if
      TRecorderTagId(PtrUInt(fBindings[C].Items.Objects[I]))=fSelectedTagIds[C] then begin Sel:=I; Break; end;
    fBindings[C].ItemIndex:=Sel; end; finally fPopulating:=False; end; end;
procedure TRecorder3dSettingsDialog.BindingChanged(Sender:TObject);
var B:TComboBox; begin if fPopulating then Exit; B:=TComboBox(Sender);
  if B.ItemIndex>=0 then fSelectedTagIds[TRecorder3dBindingSlot(B.Tag)]:=
    TRecorderTagId(PtrUInt(B.Items.Objects[B.ItemIndex])); end;
procedure TRecorder3dSettingsDialog.SearchChanged(Sender:TObject); begin PopulateBindings(fSearchEdit.Text); end;
procedure TRecorder3dSettingsDialog.Browse(Sender:TObject);
var D:TOpenDialog; begin D:=TOpenDialog.Create(Self); try D.Filter:='Сцены OBR|*.obr;*.OBR|Все файлы|*.*';
  if D.Execute then begin fFileEdit.Text:=D.FileName; try ReloadTree except on E:Exception do
    MessageDlg('Ошибка сцены',E.Message,mtError,[mbOK],0); end; end; finally D.Free; end; end;

procedure TRecorder3dSettingsDialog.ReloadTree;
var R:I3dSceneLoader; I,J:Integer; P,N:TTreeNode; O:TRecorder3dNodeRenderOverride;
begin SaveSelectedNode; FreeAndNil(fScene); fSelectedNode:=nil; fTree.Items.Clear;
  if not FileExists(fFileEdit.Text) then begin FillVertexGrid; Exit; end;
  R:=T3dLegacySceneLoader.Create; fScene:=R.LoadScene(fFileEdit.Text); R:=nil;
  for I:=0 to fComponent.NodeRenderOverrideCount-1 do begin O:=fComponent.NodeRenderOverrides[I];
    fSelectedNode:=fScene.FindNode(O.NodeId); if fSelectedNode<>nil then begin fSelectedNode.HasRenderOverride:=True;
      fSelectedNode.DrawFillOverride:=O.DrawFill; fSelectedNode.DrawWireframeOverride:=O.DrawWireframe;
      fSelectedNode.DrawPointsOverride:=O.DrawPoints; fSelectedNode.DrawNormalsOverride:=O.DrawNormals; end; end;
  fSelectedNode:=nil;
  for I:=0 to High(fScene.Nodes) do begin P:=nil; for J:=0 to fTree.Items.Count-1 do
    if PtrUInt(fTree.Items[J].Data)=fScene.Nodes[I].ParentId then begin P:=fTree.Items[J]; Break; end;
    N:=fTree.Items.AddChild(P,fScene.Nodes[I].Name); N.Data:=Pointer(PtrUInt(fScene.Nodes[I].Id));
    if fScene.Nodes[I].Id=fComponent.BindingTargetNodeId then fTree.Selected:=N; end;
  if (fTree.Selected=nil) and (fTree.Items.Count>0) then fTree.Selected:=fTree.Items[0];
  TreeChanged(fTree);
end;

procedure TRecorder3dSettingsDialog.SaveSelectedNode;
begin if fSelectedNode=nil then Exit; fSelectedNode.HasRenderOverride:=fUseObjectSettings.Checked;
  fSelectedNode.DrawFillOverride:=fObjectChecks[0].Checked; fSelectedNode.DrawWireframeOverride:=fObjectChecks[1].Checked;
  fSelectedNode.DrawPointsOverride:=fObjectChecks[2].Checked; fSelectedNode.DrawNormalsOverride:=fObjectChecks[3].Checked; end;
procedure TRecorder3dSettingsDialog.LoadSelectedNode;
var I:Integer; begin for I:=0 to 3 do fObjectChecks[I].Enabled:=fSelectedNode<>nil;
  fUseObjectSettings.Enabled:=fSelectedNode<>nil; if fSelectedNode=nil then Exit;
  fUseObjectSettings.Checked:=fSelectedNode.HasRenderOverride;
  if fSelectedNode.HasRenderOverride then begin fObjectChecks[0].Checked:=fSelectedNode.DrawFillOverride;
    fObjectChecks[1].Checked:=fSelectedNode.DrawWireframeOverride; fObjectChecks[2].Checked:=fSelectedNode.DrawPointsOverride;
    fObjectChecks[3].Checked:=fSelectedNode.DrawNormalsOverride; end else
    for I:=0 to 3 do fObjectChecks[I].Checked:=fChecks[I].Checked; end;
procedure TRecorder3dSettingsDialog.TreeChanged(Sender:TObject);
begin SaveSelectedNode; fSelectedNode:=nil; if (fScene<>nil) and (fTree.Selected<>nil) then
  fSelectedNode:=fScene.FindNode(QWord(PtrUInt(fTree.Selected.Data)));
  LoadSelectedNode; FillVertexGrid; end;
function TRecorder3dSettingsDialog.ResolveMesh(ANode:T3dNode):T3dMeshData;
var N:T3dNode; begin Result:=nil; if ANode=nil then Exit; Result:=ANode.Mesh;
  if (Result<>nil) and (Length(Result.Positions)=0) and (Result.SourceNodeId<>0) then begin
    N:=fScene.FindNode(Result.SourceNodeId); if N<>nil then Result:=N.Mesh; end; end;
function IndexesText(const A:T3dIndexArray):string;
var I:Integer; begin Result:=''; for I:=0 to High(A) do begin if Result<>'' then Result:=Result+', '; Result:=Result+IntToStr(A[I]); end; end;
procedure TRecorder3dSettingsDialog.FillVertexGrid;
var M:T3dMeshData; I:Integer; V:T3dLogicalVertexInfo;
begin M:=ResolveMesh(fSelectedNode); fTopology:=BuildMeshTopology(M); SetLength(fRelations,0);
  fGrid.RowCount:=Max(1,Length(fTopology.Vertices)+1); for I:=0 to High(fTopology.Vertices) do begin V:=fTopology.Vertices[I];
    fGrid.Cells[0,I+1]:=IntToStr(I); fGrid.Cells[1,I+1]:=IntToStr(V.StableId);
    fGrid.Cells[2,I+1]:=FloatToStr(V.Position.X); fGrid.Cells[3,I+1]:=FloatToStr(V.Position.Y);
    fGrid.Cells[4,I+1]:=FloatToStr(V.Position.Z); fGrid.Cells[5,I+1]:=IntToStr(V.CornerCount);
    fGrid.Cells[6,I+1]:=IndexesText(V.FaceIndexes); end; fGrid.Invalidate; end;
procedure TRecorder3dSettingsDialog.GridSelect(Sender:TObject; ACol,ARow:Integer; var CanSelect:Boolean);
begin if ARow>0 then fRelations:=ClassifyLogicalVertices(fTopology,ARow-1) else SetLength(fRelations,0); fGrid.Invalidate; end;
procedure TRecorder3dSettingsDialog.GridPrepare(Sender:TObject; ACol,ARow:Integer; AState:TGridDrawState);
begin if (ARow<=0) or (ARow-1>High(fRelations)) then Exit; case fRelations[ARow-1] of
  trPrimary:fGrid.Canvas.Brush.Color:=$0080E8FF; trAdjacent:fGrid.Canvas.Brush.Color:=$00D0FFD0; end; end;

procedure TRecorder3dSettingsDialog.LoadModel;
var C:TRecorder3dBindingSlot; begin fFileEdit.Text:=fComponent.SceneFileName;
  fChecks[0].Checked:=fComponent.DrawFill; fChecks[1].Checked:=fComponent.DrawWireframe;
  fChecks[2].Checked:=fComponent.DrawPoints; fChecks[3].Checked:=fComponent.DrawNormals;
  fChecks[4].Checked:=fComponent.ShowAxes; fNormalLengthEdit.Text:=FloatToStr(fComponent.NormalLength);
  for C:=Low(C) to High(C) do fSelectedTagIds[C]:=fComponent.BindingTagIds[C];
  if fSelectedTagIds[r3bNormalLength]=0 then fSelectedTagIds[r3bNormalLength]:=fComponent.NormalLengthTagId;
  PopulateBindings(''); try ReloadTree except on E:Exception do MessageDlg('Сцена не загружена',E.Message,mtWarning,[mbOK],0); end; end;
procedure TRecorder3dSettingsDialog.SaveModel;
var C:TRecorder3dBindingSlot; I:Integer; Id:TRecorderTagId; T:TRecorderTag; O:TRecorder3dNodeRenderOverride;
begin SaveSelectedNode; fComponent.SceneFileName:=fFileEdit.Text; fComponent.DrawFill:=fChecks[0].Checked;
  fComponent.DrawWireframe:=fChecks[1].Checked; fComponent.DrawPoints:=fChecks[2].Checked;
  fComponent.DrawNormals:=fChecks[3].Checked; fComponent.ShowAxes:=fChecks[4].Checked;
  fComponent.NormalLength:=StrToFloatDef(fNormalLengthEdit.Text,0.25);
  if fTree.Selected<>nil then fComponent.BindingTargetNodeId:=QWord(PtrUInt(fTree.Selected.Data));
  for C:=Low(C) to High(C) do begin Id:=fSelectedTagIds[C]; fComponent.BindingTagIds[C]:=Id;
    T:=nil; if (fRegistry<>nil) and (Id<>0) then T:=fRegistry.FindById(Id);
    if T=nil then fComponent.BindingTagNames[C]:='' else fComponent.BindingTagNames[C]:=T.Name; end;
  fComponent.NormalLengthTagId:=fComponent.BindingTagIds[r3bNormalLength];
  fComponent.NormalLengthTagName:=fComponent.BindingTagNames[r3bNormalLength];
  fComponent.ClearNodeRenderOverrides; if fScene<>nil then for I:=0 to High(fScene.Nodes) do
    if fScene.Nodes[I].HasRenderOverride then begin O:=fComponent.AddNodeRenderOverride; O.NodeId:=fScene.Nodes[I].Id;
      O.DrawFill:=fScene.Nodes[I].DrawFillOverride; O.DrawWireframe:=fScene.Nodes[I].DrawWireframeOverride;
      O.DrawPoints:=fScene.Nodes[I].DrawPointsOverride; O.DrawNormals:=fScene.Nodes[I].DrawNormalsOverride; end; end;
function ShowRecorder3dSettingsDialog(AOwner:TComponent; AComponent:TRecorder3dComponent;
  ARegistry:TRecorderTagRegistry):Boolean;
var D:TRecorder3dSettingsDialog;
begin D:=TRecorder3dSettingsDialog.CreateDialog(AOwner,AComponent,ARegistry); try
  Result:=D.ShowModal=mrOk; if Result then D.SaveModel; finally D.Free; end; end;
end.
