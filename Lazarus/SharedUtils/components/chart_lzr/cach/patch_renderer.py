# -*- coding: utf-8 -*-
import io

file_path = "uOglChartRenderer.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Normalize
content = content.replace("\r\n", "\n").replace("\r", "\n")

# 1. Add uOglChartCursor to uses clause
target_uses = "uOglChartChart, uOglChartFontMng, uOglChartLineHelper, uOglChartTextLabel;"
replacement_uses = "uOglChartChart, uOglChartFontMng, uOglChartLineHelper, uOglChartTextLabel, uOglChartCursor;"

if target_uses in content:
    content = content.replace(target_uses, replacement_uses)
    print("Uses clause updated.")
else:
    print("Error: uses clause target not found")

# 2. Expose fFontMng and declare private methods
target_decl = """    procedure DrawTextLabel(ALabel: TChartTextLabel; APage: TChartPage; const ARect: TChartPixelRect);
    /// <summary> Рекурсивный обход и отрисовка дочерних объектов модели. </summary>"""

replacement_decl = """    procedure DrawTextLabel(ALabel: TChartTextLabel; APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawCursor(ACursor: TChartCursor; APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawCursorLabel(ACursor: TChartCursor; AXPixel, AYPixel: Single; const AText: string);
    function FindSelectedTrend(APage: TChartPage; ASelectedObj: TChartBaseObject): cBaseTrend;
    function GetTrendValueAtX(ATrend: cBaseTrend; AWorldX: Double; out AValueY: Double): Boolean;
    /// <summary> Рекурсивный обход и отрисовка дочерних объектов модели. </summary>"""

if target_decl in content:
    content = content.replace(target_decl, replacement_decl)
    print("Private declarations updated.")
else:
    print("Error: private declarations target not found")

# 3. Add FontManager property to public section
target_prop = """    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;"""
replacement_prop = """    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;
    property FontManager: cOglFontMng read fFontMng;"""

if target_prop in content:
    content = content.replace(target_prop, replacement_prop)
    print("FontManager property exposed.")
else:
    print("Error: property target not found")

# 4. Dispatch TChartCursor in RenderObject
target_dispatch = """  if AObject is TChartTextLabel then
    DrawTextLabel(TChartTextLabel(AObject), APage, ARect);"""

replacement_dispatch = """  if AObject is TChartTextLabel then
    DrawTextLabel(TChartTextLabel(AObject), APage, ARect);
  if AObject is TChartCursor then
    DrawCursor(TChartCursor(AObject), APage, ARect);"""

if target_dispatch in content:
    content = content.replace(target_dispatch, replacement_dispatch)
    print("RenderObject dispatch updated.")
else:
    print("Error: RenderObject dispatch target not found")

# 5. Fix PixelToXValue implementation for log scale
target_pixel_to_x = """function TOpenGLChartRenderer.PixelToXValue(APage: TChartPage; AAxis: TChartAxis; APixelX, ALeft, ARight: Single): Double;

var
  lMin, lMax: Double;
begin
  lMin := 0;
  lMax := 1;
  if Assigned(AAxis) and AAxis.UseOwnX then
  begin
    lMin := AAxis.XMinValue;
    lMax := AAxis.XMaxValue;
  end

  else if Assigned(APage) then
  begin
    lMin := APage.XMinValue;
    lMax := APage.XMaxValue;
  end;

  if ARight = ALeft then
    Exit(lMin);
  Result := lMin + (APixelX - ALeft) / (ARight - ALeft) * (lMax - lMin);
end;"""

replacement_pixel_to_x = """function TOpenGLChartRenderer.PixelToXValue(APage: TChartPage; AAxis: TChartAxis; APixelX, ALeft, ARight: Single): Double;

var
  lMin, lMax: Double;
  lScale: TChartAxisScale;
begin
  lMin := 0;
  lMax := 1;
  lScale := casLinear;
  if Assigned(AAxis) and AAxis.UseOwnX then
  begin
    lMin := AAxis.XMinValue;
    lMax := AAxis.XMaxValue;
    lScale := AAxis.XScale;
  end

  else if Assigned(APage) then
  begin
    lMin := APage.XMinValue;
    lMax := APage.XMaxValue;
    lScale := APage.XScale;
  end;

  if ARight = ALeft then
    Exit(lMin);

  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1e-10);
    if lMax <= lMin then
      lMax := lMin * 10;
    Result := Power(10, Log10(lMin) + (APixelX - ALeft) / (ARight - ALeft) * (Log10(lMax) - Log10(lMin)));
  end
  else
    Result := lMin + (APixelX - ALeft) / (ARight - ALeft) * (lMax - lMin);
end;"""

