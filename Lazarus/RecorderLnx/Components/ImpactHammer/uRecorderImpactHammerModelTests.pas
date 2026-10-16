unit uRecorderImpactHammerModelTests;

{$mode objfpc}{$H+}

interface

procedure RunRecorderImpactHammerModelTests;

implementation

uses
  Classes, SysUtils, Math, Graphics, uRecorderImpactHammerModel,
  uRecorderImpactHammerContracts, uRecorderImpactHammerPresenter,
  uRecorderImpactGeometryBindingDialog;

type
  TGeometryTestTarget=class(TInterfacedObject,IRecorderModelPointCatalog,
    IRecorderModelPointBindingSink)
    function ResolvePoint(const APointGroup:string; APointNumber:Integer;
      out ATargetNodeId:QWord):Boolean;
    function ObjectCount:Integer;
    function ObjectInfo(AIndex:Integer; out AInfo:TRecorderModelObjectInfo):Boolean;
    procedure PublishBindings(const ASourceBindingId,ATargetComponentId:string;
      const ABindings:array of TRecorderModelPointBinding);
    procedure RemoveBindings(const ASourceBindingId:string);
    procedure ConfigureAnimation(const ASourceBindingId:string; AScale,AFrequencyHz:Double);
    procedure PlayAnimation(const ASourceBindingId:string);
    procedure StopAnimation(const ASourceBindingId:string);
  end;

function TGeometryTestTarget.ResolvePoint(const APointGroup:string;
  APointNumber:Integer; out ATargetNodeId:QWord):Boolean;
begin ATargetNodeId:=77; Result:=True; end;
function TGeometryTestTarget.ObjectCount:Integer;
begin Result:=1; end;
function TGeometryTestTarget.ObjectInfo(AIndex:Integer;
  out AInfo:TRecorderModelObjectInfo):Boolean;
begin AInfo.NodeId:=77; AInfo.Name:='Test object'; Result:=AIndex=0; end;
procedure TGeometryTestTarget.PublishBindings(const ASourceBindingId,
  ATargetComponentId:string; const ABindings:array of TRecorderModelPointBinding);
begin end;
procedure TGeometryTestTarget.RemoveBindings(const ASourceBindingId:string);
begin end;
procedure TGeometryTestTarget.ConfigureAnimation(const ASourceBindingId:string;
  AScale,AFrequencyHz:Double);
begin end;
procedure TGeometryTestTarget.PlayAnimation(const ASourceBindingId:string);
begin end;
procedure TGeometryTestTarget.StopAnimation(const ASourceBindingId:string);
begin end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure ConfigureValid(AComponent: TRecorderImpactHammerComponent);
var
  Response: TImpactResponseBinding;
begin
  AComponent.HammerTagId := 101;
  AComponent.HammerTagName := 'Hammer';
  AComponent.TriggerPolarity := itpAbsolute;
  AComponent.TriggerThreshold := 12.5;
  AComponent.TriggerHysteresis := 0.5;
  AComponent.PretriggerSamples := 128;
  AComponent.CaptureSamples := 8192;
  AComponent.ImpactCapacity := 64;
  AComponent.FftSize := 8192;
  AComponent.WindowKind := iwExponential;
  AComponent.ZeroPadFactor := 4;
  AComponent.Estimator := ifeH2;
  AComponent.CoherenceThreshold := 0.91;
  AComponent.WelchSegmentSize := 2048;
  AComponent.WelchOverlapPercent := 75;
  Response := AComponent.AddResponse;
  Response.TagId := 202;
  Response.TagName := 'Acceleration Z';
  Response.PointId := 'P-17';
  Response.Axis := iraZ;
  Response.Color := clBlue;
  Response.Enabled := True;
end;

procedure TestDefaults;
var
  Component: TRecorderImpactHammerComponent;
