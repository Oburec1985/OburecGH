unit uRecorderMic185ChannelDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls,
  uRecorderTags, uMic185MebiusTypes;

type

  { TRecorderMic185ChannelForm }

  TRecorderMic185ChannelForm = class(TForm)
    btnApply: TButton;
    btnCancel: TButton;
    cbActualRangeUnit: TComboBox;
    cbCommutation: TComboBox;
    cbModulePower: TComboBox;
    cbNominalRange: TComboBox;
    cbSensorScheme: TComboBox;
    cbShuntValue: TComboBox;
    cbThermoChannel: TComboBox;
    chkChannelShunt: TCheckBox;
    edActualRange: TEdit;
    edHardBalance: TEdit;
    edInnerResistance: TEdit;
    edNominalRangeUnit: TEdit;
    edOuterResistance: TEdit;
    edSoftBalance: TEdit;
    edSoftBalanceUnit: TEdit;
    edStrainSensitivity: TEdit;
    gbChannel: TGroupBox;
    gbModule: TGroupBox;
    gbSensor: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure btnApplyClick(Sender: TObject);
    procedure SettingsChanged(Sender: TObject);
  private
    fRegistry: TRecorderTagRegistry;
    fTag: TRecorderTag;
    fModuleSettings: TMic185ModuleProgramSettings;
    procedure ReadSettingsFromUi(var ASettings: TMic185ChannelProgramSettings);
    procedure ReadModuleSettingsFromUi(var ASettings: TMic185ModuleProgramSettings);
    procedure UpdateActualRange;
  public
    procedure LoadTag(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const AModuleSettings: TMic185ModuleProgramSettings);
    procedure SaveTag(ATag: TRecorderTag;
      var AModuleSettings: TMic185ModuleProgramSettings);
  end;

function ShowRecorderMic185ChannelDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var AModuleSettings: TMic185ModuleProgramSettings): Boolean;

implementation

{$R *.lfm}

uses
  uRecorderMic185DataSource, uRecorderMic185Calibration, uMic185Constants;

procedure FillCombo(ACombo: TComboBox; const AValues: array of string;
  AIndex: Integer);
var
  I: Integer;
begin
  ACombo.Items.Clear;
  for I := Low(AValues) to High(AValues) do
    ACombo.Items.Add(AValues[I]);
  if (AIndex >= 0) and (AIndex < ACombo.Items.Count) then
    ACombo.ItemIndex := AIndex
  else if ACombo.Items.Count > 0 then
    ACombo.ItemIndex := 0;
end;

function TextToFloatDef(const AText: string; ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AText);
  if TryStrToFloat(lText, Result) then
    Exit;
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator, []);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator, []);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

function Mic185UnitIsRawCode(const AUnitName: string): Boolean;
var
  lUnit: string;
begin
  lUnit := Trim(AUnitName);
  Result := SameText(lUnit, 'код') or SameText(lUnit, 'code');
end;

procedure ApplyMic185HardwareModeFromUnit(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag);
begin
  if ATag = nil then
    Exit;
  if Mic185UnitIsRawCode(ATag.UnitName) then
    ATag.HardwareCalibrationEnabled := False;
  if ATag.HardwareCalibrationEnabled then
    RecorderMic185LoadHardwareCalibrationForTag(ARegistry, ATag, True)
  else
    ATag.UnitName := 'код';
end;

procedure TRecorderMic185ChannelForm.btnApplyClick(Sender: TObject);
begin

end;

procedure TRecorderMic185ChannelForm.SettingsChanged(Sender: TObject);
begin
  UpdateActualRange;
end;

procedure TRecorderMic185ChannelForm.ReadSettingsFromUi(
  var ASettings: TMic185ChannelProgramSettings);
var
  lPowerMa: Double;
