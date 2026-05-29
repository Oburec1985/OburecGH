unit uOglChartRenderer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, gl, glext, uOglChartTypes, uOglChartBaseObj,
  uOglChartDrawObj, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartChart, uOglChartFontMng;

type
  TChartEditLabelKind = (celNone, celAxisMin, celAxisMax, celXMin, celXMax);

  TChartTextHit = record
    Rect: TChartPixelRect;
    Axis: TChartAxis;
    Page: TChartPage;
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
    fUseShader: Boolean;
    fProgram: GLuint;
    fProgram1d: GLuint;
    fShaderInitialized: Boolean;
    procedure InitShaders;
    fPageRect: TChartPixelRect;
    fFontMng: cOglFontMng;
    fTextHits: array of TChartTextHit;
    fActiveHit: TChartTextHit;
    fEditText: string;
    fEditCursor: Integer;
    fEditSelectionStart: Integer;
    fEditSelectionLength: Integer;
    fSelectedObject: TChartBaseObject;
    fHoveredObject: TChartBaseObject;
    fSelectionRectActive: Boolean;
    fSelectionRect: TChartPixelRect;

    procedure Apply2DView;
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
    procedure DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
    procedure RenderPage(APage: TChartPage);
    procedure DrawHighlights;
    procedure DrawHighlightRect(const ARect: TChartPixelRect; AColor: Cardinal);
  public
    destructor Destroy; override;
    function GetPageRect(APage: TChartPage): TChartPixelRect;
    function GetPageContentRect(APage: TChartPage): TChartPixelRect;
    function GetTextHitAt(AX, AY: Integer; out AHit: TChartTextHit): Boolean;
    function PixelToXValue(APage: TChartPage; AAxis: TChartAxis; APixelX, ALeft, ARight: Single): Double;
    function PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;
    function GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;
    function AxisValueToPixel(AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;
    function XValueToPixel(APage: TChartPage; AAxis: TChartAxis; AValue: Double; APixelMin, APixelMax: Single): Single;

    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;
    property HoveredObject: TChartBaseObject read fHoveredObject write fHoveredObject;
    property SelectionRectActive: Boolean read fSelectionRectActive write fSelectionRectActive;
    property SelectionRect: TChartPixelRect read fSelectionRect write fSelectionRect;
    procedure Initialize(AHost: IOpenGLContextHost);
    procedure Resize(AWidth, AHeight: Integer);
    procedure Render(AModel: TObject);
    function MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;
    function KeyDown(AKey: Word): Boolean;
    function TextInput(const AText: string): Boolean;
  end;

implementation

procedure LogToFile(const AMsg: string);
var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;
end;

const
  SHADER_LINE_LG_VERT = 
    'uniform vec4 a_minmax;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(x)/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range, test;'#10 +
    '  gl_Position = gl_Vertex;'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg[0] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[1]);'#10 +
    '    if (a_minmax[0] <= 0.0) lgMin = -12.0;'#10 +
    '    else lgMin = Log10(a_minmax[0]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[1] - a_minmax[0];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[0] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[0] = a_minmax[0] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[0]) - lgMin) * lgRange;'#10 +
    '      gl_Position[0] = range * rate + a_minmax[0];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  if (a_Lg[1] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[3]);'#10 +
    '    if (a_minmax[2] <= 0.0) lgMin = -12.0;'#10 +
    '    else lgMin = Log10(a_minmax[2]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[3] - a_minmax[2];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[1] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[1] = a_minmax[2] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[1]) - lgMin) * lgRange;'#10 +
    '      gl_Position[1] = range * rate + a_minmax[2];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;'#10 +
    '}';

  SHADER_LINE_LG_1D_VERT = 
    '#version 130'#10 +
    'uniform vec4 a_minmax;'#10 +
    'uniform vec2 a_LinePar;'#10 +
    'uniform ivec2 a_Lg;'#10 +
    'float Log10(float x) {'#10 +
    '  x = log2(x)/log2(10.0);'#10 +
    '  return(x);'#10 +
    '}'#10 +
    'void main() {'#10 +
    '  float rate, lgMax, lgMin, lgRange, range, test;'#10 +
    '  gl_Position = gl_Vertex;'#10 +
    '  gl_Position[0] = a_LinePar[0] + a_LinePar[1] * float(gl_VertexID);'#10 +
    '  gl_Position[1] = gl_Vertex[0];'#10 +
    '  gl_FrontColor = gl_Color;'#10 +
    '  if (a_Lg[0] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[1]);'#10 +
    '    if (a_minmax[0] <= 0.0) lgMin = -12.0;'#10 +
    '    else lgMin = Log10(a_minmax[0]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[1] - a_minmax[0];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[0] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[0] = a_minmax[0] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[0]) - lgMin) * lgRange;'#10 +
    '      gl_Position[0] = range * rate + a_minmax[0];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  if (a_Lg[1] == 1) {'#10 +
    '    lgMax = Log10(a_minmax[3]);'#10 +
    '    if (a_minmax[2] <= 0.0) lgMin = -12.0;'#10 +
    '    else lgMin = Log10(a_minmax[2]);'#10 +
    '    lgRange = lgMax - lgMin;'#10 +
    '    range = a_minmax[3] - a_minmax[2];'#10 +
    '    lgRange = 1.0 / lgRange;'#10 +
    '    if (gl_Position[1] <= 0.0) {'#10 +
    '      rate = 0.0;'#10 +
    '      gl_Position[1] = a_minmax[2] - 200.0;'#10 +
    '    } else {'#10 +
    '      rate = (Log10(gl_Position[1]) - lgMin) * lgRange;'#10 +
    '      gl_Position[1] = range * rate + a_minmax[2];'#10 +
    '    }'#10 +
    '  }'#10 +
    '  gl_Position = gl_ModelViewProjectionMatrix * gl_Position;'#10 +
    '}';

