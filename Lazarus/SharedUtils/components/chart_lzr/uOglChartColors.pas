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
  OGL_CHART_LINE_COLOR_COUNT = 18;

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
  { Палитра основана на ColorArray из uCommonTypes проекта plgControlCyclogram.
    Значения point3 RGB переведены в системный BGR-формат TColor.
    Второй цвет намеренно затемнён до травяного зелёного. Цвет с индексом 5
    задан пользователем как RGB(0, 128, 128). }
  CLineColors: array[0..OGL_CHART_LINE_COLOR_COUNT - 1] of TColor = (
    $00FF0000, $00228B22, $000000FF, $00168EDA, $00C50040, $00808000,
    $009E544C, $00C710E2, $00E8BA7D, $007AE0C4, $00577A3B, $002E1C85,
    $009640E8, $005E701A, $005440CC, $002100E3, $00A67A00, $001FA89E
  );

  CLineColorNames: array[0..OGL_CHART_LINE_COLOR_COUNT - 1] of string = (
    'Синий', 'Травяной зелёный', 'Красный', 'Оранжевый', 'Пурпурный', 'Бирюзовый',
    'Фиолетовый', 'Сиреневый', 'Aero', 'Alien Armpit', 'Amazon',
    'Antique Ruby', 'Barbie Pink', 'Bittersweet', 'Brick Red', 'Cadmium Red',
    'Cerulean', 'Citron'
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
