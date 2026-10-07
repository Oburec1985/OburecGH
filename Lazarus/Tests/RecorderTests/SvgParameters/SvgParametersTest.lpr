program SvgParametersTest;

{$mode objfpc}{$H+}

uses
  Interfaces, Classes, Math, SysUtils, BGRABitmap, BGRABitmapTypes, BGRASVG,
  uRecorderSvgParameters, uRecorderSvgRenderer;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckNear(AExpected, AActual, AEpsilon: Double;
  const AMessage: string);
begin
  Check(Abs(AExpected - AActual) <= AEpsilon,
    Format('%s: expected %.12g, got %.12g',
      [AMessage, AExpected, AActual]));
end;

procedure CheckParameterEditingHelpers;
const
  CTypedTemplate =
    '<svg><g transform="rotate({{Angle|105}})">' +
    '<path fill="{{ZoneColor|#21a53a}}"/>' +
    '<path d="recorder-ticks({{TickCount|24}},0,0,1,2)"/>' +
    '<text display="{{ReadoutVisible|inline}}">{{Caption|P}}</text>' +
    '<path style="stroke:{{ZoneColor}}"/></g></svg>';
var
  lNumber: Double;
begin
  Check(DetectSvgParameterKind(CTypedTemplate, 'Angle') = rspNumber,
    'transform parameter kind');
  Check(DetectSvgParameterKind(CTypedTemplate, 'ZoneColor') = rspColor,
    'colour parameter kind');
  Check(DetectSvgParameterKind(CTypedTemplate, 'ReadoutVisible') =
    rspVisibility, 'visibility parameter kind');
  Check(DetectSvgParameterKind(CTypedTemplate, 'Caption') = rspText,
    'text parameter kind');
  Check(DetectSvgParameterKind(CTypedTemplate, 'TickCount') = rspNumber,
    'tick count parameter kind');
  Check(DetectSvgParameterKind(
    '<svg><g transform="rotate(recorder-value-angle({{LeftValue|2.8}},0,6,-180,0))">' +
    '<text>{{LeftValue|2.8}}</text></g></svg>', 'LeftValue') = rspNumber,
    'value shared by needle and text must remain numeric');
  Check(ResolveSvgRendererExpressions(
    'rotate(recorder-value-angle(2.8,0,6,-180,0))') = 'rotate(-96)',
    'left needle angle must follow its scale');
  Check(ResolveSvgRendererExpressions(
    'rotate(recorder-value-angle(1.4,0,3,180,0))') = 'rotate(96)',
    'right needle angle must follow its scale');
  Check(ResolveSvgRendererExpressions(
    'rotate(recorder-value-angle(9,0,6,-180,0))') = 'rotate(0)',
    'needle must stop at the scale limit');
  Check(Pos('recorder-ticks', ResolveSvgRendererExpressions(
    '<path d="recorder-ticks(4,0,0,1,2)"/>')) = 0,
    'tick expression was not expanded');

  Check(TryParseSvgNumber('105', lNumber), 'integer SVG number parse');
  CheckNear(105, lNumber, 1.0E-12, 'integer SVG number value');
  Check(TryParseSvgNumber('0.5', lNumber), 'fractional SVG number parse');
  CheckNear(0.5, lNumber, 1.0E-12, 'fractional SVG number value');
  Check(not TryParseSvgNumber('12 px', lNumber),
    'number with unit suffix accepted');

  { The editor changes a value by five percent of its decimal order, not by
    five percent of the current value. This keeps repeated clicks stable. }
  CheckNear(5, SvgNumberOrderStep(105), 1.0E-12,
    'numeric step for hundreds');
  CheckNear(0.05, SvgNumberOrderStep(9), 1.0E-12,
    'numeric step for units');
  CheckNear(0.005, SvgNumberOrderStep(0.5), 1.0E-12,
    'numeric step below one');
  CheckNear(0.05, SvgNumberOrderStep(0), 1.0E-12,
    'numeric step fallback for zero');
  Check(FormatSvgNumber(105 + SvgNumberOrderStep(105)) = '110',
    'numeric increment formatting');
  Check(FormatSvgNumber(105 - SvgNumberOrderStep(105)) = '100',
    'numeric decrement formatting');

  Check(ResolveSvgParameterDefaults(
    '<text>{{LeftScaleMax|6}}</text><text>{{Caption|P &amp; V}}</text>') =
    '<text>6</text><text>P &amp; V</text>',
    'unbound parameters did not resolve to source defaults');
  Check(ResolveSvgParameterDefaults(
    ReplaceSvgParameter('<text>{{LeftScaleMax|6}}</text>',
      'LeftScaleMax', '12')) = '<text>12</text>',
    'explicit binding was overwritten by the default');