function CreateShader(AShaderType: GLenum; const ASource: string): GLuint;
var
  lShader: GLuint;
  lStatus: GLint;
  lLogLen: GLint;
  lLog: string;
  lSourcePtr: PAnsiChar;
  lSourceLen: GLint;
begin
  lShader := glCreateShader(AShaderType);
  lSourcePtr := PAnsiChar(ASource);
  lSourceLen := Length(ASource);
  glShaderSource(lShader, 1, @lSourcePtr, @lSourceLen);
  glCompileShader(lShader);
  
  glGetShaderiv(lShader, GL_COMPILE_STATUS, @lStatus);
  if lStatus = GL_FALSE then
  begin
    glGetShaderiv(lShader, GL_INFO_LOG_LENGTH, @lLogLen);
    SetLength(lLog, lLogLen);
    glGetShaderInfoLog(lShader, lLogLen, nil, PAnsiChar(lLog));
    LogToFile('Shader compile error: ' + lLog);
    glDeleteShader(lShader);
    Exit(0);
  end;
  Result := lShader;
end;

function CreateProgram(AVertexSource: string): GLuint;
var
  lVertexShader: GLuint;
  lProgram: GLuint;
  lStatus: GLint;
  lLogLen: GLint;
  lLog: string;
begin
  Result := 0;
  lVertexShader := CreateShader(GL_VERTEX_SHADER, AVertexSource);
  if lVertexShader = 0 then Exit;
  
  lProgram := glCreateProgram();
  glAttachShader(lProgram, lVertexShader);
  glLinkProgram(lProgram);
  
  glGetProgramiv(lProgram, GL_LINK_STATUS, @lStatus);
  if lStatus = GL_FALSE then
  begin
    glGetProgramiv(lProgram, GL_INFO_LOG_LENGTH, @lLogLen);
    SetLength(lLog, lLogLen);
    glGetProgramInfoLog(lProgram, lLogLen, nil, PAnsiChar(lLog));
    LogToFile('Program link error: ' + lLog);
    glDeleteProgram(lProgram);
    glDeleteShader(lVertexShader);
    Exit;
  end;
  
  glDeleteShader(lVertexShader);
  Result := lProgram;
end;

const
  VK_BACK = 8;
  VK_DELETE = 46;
  VK_LEFT = 37;
  VK_RIGHT = 39;
  VK_HOME = 36;
  VK_END = 35;

{ TOpenGLChartRenderer }

