unit uRecorderStrainCalibrationFrame;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Math,
  uRecorderTags, uRecorderStrainCalibration;

type
  TRecorderStrainCalibrationFrame = class(TFrame)
    cbExcitationKind, cbInputUnit, cbOutputUnit, cbScheme: TComboBox;
    edDeltaT, edExcitation, edExpansion, edGaugeFactor, edMaxStrain,
      edName, edPoisson, edResistance, edTcr, edYoung: TEdit;
    lblCoefficients, lblError, lblExcitation: TLabel;
    procedure cbExcitationKindChange(Sender: TObject);
  private
    function ReadValue(AEdit: TEdit; out AValue: Double): Boolean;
    function SelectedInputUnit: TRecorderStrainInputUnit;
    procedure PopulateInputUnits(ASelected: TRecorderStrainInputUnit);
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadCalibration(ACalibration: TRecorderCalibration);
    function TryApply(ACalibration: TRecorderCalibration;
      out AError: string): Boolean;
  end;

implementation

{$R *.lfm}

constructor TRecorderStrainCalibrationFrame.Create(AOwner: TComponent);
var
  K: TRecorderStrainExcitationKind;
  O: TRecorderStrainOutputUnit;
  S: TRecorderStrainScheme;
begin
  inherited Create(AOwner);
  for S := Low(S) to High(S) do
    cbScheme.Items.Add(RecorderStrainSchemeName(S));
  for O := Low(O) to High(O) do
    cbOutputUnit.Items.Add(RecorderStrainOutputUnitName(O));
  for K := Low(K) to High(K) do
    cbExcitationKind.Items.Add(RecorderStrainExcitationKindName(K));
end;

function TRecorderStrainCalibrationFrame.SelectedInputUnit:
  TRecorderStrainInputUnit;
begin
  if (cbInputUnit.ItemIndex >= 0) and
    (cbInputUnit.ItemIndex < cbInputUnit.Items.Count) then
    Result := TRecorderStrainInputUnit(PtrInt(
      cbInputUnit.Items.Objects[cbInputUnit.ItemIndex]))
  else
    Result := rsiMilliVolt;
end;

procedure TRecorderStrainCalibrationFrame.PopulateInputUnits(
  ASelected: TRecorderStrainInputUnit);

  procedure AddUnit(AUnit: TRecorderStrainInputUnit);
  begin
    cbInputUnit.Items.AddObject(RecorderStrainInputUnitName(AUnit),
      TObject(PtrInt(AUnit)));
    if AUnit = ASelected then
      cbInputUnit.ItemIndex := cbInputUnit.Items.Count - 1;
  end;

begin
  cbInputUnit.Items.BeginUpdate;
  try
    cbInputUnit.Clear;
    if cbExcitationKind.ItemIndex = Ord(rsekCurrent) then
    begin
      AddUnit(rsiMilliVolt);
      AddUnit(rsiMilliVoltPerMilliAmp);
      AddUnit(rsiOhm);
    end
    else
    begin
      AddUnit(rsiRatio);
      AddUnit(rsiMilliVoltPerVolt);
      AddUnit(rsiVolt);
      AddUnit(rsiMilliVolt);
    end;
    if cbInputUnit.ItemIndex < 0 then
      cbInputUnit.ItemIndex := 0;
  finally
    cbInputUnit.Items.EndUpdate;
  end;
end;

procedure TRecorderStrainCalibrationFrame.cbExcitationKindChange(Sender: TObject);
var
  lSelected: TRecorderStrainInputUnit;
begin
  lSelected := SelectedInputUnit;
  if cbExcitationKind.ItemIndex = Ord(rsekCurrent) then
    lblExcitation.Caption := 'Ток питания, мА'
  else
    lblExcitation.Caption := 'Напряжение, В';
  PopulateInputUnits(lSelected);
end;

function TRecorderStrainCalibrationFrame.ReadValue(AEdit: TEdit;
  out AValue: Double): Boolean;
var
  lText: string;
