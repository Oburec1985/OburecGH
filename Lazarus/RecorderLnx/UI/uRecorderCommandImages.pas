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
  Classes, SysUtils, Graphics, ImgList;

const
  CIconSettings = 0;
  CIconRecord = 1;
  CIconView = 2;
  CIconStop = 3;
  CIconEditForm = 15;
  CIconOscillogram = 49;
  CIconTextLabel = 6;
  CIconSpectrum = 7;
  CIconDigitalIndicator = 8;
  CIconTagTable = 20;
  CIconButton = 10;
  CIconComboBox = 11;
  CIconDeviceRoot = 23;
  CIconDeviceController = 24;
  CIconDeviceModule = 25;
  CIconSaveConfig = 58;
  CIconAdd = 27;
  CIconRemove = 28;
  CIconEdit = 29;
  CIconProperty = 30;
  CIconHardwareCurve = 31;
  CIconChannelCurve = 32;
  CIconSearch = 33;
  CIconFolderOpen = 34;
  CIconLeft = 35;
  CIconRight = 36;
  CIconRunWp = 37;
  CIconSaveConfigAs = 48;
  CIconTrends = 5;
  CIconImageComponent = 59;
  CIconMeasurementSection = 60;
  CIconDonut = 61;
  CIconInputField = 62;
  CIconSqlTrend = 63;
  CIconFrequencyResponse = 64;
  CIconLissajous = 65;
  CIconPluginOscillogram = 66;

  CRecorderOriginalImageCount = 15;
  CRecorderCommandImageCount = 67;
  CTagDialogIconHardwareSource = 42;
  CTagDialogIconZeroBalance = 51;
  CTagDialogIconHardwareCurveRead = 57;
  CTagDialogImageCount = 58;

procedure LoadRecorderCommandImages(AImages: TCustomImageList);
procedure EnsureRecorderTagDialogImages(AImages: TCustomImageList);
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

procedure AddIconFile(AImages: TCustomImageList; const AFileName: string);
var
  lIcon: TIcon;
begin
  lIcon := TIcon.Create;
  try
    if FileExists(AFileName) then
      lIcon.LoadFromFile(AFileName);
    AImages.AddIcon(lIcon);
  finally
    lIcon.Free;
  end;
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

procedure SetImageListIconAt(AImages: TCustomImageList; AIndex: Integer;
  const AFileName: string);
var
  lIcon: TIcon;
begin
  if (AImages = nil) or (AFileName = '') or not FileExists(AFileName) then
    Exit;
  EnsureImageListSize(AImages, AIndex + 1);
  lIcon := TIcon.Create;
  try
    lIcon.LoadFromFile(AFileName);
    AImages.ReplaceIcon(AIndex, lIcon);
  finally
    lIcon.Free;
  end;
end;

procedure EnsureRecorderTagDialogImages(AImages: TCustomImageList);
begin
  if AImages = nil then
    Exit;
  if AImages.Width < 32 then
    AImages.Width := 32;
  if AImages.Height < 32 then
    AImages.Height := 32;
  SetImageListIconAt(AImages, CTagDialogIconHardwareSource, FirstExistingFile([
    CWindevRoot + 'rc_guisrv\res\v3\ico\hardware.ico',
    CWindevRoot + 'rc_guisrv\res\hardware.ico',
    ImageFile('hardware.ico'),
    ImageFile('from_rcguisrv\res\v3\ico\hardware.ico')
  ]));
  SetImageListIconAt(AImages, CTagDialogIconZeroBalance, FirstExistingFile([
    CWindevRoot + 'rc_guisrv\res\v3\ico\zbalance.ico',
    CWindevRoot + 'rc_guisrv\res\zbalance.ico',
    ImageFile('zbalance.ico'),
    ImageFile('from_rcguisrv\res\v3\ico\zbalance.ico')
  ]));
  SetImageListIconAt(AImages, CTagDialogIconHardwareCurveRead, FirstExistingFile([
    CWindevRoot + 'rc_guisrv\res\v3\ico\ram_out.ico',
    CWindevRoot + 'rc_guisrv\res\ram_out.ico',
    ImageFile('ram_out.ico'),
    ImageFile('from_rcguisrv\res\v3\ico\ram_out.ico'),
    ImageFile('from_rcguisrv\res\harf_t.ico')
  ]));
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

procedure RegenerateRecorderDesignerIcons(AImages: TCustomImageList);
begin
  if AImages = nil then
    Exit;
  EnsureImageListSize(AImages, CRecorderCommandImageCount);
  ReplaceInputFieldIcon(AImages);
  ReplaceComponentPaletteIcons(AImages);
end;

procedure LoadRecorderCommandImages(AImages: TCustomImageList);
begin
  if AImages = nil then
    Exit;

  AImages.Width := 42;
  AImages.Height := 42;

  { Forms usually keep ilCommandButtons in the .lfm. Do not append file-based
    fallback icons to a designer-filled list: indexes 59/60 are semantic now. }
  if AImages.Count = 0 then
  begin
    while AImages.Count < CRecorderOriginalImageCount do
      AddBitmapFile(AImages, '');

    AddIconFile(AImages, ImageFile('Mdiedit.ico'));
    AddIconFile(AImages, ImageFile('graphcfg.ico'));
    AddIconFile(AImages, ImageFile('Note.ico'));
    AddIconFile(AImages, ImageFile('Physics.ico'));
    AddIconFile(AImages, ImageFile('sensor.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\vtag_pro.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\property.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\more.ico'));
    AddIconFile(AImages, ImageFile('devroot.ico'));
    AddIconFile(AImages, ImageFile('hardware.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\module.ico'));
    AddBitmapFile(AImages, ImageFile('savecfgd.bmp'));
    AddIconFile(AImages, ImageFile('add.ico'));
    AddIconFile(AImages, ImageFile('remove.ico'));
    AddIconFile(AImages, ImageFile('edit.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\property.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\harf_t.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\Scales.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\ico\search.ico'));
    AddIconFile(AImages, ImageFile('foldero.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\arw_rl.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\res\arw_lr.ico'));
    AddIconFile(AImages, ImageFile('from_rcguisrv\ico\play.ico'));
  end;

  EnsureImageListSize(AImages, CRecorderCommandImageCount);
  { Все штатные пиктограммы, включая 61..66, хранятся непосредственно в
    ilCommandButtons формы. Runtime не должен подменять дизайнерский список:
    иначе Lazarus показывает одно изображение, а приложение — другое. }
end;

initialization
  {$I uRecorderDonutIcon.lrs}

end.
