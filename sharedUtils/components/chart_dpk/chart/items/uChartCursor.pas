unit uChartCursor;

interface

uses
  ubtnlistview, classes, stdctrls, controls, ExtCtrls, ComCtrls, uchartevents,
  uBaseObj, utrend, uCommonTypes, sysutils, uDrawObj, opengl, upage, uaxis,
  uFrameListener, messages, windows, uCursors;

type
  cChartCursor = class;

  cCursorFrameListener = class(cFramelistener)
  public
    cursor:cChartCursor;
  protected
    cursowner:integer;
    // чувствительность к выделению мышкой
    size:integer;
    // Кусор перемещается за мышкой
    b_move,
    // мышь над курсором
    b_overCursor:boolean;
  protected
    procedure addEvents;
    procedure RemoveEvents;
    procedure OnResize(sender:tobject);
    procedure init(p_data:tobject; p_name:string);override;
    function OverCursor(mouseX:integer):boolean;
  public
    procedure WndProc(var msg:tmessage;var mouse:smousestruct);override;
    destructor destroy;
  end;

  cChartCursor = class(cdrawobj)
  public
    weight:double;
  protected
    // координаты в нормализованом окне
    fx:single;
    // положение курсора по x
    ix:integer;
    init:boolean;
  protected
    procedure setx(v:integer);
  public
    constructor create;override;
    procedure drawdata;override;
    property x:integer read ix write setx;
  end;

implementation
uses
  uchart, uBasePage;

  const
  c_dist = 2;

procedure cCursorFrameListener.init(p_data:tobject; p_name:string);
begin
  inherited;
  cursor:=cChartCursor.create;
  cursor.parent:=cchart(p_data).activepage;
  size:=3;
  b_move:=false;
  b_overCursor:=false;
  addEvents;
  cursowner:=0;
end;

function cCursorFrameListener.OverCursor(mouseX:integer):boolean;
begin
  result:=(mousex<=cursor.x+size) and (mousex>=cursor.x-size);
end;

procedure cCursorFrameListener.WndProc(var msg:tmessage;var mouse:smousestruct);
var
  p:cbasepage;
begin
  case msg.Msg of
    wm_mousemove:
    begin
      if cursor.visible then
      begin
        if not b_move then
        begin
          if OverCursor(mouse.ipos.x) then
          begin
            b_overCursor:=true;
            cchart(data).setcursor(crSize, cursowner);
          end
          else
          begin
            b_overCursor:=false;
            cchart(data).setcursor(crDefault, cursowner);
          end;
        end
        else
        begin
          cursor.x:=mouse.ipos.x;
          //cursor.fx:=mouse.pos.x;
        end;
      end;
    end;
    WM_LBUTTONDOWN:
    begin
      if b_overcursor then
        b_move:=true;
    end;
    WM_LBUTTONUP:
    begin
      b_move:=false;
    end;
    WM_KEYUP:
    // при отпускании клавиши контрол сбрасывается
    // флаг необходиvjcnb рисовать область выделения
    begin
      if integer(msg.WParam)=VK_CONTROL then
      begin

      end;
    end;
    WM_Size:
    begin
      if not cursor.init then
      begin
        p:=cchart(data).activepage;
        cursor.x:=cpage(p).bound.Left+cpage(p).GetPixelTabSpace.left;
        cursor.fx:=-1;
        cursor.init:=true;
      end;
    end;
  end;
end;

destructor cCursorFrameListener.destroy;
begin
  removeevents;
  inherited;
end;

procedure cCursorFrameListener.OnResize(sender:tobject);
begin
  cursor.setx(cursor.ix);
end;

procedure cCursorFrameListener.RemoveEvents;
begin
  cchart(data).objmng.events.removeEvent(OnResize, e_onResize);
end;

procedure cCursorFrameListener.addEvents;
begin
  cchart(data).objmng.events.AddEvent('OnResizeCursorFrame', e_onResize, OnResize);
end;

procedure cChartCursor.drawdata;
var
  p:cpage;
  a:cAxis;
  w:double;
begin
  // GL_LINE_WIDTH_RANGE GL_LINE_WIDTH_GRANULARITY
  glGetDoublev(GL_LINE_WIDTH,@w);
  glLineWidth(weight);
  p:=cpage(getpage);
  a:=p.activeAxis;
  glColor3fv(@color);
  // установка типа линии (пунктир)
  glLineStipple (1, $F0F0);
  glEnable (GL_LINE_STIPPLE);
  glMatrixMode(gl_projection);
  glpushmatrix;
  glloadidentity;
  glbegin(gl_lines);
    glvertex(fx,-1);
    glvertex(fx,1);
  glend;
  glDisable (GL_LINE_STIPPLE);
  glpopmatrix;
  glLineWidth(w);
end;

constructor cChartCursor.create;
var
  cursorframe:cCursorFrameListener;
begin
  inherited;
  weight:=2;
  Color:=red;
  ix:=-1;
  fx:=-1;
  init:=false;
  imageindex:=c_Cross_Img;
end;

procedure cChartCursor.setx(v:integer);
var
  page:cpage;
begin
  page:=cpage(cChart(chart).activepage);
  //page.GetViewport(viewport);
  if v<page.m_viewport[0] then
    v:=page.m_viewport[0]+c_dist;
  if v>page.m_viewport[0]+page.m_viewport[2] then
    v:=page.m_viewport[0]+page.m_viewport[2]-c_dist;
  ix:=v;
  if chart=nil then exit;
  if v>=0 then
  begin
    fx:=2*(v-page.m_viewport[0])/(page.m_viewport[2])-1;
    cChart(chart).legend.needUpdate:=true;
    cChart(chart).needRedraw:=true;
  end;
end;

end.
