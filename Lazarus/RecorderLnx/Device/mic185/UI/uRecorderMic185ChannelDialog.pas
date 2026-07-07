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

procedure FillCombo(ACombo: TComboBox; const AValues: array of string;
  AIndex: Integer);
var
  I: Integer;
begin
  ACombo.Items.Clear;
  for I := Low(AValues) to High(AValues) do
    ACombo.Items.Add(AValues[I]);
  if (AIndex >= 0) and (AIndex < ACombo.Items.Count) then
    ACombo.ItemIndex := AIndex;
end;

procedure TRecorderMic185ChannelForm.LoadTag(ATag: TRecorderTag);
begin
  FillCombo(cbNominalRange, ['±500', '±50', '±5'], 2);
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
  if ATag <> nil then
  begin
    Caption := 'Свойства канала ' + ATag.Address;
    if ATag.UnitName <> '' then
      cbActualRangeUnit.Text := ATag.UnitName;
    edSoftBalance.Text := FormatFloat('0.000', ATag.Mic140SoftBalance);
  end;
end;

procedure TRecorderMic185ChannelForm.SaveTag(ATag: TRecorderTag);
var
  lValue: Double;
begin
  if ATag = nil then
    Exit;
  ATag.UnitName := cbActualRangeUnit.Text;
  ATag.SourceValueMode := cbCommutation.Text;
  if TryStrToFloat(StringReplace(edSoftBalance.Text, ',', '.', []), lValue) then
    ATag.Mic140SoftBalance := lValue;
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
