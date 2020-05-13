unit uUI;
interface

uses   forms, controls, windows, messages, dialogs, sysutils, classes,
       uRender, uEventList, u3dTypes, uglFrameListener, uSceneMng,
       uGlEventTypes, uEventTypes, mathfunction, uNodeObject, uObject,
       uUIUtils, uSelecTools, uLog3dFile, uCursors, uConfigFile3d
       ,ubasecamera, uTestObjects, usetlist, uBaseObj, utimecontroller,
       uGroupObjects, uCommonTypes, uObjectTypes
       ;

type
  cUI = class
  public
    TimeCntrl:ctimeController;
    // объект рендера сцены
    m_RenderScene:cRender;
    // сцена
    scene:cscene;
    // идентификатор системы координат на которую воздействует пользователь
    AxisSystem:integer;
    // Конфигурационный файл. Хранит пути к ресурсам
    ConfigFile:cCfgFile;
    // информация о движении мыши.
    mouse:MouseStruct;
    // список курсоров
    cursors:tstringlist;
    // хранит ссыль на события сцены
    eventlist:ceventlist;
    // сбрасывается при перерисовке
    needredraw:boolean;
    tryselect:boolean;
    m_selectTools:cSelectTools; // информация о выделенном объекте
  private
    // яляется родителем лога
    log:cLog3dFile;
    oldMouseMoveProc,newMouseMoveProc:pointer;
    // выбранные объекты
    select:cSelectList;
  protected
    // Курсор - индекс картинки
    fcursor:integer;
  public
    updatehandle:boolean;
    // класс служит для дополнения оконной процедуры вне движка
    framelistener:cglFrameList;
  public
  private
    procedure updatecoord(var Msg : TMessage);
    procedure InitMouse;
    // Обновить приращения мыши. По ним camera определяет как надо повернуться
    Procedure WndProc(var Msg : TMessage);
    // по событию удаления зануляем выбраный объект
    procedure doNilSelected(sender:tobject);
    procedure setcursor(c:integer);
  public
    // возвращает Tbound в мировых координатах
    function getSelectBound(var res:boolean):tbound;
    // установка курсора по имени
    procedure SetCursByName(name:string);
    // переводит мировые в экранные
    procedure WorldToScreen(p3:point3;ViewMatrix:matrixgl;var winx:integer;var winy:integer;var winz:integer);
    constructor Create(Handle:hwnd;resourses:string);
    destructor destroy;
    // Получить индекс объекта в списке сцены
    function GetObjIndex(obj:cNodeObject):integer;
    function getselected(i:integer):cnodeobject;overload;
    function getselected:cnodeobject;overload;
    function GetSelectObjActiveAxisSystem:matrixgl;
    // Выделить объект
    procedure selectobject(obj:cnodeobject;UseGroupSettings:boolean);
    property cursor: integer read fcursor write setcursor;
    function GetSelectList:cselectlist;
    // необходимо вызывать после того как был обновлен список выбранных объектов select
    function selectCount:integer;
    // очистить список выбраных объектов. Не вызывает события!
    procedure ClearSelect;
    // не вызыает события
    procedure AddSelect(obj:cbaseobj);
    // вызыает соьытия gl_newSelect
    procedure UpdateSelected;
    procedure Zoom;
  end;


implementation

procedure cui.WorldToScreen(p3:point3;ViewMatrix:matrixgl;var winx:integer;var winy:integer;var winz:integer);
begin
  WorldToScr(p3,viewMatrix,winx,winy,winz);
end;

function cUI.GetSelectList:cselectlist;
begin
  result:=select;
end;

function cUI.selectCount:integer;
begin
  result:=select.count;
end;

procedure cUI.UpdateSelected;
var
  obj:cobject;
  i:integer;
begin
  // установка флагов нового выделенного объекта
  for I := 0 to select.Count - 1 do
  begin
    obj:=cobject(getselected(i));
    if obj<> nil then
      cobject(obj).setflag(draw_bound);
  end;
  // Вызов процедур подписанных на события объектов
  eventlist.CallAllEvents(E_glSelectNew);
end;

function cui.getSelectBound(var res:boolean):tbound;
var
  o:cbaseobj;
  i:integer;
  start:boolean;
  b:tbound;
  c:cbasecamera;
