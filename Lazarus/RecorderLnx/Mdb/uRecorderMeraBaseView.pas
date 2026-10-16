unit uRecorderMeraBaseView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Grids, Dialogs,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderMdbTypes, uRecorderMdbManager, uRecorderMeraBaseModel;

type
  { Embedded operator surface for the XML test database. It persists the
    selected database root and context in its visual component model. }
  TRecorderMeraBaseView = class(TPanel, IVForm)
  private
    fManager: TRecorderMdbManager;
    fComponent: TRecorderMeraBaseComponent;
    fBottomPanel: TPanel;
    fObjects: TMdbObjectInfos;
    fTests: TMdbTestInfos;
    fMeasurements: TMdbMeasurementInfos;
    fUpdating: Boolean;
    fEditMode: Boolean;
    fObjectCombo: TComboBox;
    fObjectType: TComboBox;
    fLoadedType: string;
    fTestCombo: TComboBox;
    fTestType: TEdit;
    fTestDate: TCheckBox;
    fRegistrationCombo: TComboBox;
    fAlarmCheck: TCheckBox;
    fProperties: TStringGrid;
    fAddProperty, fDeleteProperty: TButton;
    fContextEdit: TEdit;
    fPathEdit: TEdit;
    fApplyButton: TButton;
    fRefreshButton: TButton;
    fSettingsButton: TButton;
    fBrowseButton: TButton;
    fEnabledCheck: TCheckBox;
    fStatusLabel: TLabel;
    fSelectedPath: TEdit;
    function AddLabel(AParent: TWinControl; const ACaption: string;
      ALeft, ATop: Integer): TLabel;
    function ItemDataIndex(ACombo: TComboBox): Integer;
    function SelectedObjectIndex: Integer;
    function SelectedTestIndex: Integer;
    function ComboHasText(ACombo: TComboBox; const AText: string): Boolean;
    procedure UpdateDraftColors;
    procedure TypeSelected(Sender: TObject);
    procedure AddPropertyClick(Sender: TObject);
    procedure DeletePropertyClick(Sender: TObject);
    procedure PropertySelect(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure LoadObjectProperties;
    procedure SaveObjectProperties(const AObjectId: string = '');
    procedure CreateEnteredBranch;
    procedure BuildControls;
    procedure LayoutBottomControls;
    procedure BottomPanelResize(Sender: TObject);
    procedure LoadObjects;
    procedure LoadTests;
    procedure LoadMeasurements;
    procedure SelectObjectById(const AId: string);
    procedure SelectTestById(const AId: string);
    procedure UpdateDetails;
    procedure SetStatus(const AText: string; AIsError: Boolean = False);
    procedure ObjectChanged(Sender: TObject);
    procedure TestChanged(Sender: TObject);
    procedure RegistrationChanged(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    procedure ApplyEditMode(AValue: Boolean);
    property EditMode: Boolean read fEditMode write fEditMode;
  end;

implementation

uses
  Graphics, FileCtrl, DateUtils, Math, uRecorderXmlDatabase,
  uRecorderMdbDialog, uRecorderMeraPaths;

const
  CMdbDraftColor = TColor($00E1D5FF);

constructor TRecorderMeraBaseView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Color := clBtnFace;
  BuildControls;
end;

destructor TRecorderMeraBaseView.Destroy;
begin
  fManager.Free;
  inherited Destroy;
end;

function TRecorderMeraBaseView.AddLabel(AParent: TWinControl;
  const ACaption: string; ALeft, ATop: Integer): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  Result.Left := ALeft;
  Result.Top := ATop;
end;

procedure TRecorderMeraBaseView.BuildControls;
var
  lLeft, lRight, lBottom: TPanel;
  lObjectGroup, lTestGroup, lRegGroup, lContextGroup: TGroupBox;
begin
  lBottom := TPanel.Create(Self);
  fBottomPanel := lBottom;
  lBottom.Parent := Self;
  lBottom.Align := alBottom;
  lBottom.Height := 108;
  lBottom.BevelOuter := bvLowered;
  lBottom.OnResize := @BottomPanelResize;

  AddLabel(lBottom, 'Путь к БД:', 8, 9);
  fPathEdit := TEdit.Create(Self);
  fPathEdit.Parent := lBottom;
  fPathEdit.SetBounds(82, 5, 180, 27);
  fPathEdit.ReadOnly := True;
  fPathEdit.Anchors := [akLeft, akTop];
  fBrowseButton := TButton.Create(Self);
  fBrowseButton.Parent := lBottom;
  fBrowseButton.SetBounds(394, 4, 38, 29);
  fBrowseButton.Caption := '...';
  fBrowseButton.Hint := 'Выбрать каталог XML-базы';
  fBrowseButton.ShowHint := True;
  fBrowseButton.OnClick := @BrowseClick;
  fSettingsButton := TButton.Create(Self);
  fSettingsButton.Parent := lBottom;
  fSettingsButton.SetBounds(438, 4, 48, 29);
  fSettingsButton.Caption := 'БД';
  fSettingsButton.Hint := 'Открыть настройку базы испытаний';
  fSettingsButton.ShowHint := True;
  fSettingsButton.OnClick := @SettingsClick;
  fRefreshButton := TButton.Create(Self);
  fRefreshButton.Parent := lBottom;
  fRefreshButton.SetBounds(492, 4, 82, 29);
  fRefreshButton.Caption := 'Обновить';
  fRefreshButton.Hint := 'Создать недостающие элементы и обновить XML-базу';
  fRefreshButton.ShowHint := True;
  fRefreshButton.OnClick := @RefreshClick;
  fApplyButton := TButton.Create(Self);
  fApplyButton.Parent := lBottom;
  fApplyButton.SetBounds(492, 4, 82, 29);
  fApplyButton.Caption := 'Применить';
  fApplyButton.OnClick := @ApplyClick;
  fEnabledCheck := TCheckBox.Create(Self);
  fEnabledCheck.Parent := lBottom;
  fEnabledCheck.SetBounds(82, 37, 180, 24);
  fEnabledCheck.Caption := 'XML-база доступна';
  fEnabledCheck.Enabled := False;
  fStatusLabel := TLabel.Create(Self);
  fStatusLabel.Parent := lBottom;
  fStatusLabel.SetBounds(8, 56, 566, 18);
  fStatusLabel.AutoSize := False;
  fStatusLabel.Anchors := [akLeft, akTop, akRight];
  fStatusLabel.WordWrap := True;
  fSelectedPath := TEdit.Create(Self);
  fSelectedPath.Parent := lBottom;
  fSelectedPath.ReadOnly := True;
  fSelectedPath.SetBounds(8, 76, 560, 24);

  LayoutBottomControls;

  lLeft := TPanel.Create(Self);
  lLeft.Parent := Self;
  lLeft.Align := alLeft;
  lLeft.Width := 330;
  lLeft.BevelOuter := bvNone;

  lObjectGroup := TGroupBox.Create(Self);
  lObjectGroup.Parent := lLeft;
  lObjectGroup.Align := alTop;
  lObjectGroup.Height := 120;
  lObjectGroup.Caption := 'Объект';
  AddLabel(lObjectGroup, 'Наименование:', 12, 25);
  fObjectCombo := TComboBox.Create(Self);
  fObjectCombo.Parent := lObjectGroup;
  fObjectCombo.SetBounds(12, 45, 305, 27);
  fObjectCombo.Style := csDropDown;
  fObjectCombo.OnChange := @ObjectChanged;
  AddLabel(lObjectGroup, 'Тип:', 12, 83);
  fObjectType := TComboBox.Create(Self);
  fObjectType.Parent := lObjectGroup;
  fObjectType.SetBounds(55, 79, 262, 27);
  fObjectType.Style := csDropDown;
  fObjectType.OnSelect := @TypeSelected;
  fObjectType.OnExit := @TypeSelected;

  lTestGroup := TGroupBox.Create(Self);
  lTestGroup.Parent := lLeft;
  lTestGroup.Align := alTop;
  lTestGroup.Height := 145;
  lTestGroup.Caption := 'Испытание';
  AddLabel(lTestGroup, 'Наименование:', 12, 25);
  fTestCombo := TComboBox.Create(Self);
  fTestCombo.Parent := lTestGroup;
  fTestCombo.SetBounds(12, 45, 230, 27);
  fTestCombo.Style := csDropDown;
  fTestCombo.OnChange := @TestChanged;
  fTestDate := TCheckBox.Create(Self);
  fTestDate.Parent := lTestGroup;
  fTestDate.SetBounds(250, 47, 65, 24);
  fTestDate.Caption := 'Дата';
  fTestDate.Enabled := False;
  AddLabel(lTestGroup, 'Тип:', 12, 84);
  fTestType := TEdit.Create(Self);
  fTestType.Parent := lTestGroup;
  fTestType.SetBounds(12, 104, 305, 27);
  fTestType.ReadOnly := True;

  lRegGroup := TGroupBox.Create(Self);
  lRegGroup.Parent := lLeft;
  lRegGroup.Align := alClient;
  lRegGroup.Caption := 'Регистрация';
  AddLabel(lRegGroup, 'Наименование:', 12, 28);
  fRegistrationCombo := TComboBox.Create(Self);
  fRegistrationCombo.Parent := lRegGroup;
  fRegistrationCombo.SetBounds(12, 49, 230, 27);
  fRegistrationCombo.Style := csDropDown;
  fRegistrationCombo.OnChange := @RegistrationChanged;
  fAlarmCheck := TCheckBox.Create(Self);
  fAlarmCheck.Parent := lRegGroup;
  fAlarmCheck.SetBounds(250, 51, 72, 24);
  fAlarmCheck.Caption := 'Авария';
  fAlarmCheck.Enabled := False;

  lRight := TPanel.Create(Self);
  lRight.Parent := Self;
  lRight.Align := alClient;
  lRight.BevelOuter := bvNone;
  fProperties := TStringGrid.Create(Self);
  fProperties.Parent := lRight;
  fProperties.Align := alClient;
  fProperties.ColCount := 2;
  fProperties.RowCount := 4;
  fProperties.FixedCols := 0;
  fProperties.FixedRows := 1;
  fProperties.Cells[0, 0] := 'Свойство';
  fProperties.Cells[1, 0] := 'Значение';
  fProperties.ColWidths[0] := 115;
  fProperties.ColWidths[1] := 125;
  fProperties.OnSelectCell := @PropertySelect;

  lContextGroup := TGroupBox.Create(Self);
  lContextGroup.Parent := lRight;
  lContextGroup.Align := alBottom;
  lContextGroup.Height := 128;
  lContextGroup.Caption := 'Текущий контекст';
  fAddProperty := TButton.Create(Self);
  fAddProperty.Parent := lContextGroup;
  fAddProperty.SetBounds(12, 20, 112, 26);
  fAddProperty.Caption := '+ Свойство';
  fAddProperty.OnClick := @AddPropertyClick;
  fDeleteProperty := TButton.Create(Self);
  fDeleteProperty.Parent := lContextGroup;
  fDeleteProperty.SetBounds(130, 20, 112, 26);
  fDeleteProperty.Caption := '− Свойство';
  fDeleteProperty.OnClick := @DeletePropertyClick;
  AddLabel(lContextGroup, 'Объект / испытание:', 12, 49);
  fContextEdit := TEdit.Create(Self);
  fContextEdit.Parent := lContextGroup;
  fContextEdit.SetBounds(12, 66, 232, 27);
  fContextEdit.ReadOnly := True;
  fContextEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(lContextGroup,
    'Выбор применяется к следующим регистрациям замеров.', 12, 102);
end;

procedure TRecorderMeraBaseView.LayoutBottomControls;
const
  CRightMargin = 8;
  CGap = 6;
begin
  if (fBottomPanel = nil) or (fPathEdit = nil) then Exit;
  fApplyButton.Left := fBottomPanel.ClientWidth - CRightMargin -
    fApplyButton.Width;
  fRefreshButton.Left := fApplyButton.Left - CGap - fRefreshButton.Width;
  fSettingsButton.Left := fRefreshButton.Left - CGap - fSettingsButton.Width;
  fBrowseButton.Left := fSettingsButton.Left - CGap - fBrowseButton.Width;
  fPathEdit.Width := fBrowseButton.Left - CGap - fPathEdit.Left;
  if fPathEdit.Width < 80 then fPathEdit.Width := 80;
  if fSelectedPath <> nil then
    fSelectedPath.Width := fBottomPanel.ClientWidth - 16;
end;

procedure TRecorderMeraBaseView.BottomPanelResize(Sender: TObject);
begin
  LayoutBottomControls;
end;

function TRecorderMeraBaseView.ItemDataIndex(ACombo: TComboBox): Integer;
begin
  if (ACombo = nil) or (ACombo.ItemIndex < 0) then Exit(-1);
  Result := PtrInt(ACombo.Items.Objects[ACombo.ItemIndex]) - 1;
end;

function TRecorderMeraBaseView.SelectedObjectIndex: Integer;
begin
  Result := ItemDataIndex(fObjectCombo);
end;

function TRecorderMeraBaseView.SelectedTestIndex: Integer;
begin
  Result := ItemDataIndex(fTestCombo);
end;

function TRecorderMeraBaseView.ComboHasText(ACombo: TComboBox;
  const AText: string): Boolean;
var I: Integer;
begin
  Result := False;
  if (ACombo = nil) or (Trim(AText) = '') then Exit;
  for I := 0 to ACombo.Items.Count - 1 do
    if SameText(Trim(ACombo.Items[I]), Trim(AText)) then Exit(True);
end;

procedure TRecorderMeraBaseView.UpdateDraftColors;

  procedure SetDraftColor(ACombo: TComboBox);
  begin
    if (Trim(ACombo.Text) = '') or ComboHasText(ACombo, ACombo.Text) then
      ACombo.Color := clWindow
    else
      ACombo.Color := CMdbDraftColor;
  end;

begin
  SetDraftColor(fObjectCombo);
  SetDraftColor(fTestCombo);
  SetDraftColor(fRegistrationCombo);
end;

procedure TRecorderMeraBaseView.PropertySelect(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if (ARow >= 4) or ((ARow = 1) and (ACol = 1)) then
    fProperties.Options := fProperties.Options + [goEditing]
  else
    fProperties.Options := fProperties.Options - [goEditing];
end;

procedure TRecorderMeraBaseView.LoadObjectProperties;
var
  Names: TStringList;
  Node: TRecorderXmlDbNode;
  I, ObjectIndex: Integer;
begin
  if fManager = nil then Exit;
  Names := TStringList.Create;
  try
    fManager.Repository.LoadTypeProperties(Trim(fObjectType.Text), Names);
    fLoadedType := Trim(fObjectType.Text);
    fProperties.RowCount := Max(4, 4 + Names.Count);
    Node := nil;
    ObjectIndex := SelectedObjectIndex;
    if ObjectIndex >= 0 then Node := fManager.Repository.FindNode(fObjects[ObjectIndex].Id);
    for I := 0 to Names.Count - 1 do
    begin
      fProperties.Cells[0, I + 4] := Names[I];
      fProperties.Cells[1, I + 4] := '';
      if Node <> nil then
        fProperties.Cells[1, I + 4] := Node.Properties.Values['User.' + Names[I]];
    end;
  finally
    Names.Free;
  end;
end;

procedure TRecorderMeraBaseView.TypeSelected(Sender: TObject);
begin
  if fUpdating then Exit;
  if SameText(fLoadedType, Trim(fObjectType.Text)) then Exit;
  if not ComboHasText(fObjectType, fObjectType.Text) then Exit;
  LoadObjectProperties;
end;

procedure TRecorderMeraBaseView.AddPropertyClick(Sender: TObject);
begin
  if fManager = nil then Exit;
  fProperties.RowCount := fProperties.RowCount + 1;
  fProperties.Row := fProperties.RowCount - 1;
  fProperties.Col := 0;
  fProperties.Options := fProperties.Options + [goEditing];
  fProperties.SetFocus;
end;

procedure TRecorderMeraBaseView.DeletePropertyClick(Sender: TObject);
var I, Row: Integer;
begin
  Row := fProperties.Row;
  if Row < 4 then Exit;
  for I := Row to fProperties.RowCount - 2 do
    fProperties.Rows[I].Assign(fProperties.Rows[I + 1]);
  fProperties.RowCount := fProperties.RowCount - 1;
end;

procedure TRecorderMeraBaseView.SaveObjectProperties(const AObjectId: string);
var
  Names: TStringList;
  Node: TRecorderXmlDbNode;
  Id: string;
  I, ObjectIndex: Integer;
begin
  if fManager = nil then Exit;
  Id := AObjectId;
  ObjectIndex := SelectedObjectIndex;
  if (Id = '') and (ObjectIndex >= 0) then Id := fObjects[ObjectIndex].Id;
  if Id = '' then Exit;
  Node := fManager.Repository.FindNode(Id);
  if Node = nil then Exit;
  Names := TStringList.Create;
  try
    for I := 4 to fProperties.RowCount - 1 do
      if Trim(fProperties.Cells[0, I]) <> '' then
        Names.Add(Trim(fProperties.Cells[0, I]));
    fManager.Repository.SaveTypeProperties(Trim(fObjectType.Text), Names);
    fManager.Repository.UpdateObject(Id, Node.Name, Trim(fObjectType.Text),
      fProperties.Cells[1, 1]);
    for I := 4 to fProperties.RowCount - 1 do
      if Trim(fProperties.Cells[0, I]) <> '' then
        Node.Properties.Values['User.' + Trim(fProperties.Cells[0, I])] :=
          fProperties.Cells[1, I];
    fManager.Repository.SaveNode(Node);
    fManager.Repository.ListObjectTypes(fObjectType.Items);
  finally
    Names.Free;
  end;
end;

procedure TRecorderMeraBaseView.SetStatus(const AText: string;
  AIsError: Boolean);
begin
  fStatusLabel.Caption := AText;
  if AIsError then
    fStatusLabel.Font.Color := clRed
  else
    fStatusLabel.Font.Color := clGreen;
end;

procedure TRecorderMeraBaseView.LoadObjects;
var I: Integer;
begin
  fManager.Repository.ListObjectTypes(fObjectType.Items);
  fManager.Repository.ListObjects(fObjects);
  fObjectCombo.Items.BeginUpdate;
  try
    fObjectCombo.Clear;
    for I := 0 to High(fObjects) do
      fObjectCombo.Items.AddObject(fObjects[I].Name,
        TObject(PtrInt(I + 1)));
  finally
    fObjectCombo.Items.EndUpdate;
  end;
  SelectObjectById(fManager.Context.ObjectId);
  if (fObjectCombo.ItemIndex < 0) and (fObjectCombo.Items.Count > 0) then
    fObjectCombo.ItemIndex := 0;
  LoadTests;
end;

procedure TRecorderMeraBaseView.LoadTests;
var I, lObjectIndex: Integer;
begin
  SetLength(fTests, 0);
  fTestCombo.Clear;
  lObjectIndex := SelectedObjectIndex;
  if lObjectIndex >= 0 then
    fManager.Repository.ListTests(fObjects[lObjectIndex].Id, fTests);
  for I := 0 to High(fTests) do
    fTestCombo.Items.AddObject(fTests[I].Name, TObject(PtrInt(I + 1)));
  SelectTestById(fManager.Context.TestId);
  if (fTestCombo.ItemIndex < 0) and (fTestCombo.Items.Count > 0) then
    fTestCombo.ItemIndex := 0;
  LoadMeasurements;
end;

procedure TRecorderMeraBaseView.LoadMeasurements;
var I, lObjectIndex, lTestIndex: Integer;
begin
  SetLength(fMeasurements, 0);
  fRegistrationCombo.Clear;
  lObjectIndex := SelectedObjectIndex;
  lTestIndex := SelectedTestIndex;
  if (lObjectIndex >= 0) and (lTestIndex >= 0) then
    fManager.Repository.ListMeasurements(fObjects[lObjectIndex].Id,
      fTests[lTestIndex].Id, fMeasurements);
  for I := 0 to High(fMeasurements) do
    if Trim(fMeasurements[I].Reason) <> '' then
      fRegistrationCombo.Items.AddObject(fMeasurements[I].Reason,
        TObject(PtrInt(I + 1)))
    else
      fRegistrationCombo.Items.AddObject(fMeasurements[I].RegistrationId,
        TObject(PtrInt(I + 1)));
  if fRegistrationCombo.Items.Count > 0 then
    fRegistrationCombo.ItemIndex := 0;
  UpdateDetails;
end;

procedure TRecorderMeraBaseView.SelectObjectById(const AId: string);
var I, lIndex: Integer;
begin
  for I := 0 to fObjectCombo.Items.Count - 1 do
  begin
    lIndex := PtrInt(fObjectCombo.Items.Objects[I]) - 1;
    if (lIndex >= 0) and (fObjects[lIndex].Id = AId) then
    begin
      fObjectCombo.ItemIndex := I;
      Exit;
    end;
  end;
end;

procedure TRecorderMeraBaseView.SelectTestById(const AId: string);
var I, lIndex: Integer;
begin
  for I := 0 to fTestCombo.Items.Count - 1 do
  begin
    lIndex := PtrInt(fTestCombo.Items.Objects[I]) - 1;
    if (lIndex >= 0) and (fTests[lIndex].Id = AId) then
    begin
      fTestCombo.ItemIndex := I;
      Exit;
    end;
  end;
end;

procedure TRecorderMeraBaseView.UpdateDetails;
var lObjectIndex, lTestIndex, lMeasurementIndex: Integer;
begin
  lObjectIndex := SelectedObjectIndex;
  lTestIndex := SelectedTestIndex;
  fObjectType.Text := '';
  fTestType.Clear;
  fContextEdit.Clear;
  fProperties.Cells[0, 1] := 'sn';
  fProperties.Cells[1, 1] := '';
  fProperties.Cells[0, 2] := 'Тип объекта';
  fProperties.Cells[1, 2] := '';
  fProperties.Cells[0, 3] := 'Статус регистрации';
  fProperties.Cells[1, 3] := '';
  if lObjectIndex >= 0 then
  begin
    fObjectType.Text := fObjects[lObjectIndex].ObjectType;
    fProperties.Cells[1, 1] := fObjects[lObjectIndex].SerialNumber;
    fProperties.Cells[1, 2] := fObjects[lObjectIndex].ObjectType;
  end;
  LoadObjectProperties;
  if lTestIndex >= 0 then
  begin
    fTestType.Text := fTests[lTestIndex].MetadataJson;
    if lObjectIndex >= 0 then
      fContextEdit.Text := fObjects[lObjectIndex].Name + ' / ' +
        fTests[lTestIndex].Name;
  end;
  lMeasurementIndex := ItemDataIndex(fRegistrationCombo);
  fSelectedPath.Clear;
  if fManager <> nil then
  begin
    if (lMeasurementIndex >= 0) and (lObjectIndex >= 0) and
      (lTestIndex >= 0) then
      fSelectedPath.Text := fManager.Repository.BasePath +
        fManager.Repository.FindNode(fMeasurements[lMeasurementIndex].RegistrationId).RelativePath
    else if (lTestIndex >= 0) and (lObjectIndex >= 0) then
      fSelectedPath.Text := fManager.Repository.BasePath +
        fManager.Repository.FindNode(fTests[lTestIndex].Id).RelativePath
    else if lObjectIndex >= 0 then
      fSelectedPath.Text := fManager.Repository.BasePath +
        fManager.Repository.FindNode(fObjects[lObjectIndex].Id).RelativePath;
  end;
  if lMeasurementIndex >= 0 then
  begin
    fProperties.Cells[1, 3] := fMeasurements[lMeasurementIndex].Status;
    fAlarmCheck.Checked := SameText(fMeasurements[lMeasurementIndex].Status,
      'alarm');
  end
  else
    fAlarmCheck.Checked := False;
  fApplyButton.Enabled := (not fEditMode) and (lObjectIndex >= 0) and
    (lTestIndex >= 0);
end;

procedure TRecorderMeraBaseView.ObjectChanged(Sender: TObject);
begin
  if fUpdating then Exit;
  UpdateDraftColors;
  if fObjectCombo.ItemIndex < 0 then
  begin
    fTestCombo.ItemIndex := -1;
    fRegistrationCombo.ItemIndex := -1;
    UpdateDetails;
    Exit;
  end;
  try
    fUpdating := True;
    LoadTests;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderMeraBaseView.TestChanged(Sender: TObject);
begin
  if fUpdating then Exit;
  UpdateDraftColors;
  if fTestCombo.ItemIndex < 0 then
  begin
    fRegistrationCombo.ItemIndex := -1;
    UpdateDetails;
    Exit;
  end;
  try
    fUpdating := True;
    LoadMeasurements;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderMeraBaseView.RegistrationChanged(Sender: TObject);
begin
  if not fUpdating then
  begin
    UpdateDraftColors;
    UpdateDetails;
  end;
end;

procedure TRecorderMeraBaseView.ApplyClick(Sender: TObject);
var lObjectIndex, lTestIndex: Integer;
begin
  lObjectIndex := SelectedObjectIndex;
  lTestIndex := SelectedTestIndex;
  if lObjectIndex < 0 then Exit;
  try
    SaveObjectProperties;
    fManager.Repository.ListObjects(fObjects);
    if lTestIndex < 0 then
    begin
      UpdateDetails;
      SetStatus('Тип и свойства объекта сохранены');
      Exit;
    end;
    fManager.SelectContext(fObjects[lObjectIndex], fTests[lTestIndex]);
    fComponent.ObjectId := fManager.Context.ObjectId;
    fComponent.TestId := fManager.Context.TestId;
    SetStatus('Контекст применён: ' + fObjects[lObjectIndex].Name + ' / ' +
      fTests[lTestIndex].Name);
  except
    on E: Exception do
    begin
      SetStatus(E.Message, True);
      MessageDlg('База испытаний', E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TRecorderMeraBaseView.SettingsClick(Sender: TObject);
var lDialog: TRecorderMdbDialog;
begin
  if (fManager = nil) or (fComponent = nil) then Exit;
  lDialog := TRecorderMdbDialog.Create(Self);
  try
    if lDialog.Execute(fManager) then
    begin
      fComponent.ObjectId := fManager.Context.ObjectId;
      fComponent.TestId := fManager.Context.TestId;
      LoadObjects;
      SetStatus('Контекст применён: ' + fManager.Context.ObjectName + ' / ' +
        fManager.Context.TestName);
    end;
  finally
    lDialog.Free;
  end;
  fComponent.BasePath := fManager.Repository.BasePath;
  fPathEdit.Text := fComponent.BasePath;
  LoadObjects;
end;

procedure TRecorderMeraBaseView.BrowseClick(Sender: TObject);
var lPath: string;
begin
  if fComponent = nil then Exit;
  lPath := fComponent.BasePath;
  if not SelectDirectory('Каталог XML-базы испытаний', '', lPath) then Exit;
  fComponent.BasePath := ExcludeTrailingPathDelimiter(ExpandFileName(lPath));
  Configure(fComponent, nil);
end;

procedure TRecorderMeraBaseView.CreateEnteredBranch;
var
  lObjectName, lTestName, lRegistrationName: string;
  lObjectId, lTestId, lRegistrationId: string;
  I, lIndex: Integer;
begin
  lObjectName := Trim(fObjectCombo.Text);
  lTestName := Trim(fTestCombo.Text);
  lRegistrationName := Trim(fRegistrationCombo.Text);
  if lObjectName = '' then Exit;

  lObjectId := '';
  fManager.Repository.ListObjects(fObjects);
  for I := 0 to High(fObjects) do
    if SameText(fObjects[I].Name, lObjectName) then
    begin
      lObjectId := fObjects[I].Id;
      Break;
    end;
  if lObjectId = '' then
    lObjectId := fManager.Repository.CreateObject(lObjectName,
      Trim(fObjectType.Text), '');
  SaveObjectProperties(lObjectId);

  lTestId := '';
  if lTestName <> '' then
  begin
    fManager.Repository.ListTests(lObjectId, fTests);
    for I := 0 to High(fTests) do
      if SameText(fTests[I].Name, lTestName) then
      begin
        lTestId := fTests[I].Id;
        Break;
      end;
    if lTestId = '' then
      lTestId := fManager.Repository.CreateTest(lObjectId, lTestName,
        Trim(fTestType.Text), LocalTimeToUniversal(Now));
  end;

  lRegistrationId := '';
  if (lTestId <> '') and (lRegistrationName <> '') then
  begin
    fManager.Repository.ListMeasurements(lObjectId, lTestId, fMeasurements);
    for I := 0 to High(fMeasurements) do
      if SameText(fMeasurements[I].Reason, lRegistrationName) then
      begin
        lRegistrationId := fMeasurements[I].RegistrationId;
        Break;
      end;
    if lRegistrationId = '' then
      lRegistrationId := fManager.Repository.CreateRegistration(lObjectId,
        lTestId, lRegistrationName, '', LocalTimeToUniversal(Now));
  end;

  LoadObjects;
  SelectObjectById(lObjectId);
  LoadTests;
  if lTestId <> '' then
  begin
    SelectTestById(lTestId);
    LoadMeasurements;
  end;
  if lRegistrationId <> '' then
    for I := 0 to fRegistrationCombo.Items.Count - 1 do
    begin
      lIndex := PtrInt(fRegistrationCombo.Items.Objects[I]) - 1;
      if (lIndex >= 0) and
        SameText(fMeasurements[lIndex].RegistrationId, lRegistrationId) then
      begin
        fRegistrationCombo.ItemIndex := I;
        Break;
      end;
    end;
  if (SelectedObjectIndex >= 0) and (SelectedTestIndex >= 0) then
  begin
    fManager.SelectContext(fObjects[SelectedObjectIndex],
      fTests[SelectedTestIndex]);
    fComponent.ObjectId := fManager.Context.ObjectId;
    fComponent.TestId := fManager.Context.TestId;
  end;
  UpdateDraftColors;
  UpdateDetails;
end;

procedure TRecorderMeraBaseView.RefreshClick(Sender: TObject);
begin
  try
    fUpdating := True;
    CreateEnteredBranch;
    SetStatus('XML-база обновлена');
  except
    on E: Exception do SetStatus(E.Message, True);
  end;
  fUpdating := False;
end;

procedure TRecorderMeraBaseView.ApplyEditMode(AValue: Boolean);
begin
  fEditMode := AValue;
  fObjectCombo.Enabled := not AValue;
  fTestCombo.Enabled := not AValue;
  fRegistrationCombo.Enabled := not AValue;
  fRefreshButton.Enabled := not AValue;
  fSettingsButton.Enabled := not AValue;
  fBrowseButton.Enabled := not AValue;
  UpdateDetails;
end;

procedure TRecorderMeraBaseView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  FreeAndNil(fManager);
  fComponent := nil;
  if not (AComponent is TRecorderMeraBaseComponent) then
  begin
    SetStatus('Компонент базы испытаний не настроен', True);
    Exit;
  end;
  fComponent := TRecorderMeraBaseComponent(AComponent);
  if Trim(fComponent.BasePath) = '' then
    fComponent.BasePath := IncludeTrailingPathDelimiter(
      RecorderMeraFilesPath) + 'mdb';
  try
    fManager := TRecorderMdbManager.Create(fComponent.BasePath,
      fComponent.ObjectId, fComponent.TestId);
    fPathEdit.Text := fManager.Repository.BasePath;
    fEnabledCheck.Checked := DirectoryExists(fManager.Repository.BasePath);
    fUpdating := True;
    LoadObjects;
    if fManager.Context.IsValid then
      SetStatus('Активный контекст: ' + fManager.Context.ObjectName + ' / ' +
        fManager.Context.TestName)
    else
      SetStatus('Выберите изделие и испытание');
  except
    on E: Exception do SetStatus(E.Message, True);
  end;
  fUpdating := False;
end;

procedure TRecorderMeraBaseView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
begin
end;

function TRecorderMeraBaseView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorderMeraBaseComponent,
    TRecorderMeraBaseView);

end.
