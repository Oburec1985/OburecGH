program SourceUnitPipelineUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, Forms, Controls, StdCtrls, Classes, SysUtils, LazUTF8, LazFileUtils,
  uRecorderTags, uRecorderTagSettingsProvider, uRecorderUnitManager, uRecorderDataSources,
  uRecorderProjectFiles,
  uRecorderMeraPaths,
  uRecorderMeraSdbThermocouples,
  uRecorderHardwareTagSettingsProviders, uTagSettingsDialog,
  uRecorderMic140DeviceConfig, uRecorderMic140StreamTypes, uRecorderMic140DataSource,
  uRecorderMic185DataSource, uMic185MebiusTypes, uRecorderMic185Calibration,
  uRecorderConfiguredDataSources, uRecorderPxiMx248Factory;

type
  TCustomUnitSource = class(TRecorderDataSourceBase)
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    Calls: Integer;
    LastUnit: string;
    RejectTagName: string;
    ValidationCalls: Integer;
    constructor Create;
    procedure GetUnitNames(ATag: TRecorderTag; AUnitNames: TStrings); override;
    function CanSetUnits(ATag: TRecorderTag;
      const AUnitName: string; out AErrorText: string): Boolean; override;
    function SetUnits(ATag: TRecorderTag;
      const AUnitName: string; out AErrorText: string): Boolean; override;
  end;
  TCustomSourceQuery = class
  public
    Source: IInterface;
    function Query(const ASourceId: string): IInterface;
  end;
  TLookupTestSource = class(TRecorderDataSourceBase)
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  end;
  TRealSourceBindings = class
  private
    Sources: TInterfaceList;
  public
    constructor Create;
    destructor Destroy; override;
    function Query(const ASourceId: string): IInterface;
  end;

var OwnedBindings: TList;

constructor TRealSourceBindings.Create;
begin
  inherited Create;
  Sources := TInterfaceList.Create;
  Sources.Add(TRecorderMic140DataSource.Create('MIC-140: 192.0.2.41:4000',
    '192.0.2.41', 4000, 48, 10, 200));
  Sources.Add(TRecorderMic185DataSource.Create('MIC-185: 192.0.2.185:4000',
    '192.0.2.185', 4000, 100, 200));
end;

destructor TRealSourceBindings.Destroy;
begin
  Sources.Free;
  inherited Destroy;
end;

function TRealSourceBindings.Query(const ASourceId: string): IInterface;
var I: Integer; Source: IRecorderDataSource;
begin
  Result := nil;
  for I := 0 to Sources.Count - 1 do
    if Supports(Sources[I], IRecorderDataSource, Source) and
      SameText(Source.SourceId, ASourceId) then Exit(Sources[I]);
end;

function CreateTestRegistry: TRecorderTagRegistry;
var Bindings: TRealSourceBindings;
begin
  Result := TRecorderTagRegistry.Create;
  Bindings := TRealSourceBindings.Create;
  OwnedBindings.Add(Bindings);
  Result.ConfigureTagSources(@Bindings.Query);
end;

procedure FreeTestBindings;
begin
  while OwnedBindings.Count > 0 do
  begin
    TObject(OwnedBindings[OwnedBindings.Count - 1]).Free;
    OwnedBindings.Delete(OwnedBindings.Count - 1);
  end;
  FreeAndNil(OwnedBindings);
end;

procedure TLookupTestSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
begin
end;

procedure TLookupTestSource.DoTick;
begin
end;

constructor TCustomUnitSource.Create;
begin
  inherited Create('third-party-source', 'unit contract fixture', 200);
end;

procedure TCustomUnitSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
begin
end;

procedure TCustomUnitSource.DoTick;
begin
end;

procedure TCustomUnitSource.GetUnitNames(ATag: TRecorderTag; AUnitNames: TStrings);
begin
  AUnitNames.Clear;
  AUnitNames.Add('degC'); AUnitNames.Add('mV');
  AUnitNames.Add('V'); AUnitNames.Add('code');
end;

function TCustomUnitSource.SetUnits(ATag: TRecorderTag;
  const AUnitName: string; out AErrorText: string): Boolean;
begin
  Inc(Calls);
  LastUnit := AUnitName;
  ATag.SourceHardwareOutputUnitName := AUnitName;
  ATag.SourceUnitName := AUnitName;
  ATag.HardwareCalibrationEnabled := not SameText(AUnitName, 'code');
  ATag.AutoUnit := False;
  ATag.UnitName := AUnitName;
  AErrorText := '';
  Result := True;
end;

function TCustomSourceQuery.Query(const ASourceId: string): IInterface;
begin
  Result := Source;
end;

function TCustomUnitSource.CanSetUnits(ATag: TRecorderTag;
  const AUnitName: string; out AErrorText: string): Boolean;
begin
  Inc(ValidationCalls);
  Result := ATag.Name <> RejectTagName;
  if Result then AErrorText := '' else AErrorText := 'Rejected test channel';
end;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

function IsTemperature(const AUnit: string): Boolean;
begin
  Result := SameText(AUnit, 'degC') or SameText(AUnit, 'C') or
    SameText(AUnit, '°C');
end;

function HasTemperature(AItems: TStrings): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to AItems.Count - 1 do
    if IsTemperature(AItems[I]) then Exit(True);
end;

function HasVoltage(AItems: TStrings): Boolean;
begin
  Result := (AItems.IndexOf('mV') >= 0) or (AItems.IndexOf('мВ') >= 0);
end;

procedure RefreshChoices(AForm: TTagSettingsDialog);
begin
  if Assigned(AForm.fUnitCombo.OnDropDown) then
    AForm.fUnitCombo.OnDropDown(AForm.fUnitCombo);
end;

procedure TestMic140Temperature;
var
  lRegistry: TRecorderTagRegistry;
  lReloaded: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lTags: TList;
  lForm: TTagSettingsDialog;
  lConfig: TRecorderMic140SourceConfig;
  lSettings: TRecorderMic140ChannelSettings;
  lCalibration: TRecorderCalibration;
  lProvider: IRecorderTagSettingsProvider;
  lResolver: IRecorderTagSettingsProviderResolver;
  lState: TRecorderTagSettingsState;
  lUnit: string;
  lChannel: Integer;
  lRoundtripPath: string;
  lIteration: Integer;
