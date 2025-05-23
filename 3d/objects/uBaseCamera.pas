unit uBaseCamera;

interface
uses
 Windows, Messages, OpenGL, Classes, MathFunction, uobject, uMatrix, math, uCommonMath,
 usimpleobjects, uObjectTypes, umNode, uNode, uNodeObject, uCommonTypes, u3dTypes;

 Type

  cBaseCamera = class(cobject)
  public
    fov, // ���� ������ ������
    aspect, // ��������� ������ ���� � ������
    left, right, top, bottom,
    nearplane, farplane:single;
    m_targetsize:single;
    target:cnode;
    fOrtho,factive,fkeepquad:boolean;
  private
    // ������� ����������� ���� ��� ����; � ������ �������������� ������� ���������� � ���� ����
    // m_tg - ������� ���. ���� ��� ����
    m_cos, m_tg:single;
  //private
  public
    function gettargetpos:point3;
    procedure setCamera;virtual;
    procedure setobjtoworld;override;
    procedure setactive(active:boolean);
  private
  public
    function TypeString:String;override;
    // ��������� ������ ������ ������
    procedure rotateAroundTarget(m:matrixgl; axis:point3; angel:single);overload;
    procedure rotateAroundTarget(p_node:cnode; axis:point3; angel:single);overload;
    function getCopy:cnodeobject;override;
    procedure CopyTo(obj:cnodeobject);override;
    // �������� ������� ����
    function GetTargetM:matrixgl;
    procedure GetTarget(p_target:cnode);overload;
    procedure GetTarget(p_target:cNodeObject);overload;
    procedure setKeepquad(p_keepquad:boolean);
    function getKeepquad:boolean;
    // ���������� ������ (�������� ��� ����������� ��������� � ������)
    procedure draw;override;
    // �������������� ������. � ����� ����� ���� ������ ���� �������� ������
    property active:boolean read factive write setactive;
    // ���������� ������� ����������� ��� ��������������� ����
    property keepquad:boolean read getKeepquad write setKeepquad;
    // ���� ������ �� ������� - ������ ������ ��������
    constructor create;override;
    // ��������� ����������������� ����������� ������. ����� ���� ��������������
    // ��� ���������� ������ ������� ����
    procedure UserMoveCamera(msg:tmessage;mouse:MouseStruct);virtual;
    //procedure UserMoveObj(var msg:tmessage;mouse:MouseStruct);override;
    // ��������� �������
    procedure ZoomBound(b:tbound);
  protected
    function getWndCtxt:TWndContext;
    procedure setOrtho(p_Ortho:boolean);
  public
    property Ortho:boolean read fOrtho write setOrtho;
    property wndcontext:TWndContext read getWndCtxt;
  end;

const
  c_zoomThreshold = 30;

implementation
uses
  uUIutils,
  uscenemng,
  uRender
  ;

function cBaseCamera.TypeString:String;
begin
  result:='������';
end;

procedure cBaseCamera.rotateAroundTarget(m:matrixgl; axis:point3; angel:single);
begin
  node.RotateNodeInWorldByAxisAngle(angel,axis,m);
  setobjtoworld;
end;

procedure cBaseCamera.rotateAroundTarget(p_node:cnode; axis:point3; angel:single);
begin
  node.RotateNodeInWorldByAxisAngle(angel,axis,p_node);
end;

procedure cBaseCamera.draw;
var TMtype:GLUInt;
    target:point3;
    m:matrixgl;
begin
  inherited draw;
  // ������ ����� ������� �������
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glPushMatrix;
  glLoadIdentity;
  m:=restm;
  // ������������� ������� ������������� ������� �������
  glloadmatrixf(@m);
  gltranslate(0,0,2);
  if active and CheckFlag(settings,draw_target) then
  begin
    // ������������ ����
    DrawBox(m_targetsize);
  end;
  glPopMatrix;
  if TMType = GL_MODELVIEW then
    glMatrixMode(GL_MODELVIEW);
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);
end;

