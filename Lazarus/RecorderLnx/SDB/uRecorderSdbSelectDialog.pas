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
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, Grids, Menus,
  ImgList, TAGraph, TASeries, TATypes,
  uRecorderSdbStore, uRecorderSdbTypes, uRecorderSdbImages, uRecorderTags,
  uRecorderStrainCalibration, uRecorderStrainCalibrationFrame,
  uRecorderCalibrationPropertiesDialog,
  uSharedStringEncoding;

function ShowRecorderSdbSelectDialog(AOwner: TComponent; const AInitialKey: string;
  out ASelectedKey: string): Boolean;
function ShowRecorderSdbFolderSelectDialog(AOwner: TComponent;
  const AInitialKey: string; out ASelectedKey: string): Boolean;
function CreateRecorderSdbSelectGuideForm(AOwner: TComponent): TForm;

implementation

var
  g_CopiedSdbCalibrationKey: string = '';

type
  TRecorderSdbSelectDialog = class(TForm)
    btnApplyName: TButton;
    btnCancel: TButton;
    btnSaveStrain: TButton;
    btnSelect: TButton;
    chartScale: TChart;
    edDescription: TEdit;
    edKey: TEdit;
    edRange: TEdit;
    edUnits: TEdit;
    gridPoints: TStringGrid;
    ilSdbTree: TImageList;
    lbDescription: TLabel;
    lbFormulaKind: TLabel;
    lbFormulaKindValue: TLabel;
    lbFormulaOffset: TLabel;
    lbFormulaOffsetValue: TLabel;
    lbFormulaScale: TLabel;
    lbFormulaScaleValue: TLabel;
    lbFormulaSensitivity: TLabel;
    lbFormulaSensitivityValue: TLabel;
    lbKey: TLabel;
    lbRange: TLabel;
    lbUnits: TLabel;
    miCreateFolder: TMenuItem;
    miCreateCalibration: TMenuItem;
    miCopyCalibration: TMenuItem;
    miPasteCalibration: TMenuItem;
    pcScaleData: TPageControl;
    pmSdbTree: TPopupMenu;
    pnBottom: TPanel;
    pnDetails: TPanel;
    pnFormulaDetails: TPanel;
    pnScale: TPanel;
    pnStrainActions: TPanel;
    sbStrainEditor: TScrollBox;
    seriesScale: TLineSeries;
    spTree: TSplitter;
    treeSdb: TTreeView;
    tsChart: TTabSheet;
    tsParameters: TTabSheet;
    tsTable: TTabSheet;
    procedure btnSelectClick(Sender: TObject);
    procedure btnSaveStrainClick(Sender: TObject);
    procedure btnApplyNameClick(Sender: TObject);
    procedure edKeyChange(Sender: TObject);
    procedure edKeyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pcScaleDataChange(Sender: TObject);
    procedure miCreateFolderClick(Sender: TObject);
    procedure miCreateCalibrationClick(Sender: TObject);
    procedure miCopyCalibrationClick(Sender: TObject);
    procedure miPasteCalibrationClick(Sender: TObject);
    procedure pmSdbTreePopup(Sender: TObject);
    procedure treeSdbChange(Sender: TObject; Node: TTreeNode);
    procedure treeSdbCollapsed(Sender: TObject; Node: TTreeNode);
    procedure treeSdbDblClick(Sender: TObject);
    procedure treeSdbExpanded(Sender: TObject; Node: TTreeNode);
    procedure treeSdbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    fScaleDataActiveTab: TTabSheet;
    fSelectedKey: string;
    fSelectFolders: Boolean;
    fCalibrationDraft: TRecorderCalibration;
    fCalibrationEditor: TRecorderCalibrationPropertiesDialog;
    fCalibrationKey: string;
    fStrainDraft: TRecorderCalibration;
    fStrainEditor: TRecorderStrainCalibrationFrame;
    fStrainKey: string;
    fTree: TRecorderSdbTree;
    procedure AddNode(AParent: TTreeNode; AItem: TRecorderSdbNode);
    procedure ApplyNodeIcon(ANode: TTreeNode; AExpanded: Boolean);
    procedure ApplyCalibrationName;
    procedure ClearScaleDetails;
    procedure ConfigureScaleChart;
    procedure ConfigureScaleSeries;
    function FolderKey(AItem: TRecorderSdbNode): string;
    function PasteFolderKey(AItem: TRecorderSdbNode): string;
    procedure ReloadTree(const ASelectedKey: string);
    function SelectedItem: TRecorderSdbNode;
    function SelectedChoice: TRecorderSdbNode;
    procedure SelectInitialKey(const AKey: string);
    procedure ShowItem(AItem: TRecorderSdbNode);
    procedure ShowNodeCommonInfo(AItem: TRecorderSdbNode);
    procedure ShowScaleDetails(AItem: TRecorderSdbNode);
    procedure ShowFormulaDetails(ACalibration: TRecorderCalibration);
    procedure ShowCalibrationEditor(ACalibration: TRecorderCalibration;
      const AKey: string);
    procedure ShowStrainDetails(ACalibration: TRecorderCalibration;
      const AKey: string);
    procedure UpdateScaleChart(ACalibration: TRecorderCalibration;
      const AMinX, AMaxX: Double);
    procedure UpdateTreeIcons(ANode: TTreeNode);
  public
    destructor Destroy; override;
    function Execute(const AInitialKey: string; ASelectFolders: Boolean;
      out ASelectedKey: string): Boolean;
  end;