begin
  lRegistry := CreateTestRegistry;
  lTags := TList.Create;
  lForm := nil;
  try
    lTag := lRegistry.CreateTag('MIC140-temperature', 16);
    lTag.SourceId := 'MIC-140: 192.0.2.41:4000';
    lTag.Address := '41-01';
    lTag.PollFrequencyHz := 10;
    lTag.SourceUnitName := 'degC';
    lTag.UnitName := 'degC';
    lTag.AutoUnit := True;
    lTag.HardwareCalibrationEnabled := True;
    lTag.ChannelCalibrationEnabled := False;
    lCalibration := TRecorderCalibration.Create(rckScale);
    lCalibration.Name := 'MIC140 test ADC';
    lCalibration.UnitIn := 'code';
    lCalibration.UnitOut := 'mV';
    lCalibration.Scale := 0.01;
    lRegistry.Calibrations.Add(lCalibration);
    lTag.HardwareCalibrationName := lCalibration.Name;
    lConfig := EnsureRecorderMic140DeviceConfig(lRegistry, lTag.SourceId);
    lConfig.EnsureChannelCapacity(48);
    RecorderMic140InitChannelSettings(lSettings, 0, 1);
    lSettings.OutputMode := 'degC';
    lSettings.ChannelCalibrationEnabled := True;
    lSettings.HardwareCalibrationEnabled := True;
    lSettings.HardwareCalibrationName := lCalibration.Name;
    lSettings.ThermocoupleScaleName := 'T';
    lConfig.SetChannelSettings(1, lTag.Address, lSettings);
    RecorderMic140ApplyTagOutputPresentation(lTag, lSettings);
    lRegistry.RegisterActiveSource(lTag.SourceId);

    lResolver := CreateRecorderHardwareTagSettingsResolver;
    Check(Supports(lTag.GetSource, IRecorderTagSettingsProvider, lProvider), 'MIC140 source provider');
    Check(lProvider.ReadState(lRegistry, lTag, lState), 'MIC140 provider state');
    Check(IsTemperature(lState.OutputUnitName), 'Provider must expose complete temperature stage');
    Check(lTag.HardwareCalibrationEnabled and not lTag.ChannelCalibrationEnabled,
      'ReadState must not toggle hardware/channel GX');
    Check(lRegistry.TryGetTagAutoUnit(lTag, lUnit) and IsTemperature(lUnit),
      'Core AutoUnit must prefer complete datasource stage, not ADC mV');
    lRoundtripPath := ExpandFileName('lib/source-unit-roundtrip.json');
    lReloaded := CreateTestRegistry;
    try
      SaveRecorderProjectConfig(lRoundtripPath, lRegistry);
      LoadRecorderProjectConfig(lRoundtripPath, lReloaded);
      Check(IsTemperature(lReloaded.Tags[0].SourceHardwareOutputUnitName),
        'Cold reload must retain complete source hardware unit before opening editor');
      Check(lReloaded.TryGetTagAutoUnit(lReloaded.Tags[0], lUnit) and
        IsTemperature(lUnit), 'Cold reload AutoUnit must remain temperature');
      Check(lReloaded.Tags[0].HardwareCalibrationEnabled and
        not lReloaded.Tags[0].ChannelCalibrationEnabled,
        'Roundtrip must preserve independent GX flags');
    finally
      lReloaded.Free;
      DeleteFile(lRoundtripPath);
    end;

    lTags.Add(lTag);
    lForm := TTagSettingsDialog.CreateDialog(nil, lRegistry, lTags);
    lForm.Show;
    Application.ProcessMessages;
    RefreshChoices(lForm);
    Check(HasTemperature(lForm.fUnitCombo.Items), 'Temperature must remain selectable with Auto enabled');
    Check(HasVoltage(lForm.fUnitCombo.Items), 'Source voltage mode must remain selectable');
    Check(IsTemperature(lForm.fUnitCombo.Text), 'Opening editor must not replace degC by mV');
    lForm.fHardwareCurveCheck.Checked := False;
    Application.ProcessMessages;
    Check(lTag.HardwareCalibrationEnabled, 'Unapplied hardware checkbox must not mutate tag');
    lForm.fHardwareCurveCheck.Checked := True;
    Application.ProcessMessages;
    Check(IsTemperature(lForm.fUnitCombo.Text), 'Re-enable hardware GX must restore configured degC');
    Check(not lTag.ChannelCalibrationEnabled, 'Preview must not enable external channel GX');
    lForm.fApplyButton.Click;
    Check(IsTemperature(lTag.UnitName), 'Apply must retain degC with external GX off');
    Check(lConfig.TryGetChannelSettings(lTag.Address, lChannel, lSettings),
      'Read applied source channel');
    Check(uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(lSettings), 'Apply must preserve datasource temperature mode');
    lForm.fUnitCombo.ItemIndex := lForm.fUnitCombo.Items.IndexOf('mV');
    Check(lForm.fUnitCombo.ItemIndex >= 0, 'Select source voltage mode');
    if Assigned(lForm.fUnitCombo.OnChange) then
      lForm.fUnitCombo.OnChange(lForm.fUnitCombo);
    lForm.fApplyButton.Click;
    Check(lConfig.TryGetChannelSettings(lTag.Address, lChannel, lSettings) and
      not uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(lSettings),
      'Applying voltage unit must update datasource mode');
    Check(SameText(lCalibration.UnitOut, 'mV') and
      (Abs(lCalibration.Scale - 0.01) < 1e-12),
      'Changing source unit must not edit shared ADC calibration');
    lForm.Free;
    lForm := TTagSettingsDialog.CreateDialog(nil, lRegistry, lTags);
    lForm.Show;
    Application.ProcessMessages;
    lForm.fHardwareCurveCheck.Checked := False;
    Application.ProcessMessages;
    lForm.Free;
    lForm := nil;
    Check(lTag.HardwareCalibrationEnabled and not lTag.ChannelCalibrationEnabled,
      'Closing unapplied editor must preserve GX flags');
    Check(lConfig.TryGetChannelSettings(lTag.Address, lChannel, lSettings) and
      not uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(lSettings),
      'Closing unapplied editor must preserve datasource mode');
    lTag.HardwareCalibrationEnabled := False;
    lTag.AutoUnit := True;
    lRegistry.SyncTagAutoUnit(lTag);
    lForm := TTagSettingsDialog.CreateDialog(nil, lRegistry, lTags);
    lForm.Show;
    Application.ProcessMessages;
    Check(SameText(lForm.fUnitCombo.Text, 'code'), 'AH off begins in code');
    lForm.fHardwareCurveCheck.Checked := True;
    lForm.fHardwareCurveCheck.OnClick(lForm.fHardwareCurveCheck);
    lForm.fUnitCombo.OnExit(lForm.fUnitCombo);
    Check(lForm.fAutoUnitCheck.Checked,
      'Enabling AH and leaving unchanged unit must preserve Auto');
    lForm.fApplyButton.Click;
    Check(lTag.AutoUnit, 'Apply after AH toggle must preserve Auto');
    lForm.fHardwareCurveCheck.Checked := False;
    lForm.fHardwareCurveCheck.OnClick(lForm.fHardwareCurveCheck);
    lForm.fUnitCombo.OnExit(lForm.fUnitCombo);
    Check(lForm.fAutoUnitCheck.Checked,
      'Disabling AH and leaving unchanged unit must preserve Auto');
    lForm.fApplyButton.Click;
    lForm.fUnitCombo.Text := 'degC';
    Check(Assigned(lForm.fUnitCombo.OnExit), 'Typed units have a commit handler');
    lForm.fUnitCombo.OnExit(lForm.fUnitCombo);
    Check(IsTemperature(lForm.fUnitCombo.Text) and lForm.fHardwareCurveCheck.Checked,
      'Typing physical source mode requests hardware stage without resetting text');
    Check(lTag.HardwareCalibrationEnabled,
      'Explicit physical unit commit immediately enables the source hardware stage');
    Check(lConfig.TryGetChannelSettings(lTag.Address, lChannel, lSettings) and
      uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(lSettings),
      'Nested hardware editor must see committed source mode before Apply');
    Check(not lForm.fAutoUnitCheck.Checked, 'Explicit source choice is manual');
    lForm.fApplyButton.Click;
    Check(IsTemperature(lTag.UnitName) and not lTag.AutoUnit,
      'Manual degree Apply must not restore stale code output unit');
    Check(lConfig.TryGetChannelSettings(lTag.Address, lChannel, lSettings) and
      uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(lSettings),
      'Manual degree Apply updates actual source mode');
    lForm.fAutoUnitCheck.Checked := True;
    lForm.fAutoUnitCheck.OnClick(lForm.fAutoUnitCheck);
    Check(IsTemperature(lForm.fUnitCombo.Text), 'Auto must preserve pending source mode');
    lForm.fApplyButton.Click;
    Check(lTag.HardwareCalibrationEnabled and IsTemperature(lTag.UnitName),
      'Typed degree Apply updates hardware stage and effective tag unit');
    Check(lConfig.TryGetChannelSettings(lTag.Address, lChannel, lSettings) and
      uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(lSettings),
      'Typed degree Apply must switch actual datasource mode from mV');
    lForm.Free;
    lForm := nil;
    for lIteration := 1 to 3 do
    begin
      lForm := TTagSettingsDialog.CreateDialog(nil, lRegistry, lTags);
      lForm.Show;
      Application.ProcessMessages;
      RefreshChoices(lForm);
      Check(IsTemperature(lForm.fUnitCombo.Text),
        'Reopened Auto degree editor must not restore stale voltage prefix');
      WriteLn('COMBO reopen iteration=', lIteration, ' text=', lForm.fUnitCombo.Text,
        ' index=', lForm.fUnitCombo.ItemIndex, ' count=', lForm.fUnitCombo.Items.Count);
      Check((lForm.fUnitCombo.ItemIndex >= 0) and
        IsTemperature(lForm.fUnitCombo.Items[lForm.fUnitCombo.ItemIndex]),
        'Native combo selected item must agree with degree Text on reopen');
      lForm.fUnitCombo.ItemIndex := lForm.fUnitCombo.Items.IndexOf('uV');
      lForm.fUnitCombo.Text := 'degC';
      lForm.fUnitCombo.OnExit(lForm.fUnitCombo);
      lForm.fAutoUnitCheck.Checked := True;
      lForm.fAutoUnitCheck.OnClick(lForm.fAutoUnitCheck);
      Check(IsTemperature(lForm.fUnitCombo.Text) and
        (lForm.fUnitCombo.ItemIndex >= 0) and
        IsTemperature(lForm.fUnitCombo.Items[lForm.fUnitCombo.ItemIndex]),
        'Auto refresh must synchronize native selected item with degree Text');
      lForm.btnOkClick(lForm);
      Check(lTag.AutoUnit and IsTemperature(lTag.UnitName),
        'OK after explicit degree plus Auto must persist degree');
      lForm.Free;
      lForm := nil;
    end;
  finally
    lForm.Free;
    lTags.Free;
    lRegistry.Free;
  end;
  WriteLn('RESULT MIC140 temperature provider/core/UI passed');