if target_pixel_to_x in content:
    content = content.replace(target_pixel_to_x, replacement_pixel_to_x)
    print("PixelToXValue implementation updated.")
else:
    print("Error: PixelToXValue implementation target not found")

# 6. Append DrawCursor and helper method implementations
implementation_end = """function GlyphRow(AChar: Char; ARow: Integer): string;"""
cursor_impl = """function TOpenGLChartRenderer.FindSelectedTrend(APage: TChartPage; ASelectedObj: TChartBaseObject): cBaseTrend;
var
  lAxis: TChartAxis;
  I, J: Integer;
begin
  Result := nil;
  if not Assigned(APage) then Exit;
  
  if Assigned(ASelectedObj) then
  begin
    if ASelectedObj is cBaseTrend then
      Exit(cBaseTrend(ASelectedObj))
    else if ASelectedObj is TChartAxis then
    begin
      lAxis := TChartAxis(ASelectedObj);
      for I := 0 to lAxis.ChildCount - 1 do
        if lAxis.Children[I] is cBaseTrend then
          Exit(cBaseTrend(lAxis.Children[I]));
    end;
  end;
  
  for I := 0 to APage.ChildCount - 1 do
  begin
    if APage.Children[I] is TChartAxis then
    begin
      lAxis := TChartAxis(APage.Children[I]);
      for J := 0 to lAxis.ChildCount - 1 do
        if lAxis.Children[J] is cBaseTrend then
        begin
          if lAxis.Children[J].Visible then
            Exit(cBaseTrend(lAxis.Children[J]));
        end;
    end;
  end;
end;

function TOpenGLChartRenderer.GetTrendValueAtX(ATrend: cBaseTrend; AWorldX: Double; out AValueY: Double): Boolean;
var
  lLine: cLineSeries;
  lBuff: cBuffTrend1d;
  I: Integer;
  lIdx: Integer;
  lX1, lX2, lY1, lY2: Double;
  lRatio: Double;
begin
  Result := False;
  AValueY := 0;
  if not Assigned(ATrend) or not ATrend.Visible then Exit;

  if ATrend is cLineSeries then
  begin
    lLine := cLineSeries(ATrend);
    if lLine.PointCount = 0 then Exit;
    if lLine.PointCount = 1 then
    begin
      AValueY := lLine.Points[0].Y;
      Exit(True);
    end;
    
    if AWorldX <= lLine.Points[0].X then
    begin
      AValueY := lLine.Points[0].Y;
      Exit(True);
    end;
    if AWorldX >= lLine.Points[lLine.PointCount - 1].X then
    begin
      AValueY := lLine.Points[lLine.PointCount - 1].Y;
      Exit(True);
    end;

    for I := 0 to lLine.PointCount - 2 do
    begin
      if (AWorldX >= lLine.Points[I].X) and (AWorldX <= lLine.Points[I+1].X) then
      begin
        lX1 := lLine.Points[I].X;
        lX2 := lLine.Points[I+1].X;
        lY1 := lLine.Points[I].Y;
        lY2 := lLine.Points[I+1].Y;
        if lX2 <> lX1 then
          lRatio := (AWorldX - lX1) / (lX2 - lX1)
        else
          lRatio := 0;
        AValueY := lY1 + lRatio * (lY2 - lY1);
        Exit(True);
      end;
    end;
  end
  else if ATrend is cBuffTrend1d then
  begin
    lBuff := cBuffTrend1d(ATrend);
    if lBuff.Count = 0 then Exit;
    if lBuff.Count = 1 then
    begin
      AValueY := lBuff.Values[0];
      Exit(True);
    end;
    if lBuff.DX = 0 then Exit;
    
    lRatio := (AWorldX - lBuff.X0) / lBuff.DX;
    if lRatio <= 0 then
    begin
      AValueY := lBuff.Values[0];
      Exit(True);
    end;
    if lRatio >= lBuff.Count - 1 then
    begin
      AValueY := lBuff.Values[lBuff.Count - 1];
      Exit(True);
    end;
    
    lIdx := Trunc(lRatio);
    lY1 := lBuff.Values[lIdx];
    lY2 := lBuff.Values[lIdx + 1];
    lRatio := lRatio - lIdx;
    AValueY := lY1 + lRatio * (lY2 - lY1);
    Exit(True);
  end;
end;

procedure TOpenGLChartRenderer.DrawCursorLabel(ACursor: TChartCursor; AXPixel, AYPixel: Single; const AText: string);
var
  lFont: cOglFont;
  lTextWidth, lTextHeight: Single;
  lRect: TChartPixelRect;
  lLines: TStringList;
  I: Integer;
begin
  lFont := fFontMng.Font(cfGridTick);
  lLines := TStringList.Create;
  try
    lLines.Text := AText;
    lTextWidth := 0;
    for I := 0 to lLines.Count - 1 do
      lTextWidth := Max(lTextWidth, lFont.TextPixelWidth(lLines[I]));
    lTextHeight := lLines.Count * lFont.TextPixelHeight;
    
    lRect.Left := AXPixel - lTextWidth / 2 - 6;
    lRect.Right := AXPixel + lTextWidth / 2 + 6;
    lRect.Top := AYPixel - lTextHeight / 2 - 4;
    lRect.Bottom := AYPixel + lTextHeight / 2 + 4;
    
    SetGLColor($E515151A); // Прозрачный темно-серый фон
    FillRect(lRect);
    
    SetGLColor(ACursor.Color);
    glLineWidth(1);
    DrawRect(lRect);
    
    SetGLColor($FFFFFFFF);
    for I := 0 to lLines.Count - 1 do
    begin
      DrawText(lLines[I], lRect.Left + 6, lRect.Top + 4 + I * lFont.TextPixelHeight, lFont);
    end;
  finally
    lLines.Free;
  end;
end;

procedure TOpenGLChartRenderer.DrawCursor(ACursor: TChartCursor; APage: TChartPage; const ARect: TChartPixelRect);
var
  lPixelX1, lPixelX2: Single;
  lValY1, lValY2: Double;
  lTrend: cBaseTrend;
  lYAxis: TChartAxis;
  lLabelY1, lLabelY2: Single;
  lText: string;
begin
  if not Assigned(ACursor) or not ACursor.Visible then Exit;

  lYAxis := GetPrimaryXAxis(APage);
  lPixelX1 := XValueToPixel(APage, lYAxis, ACursor.X1, ARect.Left, ARect.Right);
  lPixelX2 := XValueToPixel(APage, lYAxis, ACursor.X2, ARect.Left, ARect.Right);

  lTrend := FindSelectedTrend(APage, fSelectedObject);
  
  if (lPixelX1 >= ARect.Left) and (lPixelX1 <= ARect.Right) then
  begin
    SetGLColor(ACursor.Color);
    glLineWidth(2.0);
    glLineStipple(2, $0F0F);
    glEnable(GL_LINE_STIPPLE);
    DrawLine(lPixelX1, ARect.Bottom, lPixelX1, ARect.Top);
    glDisable(GL_LINE_STIPPLE);

    if ACursor.ShowLabel then
    begin
      lValY1 := 0.0;
      if Assigned(lTrend) then
        GetTrendValueAtX(lTrend, ACursor.X1, lValY1);
      
      lText := Format('X1: %0.5g'#13'Y1: %0.5g', [ACursor.X1, lValY1]);
      lLabelY1 := ARect.Bottom + ACursor.LabelY1Offset * (ARect.Top - ARect.Bottom);
      DrawCursorLabel(ACursor, lPixelX1, lLabelY1, lText);
    end;
  end;

  if ACursor.CursorType = cctDouble then
  begin
    if (lPixelX2 >= ARect.Left) and (lPixelX2 <= ARect.Right) then
    begin
      SetGLColor(ACursor.Color);
      glLineWidth(1.5);
      glLineStipple(2, $3333);
      glEnable(GL_LINE_STIPPLE);
      DrawLine(lPixelX2, ARect.Bottom, lPixelX2, ARect.Top);
      glDisable(GL_LINE_STIPPLE);

      if ACursor.ShowLabel then
      begin
        lValY2 := 0.0;
        if Assigned(lTrend) then
          GetTrendValueAtX(lTrend, ACursor.X2, lValY2);

        lText := Format('X2: %0.5g'#13'Y2: %0.5g', [ACursor.X2, lValY2]);
        lLabelY2 := ARect.Bottom + ACursor.LabelY2Offset * (ARect.Top - ARect.Bottom);
        DrawCursorLabel(ACursor, lPixelX2, lLabelY2, lText);
      end;
    end;
  end;
end;

""" + implementation_end

if implementation_end in content:
    content = content.replace(implementation_end, cursor_impl)
    print("Cursor implementations appended.")
else:
    print("Error: implementation end target not found")

content = content.replace("\n", "\r\n")

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Done.")
