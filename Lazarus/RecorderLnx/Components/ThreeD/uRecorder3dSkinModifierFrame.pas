unit uRecorder3dSkinModifierFrame;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Designer-backed editor for the Skin modifier. The parent 3D dialog supplies
  the current mesh/vertex and live-scene callbacks; this frame owns all bone,
  tag-picker and influence-list presentation. }

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Grids, Spin, Dialogs,
  uRecorder3dModel, uRecorderTags;

type
  TRecorder3dAddSkinBoneEvent=procedure(AMeshNodeId:QWord;
    ALogicalVertexId:LongWord; const AName:string; AWeight:Single;
    out AHelperNodeId:QWord) of object;
  TRecorder3dDeleteSkinBoneEvent=procedure(AHelperNodeId:QWord) of object;
  TRecorder3dRenameSkinBoneEvent=procedure(AHelperNodeId:QWord;
    const AName:string) of object;
  TRecorder3dSetSkinInfluenceEvent=procedure(AHelperNodeId,AMeshNodeId:QWord;
    ALogicalVertexId:LongWord; AWeight:Single) of object;
  TRecorder3dRemoveSkinInfluenceEvent=procedure(AHelperNodeId,AMeshNodeId:QWord;
    ALogicalVertexId:LongWord) of object;

  TRecorder3dSkinModifierFrame=class(TFrame)
  published
    pnlBones:TPanel;
    lblBones,lblBoneName,lblTagSearch,lblTagX,lblTagY,lblTagZ,
      lblInfluences,lblState,lblWeight:TLabel;
    lbBones:TListBox;
    pnlBoneButtons,pnlInfluenceButtons,pnlBoneProperties:TPanel;
    btnAddBone,btnDeleteBone,btnResetBones,btnBindVertex,btnRemoveVertex:TButton;
    edBoneName,edTagSearch:TEdit;
    cbTagX,cbTagY,cbTagZ,cbModeX,cbModeY,cbModeZ:TComboBox;
    chkUseInactive:TCheckBox;
    splBones:TSplitter;
    sgInfluences:TStringGrid;
    seWeight:TFloatSpinEdit;
    procedure BoneSelectionChange(Sender:TObject);
    procedure AddBoneClick(Sender:TObject);
    procedure DeleteBoneClick(Sender:TObject);
    procedure ResetBonesClick(Sender:TObject);
    procedure BoneNameEditingDone(Sender:TObject);
    procedure TagSearchChange(Sender:TObject);
    procedure TagChange(Sender:TObject);
    procedure ModeChange(Sender:TObject);
    procedure UseInactiveChange(Sender:TObject);
    procedure BindVertexClick(Sender:TObject);
    procedure RemoveVertexClick(Sender:TObject);
    procedure InfluenceSelection(Sender:TObject; ACol,ARow:Integer;
      var CanSelect:Boolean);
  private
    fComponent:TRecorder3dComponent;
    fRegistry:TRecorderTagRegistry;
    fMeshNodeId:QWord;
    fLogicalVertexId:LongWord;
    fHasVertex:Boolean;
    fLoading:Boolean;
    fOnChanged:TNotifyEvent;
    fOnAddBone:TRecorder3dAddSkinBoneEvent;
    fOnDeleteBone:TRecorder3dDeleteSkinBoneEvent;
    fOnResetBones:TNotifyEvent;
    fOnRenameBone:TRecorder3dRenameSkinBoneEvent;
    fOnSetInfluence:TRecorder3dSetSkinInfluenceEvent;
    fOnRemoveInfluence:TRecorder3dRemoveSkinInfluenceEvent;
    function SelectedBone:TRecorder3dSkinBone;
    function AxisCombo(AAxis:TRecorder3dSkinAxis):TComboBox;
    function ModeCombo(AAxis:TRecorder3dSkinAxis):TComboBox;
    function TagMatches(ATag:TRecorderTag; const AFilter:string):Boolean;
    procedure PopulateTagCombo(AAxis:TRecorder3dSkinAxis;
      const AFilter:string);
    procedure PopulateTagCombos;
    procedure LoadSelectedBone;
    procedure LoadInfluences;
    procedure UpdateActions;
    procedure Changed;
  public
    constructor Create(AOwner:TComponent); override;
    procedure Configure(AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry);
    procedure SetSelectedVertex(AMeshNodeId:QWord;
      ALogicalVertexId:LongWord; AHasVertex:Boolean);
    procedure Reload;
    property OnChanged:TNotifyEvent read fOnChanged write fOnChanged;
    property OnAddBone:TRecorder3dAddSkinBoneEvent read fOnAddBone write fOnAddBone;
    property OnDeleteBone:TRecorder3dDeleteSkinBoneEvent read fOnDeleteBone write fOnDeleteBone;
    property OnResetBones:TNotifyEvent read fOnResetBones write fOnResetBones;
    property OnRenameBone:TRecorder3dRenameSkinBoneEvent read fOnRenameBone write fOnRenameBone;
    property OnSetInfluence:TRecorder3dSetSkinInfluenceEvent read fOnSetInfluence write fOnSetInfluence;
    property OnRemoveInfluence:TRecorder3dRemoveSkinInfluenceEvent read fOnRemoveInfluence write fOnRemoveInfluence;
  end;