end;

procedure TestCompleteSourceStage;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  C: TRecorderCalibration;
  S: TRecorderMic140ChannelSettings;
  V: TRecorderDoubleArray;
  I, J: Integer;
  Started: QWord;
  U: string;
  Rejected: Boolean;
begin
  R := CreateTestRegistry;
  try
    T := R.CreateTag('complete-source-stage', 16);
    T.AutoUnit := True;
    T.HardwareCalibrationEnabled := True;
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'ADC times 2'; C.Scale := 2; C.UnitIn := 'code'; C.UnitOut := 'mV';
    R.Calibrations.Add(C); T.HardwareCalibrationName := C.Name;
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'external times 4'; C.Scale := 4; C.UnitIn := 'degC'; C.UnitOut := 'degC';
    R.Calibrations.Add(C); T.CalibrationNames.Add(C.Name);
    T.ChannelCalibrationEnabled := True;
    RecorderMic140InitChannelSettings(S, 0, 1);
    S.OutputMode := 'degC';
    RecorderMic140ApplyTagOutputPresentation(T, S);
    Check(Abs(R.TransformTagHardwareValue(T, 1) - 2) < 1e-10, 'ADC helper must retain ADC transform');
    Check(Abs(R.TransformTagSourceOutput(T, 6) - 24) < 1e-10,
      'Complete source ADC2 TC3 followed by external4 must equal 24');
    Check(Abs(R.TransformTagValue(T, 6) - 24) < 1e-10,
      'Generic marked source path must not repeat ADC');
    SetLength(V, 4096);
    for I := 0 to High(V) do V[I] := 6;
    R.TransformTagSourceBlock(T, V, Length(V));
    for I := 0 to High(V) do Check(Abs(V[I] - 24) < 1e-10, 'Prepared block value');
    Started := GetTickCount64;
    for J := 1 to 1000 do
    begin
      for I := 0 to High(V) do V[I] := 6;
      R.TransformTagSourceBlock(T, V, Length(V));
    end;
    WriteLn('BENCH source block 4096000 samples ms=', GetTickCount64 - Started);
    T.ChannelCalibrationEnabled := False;
    Check(Abs(R.TransformTagSourceOutput(T, 6) - 6) < 1e-10, 'External GX off must retain complete source value');
    T.HardwareCalibrationEnabled := False;
    Check(R.TryGetTagAutoUnit(T, U) and SameText(U, 'code'),
      'Hardware off must expose raw codes');
    T.ChannelCalibrationEnabled := True;
    Rejected := False;
    try
      R.ValidateTagSourceOutput(T);
    except
      on E: ERecorderTagError do Rejected := True;
    end;
    Check(not Rejected and (T.CalibrationWarning <> ''),
      'Unit mismatch warns without blocking numeric GX');
    Check(Abs(R.TransformTagSourceOutput(T, 6) - 24) < 1e-10,
      'Mismatched input still runs every numeric GX');
    Check(R.TryGetTagAutoUnit(T, U) and IsTemperature(U),
      'Last active GX determines output unit even with input warning');
    T.ChannelCalibrationEnabled := False;
    C.UnitIn := 'code';
    T.ChannelCalibrationEnabled := True;
    R.ValidateTagSourceOutput(T);
    Check(Abs(R.TransformTagSourceOutput(T, 1) - 4) < 1e-10,
      'Hardware off must still allow explicit code-to-physical external GX');
    Check(R.TryGetTagAutoUnit(T, U) and IsTemperature(U),
      'Explicit code-to-physical GX must advertise its output unit');
  finally R.Free; end;
  WriteLn('RESULT complete source stage scalar/block passed');
end;

procedure TestImmediateSourceUnitMode;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  S: TRecorderMic140ChannelSettings;
  C: TRecorderCalibration;
  Channel: Integer;
  Found: Boolean;
  Provider: IRecorderTagSettingsProvider;
  State: TRecorderTagSettingsState;
begin
  R := CreateTestRegistry;
  try
    T := R.CreateTag('immediate-source-mode', 16);
    T.SourceId := 'MIC-140: 192.0.2.41:4000'; T.Address := '41-01';
    T.HardwareCalibrationEnabled := True; T.AutoUnit := True;
    RecorderMic140InitChannelSettings(S, 0, 1);
    S.OutputMode := 'mV';
    RecorderMic140UpdateChannelSettings(R, T, S);
    T.SetUnits('degC');
    Check(RecorderMic140TryGetChannelSettings(R, T, Channel, S) and
      uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(S),
      'Direct tag.SetUnits must immediately update typed datasource mode');
    Check(IsTemperature(T.SourceHardwareOutputUnitName) and IsTemperature(T.UnitName),
      'Immediate mode change must synchronize source metadata and tag unit');
    S.OutputMode := 'mV';
    RecorderMic140UpdateChannelSettings(R, T, S);
    Check(SameText(T.SourceHardwareOutputUnitName, 'mV') and SameText(T.UnitName, 'mV'),
      'Reverse typed hardware change must immediately synchronize tag presentation');
    Check(Supports(T.GetSource, IRecorderTagSettingsProvider, Provider) and
      Provider.ReadState(R, T, State) and SameText(State.OutputUnitName, 'mV'),
      'Source-owned settings must report configured mV despite retained thermocouple scale');
    T.SetUnits('code');
    Found := RecorderMic140TryGetChannelSettings(R, T, Channel, S);
    WriteLn('RAW MODE hw=', T.HardwareCalibrationEnabled, ' typed=', S.OutputMode,
      ' unit=', T.UnitName, ' sourceMode=', T.SourceValueMode, ' found=', Found,
      ' temp=', uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(S));
    Check(not T.HardwareCalibrationEnabled and
      Found and
      not uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(S),
      'Raw-code selection must disable AH without overwriting configured source mode');
    T.SetUnits('mV');
    Check(T.HardwareCalibrationEnabled, 'Physical source selection immediately restores AH');
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'external sensor voltage to temperature'; C.Scale := 2;
    C.UnitIn := 'mV'; C.UnitOut := 'degC';
    R.Calibrations.Add(C); T.CalibrationNames.Add(C.Name);
    T.ChannelCalibrationEnabled := True;
    T.SetUnits('degC');
    Check(RecorderMic140TryGetChannelSettings(R, T, Channel, S) and
      uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(S),
      'Supported physical request must reach datasource even with external GX');
    Check(T.CalibrationWarning <> '', 'Downstream mismatch is a software warning');
  finally R.Free; end;
  WriteLn('RESULT immediate generic source mode passed');
