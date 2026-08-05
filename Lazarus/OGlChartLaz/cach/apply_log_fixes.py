import os

def main():
    target_file = r"d:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"
    
    with open(target_file, 'r', encoding='cp1251', errors='strict') as f:
        content = f.read()

    # 1. Замена базы -12.0 на -10.0 в SHADER_LINE_LG_VERT и SHADER_LINE_LG_1D_VERT
    # Ищем: '    if (a_minmax[0] <= 0.0) lgMin = -12.0;'#10 +
    # Ищем: '    if (a_minmax[2] <= 0.0) lgMin = -12.0;'#10 +
    content = content.replace("lgMin = -12.0;", "lgMin = -10.0;")

    # 2. Замена 1E-12 на 1e-10 / 1E-10
    # AxisValueToPixel
    old_axis_val = """function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
var
  lMin: Double;
  lMax: Double;
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
  begin
    lMin := Max(AAxis.MinValue, 1E-12);
    lMax := Max(AAxis.MaxValue, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1E-12)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    new_axis_val = """function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
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

    content = content.replace(old_axis_val, new_axis_val)

    # XValueToPixel
    old_x_val = """  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1E-12);
    lMax := Max(lMax, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1E-12)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    new_x_val = """  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1e-10);
    lMax := Max(lMax, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1e-10)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end"""

    content = content.replace(old_x_val, new_x_val)

    # PixelToAxisValue
    old_pix_to_val = """  if AAxis.Scale = casLog10 then
    Result := Power(10, Log10(Max(AAxis.MinValue, 1E-12)) + (APixelY - ABottom) / (ATop - ABottom) * (Log10(Max(AAxis.MaxValue, 1E-12)) - Log10(Max(AAxis.MinValue, 1E-12))))"""

    new_pix_to_val = """  if AAxis.Scale = casLog10 then
    Result := Power(10, Log10(Max(AAxis.MinValue, 1e-10)) + (APixelY - ABottom) / (ATop - ABottom) * (Log10(Max(AAxis.MaxValue, 1e-10)) - Log10(Max(AAxis.MinValue, 1e-10))))"""

    content = content.replace(old_pix_to_val, new_pix_to_val)

    # 3. Переписываем BuildLogTicks
    old_build_ticks = """procedure TOpenGLChartRenderer.BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);
const
  CMul: array[0..2] of Integer = (1, 2, 5);
var
  lPow: Integer;
  lMulIndex: Integer;
  lValue: Double;
  lIndex: Integer;
begin
  ATicks := nil;
  if AMin <= 0 then
    AMin := 0.001;
  if AMax <= AMin then
    AMax := AMin * 10;

  lIndex := 0;
  for lPow := Floor(Log10(AMin)) to Ceil(Log10(AMax)) do
    for lMulIndex := Low(CMul) to High(CMul) do
    begin
      lValue := CMul[lMulIndex] * Power(10, lPow);
      if (lValue >= AMin) and (lValue <= AMax) then
      begin
        SetLength(ATicks, lIndex + 1);
        ATicks[lIndex].Value := lValue;
        ATicks[lIndex].Text := FormatFloat('0.######', lValue);
        Inc(lIndex);
      end;
    end;
end;"""

    new_build_ticks = """procedure TOpenGLChartRenderer.BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);
var
  lPow: Integer;
  lMinPow, lMaxPow: Integer;
  lValue: Double;
  lIndex: Integer;
  lMinVal: Double;
begin
  ATicks := nil;
  lMinVal := AMin;
  if lMinVal <= 0 then
    lMinVal := 1e-10;
  if AMax <= lMinVal then
    AMax := lMinVal * 10;

  lMinPow := Floor(Log10(lMinVal));
  lMaxPow := Ceil(Log10(AMax));

  lIndex := 0;
  for lPow := lMinPow to lMaxPow do
  begin
    lValue := Power(10, lPow);
    if (lValue >= lMinVal * (1.0 - 1e-9)) and (lValue <= AMax * (1.0 + 1e-9)) then
    begin
      SetLength(ATicks, lIndex + 1);
      ATicks[lIndex].Value := lValue;
      
      if (AMin <= 0) and (lValue <= 1.01e-10) then
        ATicks[lIndex].Text := '0'
      else if (lValue >= 1) and (lValue < 1e6) then
        ATicks[lIndex].Text := FormatFloat('0', lValue)
      else if (lValue < 1) and (lValue >= 1e-5) then
        ATicks[lIndex].Text := FormatFloat('0.#######', lValue)
      else
        ATicks[lIndex].Text := FormatFloat('0.E+0', lValue);
        
      Inc(lIndex);
    end;
  end;
end;"""

    content = content.replace(old_build_ticks, new_build_ticks)

    with open(target_file, 'w', encoding='cp1251', newline='\r\n') as f:
        f.write(content)
        
    print("Success")

if __name__ == '__main__':
    main()
