unit uRecorderSvgParameters;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math;

type
  TRecorderSvgParameterKind = (rspText, rspNumber, rspColor,
    rspVisibility, rspMixed);

function LoadSvgText(const AFileName: string): string;
procedure ExtractSvgParameters(const AFileName: string; ADest: TStrings);
function ReplaceSvgParameter(const ASource, AName, AValue: string): string;
function ResolveSvgParameterDefaults(const ASource: string): string;
function ResolveSvgRendererExpressions(const ASource: string): string;
function EscapeSvgParameterValue(const AValue: string): string;
function DetectSvgParameterKind(const ASource, AName: string):
  TRecorderSvgParameterKind;
function TryParseSvgNumber(const AValue: string; out ANumber: Double): Boolean;
function SvgNumberOrderStep(AValue: Double): Double;
function FormatSvgNumber(AValue: Double): string;
function ValidateSvgParameterTemplate(const ASource: string;
  out AError: string): Boolean;
function ValidateSvgParameterValue(const ASource, AName, AValue: string;
  out AError: string): Boolean;

implementation

const
  CRecorderDegreeDash = 'recorder-deg-dash(';
  CRecorderTicks = 'recorder-ticks(';
  CRecorderValueAngle = 'recorder-value-angle(';

function LoadSvgText(const AFileName: string): string;
var
  lStream: TFileStream;
  lBytes: RawByteString;
begin
  Result := '';
  if not FileExists(AFileName) then
    Exit;
  lStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(lBytes, lStream.Size);
    if Length(lBytes) > 0 then
      lStream.ReadBuffer(lBytes[1], Length(lBytes));
    Result := string(lBytes);
  finally
    lStream.Free;
  end;
end;

procedure ExtractSvgParameters(const AFileName: string; ADest: TStrings);
var
  lSource, lName, lToken, lDefaultValue: string;
  lOpenPos, lClosePos, lSearchPos, lSeparatorPos: SizeInt;
