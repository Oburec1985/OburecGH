unit uRecorderStrainCalibration;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, uRecorderTags;

type
  TRecorderStrainScheme = (rssQuarterActive, rssHalfPoisson,
    rssHalfOpposed, rssFullOneActive, rssFullTwoOpposed,
    rssFullPoisson, rssFullFourActive);
  TRecorderStrainInputUnit = (rsiRatio, rsiMilliVoltPerVolt,
    rsiVolt, rsiMilliVolt, rsiMilliVoltPerMilliAmp, rsiOhm);
  TRecorderStrainOutputUnit = (rsoStrain, rsoMicrostrain,
    rsoPascal, rsoMegaPascal, rsoMilliVolt);
  TRecorderStrainExcitationKind = (rsekVoltage, rsekCurrent);

  TRecorderStrainConfig = class
  public
    Scheme: TRecorderStrainScheme;
    InputUnit: TRecorderStrainInputUnit;
    OutputUnit: TRecorderStrainOutputUnit;
    ExcitationKind: TRecorderStrainExcitationKind;
    ExcitationValue: Double;
    GaugeFactor: Double;
    Poisson: Double;
    YoungMPa: Double;
    NominalResistanceOhm: Double;
    TemperatureDeltaC: Double;
    GaugeTcr: Double;
    MaterialExpansion: Double;
    MaxMicrostrain: Double;
    constructor Create;
    procedure Load(const AText: string);
    function Save: string;
  end;

function RecorderStrainBuildCalibration(AConfig: TRecorderStrainConfig;
  ACalibration: TRecorderCalibration; out AMaxRelativeError: Double;
  out AError: string): Boolean;
function RecorderStrainSchemeName(AValue: TRecorderStrainScheme): string;
function RecorderStrainInputUnitName(AValue: TRecorderStrainInputUnit): string;
function RecorderStrainOutputUnitName(AValue: TRecorderStrainOutputUnit): string;
function RecorderStrainExcitationKindName(
  AValue: TRecorderStrainExcitationKind): string;

implementation

constructor TRecorderStrainConfig.Create;
begin
  Scheme := rssQuarterActive;
  InputUnit := rsiMilliVoltPerVolt;
  OutputUnit := rsoMicrostrain;
  ExcitationKind := rsekVoltage;
  ExcitationValue := 5.0;
  GaugeFactor := 2.0;
  Poisson := 0.3;
  YoungMPa := 2.0E5;
  NominalResistanceOhm := 120.0;
  TemperatureDeltaC := 0.0;
  GaugeTcr := 0.0;
  MaterialExpansion := 0.0;
  MaxMicrostrain := 10000.0;
end;

procedure TRecorderStrainConfig.Load(const AText: string);
var L: TStringList;
begin
  L := TStringList.Create;
  try
    L.Text := StringReplace(AText, ';', LineEnding, [rfReplaceAll]);
    Scheme := TRecorderStrainScheme(StrToIntDef(L.Values['scheme'], Ord(Scheme)));
    InputUnit := TRecorderStrainInputUnit(StrToIntDef(L.Values['input'], Ord(InputUnit)));
    OutputUnit := TRecorderStrainOutputUnit(StrToIntDef(L.Values['output'], Ord(OutputUnit)));
    ExcitationKind := TRecorderStrainExcitationKind(StrToIntDef(
      L.Values['excitationKind'], Ord(ExcitationKind)));
    ExcitationValue := StrToFloatDef(L.Values['excitation'], ExcitationValue);
    GaugeFactor := StrToFloatDef(L.Values['gaugeFactor'], GaugeFactor);
    Poisson := StrToFloatDef(L.Values['poisson'], Poisson);
    if L.Values['youngMPa'] <> '' then
      YoungMPa := StrToFloatDef(L.Values['youngMPa'], YoungMPa)
    else if L.Values['youngPa'] <> '' then
      YoungMPa := StrToFloatDef(L.Values['youngPa'], YoungMPa * 1E6) / 1E6;
    NominalResistanceOhm := StrToFloatDef(L.Values['resistance'], NominalResistanceOhm);
    TemperatureDeltaC := StrToFloatDef(L.Values['deltaT'], TemperatureDeltaC);
    GaugeTcr := StrToFloatDef(L.Values['tcr'], GaugeTcr);
    MaterialExpansion := StrToFloatDef(L.Values['expansion'], MaterialExpansion);
    MaxMicrostrain := StrToFloatDef(L.Values['maxMicrostrain'], MaxMicrostrain);
  finally L.Free; end;
end;

