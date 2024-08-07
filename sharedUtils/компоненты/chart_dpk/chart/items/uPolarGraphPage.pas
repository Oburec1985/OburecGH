unit uPolarGraphPage;

interface

uses
  Controls, windows, ubaseobj, udrawobj, uTrend, uCommonTypes, opengl,
  uOglExpFunc, classes, utext,
  uAxis, messages, sysutils, uEventList, uSetList, uFrameListener, math,
  mathfunction, uChartEvents, uPoint, dialogs, types, forms, uSimpleObjects,
  uDoubleCursor, NativeXML, uBasePage, Clipbrd, uGraphObj, uLabel, ufloatlabel, uCommonMath;

type
  cPolarGraph = class(cGraphObj)
  public
    fneedrecompile: boolean;
  private
    fListId: cardinal;
    // ��������� ����������� ����� (������������� ��� ��������� ������ �������)
    fDrawFirstPoint: boolean;
    fFPArrSize:integer; // ������ �������
    fFPArrUsed:integer; // ������������ ���������

    fDrawFP: boolean;
    fDrawLines: boolean;
    fDrawPoints: boolean;
    fPointColor: point3;
    fFirstPointColor: point3;
    fDrawFPLine: boolean;
  protected
    procedure doLincParent;override;
    procedure compile; virtual;
    procedure DrawData; override;
    procedure setmainParent(p: cbaseObj); override;
    function FPcount:integer;virtual;abstract;
    function FPindex(i:integer):integer;virtual;abstract;
    procedure SetDrawFPLine(b:boolean);virtual;
    function GetDrawFPLine:boolean;virtual;
  public
    function gety(i: integer): double; virtual; abstract;
    function getx(i: integer): double; virtual; abstract;
    property DrawLines: boolean read fDrawLines write fDrawLines;
    property DrawPoints: boolean read fDrawPoints write fDrawPoints;
    property PointColor: point3 read fPointColor write fPointColor;
    property FirstPointColor: point3 read fFirstPointColor write fFirstPointColor;
    property UseFirstPoint: boolean read fDrawFP write fDrawFP;
    property drawFPLine : boolean read GetDrawFPLine write SetDrawFPLine;
    constructor create;override;
  end;

  cPolarGraph1d = class(cPolarGraph)
  private
    m_xData: array of double;
    m_yData: array of double;
    // ���������� ������������ ������
    fUsedItems:integer;
  protected
    // �������� ���������� ����� ������
    function getCount: integer; override;
    procedure setCount(i: integer); override;
    function getcapacity: integer;
    procedure setcapacity(i: integer);
  public
    procedure addData(const x: array of double; const y: array of double; fromind: integer);
    function getP2(i: integer): point2; override;
    function gety(i: integer): double; override;
    function getx(i: integer): double; override;
    property Capacity:integer read getcapacity write setcapacity;
    constructor create;override;
  end;

  cPolarGraph1dCycle = class(cPolarGraph)
  private
    m_xData: array of double;
    m_yData: array of double;
    // ���������� ������������ ������
    fUsedItems:integer;
    // ������ ��������� �������������� �����
    flastitem:integer;
  protected
    // �������� ���������� ����� ������
    function getCount: integer; override;
    procedure setCount(i: integer); override;
    function getcapacity: integer;
    procedure setcapacity(i: integer);
    // �������������� ������� � ������ ���������� ������
    function userIndToInternal(i:integer):integer;
  public
    procedure addData(const x: array of double; const y: array of double;
      fromind: integer);
    function getP2(i: integer): point2; override;
    function gety(i: integer): double; override;
    function getx(i: integer): double; override;
    property Capacity:integer read getcapacity write setcapacity;
    constructor create;override;
  end;

  cPolarAxis = class (cdrawObj)
  protected
    procedure BeforeDrawChild; override;
  public
    constructor create;
  end;

  cPolarGraphPage = class(cBasePage)
  private
    fPSize:double;
    m_graphs:cPolarAxis;
    // ���������� �����
    m_center: tpoint;
    // ������� ���� ���
    stateM: matrixgl;
    // ��������� �����
    // lg10_step, Line_Step
    m_gridType: integer;
    // ���������� ������ �� �����
    m_GridCount: integer;
    m_gridStep: double;
    // ���������� ����� �� �����
    m_AngelGridCount: integer;
    // �� ��� �����/ �����
    m_AngelGridType: integer;
    fGridListId: cardinal;
  private
    // ������ � ��������
    m_Tab: integer;
    fneedrecompile: boolean;
    // �������� � ����������� �������
    m_Max: double;
    m_PageLabel:cLabel;
    m_MaxXedit, m_MaxYedit:cfloatlabel;
  private
    procedure UpdateAxisByText(Sender: tobject; var Key: Word; Shift: TShiftState);
    procedure initTEdit(edit: cdrawobj);
    function ModComponentName(p_name: string): string;
    procedure DrawGraphBorder;
    // ��������� ���� ������� � �������. �� ������������� ������� ������� �����
    // ������� ���� ��������� DrawObjVp
    procedure DrawCross;
    procedure DrawGrid;
    procedure drawPage;
    // ��������� ������� ����/ ���������� � PrepareZoom
    Procedure SetZoom;
    procedure compile;
    procedure CompileGrid;
    procedure drawAngelGrid(f: cfont);
    procedure drawCyclesGrid(f: cfont);
    // ����������� ������� �������
    procedure PrepareZoom;
    procedure setmax(v:double);
    procedure setEditPos(Sender: tobject);
    procedure SetLabelPos;
    procedure OnSetText(Sender: tobject);
    procedure setPSize(p_size:double);
  protected
    // �������������� � ���������� � ������� ����� ����������� ���������
    procedure linc(p_chart: tcomponent); override;
    procedure setCaption(s: string);override;
    procedure BeforeDrawChild; override;
    // procedure DoClick(i_p:tpoint;f_p:point2);override;
    // procedure DoButtonUp(i_p:tpoint;f_p:point2);override;
    // procedure DoMouseMove(i_p:tpoint;f_p:point2);override;
    // procedure doOnExit;override;
    procedure UpdatePixTabs;
    procedure setBound(rect: trect); override;
    // procedure linc(p_chart: tcomponent); override;
    procedure DrawData; override;
  public
    function isCarrier: boolean;override;
    // �������� ������ �������
    property Max:double read m_max write setMax;
    property PSize:double read fPSize write setPSize;
    constructor create; override;
    destructor destroy; override;
  public
  end;

