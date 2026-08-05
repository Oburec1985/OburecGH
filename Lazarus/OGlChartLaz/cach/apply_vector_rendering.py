import os

RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print("Updating DrawTrendPoints with tangent vector rendering...")

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

replacement_draw_points = """procedure TOpenGLChartRenderer.DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX, lY: Single;
  lXLeft, lYLeft, lXRight, lYRight: Single;
  lType: TBeziePointType;
  bp: cBeziePoint;
begin
  if not Assigned(ATrend) or (ATrend.BeziePointCount <= 0) or not Assigned(AYAxis) or not ATrend.ShowPoints then
    Exit;

  for lIndex := 0 to ATrend.BeziePointCount - 1 do
  begin
    bp := ATrend.BeziePoints[lIndex];
    lPoint := bp.Point;
    lX := XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
    lType := bp.PointType;

    // Draw tangent lines and control points if smooth and selected
    if (lType = bptSmooth) and bp.Selected then
    begin
      lXLeft := XValueToPixel(APage, AYAxis, bp.Left.X, ARect.Left, ARect.Right);
      lYLeft := AxisValueToPixel(AYAxis, bp.Left.Y, ARect.Bottom, ARect.Top);
      lXRight := XValueToPixel(APage, AYAxis, bp.Right.X, ARect.Left, ARect.Right);
      lYRight := AxisValueToPixel(AYAxis, bp.Right.Y, ARect.Bottom, ARect.Top);

      // Tangent vector lines
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
      glEnd;
    end;

    // Fill color: Red if selected, Blue otherwise
    if bp.Selected then
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
    print("Successfully replaced DrawTrendPoints in renderer.")
else:
    print("Warning: target_draw_points not found!")

with open(RENDERER_PATH, 'wb') as f:
    f.write(content_r_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
