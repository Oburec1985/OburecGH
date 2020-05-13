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
    // ������ ������� �����
    m_RenderScene:cRender;
    // �����
    scene:cscene;
    // ������������� ������� ��������� �� ������� ������������ ������������
    AxisSystem:integer;
    // ���������������� ����. ������ ���� � ��������
    ConfigFile:cCfgFile;
    // ���������� � �������� ����.
    mouse:MouseStruct;
    // ������ ��������
    cursors:tstringlist;
    // ������ ����� �� ������� �����
    eventlist:ceventlist;
    // ������������ ��� �����������
    needredraw:boolean;
    tryselect:boolean;
    m_selectTools:cSelectTools; // ���������� � ���������� �������
  private
    // ������� ��������� ����
    log:cLog3dFile;
    oldMouseMoveProc,newMouseMoveProc:pointer;
    // ��������� �������
    select:cSelectList;
  protected
    // ������ - ������ ��������
    fcursor:integer;
  public
    updatehandle:boolean;
    // ����� ������ ��� ���������� ������� ��������� ��� ������
    framelistener:cglFrameList;
  public
  private
    procedure updatecoord(var Msg : TMessage);
    procedure InitMouse;
    // �������� ���������� ����. �� ��� camera ���������� ��� ���� �����������
    Procedure WndProc(var Msg : TMessage);
    // �� ������� �������� �������� �������� ������
    procedure doNilSelected(sender:tobject);
    procedure setcursor(c:integer);
  public
    // ���������� Tbound � ������� �����������
    function getSelectBound(var res:boolean):tbound;
    // ��������� ������� �� �����
    procedure SetCursByName(name:string);
    // ��������� ������� � ��������
    procedure WorldToScreen(p3:point3;ViewMatrix:matrixgl;var winx:integer;var winy:integer;var winz:integer);
    constructor Create(Handle:hwnd;resourses:string);
    destructor destroy;
    // �������� ������ ������� � ������ �����
    function GetObjIndex(obj:cNodeObject):integer;
    function getselected(i:integer):cnodeobject;overload;
    function getselected:cnodeobject;overload;
    function GetSelectObjActiveAxisSystem:matrixgl;
    // �������� ������
    procedure selectobject(obj:cnodeobject;UseGroupSettings:boolean);
    property cursor: integer read fcursor write setcursor;
    function GetSelectList:cselectlist;
    // ���������� �������� ����� ���� ��� ��� �������� ������ ��������� �������� select
    function selectCount:integer;
    // �������� ������ �������� ��������. �� �������� �������!
    procedure ClearSelect;
    // �� ������� �������
    procedure AddSelect(obj:cbaseobj);
    // ������� ������� gl_newSelect
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
  // ��������� ������ ������ ����������� �������
  for I := 0 to select.Count - 1 do
  begin
    obj:=cobject(getselected(i));
    if obj<> nil then
      cobject(obj).setflag(draw_bound);
  end;
  // ����� �������� ����������� �� ������� ��������
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
  // ���� ������ � ������
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
  // ����� ������
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

  // �������� ����������� �������
  TimeCntrl:=cTimeController.create;

  // �������� ��������
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
  //��������� � cScene EventList.destroy;
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
         // �������� �� x �������� �� �������� ������ y
         mouse.dx:= x - mouse.x;
         // �������� �� y �������������, �� �� ���� ���������� �������� � ��� �� ��������� � windows
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
      updatecoord(msg);// ���������� ��������� ���� � ���������� �������� � ������.
      EventList.CallAllEvents(E_glMouseMove);
    end;
    WM_MouseWheel:
    begin
      updatecoord(msg);// ���������� ��������� ���� � ���������� �������� � ������.
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
        // ��������� �������� ����������� ��������
        m_renderscene.ChangeSize;
    end;
  end;
  if msg.Msg=wm_paint then
  begin
     m_RenderScene.RenderScene;
     // ���������� ����, ��� ����� �����������
     needredraw:=false;
  end;
  // ����� ������� �������� ���� framelistener-� (������������� �������� �� ������� ���������,
  // ������������ ������������� ������ ��� ���������� ������������ ���������� ����-
  // ��������)
  framelistener.wndproc(msg,mouse);
  if needredraw then
    m_renderscene.invalidaterect;
  // �������� ������ ������� ���������
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
