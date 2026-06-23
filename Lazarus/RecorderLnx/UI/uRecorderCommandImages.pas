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
  CIconSaveConfig = 26;
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
  CIconSaveConfigAs = 38;
  CIconTrends = 5;

  CRecorderOriginalImageCount = 15;
  CRecorderCommandImageCount = 39;
  CTagDialogIconHardwareSource = 42;
  CTagDialogIconZeroBalance = 51;
  CTagDialogImageCount = 52;

procedure LoadRecorderCommandImages(AImages: TCustomImageList);
procedure EnsureRecorderTagDialogImages(AImages: TCustomImageList);

implementation

uses
  Types;

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
  if Result <> nil then
    Exit;
  Result := TBitmap.Create;
  Result.SetSize(42, 42);
  Result.TransparentColor := clFuchsia;
  Result.Transparent := True;
  DrawSaveConfigGlyph(Result.Canvas, ASaveAs);
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
    lMask := CreateMaskFromTransparentBitmap(lBitmap);
    try
      AImages.Replace(CIconSaveConfig, lBitmap, lMask);
    finally
      lMask.Free;
    end;
  finally
    lBitmap.Free;
  end;

  lBitmap := CreateSaveConfigBitmap(True);
  try
    lMask := CreateMaskFromTransparentBitmap(lBitmap);
    try
      AImages.Replace(CIconSaveConfigAs, lBitmap, lMask);
    finally
      lMask.Free;
    end;
  finally
    lBitmap.Free;
  end;
end;

procedure LoadRecorderCommandImages(AImages: TCustomImageList);
begin
  if AImages = nil then
    Exit;

  AImages.Width := 42;
  AImages.Height := 42;

  if AImages.Count < CRecorderCommandImageCount then
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
    EnsureImageListSize(AImages, CRecorderCommandImageCount);
  end;

  RefreshSaveConfigIcons(AImages);
end;

end.
