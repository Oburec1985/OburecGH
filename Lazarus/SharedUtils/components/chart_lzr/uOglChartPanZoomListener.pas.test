unit uOglChartPanZoomListener;

{
  РњРѕРґСѓР»СЊ uOglChartPanZoomListener
  РћРїРёСЃР°РЅРёРµ: РЎР»СѓС€Р°С‚РµР»СЊ РґР»СЏ РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёСЏ (СЃРєСЂРѕР»Р»Р°) Рё РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёСЏ (Р·СѓРјР°) РіСЂР°С„РёРєРѕРІ.
}
{$mode objfpc}{$H+}
{$codepage UTF8}
interface
uses
  Classes, SysUtils, Controls, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,
  uOglChartTextLabel;

type
  TZoomSelectMode = (zsmXY, zsmYOnly, zsmXOnly);

  /// <summary>
  /// РЎР»СѓС€Р°С‚РµР»СЊ РґР»СЏ СЂРµР°Р»РёР·Р°С†РёРё РёРЅС‚РµСЂР°РєС‚РёРІРЅРѕР№ РЅР°РІРёРіР°С†РёРё: РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёРµ (Zoom) Рё РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёРµ (Pan).
  /// РЈРїСЂР°РІР»СЏРµС‚ РїРµСЂРµС‚Р°СЃРєРёРІР°РЅРёРµРј РїСЂР°РІРѕР№ РєРЅРѕРїРєРѕР№ РјС‹С€Рё, РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёРµРј РєРѕР»РµСЃРёРєРѕРј РЅР°Рґ СЃС‚СЂР°РЅРёС†Р°РјРё,
  /// Рё РїСЂРёР±Р»РёР¶РµРЅРёРµРј РїРѕ РІС‹РґРµР»РµРЅРЅРѕР№ СЂР°РјРєРµ СЃ Р·Р°Р¶Р°С‚РѕР№ РєР»Р°РІРёС€РµР№ Ctrl.
  /// </summary>
  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;             // Р¤Р»Р°Рі Р°РєС‚РёРІРЅРѕРіРѕ РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёСЏ РіСЂР°С„РёРєР° (РїСЂР°РІР°СЏ РєРЅРѕРїРєР° РјС‹С€Рё).
    fLastX: Integer;                 // РџРѕСЃР»РµРґРЅСЏСЏ РєРѕРѕСЂРґРёРЅР°С‚Р° X РјС‹С€Рё РґР»СЏ СЂР°СЃС‡РµС‚Р° СЃРјРµС‰РµРЅРёСЏ (delta).
    fLastY: Integer;                 // РџРѕСЃР»РµРґРЅСЏСЏ РєРѕРѕСЂРґРёРЅР°С‚Р° Y РјС‹С€Рё РґР»СЏ СЂР°СЃС‡РµС‚Р° СЃРјРµС‰РµРЅРёСЏ.
    fActivePage: TChartPage;         // РЎСЃС‹Р»РєР° РЅР° Р°РєС‚РёРІРЅСѓСЋ (РёРЅС‚РµСЂР°РєС‚РёРІРЅСѓСЋ РІ РґР°РЅРЅС‹Р№ РјРѕРјРµРЅС‚) СЃС‚СЂР°РЅРёС†Сѓ С‡Р°СЂС‚Р°.
    fIsZoomSelecting: Boolean;       // Р¤Р»Р°Рі Р°РєС‚РёРІРЅРѕРіРѕ РІС‹Р±РѕСЂР° СЂР°РјРєРё Р·СѓРјРёСЂРѕРІР°РЅРёСЏ (Ctrl + Drag).
    fZoomStartX: Integer;            // РќР°С‡Р°Р»СЊРЅР°СЏ РєРѕРѕСЂРґРёРЅР°С‚Р° X СЂР°РјРєРё Р·СѓРјРёСЂРѕРІР°РЅРёСЏ.
    fZoomStartY: Integer;
    fZoomSelectMode: TZoomSelectMode;            // РќР°С‡Р°Р»СЊРЅР°СЏ РєРѕРѕСЂРґРёРЅР°С‚Р° Y СЂР°РјРєРё Р·СѓРјРёСЂРѕРІР°РЅРёСЏ.
  public
    /// <summary>
    /// РљРѕРЅСЃС‚СЂСѓРєС‚РѕСЂ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ.
    /// </summary>

    constructor Create; override;
    /// <summary>
    /// Р—Р°РїСѓСЃРєР°РµС‚ РёРЅС‚РµСЂР°РєС‚РёРІРЅС‹Рµ СЂРµР¶РёРјС‹ (РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёРµ РїСЂР°РІРѕР№ РєРЅРѕРїРєРѕР№ РёР»Рё СЂР°РјРєСѓ Р·СѓРјР° СЃ Ctrl).
    /// </summary>

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Р’С‹РїРѕР»РЅСЏРµС‚ СЃРјРµС‰РµРЅРёРµ РіСЂР°С„РёРєРѕРІ РёР»Рё РѕС‚СЂРёСЃРѕРІРєСѓ СЂР°РјРєРё Р·СѓРјР°.
    /// </summary>

    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Р—Р°РІРµСЂС€Р°РµС‚ РёРЅС‚РµСЂР°РєС‚РёРІРЅС‹Рµ СЂРµР¶РёРјС‹ Рё РїСЂРёРјРµРЅСЏРµС‚ РёР·РјРµРЅРµРЅРёСЏ (Р·СѓРјРёСЂРѕРІР°РЅРёРµ РїРѕ СЂР°РјРєРµ).
    /// </summary>

    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Р’С‹РїРѕР»РЅСЏРµС‚ Р·СѓРјРёСЂРѕРІР°РЅРёРµ РіСЂР°С„РёРєР° РєРѕР»РµСЃРёРєРѕРј РјС‹С€Рё РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ С‚РµРєСѓС‰РµРіРѕ РїРѕР»РѕР¶РµРЅРёСЏ РєСѓСЂСЃРѕСЂР°.
    /// </summary>

    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); override;
  end;