implementation

uses
  Math, LazUTF8;

{$R *.lfm}

constructor TRecorder3dSkinModifierFrame.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  cbTagX.Tag:=Ord(r3sX);
  cbTagY.Tag:=Ord(r3sY);
  cbTagZ.Tag:=Ord(r3sZ);
  cbModeX.Tag:=Ord(r3sX);
  cbModeY.Tag:=Ord(r3sY);
  cbModeZ.Tag:=Ord(r3sZ);
  cbModeX.Items.Add('Текущее');
  cbModeX.Items.Add('Оценка тега');
  cbModeY.Items.Assign(cbModeX.Items);
  cbModeZ.Items.Assign(cbModeX.Items);
  UseInactiveChange(chkUseInactive);
  sgInfluences.Cells[0,0]:='Объект';
  sgInfluences.Cells[1,0]:='Вершина';
  sgInfluences.Cells[2,0]:='Вес';
  sgInfluences.ColWidths[0]:=82;
  sgInfluences.ColWidths[1]:=82;
  sgInfluences.ColWidths[2]:=64;
  UpdateActions;
end;

function TRecorder3dSkinModifierFrame.ModeCombo(
  AAxis:TRecorder3dSkinAxis):TComboBox;
begin
  case AAxis of
    r3sX:Result:=cbModeX;
    r3sY:Result:=cbModeY;
    else Result:=cbModeZ;
  end;
end;

procedure TRecorder3dSkinModifierFrame.ResetBonesClick(Sender:TObject);
begin
  if Assigned(fOnResetBones) then
    fOnResetBones(Self);
end;

