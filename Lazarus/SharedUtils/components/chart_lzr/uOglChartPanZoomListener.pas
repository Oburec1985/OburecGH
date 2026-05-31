unit uOglChartPanZoomListener;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartTrend, uOglChartRenderer, uOglChartChart,
  uOglChartTextLabel;

type
  /// <summary>
  /// Слушатель для реализации интерактивной навигации: масштабирование (Zoom) и панорамирование (Pan).
  /// Управляет перетаскиванием правой кнопкой мыши, масштабированием колесиком над страницами,
  /// и приближением по выделенной рамке с зажатой клавишей Ctrl.
  /// </summary>
  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;             // Флаг активного панорамирования графика (правая кнопка мыши).
    fLastX: Integer;                 // Последняя координата X мыши для расчета смещения (delta).
    fLastY: Integer;                 // Последняя координата Y мыши для расчета смещения.
    fActivePage: TChartPage;         // Ссылка на активную (интерактивную в данный момент) страницу чарта.
    fIsZoomSelecting: Boolean;       // Флаг активного выбора рамки зумирования (Ctrl + Drag).
    fZoomStartX: Integer;            // Начальная координата X рамки зумирования.
    fZoomStartY: Integer;            // Начальная координата Y рамки зумирования.
  public
    /// <summary>
    /// Конструктор по умолчанию.
    /// </summary>

    constructor Create; override;
    /// <summary>
    /// Запускает интерактивные режимы (панорамирование правой кнопкой или рамку зума с Ctrl).
    /// </summary>

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Выполняет смещение графиков или отрисовку рамки зума.
    /// </summary>

    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Завершает интерактивные режимы и применяет изменения (зумирование по рамке).
    /// </summary>

    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Выполняет зумирование графика колесиком мыши относительно текущего положения курсора.
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
  // 1. Если это линия тренда / ряд точек
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

  // 2. Если это буферизованный тренд 1D
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

  // 3. Если это метка или флаг
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

    // По X
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

    // По Y
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

  // Рекурсивно обходим детей
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
end;

procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);

var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
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
      // Если зажат Ctrl, то это режим зума по рамке (только внутри plot area)
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
                begin
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
    // 1. Состояние выделения области зумирования (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lSelRect.Left := Max(lContentRect.Left, Min(fZoomStartX, X));
      lSelRect.Right := Min(lContentRect.Right, Max(fZoomStartX, X));
      lSelRect.Top := Max(lContentRect.Top, Min(fZoomStartY, Y));
      lSelRect.Bottom := Min(lContentRect.Bottom, Max(fZoomStartY, Y));
      lRenderer.SelectionRectActive := True;
      lRenderer.SelectionRect := lSelRect;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 2. Состояние обычного панорамирования графика правой кнопкой мыши
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
      
      // Определяем выбранную ось (Y) для изоляции панорамирования
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
      // 1. Полный масштаб при движении влево и вверх
      if (X < fZoomStartX) and (Y < fZoomStartY) then
      begin
        FitPageZoom(fActivePage);
        lControl.Redraw;
        Handled := True;
      end

      // 2. Приближение при движении вправо и вниз
      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then
      begin
        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        lSelRect.Left := Max(lContentRect.Left, fZoomStartX);
        lSelRect.Right := Min(lContentRect.Right, X);
        lSelRect.Top := Max(lContentRect.Top, fZoomStartY);
        lSelRect.Bottom := Min(lContentRect.Bottom, Y);
        if (lSelRect.Right > lSelRect.Left) and (lSelRect.Bottom > lSelRect.Top) then
        begin
          // Зум по X
          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;
          // Определяем выбранную ось (Y) для изоляции рамки зума
          lSelectedAxis := nil;
          if Assigned(lRenderer.SelectedObject) then
          begin
            if lRenderer.SelectedObject is TChartAxis then
              lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
            else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
              lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
          end;

          // Зум по осям Y
          for lIndex := 0 to fActivePage.ChildCount - 1 do
            if fActivePage.Children[lIndex] is TChartAxis then
            begin
              lAxis := TChartAxis(fActivePage.Children[lIndex]);
              if (lSelectedAxis = nil) or (lAxis = lSelectedAxis) then
              begin
                if lAxis.UseOwnX then
                begin
                  NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                  NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                  lAxis.XMinValue := NewXMin;
                  lAxis.XMaxValue := NewXMax;
                end;

                NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
                NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
                lAxis.MinValue := NewYMin;
                lAxis.MaxValue := NewYMax;
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
    // Находим страницу под мышкой для масштабирования
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
      // Масштабирование по оси X относительно курсора мыши
      lMouseValX := lRenderer.PixelToXValue(lPage, nil, X, lContentRect.Left, lContentRect.Right);
      lPage.XMinValue := lMouseValX - (lMouseValX - lPage.XMinValue) * lZoomFactor;
      lPage.XMaxValue := lMouseValX + (lPage.XMaxValue - lMouseValX) * lZoomFactor;
      
      // Определяем выбранную ось (Y) для изоляции зума
      lSelectedAxis := nil;
      if Assigned(lRenderer.SelectedObject) then
      begin
        if lRenderer.SelectedObject is TChartAxis then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject)
        else if (lRenderer.SelectedObject is cBaseTrend) and Assigned(lRenderer.SelectedObject.Parent) and (lRenderer.SelectedObject.Parent is TChartAxis) then
          lSelectedAxis := TChartAxis(lRenderer.SelectedObject.Parent);
      end;

      // Масштабирование по осям Y относительно курсора мыши
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

