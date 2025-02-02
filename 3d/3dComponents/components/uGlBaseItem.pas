unit uGlBaseItem;

interface
uses
  SysUtils, Classes, Controls, messages, dialogs, usceneMng, ueventlist,
  uUI, uRender, uobject, uNodeObject, mathfunction , uCommonTypes;

type
  cpoint3 = class(tPersistent)
  public
    p3:point3;
    // ����� �������� ���������� � ��� ����� ��������� ������������ p3 ���� ��
    // ������ x,y ��� z
    setflag:byte;
    fSetPosEvent:tnotifyevent;
  protected
    function getx:single;
    procedure setx(v:single);
    function gety:single;
    procedure sety(v:single);
    function getz:single;
    procedure setz(v:single);
  published
    property x:single read getx write setx;
    property y:single read gety write sety;
    property z:single read getz write setz;
  end;

  glRegItem = class(tcomponent)
  protected
    fpos:cpoint3;
    allinit:boolean;
  public
    node:cnodeobject;
    fbasegl:tobject;
  // �������
  private
    fonclick:tnotifyevent;
  public
    function gettype:string;virtual;
    function InitUI:boolean;
    constructor create(aowner:tcomponent);
    destructor destroy;override;
  public
    // ���������� �������������� ����� ��������� ���������� �������� ��� �������� �����
    procedure setParent(v:tcomponent);
  protected
    // �������� �������� ������ ������ �� �������� ��������
    procedure doClick(sender:tobject);
    // ���������� ������������ ���������
    procedure redraw;
    procedure loaded;override;
    procedure init;virtual;
    // ���������� ����� ����������� ������� � �����
    procedure BeforeAddObj(obj:cnodeobject);virtual;
    procedure DoInit(sender:Tobject);
    procedure DoBeforeAddObj(sender:Tobject);
  protected
    function getscene:cscene;

    procedure initEvents;virtual;
    // ����� TComponent �������� ��� ���������� ����� ������ � ������.
    // ���� ���� ����� �� �����������, ����������� ������ ������� �������.
    function GetParentComponent:tcomponent;override;
    function HasParent: Boolean; override;
    // ����� TComponent �������� ��� �������������� �������� ������ ��� ������
    // �� ������. ���� ���� ����� �� �����������, ������������� ��������� ����-
    // ������.
    procedure SetParentComponent (Value: TComponent); override;
    //opInsert ��������� ������ ������.
    //opRemove ��������� ������ ���������.
    procedure notification(AComponent: TComponent; Operation: TOperation);override;
  private
    function getOwnerName:string;
    procedure setBase(base:tobject);
    function getBase:tobject;
  public
    property basegl:tobject read getBase write setBase ;
  protected
    procedure SetName(const NewName: TComponentName);override;
    procedure setevent(sender:tobject);
    procedure setposition(pos:cpoint3);
    function getposition:cpoint3;
    procedure SetOnClick(event:TNotifyEvent);
    function GetOnClick:TNotifyEvent;    
  published
    property OnClick:tnotifyevent read GetOnClick write SetOnClick;
    property ParentName:string read GetOwnerName;
    property position:cpoint3 read getposition write setposition;
  end;

implementation
 uses ubaseglcomponent, uGlComponent;

 // ����� ��� �������� ��������� x,y,z
procedure cpoint3.setx(v: Single);
begin
  p3.x:=v;
  setflag:=0;
  if assigned(fSetPosEvent) then
     fsetPosEvent(self);
end;

function cpoint3.getx:single;
begin
  result:=p3.x;
end;

procedure cpoint3.sety(v: Single);
begin
  p3.y:=v;
  setflag:=1;
  if assigned(fSetPosEvent) then
     fsetPosEvent(self);
end;

function cpoint3.gety:single;
begin
  result:=p3.y;
end;

procedure cpoint3.setz(v: Single);
begin
  p3.z:=v;
  setflag:=2;
  if assigned(fSetPosEvent) then
     fsetPosEvent(self);
end;
function cpoint3.getz:single;
begin
  result:=p3.z;
end;

procedure glregitem.BeforeAddObj(obj:cnodeobject);
begin

end;

procedure glregitem.doClick(sender:tobject);
begin
  if assigned(fonclick) then
    fonclick(self);
end;

function glregitem.GetOnClick:TNotifyEvent;
begin
  result:=fonclick;
end;

procedure glregitem.SetOnClick(event:TNotifyEvent);
begin
  fonclick:=event;
end;


procedure glregitem.DoBeforeAddObj(sender:Tobject);
begin
  beforeaddobj(cNodeObject(sender));
end;

procedure glregitem.setevent(sender:tobject);
begin
  if cpoint3(sender)<>nil then
  begin
    if csloading in componentstate then
    begin
      case cpoint3(sender).setflag of
        0:fpos.p3.x:=cpoint3(sender).x;
        1:fpos.p3.y:=cpoint3(sender).y;
        2:fpos.p3.z:=cpoint3(sender).z;
      end;
    end;
    if node<>nil then
    begin
      node.position:=cpoint3(sender).p3;
      cBaseGlComponent(basegl).mUI.m_RenderScene.invalidaterect;
    end;
  end;
