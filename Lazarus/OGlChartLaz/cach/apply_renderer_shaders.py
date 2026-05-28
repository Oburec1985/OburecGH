import os

RENDERER_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"

print("Starting shader support implementation in renderer...")

with open(RENDERER_PATH, 'rb') as f:
    raw = f.read()
content = raw.decode('cp1251')
content_lf = content.replace('\r\n', '\n').replace('\r', '\n')

# 1. Update uses
old_uses = """uses
  Classes, SysUtils, Math, gl, uOglChartTypes, uOglChartBaseObj,"""

new_uses = """uses
  Classes, SysUtils, Math, gl, glext, uOglChartTypes, uOglChartBaseObj,"""

if old_uses in content_lf:
    content_lf = content_lf.replace(old_uses, new_uses)
    print("Added glext to uses.")
else:
    print("Error: old_uses not found!")

# 2. Add private fields to TOpenGLChartRenderer class declaration
old_fields = """  TOpenGLChartRenderer = class(TInterfacedObject, IChartRenderer)
  private
    fHost: IOpenGLContextHost;"""

new_fields = """  TOpenGLChartRenderer = class(TInterfacedObject, IChartRenderer)
  private
    fHost: IOpenGLContextHost;
    fUseShader: Boolean;
    fProgram: GLuint;
    fProgram1d: GLuint;
    fShaderInitialized: Boolean;
    procedure InitShaders;"""

if old_fields in content_lf:
    content_lf = content_lf.replace(old_fields, new_fields)
    print("Added private shader fields and helper method.")
else:
    print("Error: old_fields not found!")

# 3. Add public property UseShader
old_public = """    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;
    property HoveredObject: TChartBaseObject read fHoveredObject write fHoveredObject;
  end;"""

new_public = """    property SelectedObject: TChartBaseObject read fSelectedObject write fSelectedObject;
    property HoveredObject: TChartBaseObject read fHoveredObject write fHoveredObject;
    property UseShader: Boolean read fUseShader write fUseShader;
  end;"""

if old_public in content_lf:
    content_lf = content_lf.replace(old_public, new_public)
    print("Added public UseShader property.")
else:
    print("Error: old_public not found!")

# 4. Insert helpers and shaders at the start of implementation
old_impl_start = """implementation

const
  VK_BACK = 8;"""

# Source code of shaders matching user original ones, but with log10 registration register fix (Log10) and float suffixes (.0) for GLSL compatibility
new_impl_start = """implementation

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
  VK_BACK = 8;"""

if old_impl_start in content_lf:
    content_lf = content_lf.replace(old_impl_start, new_impl_start)
    print("Inserted shader compiler functions.")
else:
    print("Error: old_impl_start not found!")

# 5. Add InitShaders implementation and modify Destroy / Initialize
old_destroy = """destructor TOpenGLChartRenderer.Destroy;
begin
  fFontMng.Free;
  inherited Destroy;
end;"""

new_destroy = """procedure TOpenGLChartRenderer.InitShaders;
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
end;"""

if old_destroy in content_lf:
    content_lf = content_lf.replace(old_destroy, new_destroy)
    print("Added InitShaders and updated Destroy.")
else:
    print("Error: old_destroy not found!")

# 6. Update Initialize
old_init = """procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;"""

new_init = """procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  
  if not fShaderInitialized then
    InitShaders;

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;"""

if old_init in content_lf:
    content_lf = content_lf.replace(old_init, new_init)
    print("Updated Initialize to call InitShaders.")
else:
    print("Error: old_init not found!")

# 7. Update DrawLineSeries with shader branch
old_draw_series = """procedure TOpenGLChartRenderer.DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect;
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
end;"""

new_draw_series = """procedure TOpenGLChartRenderer.DrawLineSeries(ASeries: TChartLineSeries; const ARect: TChartPixelRect;
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
end;"""

if old_draw_series in content_lf:
    content_lf = content_lf.replace(old_draw_series, new_draw_series)
    print("Updated DrawLineSeries with shader logic.")
else:
    print("Error: old_draw_series not found!")

# 8. Update DrawBuffTrend1d with shader branch
old_draw_buff = """procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
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
end;"""

new_draw_buff = """procedure TOpenGLChartRenderer.DrawBuffTrend1d(ATrend: cBuffTrend1d; const ARect: TChartPixelRect;
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
end;"""

if old_draw_buff in content_lf:
    content_lf = content_lf.replace(old_draw_buff, new_draw_buff)
    print("Updated DrawBuffTrend1d with shader logic.")
else:
    print("Error: old_draw_buff not found!")

# Save to file
with open(RENDERER_PATH, 'wb') as f:
    f.write(content_lf.replace('\n', '\r\n').encode('cp1251'))

print("Completed successfully.")