procedure FitZoomX(APage: TChartPage); overload;
procedure FitZoomX(AAxis: TChartAxis); overload;
procedure FitZoomY(APage: TChartPage); overload;
procedure FitZoomY(AAxis: TChartAxis); overload;
procedure FitZoomXY(APage: TChartPage); overload;
procedure FitZoomXY(AAxis: TChartAxis); overload;
procedure FitPageZoom(APage: TChartPage);

implementation


function IsOnYAxisBand(ARenderer: TOpenGLChartRenderer; APage: TChartPage;
  AX, AY: Integer): Boolean;
var
  lContentRect, lPageRect: TChartPixelRect;
begin
  lPageRect := ARenderer.GetPageRect(APage);
  lContentRect := ARenderer.GetPageContentRect(APage);
  Result := (AX >= lPageRect.Left) and (AX < lContentRect.Left) and
    (AY >= lContentRect.Top) and (AY <= lContentRect.Bottom);
end;

function IsOnXAxisBand(ARenderer: TOpenGLChartRenderer; APage: TChartPage;
  AX, AY: Integer): Boolean;
var
  lContentRect, lPageRect: TChartPixelRect;
begin
  lPageRect := ARenderer.GetPageRect(APage);
  lContentRect := ARenderer.GetPageContentRect(APage);
  Result := (AY > lContentRect.Bottom) and (AY <= lPageRect.Bottom) and
    (AX >= lContentRect.Left) and (AX <= lContentRect.Right);
end;

procedure BuildZoomSelectionRect(AMode: TZoomSelectMode;
  const AContent: TChartPixelRect; AStartX, AStartY, AX, AY: Integer;
  out ASelRect: TChartPixelRect);
begin
  case AMode of
    zsmYOnly:
      begin
        ASelRect.Left := AContent.Left;
        ASelRect.Right := AContent.Right;
        ASelRect.Top := Max(AContent.Top, Min(AStartY, AY));
        ASelRect.Bottom := Min(AContent.Bottom, Max(AStartY, AY));
      end;
    zsmXOnly:
      begin
        ASelRect.Top := AContent.Top;
        ASelRect.Bottom := AContent.Bottom;
        ASelRect.Left := Max(AContent.Left, Min(AStartX, AX));
        ASelRect.Right := Min(AContent.Right, Max(AStartX, AX));
      end;
  else
    begin
      ASelRect.Left := Max(AContent.Left, Min(AStartX, AX));
      ASelRect.Right := Min(AContent.Right, Max(AStartX, AX));
      ASelRect.Top := Max(AContent.Top, Min(AStartY, AY));
      ASelRect.Bottom := Min(AContent.Bottom, Max(AStartY, AY));
    end;
  end;
end;

type
  TAxisBounds = record
    Axis: TChartAxis;
    MinY, MaxY: Double;
    MinX, MaxX: Double;
    HasY, HasX: Boolean;
  end;

  TAxisBoundsArray = array of TAxisBounds;