const
  lg10_step = 0;
  Line_step = 1;
  AngelGrid_sections = 0;
  AngelGrid_Ray = 1;
  c_digits = 4;

implementation

uses
  uchart;

{ cPolarGraphPage }

procedure cPolarGraphPage.BeforeDrawChild;
begin
  inherited;
  glMatrixMode(GL_PROJECTION_MATRIX);
  glloadidentity;
end;

procedure cPolarGraphPage.compile;
begin
  if fneedrecompile then
  begin
    fneedrecompile := false;
    CompileGrid;
  end;
end;

procedure cPolarGraphPage.CompileGrid;
var
  f: cfont;
begin
  f := GetFont(c_AxisFontInd);
  if fGridListId <> 0 then
    glDeleteLists(fGridListId, 1);
  fGridListId := glGenLists(1);
  glNewList(fGridListId, GL_COMPILE);
  drawCyclesGrid(f);
  drawAngelGrid(f);
  glEndList;
end;

procedure cPolarGraphPage.drawCyclesGrid(f: cfont);
var
  i, ord: integer;
  r: glfloat;
begin
  case m_gridType of
    lg10_step:
      begin
        ord := trunc(log10(m_Max));

        for i := 0 to m_GridCount - 1 do
        begin
          r := Power(10, ord - m_GridCount + i);
          DrawCycle(r);
        end;
        glEndList;
      end;
    Line_step:
      begin
        ord := trunc(m_Max / m_gridStep);
        for i := 0 to ord do
        begin
          r := (i + 1) * m_gridStep;
          if r <= m_Max then
          begin
            glColor3fv(@gray);
            DrawCycle(r, 40);
            // ��������� ������ ��������
            glColor3fv(@black);
            f.scaleVectorText := p2(1, 1);
            //f.OutText(formatstrNoE(r, c_digits), p2(r, 0), m_Max, c_right);
            f.OutText(formatstrNoE(-r, c_digits), p2(-r, 0), m_Max, c_left);
            //f.OutText(formatstrNoE(r, c_digits), p2(0, r), m_Max, c_left);
            f.OutText(formatstrNoE(-r, c_digits), p2(0, -r), m_Max, c_left);
          end
          else
            break;
        end;

      end;
  end;
