unit uOglChartRenderer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, gl, uOglChartTypes, uOglChartBaseObj,
  uOglChartDrawObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, uOglChartFontMng;

type
  TChartEditLabelKind = (celNone, celAxisMin, celAxisMax);

  TChartTextHit = record
    Rect: TChartPixelRect;
    Axis: TChartAxis;
    Kind: TChartEditLabelKind;
    Text: string;
    TextLeft: Integer;
    Font: cOglFont;
  end;

  TChartTick = record
    Value: Double;
    Text: string;
  end;
  TChartTickArray = array of TChartTick;

  { TOpenGLChartRenderer - OpenGL-рендер дерева модели графика. }
  TOpenGLChartRenderer = class(TInterfacedObject, IChartRenderer)
  private
    fHost: IOpenGLContextHost;
    fPageRect: TChartPixelRect;
    fFontMng: cOglFontMng;
    fTextHits: array of TChartTextHit;
    fActiveHit: TChartTextHit;
    fEditText: string;
    fEditCursor: Integer;
    fEditSelectionStart: Integer;
    fEditSelectionLength: Integer;

    procedure Apply2DView;
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
    procedure RenderPage(APage: TChartPage);
  public
    destructor Destroy; override;
    procedure Initialize(AHost: IOpenGLContextHost);
    procedure Resize(AWidth, AHeight: Integer);
    procedure Render(AModel: TObject);
    function MouseDown(AX, AY: Integer): Boolean;
    function KeyDown(AKey: Word): Boolean;
    function TextInput(const AText: string): Boolean;
  end;

implementation

const
  VK_BACK = 8;
  VK_DELETE = 46;
  VK_LEFT = 37;
  VK_RIGHT = 39;
  VK_HOME = 36;
  VK_END = 35;

{ TOpenGLChartRenderer }

destructor TOpenGLChartRenderer.Destroy;
begin
  fFontMng.Free;
  inherited Destroy;
end;

procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

procedure TOpenGLChartRenderer.Resize(AWidth, AHeight: Integer);
begin
  if AHeight = 0 then
    AHeight := 1;
  glViewport(0, 0, AWidth, AHeight);
end;

function TOpenGLChartRenderer.FindAxis(APage: TChartPage; AOrientation: TChartAxisOrientation): TChartAxis;
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
end;

function TOpenGLChartRenderer.NiceStep(ARange: Double; ATargetCount: Integer): Double;
var
  lRawStep: Double;
  lPower: Double;
  lFraction: Double;
begin
  if (ARange <= 0) or (ATargetCount <= 0) then
    Exit(1);

  lRawStep := ARange / ATargetCount;
  lPower := Power(10, Floor(Log10(lRawStep)));
  lFraction := lRawStep / lPower;

  if lFraction <= 1 then
    Result := 1 * lPower
  else if lFraction <= 2 then
    Result := 2 * lPower
  else if lFraction <= 5 then
    Result := 5 * lPower
  else
    Result := 10 * lPower;
end;

function TOpenGLChartRenderer.FormatTick(AValue, AStep: Double): string;
var
  lDigits: Integer;
begin
  if AStep >= 1 then
    lDigits := 0
  else
    lDigits := Min(6, Max(0, Ceil(-Log10(AStep))));
  Result := FormatFloat('0.' + StringOfChar('0', lDigits), AValue);
end;

procedure TOpenGLChartRenderer.BuildLinearTicks(AMin, AMax: Double; ATargetCount: Integer; out ATicks: TChartTickArray);
var
  lStep: Double;
  lValue: Double;
  lIndex: Integer;
  lOriginalMin: Double;
  lOriginalMax: Double;
