unit uEditObj;

interface
uses  uUI, classes, MathFunction,
      uobject,sysutils,dialogs, uCommonTypes;

type
  cpoint3_ = class(tPersistent)
  private
    parent:pointer;
  public
    p3:point3;
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

  cEditObj = class(TComponent)
  public
    parent:pointer; // ссылка на cDaseGlComponent
  protected
    obj:cobject;
    m_pos:cpoint3_;
  private
    function getName:string;
  public
    constructor create(aowner:tcomponent);//override;
    destructor destroy;
    Procedure SetObj(pObj:cobject);
    function getObj:cobject;
    Procedure setPosition(pos:cpoint3_);
    function getPosition:cpoint3_;
  published
    property position:cpoint3_ read getPosition write setPosition;
    property name:string read getName;
  end;

implementation
  uses ubaseglcomponent, uNodeObject;
// класс для хранения координат x,y,z
procedure cpoint3_.setx(v: Single);
begin
  p3.x:=v;
  if parent<>nil then
  begin
    ceditobj(parent).setPosition(self);
  end;
  if assigned(fSetPosEvent) then
     fsetPosEvent(self);
end;

function cpoint3_.getx:single;
begin
  result:=p3.x;
end;

procedure cpoint3_.sety(v: Single);
begin
  p3.y:=v;
  if parent<>nil then
  begin
    ceditobj(parent).setPosition(self);
  end;
  if assigned(fSetPosEvent) then
     fsetPosEvent(self);
end;
function cpoint3_.gety:single;
begin
  result:=p3.y;
end;

procedure cpoint3_.setz(v: Single);
begin
  p3.z:=v;
  if parent<>nil then
  begin
    ceditobj(parent).setPosition(self);
  end;
  if assigned(fSetPosEvent) then
     fsetPosEvent(self);  
end;
function cpoint3_.getz:single;
begin
  result:=p3.z;
end;

constructor cEditObj.create(aowner:tcomponent);
begin
  inherited create(aowner);
  m_pos:=cpoint3_.create;
  m_pos.parent:=self;
//  parent:=aowner;
end;

destructor cEditObj.destroy;
begin
  m_pos.destroy;
end;

// Установить объект
procedure cEditObj.setPosition(pos:cpoint3_);
begin
  m_pos.p3:=pos.p3;
  if obj<>nil then
  begin
    obj.position:=m_pos.p3;
    if parent<>nil then
    begin
      cBaseGlComponent(parent).mUI.m_RenderScene.invalidaterect;
      cBaseGlComponent(parent).update:=true;
    end;
  end;
end;

function cEditObj.getPosition:cpoint3_;
var p3:point3;
begin
  result:=nil;
  if m_pos<>nil then
  begin
    m_pos.p3:=obj.position;
  end;
  result:=m_pos;
end;
// Установить объект
procedure cEditObj.setObj(pObj:cobject);
begin
  obj:=pObj;
end;

function cEditObj.getObj:cobject;
begin
  result:=obj;
end;
// Получить имя объекта
function cEditObj.getName:string;
begin
  if obj<>nil then
    result:=obj.name;
end;

end.
