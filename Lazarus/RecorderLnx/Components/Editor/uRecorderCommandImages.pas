unit uRecorderCommandImages;

{
  Модуль uRecorderCommandImages

  Назначение:
    ? ? ? ? RecorderLnx. ? ? ? ?
    Recorder (rc_ctrpn/res/v3, rc_guisrv/res, images/), ? ? ? ?.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Graphics, ImgList, uRcIconIds;

procedure ValidateRecorderCommandImages(AImages: TCustomImageList);
procedure RegenerateRecorderDesignerIcons(AImages: TCustomImageList);

implementation

uses
  Types, LResources;

const
  CRecorderImagesDir = 'D:\works\windev-v3.9\images';
  CWindevRoot = 'D:\works\windev-v3.9\';

function ImageFile(const ARelativeName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(CRecorderImagesDir) + ARelativeName;
end;

function FirstExistingFile(const APaths: array of string): string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(APaths) to High(APaths) do
    if (APaths[I] <> '') and FileExists(APaths[I]) then
      Exit(APaths[I]);
end;

procedure AddBitmapFile(AImages: TCustomImageList; const AFileName: string);
var
  lBitmap: TBitmap;
begin
  lBitmap := TBitmap.Create;
  try
    if FileExists(AFileName) then
      lBitmap.LoadFromFile(AFileName);
    AImages.Add(lBitmap, nil);
  finally
    lBitmap.Free;
  end;
end;

procedure ScaleBitmapToImageListSize(ABitmap: TBitmap; ASize: Integer);
var
  lScaled: TBitmap;
begin
  if (ABitmap = nil) or (ABitmap.Width = 0) or (ABitmap.Height = 0) then
    Exit;
  if (ABitmap.Width = ASize) and (ABitmap.Height = ASize) then
    Exit;
  lScaled := TBitmap.Create;
  try
    lScaled.SetSize(ASize, ASize);
    lScaled.Canvas.StretchDraw(Rect(0, 0, ASize, ASize), ABitmap);
    ABitmap.Assign(lScaled);
  finally
    lScaled.Free;
  end;
end;

function BitmapUsesFuchsiaBackground(ABitmap: TBitmap): Boolean;
begin
  Result := (ABitmap <> nil)
    and (ABitmap.Canvas.Pixels[0, 0] = clFuchsia);
end;

function CreateMaskFromTransparentBitmap(ABitmap: TBitmap): TBitmap;
var
  X, Y: Integer;
  lColor: TColor;
begin
  Result := TBitmap.Create;
  Result.SetSize(ABitmap.Width, ABitmap.Height);
  Result.PixelFormat := pf24bit;
  for Y := 0 to ABitmap.Height - 1 do
    for X := 0 to ABitmap.Width - 1 do
    begin
      lColor := ABitmap.Canvas.Pixels[X, Y];
      if (ABitmap.Transparent)
        and (lColor = ABitmap.TransparentColor) then
        Result.Canvas.Pixels[X, Y] := clWhite
      else
        Result.Canvas.Pixels[X, Y] := clBlack;
    end;
end;

procedure PrepareBitmapForImageList(ABitmap: TBitmap; ASize: Integer);
begin
  ScaleBitmapToImageListSize(ABitmap, ASize);
  if BitmapUsesFuchsiaBackground(ABitmap) then
  begin
    ABitmap.TransparentColor := clFuchsia;
    ABitmap.Transparent := True;
  end;
end;

function TryLoadSaveBitmapFromRecorder(ASaveAs: Boolean): TBitmap;
const
  CSize = 42;
var
  lFileName: string;
begin
  Result := nil;
  if ASaveAs then
    lFileName := FirstExistingFile([
      CWindevRoot + 'rc_ctrpn\res\v3\menu_save_as.bmp',
      CWindevRoot + 'rc_guisrv\res\saveas.bmp',
      CWindevRoot + 'images\saveas.bmp'])
  else
    lFileName := FirstExistingFile([
      CWindevRoot + 'rc_ctrpn\res\v3\config_save_normal.bmp',
      CWindevRoot + 'rc_guisrv\res\savecfgd.bmp',
      CWindevRoot + 'images\savecfgd.bmp']);
  if lFileName = '' then
    Exit;
  Result := TBitmap.Create;
  try
    Result.LoadFromFile(lFileName);
    PrepareBitmapForImageList(Result, CSize);
  except
    FreeAndNil(Result);
  end;
end;

procedure DrawSaveConfigGlyph(ACanvas: TCanvas; ASaveAs: Boolean);
const
  CSize = 42;
var
  R: TRect;
begin
  ACanvas.Brush.Color := clFuchsia;
  ACanvas.FillRect(0, 0, CSize, CSize);

  { ? ? }
  ACanvas.Brush.Color := $00B8B8B8;
  ACanvas.Pen.Color := $00505050;
  ACanvas.Rectangle(10, 4, 32, 12);
  ACanvas.Pen.Color := clWhite;
  ACanvas.MoveTo(11, 5);
  ACanvas.LineTo(11, 11);
  ACanvas.LineTo(31, 11);

  { ? ? }
  ACanvas.Brush.Color := $00D0D0D0;
  ACanvas.Pen.Color := $00404040;
  R := Rect(8, 11, 34, 38);
  ACanvas.RoundRect(R, 2, 2);
  ACanvas.Pen.Color := clWhite;
  ACanvas.MoveTo(9, 12);
  ACanvas.LineTo(9, 37);
  ACanvas.MoveTo(9, 12);
  ACanvas.LineTo(33, 12);

  { ? }
  ACanvas.Brush.Color := $00A02828;
  ACanvas.Pen.Color := $00601818;
  ACanvas.Rectangle(12, 18, 30, 30);

  if ASaveAs then
  begin
    { ? ? ? ? ? }
    ACanvas.Brush.Color := clWhite;
    ACanvas.Pen.Color := $00404040;
    R := Rect(20, 20, 39, 39);
    ACanvas.Rectangle(R);
    ACanvas.Pen.Color := $00808080;
    ACanvas.MoveTo(22, 36);
    ACanvas.LineTo(37, 36);
    ACanvas.MoveTo(22, 33);
    ACanvas.LineTo(34, 33);
    ACanvas.MoveTo(22, 30);
    ACanvas.LineTo(37, 30);
    ACanvas.Pen.Color := $000060A0;
    ACanvas.Pen.Width := 2;
    ACanvas.MoveTo(24, 38);
    ACanvas.LineTo(38, 24);
    ACanvas.Pen.Width := 1;
  end;
end;

function CreateSaveConfigBitmap(ASaveAs: Boolean): TBitmap;
begin
  Result := TryLoadSaveBitmapFromRecorder(ASaveAs);
  { В форме уже хранится эталонная кроссплатформенная картинка. Если внешний
    каталог исходников оригинального Recorder недоступен (обычно в Linux),
    нельзя заменять её нарисованным fallback: LCL по-разному обрабатывает его
    маску прозрачности, из-за чего появляется розовый фон. }
end;

procedure EnsureImageListSize(AImages: TCustomImageList; AMinCount: Integer);
begin
  while AImages.Count < AMinCount do
    AddBitmapFile(AImages, '');
end;

procedure RefreshSaveConfigIcons(AImages: TCustomImageList);
var
  lBitmap, lMask: TBitmap;
begin
  if AImages = nil then
    Exit;
  AImages.Width := 42;
  AImages.Height := 42;
  EnsureImageListSize(AImages, CRecorderCommandImageCount);

  lBitmap := CreateSaveConfigBitmap(False);
  try
    if lBitmap <> nil then
    begin
      lMask := CreateMaskFromTransparentBitmap(lBitmap);
      try
        AImages.Replace(CIconSaveConfig, lBitmap, lMask);
      finally
        lMask.Free;
      end;
    end;
  finally
    lBitmap.Free;
  end;

  lBitmap := CreateSaveConfigBitmap(True);
  try
    if lBitmap <> nil then
    begin
      lMask := CreateMaskFromTransparentBitmap(lBitmap);
      try
        AImages.Replace(CIconSaveConfigAs, lBitmap, lMask);
      finally
        lMask.Free;
      end;
    end;
  finally
    lBitmap.Free;
  end;
end;

procedure ReplaceInputFieldIcon(AImages: TCustomImageList);
const
  CSize = 42;
var
  lBitmap: TBitmap;
begin
  lBitmap := TBitmap.Create;
  try
    lBitmap.SetSize(CSize, CSize);
    lBitmap.PixelFormat := pf24bit;
    lBitmap.Transparent := False;
    lBitmap.Canvas.Brush.Color := clWhite;
    lBitmap.Canvas.FillRect(0, 0, CSize, CSize);

    { Рамка редактируемого текста, набранные символы и I-образный курсор
      отличают поле ввода от объёмной кнопки даже в маленькой палитре. }
    lBitmap.Canvas.Brush.Color := clWhite;
    lBitmap.Canvas.Pen.Color := $00606060;
    lBitmap.Canvas.Rectangle(3, 10, 39, 32);
    lBitmap.Canvas.Pen.Color := $00D8D8D8;
    lBitmap.Canvas.MoveTo(4, 11);
    lBitmap.Canvas.LineTo(38, 11);
    lBitmap.Canvas.Font.Color := $00303030;
    lBitmap.Canvas.Font.Size := 9;
    lBitmap.Canvas.TextOut(7, 13, 'abc');
    lBitmap.Canvas.Pen.Color := clBlack;
    lBitmap.Canvas.Pen.Width := 2;
    lBitmap.Canvas.MoveTo(31, 14);
    lBitmap.Canvas.LineTo(31, 28);
    lBitmap.Canvas.MoveTo(28, 14);
    lBitmap.Canvas.LineTo(34, 14);
    lBitmap.Canvas.MoveTo(28, 28);
    lBitmap.Canvas.LineTo(34, 28);
    lBitmap.Canvas.Pen.Width := 1;

    AImages.Replace(CIconInputField, lBitmap, nil);
  finally
    lBitmap.Free;
  end;
end;

procedure DrawPaletteFrame(ACanvas: TCanvas);
begin
  ACanvas.Brush.Color := clWhite;
  ACanvas.Pen.Color := $00606060;
  ACanvas.Rectangle(3, 3, 39, 39);
  ACanvas.Pen.Color := $00C8C8C8;
  ACanvas.MoveTo(8, 8);
  ACanvas.LineTo(8, 35);
  ACanvas.LineTo(35, 35);
end;

procedure DrawPaletteGlyph(ACanvas: TCanvas; AKind: Integer);
const
  CSpectrumHeights: array[0..6] of Integer = (9, 18, 13, 27, 21, 15, 8);
var
  I: Integer;
begin
  DrawPaletteFrame(ACanvas);
  ACanvas.Pen.Width := 2;
  case AKind of
    0, 6: begin
      { Настольный осциллограф: корпус, ЭЛТ-экран и ручки управления. }
      ACanvas.Brush.Color := $00C8C8C8;
      ACanvas.Pen.Color := $00404040;
      ACanvas.Rectangle(3, 7, 39, 36);
      ACanvas.Brush.Color := $00181818;
      ACanvas.Rectangle(6, 10, 29, 32);
      ACanvas.Pen.Color := $00383838;
      ACanvas.Pen.Width := 1;
      ACanvas.MoveTo(7, 17); ACanvas.LineTo(28, 17);
      ACanvas.MoveTo(7, 24); ACanvas.LineTo(28, 24);
      ACanvas.MoveTo(13, 11); ACanvas.LineTo(13, 31);
      ACanvas.MoveTo(21, 11); ACanvas.LineTo(21, 31);
      ACanvas.Pen.Color := clLime;
      ACanvas.Pen.Width := 2;
      ACanvas.MoveTo(7, 22); ACanvas.LineTo(10, 22);
      ACanvas.LineTo(13, 15); ACanvas.LineTo(17, 28);
      ACanvas.LineTo(21, 14); ACanvas.LineTo(25, 23);
      ACanvas.LineTo(28, 21);
      ACanvas.Brush.Color := $00707070;
      ACanvas.Pen.Color := $00303030;
      ACanvas.Ellipse(31, 11, 37, 17);
      ACanvas.Ellipse(31, 21, 37, 27);
      ACanvas.Brush.Color := $00202020;
      ACanvas.Rectangle(31, 30, 37, 33);
      ACanvas.Pen.Width := 1;
      ACanvas.MoveTo(7, 36); ACanvas.LineTo(7, 39);
      ACanvas.MoveTo(35, 36); ACanvas.LineTo(35, 39);
      if AKind = 6 then begin
        ACanvas.Brush.Color := $00E08020;
        ACanvas.Pen.Color := $00804010;
        ACanvas.Ellipse(28, 3, 40, 15);
        ACanvas.Font.Color := clWhite;
        ACanvas.Font.Style := [fsBold];
        ACanvas.Font.Size := 7;
        ACanvas.TextOut(31, 3, 'P');
        ACanvas.Font.Style := [];
      end;
    end;
    1, 2: begin
      ACanvas.Pen.Color := clBlue;
      ACanvas.MoveTo(5, 29); ACanvas.LineTo(11, 18);
      ACanvas.LineTo(16, 25); ACanvas.LineTo(22, 11);
      ACanvas.LineTo(28, 23); ACanvas.LineTo(37, 14);
      if AKind = 2 then begin
        ACanvas.Brush.Color := $00D09030;
        ACanvas.Pen.Color := $00704010;
        ACanvas.Ellipse(25, 26, 38, 31);
        ACanvas.Rectangle(25, 28, 38, 36);
      end;
    end;
    3: begin
      ACanvas.Brush.Color := $0000A020;
      ACanvas.Pen.Color := $00007010;
      for I := 0 to High(CSpectrumHeights) do
        ACanvas.Rectangle(6 + I * 4, 34 - CSpectrumHeights[I],
          9 + I * 4, 35);
    end;
    4: begin
      ACanvas.Pen.Color := $000080D0;
      ACanvas.MoveTo(5, 31); ACanvas.LineTo(10, 30);
      ACanvas.LineTo(15, 27); ACanvas.LineTo(20, 21);
      ACanvas.LineTo(25, 13); ACanvas.LineTo(31, 10);
      ACanvas.LineTo(37, 9);
      ACanvas.Brush.Color := $000080D0;
      ACanvas.Ellipse(18, 19, 23, 24);
      ACanvas.Ellipse(29, 8, 34, 13);
    end;
    5: begin
      ACanvas.Pen.Color := $009020B0;
      ACanvas.MoveTo(21, 21); ACanvas.LineTo(29, 8);
      ACanvas.LineTo(35, 21); ACanvas.LineTo(29, 34);
      ACanvas.LineTo(13, 8); ACanvas.LineTo(7, 21);
      ACanvas.LineTo(13, 34); ACanvas.LineTo(21, 21);
    end;
  end;
  ACanvas.Pen.Width := 1;
end;

procedure ReplaceComponentPaletteIcon(AImages: TCustomImageList;
  AIndex, AKind: Integer);
var
  lBitmap: TBitmap;
begin
  lBitmap := TBitmap.Create;
  try
    lBitmap.SetSize(42, 42);
    lBitmap.PixelFormat := pf24bit;
    lBitmap.Transparent := False;
    lBitmap.Canvas.Brush.Color := clWhite;
    lBitmap.Canvas.FillRect(0, 0, 42, 42);
    DrawPaletteGlyph(lBitmap.Canvas, AKind);
    AImages.Replace(AIndex, lBitmap, nil);
  finally
    lBitmap.Free;
  end;
end;

procedure ReplaceComponentPaletteIcons(AImages: TCustomImageList);
begin
  ReplaceComponentPaletteIcon(AImages, CIconTrends, 1);
  ReplaceComponentPaletteIcon(AImages, CIconSqlTrend, 2);
  ReplaceComponentPaletteIcon(AImages, CIconFrequencyResponse, 4);
  ReplaceComponentPaletteIcon(AImages, CIconLissajous, 5);
  ReplaceComponentPaletteIcon(AImages, CIconPluginOscillogram, 6);
end;

procedure Replace3dSceneIcon(AImages: TCustomImageList);
var
  lBitmap: TBitmap;
begin
  lBitmap := TBitmap.Create;
  try
    lBitmap.SetSize(42, 42);
    lBitmap.PixelFormat := pf24bit;
    lBitmap.Transparent := False;
    lBitmap.Canvas.Brush.Color := clWhite;
    lBitmap.Canvas.FillRect(0, 0, 42, 42);

    { Перспективная проекция куба в той же строгой линейной стилистике,
      что и пиктограмма измерительного сечения. }
    lBitmap.Canvas.Pen.Color := $00404040;
    lBitmap.Canvas.Pen.Width := 2;
    lBitmap.Canvas.Brush.Color := $00E8F2F5;
    lBitmap.Canvas.Polygon([Point(7, 14), Point(23, 7), Point(35, 14),
      Point(19, 22)]);
    lBitmap.Canvas.Brush.Color := $00CFE8DC;
    lBitmap.Canvas.Polygon([Point(7, 14), Point(19, 22), Point(19, 37),
      Point(7, 29)]);
    lBitmap.Canvas.Brush.Color := $00B8D8E8;
    lBitmap.Canvas.Polygon([Point(19, 22), Point(35, 14), Point(35, 29),
      Point(19, 37)]);
    lBitmap.Canvas.Pen.Width := 1;
  finally
    AImages.Replace(CIcon3dScene, lBitmap, nil);
    lBitmap.Free;
  end;
end;

procedure Draw3dToolbarGlyph(ACanvas: TCanvas; AKind: Integer);
const
  { Cross-platform redraw of the Pan/Rotate/Zoom/Fit vocabulary from
    delphi11/3d/forms/uObjCtrFrame.dfm. The original four-state BMP strips and
    PAN_CURSOR resource are Windows-specific; TSpeedButton supplies states and
    the widget uses the native LCL hand cursor. }
  CAxisColors: array[0..2] of TColor = (clRed, $0000A000, $00D08020);
var
  lAxis: Integer;
begin
  ACanvas.Brush.Color := clWhite;
  ACanvas.FillRect(0, 0, 42, 42);
  ACanvas.Pen.Color := $00383838;
  ACanvas.Pen.Width := 2;
  case AKind of
    0: begin
      ACanvas.Brush.Style := bsClear;
      ACanvas.Polygon([Point(7, 5), Point(31, 22), Point(21, 24),
        Point(27, 36), Point(21, 39), Point(15, 27), Point(7, 34)]);
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Pen.Color := clRed; ACanvas.MoveTo(24, 15); ACanvas.LineTo(38, 15);
      ACanvas.Pen.Color := $0000A000; ACanvas.MoveTo(24, 15); ACanvas.LineTo(24, 3);
    end;
    1: begin
      ACanvas.Brush.Color := $00F0D0A0;
      ACanvas.Polygon([Point(11, 36), Point(7, 23), Point(10, 20),
        Point(14, 27), Point(14, 10), Point(18, 8), Point(20, 23),
        Point(22, 7), Point(26, 8), Point(27, 23), Point(30, 11),
        Point(34, 13), Point(33, 29), Point(27, 37)]);
    end;
    2: begin
      { Legacy rotate glyph: three coloured object axes meeting at one pivot. }
      ACanvas.Brush.Color := $00404040;
      ACanvas.Ellipse(18, 18, 24, 24);
      ACanvas.Pen.Width := 3;
      ACanvas.Pen.Color := clRed;
      ACanvas.MoveTo(21, 21); ACanvas.LineTo(37, 27);
      ACanvas.Brush.Color := clRed;
      ACanvas.Polygon([Point(37,27),Point(31,28),Point(34,22)]);
      ACanvas.Pen.Color := $0000A000;
      ACanvas.MoveTo(21, 21); ACanvas.LineTo(21, 4);
      ACanvas.Brush.Color := $0000A000;
      ACanvas.Polygon([Point(21,4),Point(17,10),Point(25,10)]);
      ACanvas.Pen.Color := $00D08020;
      ACanvas.MoveTo(21, 21); ACanvas.LineTo(7, 36);
      ACanvas.Brush.Color := $00D08020;
      ACanvas.Polygon([Point(7,36),Point(9,29),Point(14,34)]);
    end;
    5, 6, 7, 8: begin
      if AKind >= 6 then lAxis := AKind - 6 else lAxis := -1;
      if lAxis >= 0 then ACanvas.Pen.Color := CAxisColors[lAxis];
      ACanvas.Arc(7, 7, 35, 35, 34, 14, 12, 8);
      ACanvas.Brush.Color := ACanvas.Pen.Color;
      ACanvas.Polygon([Point(8, 7), Point(16, 8), Point(11, 14)]);
      ACanvas.Brush.Style := bsClear;
      ACanvas.Ellipse(16, 16, 27, 27);
      ACanvas.Brush.Style := bsSolid;
      if AKind = 5 then begin
        ACanvas.Pen.Color := $00808080;
        ACanvas.Arc(11, 3, 31, 39, 20, 4, 20, 38);
      end;
      if lAxis >= 0 then begin
        ACanvas.Font.Color := CAxisColors[lAxis];
        ACanvas.Font.Style := [fsBold]; ACanvas.Font.Size := 10;
        ACanvas.TextOut(17, 14, Chr(Ord('X') + lAxis));
        ACanvas.Font.Style := [];
      end;
    end;
    3: begin
      { Legacy zoom glyph: a perspective wedge pointing to the right. }
      ACanvas.Brush.Color := $00D8E8E8;
      ACanvas.Pen.Color := $00383838;
      ACanvas.Polygon([Point(6,8),Point(36,21),Point(6,34)]);
      ACanvas.MoveTo(11,12); ACanvas.LineTo(11,30);
      ACanvas.MoveTo(11,12); ACanvas.LineTo(30,21);
      ACanvas.MoveTo(11,30); ACanvas.LineTo(30,21);
      ACanvas.Brush.Color := $0000A000;
      ACanvas.Polygon([Point(30,17),Point(38,21),Point(30,25)]);
    end;
    4: begin
      { Legacy fit glyph: compact green scene cube, not framing brackets. }
      ACanvas.Pen.Color := $00306030;
      ACanvas.Brush.Color := $00B8E0B8;
      ACanvas.Polygon([Point(10,15),Point(21,9),Point(32,15),Point(21,21)]);
      ACanvas.Brush.Color := $0088C888;
      ACanvas.Polygon([Point(10,15),Point(21,21),Point(21,34),Point(10,28)]);
      ACanvas.Brush.Color := $0068B068;
      ACanvas.Polygon([Point(21,21),Point(32,15),Point(32,28),Point(21,34)]);
    end;
  end;
  ACanvas.Pen.Width := 1;
end;

procedure Replace3dToolbarIcons(AImages: TCustomImageList);
var
  lBitmap: TBitmap;
  lKind: Integer;
begin
  for lKind := 0 to 8 do
  begin
    lBitmap := TBitmap.Create;
    try
      lBitmap.SetSize(42, 42);
      lBitmap.PixelFormat := pf24bit;
      lBitmap.Transparent := False;
      Draw3dToolbarGlyph(lBitmap.Canvas, lKind);
      AImages.Replace(CIcon3dSelect + lKind, lBitmap, nil);
    finally
      lBitmap.Free;
    end;
  end;
end;

procedure RegenerateRecorderDesignerIcons(AImages: TCustomImageList);
begin
  if AImages = nil then
    Exit;
  EnsureImageListSize(AImages, CRecorderCommandImageCount);
  ReplaceInputFieldIcon(AImages);
  ReplaceComponentPaletteIcons(AImages);
  Replace3dSceneIcon(AImages);
  Replace3dToolbarIcons(AImages);
end;

procedure ValidateRecorderCommandImages(AImages: TCustomImageList);
begin
  if AImages = nil then
    raise EArgumentNilException.Create('Recorder command ImageList is nil');
  if AImages.Count < CRecorderCommandImageCount then
    raise EInvalidOperation.CreateFmt(
      'Recorder command ImageList contains %d icons; expected at least %d',
      [AImages.Count, CRecorderCommandImageCount]);
end;

initialization
  {$I uRecorderDonutIcon.lrs}

end.
