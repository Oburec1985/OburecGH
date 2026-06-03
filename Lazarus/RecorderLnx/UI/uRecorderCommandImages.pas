unit uRecorderCommandImages;

{
  ћодуль uRecorderCommandImages

  Ќазначение:
    ¬спомогательный модуль дл€ загрузки графических ресурсов (иконок и растровых
    изображений) командных кнопок и элементов интерфейса RecorderLnx из общего
    каталога картинок.

  ћесто в архитектуре:
    UI слой (UI layer/assets helper). ѕредоставл€ет константы индексов изображений
    и процедуру загрузки списка изображений.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ImgList;

const
  { »ндексы изображений в списке картинок }
  CIconSettings = 0;
  CIconRecord = 1;
  CIconView = 2;
  CIconStop = 3;
  CIconEditForm = 15;
  CIconOscillogram = 5;
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
  CIconRight = 36;
  CIconLeft = 35;

  CRecorderOriginalImageCount = 15;
  CRecorderCommandImageCount = 35;

{ «агружает командные иконки и изображени€ в переданный список изображений }
procedure LoadRecorderCommandImages(AImages: TCustomImageList);

implementation

const
  CRecorderImagesDir = 'D:\works\windev-v3.9\images';

function ImageFile(const ARelativeName: string): string;
begin
  Result := IncludeTrailingPathDelimiter(CRecorderImagesDir) + ARelativeName;
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

procedure LoadRecorderCommandImages(AImages: TCustomImageList);
begin
  if AImages = nil then
    Exit;

  if AImages.Count >= CRecorderCommandImageCount then
    Exit;

  AImages.Width := 42;
  AImages.Height := 42;

  while AImages.Count < CRecorderOriginalImageCount do
    AddBitmapFile(AImages, '');

  AddIconFile(AImages, ImageFile('Mdiedit.ico'));               // CIconEditForm
  AddIconFile(AImages, ImageFile('graphcfg.ico'));              // CIconOscillogram
  AddIconFile(AImages, ImageFile('Note.ico'));                  // CIconTextLabel
  AddIconFile(AImages, ImageFile('Physics.ico'));               // CIconSpectrum
  AddIconFile(AImages, ImageFile('sensor.ico'));                // CIconDigitalIndicator
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\vtag_pro.ico')); // CIconTagTable
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\property.ico')); // CIconButton
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\more.ico'));     // CIconComboBox
  AddIconFile(AImages, ImageFile('devroot.ico'));               // CIconDeviceRoot
  AddIconFile(AImages, ImageFile('hardware.ico'));              // CIconDeviceController
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\module.ico')); // CIconDeviceModule
  AddBitmapFile(AImages, ImageFile('savecfgd.bmp'));            // CIconSaveConfig
  AddIconFile(AImages, ImageFile('add.ico'));                   // CIconAdd
  AddIconFile(AImages, ImageFile('remove.ico'));                // CIconRemove
  AddIconFile(AImages, ImageFile('edit.ico'));                  // CIconEdit
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\property.ico')); // CIconProperty
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\harf_t.ico')); // CIconHardwareCurve
  AddIconFile(AImages, ImageFile('from_rcguisrv\res\Scales.ico')); // CIconChannelCurve
  AddIconFile(AImages, ImageFile('from_rcguisrv\ico\search.ico')); // CIconSearch
  AddIconFile(AImages, ImageFile('foldero.ico'));               // CIconFolderOpen
end;

end.