function TRecorderStrainConfig.Save: string;
var L: TStringList;
begin
  L := TStringList.Create;
  try
    L.Values['scheme'] := IntToStr(Ord(Scheme));
    L.Values['input'] := IntToStr(Ord(InputUnit));
    L.Values['output'] := IntToStr(Ord(OutputUnit));
    L.Values['excitationKind'] := IntToStr(Ord(ExcitationKind));
    L.Values['excitation'] := FloatToStr(ExcitationValue);
    L.Values['gaugeFactor'] := FloatToStr(GaugeFactor);
    L.Values['poisson'] := FloatToStr(Poisson);
    L.Values['youngMPa'] := FloatToStr(YoungMPa);
    L.Values['resistance'] := FloatToStr(NominalResistanceOhm);
    L.Values['deltaT'] := FloatToStr(TemperatureDeltaC);
    L.Values['tcr'] := FloatToStr(GaugeTcr);
    L.Values['expansion'] := FloatToStr(MaterialExpansion);
    L.Values['maxMicrostrain'] := FloatToStr(MaxMicrostrain);
    Result := StringReplace(Trim(L.Text), LineEnding, ';', [rfReplaceAll]);
  finally L.Free; end;
end;

function RecorderStrainSchemeName(AValue: TRecorderStrainScheme): string;
const N: array[TRecorderStrainScheme] of string = ('1/4 моста: 1 активный',
  'Полумост: продольный + поперечный', 'Полумост: 2 продольных противофазно',
  'Мост: 1 активный', 'Мост: 2 продольных противофазно',
  'Мост: 2 продольных + 2 поперечных', 'Полный мост: 4 продольных');
begin Result := N[AValue]; end;

function RecorderStrainInputUnitName(AValue: TRecorderStrainInputUnit): string;
const N: array[TRecorderStrainInputUnit] of string =
  ('dU/U', 'мВ/В', 'В', 'мВ', 'мВ/мА', 'Ом');
begin Result := N[AValue]; end;

function RecorderStrainOutputUnitName(AValue: TRecorderStrainOutputUnit): string;
const N: array[TRecorderStrainOutputUnit] of string = ('strain', 'мкстр', 'Па', 'МПа', 'мВ');
begin Result := N[AValue]; end;

function RecorderStrainExcitationKindName(
  AValue: TRecorderStrainExcitationKind): string;
const N: array[TRecorderStrainExcitationKind] of string =
  ('Напряжение', 'Ток');
begin Result := N[AValue]; end;

procedure ShoulderDeltas(AScheme: TRecorderStrainScheme; AM, ANu, AT: Double;
  out D1, D2, D3, D4: Double);
begin
  D1 := 0; D2 := 0; D3 := 0; D4 := 0;
  case AScheme of
    rssQuarterActive, rssFullOneActive: D1 := AM + AT;
    rssHalfPoisson: begin D1 := AM + AT; D2 := -ANu * AM + AT; end;
    rssHalfOpposed: begin D1 := AM + AT; D2 := -AM + AT; end;
    rssFullTwoOpposed: begin D1 := AM + AT; D3 := -AM + AT; end;
    rssFullPoisson: begin D1 := AM + AT; D2 := -ANu*AM + AT;
      D3 := -AM + AT; D4 := ANu*AM + AT; end;
    rssFullFourActive: begin D1 := AM + AT; D2 := -AM + AT;
      D3 := -AM + AT; D4 := AM + AT; end;
  end;
end;

function BridgeRatio(C: TRecorderStrainConfig; AM: Double): Double;
var D1,D2,D3,D4,T: Double;
begin
  T := (C.GaugeTcr + C.GaugeFactor * C.MaterialExpansion) * C.TemperatureDeltaC;
  ShoulderDeltas(C.Scheme, AM, C.Poisson, T, D1,D2,D3,D4);
  Result := (1+D4)/(2+D3+D4) - (1+D2)/(2+D1+D2);
end;

function BridgeEquivalentResistance(C: TRecorderStrainConfig;
  AM: Double): Double;
var D1,D2,D3,D4,T,B12,B34: Double;
begin
  T := (C.GaugeTcr + C.GaugeFactor * C.MaterialExpansion) * C.TemperatureDeltaC;
  ShoulderDeltas(C.Scheme, AM, C.Poisson, T, D1,D2,D3,D4);
  B12 := C.NominalResistanceOhm * (2 + D1 + D2);
  B34 := C.NominalResistanceOhm * (2 + D3 + D4);
  if SameValue(B12 + B34, 0.0) then
    Result := 0.0
  else
    Result := B12 * B34 / (B12 + B34);
end;

function BridgeSupplyVoltage(C: TRecorderStrainConfig; AM: Double): Double;
begin
  if C.ExcitationKind = rsekCurrent then
    Result := (C.ExcitationValue / 1000.0) * BridgeEquivalentResistance(C, AM)
  else
    Result := C.ExcitationValue;
end;

function BridgeOutputVoltage(C: TRecorderStrainConfig; AM: Double): Double;
begin
  Result := BridgeRatio(C, AM) * BridgeSupplyVoltage(C, AM);