end;

procedure TestMic185SourceUnits;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lResolver: IRecorderTagSettingsProviderResolver;
  lProvider: IRecorderTagSettingsProvider;
  lState: TRecorderTagSettingsState;
  lUnit: string;
  I: Integer;
  lUnits: array[0..1] of string;
begin
  lUnits[0] := 'Ом';
  lUnits[1] := 'мкстрн';
  lRegistry := CreateTestRegistry;
  try
    lTag := lRegistry.CreateTag('MIC185-unit', 16);
    lTag.SourceId := 'MIC-185: 192.0.2.185:4000';
    lTag.Address := '1-01';
    lTag.PollFrequencyHz := 100;
    RecorderMic185SetKnownIdentity(lRegistry, lTag.SourceId, 171, 0);
    lTag.HardwareCalibrationName := 'MIC185 sn0171 range1 ch01';
    lTag.HardwareCalibrationEnabled := True;
    lTag.ChannelCalibrationEnabled := False;
    lResolver := CreateRecorderHardwareTagSettingsResolver;
    Check(Supports(lTag.GetSource, IRecorderTagSettingsProvider, lProvider), 'MIC185 source provider');
    for I := 0 to High(lUnits) do
    begin
      RecorderMic185SetSourceChannelUnitName(lRegistry, lTag.SourceId,
        lTag.Address, lTag.PollFrequencyHz, lUnits[I]);
      lTag.SourceUnitName := lUnits[I];
      lTag.UnitName := lUnits[I];
      Check(lProvider.ReadState(lRegistry, lTag, lState), 'MIC185 state');
      Check(SameText(lState.OutputUnitName, lUnits[I]), 'MIC185 effective source unit');
      Check(lRegistry.TryGetTagAutoUnit(lTag, lUnit) and SameText(lUnit, lUnits[I]),
        'MIC185 AutoUnit must not regress to intermediate mV');
      Check(lTag.HardwareCalibrationEnabled and not lTag.ChannelCalibrationEnabled,
        'MIC185 ReadState must preserve GX flags');
    end;
  finally lRegistry.Free; end;
  WriteLn('RESULT MIC185 effective source units passed');
end;

procedure TestMic185UnitPresentation;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  C, Current: TRecorderCalibration;
  Tags: TList;
  Form: TTagSettingsDialog;
  Settings, AfterSettings: TMic185ChannelProgramSettings;
  Units: array[0..3] of string;
  ExpectedK: array[0..3] of Double;
  Info: TRecorderUnitInfo;
  SavedMode, SavedCalibration: string;
  PowerMa: Double;
  I, J: Integer;
begin
  R := CreateTestRegistry;
  Tags := TList.Create;
  Form := nil;
  try
    T := R.CreateTag('MIC185-unit-presentation', 16);
    T.SourceId := 'MIC-185: 192.0.2.185:4000';
    T.Address := '1-01'; T.PollFrequencyHz := 100;
    T.HardwareCalibrationEnabled := True;
    T.ChannelCalibrationEnabled := False;
    T.AutoUnit := False;
    RecorderMic185ReadChannelMode('', 100, Settings);
    Settings.MeasRangeIndex := 3;
    Settings.Resistance := 350;
    Settings.TensoSensitivity := 2;
    Settings.SensorScheme := 0;
    RecorderMic185SetSourceChannelMode(R, T.SourceId, T.Address, 100, Settings);
    RecorderMic185SetSourcePowerMaCode(R, T.SourceId, 100, 10000);
    RecorderMic185SetSourceChannelUnitName(R, T.SourceId, T.Address, 100, 'мВ');
    T.UnitName := 'mV';
    C := TRecorderCalibration.Create(rckPiecewiseLinear);
    C.Name := 'MIC185 sn0171 range4 ch01';
    C.UnitIn := 'code'; C.UnitOut := 'mV';
    C.AddPoint(3, 0); C.AddPoint(13, 20);
    R.Calibrations.Add(C);
    T.HardwareCalibrationName := C.Name;
    SavedCalibration := C.Name;
    Current := TRecorderCalibration.Create(rckScale);
    Current.Name := 'MIC185 sn0171 current ch01';
    Current.Scale := 2;
    R.Calibrations.Add(Current);
    SavedMode := RecorderMic185FormatChannelMode(Settings);
    PowerMa := Abs(Mic185PowerCodeToMa(10000)) * 2;
    Units[0] := 'mV'; Units[1] := 'Ohm'; Units[2] := 'uStrain'; Units[3] := 'V';
    ExpectedK[0] := 2;
    ExpectedK[1] := 2 / PowerMa;
    ExpectedK[2] := 2 * 1000000 / (PowerMa * 350 * 2);
    ExpectedK[3] := 0.002;
    Tags.Add(T);
    Form := TTagSettingsDialog.CreateDialog(nil, R, Tags);
    Check(Form.fHardwareCurveEdit.Text = RecorderMic185FormatHardwareKx(2, 3),
      'MIC185 initial ADC presentation is k*(code-b)');
    for I := 1 to 4 do
    begin
      RefreshChoices(Form);
      J := I mod 4;
      Check(Form.fUnitCombo.Items.IndexOf(Units[J]) >= 0,
        'Every physical unit is selectable on the same MIC185 range');
      Form.fUnitCombo.ItemIndex := Form.fUnitCombo.Items.IndexOf(Units[J]);
      Form.fUnitCombo.OnSelect(Form.fUnitCombo);
      Check(Form.fHardwareCurveEdit.Text =
        RecorderMic185FormatHardwareKx(ExpectedK[J], 3),
        'MIC185 hardware GX text updates immediately after selecting ' + Units[J] +
        ': ' + Form.fHardwareCurveEdit.Text);
      Check(RecorderUnitManager.TryGetUnitInfo(T.GetUnits, Info) and
        SameText(Info.Name, Units[J]), 'MIC185 selected unit is committed');
      RecorderMic185GetSourceChannelMode(R, T.SourceId, T.Address, 100, AfterSettings);
      Check(RecorderMic185FormatChannelMode(AfterSettings) = SavedMode,
        'Changing MIC185 software units must preserve all hardware channel settings');
      Check((T.HardwareCalibrationName = SavedCalibration) and
        (R.FindCalibrationByName(SavedCalibration) = C) and
        (C.PointAt(0).X = 3) and (C.PointAt(1).Y = 20),
        'Changing units must not replace or rewrite the shared ADC GX');
      Check(T.HardwareCalibrationEnabled and not T.ChannelCalibrationEnabled and
        not T.AutoUnit, 'Source unit commit preserves the intended independent flags');
    end;
  finally
    Form.Free;
    Tags.Free;
    R.Free;
  end;
  WriteLn('RESULT MIC185 immediate unit presentation and unchanged hardware range passed');
end;

