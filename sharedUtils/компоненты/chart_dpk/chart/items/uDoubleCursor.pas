unit uDoubleCursor;

interface

uses
  ubtnlistview, classes, stdctrls, controls, ExtCtrls, ComCtrls, uchartevents,
  uBaseObj, utrend, ucommonmath, uCommonTypes, sysutils, uDrawObj, opengl,  uaxis,
  uFrameListener, messages, windows, uCursors, ulogFile;

type
  cDoubleCursor = class;

  cDoubleCursorFrameListener = class(cFramelistener)
  public
  protected
    cursowner:integer;
    // ���������������� � ��������� ������
    size:integer;
    // ����� ������������ �� ������
    b_move,
    // ���� ��� ��������
    b_overCursor:boolean;
    // ���������� ��� ����� �������� ����.
    iovercursor:integer;
  protected
    procedure addEvents;
    procedure RemoveEvents;
    procedure OnResize(sender:tobject);
    procedure OnResizeOrScale(sender:tobject);
    procedure init(p_data:tobject; p_name:string);override;
    function OverCursor(mouse:tpoint):boolean;overload;
    function Getcursor:cDoubleCursor;
  public
    procedure WndProc(var msg:tmessage;var mouse:smousestruct);override;
    destructor destroy;
  end;

  cDoubleCursor = class(cdrawobj)
  public
    weight1:double;
    weight2:double;
  public
    // ���������� � ��������� (��������)
    // ����������� ��� �������� �������, ��������� �� fx1, fx2
    // (������� �� ������������ ��������� �� ��� ��� ���������)
    m_lgx1, m_lgx2:double;
  private
    fmagniteObj:cDrawObj;
  protected
    // ���������� � �������� ����. ��������� �� ���
    fx1, fx2:single;
    // ��������� ������� �� x
    ix1,
    ix2:integer;
    init:boolean;
    // ��� ������� ��������� ��� �������
    fcursortype:integer;
    // �������� ����� �� y
    b_drawYLine:boolean;
    fmagniteMin,fmagniteMax,
    fAbsScreenMode:boolean;
    // ���������������� ������� ����� X
    fmagniteValue:double;
    fmagniteValuePix:integer;
  protected
    procedure fsetx1(v:integer);overload;
    procedure fsetx2(v:integer);overload;
    procedure setCursorType(ftype:integer);
    procedure procdrawYLine(tr:ctrend);
    procedure setDrawYLine(b:boolean);
    function getDrawYLine:boolean;
    function GetPage:cdrawobj;
    procedure setMagnitudeObj(o:cdrawobj);
  public
    function dx:single;
  public
    constructor create;override;
    destructor destroy;override;
    procedure drawdata;override;
    procedure setLgx1(v:single);
    procedure setLgx2(v:single);
    function LgPosToLinear(lgpos:double):double;
    function LinearToLgPos(LinearPos:double):double;
    procedure setx1(v:single);overload;
    procedure setx2(v:single);overload;
    // �������� �� ������� ���������
    function getx1:single;
    function getx2:single;
    // �������� �������� fx1 � fx2
    function getFx1:single;
    function getFx2:single;
    property x1:integer read ix1 write fsetx1;
    property x2:integer read ix2 write fsetx2;
    // ���������� ����� �� ������ ��������� ������� ��� ��������� ���� (����������)
    // ������������ ���� ��� ���������� ���� true
    property AbsScreenMode:boolean read fAbsScreenMode write fAbsScreenMode;
    property cursortype:integer read fcursortype write setcursortype;
    property drawYline:boolean read getDrawYLine write setDrawYLine;
    property magniteMin:boolean read fmagniteMin write fmagniteMin;
    property magniteMax:boolean read fmagniteMax write fmagniteMax;
    property magniteValue:double read fmagniteValue write fmagniteValue;
    property magniteObj:cdrawobj read fmagniteObj write setMagnitudeObj;
  end;

  const
    c_SingleCursor = 0;
    c_DoubleCursor = 1;

implementation
uses
  uchart, upage, ubasepage, ubasicTrend;

  const
    c_dist = 2;



procedure cDoubleCursorFrameListener.init(p_data:tobject; p_name:string);
begin
  inherited;
  size:=3;
  b_move:=false;
  b_overCursor:=false;
  addEvents;
  cursowner:=cchart(data).GenCursOwnerName;
end;

