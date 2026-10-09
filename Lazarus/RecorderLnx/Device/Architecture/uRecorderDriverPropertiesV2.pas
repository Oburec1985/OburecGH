unit uRecorderDriverPropertiesV2;

{
  Strict textual adapter over a typed device-property catalog. Parsing and
  validation complete against a candidate snapshot before the live values are
  replaced, so an invalid packet cannot partially change driver configuration.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDriverContractsV2;

type
  TRecorderTransactionalPropertyStore = class(TInterfacedObject,
    IRecorderTransactionalProperties)
  private
    fDescriptors: TRecorderPropertyDescriptorArray;
    fValues: TStringList;
    function FindDescriptor(const AName: string): Integer;
    function ParsePacket(const AText: string; AAllowWildcard: Boolean;
      out AItems: TStringList): TRecorderOperationResult;
    function ValidateValue(const ADescriptor: TRecorderPropertyDescriptor;
      const AValue: string; out ACanonicalValue: string): TRecorderOperationResult;
    procedure ValidateDescriptor(var ADescriptor: TRecorderPropertyDescriptor);
    function ValidateSnapshot(AValues: TStrings): TRecorderOperationResult;
    function BuildCandidate(const AProperties: string; out ACandidate: TStringList):
      TRecorderOperationResult;
    function SerializeValues(AValues: TStrings): string;
  protected
    { Pure calculation hook. It may normalize dependent candidate values but
      must not perform I/O or mutate live driver state. }
    function CalculateCandidate(AValues: TStrings): TRecorderOperationResult; virtual;
    function ValidateCandidate(AValues: TStrings): TRecorderOperationResult; virtual;
    { Called after the immutable snapshot swap. It must be non-throwing and must
      not perform device I/O. If it nevertheless raises, the base rolls the
      snapshot back and reports rocInternal. }
    procedure AfterCommit(const APreviousValues: string); virtual;
  public
    constructor Create(const ADescriptors: array of TRecorderPropertyDescriptor);
    destructor Destroy; override;
    function GetPropertyDescriptors: TRecorderPropertyDescriptorArray;
    function GetProperties(const ARequest: string; out AResponse: string):
      TRecorderOperationResult;
    function CalcProperties(const AProperties: string; out AResponse: string):
      TRecorderOperationResult;
    function SetProperties(const AProperties: string): TRecorderOperationResult;
    function ValueOf(const AName: string): string;
  end;

function RecorderPropertyDescriptor(const AName: string;
  AKind: TRecorderPropertyKind; AAccess: TRecorderPropertyAccess;
  const ADefaultValue: string; AScope: TRecorderPropertyScope = rpsDevice;
  const AUnitName: string = ''; const AMinimumValue: string = '';
  const AMaximumValue: string = ''; const ASinceVersion: string = '1';
  const AAllowedValues: string = ''):
  TRecorderPropertyDescriptor;

implementation

function RecorderPropertyDescriptor(const AName: string;
  AKind: TRecorderPropertyKind; AAccess: TRecorderPropertyAccess;
  const ADefaultValue: string; AScope: TRecorderPropertyScope;
  const AUnitName, AMinimumValue, AMaximumValue, ASinceVersion,
  AAllowedValues: string):
  TRecorderPropertyDescriptor;
begin
  Result.Name := Trim(AName);
  Result.ValueKind := AKind;
  Result.Scope := AScope;
  Result.Access := AAccess;
  Result.DefaultValue := ADefaultValue;
  Result.UnitName := AUnitName;
  Result.MinimumValue := AMinimumValue;
  Result.MaximumValue := AMaximumValue;
  Result.AllowedValues := AAllowedValues;
  Result.SinceVersion := ASinceVersion;
end;

constructor TRecorderTransactionalPropertyStore.Create(
  const ADescriptors: array of TRecorderPropertyDescriptor);
var
  I: Integer;
begin
  inherited Create;
  fValues := TStringList.Create;
  fValues.CaseSensitive := False;
  fValues.NameValueSeparator := '=';
  SetLength(fDescriptors, Length(ADescriptors));
  for I := 0 to High(ADescriptors) do
  begin
    if (Trim(ADescriptors[I].Name) = '') or
      (FindDescriptor(ADescriptors[I].Name) >= 0) then
      raise EArgumentException.Create('Property descriptor names must be unique');
    fDescriptors[I] := ADescriptors[I];
    ValidateDescriptor(fDescriptors[I]);
    fValues.Add(fDescriptors[I].Name + '=' + fDescriptors[I].DefaultValue);
  end;
end;

procedure TRecorderTransactionalPropertyStore.ValidateDescriptor(
  var ADescriptor: TRecorderPropertyDescriptor);
var
  lCanonical: string;
  lAllowed: TStringList;
  lFormat: TFormatSettings;
  lMax, lMin: Double;
  I, J: Integer;
  lResult: TRecorderOperationResult;
begin
  ADescriptor.Name := Trim(ADescriptor.Name);
  if (ADescriptor.Name = '') or (Pos(';', ADescriptor.Name) > 0) or
    (Pos('=', ADescriptor.Name) > 0) then
    raise EArgumentException.Create('Invalid property descriptor name');
  if (ADescriptor.ValueKind <> rpkEnum) and
    (Trim(ADescriptor.AllowedValues) <> '') then
    raise EArgumentException.Create('Allowed values require enum kind: ' +
      ADescriptor.Name);
  if (ADescriptor.ValueKind = rpkEnum) and
    (Trim(ADescriptor.AllowedValues) = '') then
    raise EArgumentException.Create('Enum values are empty: ' + ADescriptor.Name);
  if ADescriptor.ValueKind = rpkEnum then
  begin
    lAllowed := TStringList.Create;
    try
      lAllowed.StrictDelimiter := True;
      lAllowed.Delimiter := '|';
      lAllowed.DelimitedText := ADescriptor.AllowedValues;
      for I := 0 to lAllowed.Count - 1 do
      begin
        lAllowed[I] := Trim(lAllowed[I]);
        if lAllowed[I] = '' then
          raise EArgumentException.Create('Empty enum value: ' + ADescriptor.Name);
        for J := 0 to I - 1 do
          if SameText(lAllowed[I], lAllowed[J]) then
            raise EArgumentException.Create('Duplicate enum value: ' +
              ADescriptor.Name);
      end;
    finally
      lAllowed.Free;
    end;
  end;
  if not (ADescriptor.ValueKind in [rpkInteger, rpkFloat]) and
    ((ADescriptor.MinimumValue <> '') or (ADescriptor.MaximumValue <> '')) then
    raise EArgumentException.Create('Bounds require numeric kind: ' +
      ADescriptor.Name);
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  lFormat.ThousandSeparator := #0;
  if (ADescriptor.MinimumValue <> '') and
    not TryStrToFloat(ADescriptor.MinimumValue, lMin, lFormat) then
    raise EArgumentException.Create('Invalid minimum: ' + ADescriptor.Name);
  if (ADescriptor.MaximumValue <> '') and
    not TryStrToFloat(ADescriptor.MaximumValue, lMax, lFormat) then
    raise EArgumentException.Create('Invalid maximum: ' + ADescriptor.Name);
  if (ADescriptor.MinimumValue <> '') and (ADescriptor.MaximumValue <> '') and
    (lMin > lMax) then
    raise EArgumentException.Create('Minimum exceeds maximum: ' + ADescriptor.Name);
  lResult := ValidateValue(ADescriptor, ADescriptor.DefaultValue, lCanonical);
  if not lResult.IsSuccess then
    raise EArgumentException.Create('Invalid default for ' + ADescriptor.Name +
      ': ' + lResult.MessageText);
  ADescriptor.DefaultValue := lCanonical;
end;

function TRecorderTransactionalPropertyStore.ValidateSnapshot(
  AValues: TStrings): TRecorderOperationResult;
var
  I, lDescriptorIndex: Integer;
  lCanonical: string;
begin
  if AValues.Count <> Length(fDescriptors) then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'properties.calculate', 'Calculated snapshot changed property count'));
  for I := 0 to AValues.Count - 1 do
  begin
    lDescriptorIndex := FindDescriptor(AValues.Names[I]);
    if lDescriptorIndex < 0 then
      Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
        'properties.calculate', 'Calculated snapshot contains unknown property'));
    Result := ValidateValue(fDescriptors[lDescriptorIndex],
      AValues.ValueFromIndex[I], lCanonical);
    if not Result.IsSuccess then Exit;
    AValues.ValueFromIndex[I] := lCanonical;
  end;
  Result := TRecorderOperationResult.Success;
