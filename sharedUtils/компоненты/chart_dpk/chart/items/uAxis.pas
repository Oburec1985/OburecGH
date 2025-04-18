unit uAxis;

interface

uses ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, types,
  sysutils, math, uCommonMath, stdctrls, forms, controls, uText, uEventList,
  uChartEvents, classes, dialogs, uGistogram, mathfunction, NativeXML;

type
  // ��������� ��������
  AxisCfg = record
    // ������ �����
    m_MaxValue: double;
    m_MinValue: double;
    // ���������� �������� ��������� ����(������������ ������� ��������)
    UpdateAxis: boolean;
    // �������
    active: boolean;
    // ��������� ��������� ����
    settings: cardinal;
    // ������ ��������� ������
    activefont: integer; // ������ ��������� ������
  end;

  cAxis = class(cdrawobj)
  public
    // ������� ���������
    m_YUnits, m_XUnits: string;
    // ������� ���� ���
    stateM: matrixgl;
    // ������� ��� (���������� �� ������ ���� � ���������� ���� (-1..1))
    axispos: single;
    // �������� � �������� ������������ ������ ����
    iaxispos: integer;
  public
    // �������� � ���� �������� ����� �� �����
    // ������������ ��� ������������ ����
    yGridDataVal: array of double;
    xGridDataVal: array of double;
  protected
    fLg: boolean;
    axisdata: array of single;
    projection: array [0 .. 15] of gldouble; // ������� ��������.
    // ��������� ��������
    cfg: AxisCfg;
    // ������ ��� � ������� ���� ��������
    index: integer;
  protected
    // ����������� zoomfrect. ��� ��������� �������� �������� ����� � ��������������� �������
    procedure callLgEvent;
    procedure setLg(b: boolean);
    procedure setmainParent(p: cbaseObj); override;
    procedure BeforeDrawChild; override;
    // �������� ���������� �������
    procedure createevents; override;
    procedure deleteevents; override;
    procedure unlinc; override;
    // ���������� ���
    procedure drawdata; override;
    // ���������� ��� ���������� ������ ��������
    procedure DoLincParent; override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    // �������� �����
    procedure DrawText;
    // ������ �����
    function OffsetRectTofRect(rect: TRect): fRect;
    // �������� ����� ���
    procedure drawAxis;
    // ��������� �����
    // procedure drawGrid;
    function textsign: integer;
    function evaltextscale(f: cfont): point2;
  public
    function getzoomrect: fRect;
    // �������� ������ ��������� ��� i - ����� ���
    procedure UpdateAxisData(i: integer);
    // ����������� ���� ���������� ������
    function p2ToP2i(p: point2; var res: boolean): tpoint;
    function p2iToP2(p: tpoint): point2;
    function XToXi(x: single): integer;
    // �������� ������ ����� �� x
    function getdx: double;
    // �������� ������ ����� �� y
    function getdy: single;
    procedure loadstate;
  public
    // index - ����� ������
    Procedure OutText(str: PCHAR; p2: point2; align: integer; index: integer);
  public
    // ������ �������� �������! ����� ����� Page.NewAxis!!!
    constructor create; override;
    destructor destroy; override;
    function GetTypeString: string; override;
    procedure setflag(fl: cardinal);
    procedure dropflag(fl: cardinal);
    // ���������� ������
    function AddTrend: ctrend;
    // ���������� �����������
    function AddGistogram: cGistogram;
    Procedure ZoomfRect(var rect: fRect);
    // ��������� ���������� ���� �� ������� ��������� � �����
    function toTrend(p2: point2): point2;
  protected
    procedure setactive(v: boolean);
    function getactive: boolean;
    procedure setMax(v: Point2d);
    function getMax: Point2d;
    procedure setMin(v: Point2d);
    function getMin: Point2d;
    procedure setMaxY(v: double);
    function getMaxY: double;
    procedure setMinY(v: double);
    function getMinY: double;
  public
    property maxY: double read getMaxY write setMaxY;
    // ������� �� xy
    property minY: double read getMinY write setMinY;
    property active: boolean read getactive write setactive;
    // �������� �� xy
    property max: Point2d read getMax write setMax;
    // ������� �� xy
    property min: Point2d read getMin write setMin;
    property Lg: boolean read fLg write setLg;
  end;

  // ����� ���������� Val �� ����� min max ��� �������, ��� min max ��������������� ����� log10
  // ��������� � ���������� 0..1