begin
  ATicks := nil;
  if AMax = AMin then
    AMax := AMin + 1;
  if AMax < AMin then
  begin
    lValue := AMin;
    AMin := AMax;
    AMax := lValue;
  end;

  lOriginalMin := AMin;
  lOriginalMax := AMax;
  lStep := NiceStep(AMax - AMin, ATargetCount);
  lValue := Ceil(AMin / lStep) * lStep;
  lIndex := 0;
  SetLength(ATicks, 1);
  ATicks[0].Value := lOriginalMin;
  ATicks[0].Text := FormatTick(lOriginalMin, lStep);
  lIndex := 1;

  while lValue <= AMax + lStep * 0.5 do
  begin
    if (Abs(lValue - lOriginalMin) > lStep * 1E-6) and
      (Abs(lValue - lOriginalMax) > lStep * 1E-6) then
    begin
      SetLength(ATicks, lIndex + 1);
      ATicks[lIndex].Value := lValue;
      ATicks[lIndex].Text := FormatTick(lValue, lStep);
      Inc(lIndex);
    end;
    lValue := lValue + lStep;
  end;

  if Abs(lOriginalMax - lOriginalMin) > lStep * 1E-6 then
  begin
    SetLength(ATicks, lIndex + 1);
    ATicks[lIndex].Value := lOriginalMax;
    ATicks[lIndex].Text := FormatTick(lOriginalMax, lStep);
  end;
end;

procedure TOpenGLChartRenderer.BuildLogTicks(AMin, AMax: Double; out ATicks: TChartTickArray);
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
end;

procedure TOpenGLChartRenderer.BuildAxisTicks(AAxis: TChartAxis; ATargetCount: Integer; out ATicks: TChartTickArray);
begin
  if Assigned(AAxis) and (AAxis.Scale = casLog10) then
    BuildLogTicks(AAxis.MinValue, AAxis.MaxValue, ATicks)
  else if Assigned(AAxis) then
    BuildLinearTicks(AAxis.MinValue, AAxis.MaxValue, ATargetCount, ATicks)
  else
    ATicks := nil;
end;

function TOpenGLChartRenderer.ValueToPixel(AValue, AMin, AMax: Double; APixelMin, APixelMax: Single): Single;
begin
  if AMax = AMin then
    Exit((APixelMin + APixelMax) / 2);
  Result := APixelMin + (APixelMax - APixelMin) * ((AValue - AMin) / (AMax - AMin));
end;

function TOpenGLChartRenderer.AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
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