begin
  Component := TRecorderImpactHammerComponent.Create;
  try
    Check(Component.FftSize = 4096, 'Default FFT size');
    Check(Component.Estimator = ifeH1, 'Default estimator');
    Check(Component.ResponseCount = 0, 'Default responses');
    Component.AddResponse;
    Check(not Component.Responses[0].BandRms, 'Band RMS default disabled');
    Check(Component.Responses[0].BandTolerancePercent = 5, 'Band tolerance default');
    Check(not Component.Responses[0].GradientEnabled, 'Gradient default disabled');
  finally
    Component.Free;
  end;
end;

procedure TestAssignAndRoundTrip;
var
  Source: TRecorderImpactHammerComponent;
  Copy: TRecorderImpactHammerComponent;
  Loaded: TRecorderImpactHammerComponent;
  Values: TStringList;
  ErrorText: string;
  AxisState: TImpactResultAxisState;
begin
  Source := TRecorderImpactHammerComponent.Create;
  Copy := TRecorderImpactHammerComponent.Create;
  Loaded := TRecorderImpactHammerComponent.Create;
  Values := TStringList.Create;
  try
    ConfigureValid(Source);
    Source.ExportPath := 'D:\FRF';
    Source.ActiveResultType := irtCoherence;
    Source.ExcitationVisible := False;
    Source.ExcitationOwnAxis := True;
    Source.Target3dComponentId := '3d-main';
    Source.Target3dNodeId := 77;
    Source.GeometryBindingMode := rgbmIntensity;
    Source.MarkerSizePixels := 22;
    Source.MarkerColor := clYellow;
    Source.MarkerGradientEnabled := True;
    Source.CreateColorModifier := True;
    Source.ShowAnchorMarkers := True;
    Source.Responses[0].PointLabel := 'Route-A';
    Source.Responses[0].EnvelopeXEnabled := True;
    Source.Responses[0].EnvelopeX := 2.5;
    Source.Responses[0].Visible := False;
    Source.Responses[0].PointNumber := 17;
    Source.Responses[0].Target3dNodeId := 88;
    Source.Responses[0].Target3dNodeName := 'Geometry B';
    Source.Responses[0].IntensityOnly := True;
    Source.Responses[0].Visualization := rpvSphere;
    Source.Responses[0].DisplayColor := clLime;
    Source.Responses[0].MarkerSizePixels := 17.5;
    Source.Responses[0].IntensitySource := risAmplitude;
    Source.Responses[0].BandRms := True;
    Source.Responses[0].BandTolerancePercent := 12.5;
    Source.Responses[0].GradientEnabled := True;
    AxisState := Source.AxisStates[irtFrfMagnitude];
    AxisState.LogX := True;
    AxisState.LogY := True;
    AxisState.AutoScale := False;
    AxisState.XMin := 1;
    AxisState.XMax := 1000;
    AxisState.YMin := 0.01;
    AxisState.YMax := 10;
    Source.AxisStates[irtFrfMagnitude] := AxisState;
    Copy.Assign(Source);
    Source.Responses[0].PointId := 'changed';
    Check(Copy.Responses[0].PointId = 'P-17', 'Assign must be deep');
    Copy.SaveToStrings(Values, 'Impact.');
    Check(Loaded.LoadFromStrings(Values, 'Impact.', ErrorText), ErrorText);
    Check(Loaded.HammerTagId = 101, 'Hammer TagId roundtrip');
    Check(Loaded.TriggerPolarity = itpAbsolute, 'Polarity roundtrip');
    Check(Loaded.Estimator = ifeH2, 'Estimator roundtrip');
    Check(Loaded.ResponseCount = 1, 'Response count roundtrip');
    Check(Loaded.Responses[0].TagId = 202, 'Response TagId roundtrip');
    Check(Loaded.Responses[0].Axis = iraZ, 'Response axis roundtrip');
    Check(Loaded.Responses[0].Color = clBlue, 'Response color roundtrip');
    Check(Loaded.AxisStates[irtFrfMagnitude].LogX,
      'Result X scale roundtrip');
    Check(Loaded.AxisStates[irtFrfMagnitude].LogY,
      'Result Y scale roundtrip');
    Check(not Loaded.AxisStates[irtFrfMagnitude].AutoScale,
      'Result manual scale roundtrip');
    Check(Loaded.AxisStates[irtFrfMagnitude].XMax = 1000,
      'Result X range roundtrip');
    Check(Loaded.ActiveResultType = irtCoherence,
      'Active result roundtrip');
    Check(not Loaded.ExcitationVisible, 'Excitation visibility roundtrip');
    Check(Loaded.ExcitationOwnAxis, 'Excitation own axis roundtrip');
    Check(not Loaded.Responses[0].Visible, 'Response visibility roundtrip');
    Check(Loaded.Target3dComponentId = '3d-main',
      'Target 3D component roundtrip');
    Check(Loaded.Target3dNodeId = 77, 'Target object roundtrip');
    Check(Loaded.MarkerSizePixels = 22, 'Common marker size roundtrip');
    Check(Loaded.MarkerColor = clYellow, 'Common marker color roundtrip');
    Check(Loaded.MarkerGradientEnabled, 'Common gradient roundtrip');
    Check(Loaded.CreateColorModifier, 'Color modifier creation roundtrip');
    Check(Loaded.ShowAnchorMarkers, 'Anchor visibility roundtrip');
    Check(Loaded.Responses[0].PointLabel = 'Route-A', 'Route label roundtrip');
    Check(Loaded.Responses[0].EnvelopeXEnabled and
      (Loaded.Responses[0].EnvelopeX = 2.5), 'Envelope roundtrip');
    Check(Loaded.Responses[0].Target3dNodeId = 88,
      'Per-channel object overrides component fallback');
    Check(Loaded.Responses[0].Target3dNodeName = 'Geometry B',
      'Per-channel object name roundtrip');
    Check(Loaded.GeometryBindingMode = rgbmIntensity,
      'Geometry binding mode roundtrip');
    Check(Loaded.Responses[0].PointNumber = 17,
      'Point number roundtrip');
    Check(Loaded.Responses[0].IntensityOnly,
      'Intensity-only roundtrip');
    Check(Loaded.Responses[0].Visualization = rpvSphere,
      'Visualization roundtrip');
    Check(Loaded.Responses[0].DisplayColor = clLime,
      'Display color roundtrip');
    Check(Loaded.Responses[0].MarkerSizePixels = 17.5,
      'Marker screen size roundtrip');
    Check(Loaded.Responses[0].IntensitySource = risAmplitude,
      'Amplitude source roundtrip');
    Check(Loaded.Responses[0].BandRms, 'Band RMS roundtrip');
    Check(Loaded.Responses[0].BandTolerancePercent = 12.5, 'Band tolerance roundtrip');
    Check(Loaded.Responses[0].GradientEnabled, 'Gradient roundtrip');
    Check(Loaded.ExportPath = 'D:\FRF', 'Export path roundtrip');
    Values.Values['Impact.Version'] := '8';
    Values.Delete(Values.IndexOfName('Impact.Response.0.Target3dNodeId'));
    Values.Delete(Values.IndexOfName('Impact.Response.0.Target3dNodeName'));
    Check(Loaded.LoadFromStrings(Values, 'Impact.', ErrorText), ErrorText);
    Check(Loaded.Responses[0].Target3dNodeId = 77,
      'Legacy channel inherits component object');
    Check((Loaded.MarkerSizePixels = 17.5) and
      (Loaded.MarkerColor = clLime) and Loaded.MarkerGradientEnabled,
      'Legacy marker style migrates from first channel');
  finally
    Values.Free;
    Loaded.Free;
    Copy.Free;
    Source.Free;
  end;