function evalLogPos(min, max: double; valLg: double): double;
// rect- ���������� ���� �� ����������������, minLinear,maxLinear ��������� ����
function RectToLogScale(var rect: fRect; minLinear, maxLinear: Point2d;
  lgx, lgy: boolean): fRect;
// valLg - �������� �������� (�� �������, �� � ����������� ��������������� �����. ����� ��������
// �������������� ������ �������� �������� ����� ������� ����)
function ValToLogScale(v: double; minmax: Point2d): double;
function LogValToLinearScale(v: double; minmax: Point2d): double;


const
  // ����� ��� ������� ��� ���
  c_axisTab = 45;


implementation

uses
  uPage;

const
  NumberGridLines = 10;
  textSelOffset = 5;
  textWidth = 4;
  textheight = 8;
  GLF_START_LIST = 1000;
  pi = 3.14159265;
  c_FloatMin = 0.00001;

  { axisdata:array[0..15] of single =
    // ��� x � ��������
    (-1,-1,  1,-1, 1,-0.95, 1,-1.05,
    // ��� y � ��������
    -1,-1, -1,1 , -1.05,1, -0.95,1); }
  //
function evalLogPos(min, max: double; valLg: double): double;
var
  range, lgRange, lgMax, lgMin: double;
begin
  if (min <= 0) or (max <= 0) then
    exit;
  lgMax := log10(max);
  lgMin := log10(min);
  lgRange := lgMax - lgMin;
  range := max - min;
  result := range * (log10(valLg) - lgMin) / lgRange + min;
end;

function LogValToLinearScale(v: double; minmax: Point2d): double;
var
  range, lgRange, lgMax, lgMin, rate: double;
begin
  lgMax := log10(minmax.y);
  lgMin := log10(minmax.x);
  lgRange := lgMax - lgMin;
  range := minmax.y - minmax.x;
  // ������������ ������� rect
  rate := (log10(v) - lgMin) / lgRange;
  result := rate * range + minmax.x;
end;

function ValToLogScale(v: double; minmax: Point2d): double;
var
  range, lgRange, lgMax, lgMin, rate: double;
begin
  lgMax := log10(minmax.y);
  lgMin := log10(minmax.x);
  lgRange := lgMax - lgMin;
  range := minmax.y - minmax.x;
  // ������������ ������� rect
  rate := (v - minmax.x) / range;
  result := rate * lgRange + lgMin;
  result := Power(10, result);
end;

function RectToLogScale(var rect: fRect; minLinear, maxLinear: Point2d;
  lgx, lgy: boolean): fRect;
var
  Xrange, XlgRange, xlgMax, xlgMin, Yrange, YlgRange, ylgMax, ylgMin,
    rate: double;
  leftbot, topright: point2;