end;

destructor TRecorderTransactionalPropertyStore.Destroy;
begin
  fValues.Free;
  inherited Destroy;
end;

function TRecorderTransactionalPropertyStore.FindDescriptor(
  const AName: string): Integer;
begin
  for Result := 0 to High(fDescriptors) do
    if SameText(fDescriptors[Result].Name, Trim(AName)) then
      Exit;
  Result := -1;
end;

function TRecorderTransactionalPropertyStore.ParsePacket(const AText: string;
  AAllowWildcard: Boolean; out AItems: TStringList): TRecorderOperationResult;
var
  I, lEquals: Integer;
  lItem, lName, lValue: string;
  lParts: TStringList;
begin
  AItems := nil;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ';';
    lParts.DelimitedText := AText;
    AItems := TStringList.Create;
    AItems.CaseSensitive := False;
    AItems.NameValueSeparator := '=';
    for I := 0 to lParts.Count - 1 do
    begin
      lItem := Trim(lParts[I]);
      if lItem = '' then
        Exit(TRecorderOperationResult.Failure(rocInvalidArgument, 'properties.parse',
          'Empty property item'));
      if AAllowWildcard and (lItem = '*') then
      begin
        if lParts.Count <> 1 then
          Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
            'properties.parse', 'Wildcard must be the only request item'));
        AItems.Add('*');
        Exit(TRecorderOperationResult.Success);
      end;
      lEquals := Pos('=', lItem);
      if AAllowWildcard then
      begin
        if lEquals <> 0 then
          Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
            'properties.parse', 'Get request must contain names only'));
        lName := lItem;
        lValue := '';
      end
      else
      begin
        if (lEquals <= 1) or (Pos('=', Copy(lItem, lEquals + 1, MaxInt)) > 0) then
          Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
            'properties.parse', 'Expected exactly one name=value separator'));
        lName := Trim(Copy(lItem, 1, lEquals - 1));
        lValue := Trim(Copy(lItem, lEquals + 1, MaxInt));
      end;
      if FindDescriptor(lName) < 0 then
        Exit(TRecorderOperationResult.Failure(rocUnsupported, 'properties.parse',
          'Unknown property: ' + lName));
      if AItems.IndexOfName(lName) >= 0 then
        Exit(TRecorderOperationResult.Failure(rocInvalidArgument, 'properties.parse',
          'Duplicate property: ' + lName));
      AItems.Add(lName + '=' + lValue);
    end;
    if AItems.Count = 0 then
      Exit(TRecorderOperationResult.Failure(rocInvalidArgument, 'properties.parse',
        'Property packet is empty'));
    Result := TRecorderOperationResult.Success;
  finally
    lParts.Free;
    if not Result.IsSuccess then
      FreeAndNil(AItems);
  end;
