unit uRecorderImpactGeometryBindingDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Edits the durable FRF-to-geometry mapping. The dialog only changes the
  ImpactHammer model after OK; publishing and modifier creation remain in the
  application service and the selected 3D binding sink. }

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Grids, Graphics,
  ColorBox, u3dMotionContracts,
  Dialogs, uRecorderImpactHammerModel, uRecorderImpactHammerContracts;

type
  TRecorderImpactBindingRow = record
    Target3dNodeId: QWord;
    Target3dNodeName: string;
    PointNumber: Integer;
    PointLabel: string;
    EnvelopeXEnabled, EnvelopeYEnabled, EnvelopeZEnabled: Boolean;
    EnvelopeX, EnvelopeY, EnvelopeZ: Double;
    Axis: TImpactResponseAxis;
    IntensityOnly: Boolean;
    Visualization: TRecorderPointVisualization;
    Color: TColor;
    MarkerSizePixels: Double;
    IntensitySource: TRecorderIntensitySource;
    BandRms: Boolean;
    BandTolerancePercent: Double;
    GradientEnabled: Boolean;
  end;

  TRecorderImpactGeometryBindingDialog = class(TForm)
  published
    lblTarget, lblObject, lblMode, lblPoint, lblAxis, lblDisplay,
      lblColor, lblSize, lblSource, lblScale, lblAggregation, lblBandTolerance: TLabel;
    cbTarget, cbObject, cbMode, cbAxis, cbVisualization, cbSource, cbAggregation: TComboBox;
    grdChannels: TStringGrid;
    edPoint: TEdit;
    edLabel, edEnvelopeX: TEdit;
    lblPointLabel, lblEnvelope: TLabel;
    chkEnvelopeX: TCheckBox;
    chkCreateColorModifier, chkShowAnchors: TCheckBox;
    edSize: TEdit;
    edBandTolerance: TEdit;
    chkIntensityOnly: TCheckBox;
    chkGradient: TCheckBox;
    chkOnlySensors:TCheckBox;
    colorDisplay: TColorBox;
    btnOk, btnCancel: TButton;
    procedure TargetChange(Sender: TObject);
    procedure ChannelSelect(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure OkClick(Sender: TObject);
    procedure EditorChange(Sender: TObject);
  private
    fModel: TRecorderImpactHammerComponent;
    fCatalog: IRecorderModelPointCatalog;
    fRows: array of TRecorderImpactBindingRow;
    fObjectIds: array of QWord;
    fEditingIndex: Integer;
    fLoading: Boolean;
    fPreview: TNotifyEvent;
    procedure LoadTargets;
    procedure LoadObjects;
    procedure LoadChannels;
    procedure LoadEditor(AIndex: Integer);
    procedure SaveEditor;
    function SelectedObjectId: QWord;
    procedure ApplyToModel;
  public
    procedure Initialize(AModel:TRecorderImpactHammerComponent;
      APreview:TNotifyEvent=nil);
    class function Execute(AOwner: TComponent;
      AModel: TRecorderImpactHammerComponent;
      APreview: TNotifyEvent = nil): Boolean;
  end;

implementation

{$R *.lfm}

class function TRecorderImpactGeometryBindingDialog.Execute(AOwner: TComponent;
  AModel: TRecorderImpactHammerComponent; APreview: TNotifyEvent): Boolean;
var
  Dialog: TRecorderImpactGeometryBindingDialog;
  Backup: TRecorderImpactHammerComponent;
begin
  Backup := TRecorderImpactHammerComponent.Create;
  Backup.Assign(AModel);
  Dialog := TRecorderImpactGeometryBindingDialog.Create(AOwner);
  try
    Dialog.Initialize(AModel,APreview);
    Result := Dialog.ShowModal = mrOk;
    if not Result then
    begin
      AModel.Assign(Backup);
      if Assigned(APreview) then APreview(Dialog);
    end;
  finally
    ClearRecorderGeometryPreview;
    Dialog.Free;
    Backup.Free;
  end;
end;

procedure TRecorderImpactGeometryBindingDialog.Initialize(
  AModel:TRecorderImpactHammerComponent; APreview:TNotifyEvent);
begin
  fModel:=AModel;
  fPreview:=APreview;
  fEditingIndex:=-1;
  fLoading:=True;
  try
    LoadTargets;
    LoadChannels;
  finally fLoading:=False; end;
end;

procedure TRecorderImpactGeometryBindingDialog.LoadTargets;
var
  Index: Integer;
begin
  GetRecorderModelPointTargetIds(cbTarget.Items);
  Index := cbTarget.Items.IndexOf(fModel.Target3dComponentId);
  if (Index < 0) and (cbTarget.Items.Count > 0) then
    Index := 0;
  cbTarget.ItemIndex := Index;
  cbMode.ItemIndex := Ord(fModel.GeometryBindingMode);
  colorDisplay.Selected := fModel.MarkerColor;
  cbVisualization.ItemIndex:=Ord(fModel.MarkerVisualization);
  edSize.Text := FloatToStr(fModel.MarkerSizePixels);
  chkGradient.Checked := fModel.MarkerGradientEnabled;
  chkCreateColorModifier.Checked := fModel.CreateColorModifier;
  chkShowAnchors.Checked := fModel.ShowAnchorMarkers;
  chkOnlySensors.Checked:=fModel.OnlySensors;
  LoadObjects;
end;

procedure TRecorderImpactGeometryBindingDialog.LoadObjects;
var
  Sink: IRecorderModelPointBindingSink;
  Info: TRecorderModelObjectInfo;
  I, Selected: Integer;
begin
  fCatalog := nil;
  SetLength(fObjectIds, 0);
  cbObject.Clear;
  if cbTarget.ItemIndex < 0 then
    Exit;
  if not FindRecorderModelPointTarget(cbTarget.Text, fCatalog, Sink) then
    Exit;
  Selected := -1;
  for I := 0 to fCatalog.ObjectCount - 1 do
    if fCatalog.ObjectInfo(I, Info) then
    begin
      SetLength(fObjectIds, Length(fObjectIds) + 1);
      fObjectIds[High(fObjectIds)] := Info.NodeId;
      cbObject.Items.Add(Info.Name);
      if Info.NodeId = fModel.Target3dNodeId then
        Selected := cbObject.Items.Count - 1;
    end;
  if (Selected < 0) and (cbObject.Items.Count > 0) then
    Selected := 0;
  cbObject.ItemIndex := Selected;
end;

procedure TRecorderImpactGeometryBindingDialog.LoadChannels;
var
  I, ObjectIndex: Integer;
  Response: TImpactResponseBinding;
begin
  SetLength(fRows, fModel.ResponseCount);
  grdChannels.Cells[0, 0] := 'Канал FRF';
  grdChannels.Cells[1, 0] := 'Точка';
  grdChannels.Cells[2, 0] := 'Подпись';
  grdChannels.Cells[3, 0] := 'Объект';
  grdChannels.ColWidths[0] := 220;
  grdChannels.ColWidths[1] := 80;
  grdChannels.ColWidths[2] := 130;
  grdChannels.ColWidths[3] := 220;
  grdChannels.RowCount := fModel.ResponseCount + 1;
  for I := 0 to fModel.ResponseCount - 1 do
  begin
    Response := fModel.Responses[I];
    fRows[I].Target3dNodeId := Response.Target3dNodeId;
    if fRows[I].Target3dNodeId = 0 then
      fRows[I].Target3dNodeId := fModel.Target3dNodeId;
    fRows[I].Target3dNodeName := Response.Target3dNodeName;
    if fRows[I].Target3dNodeId = 0 then
      fRows[I].Target3dNodeId := SelectedObjectId;
    for ObjectIndex := 0 to High(fObjectIds) do
      if fObjectIds[ObjectIndex] = fRows[I].Target3dNodeId then
        fRows[I].Target3dNodeName := cbObject.Items[ObjectIndex];
    fRows[I].PointNumber := Response.PointNumber;
    fRows[I].PointLabel := Response.PointLabel;
    fRows[I].EnvelopeXEnabled := Response.EnvelopeXEnabled;
    fRows[I].EnvelopeYEnabled := Response.EnvelopeYEnabled;
    fRows[I].EnvelopeZEnabled := Response.EnvelopeZEnabled;
    fRows[I].EnvelopeX := Response.EnvelopeX;
    fRows[I].EnvelopeY := Response.EnvelopeY;
    fRows[I].EnvelopeZ := Response.EnvelopeZ;
    fRows[I].Axis := Response.Axis;
    fRows[I].IntensityOnly := Response.IntensityOnly;
    fRows[I].Visualization := Response.Visualization;
    fRows[I].Color := Response.DisplayColor;
    fRows[I].MarkerSizePixels := Response.MarkerSizePixels;
    fRows[I].IntensitySource := Response.IntensitySource;
    fRows[I].BandRms := Response.BandRms;
    fRows[I].BandTolerancePercent := Response.BandTolerancePercent;
    fRows[I].GradientEnabled := Response.GradientEnabled;
    grdChannels.Cells[0, I + 1] := Response.TagName;
    grdChannels.Cells[1, I + 1] := IntToStr(Response.PointNumber);
    grdChannels.Cells[2, I + 1] := fRows[I].PointLabel;
    grdChannels.Cells[3, I + 1] := fRows[I].Target3dNodeName;
  end;
  fEditingIndex := -1;
  if fModel.ResponseCount > 0 then
  begin
    grdChannels.Row := 1;
    LoadEditor(0);
  end;
end;

procedure TRecorderImpactGeometryBindingDialog.LoadEditor(AIndex: Integer);
var
  I: Integer;
  WasLoading:Boolean;
begin
  WasLoading:=fLoading;
  fLoading := True;
  try
  fEditingIndex := AIndex;
  if (AIndex < 0) or (AIndex > High(fRows)) then
    Exit;
  cbObject.ItemIndex := -1;
  for I := 0 to High(fObjectIds) do
    if fObjectIds[I] = fRows[AIndex].Target3dNodeId then
      cbObject.ItemIndex := I;
  if (cbObject.ItemIndex < 0) and (fRows[AIndex].Target3dNodeId = 0) and
    (cbObject.Items.Count > 0) then cbObject.ItemIndex := 0;
  if cbObject.ItemIndex >= 0 then
  begin
    fRows[AIndex].Target3dNodeId := SelectedObjectId;
    fRows[AIndex].Target3dNodeName := cbObject.Text;
    grdChannels.Cells[3, AIndex + 1] := cbObject.Text;
  end;
  edPoint.Text := IntToStr(fRows[AIndex].PointNumber);
  edLabel.Text := fRows[AIndex].PointLabel;
  chkEnvelopeX.Checked := fRows[AIndex].EnvelopeXEnabled or
    fRows[AIndex].EnvelopeYEnabled or fRows[AIndex].EnvelopeZEnabled;
  edEnvelopeX.Text := FloatToStr(Max(fRows[AIndex].EnvelopeX,
    Max(fRows[AIndex].EnvelopeY,fRows[AIndex].EnvelopeZ)));
  edEnvelopeX.Enabled:=chkEnvelopeX.Checked;
  cbAxis.ItemIndex := Ord(fRows[AIndex].Axis);
  chkIntensityOnly.Checked := fRows[AIndex].IntensityOnly;
  cbAxis.Enabled:=not chkIntensityOnly.Checked;
  cbSource.ItemIndex := Ord(fRows[AIndex].IntensitySource);
  cbAggregation.ItemIndex := Ord(fRows[AIndex].BandRms);
  edBandTolerance.Text := FloatToStr(fRows[AIndex].BandTolerancePercent);
  edBandTolerance.Enabled := fRows[AIndex].BandRms;
  finally fLoading := WasLoading; end;
end;

procedure TRecorderImpactGeometryBindingDialog.SaveEditor;
var
  PointNumber: Integer;
begin
  if fLoading then Exit;
  if (fEditingIndex < 0) or (fEditingIndex > High(fRows)) then
    Exit;
  if not TryStrToInt(edPoint.Text, PointNumber) or (PointNumber < 1) then
    PointNumber := fRows[fEditingIndex].PointNumber;
  if (PointNumber <> fRows[fEditingIndex].PointNumber) and
    (edLabel.Text = IntToStr(fRows[fEditingIndex].PointNumber)) then
  begin
    fLoading := True;
    try edLabel.Text := IntToStr(PointNumber);
    finally fLoading := False; end;
  end;
  fRows[fEditingIndex].PointNumber := PointNumber;
  fRows[fEditingIndex].PointLabel := Trim(edLabel.Text);
  if fRows[fEditingIndex].PointLabel = '' then
    fRows[fEditingIndex].PointLabel := IntToStr(PointNumber);
  fRows[fEditingIndex].EnvelopeXEnabled := chkEnvelopeX.Checked;
  fRows[fEditingIndex].EnvelopeYEnabled := chkEnvelopeX.Checked;
  fRows[fEditingIndex].EnvelopeZEnabled := chkEnvelopeX.Checked;
  fRows[fEditingIndex].EnvelopeX := StrToFloatDef(edEnvelopeX.Text, 1);
  fRows[fEditingIndex].EnvelopeY := fRows[fEditingIndex].EnvelopeX;
  fRows[fEditingIndex].EnvelopeZ := fRows[fEditingIndex].EnvelopeX;
  fRows[fEditingIndex].Target3dNodeId := SelectedObjectId;
  fRows[fEditingIndex].Target3dNodeName := cbObject.Text;
  if cbAxis.ItemIndex >= 0 then
    fRows[fEditingIndex].Axis := TImpactResponseAxis(cbAxis.ItemIndex);
  fRows[fEditingIndex].IntensityOnly := chkIntensityOnly.Checked;
  if cbSource.ItemIndex >= 0 then
    fRows[fEditingIndex].IntensitySource := TRecorderIntensitySource(cbSource.ItemIndex);
  fRows[fEditingIndex].BandRms := cbAggregation.ItemIndex = 1;
  fRows[fEditingIndex].BandTolerancePercent := StrToFloatDef(edBandTolerance.Text, 5);
  grdChannels.Cells[1, fEditingIndex + 1] := IntToStr(PointNumber);
  grdChannels.Cells[2, fEditingIndex + 1] := fRows[fEditingIndex].PointLabel;
  grdChannels.Cells[3, fEditingIndex + 1] := cbObject.Text;
end;

procedure TRecorderImpactGeometryBindingDialog.TargetChange(Sender: TObject);
begin
  if fLoading then Exit;
  LoadObjects;
  EditorChange(Sender);
end;

procedure TRecorderImpactGeometryBindingDialog.EditorChange(Sender: TObject);
var
  Size: Double;
  Demo: TRecorderModelPointBinding;
begin
  cbAxis.Enabled:=not chkIntensityOnly.Checked;
  if fLoading or (fModel = nil) or (Length(fRows) = 0) or
    (cbTarget.ItemIndex < 0) or (SelectedObjectId = 0) then Exit;
  if not TryStrToFloat(edSize.Text, Size) or (Size <= 0) or (Size > 1000) then Exit;
  edBandTolerance.Enabled := cbAggregation.ItemIndex = 1;
  if (cbAggregation.ItemIndex = 1) and
    ((StrToFloatDef(edBandTolerance.Text, 0) <= 0) or
     (StrToFloatDef(edBandTolerance.Text, 0) > 100)) then Exit;
  SaveEditor;
  edEnvelopeX.Enabled := chkEnvelopeX.Checked;
  ApplyToModel;
  if Assigned(fPreview) then fPreview(Self);
  Demo := Default(TRecorderModelPointBinding);
  Demo.ModifierTargetNodeId := fRows[fEditingIndex].Target3dNodeId;
  Demo.PointNumber := fRows[fEditingIndex].PointNumber;
  Demo.PointLabel := fRows[fEditingIndex].PointLabel;
  Demo.EnvelopeXEnabled := fRows[fEditingIndex].EnvelopeXEnabled;
  Demo.EnvelopeYEnabled := fRows[fEditingIndex].EnvelopeYEnabled;
  Demo.EnvelopeZEnabled := fRows[fEditingIndex].EnvelopeZEnabled;
  Demo.EnvelopeX := fRows[fEditingIndex].EnvelopeX;
  Demo.EnvelopeY := fRows[fEditingIndex].EnvelopeY;
  Demo.EnvelopeZ := fRows[fEditingIndex].EnvelopeZ;
  Demo.MarkerSizePixels := Size;
  Demo.Visualization := TRecorderPointVisualization(cbVisualization.ItemIndex);
  Demo.Axis := T3dMotionAxis(Ord(fRows[fEditingIndex].Axis));
  Demo.Color := colorDisplay.Selected;
  SetRecorderGeometryPreview(cbTarget.Text, Demo);
end;

procedure TRecorderImpactGeometryBindingDialog.ChannelSelect(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if fLoading then Exit;
  SaveEditor;
  if ARow > 0 then
    LoadEditor(ARow - 1);
  EditorChange(Sender);
end;

function TRecorderImpactGeometryBindingDialog.SelectedObjectId: QWord;
begin
  Result := 0;
  if (cbObject.ItemIndex >= 0) and
    (cbObject.ItemIndex <= High(fObjectIds)) then
    Result := fObjectIds[cbObject.ItemIndex];
end;

procedure TRecorderImpactGeometryBindingDialog.ApplyToModel;
var
  I: Integer;
  Response: TImpactResponseBinding;
begin
  fModel.Target3dComponentId := cbTarget.Text;
  fModel.Target3dNodeId := SelectedObjectId;
  fModel.GeometryBindingMode := TRecorderGeometryBindingMode(cbMode.ItemIndex);
  fModel.MarkerColor := colorDisplay.Selected;
  if cbVisualization.ItemIndex>=0 then
    fModel.MarkerVisualization:=TRecorderPointVisualization(cbVisualization.ItemIndex);
  fModel.MarkerSizePixels := StrToFloatDef(edSize.Text, 10);
  fModel.MarkerGradientEnabled := chkGradient.Checked;
  fModel.CreateColorModifier := chkCreateColorModifier.Checked;
  fModel.ShowAnchorMarkers := chkShowAnchors.Checked;
  fModel.OnlySensors:=chkOnlySensors.Checked;
  for I := 0 to High(fRows) do
  begin
    Response := fModel.Responses[I];
    Response.Target3dNodeId := fRows[I].Target3dNodeId;
    Response.Target3dNodeName := fRows[I].Target3dNodeName;
    Response.PointNumber := fRows[I].PointNumber;
    Response.PointLabel := fRows[I].PointLabel;
    Response.EnvelopeXEnabled := fRows[I].EnvelopeXEnabled;
    Response.EnvelopeYEnabled := fRows[I].EnvelopeYEnabled;
    Response.EnvelopeZEnabled := fRows[I].EnvelopeZEnabled;
    Response.EnvelopeX := fRows[I].EnvelopeX;
    Response.EnvelopeY := fRows[I].EnvelopeY;
    Response.EnvelopeZ := fRows[I].EnvelopeZ;
    Response.Axis := fRows[I].Axis;
    Response.IntensityOnly := fRows[I].IntensityOnly;
    Response.Visualization := fModel.MarkerVisualization;
    Response.IntensitySource := fRows[I].IntensitySource;
    Response.BandRms := fRows[I].BandRms;
    Response.BandTolerancePercent := fRows[I].BandTolerancePercent;
  end;
end;

procedure TRecorderImpactGeometryBindingDialog.OkClick(Sender: TObject);
var
  I, ObjectIndex: Integer;
  ObjectFound: Boolean;
begin
  SaveEditor;
  if cbTarget.ItemIndex < 0 then
  begin
    MessageDlg('Выберите 3D-компонент.', mtError, [mbOK], 0);
    Exit;
  end;
  if (cbAggregation.ItemIndex = 1) and
    ((StrToFloatDef(edBandTolerance.Text, 0) <= 0) or
     (StrToFloatDef(edBandTolerance.Text, 0) > 100)) then
  begin
    MessageDlg('Полуширина полосы должна быть больше 0 и не больше 100%.',
      mtError, [mbOK], 0);
    Exit;
  end;
  if (StrToFloatDef(edSize.Text, 0) <= 0) or
    (StrToFloatDef(edSize.Text, 0) > 1000) then
  begin
    MessageDlg('Размер должен быть больше 0 и не больше 1000 пикселей.',
      mtError, [mbOK], 0);
    Exit;
  end;
  if SelectedObjectId = 0 then
  begin
    MessageDlg('Выберите объект геометрии.', mtError, [mbOK], 0);
    Exit;
  end;
  for I := 0 to High(fRows) do
  begin
    if fRows[I].PointNumber<1 then
    begin
      grdChannels.Row:=I+1;
      LoadEditor(I);
      MessageDlg('Номер точки должен быть положительным.',mtError,[mbOK],0);
      Exit;
    end;
    if (fRows[I].EnvelopeXEnabled and (fRows[I].EnvelopeX <= 0)) or
      (fRows[I].EnvelopeYEnabled and (fRows[I].EnvelopeY <= 0)) or
      (fRows[I].EnvelopeZEnabled and (fRows[I].EnvelopeZ <= 0)) then
    begin
      grdChannels.Row := I + 1;
      LoadEditor(I);
      MessageDlg('Включённые полуразмеры оболочки должны быть положительными.',
        mtError, [mbOK], 0);
      Exit;
    end;
    if fRows[I].BandRms and
      ((fRows[I].BandTolerancePercent <= 0) or
       (fRows[I].BandTolerancePercent > 100)) then
    begin
      grdChannels.Row := I + 1;
      LoadEditor(I);
      MessageDlg('Полуширина полосы должна быть больше 0 и не больше 100%.',
        mtError, [mbOK], 0);
      Exit;
    end;
    ObjectFound := False;
    for ObjectIndex := 0 to High(fObjectIds) do
      if fObjectIds[ObjectIndex] = fRows[I].Target3dNodeId then
        ObjectFound := True;
    if not ObjectFound then
    begin
      grdChannels.Row := I + 1;
      LoadEditor(I);
      MessageDlg('Выберите объект геометрии для канала ' +
        fModel.Responses[I].TagName + '.', mtError, [mbOK], 0);
      Exit;
    end;
  end;
  ApplyToModel;
  ModalResult := mrOk;
end;

end.