begin
  leftbot.x := min(rect.BottomLeft.x, rect.topright.x);
  leftbot.y := min(rect.BottomLeft.y, rect.topright.y);
  topright.x := max(rect.BottomLeft.x, rect.topright.x);
  topright.y := max(rect.BottomLeft.y, rect.topright.y);
  rect.BottomLeft := leftbot;
  rect.topright := topright;
  if lgx then
  begin
    xlgMax := log10(maxLinear.x);
    xlgMin := log10(minLinear.x);
    XlgRange := xlgMax - xlgMin;
    Xrange := maxLinear.x - minLinear.x;
    // ������������ ������� rect
    rate := (rect.BottomLeft.x - minLinear.x) / Xrange;
    rect.BottomLeft.x := rate * XlgRange + xlgMin;
    rect.BottomLeft.x := Power(10, rect.BottomLeft.x);
    // ������������ �������� rect
    rate := (rect.topright.x - minLinear.x) / Xrange;
    rect.topright.x := rate * XlgRange + xlgMin;
    rect.topright.x := Power(10, rect.topright.x);
  end;
  if lgy then
  begin
    ylgMax := log10(maxLinear.y);
    ylgMin := log10(minLinear.y);
    YlgRange := ylgMax - ylgMin;
    Yrange := maxLinear.y - minLinear.y;
    // ������������ ������� rect
    rate := (rect.BottomLeft.y - minLinear.y) / Yrange;
    rect.BottomLeft.y := rate * YlgRange + ylgMin;
    rect.BottomLeft.y := Power(10, rect.BottomLeft.y);
    // ������������ �������� rect
    rate := (rect.topright.y - minLinear.y) / Yrange;
    rect.topright.y := rate * YlgRange + ylgMin;
    rect.topright.y := Power(10, rect.topright.y);
  end;
end;

constructor cAxis.create;
var
  i: integer;
begin
  inherited;
  index := 0;
  // ��������� ������ �� ���������
  cfg.settings := 0;
  cfg.m_MinValue := 0;
  cfg.m_MaxValue := 1;

  mathfunction.CreateOrthoMatrix(min.x, max.x, min.y, max.y, -1, 1, stateM);
  for i := 0 to 15 do
  begin
    projection[i] := stateM[i];
  end;

  // ���� ���
  color := black;
  imageindex := c_axis_img;
  // Move(identmatrix4d[0],projection[0],sizeof(double)*16);
end;

destructor cAxis.destroy;
var
  p:cpage;
begin
  p:=cpage(getpage());
  inherited;
  if p<>nil then
  begin
    if p.activeAxis=nil then
    begin
      if p.getAxisCount>0 then
      begin
        p.activeAxis:=caxis(p.axises.getChild(0));
      end;
    end;
  end;
end;

procedure cAxis.setmainParent(p: cbaseObj);
begin
  if p is cpage then
    cpage(p).addaxis(self)
  else
    inherited;
end;

procedure cAxis.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
var
  minP2, MaxP2: point2;
  rect: fRect;
begin
  inherited;
  minP2.x := xmlNode.ReadAttributeFloat('Min.X');
  minP2.y := xmlNode.ReadAttributeFloat('Min.Y');
  MaxP2.x := xmlNode.ReadAttributeFloat('Max.X');
  MaxP2.y := xmlNode.ReadAttributeFloat('Max.Y');

  rect.BottomLeft.x := minP2.x;
  rect.BottomLeft.y := minP2.y;
  rect.topright.x := MaxP2.x;
  rect.topright.y := MaxP2.y;

  ZoomfRect(rect);
end;

procedure cAxis.SaveObjAttributes(xmlNode: txmlNode);
begin
  inherited;
  xmlNode.WriteAttributeFloat('Min.X', min.x);
  xmlNode.WriteAttributeFloat('Min.Y', min.y);
  xmlNode.WriteAttributeFloat('Max.X', max.x);
  xmlNode.WriteAttributeFloat('Max.Y', max.y);
end;

procedure cAxis.DoLincParent;
var
  page: cpage;
  rect: TRect;
begin
  inherited;
  page := cpage(getpage);
  if getdrawobjmng = nil then
  begin
    if page <> nil then
    begin
      if page.drawobjmng <> nil then
      begin
        setmng(page.drawobjmng);
      end;
    end;
  end;
  if page = nil then
    exit;
  index := page.getaxiscount;
  // ����������� ������ ��� ���
  if index > 1 then
  begin
    rect := page.GetPixelTabSpace;
    rect.Left := rect.Left + c_axisTab;
    page.settabspace(rect);
  end;
end;