{$R *.lfm}

function ShowRecorderSdbSelectDialog(AOwner: TComponent;
  const AInitialKey: string; out ASelectedKey: string): Boolean;
var
  lDialog: TRecorderSdbSelectDialog;
begin
  lDialog := TRecorderSdbSelectDialog.Create(AOwner);
  try
    Result := lDialog.Execute(AInitialKey, False, ASelectedKey);
  finally
    lDialog.Free;
  end;
end;

function TRecorderSdbSelectDialog.FolderKey(AItem: TRecorderSdbNode): string;
begin
  Result := '';
  if (AItem <> nil) and (AItem.ItemKind in [sikRoot, sikFolder]) then
    Result := AItem.FolderInfo.Key;
end;

function TRecorderSdbSelectDialog.PasteFolderKey(
  AItem: TRecorderSdbNode): string;
var
  lPath: string;
begin
  Result := FolderKey(AItem);
  if (AItem = nil) or (AItem.ItemKind <> sikScale) then
    Exit;
  lPath := StringReplace(AItem.ScaleInfo.Key, '\', PathDelim, [rfReplaceAll]);
  Result := ExtractFileDir(lPath);
  if Result = '.' then
    Result := '';
  Result := StringReplace(Result, PathDelim, '\', [rfReplaceAll]);
end;

procedure TRecorderSdbSelectDialog.treeSdbMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lNode: TTreeNode;
begin
  if Button <> mbRight then
    Exit;
  lNode := treeSdb.GetNodeAt(X, Y);
  if lNode <> nil then
    treeSdb.Selected := lNode
  else
    treeSdb.Selected := nil;
end;

procedure TRecorderSdbSelectDialog.pmSdbTreePopup(Sender: TObject);
var
  lItem: TRecorderSdbNode;
begin
  lItem := SelectedItem;
  miCreateFolder.Enabled := (lItem <> nil) and
    (lItem.ItemKind in [sikRoot, sikFolder]);
  miCreateCalibration.Enabled := miCreateFolder.Enabled;
  miCopyCalibration.Enabled := (lItem <> nil) and
    (lItem.ItemKind = sikScale);
  miPasteCalibration.Enabled := (lItem <> nil) and
    (Trim(g_CopiedSdbCalibrationKey) <> '');
end;

procedure TRecorderSdbSelectDialog.miCopyCalibrationClick(Sender: TObject);
var
  lItem: TRecorderSdbNode;
begin
  lItem := SelectedItem;
  if (lItem = nil) or (lItem.ItemKind <> sikScale) then
    Exit;
  g_CopiedSdbCalibrationKey := lItem.ScaleInfo.Key;
end;

procedure TRecorderSdbSelectDialog.miPasteCalibrationClick(Sender: TObject);
var
  lCreatedKey: string;
  lError: string;
  lItem: TRecorderSdbNode;
begin
  lItem := SelectedItem;
  if (lItem = nil) or (Trim(g_CopiedSdbCalibrationKey) = '') then
    Exit;
  if not RecorderSdbCopyCalibration(g_CopiedSdbCalibrationKey,
    PasteFolderKey(lItem), lCreatedKey, lError) then
  begin
    MessageDlg('Копирование ГХ', lError, mtError, [mbOK], 0);
    Exit;
  end;
  ReloadTree(lCreatedKey);
end;

procedure TRecorderSdbSelectDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not (ssCtrl in Shift) then
    Exit;
  case Key of
    Ord('C'): miCopyCalibrationClick(Sender);
    Ord('V'): miPasteCalibrationClick(Sender);
  else
    Exit;
  end;
  Key := 0;
end;

procedure TRecorderSdbSelectDialog.miCreateCalibrationClick(Sender: TObject);
var
  lCreatedKey: string;
  lError: string;
  lItem: TRecorderSdbNode;
  lName: string;
begin
  lItem := SelectedItem;
  if (lItem = nil) or not (lItem.ItemKind in [sikRoot, sikFolder]) then
    Exit;
  lName := '';
  if not InputQuery('Новая ГХ', 'Имя ГХ:', lName) then
    Exit;
  if not RecorderSdbCreateCalibration(FolderKey(lItem), lName,
    lCreatedKey, lError) then
  begin
    MessageDlg('Создание ГХ', lError, mtError, [mbOK], 0);
    Exit;
  end;
  ReloadTree(lCreatedKey);
end;

procedure TRecorderSdbSelectDialog.miCreateFolderClick(Sender: TObject);
var
  lCreatedKey: string;
  lError: string;
  lItem: TRecorderSdbNode;
  lName: string;
begin
  lItem := SelectedItem;
  if (lItem = nil) or not (lItem.ItemKind in [sikRoot, sikFolder]) then
    Exit;
  lName := '';
  if not InputQuery('Новый каталог БДГХ', 'Имя каталога:', lName) then
    Exit;
  if not RecorderSdbCreateFolder(FolderKey(lItem), lName,
    lCreatedKey, lError) then
  begin
    MessageDlg('Создание каталога БДГХ', lError, mtError, [mbOK], 0);
    Exit;
  end;
  ReloadTree(lCreatedKey);
end;

procedure TRecorderSdbSelectDialog.ReloadTree(const ASelectedKey: string);
begin
  treeSdb.Items.BeginUpdate;
  try
    treeSdb.Items.Clear;
    fTree.Load;
    AddNode(nil, fTree.Root);
    treeSdb.FullExpand;
    UpdateTreeIcons(treeSdb.Items.GetFirstNode);
  finally
    treeSdb.Items.EndUpdate;
  end;
  SelectInitialKey(ASelectedKey);
  if treeSdb.Selected = nil then
    treeSdb.Selected := treeSdb.Items.GetFirstNode;
  ShowItem(SelectedItem);
end;

function ShowRecorderSdbFolderSelectDialog(AOwner: TComponent;
  const AInitialKey: string; out ASelectedKey: string): Boolean;
var
  lDialog: TRecorderSdbSelectDialog;
begin
  lDialog := TRecorderSdbSelectDialog.Create(AOwner);
  try
    Result := lDialog.Execute(AInitialKey, True, ASelectedKey);
  finally
    lDialog.Free;
  end;
end;

function CreateRecorderSdbSelectGuideForm(AOwner: TComponent): TForm;
begin
  Result := TRecorderSdbSelectDialog.Create(AOwner);
end;

destructor TRecorderSdbSelectDialog.Destroy;
begin
  fCalibrationDraft.Free;
  fStrainDraft.Free;
  inherited Destroy;
end;

procedure TRecorderSdbSelectDialog.FormCreate(Sender: TObject);
begin
  gridPoints.Cells[0, 0] := 'i';
  gridPoints.Cells[1, 0] := 'X(i)';
  gridPoints.Cells[2, 0] := 'Y(i)';
  fScaleDataActiveTab := tsTable;
  ConfigureScaleChart;
  ConfigureScaleSeries;
  btnApplyName.Enabled := False;
end;

procedure TRecorderSdbSelectDialog.edKeyChange(Sender: TObject);
var
  lItem: TRecorderSdbNode;
begin
  lItem := SelectedItem;
  btnApplyName.Enabled := (lItem <> nil) and (lItem.ItemKind = sikScale) and
    (Trim(edKey.Text) <> '') and
    (Trim(edKey.Text) <> Trim(RecorderSdbNodeDisplayName(lItem)));
end;

procedure TRecorderSdbSelectDialog.edKeyKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> 13 then
    Exit;
  Key := 0;
  ApplyCalibrationName;
end;

procedure TRecorderSdbSelectDialog.btnApplyNameClick(Sender: TObject);
begin
  ApplyCalibrationName;
end;

procedure TRecorderSdbSelectDialog.ApplyCalibrationName;
var
  lError: string;
  lItem: TRecorderSdbNode;
  lKey: string;
begin
  lItem := SelectedItem;
  if (lItem = nil) or (lItem.ItemKind <> sikScale) then
    Exit;
  lKey := lItem.ScaleInfo.Key;
  if not RecorderSdbRenameCalibration(lKey, edKey.Text, lError) then
  begin
    MessageDlg('Переименование ГХ', lError, mtError, [mbOK], 0);
    Exit;
  end;
  ReloadTree(lKey);
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

function TRecorderSdbSelectDialog.SelectedChoice: TRecorderSdbNode;
begin
  Result := nil;
  if (SelectedItem <> nil) and
    (((not fSelectFolders) and (SelectedItem.ItemKind = sikScale)) or
    (fSelectFolders and (SelectedItem.ItemKind in [sikRoot, sikFolder]))) then
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
  tsTable.TabVisible := True;
  tsChart.TabVisible := True;
  tsParameters.TabVisible := False;
  pnFormulaDetails.Visible := False;
  if fCalibrationEditor <> nil then
    fCalibrationEditor.Visible := False;
  if fStrainEditor <> nil then
    fStrainEditor.Visible := False;
  sbStrainEditor.Visible := False;
  pnStrainActions.Visible := False;
  seriesScale.Clear;
  chartScale.Title.Visible := False;
end;

procedure TRecorderSdbSelectDialog.ShowNodeCommonInfo(AItem: TRecorderSdbNode);
begin
  edKey.ReadOnly := True;
  btnApplyName.Enabled := False;
  edKey.Text := '';
  edDescription.Text := '';
  if AItem = nil then
    Exit;
  RecorderSdbReloadNodeMetadata(AItem);
  edKey.Text := RecorderSdbNodeDisplayName(AItem);
  edDescription.Text := RecorderSdbNodeDisplayDescription(AItem);
  edKey.ReadOnly := AItem.ItemKind <> sikScale;
end;

procedure TRecorderSdbSelectDialog.UpdateScaleChart(
  ACalibration: TRecorderCalibration; const AMinX, AMaxX: Double);
var
  I: Integer;
  lMaxX: Double;
  lMinX: Double;
begin
  ConfigureScaleChart;
  ConfigureScaleSeries;
  seriesScale.Clear;
  if ACalibration = nil then
  begin
    chartScale.Title.Visible := False;
    Exit;
  end;
  if ACalibration.Kind in [rckScale, rckLinear] then
  begin
    lMinX := AMinX;
    lMaxX := AMaxX;
    if SameValue(lMinX, lMaxX) then
    begin
      lMinX := 0;
      lMaxX := 1;
    end;
    seriesScale.AddXY(lMinX, ACalibration.Transform(lMinX));
    seriesScale.AddXY(lMaxX, ACalibration.Transform(lMaxX));
  end
  else
  begin
    if ACalibration.PointCount = 0 then
    begin
      chartScale.Title.Visible := False;
      Exit;
    end;
    for I := 0 to ACalibration.PointCount - 1 do
      seriesScale.AddXY(ACalibration.PointAt(I).X, ACalibration.PointAt(I).Y);
  end;
  chartScale.BottomAxis.Title.Caption := ACalibration.UnitIn;
  chartScale.LeftAxis.Title.Caption := ACalibration.UnitOut;
  chartScale.Title.Text.Clear;
  chartScale.Title.Text.Add('ГХ');
  chartScale.Title.Visible := True;
end;

procedure TRecorderSdbSelectDialog.ShowCalibrationEditor(
  ACalibration: TRecorderCalibration; const AKey: string);
begin
  FreeAndNil(fCalibrationDraft);
  fCalibrationDraft := ACalibration.Clone;
  fCalibrationKey := AKey;
  if fCalibrationEditor = nil then
  begin
    fCalibrationEditor := TRecorderCalibrationPropertiesDialog.Create(Self);
    fCalibrationEditor.EmbedIn(sbStrainEditor, fCalibrationDraft);
  end
  else
  begin
    fCalibrationEditor.EditCalibration(fCalibrationDraft);
    fCalibrationEditor.Visible := True;
  end;
  if fStrainEditor <> nil then
    fStrainEditor.Visible := False;
  pnFormulaDetails.Visible := False;
  sbStrainEditor.Visible := True;
  pnStrainActions.Visible := True;
  btnSaveStrain.Caption := 'Сохранить ГХ';
  tsParameters.Caption := 'Настройка';
  tsTable.TabVisible := False;
  tsParameters.TabVisible := True;
  pcScaleData.ActivePage := tsParameters;
  fScaleDataActiveTab := tsParameters;
end;

procedure TRecorderSdbSelectDialog.ShowFormulaDetails(
  ACalibration: TRecorderCalibration);
var
  lInputPerOutput: string;
  lOutputPerInput: string;
begin
  tsTable.TabVisible := False;
  tsParameters.TabVisible := True;
  tsParameters.Caption := 'Параметры';
  sbStrainEditor.Visible := False;
  pnStrainActions.Visible := False;
  pnFormulaDetails.Visible := True;

  if ACalibration.Kind = rckLinear then
    lbFormulaKindValue.Caption := 'Прямая kx+b'
  else
    lbFormulaKindValue.Caption := 'Масштабный множитель';
  lInputPerOutput := ACalibration.UnitIn + '/' + ACalibration.UnitOut;
  lOutputPerInput := ACalibration.UnitOut + '/' + ACalibration.UnitIn;
  if SameValue(ACalibration.Scale, 0.0) then
    lbFormulaSensitivityValue.Caption := 'не определена (' + lInputPerOutput + ')'
  else
    lbFormulaSensitivityValue.Caption := FormatFloat('0.###############',
      1.0 / ACalibration.Scale) + ' ' + lInputPerOutput;
  lbFormulaScaleValue.Caption := FormatFloat('0.###############',
    ACalibration.Scale) + ' ' + lOutputPerInput;
  lbFormulaOffset.Visible := ACalibration.Kind = rckLinear;
  lbFormulaOffsetValue.Visible := lbFormulaOffset.Visible;
  lbFormulaOffsetValue.Caption := FormatFloat('0.###############',
    ACalibration.Offset) + ' ' + ACalibration.UnitOut;

  pcScaleData.ActivePage := tsParameters;
  fScaleDataActiveTab := tsParameters;
end;

procedure TRecorderSdbSelectDialog.ShowStrainDetails(
  ACalibration: TRecorderCalibration; const AKey: string);
var
  I: Integer;
  lCfg: TRecorderStrainConfig;
  lMaxX: Double;
  lMinX: Double;
  lX: Double;
begin
  FreeAndNil(fStrainDraft);
  fStrainDraft := ACalibration.Clone;
  fStrainKey := AKey;
  if fStrainEditor = nil then
  begin
    fStrainEditor := TRecorderStrainCalibrationFrame.Create(Self);
    fStrainEditor.Parent := sbStrainEditor;
    fStrainEditor.Align := alTop;
  end;
  fStrainEditor.LoadCalibration(fStrainDraft);
  fStrainEditor.Visible := True;
  if fCalibrationEditor <> nil then
    fCalibrationEditor.Visible := False;
  pnFormulaDetails.Visible := False;
  sbStrainEditor.Visible := True;
  pnStrainActions.Visible := True;
  btnSaveStrain.Caption := 'Сохранить ГХ';
  tsParameters.Caption := 'Настройка';
  tsTable.TabVisible := False;
  tsParameters.TabVisible := True;
  if pcScaleData.ActivePage <> tsChart then
  begin
    pcScaleData.ActivePage := tsParameters;
    fScaleDataActiveTab := tsParameters;
  end;

  lCfg := TRecorderStrainConfig.Create;
  try
    lCfg.Load(ACalibration.ModuleData);
    edRange.Text := UTF8Encode('±') + FormatFloat('0.###############',
      lCfg.MaxMicrostrain) + UTF8Encode(' мкстр');
    ConfigureScaleChart;
    ConfigureScaleSeries;
    seriesScale.Clear;
    if RecorderStrainInputRange(lCfg, lMinX, lMaxX) then
    begin
      for I := 0 to 100 do
      begin
        lX := lMinX + (lMaxX - lMinX) * I / 100;
        seriesScale.AddXY(lX, ACalibration.Transform(lX));
      end;
      chartScale.BottomAxis.Title.Caption := ACalibration.UnitIn;
      chartScale.LeftAxis.Title.Caption := ACalibration.UnitOut;
      chartScale.Title.Text.Clear;
      chartScale.Title.Text.Add('Тензокалькуляторная ГХ');
      chartScale.Title.Visible := True;
    end;
  finally
    lCfg.Free;
  end;
end;

procedure TRecorderSdbSelectDialog.ShowScaleDetails(AItem: TRecorderSdbNode);
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lInfo: TSdbScaleInfo;
begin
  lInfo := AItem.ScaleInfo;
  edUnits.Text := lInfo.SrcUnits + ' -> ' + lInfo.DstUnits;

  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibrationFromInfo(lInfo, lCalibration) then
      Exit;
    if lCalibration.Kind = rckStrain then
    begin
      ShowStrainDetails(lCalibration, lInfo.Key);
      Exit;
    end;
    if lCalibration.Kind <> rckStrain then
      ShowCalibrationEditor(lCalibration, lInfo.Key);
    edRange.Text := FormatFloat('0.######', lInfo.SrcFrom) + ' .. ' +
      FormatFloat('0.######', lInfo.SrcTo) + ' -> ' +
      FormatFloat('0.######', lInfo.DstFrom) + ' .. ' +
      FormatFloat('0.######', lInfo.DstTo);
    gridPoints.RowCount := Max(2, lCalibration.PointCount + 1);
    for I := 0 to lCalibration.PointCount - 1 do
    begin
      gridPoints.Cells[0, I + 1] := IntToStr(I + 1);
      gridPoints.Cells[1, I + 1] := FormatFloat('0.###############',
        lCalibration.PointAt(I).X);
      gridPoints.Cells[2, I + 1] := FormatFloat('0.###############',
        lCalibration.PointAt(I).Y);
    end;
    UpdateScaleChart(lCalibration, lInfo.SrcFrom, lInfo.SrcTo);
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
  btnSelect.Enabled := SelectedChoice <> nil;
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
  lScale := SelectedChoice;
  if lScale = nil then
    Exit;
  if lScale.ItemKind = sikScale then
    fSelectedKey := lScale.ScaleInfo.Key
  else
    fSelectedKey := lScale.FolderInfo.Key;
  ModalResult := mrOk;
end;

procedure TRecorderSdbSelectDialog.treeSdbDblClick(Sender: TObject);
begin
  if fSelectFolders then
  begin
    if (treeSdb.Selected <> nil) and treeSdb.Selected.HasChildren then
      treeSdb.Selected.Expanded := not treeSdb.Selected.Expanded;
  end
  else
    btnSelectClick(Sender);
end;

procedure TRecorderSdbSelectDialog.btnSaveStrainClick(Sender: TObject);
var
  lError: string;
  lKey: string;
begin
  if (fStrainEditor <> nil) and fStrainEditor.Visible and
    (fStrainDraft <> nil) and (fStrainKey <> '') then
  begin
    if not fStrainEditor.TryApply(fStrainDraft, lError) then
    begin
      if lError <> '' then
        MessageDlg('Настройка ГХ', lError, mtError, [mbOK], 0);
      Exit;
    end;
    lKey := fStrainKey;
    if not RecorderSdbUpdateCalibration(lKey, fStrainDraft, lError) then
    begin
      MessageDlg('Сохранение ГХ', lError, mtError, [mbOK], 0);
      Exit;
    end;
  end
  else if (fCalibrationEditor <> nil) and fCalibrationEditor.Visible and
    (fCalibrationDraft <> nil) and (fCalibrationKey <> '') then
  begin
    fCalibrationEditor.ApplyChanges;
    lKey := fCalibrationKey;
    if not RecorderSdbUpdateCalibration(lKey, fCalibrationDraft, lError) then
    begin
      MessageDlg('Сохранение ГХ', lError, mtError, [mbOK], 0);
      Exit;
    end;
  end
  else
    Exit;
  ReloadTree(lKey);
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
      (((TRecorderSdbNode(lNode.Data).ItemKind = sikScale) and
      SameText(TRecorderSdbNode(lNode.Data).ScaleInfo.Key, lKey)) or
      ((TRecorderSdbNode(lNode.Data).ItemKind in [sikRoot, sikFolder]) and
      SameText(TRecorderSdbNode(lNode.Data).FolderInfo.Key, lKey))) then
    begin
      treeSdb.Selected := lNode;
      lNode.MakeVisible;
      Exit;
    end;
    lNode := lNode.GetNext;
  end;
end;

function TRecorderSdbSelectDialog.Execute(const AInitialKey: string;
  ASelectFolders: Boolean; out ASelectedKey: string): Boolean;
begin
  ASelectedKey := '';
  fSelectedKey := '';
  fSelectFolders := ASelectFolders;
  if fSelectFolders then
  begin
    Caption := 'Выбор папки базы градуировочных характеристик';
    btnSelect.Caption := 'Экспортировать';
  end;
  fTree := TRecorderSdbTree.Create;
  try
    ReloadTree(AInitialKey);
    Result := ShowModal = mrOk;
    if Result then
      ASelectedKey := fSelectedKey;
  finally
    fTree.Free;
    fTree := nil;
  end;
end;

end.