end;

procedure cPolarGraphPage.drawAngelGrid(f: cfont);
var
  lp1, lp2: point2;
  angel: double;
  i: integer;
begin
  // ������ ������� �����
  lp1 := p2(0, 0);
  case m_AngelGridType of
    AngelGrid_sections:
      begin

      end;
    AngelGrid_Ray:
      begin
        // ���� ����������
        lp2.x := m_Max;
        lp2.y := 0;
      end;
  end;
  // ��������� ���� ����� (�������)
  glColor3fv(@gray);
  glLineStipple(1, $F0F0);
  glEnable(GL_LINE_STIPPLE);
  glMatrixMode(GL_MODELVIEW);
  glpushmatrix;
  glLoadIdentity;
  for i := 0 to m_AngelGridCount - 1 do
  begin
    // angel:=2*pi/m_AngelGridCount;
    angel := 360 / m_AngelGridCount;
    case m_AngelGridType of
      AngelGrid_sections:
        begin

        end;
      AngelGrid_Ray:
        begin
          f.OutText(formatstrNoE(angel * i, c_digits), p2(0.95 * m_Max, 0),
            m_Max, c_right);
          glBegin(GL_LINES);
          glVertex2fv(@lp1);
          glVertex2fv(@lp2);
          glEnd;
          glrotate(angel, 0, 0, 1);
        end;
    end;
  end;
  glpopmatrix;
  glDisable(GL_LINE_STIPPLE);
end;

function cPolarGraphPage.ModComponentName(p_name: string): string;
var
  obj: tcomponent;
  i: integer;
begin
  for i := 0 to cchart(self.chart).ComponentCount - 1 do
  begin
    obj := cchart(self.chart).Components[i];
  end;
  obj := cchart(self.chart).FindComponent(p_name);
  while obj <> nil do
  begin
    p_name := ModName(p_name, false);
    obj := cchart(self.chart).FindComponent(p_name);
  end;
  result := p_name;
end;

// �������� ��� ��� ����� ������ � TEdit
procedure cPolarGraphPage.UpdateAxisbyText(Sender: tobject; var Key: Word;
  Shift: TShiftState);
var
  rect: fRect;
  v:double;
begin
  if Key = 13 then
  begin
    v := strtofloatext(cfloatlabel(sender).Text);
    setmax(v);
  end;
  cchart(chart).redraw;
end;


procedure cPolarGraphPage.setEditPos(Sender: tobject);
var
  bounds, tabs: TRect;
  tabtext: TPoint;
  topoffset: integer;
  ipos:tpoint;
  p:point2;
  w, h:integer;
begin
  if m_MaxYedit <> nil then
  begin
    bounds := bound;
    tabs := m_pixelTabSpace;
    topoffset := twincontrol(chart).Height - bounds.Top;
    w:=getwidth;
    ipos.x:=bounds.Left+(w shr 1);
    ipos.y:=bounds.top-tabs.Top;
    h:=getheight;
    if (w<>0) and (h<>0) then
    begin
      p:=p2iTop2(ipos);
      // �� �������� ����� ����������� ����� �� �������� page.tabspace
      p.y:=p.y-m_MaxYedit.GetTextHeigth;
      m_MaxYedit.position := p;

      ipos.x:=bounds.Right-tabs.Right;
      ipos.y:=bounds.top-(getheight shr 1);
      p:=p2iTop2(ipos);
      m_MaxXedit.position := p;
    end;
    // ��������� ����� ��������
    SetLabelPos;
  end;
