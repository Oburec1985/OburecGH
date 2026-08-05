import os

LISTENER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartFrameListener.pas"
RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print("Starting interpolation type and movement updates...")

# 1. Update uOglChartFrameListener.pas
with open(LISTENER_PATH, 'rb') as f:
    raw_l = f.read()
content_l = raw_l.decode('cp1251')
content_l_lf = content_l.replace('\r\n', '\n').replace('\r', '\n')

# 1.1 Declaring KeyPress in TChartSelectListener interface
target_select_decl = """  TChartSelectListener = class(TChartFrameListener)
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
  end;"""

replacement_select_decl = """  TChartSelectListener = class(TChartFrameListener)
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); override;
  end;"""

if target_select_decl in content_l_lf:
    content_l_lf = content_l_lf.replace(target_select_decl, replacement_select_decl)
    print("Declared KeyPress in TChartSelectListener.")
else:
    print("Warning: target_select_decl not found!")

# 1.2 Removing incorrect reset from TChartPanZoomListener.MouseMove
target_panzoom_reset = """begin
  if not Enabled then Exit;

  if fIsDraggingPoint then
  begin
    fIsDraggingPoint := False;
    fDragTrend := nil;
    fDragPointIdx := -1;
    Handled := True;
    Exit;
  end;

  if Supports(ASender, IChartControl, lControl) then"""

replacement_panzoom_reset = """begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then"""

if target_panzoom_reset in content_l_lf:
    content_l_lf = content_l_lf.replace(target_panzoom_reset, replacement_panzoom_reset)
    print("Removed incorrect fIsDraggingPoint reset in MouseMove.")
else:
    print("Warning: target_panzoom_reset not found!")

# 1.3 Appending KeyPress implementation after MouseDown in uOglChartFrameListener.pas
target_mouseup_sep = """      lControl.Redraw;
    end;
  end;
end;

procedure TChartSelectListener.MouseMove("""

replacement_mouseup_sep = """      lControl.Redraw;
    end;
  end;
end;

procedure TChartSelectListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
var
  lControl: IChartControl;
  lRenderer: TOpenGLChartRenderer;
  lTrend: cTrend;
  I: Integer;
begin
  if not Enabled then Exit;

  if (Key in ['1', '2', '3', 't', 'T']) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is cTrend) then
    begin
      lTrend := cTrend(lRenderer.SelectedObject);
      for I := 0 to lTrend.BeziePointCount - 1 do
      begin
        if lTrend.BeziePoints[I].Selected then
        begin
          case Key of
            '1': lTrend.BeziePoints[I].PointType := bptCorner;
            '2': lTrend.BeziePoints[I].PointType := bptSmooth;
            '3': lTrend.BeziePoints[I].PointType := bptNull;
            't', 'T': 
              begin
                case lTrend.BeziePoints[I].PointType of
                  bptCorner: lTrend.BeziePoints[I].PointType := bptSmooth;
                  bptSmooth: lTrend.BeziePoints[I].PointType := bptNull;
                  bptNull: lTrend.BeziePoints[I].PointType := bptCorner;
                end;
              end;
          end;
          lTrend.GenerateSplinePoints;
          lControl.Redraw;
          Handled := True;
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TChartSelectListener.MouseMove("""

if target_mouseup_sep in content_l_lf:
    content_l_lf = content_l_lf.replace(target_mouseup_sep, replacement_mouseup_sep)
    print("Added KeyPress implementation for TChartSelectListener.")
else:
    print("Warning: target_mouseup_sep not found!")

# Save uOglChartFrameListener.pas
with open(LISTENER_PATH, 'wb') as f:
    f.write(content_l_lf.replace('\n', '\r\n').encode('cp1251'))


# 2. Update uOglChartRenderer.pas (DrawTrendPoints)
with open(RENDERER_PATH, 'rb') as f:
    raw_r = f.read()
content_r = raw_r.decode('cp1251')
content_r_lf = content_r.replace('\r\n', '\n').replace('\r', '\n')

