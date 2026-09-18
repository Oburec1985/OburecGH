unit uSharedNumberFormat;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

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
begin
  lDigits := AMaxDigits;
  if lDigits < 1 then
    lDigits := 1
  else if lDigits > 15 then
    lDigits := 15;
  Result := FloatToStrF(AValue, ffGeneral, lDigits, 0, AFormatSettings);
end;

function FormatSignificant(const AValue: Double;
  const AMaxDigits: Integer): string;
begin
  Result := FormatSignificant(AValue, AMaxDigits, DefaultFormatSettings);
end;

end.
