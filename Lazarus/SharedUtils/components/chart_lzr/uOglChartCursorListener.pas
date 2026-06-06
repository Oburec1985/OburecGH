unit uOglChartCursorListener;

{
  Модуль uOglChartCursorListener
  Описание: Слушатель событий мыши для управления интерактивным курсором графика.
}

{ objfpc}{+}

interface

uses

  Classes, SysUtils, Controls, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartRenderer, uOglChartChart,
  uOglChartCursor, uOglChartTrend, uOglChartFontMng;

type

  TDragCursorState = (dcsNone, dcsX1, dcsX2, dcsLabel1, dcsLabel2);

  { TChartCursorListener }

  // Слушатель событий для интерактивного измерительного курсора.
  // Обрабатывает перемещение линий курсора, перетаскивание меток,
  // притягивание к экстремумам трендов (Shift) и клавиатурные сочетания.

  TChartCursorListener = class(TChartFrameListener)
  private
    fDragState: TDragCursorState;
    fActivePage: TChartPage;
    fLastMouseX: Integer;
    fLastMouseY: Integer;
    fStartX: Integer;
    fStartY: Integer;

    

    function GetCursorLabelRect(ACursor: TChartCursor; ALabelIdx: Integer; AXPixel, AYPixel: Single; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;
    function GetSnappedX(ATrend: cBaseTrend; AMouseWorldX, AMouseWorldY, ADeltaXWorld: Double; const AMode: string): Double;
public
      constructor Create; override;
      procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;

    

procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); override;

  end;

implementation

constructor TChartCursorListener.Create;

begin

  inherited Create;

  fDragState := dcsNone;

  fActivePage := nil;

  fLastMouseX := 0;

  fLastMouseY := 0;

end;

function TChartCursorListener.GetCursorLabelRect(ACursor: TChartCursor; ALabelIdx: Integer; AXPixel, AYPixel: Single; ARenderer: TOpenGLChartRenderer; APage: TChartPage): TChartPixelRect;

var

  lFont: cOglFont;

  lTextWidth, lTextHeight: Single;

  lText: string;

  lTrend: cBaseTrend;

  lAxis: TChartAxis;

  lValY: Double;

  lLines: TStringList;

  I: Integer;