function cDoubleCursorFrameListener.OverCursor(mouse:tpoint):boolean;
var
  a:caxis;
  p:cpage;
  lsize,x:single;
  tabs:trect;
  b:boolean;
  cursor:cDoublecursor;
begin
  result:=false;
  cursor:=getcursor;
  // ��� 1-� ��������?
  if not cursor.fAbsScreenMode then
  begin
    p:=cpage(cChart(data).activepage);
    b:=p.MouseInPage(mouse);
    if b then
    begin
      if (mouse.x<=cursor.x1+size) and (mouse.x>=cursor.x1-size) then
      begin
        iovercursor:=1;
        result:=true;
      end;
      if cursor.cursortype=c_DoubleCursor then
      begin
        // ��� 2-� ��������?
        if (mouse.x<=cursor.x2+size) and (mouse.x>=cursor.x2-size) then
        begin
          iovercursor:=2;
          result:=true;
        end;
      end;
    end;
  end
  else
  begin
    p:=cpage(cChart(data).activepage);
    tabs:=p.GetPixelTabSpace;
    b:=p.MouseInPage(mouse);
    if b then
    begin
      a:=p.activeAxis;
      if a=nil then // ��������� � ��������������� ����������
      begin
        x:=p.p2iTop2(point(mouse.x,0)).x;
        lsize:=p.p2iToP2(point(size,0)).x;
      end
      else
      begin
        p.setDrawObjVP;
        x:=p.p2iToTrend(point(mouse.x,0),a).x;
        lsize:=p.PixelSizeToTrend(point(size,0),a).x;
        //p.Caption:=floattostr(x);
      end;
      if (x<=cursor.fx1+lsize) and (x>=cursor.fx1-lsize) then
      begin
        iovercursor:=1;
        result:=true;
      end;
      if cursor.cursortype=c_DoubleCursor then
      begin
        // ��� 2-� ��������?
        if (x<=cursor.fx2+lsize) and (x>=cursor.fx2-lsize) then
        begin
          iovercursor:=2;
          result:=true;
        end;
      end;
    end;
  end;
end;

function cDoubleCursorFrameListener.Getcursor:cDoubleCursor;
Var
  page:cdrawobj;
begin
  result:=nil;
  if cChart(data)<>nil then
  begin
    page:=cChart(data).activepage;
    if page<>nil then
    begin
      if page is cpage then
      begin
        result:=cpage(page).cursor;
      end;
    end;
  end;
end;

function GetMax(c:cDoubleCursor; X:double; var ind:integer):double;
var
  y:double;
  p:cpage;
  a:caxis;
  t:cbasictrend;
  lo, hi:integer;
  I: Integer;
begin
  ind:=-1;
  p:=cpage(c.getpage);
  a:=p.activeAxis;
  t:=cbasictrend(c.magniteObj);
  if p.LgX then
  begin
    x:=ValToLogScale(x,p2d(a.min.x,a.max.x));
  end;
  if t<>nil then
  begin
    lo:=t.GetLowInd(x-c.fmagniteValue);
    if lo=-1 then
    begin
      ind:=-1;
      exit;
    end;
    hi:=t.GetHiInd(x+c.fmagniteValue);
    result:=t.getP2(LO).y;

    for I := lo+1 to hi do
    begin
      y:=t.getP2(i).y;
      if y>result then
      begin
        result:=y;
        ind:=i;
      end;
    end;
  end
  else
    ind:=-1;
end;

function GetMin(c:cDoubleCursor; X:double;var ind:integer):double;
var
  y:double;
  p:cpage;
  a:caxis;
  t:cbasictrend;
  lo, hi:integer;
  I: Integer;
begin
  ind:=-1;
  p:=cpage(c.getpage);
  a:=p.activeAxis;
  t:=cbasictrend(c.magniteObj);
  result:=0;
  if t=nil then
    exit;
  if t.count=0 then
  begin
    result:=0;
    ind:=-1;
    exit;
  end;
  if t<>nil then
  begin
    lo:=t.GetLowInd(x-c.fmagniteValue);
    hi:=t.GetHiInd(x+c.fmagniteValue);
    if t.Count>0 then
    begin
      if (lo>-1) and (hi<(t.count-1)) then
      begin
        result:=t.GetP2(LO).y;
        for I := lo+1 to hi do
        begin
          y:=t.GetP2(i).y;
          if y<result then
          begin
            result:=y;
            ind:=i;
          end;
        end;
      end;
    end;
  end
  else
    ind:=-1;