procedure TestMx248ChargeCategory;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  Source: IRecorderDataSource;
  Configured: TRecorderConfiguredDataSource;
  Names: TStringList;
  SourceInfo, Info: TRecorderUnitInfo;
  I: Integer;
begin
  R := CreateTestRegistry;
  Names := TStringList.Create;
  Configured := TRecorderConfiguredDataSource.Create;
  try
    Configured.SourceId := 'pxi-mx248:1:2';
    Configured.SpecificConfigText := 'channel.1.amplifier-enabled=True';
    Source := RecorderCreatePxiMx248DataSource(Configured, 200);
    Source.ConfigureTags(R);
    Check(R.TagCount = 8, 'Real MX248 source exposes eight cold-configured channels');
    T := R.Tags[0];
    Source.GetUnitNames(T, Names);
    Check(Names.Count > 0, 'Common datasource API advertises charge units');
    Check(RecorderUnitManager.TryGetUnitInfo('pC', SourceInfo), 'Charge unit known');
    for I := 0 to Names.Count - 1 do
    begin
      Check(RecorderUnitManager.TryGetUnitInfo(Names[I], Info), 'Advertised unit known');
      Check(SameText(Info.QuantityId, SourceInfo.QuantityId),
        'Charge mode must not advertise voltage units');
    end;
  finally Source := nil; Configured.Free; Names.Free; R.Free; end;
  WriteLn('RESULT MX248 charge category passed');
end;

procedure TestLiveMic140MissingCurvePreflight;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  Source: TRecorderMic140DataSource;
  Query: TCustomSourceQuery;
  S: TRecorderMic140ChannelSettings;
  C: TRecorderCalibration;
  ErrorText: string;
  Rejected: Boolean;
begin
  R := TRecorderTagRegistry.Create;
  Query := TCustomSourceQuery.Create;
  try
    Source := TRecorderMic140DataSource.Create('MIC-140: 192.0.2.41:4000',
      '192.0.2.41', 4000, 48, 10, 200);
    Query.Source := Source;
    R.ConfigureTagSources(@Query.Query);
    T := R.CreateTag('missing-live-TC', 16);
    T.SourceId := 'MIC-140: 192.0.2.41:4000'; T.Address := '41-01';
    T.HardwareCalibrationEnabled := True; T.AutoUnit := True;
    RecorderMic140InitChannelSettings(S, 0, 1);
    S.OutputMode := 'mV'; S.ThermocoupleScaleName := 'nonexistent explicit TC';
    S.ThermocoupleScalePath := 'nonexistent explicit TC';
    RecorderMic140UpdateChannelSettings(R, T, S);
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'available ADC for TC preflight'; C.Scale := 1;
    C.UnitIn := 'code'; C.UnitOut := 'mV'; R.Calibrations.Add(C);
    T.HardwareCalibrationName := C.Name;
    Source.ConfigureTags(R);
    T.AddSample(1, 17);
    { Start on an unprepared source exits before device.Start: this exercises
      the live preflight branch without connecting test hardware. }
    Source.Start;
    Check(Source.State = dssRunning, 'Fixture reaches live unit policy');
    Check(not Source.CanSetUnits(T, 'degC', ErrorText) and
      (Pos('thermocouple', ErrorText) > 0), 'Live missing TC remains a hard preflight error');
    Rejected := False;
    try T.SetUnits('degC'); except on E: ERecorderTagError do Rejected := True; end;
    Check(Rejected and SameText(T.UnitName, 'mV') and T.AutoUnit and
      (T.SignalBuffer.LatestValue = 17), 'Rejected live TC edit preserves metadata and history');
    Source.Stop;
  finally
    R.Free; Query.Free;
  end;
  WriteLn('RESULT live missing TC preflight passed');
end;

procedure TestWarningMathAndLastScale;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  C, Last: TRecorderCalibration;
  Query: TCustomSourceQuery;
  Source: TCustomUnitSource;
  Values: TRecorderDoubleArray;
  Rejected: Boolean;
begin
  R := TRecorderTagRegistry.Create;
  Query := TCustomSourceQuery.Create;
  try
    Source := TCustomUnitSource.Create;
    Query.Source := Source;
    R.ConfigureTagSources(@Query.Query);
    T := R.CreateTag('warning-math', 16);
    T.SourceId := 'third-party-source';
    T.SourceHardwareOutputUnitName := 'degC'; T.SourceUnitName := 'degC';
    T.HardwareCalibrationEnabled := True; T.ChannelCalibrationEnabled := True;
    T.AutoUnit := True;
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'mismatched factor'; C.UnitIn := 'mV'; C.UnitOut := 'parrots'; C.Scale := 0.1;
    R.Calibrations.Add(C); T.CalibrationNames.Add(C.Name);
    R.ValidateTagSourceOutput(T);
    Check(Abs(R.TransformTagSourceOutput(T, 2000) - 200) < 1e-10,
      '2000 degC through mV-input 0.1 GX remains numeric 200 parrots');
    SetLength(Values, 2); Values[0] := 2000; Values[1] := 1000;
    R.TransformTagSourceBlock(T, Values, 2);
    Check((Abs(Values[0] - 200) < 1e-10) and (Abs(Values[1] - 100) < 1e-10),
      'Mismatched prepared block runs numeric GX');
    Check((T.CalibrationWarning <> '') and (T.GetLastScale = C) and
      (T.GetUnits = 'parrots') and (T.UnitName = 'parrots'),
      'Warning and last enabled GX define both display and export units');
    Last := TRecorderCalibration.Create(rckLinear);
    Last.Name := 'second GX'; Last.UnitIn := 'parrots'; Last.UnitOut := 'parrots';
    Last.Scale := 2; Last.Offset := 3;
    R.Calibrations.Add(Last); T.CalibrationNames.Add(Last.Name);
    Source.UpdateScales(T);
    Check((T.GetLastScale = Last) and
      (Abs(R.TransformTagSourceOutput(T, 2000) - 403) < 1e-10),
      'Nonlinear plan retains all enabled numeric stages');
    RecorderSetCalibrationStepEnabled(T.CalibrationNames, 1, False);
    Source.UpdateScales(T);
    Check((T.GetLastScale = C) and
      (Abs(R.TransformTagSourceOutput(T, 2000) - 200) < 1e-10),
      'Disabled tail scale does not affect math or unit selection');
    C.UnitIn := 'degC'; Source.UpdateScales(T);
    Check(T.CalibrationWarning = '', 'Fixing input units clears old warning');
    RecorderSetCalibrationStepEnabled(T.CalibrationNames, 0, False);
    Source.UpdateScales(T);
    Check((T.GetLastScale = nil) and IsTemperature(T.GetUnits) and
      (Abs(R.TransformTagSourceOutput(T, 2000) - 2000) < 1e-10),
      'No enabled channel scale falls back to datasource units and identity math');
    T.CalibrationNames.Add('missing mandatory GX');
    Rejected := False;
    try
      Source.UpdateScales(T);
      R.ValidateTagSourceOutput(T);
    except on E: ERecorderTagError do Rejected := True; end;
    Check(Rejected, 'Missing GX remains a hard error');
  finally
    R.Free; Query.Free;
  end;
  WriteLn('RESULT warning math, disabled scales and source units passed');
end;

procedure TestMic185PreparedNumeric;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  ADC, External: TRecorderCalibration;
  S: TMic185ChannelProgramSettings;
  P: TRecorderMic185ValueTransform;
  Rejected: Boolean;