end;

function TRecorderTransactionalPropertyStore.ValidateValue(
  const ADescriptor: TRecorderPropertyDescriptor; const AValue: string;
  out ACanonicalValue: string): TRecorderOperationResult;
var
  lBool: Boolean;
  lFloat, lMin, lMax: Double;
  lInt: Int64;
  lFormat: TFormatSettings;
  lAllowed: TStringList;
  I: Integer;
begin
  ACanonicalValue := AValue;
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  lFormat.ThousandSeparator := #0;
  case ADescriptor.ValueKind of
    rpkString: ;
    rpkInteger:
      begin
        if not TryStrToInt64(AValue, lInt) then
          Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
            'properties.validate', ADescriptor.Name + ' is not an integer'));
        lFloat := lInt;
        ACanonicalValue := IntToStr(lInt);
      end;
    rpkFloat:
      begin
        if not TryStrToFloat(AValue, lFloat, lFormat) then
          Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
            'properties.validate', ADescriptor.Name + ' is not a float'));
        ACanonicalValue := FloatToStr(lFloat, lFormat);
      end;
    rpkBoolean:
      begin
        if SameText(AValue, 'true') or (AValue = '1') then lBool := True
        else if SameText(AValue, 'false') or (AValue = '0') then lBool := False
        else Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
          'properties.validate', ADescriptor.Name + ' is not a boolean'));
        ACanonicalValue := BoolToStr(lBool, True);
      end;
    rpkEnum:
      begin
        lAllowed := TStringList.Create;
        try
          lAllowed.StrictDelimiter := True;
          lAllowed.Delimiter := '|';
          lAllowed.DelimitedText := ADescriptor.AllowedValues;
          for I := 0 to lAllowed.Count - 1 do
            if SameText(Trim(lAllowed[I]), Trim(AValue)) then
            begin
              ACanonicalValue := Trim(lAllowed[I]);
              Exit(TRecorderOperationResult.Success);
            end;
          Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
            'properties.validate', ADescriptor.Name + ' is not an allowed value'));
        finally
          lAllowed.Free;
        end;
      end;
  end;
  if ADescriptor.ValueKind in [rpkInteger, rpkFloat] then
  begin
    if (ADescriptor.MinimumValue <> '') and
      TryStrToFloat(ADescriptor.MinimumValue, lMin, lFormat) and (lFloat < lMin) then
      Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
        'properties.validate', ADescriptor.Name + ' is below minimum'));
    if (ADescriptor.MaximumValue <> '') and
      TryStrToFloat(ADescriptor.MaximumValue, lMax, lFormat) and (lFloat > lMax) then
      Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
        'properties.validate', ADescriptor.Name + ' is above maximum'));
  end;
  Result := TRecorderOperationResult.Success;
end;

