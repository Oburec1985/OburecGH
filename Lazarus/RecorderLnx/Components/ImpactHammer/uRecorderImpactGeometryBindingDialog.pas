unit uRecorderImpactGeometryBindingDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Немодальный редактор отображения FRF на 3D-модели. Связи каналов с точками
  принадлежат шагам маршрута и не меняются вместе с настройками отображения. }

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ColorBox, LCLType,
  uRecorderImpactHammerModel, uRecorderImpactHammerContracts;

type
  TRecorderImpactGeometryBindingDialog = class(TForm)
  published
    lblTarget, lblObject, lblMode, lblAxis, lblDisplay,
      lblColor, lblSize, lblSource, lblScale, lblAggregation, lblBandTolerance: TLabel;
    cbTarget, cbObject, cbMode, cbAxis, cbVisualization, cbSource, cbAggregation: TComboBox;
    edEnvelopeX: TEdit;
    lblEnvelope: TLabel;
    chkEnvelopeX: TCheckBox;
    chkCreateColorModifier, chkShowAnchors, chkResultValues: TCheckBox;
    edSize: TEdit;
    edBandTolerance: TEdit;
    chkIntensityOnly: TCheckBox;
    chkLogRadius: TCheckBox;
    chkGradient: TCheckBox;
    colorDisplay: TColorBox;
    btnOk: TButton;
    procedure TargetChange(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure ResultValuesChange(Sender: TObject);
    procedure ObjectChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    fModel: TRecorderImpactHammerComponent;
    fCatalog: IRecorderModelPointCatalog;
    fObjectIds: array of QWord;
    fLoading: Boolean;
    fPreview: TNotifyEvent;
    procedure LoadTargets;
    procedure LoadObjects;
    procedure LoadDisplay;
    function SelectedObjectId: QWord;
    procedure ApplyToModel;
    procedure SceneSelection(const ASelection:TRecorderModelPointSelection);
  public
    destructor Destroy; override;
    class function ShowBinding(AOwner:TComponent;
      AModel:TRecorderImpactHammerComponent; APreview:TNotifyEvent=nil):
      TRecorderImpactGeometryBindingDialog;
    procedure Initialize(AModel:TRecorderImpactHammerComponent;
      APreview:TNotifyEvent=nil);
    class function Execute(AOwner: TComponent;
      AModel: TRecorderImpactHammerComponent;
      APreview: TNotifyEvent = nil): Boolean;
  end;

implementation

{$R *.lfm}

class function TRecorderImpactGeometryBindingDialog.ShowBinding(AOwner:TComponent;
  AModel:TRecorderImpactHammerComponent; APreview:TNotifyEvent):
  TRecorderImpactGeometryBindingDialog;
begin
  Result:=TRecorderImpactGeometryBindingDialog.Create(AOwner);
  Result.Initialize(AModel,APreview);
  Result.Show;
  Result.SceneSelection(CurrentRecorderModelPointSelection);
end;

destructor TRecorderImpactGeometryBindingDialog.Destroy;
begin
  UnsubscribeRecorderModelPointSelection(@SceneSelection);
  inherited Destroy;
end;

procedure TRecorderImpactGeometryBindingDialog.FormClose(Sender:TObject;
  var CloseAction:TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TRecorderImpactGeometryBindingDialog.FormKeyDown(Sender:TObject;
  var Key:Word; Shift:TShiftState);
begin
  if Key<>VK_RETURN then Exit;
  EditorChange(Sender);
  Key:=0;
end;

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
    Dialog.Free;
    Backup.Free;
  end;
end;

procedure TRecorderImpactGeometryBindingDialog.Initialize(
  AModel:TRecorderImpactHammerComponent; APreview:TNotifyEvent);
begin
  fModel:=AModel;
  fPreview:=APreview;
  fLoading:=True;
  try
    LoadTargets;
    LoadDisplay;
  finally fLoading:=False; end;
  UnsubscribeRecorderModelPointSelection(@SceneSelection);
  SubscribeRecorderModelPointSelection(@SceneSelection);
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
  chkResultValues.Checked := fModel.ResultValuesVisible;
  chkLogRadius.Checked := fModel.IntensityLogScale;
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

procedure TRecorderImpactGeometryBindingDialog.ObjectChange(Sender:TObject);
begin
  EditorChange(Sender);
end;

procedure TRecorderImpactGeometryBindingDialog.SceneSelection(
  const ASelection:TRecorderModelPointSelection);
var I:Integer;
begin
  if not Visible or fLoading or (ASelection.NodeId=0) then Exit;
  fLoading:=True;
  try
    if ASelection.SceneComponentId<>cbTarget.Text then
    begin
      I:=cbTarget.Items.IndexOf(ASelection.SceneComponentId);
      if I<0 then Exit;
      cbTarget.ItemIndex:=I;
      LoadObjects;
    end;
    for I:=0 to High(fObjectIds) do
      if fObjectIds[I]=ASelection.NodeId then
      begin
        cbObject.ItemIndex:=I;
        Exit;
      end;
  finally fLoading:=False; end;
end;

procedure TRecorderImpactGeometryBindingDialog.LoadDisplay;
var
  Response:TImpactResponseBinding;
begin
  cbAxis.ItemIndex:=0;
  cbSource.ItemIndex:=0;
  cbAggregation.ItemIndex:=0;
  if fModel.ResponseCount=0 then Exit;
  Response:=fModel.Responses[0];
  chkEnvelopeX.Checked:=Response.EnvelopeXEnabled or
    Response.EnvelopeYEnabled or Response.EnvelopeZEnabled;
  edEnvelopeX.Text:=FloatToStr(Max(Response.EnvelopeX,
    Max(Response.EnvelopeY,Response.EnvelopeZ)));
  edEnvelopeX.Enabled:=chkEnvelopeX.Checked;
  cbAxis.ItemIndex:=Ord(Response.Axis);
  chkIntensityOnly.Checked:=Response.IntensityOnly;
  cbAxis.Enabled:=not chkIntensityOnly.Checked;
  cbSource.ItemIndex:=Ord(Response.IntensitySource);
  cbAggregation.ItemIndex:=Ord(Response.BandRms);
  edBandTolerance.Text:=FloatToStr(Response.BandTolerancePercent);
  edBandTolerance.Enabled:=Response.BandRms;
end;

procedure TRecorderImpactGeometryBindingDialog.TargetChange(Sender: TObject);
begin
  if fLoading then Exit;
  LoadObjects;
  ObjectChange(Sender);
end;

procedure TRecorderImpactGeometryBindingDialog.EditorChange(Sender: TObject);
var
  Size: Double;
begin
  cbAxis.Enabled:=not chkIntensityOnly.Checked;
  if fLoading or (fModel = nil) or
    (cbTarget.ItemIndex < 0) or (SelectedObjectId = 0) then Exit;
  if not TryStrToFloat(edSize.Text, Size) or (Size <= 0) or (Size > 1000) then Exit;
  edBandTolerance.Enabled := cbAggregation.ItemIndex = 1;
  if (cbAggregation.ItemIndex = 1) and
    ((StrToFloatDef(edBandTolerance.Text, 0) <= 0) or
     (StrToFloatDef(edBandTolerance.Text, 0) > 100)) then Exit;
  edEnvelopeX.Enabled := chkEnvelopeX.Checked;
  ApplyToModel;
  if Assigned(fPreview) then fPreview(Self);
end;

procedure TRecorderImpactGeometryBindingDialog.ResultValuesChange(Sender: TObject);
begin
  if fLoading or (fModel = nil) then Exit;
  fModel.ResultValuesVisible := chkResultValues.Checked;
  if Assigned(fPreview) then fPreview(Self);
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
  fModel.IntensityLogScale := chkLogRadius.Checked;
  fModel.MarkerGradientEnabled := chkGradient.Checked;
  fModel.CreateColorModifier := chkCreateColorModifier.Checked;
  fModel.ShowAnchorMarkers := chkShowAnchors.Checked;
  for I := 0 to fModel.ResponseCount-1 do
  begin
    { ID и подписи геометрических точек остаются в данных шага маршрута. }
    Response := fModel.Responses[I];
    Response.EnvelopeXEnabled := chkEnvelopeX.Checked;
    Response.EnvelopeYEnabled := chkEnvelopeX.Checked;
    Response.EnvelopeZEnabled := chkEnvelopeX.Checked;
    Response.EnvelopeX := StrToFloatDef(edEnvelopeX.Text,1);
    Response.EnvelopeY := StrToFloatDef(edEnvelopeX.Text,1);
    Response.EnvelopeZ := StrToFloatDef(edEnvelopeX.Text,1);
    Response.Axis := TImpactResponseAxis(cbAxis.ItemIndex);
    Response.IntensityOnly := chkIntensityOnly.Checked;
    Response.Visualization := fModel.MarkerVisualization;
    Response.IntensitySource := TRecorderIntensitySource(cbSource.ItemIndex);
    Response.BandRms := (cbAggregation.ItemIndex=1);
    Response.BandTolerancePercent := StrToFloatDef(edBandTolerance.Text,5);
  end;
end;

procedure TRecorderImpactGeometryBindingDialog.OkClick(Sender: TObject);
begin
  EditorChange(Sender);
  if fsModal in FormState then ModalResult:=mrOk else Close;
end;

end.
