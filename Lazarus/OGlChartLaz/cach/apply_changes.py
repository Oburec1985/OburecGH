import os

def process_file(filename, replacements):
    print(f"Processing {os.path.basename(filename)}...")
    f = open(filename, 'rb')
    raw_data = f.read()
    f.close()
    
    # Try decoding
    text = None
    for enc in ['utf-8', 'cp1251']:
        try:
            text = raw_data.decode(enc)
            print(f"  Decoded successfully as {enc}")
            break
        except Exception:
            continue
            
    if text is None:
        raise ValueError(f"Could not decode file {filename} as UTF-8 or CP1251")
        
    # Normalize line endings to LF
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    
    for old, new, desc in replacements:
        old_lf = old.replace('\r\n', '\n').replace('\r', '\n').strip()
        new_lf = new.replace('\r\n', '\n').replace('\r', '\n').strip()
        if old_lf in text:
            text = text.replace(old_lf, new_lf)
            print(f"  OK: {desc}")
        else:
            # Try matching with flexible whitespace/newlines
            import re
            pattern = re.escape(old_lf).replace(r'\ ', r'\s+').replace(r'\n', r'\s*\n\s*')
            match = re.search(pattern, text)
            if match:
                text = text[:match.start()] + new_lf + text[match.end():]
                print(f"  OK (regex match): {desc}")
            else:
                print(f"  FAIL: {desc}")
            
    # Normalize line endings to CRLF
    text = text.replace('\n', '\r\n')
    
    # Save back as Windows-1251 (CP1251) with newline='' to prevent double conversion
    f = open(filename, 'w', encoding='cp1251', newline='')
    f.write(text)
    f.close()

# ----------------- uOglChartAxis.pas -----------------
axis_reps = [
    (
        """  TChartAxisOrientation = (caoX, caoY);
  TChartAxisScale = (casLinear, casLog10);""",
        """  TChartAxisScale = (casLinear, casLog10);""",
        "Orientation type definition"
    ),
    (
        """  cAxis = class(cDrawObj)
  private
    fOrientation: TChartAxisOrientation;
    fScale: TChartAxisScale;
    fMinValue: Double;
    fMaxValue: Double;""",
        """  cAxis = class(cDrawObj)
  private
    fScale: TChartAxisScale;
    fMinValue: Double;
    fMaxValue: Double;
    fUseOwnX: Boolean;
    fXMinValue: Double;
    fXMaxValue: Double;
    fXScale: TChartAxisScale;""",
        "Axis type and fields"
    ),
    (
        """    property Orientation: TChartAxisOrientation read fOrientation write fOrientation;
    property Scale: TChartAxisScale read fScale write fScale;
    property MinValue: Double read fMinValue write fMinValue;
    property MaxValue: Double read fMaxValue write fMaxValue;
  end;""",
        """    property Scale: TChartAxisScale read fScale write fScale;
    property MinValue: Double read fMinValue write fMinValue;
    property MaxValue: Double read fMaxValue write fMaxValue;
    property UseOwnX: Boolean read fUseOwnX write fUseOwnX;
    property XMinValue: Double read fXMinValue write fXMinValue;
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    property XScale: TChartAxisScale read fXScale write fXScale;
  end;""",
        "Axis properties"
    ),
    (
        """procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fOrientation := caoY;
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
end;""",
        """procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
  fUseOwnX := False;
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
end;""",
        "Axis AssignDefaultProperties"
    )
]
process_file(r'C:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartAxis.pas', axis_reps)

# ----------------- uOglChartPage.pas -----------------
page_reps = [
    (
        """uses
  uOglChartDrawObj;""",
        """uses
  uOglChartDrawObj, uOglChartAxis;""",
        "Page uses clause"
    ),
    (
        """  cBasePage = class(cMoveObj)
  private
    fAlign: TChartPageAlign;
    fAlignWeight: Integer;
    fBorderColor: Cardinal;
    fFillColor: Cardinal;
    fBorderWidth: Single;
    fPixelTabSpace: TChartPixelRect;
  public
    procedure AssignDefaultProperties; override;

    property Align: TChartPageAlign read fAlign write fAlign;
    property AlignWeight: Integer read fAlignWeight write fAlignWeight;
    property BorderColor: Cardinal read fBorderColor write fBorderColor;
    property FillColor: Cardinal read fFillColor write fFillColor;
    property BorderWidth: Single read fBorderWidth write fBorderWidth;
    property PixelTabSpace: TChartPixelRect read fPixelTabSpace write fPixelTabSpace;
  end;""",
        """  cBasePage = class(cMoveObj)
  private
    fAlign: TChartPageAlign;
    fAlignWeight: Integer;
    fBorderColor: Cardinal;
    fFillColor: Cardinal;
    fBorderWidth: Single;
    fPixelTabSpace: TChartPixelRect;
    fXMinValue: Double;
    fXMaxValue: Double;
    fXScale: TChartAxisScale;
  public
    procedure AssignDefaultProperties; override;

    property Align: TChartPageAlign read fAlign write fAlign;
    property AlignWeight: Integer read fAlignWeight write fAlignWeight;
    property BorderColor: Cardinal read fBorderColor write fBorderColor;
    property FillColor: Cardinal read fFillColor write fFillColor;
    property BorderWidth: Single read fBorderWidth write fBorderWidth;
    property PixelTabSpace: TChartPixelRect read fPixelTabSpace write fPixelTabSpace;
    property XMinValue: Double read fXMinValue write fXMinValue;
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    property XScale: TChartAxisScale read fXScale write fXScale;
  end;""",
        "Page fields and properties"
    ),
    (
        """procedure cBasePage.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Page';
  Caption := 'Page';
  fBorderColor := $FF606060;
  fFillColor := $FFFFFFFF;
  fBorderWidth := 2;
  fPixelTabSpace.Left := 42;
  fPixelTabSpace.Top := 34;
  fPixelTabSpace.Right := 12;
  fPixelTabSpace.Bottom := 24;
  fAlign := cpaAuto;
  fAlignWeight := 1;
  SetFloatRect(0.04, 0.06, 0.96, 0.94);
end;""",
        """procedure cBasePage.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Page';
  Caption := 'Page';
  fBorderColor := $FF606060;
  fFillColor := $FFFFFFFF;
  fBorderWidth := 2;
  fPixelTabSpace.Left := 42;
  fPixelTabSpace.Top := 34;
  fPixelTabSpace.Right := 12;
  fPixelTabSpace.Bottom := 24;
  fAlign := cpaAuto;
  fAlignWeight := 1;
  SetFloatRect(0.04, 0.06, 0.96, 0.94);
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
end;""",
        "Page AssignDefaultProperties"
    )
]
process_file(r'C:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartPage.pas', page_reps)

