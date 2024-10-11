unit uObjCtrFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,  ComCtrls, ImgList,
  uglframelistener, uUI, ToolWin, Buttons, uObject, uMatrix,
  MathFunction, uSimpleObjects, Opengl, uEventList, uSelectools, uBasecamera, uNodeObject,
  uUIutils, dialogs, uglEventTypes, uCommonTypes, u3dTypes, StdCtrls;

const
  pan  = 0;
  rot  = 1;
  zoom = 2;

type
  cCtrlFrameListener = class(cglFrameListener)
  private
    // идентификатор выделеной оси. x - 0;y - 1; z - 2 иначе -1;
    selected:integer;
  public
    btn:smallint; // содержит идентификатор нажатой кнопки (pan(0), rot(1), zoom(2))
  private
    // Находим на сколько надо развернуть камеру вида (определяется по проекции
    // движения мыши на вращаемую ось)
    function GetRotateValue:single;
    // Повернуть камеру вокруг одной из осей, вокруг цели
    procedure RotateView;
    // передвижение выбранного объекта вдоль выбранной оси
    procedure MoveObject(dx,dy:integer;m:matrixgl;obj:cnodeobject);
    // вращение выбранного объекта вдоль выбранной оси
    procedure RotateObject(dx,dy:integer;m:matrixgl;obj:cnodeobject);
    // событие происходит при отрисовке сцены и рисует оси для перемещения объекта
    // "Тащить" камеру
    procedure PanCamera;
    // сдвинуть камеру вперед/назад
    procedure MoveCamera;
    // size - размер интерфейса
    function DoSelectInterface(x : GLint; y : GLint;size:single) : GLint;
  public
    procedure drawMoveAxis(sender:tobject);
    procedure drawRotateInterface(sender:tobject);

    Constructor create(p_ui:tobject;pname:string);override;
    procedure WndProc(msg:tmessage; mouse:mousestruct);override;
  end;

  TCtrlViewFrame = class(TFrame)
    GroupBox1: TGroupBox;
    PanBtn: TSpeedButton;
    RotBtn: TSpeedButton;
    ZoomBtn: TSpeedButton;
    SpeedZoom: TSpeedButton;
    procedure ZoomBtnClick(Sender: TObject);
    procedure RotBtnClick(Sender: TObject);
    procedure PanBtnClick(Sender: TObject);
    procedure SpeedZoomClick(Sender: TObject);
  private
    fr:cCtrlFrameListener;
    ui:cUI;
  private
  public
    procedure lincScene(p_ui:cUI);
  end;
  function DoSelect(x : GLint; y : GLint;m:matrixgl;camera:cbasecamera;len:single) : GLint;
  // используется в процедуре выбора объекта
  procedure SetCamera(camera:cbasecamera;pos:point3;aim:point3);

implementation

{$R *.dfm}

Constructor cCtrlFrameListener.create(p_ui:tobject;pname:string);
begin
  inherited create(p_ui,pname);
  btn:=-1;
  selected:=-1;
end;

procedure cCtrlFrameListener.PanCamera;
var p3:point3;
    camera:cbasecamera;
begin
  p3.x:=cUI(ui).mouse.dx*0.01;
  p3.y:=-cUI(ui).mouse.dy*0.01;
  p3.z:=0;
  camera:=cUI(ui).m_RenderScene.activecamera;
  camera.MoveNodeInLocalNodeWorld(p3.x,p3.y,p3.z);
end;

procedure cCtrlFrameListener.MoveCamera;
var p3:point3;
    camera:cbasecamera;
begin
  camera:=cUI(ui).m_RenderScene.activecamera;
  if camera.ortho then
  begin
    if cUI(ui).mouse.wheel>0 then
      camera.left:=camera.left*1.1
    else
      camera.left:=camera.left*0.9;
    camera.right:=-camera.left;
    camera.bottom:=camera.left;
    camera.top:=camera.right;
    camera.SetObjToWorld;
  end
  else
  begin
    p3.z:=cUI(ui).mouse.wheel*0.005;
    camera.MoveNodeInLocalNodeWorld(0,0,p3.z);
  end;
end;

procedure cCtrlFrameListener.MoveObject(dx,dy:integer;m:matrixgl;obj:cnodeobject);
var
  p3:point3;
begin
  if OBJ=nil then exit;
  if ((dx=0) and (dy=0)) or (cobject(obj).selectaxis<=0) then
  begin
    exit;
  end;
  p3:=GetProjection(dx,dy,m,cobject(obj).selectaxis,cobject(obj).m_AxisLength);
  obj.MoveNodeInWorld(p3,m);