end;


procedure cDoubleCursorFrameListener.WndProc(var msg:tmessage;var mouse:smousestruct);
var
  cursor:cdoublecursor;
  I: Integer;
  page:cdrawobj;
  p:cpage;
  a:caxis;
  t:cbasictrend;
  range, sens:double;
  ind:integer;
  // ������� �� ������ ��� � �������� ���������
  commonalg:boolean;
  newpos:double;
begin
  cursor:=getcursor;
  if cursor=nil then exit;
  case msg.Msg of
    wm_mousemove:
    begin
      if cursor.visible then
      begin
        if not b_move then
        begin
          frList.ControlFrame:=nil;
          if OverCursor(mouse.iPos_inv) then
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
          commonalg:=true;
          frList.ControlFrame:=self;
          // ������ �� ����������
          if cursor.magniteMin or cursor.magniteMax then
          begin
            p:=cpage(cursor.GetPage);
            a:=p.activeAxis;
            t:=cbasictrend(cursor.magniteObj);
            if t=nil then
            begin
              for I := 0 to a.childcount - 1 do
              begin
                if a.getChild(i) is cbasictrend then
                begin
                  t:=cbasictrend(a.getChild(i));
                  if t.visible then
                  begin
                    cursor.magniteObj:=t;
                    break;
                  end;
                end;
              end;
            end;
            // ���� �������
            if GetKeyState(VK_CONTROL)<0 then
            begin
              GetMin(cursor, mouse.activeAxisPos.x, ind);
              commonalg:=false;
              if ind<>-1 then
                newpos:=t.getp2(ind).x
              else
                commonalg:=true;
            end;
            //peekMessage();
            // ���� ��������
            if ShiftKeyDown then
            begin
              //p:=cpage(cursor.GetPage);
              //p.Caption:='����';

              commonalg:=false;
              GetMax(cursor, mouse.activeAxisPos.x, ind);
              if ind<>-1 then
              begin
                if p.lgx then
                begin
                  newpos:=evalLogPos(a.min.x, a.max.x, t.getp2(ind).x);
                end
                else
                begin
                  newpos:=t.getp2(ind).x
                end;
              end
              else
                commonalg:=true;
            end
            else
            begin
              //p.Caption:='�� ����';
            end;
          end;
          // ������� ������
          case iovercursor of
            1:
            begin
              if commonalg then
                cursor.x1:=mouse.ipos.x
              else
                cursor.setx1(newpos);
            end;
            2:
            begin
             if commonalg then
               cursor.x2:=mouse.ipos.x
             else
               cursor.setx2(newpos);
            end;
          end;
          // ���� �������� ������ ������
          if iovercursor=1 then
          begin
            cchart(data).objmng.events.CallAllEventsWithSender(e_OnMoveCursor,cursor);
          end;
          // ���� �������� ������ ������
          if iovercursor=2 then
          begin
            cchart(data).objmng.events.CallAllEventsWithSender(e_OnMoveCursor2,cursor);
          end;
        end;
      end;
    end;
    WM_LBUTTONDOWN:
    begin
      if b_overcursor then
        b_move:=true;
      //p:=cpage(cursor.GetPage);
      //p.Caption:=modname(p.Caption, false);
    end;
    WM_LBUTTONUP:
    begin
      b_move:=false;
    end;
    WM_KEYUP:
    // ��� ���������� ������� ������� ������������
    // ���� ��������vjcnb �������� ������� ���������
    begin
      if integer(msg.WParam)=VK_CONTROL then
      begin

      end;
    end;
    WM_Size:
    begin
      for I := 0 to cchart(data).activetab.ChildCount - 1 do
      begin
        page:=cchart(data).GetPage(i);
        if page is cpage then
        begin
          cursor:=cpage(page).cursor;
          if cursor<>nil then
          begin
            if not cursor.init then
            begin
              cursor.x1:=cpage(cchart(data).activepage).bound.Left+
                         cpage(cchart(data).activepage).GetPixelTabSpace.left;
              cursor.fx1:=-1;
              cursor.x2:=cpage(cchart(data).activepage).bound.Right-
                         cpage(cchart(data).activepage).GetPixelTabSpace.left;
              cursor.fx2:=1;
              cursor.init:=true;
            end;
          end;
        end;
      end;
    end;
  end;
