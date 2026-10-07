unit uRecorder3dSceneTreeDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Edits procedural objects in the live 3D scene. Geometry creation stays in
  u3dPrimitives; this form only validates commands and presents scene state. }

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Grids, StdCtrls, ExtCtrls, Spin,
  Graphics, ColorBox,
  LCLType, u3dScene, u3dPrimitives, uRecorder3dModel;

type
  TRecorder3dSceneNodeEvent=procedure(ANodeId:QWord) of object;
  TRecorder3dSceneTreeDialog = class(TForm)
  published
    TopPan, BottomPan: TPanel;
    lblType, lblIterations, lblCrossSection, lblHint, lblBackground: TLabel;
    cbType: TComboBox;
    cbBackground:TColorBox;
    seIterations, seCrossSection: TSpinEdit;
    btnAdd, btnDelete, btnOk, btnCancel: TButton;
    sgScene: TStringGrid;
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure GridDblClick(Sender:TObject);
    procedure CloseClick(Sender:TObject);
    procedure BackgroundColorSelect(Sender:TObject);
    procedure FormClose(Sender:TObject; var CloseAction:TCloseAction);
    procedure ParametersChange(Sender: TObject);
    procedure TypeChange(Sender: TObject);
  private
    fScene: T3dScene;
    fComponent: TRecorder3dComponent;
    fModified: Boolean;
    fOwnPreview: Boolean;
    fLoadingSelection: Boolean;
    fSynchronizingSelection:Boolean;
    fLoadingBackground:Boolean;
    fOnSceneChanged: TNotifyEvent;
    fOnNodeSelected:TRecorder3dSceneNodeEvent;
    fOnOpenObjectEditor:TRecorder3dSceneNodeEvent;
    fRowNodeIds: array of QWord;
    procedure BuildGrid(ASelectedNodeId: QWord);
    procedure ConfigureGrid;
    function CurrentNodeId: QWord;
    function PrimitiveKind: T3dPrimitiveKind;
    function UniqueName(AKind: T3dPrimitiveKind): string;
    procedure RemoveNodeAndReferences(ANodeId: QWord);
    procedure SelectNode(ANodeId: QWord);
    procedure RefreshActions;
    procedure LoadSelectedPrimitive(ANodeId:QWord=0);
  public
    destructor Destroy; override;
    property OnSceneChanged: TNotifyEvent read fOnSceneChanged
      write fOnSceneChanged;
    property OnNodeSelected:TRecorder3dSceneNodeEvent read fOnNodeSelected
      write fOnNodeSelected;
    property OnOpenObjectEditor:TRecorder3dSceneNodeEvent
      read fOnOpenObjectEditor write fOnOpenObjectEditor;
    procedure PrepareGuidePreview(AAfterDelete: Boolean);
    procedure ShowEditor(AScene:T3dScene; AComponent:TRecorder3dComponent;
      ASelectedNodeId:QWord);
    procedure SelectNodeFromView(ANodeId:QWord);
    procedure DetachScene;
    function Execute(AScene: T3dScene; AComponent: TRecorder3dComponent;
      ASelectedNodeId: QWord; out ANodeId: QWord;
      out AModified: Boolean): Boolean;
  end;

implementation

uses
  u3dCoreTypes;

{$R *.lfm}

const
  CCoordinateFormat = '0.###';

destructor TRecorder3dSceneTreeDialog.Destroy;
begin
  if fOwnPreview then
  begin
    fScene.Free;
    fComponent.Free;
  end;
  inherited Destroy;
end;

procedure TRecorder3dSceneTreeDialog.PrepareGuidePreview(
  AAfterDelete: Boolean);
var
  Kind: T3dPrimitiveKind;
begin
  if fOwnPreview then
  begin
    fScene.Free;
    fComponent.Free;
  end;
  fScene := T3dScene.Create;
  fComponent := TRecorder3dComponent.Create;
  fOwnPreview := True;
  for Kind := Low(T3dPrimitiveKind) to High(T3dPrimitiveKind) do
    try
      cbType.ItemIndex := Ord(Kind);
      TypeChange(cbType);
      if Kind = pkLine then
        seIterations.Value := 5
      else
        seIterations.Value := 2;
      AddClick(btnAdd);
    except
      on E: Exception do
        raise Exception.CreateFmt('3D preview kind %d: %s',
          [Ord(Kind), E.Message]);
    end;
  if AAfterDelete then
  begin
    sgScene.Row := sgScene.RowCount - 1;
    DeleteClick(btnDelete);
  end
  else
  begin
    cbType.ItemIndex := Ord(pkLine);
    TypeChange(cbType);
    sgScene.Row := sgScene.RowCount - 1;
    btnDelete.Enabled := True;
  end;
