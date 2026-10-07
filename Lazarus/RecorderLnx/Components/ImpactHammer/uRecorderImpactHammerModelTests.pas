unit uRecorderImpactHammerModelTests;

{$mode objfpc}{$H+}

interface

procedure RunRecorderImpactHammerModelTests;

implementation

uses
  Classes, SysUtils, Math, Graphics, uRecorderImpactHammerModel,
  uRecorderImpactHammerContracts, uRecorderImpactHammerPresenter;

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
    Source.Responses[0].Visible := False;
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
    Check(Loaded.ExportPath = 'D:\FRF', 'Export path roundtrip');
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

procedure RunRecorderImpactHammerModelTests;
begin
  TestDefaults;
  TestAssignAndRoundTrip;
  TestEditableDraftRoundTrip;
  TestValidation;
  TestPresenterVisibilityAndCursor;
end;

end.
