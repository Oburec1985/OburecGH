unit uRecorderUnitManager;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs;

const
  RECORDER_QUANTITY_VOLTAGE = 'voltage';
  RECORDER_QUANTITY_ACCELERATION = 'acceleration';
  RECORDER_QUANTITY_VELOCITY = 'velocity';
  RECORDER_QUANTITY_DISPLACEMENT = 'displacement';
  RECORDER_QUANTITY_FORCE = 'force';
  RECORDER_QUANTITY_FREQUENCY = 'frequency';
  RECORDER_QUANTITY_ELECTRIC_CHARGE = 'electric_charge';
  RECORDER_QUANTITY_RAW_CODE = 'raw_code';

type
  ERecorderUnitError = class(Exception);

  TRecorderUnitInfo = record
    QuantityId: string;
    Name: string;
    BaseUnitName: string;
    ScaleToBase: Double;
  end;

  { TRecorderUnitManager

    ScaleToBase converts one unit to its quantity's base unit:
      baseValue := sourceValue * ScaleToBase.

    ConversionFactor(AFrom, ATo) returns a multiplier in the requested
    direction:
      targetValue := sourceValue * ConversionFactor(AFrom, ATo).

    Register quantities and units during application/plugin initialization;
    subsequent lookup and conversion calls do not modify the registry. }
  TRecorderUnitManager = class
  private type
    TUnitDefinition = class
      QuantityId: string;
      Name: string;
      BaseUnitName: string;
      ScaleToBase: Double;
    end;
  private
    fAliases: TStringList;
    fDefinitions: TObjectList;
    function NormalizeUnitName(const AName: string): string;
    function FindDefinition(const AUnitName: string): TUnitDefinition;
    procedure FillUnitInfo(ADefinition: TUnitDefinition;
      out AInfo: TRecorderUnitInfo);
    procedure RegisterDefinition(const AQuantityId, AUnitName: string;
      AScaleToBase: Double; const AAliases: array of string;
      AIsBaseUnit: Boolean);
    procedure RegisterDefaults;
  public
    constructor Create(ARegisterDefaults: Boolean = True);
    destructor Destroy; override;

    procedure RegisterQuantity(const AQuantityId, ABaseUnitName: string;
      const ABaseAliases: array of string);
    procedure RegisterUnit(const AQuantityId, AUnitName: string;
      AScaleToBase: Double; const AAliases: array of string);

    procedure FillUnitNames(AItems: TStrings; const ASubstring: string = '');
    function TryGetUnitInfo(const AUnitName: string;
      out AInfo: TRecorderUnitInfo): Boolean;
    function QuantityCaption(const AQuantityId: string): string;
    function AreCompatible(const AFirstUnit, ASecondUnit: string): Boolean;
    function TryGetConversionFactor(const AFromUnit, AToUnit: string;
      out AFactor: Double): Boolean;
    function ConversionFactor(const AFromUnit, AToUnit: string): Double;
    function TryConvert(const AValue: Double; const AFromUnit, AToUnit: string;
      out AResult: Double): Boolean;
    function Convert(const AValue: Double; const AFromUnit,
      AToUnit: string): Double;
  end;

function RecorderUnitManager: TRecorderUnitManager;

implementation

var
  g_RecorderUnitManager: TRecorderUnitManager = nil;