end;

procedure TRecorder3dSceneTreeDialog.ConfigureGrid;
begin
  sgScene.Cells[0, 0] := 'Имя';
  sgScene.Cells[1, 0] := 'X';
  sgScene.Cells[2, 0] := 'Y';
  sgScene.Cells[3, 0] := 'Z';
  sgScene.ColWidths[1] := 85;
  sgScene.ColWidths[2] := 85;
  sgScene.ColWidths[3] := 85;
  sgScene.ColWidths[0] := Max(140, sgScene.ClientWidth - 3 * 85 - 8);
end;

procedure TRecorder3dSceneTreeDialog.BuildGrid(ASelectedNodeId: QWord);
var
  I: Integer;
begin
  sgScene.RowCount := 1;
  SetLength(fRowNodeIds, 1);
  if fScene <> nil then
    for I := 0 to High(fScene.Nodes) do
    begin
      sgScene.RowCount := sgScene.RowCount + 1;
      SetLength(fRowNodeIds, sgScene.RowCount);
      fRowNodeIds[sgScene.RowCount - 1] := fScene.Nodes[I].Id;
      sgScene.Cells[0, sgScene.RowCount - 1] := fScene.Nodes[I].Name;
      sgScene.Cells[1, sgScene.RowCount - 1] := FormatFloat(CCoordinateFormat, fScene.Nodes[I].WorldTransform[12]);
      sgScene.Cells[2, sgScene.RowCount - 1] := FormatFloat(CCoordinateFormat, fScene.Nodes[I].WorldTransform[13]);
      sgScene.Cells[3, sgScene.RowCount - 1] := FormatFloat(CCoordinateFormat, fScene.Nodes[I].WorldTransform[14]);
    end;
  ConfigureGrid;
  SelectNode(ASelectedNodeId);
  RefreshActions;
end;

function TRecorder3dSceneTreeDialog.CurrentNodeId: QWord;
begin
  if (sgScene.Row > 0) and (sgScene.Row < Length(fRowNodeIds)) then
    Result := fRowNodeIds[sgScene.Row]
  else
    Result := 0;
end;

function TRecorder3dSceneTreeDialog.PrimitiveKind: T3dPrimitiveKind;
begin
  if cbType.ItemIndex < 0 then
    Result := pkCube
  else
    Result := T3dPrimitiveKind(cbType.ItemIndex);
end;

function TRecorder3dSceneTreeDialog.UniqueName(
  AKind: T3dPrimitiveKind): string;
const
  CNames: array[T3dPrimitiveKind] of string =
    ('Куб', 'Пластина', 'Плоскость', 'Линия');
var
  Number: Integer;
begin
  Number := 1;
  repeat
    Result := Format('%s %d', [CNames[AKind], Number]);
    Inc(Number);
  until (fScene = nil) or (fScene.FindNode(Result) = nil);
end;

procedure TRecorder3dSceneTreeDialog.AddClick(Sender: TObject);
var
  Spec: T3dPrimitiveSpec;
  lUpdated: Integer;
begin
  if (fScene = nil) or (fComponent = nil) then
    Exit;
  Spec.Kind := PrimitiveKind;
  Spec.Iterations := seIterations.Value;
  Spec.CrossSectionIterations:=seCrossSection.Value;
  Spec.NodeId := fComponent.AllocatePrimitiveNodeId(fScene);
  Spec.Name := UniqueName(Spec.Kind);
  Spec.Position := Vector3d(0, 0, 0);
  fScene.AddNode(CreatePrimitiveNode(Spec));
  fComponent.AddPrimitive(Spec);
  fScene.RebuildWorldTransforms(lUpdated);
  fScene.MarkBoundsDirty;
  fModified := True;
  BuildGrid(Spec.NodeId);
  if Assigned(fOnSceneChanged) then fOnSceneChanged(Self);
  if Assigned(fOnNodeSelected) then fOnNodeSelected(Spec.NodeId);
end;

procedure TRecorder3dSceneTreeDialog.RemoveNodeAndReferences(ANodeId: QWord);
var
  I, PreviousCount: Integer;
  RemovedIds: array of QWord;

  function ContainsId(AId: QWord): Boolean;
  var
    J: Integer;
  begin
    for J := 0 to High(RemovedIds) do
      if RemovedIds[J] = AId then
        Exit(True);
    Result := False;
  end;

