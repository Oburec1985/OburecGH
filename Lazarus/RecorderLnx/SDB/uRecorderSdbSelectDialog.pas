unit uRecorderSdbSelectDialog;

{
  Native replacement for original Recorder IMeSDBViewer in selection mode.
  It displays the common SDB tree and returns the stable scale key, not a
  transient file name. The caller decides whether the selected scale is valid
  for its channel type.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Grids,
  uRecorderSdbStore, uRecorderSdbTypes, uRecorderTags;

function ShowRecorderSdbSelectDialog(AOwner: TComponent; const AInitialKey: string;
  out ASelectedKey: string): Boolean;

implementation

type
  TRecorderSdbSelectDialog = class(TForm)
    btnCancel: TButton;
    btnSelect: TButton;
    edDescription: TEdit;
    edKey: TEdit;
    edRange: TEdit;
    edUnits: TEdit;
    gridPoints: TStringGrid;
    lbDescription: TLabel;
    lbKey: TLabel;
    lbRange: TLabel;
    lbUnits: TLabel;
    pnBottom: TPanel;
    pnDetails: TPanel;
    spTree: TSplitter;
    treeSdb: TTreeView;
    procedure btnSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure treeSdbChange(Sender: TObject; Node: TTreeNode);
    procedure treeSdbDblClick(Sender: TObject);
  private
    fSelectedKey: string;
    fTree: TRecorderSdbTree;
    procedure AddNode(AParent: TTreeNode; AItem: TRecorderSdbNode);
    function SelectedScale: TRecorderSdbNode;
    procedure SelectInitialKey(const AKey: string);
    procedure ShowScale(AItem: TRecorderSdbNode);
  public
    function Execute(const AInitialKey: string; out ASelectedKey: string): Boolean;
  end;

{$R *.lfm}

function ShowRecorderSdbSelectDialog(AOwner: TComponent;
  const AInitialKey: string; out ASelectedKey: string): Boolean;
var
  lDialog: TRecorderSdbSelectDialog;
begin
  lDialog := TRecorderSdbSelectDialog.Create(AOwner);
  try
    Result := lDialog.Execute(AInitialKey, ASelectedKey);
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderSdbSelectDialog.FormCreate(Sender: TObject);
begin
  gridPoints.FixedCols := 0;
  gridPoints.FixedRows := 1;
  gridPoints.ColCount := 3;
  gridPoints.RowCount := 2;
  gridPoints.Cells[0, 0] := 'i';
  gridPoints.Cells[1, 0] := 'X(i)';
  gridPoints.Cells[2, 0] := 'Y(i)';
  gridPoints.ColWidths[0] := 45;
  gridPoints.ColWidths[1] := 140;
  gridPoints.ColWidths[2] := 140;
end;

procedure TRecorderSdbSelectDialog.AddNode(AParent: TTreeNode;
  AItem: TRecorderSdbNode);
var
  I: Integer;
  lNode: TTreeNode;
begin
  if AItem = nil then
    Exit;
  if AItem.ItemKind = sikRoot then
    lNode := treeSdb.Items.AddObject(AParent, AItem.Caption, AItem)
  else
    lNode := treeSdb.Items.AddChildObject(AParent, AItem.Caption, AItem);
  for I := 0 to AItem.GetChildCount - 1 do
    if AItem.GetChild(I) is TRecorderSdbNode then
      AddNode(lNode, TRecorderSdbNode(AItem.GetChild(I)));
end;

function TRecorderSdbSelectDialog.SelectedScale: TRecorderSdbNode;
begin
  Result := nil;
  if (treeSdb.Selected <> nil) and
    (TObject(treeSdb.Selected.Data) is TRecorderSdbNode) and
    (TRecorderSdbNode(treeSdb.Selected.Data).ItemKind = sikScale) then
    Result := TRecorderSdbNode(treeSdb.Selected.Data);
end;

procedure TRecorderSdbSelectDialog.ShowScale(AItem: TRecorderSdbNode);
var
  I: Integer;
  lCalibration: TRecorderCalibration;
begin
  edKey.Text := '';
  edDescription.Text := '';
  edUnits.Text := '';
  edRange.Text := '';
  gridPoints.RowCount := 2;
  gridPoints.Cells[0, 1] := '';
  gridPoints.Cells[1, 1] := '';
  gridPoints.Cells[2, 1] := '';
  btnSelect.Enabled := AItem <> nil;
  if AItem = nil then
    Exit;

  edKey.Text := AItem.ScaleInfo.Key;
  edDescription.Text := AItem.ScaleInfo.Description;
  edUnits.Text := AItem.ScaleInfo.SrcUnits + ' -> ' + AItem.ScaleInfo.DstUnits;
  edRange.Text := FormatFloat('0.######', AItem.ScaleInfo.SrcFrom) + ' .. ' +
    FormatFloat('0.######', AItem.ScaleInfo.SrcTo) + ' -> ' +
    FormatFloat('0.######', AItem.ScaleInfo.DstFrom) + ' .. ' +
    FormatFloat('0.######', AItem.ScaleInfo.DstTo);

  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(AItem.ScaleInfo.Key, lCalibration) then
      Exit;
    gridPoints.RowCount := Max(2, lCalibration.PointCount + 1);
    for I := 0 to lCalibration.PointCount - 1 do
    begin
      gridPoints.Cells[0, I + 1] := IntToStr(I + 1);
      gridPoints.Cells[1, I + 1] := FormatFloat('0.###############',
        lCalibration.PointAt(I).X);
      gridPoints.Cells[2, I + 1] := FormatFloat('0.###############',
        lCalibration.PointAt(I).Y);
    end;
  finally
    lCalibration.Free;
  end;
end;

procedure TRecorderSdbSelectDialog.treeSdbChange(Sender: TObject; Node: TTreeNode);
begin
  ShowScale(SelectedScale);
end;

procedure TRecorderSdbSelectDialog.btnSelectClick(Sender: TObject);
var
  lScale: TRecorderSdbNode;
begin
  lScale := SelectedScale;
  if lScale = nil then
    Exit;
  fSelectedKey := lScale.ScaleInfo.Key;
  ModalResult := mrOk;
end;

procedure TRecorderSdbSelectDialog.treeSdbDblClick(Sender: TObject);
begin
  btnSelectClick(Sender);
end;

procedure TRecorderSdbSelectDialog.SelectInitialKey(const AKey: string);
var
  lKey: string;
  lNode: TTreeNode;
begin
  lKey := RecorderSdbNormalizeKey(AKey);
  lNode := treeSdb.Items.GetFirstNode;
  while lNode <> nil do
  begin
    if (TObject(lNode.Data) is TRecorderSdbNode) and
      SameText(TRecorderSdbNode(lNode.Data).ScaleInfo.Key, lKey) then
    begin
      treeSdb.Selected := lNode;
      lNode.MakeVisible;
      Exit;
    end;
    lNode := lNode.GetNext;
  end;
end;

function TRecorderSdbSelectDialog.Execute(const AInitialKey: string;
  out ASelectedKey: string): Boolean;
begin
  ASelectedKey := '';
  fSelectedKey := '';
  fTree := TRecorderSdbTree.Create;
  try
    fTree.Load;
    treeSdb.Items.BeginUpdate;
    try
      treeSdb.Items.Clear;
      AddNode(nil, fTree.Root);
      treeSdb.FullExpand;
    finally
      treeSdb.Items.EndUpdate;
    end;
    SelectInitialKey(AInitialKey);
    if treeSdb.Selected = nil then
      treeSdb.Selected := treeSdb.Items.GetFirstNode;
    ShowScale(SelectedScale);
    Result := ShowModal = mrOk;
    if Result then
      ASelectedKey := fSelectedKey;
  finally
    fTree.Free;
    fTree := nil;
  end;
end;

end.
