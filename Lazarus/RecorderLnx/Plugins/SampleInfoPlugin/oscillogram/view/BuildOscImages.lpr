program BuildOscImages;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, Controls, Graphics, ImgList, LResources;
var lBitmap: TBitmap; lImages: TImageList; lText: TStringStream; I: Integer;
procedure AddIcon(AKind: Integer);
  begin
    lBitmap.Canvas.Brush.Color := clFuchsia;
    lBitmap.Canvas.FillRect(Rect(0, 0, 16, 16));
    lBitmap.Canvas.Pen.Color := clNavy;
    case AKind of
      0: begin
        lBitmap.Canvas.Pen.Style := psDash;
        lBitmap.Canvas.MoveTo(1, 8);
        lBitmap.Canvas.LineTo(15, 8);
        lBitmap.Canvas.Pen.Style := psSolid;
      end;
      1: begin
        lBitmap.Canvas.Rectangle(1, 2, 15, 14);
        lBitmap.Canvas.MoveTo(2, 11);
        lBitmap.Canvas.LineTo(6, 8);
        lBitmap.Canvas.LineTo(10, 10);
        lBitmap.Canvas.LineTo(14, 4);
      end;
      2: begin
        lBitmap.Canvas.MoveTo(8, 1);
        lBitmap.Canvas.LineTo(8, 15);
        lBitmap.Canvas.MoveTo(5, 11);
        lBitmap.Canvas.LineTo(5, 15);
      end;
      3: begin
        lBitmap.Canvas.Rectangle(1, 2, 15, 14);
        lBitmap.Canvas.MoveTo(3, 6);
        lBitmap.Canvas.LineTo(13, 6);
        lBitmap.Canvas.MoveTo(3, 10);
        lBitmap.Canvas.LineTo(13, 10);
      end;
    end;
    lImages.AddMasked(lBitmap, clFuchsia);
  end;
begin
  Application.Initialize;
  lImages := TImageList.Create(nil);
  lBitmap := TBitmap.Create;
  lText := TStringStream.Create('');
  try
    lImages.Name := 'fToolImages';
    lImages.Width := 16;
    lImages.Height := 16;
    lBitmap.SetSize(16,16);
    for I := 0 to 3 do AddIcon(I);
    WriteComponentAsTextToStream(lText,lImages);
    Write(lText.DataString);
  finally
    lText.Free; lBitmap.Free; lImages.Free;
  end;
end.

