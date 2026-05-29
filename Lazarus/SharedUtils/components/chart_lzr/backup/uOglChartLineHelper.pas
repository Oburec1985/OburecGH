unit uOglChartLineHelper;

{$mode objfpc}{$H+}
{$codepage cp1251}

interface

uses
  gl, glext, Math, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj, 
  uOglChartPage, uOglChartAxis, uOglChartTrend;

/// <summary>
/// Рисует график TChartLineSeries с использованием OpenGL-контекста.
/// </summary>
/// <param name="ARenderer">Ссылка на объект рендерера (для вызова ValueToPixel / XValueToPixel при отключенных шейдерах)</param>
/// <param name="ASeries">Линейный график, содержащий точки и цвет для отрисовки</param>
/// <param name="ARect">Пиксельные границы области рисования на экране</param>
/// <param name="APage">Страница графика (для получения глобальных XMin/XMax)</param>
/// <param name="AYAxis">Ось Y, к которой привязан график</param>
/// <param name="AUseShader">Флаг использования шейдеров</param>
/// <param name="AShaderInitialized">Состояние готовности шейдера</param>
/// <param name="AShaderProgram">ID скомпилированной шейдерной программы в OpenGL</param>
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

implementation

// Объявляем тип-интерфейс рендерера для обхода циклической зависимости
type
  TOffsetHelper = class
  public
    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single; virtual; abstract;
    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single; virtual; abstract;
    procedure SetGLColor(AColor: Cardinal); virtual; abstract;
  end;

procedure RenderLineSeries(   ARenderer: TObject;
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
  lRendererObj: TOffsetHelper;
begin
  // Проверка входных данных на валидность
  if not Assigned(ASeries) or (ASeries.PointCount <= 0) or not Assigned(AYAxis) or not Assigned(ARenderer) then
    Exit;

  lRendererObj := TOffsetHelper(ARenderer);

  // Установка цвета графика и толщины линии
  lRendererObj.SetGLColor(ASeries.Color);
  glLineWidth(2.3);

  // Логический блок 1: Аппаратная отрисовка через OpenGL шейдеры
  if AUseShader and AShaderInitialized then
  begin
    // Определение диапазонов по осям X и Y
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

    // Активация шейдерной программы
    glUseProgram(AShaderProgram);

    // Передача униформ-переменных границ диапазона в шейдер
    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(AShaderProgram, 'a_minmax');
    glUniform4fv(lMinMaxLoc, 1, @lMinMax[0]);

    // Передача флагов логарифмического масштаба в шейдер (0 - линейный, 1 - log10)
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

    // Подготовка матрицы масштабирования и трансформации координат
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    // Передача массива точек в конвейер OpenGL без CPU расчёта координат
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ASeries.PointCount - 1 do
    begin
      lPoint := ASeries.Points[lIndex];
      glVertex2f(lPoint.X, lPoint.Y);
    end;
    glEnd;

    // Восстановление матрицы и отключение шейдера
    glPopMatrix;
    glUseProgram(0);
  end
  // Логический блок 2: Программная (CPU) отрисовка с ручным пересчётом координат в пиксели
  else
  begin
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ASeries.PointCount - 1 do
    begin
      lPoint := ASeries.Points[lIndex];
      // Перевод значений в экранные пиксели на процессоре
      lX := lRendererObj.XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
      lY := lRendererObj.AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
      glVertex2f(lX, lY);
    end;
    glEnd;
  end;
end;

end.