function cAxis.OffsetRectTofRect(rect: TRect): fRect;
var
  res: fRect;
  p: cpage;
begin
  p := cpage(getpage);
  rect.right := p.getWidth - rect.right;
  rect.top := p.getheight - rect.top;
  res.BottomLeft.x := rect.Left * 2 / p.getWidth - 1;
  res.BottomLeft.y := rect.Bottom * 2 / p.getheight - 1;
  res.topright.x := rect.right * 2 / p.getWidth - 1;
  res.topright.y := rect.top * 2 / p.getheight - 1;
  result := res;
end;

Procedure cAxis.OutText(str: PCHAR; p2: point2; align: integer; index: integer);
begin
  getfont(index).OutText(str, p2, align);
end;

function cAxis.getdx: double;
var
  p: cpage;
begin
  p := cpage(getpage);
  result := p.MaxX - p.MinX;
end;

function cAxis.getdy: single;
begin
  result := cfg.m_MaxValue - cfg.m_MinValue;
end;

procedure cAxis.DrawText;
var
  // m:array [0..15] of single;
  p2: point2; // ��������� ��������� ������ ����� ������ ����
  i, j: integer;
  linecount: tpoint;
  // ��� ����� ������� � ����������� -1..1 � �������� ������
  step: point2;
  // ��� ��� ���������� �������� ������
  ValStep: point2;
  str: string;
  poly: fRect;
  bounds: TRect;
  p: cpage;
  lscale:point2;
  f:cfont;
const
  color: array [0 .. 2] of glFloat = (0, 0, 0);
  ActiveColor: array [0 .. 2] of glFloat = (1, 0.3, 0.3);
begin
  p := cpage(getpage);
  linecount.x := p.gridlinecount_X;
  linecount.y := p.gridlinecount_Y;
  // ����������� ��� x
  bounds := p.bound;
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  f:=nil;
  // ������ ����� ��� � ������� ���� ��������
  if (index = 0) and (linecount.x >= 0) then
  begin
    step.x := 2 / linecount.x;
    ValStep.x := getdx / linecount.x;
    glViewPort(bounds.Left + p.GetPixelTabSpace.Left, bounds.Bottom,
      p.getWidth - p.GetPixelTabSpace.right - p.GetPixelTabSpace.Left,
      p.getheight);
    // ����������� ��� x
    p2.y := p.getTabSpace.BottomLeft.y - p.getTabText.y;
    if p.lgx then
      linecount.x := length(xGridDataVal);
    for i := 1 to linecount.x - 2 do
    begin
      if p.lgx then
      begin
        if (i*2)>=length(p.xGridData) then
        begin
          break;
        end;
        p2.x := cpage(p).xGridData[i * 2].x;
        ValStep.x := xGridDataVal[i];
        str := formatstr(ValStep.x, textsign);
        OutText(PCHAR(str), p2, c_left, c_AxisFontInd);
        if f<>nil then
          f.scaleVectorText:=lscale;
      end
      else
      begin
        p2.x := -1 + step.x * i;
        str := formatstr(ValStep.x * i + p.MinX, textsign);
        if ((i = linecount.x) or (i = 0)) then
        begin
        end
        else
        begin
          OutText(PCHAR(str), p2, c_left, c_AxisFontInd);
        end;
      end;
    end;
  end;
  glViewPort(bounds.Left, bounds.Bottom + p.GetPixelTabSpace.Bottom,
    p.getWidth, p.getheight - p.GetPixelTabSpace.top -
      p.GetPixelTabSpace.Bottom);
  // ����������� ��� y
  p2.x := axispos - p.getTabText.x;
  if (linecount.y >= 0) then
  begin
    if Lg then
      linecount.y := length(yGridDataVal);
    // ������ ���/ �������� ����� ��� ������� (������ ��� �������� ���)
    j := c_AxisFontInd;
    if p.getaxiscount > 1 then
    begin
      if active then
      begin
        j := c_AxisBoldFontInd;
        f:=GetFont(j);
        lscale:=f.scaleVectorText;
        f.scaleVectorText:=evaltextscale(f);
      end;
    end;

    for i := 1 to linecount.y - 1 do
    begin
      if Lg then
      begin
        if i * 2 >= length(cpage(getpage).yGridData) then
          break;
        p2.y := cpage(getpage).yGridData[i * 2].y;
        ValStep.y := yGridDataVal[i];
        str := formatstr(ValStep.y, textsign);
        OutText(PCHAR(str), p2, c_right, j);
      end
      else
      begin
        step.y := 2 / linecount.y;
        ValStep.y := getdy / linecount.y;
        p2.y := -1 + step.y * i;
        str := formatstr(ValStep.y * i + cfg.m_MinValue, textsign);
        if ((i = linecount.y) or (i = 0)) then
        begin
        end
        else
        begin
          OutText(PCHAR(str), p2, c_right, j);
        end;
      end;
    end;
    if f<>nil then
      f.scaleVectorText:=lscale;
  end;
  glpopmatrix;