procedure TOpenGLChartRenderer.InitShaders;
begin
  fShaderInitialized := False;
  if not Load_GL_version_2_0 then
  begin
    LogToFile('Failed to load OpenGL 2.0 extensions.');
    Exit;
  end;

  fProgram := CreateProgram(SHADER_LINE_LG_VERT);
  fProgram1d := CreateProgram(SHADER_LINE_LG_1D_VERT);

  if (fProgram <> 0) and (fProgram1d <> 0) then
  begin
    fShaderInitialized := True;
    LogToFile('Shaders initialized successfully.');
  end
  else
    LogToFile('Failed to initialize shaders.');
end;

destructor TOpenGLChartRenderer.Destroy;
begin
  if fShaderInitialized then
  begin
    glDeleteProgram(fProgram);
    glDeleteProgram(fProgram1d);
  end;
  fFontMng.Free;
  inherited Destroy;
end;

procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  
  if not fShaderInitialized then
    InitShaders;

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

procedure TOpenGLChartRenderer.Resize(AWidth, AHeight: Integer);
begin
  if AHeight = 0 then
    AHeight := 1;
  glViewport(0, 0, AWidth, AHeight);
end;

function TOpenGLChartRenderer.GetPrimaryXAxis(APage: TChartPage): TChartAxis;
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
    Result := FormatFloat('0', AValue)
  else
  begin
    lDigits := Min(6, Max(0, Ceil(-Log10(AStep))));
    if lDigits = 0 then
      Result := FormatFloat('0', AValue)
    else
      Result := FormatFloat('0.' + StringOfChar('0', lDigits), AValue);
  end;
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
var
  lTotalOffset: Single;
  lYTicks: TChartTickArray;
  lAxisFont: cOglFont;
  lYAxis: TChartAxis;
  lText: string;
  lMaxTextWidth, lTextWidth: Single;
  I, J, lYAxisIdx: Integer;
begin
  lTotalOffset := 0;
  lYAxisIdx := 0;
  if Assigned(APage) then
  begin
    for I := 0 to APage.ChildCount - 1 do
      if APage.Children[I] is TChartAxis then
      begin
        lYAxis := TChartAxis(APage.Children[I]);
        if lYAxisIdx > 0 then
        begin
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
          lTotalOffset := lTotalOffset + lMaxTextWidth + 15;
        end;
        Inc(lYAxisIdx);
      end;
  end;

  Result.Left := fPageRect.Left + APage.PixelTabSpace.Left + Round(lTotalOffset);
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
  if not Assigned(fHost) or not Assigned(APage) then
  begin
    Result.Left := 0;
    Result.Top := 0;
    Result.Right := 0;
    Result.Bottom := 0;
    Exit;
  end;

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
    ',': case ARow of 5: Result := '00100'; 6: Result := '01000'; end;
    '-': if ARow = 3 then Result := '01110';
    '_': if ARow = 6 then Result := '11111';
  end;
end;

