unit uBasePage;

interface

uses ubaseobj, udrawobj, uTrend, uCommonTypes, opengl, uOglExpFunc, classes, stdctrls,
     Graphics, windows, uAxis, messages, utext, sysutils, uEventList, mathfunction,
     uChartEvents, uPoint, dialogs, types, controls, forms, uAlignEdit,
     uDoubleCursor, usimpleobjects, NativeXML, uMatrix;

type

  cBasePage = class(cdrawobj)
  public
    // левый нижний угол поля просмотра и верхний правый угол
    m_TabSpace:fRect;
    // Цвет сетки
    BorderColor:point3;
    // отступ в пикселях
    m_pixelTabSpace:trect;
    // вьюпорт отрисовываемого объекта. С учетом отсутпов для осей x, y, width, heigth
    // (x, y - левый нижний угол)
    m_viewport:array[0..3] of glint;
    // весь вьюпорт окна
    m_NormalViewport:array[0..3] of glint;
    // матрица вида
    m_view:array[0..15] of double;
    fRelativeBound:frect;
    ibound:trect;
    // оконные свойства
    fdrag,
    fEditable, // позволяет редактировать - перемещать и ресайзить
    fDblClick:boolean;
    fDragBegin,
    fDragEnd:tpoint;
    fMin,fMax:point2;
  protected
    function getRelBound:frect;
    procedure setRelBound(r:frect);
    // получить границы чарта в которых можно рисовать страницу
    function getClientBound:trect;
    procedure drawBound;
    // отрисовка фона страницы
    procedure drawPageField;
    // привязать относительные координаты к новым размерам окна
    procedure EvalRelativeBound(b:trect);
    function GetIBound:trect;
    procedure GetNormalViewport(var v:array of glint);
    procedure GetViewport(var v:array of glint);
    procedure BeforeDrawChild;override;
  protected
    procedure setBound(rect:trect);virtual;
    procedure SetTabSpace(rect:trect);virtual;
  public
    // страница является носителем других элементов и может становиться главной
    // страницый CHART.ACTIVEPAGE
    function isCarrier:boolean;virtual;
    procedure SetView(min,max:point2);
    // происходит по клику на оконном компоненте
    // i_p - координаты относительно верхнего угла. f_p Координаты в мире окна
    procedure DoClick(i_p:tpoint;f_p:point2);virtual;
    // происходит когда курсор пролетает над компонентом
    // i_p - клиентские коодинаты всего чарта
    procedure DoMouseMove(i_p:tpoint;f_p:point2);virtual;
    procedure DoButtonUp(i_p:tpoint;f_p:point2);virtual;
    procedure DoKeyDowne(key:word);virtual;
    procedure DoDblClick(i_p:tpoint;f_p:point2);virtual;
    // происходит при выходе мыши за пределы окна
    procedure DoOnExit;virtual;
    // Мышь в пределах окна (скармливать mouse_inv)
    function MouseInPage(point:tpoint):boolean;
    // Переводит координаты чарта в координаты тренда
    // function GetZoomRect(TranslateRect:frect):fRect;
    // переводит пиксельную точку в нормализованные координаты чарта
    function p2iTop2(p:tpoint):point2;overload;
    // localViewport - true если вьюпорт учитывающий поля
    function p2iTop2(p:tpoint; const view:array of double; localViewport:boolean):point2;overload;
    //скармливаются нормализованные координаты чарта
    function p2ToP2i(p:point2):tpoint;
    // координаты мира в координаты -1..+1
    function realXToX1(x1x2: point2): point2;
    // Установить вьюпорт отрисовки трендов
    procedure setDrawObjVP;
    procedure setCommonVP;
    // привязать относительные координаты к новым размерам окна
    procedure updateRelativeBound;
    // ширина и высота области отрисовки чарта
    function getwidth:integer;
    function getheight:integer;
  public
    property Relativebound:frect read getRelBound write setRelBound;
    // поля с учетом компонент
    property bound:trect read getIbound write setbound;
    constructor create;override;
  end;

  const
    pi = 3.14159265;
    // Обусчловлен изменением размеров текста из за меньших размеров
    // окна вывода (вьюпорта)
    identMatrix4d: array [0..15] of double = (1,0,0,0 ,0,1,0,0, 0,0,1,0, 0,0,0,1);

implementation
uses uChart, uCommonMath, uPageMng, upage;