begin
  c:=m_RenderScene.activecamera;
  start:=true;
  res:=false;
  if selectCount=0 then
  begin
    for I := 0 to scene.count - 1 do
    begin
      o:=scene.getobj(i);
      if o=c then
        continue;
      if o is cObject then
      begin
        if start then
        begin
          res:=true;
          b:=cobject(o).GetAbsBound;
          start:=false;
        end
        else
        begin
          UpdateBound(cobject(o), b);
        end;
      end;
    end;
  end
  else
  begin
    for I := 0 to selectCount - 1 do
    begin
      o:=getselected(i);
      if o=c then
        continue;
      if o is cObject then
      begin
        if start then
        begin
          res:=true;
          b:=cobject(o).GetAbsBound;
          start:=false;
        end
        else
        begin
          UpdateBound(cobject(o), b);
        end;
      end;
    end;
  end;
  result:=b;
end;

procedure cui.Zoom;
var
  b:tbound;
  res:boolean;
begin
  b:=getSelectBound(res);
  m_RenderScene.activecamera.ZoomBound(b);
end;

procedure cui.ClearSelect;
var
  obj:cnodeobject;
  I: Integer;
begin
  for I := 0 to select.Count - 1 do
  begin
    obj:=getselected(i);
    if obj<> nil then
      cobject(obj).dropflag(draw_bound);
  end;
  select.Clear;
end;

procedure cui.AddSelect(obj:cbaseobj);
begin
  select.AddObj(obj);
end;

procedure cui.selectobject(obj:cnodeobject;UseGroupSettings:boolean);
var head:cnodeobject;
begin
  if obj=nil then
  begin
    ClearSelect;
    updateselected;
    m_selectTools.selected:=nil;
    EventList.CallAllEvents(E_glUnSelect);
    exit;
  end;
  // если объект в группе
  if UseGroupSettings then
  begin
    if obj.group then
    begin
      head:=GetGroupLeader(obj);
      if head.groupclosed then
      begin
        obj:=head;
      end;
    end;
  end;
  ClearSelect;
  AddSelect(obj);
  updateselected;
end;

procedure cUI.InitMouse;
begin
  mouse.m_RotSens:=1;
  mouse.m_MoveSens:=0.01;
  mouse.m_bChangeX:=true;
  mouse.m_bChangeY:=true;
end;

procedure cUI.setcursor(c:integer);
var cur:hcursor;
begin
  fcursor:=c;
  cur:=screen.Cursors[c];
  SetClassLong(m_RenderScene.m_wndContext.Handle,GCL_HCURSOR,cur);
  if EventList<>nil then
    EventList.CallAllEvents(E_glOnChangeCursor)
end;

constructor cUI.Create(Handle:hwnd;resourses:string);
var
  camera:cbaseCamera;
begin
  // режим выбора
  tryselect:=true;
  updatehandle:=false;
  fcursor:=crdefault;

  log:=cLog3dFile.Create((extractfiledir(application.ExeName)+'\logfile.log'));
  ConfigFile:=cCfgFile.create(resourses);
  scene:=cScene.create;
  eventlist:=scene.Events;
  m_RenderScene:=cRender.Create(self,handle, resourses, eventlist);
  m_RenderScene.scene:=scene;
  scene.render:=m_RenderScene;
  scene.Add(TestLight(self));

  camera:=TestCamera(self);
  scene.Add(camera);
  camera.active:=true;
  select:= cSelectList.create;

  // Создание контроллера времени
  TimeCntrl:=cTimeController.create;

  // Загрузка настроек
  loadUI(self);

  m_selectTools:=cselectTools.Create;
  newMouseMoveProc:=MakeObjectInstance(WndProc);
  OldMouseMoveProc:=Pointer(SetWindowLong(Handle,gwl_wndProc,Cardinal(newMouseMoveProc)));
  framelistener:=cglFrameList.create(self);
  EventList.AddEvent('UI DeleteObject', E_OnDestroyObject, donilselected);
  cursors:=LoadCursors;
end;

destructor cUI.destroy;
var
  i:integer;
  curs:ccursor;
begin
  saveUI(self);
  SetWindowLong(m_renderscene.m_wndContext.Handle,gwl_wndProc,integer(OldMouseMoveProc));
  EventList.CallAllEvents(E_glOnDestroyScene);

  ConfigFile.destroy;
  ConfigFile:=nil;
  select.destroy;
  select:=nil;
  //удаляется в cScene EventList.destroy;
  m_selectTools.destroy;
  m_selectTools:=nil;
  m_RenderScene.Destroy;
  m_RenderScene:=nil;
  scene.destroy;
  scene:=nil;
  log.Destroy;
  log:=nil;
  TimeCntrl.destroy;
  TimeCntrl:=nil;
  framelistener.destroy;
  framelistener:=nil;
  for i:=0 to cursors.Count-1 do
  begin
    curs:=ccursor(cursors.Objects[i]);
    curs.Destroy;
  end;
  cursors.Destroy;
  inherited;