# ----------------- uOglChartTrend.pas -----------------
trend_reps = [
    (
        """  cBaseTrend = class(cDrawObj)
  private
    fXAxis: cAxis;
  public
    procedure AssignDefaultProperties; override;
    property XAxis: cAxis read fXAxis write fXAxis;
  end;""",
        """  cBaseTrend = class(cDrawObj)
  public
    procedure AssignDefaultProperties; override;
  end;""",
        "Trend properties declaration"
    ),
    (
        """procedure cBaseTrend.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Series';
  Caption := 'Series';
  fXAxis := nil;
end;""",
        """procedure cBaseTrend.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Series';
  Caption := 'Series';
end;""",
        "Trend AssignDefaultProperties implementation"
    )
]
process_file(r'C:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartTrend.pas', trend_reps)

# ----------------- uOglChartRenderer.pas -----------------
renderer_reps = [
    (
        "  TChartEditLabelKind = (celNone, celAxisMin, celAxisMax);",
        "  TChartEditLabelKind = (celNone, celAxisMin, celAxisMax, celXMin, celXMax);",
        "TChartEditLabelKind"
    ),
    (
        """  TChartTextHit = record
    Rect: TChartPixelRect;
    Axis: TChartAxis;
    Kind: TChartEditLabelKind;
    Text: string;
    TextLeft: Integer;
    Font: cOglFont;
  end;""",
        """  TChartTextHit = record
    Rect: TChartPixelRect;
    Axis: TChartAxis;
    Page: TChartPage;
    Kind: TChartEditLabelKind;
    Text: string;
    TextLeft: Integer;
    Font: cOglFont;
  end;""",
        "TChartTextHit"
    ),
    (
        """    procedure Apply2DView;
    procedure SetGLColor(AColor: Cardinal);
    function PageContentRect(APage: TChartPage): TChartPixelRect;
    function PageToPixelRect(APage: TChartPage): TChartPixelRect;
    function FindAxis(APage: TChartPage; AOrientation: TChartAxisOrientation): TChartAxis;
    function NiceStep(ARange: Double; ATargetCount: Integer): Double;
    procedure BuildLinearTicks(AMin, AMax: Double; ATargetCount: Integer; out ATicks: TChartTickArray);
    procedure BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);
    procedure BuildAxisTicks(AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
    function FormatTick(AValue, AStep: Double): string;
    function ValueToPixel(AValue, AMin, AMax: Double; APixelMin, APixelMax: Single): Single;
    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;

    procedure DrawLine(AX1, AY1, AX2, AY2: Single);
    procedure DrawRect(const ARect: TChartPixelRect);
    procedure FillRect(const ARect: TChartPixelRect);
    procedure AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont; AAxis: TChartAxis; AKind: TChartEditLabelKind);
    procedure DrawText(const AText: string; AX, AY: Single; AFont: cOglFont);
    procedure DrawTextSelection(AX, AY: Single; AFont: cOglFont; AStartIndex, ALength: Integer);
    procedure DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont; AAxis: TChartAxis; AKind: TChartEditLabelKind);
    procedure DrawGrid(const ARect: TChartPixelRect; AXAxis, AYAxis: TChartAxis);
    procedure DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
    procedure DrawPageFrame(APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect; AXAxis, AYAxis: TChartAxis);
    procedure DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect; AXAxis, AYAxis: TChartAxis);
    procedure RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect; AXAxis, AYAxis: TChartAxis);
    procedure RenderPage(APage: TChartPage);""",
        """    procedure Apply2DView;
    procedure SetGLColor(AColor: Cardinal);
    function PageContentRect(APage: TChartPage): TChartPixelRect;
    function PageToPixelRect(APage: TChartPage): TChartPixelRect;
    function GetPrimaryXAxis(APage: TChartPage): TChartAxis;
    function NiceStep(ARange: Double; ATargetCount: Integer): Double;
    procedure BuildLinearTicks(AMin, AMax: Double; ATargetCount: Integer; out ATicks: TChartTickArray);
    procedure BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);
    procedure BuildAxisTicks(AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
    procedure BuildXTicks(APage: TChartPage; AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
    function FormatTick(AValue, AStep: Double): string;
    function ValueToPixel(AValue, AMin, AMax: Double; APixelMin, APixelMax: Single): Single;
    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;

    procedure DrawLine(AX1, AY1, AX2, AY2: Single);
    procedure DrawRect(const ARect: TChartPixelRect);
    procedure FillRect(const ARect: TChartPixelRect);
    procedure AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont; AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);
    procedure DrawText(const AText: string; AX, AY: Single; AFont: cOglFont);
    procedure DrawTextSelection(AX, AY: Single; AFont: cOglFont; AStartIndex, ALength: Integer);
    procedure DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont; AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);
    procedure DrawGrid(const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
    procedure DrawPageFrame(APage: TChartPage; const ARect: TChartPixelRect);
    procedure DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure RenderPage(APage: TChartPage);""",
        "Declarations"
    ),
    (
        """    '.': if ARow = 6 then Result := '00100';
    '-': if ARow = 3 then Result := '01110';""",
        """    '.': if ARow = 6 then Result := '00100';
    ',': case ARow of 5: Result := '00100'; 6: Result := '01000'; end;
    '-': if ARow = 3 then Result := '01110';""",
        "GlyphRow Comma"
    ),
    (
        """function TOpenGLChartRenderer.FindAxis(APage: TChartPage; AOrientation: TChartAxisOrientation): TChartAxis;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(APage) then
    Exit;
  for I := 0 to APage.ChildCount - 1 do
    if (APage.Children[I] is TChartAxis) and
      (TChartAxis(APage.Children[I]).Orientation = AOrientation) then
      Exit(TChartAxis(APage.Children[I]));
end;""",
        """function TOpenGLChartRenderer.GetPrimaryXAxis(APage: TChartPage): TChartAxis;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(APage) then
    Exit;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      Result := TChartAxis(APage.Children[I]);
      Exit;
    end;
end;""",
        "GetPrimaryXAxis"
    ),
    (
        """function TOpenGLChartRenderer.FormatTick(AValue, AStep: Double): string;
var
  lDigits: Integer;
begin
  if AStep >= 1 then
    lDigits := 0
  else
    lDigits := Min(6, Max(0, Ceil(-Log10(AStep))));
  Result := FormatFloat('0.' + StringOfChar('0', lDigits), AValue);
end;""",
        """function TOpenGLChartRenderer.FormatTick(AValue, AStep: Double): string;
var
  lDigits: Integer;
begin
  if AStep >= 1 then
    Result := FormatFloat('0', AValue)
  else
  begin
    lDigits := Min(6, Max(0, Ceil(-Log10(AStep))));
    if lDigits = 0 then
      Result := FormatFloat('0', AValue)
    else
      Result := FormatFloat('0.' + StringOfChar('0', lDigits), AValue);
  end;
end;""",
        "FormatTick"
    ),
    (
        """function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
var
  lMin: Double;
  lMax: Double;
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
  begin
    lMin := Max(AAxis.MinValue, 1E-12);
    lMax := Max(AAxis.MaxValue, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1E-12)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end
  else if Assigned(AAxis) then
    Result := ValueToPixel(AValue, AAxis.MinValue, AAxis.MaxValue, APixelMin, APixelMax)
  else
    Result := (APixelMin + APixelMax) / 2;
end;""",
        """function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
var
  lMin: Double;
  lMax: Double;
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
  begin
    lMin := Max(AAxis.MinValue, 1E-12);
    lMax := Max(AAxis.MaxValue, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1E-12)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end
  else if Assigned(AAxis) then
    Result := ValueToPixel(AValue, AAxis.MinValue, AAxis.MaxValue, APixelMin, APixelMax)
  else
    Result := (APixelMin + APixelMax) / 2;
end;

function TOpenGLChartRenderer.XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
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

  if lScale = casLog10 then
  begin
    lMin := Max(lMin, 1E-12);
    lMax := Max(lMax, lMin * 10);
    Result := ValueToPixel(Log10(Max(AValue, 1E-12)), Log10(lMin), Log10(lMax), APixelMin, APixelMax);
  end
  else
    Result := ValueToPixel(AValue, lMin, lMax, APixelMin, APixelMax);
end;

procedure TOpenGLChartRenderer.BuildXTicks(APage: TChartPage; AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
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

  if lScale = casLog10 then
    BuildLogTicks(lMin, lMax, ATicks)
  else
    BuildLinearTicks(lMin, lMax, ATargetCount, ATicks);
end;""",
        "XValueToPixel and BuildXTicks"
    ),
    (
        """procedure TOpenGLChartRenderer.AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont;
  AAxis: TChartAxis; AKind: TChartEditLabelKind);
var
  lIndex: Integer;
begin
  if not Assigned(AFont) or not Assigned(AAxis) or (AKind = celNone) then
    Exit;
  lIndex := Length(fTextHits);
  SetLength(fTextHits, lIndex + 1);
  fTextHits[lIndex].Rect.Left := Floor(AX);
  fTextHits[lIndex].Rect.Top := Floor(AY);
  fTextHits[lIndex].Rect.Right := Ceil(AX + AFont.TextPixelWidth(AText));
  fTextHits[lIndex].Rect.Bottom := Ceil(AY + AFont.TextPixelHeight);
  fTextHits[lIndex].Axis := AAxis;
  fTextHits[lIndex].Kind := AKind;
  fTextHits[lIndex].Text := AText;
  fTextHits[lIndex].TextLeft := Floor(AX);
  fTextHits[lIndex].Font := AFont;
end;""",
        """procedure TOpenGLChartRenderer.AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont;
  AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);
var
  lIndex: Integer;
begin
  if not Assigned(AFont) or (AKind = celNone) then
    Exit;
  lIndex := Length(fTextHits);
  SetLength(fTextHits, lIndex + 1);
  fTextHits[lIndex].Rect.Left := Floor(AX);
  fTextHits[lIndex].Rect.Top := Floor(AY);
  fTextHits[lIndex].Rect.Right := Ceil(AX + AFont.TextPixelWidth(AText));
  fTextHits[lIndex].Rect.Bottom := Ceil(AY + AFont.TextPixelHeight);
  fTextHits[lIndex].Axis := AAxis;
  fTextHits[lIndex].Page := APage;
  fTextHits[lIndex].Kind := AKind;
  fTextHits[lIndex].Text := AText;
  fTextHits[lIndex].TextLeft := Floor(AX);
  fTextHits[lIndex].Font := AFont;
end;""",
        "AddTextHit implementation"
    ),
    (
        """procedure TOpenGLChartRenderer.DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont;
  AAxis: TChartAxis; AKind: TChartEditLabelKind);
var
  lCursorX: Single;
begin
  AddTextHit(AText, AX, AY, AFont, AAxis, AKind);
  if Assigned(fActiveHit.Axis) and (fActiveHit.Axis = AAxis) and (fActiveHit.Kind = AKind) then
  begin
    DrawTextSelection(AX, AY, AFont, fEditSelectionStart, fEditSelectionLength);
    lCursorX := AX + AFont.TextPixelWidth(Copy(fEditText, 1, Max(0, fEditCursor - 1)));
    SetGLColor($FF202020);
    DrawLine(lCursorX, AY - 1, lCursorX, AY + AFont.TextPixelHeight + 1);
    DrawText(fEditText, AX, AY, AFont);
  end
  else
    DrawText(AText, AX, AY, AFont);
end;""",
        """procedure TOpenGLChartRenderer.DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont;
  AAxis: TChartAxis; APage: TChartPage; AKind: TChartEditLabelKind);
var
  lCursorX: Single;
begin
  AddTextHit(AText, AX, AY, AFont, AAxis, APage, AKind);
  if (Assigned(fActiveHit.Axis) and (fActiveHit.Axis = AAxis) and (fActiveHit.Kind = AKind)) or
     (Assigned(fActiveHit.Page) and (fActiveHit.Page = APage) and (fActiveHit.Kind = AKind)) then
  begin
    DrawTextSelection(AX, AY, AFont, fEditSelectionStart, fEditSelectionLength);
    lCursorX := AX + AFont.TextPixelWidth(Copy(fEditText, 1, Max(0, fEditCursor - 1)));
    SetGLColor($FF202020);
    DrawLine(lCursorX, AY - 1, lCursorX, AY + AFont.TextPixelHeight + 1);
    DrawText(fEditText, AX, AY, AFont);
  end
  else
    DrawText(AText, AX, AY, AFont);
end;""",
        "DrawEditableText implementation"
    ),
    (
        """procedure TOpenGLChartRenderer.DrawGrid(const ARect: TChartPixelRect; AXAxis, AYAxis: TChartAxis);
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
begin
  if not Assigned(AXAxis) or not Assigned(AYAxis) then
    Exit;

  BuildAxisTicks(AXAxis, 8, lXTicks);
  BuildAxisTicks(AYAxis, 8, lYTicks);

  SetGLColor($FFB8B8B8);
  glLineWidth(1.6);
  for lIndex := 0 to High(lXTicks) do
  begin
    lX := AxisValueToPixel(AXAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right);
    DrawLine(lX, ARect.Top, lX, ARect.Bottom);
  end;

  for lIndex := 0 to High(lYTicks) do
  begin
    lY := AxisValueToPixel(AYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
    DrawLine(ARect.Left, lY, ARect.Right, lY);
  end;
end;""",
        """procedure TOpenGLChartRenderer.DrawGrid(const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
begin
  BuildXTicks(APage, AYAxis, 8, lXTicks);
  if Assigned(AYAxis) then
    BuildAxisTicks(AYAxis, 8, lYTicks)
  else
    lYTicks := nil;

  SetGLColor($FFB8B8B8);
  glLineWidth(1.6);
  for lIndex := 0 to High(lXTicks) do
  begin
    lX := XValueToPixel(APage, AYAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right);
    DrawLine(lX, ARect.Top, lX, ARect.Bottom);
  end;

  for lIndex := 0 to High(lYTicks) do
  begin
    lY := AxisValueToPixel(AYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
    DrawLine(ARect.Left, lY, ARect.Right, lY);
  end;
end;""",
        "DrawGrid"
    ),
    (
        """procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
const
  CTick = 5;
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
  lXAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
begin
  lXAxis := FindAxis(APage, caoX);
  lYAxis := FindAxis(APage, caoY);
  if not Assigned(lXAxis) or not Assigned(lYAxis) then
    Exit;

  SetGLColor($FF303030);
  glLineWidth(2);
  DrawLine(ARect.Left, ARect.Bottom, ARect.Right, ARect.Bottom);
  DrawLine(ARect.Left, ARect.Top, ARect.Left, ARect.Bottom);

  SetGLColor($FF606060);
  glLineWidth(1.5);
  DrawRect(ARect);

  SetGLColor($FF404040);
  glLineWidth(1);

  BuildAxisTicks(lXAxis, 8, lXTicks);
  BuildAxisTicks(lYAxis, 8, lYTicks);

  for lIndex := 0 to High(lXTicks) do
  begin
    lX := AxisValueToPixel(lXAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right);
    DrawLine(lX, ARect.Bottom, lX, ARect.Bottom + CTick);
  end;

  for lIndex := 0 to High(lYTicks) do
  begin
    lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
    DrawLine(ARect.Left - CTick, lY, ARect.Left, lY);
  end;

  if Assigned(APage) and (APage.Caption <> '') then
    DrawText(APage.Caption, fPageRect.Left + 6, fPageRect.Top + 6, fFontMng.Font(cfPageCaption));

  lFont := fFontMng.Font(cfGridTick);
  for lIndex := 0 to High(lXTicks) do
  begin
    lText := lXTicks[lIndex].Text;
    lX := AxisValueToPixel(lXAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right) -
      lFont.TextPixelWidth(lText) / 2;
    if Abs(lXTicks[lIndex].Value - lXAxis.MinValue) < 1E-9 then
      DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lXAxis, celAxisMin)
    else if Abs(lXTicks[lIndex].Value - lXAxis.MaxValue) < 1E-9 then
      DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lXAxis, celAxisMax)
    else
      DrawText(lText, lX, ARect.Bottom + 7, lFont);
  end;

  for lIndex := 0 to High(lYTicks) do
  begin
    lText := lYTicks[lIndex].Text;
    lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
      lFont.TextPixelHeight / 2;
    if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
      DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, celAxisMin)
    else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
      DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, celAxisMax)
    else
      DrawText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont);
  end;
end;""",
        """procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
const
  CTick = 5;
var
  lIndex: Integer;
  I: Integer;
  lX: Single;
  lY: Single;
  lPrimaryAxis: TChartAxis;
  lYAxis: TChartAxis;
  lXTicks: TChartTickArray;
  lYTicks: TChartTickArray;
  lFont: cOglFont;
  lText: string;
begin
  lPrimaryAxis := GetPrimaryXAxis(APage);

  SetGLColor($FF303030);
  glLineWidth(2);
  DrawLine(ARect.Left, ARect.Bottom, ARect.Right, ARect.Bottom);
  DrawLine(ARect.Left, ARect.Top, ARect.Left, ARect.Bottom);

  SetGLColor($FF606060);
  glLineWidth(1.5);
  DrawRect(ARect);

  // Draw X ticks and labels
  BuildXTicks(APage, lPrimaryAxis, 8, lXTicks);

  SetGLColor($FF404040);
  glLineWidth(1);
  for lIndex := 0 to High(lXTicks) do
  begin
    lX := XValueToPixel(APage, lPrimaryAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right);
    DrawLine(lX, ARect.Bottom, lX, ARect.Bottom + CTick);
  end;

  if Assigned(APage) and (APage.Caption <> '') then
    DrawText(APage.Caption, fPageRect.Left + 6, fPageRect.Top + 6, fFontMng.Font(cfPageCaption));

  lFont := fFontMng.Font(cfGridTick);
  for lIndex := 0 to High(lXTicks) do
  begin
    lText := lXTicks[lIndex].Text;
    lX := XValueToPixel(APage, lPrimaryAxis, lXTicks[lIndex].Value, ARect.Left, ARect.Right) -
      lFont.TextPixelWidth(lText) / 2;
      
    if (Assigned(lPrimaryAxis) and lPrimaryAxis.UseOwnX) then
    begin
      if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lPrimaryAxis, nil, celXMin)
      else if Abs(lXTicks[lIndex].Value - lPrimaryAxis.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, lPrimaryAxis, nil, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lFont);
    end
    else
    begin
      if Abs(lXTicks[lIndex].Value - APage.XMinValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, nil, APage, celXMin)
      else if Abs(lXTicks[lIndex].Value - APage.XMaxValue) < 1E-9 then
        DrawEditableText(lText, lX, ARect.Bottom + 7, lFont, nil, APage, celXMax)
      else
        DrawText(lText, lX, ARect.Bottom + 7, lFont);
    end;
  end;

  // Draw all Y axes
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);

      SetGLColor($FF404040);
      glLineWidth(1);
      for lIndex := 0 to High(lYTicks) do
      begin
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        DrawLine(ARect.Left - CTick, lY, ARect.Left, lY);
      end;

      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
          lFont.TextPixelHeight / 2;
        if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
          DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMin)
        else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
          DrawEditableText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMax)
        else
          DrawText(lText, ARect.Left - lFont.TextPixelWidth(lText) - 7, lY, lFont);
      end;
    end;
end;""",
        "DrawAxes"
    ),
    (
        """procedure TOpenGLChartRenderer.DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect;
  AXAxis, AYAxis: TChartAxis);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX: Single;
  lY: Single;
begin
  if not Assigned(ASeries) or (ASeries.PointCount <= 0) or
    not Assigned(AXAxis) or not Assigned(AYAxis) then
    Exit;

  SetGLColor(ASeries.Color);
  glLineWidth(2.3);
  glBegin(GL_LINE_STRIP);
  for lIndex := 0 to ASeries.PointCount - 1 do
  begin
    lPoint := ASeries.Points[lIndex];
    lX := AxisValueToPixel(AXAxis, lPoint.X, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
    glVertex2f(lX, lY);
  end;
  glEnd;
end;""",
        """procedure TOpenGLChartRenderer.DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX: Single;
  lY: Single;
begin
  if not Assigned(ASeries) or (ASeries.PointCount <= 0) or not Assigned(AYAxis) then
    Exit;

  SetGLColor(ASeries.Color);
  glLineWidth(2.3);
  glBegin(GL_LINE_STRIP);
  for lIndex := 0 to ASeries.PointCount - 1 do
  begin
    lPoint := ASeries.Points[lIndex];
    lX := XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
    glVertex2f(lX, lY);
  end;
  glEnd;
end;""",
        "DrawLineSeries"
    ),
    (
        """procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
  AXAxis, AYAxis: TChartAxis);
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
begin
  if not Assigned(ATrend) or (ATrend.Count <= 0) or
    not Assigned(AXAxis) or not Assigned(AYAxis) then
    Exit;

  SetGLColor(ATrend.Color);
  glLineWidth(2.3);
  glBegin(GL_LINE_STRIP);
  for lIndex := 0 to ATrend.Count - 1 do
  begin
    lX := AxisValueToPixel(AXAxis, ATrend.X0 + lIndex * ATrend.DX, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, ATrend.Values[lIndex], ARect.Bottom, ARect.Top);
    glVertex2f(lX, lY);
  end;
  glEnd;
end;""",
        """procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
begin
  if not Assigned(ATrend) or (ATrend.Count <= 0) or not Assigned(AYAxis) then
    Exit;

  SetGLColor(ATrend.Color);
  glLineWidth(2.3);
  glBegin(GL_LINE_STRIP);
  for lIndex := 0 to ATrend.Count - 1 do
  begin
    lX := XValueToPixel(APage, AYAxis, ATrend.X0 + lIndex * ATrend.DX, ARect.Left, ARect.Right);
    lY := AxisValueToPixel(AYAxis, ATrend.Values[lIndex], ARect.Bottom, ARect.Top);
    glVertex2f(lX, lY);
  end;
  glEnd;
end;""",
        "DrawBuffTrend1d"
    ),
    (
        """procedure TOpenGLChartRenderer.RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect;
  AXAxis, AYAxis: TChartAxis);
var
  lIndex: Integer;
  lXAxis: TChartAxis;
  lYAxis: TChartAxis;
begin
  if not Assigned(AObject) then
    Exit;

  if (AObject is TChartDrawObject) and not TChartDrawObject(AObject).Visible then
    Exit;

  lXAxis := AXAxis;
  lYAxis := AYAxis;
  if AObject is TChartAxis then
  begin
    if TChartAxis(AObject).Orientation = caoX then
      lXAxis := TChartAxis(AObject)
    else
      lYAxis := TChartAxis(AObject);
  end;
  if (AObject is TChartSeries) and Assigned(TChartSeries(AObject).XAxis) then
    lXAxis := TChartSeries(AObject).XAxis;

  if AObject is cBuffTrend1d then
    DrawBuffTrend1d(cBuffTrend1d(AObject), ARect, lXAxis, lYAxis)
  else if AObject is TChartLineSeries then
    DrawLineSeries(TChartLineSeries(AObject), ARect, lXAxis, lYAxis);

  for lIndex := 0 to AObject.ChildCount - 1 do
    RenderObject(AObject.Children[lIndex], ARect, lXAxis, lYAxis);
end;""",
        """procedure TOpenGLChartRenderer.RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lYAxis: TChartAxis;
begin
  if not Assigned(AObject) then
    Exit;

  if (AObject is TChartDrawObject) and not TChartDrawObject(AObject).Visible then
    Exit;

  lYAxis := AYAxis;
  if AObject is TChartAxis then
    lYAxis := TChartAxis(AObject);

  if AObject is cBuffTrend1d then
    DrawBuffTrend1d(cBuffTrend1d(AObject), ARect, APage, lYAxis)
  else if AObject is TChartLineSeries then
    DrawLineSeries(TChartLineSeries(AObject), ARect, APage, lYAxis);

  for lIndex := 0 to AObject.ChildCount - 1 do
    RenderObject(AObject.Children[lIndex], ARect, APage, lYAxis);
end;""",
        "RenderObject"
    ),
    (
        """procedure TOpenGLChartRenderer.RenderPage(APage: TChartPage);
var
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lXAxis: TChartAxis;
  lYAxis: TChartAxis;
begin
  if not Assigned(APage) then
    Exit;
  if not APage.Visible then
    Exit;

  fPageRect := PageToPixelRect(APage);
  lContentRect := PageContentRect(APage);
  lXAxis := FindAxis(APage, caoX);
  lYAxis := FindAxis(APage, caoY);

  DrawPageFrame(APage, fPageRect);
  DrawGrid(lContentRect, lXAxis, lYAxis);
  DrawAxes(lContentRect, APage);

  glEnable(GL_SCISSOR_TEST);
  glScissor(lContentRect.Left, fHost.GetHeight - lContentRect.Bottom,
    Max(1, lContentRect.Right - lContentRect.Left),
    Max(1, lContentRect.Bottom - lContentRect.Top));
  for lIndex := 0 to APage.ChildCount - 1 do
    RenderObject(APage.Children[lIndex], lContentRect, lXAxis, lYAxis);
  glDisable(GL_SCISSOR_TEST);
end;""",
        """procedure TOpenGLChartRenderer.RenderPage(APage: TChartPage);
var
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lYAxis: TChartAxis;
begin
  if not Assigned(APage) then
    Exit;
  if not APage.Visible then
    Exit;

  fPageRect := PageToPixelRect(APage);
  lContentRect := PageContentRect(APage);
  lYAxis := GetPrimaryXAxis(APage);

  DrawPageFrame(APage, fPageRect);
  DrawGrid(lContentRect, APage, lYAxis);
  DrawAxes(lContentRect, APage);

  glEnable(GL_SCISSOR_TEST);
  glScissor(lContentRect.Left, fHost.GetHeight - lContentRect.Bottom,
    Max(1, lContentRect.Right - lContentRect.Left),
    Max(1, lContentRect.Bottom - lContentRect.Top));
  for lIndex := 0 to APage.ChildCount - 1 do
    RenderObject(APage.Children[lIndex], lContentRect, APage, nil);
  glDisable(GL_SCISSOR_TEST);
end;""",
        "RenderPage"
    ),
    (
        """  if TryStrToFloat(fEditText, lValue) then
    if fActiveHit.Kind = celAxisMin then
      fActiveHit.Axis.MinValue := lValue
    else if fActiveHit.Kind = celAxisMax then
      fActiveHit.Axis.MaxValue := lValue;""",
        """  if TryStrToFloat(fEditText, lValue) then
  begin
    if fActiveHit.Kind = celAxisMin then
      fActiveHit.Axis.MinValue := lValue
    else if fActiveHit.Kind = celAxisMax then
      fActiveHit.Axis.MaxValue := lValue
    else if fActiveHit.Kind = celXMin then
    begin
      if Assigned(fActiveHit.Axis) then
        fActiveHit.Axis.XMinValue := lValue
      else if Assigned(fActiveHit.Page) then
        fActiveHit.Page.XMinValue := lValue;
    end
    else if fActiveHit.Kind = celXMax then
    begin
      if Assigned(fActiveHit.Axis) then
        fActiveHit.Axis.XMaxValue := lValue
      else if Assigned(fActiveHit.Page) then
        fActiveHit.Page.XMaxValue := lValue;
    end;
  end;""",
        "KeyDown and TextInput updates"
    )
]
process_file(r'C:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas', renderer_reps)