end;

procedure cPolarGraphPage.initTEdit(edit: cdrawobj);
begin
  edit.fhelper := true;
  cfloatlabel(edit).OnKeyEnter := UpdateAxisbyText;
  cfloatlabel(edit).Transparent:=false;
  AddChild(edit);
end;


function cPolarGraphPage.isCarrier: boolean;
begin
  result:=true;
end;


procedure cPolarGraphPage.SetLabelPos;
var
  pos: point2;
  h: single;
  w:integer;
begin
  w:=getwidth;
  if w<>0 then
  begin
    if getheight<>0 then
    begin
      h := m_PageLabel.GetTextHeigth;
      pos.y := 1 - 2 * h;
      //pos.x := 0 - m_PageLabel.GetTextWidth / 2+0.5;
      pos.x := 0.3;
      m_PageLabel.position := pos;
    end;
  end;
end;

procedure cPolarGraphPage.OnSetText(Sender: tobject);
begin
  SetLabelPos;
end;

procedure cPolarGraphPage.linc(p_chart: tcomponent);
begin
  if p_chart = nil then
    exit;
  if chart <> nil then
    exit;
  inherited;
  m_PageLabel := clabel.create;
  m_PageLabel.Name := ModComponentName('PageLabel');
  m_PageLabel.autocreate:=true;
  m_PageLabel.fhelper := true;
  m_PageLabel.Transparent:=false;
  m_PageLabel.locked:=true;
  AddChild(m_PageLabel);
  m_PageLabel.OnSetText := OnSetText;
end;


constructor cPolarGraphPage.create;
begin
  inherited;
  m_graphs:=cPolarAxis.create;
  AddChild(m_graphs);

  m_MaxXedit := cfloatlabel.create;
  m_MaxXedit.autocreate:=true;
  m_MaxXedit.textcolor := blue;
  m_MaxXedit.align := c_right;
  m_MaxXedit.Name := modname('polarMaxXEdit',false);
  m_MaxXedit.Transparent:=true;
  initTEdit(m_MaxXedit);

  m_MaxYedit:=cfloatlabel.create;
  m_MaxYedit.autocreate:=true;
  m_MaxYedit.textcolor := blue;
  m_MaxYedit.align := c_right;
  m_MaxYedit.Name := modname('polarMaxYEdit',false);
  m_MaxYedit.Transparent:=true;
  initTEdit(m_MaxYedit);

  m_gridType := Line_step;
  // m_gridType:=lg10_step;
  m_gridStep := 5;
  m_GridCount := 4;
  m_AngelGridType := AngelGrid_Ray;
  m_AngelGridCount := 36;
  m_Tab := 14;
  m_Max := 10;
  // ��� ��������
  color := white;
  PrepareZoom;
end;

destructor cPolarGraphPage.destroy;
begin

  inherited;
end;

procedure cPolarGraphPage.drawPage;
begin
  glColor3fv(@color);
  // ��������� �������� ����
  glBegin(GL_QUADs);
  glvertex2f(-1, -1);
  glvertex2f(-1, 1);
  glvertex2f(1, 1);
  glvertex2f(1, -1);
  glEnd;
end;

procedure cPolarGraphPage.setBound(rect: trect);
var
  clientrect:trect;
  w,h:integer;
