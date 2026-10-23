unit uOglChartCursorListener;
{
  Модуль uOglChartCursorListener
  Описание: Слушатель событий мыши для управления интерактивным курсором графика.
  Shift выбирает максимум видимого ряда в окне ±10 экранных пикселей,
  Ctrl+Shift — минимум. Ряд принадлежит текущей странице; Y мыши не меняет
  тип экстремума. Поиск не выделяет память и пропускает NaN/Infinity.
}
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartRenderer, uOglChartChart,
  uOglChartCursor, uOglChartTrend, uOglChartFontMng;
type
  TDragCursorState = (dcsNone, dcsX1, dcsX2, dcsLabel1, dcsLabel2, dcsHorizontal);
  { TChartCursorListener }
  // Слушатель событий для интерактивного измерительного курсора.
  // Обрабатывает перемещение линий курсора, перетаскивание меток,
  // притягивание к экстремумам трендов (Shift) и клавиатурные сочетания.
  TChartCursorListener = class(TChartFrameListener)
  private
    fDragState: TDragCursorState;
    fActivePage: TChartPage;
    fHorizontal: TChartHorizontalCursor;
    fLastMouseX: Integer;
    fLastMouseY: Integer;
    fStartX: Integer;
    fStartY: Integer;

    function GetCursorLabelRect(ACursor: TChartCursor; ALabelIdx: Integer; AXPixel, AYPixel: Single; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;
    function SpectrumCursorXAtFraction(APage: TChartPage;
      AFraction: Double): Double;
public
      constructor Create; override;
      procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;
  end;
// Allocation-free extremum search; bounds are world X (caller supplies log-aware window).
function ChartSnapXToExtremum(ATrend: cBaseTrend; AX, ALeftX,
  ARightX: Double; AMinimum: Boolean): Double;
implementation
constructor TChartCursorListener.Create;
begin
  inherited Create;
  fDragState := dcsNone;
  fActivePage := nil;
  fLastMouseX := 0;
  fLastMouseY := 0;
end;

function TChartCursorListener.SpectrumCursorXAtFraction(APage: TChartPage;
  AFraction: Double): Double;
var
  lMinX, lMaxX: Double;
begin
  Result := 0;
  if APage = nil then
    Exit;
  lMinX := APage.XMinValue;
  lMaxX := APage.XMaxValue;
  AFraction := EnsureRange(AFraction, 0.0, 1.0);
  if (APage.XScale = casLog10) and (lMinX > 0) and (lMaxX > lMinX) then
    Result := Power(10, Log10(lMinX) +
      AFraction * (Log10(lMaxX) - Log10(lMinX)))
  else
    Result := lMinX + AFraction * (lMaxX - lMinX);
end;
function TChartCursorListener.GetCursorLabelRect(ACursor: TChartCursor; ALabelIdx: Integer; AXPixel, AYPixel: Single; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;
var
  lFont: cOglFont;
  lTextWidth, lTextHeight: Single;
  lText: string;
  lLines: TStringList;
  I: Integer;
  lColors: TCardinalArray;
begin
  lFont := ARenderer.FontManager.Font(cfGridTick);
  lText := ARenderer.GetCursorLabelTextAndColors(ACursor, ALabelIdx, APage, lColors);
  lLines := TStringList.Create;
  try
    lLines.Text := lText;
    lTextWidth := 0;
    for I := 0 to lLines.Count - 1 do
      lTextWidth := Max(lTextWidth, lFont.TextPixelWidth(lLines[I]));
    lTextHeight := lLines.Count * lFont.TextPixelHeight + (lLines.Count - 1) * 2;

    Result := ChartCursorLabelRect(AXPixel, AYPixel, lTextWidth, lTextHeight,
      ((ALabelIdx = 1) and ACursor.Label1OnLeft) or
      ((ALabelIdx = 2) and ACursor.Label2OnLeft));
  finally
    lLines.Free;
  end;
end;
function ChartSnapXToExtremum(ATrend: cBaseTrend;
  AX, ALeftX, ARightX: Double; AMinimum: Boolean): Double;
var
  lLine: cLineSeries;
  lBuff: cBuffTrend1d;
  I: Integer;
  lValX, lValY: Double;
  lMinY, lMaxY: Double;
  lMinX, lMaxX: Double;
  lFound: Boolean;
  lIdxStart, lIdxEnd: Integer;
  lIndexA, lIndexB: Double;
  AMouseWorldX: Double;
begin
  AMouseWorldX := AX;
  Result := AMouseWorldX;
  if not Assigned(ATrend) then Exit;

  lMinY := Infinity;
  lMaxY := NegInfinity;
  lMinX := AMouseWorldX;
  lMaxX := AMouseWorldX;
  lFound := False;

  if ATrend is cLineSeries then
  begin
    lLine := cLineSeries(ATrend);
    for I := 0 to lLine.PointCount - 1 do
    begin
      lValX := lLine.Points[I].X;
      lValY := lLine.Points[I].Y;
      if not IsNan(lValX) and not IsInfinite(lValX) and
        not IsNan(lValY) and not IsInfinite(lValY) and
        (lValX >= ALeftX) and (lValX <= ARightX) then
      begin
        lFound := True;
        if (lValY < lMinY) or ((lValY = lMinY) and
          (Abs(lValX - AMouseWorldX) < Abs(lMinX - AMouseWorldX))) then
        begin
          lMinY := lValY;
          lMinX := lValX;
        end;
        if (lValY > lMaxY) or ((lValY = lMaxY) and
          (Abs(lValX - AMouseWorldX) < Abs(lMaxX - AMouseWorldX))) then
        begin
          lMaxY := lValY;
          lMaxX := lValX;
        end;
      end;
    end;
  end
  else if ATrend is cBuffTrend1d then
  begin
    lBuff := cBuffTrend1d(ATrend);
    if (lBuff.DX <> 0) and (lBuff.Count > 0) and
      not IsNan(lBuff.DX) and not IsInfinite(lBuff.DX) and
      not IsNan(lBuff.X0) and not IsInfinite(lBuff.X0) then
    begin
      lIndexA := (ALeftX - lBuff.X0) / lBuff.DX;
      lIndexB := (ARightX - lBuff.X0) / lBuff.DX;
      if (Max(lIndexA, lIndexB) < 0) or
        (Min(lIndexA, lIndexB) > lBuff.Count - 1) then Exit;
      lIdxStart := Floor(Max(0, Min(lIndexA, lIndexB)));
      lIdxEnd := Ceil(Min(lBuff.Count - 1, Max(lIndexA, lIndexB)));

      for I := lIdxStart to lIdxEnd do
      begin
        lValX := lBuff.X0 + I * lBuff.DX;
        lValY := lBuff.Values[I];
        if not IsNan(lValY) and not IsInfinite(lValY) and
          not IsNan(lValX) and not IsInfinite(lValX) and
          (lValX >= ALeftX) and (lValX <= ARightX) then
        begin
          lFound := True;
          if (lValY < lMinY) or ((lValY = lMinY) and
            (Abs(lValX - AMouseWorldX) < Abs(lMinX - AMouseWorldX))) then
          begin
            lMinY := lValY;
            lMinX := lValX;
          end;
          if (lValY > lMaxY) or ((lValY = lMaxY) and
            (Abs(lValX - AMouseWorldX) < Abs(lMaxX - AMouseWorldX))) then
          begin
            lMaxY := lValY;
            lMaxX := lValX;
          end;
        end;
      end;
    end;
  end;

  if lFound then
  begin
    if AMinimum then
      Result := lMinX
    else
      Result := lMaxX;
  end;
end;
procedure TChartCursorListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lCursor: TChartCursor;
  I: Integer;
  lPixelX1, lPixelX2: Single;
  lLabelY1, lLabelY2: Single;
  lLabelRect1, lLabelRect2: TChartPixelRect;
  lHorizontal: TChartHorizontalCursor;
begin
  if not Enabled then Exit;
  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lModel) then Exit;
    fActivePage := nil;
    fHorizontal := nil;
    fDragState := dcsNone;

    for I := 0 to lModel.ChildCount - 1 do
    begin
      if lModel.Children[I] is TChartPage then
      begin
        lPage := TChartPage(lModel.Children[I]);
        lPageRect := lRenderer.GetPageRect(lPage);
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        begin
          fActivePage := lPage;
          Break;
        end;
      end;
    end;
    if not Assigned(fActivePage) then Exit;
    lCursor := nil;
    for I := 0 to fActivePage.ChildCount - 1 do
      if fActivePage.Children[I] is TChartCursor then
        lCursor := TChartCursor(fActivePage.Children[I]);
    lContentRect := lRenderer.GetPageContentRect(fActivePage);
    if Assigned(lCursor) and lCursor.Visible then
    begin
    lPixelX1 := lRenderer.XValueToPixel(fActivePage, nil, lCursor.X1, lContentRect.Left, lContentRect.Right);
    lPixelX2 := lRenderer.XValueToPixel(fActivePage, nil, lCursor.X2, lContentRect.Left, lContentRect.Right);

    lLabelY1 := lContentRect.Bottom + lCursor.LabelY1Offset * (lContentRect.Top - lContentRect.Bottom);
    lLabelRect1 := GetCursorLabelRect(lCursor, 1, lPixelX1, lLabelY1, lRenderer, fActivePage);
    if (X >= lLabelRect1.Left) and (X <= lLabelRect1.Right) and
       (Y >= lLabelRect1.Top) and (Y <= lLabelRect1.Bottom) then
    begin
      fDragState := dcsLabel1;
      fStartX := X;
      fStartY := Y;
      Handled := True;
      Exit;
    end;
    if lCursor.CursorType = cctDouble then
    begin
      lLabelY2 := lContentRect.Bottom + lCursor.LabelY2Offset * (lContentRect.Top - lContentRect.Bottom);
      lLabelRect2 := GetCursorLabelRect(lCursor, 2, lPixelX2, lLabelY2, lRenderer, fActivePage);
      if (X >= lLabelRect2.Left) and (X <= lLabelRect2.Right) and
         (Y >= lLabelRect2.Top) and (Y <= lLabelRect2.Bottom) then
      begin
        fDragState := dcsLabel2;
        fStartX := X;
        fStartY := Y;
        Handled := True;
        Exit;
      end;
    end;
    if Abs(X - lPixelX1) <= 5 then
    begin
      fDragState := dcsX1;
      fStartX := X;
      fStartY := Y;
      if ssShift in Shift then MouseMove(ASender, Shift, X, Y, Handled);
      Handled := True;
      Exit;
    end;
    if (lCursor.CursorType = cctDouble) and (Abs(X - lPixelX2) <= 5) then
    begin
      fDragState := dcsX2;
      fStartX := X;
      fStartY := Y;
      if ssShift in Shift then MouseMove(ASender, Shift, X, Y, Handled);
      Handled := True;
      Exit;
    end;
    end;
    if (X < lContentRect.Left) or (X > lContentRect.Right) or
      (Y < lContentRect.Top) or (Y > lContentRect.Bottom) then Exit;
    for I := 0 to fActivePage.ChildCount - 1 do
      if fActivePage.Children[I] is TChartHorizontalCursor then
      begin
        lHorizontal := TChartHorizontalCursor(fActivePage.Children[I]);
        if not lHorizontal.Visible or (lHorizontal.Axis = nil) then Continue;
        if Abs(Y - lRenderer.AxisValueToPixel(lHorizontal.Axis,
          lHorizontal.Y, lContentRect.Bottom, lContentRect.Top)) > 5 then Continue;
        fHorizontal := lHorizontal;
        fDragState := dcsHorizontal;
        Handled := True;
        Exit;
      end;
  end;
end;
procedure TChartCursorListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lCursor: TChartCursor;
  I, J: Integer;
  lPixelX1, lPixelX2: Single;
  lLabelY1, lLabelY2: Single;
  lLabelRect1, lLabelRect2: TChartPixelRect;
  lHoverLine, lHoverLabel: Boolean;
  lMouseWorldX, lLeftX, lRightX: Double;
  lTrend: cBaseTrend;
  lAxis: TChartAxis;
  lSnappedX: Double;
  lNewOffset: Double;
begin
  if not Enabled then Exit;
  fLastMouseX := X;
  fLastMouseY := Y;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lModel) then Exit;
    if fDragState <> dcsNone then
    begin
      if not Assigned(fActivePage) then Exit;
      // Configuration can remove a page/overlay between mouse messages.
      I := 0;
      while (I < lModel.ChildCount) and (lModel.Children[I] <> fActivePage) do Inc(I);
      if I = lModel.ChildCount then
      begin
        fDragState := dcsNone; fActivePage := nil; fHorizontal := nil;
        Exit;
      end;
      if fDragState = dcsHorizontal then
      begin
        I := 0;
        while (I < fActivePage.ChildCount) and
          (fActivePage.Children[I] <> fHorizontal) do Inc(I);
        if I = fActivePage.ChildCount then
        begin
          fDragState := dcsNone; fHorizontal := nil;
          Exit;
        end;
        if not fHorizontal.Visible or (fHorizontal.Axis = nil) then Exit;
        I := 0;
        while (I < fActivePage.ChildCount) and
          (fActivePage.Children[I] <> fHorizontal.Axis) do Inc(I);
        if I = fActivePage.ChildCount then
        begin
          fDragState := dcsNone; fHorizontal := nil;
          Exit;
        end;
        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        fHorizontal.Y := lRenderer.PixelToAxisValue(fHorizontal.Axis,
          EnsureRange(Y, lContentRect.Top, lContentRect.Bottom),
          lContentRect.Bottom, lContentRect.Top);
        lControl.NotifyCursorChanged(fHorizontal);
        lControl.Redraw;
        Handled := True;
        Exit;
      end;
      lCursor := GetOrCreatePageCursor(fActivePage);
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      if fDragState in [dcsX1, dcsX2] then
      begin
        lMouseWorldX := lRenderer.PixelToXValue(fActivePage, nil, X, lContentRect.Left, lContentRect.Right);

        if ssShift in Shift then
        begin
          // Вычисляем радиус примагничивания 10 пикселей
          { Both pixel boundaries must be transformed separately on logarithmic X. }
          lLeftX := lRenderer.PixelToXValue(fActivePage, nil, X - 10, lContentRect.Left, lContentRect.Right);
          lRightX := lRenderer.PixelToXValue(fActivePage, nil, X + 10, lContentRect.Left, lContentRect.Right);
          // Определяем активный объект по правилам приоритета
          lTrend := nil;
          if Assigned(lRenderer.SelectedObject) then
          begin
            if (lRenderer.SelectedObject is cBaseTrend) and
              cBaseTrend(lRenderer.SelectedObject).Visible and
              (lRenderer.SelectedObject.Parent is TChartAxis) and
              TChartAxis(lRenderer.SelectedObject.Parent).Visible and
              (lRenderer.SelectedObject.Parent.Parent = fActivePage) then
              lTrend := cBaseTrend(lRenderer.SelectedObject)
            else if (lRenderer.SelectedObject is TChartAxis) and
              TChartAxis(lRenderer.SelectedObject).Visible and
              (lRenderer.SelectedObject.Parent = fActivePage) then
            begin
              for I := 0 to TChartAxis(lRenderer.SelectedObject).ChildCount - 1 do
                if (TChartAxis(lRenderer.SelectedObject).Children[I] is cBaseTrend) and
                  cBaseTrend(TChartAxis(lRenderer.SelectedObject).Children[I]).Visible then
                begin
                  lTrend := cBaseTrend(TChartAxis(lRenderer.SelectedObject).Children[I]);
                  Break;
                end;
            end;
          end;

          // Если тренд не найден и выделена страница (или выделение пустое/другое)
          if not Assigned(lTrend) then
          begin
            // Ищем активную ось (которая выделена) или первую в списке на активной странице
            lAxis := nil;
            if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartAxis) and
              TChartAxis(lRenderer.SelectedObject).Visible and
              (TChartAxis(lRenderer.SelectedObject).Parent = fActivePage) then
              lAxis := TChartAxis(lRenderer.SelectedObject)
            else
            begin
              for I := 0 to fActivePage.ChildCount - 1 do
                if (fActivePage.Children[I] is TChartAxis) and
                  TChartAxis(fActivePage.Children[I]).Visible then
                begin
                  for J := 0 to fActivePage.Children[I].ChildCount - 1 do
                    if (fActivePage.Children[I].Children[J] is cBaseTrend) and
                      cBaseTrend(fActivePage.Children[I].Children[J]).Visible then
                    begin
                      lAxis := TChartAxis(fActivePage.Children[I]);
                      Break;
                    end;
                  if lAxis <> nil then Break;
                end;
            end;

            if Assigned(lAxis) then
            begin
              for I := 0 to lAxis.ChildCount - 1 do
                if (lAxis.Children[I] is cBaseTrend) and
                  cBaseTrend(lAxis.Children[I]).Visible then
                begin
                  lTrend := cBaseTrend(lAxis.Children[I]);
                  Break;
                end;
            end;
          end;
          if Assigned(lTrend) then
          begin
            lSnappedX := ChartSnapXToExtremum(lTrend, lMouseWorldX,
              Min(lLeftX, lRightX), Max(lLeftX, lRightX), ssCtrl in Shift);
            lMouseWorldX := lSnappedX;
          end;
        end;
        if fDragState = dcsX1 then
          lCursor.X1 := lMouseWorldX
        else
          lCursor.X2 := lMouseWorldX;
      end
      else if fDragState in [dcsLabel1, dcsLabel2] then
      begin
        lPixelX1 := lRenderer.XValueToPixel(fActivePage, nil, lCursor.X1,
          lContentRect.Left, lContentRect.Right);
        lPixelX2 := lRenderer.XValueToPixel(fActivePage, nil, lCursor.X2,
          lContentRect.Left, lContentRect.Right);
        if lContentRect.Top <> lContentRect.Bottom then
        begin
          lNewOffset := (Y - lContentRect.Bottom) / (lContentRect.Top - lContentRect.Bottom);
          if lNewOffset < 0.0 then lNewOffset := 0.0;
          if lNewOffset > 1.0 then lNewOffset := 1.0;

          if fDragState = dcsLabel1 then
          begin
            lCursor.LabelY1Offset := lNewOffset;
            lCursor.Label1OnLeft := X < lPixelX1;
          end
          else
          begin
            lCursor.LabelY2Offset := lNewOffset;
            lCursor.Label2OnLeft := X < lPixelX2;
          end;
        end;
      end;
      lControl.NotifyCursorChanged(lCursor);
      lControl.Redraw;
      Handled := True;
      Exit;
    end;
    lPage := nil;
    for I := 0 to lModel.ChildCount - 1 do
    begin
      if lModel.Children[I] is TChartPage then
      begin
        lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[I]));
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        begin
          lPage := TChartPage(lModel.Children[I]);
          Break;
        end;
      end;
    end;
    if Assigned(lPage) then
    begin
      lCursor := GetOrCreatePageCursor(lPage);
      if lCursor.Visible then
      begin
        lContentRect := lRenderer.GetPageContentRect(lPage);
        lPixelX1 := lRenderer.XValueToPixel(lPage, nil, lCursor.X1, lContentRect.Left, lContentRect.Right);
        lPixelX2 := lRenderer.XValueToPixel(lPage, nil, lCursor.X2, lContentRect.Left, lContentRect.Right);
        lHoverLine := False;
        lHoverLabel := False;
        lLabelY1 := lContentRect.Bottom + lCursor.LabelY1Offset * (lContentRect.Top - lContentRect.Bottom);
        lLabelRect1 := GetCursorLabelRect(lCursor, 1, lPixelX1, lLabelY1, lRenderer, lPage);
        if (X >= lLabelRect1.Left) and (X <= lLabelRect1.Right) and
           (Y >= lLabelRect1.Top) and (Y <= lLabelRect1.Bottom) then
        begin
          lHoverLabel := True;
        end;
        if not lHoverLabel and (lCursor.CursorType = cctDouble) then
        begin
          lLabelY2 := lContentRect.Bottom + lCursor.LabelY2Offset * (lContentRect.Top - lContentRect.Bottom);
          lLabelRect2 := GetCursorLabelRect(lCursor, 2, lPixelX2, lLabelY2, lRenderer, lPage);
          if (X >= lLabelRect2.Left) and (X <= lLabelRect2.Right) and
             (Y >= lLabelRect2.Top) and (Y <= lLabelRect2.Bottom) then
          begin
            lHoverLabel := True;
          end;
        end;
        if not lHoverLabel then
        begin
          if Abs(X - lPixelX1) <= 5 then
            lHoverLine := True
          else if (lCursor.CursorType = cctDouble) and (Abs(X - lPixelX2) <= 5) then
            lHoverLine := True;
        end;
        if lHoverLine then
        begin
          TControl(ASender).Cursor := crSizeWE;
          Handled := True;
          Exit;
        end
        else if lHoverLabel then
        begin
          TControl(ASender).Cursor := crSizeNS;
          Handled := True;
          Exit;
        end;
      end;
    end;
  end;