procedure TOpenGLChartRenderer.AddTextHit(const AText: string; AX, AY: Single; AFont: cOglFont;
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
end;

procedure TOpenGLChartRenderer.DrawGrid(const ARect: TChartPixelRect; APage: TChartPage; AYAxis: TChartAxis);
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
end;

procedure TOpenGLChartRenderer.DrawAxes(const ARect: TChartPixelRect; APage: TChartPage);
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
  lAxisOffset: Single;
  lMaxTextWidth, lTextWidth: Single;
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
  lAxisOffset := 0;
  for I := 0 to APage.ChildCount - 1 do
    if APage.Children[I] is TChartAxis then
    begin
      lYAxis := TChartAxis(APage.Children[I]);
      BuildAxisTicks(lYAxis, 8, lYTicks);

      if lYAxis = fSelectedObject then
        lFont := fFontMng.Font(cfAxisSelected)
      else
        lFont := fFontMng.Font(cfAxisLabel);

      lX := ARect.Left - lAxisOffset;

      // Устанавливаем цвет оси по ее свойству Color
      SetGLColor(lYAxis.Color);
      glLineWidth(1.5);
      // Отрисовываем вертикальную линию для каждой оси Y отдельно!
      DrawLine(lX, ARect.Top, lX, ARect.Bottom);

      // Отрисовываем тики для каждой оси
      for lIndex := 0 to High(lYTicks) do
      begin
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top);
        DrawLine(lX - CTick, lY, lX, lY);
      end;

      // Отрисовываем текстовые метки осей
      for lIndex := 0 to High(lYTicks) do
      begin
        lText := lYTicks[lIndex].Text;
        lY := AxisValueToPixel(lYAxis, lYTicks[lIndex].Value, ARect.Bottom, ARect.Top) -
          lFont.TextPixelHeight / 2;
        if Abs(lYTicks[lIndex].Value - lYAxis.MinValue) < 1E-9 then
          DrawEditableText(lText, lX - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMin)
        else if Abs(lYTicks[lIndex].Value - lYAxis.MaxValue) < 1E-9 then
          DrawEditableText(lText, lX - lFont.TextPixelWidth(lText) - 7, lY, lFont, lYAxis, nil, celAxisMax)
        else
          DrawText(lText, lX - lFont.TextPixelWidth(lText) - 7, lY, lFont);
      end;

      // Вычисляем ширину для следующей оси Y
      lMaxTextWidth := 0.0;
      for lIndex := 0 to High(lYTicks) do
      begin
        lTextWidth := lFont.TextPixelWidth(lYTicks[lIndex].Text);
        if lTextWidth > lMaxTextWidth then
          lMaxTextWidth := lTextWidth;
      end;
      lAxisOffset := lAxisOffset + lMaxTextWidth + 15;
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
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lPoint: TChartPoint;
  lX: Single;
  lY: Single;
  lXMin, lXMax, lYMin, lYMax: Double;
  lMinMax: array[0..3] of GLfloat;
  lLg: array[0..1] of GLint;
  lMinMaxLoc, lLgLoc: GLint;
begin
  if not Assigned(ASeries) or (ASeries.PointCount <= 0) or not Assigned(AYAxis) then
    Exit;

  SetGLColor(ASeries.Color);
  glLineWidth(2.3);

  if fUseShader and fShaderInitialized then
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

    glUseProgram(fProgram);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(fProgram, 'a_minmax');
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
    
    lLgLoc := glGetUniformLocation(fProgram, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ASeries.PointCount - 1 do
    begin
      lPoint := ASeries.Points[lIndex];
      glVertex2f(lPoint.X, lPoint.Y);
    end;
    glEnd;

    glPopMatrix;
    glUseProgram(0);
  end
  else
  begin
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ASeries.PointCount - 1 do
    begin
      lPoint := ASeries.Points[lIndex];
      lX := XValueToPixel(APage, AYAxis, lPoint.X, ARect.Left, ARect.Right);
      lY := AxisValueToPixel(AYAxis, lPoint.Y, ARect.Bottom, ARect.Top);
      glVertex2f(lX, lY);
    end;
    glEnd;
  end;
end;

procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
  APage: TChartPage; AYAxis: TChartAxis);
var
  lIndex: Integer;
  lX: Single;
  lY: Single;
  lXMin, lXMax, lYMin, lYMax: Double;
  lMinMax: array[0..3] of GLfloat;
  lLg: array[0..1] of GLint;
  lLinePar: array[0..1] of GLfloat;
  lMinMaxLoc, lLgLoc, lLineParLoc: GLint;
