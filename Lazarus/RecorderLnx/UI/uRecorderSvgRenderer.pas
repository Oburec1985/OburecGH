unit uRecorderSvgRenderer;

{$mode objfpc}{$H+}

interface

uses
  Math, Types, BGRABitmap, BGRABitmapTypes, BGRASVG;

function RenderSvgContent(ASvg: TBGRASVG; AWidth,
  AHeight: Integer): TBGRABitmap;

implementation

const
  CMaxSvgSourceSize = 4096;

function SvgSourceSize(AValue: Double; AFallback: Integer): Integer;
begin
  if AValue > 0 then
    Result := EnsureRange(Ceil(AValue), 1, CMaxSvgSourceSize)
  else
    Result := EnsureRange(AFallback, 1, CMaxSvgSourceSize);
end;

function RenderSvgContent(ASvg: TBGRASVG; AWidth,
  AHeight: Integer): TBGRABitmap;
var
  lBounds: TRect;
  lContent: TBGRABitmap;
  lSource: TBGRABitmap;
begin
  Result := TBGRABitmap.Create(Max(1, AWidth), Max(1, AHeight),
    BGRAPixelTransparent);
  if ASvg = nil then
    Exit;

  lSource := TBGRABitmap.Create(
    SvgSourceSize(ASvg.WidthAsPixel, AWidth),
    SvgSourceSize(ASvg.HeightAsPixel, AHeight), BGRAPixelTransparent);
  try
    ASvg.StretchDraw(lSource.Canvas2D, 0, 0, lSource.Width, lSource.Height,
      False);
    lBounds := lSource.GetImageBounds;
    if (lBounds.Right <= lBounds.Left) or (lBounds.Bottom <= lBounds.Top) then
      Exit;

    lContent := lSource.GetPart(lBounds);
    try
      Result.Free;
      Result := lContent.Resample(Max(1, AWidth), Max(1, AHeight),
        rmFineResample);
    finally
      lContent.Free;
    end;
  finally
    lSource.Free;
  end;
end;

end.
