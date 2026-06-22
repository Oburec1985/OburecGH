unit uRecorderSdbSelectDialog;

{
  Native replacement for original Recorder IMeSDBViewer in selection mode.
  Tree nodes share name/description; scale leaves additionally show units,
  range, point table and curve chart.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls, Grids,
  ImgList, TAGraph, TASeries, TATypes,
  uRecorderSdbStore, uRecorderSdbTypes, uRecorderSdbImages, uRecorderTags,
  uSharedStringEncoding;

function ShowRecorderSdbSelectDialog(AOwner: TComponent; const AInitialKey: string;
  out ASelectedKey: string): Boolean;

implementation

type
  TRecorderSdbSelectDialog = class(TForm)
    btnCancel: TButton;
    btnSelect: TButton;
    chartScale: TChart;
    edDescription: TEdit;
    edKey: TEdit;
    edRange: TEdit;
    edUnits: TEdit;
    gridPoints: TStringGrid;
    ilSdbTree: TImageList;
    lbDescription: TLabel;
    lbKey: TLabel;
    lbRange: TLabel;
    lbUnits: TLabel;
    pcScaleData: TPageControl;
    pnBottom: TPanel;
    pnDetails: TPanel;
    pnScale: TPanel;
    seriesScale: TLineSeries;
    spTree: TSplitter;
    treeSdb: TTreeView;
    tsChart: TTabSheet;
    tsTable: TTabSheet;
    procedure btnSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pcScaleDataChange(Sender: TObject);
    procedure treeSdbChange(Sender: TObject; Node: TTreeNode);
    procedure treeSdbCollapsed(Sender: TObject; Node: TTreeNode);
    procedure treeSdbDblClick(Sender: TObject);
    procedure treeSdbExpanded(Sender: TObject; Node: TTreeNode);
  private
    fScaleDataActiveTab: TTabSheet;
    fSelectedKey: string;
    fTree: TRecorderSdbTree;
    procedure AddNode(AParent: TTreeNode; AItem: TRecorderSdbNode);
    procedure ApplyNodeIcon(ANode: TTreeNode; AExpanded: Boolean);
    procedure ClearScaleDetails;
    procedure ConfigureScaleChart;
    procedure ConfigureScaleSeries;
    function SelectedItem: TRecorderSdbNode;
    function SelectedScale: TRecorderSdbNode;
    procedure SelectInitialKey(const AKey: string);
    procedure ShowItem(AItem: TRecorderSdbNode);
    procedure ShowNodeCommonInfo(AItem: TRecorderSdbNode);
    procedure ShowScaleDetails(AItem: TRecorderSdbNode);
    procedure UpdateScaleChart(ACalibration: TRecorderCalibration);
    procedure UpdateTreeIcons(ANode: TTreeNode);
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
  gridPoints.Cells[0, 0] := 'i';
  gridPoints.Cells[1, 0] := 'X(i)';
  gridPoints.Cells[2, 0] := 'Y(i)';
  fScaleDataActiveTab := tsTable;
  ConfigureScaleChart;
  ConfigureScaleSeries;
end;

procedure TRecorderSdbSelectDialog.pcScaleDataChange(Sender: TObject);
begin
  if pcScaleData.ActivePage <> nil then
    fScaleDataActiveTab := pcScaleData.ActivePage;
end;

procedure TRecorderSdbSelectDialog.ConfigureScaleChart;
begin
  with chartScale do
  begin
    Margins.Left := 8;
    Margins.Top := 8;
    Margins.Right := 8;
    Margins.Bottom := 28;
    BottomAxis.Margin := 4;
    BottomAxis.MarginsForMarks := True;
    LeftAxis.MarginsForMarks := True;
  end;
end;

procedure TRecorderSdbSelectDialog.ConfigureScaleSeries;
begin
  with seriesScale do
  begin
    ColorEach := ceNone;
    ShowLines := True;
    ShowPoints := False;
    SeriesColor := clBlue;
    LinePen.Color := clBlue;
    LinePen.Width := 1;
    Pointer.Visible := False;
    Pointer.Style := psNone;
    Pointer.HorizSize := 1;
    Pointer.VertSize := 1;
  end;
end;

procedure TRecorderSdbSelectDialog.ApplyNodeIcon(ANode: TTreeNode;
  AExpanded: Boolean);
var
  lItem: TRecorderSdbNode;
begin
  if (ANode = nil) or not (TObject(ANode.Data) is TRecorderSdbNode) then
    Exit;
  lItem := TRecorderSdbNode(ANode.Data);
  case lItem.ItemKind of
    sikScale:
      begin
        ANode.ImageIndex := CSdbIconScale;
        ANode.SelectedIndex := CSdbIconScale;
      end;
    sikFolder, sikRoot:
      begin
        if AExpanded then
        begin
          ANode.ImageIndex := CSdbIconFolderOpen;
          ANode.SelectedIndex := CSdbIconFolderOpen;
        end
        else
        begin
          ANode.ImageIndex := CSdbIconFolderClosed;
          ANode.SelectedIndex := CSdbIconFolderClosed;
        end;
      end;
  end;
end;

procedure TRecorderSdbSelectDialog.treeSdbExpanded(Sender: TObject;
  Node: TTreeNode);
begin
  ApplyNodeIcon(Node, True);
end;

procedure TRecorderSdbSelectDialog.treeSdbCollapsed(Sender: TObject;
  Node: TTreeNode);
begin
  ApplyNodeIcon(Node, False);
end;

procedure TRecorderSdbSelectDialog.UpdateTreeIcons(ANode: TTreeNode);
begin
  if ANode = nil then
    Exit;
  ApplyNodeIcon(ANode, ANode.Expanded);
  UpdateTreeIcons(ANode.GetFirstChild);
  UpdateTreeIcons(ANode.GetNextSibling);
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
  ApplyNodeIcon(lNode, False);
  for I := 0 to AItem.GetChildCount - 1 do
    if AItem.GetChild(I) is TRecorderSdbNode then
      AddNode(lNode, TRecorderSdbNode(AItem.GetChild(I)));
end;

function TRecorderSdbSelectDialog.SelectedScale: TRecorderSdbNode;
begin
  Result := nil;
  if (SelectedItem <> nil) and (SelectedItem.ItemKind = sikScale) then
    Result := SelectedItem;
end;

function TRecorderSdbSelectDialog.SelectedItem: TRecorderSdbNode;
begin
  Result := nil;
  if (treeSdb.Selected <> nil) and
    (TObject(treeSdb.Selected.Data) is TRecorderSdbNode) then
    Result := TRecorderSdbNode(treeSdb.Selected.Data);
end;

procedure TRecorderSdbSelectDialog.ClearScaleDetails;
begin
  edUnits.Text := '';
  edRange.Text := '';
  gridPoints.RowCount := 2;
  gridPoints.Cells[0, 1] := '';
  gridPoints.Cells[1, 1] := '';
  gridPoints.Cells[2, 1] := '';
  seriesScale.Clear;
  chartScale.Title.Visible := False;
end;

procedure TRecorderSdbSelectDialog.ShowNodeCommonInfo(AItem: TRecorderSdbNode);
begin
  edKey.Text := '';
  edDescription.Text := '';
  if AItem = nil then
    Exit;
  RecorderSdbReloadNodeMetadata(AItem);
  edKey.Text := RecorderSdbNodeDisplayName(AItem);
  edDescription.Text := RecorderSdbNodeDisplayDescription(AItem);
end;

procedure TRecorderSdbSelectDialog.UpdateScaleChart(
  ACalibration: TRecorderCalibration);
var
  I: Integer;
begin
  ConfigureScaleChart;
  ConfigureScaleSeries;
  seriesScale.Clear;
  if (ACalibration = nil) or (ACalibration.PointCount = 0) then
  begin
    chartScale.Title.Visible := False;
    Exit;
  end;
  for I := 0 to ACalibration.PointCount - 1 do
    seriesScale.AddXY(ACalibration.PointAt(I).X, ACalibration.PointAt(I).Y);
  chartScale.BottomAxis.Title.Caption := ACalibration.UnitIn;
  chartScale.LeftAxis.Title.Caption := ACalibration.UnitOut;
  chartScale.Title.Text.Clear;
  chartScale.Title.Text.Add('ГХ');
  chartScale.Title.Visible := True;
end;

procedure TRecorderSdbSelectDialog.ShowScaleDetails(AItem: TRecorderSdbNode);
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lInfo: TSdbScaleInfo;
begin
  lInfo := AItem.ScaleInfo;
  edUnits.Text := lInfo.SrcUnits + ' -> ' + lInfo.DstUnits;
  edRange.Text := FormatFloat('0.######', lInfo.SrcFrom) + ' .. ' +
    FormatFloat('0.######', lInfo.SrcTo) + ' -> ' +
    FormatFloat('0.######', lInfo.DstFrom) + ' .. ' +
    FormatFloat('0.######', lInfo.DstTo);

  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibrationFromInfo(lInfo, lCalibration) then
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
    UpdateScaleChart(lCalibration);
  finally
    lCalibration.Free;
  end;
end;

procedure TRecorderSdbSelectDialog.ShowItem(AItem: TRecorderSdbNode);
begin
  if pnScale.Visible and (pcScaleData.ActivePage <> nil) then
    fScaleDataActiveTab := pcScaleData.ActivePage;
  ClearScaleDetails;
  pnScale.Visible := False;
  btnSelect.Enabled := (AItem <> nil) and (AItem.ItemKind = sikScale);
  ShowNodeCommonInfo(AItem);
  if (AItem = nil) or (AItem.ItemKind <> sikScale) then
    Exit;
  pnScale.Visible := True;
  if fScaleDataActiveTab <> nil then
    pcScaleData.ActivePage := fScaleDataActiveTab;
  ShowScaleDetails(AItem);
end;

procedure TRecorderSdbSelectDialog.treeSdbChange(Sender: TObject; Node: TTreeNode);
begin
  ShowItem(SelectedItem);
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
      UpdateTreeIcons(treeSdb.Items.GetFirstNode);
    finally
      treeSdb.Items.EndUpdate;
    end;
    SelectInitialKey(AInitialKey);
    if treeSdb.Selected = nil then
      treeSdb.Selected := treeSdb.Items.GetFirstNode;
    ShowItem(SelectedItem);
    Result := ShowModal = mrOk;
    if Result then
      ASelectedKey := fSelectedKey;
  finally
    fTree.Free;
    fTree := nil;
  end;
end;

end.
