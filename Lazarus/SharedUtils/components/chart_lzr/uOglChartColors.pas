unit uOglChartColors;

{
  Standard chart line palette (same order as legacy cChart / wpgLine).
  Index 0 = blue, 1 = green, 2 = red, ...
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Graphics;

const
  OGL_CHART_LINE_COLOR_COUNT = 14;

function OglChartLinePaletteColor(AIndex: Integer): TColor;
function OglChartLinePaletteGLColor(AIndex: Integer): Cardinal;
function OglChartLinePaletteName(AIndex: Integer): string;
function OglChartLinePaletteIndexForColor(AColor: TColor): Integer;
function OglChartLinePaletteNameForColor(AColor: TColor): string;
function OglChartColorToGL(AColor: TColor): Cardinal;
procedure OglChartLineAppearance(AChartLineIndex: Integer; out AName: string;
  out AColor: LongInt);

implementation

const
  { BGR order, matches wpgLineSett::m_Colors from the Delphi chart component. }
  CLineColors: array[0..OGL_CHART_LINE_COLOR_COUNT - 1] of TColor = (
    $00FF0000, $00008000, $000000FF, $00800000, $0000FF00, $00FFFF00,
    $00FF8000, $00FF0080, $00FF00FF, $008080FF, $000080FF, $00008080,
    $00004080, $00000040
  );

  CLineColorNames: array[0..OGL_CHART_LINE_COLOR_COUNT - 1] of string = (
    'РЎРёРЅРёР№', 'Р—РµР»С‘РЅС‹Р№', 'РљСЂР°СЃРЅС‹Р№', 'РўС‘РјРЅРѕ-СЃРёРЅРёР№', 'Р›Р°Р№Рј', 'Р‘РёСЂСЋР·РѕРІС‹Р№',
    'Р“РѕР»СѓР±РѕР№', 'Р¤РёРѕР»РµС‚РѕРІС‹Р№', 'РџСѓСЂРїСѓСЂРЅС‹Р№', 'Р РѕР·РѕРІС‹Р№', 'РћСЂР°РЅР¶РµРІС‹Р№', 'РћР»РёРІРєРѕРІС‹Р№',
    'РљРѕСЂРёС‡РЅРµРІС‹Р№', 'Р‘РѕСЂРґРѕРІС‹Р№'
  );

function OglChartNormalizeIndex(AIndex: Integer): Integer;
begin
  Result := AIndex mod OGL_CHART_LINE_COLOR_COUNT;
  if Result < 0 then
    Result := Result + OGL_CHART_LINE_COLOR_COUNT;
end;

function OglChartLinePaletteColor(AIndex: Integer): TColor;
begin
  Result := CLineColors[OglChartNormalizeIndex(AIndex)];
end;

function OglChartColorToGL(AColor: TColor): Cardinal;
begin
  Result := (LongWord(AColor) and $00FFFFFF) or $FF000000;
end;

function OglChartLinePaletteGLColor(AIndex: Integer): Cardinal;
begin
  Result := OglChartColorToGL(OglChartLinePaletteColor(AIndex));
end;

function OglChartLinePaletteName(AIndex: Integer): string;
begin
  Result := CLineColorNames[OglChartNormalizeIndex(AIndex)];
end;

function OglChartLinePaletteIndexForColor(AColor: TColor): Integer;
var
  I: Integer;
  lColor: LongInt;
begin
  lColor := LongInt(AColor) and $00FFFFFF;
  for I := 0 to OGL_CHART_LINE_COLOR_COUNT - 1 do
    if (LongInt(CLineColors[I]) and $00FFFFFF) = lColor then
      Exit(I);
  Result := -1;
end;

function OglChartLinePaletteNameForColor(AColor: TColor): string;
var
  lIndex: Integer;
begin
  lIndex := OglChartLinePaletteIndexForColor(AColor);
  if lIndex >= 0 then
    Result := OglChartLinePaletteName(lIndex)
  else
    Result := '';
end;

procedure OglChartLineAppearance(AChartLineIndex: Integer; out AName: string;
  out AColor: LongInt);
var
  lIndex: Integer;
begin
  lIndex := OglChartNormalizeIndex(AChartLineIndex);
  AColor := LongInt(OglChartLinePaletteColor(lIndex));
  AName := OglChartLinePaletteName(lIndex);
end;

end.