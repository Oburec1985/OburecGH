import os

RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"
LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("1. Updating uOglChartRenderer.pas (PageContentRect, DrawAxes, Highlights thickness)...")

with open(RENDERER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1.1 Update PageContentRect
target_content_rect = """function TOpenGLChartRenderer.PageContentRect(APage: TChartPage): TChartPixelRect;
begin
  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left;
  Result.Top := fPageRect.Top + APage.PixelTabSpace.Top;
  Result.Right := fPageRect.Right - APage.PixelTabSpace.Right;
  Result.Bottom := fPageRect.Bottom - APage.PixelTabSpace.Bottom;

  if Result.Right < Result.Left + 20 then
    Result.Right := Result.Left + 20;
  if Result.Bottom < Result.Top + 20 then
    Result.Bottom := Result.Top + 20;
end;"""

replacement_content_rect = """function TOpenGLChartRenderer.PageContentRect(APage: TChartPage): TChartPixelRect;
var
  lTotalOffset: Single;
  lYTicks: TChartTickArray;
  lAxisFont: cOglFont;
  lYAxis: TChartAxis;
  lText: string;
  lMaxTextWidth, lTextWidth: Single;
  I, J, lYAxisIdx: Integer;
begin
  lTotalOffset := 0;
  lYAxisIdx := 0;
  if Assigned(APage) then
  begin
    for I := 0 to APage.ChildCount - 1 do
      if APage.Children[I] is TChartAxis then
      begin
        lYAxis := TChartAxis(APage.Children[I]);
        if lYAxisIdx > 0 then
        begin
          BuildAxisTicks(lYAxis, 8, lYTicks);
          if lYAxis = fSelectedObject then
            lAxisFont := fFontMng.Font(cfAxisSelected)
          else
            lAxisFont := fFontMng.Font(cfAxisLabel);

          lMaxTextWidth := 0;
          for J := 0 to High(lYTicks) do
          begin
            lText := lYTicks[J].Text;
            lTextWidth := lAxisFont.TextPixelWidth(lText);
            if lTextWidth > lMaxTextWidth then
              lMaxTextWidth := lTextWidth;
          end;
          lTotalOffset := lTotalOffset + lMaxTextWidth + 15;
        end;
        Inc(lYAxisIdx);
      end;
  end;

  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left + lTotalOffset;
  Result.Top := fPageRect.Top + APage.PixelTabSpace.Top;
  Result.Right := fPageRect.Right - APage.PixelTabSpace.Right;
  Result.Bottom := fPageRect.Bottom - APage.PixelTabSpace.Bottom;

  if Result.Right < Result.Left + 20 then
    Result.Right := Result.Left + 20;
  if Result.Bottom < Result.Top + 20 then
    Result.Bottom := Result.Top + 20;
end;"""

content_lf = content_lf.replace(target_content_rect, replacement_content_rect)

# 1.2 Update DrawAxes Y axes section
target_draw_y_axes = """  // Draw all Y axes
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);

      SetGLColor($FF404040);
      glLineWidth(1);
      for lIndex := 0 to High(lYTicks) do
      begin
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        DrawLine(ARect.Left - CTick, lY, ARect.Left, lY);
      end;

      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
          lFont.TextPixelHeight / 2;
        if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
          DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMin)
        else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
          DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMax)
        else
          DrawText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont);
      end;
    end;"""

replacement_draw_y_axes = """  // Draw all Y axes
  lAxisOffset := 0;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);

      if lYAxis = fSelectedObject then
        lFont := fFontMng.Font(cfAxisSelected)
      else
        lFont := fFontMng.Font(cfAxisLabel);

      lX := ARect.Left - lAxisOffset;

      // Устанавливаем цвет оси по ее свойству Color
      SetGLColor(lYAxis.Color);
      glLineWidth(1.5);
      // Отрисовываем вертикальную линию для каждой оси Y отдельно!
      DrawLine(lX, ARect.Top, lX, ARect.Bottom);

      // Отрисовываем тики для каждой оси
      for lIndex := 0 to High(lYTicks) do
      begin
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        DrawLine(lX - CTick, lY, lX, lY);
      end;

      // Отрисовываем текстовые метки осей
      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
          lFont.TextPixelHeight / 2;
        if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
          DrawEditableText(lText, lX - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMin)
        else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
          DrawEditableText(lText, lX - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMax)
        else
          DrawText(lText, lX - lFont.TextPixelWidth(lText) - 7, lY, lFont);
      end;

      // Вычисляем ширину для следующей оси Y
      lMaxTextWidth := 0.0;
      for lIndex := 0 to High(lYTicks) do
      begin
        lTextWidth := lFont.TextPixelWidth(lYTicks[lIndex].Text);
        if lTextWidth > lMaxTextWidth then
          lMaxTextWidth := lTextWidth;
      end;
      lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
    end;"""

content_lf = content_lf.replace(target_draw_y_axes, replacement_draw_y_axes)

# Add local variables to DrawAxes
target_drawaxes_vars = """procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
const
  CTick = 5;
var
  lIndex: Integer;
  I: Integer;
  lX: Single;
  lY: Single;
  lPrimaryAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
begin"""

replacement_drawaxes_vars = """procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
const
  CTick = 5;
var
  lIndex: Integer;
  I: Integer;
  lX: Single;
  lY: Single;
  lPrimaryAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
  lAxisOffset: Single;
  lMaxTextWidth, lTextWidth: Single;
begin"""

content_lf = content_lf.replace(target_drawaxes_vars, replacement_drawaxes_vars)

# 1.3 Thinner borders in DrawHighlightRect and DrawHighlights
content_lf = content_lf.replace(
    "  glLineWidth(2);\n  DrawRect(ARect);",
    "  glLineWidth(1.2);\n  DrawRect(ARect);"
)
content_lf = content_lf.replace(
    "          SetGLColor($FFFF3300);\n          glLineWidth(3);\n          DrawRect(fTextHits[lIndex].Rect);",
    "          SetGLColor($FFFF3300);\n          glLineWidth(1.5);\n          DrawRect(fTextHits[lIndex].Rect);"
)

with open(RENDERER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))


