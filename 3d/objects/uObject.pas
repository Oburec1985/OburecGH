unit uObject;

interface
uses MathFunction, uMatrix, OpenGl, windows, Classes, uquat, uSimpleObjects, u3dtypes,
     uNodeObject, uObjectTypes, uEventList, uGlEventTypes, uCommonTypes, uBaseObj, uBaseObjMng;

type
 cObject = class(cNodeObject)
   // ����� ���� ����� � ������������ ������ ������� ��������� ������
 protected
   fneedRecompile:boolean;
 public
   defoultcolor:point3; // ���� ��������� ������� �� ���������
   selectaxis:integer; // ��������� ���
   m_fAxisLength:single;
   // ����� ������ �������
   bound:tbound;
   settings:word;
 public
   // ����� � ������������ ������ ������� ��������� ������
   property m_AxisLength:single read m_fAxisLength write m_fAxisLength;
 protected
   procedure drawLocalAxis;
   procedure drawNodeAxis;
   procedure drawParentAxis;
   procedure drawdata;virtual;
   // ���������� ����� ���������� ����������� ������ ���������� �������
   procedure compile;virtual;
 public
   procedure UpdateBounds;virtual;
   // �������� ����� �������
   function getCopy:cnodeobject;override;
   procedure CopyTo(obj:cnodeobject);override;
   procedure setflag(flag:word);
   procedure dropflag(flag:word);
   // �������� ������ ������� ������� (��� z)
   function getSight:point3;
   function getUp:point3;
   function getPosition:point3;
   // ���������� ������� � ������� ����������. ���������� ������ ���
   // ��� ��������� ��������� �������
   procedure draw;virtual;
   procedure DrawBounds(color:point3);
   Constructor Create;override;
 // �������
 public
   fOnClick:tNotifyEvent;
 public
   procedure doClick;
   function GetAbsBound:TBound;
 private
   function getboundsize:single;
   procedure setboundsize(size:single);
 public
   property needRecompile:boolean read  fneedRecompile write fneedRecompile;
   property boundsize:single read getboundsize write setboundsize;
 end;
 // ��������������� ��� bound - � ������� �����������; obj ����� bound+��������� � ������������
 procedure UpdateBound(obj:cobject;var bound:tbound);

const
  Fl_RotX     = 0;
  Fl_RotX_inv = 1;
  Fl_RotY     = 2;
  Fl_RotY_inv = 3;
  Fl_RotZ     = 4;
  Fl_RotZ_inv = 5;

  red:point3 = (x:1;y:0;z:0);
  green:point3 = (x:0;y:1;z:0);
  blue:point3 = (x:0;y:0;z:1);
  white:point3 = (x:1;y:1;z:1);

implementation

procedure UpdateBound(obj:cobject;var bound:tbound);
var b:tbound;
    m:matrixgl;
    str:string;
begin
  //if not obj.groupHeader then
  //  m:=evalrightmatrix(cnodeobject(obj.parent).restm,obj.restm)
  //else
  //  m:=identMatrix4;
  m:=obj.restm;
  b:=MultBoundByM(obj.bound,m);
  if b.lo.x<bound.lo.x then
    bound.lo.x:=b.lo.x;
  if b.lo.y<bound.lo.y then
    bound.lo.y:=b.lo.y;
  if b.lo.z<bound.lo.z then
    bound.lo.z:=b.lo.z;

  if b.hi.x>bound.hi.x then
    bound.hi.x:=b.hi.x;
  if b.hi.y>bound.hi.y then
    bound.hi.y:=b.hi.y;
  if b.hi.z>bound.hi.z then
    bound.hi.z:=b.hi.z;
end;

procedure cObject.UpdateBounds;
begin

end;

function cObject.getCopy:cnodeobject;
var obj:cobject;
begin
  obj:=cobject.Create;
  obj.setMng(getmng);
  copyTo(obj);
  result:=obj;
end;

procedure cObject.CopyTo(obj:cnodeobject);
begin
  if obj is cobject then
  begin
    inherited copyto(obj);
    cobject(obj).selectaxis:=selectaxis;
    cobject(obj).m_fAxisLength:=m_fAxisLength;
    // ����� ������ �������
    cobject(obj).bound:=bound;
    cobject(obj).settings:=settings;
  end;
end;

procedure cObject.setflag(flag:word);
begin
  settings:=settings or flag;
end;

procedure cObject.dropflag(flag:word);
begin
  if CheckFlag(settings,flag) then
    settings:=settings - flag;