begin
  if not Assigned(ATrend) or (ATrend.Count <= 0) or not Assigned(AYAxis) then
    Exit;

  SetGLColor(ATrend.Color);
  glLineWidth(2.3);

  if fUseShader and fShaderInitialized then
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

    glUseProgram(fProgram1d);

    lMinMax[0] := lXMin;
    lMinMax[1] := lXMax;
    lMinMax[2] := lYMin;
    lMinMax[3] := lYMax;
    lMinMaxLoc := glGetUniformLocation(fProgram1d, 'a_minmax');
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
    
    lLgLoc := glGetUniformLocation(fProgram1d, 'a_Lg');
    glUniform2iv(lLgLoc, 1, @lLg[0]);

    lLinePar[0] := ATrend.X0;
    lLinePar[1] := ATrend.DX;
    lLineParLoc := glGetUniformLocation(fProgram1d, 'a_LinePar');
    glUniform2fv(lLineParLoc, 1, @lLinePar[0]);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(ARect.Left, ARect.Bottom, 0);
    glScalef((ARect.Right - ARect.Left) / (lXMax - lXMin), (ARect.Top - ARect.Bottom) / (lYMax - lYMin), 1.0);
    glTranslatef(-lXMin, -lYMin, 0);

    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ATrend.Count - 1 do
    begin
      glVertex2f(ATrend.Values[lIndex], 0);
    end;
    glEnd;

    glPopMatrix;
    glUseProgram(0);
  end
  else
  begin
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to ATrend.Count - 1 do
    begin
      lX := XValueToPixel(APage, AYAxis, ATrend.X0 + lIndex * ATrend.DX, ARect.Left, ARect.Right);
      lY := AxisValueToPixel(AYAxis, ATrend.Values[lIndex], ARect.Bottom, ARect.Top);
      glVertex2f(lX, lY);
    end;
    glEnd;
  end;
end;

