import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print("Replacing select and panzoom hit tests in uOglChartFrameListener.pas...")

with open(LISTENER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Target block for SelectListener MouseDown
target_select = """    // 1.8. Проверяем попадание в вершины тренда (cTrend)
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

replacement_select = """    // 1.8. Проверяем попадание в вершины тренда (cTrend)
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

if target_select in content_lf:
    content_lf = content_lf.replace(target_select, replacement_select)
    print("Select hit test updated.")
else:
    print("Warning: target_select not found!")


# 2. Target block for PanZoomListener MouseDown
target_panzoom = """      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
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

replacement_panzoom = """      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
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

if target_panzoom in content_lf:
    content_lf = content_lf.replace(target_panzoom, replacement_panzoom)
    print("PanZoom hit test updated.")
else:
    print("Warning: target_panzoom not found!")

with open(LISTENER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