end;

procedure cAxis.drawAxis;
var
  page: cpage;
begin
  page := cpage(getpage);
  page.setCommonVP;
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  // ������� ���������� ������� ����������� ��� ����� a � �������, x �� ��������� 1
  glEnableClientState(GL_VERTEX_ARRAY); // ���. ����� ���������
  glVertexPointer(2, GL_FLOAT, 0, @axisdata[0]); // ��������� �� ������
  glDrawArrays(GL_LINES, 0, round(length(axisdata) / 2));
  // glDrawArrays(GL_LINES,0,Length(axisdata));
  glDisableClientState(GL_VERTEX_ARRAY);
  glpopmatrix;
  page.setDrawObjVP;
end;

procedure cAxis.drawdata;
var
  i: integer;
  obj: cdrawobj;
  p: cpage;
begin
  // ���������� ��� ������� � �������
  glColor3fv(@color);
  drawAxis;
  DrawText;
  p := cpage(getpage);
  // ���������� ����� �������� ������� �����
  p.setDrawObjVP;
  inherited;
end;

procedure cAxis.loadstate;
begin
  glMatrixMode(gl_projection);
  glloadmatrixf(@stateM);
end;

procedure cAxis.setactive(v: boolean);
begin
  cfg.active := v;
  if v then
  begin
    if events <> nil then
      events.CallAllEventsWithSender(e_OnChangeAxisScale, self);
  end;
end;

function cAxis.getactive: boolean;
begin
  result := cfg.active;
end;

procedure cAxis.setMax(v: Point2d);
var
  zoom: fRect;
  p: Point2d;
begin
  p := min;
  zoom.BottomLeft := p2(p.x, p.y);
  p := v;
  zoom.topright := p2(p.x, p.y);
  if min.x > v.x then
    zoom.topright.x := v.x - 1;
  if min.y > v.y then
    zoom.topright.y := v.y - 1;

  ZoomfRect(zoom);
end;

function cAxis.getMax: Point2d;
var
  p: cpage;
  d: double;
begin
  p := cpage(getpage);
  if p <> nil then
  begin
    d := p.MaxX;
  end
  else
    d := 0;
  result := p2d(d, cfg.m_MaxValue);
end;

function cAxis.getMaxY: double;
begin
  result := cfg.m_MaxValue;
end;

function cAxis.getMinY: double;
begin
  result := cfg.m_MinValue;
end;

procedure cAxis.setMinY(v: double);
begin
  cfg.m_MinValue := v;
end;

procedure cAxis.setMaxY(v: double);
begin
  cfg.m_MaxValue := v;
end;

procedure cAxis.setMin(v: Point2d);
var
  zoom: fRect;
  p: Point2d;