function GetOrAddAxisBounds(AAxis: TChartAxis; var ABounds: TAxisBoundsArray): Integer;

var
  i: Integer;
begin
  for i := 0 to High(ABounds) do
    if ABounds[i].Axis = AAxis then
    begin
      Result := i;
      Exit;
    end;

  SetLength(ABounds, Length(ABounds) + 1);
  Result := High(ABounds);
  ABounds[Result].Axis := AAxis;
  ABounds[Result].MinY := 1E30;
  ABounds[Result].MaxY := -1E30;
  ABounds[Result].MinX := 1E30;
  ABounds[Result].MaxX := -1E30;
  ABounds[Result].HasY := False;
  ABounds[Result].HasX := False;
end;

function FindParentAxis(AObject: TChartBaseObject): TChartAxis;

var
  p: TChartBaseObject;
begin
  Result := nil;
  p := AObject.Parent;
  while Assigned(p) do
  begin
    if p is TChartAxis then
    begin
      Result := TChartAxis(p);
      Exit;
    end;

    p := p.Parent;
  end;

end;

function FindParentPage(AObject: TChartBaseObject): TChartPage;

var
  p: TChartBaseObject;
begin
  Result := nil;
  p := AObject.Parent;
  while Assigned(p) do
  begin
    if p is TChartPage then
    begin
      Result := TChartPage(p);
      Exit;
    end;

    p := p.Parent;
  end;

end;

function ResolveSelectedAxis(APage: TChartPage; ASelected: TChartBaseObject): TChartAxis;
begin
  Result := nil;
  if (not Assigned(APage)) or (not Assigned(ASelected)) then
    Exit;
  if (ASelected is TChartAxis) and (ASelected.Parent = APage) then
    Exit(TChartAxis(ASelected));
  if (ASelected is cBaseTrend) and Assigned(ASelected.Parent) and
    (ASelected.Parent is TChartAxis) and (ASelected.Parent.Parent = APage) then
    Exit(TChartAxis(ASelected.Parent));
end;

procedure ApplyPresetZoomY(AAxis: TChartAxis);
begin
  if not Assigned(AAxis) then
    Exit;
  if AAxis.HasPresetRange and (AAxis.PresetMaxValue > AAxis.PresetMinValue) then
  begin
    AAxis.MinValue := AAxis.PresetMinValue;
    AAxis.MaxValue := AAxis.PresetMaxValue;
  end;
end;

procedure ApplyPresetZoomY(APage: TChartPage; ASelected: TChartBaseObject);
var
  I: Integer;
  lAxis: TChartAxis;
  lSelectedAxis: TChartAxis;
begin
  if not Assigned(APage) then
    Exit;
  lSelectedAxis := ResolveSelectedAxis(APage, ASelected);
  if Assigned(lSelectedAxis) then
  begin
    ApplyPresetZoomY(lSelectedAxis);
    Exit;
  end;

  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lAxis := TChartAxis(APage.Children[I]);
      ApplyPresetZoomY(lAxis);
    end;
end;


procedure RestoreUserZoomOnPage(APage: TChartPage; ASelected: TChartBaseObject;
  AResetX, AResetY: Boolean);
var
  I: Integer;
  lAxis: TChartAxis;
  lSelectedAxis: TChartAxis;
begin
  if not Assigned(APage) then
    Exit;
  if AResetX then
  begin
    APage.ZoomedX := False;
    if APage.AutoScaleOnZoomReset then
    begin
      if APage.PresetMaxXValue > APage.PresetMinXValue then
      begin
        APage.XMinValue := APage.PresetMinXValue;
        APage.XMaxValue := APage.PresetMaxXValue;
      end
      else
        FitZoomX(APage);
    end
    else if APage.HasPresetXRange and (APage.PresetMaxXValue > APage.PresetMinXValue) then
    begin
      APage.XMinValue := APage.PresetMinXValue;
      APage.XMaxValue := APage.PresetMaxXValue;
    end
    else
      FitZoomX(APage);
  end;
  if not AResetY then
    Exit;
  if APage.AutoScaleOnZoomReset then
  begin
    lSelectedAxis := ResolveSelectedAxis(APage, ASelected);
    if Assigned(lSelectedAxis) then
    begin
      lSelectedAxis.HasPresetRange := False;
      FitZoomY(lSelectedAxis);
      Exit;
    end;
    for I := 0 to APage.ChildCount - 1 do
      if APage.Children[I] is TChartAxis then
        TChartAxis(APage.Children[I]).HasPresetRange := False;
    FitZoomY(APage);
  end
  else
    ApplyPresetZoomY(APage, ASelected);
