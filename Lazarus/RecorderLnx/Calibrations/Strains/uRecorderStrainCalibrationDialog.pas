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
    fDeviceExcitation: string;
    fPreferredInputUnit: string;
    function SelectedInputUnit: TRecorderStrainInputUnit;
    function TryPreferredInputUnit(out AUnit: TRecorderStrainInputUnit): Boolean;
    function ReadValue(AEdit: TEdit; out AValue: Double): Boolean;
    procedure PopulateInputUnits(ASelected: TRecorderStrainInputUnit);
    procedure ApplyDeviceExcitation(var AConfig: TRecorderStrainConfig);
    procedure LoadCalibration;
  public
    procedure EditCalibration(ACalibration: TRecorderCalibration;
      const ADeviceExcitation: string = ''; const AInputUnit: string = '');
  end;

function ShowRecorderStrainCalibrationDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration; const ADeviceExcitation: string = '';
  const AInputUnit: string = ''): Boolean;

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
  ACalibration: TRecorderCalibration; const ADeviceExcitation: string;
  const AInputUnit: string);
begin
  fCalibration := ACalibration;
  fDeviceExcitation := Trim(ADeviceExcitation);
  fPreferredInputUnit := Trim(AInputUnit);
  LoadCalibration;
end;

function TRecorderStrainCalibrationDialog.TryPreferredInputUnit(
  out AUnit: TRecorderStrainInputUnit): Boolean;
var
  lText: string;
begin
  Result := True;
  lText := LowerCase(Trim(fPreferredInputUnit));
  lText := StringReplace(lText, ' ', '', [rfReplaceAll]);
  if (lText = 'ом') or (lText = 'ohm') then
    AUnit := rsiOhm
  else if (lText = 'мв/ма') or (lText = 'mv/ma') or
    (lText = 'мв/мa') or (lText = 'mv/мa') then
    AUnit := rsiMilliVoltPerMilliAmp
  else if (lText = 'мв') or (lText = 'mv') then
    AUnit := rsiMilliVolt
  else if (lText = 'в') or (lText = 'v') then
    AUnit := rsiVolt
  else if (lText = 'мв/в') or (lText = 'mv/v') then
    AUnit := rsiMilliVoltPerVolt
  else
    Result := False;
end;

function TryParseStrainExcitationText(const AText: string;
  out AKind: TRecorderStrainExcitationKind; out AValue: Double): Boolean;
var
  lClean: string;
  lNumber: string;
  I: Integer;
begin
  lClean := LowerCase(Trim(AText));
  lClean := StringReplace(lClean, ' ', '', [rfReplaceAll]);
  lClean := StringReplace(lClean, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lClean := StringReplace(lClean, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lNumber := '';
  for I := 1 to Length(lClean) do
    if lClean[I] in ['0'..'9', '-', '+', DefaultFormatSettings.DecimalSeparator] then
      lNumber := lNumber + lClean[I]
    else if lNumber <> '' then
      Break;
  Result := TryStrToFloat(lNumber, AValue);
  if not Result then
    Exit;
  if (Pos('ma', lClean) > 0) or (Pos('ма', lClean) > 0) then
    AKind := rsekCurrent
  else if (Pos('a', lClean) > 0) or (Pos('а', lClean) > 0) then
  begin
    AKind := rsekCurrent;
    AValue := AValue * 1000.0;
  end
  else
    AKind := rsekVoltage;
end;

procedure TRecorderStrainCalibrationDialog.ApplyDeviceExcitation(
  var AConfig: TRecorderStrainConfig);
var
  lKind: TRecorderStrainExcitationKind;
  lValue: Double;
begin
  if not TryParseStrainExcitationText(fDeviceExcitation, lKind, lValue) then
    Exit;
  AConfig.ExcitationKind := lKind;
  AConfig.ExcitationValue := lValue;
  if (lKind = rsekCurrent) and
    (AConfig.InputUnit in [rsiRatio, rsiMilliVoltPerVolt, rsiVolt]) then
    AConfig.InputUnit := rsiMilliVoltPerMilliAmp
  else if (lKind = rsekVoltage) and
    (AConfig.InputUnit in [rsiMilliVoltPerMilliAmp, rsiOhm]) then
    AConfig.InputUnit := rsiMilliVoltPerVolt;
end;

procedure TRecorderStrainCalibrationDialog.LoadCalibration;
var
  C: TRecorderStrainConfig;
  lPreferredUnit: TRecorderStrainInputUnit;
begin
  C := TRecorderStrainConfig.Create;
  try
    if fCalibration <> nil then C.Load(fCalibration.ModuleData);
    ApplyDeviceExcitation(C);
    if TryPreferredInputUnit(lPreferredUnit) then
      C.InputUnit := lPreferredUnit;
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
    lblCoefficients.Caption := Format('y = %.8g + %.8g·x',
      [fCalibration.Offset, fCalibration.K1]);
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
  ACalibration: TRecorderCalibration; const ADeviceExcitation: string;
  const AInputUnit: string): Boolean;
var D: TRecorderStrainCalibrationDialog;
begin D := TRecorderStrainCalibrationDialog.Create(AOwner); try D.EditCalibration(ACalibration, ADeviceExcitation, AInputUnit); Result := D.ShowModal=mrOk; finally D.Free; end; end;

end.