begin
  p := v;
  zoom.BottomLeft := p2(p.x, p.y);
  p := max;
  zoom.topright := p2(p.x, p.y);
  if max.x < v.x then
    zoom.topright.x := v.x + 1;
  if max.y < v.y then
    zoom.topright.y := v.y + 1;

  ZoomfRect(zoom);
  { cfg.m_MinValues:=v;
    if active then
    begin
    events.CallAllEventsWithSender(e_OnChangeAxisScale,self);
    end; }
end;

function cAxis.getMin: Point2d;
var
  p: cpage;
begin
  p := cpage(getpage);
  if p <> nil then
  begin
    result.x := p.MinX;
  end
  else
    result.x := 0;
  result.y := cfg.m_MinValue;
end;

procedure cAxis.setflag(fl: cardinal);
begin
  uCommonMath.setflag(cfg.settings, fl);
end;

procedure cAxis.dropflag(fl: cardinal);
begin
  uCommonMath.dropflag(cfg.settings, fl);
end;

function cAxis.AddTrend: ctrend;
var
  trend: ctrend;
begin
  trend := ctrend.create;
  while GetChild(trend.name) <> nil do
  begin
    trend.name := ModName(trend.name, false);
  end;
  trend.parent := self;
  result := trend;
end;

function cAxis.AddGistogram: cGistogram;
var
  Gist: cGistogram;
begin
  Gist := cGistogram.create;
  while GetChild(Gist.name) <> nil do
  begin
    Gist.name := ModName(Gist.name, false);
  end;
  Gist.parent := self;
  result := Gist;
end;

procedure cAxis.createevents;
begin

end;

procedure cAxis.deleteevents;
begin
  // getpage(self).events.RemoveEvent(setEditPos, e_OnResize);
end;

function cAxis.GetTypeString: string;
begin
  result := '���';
end;

// --------------------- ��������� ������������� ----------------------
Procedure cAxis.ZoomfRect(var rect: fRect);
var
  p: GLUInt;
  b: boolean;
  lrect: fRect;
  i: integer;
  page: cpage;
  // lstatem:matrixgl;
begin
  // ======================���������� � ���������=========================
  glGetIntegerv(gl_Matrix_Mode, @p);
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;

  // �������������� ������� �������������
  lrect.BottomLeft.x := uCommonMath.min(rect.BottomLeft.x, rect.topright.x, b);
  lrect.BottomLeft.y := uCommonMath.min(rect.BottomLeft.y, rect.topright.y, b);
  lrect.topright.x := uCommonMath.max(rect.BottomLeft.x, rect.topright.x, b);
  lrect.topright.y := uCommonMath.max(rect.BottomLeft.y, rect.topright.y, b);
  // �������� �� ��������
  if Lg then
  begin
    if lrect.topright.y <= 0 then
    begin
      lrect.BottomLeft.y := c_FloatMin;
      lrect.topright.y := c_FloatMin * 100;
    end
    else
    begin
      if lrect.BottomLeft.y <= 0 then
      begin
        lrect.BottomLeft.y := c_FloatMin;
      end;
    end;
  end;
  page := cpage(getpage);
  if page.lgx then
  begin
    if lrect.topright.x <= 0 then
    begin
      lrect.BottomLeft.x := c_FloatMin;
      lrect.topright.x := c_FloatMin * 100;
    end
    else
    begin
      if lrect.BottomLeft.x <= 0 then
      begin
        lrect.BottomLeft.x := c_FloatMin;
      end;
    end;
  end;

  rect := lrect;

  if rect.BottomLeft.x >= rect.topright.x then
  begin
    rect.topright.x := rect.BottomLeft.x + 1;
  end;
  if rect.BottomLeft.y >= rect.topright.y then
  begin
    rect.topright.y := rect.BottomLeft.y + 0.1;
    rect.BottomLeft.y := rect.BottomLeft.y - 0.1;
  end;

  // min
  page.MinX := rect.BottomLeft.x;
  cfg.m_MinValue := rect.BottomLeft.y;
  // max
  page.MaxX := rect.topright.x;
  cfg.m_MaxValue := rect.topright.y;

  // �������� ����������� ������� �.�. � ������ ��������� ����
  // �� ������� ������ glOrtho �� ��������
  mathfunction.CreateOrthoMatrix(page.MinX, page.MaxX, min.y, max.y, -1, 1, stateM);
  for i := 0 to 15 - 1 do
  begin
    projection[i] := stateM[i];
  end;
  glpopmatrix;
  if p = GL_MODELVIEW then
    glMatrixMode(GL_MODELVIEW);
  if p = gl_projection then
    glMatrixMode(gl_projection);

  if active then
  begin
    if events <> nil then
      events.CallAllEventsWithSender(e_OnChangeAxisScale, self);
  end;
  // �������� 30.09.24
  if Lg or page.LgX then
    callLgEvent;
