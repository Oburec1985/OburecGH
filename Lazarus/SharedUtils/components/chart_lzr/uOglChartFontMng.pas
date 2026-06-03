unit uOglChartFontMng;

{$mode objfpc}{$H+}

{
  Модуль uOglChartFontMng
  Описание: Управляет шрифтами отрисовки в OpenGL (вычисление пиксельной ширины символов,
            высоты текста, определение символа под курсором мыши).
}

interface

var
  gUseTextureAtlas: Boolean = True;

type
  { cChartFontKind }
  // Типы шрифтов для различных элементов чарта
  cChartFontKind = (
    cfPageCaption,   // Заголовок страницы
    cfAxisLabel,     // Подписи осей
    cfAxisSelected,  // Подпись выделенной оси
    cfGridTick,      // Деления сетки
    cfLegend,        // Легенда графика
    cfDebug          // Отладочная информация
  );

  { cOglFont }
  // Класс шрифта, используемый для вычисления метрик текста.
    { cOglCharCoord }
  cOglCharCoord = record
    X1, Y1, X2, Y2: Single;
    Width: Single;
  end;

  { cOglFont }
  cOglFont = class(TObject)
  private
    fName: string;
    fScale: Single;
    fColor: Cardinal;
    fBold: Boolean;
    
    // Новые поля для текстурного атласа
    fTextureId: Cardinal;
    fTextHeight: Integer;
    fCharCoords: array of cOglCharCoord;
    fWideCharsCache: WideString;
    procedure BuildTextureAtlas;
    function GetSupportedCharIndex(AChar: WideChar): Integer;
    procedure DrawTextSoftware(const AText: string; AX, AY: Single);
    procedure DrawTextHardware(const AText: string; AX, AY: Single);
    
    // Сеттеры для обновления текстурного атласа
    procedure SetName(const AValue: string);
    procedure SetScale(AValue: Single);
    procedure SetColor(AValue: Cardinal);
    procedure SetBold(AValue: Boolean);
  private
    fPageCaptionFontSize: Integer;
  public
    constructor Create(const AName: string; AScale: Single; AColor: Cardinal; ABold: Boolean);
    destructor Destroy; override;
    
    procedure DrawText(const AText: string; AX, AY: Single);
    function CharPixelWidth(AChar: WideChar): Integer;
    function TextPixelWidth(const AText: string): Integer;
    function TextPixelHeight: Integer;
    function HitCharIndex(const AText: string; AX, ATextLeft: Integer): Integer;

    property Name: string read fName write SetName;
    property Scale: Single read fScale write SetScale;
    property Color: Cardinal read fColor write SetColor;
    property Bold: Boolean read fBold write SetBold;
  end;

  { cOglFontMng }
  // Менеджер шрифтов чарта, содержащий преднастроенные шрифты для всех типов cChartFontKind.
  cOglFontMng = class(TObject)
  private
    fFonts: array[cChartFontKind] of cOglFont; // Набор преднастроенных шрифтов
  public
    constructor Create;
    destructor Destroy; override;

    // Возвращает объект шрифта по его типу
    function Font(AKind: cChartFontKind): cOglFont;
  end;

implementation

uses
  Math, gl, glext, Graphics;

{ cOglFont }

