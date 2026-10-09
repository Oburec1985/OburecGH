unit uRecorderMeraBaseView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Grids, Dialogs,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderSqlDbManager, uRecorderMdbTypes, uRecorderMdbManager,
  uRecorderMeraBaseModel;

type
  { Embedded operator surface for selecting the product/test context attached
    to subsequent SQL registrations. The application injects its live SQL
    manager; the view never owns or replaces that runtime. }
  TRecorderMeraBaseView = class(TPanel, IVForm)
  private
    fManager: TRecorderMdbManager;
    fObjects: TMdbObjectInfos;
    fTests: TMdbTestInfos;
    fMeasurements: TMdbMeasurementInfos;
    fUpdating: Boolean;
    fEditMode: Boolean;
    fObjectCombo: TComboBox;
    fObjectType: TEdit;
    fTestCombo: TComboBox;
    fTestType: TEdit;
    fTestDate: TCheckBox;
    fRegistrationCombo: TComboBox;
    fAlarmCheck: TCheckBox;
    fProperties: TStringGrid;
    fContextEdit: TEdit;
    fPathEdit: TEdit;
    fApplyButton: TButton;
    fRefreshButton: TButton;
    fEnabledCheck: TCheckBox;
    fStatusLabel: TLabel;
    class var fSqlDbManager: TRecorderSqlDbManager;
    function AddLabel(AParent: TWinControl; const ACaption: string;
      ALeft, ATop: Integer): TLabel;
    function ItemDataIndex(ACombo: TComboBox): Integer;
    function SelectedObjectIndex: Integer;
    function SelectedTestIndex: Integer;
    procedure BuildControls;
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class procedure SetSqlDbManager(AManager: TRecorderSqlDbManager);
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
  Graphics;

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

class procedure TRecorderMeraBaseView.SetSqlDbManager(
  AManager: TRecorderSqlDbManager);
begin
  fSqlDbManager := AManager;
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
  lBottom.Parent := Self;
  lBottom.Align := alBottom;
  lBottom.Height := 108;
  lBottom.BevelOuter := bvLowered;

  AddLabel(lBottom, 'Путь к БД:', 8, 9);
  fPathEdit := TEdit.Create(Self);
  fPathEdit.Parent := lBottom;
  fPathEdit.SetBounds(82, 5, 330, 27);
  fPathEdit.ReadOnly := True;
  fPathEdit.Anchors := [akLeft, akTop, akRight];
  fRefreshButton := TButton.Create(Self);
  fRefreshButton.Parent := lBottom;
  fRefreshButton.SetBounds(420, 4, 82, 29);
  fRefreshButton.Caption := 'Обновить';
  fRefreshButton.Anchors := [akTop, akRight];
  fRefreshButton.OnClick := @RefreshClick;
  fApplyButton := TButton.Create(Self);
  fApplyButton.Parent := lBottom;
  fApplyButton.SetBounds(508, 4, 72, 29);
  fApplyButton.Caption := 'Применить';
  fApplyButton.Anchors := [akTop, akRight];
  fApplyButton.OnClick := @ApplyClick;
  fEnabledCheck := TCheckBox.Create(Self);
  fEnabledCheck.Parent := lBottom;
  fEnabledCheck.SetBounds(185, 37, 160, 24);
  fEnabledCheck.Caption := 'SQL БД включена';
  fEnabledCheck.Enabled := False;
  fStatusLabel := TLabel.Create(Self);
  fStatusLabel.Parent := lBottom;
  fStatusLabel.SetBounds(8, 68, 566, 32);
  fStatusLabel.AutoSize := False;
  fStatusLabel.Anchors := [akLeft, akTop, akRight];
  fStatusLabel.WordWrap := True;

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
  fObjectCombo.Style := csDropDownList;
  fObjectCombo.OnChange := @ObjectChanged;
  AddLabel(lObjectGroup, 'Тип:', 12, 83);
  fObjectType := TEdit.Create(Self);
  fObjectType.Parent := lObjectGroup;
  fObjectType.SetBounds(55, 79, 262, 27);
  fObjectType.ReadOnly := True;

  lTestGroup := TGroupBox.Create(Self);
  lTestGroup.Parent := lLeft;
  lTestGroup.Align := alTop;
  lTestGroup.Height := 145;
  lTestGroup.Caption := 'Испытание';
  AddLabel(lTestGroup, 'Наименование:', 12, 25);
  fTestCombo := TComboBox.Create(Self);
  fTestCombo.Parent := lTestGroup;
  fTestCombo.SetBounds(12, 45, 230, 27);
  fTestCombo.Style := csDropDownList;
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
  fRegistrationCombo.Style := csDropDownList;
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
  fProperties.Options := fProperties.Options - [goEditing];

  lContextGroup := TGroupBox.Create(Self);
  lContextGroup.Parent := lRight;
  lContextGroup.Align := alBottom;
  lContextGroup.Height := 128;
  lContextGroup.Caption := 'Текущий контекст';
  AddLabel(lContextGroup, 'Объект / испытание:', 12, 28);
  fContextEdit := TEdit.Create(Self);
  fContextEdit.Parent := lContextGroup;
  fContextEdit.SetBounds(12, 49, 232, 27);
  fContextEdit.ReadOnly := True;
  fContextEdit.Anchors := [akLeft, akTop, akRight];
  AddLabel(lContextGroup,
    'Выбор применяется к следующим регистрациям SQL БД.', 12, 88);
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
  fObjectType.Clear;
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
  if lTestIndex >= 0 then
  begin
    fTestType.Text := fTests[lTestIndex].MetadataJson;
    if lObjectIndex >= 0 then
      fContextEdit.Text := fObjects[lObjectIndex].Name + ' / ' +
        fTests[lTestIndex].Name;
  end;
  lMeasurementIndex := ItemDataIndex(fRegistrationCombo);
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
  try
    fUpdating := True;
    LoadMeasurements;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderMeraBaseView.RegistrationChanged(Sender: TObject);
begin
  if not fUpdating then UpdateDetails;
end;

procedure TRecorderMeraBaseView.ApplyClick(Sender: TObject);
var lObjectIndex, lTestIndex: Integer;
begin
  lObjectIndex := SelectedObjectIndex;
  lTestIndex := SelectedTestIndex;
  if (lObjectIndex < 0) or (lTestIndex < 0) then Exit;
  try
    fManager.SelectContext(fObjects[lObjectIndex], fTests[lTestIndex]);
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

procedure TRecorderMeraBaseView.RefreshClick(Sender: TObject);
begin
  try
    fUpdating := True;
    LoadObjects;
    SetStatus('Данные базы обновлены');
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
  UpdateDetails;
end;

procedure TRecorderMeraBaseView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  FreeAndNil(fManager);
  if fSqlDbManager = nil then
  begin
    SetStatus('SQL БД RecorderLnx не инициализирована', True);
    Exit;
  end;
  try
    fManager := TRecorderMdbManager.Create(fSqlDbManager.Config,
      fSqlDbManager);
    fPathEdit.Text := fSqlDbManager.Config.Database;
    fEnabledCheck.Checked := fSqlDbManager.Config.Enabled;
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