begin
  R := CreateTestRegistry;
  try
    T := R.CreateTag('MIC185-prepared', 16);
    T.SourceId := 'MIC-185: 192.0.2.185:4000'; T.Address := '1-01';
    T.PollFrequencyHz := 100; T.AutoUnit := True;
    RecorderMic185ReadChannelMode('', 100, S);
    S.SoftBalanceFine := 3;
    RecorderMic185SetSourceChannelUnitName(R, T.SourceId, T.Address, 100, 'Ом');
    ADC := TRecorderCalibration.Create(rckScale);
    ADC.Name := 'numeric ADC'; ADC.Scale := 2; ADC.UnitIn := 'code'; ADC.UnitOut := 'mV';
    R.Calibrations.Add(ADC);
    External := TRecorderCalibration.Create(rckScale);
    External.Name := 'numeric external'; External.Scale := 4;
    External.UnitIn := 'code'; External.UnitOut := 'degC';
    R.Calibrations.Add(External); T.CalibrationNames.Add(External.Name);
    T.ChannelCalibrationEnabled := True; T.HardwareCalibrationEnabled := False;
    P := RecorderMic185BuildValueTransform(R, T, S, ADC);
    Check(Abs(RecorderMic185ApplyValueTransform(10, P) - 40) < 1e-10,
      'MIC185 AH off must bypass ADC, balance and Ohm conversion, retaining code GX');
    T.ChannelCalibrationEnabled := False;
    External.UnitIn := 'degC';
    T.ChannelCalibrationEnabled := True;
    Rejected := False;
    try
      P := RecorderMic185BuildValueTransform(R, T, S, ADC);
    except on E: Exception do Rejected := True; end;
    Check(not Rejected and (T.CalibrationWarning <> ''),
      'MIC185 mismatched units warn while preserving numeric GX');
    Check(Abs(RecorderMic185ApplyValueTransform(10, P) - 40) < 1e-10,
      'MIC185 mismatched GX still applies its numeric factor');
    External.Scale := 0.1; External.UnitOut := 'parrots';
    T.AutoUnit := False; T.UnitName := 'V';
    P := RecorderMic185BuildValueTransform(R, T, S, ADC);
    Check((Abs(RecorderMic185ApplyValueTransform(2000, P) - 200) < 1e-10) and
      (T.CalibrationWarning <> '') and (T.UnitName = 'parrots') and
      (T.GetUnits = 'parrots'), 'MIC185 warning plan preserves numeric math and true export units');
    External.Scale := 4;
    T.AutoUnit := True;
    T.ChannelCalibrationEnabled := False;
    External.UnitIn := 'Ом'; External.UnitOut := 'Ом';
    T.HardwareCalibrationEnabled := True; T.ChannelCalibrationEnabled := True;
    P := RecorderMic185BuildValueTransform(R, T, S, ADC);
    Check(P.PowerMa > 0, 'MIC185 excitation current is positive');
    Check(Abs(RecorderMic185ApplyValueTransform(10, P) -
      ((10 - 3) * 2 / P.PowerMa * 4)) < 1e-9,
      'MIC185 prepared ADC then Ohm source stage then external GX');
    Rejected := False;
    try
      P := RecorderMic185BuildValueTransform(R, T, S, nil);
    except on E: Exception do Rejected := True; end;
    Check(Rejected, 'MIC185 cold prepare rejects missing enabled ADC');
  finally R.Free; end;
  WriteLn('RESULT MIC185 prepared numeric pipeline passed');
end;

procedure TestUnitChoiceFallback;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  L: TList;
  F: TTagSettingsDialog;
begin
  R := CreateTestRegistry;
  L := TList.Create;
  F := nil;
  try
    T := R.CreateTag('unit-choice-fallback', 16);
    L.Add(T);
    F := TTagSettingsDialog.CreateDialog(nil, R, L);
    F.fUnitCombo.Text := '';
    RefreshChoices(F);
    Check((F.fUnitCombo.Items.Count = 1) and
      (F.fUnitCombo.Text = 'б.р.'), 'Empty unit must show dimensionless only');
    F.fUnitCombo.Text := 'мВ';
    RefreshChoices(F);
    Check(HasVoltage(F.fUnitCombo.Items) and
      (F.fUnitCombo.Items.IndexOf('Hz') < 0) and
      (F.fUnitCombo.Items.IndexOf('code') < 0), 'Typed voltage limits category');
    Check(F.fUnitCombo.Text = 'мВ', 'Dropdown preserves typed alias');
    F.fUnitCombo.Text := 'custom-unit';
    RefreshChoices(F);
    Check((F.fUnitCombo.Items.Count = 1) and
      (F.fUnitCombo.Items[0] = 'custom-unit'), 'Unknown unit does not offer catalogue');
  finally F.Free; L.Free; R.Free; end;
  WriteLn('RESULT unit choice fallback passed');
end;

procedure TestCustomLiveSourceInterface;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  Source: TCustomUnitSource;
  Query: TCustomSourceQuery;
  Tags: TList;
  Form: TTagSettingsDialog;
  I, BeforeCalls: Integer;
begin
  R := CreateTestRegistry;
  Query := TCustomSourceQuery.Create;
  Tags := TList.Create;
  try
    Source := TCustomUnitSource.Create;
    Query.Source := Source;
    R.ConfigureTagSources(@Query.Query);
    T := R.CreateTag('custom-live-source', 16);
    T.SourceId := 'third-party-source';
    T.SetUnits('degC');
    Check((Source.Calls = 1) and IsTemperature(Source.LastUnit),
      'Unknown datasource must receive SetUnits through live generic interface');
    Check(T.HardwareCalibrationEnabled and IsTemperature(T.UnitName),
      'Generic live unit request updates effective tag state');
    T.SetUnits('code');
    Check((Source.Calls = 2) and SameText(Source.LastUnit, 'code') and
      not T.HardwareCalibrationEnabled and not T.AutoUnit,
      'Live source receives synchronized raw-code request');
    T.SetUnits('degC');
    Tags.Add(T);
    for I := 0 to 1 do
    begin
      T.AutoUnit := I = 1;
      BeforeCalls := Source.Calls;
      Form := TTagSettingsDialog.CreateDialog(nil, R, Tags);
      try
        Form.Show;
        Application.ProcessMessages;
        RefreshChoices(Form);
        Check(Form.fAutoUnitCheck.Checked = (I = 1),
          'Opening editor preserves manual/Auto unit mode');
      finally Form.Free; end;
      Check((T.AutoUnit = (I = 1)) and (Source.Calls = BeforeCalls),
        'Opening and closing editor must not issue source unit requests');
    end;
  finally
    Tags.Free;
    R.Free;
    Query.Free;
  end;
  WriteLn('RESULT custom live source interface passed');
end;

procedure TestDefaultThermocouple;
const Name: string = 'K_ГОСТ Р 8.585-2001';
var
  R: TRecorderTagRegistry;
  C: TRecorderCalibration;
  S: TRecorderMic140ChannelSettings;
  OldDir, OldKey, OldLast, OldMera, Dir: string;
  Files: TStringList;
