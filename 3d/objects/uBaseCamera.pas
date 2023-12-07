unit uBaseCamera;

interface
uses
 Windows, Messages, OpenGL, Classes, MathFunction, uobject, uMatrix, math,
 usimpleobjects, uObjectTypes, umNode, uNode, uNodeObject, uCommonTypes, u3dTypes;
 Type

  cBaseCamera = class(cobject)
  public
    fov, // Угол обзора камеры
    aspect, // отношение ширины окна к высоте
    left, right, top, bottom,
    nearplane, farplane:single;
    m_targetsize:single;
    target:cnode;
    fOrtho,factive,fkeepquad:boolean;
  private
    // косинус допустимого угла при зуме; в камеру призумливаются объекты попадающие в этот угол
    // m_tg - тангенс доп. угла при зуме
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
    // Повернуть камеру вокруг обекта
    procedure rotateAroundTarget(m:matrixgl; axis:point3; angel:single);overload;
    procedure rotateAroundTarget(p_node:cnode; axis:point3; angel:single);overload;
    function getCopy:cnodeobject;override;
    procedure CopyTo(obj:cnodeobject);override;
    // Получить матрицу цели
    function GetTargetM:matrixgl;
    procedure GetTarget(p_target:cnode);overload;
    procedure GetTarget(p_target:cNodeObject);overload;
    procedure setKeepquad(p_keepquad:boolean);
    function getKeepquad:boolean;
    // Отрисовать камеру (пустышки для обозначения положения и мишени)
    procedure draw;override;
    // Активизировать камеру. В сцене может быть только одна активная камера
    property active:boolean read factive write setactive;
    // удерживать объекты квадратными при масштабировании окна
    property keepquad:boolean read getKeepquad write setKeepquad;
    // Если камера не активна - делает камеру активной
    constructor create;override;
    // процедура пользовательского перемещения камеры. Может быть переопределена
    // для реализации камеры другого типа
    procedure UserMoveCamera(msg:tmessage;mouse:MouseStruct);virtual;
    //procedure UserMoveObj(var msg:tmessage;mouse:MouseStruct);override;
    // призумить область
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
  result:='Камера';
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
  // Узнаем какая матрица активна
  glGetIntegerv(gl_Matrix_Mode,@TMType);
  glMatrixMode(GL_Modelview);
  glPushMatrix;
  glLoadIdentity;
  m:=restm;
  // Устанавливает текущую резульирующую матрицу объекта
  glloadmatrixf(@m);
  gltranslate(0,0,2);
  if active and CheckFlag(settings,draw_target) then
  begin
    // Отрисовываем цель
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
  // 5 градусов - допуск
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
    // Вытаскивает вектор взгляда (ось z) из матрицы положения объекта
    p:=getSight;
    // Возвращает вектор умноженый на скаляр
    p:=scalevectorp3(2,p);
    // возвращает сумму векторов
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

