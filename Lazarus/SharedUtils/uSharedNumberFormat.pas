unit uSharedNumberFormat;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math;

// Formats a display value with a bounded number of significant digits.
// The default four digits allow at most one fraction digit for a
// three-digit integer part. This changes presentation, not the source value.
function FormatSignificant(const AValue: Double;
  const AMaxDigits: Integer = 4): string; overload;
function FormatSignificant(const AValue: Double;
  const AMaxDigits: Integer;
  const AFormatSettings: TFormatSettings): string; overload;

implementation

function FormatSignificant(const AValue: Double;
  const AMaxDigits: Integer;
  const AFormatSettings: TFormatSettings): string;
var
  lDigits: Integer;
  lDecimalPlaces: Integer;
  lOrder: Integer;
  lRoundedValue: Double;
  lDecimalSeparatorPos: SizeInt;
begin
  if IsNan(AValue) then
    Exit('NaN');
  if IsInfinite(AValue) then
  begin
    if AValue < 0 then
      Exit('-Inf');
    Exit('Inf');
  end;
  if AValue = 0 then
    Exit('0');

  lDigits := AMaxDigits;
  if lDigits < 1 then
    lDigits := 1
  else if lDigits > 15 then
    lDigits := 15;
  lOrder := Floor(Log10(Abs(AValue)));
  lDecimalPlaces := lDigits - lOrder - 1;
  if lDecimalPlaces > 15 then
    lDecimalPlaces := 15;

  if lDecimalPlaces < 0 then
  begin
    lRoundedValue := RoundTo(AValue, -lDecimalPlaces);
    Result := FloatToStrF(lRoundedValue, ffFixed, 18, 0, AFormatSettings);
  end
  else
    Result := FloatToStrF(AValue, ffFixed, 18, lDecimalPlaces, AFormatSettings);

  lDecimalSeparatorPos := Pos(AFormatSettings.DecimalSeparator, Result);
  if lDecimalSeparatorPos > 0 then
  begin
    while (Length(Result) > lDecimalSeparatorPos) and
      (Result[Length(Result)] = '0') do
      Delete(Result, Length(Result), 1);
    if Length(Result) = lDecimalSeparatorPos then
      Delete(Result, Length(Result), 1);
  end;
  if Result = '-0' then
    Result := '0';
end;

function FormatSignificant(const AValue: Double;
  const AMaxDigits: Integer): string;
begin
  Result := FormatSignificant(AValue, AMaxDigits, DefaultFormatSettings);
end;

end.