begin
  RecorderMeraGetThermocoupleCache(OldDir, OldKey);
  OldLast := RecorderMeraThermocoupleLastMeraPath;
  OldMera := RecorderMeraFilesPath;
  Dir := IncludeTrailingPathDelimiter(ExpandFileName('lib/default-tc-fixture'));
  ForceDirectories(Dir);
  Files := TStringList.Create;
  R := CreateTestRegistry;
  try
    Files.Text := 'fixture';
    Files.SaveToFile(UTF8ToSys(Dir + Name + '.xml'));
    Files.SaveToFile(UTF8ToSys(Dir + Name + '.csv'));
    Check(FileExistsUTF8(Dir + Name + '.xml') and FileExistsUTF8(Dir + Name + '.csv'),
      'Fixture catalogue must use actual UTF8 filenames');
    SetRecorderMeraFilesPath(Dir);
    RecorderMeraSetThermocoupleLastMeraPath(RecorderMeraFilesPath);
    RecorderMeraSetThermocoupleCache(Dir, 'SourceUnitPipelineUiSmoke/thermocouples');
    Files.Clear;
    RecorderMeraListThermocoupleScales(Files);
    WriteLn('DEFAULT TC catalogue count=', Files.Count, ' entries=', Files.CommaText);
    Check(Files.IndexOf(Name) >= 0, 'Catalogue must preserve UTF8 and dotted GOST name');
    C := TRecorderCalibration.Create(rckScale);
    C.Name := 'TC ' + Name; C.UnitIn := 'mV'; C.UnitOut := 'degC'; C.Scale := 1;
    R.Calibrations.Add(C);
    RecorderMic140InitChannelSettings(S, 0, 1);
    Check(not RecorderMic140TryAssignDefaultThermocouple(R, S),
      'Voltage mode must not acquire default thermocouple');
    S.OutputMode := 'degC';
    Check(RecorderMic140TryAssignDefaultThermocouple(R, S) and
      (S.ThermocoupleScaleName = Name), 'Degree mode selects available K GOST default');
    S.ThermocoupleScaleName := 'Existing T'; S.ThermocoupleScalePath := 'existing/T';
    Check(not RecorderMic140TryAssignDefaultThermocouple(R, S) and
      (S.ThermocoupleScaleName = 'Existing T'), 'Existing thermocouple must be preserved');
    DeleteFileUTF8(Dir + Name + '.xml'); DeleteFileUTF8(Dir + Name + '.csv');
    S.ThermocoupleScaleName := ''; S.ThermocoupleScalePath := '';
    Check(not RecorderMic140TryAssignDefaultThermocouple(R, S),
      'Missing K catalogue must not fabricate default calibration');
  finally
    SetRecorderMeraFilesPath(OldMera);
    RecorderMeraSetThermocoupleCache(OldDir, OldKey);
    RecorderMeraSetThermocoupleLastMeraPath(OldLast);
    DeleteFileUTF8(Dir + Name + '.xml'); DeleteFileUTF8(Dir + Name + '.csv');
    R.Free; Files.Free;
  end;
  WriteLn('RESULT default thermocouple selection passed');
end;

procedure TestBatchSourceUnitChoices;
var
  R: TRecorderTagRegistry;
  Tags: TList;
  F: TTagSettingsDialog;
  T: TRecorderTag;
  S: TRecorderMic140ChannelSettings;
  I, Channel: Integer;
begin
  R := CreateTestRegistry; Tags := TList.Create; F := nil;
  try
    for I := 1 to 10 do
    begin
      T := R.CreateTag('batch-temperature-' + IntToStr(I), 16);
      T.SourceId := 'MIC-140: 192.0.2.41:4000'; T.Address := Format('41-%.2d', [I]);
      T.AutoUnit := True; T.HardwareCalibrationEnabled := True;
      RecorderMic140InitChannelSettings(S, 0, I); S.OutputMode := 'mV';
      RecorderMic140UpdateChannelSettings(R, T, S); Tags.Add(T);
    end;
    F := TTagSettingsDialog.CreateDialog(nil, R, Tags);
    F.Show; Application.ProcessMessages; RefreshChoices(F);
    Check(HasTemperature(F.fUnitCombo.Items), 'Ten MIC140 tags expose common temperature source mode');
    F.fUnitCombo.Text := 'degC'; F.fUnitCombo.OnExit(F.fUnitCombo);
    for I := 0 to Tags.Count - 1 do
    begin
      T := TRecorderTag(Tags[I]);
      Check(RecorderMic140TryGetChannelSettings(R, T, Channel, S) and
        uRecorderMic140DeviceConfig.RecorderMic140ChannelUsesTemperature(S) and IsTemperature(T.UnitName),
        'Batch unit commit must update every typed datasource channel immediately');
    end;
    F.Free; F := nil;
    T := R.CreateTag('mixed-MIC185', 16);
    T.SourceId := 'MIC-185: 192.0.2.185:4000'; T.Address := '1-01';
    RecorderMic185SetKnownIdentity(R, T.SourceId, 171, 0);
    RecorderMic185SetSourceChannelUnitName(R, T.SourceId, T.Address, 100, 'мВ');
    T.UnitName := 'мВ'; T.HardwareCalibrationEnabled := True; Tags.Add(T);
    F := TTagSettingsDialog.CreateDialog(nil, R, Tags);
    F.Show; Application.ProcessMessages; RefreshChoices(F);
    Check(not HasTemperature(F.fUnitCombo.Items) and
      (F.fUnitCombo.Items.IndexOf('Ом') < 0) and HasVoltage(F.fUnitCombo.Items),
      'Mixed provider batch offers only common physical quantities');
  finally F.Free; Tags.Free; R.Free; end;
  WriteLn('RESULT batch source unit choices passed');
end;

procedure TestBatchPreflightRejectsBeforeMutation;
var
  R: TRecorderTagRegistry;
  Tags: TList;
  F: TTagSettingsDialog;
  T: TRecorderTag;
  Source: TCustomUnitSource;
  Query: TCustomSourceQuery;
  I: Integer;
  Rejected: Boolean;
begin
  R := CreateTestRegistry; Tags := TList.Create;
  Query := TCustomSourceQuery.Create; F := nil;
  try
    Source := TCustomUnitSource.Create; Query.Source := Source;
    Source.RejectTagName := 'batch-rejected-2';
    R.ConfigureTagSources(@Query.Query);
    for I := 1 to 2 do
    begin
      T := R.CreateTag('batch-rejected-' + IntToStr(I), 16);
      T.SourceId := 'third-party-source'; T.SourceHardwareOutputUnitName := 'V';
      T.SourceUnitName := 'V'; T.UnitName := 'V';
      T.HardwareCalibrationEnabled := True; T.AutoUnit := True; Tags.Add(T);
    end;
    F := TTagSettingsDialog.CreateDialog(nil, R, Tags);
    F.Show; Application.ProcessMessages;
    F.fUnitCombo.Text := 'mV';
    Rejected := False;
    try F.fUnitCombo.OnExit(F.fUnitCombo);
    except on E: ERecorderTagError do Rejected := True; end;
    Check(Rejected and (Source.ValidationCalls >= 2), 'Batch validates rejecting second channel');
    Check(Source.Calls = 0, 'Rejected batch must issue zero source SetUnits commands');
    for I := 0 to Tags.Count - 1 do
    begin
      T := TRecorderTag(Tags[I]);
      Check((T.UnitName = 'V') and T.HardwareCalibrationEnabled and T.AutoUnit,
        'Rejected batch must preserve every tag unit and flag');
    end;
  finally F.Free; Tags.Free; R.Free; Query.Free; end;
  WriteLn('RESULT batch source unit preflight passed');
end;

procedure TestMissingTypedMic140Preflight;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  Rejected: Boolean;
begin
  R := CreateTestRegistry;
  try
    T := R.CreateTag('missing-typed-channel', 16);
    T.SourceId := 'MIC-140: 192.0.2.41:4000'; T.Address := 'invalid';
    T.SourceUnitName := 'mV'; T.SourceHardwareOutputUnitName := 'mV';
    T.UnitName := 'mV'; T.AutoUnit := True; T.HardwareCalibrationEnabled := False;
    Rejected := False;
    try T.ValidateUnits('degC');
    except on E: ERecorderTagError do Rejected := True; end;
    Check(Rejected, 'Missing typed MIC140 channel must fail pure unit preflight');
    Check((T.UnitName = 'mV') and (T.SourceUnitName = 'mV') and
      (T.SourceHardwareOutputUnitName = 'mV') and T.AutoUnit and
      not T.HardwareCalibrationEnabled and not T.ChannelCalibrationEnabled,
      'Failed missing-config validation must preserve all unit and GX state');
    Rejected := False;
    try T.SetUnits('degC');
    except on E: ERecorderTagError do Rejected := True; end;
    Check(Rejected and (T.UnitName = 'mV') and T.AutoUnit and
      not T.HardwareCalibrationEnabled, 'Actual missing-config unit edit must match preflight');
  finally R.Free; end;
  WriteLn('RESULT missing typed MIC140 preflight passed');