begin
  clientrect:=getClientBound;
  if rect.Left<clientrect.Left then
    rect.left:=clientrect.Left;
  if rect.Top>clientrect.top then
    rect.top:=clientrect.top;
  if rect.Right>clientrect.Right then
    rect.Right:=clientrect.Right;
  if rect.Bottom<clientrect.Bottom then
    rect.Bottom:=clientrect.Bottom;
  if rect.Left>rect.right then
    rect.right:=rect.Left;
  if rect.bottom>rect.top then
    rect.top:=rect.bottom;
  w:=clientrect.Right-clientrect.left;
  h:=clientrect.top-clientrect.bottom;
  if (w<=0) or (h<=0) then
  begin
    exit;
  end;
  ibound:=rect;
  GetNormalViewport(m_NormalViewport);
  EvalRelativeBound(ibound);

  UpdatePixTabs;
  SetTabSpace(m_pixelTabSpace);

  // ����������� ����� �� ����
  setEditPos(nil);

  CallEventsWithSender(e_onresize, self);
  fneedrecompile:=true;
end;

procedure cPolarGraphPage.setCaption(s: string);
begin
  inherited;
  m_PageLabel.Text := s;
end;

procedure cPolarGraphPage.setmax(v: double);
begin
  m_max:=v;
  PrepareZoom;
  m_MaxXedit.text:=floattostr(v);
  m_MaxYedit.text:=floattostr(v);
  fneedrecompile:=true;
  CallEventsWithSender(e_onZoom, self);
  compile;
end;

procedure cPolarGraphPage.setPSize(p_size: double);
var
  res, step: glFloat;
  range: array [0 .. 1] of glFloat;
begin
  glGetFloatv(GL_POINT_SIZE_GRANULARITY, @step);
  glGetFloatv(GL_POINT_SIZE_RANGE, @Range);
  res := round(p_size / step) * step;
  // �������� �� ����� �� ��������
  if res < Range[0] then
    res := Range[0];
  if res > Range[1] then
    res := Range[1];
  fpsize:=res;
end;

procedure cPolarGraphPage.SetZoom;
begin
  // ======================���������� � ���������=========================
  // glGetIntegerv(gl_Matrix_Mode, @p);
  // glMatrixMode(gl_projection);
  // glpushmatrix;
  // glloadidentity;

  glMatrixMode(gl_projection);
  glloadmatrixf(@stateM);

  // glpopmatrix;
  // if p = GL_MODELVIEW then
  // glMatrixMode(GL_MODELVIEW);
  // if p = gl_projection then
  // glMatrixMode(gl_projection);
end;

procedure cPolarGraphPage.UpdatePixTabs;
var
  rad, w, h: integer;
begin
  w := getwidth;
  w := round(w / 2);
  h := getheight;
  h := round(h / 2);
  m_center.x := bound.Left + w;
  m_center.y := bound.Bottom + h;
  if w > h then
  begin
    rad := h - m_Tab;
    m_pixelTabSpace.Top := m_Tab;
    m_pixelTabSpace.Bottom := m_Tab;
    m_pixelTabSpace.Left := w - rad;
    m_pixelTabSpace.Right := m_pixelTabSpace.Left;
  end
  else
  begin
    rad := w - m_Tab;
    m_pixelTabSpace.Top := h - rad;
    m_pixelTabSpace.Bottom := m_pixelTabSpace.Top;
    m_pixelTabSpace.Left := m_Tab;
    m_pixelTabSpace.Right := m_Tab;
  end;
  fneedrecompile := True;
end;

procedure cPolarGraphPage.PrepareZoom;
var
  ord: integer;
  r: glfloat;
  i: integer;
begin
  // �������� ����������� ������� �.�. � ������ ��������� ����
  // �� ������� ������ glOrtho �� ��������
  mathfunction.CreateOrthoMatrix(-m_Max, m_Max, -m_Max, m_Max, -1, 1, stateM);
  fneedrecompile := True;
end;

procedure cPolarGraphPage.DrawCross;
var
  width, w: double;