end;

procedure ApplyPresetZoomYAll(APage: TChartPage);
var
  I: Integer;
begin
  if not Assigned(APage) then
    Exit;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
      ApplyPresetZoomY(TChartAxis(APage.Children[I]));
end;

procedure ProcessObjectBounds(AObject: TChartBaseObject; APage: TChartPage; var APageMinX, APageMaxX: Double; var AHasPageX: Boolean; var ABounds: TAxisBoundsArray);

var
  lIdx, lPtIdx, lAxisIdx: Integer;
  lLine: TChartLineSeries;
  lBuff1d: cBuffTrend1d;
  lAxis: TChartAxis;
  lVal: Double;
  lTextLabel: TChartTextLabel;
begin
  if not Assigned(AObject) then Exit;
  // 1. Р•СЃР»Рё СЌС‚Рѕ Р»РёРЅРёСЏ С‚СЂРµРЅРґР° / СЂСЏРґ С‚РѕС‡РµРє
  if AObject is TChartLineSeries then
  begin
    lLine := TChartLineSeries(AObject);
    lAxis := FindParentAxis(lLine);
    if Assigned(lAxis) then
    begin
      lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
      for lPtIdx := 0 to lLine.PointCount - 1 do
      begin
        ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lLine.Points[lPtIdx].Y);
        ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lLine.Points[lPtIdx].Y);
        ABounds[lAxisIdx].HasY := True;
        if lAxis.UseOwnX then
        begin
          ABounds[lAxisIdx].MinX := Min(ABounds[lAxisIdx].MinX, lLine.Points[lPtIdx].X);
          ABounds[lAxisIdx].MaxX := Max(ABounds[lAxisIdx].MaxX, lLine.Points[lPtIdx].X);
          ABounds[lAxisIdx].HasX := True;
        end

        else
        begin
          APageMinX := Min(APageMinX, lLine.Points[lPtIdx].X);
          APageMaxX := Max(APageMaxX, lLine.Points[lPtIdx].X);
          AHasPageX := True;
        end;

      end;

    end;

  end

  // 2. Р•СЃР»Рё СЌС‚Рѕ Р±СѓС„РµСЂРёР·РѕРІР°РЅРЅС‹Р№ С‚СЂРµРЅРґ 1D
  else if AObject is cBuffTrend1d then
  begin
    lBuff1d := cBuffTrend1d(AObject);
    lAxis := FindParentAxis(lBuff1d);
    if Assigned(lAxis) then
    begin
      lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
      for lPtIdx := 0 to lBuff1d.Count - 1 do
      begin
        ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lBuff1d.Values[lPtIdx]);
        ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lBuff1d.Values[lPtIdx]);
        ABounds[lAxisIdx].HasY := True;
        if lAxis.UseOwnX then
        begin
          ABounds[lAxisIdx].MinX := Min(ABounds[lAxisIdx].MinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          ABounds[lAxisIdx].MaxX := Max(ABounds[lAxisIdx].MaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          ABounds[lAxisIdx].HasX := True;
        end

        else
        begin
          APageMinX := Min(APageMinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          APageMaxX := Max(APageMaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
          AHasPageX := True;
        end;

      end;

    end;

  end

  // 3. Р•СЃР»Рё СЌС‚Рѕ РјРµС‚РєР° РёР»Рё С„Р»Р°Рі
  else if AObject is TChartTextLabel then
  begin
    lTextLabel := TChartTextLabel(AObject);
    lAxis := lTextLabel.Axis;
    if (lTextLabel is TChartFlagLabel) and Assigned(TChartFlagLabel(lTextLabel).Trend) then
      lAxis := FindParentAxis(TChartFlagLabel(lTextLabel).Trend);
    if not Assigned(lAxis) then
      lAxis := FindParentAxis(lTextLabel);
    if not Assigned(lAxis) and Assigned(APage) then
    begin
      for lIdx := 0 to APage.ChildCount - 1 do
        if APage.Children[lIdx] is TChartAxis then
        begin
          lAxis := TChartAxis(APage.Children[lIdx]);
          Break;
        end;

    end;

    // РџРѕ X
    if lTextLabel.IsWorldX then
    begin
      if Assigned(lAxis) and lAxis.UseOwnX then
      begin
        lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
        ABounds[lAxisIdx].MinX := Min(ABounds[lAxisIdx].MinX, lTextLabel.WorldX);
        ABounds[lAxisIdx].MaxX := Max(ABounds[lAxisIdx].MaxX, lTextLabel.WorldX);
        ABounds[lAxisIdx].HasX := True;
      end

      else
      begin
        APageMinX := Min(APageMinX, lTextLabel.WorldX);
        APageMaxX := Max(APageMaxX, lTextLabel.WorldX);
        AHasPageX := True;
      end;

    end;

    // РџРѕ Y
    if lTextLabel.IsWorldY or (lTextLabel is TChartFlagLabel) then
    begin
      if Assigned(lAxis) then
      begin
        lAxisIdx := GetOrAddAxisBounds(lAxis, ABounds);
        if lTextLabel is TChartFlagLabel then
        begin
          if GetTrendValueAtX(TChartFlagLabel(lTextLabel).Trend, TChartFlagLabel(lTextLabel).WorldX, lVal) then
          begin
            ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lVal);
            ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lVal);
            ABounds[lAxisIdx].HasY := True;
          end;

        end

        else
        begin
          ABounds[lAxisIdx].MinY := Min(ABounds[lAxisIdx].MinY, lTextLabel.WorldY);
          ABounds[lAxisIdx].MaxY := Max(ABounds[lAxisIdx].MaxY, lTextLabel.WorldY);
          ABounds[lAxisIdx].HasY := True;
        end;

      end;

    end;

  end;

  // Р РµРєСѓСЂСЃРёРІРЅРѕ РѕР±С…РѕРґРёРј РґРµС‚РµР№
  for lIdx := 0 to AObject.ChildCount - 1 do
    ProcessObjectBounds(AObject.Children[lIdx], APage, APageMinX, APageMaxX, AHasPageX, ABounds);
end;

procedure FitZoomX(APage: TChartPage);

var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
begin
  if not Assigned(APage) then Exit;
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);
  ProcessObjectBounds(APage, APage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);
  if lHasPageX then
  begin
    if Abs(lPageMaxX - lPageMinX) < 1E-9 then
    begin
      lPageMinX := lPageMinX - 1.0;
      lPageMaxX := lPageMaxX + 1.0;
    end;

    APage.XMinValue := lPageMinX;
    APage.XMaxValue := lPageMaxX;
  end;

  for lIdx := 0 to High(lAxisBounds) do
  begin
    if lAxisBounds[lIdx].HasX and lAxisBounds[lIdx].Axis.UseOwnX then
    begin
      if Abs(lAxisBounds[lIdx].MaxX - lAxisBounds[lIdx].MinX) < 1E-9 then
      begin
        lAxisBounds[lIdx].MinX := lAxisBounds[lIdx].MinX - 1.0;
        lAxisBounds[lIdx].MaxX := lAxisBounds[lIdx].MaxX + 1.0;
      end;

      lAxisBounds[lIdx].Axis.XMinValue := lAxisBounds[lIdx].MinX;
      lAxisBounds[lIdx].Axis.XMaxValue := lAxisBounds[lIdx].MaxX;
    end;

  end;

end;

procedure FitZoomX(AAxis: TChartAxis);

var
  lPage: TChartPage;
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
begin
  if not Assigned(AAxis) then Exit;
  lPage := FindParentPage(AAxis);
  if not Assigned(lPage) then Exit;
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);
  ProcessObjectBounds(lPage, lPage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);
  if AAxis.UseOwnX then
  begin
    for lIdx := 0 to High(lAxisBounds) do
      if lAxisBounds[lIdx].Axis = AAxis then
      begin
        if lAxisBounds[lIdx].HasX then
        begin
          if Abs(lAxisBounds[lIdx].MaxX - lAxisBounds[lIdx].MinX) < 1E-9 then
          begin
            lAxisBounds[lIdx].MinX := lAxisBounds[lIdx].MinX - 1.0;
            lAxisBounds[lIdx].MaxX := lAxisBounds[lIdx].MaxX + 1.0;
          end;

          AAxis.XMinValue := lAxisBounds[lIdx].MinX;
          AAxis.XMaxValue := lAxisBounds[lIdx].MaxX;
        end;

        Break;
      end;

  end

  else
  begin
    if lHasPageX then
    begin
      if Abs(lPageMaxX - lPageMinX) < 1E-9 then
      begin
        lPageMinX := lPageMinX - 1.0;
        lPageMaxX := lPageMaxX + 1.0;
      end;

      lPage.XMinValue := lPageMinX;
      lPage.XMaxValue := lPageMaxX;
    end;

  end;