end;

function cObject.getPosition:point3;
begin
  result:=getPosFromMatrixP3(restm);
end;

function cObject.getUp:point3;
begin
  result:=GetAxisFromMatrix(restm,1);
end;

function cObject.getSight:point3;
begin
  result:=GetAxisFromMatrix(restm,2);
end;

Constructor cObject.Create;
var TMtype:GLUInt;
begin
  inherited;
  objtype:=constdummy;
  m_axisLength:=3;
  settings:=0;
  boundsize:=1;
  bound.exist:=true;
end;

procedure cObject.compile;
begin

end;

procedure cObject.drawdata;
begin

end;

procedure cObject.Draw;
var
  TMtype:GLUInt;
  m:matrixgl;
begin
  drawLocalAxis;
  DrawNodeAxis;
  drawParentAxis;
   // ������ ����� ������� �������
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glPushMatrix;
  m:=restm;
  glloadmatrixf(@m);
  drawdata;
  glPopMatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

procedure cObject.DrawBounds(color:point3);
var TMtype:GLUInt;
    m:matrixgl;
begin
  // ������ ����� ������� �������
  if CheckFlag(settings,draw_bound) then
  begin
    // ������ ����� ������� �������
    glGetIntegerv(gl_Matrix_Mode, @TMType);
    glMatrixMode(GL_Modelview);
    glPushMatrix;
    m:=restm;
    glcolor3fv(@color);
    glloadmatrixf(@m);
    DrawBound(bound.lo,bound.hi, identmatrix4, color);
    glPopMatrix;
    if TMType = GL_PROJECTION then
      glMatrixMode(GL_PROJECTION);
  end;
end;

procedure cObject.DrawNodeAxis;
var TMtype:GLUInt;
    tm:matrixgl;
begin      //(settings and DRAW_NODE)<>0
  if CheckFlag(settings,draw_node) then
  begin
    // ������ ����� ������� �������
    glGetIntegerv(gl_Matrix_Mode,@TMType);
    glMatrixMode(GL_Modelview);
    glPushMatrix;
    tm:=Node.restm;
    glloadmatrixf(@tm);
    DrawPivotPoint(m_AxisLength);
    glPopMatrix;
    if TMType = GL_MODELVIEW then
      glMatrixMode(GL_MODELVIEW);
    if TMType = GL_PROJECTION then
      glMatrixMode(GL_PROJECTION);
  end;
end;

procedure cObject.drawParentAxis;
var TMtype:GLUInt;
    tm:matrixgl;
begin      
  if CheckFlag(settings,draw_Parent) then
  begin
    // ������ ����� ������� �������
    glGetIntegerv(gl_Matrix_Mode,@TMType);
    glMatrixMode(GL_Modelview);
    glPushMatrix;
    tm:=node.parentrestm;
    glloadmatrixf(@tm);
    DrawPivotPoint(m_AxisLength);
    glPopMatrix;
    if TMType = GL_MODELVIEW then
      glMatrixMode(GL_MODELVIEW);
    if TMType = GL_PROJECTION then
      glMatrixMode(GL_PROJECTION);
  end;
end;

Procedure cObject.DrawLocalAxis;
var TMtype:GLUInt;
    tm:matrixgl;
begin
  if CheckFlag(settings,draw_local) then
  begin
    // ������ ����� ������� �������
    glGetIntegerv(gl_Matrix_Mode,@TMType);
    glMatrixMode(GL_Modelview);
    glPushMatrix;
    tm:=localnode.restm;
    glloadmatrixf(@tm);
    DrawPivotPoint(m_AxisLength);
    glPopMatrix;
    if TMType = GL_PROJECTION then
      glMatrixMode(GL_PROJECTION);
  end;
end;

function cObject.getboundsize:single;
begin
  result:=bound.hi.x - bound.lo.x;
end;

function cObject.GetAbsBound:TBound;
begin
  result:=MultBoundByM(bound,restm);
end;

procedure cObject.setboundsize(size:single);
begin
  bound.hi.x:=size/2;
  bound.hi.y:=bound.hi.x;
  bound.hi.z:=bound.hi.x;

  bound.lo.x:=-bound.hi.x;
  bound.lo.y:=bound.lo.x;
  bound.lo.z:=bound.lo.x;
end;

procedure cObject.doClick;
begin
  cBaseObjMng(getmng).events.CallAllEventsWithSender(E_glOnObjClick,self);
  if assigned(fOnClick) then
    fOnClick(self);
end;

end.