end;

destructor cDoubleCursorFrameListener.destroy;
begin
  removeevents;
  inherited;
end;

procedure cDoubleCursorFrameListener.OnResize(sender:tobject);
var
  cursor:cdoublecursor;
  page:cbasepage;
  I: Integer;
begin
  for I := 0 to cchart(data).activetab.ChildCount - 1 do
  begin
    page:=cchart(data).GetPage(i);
    cursor:=cpage(page).cursor;
    if page is cpage then
    begin
      if cursor.AbsScreenMode then
      begin
        cursor.fsetx1(cursor.ix1);
        cursor.fsetx2(cursor.ix2);
      end;
      // ��������� ����������������
      if cpage(page).activeAxis<>nil then
        cursor.fmagniteValue:=cpage(page).PixelSizeToTrend(point(cursor.fmagniteValuePix,0),
                            cpage(page).activeAxis).x;
    end;
  end;
end;

procedure cDoubleCursorFrameListener.OnResizeOrScale(sender:tobject);
var
  cursor:cdoublecursor;
  page:cbasepage;
  a:caxis;
  I: Integer;
begin
  if cchart(data).activetab<>nil then
  begin
    for I := 0 to cchart(data).activetab.ChildCount - 1 do
    begin
      page:=cchart(data).GetPage(i);
      cursor:=cpage(page).cursor;
      if page is cpage then
      begin
        // ��������� ����������������
        cursor.fmagniteValue:=cpage(page).PixelSizeToTrend(
                              point(cursor.fmagniteValuePix,0),
                              cpage(page).activeAxis).x;
      end;
      if cpage(page).lgx then
      begin
        // ������������� ������ � ��������������� ���
        a:=cpage(page).activeAxis;
        if a<>nil then
        begin
          if (a.min.x<cursor.m_lgx1) and (cursor.m_lgx1<a.max.x) then
          begin
            cursor.setx1(cursor.LgPosToLinear(cursor.m_lgx1));
          end;
          if (a.min.x<cursor.m_lgx2) and (cursor.m_lgx2<a.max.x) then
          begin
            cursor.setx2(cursor.LgPosToLinear(cursor.m_lgx2));
          end;
        end;
      end;
    end;
  end;
end;

function cDoubleCursor.LgPosToLinear(lgpos:double):double;
var
  p:cpage;
  a:caxis;
begin
  p:=cpage(getpage);
  a:=p.activeAxis;
  result:=0;
  if a<>nil then
  begin
    if (a.min.x<lgpos) and (lgpos<a.max.x) then
    begin
      result:=LogValToLinearScale(lgpos,p2d(a.min.x,a.max.x));
    end;
  end;
end;

function cDoubleCursor.LinearToLgPos(LinearPos:double):double;
var
  p:cpage;
  a:caxis;
begin
  p:=cpage(getpage);
  a:=p.activeAxis;
  result:=0;
  if a<>nil then
  begin
    result:=ValToLogScale(LinearPos,p2d(a.min.x,a.max.x));
  end;
end;

procedure cDoubleCursorFrameListener.RemoveEvents;
begin
  cchart(data).objmng.events.removeEvent(OnResize, e_onResize);
  cchart(data).objmng.events.removeEvent(OnResizeOrScale, e_onResize+e_OnChangeAxisScale);
end;

procedure cDoubleCursorFrameListener.addEvents;
begin
  cchart(data).objmng.events.AddEvent('OnResizeDoubleCursorFrame', e_onResize, OnResize);
  cchart(data).objmng.events.AddEvent('OnResizeOrScale', e_onResize+e_OnChangeAxisScale,
                                      OnResizeOrScale);
end;

procedure cDoubleCursor.drawdata;
var
  p:cpage;
  a:cAxis;
  w:double;
  I,j: Integer;
  tr:cdrawobj;
  // �������� �������� �� y ��� ���������
  dy:point2;
