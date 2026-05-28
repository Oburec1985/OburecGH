import os

TREND_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartTrend.pas"
LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"
RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print("Starting tangent vector interactivity updates...")

# ----------------- 1. Update uOglChartTrend.pas -----------------
with open(TREND_PATH, 'rb') as f:
    raw_t = f.read()
content_t = raw_t.decode('cp1251')
content_t_lf = content_t.replace('\r\n', '\n').replace('\r', '\n')

# 1.1 Add declarations of UpdateBezieLeft/Right
decl_target = """    procedure GenerateSplinePoints;
    procedure UpdateBeziePoint(AIndex: Integer; AX, AY: Double);"""

decl_replacement = """    procedure GenerateSplinePoints;
    procedure UpdateBeziePoint(AIndex: Integer; AX, AY: Double);
    procedure UpdateBezieLeft(AIndex: Integer; AX, AY: Double);
    procedure UpdateBezieRight(AIndex: Integer; AX, AY: Double);"""

if decl_target in content_t_lf:
    content_t_lf = content_t_lf.replace(decl_target, decl_replacement)
    print("Added UpdateBezieLeft/Right declarations to cTrend.")
else:
    print("Warning: decl_target not found!")

# 1.2 Modify GenerateSplinePoints to preserve user manual adjustments
spline_target = """    if bp.PointType = bptSmooth then
    begin
      if I > 0 then
      begin
        lp := fBeziePoints[I - 1];
        bp.fLeft.X := bp.Point.X - (bp.Point.X - lp.Point.X) * 0.25;
        bp.fLeft.Y := bp.Point.Y - (bp.Point.Y - lp.Point.Y) * 0.25;
      end
      else
        bp.fLeft := bp.Point;

      if I < High(fBeziePoints) then
      begin
        rp := fBeziePoints[I + 1];
        bp.fRight.X := bp.Point.X + (rp.Point.X - bp.Point.X) * 0.25;
        bp.fRight.Y := bp.Point.Y + (rp.Point.Y - bp.Point.Y) * 0.25;
      end
      else
        bp.fRight := bp.Point;
    end"""

spline_replacement = """    if bp.PointType = bptSmooth then
    begin
      // Инициализируем left и right только если они равны point (т.е. не были перетащены вручную)
      if (bp.fLeft.X = bp.Point.X) and (bp.fLeft.Y = bp.Point.Y) then
      begin
        if I > 0 then
        begin
          lp := fBeziePoints[I - 1];
          bp.fLeft.X := bp.Point.X - (bp.Point.X - lp.Point.X) * 0.25;
          bp.fLeft.Y := bp.Point.Y - (bp.Point.Y - lp.Point.Y) * 0.25;
        end
        else
          bp.fLeft := bp.Point;
      end;

      if (bp.fRight.X = bp.Point.X) and (bp.fRight.Y = bp.Point.Y) then
      begin
        if I < High(fBeziePoints) then
        begin
          rp := fBeziePoints[I + 1];
          bp.fRight.X := bp.Point.X + (rp.Point.X - bp.Point.X) * 0.25;
          bp.fRight.Y := bp.Point.Y + (rp.Point.Y - bp.Point.Y) * 0.25;
        end
        else
          bp.fRight := bp.Point;
      end;
    end"""

if spline_target in content_t_lf:
    content_t_lf = content_t_lf.replace(spline_target, spline_replacement)
    print("Updated GenerateSplinePoints to preserve custom tangent vectors.")
else:
    print("Warning: spline_target not found!")

# 1.3 Update UpdateBeziePoint and add UpdateBezieLeft/Right
update_target = """procedure cTrend.UpdateBeziePoint(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fPoint.X := AX;
    fBeziePoints[AIndex].fPoint.Y := AY;
    GenerateSplinePoints;
  end;
end;"""

update_replacement = """procedure cTrend.UpdateBeziePoint(AIndex: Integer; AX, AY: Double);
var
  lDiffX, lDiffY: Double;
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    lDiffX := AX - fBeziePoints[AIndex].fPoint.X;
    lDiffY := AY - fBeziePoints[AIndex].fPoint.Y;

    fBeziePoints[AIndex].fPoint.X := AX;
    fBeziePoints[AIndex].fPoint.Y := AY;

    // Смещаем касательные усы вслед за центральной точкой
    fBeziePoints[AIndex].fLeft.X := fBeziePoints[AIndex].fLeft.X + lDiffX;
    fBeziePoints[AIndex].fLeft.Y := fBeziePoints[AIndex].fLeft.Y + lDiffY;
    fBeziePoints[AIndex].fRight.X := fBeziePoints[AIndex].fRight.X + lDiffX;
    fBeziePoints[AIndex].fRight.Y := fBeziePoints[AIndex].fRight.Y + lDiffY;

    GenerateSplinePoints;
  end;
end;

procedure cTrend.UpdateBezieLeft(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fLeft.X := AX;
    fBeziePoints[AIndex].fLeft.Y := AY;
    GenerateSplinePoints;
  end;
end;

procedure cTrend.UpdateBezieRight(AIndex: Integer; AX, AY: Double);
begin
  if (AIndex >= 0) and (AIndex < Length(fBeziePoints)) then
  begin
    fBeziePoints[AIndex].fRight.X := AX;
    fBeziePoints[AIndex].fRight.Y := AY;
    GenerateSplinePoints;
  end;
end;"""