end;

function cAxis.XToXi(x: single): integer;
var
  res: boolean;
begin
  result := p2ToP2i(p2(x, 1), res).x;
end;

function cAxis.p2ToP2i(p: point2; var res: boolean): tpoint;
var
  viewport: array [0 .. 3] of glint;
  px, py, pz: double;
  i: integer; // ������������ ������� ����������.
  wx, wy, wz: gldouble;
  ires: integer;
begin
  result.x := -1;
  result.y := -1;
  // �������� ����� ���������� ������� ����!
  // glGetIntegerv(GL_VIEWPORT, @viewport); // ����� ��������� viewport-a.
  // ���������� 09.01.14 - ������ ��� cursor-�
  px := p.x;
  py := p.y;
  pz := 0;
  res := false;
  ires := gluProject(p.x, p.y, pz, @identMatrix4d, @projection,
    @cpage(getpage).m_viewport, wx, wy, wz);
  if ires = 1 then
  begin
    if (wx > 0) and (wy > 0) then
    begin
      res := true;
      result.x := round(wx);
      result.y := round(wy);
      result.y := twincontrol(cpage(getpage).chart).Height - result.y;
    end;
  end;
end;

procedure cAxis.UpdateAxisData(i: integer);
var
  page: cpage;
  w: single;
  p: tpoint;
  lp: cpage;
begin
  page := cpage(getpage);
  if page = nil then
    exit;
  index := i;
  if i = 0 then
  begin
    axispos := (page.getTabSpace.BottomLeft.x);
    setlength(axisdata, 8);
    axisdata[0] := axispos;
    axisdata[1] := page.getTabSpace.BottomLeft.y;
    axisdata[2] := page.getTabSpace.topright.x;
    axisdata[3] := page.getTabSpace.BottomLeft.y;
    axisdata[4] := axispos;
    axisdata[5] := page.getTabSpace.BottomLeft.y;
    axisdata[6] := axispos;
    axisdata[7] := page.getTabSpace.topright.y;
  end
  else
  // ���� ��� �� ������ ������ ������ Y
  begin
    lp := cpage(getpage);
    // ��� ������ ������������� � ������� caxis.doLincParent
    w := (page.getTabSpace.BottomLeft.x + 1) / lp.getaxiscount;
    axispos := -1 + w * i;
    setlength(axisdata, 4);
    axisdata[0] := axispos;
    axisdata[1] := page.getTabSpace.BottomLeft.y;
    axisdata[2] := axispos;
    axisdata[3] := page.getTabSpace.topright.y;
  end;
  p := page.p2ToP2i(p2(axispos, 1));
  iaxispos := p.x - page.bound.Left;
end;

function cAxis.toTrend(p2: point2): point2;
var
  page: cpage;
  res: point2;
  dx, dy, len, width, Height: single;