function UpCaseWide(AChar: WideChar): WideChar;
begin
  if (AChar >= #$0430) and (AChar <= #$044F) then
    Result := WideChar(Ord(AChar) - 32)
  else if AChar = #$0451 then
    Result := #$0401
  else if (AChar >= 'a') and (AChar <= 'z') then
    Result := WideChar(Ord(AChar) - 32)
  else
    Result := AChar;
end;

function GlyphRow(AChar: WideChar; ARow: Integer): string;
begin
  Result := '00000';
  case UpCaseWide(AChar) of
    'A': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11111'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'B': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    'C': case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10000'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '01111'; end;
    'D': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    'E': case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '11111'; end;
    'F': case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '10000'; end;
    'G': case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10011'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01111'; end;
    'H': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11111'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'I': case ARow of 0: Result := '11111'; 1: Result := '00100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '11111'; end;
    'J': case ARow of 0: Result := '00111'; 1: Result := '00010'; 2: Result := '00010'; 3: Result := '00010'; 4: Result := '10010'; 5: Result := '10010'; 6: Result := '01100'; end;
    'K': case ARow of 0: Result := '10001'; 1: Result := '10010'; 2: Result := '10100'; 3: Result := '11000'; 4: Result := '10100'; 5: Result := '10010'; 6: Result := '10001'; end;
    'L': case ARow of 0: Result := '10000'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10000'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '11111'; end;
    'M': case ARow of 0: Result := '10001'; 1: Result := '11011'; 2: Result := '10101'; 3: Result := '10101'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'N': case ARow of 0: Result := '10001'; 1: Result := '11001'; 2: Result := '10101'; 3: Result := '10011'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'O': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    'P': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '10000'; end;
    'Q': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10101'; 5: Result := '10010'; 6: Result := '01101'; end;
    'R': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10100'; 5: Result := '10010'; 6: Result := '10001'; end;
    'S': case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '01110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    'T': case ARow of 0: Result := '11111'; 1: Result := '00100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '00100'; end;
    'U': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    'V': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '01010'; 5: Result := '01010'; 6: Result := '00100'; end;
    'W': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10101'; 4: Result := '10101'; 5: Result := '10101'; 6: Result := '01010'; end;
    'X': case ARow of 0: Result := '10001'; 1: Result := '01010'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '01010'; 6: Result := '10001'; end;
    'Y': case ARow of 0: Result := '10001'; 1: Result := '01010'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '00100'; end;
    'Z': case ARow of 0: Result := '11111'; 1: Result := '00001'; 2: Result := '00010'; 3: Result := '00100'; 4: Result := '01000'; 5: Result := '10000'; 6: Result := '11111'; end;
    '0': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10011'; 3: Result := '10101'; 4: Result := '11001'; 5: Result := '10001'; 6: Result := '01110'; end;
    '1': case ARow of 0: Result := '00100'; 1: Result := '01100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '01110'; end;
    '2': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '00001'; 3: Result := '00010'; 4: Result := '00100'; 5: Result := '01000'; 6: Result := '11111'; end;
    '3': case ARow of 0: Result := '11110'; 1: Result := '00001'; 2: Result := '00001'; 3: Result := '01110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    '4': case ARow of 0: Result := '00010'; 1: Result := '00110'; 2: Result := '01010'; 3: Result := '10010'; 4: Result := '11111'; 5: Result := '00010'; 6: Result := '00010'; end;
    '5': case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    '6': case ARow of 0: Result := '01110'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    '7': case ARow of 0: Result := '11111'; 1: Result := '00001'; 2: Result := '00010'; 3: Result := '00100'; 4: Result := '01000'; 5: Result := '01000'; 6: Result := '01000'; end;
    '8': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '01110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    '9': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '01111'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '01110'; end;
    '.': if ARow = 6 then Result := '00100';
    ',': case ARow of 5: Result := '00100'; 6: Result := '01000'; end;
    '-': if ARow = 3 then Result := '01110';
    '_': if ARow = 6 then Result := '11111';
    #$0410: case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11111'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$0411: case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    #$0412: case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    #$0413: case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10000'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '10000'; end;
    #$0414: case ARow of 0: Result := '01110'; 1: Result := '01010'; 2: Result := '01010'; 3: Result := '01010'; 4: Result := '01010'; 5: Result := '11111'; 6: Result := '10001'; end;
    #$0415: case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '11111'; end;
    #$0416: case ARow of 0: Result := '10101'; 1: Result := '10101'; 2: Result := '01110'; 3: Result := '00100'; 4: Result := '01110'; 5: Result := '10101'; 6: Result := '10101'; end;
    #$0417: case ARow of 0: Result := '11110'; 1: Result := '00001'; 2: Result := '00010'; 3: Result := '01100'; 4: Result := '00010'; 5: Result := '00001'; 6: Result := '11110'; end;
    #$0418: case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10011'; 3: Result := '10101'; 4: Result := '11001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$0419: case ARow of 0: Result := '10101'; 1: Result := '10001'; 2: Result := '10011'; 3: Result := '10101'; 4: Result := '11001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$041A: case ARow of 0: Result := '10001'; 1: Result := '10010'; 2: Result := '10100'; 3: Result := '11000'; 4: Result := '10100'; 5: Result := '10010'; 6: Result := '10001'; end;
    #$041B: case ARow of 0: Result := '01111'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$041C: case ARow of 0: Result := '10001'; 1: Result := '11011'; 2: Result := '10101'; 3: Result := '10101'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$041D: case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11111'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$041E: case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    #$041F: case ARow of 0: Result := '11111'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$0420: case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '10000'; end;
    #$0421: case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10000'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '01111'; end;
    #$0422: case ARow of 0: Result := '11111'; 1: Result := '00100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '00100'; end;
    #$0423: case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '01010'; 3: Result := '00100'; 4: Result := '01000'; 5: Result := '10000'; 6: Result := '10000'; end;
    #$0424: case ARow of 0: Result := '00100'; 1: Result := '01110'; 2: Result := '10101'; 3: Result := '10101'; 4: Result := '01110'; 5: Result := '00100'; 6: Result := '00100'; end;
    #$0425: case ARow of 0: Result := '10001'; 1: Result := '01010'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '01010'; 6: Result := '10001'; end;
    #$0426: case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '11111'; 6: Result := '00001'; end;
    #$0427: case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '01111'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '00001'; end;
    #$0428: case ARow of 0: Result := '10101'; 1: Result := '10101'; 2: Result := '10101'; 3: Result := '10101'; 4: Result := '10101'; 5: Result := '11111'; 6: Result := '00000'; end;
    #$0429: case ARow of 0: Result := '10101'; 1: Result := '10101'; 2: Result := '10101'; 3: Result := '10101'; 4: Result := '10101'; 5: Result := '11111'; 6: Result := '00001'; end;
    #$042A: case ARow of 0: Result := '11000'; 1: Result := '01000'; 2: Result := '01000'; 3: Result := '01110'; 4: Result := '01001'; 5: Result := '01001'; 6: Result := '01110'; end;
    #$042B: case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11101'; 4: Result := '10011'; 5: Result := '10011'; 6: Result := '11101'; end;
    #$042C: case ARow of 0: Result := '10000'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    #$042D: case ARow of 0: Result := '11110'; 1: Result := '00001'; 2: Result := '00001'; 3: Result := '01110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    #$042E: case ARow of 0: Result := '10001'; 1: Result := '10101'; 2: Result := '10101'; 3: Result := '11111'; 4: Result := '10101'; 5: Result := '10101'; 6: Result := '10001'; end;
    #$042F: case ARow of 0: Result := '01111'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '01111'; 4: Result := '01001'; 5: Result := '10001'; 6: Result := '10001'; end;
    #$0401: case ARow of 0: Result := '01010'; 1: Result := '11111'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '11111'; end;
  end;

end;

constructor cOglFont.Create(const AName: string; AScale: Single; AColor: Cardinal; ABold: Boolean);
var
  lWS: WideString;
  I: Integer;
begin
  inherited Create;
  fName := AName;
  fScale := AScale;
  fColor := AColor;
  fBold := ABold;
  fTextureId := 0;
  fTextHeight := 0;
  
  lWS := '';
  for I := 32 to 126 do
    lWS := lWS + WideChar(I);
  lWS := lWS + WideChar($0401); // 'Ё'
  for I := $0410 to $044F do
    lWS := lWS + WideChar(I);   // 'А'..'я'
  lWS := lWS + WideChar($0451); // 'ё'
  
  fWideCharsCache := lWS;
end;

destructor cOglFont.Destroy;
begin
  if fTextureId <> 0 then
    glDeleteTextures(1, @fTextureId);
  inherited Destroy;
end;

procedure cOglFont.SetName(const AValue: string);
begin
  if fName <> AValue then
  begin
    fName := AValue;
    if fTextureId <> 0 then
    begin
      glDeleteTextures(1, @fTextureId);
      fTextureId := 0;
    end;
  end;
end;

procedure cOglFont.SetScale(AValue: Single);
begin
  if fScale <> AValue then
  begin
    fScale := AValue;
    if fTextureId <> 0 then
    begin
      glDeleteTextures(1, @fTextureId);
      fTextureId := 0;
    end;
  end;
end;

procedure cOglFont.SetColor(AValue: Cardinal);
begin
  fColor := AValue;
end;

procedure cOglFont.SetBold(AValue: Boolean);
begin
  if fBold <> AValue then
  begin
    fBold := AValue;
    if fTextureId <> 0 then
    begin
      glDeleteTextures(1, @fTextureId);
      fTextureId := 0;
    end;
  end;
end;

function cOglFont.GetSupportedCharIndex(AChar: WideChar): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(fWideCharsCache) do
    if fWideCharsCache[I] = AChar then
      Exit(I);
end;

procedure cOglFont.BuildTextureAtlas;
var
  lBitmap: TBitmap;
  lWidth, lHeight: Integer;
  lChar: WideChar;
  lText: string;
  lX, lY: Integer;
  I: Integer;
  lCharWidth: Integer;
  lPixelPtr: PDWord;
  lColorVal: Cardinal;
  lAlpha: Byte;
  lRow, lCol: Integer;
  lTexWidth, lTexHeight: Integer;
  lRawData: PByte;
  lLineStride: Integer;
begin
  if fTextureId <> 0 then
  begin
    glDeleteTextures(1, @fTextureId);
    fTextureId := 0;
  end;

  lBitmap := TBitmap.Create;
  try
    lBitmap.PixelFormat := pf32bit;
    lBitmap.Canvas.Font.Name := fName;
    
    lBitmap.Canvas.Font.Size := Round(fScale * 7.2);
    if fBold then
      lBitmap.Canvas.Font.Style := [fsBold]
    else
      lBitmap.Canvas.Font.Style := [];

    lHeight := lBitmap.Canvas.TextHeight('A');
    if lHeight < 1 then lHeight := 1;

    lTexWidth := 2048;
    lTexHeight := 16;
    while lTexHeight < lHeight do
      lTexHeight := lTexHeight * 2;

    lBitmap.Width := lTexWidth;
    lBitmap.Height := lTexHeight;

    lBitmap.Canvas.Brush.Color := clBlack;
    lBitmap.Canvas.FillRect(0, 0, lTexWidth, lTexHeight);

    lBitmap.Canvas.Font.Color := clWhite;
    lBitmap.Canvas.Brush.Style := bsClear;

    lX := 0;
    SetLength(fCharCoords, Length(fWideCharsCache) + 1);
    
    for I := 1 to Length(fWideCharsCache) do
    begin
      lChar := fWideCharsCache[I];
      lText := UTF8Encode(WideString(lChar));
      lCharWidth := lBitmap.Canvas.TextWidth(lText);
      
      if lX + lCharWidth >= lTexWidth then
        lCharWidth := lTexWidth - lX;

      lBitmap.Canvas.TextOut(lX, 0, lText);

      fCharCoords[I].X1 := lX / lTexWidth;
      fCharCoords[I].Y1 := 0;
      fCharCoords[I].X2 := (lX + lCharWidth) / lTexWidth;
      fCharCoords[I].Y2 := lHeight / lTexHeight;
      fCharCoords[I].Width := lCharWidth;

      lX := lX + lCharWidth;
    end;

    lRawData := lBitmap.RawImage.Data;
    lLineStride := lBitmap.RawImage.Description.BytesPerLine;
    for lRow := 0 to lTexHeight - 1 do
    begin
      lPixelPtr := PDWord(lRawData + lRow * lLineStride);
      for lCol := 0 to lTexWidth - 1 do
      begin
        lColorVal := lPixelPtr^;
        lAlpha := lColorVal and $FF;
        lPixelPtr^ := (Cardinal(lAlpha) shl 24) or $00FFFFFF;
        Inc(lPixelPtr);
      end;
    end;

    glGenTextures(1, @fTextureId);
    glBindTexture(GL_TEXTURE_2D, fTextureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, lTexWidth, lTexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, lRawData);

    fTextHeight := lHeight;
  finally
    lBitmap.Free;
  end;
end;

procedure cOglFont.DrawText(const AText: string; AX, AY: Single);
begin
  if not gUseTextureAtlas then
  begin
    DrawTextSoftware(AText, AX, AY);
    Exit;
  end;
  DrawTextHardware(AText, AX, AY);
end;

procedure cOglFont.DrawTextSoftware(const AText: string; AX, AY: Single);
var
  I: Integer;
  lRow: Integer;
  lCol: Integer;
  lGlyphRow: string;
  lX: Single;
  lY: Single;
  lAdvanceX: Single;
  lWideText: WideString;
  r, g, b, a: Byte;
begin
  lWideText := UTF8Decode(AText);
  r := Byte(fColor);
  g := Byte(fColor shr 8);
  b := Byte(fColor shr 16);
  a := Byte(fColor shr 24);
  glColor4ub(r, g, b, a);
  
  glBegin(GL_QUADS);
  for I := 1 to Length(lWideText) do
    for lRow := 0 to 6 do
    begin
      lGlyphRow := GlyphRow(lWideText[I], lRow);
      for lCol := 1 to Length(lGlyphRow) do
        if lGlyphRow[lCol] = '1' then
        begin
          lAdvanceX := TextPixelWidth(UTF8Encode(Copy(lWideText, 1, I - 1)));
          lX := AX + lAdvanceX + (lCol - 1) * fScale;
          lY := AY + lRow * fScale;
          glVertex2f(lX, lY);
          glVertex2f(lX + fScale, lY);
          glVertex2f(lX + fScale, lY + fScale);
          glVertex2f(lX, lY + fScale);
          if fBold then
          begin
            glVertex2f(lX + 1, lY);
            glVertex2f(lX + fScale + 1, lY);
            glVertex2f(lX + fScale + 1, lY + fScale);
            glVertex2f(lX + 1, lY + fScale);
          end;
        end;
    end;
  glEnd;
end;

procedure cOglFont.DrawTextHardware(const AText: string; AX, AY: Single);
var
  I: Integer;
  lWideText: WideString;
  lCharIdx: Integer;
  lX, lY: Single;
  lWidth: Single;
  r, g, b, a: Byte;
begin
  if fTextureId = 0 then
    BuildTextureAtlas;

  if fTextureId = 0 then
    Exit;

  lWideText := UTF8Decode(AText);
  
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, fTextureId);
  
  r := Byte(fColor);
  g := Byte(fColor shr 8);
  b := Byte(fColor shr 16);
  a := Byte(fColor shr 24);
  glColor4ub(r, g, b, a);

  glBegin(GL_QUADS);
  lX := AX;
  lY := AY;
  for I := 1 to Length(lWideText) do
  begin
    lCharIdx := GetSupportedCharIndex(lWideText[I]);
    if lCharIdx > 0 then
    begin
      lWidth := fCharCoords[lCharIdx].Width;
      
      glTexCoord2f(fCharCoords[lCharIdx].X1, fCharCoords[lCharIdx].Y2);
      glVertex2f(lX, lY + fTextHeight);
      
      glTexCoord2f(fCharCoords[lCharIdx].X2, fCharCoords[lCharIdx].Y2);
      glVertex2f(lX + lWidth, lY + fTextHeight);
      
      glTexCoord2f(fCharCoords[lCharIdx].X2, fCharCoords[lCharIdx].Y1);
      glVertex2f(lX + lWidth, lY);
      
      glTexCoord2f(fCharCoords[lCharIdx].X1, fCharCoords[lCharIdx].Y1);
      glVertex2f(lX, lY);

      lX := lX + lWidth;
    end
    else
    begin
      lX := lX + CharPixelWidth(lWideText[I]);
    end;
  end;
  glEnd;

  glDisable(GL_TEXTURE_2D);
  glDisable(GL_BLEND);
