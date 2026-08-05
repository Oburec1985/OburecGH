import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"

print(f"Modifying {os.path.basename(FILE_PATH)}...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Update TChartPanZoomListener fields to include dragging states
target_fields = """  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;
    fLastX: Integer;
    fLastY: Integer;
    fActivePage: TChartPage;
    fResizingBorder: Integer;
    fMovingPage: Boolean;
    fIsResizing: Boolean;
    fSnapSensitivity: Integer;
    fIsZoomSelecting: Boolean;
    fZoomStartX: Integer;
    fZoomStartY: Integer;"""

replacement_fields = """  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;
    fLastX: Integer;
    fLastY: Integer;
    fActivePage: TChartPage;
    fResizingBorder: Integer;
    fMovingPage: Boolean;
    fIsResizing: Boolean;
    fSnapSensitivity: Integer;
    fIsZoomSelecting: Boolean;
    fZoomStartX: Integer;
    fZoomStartY: Integer;
    fDragTrend: cTrend;
    fDragPointIdx: Integer;
    fIsDraggingPoint: Boolean;"""

if target_fields in content_lf:
    content_lf = content_lf.replace(target_fields, replacement_fields)
    print("PanZoomListener fields updated successfully.")
else:
    print("Warning: target_fields not found!")

# 2. Update TChartSelectListener.MouseDown
target_select_mousedown = """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. Проверяем попадание в текстовые метки (оси, значения)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled, чтобы сработал стандартный текстовый редактор рендера!
      Exit;
    end;"""

replacement_select_mousedown = """procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. Проверяем попадание в текстовые метки (оси, значения)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled, чтобы сработал стандартный текстовый редактор рендера!
      Exit;
    end;

    // 1.5. Проверяем попадание в вертикальную ось Y
    if lRenderer.GetAxisHitAt(X, Y, lSelectedAxis) then
    begin
      lRenderer.SelectedObject := lSelectedAxis;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 1.8. Проверяем попадание в вершины тренда (cTrend)
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
                    if Assigned(lTrend.YAxis) then
                      lYAxis := lTrend.YAxis;

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

if target_select_mousedown in content_lf:
    content_lf = content_lf.replace(target_select_mousedown, replacement_select_mousedown)
    print("TChartSelectListener.MouseDown updated successfully.")
else:
    print("Warning: target_select_mousedown not found!")

# 3. Update TChartPanZoomListener.Create
target_panzoom_create = """constructor TChartPanZoomListener.Create;
begin
  inherited Create;
  fIsPanning := False;
  fActivePage := nil;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fSnapSensitivity := 5;
  fIsZoomSelecting := False;
  fZoomStartX := 0;
  fZoomStartY := 0;
end;"""

replacement_panzoom_create = """constructor TChartPanZoomListener.Create;
begin
  inherited Create;
  fIsPanning := False;
  fActivePage := nil;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fSnapSensitivity := 5;
  fIsZoomSelecting := False;
  fZoomStartX := 0;
  fZoomStartY := 0;
  fIsDraggingPoint := False;
  fDragTrend := nil;
  fDragPointIdx := -1;
end;"""

if target_panzoom_create in content_lf:
    content_lf = content_lf.replace(target_panzoom_create, replacement_panzoom_create)
    print("TChartPanZoomListener.Create updated successfully.")
else:
    print("Warning: target_panzoom_create not found!")

# 4. Update TChartPanZoomListener.MouseDown (check for vertex hit)
target_panzoom_mousedown = """    if Button = mbLeft then
    begin
      // 1. Изменение размеров выделенной страницы"""

replacement_panzoom_mousedown = """    if Button = mbLeft then
    begin
      // 0.5. Проверяем попадание в вершины тренда для перетаскивания (mbLeft)
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
                    if Assigned(lTrend.YAxis) then
                      lYAxis := lTrend.YAxis;

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
        end;

      // 1. Изменение размеров выделенной страницы"""

# We need some helper variables in panzoom mousedown local variables:
# Actually it already has lRenderer, lControl, lModel, lPage, lPageRect, lContentRect, lIndex, lInnerIndex.
# We need to inject variables for our check: lYAxis: TChartAxis; lTrend, lTempTrend: cTrend; lPoint: TChartPoint; lX, lY: Single; J, K, lIdx: Integer;
# Let's inspect TOpenGLChartRenderer.MouseDown var section in uOglChartFrameListener.pas around TChartPanZoomListener.MouseDown.

# Let's find TChartPanZoomListener.MouseDown local variables block
target_panzoom_var = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
begin"""

replacement_panzoom_var = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
  lYAxis: TChartAxis;
  lTrend, lTempTrend: cTrend;
  lPoint: TChartPoint;
  lX, lY: Single;
  J, K, lIdx: Integer;
begin"""

if target_panzoom_var in content_lf:
    content_lf = content_lf.replace(target_panzoom_var, replacement_panzoom_var)
    print("TChartPanZoomListener.MouseDown variables updated successfully.")
else:
    print("Warning: target_panzoom_var not found!")

if target_panzoom_mousedown in content_lf:
    content_lf = content_lf.replace(target_panzoom_mousedown, replacement_panzoom_mousedown)
    print("TChartPanZoomListener.MouseDown logic updated successfully.")
else:
    print("Warning: target_panzoom_mousedown not found!")

# 5. Update TChartPanZoomListener.MouseMove (drag handling)
target_panzoom_mousemove = """    // 0. Состояние выделения области зумирования (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then"""

replacement_panzoom_mousemove = """    // 0.2. Состояние перетаскивания вершины тренда
    if fIsDraggingPoint and Assigned(fDragTrend) and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lAxis := fDragTrend.YAxis;
      if not Assigned(lAxis) then
      begin
        for lIndex := 0 to fActivePage.ChildCount - 1 do
          if fActivePage.Children[lIndex] is TChartAxis then
          begin
            lAxis := TChartAxis(fActivePage.Children[lIndex]);
            Break;
          end;
      end;

      if Assigned(lAxis) then
      begin
        lXRange := lRenderer.PixelToXValue(fActivePage, nil, X, lContentRect.Left, lContentRect.Right);
        lYRange := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);

        if lXRange < fActivePage.XMinValue then lXRange := fActivePage.XMinValue;
        if lXRange > fActivePage.XMaxValue then lXRange := fActivePage.XMaxValue;

        if lYRange < lAxis.MinValue then lYRange := lAxis.MinValue;
        if lYRange > lAxis.MaxValue then lYRange := lAxis.MaxValue;

        fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);
        lControl.Redraw;
        Handled := True;
        Exit;
      end;
    end;

    // 0. Состояние выделения области зумирования (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then"""

if target_panzoom_mousemove in content_lf:
    content_lf = content_lf.replace(target_panzoom_mousemove, replacement_panzoom_mousemove)
    print("TChartPanZoomListener.MouseMove logic updated successfully.")
else:
    print("Warning: target_panzoom_mousemove not found!")

# 6. Update TChartPanZoomListener.MouseUp (reset drag state)
target_panzoom_mouseup = """  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;"""

replacement_panzoom_mouseup = """  if fIsDraggingPoint then
  begin
    fIsDraggingPoint := False;
    fDragTrend := nil;
    fDragPointIdx := -1;
    Handled := True;
    Exit;
  end;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;"""

if target_panzoom_mouseup in content_lf:
    content_lf = content_lf.replace(target_panzoom_mouseup, replacement_panzoom_mouseup)
    print("TChartPanZoomListener.MouseUp logic updated successfully.")
else:
    print("Warning: target_panzoom_mouseup not found!")

# Save the updated file
content_crlf = content_lf.replace('\n', '\r\n')
with open(FILE_PATH, 'wb') as f:
    f.write(content_crlf.encode('cp1251'))

print("File saved successfully.")