end;

procedure TestEditableDraftRoundTrip;
var
  lSource, lLoaded: TRecorderImpactHammerComponent;
  lValues: TStringList;
  lError: string;
begin
  lSource := TRecorderImpactHammerComponent.Create;
  lLoaded := TRecorderImpactHammerComponent.Create;
  lValues := TStringList.Create;
  try
    lSource.SaveToStrings(lValues, 'Impact.');
    Check(lLoaded.LoadFromStrings(lValues, 'Impact.', lError),
      'Unconfigured component must remain editable after project load: ' + lError);
    Check(not lLoaded.Validate(lError),
      'Unconfigured component must still be rejected by runtime validation');
  finally
    lValues.Free;
    lLoaded.Free;
    lSource.Free;
  end;
end;

procedure TestPresenterVisibilityAndCursor;
var
  Presenter: TRecorderImpactHammerPresenter;
  Snapshot: TRecorderImpactHammerSnapshot;
  Frame: TRecorderImpactPresentationFrame;
  AxisState: TImpactResultAxisState;
begin
  Snapshot := Default(TRecorderImpactHammerSnapshot);
  Snapshot.Results[irtFrfMagnitude].ResultType := irtFrfMagnitude;
  Snapshot.Results[irtFrfMagnitude].XUnitName := 'Hz';
  SetLength(Snapshot.Results[irtFrfMagnitude].Curves, 2);
  with Snapshot.Results[irtFrfMagnitude].Curves[0] do
  begin
    Name := 'visible';
    Visible := True;
    X := [10.0, 20.0];
    Y := [2.0, 6.0];
  end;
  with Snapshot.Results[irtFrfMagnitude].Curves[1] do
  begin
    Name := 'hidden';
    Visible := False;
    X := [10.0, 20.0];
    Y := [100.0, 200.0];
  end;
  Snapshot.Cursor.FrequencyHz := 15;
  AxisState := Default(TImpactResultAxisState);
  AxisState.AutoScale := True;
  Presenter := TRecorderImpactHammerPresenter.Create;
  try
    Presenter.Configure(irtFrfMagnitude, AxisState);
    Check(Presenter.Build(Snapshot, Frame), 'Visible curve must build frame');
    Check(Length(Frame.Curves) = 1, 'Hidden curves must be filtered');
    Check(Frame.Curves[0].Name = 'visible', 'Visible curve identity');
    Check(Abs(Frame.Cursor.Values[0] - 4.0) < 1E-12,
      'Cursor must interpolate prepared curve');
    Check(Frame.XUnitName = 'Hz', 'Presenter preserves X unit');
  finally
    Presenter.Free;
  end;