end;

function GaugeTemplateFileName: string;
begin
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) +
    '..\..\..\..\RecorderLnx\Assets\SvgTemplates\parametric-dual-gauge.svg');
end;

function IsDialBackground(const APixel: TBGRAPixel): Boolean;
begin
  Result := (Abs(Integer(APixel.red) - 200) <= 6) and
    (Abs(Integer(APixel.green) - 200) <= 6) and
    (Abs(Integer(APixel.blue) - 200) <= 6);
end;

procedure CheckContinuousGaugeScale;
var
  I, lAngle, lX, lY: Integer;
  lBitmap: TBGRABitmap;
  lParameters: TStringList;
  lSource, lTemplateName: string;
  lSvg: TBGRASVG;
begin
  lTemplateName := GaugeTemplateFileName;
  Check(FileExists(lTemplateName), 'gauge template not found: ' + lTemplateName);

  lParameters := TStringList.Create;
  lSvg := TBGRASVG.Create;
  lBitmap := nil;
  try
    lParameters.NameValueSeparator := '=';
    ExtractSvgParameters(lTemplateName, lParameters);
    lSource := LoadSvgText(lTemplateName);
    for I := 0 to lParameters.Count - 1 do
      lSource := ReplaceSvgParameter(lSource, lParameters.Names[I],
        EscapeSvgParameterValue(lParameters.ValueFromIndex[I]));

    lSource := ResolveSvgRendererExpressions(lSource);
    lSvg.AsUTF8String := lSource;
    lBitmap := RenderSvgContent(lSvg, 700, 540);
    { The coloured band is centred at radius 198. Every sampled angle must
      differ from the grey dial; otherwise a renderer split the scale. }
    for lAngle := 0 to 359 do
    begin
      lX := Round(350 + 198 * Sin(DegToRad(lAngle)));
      lY := Round(235 - 198 * Cos(DegToRad(lAngle)));
      Check(not IsDialBackground(lBitmap.GetPixel(lX, lY)),
        Format('gauge scale gap at %d degrees', [lAngle]));
    end;
    lBitmap.SaveToFile(ChangeFileExt(ParamStr(0), '.gauge.png'));
  finally
    lBitmap.Free;
    lSvg.Free;
    lParameters.Free;
  end;
end;

var
  ErrorText: string;
begin
  CheckParameterEditingHelpers;
  Check(ValidateSvgParameterTemplate(
    '<svg><circle style="fill:{{EyeColor|#121212}};stroke:#000"/></svg>',
    ErrorText), 'legacy EyeColor style rejected: ' + ErrorText);
  Check(not ValidateSvgParameterTemplate(
    '<svg><circle style="filter:{{Effect|url(x)}}"/></svg>', ErrorText),
    'unsafe style property accepted');
  Check(not ValidateSvgParameterValue(
    '<svg><circle style="fill:{{EyeColor|#121212}}"/></svg>',
    'EyeColor', 'url(http://bad)', ErrorText), 'unsafe URL accepted');
  Check(not ValidateSvgParameterValue(
    '<svg><text style="font-family:{{Font|Arial}}">x</text></svg>',
    'Font', 'expression(alert(1))', ErrorText), 'expression accepted');
  CheckContinuousGaugeScale;
  Writeln('RESULT SvgParameters passed');
end.