procedure TOpenGLChartRenderer.RenderObject(AObject: TChartBaseObject; const ARect: TChartPixelRect;
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
  begin
    DrawLineSeries(TChartLineSeries(AObject), ARect, APage, lYAxis);
    if AObject is cTrend then
      DrawTrendPoints(cTrend(AObject), ARect, APage, lYAxis);
  end;

  for lIndex := 0 to AObject.ChildCount - 1 do
    RenderObject(AObject.Children[lIndex], ARect, APage, lYAxis);
end;

procedure TOpenGLChartRenderer.RenderPage(APage: TChartPage);
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

  glEnable(GL_SCISSOR_TEST);
  glScissor(fPageRect.Left, fHost.GetHeight - fPageRect.Bottom,
    Max(1, fPageRect.Right - fPageRect.Left),
    Max(1, fPageRect.Bottom - fPageRect.Top));

  DrawPageFrame(APage, fPageRect);
  DrawGrid(lContentRect, APage, lYAxis);
  DrawAxes(lContentRect, APage);

  glScissor(lContentRect.Left, fHost.GetHeight - lContentRect.Bottom,
    Max(1, lContentRect.Right - lContentRect.Left),
    Max(1, lContentRect.Bottom - lContentRect.Top));
  for lIndex := 0 to APage.ChildCount - 1 do
    RenderObject(APage.Children[lIndex], lContentRect, APage, nil);
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

  DrawHighlights;

  if fSelectionRectActive then
  begin
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Заливка полупрозрачным синим цветом
    SetGLColor($403C7DFF);
    FillRect(fSelectionRect);
    
    // Рамка
    SetGLColor($FF3C7DFF);
    glLineWidth(1.5);
    DrawRect(fSelectionRect);
    
    glDisable(GL_BLEND);
  end;
end;

function TOpenGLChartRenderer.MouseDown(AX, AY: Integer; ADoubleClick: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  fActiveHit.Axis := nil;
  fActiveHit.Page := nil;
  fActiveHit.Kind := celNone;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
      (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      fActiveHit := fTextHits[I];
      fEditText := fTextHits[I].Text;
      if ADoubleClick then
      begin
        fEditSelectionStart := 1;
        fEditSelectionLength := Length(fEditText);
        fEditCursor := Length(fEditText) + 1;
      end
      else
      begin
        fEditCursor := fTextHits[I].Font.HitCharIndex(fEditText, AX, fTextHits[I].TextLeft);
        fEditSelectionStart := fEditCursor;
        fEditSelectionLength := 0;
      end;
      Result := True;
      Exit;
    end;
end;

function TOpenGLChartRenderer.KeyDown(AKey: Word): Boolean;
var
  lValue: Double;
begin
  Result := fActiveHit.Kind <> celNone;
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
  end;
end;

function TOpenGLChartRenderer.TextInput(const AText: string): Boolean;
var
  lValue: Double;
  lChar: Char;
begin
  Result := fActiveHit.Kind <> celNone;
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
  end;
end;

procedure TOpenGLChartRenderer.DrawHighlightRect(const ARect: TChartPixelRect; AColor: Cardinal);
begin
  SetGLColor(AColor);
  glLineWidth(1.2);
  DrawRect(ARect);
end;

procedure TOpenGLChartRenderer.DrawHighlights;
var
  lHovered, lSelected: TChartBaseObject;
  lIndex: Integer;
  lPageRect: TChartPixelRect;
begin
  lHovered := fHoveredObject;
  lSelected := fSelectedObject;

  // 1. Highlight hovered page or axis text hit
  if Assigned(lHovered) then
  begin
    if lHovered is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lHovered));
      DrawHighlightRect(lPageRect, $50FFCC00); // semi-transparent yellow highlight frame
    end
    else if lHovered is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lHovered then
          DrawHighlightRect(fTextHits[lIndex].Rect, $80FFCC00);
    end;
  end;

  // 2. Highlight selected page or axis text hit
  if Assigned(lSelected) then
  begin
    if lSelected is TChartPage then
    begin
      lPageRect := PageToPixelRect(TChartPage(lSelected));
      SetGLColor($FFFF3300); // Bold orange/red border
      glLineWidth(3);
      DrawRect(lPageRect);
    end
    else if lSelected is TChartAxis then
    begin
      for lIndex := 0 to High(fTextHits) do
        if fTextHits[lIndex].Axis = lSelected then
        begin
          SetGLColor($FFFF3300);
          glLineWidth(1.5);
          DrawRect(fTextHits[lIndex].Rect);
        end;
    end;
  end;
end;

function TOpenGLChartRenderer.GetPageRect(APage: TChartPage): TChartPixelRect;
begin
  Result := PageToPixelRect(APage);
end;

function TOpenGLChartRenderer.GetPageContentRect(APage: TChartPage): TChartPixelRect;
begin
  fPageRect := PageToPixelRect(APage);
  Result := PageContentRect(APage);
end;

function TOpenGLChartRenderer.GetTextHitAt(AX, AY: Integer; out AHit: TChartTextHit): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(fTextHits) do
    if (AX >= fTextHits[I].Rect.Left) and (AX <= fTextHits[I].Rect.Right) and
       (AY >= fTextHits[I].Rect.Top) and (AY <= fTextHits[I].Rect.Bottom) then
    begin
      AHit := fTextHits[I];
      Result := True;
      Exit;
    end;
end;

function TOpenGLChartRenderer.PixelToXValue(APage: TChartPage; AAxis: TChartAxis; APixelX, ALeft, ARight: Single): Double;
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
end;

function TOpenGLChartRenderer.PixelToAxisValue(AAxis: TChartAxis; APixelY, ABottom, ATop: Single): Double;
begin
  if not Assigned(AAxis) then
    Exit(0);
  if ABottom = ATop then
    Exit(AAxis.MinValue);
  if AAxis.Scale = casLog10 then
    Result := Power(10, Log10(Max(AAxis.MinValue, 1E-12)) + (APixelY - ABottom) / (ATop - ABottom) * (Log10(Max(AAxis.MaxValue, 1E-12)) - Log10(Max(AAxis.MinValue, 1E-12))))
  else
    Result := AAxis.MinValue + (APixelY - ABottom) / (ATop - ABottom) * (AAxis.MaxValue - AAxis.MinValue);
end;


procedure TOpenGLChartRenderer.DrawTrendPoints(ATrend: cTrend; const ARect: TChartPixelRect;
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

      // Tangent vector lines (gray lines)
      SetGLColor($FF808080); 
      glLineWidth(1.0);
      glBegin(GL_LINES);
      glVertex2f(lX, lY);
      glVertex2f(lXLeft, lYLeft);
      glVertex2f(lX, lY);
      glVertex2f(lXRight, lYRight);
      glEnd;

      // Handle control points: GREEN squares of size 8x8 (half-size 4.0) with black border
      SetGLColor($FF00D000); // Bright green
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

      // Black outline for green handles
      SetGLColor($FF000000);
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
end;

function TOpenGLChartRenderer.GetAxisHitAt(AModel: TChartModel; AX, AY: Integer; out AAxis: TChartAxis): Boolean;
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
  for lIndex := 0 to AModel.ChildCount - 1 do
    if AModel.Children[lIndex] is TChartPage then
    begin
      lPage := TChartPage(AModel.Children[lIndex]);
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

end.