procedure cBaseCamera.setActive(active:boolean);
begin
  if active then
  begin
    if (settings and C_ACTIVECAMERA)=0 then
      settings:=settings + C_ACTIVECAMERA;
  end
  else
  begin
    if (settings and C_ACTIVECAMERA)<>0 then
      settings:=settings - C_ACTIVECAMERA;
  end;
  factive:=active;
  setobjtoworld;  
end;

procedure cBaseCamera.setobjtoworld;
begin
  inherited setobjtoworld;
  if active then
  begin
    setCamera;
  end;
end;

function cBaseCamera.getWndCtxt:TWndContext;
begin
  result:=crender(cScene(getmng).render).m_wndContext;
end;

constructor cBaseCamera.create;
begin
  inherited;
  fHelper:=false;
  objtype:=constcamera;
  imageindex:=constcameraImgIndex;
  fov:=60;
  // 5 �������� - ������
  m_cos:=cos(pi*(fov-c_zoomThreshold)/180);
  m_tg:=sqrt(1-m_Cos*m_cos)/m_cos;
  aspect:=1;
  nearplane:=0.1;
  farplane:=500;
  active:=false;
  m_targetsize:=0.1;
  bound.exist:=false;
  fkeepquad:=true;
  left:=-2; right:=-left; bottom:=left; top:=right;
  target:=nil;
  DropFlag(draw_TARGET);
end;

procedure cBaseCamera.SetCamera;
var aim,up:point3;
    test:single;
    TMtype:GLUInt;
    m:matrixgl;
    l_aspect:single;
begin
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  up:=getup;
  aim:=gettargetpos;
  if not keepquad then
  begin
    if ortho then
    begin
      glOrtho(left,right,Bottom,Top,nearplane,farplane);
    end
    else
    begin
      gluPerspective(fov,aspect,nearplane,farplane)
    end;
  end
  else
  begin
    if ortho then
    begin
      glOrtho(left,right,Bottom,Top,nearplane,farplane);
    end
    else
    begin
      l_aspect:=(wndContext.ClientWidth/wndContext.ClientHeight);
      gluPerspective(fov,l_aspect,nearplane,farplane);
    end;
  end;
  // test:=multscalarp3(getSight,up);
  glulookat(position.x,position.y,position.z,
            aim.x,aim.y,aim.z,
            up.x,up.y,up.z);
  if TMType = GL_MODELVIEW then
  begin
   glMatrixMode(GL_MODELVIEW);
  end;
end;

function cBaseCamera.gettargetpos:point3;
var p:point3;
begin
  if target=nil then
  begin
    // ����������� ������ ������� (��� z) �� ������� ��������� �������
    p:=getSight;
    // ���������� ������ ��������� �� ������
    p:=scalevectorp3(2,p);
    // ���������� ����� ��������
    p:=summVectorp3(p,position);
  end
  else
  begin
    p:=target.position;
  end;
  result:=p;
end;

procedure cBaseCamera.GetTarget(p_target:cnode);
begin
  if p_target<>nil then
    target:=p_target
  else
    target:=nil;
end;

procedure cBaseCamera.GetTarget(p_target:cNodeObject);
begin
  if p_target<>nil then
    target:=p_target.localnode
  else
    target:=nil;
end;

procedure cBaseCamera.setKeepquad(p_keepquad:boolean);
begin
  fkeepquad:=p_keepquad;
end;

function cBaseCamera.getKeepquad:boolean;
begin
  result:=fkeepquad;
end;

function cBaseCamera.getCopy:cnodeobject;
var obj:cbasecamera;
begin
  obj:=cbasecamera.Create;
  copyto(obj);
  result:=obj;
end;