begin
  // GL_LINE_WIDTH_RANGE GL_LINE_WIDTH_GRANULARITY
  glGetDoublev(GL_LINE_WIDTH,@w);
  glLineWidth(weight1);
  p:=cpage(getpage);
  p.setDrawObjVP;
  a:=p.activeAxis;
  glColor3fv(@color);
  // ��������� ���� ����� (�������)
  glLineStipple (1, $F0F0);
  glEnable (GL_LINE_STIPPLE);
  glMatrixMode(gl_projection);
  glpushmatrix;
  if AbsScreenMode then
  begin
    if a<>nil then
    begin
      a.loadstate;
      dy:=p2(a.min.y,a.max.y);
    end;
  end
  else
  begin
    dy:=p2(-1,1);
    glloadidentity;
  end;
  glbegin(gl_lines);
    glvertex(fx1,dy.x);
    glvertex(fx1,dy.y);
  glend;
  if cursortype=c_doubleCursor then
  begin
    glLineWidth(weight2);
    glbegin(gl_lines);
      glvertex(fx2,dy.x);
      glvertex(fx2,dy.y);
    glend;
  end;
  glDisable (GL_LINE_STIPPLE);
  if b_drawYLine then
  begin
    glLineWidth(1);
    for I := 0 to p.getAxisCount - 1 do
    begin
      a:=p.getaxis(i);
      for j := 0 to a.childCount - 1 do
      begin
        tr:=cdrawobj(a.getChild(j));
        if tr is ctrend then
        begin
          procdrawYLine(ctrend(tr));
        end;
      end;
    end;
  end;
  glLineWidth(w);
  glpopmatrix;
end;

constructor cDoubleCursor.create;
begin
  inherited;
  fmagniteObj:=nil;
  fmagniteMax:=true;
  fmagniteMin:=true;
  fmagniteValuePix:=5;
  fAbsScreenMode:=true;
  cursortype:=c_SingleCursor;
  weight1:=2;
  weight2:=1;
  Color:=red;
  ix1:=-1;
  fx1:=-1;
  ix2:=-1;
  fx2:=-1;
  init:=false;
  imageindex:=c_Cross_Img;
end;

destructor cDoubleCursor.destroy;
begin
  inherited;
end;

procedure cDoubleCursor.setx1(v:single);
var
  a:caxis;
  page:cpage;
begin
  entercs;
  if fAbsScreenMode then
  begin
    page:=cpage(getpage);
    a:=page.activeAxis;
    if (v>a.min.x) and (v<a.max.x) then
    begin
      fx1:=v;
      ix1:=a.XToXi(v);
      cChart(chart).legend.NeedUpdate:=true;
      cChart(chart).needRedraw:=true;
    end
    else
    begin
      fx1:=v;
    end;
  end;
  cChart(chart).needRedraw:=true;
  exitcs;
end;

procedure cDoubleCursor.setx2(v:single);
var
  a:caxis;
  page:cpage;
begin
  entercs;
  if fAbsScreenMode then
  begin
    page:=cpage(getpage);
    a:=page.activeAxis;
    if (v>a.min.x) and (v<a.max.x) then
    begin
      fx2:=v;
      ix2:=a.XToXi(v);
      cChart(chart).legend.NeedUpdate:=true;
      cChart(chart).needRedraw:=true;
    end
    else
    begin
      fx2:=v;
    end;
  end;
  cChart(chart).needRedraw:=true;
  exitcs;
end;

procedure cDoubleCursor.fsetx1(v:integer);
var
  page:cpage;
  a:caxis;
  p1, p2:point2d;
begin
  entercs;
  page:=cpage(getpage);
  //page.GetViewport(viewport);
  if v<page.m_viewport[0] then
    v:=page.m_viewport[0]+c_dist;
  if v>page.m_viewport[0]+page.m_viewport[2] then
    v:=page.m_viewport[0]+page.m_viewport[2]-c_dist;
  ix1:=v;
  if chart=nil then exit;
  if v>=0 then
  begin
    if not fAbsScreenMode then
      fx1:=2*(v-page.m_viewport[0])/(page.m_viewport[2])-1
    else
    begin
      a:=page.activeAxis;
      if a<>nil then
      begin
        fx1:=page.p2iToTrend(point(v,0),a).x;
      end;

      if page.lgx then
      begin
        m_lgx1:=ValToLogScale(fx1, p2d(page.activeAxis.min.x,page.activeAxis.max.x));
        m_lgx2:=ValToLogScale(fx2, p2d(page.activeAxis.min.x,page.activeAxis.max.x));
      end;
    end;
    if cChart(chart).legend<>nil then
    begin
      cChart(chart).legend.NeedUpdate:=true;
    end;
    cChart(chart).needRedraw:=true;
  end;
  exitcs;