if update_target in content_t_lf:
    content_t_lf = content_t_lf.replace(update_target, update_replacement)
    print("Replaced UpdateBeziePoint and added UpdateBezieLeft/Right implementations.")
else:
    print("Warning: update_target not found!")

# Save uOglChartTrend.pas
with open(TREND_PATH, 'wb') as f:
    f.write(content_t_lf.replace('\n', '\r\n').encode('cp1251'))


# ----------------- 2. Update uOglChartFrameListener.pas -----------------
with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

# 2.1 Add TChartDragPart type declaration and fDragPart field
decl_listener_target = """  { TChartPanZoomListener
    Слушатель для панорамирования (перетаскивания правой кнопкой мыши) и масштабирования (колесиком мыши). }
  TChartPanZoomListener = class(TChartFrameListener)
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

decl_listener_replacement = """  TChartDragPart = (cdpPoint, cdpLeft, cdpRight);

  { TChartPanZoomListener
    Слушатель для панорамирования (перетаскивания правой кнопкой мыши) и масштабирования (колесиком мыши). }
  TChartPanZoomListener = class(TChartFrameListener)
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
    fIsDraggingPoint: Boolean;
    fDragPart: TChartDragPart;"""

if decl_listener_target in content_l_lf:
    content_l_lf = content_l_lf.replace(decl_listener_target, decl_listener_replacement)
    print("Declared TChartDragPart and fDragPart field in uOglChartFrameListener.pas.")
else:
    print("Warning: decl_listener_target not found!")

# 2.2 Initialize fDragPart in TChartPanZoomListener.Create
init_target = """  fIsDraggingPoint := False;
  fDragTrend := nil;
  fDragPointIdx := -1;
end;"""

init_replacement = """  fIsDraggingPoint := False;
  fDragTrend := nil;
  fDragPointIdx := -1;
  fDragPart := cdpPoint;
end;"""

if init_target in content_l_lf:
    content_l_lf = content_l_lf.replace(init_target, init_replacement)
    print("Initialized fDragPart in TChartPanZoomListener.Create.")
else:
    print("Warning: init_target not found!")

# 2.3 Add local variables to MouseDown
vars_target = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
  J, K, lIdx, I: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin"""

vars_replacement = """procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
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
  lXLeft, lYLeft, lXRight, lYRight: Single;
  J, K, lIdx, I: Integer;
  lTempAxis: TChartAxis;
  lInnerIdx, lPointIdx: Integer;
begin"""

if vars_target in content_l_lf:
    content_l_lf = content_l_lf.replace(vars_target, vars_replacement)
    print("Added local variables lXLeft, lYLeft, lXRight, lYRight to TChartPanZoomListener.MouseDown.")
else:
    print("Warning: vars_target not found!")

# 2.4 Update hit-test logic in TChartPanZoomListener.MouseDown
hittest_target = """                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            fIsDraggingPoint := True;
                            fDragTrend := lTrend;
                            fDragPointIdx := K;
                            fActivePage := lPage;"""

hittest_replacement = """                          // Если вершина сглаженная и выделена, сначала проверяем её направляющие векторы (усы)
                          if (lTrend.BeziePoints[K].PointType = bptSmooth) and lTrend.BeziePoints[K].Selected then
                          begin
                            lXLeft := lRenderer.XValueToPixel(lPage, lYAxis, lTrend.BeziePoints[K].Left.X, lContentRect.Left, lContentRect.Right);
                            lYLeft := lRenderer.AxisValueToPixel(lYAxis, lTrend.BeziePoints[K].Left.Y, lContentRect.Bottom, lContentRect.Top);
                            lXRight := lRenderer.XValueToPixel(lPage, lYAxis, lTrend.BeziePoints[K].Right.X, lContentRect.Left, lContentRect.Right);
                            lYRight := lRenderer.AxisValueToPixel(lYAxis, lTrend.BeziePoints[K].Right.Y, lContentRect.Bottom, lContentRect.Top);

                            if (Abs(X - lXLeft) <= 6) and (Abs(Y - lYLeft) <= 6) then
                            begin
                              fIsDraggingPoint := True;
                              fDragTrend := lTrend;
                              fDragPointIdx := K;
                              fDragPart := cdpLeft;
                              fActivePage := lPage;
                              Handled := True;
                              Exit;
                            end;

                            if (Abs(X - lXRight) <= 6) and (Abs(Y - lYRight) <= 6) then
                            begin
                              fIsDraggingPoint := True;
                              fDragTrend := lTrend;
                              fDragPointIdx := K;
                              fDragPart := cdpRight;
                              fActivePage := lPage;
                              Handled := True;
                              Exit;
                            end;
                          end;

                          if (Abs(X - lX) <= 6) and (Abs(Y - lY) <= 6) then
                          begin
                            fIsDraggingPoint := True;
                            fDragTrend := lTrend;
                            fDragPointIdx := K;
                            fDragPart := cdpPoint;
                            fActivePage := lPage;"""

