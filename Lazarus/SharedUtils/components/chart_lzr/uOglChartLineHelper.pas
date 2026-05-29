unit uOglChartLineHelper;

{$mode objfpc}{$H+}
{$codepage cp1251}

interface

uses
  SysUtils, gl, glext, Math, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj, 
  uOglChartPage, uOglChartAxis, uOglChartTrend;

type
  /// <summary>
  /// Интерфейс обратного вызова для рендерера для преобразования значений в пиксели
  /// и настройки цвета без создания жесткой круговой зависимости между модулями.
  /// </summary>
  IChartOffsetHelper = interface
    ['{E8A375A2-2B3D-4A23-9D27-C8C1F4A579B1}']
    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
    procedure SetGLColor(AColor: Cardinal);
  end;

/// <summary>
/// Отрисовывает стандартную серию линий TChartLineSeries.
/// </summary>
procedure RenderLineSeries(
  ARenderer: TObject;
  ASeries: TChartLineSeries; 
  const ARect: TChartPixelRect;
  APage: TChartPage; 
  AYAxis: TChartAxis;
  AUseShader: Boolean;
  AShaderInitialized: Boolean;
  AShaderProgram: GLuint
);

/// <summary>
/// Отрисовывает одномерный буферизированный тренд cBuffTrend1d.
/// </summary>
procedure RenderBuffTrend1d(
  ARenderer: TObject;
  ATrend: cBuffTrend1d;
  const ARect: TChartPixelRect;
  APage: TChartPage;
  AYAxis: TChartAxis;
  AUseShader: Boolean;
  AShaderInitialized: Boolean;
  AShaderProgram: GLuint
);

/// <summary>
/// Отрисовывает опорные точки и касательные линии для сплайнов cTrend.
/// </summary>
procedure RenderTrendPoints(
  ARenderer: TObject;
  ATrend: cTrend;
  const ARect: TChartPixelRect;
  APage: TChartPage;
  AYAxis: TChartAxis
);

implementation

procedure RenderLineSeries( ARenderer: TObject;
                            ASeries: TChartLineSeries;
                            const ARect: TChartPixelRect;
                            APage: TChartPage;
                            AYAxis: TChartAxis;
                            AUseShader: Boolean;
                            AShaderInitialized: Boolean;
                            AShaderProgram: GLuint
                          );
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX: Single;
  lY: Single;
  lXMin, lXMax, lYMin, lYMax: Double;
  lMinMax: array[0..3] of GLfloat;
  lLg: array[0..1] of GLint;
  lMinMaxLoc, lLgLoc: GLint;
  lRendererObj: IChartOffsetHelper;