begin
  SetLength(RemovedIds, 1);
  RemovedIds[0] := ANodeId;
  repeat
    PreviousCount := Length(RemovedIds);
    for I := 0 to High(fScene.Nodes) do
      if ContainsId(fScene.Nodes[I].ParentId) and
         (not ContainsId(fScene.Nodes[I].Id)) then
      begin
        SetLength(RemovedIds, Length(RemovedIds) + 1);
        RemovedIds[High(RemovedIds)] := fScene.Nodes[I].Id;
      end;
  until PreviousCount = Length(RemovedIds);
  for I := 0 to High(RemovedIds) do
  begin
    fComponent.RemoveNodeReferences(RemovedIds[I]);
    if not fComponent.DeletePrimitive(RemovedIds[I]) then
      fComponent.MarkNodeRemoved(RemovedIds[I]);
  end;
  fScene.RemoveNode(ANodeId);
end;

procedure TRecorder3dSceneTreeDialog.DeleteClick(Sender: TObject);
var
  NodeId: QWord;
begin
  NodeId := CurrentNodeId;
  if (NodeId = 0) or (fScene = nil) or (fComponent = nil) then
    Exit;
  RemoveNodeAndReferences(NodeId);
  fModified := True;
  BuildGrid(0);
  if Assigned(fOnSceneChanged) then fOnSceneChanged(Self);
end;

procedure TRecorder3dSceneTreeDialog.FormCreate(Sender: TObject);
begin
  cbType.ItemIndex := 0;
  TypeChange(cbType);
  ConfigureGrid;
  RefreshActions;
end;

procedure TRecorder3dSceneTreeDialog.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    DeleteClick(Sender);
    Key := 0;
  end;
end;

procedure TRecorder3dSceneTreeDialog.FormResize(Sender: TObject);
begin
  if sgScene <> nil then
    ConfigureGrid;
end;

procedure TRecorder3dSceneTreeDialog.GridSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  btnDelete.Enabled := ARow > 0;
  if (ARow>0) and (ARow<Length(fRowNodeIds)) then
  begin
    LoadSelectedPrimitive(fRowNodeIds[ARow]);
    if (not fSynchronizingSelection) and Assigned(fOnNodeSelected) then
      fOnNodeSelected(fRowNodeIds[ARow]);
  end
  else
    LoadSelectedPrimitive(0);
end;

procedure TRecorder3dSceneTreeDialog.GridDblClick(Sender:TObject);
begin
  if CurrentNodeId=0 then
    Exit;
  if Assigned(fOnOpenObjectEditor) then
    fOnOpenObjectEditor(CurrentNodeId);
end;

procedure TRecorder3dSceneTreeDialog.CloseClick(Sender:TObject);
begin
  Close;
end;

procedure TRecorder3dSceneTreeDialog.BackgroundColorSelect(Sender:TObject);
begin
  if fLoadingBackground or (fComponent=nil) then Exit;
  if fComponent.BackgroundColor=LongInt(cbBackground.Selected) then Exit;
  fComponent.BackgroundColor:=LongInt(cbBackground.Selected);
  fModified:=True;
  if Assigned(fOnSceneChanged) then fOnSceneChanged(Self);
end;

