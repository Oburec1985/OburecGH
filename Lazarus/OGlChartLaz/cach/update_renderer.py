import os

FILE_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print(f"Modifying {os.path.basename(FILE_PATH)} with newline normalization...")

with open(FILE_PATH, 'rb') as f:
    raw = f.read()

# Decode as cp1251
content = raw.decode('cp1251')

# Normalize to LF for easy replacement
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Add declarations to interface
target_decl = "    procedure RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);"
replacement_decl = "    procedure DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);\n    procedure RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);"

if target_decl in content_lf:
    content_lf = content_lf.replace(target_decl, replacement_decl)
    print("Declaration 1 updated successfully.")
else:
    print("Warning: target_decl not found!")

target_decl2 = "    function PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;"
replacement_decl2 = "    function PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;\n    function GetAxisHitAt(AX, AY: Integer; out AAxis: TChartAxis): Boolean;"

if target_decl2 in content_lf:
    content_lf = content_lf.replace(target_decl2, replacement_decl2)
    print("Declaration 2 updated successfully.")
else:
    print("Warning: target_decl2 not found!")

# 2. Modify RenderObject implementation to render trend points
target_render = "  if AObject is cBuffTrend1d then\n    DrawBuffTrend1d(cBuffTrend1d(AObject), ARect, APage, lYAxis)\n  else if AObject is TChartLineSeries then\n    DrawLineSeries(TChartLineSeries(AObject), ARect, APage, lYAxis);"
replacement_render = "  if AObject is cBuffTrend1d then\n    DrawBuffTrend1d(cBuffTrend1d(AObject), ARect, APage, lYAxis)\n  else if AObject is TChartLineSeries then\n  begin\n    DrawLineSeries(TChartLineSeries(AObject), ARect, APage, lYAxis);\n    if AObject is cTrend then\n      DrawTrendPoints(cTrend(AObject), ARect, APage, lYAxis);\n  end;"

if target_render in content_lf:
    content_lf = content_lf.replace(target_render, replacement_render)
    print("RenderObject implementation updated successfully.")
else:
    print("Warning: target_render not found!")

# 3. Add implementations of GetAxisHitAt and DrawTrendPoints at the end of implementation section (before end.)
impl_addition = """
procedure TOpenGLChartRenderer.DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect;
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
end;

function TOpenGLChartRenderer.GetAxisHitAt(AX, AY: Integer; out AAxis: TChartAxis): Boolean;
var
  lIndex, I, J: Integer;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lYAxis: TChartAxis;
  lAxisX, lAxisOffset: Single;
  lYTicks: TChartTickArray;
  lAxisFont: cOglFont;
  lMaxTextWidth, lTextWidth: Integer;
  lText: string;
begin
  AAxis := nil;
  for lIndex := 0 to fModel.ChildCount - 1 do
    if fModel.Children[lIndex] is TChartPage then
    begin
      lPage := TChartPage(fModel.Children[lIndex]);
      lPageRect := GetPageRect(lPage);
      if (AX >= lPageRect.Left) and (AX <= lPageRect.Right) and
         (AY >= lPageRect.Top) and (AY <= lPageRect.Bottom) then
      begin
        lContentRect := GetPageContentRect(lPage);
        lAxisOffset := 0;
        for I := 0 to lPage.ChildCount - 1 do
          if lPage.Children[I] is TChartAxis then
          begin
            lYAxis := TChartAxis(lPage.Children[I]);
            lAxisX := lContentRect.Left - lAxisOffset;

            if (AY >= lContentRect.Top) and (AY <= lContentRect.Bottom) and
               (Abs(AX - lAxisX) <= 10) then
            begin
              AAxis := lYAxis;
              Exit(True);
            end;

            BuildAxisTicks(lYAxis, 8, lYTicks);
            if lYAxis = fSelectedObject then
              lAxisFont := fFontMng.Font(cfAxisSelected)
            else
              lAxisFont := fFontMng.Font(cfAxisLabel);

            lMaxTextWidth := 0;
            for J := 0 to High(lYTicks) do
            begin
              lText := lYTicks[J].Text;
              lTextWidth := lAxisFont.TextPixelWidth(lText);
              if lTextWidth > lMaxTextWidth then
                lMaxTextWidth := lTextWidth;
            end;
            lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
          end;
      end;
    end;
  Result := False;
end;

"""

# Insert implementation at the end (before end.)
pos = content_lf.rfind("end.")
if pos != -1:
    content_lf = content_lf[:pos] + impl_addition + content_lf[pos:]
    print("Implementation methods added successfully.")
else:
    print("Warning: end. not found!")

# Restore CRLF
content_crlf = content_lf.replace('\n', '\r\n')

with open(FILE_PATH, 'wb') as f:
    f.write(content_crlf.encode('cp1251'))

print("File saved successfully.")