end;

procedure cCtrlFrameListener.RotateObject(dx,dy:integer;m:matrixgl;obj:cnodeobject);
var
  p3:point3;
begin
  if ((dx=0) and (dy=0)) or (cobject(obj).selectaxis<=0) then
  begin
    exit;
  end;
  p3:=GetProjection(dx,dy,m,cobject(obj).selectaxis,cobject(obj).m_AxisLength);
  obj.RotateNodeWorld(scalevectorp3(cui(ui).mouse.m_RotSens,p3),m);
end;

function cCtrlFrameListener.GetRotateValue:single;
begin
  result:=0;
  // выделена ось x
  if selected=0 then
  begin
    result:=cui(ui).mouse.dx;
  end;
  // выделена ось y
  if selected=1 then
  begin
    result:=cui(ui).mouse.dy;
  end;
  // выделена ось z
  if selected=2 then
  begin
    if abs(cui(ui).mouse.dx)>abs(cui(ui).mouse.dy) then
      result:=cui(ui).mouse.dx
    else
      result:=cui(ui).mouse.dy;
  end;
end;

procedure cCtrlFrameListener.RotateView;
var angel:single;
    axis, center:point3;
    camera:cbasecamera;
    targettm:matrixgl;
    b:tbound;
    m, offsetm:matrixgl;
    res:boolean;
begin
  // id выделеной оси
  if selected<>-1 then
  begin
    angel:=GetRotateValue;
    case selected of
      // перемещение по оси x отвечает за вращение вокруг y!!! и наоборот
      0: axis:=axisy;
      1: axis:=axisx;
      2: axis:=axisz;
    end;
    camera:=cui(ui).m_RenderScene.activecamera;
    b:=cui(ui).getSelectBound(res);
    targettm:=camera.GetTargetM;
    if res then
    begin
      if getBoundCenter(b, center) then
      begin
        m:=camera.restm;
        targettm:=identmatrix4;
        targettm[12]:=center.x;
        targettm[13]:=center.y;
        targettm[14]:=center.z;
        targettm[15]:=1;
      end;
    end;
    targettm:=NoRotateMatrix4(targettm);
    // Переносит компоненты вращения из второго аргумента в первый и дает рез-т
    targettm:=GetRotMatrix4(targettm,camera.restm);
    camera.rotateAroundTarget(targetTM,axis,angel);
  end;
end;

procedure cCtrlFrameListener.drawRotateInterface(sender:tobject);
var m:matrixgl;
    r,aspect,width,heigth:single;
    p1,p2:point2;
    color:point3;
begin
  if btn=rot then
  begin
    glmatrixmode(gl_modelView);
    glpushmatrix;
    glloadidentity;
    glmatrixmode(gl_projection);
    glpushmatrix;
    glloadidentity;
    width:=cui(ui).m_RenderScene.m_wndContext.ClientWidth;
    heigth:=cui(ui).m_RenderScene.m_wndContext.ClientHeight;
    aspect:=(width/heigth);
    //gluperspective(60,aspect,1,5);
    if aspect<1 then // heigth>width
      glOrtho(-1,1,-1/aspect,1/aspect,-1,2)
    else // width>heigth
      glOrtho(-aspect,aspect,-1,1,-1,2);
    r:=0.5;
    color:=blue;
    if selected=2 then
      color:=yellow;
    glColor3fv(@color);
    drawCycle(r,60);
    // отрисовка оси x
    p1.x:=-r; p1.y:=0; p2.x:=r; p2.y:=0;
    color:=green;
    if selected=0 then
      color:=yellow;
    glColor3fv(@color);
    drawline(p1,p2);
    // отрисовка оси y
    p1.x:=0; p1.y:=-r; p2.x:=0; p2.y:=r;
    color:=red;
    if selected=1 then
      color:=yellow;
    glColor3fv(@color);
    drawline(p1,p2);
    glpopmatrix;
    glmatrixmode(gl_modelView);
    glpopmatrix;
  end;
end;

procedure cCtrlFrameListener.DrawMoveAxis(sender:tobject);
var obj:cnodeobject;
    m:matrixgl;
begin
  if cui(ui).GetSelected(0)=nil then exit;
  obj:=cui(ui).GetSelected(0);
  m:=cui(ui).GetSelectObjActiveAxisSystem;
  gldisable(GL_DEPTH_TEST);
  DrawPivotPoint(m,cui(ui).m_RenderScene.m_wndContext.axislength,
                 cobject(obj).selectaxis);
  glEnable(GL_DEPTH_TEST);
