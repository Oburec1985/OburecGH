unit uRecorderDonutView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Controls, ExtCtrls, Graphics,
  BGRAGraphicControl, BGRABitmap, BGRABitmapTypes,
  uRecorderVisualControl, uRecorderFormModel, uRecorderTags, uOglChart;

type
  TRecorderDonutView = class(TPanel, IVForm)
  private
    fComponent: TRecorderDonutComponent;
    fGraphic: TBGRAGraphicControl;
    fValues: array of Double;
    fSingleValue: Double;
    procedure DrawDonut(Sender: TObject; Bitmap: TBGRABitmap);
    procedure DrawSingleValue(Bitmap: TBGRABitmap);
    procedure GraphicMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GraphicMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure GraphicMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

const
  CColors: array[0..7, 0..2] of Byte = (
    (65, 117, 230), (63, 174, 100), (230, 146, 84),
    (161, 109, 178), (219, 197, 67), (238, 180, 139),
    (117, 189, 137), (221, 132, 192));

function DonutColor(AIndex: Integer): TBGRAPixel;
var
  lIndex: Integer;
begin
  lIndex := AIndex mod Length(CColors);
  Result := BGRA(CColors[lIndex, 0], CColors[lIndex, 1],
    CColors[lIndex, 2]);
end;

constructor TRecorderDonutView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Color := clWhite;
  fGraphic := TBGRAGraphicControl.Create(Self);
  fGraphic.Parent := Self;
  fGraphic.Align := alClient;
  fGraphic.OnRedraw := @DrawDonut;
  fGraphic.OnMouseDown := @GraphicMouseDown;
  fGraphic.OnMouseMove := @GraphicMouseMove;
  fGraphic.OnMouseUp := @GraphicMouseUp;
end;

procedure TRecorderDonutView.GraphicMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if not Assigned(OnMouseDown) then Exit;
  lPoint := ScreenToClient(fGraphic.ClientToScreen(Point(X, Y)));
  OnMouseDown(Self, Button, Shift, lPoint.X, lPoint.Y);
end;

procedure TRecorderDonutView.GraphicMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if not Assigned(OnMouseMove) then Exit;
  lPoint := ScreenToClient(fGraphic.ClientToScreen(Point(X, Y)));
  OnMouseMove(Self, Shift, lPoint.X, lPoint.Y);
end;

procedure TRecorderDonutView.GraphicMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lPoint: TPoint;
begin
  if not Assigned(OnMouseUp) then Exit;
  lPoint := ScreenToClient(fGraphic.ClientToScreen(Point(X, Y)));
  OnMouseUp(Self, Button, Shift, lPoint.X, lPoint.Y);
end;

procedure TRecorderDonutView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderDonutComponent(AComponent);
  SetLength(fValues, fComponent.TagNames.Count);
  RefreshControl(ATagRegistry, 0);
end;

procedure TRecorderDonutView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  I: Integer;
  lTag: TRecorderTag;
  lValue: Double;
  lChanged: Boolean;
begin
  if fComponent = nil then Exit;
  if fComponent.SingleValueMode then
  begin
    lValue := 0;
    lTag := nil;
    if ATagRegistry <> nil then
    begin
      if fComponent.TagId <> 0 then
        lTag := ATagRegistry.FindById(fComponent.TagId);
      if lTag = nil then
        lTag := ATagRegistry.FindByName(fComponent.TagName);
      if lTag <> nil then
      begin
        fComponent.TagId := lTag.Id;
        fComponent.TagName := lTag.Name;
        if lTag.SignalBuffer <> nil then
          lValue := lTag.SignalBuffer.LatestValue;
      end;
    end;
    if IsNan(lValue) or IsInfinite(lValue) then
      lValue := 0;
    lChanged := fSingleValue <> lValue;
    fSingleValue := lValue;
    if lChanged or (ADisplaySeconds = 0) then
      fGraphic.RedrawBitmap;
    Exit;
  end;
  if Length(fValues) <> fComponent.TagNames.Count then
    SetLength(fValues, fComponent.TagNames.Count);
  lChanged := False;
  for I := 0 to High(fValues) do
  begin
    lValue := 0;
    if ATagRegistry <> nil then
    begin
      lTag := fComponent.ResolveTagAt(ATagRegistry, I);
      if (lTag <> nil) and (lTag.SignalBuffer <> nil) then
        lValue := lTag.SignalBuffer.LatestValue;
    end;
    if IsNan(lValue) or IsInfinite(lValue) or (lValue < 0) then
      lValue := 0;
    if fValues[I] <> lValue then
    begin
      fValues[I] := lValue;
      lChanged := True;
    end;
  end;
  if lChanged or (ADisplaySeconds = 0) then
    fGraphic.RedrawBitmap;
end;

procedure TRecorderDonutView.DrawDonut(Sender: TObject; Bitmap: TBGRABitmap);
var
  I, lLegendCount: Integer;
  lTotal, lStart, lEnd, lRadius, lWidth: Double;
  lX, lY: Double;
  lText: string;
