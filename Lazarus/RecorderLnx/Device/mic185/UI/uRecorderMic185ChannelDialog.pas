unit uRecorderMic185ChannelDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls,
  uRecorderTags;

type
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
  public
    procedure LoadTag(ATag: TRecorderTag);
    procedure SaveTag(ATag: TRecorderTag);
  end;

function ShowRecorderMic185ChannelDialog(AOwner: TComponent;
  ATag: TRecorderTag): Boolean;

implementation

{$R *.lfm}

uses
  uRecorderMic185DataSource, uMic185Constants, uMic185MebiusTypes;

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

procedure TRecorderMic185ChannelForm.LoadTag(ATag: TRecorderTag);
var
  lSettings: TMic185ChannelProgramSettings;
begin
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
  edHardBalance.Text := '0.000';
  chkChannelShunt.Checked := False;
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
    edSoftBalance.Text := FloatToStr(lSettings.SoftBalance);
    edStrainSensitivity.Text := FloatToStr(lSettings.TensoSensitivity);
    edOuterResistance.Text := FloatToStr(lSettings.Resistance);
    if ATag.UnitName <> '' then
      cbActualRangeUnit.Text := ATag.UnitName;
  end;
end;

procedure TRecorderMic185ChannelForm.SaveTag(ATag: TRecorderTag);
var
  lSettings: TMic185ChannelProgramSettings;
begin
  if ATag = nil then
    Exit;
  RecorderMic185ReadChannelMode(ATag.SourceValueMode, ATag.PollFrequencyHz,
    lSettings);
  if cbNominalRange.ItemIndex >= 0 then
    lSettings.MeasRangeIndex := cbNominalRange.ItemIndex;
  if cbCommutation.ItemIndex >= 0 then
    lSettings.CommutIndex := cbCommutation.ItemIndex;
  if cbSensorScheme.ItemIndex >= 0 then
    lSettings.SensorScheme := cbSensorScheme.ItemIndex;
  if cbModulePower.ItemIndex >= 0 then
    lSettings.PowerMaCode := Mic185PowerMaToCode(cbModulePower.ItemIndex);
  lSettings.SoftBalance := Round(TextToFloatDef(edSoftBalance.Text, 0));
  if chkChannelShunt.Checked then
  begin
    if cbShuntValue.ItemIndex > 0 then
      lSettings.ShuntOn := cbShuntValue.ItemIndex - 1
    else
      lSettings.ShuntOn := 1;
  end
  else
    lSettings.ShuntOn := 0;
  lSettings.TensoSensitivity := TextToFloatDef(edStrainSensitivity.Text, 2);
  lSettings.Resistance := TextToFloatDef(edOuterResistance.Text, 200);
  lSettings.BlockSize := 1;
  ATag.UnitName := cbActualRangeUnit.Text;
  ATag.RangeMax := RecorderMic185RangeMax(lSettings.MeasRangeIndex);
  ATag.RangeMin := -ATag.RangeMax;
  ATag.SourceValueMode := RecorderMic185FormatChannelMode(lSettings);
end;

function ShowRecorderMic185ChannelDialog(AOwner: TComponent;
  ATag: TRecorderTag): Boolean;
var
  lForm: TRecorderMic185ChannelForm;
begin
  lForm := TRecorderMic185ChannelForm.Create(AOwner);
  try
    lForm.LoadTag(ATag);
    Result := lForm.ShowModal = mrOk;
    if Result then
      lForm.SaveTag(ATag);
  finally
    lForm.Free;
  end;
end;

end.