procedure cBasePage.GetNormalViewport(var v:array of glint);
begin
  v[0]:=ibound.Left;
  v[1]:=ibound.bottom;
  v[2]:=getwidth;
  v[3]:=getheight;
end;

function cBasePage.getwidth:integer;
begin
  result:=ibound.Right - ibound.left;
end;

function cBasePage.isCarrier: boolean;
begin
  result:=false;
end;

function cBasePage.getheight:integer;
begin
  result:=ibound.top - ibound.bottom;
end;

function cBasePage.getibound:trect;
begin
  result:=ibound;
end;

function cBasePage.getClientBound:trect;
begin
  result:=cPageMng(parent).getClientBound;
end;

procedure cBasePage.drawBound;
var
  width,w:double;
begin
  glcolor3fv(@BorderColor);
  glGetDoubleV(GL_LINE_WIDTH,@w);
  width:=2;
  glLineWidth(width);
  glbegin(GL_LINE_STRIP);
    glvertex2f(-1,-1);
    glvertex2f(-1,1);
    glvertex2f(1,1);
    glvertex2f(1,-1);
    glvertex2f(-1,-1);
  glend;
  glLineWidth(w);
end;

function cBasePage.getRelBound:frect;
begin
  result:=fRelativeBound;
end;

procedure cBasePage.setRelBound(r:frect);
begin
  fRelativeBound:=r;
  updateRelativeBound;
end;


procedure cBasePage.updateRelativeBound;
var
  clbound,newPixBound:trect;
  w,h:integer;
begin
  if chart=nil then
    exit;
  if parent=nil then
    exit;
  clbound:=getClientBound;
  w:=clbound.right-clbound.left;
  h:=clbound.top-clbound.bottom;
  if (w<0) or (h<0) then
  begin
    exit;
  end;
  newPixBound.left:=round(RelativeBound.BottomLeft.x*w)+clbound.left;
  newPixBound.right:=round(RelativeBound.topright.x*w)+clbound.left;
  newPixBound.top:=round(RelativeBound.topright.y*h)+clbound.bottom;
  newPixBound.bottom:=round(RelativeBound.BottomLeft.y*h)+clbound.bottom;
  bound:=newPixBound;
end;

procedure cBasePage.EvalRelativeBound(b:trect);
var
  clbound,newPixBound:trect;
  w,h:integer;
begin

  //w:=twincontrol(chart).width;
  //h:=twincontrol(chart).Height;

  clbound:=getClientBound;
  w:=clbound.right-clbound.left;
  h:=clbound.top-clbound.bottom;
  if (h<0) or (w<0) then
  begin
    exit;
  end;
  fRelativeBound.BottomLeft.x:=(b.Left-clbound.left)/w;
  fRelativeBound.topright.x:=(b.right-clbound.left)/w;
  fRelativeBound.BottomLeft.y:=(b.bottom-clbound.bottom)/h;
  fRelativeBound.topright.y:=(b.top-clbound.bottom)/h;
end;

procedure cBasePage.setBound(rect:trect);
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
  SetTabSpace(m_pixelTabSpace);
  //EvalRelativeBound(ibound);

  CallEventsWithSender(e_onresize, self);
end;

procedure cBasePage.GetViewport(var v:array of glint);
begin
  v[0]:=bound.Left + m_pixelTabSpace.Left;
  v[1]:=bound.bottom+m_pixelTabSpace.Bottom;
  v[2]:=getwidth - m_pixelTabSpace.right - m_pixelTabSpace.Left;
  v[3]:=getheight - m_pixelTabSpace.top - m_pixelTabSpace.Bottom;
end;

procedure cBasePage.SetTabSpace(rect:trect);
var
  p:GLUInt;
begin
  m_pixelTabSpace:=rect;
  //m_TabSpace:=OffsetRectTofRect(rect);
  glGetIntegerv(gl_Matrix_Mode,@p);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
  //-----------
  glPopMatrix;
  if p = GL_MODELVIEW then
    glMatrixMode(GL_MODELVIEW);
  if p = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
  // рассчет вьюпорта по bound и TabSpace
  GetViewport(m_viewport);
end;

// Установить вьюпорт отрисовки трендов
procedure cBasePage.setDrawObjVP;
begin
  // x,y - нижний левый угол (0,0)
  glViewPort(m_viewport[0],m_viewport[1],m_viewport[2],m_viewport[3]);
end;

// вьюпорт отрисовки окна
procedure cBasePage.setCommonVP;
begin
  glViewport(bound.Left,bound.Bottom,getWidth, getheight);