end;

procedure cUI.doNilSelected(sender:tobject);
begin
  //m_selectTools.selected:=nil;
end;


procedure cUI.updatecoord(var Msg : TMessage);
var x,y:integer;
begin
   case msg.Msg of
     wm_mousemove:
     begin
       if msg.lParam>0 then
       begin
         x:= loWord(msg.lParam);
         y:= HiWord(msg.lParam);
         // Движение по x отвечает за вращение вокруг y
         mouse.dx:= x - mouse.x;
         // Движение по y инвертировано, из за иной ориентации вьюпорта в огл по сравнению с windows
         mouse.dy:=mouse.y - y;
         mouse.m_strafe.y:=-mouse.dx;
         mouse.m_strafe.x:=-mouse.dy;
         mouse.x:=X;
         mouse.y:=Y;
       end;
     end;
     wm_mousewheel:
     begin
       mouse.wheel:=hiword(msg.wparam);
     end;
   end;
end;

Procedure cUI.WndProc(var msg:TMessage);
//var
  //mesh:cmeshobr;
  //p3:point3;
  //selectp:integer;
  //obj:cnodeobject;
  //lm:matrixgl;
  //cursor:cCursor;
  //updatecamera,selectaxis:boolean;
begin
  //if updatehandle then
  //  showmessage('WndProc updatehandle');
  needredraw:=false;
  //updatecamera:=false;
  case msg.Msg of
    WM_MouseMove:
    begin
      updatecoord(msg);// обновление координат мыши и приращений движения в камере.
      EventList.CallAllEvents(E_glMouseMove);
    end;
    WM_MouseWheel:
    begin
      updatecoord(msg);// обновление координат мыши и приращений движения в камере.
    end;
   WM_SetCursor:
    begin
      //cursor:=ccursor(cursors.objects[0]);
      //windows.setCursor(cursor.HIcon);
    end;
   WM_LBUTTONUP:
    begin
      mouse.LButtonDown:=false;
    end;
    WM_LBUTTONDOWN:
    begin
      mouse.LButtonPos.X:=mouse.x;
      mouse.LButtonPos.y:=mouse.y;
      mouse.LButtonDown:=true;
    end;
    WM_SIZE:
    begin
      if m_renderscene<>nil then
        // процедура вызывает перерисовку родителя
        m_renderscene.ChangeSize;
    end;
  end;
  if msg.Msg=wm_paint then
  begin
     m_RenderScene.RenderScene;
     // сбрасываем флаг, что нужна перерисовка
     needredraw:=false;
  end;
  // вызов оконных процедур всех framelistener-в (специфические навороты на оконную процедуру,
  // определяемые пользователем движка для реализации специального интерфейса поль-
  // зователя)
  framelistener.wndproc(msg,mouse);
  if needredraw then
    m_renderscene.invalidaterect;
  // вызываем старую оконную процедуру
  msg.Result:=CallWindowProc( oldMouseMoveProc,m_renderScene.m_wndContext.Handle,
                              Msg.Msg,Msg.WParam,Msg.LParam);
end;

function cUI.getselected(i:integer):cnodeobject;
begin
  if i<select.Count then
    result:=cnodeobject(select.Items[i])
  else
    result:=nil;
end;

function cUI.getselected:cnodeobject;
begin
  if select.Count<>0 then
    result:=cnodeobject(select.Items[0])
  else
    result:=nil;
end;


function cUI.GetSelectObjActiveAxisSystem:matrixgl;
var obj,camera:cnodeobject;
    m:matrixgl;
begin
  obj:=cnodeobject(getselected(0));
  if obj<>nil then
  begin
    result:=cobject(obj).activesystem(AxisSystem);
  end;
end;

function cui.GetObjIndex(obj:cNodeObject):integer;
begin
  if obj=nil then
    result:=-1
  else
    result:=scene.objects.GetIndex(obj);
end;

procedure cui.SetCursByName(name:string);
var
 curs:cCursor;
 i:integer;
begin
  curs:=nil;
  if cursors.find(name,i) then
    curs:=ccursor(cursors.Objects[i]);
  if curs<>nil then
  begin
    cursor:=curs.index;
  end
  else
    cursor:=crDefault;
end;


end.