end;

procedure FitZoomY(APage: TChartPage);

var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
  lSpan: Double;
begin
  if not Assigned(APage) then Exit;
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);
  ProcessObjectBounds(APage, APage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);
  for lIdx := 0 to High(lAxisBounds) do
  begin
    if lAxisBounds[lIdx].HasY then
    begin
      if Abs(lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY) < 1E-9 then
      begin
        lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - 1.0;
        lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + 1.0;
      end

      else
      begin
        lSpan := lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY;
        lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - lSpan * 0.1;
        lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + lSpan * 0.1;
      end;

      lAxisBounds[lIdx].Axis.MinValue := lAxisBounds[lIdx].MinY;
      lAxisBounds[lIdx].Axis.MaxValue := lAxisBounds[lIdx].MaxY;
    end;

  end;

end;

procedure FitZoomY(AAxis: TChartAxis);

var
  lPage: TChartPage;
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;
  lAxisBounds: TAxisBoundsArray;
  lIdx: Integer;
  lSpan: Double;
begin
  if not Assigned(AAxis) then Exit;
  lPage := FindParentPage(AAxis);
  if not Assigned(lPage) then Exit;
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;
  SetLength(lAxisBounds, 0);
  ProcessObjectBounds(lPage, lPage, lPageMinX, lPageMaxX, lHasPageX, lAxisBounds);
  for lIdx := 0 to High(lAxisBounds) do
    if lAxisBounds[lIdx].Axis = AAxis then
    begin
      if lAxisBounds[lIdx].HasY then
      begin
        if Abs(lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY) < 1E-9 then
        begin
          lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - 1.0;
          lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + 1.0;
        end

        else
        begin
          lSpan := lAxisBounds[lIdx].MaxY - lAxisBounds[lIdx].MinY;
          lAxisBounds[lIdx].MinY := lAxisBounds[lIdx].MinY - lSpan * 0.1;
          lAxisBounds[lIdx].MaxY := lAxisBounds[lIdx].MaxY + lSpan * 0.1;
        end;

        AAxis.MinValue := lAxisBounds[lIdx].MinY;
        AAxis.MaxValue := lAxisBounds[lIdx].MaxY;
      end;

      Break;
    end;

