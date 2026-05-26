unit uOglChartFontMng;

{$mode objfpc}{$H+}

interface

type
  cChartFontKind = (
    cfPageCaption,
    cfAxisLabel,
    cfAxisSelected,
    cfGridTick,
    cfLegend,
    cfDebug
  );

  cOglFont = class(TObject)
  private
    fName: string;
    fScale: Single;
    fColor: Cardinal;
    fBold: Boolean;
  public
    constructor Create(const AName: string; AScale: Single; AColor: Cardinal; ABold: Boolean);
    function CharPixelWidth(AChar: Char): Integer;
    function TextPixelWidth(const AText: string): Integer;
    function TextPixelHeight: Integer;
    function HitCharIndex(const AText: string; AX, ATextLeft: Integer): Integer;

    property Name: string read fName write fName;
    property Scale: Single read fScale write fScale;
    property Color: Cardinal read fColor write fColor;
    property Bold: Boolean read fBold write fBold;
  end;

  cOglFontMng = class(TObject)
  private
    fFonts: array[cChartFontKind] of cOglFont;
  public
    constructor Create;
    destructor Destroy; override;

    function Font(AKind: cChartFontKind): cOglFont;
  end;

implementation

uses
  Math;

constructor cOglFont.Create(const AName: string; AScale: Single; AColor: Cardinal; ABold: Boolean);
begin
  inherited Create;
  fName := AName;
  fScale := AScale;
  fColor := AColor;
  fBold := ABold;
end;

function cOglFont.CharPixelWidth(AChar: Char): Integer;
begin
  if AChar = ' ' then
    Result := Round(4 * fScale)
  else
    Result := Round(6 * fScale);
  if fBold then
    Inc(Result);
end;

function cOglFont.TextPixelWidth(const AText: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(AText) do
    Inc(Result, CharPixelWidth(AText[I]));
end;

function cOglFont.TextPixelHeight: Integer;
begin
  Result := Max(1, Round(7 * fScale));
end;

function cOglFont.HitCharIndex(const AText: string; AX, ATextLeft: Integer): Integer;
var
  I: Integer;
  lX: Integer;
begin
  Result := Length(AText) + 1;
  lX := ATextLeft;
  for I := 1 to Length(AText) do
  begin
    if AX < lX + CharPixelWidth(AText[I]) div 2 then
      Exit(I);
    Inc(lX, CharPixelWidth(AText[I]));
  end;
end;

constructor cOglFontMng.Create;
begin
  inherited Create;
  fFonts[cfPageCaption] := cOglFont.Create('PageCaption', 1.8, $FF303030, True);
  fFonts[cfAxisLabel] := cOglFont.Create('AxisLabel', 1.55, $FF404040, False);
  fFonts[cfAxisSelected] := cOglFont.Create('AxisSelected', 1.55, $FF202020, True);
  fFonts[cfGridTick] := cOglFont.Create('GridTick', 1.45, $FF505050, False);
  fFonts[cfLegend] := cOglFont.Create('Legend', 1.65, $FF303030, False);
  fFonts[cfDebug] := cOglFont.Create('Debug', 1.45, $FF806020, False);
end;

destructor cOglFontMng.Destroy;
var
  lKind: cChartFontKind;
begin
  for lKind := Low(cChartFontKind) to High(cChartFontKind) do
    fFonts[lKind].Free;
  inherited Destroy;
end;

function cOglFontMng.Font(AKind: cChartFontKind): cOglFont;
begin
  Result := fFonts[AKind];
end;

end.