end;

procedure TestValidation;
var
  Component: TRecorderImpactHammerComponent;
  ErrorText: string;
begin
  Component := TRecorderImpactHammerComponent.Create;
  try
    Check(not Component.Validate(ErrorText), 'Empty config must fail');
    ConfigureValid(Component);
    Check(Component.Validate(ErrorText), ErrorText);
    Component.FftSize := 3000;
    Check(not Component.Validate(ErrorText), 'Non-power-of-two FFT must fail');
    Component.SampleRateHz := 57600;
    Component.CaptureSamples := 230400;
    Component.WelchSegmentSize := 1024;
    Component.FftSize := 4096;
    Component.ZeroPadFactor := 1;
    Check(Component.Validate(ErrorText),
      'Welch capture may exceed FFT: ' + ErrorText);
    Component.FftSize := 512;
    Check(not Component.Validate(ErrorText),
      'FFT shorter than Welch segment must fail');
    Component.WelchEnabled := False;
    Component.FftSize := 16384;
    Component.CaptureSamples := 20160;
    Check(Component.Validate(ErrorText),
      'Capture may exceed FFT without Welch: ' + ErrorText);
  finally
    Component.Free;
  end;
end;

procedure TestGeometryEditAndReopen;
var
  Model:TRecorderImpactHammerComponent;
  Dlg:TRecorderImpactGeometryBindingDialog;
  Target:TGeometryTestTarget;
  Catalog:IRecorderModelPointCatalog;
  Sink:IRecorderModelPointBindingSink;
  Before,After:TStringList;
  I:Integer;