end;

procedure glRegItem.setposition(pos:cpoint3);
begin
  if pos<>nil then
  begin
    if node<>nil then
    begin
      node.position:=pos.p3;
      cBaseGlComponent(basegl).mUI.m_RenderScene.invalidaterect;
    end;
  end;
end;

function glRegItem.getposition:cpoint3;
var p3:point3;
begin
  if fpos=nil then
  begin
    fpos:=cpoint3.create;
    fpos.fSetPosEvent:=setevent;
  end;
  if node<>nil then
  begin
    if fpos<>nil then
    begin
      fpos.p3:=node.position;
    end;
  end;
  result:=fpos;
end;

constructor glRegItem.create(aowner:tcomponent);
begin
  inherited create(aowner);
  Allinit:=false;
  fpos:=cpoint3.create;
  fpos.fSetPosEvent:=setevent;
  node:=nil;
  setsubcomponent(true);
  if aowner is cBaseGlComponent then
    setParent(aowner);
end;

destructor glRegItem.destroy;
var scene:cscene;
begin
  if node<>nil then
  begin
    scene:=getscene;
    if scene<>nil then
    begin
      node.destroy;
      //scene.DeleteObj(node);
      redraw;
    end;
  end;
  fpos.Destroy;
  if basegl<>nil then
    cBaseglComponent(basegl).removeChild(self);
  inherited;
end;

function glRegItem.getscene:cscene;
var ui:cUI;
begin
  result:=nil;
  if basegl<>nil then
  begin
    ui:=cbaseglcomponent(basegl).mUI;
    if ui<>nil then
      result:=ui.scene;
  end;
end;

procedure glRegItem.redraw;
begin
  if cBaseglComponent(basegl)<>nil then
  begin
    if cBaseglComponent(basegl).mUI<>nil then
    begin
      if cBaseglComponent(basegl).mUI.m_RenderScene<>nil then
        cBaseglComponent(basegl).mUI.m_RenderScene.invalidaterect;
    end;
  end;
end;

procedure glRegItem.notification(AComponent:TComponent; Operation:TOperation);
begin
  inherited notification(AComponent,Operation);
  case operation of
    opInsert:
    begin
      //acomponent
    end;
    opRemove:
    begin
      if acomponent=fbasegl then
        fbasegl:=nil;
      //if (AComponent=self) or (AComponent=basegl) then
      //  cBaseglComponent(basegl).removeChild(self);
    end;
  end;
end;

procedure glRegItem.loaded;
begin
  initEvents;
end;

procedure glRegItem.initEvents;
begin
  if name<>'' then
  begin
    cBaseGlComponent(basegl).EList.AddEvent(name+' InitComponent',E_ComponentInit,doInit);
  end;
end;

function glRegItem.HasParent: Boolean;
begin
  if basegl<>nil then
    result:=true
  else
    result:=false;
end;

function glRegItem.GetParentComponent:tcomponent;
begin
  result:=nil;
  if basegl<>nil then
  begin
    result:=tcomponent(basegl);
  end;
end;

procedure glRegItem.setParent(v:tcomponent);
begin
  basegl:=v;
  cBaseGlComponent(basegl).subcomponents.Add(self);
  // ����������� �� ������� ������������� ����������. ��������� ��� ������������� ���������
  // ���������� cBaseGlComponent.
  doinit(nil);
end;

procedure glRegItem.SetParentComponent (Value: TComponent);
begin
  setparent(value);
end;

function glRegItem.getOwnerName:string;
begin
  if owner<>nil then
  begin
    result:=owner.Name;
  end
  else
    result:='nil';
end;

procedure glRegItem.init;
begin
  if node<>nil then
  begin
    if name<>'' then
    begin
      node.name:=name;
      node.freezObj:=true;
      cobject(node).fOnClick:=doClick;
    end;
    setposition(fpos);
  end;
end;

procedure glRegItem.DoInit(sender:Tobject);
begin
  if fbasegl<>nil then
  begin
    if fbasegl is cbaseglcomponent then
    begin
      init;
    end;
  end;
end;

procedure glRegItem.setBase(base:tobject);
begin
  fbasegl:=base;
end;

function glRegItem.getBase:tobject;
begin
  result:=fbasegl;
end;


function glRegItem.gettype:string;
begin
  result:=classname;
end;

procedure glRegItem.SetName(const NewName: TComponentName);
begin
  inherited;
  if node<>nil then
  begin
    node.name:=NewName;
  end;
end;

function glRegItem.InitUI:boolean;
begin
  result:=false;
  if basegl<>nil then
  begin
    if cBaseGlComponent(basegl).mUI<>nil then
      result:=true;
  end;
end;

initialization
  registerclass(cpoint3);
finalization
  unregisterclass(cpoint3);

end.
