import os

# 1. Modify uOglChartTypes.pas
path_types = r'd:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartTypes.pas'
with open(path_types, 'r', encoding='cp1251') as f:
    text_types = f.read()
text_types = text_types.replace('\r\n', '\n')

t_types = """  { Интерфейс для доступа к элементам управления графиком из слушателей }
  IChartControl = interface
    ['{C1D2E3F4-5678-90AB-CDEF-1234567890AB}']
    function GetRenderer: TObject;
    function GetModel: TObject;
    procedure Redraw;
  end;

implementation"""

r_types = """  { Интерфейс для доступа к элементам управления графиком из слушателей }
  IChartControl = interface
    ['{C1D2E3F4-5678-90AB-CDEF-1234567890AB}']
    function GetRenderer: TObject;
    function GetModel: TObject;
    procedure Redraw;
  end;

var
  gGLContextVersion: Cardinal = 0;

implementation"""

t_types = t_types.replace('\r', '')
r_types = r_types.replace('\r', '')

if t_types in text_types:
    text_types = text_types.replace(t_types, r_types)
    text_types = text_types.replace('\n', '\r\n')
    with open(path_types, 'w', encoding='cp1251', newline='') as f:
        f.write(text_types)


# 2. Modify uOglChartTrend.pas
path_trend = r'd:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartTrend.pas'
with open(path_trend, 'r', encoding='cp1251') as f:
    text_trend = f.read()
text_trend = text_trend.replace('\r\n', '\n')

t_trend = """  { cBaseTrend }
  cBaseTrend = class(cDrawObj)
  private
    fGLListID: Cardinal;
  public
    procedure AssignDefaultProperties; override;
    property GLListID: Cardinal read fGLListID write fGLListID;
  end;"""

r_trend = """  { cBaseTrend }
  cBaseTrend = class(cDrawObj)
  private
    fGLListID: Cardinal;
    fGLListContextVersion: Cardinal;
  public
    procedure AssignDefaultProperties; override;
    property GLListID: Cardinal read fGLListID write fGLListID;
    property GLListContextVersion: Cardinal read fGLListContextVersion write fGLListContextVersion;
  end;"""

t_trend = t_trend.replace('\r', '')
r_trend = r_trend.replace('\r', '')

if t_trend in text_trend:
    text_trend = text_trend.replace(t_trend, r_trend)
    text_trend = text_trend.replace('\n', '\r\n')
    with open(path_trend, 'w', encoding='cp1251', newline='') as f:
        f.write(text_trend)


# 3. Modify uOglChartRenderer.pas
path_renderer = r'd:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas'
with open(path_renderer, 'r', encoding='cp1251') as f:
    text_renderer = f.read()
text_renderer = text_renderer.replace('\r\n', '\n')

t_renderer = """procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  
  if not fShaderInitialized then
    InitShaders;"""

r_renderer = """procedure TOpenGLChartRenderer.Initialize(AHost: IOpenGLContextHost);
begin
  fHost := AHost;
  Inc(gGLContextVersion);
  if not Assigned(fFontMng) then
    fFontMng := cOglFontMng.Create;
  fHost.MakeCurrent;
  
  if not fShaderInitialized then
    InitShaders;"""

t_renderer = t_renderer.replace('\r', '')
r_renderer = r_renderer.replace('\r', '')

if t_renderer in text_renderer:
    text_renderer = text_renderer.replace(t_renderer, r_renderer)
    text_renderer = text_renderer.replace('\n', '\r\n')
    with open(path_renderer, 'w', encoding='cp1251', newline='') as f:
        f.write(text_renderer)


# 4. Modify uOglChartLineHelper.pas
path_helper = r'd:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartLineHelper.pas'
with open(path_helper, 'r', encoding='cp1251') as f:
    text_helper = f.read()
text_helper = text_helper.replace('\r\n', '\n')

t_helper_line = """    if ASeries.GLListID = 0 then
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
    end;"""

r_helper_line = """    if (ASeries.GLListID = 0) or (ASeries.GLListContextVersion <> gGLContextVersion) then
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
    end;"""

t_helper_buff = """    if ATrend.GLListID = 0 then
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
    end;"""

r_helper_buff = """    if (ATrend.GLListID = 0) or (ATrend.GLListContextVersion <> gGLContextVersion) then
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
    end;"""

t_helper_line = t_helper_line.replace('\r', '')
r_helper_line = r_helper_line.replace('\r', '')
t_helper_buff = t_helper_buff.replace('\r', '')
r_helper_buff = r_helper_buff.replace('\r', '')

if t_helper_line in text_helper:
    text_helper = text_helper.replace(t_helper_line, r_helper_line)
if t_helper_buff in text_helper:
    text_helper = text_helper.replace(t_helper_buff, r_helper_buff)

text_helper = text_helper.replace('\n', '\r\n')
with open(path_helper, 'w', encoding='cp1251', newline='') as f:
    f.write(text_helper)

print("Successfully applied GL context switching fixes to all files (idempotent)!")