target_draw_points = """procedure TOpenGLChartRenderer.DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX: Single;
  lY: Single;
begin
  if not Assigned(ATrend) or (ATrend.BeziePointCount <= 0) or not Assigned(AYAxis) or not ATrend.ShowPoints then
    Exit;

  for lIndex := 0 to ATrend.BeziePointCount - 1 do
  begin
    lPoint := ATrend.BeziePoints[lIndex].Point;
    lX := XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);

    // Fill color: Red if selected, Blue otherwise
    if ATrend.BeziePoints[lIndex].Selected then
      SetGLColor($FFFF3C3C)
    else
      SetGLColor($FF3C7DFF);

    glBegin(GL_QUADS);
    glVertex2f(lX - 4, lY - 4);
    glVertex2f(lX + 4, lY - 4);
    glVertex2f(lX + 4, lY + 4);
    glVertex2f(lX - 4, lY + 4);
    glEnd;

    // Black border outline
    SetGLColor($FF000000);
    glLineWidth(1.0);
    glBegin(GL_LINE_LOOP);
    glVertex2f(lX - 4, lY - 4);
    glVertex2f(lX + 4, lY - 4);
    glVertex2f(lX + 4, lY + 4);
    glVertex2f(lX - 4, lY + 4);
    glEnd;
  end;
end;"""

replacement_draw_points = """procedure TOpenGLChartRenderer.DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX: Single;
  lY: Single;
  lType: TBeziePointType;
begin
  if not Assigned(ATrend) or (ATrend.BeziePointCount <= 0) or not Assigned(AYAxis) or not ATrend.ShowPoints then
    Exit;

  for lIndex := 0 to ATrend.BeziePointCount - 1 do
  begin
    lPoint := ATrend.BeziePoints[lIndex].Point;
    lX := XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
    lType := ATrend.BeziePoints[lIndex].PointType;

    // Fill color: Red if selected, Blue otherwise
    if ATrend.BeziePoints[lIndex].Selected then
      SetGLColor($FFFF3C3C)
    else
      SetGLColor($FF3C7DFF);

    case lType of
      bptCorner: // Square
        begin
          glBegin(GL_QUADS);
          glVertex2f(lX - 4, lY - 4);
          glVertex2f(lX + 4, lY - 4);
          glVertex2f(lX + 4, lY + 4);
          glVertex2f(lX - 4, lY + 4);
          glEnd;
        end;
      bptSmooth: // Diamond
        begin
          glBegin(GL_QUADS);
          glVertex2f(lX, lY - 5);
          glVertex2f(lX + 5, lY);
          glVertex2f(lX, lY + 5);
          glVertex2f(lX - 5, lY);
          glEnd;
        end;
      bptNull: // Triangle
        begin
          glBegin(GL_TRIANGLES);
          glVertex2f(lX - 5, lY + 4);
          glVertex2f(lX + 5, lY + 4);
          glVertex2f(lX, lY - 5);
          glEnd;
        end;
    end;

    // Black border outline
    SetGLColor($FF000000);
    glLineWidth(1.0);
    case lType of
      bptCorner:
        begin
          glBegin(GL_LINE_LOOP);
          glVertex2f(lX - 4, lY - 4);
          glVertex2f(lX + 4, lY - 4);
          glVertex2f(lX + 4, lY + 4);
          glVertex2f(lX - 4, lY + 4);
          glEnd;
        end;
      bptSmooth:
        begin
          glBegin(GL_LINE_LOOP);
          glVertex2f(lX, lY - 5);
          glVertex2f(lX + 5, lY);
          glVertex2f(lX, lY + 5);
          glVertex2f(lX - 5, lY);
          glEnd;
        end;
      bptNull:
        begin
          glBegin(GL_LINE_LOOP);
          glVertex2f(lX - 5, lY + 4);
          glVertex2f(lX + 5, lY + 4);
          glVertex2f(lX, lY - 5);
          glEnd;
        end;
    end;
  end;
end;"""

if target_draw_points in content_r_lf:
    content_r_lf = content_r_lf.replace(target_draw_points, replacement_draw_points)
    print("Updated DrawTrendPoints with shape rendering based on interpolation type.")
else:
    print("Warning: target_draw_points not found!")

# Save uOglChartRenderer.pas
with open(RENDERER_PATH, 'wb') as f:
    f.write(content_r_lf.replace('\n', '\r\n').encode('cp1251'))

print("All updates applied successfully.")