end;

procedure cCtrlFrameListener.wndproc(msg:tmessage; mouse:mousestruct);
var obj:cnodeobject;
    selectaxis, changecursor:boolean;
begin
  changecursor:=false;
  case msg.Msg of
   WM_MouseMove:
    begin
      // Поиск объекта по клику мыши
      obj:=cnodeobject(cui(ui).getselected(0));
      changecursor:=(obj<>nil) or (btn=rot);
      if changecursor then
      begin
        changecursor:=false;
        // проверяем, что не выделена ось смещения объекта
        if (obj<>nil) then
        begin
          changecursor:=DoSelect(mouse.x, mouse.y, cui(ui).GetSelectObjActiveAxisSystem,
                                 cui(ui).m_renderscene.activecamera,
                                 cui(ui).m_RenderScene.m_wndContext.axislength)
                                 <>-1;
        end;
        // проверяем, что не выделен вращательный интерфес
        if (not changecursor) and (btn=rot) then
        begin
          changecursor:=(doSelectInterface(mouse.x, mouse.y, 0.5)<>-1);
        end;
        if changecursor then
        begin
           if cui(ui).cursor=crDefault then
           begin
             selectaxis:=true;
             cui(ui).cursor:=crSizeAll;
           end;
        end
        else
        begin
          if (cui(ui).cursor=crSizeAll) and not mouse.LButtonDown then
          begin
            selectaxis:=false;
            cui(ui).cursor:=crdefault;
          end;
        end;
        cui(ui).eventlist.CallAllEvents(e_glmousemove);
      end;
      begin
        if mouse.LButtonDown then
        begin
          // Вращаем/ двигаем объект
          if (obj<>nil) and (cobject(obj).selectaxis<>-1) then
          begin
            if GetKeyState(VK_CONTROL)>=0 then // Если ctrl не нажат
              MoveObject(mouse.dx,mouse.dy,cui(ui).GetSelectObjActiveAxisSystem,obj)
            else                              // Если ctrl нажат
              RotateObject(mouse.dx,mouse.dy,cui(ui).GetSelectObjActiveAxisSystem,obj);
            cui(ui).needredraw:=true;
          end;
          if (selected<>-1) and (btn=rot) then
          begin
            RotateView;
            cui(ui).needredraw:=true;
          end;
          if btn = pan then
          begin
            PanCamera;
            cui(ui).needredraw:=true;
          end;
        end;
      end;
    end;
    WM_MOUSEWHEEL:
    begin
      if btn=zoom then
      begin
        MoveCamera;
        cui(ui).needredraw:=true;
      end;
    end;
    WM_LBUTTONDOWN:
    begin
      if btn=-1 then
      begin
        // Поиск оси вдоль которой двигать объект
        obj:=cnodeobject(cui(ui).getselected(0));
        if obj<>nil then
        begin
          cobject(obj).selectaxis:=DoSelect(mouse.x,mouse.y,cui(ui).GetSelectObjActiveAxisSystem,
                                            cui(ui).m_renderscene.activecamera,cui(ui).m_RenderScene.m_wndContext.axislength);
        end;
        // Поиск объекта по клику
        if cui(ui).tryselect and not (cui(ui).cursor=crSizeall) then
          findobject(mouse.x,mouse.y,ui);
        cui(ui).needredraw:=true;
        // Установка фокуса ввода на окне
        Windows.SetFocus(cui(ui).m_renderscene.m_wndContext.Handle);
        // Вызов событий OnClick
        cui(ui).eventlist.CallAllEvents(E_glWindowClick);
      end;
      if btn=rot then
        selected:=doSelectInterface(mouse.x, mouse.y, 0.5);
    end;
    WM_Keydown:
    begin
      obj:=nil;
      begin
        // обрабатываем камеру
        obj:=cui(ui).m_RenderScene.activecamera;
        if obj<>nil then
        begin
          obj.UserMoveObj(msg,mouse);
          cui(ui).needredraw:=false;
        end;
      end;
    end;
  end;
end;

procedure TCtrlViewFrame.lincScene(p_ui:cui);
begin
  ui:=p_ui;
  fr:=cCtrlFrameListener.create(p_ui,'CntrlFrame');
  ui.framelistener.add(fr);
  // Опциональные фичи
  ui.EventList.AddEvent('UI DrawMoveAxis',E_glRenderScene,fr.DrawMoveAxis);
  ui.EventList.AddEvent('UI DrawRotateInterface',E_glRenderScene,
                         fr.drawRotateInterface);