end;

function RawInput(C: TRecorderStrainConfig; AM: Double): Double;
var R: Double;
begin
  R := BridgeRatio(C, AM);
  case C.InputUnit of
    rsiRatio: Result := R;
    rsiMilliVoltPerVolt: Result := R * 1000;
    rsiVolt: Result := BridgeOutputVoltage(C, AM);
    rsiMilliVolt: Result := BridgeOutputVoltage(C, AM) * 1000;
    rsiMilliVoltPerMilliAmp, rsiOhm:
      Result := R * BridgeEquivalentResistance(C, AM);
  end;
end;

function OutputValue(C: TRecorderStrainConfig; AEpsilon, AM: Double): Double;
begin
  case C.OutputUnit of
    rsoStrain: Result := AEpsilon;
    rsoMicrostrain: Result := AEpsilon * 1E6;
    rsoPascal: Result := C.YoungMPa * 1E6 * AEpsilon;
    rsoMegaPascal: Result := C.YoungMPa * AEpsilon;
  else Result := BridgeOutputVoltage(C, AM) * 1000;
  end;
end;

function RecorderStrainBuildCalibration(AConfig: TRecorderStrainConfig;
  ACalibration: TRecorderCalibration; out AMaxRelativeError: Double;
  out AError: string): Boolean;
var X0,X1,X2,Y0,Y1,Y2,E,M,AM,Y,P,Scale: Double; I: Integer;
begin
  Result := False; AError := ''; AMaxRelativeError := 0;
  if (AConfig = nil) or (ACalibration = nil) then Exit;
  if AConfig.GaugeFactor <= 0 then begin AError := 'Коэффициент тензочувствительности должен быть больше нуля'; Exit; end;
  if (AConfig.ExcitationValue <= 0) and
    ((AConfig.InputUnit in [rsiVolt, rsiMilliVolt]) or
     (AConfig.OutputUnit = rsoMilliVolt)) then
  begin
    if AConfig.ExcitationKind = rsekCurrent then
      AError := 'Ток питания в мА должен быть больше нуля'
    else
      AError := 'Напряжение питания должно быть больше нуля';
    Exit;
  end;
  if (AConfig.ExcitationKind = rsekCurrent) and
    (AConfig.NominalResistanceOhm <= 0) then
  begin
    AError := 'Для питания током сопротивление R0 должно быть больше нуля';
    Exit;
  end;
  E := AConfig.MaxMicrostrain * 1E-6;
  if E <= 0 then begin AError := 'Рабочий диапазон деформации должен быть больше нуля'; Exit; end;
  X0 := RawInput(AConfig, -AConfig.GaugeFactor*E);
  X1 := RawInput(AConfig, 0);
  X2 := RawInput(AConfig, AConfig.GaugeFactor*E);
  Y0 := OutputValue(AConfig, -E, -AConfig.GaugeFactor*E);
  Y1 := OutputValue(AConfig, 0, 0);
  Y2 := OutputValue(AConfig, E, AConfig.GaugeFactor*E);
  if SameValue(X0,X1) or SameValue(X1,X2) or SameValue(X0,X2) then begin AError := 'Схема не имеет чувствительности на выбранном диапазоне'; Exit; end;
  ACalibration.K2 := ((Y2-Y0)/(X2-X0) - (Y1-Y0)/(X1-X0))/(X2-X1);
  ACalibration.K1 := (Y1-Y0)/(X1-X0) - ACalibration.K2*(X0+X1);
  ACalibration.Offset := Y0 - ACalibration.K1*X0 - ACalibration.K2*Sqr(X0);
  Scale := Max(Max(Abs(Y0), Abs(Y2)), 1E-30);
  for I := 0 to 200 do begin
    E := AConfig.MaxMicrostrain*1E-6*(-1 + I/100.0);
    AM := AConfig.GaugeFactor*E;
    M := RawInput(AConfig, AM); Y := OutputValue(AConfig,E,AM);
    P := ACalibration.Offset + ACalibration.K1*M + ACalibration.K2*Sqr(M);
    AMaxRelativeError := Max(AMaxRelativeError, Abs(P-Y)/Scale);
  end;
  if AMaxRelativeError > 0.001 then begin AError := Format('Ошибка полинома %.4f%% превышает 0,1%%. Уменьшите рабочий диапазон.', [AMaxRelativeError*100]); Exit; end;
  ACalibration.Kind := rckStrain;
  ACalibration.UnitIn := RecorderStrainInputUnitName(AConfig.InputUnit);
  ACalibration.UnitOut := RecorderStrainOutputUnitName(AConfig.OutputUnit);
  ACalibration.ModuleData := AConfig.Save;
  Result := True;
end;

end.
