import os

def main():
    pas_renderer = r"d:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"
    pas_unit1 = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

    # 1. Исправление uOglChartRenderer.pas (масштабирование шкалы)
    with open(pas_renderer, 'rb') as f:
        content_ren = f.read()

    # Замена в AxisValueToPixel
    old_axis_pixel = b"""function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
var
  lMin: Double;
  lMax: Double;
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
  begin
    lMin := Max(AAxis.MinValue, 1e-10);
    lMax := Max(AAxis.MaxValue, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    new_axis_pixel = b"""function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
var
  lMin: Double;
  lMax: Double;
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
  begin
    lMin := Max(AAxis.MinValue, 1e-10);
    lMax := AAxis.MaxValue;
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    # Замена в XValueToPixel
    old_x_pixel = b"""  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1e-10);
    lMax := Max(lMax, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    new_x_pixel = b"""  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1e-10);
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    # Замена в PixelToAxisValue
    old_pixel_to_axis = b"""function TOpenGLChartRenderer.PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;
begin
  if not Assigned(AAxis) then
    Exit(0);

  if AAxis.Scale = casLog10 then
    Result := Power(10, Log10(Max(AAxis.MinValue, 1e-10)) + (APixelY - ABottom) / (ATop - ABottom) * (Log10(Max(AAxis.MaxValue, 1e-10)) - Log10(Max(AAxis.MinValue, 1e-10))))"""

    new_pixel_to_axis = b"""function TOpenGLChartRenderer.PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;
var
  lMin, lMax: Double;
begin
  if not Assigned(AAxis) then
    Exit(0);

  if AAxis.Scale = casLog10 then
  begin
    lMin := Max(AAxis.MinValue, 1e-10);
    lMax := AAxis.MaxValue;
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := Power(10, Log10(lMin) + (APixelY - ABottom) / (ATop - ABottom) * (Log10(lMax) - Log10(lMin)))
  end"""

    # Применяем замены в рендерере
    content_ren = content_ren.replace(old_axis_pixel.replace(b'\n', b'\r\n'), new_axis_pixel.replace(b'\n', b'\r\n'))
    content_ren = content_ren.replace(old_x_pixel.replace(b'\n', b'\r\n'), new_x_pixel.replace(b'\n', b'\r\n'))
    content_ren = content_ren.replace(old_pixel_to_axis.replace(b'\n', b'\r\n'), new_pixel_to_axis.replace(b'\n', b'\r\n'))

    with open(pas_renderer, 'wb') as f:
        f.write(content_ren)
    print("Renderer limits fixed.")

    # 2. Исправление unit1.pas (возвращаем русские CP1251 строковые константы)
    with open(pas_unit1, 'rb') as f:
        content_u1 = f.read()

    # Заменяем UTF-8 байты обратно на обычные CP1251 байты
    # "Выбранная ось: " в UTF-8: b'\xd0\x92\xd1\x8b\xd0\xb1\xd1\x80\xd0\xb0\xd0\xbd\xd0\xbd\xd0\xb0\xd1\x8f\x20\xd0\xbe\xd1\x81\xd1\x8c\x3a\x20'
    # "Выбранная ось: " в CP1251: b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20'
    utf8_lbl = b'\xd0\x92\xd1\x8b\xd0\xb1\xd1\x80\xd0\xb0\xd0\xbd\xd0\xbd\xd0\xb0\xd1\x8f\x20\xd0\xbe\xd1\x81\xd1\x8c\x3a\x20'
    cp1251_lbl = b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20'
    
    utf8_lbl_none = b'\xd0\x92\xd1\x8b\xd0\xb1\xd1\x80\xd0\xb0\xd0\xbd\xd0\xbd\xd0\xb0\xd1\x8f\x20\xd0\xbe\xd1\x81\xd1\x8c\x3a\x20\xd0\xbd\xd0\xb5\xd1\x82'
    cp1251_lbl_none = b'\xc2\xfb\xe1\xf0\xe0\xed\xed\xe0\xff\x20\xee\xf1\xfc\x3a\x20\xed\xe5\xf2'

    content_u1 = content_u1.replace(utf8_lbl, cp1251_lbl)
    content_u1 = content_u1.replace(utf8_lbl_none, cp1251_lbl_none)

    with open(pas_unit1, 'wb') as f:
        f.write(content_u1)
    print("Unit1 string literals restored to CP1251.")

if __name__ == '__main__':
    main()