end;


/// <summary>
/// Вычисляет пиксельную ширину символа на основе масштаба и стиля Bold.
/// </summary>
function cOglFont.CharPixelWidth(AChar: WideChar): Integer;
var
  lIdx: Integer;
begin
  if not gUseTextureAtlas then
  begin
    if AChar = ' ' then
      Result := Round(4 * fScale)
    else
      Result := Round(6 * fScale);
    if fBold then
      Inc(Result);
    Exit;
  end;

  if fTextureId = 0 then
    BuildTextureAtlas;

  lIdx := GetSupportedCharIndex(AChar);
  if lIdx > 0 then
    Result := Round(fCharCoords[lIdx].Width)
  else
  begin
    if AChar = ' ' then
      Result := Round(fTextHeight * 0.3)
    else
      Result := Round(fTextHeight * 0.5);
  end;
end;

/// <summary>
/// Вычисляет суммарную пиксельную ширину всей строки.
/// </summary>
function cOglFont.TextPixelWidth(const AText: string): Integer;
var
  I: Integer;
  lWideText: WideString;
begin
  lWideText := UTF8Decode(AText);
  Result := 0;
  for I := 1 to Length(lWideText) do
    Inc(Result, CharPixelWidth(lWideText[I]));
end;

/// <summary>
/// Возвращает высоту строки текста в пикселях с учетом масштаба.
/// </summary>
function cOglFont.TextPixelHeight: Integer;
begin
  if not gUseTextureAtlas then
  begin
    Result := Max(1, Round(7 * fScale));
    Exit;
  end;

  if fTextureId = 0 then
    BuildTextureAtlas;
  Result := fTextHeight;