# ----------------- unit1.pas -----------------
unit1_reps = [
    (
        """function AxisOrientationToText(AOrientation: TChartAxisOrientation): string;
begin
  case AOrientation of
    caoX: Result := 'X';
    caoY: Result := 'Y';
  else
    Result := '?';
  end;
end;""",
        "",
        "AxisOrientationToText deletion"
    ),
    (
        """  if AObject is cAxis then
  begin
    lAxis := cAxis(AObject);
    Result := Result + Format(' [%s, %s, %.4g..%.4g]', [
      AxisOrientationToText(lAxis.Orientation),
      AxisScaleToText(lAxis.Scale),
      lAxis.MinValue,
      lAxis.MaxValue
    ]);
  end""",
        """  if AObject is cAxis then
  begin
    lAxis := cAxis(AObject);
    Result := Result + Format(' [%s, %.4g..%.4g]', [
      AxisScaleToText(lAxis.Scale),
      lAxis.MinValue,
      lAxis.MaxValue
    ]);
    if lAxis.UseOwnX then
      Result := Result + Format(' [OwnX: %s, %.4g..%.4g]', [
        AxisScaleToText(lAxis.XScale),
        lAxis.XMinValue,
        lAxis.XMaxValue
      ]);
  end""",
        "ChartObjectTreeText"
    ),
    (
        """procedure AddAxisPair(APage: cBasePage; const ANamePrefix: string; out AXAxis, AYAxis: cAxis);
begin
  AXAxis := cAxis.Create;
  AXAxis.Name := ANamePrefix + 'AxisX';
  AXAxis.Caption := ANamePrefix + ' X';
  AXAxis.Orientation := caoX;
  APage.AddChild(AXAxis);

  AYAxis := cAxis.Create;
  AYAxis.Name := ANamePrefix + 'AxisY';
  AYAxis.Caption := ANamePrefix + ' Y';
  AYAxis.Orientation := caoY;
  APage.AddChild(AYAxis);
end;""",
        """procedure AddAxis(APage: cBasePage; const ANamePrefix: string; out AYAxis: cAxis);
begin
  AYAxis := cAxis.Create;
  AYAxis.Name := ANamePrefix + 'AxisY';
  AYAxis.Caption := ANamePrefix + ' Y';
  APage.AddChild(AYAxis);
end;""",
        "AddAxisPair to AddAxis"
    ),
    (
        """function AddLine(AYAxis, AXAxis: cAxis; const AName, ACaption: string; AColor: Cardinal): cTrend;
begin
  Result := cTrend.Create;
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Color := AColor;
  Result.XAxis := AXAxis;
  AYAxis.AddChild(Result);
end;""",
        """function AddLine(AYAxis: cAxis; const AName, ACaption: string; AColor: Cardinal): cTrend;
begin
  Result := cTrend.Create;
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Color := AColor;
  AYAxis.AddChild(Result);
end;""",
        "AddLine signature and XAxis usage"
    ),
    (
        """procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisX: cAxis;
  lAxisY: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
begin
  AChart.ObjectManager.Clear;
  AChart.Model.BackgroundColor := $FFFFFFFF;

  lPage := AddPage(AChart.Model, 'PageTrend', 'Page_Trend');
  AddAxisPair(lPage, 'Trend', lAxisX, lAxisY);
  lAxisX.MinValue := 0;
  lAxisX.MaxValue := 11;
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lSeries := AddLine(lAxisY, lAxisX, 'TrendLine', 'Trend line', $FF303030);""",
        """procedure CreateTestChart(AChart: TOglChart);
var
  lPage: cBasePage;
  lAxisY: cAxis;
  lSeries: cTrend;
  lBuff: cBuffTrend1d;
begin
  AChart.ObjectManager.Clear;
  AChart.Model.BackgroundColor := $FFFFFFFF;

  lPage := AddPage(AChart.Model, 'PageTrend', 'Page_Trend');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 11;
  AddAxis(lPage, 'Trend', lAxisY);
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lSeries := AddLine(lAxisY, 'TrendLine', 'Trend line', $FF303030);""",
        "CreateTestChart Trend page"
    ),
    (
        """  lPage := AddPage(AChart.Model, 'PageSignals', 'Page_Signals');
  AddAxisPair(lPage, 'Signals', lAxisX, lAxisY);
  lAxisX.MinValue := 0;
  lAxisX.MaxValue := 9;
  lAxisY.MinValue := 0.4;
  lAxisY.MaxValue := 0.75;
  lSeries := AddLine(lAxisY, lAxisX, 'SignalBlue', 'Signal blue', $FFFF0000);""",
        """  lPage := AddPage(AChart.Model, 'PageSignals', 'Page_Signals');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 9;
  AddAxis(lPage, 'Signals', lAxisY);
  lAxisY.MinValue := 0.4;
  lAxisY.MaxValue := 0.75;
  lSeries := AddLine(lAxisY, 'SignalBlue', 'Signal blue', $FFFF0000);""",
        "CreateTestChart Signals page"
    ),
    (
        """  lSeries := AddLine(lAxisY, lAxisX, 'SignalRed', 'Signal red', $FF0000FF);""",
        """  lSeries := AddLine(lAxisY, 'SignalRed', 'Signal red', $FF0000FF);""",
        "CreateTestChart SignalRed"
    ),
    (
        """  lPage := AddPage(AChart.Model, 'PageBars', 'Page_Bars');
  AddAxisPair(lPage, 'Bars', lAxisX, lAxisY);
  lAxisX.MinValue := 0;
  lAxisX.MaxValue := 9;
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lBuff := cBuffTrend1d.Create;
  lBuff.Name := 'BottomBuff1d';
  lBuff.Caption := 'Bottom buffer 1D';
  lBuff.Color := $FF0090D0;
  lBuff.XAxis := lAxisX;
  lBuff.X0 := 0;
  lBuff.DX := 1;
  lBuff.AddValue(0.32);
  lBuff.AddValue(0.44);
  lBuff.AddValue(0.37);
  lBuff.AddValue(0.61);
  lBuff.AddValue(0.52);
  lBuff.AddValue(0.58);
  lBuff.AddValue(0.71);
  lBuff.AddValue(0.64);
  lBuff.AddValue(0.69);
  lBuff.AddValue(0.80);
  lAxisY.AddChild(lBuff);""",
        """  lPage := AddPage(AChart.Model, 'PageBars', 'Page_Bars');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 9;
  AddAxis(lPage, 'Bars', lAxisY);
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 1;
  lBuff := cBuffTrend1d.Create;
  lBuff.Name := 'BottomBuff1d';
  lBuff.Caption := 'Bottom buffer 1D';
  lBuff.Color := $FF0090D0;
  lBuff.X0 := 0;
  lBuff.DX := 1;
  lBuff.AddValue(0.32);
  lBuff.AddValue(0.44);
  lBuff.AddValue(0.37);
  lBuff.AddValue(0.61);
  lBuff.AddValue(0.52);
  lBuff.AddValue(0.58);
  lBuff.AddValue(0.71);
  lBuff.AddValue(0.64);
  lBuff.AddValue(0.69);
  lBuff.AddValue(0.80);
  lAxisY.AddChild(lBuff);

  lPage := AddPage(AChart.Model, 'PageOwnX', 'Page_OwnX');
  lPage.XMinValue := 0;
  lPage.XMaxValue := 10;
  AddAxis(lPage, 'OwnX', lAxisY);
  lAxisY.MinValue := 0;
  lAxisY.MaxValue := 100;
  lAxisY.UseOwnX := True;
  lAxisY.XMinValue := 50;
  lAxisY.XMaxValue := 150;
  lAxisY.XScale := casLinear;
  lSeries := AddLine(lAxisY, 'OwnXLine', 'Own X line', $FF00FF00);
  lSeries.AddPoint(60, 10);
  lSeries.AddPoint(80, 50);
  lSeries.AddPoint(100, 30);
  lSeries.AddPoint(120, 90);
  lSeries.AddPoint(140, 70);""",
        "CreateTestChart Bars page"
    )
]
process_file(r'C:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas', unit1_reps)

print("All modifications completed successfully without line ending duplication.")