end;
procedure TChartCursorListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
  if not Enabled then Exit;
  if fDragState <> dcsNone then
  begin
    fDragState := dcsNone;
    fHorizontal := nil;
    Handled := True;
  end;
end;
procedure TChartCursorListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lCursor: TChartCursor;
  lPageRect, lContentRect: TChartPixelRect;
  lMouseWorldX: Double;
  I: Integer;
begin
  if not Enabled then Exit;
  // Alt + 3
  // Alt + M or Alt + 4 (MultiLine cursor toggle)
  if (((Key = Ord('M')) or (Key = Ord('4'))) and (ssAlt in Shift)) then
  begin
    if Supports(ASender, IChartControl, lControl) then
    begin
      lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
      if not Assigned(lRenderer) then Exit;
      lModel := TChartModel(lControl.GetModel);
      if not Assigned(lModel) then Exit;
      lPage := nil;
      for I := 0 to lModel.ChildCount - 1 do
      begin
        if lModel.Children[I] is TChartPage then
        begin
          lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[I]));
          if (fLastMouseX >= lPageRect.Left) and (fLastMouseX <= lPageRect.Right) and
             (fLastMouseY >= lPageRect.Top) and (fLastMouseY <= lPageRect.Bottom) then
          begin
            lPage := TChartPage(lModel.Children[I]);
            Break;
          end;
        end;
      end;
      if Assigned(lPage) then
      begin
        lCursor := GetOrCreatePageCursor(lPage);
        case lCursor.MultiLineMode of
          mlDisabled:  lCursor.MultiLineMode := mlEnabled;
          mlEnabled:   lCursor.MultiLineMode := mlShowNames;
          mlShowNames: lCursor.MultiLineMode := mlDisabled;
        end;
        lControl.NotifyCursorChanged(lCursor);
        lControl.Redraw;
        Key := 0;
        Handled := True;
        Exit;
      end;
    end;
  end;
  if (Key = Ord('3')) and (ssAlt in Shift) then
  begin
    if Supports(ASender, IChartControl, lControl) then
    begin
      lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
      if not Assigned(lRenderer) then Exit;
      lModel := TChartModel(lControl.GetModel);
      if not Assigned(lModel) then Exit;
      lPage := nil;
      for I := 0 to lModel.ChildCount - 1 do
      begin
        if lModel.Children[I] is TChartPage then
        begin
          lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[I]));
          if (fLastMouseX >= lPageRect.Left) and (fLastMouseX <= lPageRect.Right) and
             (fLastMouseY >= lPageRect.Top) and (fLastMouseY <= lPageRect.Bottom) then
          begin
            lPage := TChartPage(lModel.Children[I]);
            Break;
          end;
        end;
      end;
      if not Assigned(lPage) and (lModel.ChildCount > 0) then
      begin
        for I := 0 to lModel.ChildCount - 1 do
          if lModel.Children[I] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[I]);
            Break;
          end;
      end;
      if Assigned(lPage) then
      begin
        lCursor := GetOrCreatePageCursor(lPage);
        if not lCursor.Visible then
        begin
          { Спектральный курсор мог остаться за пределами нового zoom/range.
            При появлении ставим линии в 20% и 80% именно видимой ширины;
            для логарифмической X это геометрическая интерполяция. }
          if SameText(lPage.Name, 'SpectrumPage') then
          begin
            lCursor.X1 := SpectrumCursorXAtFraction(lPage, 0.2);
            lCursor.X2 := SpectrumCursorXAtFraction(lPage, 0.8);
          end;
          lCursor.Visible := True;
          lCursor.CursorType := cctSingle;
        end
        else if lCursor.CursorType = cctSingle then
        begin
          lCursor.CursorType := cctDouble;
        end
        else
        begin
          lCursor.Visible := False;
        end;
        lControl.NotifyCursorChanged(lCursor);
        lControl.Redraw;
        Key := 0;
        Handled := True;
        Exit;
      end;
    end;
  end;
  // Home key is 36
  if (Key = 36) then
  begin
    if Supports(ASender, IChartControl, lControl) then
    begin
      lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
      if not Assigned(lRenderer) then Exit;
      lModel := TChartModel(lControl.GetModel);
      if not Assigned(lModel) then Exit;
      lPage := nil;
      for I := 0 to lModel.ChildCount - 1 do
      begin
        if lModel.Children[I] is TChartPage then
        begin
          lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[I]));
          if (fLastMouseX >= lPageRect.Left) and (fLastMouseX <= lPageRect.Right) and
             (fLastMouseY >= lPageRect.Top) and (fLastMouseY <= lPageRect.Bottom) then
          begin
            lPage := TChartPage(lModel.Children[I]);
            Break;
          end;
        end;
      end;
      if Assigned(lPage) then
      begin
        lCursor := GetOrCreatePageCursor(lPage);
        if lCursor.Visible then
        begin
          lContentRect := lRenderer.GetPageContentRect(lPage);
          lMouseWorldX := lRenderer.PixelToXValue(lPage, nil, fLastMouseX, lContentRect.Left, lContentRect.Right);
          if ssCtrl in Shift then
          begin
            if lCursor.CursorType = cctDouble then
            begin
              lCursor.X2 := lMouseWorldX;
              lControl.NotifyCursorChanged(lCursor);
              lControl.Redraw;
              Key := 0;
              Handled := True;
            end;
          end
          else
          begin
            lCursor.X1 := lMouseWorldX;
            lControl.NotifyCursorChanged(lCursor);
            lControl.Redraw;
            Key := 0;
            Handled := True;
          end;
        end;
      end;
    end;
  end;
end;
end.