procedure TRecorder3dSceneTreeDialog.FormClose(Sender:TObject;
  var CloseAction:TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TRecorder3dSceneTreeDialog.ShowEditor(AScene:T3dScene;
  AComponent:TRecorder3dComponent; ASelectedNodeId:QWord);
begin
  fScene:=AScene;
  fComponent:=AComponent;
  fOwnPreview:=False;
  fLoadingBackground:=True;
  try
    if fComponent<>nil then
      cbBackground.Selected:=TColor(fComponent.BackgroundColor);
  finally
    fLoadingBackground:=False;
  end;
  BuildGrid(ASelectedNodeId);
  Show;
  BringToFront;
  if sgScene.CanFocus then sgScene.SetFocus;
end;

procedure TRecorder3dSceneTreeDialog.SelectNodeFromView(ANodeId:QWord);
begin
  if not Visible then Exit;
  fSynchronizingSelection:=True;
  try
    BuildGrid(ANodeId);
  finally
    fSynchronizingSelection:=False;
  end;
end;

procedure TRecorder3dSceneTreeDialog.DetachScene;
begin
  Hide;
  fScene:=nil;
  fComponent:=nil;
  BuildGrid(0);
end;

procedure TRecorder3dSceneTreeDialog.LoadSelectedPrimitive(ANodeId:QWord);
var
  Index: Integer;
  Spec: T3dPrimitiveSpec;
begin
  fLoadingSelection := True;
  try
    Index := -1;
    if ANodeId=0 then
      ANodeId:=CurrentNodeId;
    if fComponent <> nil then
      Index := fComponent.FindPrimitiveIndex(ANodeId);
    { Skin helpers are stored as small cube primitives for persistence, but
      their visual tessellation is not a user-editable scene parameter. }
    if (fComponent<>nil) and (fComponent.FindSkinBone(ANodeId)<>nil) then
      Index:=-1;
    if Index < 0 then
      Exit;
    Spec := fComponent.Primitives[Index];
    cbType.ItemIndex:=Ord(Spec.Kind);
    TypeChange(cbType);
    seIterations.Value:=Spec.Iterations;
    seCrossSection.Value:=Spec.CrossSectionIterations;
  finally
    fLoadingSelection := False;
  end;
end;

procedure TRecorder3dSceneTreeDialog.ParametersChange(Sender: TObject);
var
  Index,lUpdated: Integer;
  Spec,CommittedSpec: T3dPrimitiveSpec;
  Node: T3dNode;
begin
  if fLoadingSelection or (fComponent = nil) or (fScene = nil) then
    Exit;
  Index := fComponent.FindPrimitiveIndex(CurrentNodeId);
  if Index < 0 then
    Exit;
  if fComponent.FindSkinBone(CurrentNodeId)<>nil then
    Exit;
  Spec := fComponent.Primitives[Index];
  { A different combo type means the fields configure the next object to add;
    do not silently convert or rebuild the currently selected object. }
  if Spec.Kind<>PrimitiveKind then
    Exit;
  Spec.Iterations := seIterations.Value;
  Spec.CrossSectionIterations:=seCrossSection.Value;
  NormalizePrimitiveSpec(Spec);
  if (Spec.Iterations=fComponent.Primitives[Index].Iterations) and
     (Spec.CrossSectionIterations=
       fComponent.Primitives[Index].CrossSectionIterations) then
    Exit;
  Node := fScene.FindNode(Spec.NodeId);
  if Node = nil then
    Exit;
  RebuildPrimitiveNodeGeometry(Node, Spec);
  fComponent.UpdatePrimitiveIterations(Spec.NodeId,Spec.Iterations,
    Spec.CrossSectionIterations,CommittedSpec);
  fScene.RebuildWorldTransforms(lUpdated);
  fScene.MarkBoundsDirty;
  fModified := True;
  BuildGrid(Spec.NodeId);
  if Assigned(fOnSceneChanged) then
    fOnSceneChanged(Self);
end;

procedure TRecorder3dSceneTreeDialog.TypeChange(Sender: TObject);
begin
  seIterations.MinValue := PrimitiveIterationMinimum(PrimitiveKind);
  if seIterations.Value < seIterations.MinValue then
    seIterations.Value := seIterations.MinValue;
  if PrimitiveKind = pkLine then
    lblIterations.Caption := 'Точек:'
  else if PrimitiveKind = pkBeam then
    lblIterations.Caption := 'Вдоль:'
  else
    lblIterations.Caption := 'По ребру:';
  lblCrossSection.Visible:=PrimitiveKind=pkBeam;
  seCrossSection.Visible:=PrimitiveKind=pkBeam;
end;

procedure TRecorder3dSceneTreeDialog.SelectNode(ANodeId: QWord);
var
  I: Integer;
begin
  if ANodeId = 0 then
    Exit;
  for I := 1 to High(fRowNodeIds) do
    if fRowNodeIds[I] = ANodeId then
    begin
      sgScene.Row := I;
      Exit;
    end;
end;

procedure TRecorder3dSceneTreeDialog.RefreshActions;
begin
  btnDelete.Enabled := CurrentNodeId <> 0;
  LoadSelectedPrimitive;
end;

function TRecorder3dSceneTreeDialog.Execute(AScene: T3dScene;
  AComponent: TRecorder3dComponent; ASelectedNodeId: QWord;
  out ANodeId: QWord; out AModified: Boolean): Boolean;
var
  Snapshot: TRecorder3dComponent;
begin
  fScene := AScene;
  fComponent := AComponent;
  fModified := False;
  BuildGrid(ASelectedNodeId);
  Snapshot := TRecorder3dComponent.Create;
  try
    Snapshot.Assign(AComponent);
    Result := ShowModal = mrOk;
    ANodeId := CurrentNodeId;
    AModified := fModified;
    if (not Result) and fModified then
      AComponent.Assign(Snapshot);
  finally
    Snapshot.Free;
    if not fOwnPreview then
    begin
      fScene := nil;
      fComponent := nil;
    end;
  end;
end;

end.