procedure TRecorder3dSkinModifierFrame.Configure(
  AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
begin
  fComponent:=AComponent;
  fRegistry:=ARegistry;
  Reload;
end;

procedure TRecorder3dSkinModifierFrame.SetSelectedVertex(
  AMeshNodeId:QWord; ALogicalVertexId:LongWord; AHasVertex:Boolean);
begin
  fMeshNodeId:=AMeshNodeId;
  fLogicalVertexId:=ALogicalVertexId;
  fHasVertex:=AHasVertex;
  UpdateActions;
end;

function TRecorder3dSkinModifierFrame.SelectedBone:TRecorder3dSkinBone;
begin
  Result:=nil;
  if (fComponent=nil) or (lbBones.ItemIndex<0) then
    Exit;
  Result:=fComponent.FindSkinBone(QWord(PtrUInt(
    lbBones.Items.Objects[lbBones.ItemIndex])));
end;

function TRecorder3dSkinModifierFrame.AxisCombo(
  AAxis:TRecorder3dSkinAxis):TComboBox;
begin
  case AAxis of
    r3sX:Result:=cbTagX;
    r3sY:Result:=cbTagY;
    else Result:=cbTagZ;
  end;
end;

function TRecorder3dSkinModifierFrame.TagMatches(ATag:TRecorderTag;
  const AFilter:string):Boolean;
var
  SearchText:string;
begin
  Result:=ATag<>nil;
  if not Result or (AFilter='') then
    Exit;
  SearchText:=UTF8LowerCase(ATag.Name+' '+ATag.Address+' '+ATag.Description);
  Result:=Pos(AFilter,SearchText)>0;
end;

procedure TRecorder3dSkinModifierFrame.UseInactiveChange(Sender:TObject);
var
  Axis:TRecorder3dSkinAxis;
begin
  for Axis:=Low(Axis) to High(Axis) do
    if chkUseInactive.Checked then
      AxisCombo(Axis).Style:=csDropDown
    else
      AxisCombo(Axis).Style:=csDropDownList;
  if fComponent<>nil then
    fComponent.UseInactiveTag:=chkUseInactive.Checked;
end;

procedure TRecorder3dSkinModifierFrame.PopulateTagCombo(
  AAxis:TRecorder3dSkinAxis; const AFilter:string);
var
  Combo:TComboBox;
  Bone:TRecorder3dSkinBone;
  I,SelectedIndex:Integer;
  TagItem:TRecorderTag;
  SelectedId:TRecorderTagId;
begin
  Combo:=AxisCombo(AAxis);
  Bone:=SelectedBone;
  SelectedId:=0;
  if Bone<>nil then
    SelectedId:=Bone.TagIds[AAxis];
  Combo.Items.BeginUpdate;
  try
    Combo.Items.Clear;
    Combo.Items.AddObject('(нет)',nil);
    SelectedIndex:=0;
    if fRegistry<>nil then
      for I:=0 to fRegistry.TagCount-1 do
      begin
        TagItem:=fRegistry.Tags[I];
        if not TagMatches(TagItem,AFilter) then
          Continue;
        Combo.Items.AddObject(TagItem.Name,TagItem);
        if TagItem.Id=SelectedId then
          SelectedIndex:=Combo.Items.Count-1;
      end;
    Combo.ItemIndex:=SelectedIndex;
    if (SelectedIndex=0) and (Bone<>nil) and chkUseInactive.Checked and
      (Trim(Bone.TagNames[AAxis])<>'') then
    begin
      Combo.ItemIndex:=-1;
      Combo.Text:=Bone.TagNames[AAxis];
    end;
  finally
    Combo.Items.EndUpdate;
  end;
end;

procedure TRecorder3dSkinModifierFrame.PopulateTagCombos;
var
  Axis:TRecorder3dSkinAxis;
  Filter:string;
begin
  Filter:=UTF8LowerCase(Trim(edTagSearch.Text));
  for Axis:=Low(Axis) to High(Axis) do
    PopulateTagCombo(Axis,Filter);
end;

procedure TRecorder3dSkinModifierFrame.Reload;
var
  I,SelectedIndex:Integer;
  SelectedId:QWord;
  Bone:TRecorder3dSkinBone;
begin
  chkUseInactive.Checked:=(fComponent<>nil) and fComponent.UseInactiveTag;
  UseInactiveChange(chkUseInactive);
  SelectedId:=0;
  Bone:=SelectedBone;
  if Bone<>nil then
    SelectedId:=Bone.HelperNodeId;
  fLoading:=True;
  try
    lbBones.Items.Clear;
    SelectedIndex:=-1;
    if fComponent<>nil then
      for I:=0 to fComponent.SkinBoneCount-1 do
      begin
        Bone:=fComponent.SkinBones[I];
        lbBones.Items.AddObject(Bone.Name,TObject(PtrUInt(Bone.HelperNodeId)));
        if Bone.HelperNodeId=SelectedId then
          SelectedIndex:=lbBones.Items.Count-1;
      end;
    if (SelectedIndex<0) and (lbBones.Items.Count>0) then
      SelectedIndex:=0;
    lbBones.ItemIndex:=SelectedIndex;
    LoadSelectedBone;
  finally
    fLoading:=False;
  end;
  UpdateActions;
end;

procedure TRecorder3dSkinModifierFrame.LoadSelectedBone;
var
  Bone:TRecorder3dSkinBone;
  Axis:TRecorder3dSkinAxis;
begin
  Bone:=SelectedBone;
  if Bone=nil then
    edBoneName.Clear
  else
    edBoneName.Text:=Bone.Name;
  PopulateTagCombos;
  for Axis:=Low(Axis) to High(Axis) do
    if Bone=nil then
      ModeCombo(Axis).ItemIndex:=Ord(r3tvCurrentValue)
    else
      ModeCombo(Axis).ItemIndex:=Ord(Bone.TagValueModes[Axis]);
  LoadInfluences;
end;

procedure TRecorder3dSkinModifierFrame.LoadInfluences;
var
  I,Row:Integer;
  Bone:TRecorder3dSkinBone;
  Binding:TRecorder3dSkinBinding;
begin
  sgInfluences.RowCount:=1;
  Bone:=SelectedBone;
  if (Bone=nil) or (fComponent=nil) then
    Exit;
  Row:=1;
  for I:=0 to fComponent.SkinBindingCount-1 do
  begin
    Binding:=fComponent.SkinBindings[I];
    if Binding.HelperNodeId<>Bone.HelperNodeId then
      Continue;
    sgInfluences.RowCount:=Row+1;
    sgInfluences.Cells[0,Row]:=IntToStr(Binding.MeshNodeId);
    sgInfluences.Cells[1,Row]:=IntToStr(Binding.LogicalVertexId);
    sgInfluences.Cells[2,Row]:=FormatFloat('0.###',Binding.Weight);
    sgInfluences.Objects[0,Row]:=TObject(PtrUInt(I+1));
    Inc(Row);
  end;
end;

procedure TRecorder3dSkinModifierFrame.UpdateActions;
var
  HasBone,HasInfluence:Boolean;
begin
  HasBone:=SelectedBone<>nil;
  HasInfluence:=HasBone and (sgInfluences.Row>0) and
    (sgInfluences.Row<sgInfluences.RowCount);
  btnAddBone.Enabled:=fHasVertex and Assigned(fOnAddBone);
  btnDeleteBone.Enabled:=HasBone and Assigned(fOnDeleteBone);
  btnResetBones.Enabled:=(fComponent<>nil) and
    (fComponent.SkinBoneCount>0) and Assigned(fOnResetBones);
  edBoneName.Enabled:=HasBone;
  edTagSearch.Enabled:=HasBone;
  cbTagX.Enabled:=HasBone;
  cbTagY.Enabled:=HasBone;
  cbTagZ.Enabled:=HasBone;
  cbModeX.Enabled:=HasBone;
  cbModeY.Enabled:=HasBone;
  cbModeZ.Enabled:=HasBone;
  sgInfluences.Enabled:=HasBone;
  seWeight.Enabled:=fHasVertex and HasBone;
  btnBindVertex.Enabled:=fHasVertex and HasBone and Assigned(fOnSetInfluence);
  btnRemoveVertex.Enabled:=HasInfluence and Assigned(fOnRemoveInfluence);
  if not fHasVertex then
    lblState.Caption:='Выберите вершину объекта для добавления влияния.'
  else if not HasBone then
    lblState.Caption:='Добавьте или выберите кость.'
  else
    lblState.Caption:='';
end;

procedure TRecorder3dSkinModifierFrame.ModeChange(Sender:TObject);
var
  Axis:TRecorder3dSkinAxis;
  Combo:TComboBox;
  Bone:TRecorder3dSkinBone;
begin
  if fLoading or not (Sender is TComboBox) then
    Exit;
  Combo:=TComboBox(Sender);
  Axis:=TRecorder3dSkinAxis(Combo.Tag);
  Bone:=SelectedBone;
  if (Bone=nil) or (Combo.ItemIndex<Ord(Low(TRecorder3dTagValueMode))) or
    (Combo.ItemIndex>Ord(High(TRecorder3dTagValueMode))) then
    Exit;
  Bone.TagValueModes[Axis]:=TRecorder3dTagValueMode(Combo.ItemIndex);
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.Changed;
begin
  if not fLoading and Assigned(fOnChanged) then
    fOnChanged(Self);
end;

procedure TRecorder3dSkinModifierFrame.BoneSelectionChange(Sender:TObject);
begin
  if fLoading then
    Exit;
  fLoading:=True;
  try
    LoadSelectedBone;
  finally
    fLoading:=False;
  end;
  UpdateActions;
end;

procedure TRecorder3dSkinModifierFrame.AddBoneClick(Sender:TObject);
var
  HelperId:QWord;
  Bone:TRecorder3dSkinBone;
  BoneName:string;
begin
  if not fHasVertex or not Assigned(fOnAddBone) then
    Exit;
  BoneName:='Кость '+IntToStr(lbBones.Items.Count+1);
  HelperId:=0;
  fOnAddBone(fMeshNodeId,fLogicalVertexId,BoneName,seWeight.Value,HelperId);
  if HelperId=0 then
    Exit;
  Bone:=fComponent.EnsureSkinBone(HelperId,BoneName);
  Bone.Name:=BoneName;
  Reload;
  lbBones.ItemIndex:=lbBones.Items.IndexOfObject(TObject(PtrUInt(HelperId)));
  BoneSelectionChange(lbBones);
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.DeleteBoneClick(Sender:TObject);
var
  Bone:TRecorder3dSkinBone;
begin
  Bone:=SelectedBone;
  if (Bone=nil) or not Assigned(fOnDeleteBone) then
    Exit;
  if MessageDlg('Удаление кости',
    Format('Удалить кость «%s» и все ее влияния на вершины?',[Bone.Name]),
    mtConfirmation,[mbYes,mbNo],0)<>mrYes then
    Exit;
  fOnDeleteBone(Bone.HelperNodeId);
  Reload;
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.BoneNameEditingDone(Sender:TObject);
var
  Bone:TRecorder3dSkinBone;
  BoneName:string;
begin
  if fLoading then
    Exit;
  Bone:=SelectedBone;
  BoneName:=Trim(edBoneName.Text);
  if (Bone=nil) or (BoneName='') then
    Exit;
  Bone.Name:=BoneName;
  lbBones.Items[lbBones.ItemIndex]:=BoneName;
  if Assigned(fOnRenameBone) then
    fOnRenameBone(Bone.HelperNodeId,BoneName);
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.TagSearchChange(Sender:TObject);
begin
  if fLoading then
    Exit;
  fLoading:=True;
  try
    PopulateTagCombos;
  finally
    fLoading:=False;
  end;
end;

procedure TRecorder3dSkinModifierFrame.TagChange(Sender:TObject);
var
  Axis:TRecorder3dSkinAxis;
  Combo:TComboBox;
  Bone:TRecorder3dSkinBone;
  TagItem:TRecorderTag;
begin
  if fLoading or not (Sender is TComboBox) then
    Exit;
  Combo:=TComboBox(Sender);
  Axis:=TRecorder3dSkinAxis(Combo.Tag);
  Bone:=SelectedBone;
  if Bone=nil then
    Exit;
  TagItem:=nil;
  if (Combo.ItemIndex>0) and (Combo.Items.Objects[Combo.ItemIndex] is TRecorderTag) then
    TagItem:=TRecorderTag(Combo.Items.Objects[Combo.ItemIndex]);
  if TagItem=nil then
  begin
    Bone.TagIds[Axis]:=0;
    if chkUseInactive.Checked then
      Bone.TagNames[Axis]:=Trim(Combo.Text)
    else
      Bone.TagNames[Axis]:='';
  end
  else
  begin
    Bone.TagIds[Axis]:=TagItem.Id;
    Bone.TagNames[Axis]:=TagItem.Name;
  end;
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.BindVertexClick(Sender:TObject);
var
  Bone:TRecorder3dSkinBone;
begin
  Bone:=SelectedBone;
  if not fHasVertex or (Bone=nil) or not Assigned(fOnSetInfluence) then
    Exit;
  fOnSetInfluence(Bone.HelperNodeId,fMeshNodeId,fLogicalVertexId,
    seWeight.Value);
  LoadInfluences;
  UpdateActions;
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.RemoveVertexClick(Sender:TObject);
var
  Bone:TRecorder3dSkinBone;
  BindingIndex:Integer;
  Binding:TRecorder3dSkinBinding;
begin
  Bone:=SelectedBone;
  if (Bone=nil) or (sgInfluences.Row<=0) or
    not Assigned(fOnRemoveInfluence) then
    Exit;
  BindingIndex:=PtrUInt(sgInfluences.Objects[0,sgInfluences.Row])-1;
  if (BindingIndex<0) or (BindingIndex>=fComponent.SkinBindingCount) then
    Exit;
  Binding:=fComponent.SkinBindings[BindingIndex];
  fOnRemoveInfluence(Bone.HelperNodeId,Binding.MeshNodeId,
    Binding.LogicalVertexId);
  LoadInfluences;
  UpdateActions;
  Changed;
end;

procedure TRecorder3dSkinModifierFrame.InfluenceSelection(Sender:TObject;
  ACol,ARow:Integer; var CanSelect:Boolean);
var
  BindingIndex:Integer;
begin
  if (ARow<=0) or (ARow>=sgInfluences.RowCount) then
    Exit;
  BindingIndex:=PtrUInt(sgInfluences.Objects[0,ARow])-1;
  if (BindingIndex>=0) and (BindingIndex<fComponent.SkinBindingCount) then
    seWeight.Value:=fComponent.SkinBindings[BindingIndex].Weight;
  UpdateActions;
end;

end.