begin
  Target:=TGeometryTestTarget.Create;
  Catalog:=Target; Sink:=Target;
  RegisterRecorderModelPointTarget('geometry-test',Catalog,Sink);
  Model:=TRecorderImpactHammerComponent.Create;
  Before:=TStringList.Create; After:=TStringList.Create;
  Dlg:=nil;
  try
    Model.Target3dComponentId:='geometry-test'; Model.Target3dNodeId:=77;
    for I:=0 to 2 do
      with Model.AddResponse do
      begin
        TagName:='channel-'+IntToStr(I);
        PointNumber:=7+I; PointLabel:=IntToStr(I+1);
        Target3dNodeId:=77; Target3dNodeName:='Test object';
      end;
    Model.SaveToStrings(Before,'Test.');
    Dlg:=TRecorderImpactGeometryBindingDialog.Create(nil);
    Dlg.Initialize(Model);
    Model.SaveToStrings(After,'Test.');
    Check(Before.Text=After.Text,'Opening geometry dialog must not mutate model');
    Dlg.grdChannels.Row:=2;
    Dlg.edPoint.Text:='12'; Dlg.edLabel.Text:='sensor-B';
    Dlg.edSize.Text:='33'; Dlg.chkGradient.Checked:=True;
    Dlg.cbVisualization.ItemIndex:=Ord(rpvVector);
    Dlg.EditorChange(nil);
    Dlg.grdChannels.Row:=3;
    Check(Dlg.cbVisualization.ItemIndex=Ord(rpvVector),
      'Display type stays common when changing channel');
    Dlg.grdChannels.Row:=2;
    Dlg.chkIntensityOnly.Checked:=True; Dlg.EditorChange(nil);
    Check(not Dlg.cbAxis.Enabled,'Intensity-only disables direction');
    Dlg.chkIntensityOnly.Checked:=False; Dlg.EditorChange(nil);
    Check(Dlg.cbAxis.Enabled,'Direction restored after intensity-only off');
    Dlg.chkEnvelopeX.Checked:=True; Dlg.edEnvelopeX.Text:=FloatToStr(2.5);
    Dlg.OkClick(nil);
    Check((Model.Responses[0].PointNumber=7) and
      (Model.Responses[1].PointNumber=12) and (Model.Responses[2].PointNumber=9),
      'Editing one point preserves the other rows');
    Check((Model.Responses[1].EnvelopeX=2.5) and
      (Model.Responses[1].EnvelopeY=2.5) and (Model.Responses[1].EnvelopeZ=2.5),
      'One radius produces a spherical envelope');
    FreeAndNil(Dlg);
    Model.SaveToStrings(Before,'Test.');
    Dlg:=TRecorderImpactGeometryBindingDialog.Create(nil); Dlg.Initialize(Model);
    Model.SaveToStrings(After,'Test.');
    Check(Before.Text=After.Text,'Reopening preserves all saved geometry settings');
    Check(Dlg.grdChannels.Cells[1,2]='12','Reopened point number');
    Check(Dlg.grdChannels.Cells[2,2]='sensor-B','Reopened point label');
    Check(Dlg.edSize.Text='33','Reopened common marker size');
    Check(Dlg.chkGradient.Checked,'Reopened common gradient');
    Check(Dlg.cbVisualization.ItemIndex=Ord(rpvVector),'Reopened common display type');
  finally
    Dlg.Free; Before.Free; After.Free; Model.Free;
    UnregisterRecorderModelPointTarget('geometry-test');
    Catalog:=nil; Sink:=nil;
    ClearRecorderGeometryPreview;
  end;
end;

procedure RunRecorderImpactHammerModelTests;
var
  Dlg: TRecorderImpactGeometryBindingDialog;
begin
  Dlg := TRecorderImpactGeometryBindingDialog.Create(nil);
  try
    Check(Dlg.cbSource.Items.Count = 2, 'Geometry source resource');
    Check(Dlg.edSize.Text = '10', 'Geometry marker size resource');
    Check(Dlg.grdChannels.ColCount = 4, 'Geometry table includes label and object');
    Check(Dlg.chkGradient.Visible, 'Common gradient checkbox visible');
    Check(Assigned(Dlg.cbVisualization.OnChange), 'Geometry live preview event');
  finally Dlg.Free; end;
  TestDefaults;
  TestGeometryEditAndReopen;
  TestAssignAndRoundTrip;
  TestEditableDraftRoundTrip;
  TestValidation;
  TestPresenterVisibilityAndCursor;
end;

end.