end;

// Переводит координаты чарта в координаты тренда
// function GetZoomRect(TranslateRect:frect):fRect;
// переводит пиксельную точку в нормализованные координаты чарта
function cBasePage.p2iTop2(p:tpoint):point2;
var res:point2;
    width,height:glFloat;
begin
  p.x:=p.x - bound.Left;
  p.y:=p.y - bound.bottom;
  res.x:=p.x*2/getWidth-1;
  res.y:=p.y*2/getheight-1;
  result:=res;
end;

function cBasePage.p2iTop2(p:tpoint; const view:array of double; localViewport:boolean):point2;
var
  x,y,z:double;
begin
  if localViewport then
  begin
    gluUnProject(p.x,p.y,1,
               @identMatrix4d, @view, @m_viewport,
               x,y,z);
  end
  else
  begin
    gluUnProject(p.x,p.y,1,
               @identMatrix4d, @view, @m_NormalViewport,
               x,y,z);
  end;
  result.x:=x;
  result.y:=y;
end;

function cBasePage.realXToX1(x1x2: point2): point2;
var
  a:caxis;
begin
  a:=cpage(self).activeAxis;
  if a<>nil then
  begin
    result.x:=-1+(x1x2.x-a.min.x)/a.getdx;
    result.x:=-1+(x1x2.y-a.min.x)/a.getdx;
  end;
end;

procedure cBasePage.SetView(min,max:point2);
begin
  fmin:=min;
  fmax:=max;
  MathFunction.CreateOrthoMatrixd(fMin.x, fMax.x, fMin.y, fMax.y, -1, 1, m_view);
end;

//скармливаются нормализованные координаты чарта
function cBasePage.p2ToP2i(p:point2):tpoint;
var
  px,py,pz:double;
  I: Integer; // возвращаемые мировые координаты.
  wx,wy,wz:gldouble;
  res:integer;
begin
  result.x:=-1;
  result.y:=-1;
  if chart=nil then exit;
  px:=p.x; py:=p.y;
  pz:=0;
  res:=gluProject(p.x, p.y, pz, @identMatrix4d, @identMatrix4d, @m_NormalViewport, wx, wy, wz);
  if res=1 then
  begin
    result.x:=round(wx);
    result.y:=round(wy);
    result.y:=twincontrol(chart).Height - result.Y;
  end;
end;

function cBasePage.MouseInPage(point:tpoint):boolean;
begin
  result:=
  ((point.x>=m_NormalViewport[0]) and (point.x<=m_NormalViewport[0]+m_NormalViewport[2])) and
  ((point.y>=m_NormalViewport[1]) and (point.y<=m_NormalViewport[1]+m_NormalViewport[3]));
  //((point.x>=m_viewport[0]) and (point.x<=m_viewport[0]+m_viewport[2])) and
  //((point.y>=m_viewport[1]) and (point.y<=m_viewport[1]+m_viewport[3]));
end;

procedure cBasePage.drawPageField;
begin
  glcolor3fv(@color);
  // отрисовка полигона
  glBegin(GL_QUADs);
    glvertex2f(-1,-1);
    glvertex2f(-1,1);
    glvertex2f(1,1);
    glvertex2f(1,-1);
  glend;
end;

procedure cBasePage.DoClick(i_p:tpoint;f_p:point2);
begin
  fDragBegin:=i_p;
  fdrag:=true;
end;

procedure cBasePage.DoMouseMove(i_p:tpoint;f_p:point2);
begin
  fdragEnd:=i_p;
end;

procedure cBasePage.DoButtonUp(i_p:tpoint;f_p:point2);
begin
  fdrag:=false;
end;

procedure cBasePage.DoKeyDowne(key:word);
begin

end;

constructor cBasePage.create;
begin
  inherited;
  fmin:=p2(-1,-1);
  fmax:=p2(1,1);
  fdrag:=false;
  move(identmatrix4d[0],m_view[0],16*sizeof(double));
  fRelativebound.BottomLeft:=p2(0,0);
  fRelativebound.TopRight:=p2(1,1);
end;

procedure cBasePage.DoOnExit;
begin

end;

procedure cBasePage.DoDblClick(i_p:tpoint;f_p:point2);
begin

end;

procedure cBasePage.BeforeDrawChild;
begin
  inherited;
  glmatrixmode(gl_projection);
  glloadmatrixf(@identMatrix4);
  setCommonVP;
end;


end.