end;

procedure TCtrlViewFrame.PanBtnClick(Sender: TObject);
var 
    index:integer;
begin
  if TSpeedButton(sender).Down then
  begin
    fr.LockMouse:=true;
    fr.btn:=pan;
    ui.setcursbyname('PAN_CURSOR');
  end
  else
  begin
    fr.btn:=-1;
    fr.LockMouse:=false;
    ui.cursor:=crDefault;
  end;
  ui.m_RenderScene.invalidaterect;
end;

procedure TCtrlViewFrame.RotBtnClick(Sender: TObject);
begin
  if TSpeedButton(sender).Down then
  begin
    fr.btn:=rot;
    fr.LockMouse:=true;
  end
  else
  begin
    fr.LockMouse:=false;
    fr.btn:=-1;
  end;
  ui.cursor:=crDefault;    
  ui.m_RenderScene.invalidaterect;
end;

procedure TCtrlViewFrame.SpeedZoomClick(Sender: TObject);
begin
  ui.Zoom;
  ui.m_RenderScene.invalidaterect;
  SpeedZoom.Down:=false;
end;

procedure TCtrlViewFrame.ZoomBtnClick(Sender: TObject);
begin
  if TSpeedButton(sender).Down then
  begin
    fr.btn:=zoom;
    ui.setcursbyname('ZOOM_CURSOR');
  end
  else
    fr.btn:=-1;
  ui.m_RenderScene.invalidaterect;
end;
// используется в процедуре выбора объекта
procedure SetCamera(camera:cbasecamera;pos:point3;aim:point3);
var up:point3;
    test:single;
    TMtype:GLUInt;
    m:matrixgl;
    l_aspect:single;
begin
  up:=camera.getup;
  //if (camera.wndContext=nil) or (not camera.keepquad) then
  if not camera.keepquad then
  begin
    gluPerspective(camera.fov,camera.aspect,camera.nearplane,camera.farplane)
  end
  else
  begin
    l_aspect:=(camera.wndContext.ClientWidth/camera.wndContext.ClientHeight);
    gluPerspective(0.5,l_aspect,camera.nearplane,camera.farplane);
  end;
  // test:=multscalarp3(getSight,up);
  glulookat(pos.x,pos.y,pos.z,
            aim.x,aim.y,aim.z,
            up.x,up.y,up.z);
end;

// используется в процедуре выбора объекта
procedure SetIdentSelectView(pos:point3;aim:point3; w,h:integer);
var up:point3;
    test:single;
    TMtype:GLUInt;
    m:matrixgl;
    l_aspect:single;
begin
  up:=axisy;
  l_aspect:=(w/h);

  // GLdouble fovy,
  // GLdouble aspect,
  // GLdouble zNear,
  // GLdouble zFar
  gluPerspective(0.5,l_aspect,0.5,2);
  // test:=multscalarp3(getSight,up);
  glulookat(pos.x,pos.y,pos.z,
            aim.x,aim.y,aim.z,
            up.x,up.y,up.z);
end;

function cCtrlFrameListener.DoSelectInterface(x : GLint; y : GLint;size:single) : GLint;
var
  hits : GLint;
  vp:array[0..3] of integer;
  SelectBuf : Array [0..11] of GLint;  // массив для буфера выбора
  projection,modelview:array [0..15] of gldouble;
  aspect:single;
  dx,dy,dz:gldouble;
  p1,p2:point2;
  aim,pos:point3;
  width,heigth,I: Integer;