end;

procedure cDoubleCursor.fsetx2(v:integer);
var
  page:cpage;
  a:caxis;
begin
  entercs;
  page:=cpage(getpage);
  if v<page.m_viewport[0] then
    v:=page.m_viewport[0]+c_dist;
  if v>page.m_viewport[0]+page.m_viewport[2] then
    v:=page.m_viewport[0]+page.m_viewport[2]-c_dist;
  ix2:=v;
  if chart=nil then exit;
  if v>=0 then
  begin
    if not fAbsScreenMode then
      fx2:=2*(v-page.m_viewport[0])/(page.m_viewport[2])-1
    else
    begin
      a:=page.activeAxis;
      if a<>nil then
        fx2:=page.p2iToTrend(point(v,0),a).x;
    end;
    if cChart(chart).legend<>nil then
    begin
      cChart(chart).legend.NeedUpdate:=true;
    end;
    cChart(chart).needRedraw:=true;
  end;
  exitcs;  
end;

procedure cDoubleCursor.setCursorType(ftype:integer);
begin
  fcursortype:=ftype;
  if cChart(chart)<>nil then
  begin
    cChart(chart).legend.NeedUpdate:=true;
    cChart(chart).redraw;
  end;
end;

function cDoubleCursor.getDrawYLine:boolean;
begin
  result:=b_drawYLine;
end;

function cDoubleCursor.getFx1: single;
begin
  result:=fx1;
end;

function cDoubleCursor.getFx2: single;
begin
  result:=fx2;
end;

procedure cDoubleCursor.setDrawYLine(b:boolean);
begin
  b_drawYLine:=b;
  cChart(chart).needRedraw:=true;
end;

procedure cDoubleCursor.setLgx1(v: single);
var
  p:cpage;
begin
  m_lgx1:=v;
  p:=cpage(getpage);
  if p.lgx then
  begin
    setx1(m_lgx1);
  end;
end;

procedure cDoubleCursor.setLgx2(v: single);
var
  p:cpage;
begin
  m_lgx2:=v;
  p:=cpage(getpage);
  if p.lgx then
  begin
    setx2(m_lgx2);
  end;
end;

procedure cDoubleCursor.setMagnitudeObj(o: cdrawobj);
begin
  fmagniteObj:=o;
end;

procedure cDoubleCursor.procdrawYLine(tr:ctrend);
var
  x,y1,y2:single;
  page:cpage;
  p:point2;
  a:caxis;
begin
  page:=cpage(getpage);
  if page<>nil then
  begin
    // ��������� ������� x � ������� (��������� ��� �� �����
    // �� x ��������������� ������)
    //x:=page.iXToTrend(ix1);
    x:=fx1;
    // ������� ������� y
    y1:=tr.GetY(x);
    if fAbsScreenMode then
    begin
      p:=p2(x,y1);
    end
    else
    begin
      // ������� � ��������� ��������� ������
      p:=page.TrendPToP2(p2(x,y1),caxis(tr.parent));
    end;
    a:=page.activeAxis;
    // ������
    glColor3fv(@tr.color);
    glbegin(gl_lines);
      glvertex(a.min.x,p.y);
      glvertex(a.max.x,p.y);
    glend;
    // ������� ������� y
    if fcursortype=c_DoubleCursor then
    begin
      //x:=page.iXToTrend(ix2);
      x:=fx2;
      y2:=tr.GetY(x);
      if fAbsScreenMode then
      begin
        p:=p2(x,y2);
      end
      else
      begin
        // ������� � ��������� ��������� ������
        p:=page.TrendPToP2(p2(x,y2),caxis(tr.parent));
      end;
      // ������
      glbegin(gl_lines);
        glvertex(a.min.x,p.y);
        glvertex(a.max.x,p.y);
      glend;
    end;
  end;
end;

function cDoubleCursor.dx:single;
begin
  result:=fx2-fx1;
end;

function cDoubleCursor.getx1:single;
var
  page:cpage;
begin
  page:=cpage(getpage);
  result:=page.iXToTrend(x1);
end;

function cDoubleCursor.getx2:single;
var
  page:cpage;
begin
  page:=cpage(getpage);
  result:=page.iXToTrend(x2);
end;

function cDoubleCursor.GetPage:cdrawobj;
begin
  result:=cpage(parent);
end;



end.
