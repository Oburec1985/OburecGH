program CommandImagesSmoke;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, Controls, SysUtils, Graphics, ImgList,
  uRcIconIds, uRecorderCommandImages;

var
  lImages: TImageList;
  lBitmap, lOriginalMeraBase, lActualMeraBase: TBitmap;
  I: Integer;
begin
  Application.Initialize;
  lImages := TImageList.Create(nil);
  try
    lImages.Width := 42;
    lImages.Height := 42;
    lBitmap := TBitmap.Create;
    lOriginalMeraBase := TBitmap.Create;
    lActualMeraBase := TBitmap.Create;
    try
      lBitmap.SetSize(42, 42);
      lBitmap.Canvas.Brush.Color := clWhite;
      lBitmap.Canvas.FillRect(0, 0, 42, 42);
      lBitmap.Canvas.Pixels[0, 0] := clRed;
      for I := 1 to CRecorderOriginalImageCount + 59 do
        lImages.Add(lBitmap, nil);
      lImages.GetBitmap(CIconMeraBase, lOriginalMeraBase);
    finally
      lBitmap.Free;
    end;

    if lImages.Count <> 74 then
      raise Exception.CreateFmt('Test setup expected 74 icons, got %d',
        [lImages.Count]);

    RegenerateRecorderDesignerIcons(lImages);
    ValidateRecorderCommandImages(lImages);
    if lImages.Count <> CRecorderCommandImageCount then
      raise Exception.CreateFmt('Expected %d icons after regeneration, got %d',
        [CRecorderCommandImageCount, lImages.Count]);
    lImages.GetBitmap(CIconMeraBase, lActualMeraBase);
    if lActualMeraBase.Canvas.Pixels[0, 0] <>
      lOriginalMeraBase.Canvas.Pixels[0, 0] then
      raise Exception.Create('MeraBase icon at index 73 was modified');

    WriteLn('PASS: ImageList 74 -> ', lImages.Count,
      '; icon 73 preserved');
  finally
    lActualMeraBase.Free;
    lOriginalMeraBase.Free;
    lImages.Free;
  end;
end.