begin
  glColor3fv(@gray);
  glGetDoubleV(GL_LINE_WIDTH, @w);
  width := 1;
  glLineWidth(width);
  glBegin(GL_LINES);
  glvertex2f(-1, 0);
  glvertex2f(1, 0);
  glvertex2f(0, -1);
  glvertex2f(0, 1);
  glEnd;
  glLineWidth(w);
end;


procedure cPolarGraphPage.DrawData;
begin
  glPointSize(fPSize);
  compile;
  glMatrixMode(gl_projection);
  glpushmatrix;
  glLoadIdentity;
  setCommonVP;
  // ��������� ���� ��������
  drawPage;
  // ��������� ����� ��������
  drawBound;
  setDrawObjVP;
  // ��������� ��������
  DrawCross;
  // ��������� ����� ���� ������ ������ �������
  DrawGraphBorder;
  // ��������� ������� ���� ��� ��������� ������ ����� �����
  SetZoom;
  DrawGrid;
  glpopmatrix;
  inherited;
end;

procedure cPolarGraphPage.DrawGraphBorder;
var
  width, w: double;
begin
  glColor3fv(@red);
  glGetDoubleV(GL_LINE_WIDTH, @w);
  width := 2;
  glLineWidth(width);
  glBegin(GL_LINE_STRIP);
  glvertex2f(-1, -1);
  glvertex2f(-1, 1);
  glvertex2f(1, 1);
  glvertex2f(1, -1);
  glvertex2f(-1, -1);
  glEnd;
  glLineWidth(w);
end;

procedure cPolarGraphPage.DrawGrid;
begin
  glColor3fv(@gray);
  glCallList(fGridListId);
end;

{ cPolarGraph }
procedure cPolarGraph1dCycle.addData(const x, y: array of double; fromind: integer);
var
  l: integer;
begin
  l := length(x);
  move(x, m_xData[fromind], l * sizeof(double));
  move(y, m_yData[fromind], l * sizeof(double));
  if (fromind+l)>fUsedItems then
  begin
    fUsedItems:=fromind+l;
  end;
  fneedrecompile:=true;
end;

constructor cPolarGraph1dCycle.create;
begin
  inherited;
  flastitem:=0;
  fUsedItems:=0;
end;

function cPolarGraph1dCycle.getcapacity: integer;
begin
  result := length(m_xData);
end;

procedure cPolarGraph1dCycle.setcapacity(i: integer);
begin
  setLength(m_xData, i);
  setLength(m_yData, i);
end;

function cPolarGraph1dCycle.getCount: integer;
begin
  result := fUsedItems;
end;

procedure cPolarGraph1dCycle.setCount(i: integer);
begin
  if i>capacity then
    capacity:=i;
  fUsedItems:=i;
end;

function cPolarGraph1dCycle.userIndToInternal(i: integer): integer;
var
  c, delta:Integer;
begin
  c:=Capacity;
  if fUsedItems<c then
  begin
    result:=i;
  end
  else
  begin
    delta:=c-flastitem-1;
    if i<(delta) then
      result:=flastitem+1+i
    else
    begin
      i:=i-delta;
    end;
  end;
end;

function cPolarGraph1dCycle.getP2(i: integer): point2;
begin
  i:=userIndToInternal(i);
  result := p2(m_xData[i], m_yData[i]);
end;

function cPolarGraph1dCycle.getx(i: integer): double;
begin
  i:=userIndToInternal(i);
  result := m_xData[i];
end;

function cPolarGraph1dCycle.gety(i: integer): double;
begin
  i:=userIndToInternal(i);
  result := m_yData[i];
end;

{ cPolarGraph }
constructor cPolarGraph.create;
begin
  inherited;
  fDrawFirstPoint:=true;
  color:=blue;
  fPointColor:=red;
  DrawPoints:=false;
  DrawLines:=true;
end;

procedure cPolarGraph.doLincParent;
begin
  if fparent is cPolarGraphPage then
  begin
    parent:=cPolarGraphPage(fparent).m_graphs;
  end;
  inherited;
end;