begin
  // Первое поле - количество объектов под курсором на момент нажатия.
  // Второе поле - минимальная Z глубина объекта (экранная Z координата).
  // Третье поле - максимальная Z глубина объекта (экранная Z координата).
  // Четвертое поле - идентификатор объекта.
  glSelectBuffer(12, @SelectBuf); // создание буфера выбора
  glRenderMode(GL_SELECT);// включаем режим выбора
  // режим выбора нужен для работы следующих команд
  glInitNames;// инициализация стека имен
  glPushName(0);
  glMatrixmode(gl_modelView);
  glpushmatrix;
  glLoadIdentity;
  glMatrixMode(GL_PROJECTION);
  glpushmatrix;
  glloadidentity;
  width:=cui(ui).m_RenderScene.m_wndContext.ClientWidth;
  heigth:=cui(ui).m_RenderScene.m_wndContext.ClientHeight;
  aspect:=(width/heigth);

  if aspect<1 then // heigth>width
    glOrtho(-1,1,-1/aspect,1/aspect,-1,2)
  else // width>heigth
    glOrtho(-aspect,aspect,-1,1,-1,2);

  // vp - хранит видовую матрицу
  glGetIntegerv(GL_VIEWPORT, @vp);
  glGetDoublev(GL_PROJECTION_MATRIX,@projection); // узнаём матрицу проекции.
  glGetDoublev(GL_MODELVIEW_MATRIX,@modelview);   // узнаём видовую матрицу.
  gluUnProject(x, vp[3]-y, 0, @projection, @modelview, @vp, dx, dy, dz);
  pos.x:=dx; pos.y:=dy; pos.z:=dz;
  gluUnProject(x, vp[3]-y, 1, @projection, @modelview, @vp, dx, dy, dz);
  aim.x:=dx; aim.y:=dy; aim.z:=dz;
  glloadidentity;
  SetIdentSelectView(pos,aim,width,heigth);
  glLoadName (2); // именуем под именем 2
  drawCycle(size,60);
  // отрисовка оси x
  p1.x:=-size; p1.y:=0; p2.x:=1; p2.y:=0;
  glLoadName (0); // именуем под именем 2
  drawline(p1,p2);
  // отрисовка оси y
  p1.x:=0; p1.y:=-size; p2.x:=0; p2.y:=size;
  glLoadName (1); // именуем под именем 2
  drawline(p1,p2);
  glflush;

  hits := glRenderMode(GL_Render);
  glpopmatrix;
  glmatrixmode(gl_modelView);
  glPopMatrix;
  if hits <= 0 then
    result := -1
  else
  begin
    result :=SelectBuf [(hits - 1) * 4 + 3];
  end;
end;

// Выбор осей методом буфера выбора
// Выбор объекта в точке
// возвращает 0 - ось x; 1 - y; 2 - z;
function DoSelect(x : GLint; y : GLint;m:matrixgl;camera:cbasecamera;len:single) : GLint;
var
  hits : GLint;
  vp:array[0..3] of integer;
  SelectBuf : Array [0..11] of GLint;  // массив для буфера выбора
  projection,modelview:array [0..15] of gldouble;
  dx,dy,dz:gldouble;
  pos,aim:point3;
  TMtype:GLUInt;
  I: Integer;
begin
 glGetIntegerv(gl_Matrix_Mode,@TMType);
 // Первое поле - количество объектов под курсором на момент нажатия.
 // Второе поле - минимальная Z глубина объекта (экранная Z координата).
 // Третье поле - максимальная Z глубина объекта (экранная Z координата).
 // Четвертое поле - идентификатор объекта.
 glSelectBuffer(12, @SelectBuf); // создание буфера выбора
 glRenderMode(GL_SELECT);// включаем режим выбора
 // режим выбора нужен для работы следующих команд
 glInitNames;// инициализация стека имен
 glPushName(0);
 glMatrixMode(GL_PROJECTION);
 glpushmatrix;
 // vp - хранит видовую матрицу
 glGetIntegerv(GL_VIEWPORT, @vp);
 glGetDoublev(GL_PROJECTION_MATRIX,@projection); // узнаём матрицу проекции.
 glGetDoublev(GL_MODELVIEW_MATRIX,@modelview);   // узнаём видовую матрицу.
 gluUnProject(x, vp[3]-y, 0, @projection, @modelview, @vp, dx, dy, dz);
 pos.x:=dx; pos.y:=dy; pos.z:=dz;
 gluUnProject(x, vp[3]-y, 1, @projection, @modelview, @vp, dx, dy, dz);
 aim.x:=dx; aim.y:=dy; aim.z:=dz;

 glloadidentity;
 //gluPickMatrix(0, 0, 5, 5, @vp);

 SetCamera(camera,pos,aim);
 // рисуем объекты с именованием объектов
 DrawSelectAxis(m,len);
 glflush;
 hits := glRenderMode(GL_Render);
 glpopmatrix;

 if hits <= 0 then
   Result := -1
 else
 begin
   Result :=SelectBuf [(hits - 1) * 4 + 3];
 end;

 if TMType = GL_MODELVIEW then
   glMatrixMode(GL_MODELVIEW);
 if TMType = GL_PROJECTION then
   glMatrixMode(GL_PROJECTION);
end;

end.