// вариант ниже более здравый но не дописан. этот - работает криво
{procedure cBaseCamera.ZoomBound(b:tbound);
var
  // центр баундбокса
  center,
  // точка параллельного переноса камеры
  newpos,
  // вектор вверх
  up,
  view, viewNormalise,
  // точки на плоскости камеры
  V1, V2, V3, V4, lp2, lp3, strafe, hn, H, PH,N:point3;
  // угол к вершинам баунда
  alfa, alfa_max, cos, cos_max, tg_max, L, Ln:single;
begin
  //n:=MovePoint(v1,view, l*2);
  n:=position;
  center.x:=0.5*(b.hi.x+b.lo.x);
  center.y:=0.5*(b.hi.y+b.lo.y);
  center.z:=0.5*(b.hi.z+b.lo.z);
  //if LineCrossLine(V1,V2,V3,V4,center) then
  begin
    // находим точку пересечения луча из center (центр баундбокса) с плоскостью положения камеры и делаем туда параллельный перенос
    up:=getup;
    lp2:=SummVectorP3(n, up); // точка над камерой (в той же плоскости)
    strafe:=GetAxisFromMatrix(restm,0);
    ///lp3:=SummVectorP3(position, strafe);
    lp3:=SummVectorP3(n, strafe);
    view:=getSight;
    viewNormalise:=view;
    NormalizeVectorP3(viewNormalise);
    // пересечение луча из center вдоль вектора viewNormalise
    // с плоскостью n, lp2, lp3
    LineCrossPlaneN(center, viewNormalise, n, lp2, lp3, newpos);
    //a * в = |a| * |B| * cos ф
    // находим углы к вершинам
    lp2.x:=V1.x-newpos.x;
    lp2.y:=V1.y-newpos.y;
    lp2.z:=V1.z-newpos.z;
    H:=V1;
    V1:=lp2;
    NormalizeVectorP3(lp2);
    cos:=MultScalarP3(lp2,view);
    cos_max:=cos;
    alfa:=arccos(cos)*180/pi;
    PH:=V1;
    alfa_max:=alfa;

    lp2.x:=V2.x-newpos.x;
    lp2.y:=V2.y-newpos.y;
    lp2.z:=V2.z-newpos.z;
    V1:=lp2;
    NormalizeVectorP3(lp2);
    cos:=MultScalarP3(lp2,view);
    alfa:=arccos(cos)*180/pi;
    if alfa>alfa_max then
    begin
      alfa_max:=alfa;
      cos_max:=cos;
      H:=V2;
      PH:=V1;
      V1:=lp2;
    end;

    lp2.x:=V3.x-newpos.x;
    lp2.y:=V3.y-newpos.y;
    lp2.z:=V3.z-newpos.z;
    V1:=lp2;
    NormalizeVectorP3(lp2);
    alfa:=arccos(cos)*180/pi;
    if alfa>alfa_max then
    begin
      alfa_max:=alfa;
      cos_max:=cos;
      H:=V3;
      PH:=V1;
      V1:=lp2;
    end;

    lp2.x:=V4.x-newpos.x;
    lp2.y:=V4.y-newpos.y;
    lp2.z:=V4.z-newpos.z;
    V1:=lp2;
    NormalizeVectorP3(lp2);
    alfa:=arccos(cos)*180/pi;
    if alfa>alfa_max then
    begin
      alfa_max:=alfa;
      cos_max:=cos;
      H:=V4;
      PH:=V1;
      V1:=lp2;
    end;

    // длина вектора PN (p-позиция, N нормаль из вершины на view)
    // V1 - хранит вектор pos - H
    L:=VectorLength(PH)*cos_max;
    // ычисляем нормаль и сохраняем в V1
    N:=summvectorp3(newpos, scalevectorp3(L, viewNormalise));
    hn.x:=h.x-n.x;
    hn.y:=h.y-n.y;
    hn.z:=h.z-n.z;
    // длина нормали
    LN:=VectorLength(hn);
    // длина вектора P1N
    L:=lN/m_tg;
    V1:=scalevectorp3(-L,viewNormalise);
    position:=SummVectorP3(V1, N);
  end;
end;}

procedure cBaseCamera.ZoomBound(b:tbound);
var
  // bottom poly
  p1,p2,p3,p4,
  // top poly
  p5,p6,p7,p8,


  c, // центр баундбокса
  sc, // отступ из центра вдоль вектора взгляда камеры
  view, // вектор взгляд камеры
  pos, // позиция камеры
  cross, // точка пересечения
  VertToCross //  вектор из cross к вершине
  :point3;
  insidebox:boolean;
  poly:integer;
  angel,dist, dist1:single;
begin
  // ищем нижний полигон
  p1:=b.lo;
  p2:=p1; p2.x:=b.hi.x;
  p3:=p1; p2.z:=b.hi.z;
  p4:=p2; p2.z:=b.hi.z;
  // верхний поли
  p5:=p1; p5.y:=b.hi.y;
  p6:=p2; p6.y:=b.hi.y;
  p7:=p3; p7.y:=b.hi.y;
  p8:=b.hi;

  pos:=position;

  // середина диагонали
  c.x:=0.5*(b.hi.x+b.lo.x);
  c.y:=0.5*(b.hi.y+b.lo.y);
  c.z:=0.5*(b.hi.z+b.lo.z);
  // косинус угла векторов мишень и взгляд
  view:=getSight;
  angel:=VectorCos(sc,view);
  // вектор в обратную сторону от взгляда
  view:=scalevectorp3(-1,getSight);
  // Координаты камеры
  // точка куда надо перенести камеру, чтобы сохранить ее ориентацию,
  // но смотреть в центр объема
  sc:=SummVectorP3(c, view);
  insidebox:=insideBox3d(sc, b.lo,b.hi);
  position:=sc;
  if insidebox then
  begin

  end
  else
  begin

  end;
  {
  cross:=lineCrossBound(b.lo, b.hi, pos, c, poly);
  dist:=0;
  // определяем угол между отрезками L1 = (cross, boundPoint) и L2 = (newPos, cross) (при этом newpos сонаправлен с вектором взгляда)
  c:=p1;
  VertToCross:=subVector(c, cross);
  //cos:=MultScalar(view, VertToCross);
  }
end;

function cBaseCamera.GetTargetM:matrixgl;
var m:matrixgl;
    offsetm:matrixgl;
    r:single; // расстояние до цели
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