if hittest_target in content_l_lf:
    content_l_lf = content_l_lf.replace(hittest_target, hittest_replacement)
    print("Updated MouseDown hit-test to check tangent handles.")
else:
    print("Warning: hittest_target not found!")

# 2.5 Update Dragging logic in MouseMove
drag_target = """        fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);

        lControl.Redraw;"""

drag_replacement = """        case fDragPart of
          cdpPoint: fDragTrend.UpdateBeziePoint(fDragPointIdx, lXRange, lYRange);
          cdpLeft: fDragTrend.UpdateBezieLeft(fDragPointIdx, lXRange, lYRange);
          cdpRight: fDragTrend.UpdateBezieRight(fDragPointIdx, lXRange, lYRange);
        end;

        lControl.Redraw;"""

if drag_target in content_l_lf:
    content_l_lf = content_l_lf.replace(drag_target, drag_replacement)
    print("Updated MouseMove dragging switch based on fDragPart.")
else:
    print("Warning: drag_target not found!")

# Save uOglChartFrameListener.pas
with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))


# ----------------- 3. Update uOglChartRenderer.pas -----------------
with open(RENDERER_PATH, 'rb') as f:
    raw_r = f.read()
content_r = raw_r.decode('cp1251')
content_r_lf = content_r.replace('\r\n', '\n').replace('\r', '\n')

# 3.1 Draw tangent handle points as green squares of size 8x8 (radius 4)
vector_render_target = """      // Tangent vector lines
      SetGLColor($FF808080); // Gray vector color
      glLineWidth(1.0);
      glBegin(GL_LINES);
      glVertex2f(lX, lY);
      glVertex2f(lXLeft, lYLeft);
      glVertex2f(lX, lY);
      glVertex2f(lXRight, lYRight);
      glEnd;

      // Handle control points (little gray squares)
      SetGLColor($FF808080);
      glBegin(GL_QUADS);
      glVertex2f(lXLeft - 2.5, lYLeft - 2.5);
      glVertex2f(lXLeft + 2.5, lYLeft - 2.5);
      glVertex2f(lXLeft + 2.5, lYLeft + 2.5);
      glVertex2f(lXLeft - 2.5, lYLeft + 2.5);

      glVertex2f(lXRight - 2.5, lYRight - 2.5);
      glVertex2f(lXRight + 2.5, lYRight - 2.5);
      glVertex2f(lXRight + 2.5, lYRight + 2.5);
      glVertex2f(lXRight - 2.5, lYRight + 2.5);
      glEnd;"""

vector_render_replacement = """      // Tangent vector lines (gray lines)
      SetGLColor($FF808080); 
      glLineWidth(1.0);
      glBegin(GL_LINES);
      glVertex2f(lX, lY);
      glVertex2f(lXLeft, lYLeft);
      glVertex2f(lX, lY);
      glVertex2f(lXRight, lYRight);
      glEnd;

      // Handle control points: GREEN squares of size 8x8 (half-size 4.0) with black border
      SetGLColor($FF00D000); // Bright green
      glBegin(GL_QUADS);
      glVertex2f(lXLeft - 4, lYLeft - 4);
      glVertex2f(lXLeft + 4, lYLeft - 4);
      glVertex2f(lXLeft + 4, lYLeft + 4);
      glVertex2f(lXLeft - 4, lYLeft + 4);

      glVertex2f(lXRight - 4, lYRight - 4);
      glVertex2f(lXRight + 4, lYRight - 4);
      glVertex2f(lXRight + 4, lYRight + 4);
      glVertex2f(lXRight - 4, lYRight + 4);
      glEnd;

      // Black outline for green handles
      SetGLColor($FF000000);
      glLineWidth(1.0);
      glBegin(GL_LINE_LOOP);
      glVertex2f(lXLeft - 4, lYLeft - 4);
      glVertex2f(lXLeft + 4, lYLeft - 4);
      glVertex2f(lXLeft + 4, lYLeft + 4);
      glVertex2f(lXLeft - 4, lYLeft + 4);
      glEnd;
      glBegin(GL_LINE_LOOP);
      glVertex2f(lXRight - 4, lYRight - 4);
      glVertex2f(lXRight + 4, lYRight - 4);
      glVertex2f(lXRight + 4, lYRight + 4);
      glVertex2f(lXRight - 4, lYRight + 4);
      glEnd;"""

if vector_render_target in content_r_lf:
    content_r_lf = content_r_lf.replace(vector_render_target, vector_render_replacement)
    print("Updated vector points size and color in TOpenGLChartRenderer.")
else:
    print("Warning: vector_render_target not found!")

# Save uOglChartRenderer.pas
with open(RENDERER_PATH, 'wb') as f:
    f.write(content_r_lf.replace('\n', '\r\n').encode('cp1251'))

print("All updates applied.")