end;

procedure FitZoomXY(APage: TChartPage);
begin
  FitZoomX(APage);
  FitZoomY(APage);
end;

procedure FitZoomXY(AAxis: TChartAxis);
begin
  FitZoomX(AAxis);
  FitZoomY(AAxis);
end;

procedure FitPageZoom(APage: TChartPage);
begin
  FitZoomXY(APage);
end;

{ TChartPanZoomListener }

constructor TChartPanZoomListener.Create;
begin
  inherited Create;
  fIsPanning := False;
  fActivePage := nil;
  fIsZoomSelecting := False;
  fZoomStartX := 0;
  fZoomStartY := 0;
  fZoomSelectMode := zsmXY;
end;

procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lTextHit: TChartTextHit;
  lIndex: Integer;
begin
  if not Enabled then Exit;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    if Button = mbLeft then
    begin
      if ssDouble in Shift then
      begin
        if lRenderer.GetTextHitAt(X, Y, lTextHit) then
          Exit;

        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                RestoreUserZoomOnPage(lPage, lRenderer.SelectedObject, True, True);
                lControl.Redraw;
                Handled := True;
                Exit;
              end;
            end;
          end;
      end;

      // Р•СЃР»Рё Р·Р°Р¶Р°С‚ Ctrl, С‚Рѕ СЌС‚Рѕ СЂРµР¶РёРј Р·СѓРјР° РїРѕ СЂР°РјРєРµ (С‚РѕР»СЊРєРѕ РІРЅСѓС‚СЂРё plot area)
      if ssCtrl in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
              lPageRect := lRenderer.GetPageRect(lPage);
              if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
                 (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
              begin
                lContentRect := lRenderer.GetPageContentRect(lPage);
                if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                   (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
                  fZoomSelectMode := zsmXY
                else if IsOnYAxisBand(lRenderer, lPage, X, Y) then
                  fZoomSelectMode := zsmYOnly
                else if IsOnXAxisBand(lRenderer, lPage, X, Y) then
                  fZoomSelectMode := zsmXOnly
                else
                  Continue;
                fIsZoomSelecting := True;
                fZoomStartX := X;
                fZoomStartY := Y;
                fActivePage := lPage;
                Handled := True;
                Exit;

              end;

            end;

          end;

      end;

    end;

    if (Button = mbRight) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              fIsPanning := True;
              fLastX := X;
              fLastY := Y;
              fActivePage := lPage;
              Handled := True;
              Exit;
            end;

          end;

        end;

    end;

  end;

end;

procedure TChartPanZoomListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lWidth, lHeight: Single;
  dX, dY: Integer;
  dValX, dValY: Double;
  lXRange, lYRange: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lSelRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
begin
  if not Enabled then Exit;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    // 1. РЎРѕСЃС‚РѕСЏРЅРёРµ РІС‹РґРµР»РµРЅРёСЏ РѕР±Р»Р°СЃС‚Рё Р·СѓРјРёСЂРѕРІР°РЅРёСЏ (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      BuildZoomSelectionRect(fZoomSelectMode, lContentRect, fZoomStartX, fZoomStartY, X, Y, lSelRect);
      lRenderer.SelectionRectActive := True;
      lRenderer.SelectionRect := lSelRect;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 2. РЎРѕСЃС‚РѕСЏРЅРёРµ РѕР±С‹С‡РЅРѕРіРѕ РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёСЏ РіСЂР°С„РёРєР° РїСЂР°РІРѕР№ РєРЅРѕРїРєРѕР№ РјС‹С€Рё
    if fIsPanning and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lWidth := Max(1.0, lContentRect.Right - lContentRect.Left);
      lHeight := Max(1.0, lContentRect.Bottom - lContentRect.Top);
      dX := X - fLastX;
      dY := Y - fLastY;
      lXRange := fActivePage.XMaxValue - fActivePage.XMinValue;
      dValX := (dX / lWidth) * lXRange;
      fActivePage.XMinValue := fActivePage.XMinValue - dValX;
      fActivePage.XMaxValue := fActivePage.XMaxValue - dValX;
      fActivePage.ZoomedX := True;
      
      // РћРїСЂРµРґРµР»СЏРµРј РІС‹Р±СЂР°РЅРЅСѓСЋ РѕСЃСЊ (Y) РґР»СЏ РёР·РѕР»СЏС†РёРё РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёСЏ
      lSelectedAxis := nil;
      if Assigned(lRenderer.SelectedObject) then
      begin
        if lRenderer.SelectedObject is TChartAxis then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
        else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
      end;

      for lIndex := 0 to fActivePage.ChildCount - 1 do
        if fActivePage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(fActivePage.Children[lIndex]);
          if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
          begin
            lYRange := lAxis.MaxValue - lAxis.MinValue;
            dValY := (dY / lHeight) * lYRange;
            lAxis.MinValue := lAxis.MinValue + dValY;
            lAxis.MaxValue := lAxis.MaxValue + dValY;
          end;
        end;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

  end;

end;

procedure TChartPanZoomListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lAxis: TChartAxis;
  NewXMin, NewXMax, NewYMin, NewYMax: Double;
  lSelRect: TChartPixelRect;
  lSelectedAxis: TChartAxis;
begin
  if not Enabled then Exit;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lRenderer.SelectionRectActive := False;
      fIsZoomSelecting := False;
      // 1. РџРѕР»РЅС‹Р№ РјР°СЃС€С‚Р°Р± РїСЂРё РґРІРёР¶РµРЅРёРё РІР»РµРІРѕ (СЃРјР°С…РёРІР°РЅРёРµ РІР»РµРІРѕ)
      if ((fZoomSelectMode = zsmXY) and (X < fZoomStartX - 5)) or
         ((fZoomSelectMode = zsmXOnly) and (X < fZoomStartX - 5)) or
         ((fZoomSelectMode = zsmYOnly) and (Y < fZoomStartY - 5)) then
      begin
        RestoreUserZoomOnPage(fActivePage, lRenderer.SelectedObject,
          fZoomSelectMode <> zsmYOnly, fZoomSelectMode <> zsmXOnly);
        lControl.Redraw;
        Handled := True;
      end

      // 2. РџСЂРёР±Р»РёР¶РµРЅРёРµ РїСЂРё РґРІРёР¶РµРЅРёРё РІРїСЂР°РІРѕ Рё РІРЅРёР·
      else if ((fZoomSelectMode = zsmXY) and (X > fZoomStartX + 2) and (Y > fZoomStartY + 2)) or
         ((fZoomSelectMode = zsmYOnly) and (Abs(Y - fZoomStartY) > 2)) or
         ((fZoomSelectMode = zsmXOnly) and (Abs(X - fZoomStartX) > 2)) then
      begin
        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        BuildZoomSelectionRect(fZoomSelectMode, lContentRect, fZoomStartX, fZoomStartY, X, Y, lSelRect);
        if (lSelRect.Right > lSelRect.Left) and (lSelRect.Bottom > lSelRect.Top) then
        begin
          // Р—СѓРј РїРѕ X
          if fZoomSelectMode <> zsmYOnly then
          begin
            NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
            NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
            fActivePage.XMinValue := NewXMin;
            fActivePage.XMaxValue := NewXMax;
            fActivePage.ZoomedX := True;
          end;
          // РћРїСЂРµРґРµР»СЏРµРј РІС‹Р±СЂР°РЅРЅСѓСЋ РѕСЃСЊ (Y) РґР»СЏ РёР·РѕР»СЏС†РёРё СЂР°РјРєРё Р·СѓРјР°
          lSelectedAxis := nil;
          if Assigned(lRenderer.SelectedObject) then
          begin
            if lRenderer.SelectedObject is TChartAxis then
              lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
            else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
              lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
          end;

          // Р—СѓРј РїРѕ РѕСЃСЏРј Y
          for lIndex := 0 to fActivePage.ChildCount - 1 do
            if fActivePage.Children[lIndex] is TChartAxis then
            begin
              lAxis := TChartAxis(fActivePage.Children[lIndex]);
              if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
              begin
                if (fZoomSelectMode <> zsmYOnly) and lAxis.UseOwnX then
                begin
                  NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                  NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                  lAxis.XMinValue := NewXMin;
                  lAxis.XMaxValue := NewXMax;
                end;

                if fZoomSelectMode <> zsmXOnly then
                begin
                  NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
                  NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
                  lAxis.MinValue := NewYMin;
                  lAxis.MaxValue := NewYMax;
                end;
              end;
            end;

          lControl.Redraw;
          Handled := True;
        end;

      end

      else
      begin
        lControl.Redraw;
        Handled := True;
      end;

      fActivePage := nil;
      Exit;
    end;

    if Button = mbRight then
    begin
      if fIsPanning then
      begin
        fIsPanning := False;
        fActivePage := nil;
        Handled := True;
      end;

    end;

  end;

end;

procedure TChartPanZoomListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lContentRect: TChartPixelRect;
  lZoomFactor: Double;
  lMouseValX: Double;
  lMouseValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lSelectedAxis: TChartAxis;
begin
  if not Enabled then Exit;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;
    // РќР°С…РѕРґРёРј СЃС‚СЂР°РЅРёС†Сѓ РїРѕРґ РјС‹С€РєРѕР№ РґР»СЏ РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёСЏ
    lPage := nil;
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[lIndex]));
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          Break;
        end;

      end;

    if Assigned(lPage) and not lPage.Locked then
    begin
      lContentRect := lRenderer.GetPageContentRect(lPage);
      if WheelDelta < 0 then
        lZoomFactor := 1.1
      else
        lZoomFactor := 1.0 / 1.1;
      // РњР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёРµ РїРѕ РѕСЃРё X РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ РєСѓСЂСЃРѕСЂР° РјС‹С€Рё
      lMouseValX := lRenderer.PixelToXValue(lPage, nil, X, lContentRect.Left, lContentRect.Right);
      lPage.XMinValue := lMouseValX - (lMouseValX - lPage.XMinValue) * lZoomFactor;
      lPage.XMaxValue := lMouseValX + (lPage.XMaxValue - lMouseValX) * lZoomFactor;
      lPage.ZoomedX := True;
      
      // РћРїСЂРµРґРµР»СЏРµРј РІС‹Р±СЂР°РЅРЅСѓСЋ РѕСЃСЊ (Y) РґР»СЏ РёР·РѕР»СЏС†РёРё Р·СѓРјР°
      lSelectedAxis := nil;
      if Assigned(lRenderer.SelectedObject) then
      begin
        if lRenderer.SelectedObject is TChartAxis then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
        else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
      end;

      // РњР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёРµ РїРѕ РѕСЃСЏРј Y РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ РєСѓСЂСЃРѕСЂР° РјС‹С€Рё
      for lIndex := 0 to lPage.ChildCount - 1 do
        if lPage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(lPage.Children[lIndex]);
          if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
          begin
            lMouseValY := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);
            lAxis.MinValue := lMouseValY - (lMouseValY - lAxis.MinValue) * lZoomFactor;
            lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;
          end;
        end;

      lControl.Redraw;
      Handled := True;
    end;

  end;

end;

end.

