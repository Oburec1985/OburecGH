unit uRecorderStrainCalibrationDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Math,
  uRecorderTags, uRecorderStrainCalibration;

type
  TRecorderStrainCalibrationDialog = class(TForm)
    btnCancel, btnOk: TButton;
    cbExcitationKind, cbInputUnit, cbOutputUnit, cbScheme: TComboBox;
    edDeltaT, edExcitation, edExpansion, edGaugeFactor, edMaxStrain,
      edName, edPoisson, edResistance, edTcr, edYoung: TEdit;
    lblCoefficients, lblError, lblExcitation: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure cbExcitationKindChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fCalibration: TRecorderCalibration;
    function SelectedInputUnit: TRecorderStrainInputUnit;
    function ReadValue(AEdit: TEdit; out AValue: Double): Boolean;
    procedure PopulateInputUnits(ASelected: TRecorderStrainInputUnit);
    procedure LoadCalibration;
  public
    procedure EditCalibration(ACalibration: TRecorderCalibration);
  end;

function ShowRecorderStrainCalibrationDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration): Boolean;

implementation

{$R *.lfm}

procedure TRecorderStrainCalibrationDialog.FormCreate(Sender: TObject);
var S: TRecorderStrainScheme;
  O: TRecorderStrainOutputUnit; K: TRecorderStrainExcitationKind;
begin
  for S := Low(S) to High(S) do cbScheme.Items.Add(RecorderStrainSchemeName(S));
  for O := Low(O) to High(O) do cbOutputUnit.Items.Add(RecorderStrainOutputUnitName(O));
  for K := Low(K) to High(K) do
    cbExcitationKind.Items.Add(RecorderStrainExcitationKindName(K));
end;

procedure TRecorderStrainCalibrationDialog.cbExcitationKindChange(Sender: TObject);
var LSelected: TRecorderStrainInputUnit;
begin
  LSelected := SelectedInputUnit;
  if cbExcitationKind.ItemIndex = Ord(rsekCurrent) then
    lblExcitation.Caption := 'Ток питания, мА'
  else
    lblExcitation.Caption := 'Напряжение, В';
  PopulateInputUnits(LSelected);
end;

function TRecorderStrainCalibrationDialog.SelectedInputUnit:
  TRecorderStrainInputUnit;
begin
  if (cbInputUnit.ItemIndex >= 0) and
    (cbInputUnit.ItemIndex < cbInputUnit.Items.Count) then
    Result := TRecorderStrainInputUnit(PtrInt(
      cbInputUnit.Items.Objects[cbInputUnit.ItemIndex]))
  else
    Result := rsiMilliVolt;
end;

procedure TRecorderStrainCalibrationDialog.PopulateInputUnits(
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
    cbInputUnit.ItemIndex := -1;
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

function TRecorderStrainCalibrationDialog.ReadValue(AEdit: TEdit;
  out AValue: Double): Boolean;
var T: string;
begin
  T := StringReplace(Trim(AEdit.Text), '.', DefaultFormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := TryStrToFloat(T, AValue);
  if not Result then begin AEdit.SetFocus; MessageDlg('Введите числовое значение', mtError, [mbOK], 0); end;
end;

procedure TRecorderStrainCalibrationDialog.EditCalibration(
  ACalibration: TRecorderCalibration);
begin fCalibration := ACalibration; LoadCalibration; end;

procedure TRecorderStrainCalibrationDialog.LoadCalibration;
var C: TRecorderStrainConfig;
begin
  C := TRecorderStrainConfig.Create;
  try
    if fCalibration <> nil then C.Load(fCalibration.ModuleData);
    edName.Text := fCalibration.Name;
    cbScheme.ItemIndex := Ord(C.Scheme);
    cbOutputUnit.ItemIndex := Ord(C.OutputUnit);
    cbExcitationKind.ItemIndex := Ord(C.ExcitationKind);
    cbExcitationKindChange(cbExcitationKind);
    PopulateInputUnits(C.InputUnit);
    edExcitation.Text := FloatToStr(C.ExcitationValue); edGaugeFactor.Text := FloatToStr(C.GaugeFactor);
    edPoisson.Text := FloatToStr(C.Poisson); edYoung.Text := FloatToStr(C.YoungMPa);
    edResistance.Text := FloatToStr(C.NominalResistanceOhm); edDeltaT.Text := FloatToStr(C.TemperatureDeltaC);
    edTcr.Text := FloatToStr(C.GaugeTcr); edExpansion.Text := FloatToStr(C.MaterialExpansion);
    edMaxStrain.Text := FloatToStr(C.MaxMicrostrain);
    lblCoefficients.Caption := Format('y = %.8g + %.8g·x + %.8g·x²', [fCalibration.Offset, fCalibration.K1, fCalibration.K2]);
  finally C.Free; end;
end;

procedure TRecorderStrainCalibrationDialog.btnOkClick(Sender: TObject);
var C: TRecorderStrainConfig; E: Double; S: string;
begin
  C := TRecorderStrainConfig.Create;
  try
    C.Scheme := TRecorderStrainScheme(Max(0, cbScheme.ItemIndex));
    C.InputUnit := SelectedInputUnit;
    C.OutputUnit := TRecorderStrainOutputUnit(Max(0, cbOutputUnit.ItemIndex));
    C.ExcitationKind := TRecorderStrainExcitationKind(Max(0, cbExcitationKind.ItemIndex));
    if not ReadValue(edExcitation,C.ExcitationValue) or not ReadValue(edGaugeFactor,C.GaugeFactor) or
      not ReadValue(edPoisson,C.Poisson) or not ReadValue(edYoung,C.YoungMPa) or
      not ReadValue(edResistance,C.NominalResistanceOhm) or not ReadValue(edDeltaT,C.TemperatureDeltaC) or
      not ReadValue(edTcr,C.GaugeTcr) or not ReadValue(edExpansion,C.MaterialExpansion) or
      not ReadValue(edMaxStrain,C.MaxMicrostrain) then Exit;
    if not RecorderStrainBuildCalibration(C, fCalibration, E, S) then begin lblError.Caption := S; MessageDlg(S, mtError, [mbOK], 0); Exit; end;
    fCalibration.Name := Trim(edName.Text);
    if fCalibration.Name = '' then fCalibration.Name := 'Тензо ГХ';
    fCalibration.Description := 'Встроенный тензокалькулятор RecorderLnx';
    lblError.Caption := Format('Максимальная ошибка: %.5f%%', [E*100]);
    ModalResult := mrOk;
  finally C.Free; end;
end;

function ShowRecorderStrainCalibrationDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration): Boolean;
var D: TRecorderStrainCalibrationDialog;
begin D := TRecorderStrainCalibrationDialog.Create(AOwner); try D.EditCalibration(ACalibration); Result := D.ShowModal=mrOk; finally D.Free; end; end;

end.