procedure cPolarGraph.DrawData;
begin
  inherited;
  compile;
  glCallList(fListId);
end;

function cPolarGraph.GetDrawFPLine: boolean;
begin
  result:=false;
end;

procedure cPolarGraph.SetDrawFPLine(b: boolean);
begin

end;

procedure cPolarGraph.setmainParent(p: cbaseObj);
begin
  if p is cPolarGraph then
    cPolarGraphPage(p).m_graphs.AddChild(self)
  else
    inherited;
end;

procedure cPolarGraph.compile;
var
  i, ind: integer;
  lp: point2;
begin
  if fneedrecompile then
  begin
    fneedrecompile := false;
    if fListId <> 0 then
      glDeleteLists(fListId, 1);
    fListId := glGenLists(1);
    glNewList(fListId, GL_COMPILE);
    if DrawPoints then
    begin
      glColor3fv(@fPointColor);
      glBegin(GL_Points);
      for i := 0 to count - 1 do
      begin
        lp.x := getx(i);
        lp.y := gety(i);
        glVertex2fv(@lp);
      end;
      glEnd;
    end;
    if DrawLines then
    begin
      glColor3fv(@color);
      glBegin(GL_LINE_STRIP);
      for i := 0 to count - 1 do
      begin
        lp.x := getx(i);
        lp.y := gety(i);
        glVertex2fv(@lp);
      end;
      glEnd;
    end;
    if UseFirstPoint then
    begin
      glColor3fv(@fFirstPointColor);
      glBegin(GL_Points);
      for i := 0 to FPcount - 1 do
      begin
        ind:=fpindex(i);
        if ((ind>0)) and (ind<(count - 1)) then
        begin
          lp.x := getx(ind);
          lp.y := gety(ind);
          glVertex2fv(@lp);
        end;
      end;
      glEnd;
      if drawFPLine then
      begin
        glBegin(GL_LINE_STRIP);
        for i := 0 to FPcount - 1 do
        begin
          ind:=fpindex(i);
          if ((ind>0)) and (ind<(count - 1)) then
          begin
            lp.x := getx(ind);
            lp.y := gety(ind);
            glVertex2fv(@lp);
          end;
        end;
        glEnd;
      end;
    end;
    glEndList;
  end;
end;

{ cPolarGraph1d }

procedure cPolarGraph1d.addData(const x, y: array of double; fromind: integer);
var
  l: integer;
begin
  l := length(x);
  move(x, m_xData[fromind], l * sizeof(double));
  move(y, m_yData[fromind], l * sizeof(double));
  if (fromind+l)>fUsedItems then
  begin
    fUsedItems:=fromind+l;
  end;
  fneedrecompile:=true;
end;

constructor cPolarGraph1d.create;
begin
  inherited;
  fUsedItems:=0;
end;

function cPolarGraph1d.getcapacity: integer;
begin
  result := length(m_xData);
end;

function cPolarGraph1d.getCount: integer;
begin
  result := fUsedItems;
end;

procedure cPolarGraph1d.setcapacity(i: integer);
begin
  setLength(m_xData, i);
  setLength(m_yData, i);
end;

procedure cPolarGraph1d.setCount(i: integer);
begin
  if i>capacity then
    capacity:=i;
  fUsedItems:=i;
end;

function cPolarGraph1d.getP2(i: integer): point2;
begin
  result := p2(m_xData[i], m_yData[i]);
end;

function cPolarGraph1d.getx(i: integer): double;
begin
  result := m_xData[i];
end;

function cPolarGraph1d.gety(i: integer): double;
begin
  result := m_yData[i];
end;

{ cPolarAxis }
procedure cPolarAxis.BeforeDrawChild;
var
  p:cPolarGraphPage;
begin
  inherited;
  p:=cPolarGraphPage(parent);
  p.setDrawObjVP;
  p.SetZoom;
end;

constructor cPolarAxis.create;
begin
  inherited;
  fHelper:=true;
  autocreate:=true;
end;

end.