begin
  if cbNominalRange.ItemIndex >= 0 then
    ASettings.MeasRangeIndex := cbNominalRange.ItemIndex;
  if cbCommutation.ItemIndex >= 0 then
    ASettings.CommutIndex := cbCommutation.ItemIndex;
  if cbSensorScheme.ItemIndex >= 0 then
    ASettings.SensorScheme := cbSensorScheme.ItemIndex;
  if cbModulePower.ItemIndex >= 0 then
  begin
    lPowerMa := TextToFloatDef(cbModulePower.Text, cbModulePower.ItemIndex);
    ASettings.PowerMaCode := Mic185PowerMaToCode(lPowerMa);
  end;
  ASettings.SoftBalance := RecorderMic185SoftBalanceMvToCode(
    TextToFloatDef(edSoftBalance.Text, 0), ASettings.MeasRangeIndex);
  if chkChannelShunt.Checked then
  begin
    if cbShuntValue.ItemIndex > 0 then
      ASettings.ShuntOn := cbShuntValue.ItemIndex - 1
    else
      ASettings.ShuntOn := 1;
  end
  else
    ASettings.ShuntOn := 0;
  ASettings.TensoSensitivity := TextToFloatDef(edStrainSensitivity.Text, 2);
  ASettings.Resistance := TextToFloatDef(edOuterResistance.Text, 200);
  ASettings.BlockSize := 1;
end;

procedure TRecorderMic185ChannelForm.ReadModuleSettingsFromUi(
  var ASettings: TMic185ModuleProgramSettings);
begin
  ASettings.HardBalance := RecorderMic185HardBalanceMvToCode(
    TextToFloatDef(edHardBalance.Text, 0));
end;

procedure TRecorderMic185ChannelForm.UpdateActualRange;
var
  lSettings: TMic185ChannelProgramSettings;
begin
  RecorderMic185ReadChannelMode('', MIC185DefaultPollFrequencyHz, lSettings);
  ReadSettingsFromUi(lSettings);
  edActualRange.Text := RecorderMic185EffectiveRangeTextForTag(fRegistry, fTag,
    lSettings, cbActualRangeUnit.Text);
end;

procedure TRecorderMic185ChannelForm.LoadTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const AModuleSettings: TMic185ModuleProgramSettings);
var
  lSettings: TMic185ChannelProgramSettings;
