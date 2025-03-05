unit uYCursor;

interface
uses
  ubtnlistview, classes, stdctrls, controls, ExtCtrls, ComCtrls, uchartevents,
  uBaseObj, utrend, ucommonmath, uCommonTypes, sysutils, uDrawObj, opengl,  uaxis,
  upage, uchart, uEventList, ubasepage,
  uFrameListener, messages, windows, uCursors, ulogFile;

type
  cYCursor = class (cMoveObj)
  private
    // чувствительность в пикселях
    m_dist:single;
    // положение курсора по Y в координатах -1..1
    // вьюпорт с учетом отступов!
    m_pos,
    M_fullViewportPos:single;
    cursowner:integer;
    // чувствительность к выделению мышкой
    size:integer;
    // Кусор перемещается за мышкой
    b_move,
    // мышь над курсором
    b_overCursor:boolean;
  protected
    procedure linc(p_chart: tcomponent); override;
    procedure DoOnMove(p: point2);override;
    function GetPos: point2; override;
    // в событии mouseMove setpos в координатах FullViewPort
    procedure SetPos(p: point2); override;
    // надо возвращать Bound в вьюпорте без учета отступов для корректной работы
    // выбора мышкой!!!
    procedure EvalBound; override;
    procedure drawdata;override;
    function TestObj(p2: point2; dist: single): boolean; override;
  public
    constructor create;override;
  end;

const
  c_weight = 1;


implementation

{ cYCursor }

constructor cYCursor.create;
begin
  inherited;
  needUpdateBound:=true;
  m_pos:=0.5;
  Color:=red;
  locked:=false;
  enabled:=true;
  selectable:=true;
end;


procedure cYCursor.DoOnMove(p: point2);
begin
  inherited;
  cchart(fchart).OBJmNG.events.CallAllEventsWithSender(e_OnMoveCursorY, self);
end;

procedure cYCursor.drawdata;
var
  p:cpage;
  a:cAxis;
  w:double;
  I,j: Integer;
  tr:cdrawobj;
  // минимуми максимум по y при отрисовке
  dy:point2;
begin
  // GL_LINE_WIDTH_RANGE GL_LINE_WIDTH_GRANULARITY
  glGetDoublev(GL_LINE_WIDTH,@w);
  glLineWidth(c_weight);
  p:=cpage(getpage);
  p.setDrawObjVP;
  glColor3fv(@color);
  // установка типа линии (пунктир)
  glLineStipple (1, $F0F0);
  glEnable (GL_LINE_STIPPLE);
  glbegin(gl_lines);
    glvertex(-1,m_pos);
    glvertex(1,m_pos);
  glend;
  glDisable (GL_LINE_STIPPLE);
  glLineWidth(w);
end;

function ReEvalPosFromBorderViewtoFullView(p:point2; page:cpage):point2;
var
  xScale, yScale:single;
begin
  // лев нижн x,y, width, height
  yScale:=page.m_viewport[3]/ page.m_NormalViewport[3];
  xScale:=page.m_viewport[2]/ page.m_NormalViewport[2];
  result.x:=page.m_TabSpace.BottomLeft.x+xScale*p.x;
  result.y:=page.m_TabSpace.BottomLeft.y+xScale*p.y;
end;

function ReEvalPosYFromBorderViewtoFullView(p:single; page:cpage):single;
var
  yScale:single;
begin
  // лев нижн x,y, width, height
  yScale:=page.m_viewport[3]/ page.m_NormalViewport[3];
  result:=page.m_TabSpace.BottomLeft.y+yScale*(p+1);
end;


procedure cYCursor.EvalBound;
begin
  boundrect.BottomLeft.x:=-1;
  boundrect.TopRight.x:=1;
  M_fullViewportPos:=ReEvalPosYFromBorderViewtoFullView(m_pos,cpage(getpage));
  boundrect.BottomLeft.y:=M_fullViewportPos-m_dist;
  boundrect.TopRight.y:=m_fullViewportPos+m_dist;
end;


function cYCursor.GetPos: point2;
begin
  result.y:=ReEvalPosYFromBorderViewtoFullView(m_pos, cpage(getpage));
  result.x:=1;
end;

procedure cYCursor.linc(p_chart: tcomponent);
begin
  inherited;

end;

procedure cYCursor.SetPos(p: point2);
begin
  p:=cbasepage(getpage).p2FullViewToBorderP2(p);
  m_pos:=p.y;
  needUpdateBound:=true;
  EvalBound;
end;

function cYCursor.TestObj(p2: point2; dist: single): boolean;
begin
  //m_dist:=dist;
  result:=false;
  //if p2.y-m_pos<dist then
  if p2.y-M_fullViewportPos<dist then
  begin
    result:=true;
  end;
end;

end.