begin
  if ADest = nil then
    Exit;
  lSource := LoadSvgText(AFileName);
  lSearchPos := 1;
  while lSearchPos <= Length(lSource) do
  begin
    lOpenPos := Pos('{{', lSource, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos('}}', lSource, lOpenPos + 2);
    if lClosePos = 0 then
      Exit;
    lToken := Copy(lSource, lOpenPos + 2, lClosePos - lOpenPos - 2);
    lSeparatorPos := Pos('|', lToken);
    if lSeparatorPos > 0 then
    begin
      lName := Trim(Copy(lToken, 1, lSeparatorPos - 1));
      { Everything after the first separator is user data. Keep its whitespace
        byte-for-byte; captions and font names may intentionally contain it. }
      lDefaultValue := Copy(lToken, lSeparatorPos + 1, MaxInt);
    end
    else
    begin
      lName := Trim(lToken);
      lDefaultValue := '';
    end;
    if (lName <> '') and (ADest.IndexOfName(lName) < 0) then
      ADest.Add(lName + '=' + lDefaultValue);
    lSearchPos := lClosePos + 2;
  end;
end;

function ResolveDegreeDashExpressions(const ASource: string): string;
var
  lArgs: string;
  lClosePos, lCommaPos, lOpenPos, lSearchPos: SizeInt;
  lDegrees, lRadius: Double;
  lFormat: TFormatSettings;
  lReplacement: string;
begin
  Result := ASource;
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  lSearchPos := 1;
  repeat
    lOpenPos := Pos(CRecorderDegreeDash, Result, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos(')', Result, lOpenPos + Length(CRecorderDegreeDash));
    if lClosePos = 0 then
      raise EConvertError.Create('Unclosed recorder-deg-dash expression');
    lArgs := Copy(Result, lOpenPos + Length(CRecorderDegreeDash),
      lClosePos - lOpenPos - Length(CRecorderDegreeDash));
    lCommaPos := Pos(',', lArgs);
    if (lCommaPos = 0) or
      not TryStrToFloat(Trim(Copy(lArgs, 1, lCommaPos - 1)), lDegrees,
        lFormat) or
      not TryStrToFloat(Trim(Copy(lArgs, lCommaPos + 1, MaxInt)), lRadius,
        lFormat) or (lRadius <= 0) then
      raise EConvertError.CreateFmt('Invalid recorder-deg-dash(%s)', [lArgs]);

    { BGRASVG ignores SVG pathLength for dash metrics. Convert the public
      degree value to the physical arc length before handing SVG to it. }
    lReplacement := FloatToStr(lDegrees * Pi * lRadius / 180.0, lFormat);
    Delete(Result, lOpenPos, lClosePos - lOpenPos + 1);
    Insert(lReplacement, Result, lOpenPos);
    lSearchPos := lOpenPos + Length(lReplacement);
  until False;
end;

function ParseTickArguments(const AArgs: string; out ACount: Integer;
  out ACenterX, ACenterY, AInnerRadius, AOuterRadius: Double): Boolean;
var
  I, lStart: Integer;
  lParts: array[0..4] of string;
  lFormat: TFormatSettings;
begin
  lStart := 1;
  for I := 0 to 3 do
  begin
    lParts[I] := Copy(AArgs, lStart, Pos(',', AArgs, lStart) - lStart);
    if lParts[I] = '' then
      Exit(False);
    lStart := lStart + Length(lParts[I]) + 1;
  end;
  lParts[4] := Copy(AArgs, lStart, MaxInt);
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := TryStrToInt(Trim(lParts[0]), ACount) and
    TryStrToFloat(Trim(lParts[1]), ACenterX, lFormat) and
    TryStrToFloat(Trim(lParts[2]), ACenterY, lFormat) and
    TryStrToFloat(Trim(lParts[3]), AInnerRadius, lFormat) and
    TryStrToFloat(Trim(lParts[4]), AOuterRadius, lFormat) and
    (ACount >= 1) and (ACount <= 360) and (AInnerRadius >= 0) and
    (AOuterRadius > AInnerRadius);
end;

function BuildRadialTickPath(ACount: Integer; ACenterX, ACenterY,
  AInnerRadius, AOuterRadius: Double): string;
var
  I: Integer;
  lAngle: Double;
begin
  Result := '';
  for I := 0 to ACount - 1 do
  begin
    lAngle := 2 * Pi * I / ACount - Pi / 2;
    Result := Result + Format('M%s %sL%s %s ', [
      FormatSvgNumber(ACenterX + AInnerRadius * Cos(lAngle)),
      FormatSvgNumber(ACenterY + AInnerRadius * Sin(lAngle)),
      FormatSvgNumber(ACenterX + AOuterRadius * Cos(lAngle)),
      FormatSvgNumber(ACenterY + AOuterRadius * Sin(lAngle))]);
  end;
  Result := Trim(Result);
end;

function ResolveTickExpressions(const ASource: string): string;
var
  lArgs, lReplacement: string;
  lClosePos, lOpenPos, lSearchPos: SizeInt;
  lCount: Integer;
  lCenterX, lCenterY, lInnerRadius, lOuterRadius: Double;
begin
  Result := ASource;
  lSearchPos := 1;
  repeat
    lOpenPos := Pos(CRecorderTicks, Result, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos(')', Result, lOpenPos + Length(CRecorderTicks));
    if lClosePos = 0 then
      raise EConvertError.Create('Unclosed recorder-ticks expression');
    lArgs := Copy(Result, lOpenPos + Length(CRecorderTicks),
      lClosePos - lOpenPos - Length(CRecorderTicks));
    if not ParseTickArguments(lArgs, lCount, lCenterX, lCenterY,
      lInnerRadius, lOuterRadius) then
      raise EConvertError.CreateFmt('Invalid recorder-ticks(%s)', [lArgs]);
    lReplacement := BuildRadialTickPath(lCount, lCenterX, lCenterY,
      lInnerRadius, lOuterRadius);
    Delete(Result, lOpenPos, lClosePos - lOpenPos + 1);
    Insert(lReplacement, Result, lOpenPos);
    lSearchPos := lOpenPos + Length(lReplacement);
  until False;
end;

function ParseValueAngleArguments(const AArgs: string;
  out AValue, AScaleMin, AScaleMax, AAngleAtMin,
  AAngleAtMax: Double): Boolean;
var
  I, lCommaPos, lStart: Integer;
  lParts: array[0..4] of string;
  lNumbers: array[0..4] of Double;
begin
  lStart := 1;
  for I := 0 to 3 do
  begin
    lCommaPos := Pos(',', AArgs, lStart);
    if lCommaPos = 0 then
      Exit(False);
    lParts[I] := Trim(Copy(AArgs, lStart, lCommaPos - lStart));
    lStart := lCommaPos + 1;
  end;
  lParts[4] := Trim(Copy(AArgs, lStart, MaxInt));
  for I := 0 to High(lNumbers) do
    if not TryParseSvgNumber(lParts[I], lNumbers[I]) or
      IsNan(lNumbers[I]) or IsInfinite(lNumbers[I]) then
      Exit(False);
  AValue := lNumbers[0];
  AScaleMin := lNumbers[1];
  AScaleMax := lNumbers[2];
  AAngleAtMin := lNumbers[3];
  AAngleAtMax := lNumbers[4];
  Result := AScaleMax > AScaleMin;
end;

function ResolveValueAngleExpressions(const ASource: string): string;
var
  lArgs, lReplacement: string;
  lClosePos, lOpenPos, lSearchPos: SizeInt;
  lValue, lScaleMin, lScaleMax, lAngleAtMin, lAngleAtMax: Double;
begin
  Result := ASource;
  lSearchPos := 1;
  repeat
    lOpenPos := Pos(CRecorderValueAngle, Result, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos(')', Result, lOpenPos + Length(CRecorderValueAngle));
    if lClosePos = 0 then
      raise EConvertError.Create('Unclosed recorder-value-angle expression');
    lArgs := Copy(Result, lOpenPos + Length(CRecorderValueAngle),
      lClosePos - lOpenPos - Length(CRecorderValueAngle));
    if not ParseValueAngleArguments(lArgs, lValue, lScaleMin, lScaleMax,
      lAngleAtMin, lAngleAtMax) then
      raise EConvertError.CreateFmt('Invalid recorder-value-angle(%s)', [lArgs]);
    { Keep the needle on its semicircle when a signal exceeds the dial range. }
    lValue := EnsureRange(lValue, lScaleMin, lScaleMax);
    lReplacement := FormatSvgNumber(lAngleAtMin +
      (lValue - lScaleMin) * (lAngleAtMax - lAngleAtMin) /
      (lScaleMax - lScaleMin));
    Delete(Result, lOpenPos, lClosePos - lOpenPos + 1);
    Insert(lReplacement, Result, lOpenPos);
    lSearchPos := lOpenPos + Length(lReplacement);
  until False;
end;

function ResolveSvgRendererExpressions(const ASource: string): string;
begin
  Result := ResolveDegreeDashExpressions(ASource);
  Result := ResolveTickExpressions(Result);
  Result := ResolveValueAngleExpressions(Result);
end;

function LastPositionBefore(const ASubString, ASource: string;
  ABefore: SizeInt): SizeInt;
var
  lOffset, lFound: SizeInt;
begin
  Result := 0;
  lOffset := 1;
  repeat
    lFound := Pos(ASubString, ASource, lOffset);
    if (lFound = 0) or (lFound >= ABefore) then
      Exit;
    Result := lFound;
    lOffset := lFound + 1;
  until False;
end;

function AttributeNameBefore(const ASource: string; ATokenPos,
  ATagStart: SizeInt): string;
var
  I, lEndPos: SizeInt;
begin
  Result := '';
  I := ATokenPos - 1;
  while (I > ATagStart) and (ASource[I] <> '=') do
    Dec(I);
  if (I <= ATagStart) or (ASource[I] <> '=') then
    Exit;
  Dec(I);
  while (I > ATagStart) and (ASource[I] in [' ', #9, '"', '''']) do
    Dec(I);
  lEndPos := I;
  while (I > ATagStart) and
    (ASource[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-', ':']) do
    Dec(I);
  Result := LowerCase(Copy(ASource, I + 1, lEndPos - I));
end;

function StylePropertyBefore(const ASource: string; ATokenPos,
  ATagStart: SizeInt): string;
var
  I, lEndPos: SizeInt;
begin
  Result := '';
  I := ATokenPos - 1;
  while (I > ATagStart) and (ASource[I] <> ':') and
    (ASource[I] <> ';') and (ASource[I] <> '"') do
    Dec(I);
  if (I <= ATagStart) or (ASource[I] <> ':') then
    Exit;
  Dec(I);
  while (I > ATagStart) and (ASource[I] in [' ', #9]) do
    Dec(I);
  lEndPos := I;
  while (I > ATagStart) and
    (ASource[I] in ['a'..'z', 'A'..'Z', '-']) do
    Dec(I);
  Result := LowerCase(Copy(ASource, I + 1, lEndPos - I));
end;

function SafeSvgStyleProperty(const AProperty: string): Boolean;
begin
  Result := (AProperty = 'fill') or (AProperty = 'stroke') or
    (AProperty = 'color') or (AProperty = 'opacity') or
    (AProperty = 'fill-opacity') or (AProperty = 'stroke-opacity') or
    (AProperty = 'stroke-width') or (AProperty = 'font-family') or
    (AProperty = 'font-size') or (AProperty = 'font-weight') or
    (AProperty = 'display') or (AProperty = 'visibility');
end;

function SafeSvgPathParameter(const ASource, AToken: string;
  AOpenPos, ATagStart: SizeInt): Boolean;
var
  lDefault: Double;
  lSeparatorPos: SizeInt;
begin
  lSeparatorPos := Pos('|', AToken);
  Result := (lSeparatorPos > 0) and
    TryParseSvgNumber(Trim(Copy(AToken, lSeparatorPos + 1, MaxInt)), lDefault) and
    (Pos('recorder-ticks(', LowerCase(Copy(ASource, ATagStart,
      AOpenPos - ATagStart))) > 0);
end;

function ValidateSvgParameterTemplate(const ASource: string;
  out AError: string): Boolean;
const
  CAllowedAttributes: array[0..6] of string = ('fill', 'stroke', 'transform',
    'stroke-dasharray', 'display', 'font-family', 'font-size');
var
  I: Integer;
  lOpenPos, lClosePos, lSearchPos, lTagStart, lTagEnd: SizeInt;
  lAttribute, lToken: string;
  lAllowed: Boolean;
begin
  AError := '';
  lSearchPos := 1;
  repeat
    lOpenPos := Pos('{{', ASource, lSearchPos);
    if lOpenPos = 0 then
      Exit(True);
    lClosePos := Pos('}}', ASource, lOpenPos + 2);
    if lClosePos = 0 then
    begin
      AError := 'Незакрытый SVG-параметр.';
      Exit(False);
    end;
    lToken := Trim(Copy(ASource, lOpenPos + 2,
      lClosePos - lOpenPos - 2));
    if (lToken = '') or (lToken[1] = '|') then
    begin
      AError := 'SVG-параметр без имени.';
      Exit(False);
    end;
    lTagStart := LastPositionBefore('<', ASource, lOpenPos);
    lTagEnd := LastPositionBefore('>', ASource, lOpenPos);
    if lTagStart > lTagEnd then
    begin
      lAttribute := AttributeNameBefore(ASource, lOpenPos, lTagStart);
      lAllowed := False;
      if lAttribute = 'style' then
        lAllowed := SafeSvgStyleProperty(
          StylePropertyBefore(ASource, lOpenPos, lTagStart))
      else if lAttribute = 'd' then
        lAllowed := SafeSvgPathParameter(ASource, lToken, lOpenPos, lTagStart);
      for I := Low(CAllowedAttributes) to High(CAllowedAttributes) do
        if lAttribute = CAllowedAttributes[I] then
        begin
          lAllowed := True;
          Break;
        end;
      if not lAllowed then
      begin
        AError := Format('Параметр «%s» находится в запрещённом атрибуте «%s».',
          [lToken, lAttribute]);
        Exit(False);
      end;
    end;
    lSearchPos := lClosePos + 2;
  until False;
end;

function IsSvgColor(const AValue: string): Boolean;
var
  I: Integer;
  lValue: string;
begin
  lValue := LowerCase(AValue);
  if (lValue = 'none') or (lValue = 'currentcolor') or
    (lValue = 'transparent') then
    Exit(True);
  if (Length(AValue) <> 7) or (AValue[1] <> '#') then
    Exit(False);
  for I := 2 to 7 do
    if not (AValue[I] in ['0'..'9', 'a'..'f', 'A'..'F']) then
      Exit(False);
  Result := True;
end;

function IsSvgNumber(const AValue: string): Boolean;
var
  lNumber: Double;
begin
  Result := TryParseSvgNumber(AValue, lNumber);
end;

function TryParseSvgNumber(const AValue: string; out ANumber: Double): Boolean;
var
  lSettings: TFormatSettings;
begin
  lSettings := DefaultFormatSettings;
  lSettings.DecimalSeparator := '.';
  Result := TryStrToFloat(Trim(AValue), ANumber, lSettings);
end;

function SvgNumberOrderStep(AValue: Double): Double;
begin
  if Abs(AValue) < 1.0E-300 then
    Exit(0.05);
  Result := 0.05 * Power(10, Floor(Log10(Abs(AValue))));
end;

function FormatSvgNumber(AValue: Double): string;
var
  lSettings: TFormatSettings;
begin
  if Abs(AValue) < 1.0E-14 then
    AValue := 0;
  lSettings := DefaultFormatSettings;
  lSettings.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lSettings);
end;

function AttributeParameterKind(const AAttribute: string):
  TRecorderSvgParameterKind;
begin
  if (AAttribute = 'fill') or (AAttribute = 'stroke') or
    (AAttribute = 'color') then
    Exit(rspColor);
  if (AAttribute = 'transform') or
    (AAttribute = 'stroke-dasharray') or (AAttribute = 'font-size') or
    (AAttribute = 'd') or
    (AAttribute = 'opacity') or (AAttribute = 'fill-opacity') or
    (AAttribute = 'stroke-opacity') or (AAttribute = 'stroke-width') then
    Exit(rspNumber);
  if (AAttribute = 'display') or (AAttribute = 'visibility') then
    Exit(rspVisibility);
  Result := rspText;
end;

function DetectSvgParameterKind(const ASource, AName: string):
  TRecorderSvgParameterKind;
var
  lAttribute, lToken, lTokenName: string;
  lClosePos, lOpenPos, lSearchPos, lSeparatorPos, lTagEnd, lTagStart: SizeInt;
  lFound: Boolean;
  lKind: TRecorderSvgParameterKind;
begin
  Result := rspText;
  lFound := False;
  lSearchPos := 1;
  repeat
    lOpenPos := Pos('{{', ASource, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos('}}', ASource, lOpenPos + 2);
    if lClosePos = 0 then
      Exit;
    lToken := Copy(ASource, lOpenPos + 2, lClosePos - lOpenPos - 2);
    lSeparatorPos := Pos('|', lToken);
    if lSeparatorPos > 0 then
      lTokenName := Trim(Copy(lToken, 1, lSeparatorPos - 1))
    else
      lTokenName := Trim(lToken);
    if SameText(lTokenName, AName) then
    begin
      lTagStart := LastPositionBefore('<', ASource, lOpenPos);
      lTagEnd := LastPositionBefore('>', ASource, lOpenPos);
      lAttribute := '';
      if lTagStart > lTagEnd then
        lAttribute := AttributeNameBefore(ASource, lOpenPos, lTagStart);
      if lAttribute = 'style' then
        lAttribute := StylePropertyBefore(ASource, lOpenPos, lTagStart);
      lKind := AttributeParameterKind(lAttribute);
      if not lFound then
      begin
        Result := lKind;
        lFound := True;
      end
      else if Result <> lKind then
      begin
        { A numeric value may also be printed as text on the same dial. }
        if (Result = rspText) and (lKind = rspNumber) then
          Result := rspNumber
        else if not ((Result = rspNumber) and (lKind = rspText)) then
          Exit(rspMixed);
      end;
    end;
    lSearchPos := lClosePos + 2;
  until False;
end;

function ValidateSvgParameterValue(const ASource, AName, AValue: string;
  out AError: string): Boolean;
var
  lOpenPos, lClosePos, lSearchPos, lTagStart, lTagEnd, lSeparatorPos: SizeInt;
  lAttribute, lToken, lTokenName, lLowerValue: string;
  lValid: Boolean;
begin
  AError := '';
  lSearchPos := 1;
  repeat
    lOpenPos := Pos('{{', ASource, lSearchPos);
    if lOpenPos = 0 then
      Exit(True);
    lClosePos := Pos('}}', ASource, lOpenPos + 2);
    if lClosePos = 0 then
      Exit(False);
    lToken := Copy(ASource, lOpenPos + 2, lClosePos - lOpenPos - 2);
    lSeparatorPos := Pos('|', lToken);
    if lSeparatorPos > 0 then
      lTokenName := Trim(Copy(lToken, 1, lSeparatorPos - 1))
    else
      lTokenName := Trim(lToken);
    if SameText(lTokenName, AName) then
    begin
      lLowerValue := LowerCase(AValue);
      if (Pos('url(', lLowerValue) > 0) or
        (Pos('expression', lLowerValue) > 0) or
        (Pos('@import', lLowerValue) > 0) or
        (Pos('behavior:', lLowerValue) > 0) or
        (Pos('javascript:', lLowerValue) > 0) then
      begin
        AError := Format('Параметр «%s» содержит запрещённое CSS-значение.',
          [AName]);
        Exit(False);
      end;
      lTagStart := LastPositionBefore('<', ASource, lOpenPos);
      lTagEnd := LastPositionBefore('>', ASource, lOpenPos);
      lAttribute := '';
      if lTagStart > lTagEnd then
        lAttribute := AttributeNameBefore(ASource, lOpenPos, lTagStart);
      if lAttribute = 'style' then
        lAttribute := StylePropertyBefore(ASource, lOpenPos, lTagStart);
      if (lAttribute = 'fill') or (lAttribute = 'stroke') or
        (lAttribute = 'color') then
        lValid := IsSvgColor(AValue)
      else if (lAttribute = 'transform') or
        (lAttribute = 'stroke-dasharray') or (lAttribute = 'font-size') or
        (lAttribute = 'd') or
        (lAttribute = 'opacity') or (lAttribute = 'fill-opacity') or
        (lAttribute = 'stroke-opacity') or (lAttribute = 'stroke-width') then
        lValid := IsSvgNumber(AValue)
      else if lAttribute = 'display' then
        lValid := (LowerCase(AValue) = 'inline') or
          (LowerCase(AValue) = 'none')
      else if lAttribute = 'visibility' then
        lValid := (LowerCase(AValue) = 'visible') or
          (LowerCase(AValue) = 'hidden') or
          (LowerCase(AValue) = 'collapse')
      else
        lValid := True;
      if not lValid then
      begin
        AError := Format('Параметр «%s»: значение «%s» недопустимо для %s.',
          [AName, AValue, lAttribute]);
        Exit(False);
      end;
    end;
    lSearchPos := lClosePos + 2;
  until False;
end;

function ReplaceSvgParameter(const ASource, AName, AValue: string): string;
var
  lOpenPos, lClosePos, lSearchPos, lSeparatorPos: SizeInt;
  lToken, lTokenName: string;
begin
  Result := ASource;
  lSearchPos := 1;
  repeat
    lOpenPos := Pos('{{', Result, lSearchPos);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos('}}', Result, lOpenPos + 2);
    if lClosePos = 0 then
      Exit;
    lToken := Trim(Copy(Result, lOpenPos + 2, lClosePos - lOpenPos - 2));
    lSeparatorPos := Pos('|', lToken);
    if lSeparatorPos > 0 then
      lTokenName := Trim(Copy(lToken, 1, lSeparatorPos - 1))
    else
      lTokenName := lToken;
    if SameText(lTokenName, AName) then
    begin
      Delete(Result, lOpenPos, lClosePos + 2 - lOpenPos);
      Insert(AValue, Result, lOpenPos);
      lSearchPos := lOpenPos + Length(AValue);
    end
    else
      lSearchPos := lClosePos + 2;
  until False;
end;

function ResolveSvgParameterDefaults(const ASource: string): string;
var
  lClosePos, lOpenPos, lSeparatorPos: SizeInt;
  lDefaultValue, lToken: string;
begin
  Result := ASource;
  repeat
    lOpenPos := Pos('{{', Result);
    if lOpenPos = 0 then
      Exit;
    lClosePos := Pos('}}', Result, lOpenPos + 2);
    if lClosePos = 0 then
      Exit;
    lToken := Copy(Result, lOpenPos + 2, lClosePos - lOpenPos - 2);
    lSeparatorPos := Pos('|', lToken);
    if lSeparatorPos > 0 then
      lDefaultValue := Copy(lToken, lSeparatorPos + 1, MaxInt)
    else
      lDefaultValue := '';
    { Bindings are applied first. Any token still present is unbound and must
      fall back to the template value instead of leaking template syntax. }
    Delete(Result, lOpenPos, lClosePos + 2 - lOpenPos);
    { The default is part of the SVG source and therefore is already XML
      encoded. Escaping it again would turn &amp; into visible "&amp;" text. }
    Insert(lDefaultValue, Result, lOpenPos);
  until False;
end;

function EscapeSvgParameterValue(const AValue: string): string;
begin
  Result := StringReplace(AValue, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
end;

end.