procedure TOpenGLChartRenderer.Apply2DView;
begin
  glViewport(0, 0, fHost.GetWidth, fHost.GetHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0, fHost.GetWidth, fHost.GetHeight, 0, -1, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TOpenGLChartRenderer.SetGLColor(AColor: Cardinal);
begin
  glColor4f(
    (AColor and $000000FF) / 255,
    ((AColor and $0000FF00) shr 8) / 255,
    ((AColor and $00FF0000) shr 16) / 255,
    ((AColor and $FF000000) shr 24) / 255
  );
end;

function TOpenGLChartRenderer.PageContentRect(APage: TChartPage): TChartPixelRect;
begin
  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left;
  Result.Top := fPageRect.Top + APage.PixelTabSpace.Top;
  Result.Right := fPageRect.Right - APage.PixelTabSpace.Right;
  Result.Bottom := fPageRect.Bottom - APage.PixelTabSpace.Bottom;

  if Result.Right < Result.Left + 20 then
    Result.Right := Result.Left + 20;
  if Result.Bottom < Result.Top + 20 then
    Result.Bottom := Result.Top + 20;
end;

function TOpenGLChartRenderer.PageToPixelRect(APage: TChartPage): TChartPixelRect;
begin
  Result.Left := Round(APage.FloatRect.Left * fHost.GetWidth);
  Result.Top := Round(APage.FloatRect.Top * fHost.GetHeight);
  Result.Right := Round(APage.FloatRect.Right * fHost.GetWidth);
  Result.Bottom := Round(APage.FloatRect.Bottom * fHost.GetHeight);

  if Result.Right < Result.Left + 80 then
    Result.Right := Result.Left + 80;
  if Result.Bottom < Result.Top + 60 then
    Result.Bottom := Result.Top + 60;
end;

procedure TOpenGLChartRenderer.DrawLine(AX1, AY1, AX2, AY2: Single);
begin
  glBegin(GL_LINES);
  glVertex2f(AX1, AY1);
  glVertex2f(AX2, AY2);
  glEnd;
end;

procedure TOpenGLChartRenderer.DrawRect(const ARect: TChartPixelRect);
begin
  glBegin(GL_LINE_LOOP);
  glVertex2f(ARect.Left, ARect.Top);
  glVertex2f(ARect.Right, ARect.Top);
  glVertex2f(ARect.Right, ARect.Bottom);
  glVertex2f(ARect.Left, ARect.Bottom);
  glEnd;
end;

procedure TOpenGLChartRenderer.FillRect(const ARect: TChartPixelRect);
begin
  glBegin(GL_QUADS);
  glVertex2f(ARect.Left, ARect.Top);
  glVertex2f(ARect.Right, ARect.Top);
  glVertex2f(ARect.Right, ARect.Bottom);
  glVertex2f(ARect.Left, ARect.Bottom);
  glEnd;
end;

function GlyphRow(AChar: Char; ARow: Integer): string;
begin
  Result := '00000';
  case UpCase(AChar) of
    'A': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11111'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'B': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    'C': case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10000'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '01111'; end;
    'D': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '11110'; end;
    'E': case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '11111'; end;
    'F': case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '10000'; end;
    'G': case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10011'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01111'; end;
    'H': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11111'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'I': case ARow of 0: Result := '11111'; 1: Result := '00100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '11111'; end;
    'J': case ARow of 0: Result := '00111'; 1: Result := '00010'; 2: Result := '00010'; 3: Result := '00010'; 4: Result := '10010'; 5: Result := '10010'; 6: Result := '01100'; end;
    'K': case ARow of 0: Result := '10001'; 1: Result := '10010'; 2: Result := '10100'; 3: Result := '11000'; 4: Result := '10100'; 5: Result := '10010'; 6: Result := '10001'; end;
    'L': case ARow of 0: Result := '10000'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '10000'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '11111'; end;
    'M': case ARow of 0: Result := '10001'; 1: Result := '11011'; 2: Result := '10101'; 3: Result := '10101'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'N': case ARow of 0: Result := '10001'; 1: Result := '11001'; 2: Result := '10101'; 3: Result := '10011'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '10001'; end;
    'O': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    'P': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10000'; 5: Result := '10000'; 6: Result := '10000'; end;
    'Q': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10101'; 5: Result := '10010'; 6: Result := '01101'; end;
    'R': case ARow of 0: Result := '11110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '11110'; 4: Result := '10100'; 5: Result := '10010'; 6: Result := '10001'; end;
    'S': case ARow of 0: Result := '01111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '01110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    'T': case ARow of 0: Result := '11111'; 1: Result := '00100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '00100'; end;
    'U': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    'V': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10001'; 4: Result := '01010'; 5: Result := '01010'; 6: Result := '00100'; end;
    'W': case ARow of 0: Result := '10001'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '10101'; 4: Result := '10101'; 5: Result := '10101'; 6: Result := '01010'; end;
    'X': case ARow of 0: Result := '10001'; 1: Result := '01010'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '01010'; 6: Result := '10001'; end;
    'Y': case ARow of 0: Result := '10001'; 1: Result := '01010'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '00100'; end;
    'Z': case ARow of 0: Result := '11111'; 1: Result := '00001'; 2: Result := '00010'; 3: Result := '00100'; 4: Result := '01000'; 5: Result := '10000'; 6: Result := '11111'; end;
    '0': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10011'; 3: Result := '10101'; 4: Result := '11001'; 5: Result := '10001'; 6: Result := '01110'; end;
    '1': case ARow of 0: Result := '00100'; 1: Result := '01100'; 2: Result := '00100'; 3: Result := '00100'; 4: Result := '00100'; 5: Result := '00100'; 6: Result := '01110'; end;
    '2': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '00001'; 3: Result := '00010'; 4: Result := '00100'; 5: Result := '01000'; 6: Result := '11111'; end;
    '3': case ARow of 0: Result := '11110'; 1: Result := '00001'; 2: Result := '00001'; 3: Result := '01110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    '4': case ARow of 0: Result := '00010'; 1: Result := '00110'; 2: Result := '01010'; 3: Result := '10010'; 4: Result := '11111'; 5: Result := '00010'; 6: Result := '00010'; end;
    '5': case ARow of 0: Result := '11111'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '11110'; end;
    '6': case ARow of 0: Result := '01110'; 1: Result := '10000'; 2: Result := '10000'; 3: Result := '11110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    '7': case ARow of 0: Result := '11111'; 1: Result := '00001'; 2: Result := '00010'; 3: Result := '00100'; 4: Result := '01000'; 5: Result := '01000'; 6: Result := '01000'; end;
    '8': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '01110'; 4: Result := '10001'; 5: Result := '10001'; 6: Result := '01110'; end;
    '9': case ARow of 0: Result := '01110'; 1: Result := '10001'; 2: Result := '10001'; 3: Result := '01111'; 4: Result := '00001'; 5: Result := '00001'; 6: Result := '01110'; end;
    '.': if ARow = 6 then Result := '00100';
    '-': if ARow = 3 then Result := '01110';
    '_': if ARow = 6 then Result := '11111';
  end;
end;

procedure TOpenGLChartRenderer.AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont;
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
end;

procedure TOpenGLChartRenderer.DrawTextSelection(AX, AY: Single; AFont: cOglFont; AStartIndex, ALength: Integer);
var
  lRect: TChartPixelRect;
begin
  if not Assigned(AFont) or (ALength <= 0) then
    Exit;
  lRect.Left := Round(AX + AFont.TextPixelWidth(Copy(fEditText, 1, AStartIndex - 1)));
  lRect.Top := Round(AY - 1);
  lRect.Right := Round(lRect.Left + AFont.TextPixelWidth(Copy(fEditText, AStartIndex, ALength)));
  lRect.Bottom := Round(AY + AFont.TextPixelHeight + 1);
  SetGLColor($553C7DFF);
  FillRect(lRect);
end;

procedure TOpenGLChartRenderer.DrawText(const AText: string; AX, AY: Single; AFont: cOglFont);
var
  I: Integer;
  lRow: Integer;
  lCol: Integer;
  lGlyphRow: string;
  lX: Single;
  lY: Single;
  lScale: Single;
  lAdvanceX: Single;
begin
  if not Assigned(AFont) then
    Exit;
  lScale := AFont.Scale;
  SetGLColor(AFont.Color);
  glBegin(GL_QUADS);
  for I := 1 to Length(AText) do
    for lRow := 0 to 6 do
    begin
      lGlyphRow := GlyphRow(AText[I], lRow);
      for lCol := 1 to Length(lGlyphRow) do
        if lGlyphRow[lCol] = '1' then
        begin
          lAdvanceX := AFont.TextPixelWidth(Copy(AText, 1, I - 1));
          lX := AX + lAdvanceX + (lCol - 1) * lScale;
          lY := AY + lRow * lScale;
          glVertex2f(lX, lY);
          glVertex2f(lX + lScale, lY);
          glVertex2f(lX + lScale, lY + lScale);
          glVertex2f(lX, lY + lScale);
          if AFont.Bold then
          begin
            glVertex2f(lX + 1, lY);
            glVertex2f(lX + lScale + 1, lY);
            glVertex2f(lX + lScale + 1, lY + lScale);
            glVertex2f(lX + 1, lY + lScale);
          end;
        end;
    end;
  glEnd;
end;

procedure TOpenGLChartRenderer.DrawEditableText(const AText: string; AX, AY: Single; AFont: cOglFont;
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
end;

procedure TOpenGLChartRenderer.DrawGrid(const ARect: TChartPixelRect; AXAxis, AYAxis: TChartAxis);
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
end;

procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
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
end;

procedure TOpenGLChartRenderer.DrawPageFrame(APage: TChartPage; const ARect: TChartPixelRect);
begin
  SetGLColor(APage.FillColor);
  FillRect(ARect);
  if Assigned(APage) and APage.Selected then
    SetGLColor($FF3C7DFF)
  else
    SetGLColor(APage.BorderColor);
  glLineWidth(APage.BorderWidth);
  DrawRect(ARect);
end;

procedure TOpenGLChartRenderer.DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect;
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
end;

procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
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
end;

procedure TOpenGLChartRenderer.RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect;
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
end;

procedure TOpenGLChartRenderer.RenderPage(APage: TChartPage);
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
end;

procedure TOpenGLChartRenderer.Render(AModel: TObject);
var
  lColor: Cardinal;
  r: Single;
  g: Single;
  b: Single;
  a: Single;
  lModel: TChartModel;
  lIndex: Integer;
begin
  if not Assigned(AModel) or not (AModel is TChartModel) then
    Exit;

  lModel := TChartModel(AModel);
  lColor := lModel.BackgroundColor;
  r := (lColor and $000000FF) / 255;
  g := ((lColor and $0000FF00) shr 8) / 255;
  b := ((lColor and $00FF0000) shr 16) / 255;
  a := ((lColor and $FF000000) shr 24) / 255;

  glClearColor(r, g, b, a);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  Apply2DView;
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_TEXTURE_2D);
  SetLength(fTextHits, 0);

  lModel.AlignPagesAuto(fHost.GetWidth / Max(1, fHost.GetHeight));
  for lIndex := 0 to lModel.ChildCount - 1 do
    if lModel.Children[lIndex] is TChartPage then
      RenderPage(TChartPage(lModel.Children[lIndex]));
end;

function TOpenGLChartRenderer.MouseDown(AX, AY: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  fActiveHit.Axis := nil;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
      (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      fActiveHit := fTextHits[I];
      fEditText := fTextHits[I].Text;
      fEditCursor := fTextHits[I].Font.HitCharIndex(fEditText, AX, fTextHits[I].TextLeft);
      fEditSelectionStart := fEditCursor;
      fEditSelectionLength := 1;
      Result := True;
      Exit;
    end;
end;

function TOpenGLChartRenderer.KeyDown(AKey: Word): Boolean;
var
  lValue: Double;
begin
  Result := Assigned(fActiveHit.Axis);
  if not Result then
    Exit;

  case AKey of
    VK_BACK:
      if fEditCursor > 1 then
      begin
        Delete(fEditText, fEditCursor - 1, 1);
        Dec(fEditCursor);
      end;
    VK_DELETE:
      if fEditCursor <= Length(fEditText) then
        Delete(fEditText, fEditCursor, 1);
    VK_LEFT:
      fEditCursor := Max(1, fEditCursor - 1);
    VK_RIGHT:
      fEditCursor := Min(Length(fEditText) + 1, fEditCursor + 1);
    VK_HOME:
      fEditCursor := 1;
    VK_END:
      fEditCursor := Length(fEditText) + 1;
    else
      Exit(False);
  end;

  fEditSelectionStart := fEditCursor;
  fEditSelectionLength := 0;
  if TryStrToFloat(fEditText, lValue) then
    if fActiveHit.Kind = celAxisMin then
      fActiveHit.Axis.MinValue := lValue
    else if fActiveHit.Kind = celAxisMax then
      fActiveHit.Axis.MaxValue := lValue;
end;

function TOpenGLChartRenderer.TextInput(const AText: string): Boolean;
var
  lValue: Double;
  lChar: Char;
begin
  Result := Assigned(fActiveHit.Axis);
  if not Result or (AText = '') then
    Exit;

  lChar := AText[1];
  if not (lChar in ['0'..'9', '-', '+', '.', ',']) then
    Exit(False);

  if lChar = ',' then
    lChar := '.';

  if fEditSelectionLength > 0 then
  begin
    Delete(fEditText, fEditSelectionStart, fEditSelectionLength);
    fEditCursor := fEditSelectionStart;
  end;
  Insert(lChar, fEditText, fEditCursor);
  Inc(fEditCursor);
  fEditSelectionStart := fEditCursor;
  fEditSelectionLength := 0;

  if TryStrToFloat(fEditText, lValue) then
    if fActiveHit.Kind = celAxisMin then
      fActiveHit.Axis.MinValue := lValue
    else if fActiveHit.Kind = celAxisMax then
      fActiveHit.Axis.MaxValue := lValue;
end;

end.