end;

/// <summary>
/// Нахождение индекса символа в строке по координате клика.
/// </summary>
/// <param name="AText">Строка текста</param>
/// <param name="AX">Координата X клика</param>
/// <param name="ATextLeft">Начальная координата X отрисованного текста</param>
function cOglFont.HitCharIndex(const AText: string; AX, ATextLeft: Integer): Integer;
var
  I: Integer;
  lX: Integer;
  lWideText: WideString;
begin
  lWideText := UTF8Decode(AText);
  Result := Length(lWideText) + 1;
  lX := ATextLeft;
  for I := 1 to Length(lWideText) do
  begin
    if AX < lX + CharPixelWidth(lWideText[I]) div 2 then
      Exit(I);
    Inc(lX, CharPixelWidth(lWideText[I]));
  end;
end;

{ cOglFontMng }

/// <summary>
/// Конструктор менеджера: инициализирует стандартный набор шрифтов с предопределенными масштабами и цветами.
/// </summary>
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
  // Уничтожаем каждый шрифт в массиве
  for lKind := Low(cChartFontKind) to High(cChartFontKind) do
    fFonts[lKind].Free;
  inherited Destroy;
end;

function cOglFontMng.Font(AKind: cChartFontKind): cOglFont;
begin
  Result := fFonts[AKind];
end;

end.