begin
  lText := StringReplace(Trim(AEdit.Text), '.',
    DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := TryStrToFloat(lText, AValue) and not IsNan(AValue) and
    not IsInfinite(AValue);
  if not Result then
  begin
    AEdit.SetFocus;
    lblError.Caption := 'Введите корректное числовое значение.';
  end;
end;

procedure TRecorderStrainCalibrationFrame.LoadCalibration(
  ACalibration: TRecorderCalibration);
var
  C: TRecorderStrainConfig;
begin
  if ACalibration = nil then
    Exit;
  C := TRecorderStrainConfig.Create;
  try
    C.Load(ACalibration.ModuleData);
    edName.Text := ACalibration.Name;
    cbScheme.ItemIndex := Ord(C.Scheme);
    cbOutputUnit.ItemIndex := Ord(C.OutputUnit);
    cbExcitationKind.ItemIndex := Ord(C.ExcitationKind);
    cbExcitationKindChange(cbExcitationKind);
    PopulateInputUnits(C.InputUnit);
    edExcitation.Text := FloatToStr(C.ExcitationValue);
    edGaugeFactor.Text := FloatToStr(C.GaugeFactor);
    edPoisson.Text := FloatToStr(C.Poisson);
    edYoung.Text := FloatToStr(C.YoungMPa);
    edResistance.Text := FloatToStr(C.NominalResistanceOhm);
    edDeltaT.Text := FloatToStr(C.TemperatureDeltaC);
    edTcr.Text := FloatToStr(C.GaugeTcr);
    edExpansion.Text := FloatToStr(C.MaterialExpansion);
    edMaxStrain.Text := FloatToStr(C.MaxMicrostrain);
    lblCoefficients.Caption := Format('y = %.8g + %.8g·x',
      [ACalibration.Offset, ACalibration.K1]);
    lblError.Caption := '';
  finally
    C.Free;
  end;
end;

function TRecorderStrainCalibrationFrame.TryApply(
  ACalibration: TRecorderCalibration; out AError: string): Boolean;
var
  C: TRecorderStrainConfig;
  lDraft: TRecorderCalibration;
  lEstimate: Double;
begin
  Result := False;
  AError := '';
  if ACalibration = nil then
    Exit;
  C := TRecorderStrainConfig.Create;
  lDraft := ACalibration.Clone;
  try
    C.Scheme := TRecorderStrainScheme(Max(0, cbScheme.ItemIndex));
    C.InputUnit := SelectedInputUnit;
    C.OutputUnit := TRecorderStrainOutputUnit(Max(0, cbOutputUnit.ItemIndex));
    C.ExcitationKind := TRecorderStrainExcitationKind(
      Max(0, cbExcitationKind.ItemIndex));
    if not ReadValue(edExcitation, C.ExcitationValue) or
      not ReadValue(edGaugeFactor, C.GaugeFactor) or
      not ReadValue(edPoisson, C.Poisson) or
      not ReadValue(edYoung, C.YoungMPa) or
      not ReadValue(edResistance, C.NominalResistanceOhm) or
      not ReadValue(edDeltaT, C.TemperatureDeltaC) or
      not ReadValue(edTcr, C.GaugeTcr) or
      not ReadValue(edExpansion, C.MaterialExpansion) or
      not ReadValue(edMaxStrain, C.MaxMicrostrain) then
    begin
      AError := lblError.Caption;
      Exit;
    end;
    if not RecorderStrainBuildCalibration(C, lDraft, lEstimate, AError) then
    begin
      lblError.Caption := AError;
      Exit;
    end;
    lDraft.Name := Trim(edName.Text);
    if lDraft.Name = '' then
      lDraft.Name := 'Тензо ГХ';
    if Trim(lDraft.Description) = '' then
      lDraft.Description := 'Встроенный тензокалькулятор RecorderLnx';
    ACalibration.Assign(lDraft);
    lblCoefficients.Caption := Format('y = %.8g + %.8g·x',
      [lDraft.Offset, lDraft.K1]);
    lblError.Caption := Format('Максимальная ошибка: %.5f%%', [lEstimate * 100]);
    Result := True;
  finally
    lDraft.Free;
    C.Free;
  end;
end;

end.