function TRecorderTransactionalPropertyStore.SerializeValues(
  AValues: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to AValues.Count - 1 do
  begin
    if Result <> '' then Result := Result + ';';
    Result := Result + AValues[I];
  end;
end;

function TRecorderTransactionalPropertyStore.GetPropertyDescriptors:
  TRecorderPropertyDescriptorArray;
begin
  Result := Copy(fDescriptors);
end;

function TRecorderTransactionalPropertyStore.GetProperties(
  const ARequest: string; out AResponse: string): TRecorderOperationResult;
var
  I: Integer;
  lItems: TStringList;
begin
  AResponse := '';
  Result := ParsePacket(ARequest, True, lItems);
  if not Result.IsSuccess then Exit;
  try
    if (lItems.Count = 1) and (lItems[0] = '*') then
    begin
      AResponse := SerializeValues(fValues);
    end
    else
      for I := 0 to lItems.Count - 1 do
      begin
        if AResponse <> '' then AResponse := AResponse + ';';
        AResponse := AResponse + lItems.Names[I] + '=' +
          fValues.Values[lItems.Names[I]];
      end;
  finally
    lItems.Free;
  end;
end;

function TRecorderTransactionalPropertyStore.BuildCandidate(
  const AProperties: string; out ACandidate: TStringList):
  TRecorderOperationResult;
var
  I, lDescriptorIndex: Integer;
  lCanonical: string;
  lItems: TStringList;
begin
  ACandidate := nil;
  Result := ParsePacket(AProperties, False, lItems);
  if not Result.IsSuccess then Exit;
  ACandidate := TStringList.Create;
  try
    ACandidate.Assign(fValues);
    ACandidate.CaseSensitive := False;
    ACandidate.NameValueSeparator := '=';
    for I := 0 to lItems.Count - 1 do
    begin
      lDescriptorIndex := FindDescriptor(lItems.Names[I]);
      if fDescriptors[lDescriptorIndex].Access = rpaReadOnly then
        Exit(TRecorderOperationResult.Failure(rocUnsupported,
          'properties.validate', 'Read-only property: ' + lItems.Names[I]));
      Result := ValidateValue(fDescriptors[lDescriptorIndex],
        lItems.ValueFromIndex[I], lCanonical);
      if not Result.IsSuccess then Exit;
      ACandidate.Values[fDescriptors[lDescriptorIndex].Name] := lCanonical;
    end;
    Result := CalculateCandidate(ACandidate);
    if not Result.IsSuccess then Exit;
    Result := ValidateSnapshot(ACandidate);
    if not Result.IsSuccess then Exit;
    Result := ValidateCandidate(ACandidate);
  finally
    lItems.Free;
    if not Result.IsSuccess then FreeAndNil(ACandidate);
  end;
end;

function TRecorderTransactionalPropertyStore.CalcProperties(
  const AProperties: string; out AResponse: string): TRecorderOperationResult;
var
  lCandidate: TStringList;
begin
  AResponse := '';
  Result := BuildCandidate(AProperties, lCandidate);
  if not Result.IsSuccess then Exit;
  try
    AResponse := SerializeValues(lCandidate);
  finally
    lCandidate.Free;
  end;
end;

function TRecorderTransactionalPropertyStore.SetProperties(
  const AProperties: string): TRecorderOperationResult;
var
  lCandidate, lPrevious: TStringList;
  lPreviousSerialized: string;
begin
  Result := BuildCandidate(AProperties, lCandidate);
  if not Result.IsSuccess then Exit;
  lPrevious := fValues;
  lPreviousSerialized := SerializeValues(lPrevious);
  try
    fValues := lCandidate;
    lCandidate := lPrevious;
    try
      AfterCommit(lPreviousSerialized);
      Result := TRecorderOperationResult.Success;
    except
      on E: Exception do
      begin
        lCandidate := fValues;
        fValues := lPrevious;
        Result := TRecorderOperationResult.Failure(rocInternal,
          'properties.commit', E.ClassName + ': ' + E.Message);
      end;
    end;
  finally
    lCandidate.Free;
  end;
end;

function TRecorderTransactionalPropertyStore.CalculateCandidate(
  AValues: TStrings): TRecorderOperationResult;
begin
  Result := TRecorderOperationResult.Success;
end;

function TRecorderTransactionalPropertyStore.ValidateCandidate(
  AValues: TStrings): TRecorderOperationResult;
begin
  Result := TRecorderOperationResult.Success;
end;

procedure TRecorderTransactionalPropertyStore.AfterCommit(
  const APreviousValues: string);
begin
end;

function TRecorderTransactionalPropertyStore.ValueOf(const AName: string): string;
begin
  Result := fValues.Values[AName];
end;

end.