begin
  fRegistry := ARegistry;
  fTag := ATag;
  fModuleSettings := AModuleSettings;
  FillCombo(cbNominalRange, ['±500', '±50', '±5', '±0.5'], 2);
  FillCombo(cbActualRangeUnit, ['мВ', 'Ом', 'мкм/м', 'мВ(тензо)'], 0);
  FillCombo(cbCommutation, ['Вход', 'Земля', '49 мВ'], 0);
  FillCombo(cbThermoChannel, ['1', '2', '3', '4', 'выкл'], 0);
  FillCombo(cbSensorScheme, ['Тензометр', 'Полумост', 'Мост'], 0);
  FillCombo(cbModulePower, ['0', '1', '2', '3', '4', '5', '6'], 4);
  FillCombo(cbShuntValue, ['откл', '0', '1', '2', '3'], 0);
  edNominalRangeUnit.Text := 'мВ';
  edActualRange.Text := '±5.000';
  edSoftBalance.Text := '0.000';
  edSoftBalanceUnit.Text := 'мВ';
  edStrainSensitivity.Text := '2.000';
  edOuterResistance.Text := '200.000';
  edInnerResistance.Text := '10000';
  edHardBalance.Text := FormatFloat('0.###',
    RecorderMic185HardBalanceCodeToMv(fModuleSettings.HardBalance));
  chkChannelShunt.Checked := False;
  cbNominalRange.OnChange := @SettingsChanged;
  cbActualRangeUnit.OnChange := @SettingsChanged;
  cbModulePower.OnChange := @SettingsChanged;
  cbSensorScheme.OnChange := @SettingsChanged;
  edStrainSensitivity.OnChange := @SettingsChanged;
  edOuterResistance.OnChange := @SettingsChanged;
  if ATag <> nil then
  begin
    Caption := 'Свойства канала ' + ATag.Address;
    RecorderMic185ReadChannelMode(ATag.SourceValueMode, ATag.PollFrequencyHz,
      lSettings);
    if lSettings.MeasRangeIndex <= CMic185Range05mV then
      cbNominalRange.ItemIndex := lSettings.MeasRangeIndex;
    if lSettings.CommutIndex <= CMic185CommutCalibr then
      cbCommutation.ItemIndex := lSettings.CommutIndex;
    if lSettings.SensorScheme <= CMic185SensorSchemeBridge then
      cbSensorScheme.ItemIndex := lSettings.SensorScheme;
    cbModulePower.ItemIndex := Round(Mic185PowerCodeToMa(
      lSettings.PowerMaCode));
    if cbModulePower.ItemIndex < 0 then
      cbModulePower.ItemIndex := 0
    else if cbModulePower.ItemIndex >= cbModulePower.Items.Count then
      cbModulePower.ItemIndex := cbModulePower.Items.Count - 1;
    if lSettings.ShuntOn = 0 then
      cbShuntValue.ItemIndex := 0
    else if lSettings.ShuntOn < LongWord(cbShuntValue.Items.Count) then
      cbShuntValue.ItemIndex := lSettings.ShuntOn + 1;
    chkChannelShunt.Checked := lSettings.ShuntOn <> 0;
    edActualRange.Text := RecorderMic185RangeText(lSettings.MeasRangeIndex);
    cbActualRangeUnit.Text := RecorderMic185RangeUnitText(lSettings.MeasRangeIndex);
    edSoftBalance.Text := FormatFloat('0.###',
      RecorderMic185SoftBalanceCodeToMv(lSettings.SoftBalance,
      lSettings.MeasRangeIndex));
    edStrainSensitivity.Text := FloatToStr(lSettings.TensoSensitivity);
    edOuterResistance.Text := FloatToStr(lSettings.Resistance);
    cbActualRangeUnit.Text := RecorderMic185GetSourceChannelUnitName(
      fRegistry, ATag.SourceId, ATag.Address);
    if cbActualRangeUnit.Text = '' then
    begin
      if not Mic185UnitIsRawCode(ATag.UnitName) then
        cbActualRangeUnit.Text := ATag.UnitName;
      if cbActualRangeUnit.Text = '' then
        cbActualRangeUnit.Text := RecorderMic185RangeUnitText(
          lSettings.MeasRangeIndex);
    end;
  end;
  UpdateActualRange;
end;

procedure TRecorderMic185ChannelForm.SaveTag(ATag: TRecorderTag;
  var AModuleSettings: TMic185ModuleProgramSettings);
var
  lSettings: TMic185ChannelProgramSettings;
begin
  if ATag = nil then
    Exit;
  RecorderMic185ReadChannelMode(ATag.SourceValueMode, ATag.PollFrequencyHz,
    lSettings);
  ReadSettingsFromUi(lSettings);
  ReadModuleSettingsFromUi(AModuleSettings);
  ATag.UnitName := cbActualRangeUnit.Text;
  ATag.SourceValueMode := RecorderMic185FormatChannelMode(lSettings);
  RecorderMic185SetSourceChannelUnitName(fRegistry, ATag.SourceId,
    ATag.Address, ATag.PollFrequencyHz, ATag.UnitName);
  ApplyMic185HardwareModeFromUnit(fRegistry, ATag);
  ATag.RangeMax := RecorderMic185EffectiveRangeMaxForTag(fRegistry, ATag,
    lSettings, ATag.UnitName);
  ATag.RangeMin := -ATag.RangeMax;
end;

function ShowRecorderMic185ChannelDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var AModuleSettings: TMic185ModuleProgramSettings): Boolean;
var
  lForm: TRecorderMic185ChannelForm;
begin
  lForm := TRecorderMic185ChannelForm.Create(AOwner);
  try
    lForm.LoadTag(ARegistry, ATag, AModuleSettings);
    Result := lForm.ShowModal = mrOk;
    if Result then
      lForm.SaveTag(ATag, AModuleSettings);
  finally
    lForm.Free;
  end;
end;

end.