end;

procedure TestDirectTagSourceBinding;
var
  R: TRecorderTagRegistry;
  M, NewManager: TRecorderDataSourceManager;
  T, NewTag: TRecorderTag;
  A, B, Replacement, NewOwnerSource: IRecorderDataSource;
begin
  R := CreateTestRegistry; M := TRecorderDataSourceManager.Create; NewManager := nil;
  try
    T := R.CreateTag('existing-source-binding', 16); T.SourceId := 'source-a';
    A := TLookupTestSource.Create('source-a', 'A', 200);
    B := TLookupTestSource.Create('source-b', 'B', 200);
    M.AddSource(A); M.AddSource(B); M.ConfigureTagsAll(R);
    Check(T.GetSource = IInterface(A), 'Existing tag resolves source directly after cold binding');
    NewTag := R.CreateTag('new-source-binding', 16); NewTag.SourceId := 'source-b';
    Check(NewTag.GetSource = IInterface(B), 'New tags inherit cold source resolver');
    T.SourceId := 'source-b';
    Check(T.GetSource = IInterface(B), 'GetSource resolves current SourceId without stale source cache');
    Replacement := TLookupTestSource.Create('source-b', 'replacement B', 200);
    M.ReplaceSource(Replacement, True, False);
    Check(T.GetSource = IInterface(Replacement), 'GetSource follows replacement source');
    M.RemoveSource('source-b');
    Check(T.GetSource = nil, 'Removed source resolves nil');
    T.SourceId := 'source-a'; M.Clear;
    Check((T.GetSource = nil) and (NewTag.GetSource = nil),
      'Manager clear detaches source resolvers before freeing sources');
    NewTag := R.CreateTag('created-after-clear', 16); NewTag.SourceId := 'source-a';
    Check(NewTag.GetSource = nil, 'Tags created after clear must not inherit dead manager callback');
    M.AddSource(A); M.ConfigureTagsAll(R);
    NewManager := TRecorderDataSourceManager.Create;
    NewOwnerSource := TLookupTestSource.Create('source-a', 'new owner A', 200);
    NewManager.AddSource(NewOwnerSource); NewManager.ConfigureTagsAll(R);
    M.Clear;
    Check(T.GetSource = IInterface(NewOwnerSource),
      'Clearing older manager must preserve newer source resolver owner');
    NewManager.Free; NewManager := nil;
    Check(T.GetSource = nil, 'Destroying current manager detaches source callback');
  finally NewManager.Free; M.Free; R.Free; end;
  WriteLn('RESULT direct tag source binding lifecycle passed');
end;

procedure TestMic185CachedCurrentRange;
var
  R: TRecorderTagRegistry;
  T: TRecorderTag;
  C: TRecorderCalibration;
  S: TMic185ChannelProgramSettings;
  Source: IRecorderDataSource;
  Names: TStringList;
  ExpectedRange: Double;
  I: Integer;
begin
  R := CreateTestRegistry; Names := TStringList.Create; Source := nil;
  try
    T := R.CreateTag('cached-current-range', 16);
    T.SourceId := 'MIC-185: 192.0.2.185:4000'; T.Address := '1-01';
    T.HardwareCalibrationName := 'MIC185 sn0171 range1 ch01';
    T.HardwareCalibrationEnabled := True; T.UnitName := 'Ом'; T.AutoUnit := False;
    RecorderMic185ReadChannelMode('', 100, S); S.PowerMaCode := 0;
    RecorderMic185SetSourceChannelMode(R, T.SourceId, T.Address, 100, S);
    RecorderMic185SetSourceChannelUnitName(R, T.SourceId, T.Address, 100, 'Ом');
    C := TRecorderCalibration.Create(rckPiecewiseLinear);
    C.Name := 'MIC185 sn0171 current ch01';
    C.AddPoint(0, 0); C.AddPoint(1, 2);
    R.Calibrations.Add(C);
    Check(Abs(RecorderMic185ApplyCachedCurrentCalibration(R, T, 3) - 6) < 1e-10,
      'Cached current calibration must convert nominal excitation');
    ExpectedRange := RecorderMic185EffectiveRangeMax(S, 'Ом') / 2;
    Source := TRecorderMic185DataSource.Create(T.SourceId, '192.0.2.185', 4000, 100, 200);
    Source.ConfigureTags(R);
    for I := 0 to R.TagCount - 1 do
      if I < 4 then WriteLn('MODEL TAG ', I, ' name=', R.Tags[I].Name,
        ' address=', R.Tags[I].Address, ' module=', R.Tags[I].ModuleType);
    Check(R.TagCount > 1, 'Actual MIC185 model enumerates measurement tags');
    T := R.Tags[1];
    T.Address := '185-01';
    T.HardwareCalibrationName := 'MIC185 sn0171 range1 ch01';
    T.HardwareCalibrationEnabled := True; T.UnitName := 'Ом'; T.AutoUnit := False;
    RecorderMic185SetSourceChannelMode(R, T.SourceId, T.Address, 100, S);
    RecorderMic185SetSourceChannelUnitName(R, T.SourceId, T.Address, 100, 'Ом');
    Source.ConfigureTags(R);
    WriteLn('CURRENT RANGE address=', T.Address, ' actual=', T.RangeMax:0:8,
      ' expected=', ExpectedRange:0:8, ' unit=', T.UnitName);
    Check((RecorderMic185ChannelAddressToIndex('01') = 0) and
      (RecorderMic185ChannelAddressToIndex('171-01') = 0),
      'Bare and device-prefixed canonical addresses identify the same measurement channel');
    Check(Abs(RecorderMic185ApplyCurrentCalibration(R, T, 3) - 6) < 1e-10,
      'Full current calibration must use registered curve on canonical bare channel');
    Check(Abs(T.RangeMax - ExpectedRange) < 1e-10,
      'Model-only tag configuration must preserve registered current GX in Ohm range');
    T.HardwareCalibrationName := 'unknown';
    Check(Abs(RecorderMic185ApplyCachedCurrentCalibration(R, T, 3) - 3) < 1e-10,
      'Missing cached identity must retain nominal current without resolving hardware');
  finally Source := nil; Names.Free; R.Free; end;
  WriteLn('RESULT MIC185 cached current range passed');
end;

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  OwnedBindings := TList.Create;
  try
    TestCompleteSourceStage;
    TestImmediateSourceUnitMode;
    TestMic140Temperature;
    TestMic185SourceUnits;
    TestMic185UnitPresentation;
    TestMx248ChargeCategory;
    TestMic185PreparedNumeric;
    TestWarningMathAndLastScale;
    TestLiveMic140MissingCurvePreflight;
    TestUnitChoiceFallback;
    TestCustomLiveSourceInterface;
    TestDefaultThermocouple;
    TestBatchSourceUnitChoices;
    TestBatchPreflightRejectsBeforeMutation;
    TestMissingTypedMic140Preflight;
    TestDirectTagSourceBinding;
    TestMic185CachedCurrentRange;
    FreeTestBindings;
    WriteLn('RESULT SourceUnitPipelineUiSmoke passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT SourceUnitPipelineUiSmoke failed: ', E.Message);
      FreeTestBindings;
      Halt(1);
    end;
  end;
end.