print("2. Updating uOglChartFrameListener.pas (Nested Trend vertices selection & drag-and-drop)...")

with open(LISTENER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 2.1 Update SelectListener MouseDown Trend vertex hit test
target_select_hit = """    // 1.8. Проверяем попадание в вершины тренда (cTrend)
    lModel := TChartModel(lControl.GetModel);
    if Assigned(lModel) then
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
              
              lYAxis := nil;
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  Break;
                end;

              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is cTrend then
                begin
                  lTrend := cTrend(lPage.Children[I]);
                  if lTrend.ShowPoints then
                  begin
                    if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then
                      lYAxis := TChartAxis(lTrend.Parent);

                    if Assigned(lYAxis) then
                    begin
                      for J := 0 to lTrend.BeziePointCount - 1 do
                      begin
                        lPoint := lTrend.BeziePoints[J].Point;
                        lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                        lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                        if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                        begin
                          for K := 0 to lPage.ChildCount - 1 do
                            if lPage.Children[K] is cTrend then
                            begin
                              lTempTrend := cTrend(lPage.Children[K]);
                              for lIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                lTempTrend.BeziePoints[lIdx].Selected := False;
                            end;
                          lTrend.BeziePoints[J].Selected := True;
                          lRenderer.SelectedObject := lTrend;
                          lControl.Redraw;
                          Handled := True;
                          Exit;
                        end;
                      end;
                    end;
                  end;
                end;
            end;
          end;
        end;
    end;"""

replacement_select_hit = """    // 1.8. Проверяем попадание в вершины тренда (cTrend)
    lModel := TChartModel(lControl.GetModel);
    if Assigned(lModel) then
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
              
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  for J := 0 to lYAxis.ChildCount - 1 do
                    if lYAxis.Children[J] is cTrend then
                    begin
                      lTrend := cTrend(lYAxis.Children[J]);
                      if lTrend.ShowPoints then
                      begin
                        for K := 0 to lTrend.BeziePointCount - 1 do
                        begin
                          lPoint := lTrend.BeziePoints[K].Point;
                          lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                          lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            // Снимаем выделение со всех вершин всех трендов страницы
                            for lIdx := 0 to lPage.ChildCount - 1 do
                              if lPage.Children[lIdx] is TChartAxis then
                              begin
                                lTempAxis := TChartAxis(lPage.Children[lIdx]);
                                for lInnerIdx := 0 to lTempAxis.ChildCount - 1 do
                                  if lTempAxis.Children[lInnerIdx] is cTrend then
                                  begin
                                    lTempTrend := cTrend(lTempAxis.Children[lInnerIdx]);
                                    for lPointIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                      lTempTrend.BeziePoints[lPointIdx].Selected := False;
                                  end;
                              end;
                            lTrend.BeziePoints[K].Selected := True;
                            lRenderer.SelectedObject := lTrend;
                            lControl.Redraw;
                            Handled := True;
                            Exit;
                          end;
                        end;
                      end;
                    end;
                end;
            end;
          end;
        end;
    end;"""

content_lf = content_lf.replace(target_select_hit, replacement_select_hit)

# Add local variables to SelectListener MouseDown
target_select_vars = """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lSelectedAxis: TChartAxis;
  lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  I, J, K, lIdx: Integer;
begin"""

replacement_select_vars = """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lSelectedAxis: TChartAxis;
  lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  I, J, K, lIdx: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin"""

content_lf = content_lf.replace(target_select_vars, replacement_select_vars)


# 2.2 Update PanZoomListener MouseDown Trend vertex hit test
target_panzoom_hit = """      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
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
              lInnerIndex := 0;
              while lInnerIndex < lPage.ChildCount do
              begin
                if lPage.Children[lInnerIndex] is TChartAxis then
                  Break;
                Inc(lInnerIndex);
              end;
              
              if lInnerIndex < lPage.ChildCount then
                lYAxis := TChartAxis(lPage.Children[lInnerIndex])
              else
                lYAxis := nil;

              for lInnerIndex := 0 to lPage.ChildCount - 1 do
                if lPage.Children[lInnerIndex] is cTrend then
                begin
                  lTrend := cTrend(lPage.Children[lInnerIndex]);
                  if lTrend.ShowPoints then
                  begin
                    if Assigned(lTrend.Parent) and (lTrend.Parent is TChartAxis) then
                      lYAxis := TChartAxis(lTrend.Parent);

                    if Assigned(lYAxis) then
                    begin
                      for J := 0 to lTrend.BeziePointCount - 1 do
                      begin
                        lPoint := lTrend.BeziePoints[J].Point;
                        lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                        lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                        if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                        begin
                          fIsDraggingPoint := True;
                          fDragTrend := lTrend;
                          fDragPointIdx := J;
                          fActivePage := lPage;

                          for K := 0 to lPage.ChildCount - 1 do
                            if lPage.Children[K] is cTrend then
                            begin
                              lTempTrend := cTrend(lPage.Children[K]);
                              for lIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                lTempTrend.BeziePoints[lIdx].Selected := False;
                            end;
                          lTrend.BeziePoints[J].Selected := True;
                          lRenderer.SelectedObject := lTrend;
                          lControl.Redraw;
                          Handled := True;
                          Exit;
                        end;
                      end;
                    end;
                  end;
                end;
            end;
          end;
        end;"""

replacement_panzoom_hit = """      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
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
              
              for I := 0 to lPage.ChildCount - 1 do
                if lPage.Children[I] is TChartAxis then
                begin
                  lYAxis := TChartAxis(lPage.Children[I]);
                  for J := 0 to lYAxis.ChildCount - 1 do
                    if lYAxis.Children[J] is cTrend then
                    begin
                      lTrend := cTrend(lYAxis.Children[J]);
                      if lTrend.ShowPoints then
                      begin
                        for K := 0 to lTrend.BeziePointCount - 1 do
                        begin
                          lPoint := lTrend.BeziePoints[K].Point;
                          lX := lRenderer.XValueToPixel(lPage, lYAxis, lPoint.X, lContentRect.Left, lContentRect.Right);
                          lY := lRenderer.AxisValueToPixel(lYAxis, lPoint.Y, lContentRect.Bottom, lContentRect.Top);

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            fIsDraggingPoint := True;
                            fDragTrend := lTrend;
                            fDragPointIdx := K;
                            fActivePage := lPage;

                            // Снимаем выделение со всех вершин всех трендов страницы
                            for lIdx := 0 to lPage.ChildCount - 1 do
                              if lPage.Children[lIdx] is TChartAxis then
                              begin
                                lTempAxis := TChartAxis(lPage.Children[lIdx]);
                                for lInnerIdx := 0 to lTempAxis.ChildCount - 1 do
                                  if lTempAxis.Children[lInnerIdx] is cTrend then
                                  begin
                                    lTempTrend := cTrend(lTempAxis.Children[lInnerIdx]);
                                    for lPointIdx := 0 to lTempTrend.BeziePointCount - 1 do
                                      lTempTrend.BeziePoints[lPointIdx].Selected := False;
                                  end;
                              end;
                            lTrend.BeziePoints[K].Selected := True;
                            lRenderer.SelectedObject := lTrend;
                            lControl.Redraw;
                            Handled := True;
                            Exit;
                          end;
                        end;
                      end;
                    end;
                end;
            end;
          end;
        end;"""

content_lf = content_lf.replace(target_panzoom_hit, replacement_panzoom_hit)

# Add local variables to PanZoomListener MouseDown
target_panzoom_vars = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lContentRect: TChartPixelRect;
  lInnerIndex: Integer;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  J, K, lIdx: Integer;
begin"""

replacement_panzoom_vars = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  J, K, lIdx, I: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin"""

content_lf = content_lf.replace(target_panzoom_vars, replacement_panzoom_vars)

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