begin
  page := cpage(getpage);
  if p2.x > page.getTabSpace.topright.x then
    res.x := max.x
  else
  begin
    if p2.x < page.getTabSpace.BottomLeft.x then
      res.x := min.x
    else
    begin
      width := page.getTabSpace.topright.x - page.getTabSpace.BottomLeft.x;
      // ����� ������������� ��������� �� ����� �������
      dx := getdx;
      // �������� ��������� �������������� ���� � ��������� �������
      len := dx * (p2.x - page.getTabSpace.BottomLeft.x) / width;
      res.x := min.x + len;
    end;
  end;
  // ----------------------------------------------------
  if p2.y > page.getTabSpace.topright.y then
    res.y := max.y
  else
  begin
    if p2.y < page.getTabSpace.BottomLeft.y then
      res.y := min.y
    else
    begin
      Height := page.getTabSpace.topright.y - page.getTabSpace.BottomLeft.y;
      dy := getdy;
      len := dy * (p2.y - page.getTabSpace.BottomLeft.y) / Height;
      res.y := min.y + len;
      // -----------------------------------------------------
    end;
  end;
  result := res;
end;

function cAxis.getzoomrect: fRect;
var
  p: Point2d;
begin
  p := min;
  result.BottomLeft.x := p.x;
  result.BottomLeft.y := p.y;
  p := max;
  result.topright.x := p.x;
  result.topright.y := p.y;
end;

procedure cAxis.unlinc;
var
  page: cpage;
  rect: TRect;
  index: integer;
begin
  page := cpage(getpage);
  inherited;
  if page = nil then
    exit;
  index := page.getaxiscount;
  if index >= 1 then
  begin
    rect := page.GetPixelTabSpace;
    rect.Left := rect.Left - c_axisTab;
    page.settabspace(rect);
  end;
end;

function cAxis.evaltextscale(f: cfont): point2;
var
  p: cpage;
begin
  p := cpage(getpage);
  result := f.EvalScale(p.getWidth, p.getheight);
end;

function cAxis.textsign: integer;
var
  page: cpage;
begin
  page := cpage(getpage);
  result := page.prec;
end;

procedure cAxis.BeforeDrawChild;
begin
  inherited;
  cpage(getpage).setDrawObjVP;
  loadstate;
end;

function cAxis.p2iToP2(p: tpoint): point2;
var
  x, y, z: double;
  page: cpage;
  xWnd, yWnd:integer;
begin
  page := cpage(getpage);
  if (min.x=0) and (max.x=0) then
  begin
    result.x := 0;
    result.y := 0;
  end
  else
  begin
    //gluUnProject(p.x, p.y, 1, @identMatrix4d, @projection, @page.m_viewport, x,
    //gluUnProject(p.x, p.y, 1, @identMatrix4d, @identMatrix4d, @page.m_viewport, x,
    //  y, z);
    // bl.x,y; w;h
    xWnd:=p.x-page.m_viewport[0];
    yWnd:=p.y-page.m_viewport[1];
    if xWnd<=0 then
      result.x:=page.MinX
    else
      result.x := (page.MaxX-page.MinX)*(xWnd/page.m_viewport[2])+page.MinX;
    if yWnd<=0 then
      result.y:=Miny
    else
      result.y := (MaxY-MinY)*(yWnd/page.m_viewport[3])+MinY;
  end;
end;

procedure cAxis.setLg(b: boolean);
var
  r: fRect;
begin
  fLg := b;
  if b then
  begin

    r := getzoomrect;
    ZoomfRect(r);
  end;
  callLgEvent;
end;

procedure cAxis.callLgEvent;
var
  i: integer;
  obj: cdrawobj;
  p: cpage;
begin
  if fLg then
  begin
    p := cpage(getpage);
    // ��������� ����� ���� �������� ���
    if active then
    begin
      // ������� ������ ��� ��������� �����
      p.prepareYLgLineData;
      if p.lgx then
        p.prepareXLgLineData;
    end;
  end
  else
  begin
    // p.gridlinecount_Y:=p.prevgridcountY;
  end;
  // �������� �� 30.09.24 - ����������� ���������� ���
  for i := 0 to ChildCount - 1 do
  begin
    obj := cdrawobj(GetChild(i));
    obj.OnAxisChangeLg;
  end;
end;

end.
