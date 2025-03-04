unit uYCursor;

interface
uses
  ubtnlistview, classes, stdctrls, controls, ExtCtrls, ComCtrls, uchartevents,
  uBaseObj, utrend, ucommonmath, uCommonTypes, sysutils, uDrawObj, opengl,  uaxis,
  upage, uchart, uEventList,
  uFrameListener, messages, windows, uCursors, ulogFile;

type
  cYCursor = class (cMoveObj)
  private
    // чувствительность в пикселях
    m_dist:single;
    // положение курсора по Y в координатах -1..1
    m_pos:single;
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
    procedure SetPos(p: point2); override;
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

procedure cYCursor.EvalBound;
begin
  boundrect.BottomLeft.x:=-1;
  boundrect.TopRight.x:=1;
  boundrect.BottomLeft.y:=m_pos-m_dist;
  boundrect.TopRight.y:=m_pos+m_dist;
end;


function cYCursor.GetPos: point2;
begin
  result.y:=m_pos;
end;

procedure cYCursor.linc(p_chart: tcomponent);
begin
  inherited;

end;

procedure cYCursor.SetPos(p: point2);
begin
  m_pos:=p.y;
  needUpdateBound:=true;
  EvalBound;
end;

function cYCursor.TestObj(p2: point2; dist: single): boolean;
begin
  //m_dist:=dist;
  result:=false;
  if p2.y-m_pos<dist then
  begin
    result:=true;
  end;
end;

end.