begin
  Bitmap.Fill(BGRA(255, 255, 255));
  if fComponent = nil then Exit;
  if fComponent.SingleValueMode then
  begin
    DrawSingleValue(Bitmap);
    Exit;
  end;
  lTotal := 0;
  for I := 0 to High(fValues) do
    lTotal := lTotal + fValues[I];
  lX := Bitmap.Width * 0.35;
  lY := Bitmap.Height / 2 + 8;
  lRadius := Min(Bitmap.Width * 0.60, Bitmap.Height - 36) * 0.34;
  lWidth := lRadius * (100 - EnsureRange(fComponent.HolePercent, 10, 80)) / 50;
  Bitmap.Canvas2D.lineWidth := lWidth;
  lStart := -Pi / 2;
  if lTotal > 0 then
    for I := 0 to High(fValues) do
    begin
      if fValues[I] <= 0 then Continue;
      lEnd := lStart + 2 * Pi * fValues[I] / lTotal;
      Bitmap.Canvas2D.beginPath;
      Bitmap.Canvas2D.arc(lX, lY, lRadius, lStart, lEnd, False);
      Bitmap.Canvas2D.strokeStyle(DonutColor(I));
      Bitmap.Canvas2D.stroke;
      lStart := lEnd;
    end
  else
  begin
    Bitmap.Canvas2D.beginPath;
    Bitmap.Canvas2D.arc(lX, lY, lRadius, 0, 2 * Pi, False);
    Bitmap.Canvas2D.strokeStyle(BGRA(220, 225, 230));
    Bitmap.Canvas2D.stroke;
  end;
  Bitmap.FontHeight := 14;
  Bitmap.FontAntialias := True;
  lText := fComponent.Title;
  Bitmap.TextOut(Round(lX - Bitmap.TextSize(lText).cx / 2), 8,
    lText, BGRA(40, 45, 55));
  if lTotal > 0 then
    lText := FormatFloat('0.##', lTotal)
  else
    lText := '0';
  Bitmap.TextOut(Round(lX - Bitmap.TextSize(lText).cx / 2),
    Round(lY - Bitmap.TextSize(lText).cy / 2), lText, BGRA(40, 45, 55));
  lLegendCount := Min(Length(fValues), Max(0, (Bitmap.Height - 48) div 24));
  Bitmap.FontHeight := 11;
  for I := 0 to lLegendCount - 1 do
  begin
    Bitmap.FillEllipseAntialias(Bitmap.Width * 0.70, 42 + I * 24,
      5, 5, DonutColor(I));
    lText := fComponent.TagNames[I];
    if Length(lText) > 12 then
      lText := Copy(lText, 1, 11) + '…';
    Bitmap.TextOut(Round(Bitmap.Width * 0.70) + 10, 36 + I * 24,
      lText, BGRA(40, 45, 55));
    if lTotal > 0 then
      Bitmap.TextOut(Round(Bitmap.Width * 0.70) + 10, 47 + I * 24,
        FormatFloat('0.#%', 100 * fValues[I] / lTotal), BGRA(90, 95, 105));
  end;
end;

procedure TRecorderDonutView.DrawSingleValue(Bitmap: TBGRABitmap);
var
  lX, lY, lRadius, lWidth, lRatio: Double;
  lText: string;
begin
  lX := Bitmap.Width / 2;
  lY := Bitmap.Height / 2 + 6;
  lRadius := Min(Bitmap.Width, Bitmap.Height - 36) * 0.34;
  lWidth := lRadius * (100 - EnsureRange(fComponent.HolePercent, 10, 80)) / 50;
  if fComponent.RangeMax > fComponent.RangeMin then
    lRatio := EnsureRange((fSingleValue - fComponent.RangeMin) /
      (fComponent.RangeMax - fComponent.RangeMin), 0, 1)
  else
    lRatio := 0;
  Bitmap.Canvas2D.lineWidth := lWidth;
  Bitmap.Canvas2D.beginPath;
  Bitmap.Canvas2D.arc(lX, lY, lRadius, 0, 2 * Pi, False);
  Bitmap.Canvas2D.strokeStyle(BGRA(220, 225, 230));
  Bitmap.Canvas2D.stroke;
  if lRatio > 0 then
  begin
    Bitmap.Canvas2D.beginPath;
    Bitmap.Canvas2D.arc(lX, lY, lRadius, -Pi / 2,
      -Pi / 2 + lRatio * 2 * Pi, False);
    Bitmap.Canvas2D.strokeStyle(DonutColor(0));
    Bitmap.Canvas2D.stroke;
  end;
  Bitmap.FontAntialias := True;
  Bitmap.FontHeight := 14;
  lText := fComponent.Title;
  Bitmap.TextOut(Round(lX - Bitmap.TextSize(lText).cx / 2), 8,
    lText, BGRA(40, 45, 55));
  lText := FormatFloat('0.##', fSingleValue);
  Bitmap.TextOut(Round(lX - Bitmap.TextSize(lText).cx / 2),
    Round(lY - Bitmap.TextSize(lText).cy / 2), lText, BGRA(40, 45, 55));
  Bitmap.FontHeight := 11;
  lText := fComponent.TagName;
  Bitmap.TextOut(Round(lX - Bitmap.TextSize(lText).cx / 2),
    Bitmap.Height - 21, lText, BGRA(90, 95, 105));
end;

function TRecorderDonutView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

end.