begin

  lFont := ARenderer.FontManager.Font(cfGridTick);

  lText := '';

  lTrend := ARenderer.FindSelectedTrend(APage, ARenderer.SelectedObject);

  

  if ALabelIdx = 1 then

  begin

    lValY := 0;

    if Assigned(lTrend) then

      ARenderer.GetTrendValueAtX(lTrend, ACursor.X1, lValY);

    lText := Format('X1: %0.5g'#13'Y1: %0.5g', [ACursor.X1, lValY]);

  end

  else

  begin

    lValY := 0;

    if Assigned(lTrend) then

      ARenderer.GetTrendValueAtX(lTrend, ACursor.X2, lValY);

    lText := Format('X2: %0.5g'#13'Y2: %0.5g', [ACursor.X2, lValY]);

  end;

  

  lLines := TStringList.Create;

  try

    lLines.Text := lText;

    lTextWidth := 0;

    for I := 0 to lLines.Count - 1 do

      lTextWidth := Max(lTextWidth, lFont.TextPixelWidth(lLines[I]));

    lTextHeight := lLines.Count * lFont.TextPixelHeight + (lLines.Count - 1) * 2;

    

    Result.Left := Round(AXPixel + 2);

    Result.Right := Round(AXPixel + 2 + lTextWidth + 12);

    Result.Top := Round(AYPixel - lTextHeight / 2 - 4);

    Result.Bottom := Round(AYPixel + lTextHeight / 2 + 4);

  finally

    lLines.Free;

  end;

end;

function TChartCursorListener.GetSnappedX(ATrend: cBaseTrend; AMouseWorldX, AMouseWorldY, ADeltaXWorld: Double; const AMode: string): Double;

var

  lLine: cLineSeries;

  lBuff: cBuffTrend1d;

  I: Integer;

  lValX, lValY: Double;

  lMinY, lMaxY: Double;

  lMinX, lMaxX: Double;

  lFound: Boolean;

  lIdxStart, lIdxEnd: Integer;

begin

  Result := AMouseWorldX;

  if not Assigned(ATrend) then Exit;

  

  lMinY := 1e30;

  lMaxY := -1e30;

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

      if Abs(lValX - AMouseWorldX) <= ADeltaXWorld then

      begin

        lFound := True;

        if lValY < lMinY then

        begin

          lMinY := lValY;

          lMinX := lValX;

        end;

        if lValY > lMaxY then

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

    if (lBuff.DX <> 0) and (lBuff.Count > 0) then

    begin

      lIdxStart := Trunc((AMouseWorldX - ADeltaXWorld - lBuff.X0) / lBuff.DX);

      lIdxEnd := Trunc((AMouseWorldX + ADeltaXWorld - lBuff.X0) / lBuff.DX) + 1;

      if lIdxStart < 0 then lIdxStart := 0;

      if lIdxEnd >= lBuff.Count then lIdxEnd := lBuff.Count - 1;

      

      for I := lIdxStart to lIdxEnd do

      begin

        lValX := lBuff.X0 + I * lBuff.DX;

        lValY := lBuff.Values[I];

        if Abs(lValX - AMouseWorldX) <= ADeltaXWorld then

        begin

          lFound := True;

          if lValY < lMinY then

          begin

            lMinY := lValY;

            lMinX := lValX;

          end;

          if lValY > lMaxY then

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

    if AMode = 'min' then

      Result := lMinX

    else if AMode = 'max' then

      Result := lMaxX

    else

    begin

      if Abs(AMouseWorldY - lMinY) < Abs(AMouseWorldY - lMaxY) then

        Result := lMinX

      else

        Result := lMaxX;

    end;

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

begin

  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then

  begin

    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);

    if not Assigned(lRenderer) then Exit;

    lModel := TChartModel(lControl.GetModel);

    if not Assigned(lModel) then Exit;

    fActivePage := nil;

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

    lCursor := GetOrCreatePageCursor(fActivePage);

    if not lCursor.Visible then Exit;

    lContentRect := lRenderer.GetPageContentRect(fActivePage);

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

      Handled := True;

      Exit;

    end;

    if (lCursor.CursorType = cctDouble) and (Abs(X - lPixelX2) <= 5) then

    begin

      fDragState := dcsX2;

      fStartX := X;

      fStartY := Y;

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

  I: Integer;

  lPixelX1, lPixelX2: Single;

  lLabelY1, lLabelY2: Single;

  lLabelRect1, lLabelRect2: TChartPixelRect;

  lHoverLine, lHoverLabel: Boolean;

  lMouseWorldX, lMouseWorldY: Double;

  lMouseWorldXPlus5: Double;

  lDeltaXWorld: Double;

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

      lCursor := GetOrCreatePageCursor(fActivePage);

      lContentRect := lRenderer.GetPageContentRect(fActivePage);

      if fDragState in [dcsX1, dcsX2] then

      begin

        lMouseWorldX := lRenderer.PixelToXValue(fActivePage, nil, X, lContentRect.Left, lContentRect.Right);

        

        if ssShift in Shift then

        begin

          // Вычисляем радиус примагничивания 10 пикселей

          lMouseWorldXPlus5 := lRenderer.PixelToXValue(fActivePage, nil, X + 10, lContentRect.Left, lContentRect.Right);

          lDeltaXWorld := Abs(lMouseWorldXPlus5 - lMouseWorldX);

          lMouseWorldY := lRenderer.PixelToAxisValue(nil, Y, lContentRect.Bottom, lContentRect.Top);

          

          // Определяем активный объект по правилам приоритета

          lTrend := nil;

          if Assigned(lRenderer.SelectedObject) then

          begin

            if lRenderer.SelectedObject is cBaseTrend then

              lTrend := cBaseTrend(lRenderer.SelectedObject)

            else if lRenderer.SelectedObject is TChartAxis then

            begin

              for I := 0 to TChartAxis(lRenderer.SelectedObject).ChildCount - 1 do

                if TChartAxis(lRenderer.SelectedObject).Children[I] is cBaseTrend then

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

            if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartAxis) and (TChartAxis(lRenderer.SelectedObject).Parent = fActivePage) then

              lAxis := TChartAxis(lRenderer.SelectedObject)

            else

            begin

              for I := 0 to fActivePage.ChildCount - 1 do

                if fActivePage.Children[I] is TChartAxis then

                begin

                  lAxis := TChartAxis(fActivePage.Children[I]);

                  Break;

                end;

            end;

            

            if Assigned(lAxis) then

            begin

              for I := 0 to lAxis.ChildCount - 1 do

                if lAxis.Children[I] is cBaseTrend then

                begin

                  lTrend := cBaseTrend(lAxis.Children[I]);

                  Break;

                end;

            end;

          end;

          if Assigned(lTrend) then

          begin

            if ssCtrl in Shift then

              lSnappedX := GetSnappedX(lTrend, lMouseWorldX, lMouseWorldY, lDeltaXWorld, 'min')

            else

              lSnappedX := GetSnappedX(lTrend, lMouseWorldX, lMouseWorldY, lDeltaXWorld, 'max');

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

        if lContentRect.Top <> lContentRect.Bottom then

        begin

          lNewOffset := (Y - lContentRect.Bottom) / (lContentRect.Top - lContentRect.Bottom);

          if lNewOffset < 0.0 then lNewOffset := 0.0;

          if lNewOffset > 1.0 then lNewOffset := 1.0;

          

          if fDragState = dcsLabel1 then

            lCursor.LabelY1Offset := lNewOffset

          else

            lCursor.LabelY2Offset := lNewOffset;

        end;

      end;

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

              lControl.Redraw;

              Key := 0;

              Handled := True;

            end;

          end

          else

          begin

            lCursor.X1 := lMouseWorldX;

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