function TRecorderUnitManager.NormalizeUnitName(const AName: string): string;
begin
  Result := LowerCase(Trim(AName));
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
  Result := StringReplace(Result, #$C2#$B5, 'u', [rfReplaceAll]); // micro sign
  Result := StringReplace(Result, #$CE#$BC, 'u', [rfReplaceAll]); // Greek mu
  Result := StringReplace(Result, '^2', '2', [rfReplaceAll]);
  Result := StringReplace(Result, '²', '2', [rfReplaceAll]);
end;

function TRecorderUnitManager.FindDefinition(
  const AUnitName: string): TUnitDefinition;
var
  lIndex: Integer;
begin
  lIndex := fAliases.IndexOf(NormalizeUnitName(AUnitName));
  if lIndex < 0 then
    Exit(nil);
  Result := TUnitDefinition(fAliases.Objects[lIndex]);
end;

procedure TRecorderUnitManager.FillUnitInfo(ADefinition: TUnitDefinition;
  out AInfo: TRecorderUnitInfo);
begin
  AInfo.QuantityId := ADefinition.QuantityId;
  AInfo.Name := ADefinition.Name;
  AInfo.BaseUnitName := ADefinition.BaseUnitName;
  AInfo.ScaleToBase := ADefinition.ScaleToBase;
end;

constructor TRecorderUnitManager.Create(ARegisterDefaults: Boolean);
begin
  inherited Create;
  fAliases := TStringList.Create;
  fAliases.CaseSensitive := True;
  fAliases.Sorted := True;
  fAliases.Duplicates := dupError;
  fDefinitions := TObjectList.Create(True);
  if ARegisterDefaults then
    RegisterDefaults;
end;

destructor TRecorderUnitManager.Destroy;
begin
  FreeAndNil(fAliases);
  FreeAndNil(fDefinitions);
  inherited Destroy;
end;

procedure TRecorderUnitManager.RegisterQuantity(const AQuantityId,
  ABaseUnitName: string; const ABaseAliases: array of string);
begin
  RegisterDefinition(AQuantityId, ABaseUnitName, 1.0, ABaseAliases, True);
end;

procedure TRecorderUnitManager.RegisterUnit(const AQuantityId,
  AUnitName: string; AScaleToBase: Double; const AAliases: array of string);
begin
  RegisterDefinition(AQuantityId, AUnitName, AScaleToBase, AAliases, False);
end;

procedure TRecorderUnitManager.RegisterDefinition(const AQuantityId,
  AUnitName: string; AScaleToBase: Double; const AAliases: array of string;
  AIsBaseUnit: Boolean);
var
  lAliases: TStringList;
  lDefinition: TUnitDefinition;
  lBaseDefinition: TUnitDefinition;
  lAlias: string;
  lIndex: Integer;
begin
  if Trim(AQuantityId) = '' then
    raise ERecorderUnitError.Create('Quantity identifier must not be empty');
  if Trim(AUnitName) = '' then
    raise ERecorderUnitError.Create('Unit name must not be empty');
  if AScaleToBase <= 0 then
    raise ERecorderUnitError.Create('Unit scale to base must be positive');

  lBaseDefinition := nil;
  for lIndex := 0 to fDefinitions.Count - 1 do
    if SameText(TUnitDefinition(fDefinitions[lIndex]).QuantityId, AQuantityId) then
    begin
      lBaseDefinition := TUnitDefinition(fDefinitions[lIndex]);
      Break;
    end;
  if (not AIsBaseUnit) and (lBaseDefinition = nil) then
    raise ERecorderUnitError.CreateFmt(
      'Base unit for quantity "%s" must be registered first', [AQuantityId]);
  if AIsBaseUnit and (lBaseDefinition <> nil) then
    raise ERecorderUnitError.CreateFmt(
      'Base unit for quantity "%s" is already registered', [AQuantityId]);

  lAliases := TStringList.Create;
  try
    lAliases.Sorted := True;
    lAliases.Duplicates := dupIgnore;
    lAlias := NormalizeUnitName(AUnitName);
    lAliases.Add(lAlias);
    for lIndex := Low(AAliases) to High(AAliases) do
      lAliases.Add(NormalizeUnitName(AAliases[lIndex]));
    for lIndex := 0 to lAliases.Count - 1 do
    begin
      if lAliases[lIndex] = '' then
        raise ERecorderUnitError.Create('Unit alias must not be empty');
      if fAliases.IndexOf(lAliases[lIndex]) >= 0 then
        raise ERecorderUnitError.CreateFmt(
          'Unit alias "%s" is already registered', [lAliases[lIndex]]);
    end;

    lDefinition := TUnitDefinition.Create;
    lDefinition.QuantityId := LowerCase(Trim(AQuantityId));
    lDefinition.Name := Trim(AUnitName);
    if AIsBaseUnit then
      lDefinition.BaseUnitName := lDefinition.Name
    else
      lDefinition.BaseUnitName := lBaseDefinition.Name;
    lDefinition.ScaleToBase := AScaleToBase;
    for lIndex := 0 to lAliases.Count - 1 do
      fAliases.AddObject(lAliases[lIndex], lDefinition);
    fDefinitions.Add(lDefinition);
  finally
    lAliases.Free;
  end;
end;

procedure TRecorderUnitManager.FillUnitNames(AItems: TStrings;
  const ASubstring: string);
var
  I, J: Integer;
  lDefinition: TUnitDefinition;
  lFilter: string;
  lMatches: Boolean;
begin
  if AItems = nil then
    Exit;
  lFilter := NormalizeUnitName(ASubstring);
  AItems.BeginUpdate;
  try
    AItems.Clear;
    for I := 0 to fDefinitions.Count - 1 do
    begin
      lDefinition := TUnitDefinition(fDefinitions[I]);
      lMatches := (lFilter = '') or
        (Pos(lFilter, NormalizeUnitName(lDefinition.Name)) > 0);
      if not lMatches then
        for J := 0 to fAliases.Count - 1 do
          if (fAliases.Objects[J] = lDefinition) and
            (Pos(lFilter, fAliases[J]) > 0) then
          begin
            lMatches := True;
            Break;
          end;
      if lMatches then
        AItems.Add(lDefinition.Name);
    end;
  finally
    AItems.EndUpdate;
  end;
end;

function TRecorderUnitManager.TryGetUnitInfo(const AUnitName: string;
  out AInfo: TRecorderUnitInfo): Boolean;
var
  lDefinition: TUnitDefinition;
begin
  lDefinition := FindDefinition(AUnitName);
  Result := Assigned(lDefinition);
  if Result then
    FillUnitInfo(lDefinition, AInfo)
  else
  begin
    AInfo.QuantityId := '';
    AInfo.Name := '';
    AInfo.BaseUnitName := '';
    AInfo.ScaleToBase := 0.0;
  end;
end;

function TRecorderUnitManager.QuantityCaption(const AQuantityId: string): string;
begin
  if SameText(AQuantityId, RECORDER_QUANTITY_VOLTAGE) then
    Result := 'напряжение'
  else if SameText(AQuantityId, RECORDER_QUANTITY_ACCELERATION) then
    Result := 'ускорение'
  else if SameText(AQuantityId, RECORDER_QUANTITY_VELOCITY) then
    Result := 'скорость'
  else if SameText(AQuantityId, RECORDER_QUANTITY_DISPLACEMENT) then
    Result := 'перемещение'
  else if SameText(AQuantityId, RECORDER_QUANTITY_FORCE) then
    Result := 'сила'
  else if SameText(AQuantityId, RECORDER_QUANTITY_FREQUENCY) then
    Result := 'частота'
  else if SameText(AQuantityId, RECORDER_QUANTITY_ELECTRIC_CHARGE) then
    Result := 'электрический заряд'
  else
    Result := AQuantityId;
end;

function TRecorderUnitManager.AreCompatible(const AFirstUnit,
  ASecondUnit: string): Boolean;
var
  lFirst: TUnitDefinition;
  lSecond: TUnitDefinition;
begin
  lFirst := FindDefinition(AFirstUnit);
  lSecond := FindDefinition(ASecondUnit);
  Result := Assigned(lFirst) and Assigned(lSecond) and
    SameText(lFirst.QuantityId, lSecond.QuantityId);
end;

function TRecorderUnitManager.TryGetConversionFactor(const AFromUnit,
  AToUnit: string; out AFactor: Double): Boolean;
var
  lFrom: TUnitDefinition;
  lTo: TUnitDefinition;
begin
  lFrom := FindDefinition(AFromUnit);
  lTo := FindDefinition(AToUnit);
  Result := Assigned(lFrom) and Assigned(lTo) and
    SameText(lFrom.QuantityId, lTo.QuantityId);
  if Result then
    AFactor := lFrom.ScaleToBase / lTo.ScaleToBase
  else
    AFactor := 0.0;
end;

function TRecorderUnitManager.ConversionFactor(const AFromUnit,
  AToUnit: string): Double;
begin
  if not TryGetConversionFactor(AFromUnit, AToUnit, Result) then
    raise ERecorderUnitError.CreateFmt('Cannot convert "%s" to "%s"',
      [AFromUnit, AToUnit]);
end;

function TRecorderUnitManager.TryConvert(const AValue: Double;
  const AFromUnit, AToUnit: string; out AResult: Double): Boolean;
var
  lFactor: Double;
begin
  Result := TryGetConversionFactor(AFromUnit, AToUnit, lFactor);
  if Result then
    AResult := AValue * lFactor
  else
    AResult := 0.0;
end;

function TRecorderUnitManager.Convert(const AValue: Double;
  const AFromUnit, AToUnit: string): Double;
begin
  Result := AValue * ConversionFactor(AFromUnit, AToUnit);
end;

procedure TRecorderUnitManager.RegisterDefaults;
begin
  { Драйверы исторически публиковали code/codes/код. Это одна безразмерная
    исходная величина, поэтому все варианты должны давать единичный переход. }
  RegisterQuantity(RECORDER_QUANTITY_RAW_CODE, 'code', ['codes', 'код', 'коды']);

  RegisterQuantity(RECORDER_QUANTITY_VOLTAGE, 'V', ['В', 'volt', 'volts']);
  RegisterUnit(RECORDER_QUANTITY_VOLTAGE, 'mV', 1E-3, ['мВ']);
  RegisterUnit(RECORDER_QUANTITY_VOLTAGE, 'uV', 1E-6, ['мкВ', 'µV', 'μV']);
  RegisterUnit(RECORDER_QUANTITY_VOLTAGE, 'kV', 1E3, ['кВ']);

  RegisterQuantity(RECORDER_QUANTITY_ACCELERATION, 'm/s2',
    ['m/s^2', 'm/s²', 'м/с2', 'м/с^2', 'м/с²']);
  RegisterUnit(RECORDER_QUANTITY_ACCELERATION, 'mm/s2', 1E-3,
    ['mm/s^2', 'mm/s²', 'мм/с2', 'мм/с^2', 'мм/с²']);
  RegisterUnit(RECORDER_QUANTITY_ACCELERATION, 'g', 9.80665,
    ['G', 'же']);

  RegisterQuantity(RECORDER_QUANTITY_VELOCITY, 'm/s', ['м/с']);
  RegisterUnit(RECORDER_QUANTITY_VELOCITY, 'mm/s', 1E-3, ['мм/с']);
  RegisterUnit(RECORDER_QUANTITY_VELOCITY, 'um/s', 1E-6,
    ['мкм/с', 'µm/s', 'μm/s']);

  RegisterQuantity(RECORDER_QUANTITY_DISPLACEMENT, 'm',
    ['м', 'meter', 'metre']);
  RegisterUnit(RECORDER_QUANTITY_DISPLACEMENT, 'cm', 1E-2, ['см']);
  RegisterUnit(RECORDER_QUANTITY_DISPLACEMENT, 'mm', 1E-3, ['мм']);
  RegisterUnit(RECORDER_QUANTITY_DISPLACEMENT, 'um', 1E-6,
    ['мкм', 'µm', 'μm', 'micron']);
  RegisterUnit(RECORDER_QUANTITY_DISPLACEMENT, 'nm', 1E-9, ['нм']);

  RegisterQuantity(RECORDER_QUANTITY_FORCE, 'N', ['Н', 'newton']);
  RegisterUnit(RECORDER_QUANTITY_FORCE, 'kN', 1E3, ['кН']);

  RegisterQuantity(RECORDER_QUANTITY_FREQUENCY, 'Hz', ['Гц', 'hertz']);
  RegisterUnit(RECORDER_QUANTITY_FREQUENCY, 'kHz', 1E3, ['кГц']);

  RegisterQuantity(RECORDER_QUANTITY_ELECTRIC_CHARGE, 'C',
    ['Кл', 'coulomb']);
  RegisterUnit(RECORDER_QUANTITY_ELECTRIC_CHARGE, 'mC', 1E-3, ['мКл']);
  RegisterUnit(RECORDER_QUANTITY_ELECTRIC_CHARGE, 'uC', 1E-6,
    ['мкКл', 'µC', 'μC']);
  RegisterUnit(RECORDER_QUANTITY_ELECTRIC_CHARGE, 'nC', 1E-9, ['нКл']);
  RegisterUnit(RECORDER_QUANTITY_ELECTRIC_CHARGE, 'pC', 1E-12, ['пКл']);
end;

function RecorderUnitManager: TRecorderUnitManager;
begin
  if not Assigned(g_RecorderUnitManager) then
    g_RecorderUnitManager := TRecorderUnitManager.Create;
  Result := g_RecorderUnitManager;
end;

finalization
  FreeAndNil(g_RecorderUnitManager);

end.