begin
  if not Assigned(ASeries) or (ASeries.PointCount <= 0) or not Assigned(AYAxis) or not Assigned(ARenderer) then
    Exit;

  if not Supports(ARenderer, IChartOffsetHelper, lRendererObj) then
    Exit;

  lRendererObj.SetGLColor(ASeries.Color);
  glLineWidth(2.3);

  if AUseShader and AShaderInitialized then
  begin
    if AYAxis.UseOwnX then
    begin
      lXMin := AYAxis.XMinValue;
      lXMax := AYAxis.XMaxValue;
    end
    else
    begin
      lXMin := APage.XMinValue;
      lXMax := APage.XMaxValue;
    end;
    lYMin := AYAxis.MinValue;
    lYMax := AYAxis.MaxValue;

    glUseProgram(AShaderProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    if AYAxis.UseOwnX then
    begin
      if AYAxis.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end
    else
    begin
      if APage.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end;
    if AYAxis.Scale = casLog10 then lLg[1] := 1 else lLg[1] := 0;
    
    lLgLoc := glGetUniformLocation(AShaderProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    if ASeries.PointCount > 2000 then
    begin
      if (ASeries.GLListID = 0) or (ASeries.GLListContextVersion <> gGLContextVersion) then
      begin
        ASeries.GLListID := glGenLists(1);
        glNewList(ASeries.GLListID, GL_COMPILE);
        glBegin(GL_LINE_STRIP);
        for lIndex := 0 to ASeries.PointCount - 1 do
        begin
          lPoint := ASeries.Points[lIndex];
          glVertex2f(lPoint.X, lPoint.Y);
        end;
        glEnd;
        glEndList;
        ASeries.GLListContextVersion := gGLContextVersion;
      end;
      glCallList(ASeries.GLListID);
    end
    else
    begin
      glBegin(GL_LINE_STRIP);
      for lIndex := 0 to ASeries.PointCount - 1 do
      begin
        lPoint := ASeries.Points[lIndex];
        glVertex2f(lPoint.X, lPoint.Y);
      end;
      glEnd;
    end;

    glPopMatrix;
    glUseProgram(0);
  end
  else
  begin
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ASeries.PointCount - 1 do
    begin
      lPoint := ASeries.Points[lIndex];
      lX := lRendererObj.XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
      lY := lRendererObj.AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
      glVertex2f(lX, lY);
    end;
    glEnd;
  end;
end;

procedure RenderBuffTrend1d(
  ARenderer: TObject;
  ATrend: cBuffTrend1d;
  const ARect: TChartPixelRect;
  APage: TChartPage;
  AYAxis: TChartAxis;
  AUseShader: Boolean;
  AShaderInitialized: Boolean;
  AShaderProgram: GLuint
);
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
  lXMin, lXMax, lYMin, lYMax: Double;
  lMinMax: array[0..3] of GLfloat;
  lLg: array[0..1] of GLint;
  lLinePar: array[0..1] of GLfloat;
  lMinMaxLoc, lLgLoc, lLineParLoc: GLint;
  lRendererObj: IChartOffsetHelper;
begin
  if not Assigned(ATrend) or (ATrend.Count <= 0) or not Assigned(AYAxis) or not Assigned(ARenderer) then
    Exit;

  if not Supports(ARenderer, IChartOffsetHelper, lRendererObj) then
    Exit;

  lRendererObj.SetGLColor(ATrend.Color);
  glLineWidth(2.3);

  if AUseShader and AShaderInitialized then
  begin
    if AYAxis.UseOwnX then
    begin
      lXMin := AYAxis.XMinValue;
      lXMax := AYAxis.XMaxValue;
    end
    else
    begin
      lXMin := APage.XMinValue;
      lXMax := APage.XMaxValue;
    end;
    lYMin := AYAxis.MinValue;
    lYMax := AYAxis.MaxValue;

    glUseProgram(AShaderProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    if AYAxis.UseOwnX then
    begin
      if AYAxis.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end
    else
    begin
      if APage.XScale = casLog10 then lLg[0] := 1 else lLg[0] := 0;
    end;
    if AYAxis.Scale = casLog10 then lLg[1] := 1 else lLg[1] := 0;
    
    lLgLoc := glGetUniformLocation(AShaderProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    lLinePar[0] := ATrend.X0;
    lLinePar[1] := ATrend.DX;
    lLineParLoc := glGetUniformLocation(AShaderProgram, 'a_LinePar');
    glUniform2fv(lLineParLoc, 1, @lLinePar[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    if ATrend.Count > 2000 then
    begin
      if (ATrend.GLListID = 0) or (ATrend.GLListContextVersion <> gGLContextVersion) then
      begin
        ATrend.GLListID := glGenLists(1);
        glNewList(ATrend.GLListID, GL_COMPILE);
        glBegin(GL_LINE_STRIP);
        for lIndex := 0 to ATrend.Count - 1 do
        begin
          glVertex2f(ATrend.Values[lIndex], 0);
        end;
        glEnd;
        glEndList;
        ATrend.GLListContextVersion := gGLContextVersion;
      end;
      glCallList(ATrend.GLListID);
    end
    else
    begin
      glBegin(GL_LINE_STRIP);
      for lIndex := 0 to ATrend.Count - 1 do
      begin
        glVertex2f(ATrend.Values[lIndex], 0);
      end;
      glEnd;
    end;

    glPopMatrix;
    glUseProgram(0);
  end
  else
  begin
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ATrend.Count - 1 do
    begin
      lX := lRendererObj.XValueToPixel(APage, AYAxis, ATrend.X0 + lIndex * ATrend.DX, ARect.Left, ARect.Right);
      lY := lRendererObj.AxisValueToPixel(AYAxis, ATrend.Values[lIndex], ARect.Bottom, ARect.Top);
      glVertex2f(lX, lY);
    end;
    glEnd;
  end;
end;

procedure RenderTrendPoints(
  ARenderer: TObject;
  ATrend: cTrend;
  const ARect: TChartPixelRect;
  APage: TChartPage;
  AYAxis: TChartAxis
);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX, lY: Single;
  lXLeft, lYLeft, lXRight, lYRight: Single;
  lType: TBeziePointType;
  bp: cBeziePoint;
  lRendererObj: IChartOffsetHelper;
begin
  if not Assigned(ATrend) or (ATrend.BeziePointCount <= 0) or not Assigned(AYAxis) or not ATrend.ShowPoints or not Assigned(ARenderer) then
    Exit;

  if not Supports(ARenderer, IChartOffsetHelper, lRendererObj) then
    Exit;

  for lIndex := 0 to ATrend.BeziePointCount - 1 do
  begin
    bp := ATrend.BeziePoints[lIndex];
    lPoint := bp.Point;
    lX := lRendererObj.XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
    lY := lRendererObj.AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
    lType := bp.PointType;

    // Отрисовка касательных линий и контрольных точек для сглаженных узлов Безье
    if (lType = bptSmooth) and bp.Selected then
    begin
      lXLeft := lRendererObj.XValueToPixel(APage, AYAxis, bp.Left.X, ARect.Left, ARect.Right);
      lYLeft := lRendererObj.AxisValueToPixel(AYAxis, bp.Left.Y, ARect.Bottom, ARect.Top);
      lXRight := lRendererObj.XValueToPixel(APage, AYAxis, bp.Right.X, ARect.Left, ARect.Right);
      lYRight := lRendererObj.AxisValueToPixel(AYAxis, bp.Right.Y, ARect.Bottom, ARect.Top);

      // Рисование касательных серых линий
      lRendererObj.SetGLColor($FF808080); 
      glLineWidth(1.0);
      glBegin(GL_LINES);
      glVertex2f(lX, lY);
      glVertex2f(lXLeft, lYLeft);
      glVertex2f(lX, lY);
      glVertex2f(lXRight, lYRight);
      glEnd;

      // Рисование контрольных точек (зеленые квадраты 8x8)
      lRendererObj.SetGLColor($FF00D000); // Ярко-зеленый
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

      // Черная обводка для зеленых контрольных точек
      lRendererObj.SetGLColor($FF000000);
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
      glEnd;
    end;

    // Цвет узлов: красный при выделении, синий по умолчанию
    if bp.Selected then
      lRendererObj.SetGLColor($FFFF3C3C)
    else
      lRendererObj.SetGLColor($FF3C7DFF);

    case lType of
      bptCorner: // Обычный узел (квадрат)
        begin
          glBegin(GL_QUADS);
          glVertex2f(lX - 4, lY - 4);
          glVertex2f(lX + 4, lY - 4);
          glVertex2f(lX + 4, lY + 4);
          glVertex2f(lX - 4, lY + 4);
          glEnd;
        end;
      bptSmooth: // Сглаженный узел (ромб)
        begin
          glBegin(GL_QUADS);
          glVertex2f(lX, lY - 5);
          glVertex2f(lX + 5, lY);
          glVertex2f(lX, lY + 5);
          glVertex2f(lX - 5, lY);
          glEnd;
        end;
      bptNull: // Пустой/разрывной узел (треугольник)
        begin
          glBegin(GL_TRIANGLES);
          glVertex2f(lX - 5, lY + 4);
          glVertex2f(lX + 5, lY + 4);
          glVertex2f(lX, lY - 5);
          glEnd;
        end;
    end;

    // Черный контур вокруг узлов
    lRendererObj.SetGLColor($FF000000);
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
end;

end.