procedure cBaseCamera.CopyTo(obj:cnodeobject);
begin
  if obj is cbasecamera then
  begin
    inherited copyto(obj);
    cbasecamera(obj).fov:=fov;
    cbasecamera(obj).aspect:=aspect;
    cbasecamera(obj).nearplane:=nearplane;
    cbasecamera(obj).farplane:=farplane;
    cbasecamera(obj).m_targetsize:=m_targetsize;
    cbasecamera(obj).target:=target;
    cbasecamera(obj).factive:= factive;
    cbasecamera(obj).fkeepquad:=fkeepquad;
  end;
end;

procedure cBaseCamera.UserMoveCamera(msg:tmessage;mouse:MouseStruct);
begin
 if active then
 begin
   //RotateMouse(mouse);
   //SetCursorPos(mouse.rect.Left+mouse.cx, mouse.rect.Top+mouse.cy);
 end;
end;

procedure cBaseCamera.ZoomBound(b:tbound);
var
  // bottom poly
  //p1,p2,p3,p4,
  // top poly
  //p5,p6,p7,p8,
  //poly:integer;

  p1,
  c, // ����� ����������
  lp, // ������ �� ������ � ������
  up,
  view, // ������ ������ ������
  pos, newpos, // ������� ������
  cross // ����� �����������
  :point3;
  lb, insidebox:boolean;
  angel,dist, dist1:single;
begin
  // ���� ������ �������
  p1:=b.lo;
  //p2:=p1; p2.x:=b.hi.x;
  //p3:=p1; p2.z:=b.hi.z;
  //p4:=p2; p2.z:=b.hi.z;
  // ������� ����
  //p5:=p1; p5.y:=b.hi.y;
  //p6:=p2; p6.y:=b.hi.y;
  //p7:=p3; p7.y:=b.hi.y;
  //p8:=b.hi;

  pos:=position;

  // �������� ���������
  c.x:=0.5*(b.hi.x+b.lo.x);
  c.y:=0.5*(b.hi.y+b.lo.y);
  c.z:=0.5*(b.hi.z+b.lo.z);
  // ������� ���� �������� ������ � ������
  view:=getSight;
  // ���������� ����������������
  //lp:=subVector(pos, c);
  //angel:=VectorCos(lp,view);
  // ����� ���� ���� ��������� ������, ����� ��������� �� ����������,
  // �� �������� � ����� ������ (������� ������� ������ ����� ������� ������� � �������� �����������)
  // lp:=SubVectorP3(view, c);
  up:=getUp;
  // ����� � ���������� -up �� ������ c-up
  lp:=subVector(up, c);
  // ����� ����������� ������� � ��������� ���������� ����� ����� ������
  lb:=LineCrossLine(pos, SummVectorP3(pos, view), c, lp, cross);
  // ������ �������� ������
  lp:=subVector(c, cross);
  newpos:=SummVectorP3(pos, lp);
  /// ��������� ����� � R=��������� � ���������� C � 40 ����
  dist:=VectorLength(subVector(p1,c)); // ����� ��������� (���. �����)
  dist1:=dist/ sin(20*c_degtorad);
  // ������ �� ������ ������ � ������� ������ �� dist1
  view:=scalevectorp3(dist1, view);
  //NormalizeVectorP3(view);
  pos:=subVector(view, c);
  position:=pos;
end;

function cBaseCamera.GetTargetM:matrixgl;
var m:matrixgl;
    offsetm:matrixgl;
    r:single; // ���������� �� ����
begin
  if target<>nil then
    result:=target.restm
  else
  begin
    m:=restm;
    r:=(nearplane+farplane)/2;
    offsetm:=identmatrix4;
    offsetm[14]:=r;
    result:=MultMatrix4(m,offsetm);
  end;
end;

//procedure cBaseCamera.UserMoveObj(var msg:tmessage;mouse:MouseStruct);
//begin
//  inherited;
//  UserMoveCamera(msg,mouse);
//end;

procedure cBaseCamera.setOrtho(p_Ortho:boolean);
begin
  fortho:=p_ortho;
  if active then
  begin
    setobjtoworld;
  end;
end;

end.
