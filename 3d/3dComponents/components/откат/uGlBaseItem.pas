unit uGlBaseItem;

interface
uses
  SysUtils, Classes, Controls, messages, dialogs, Load3ds,
  uUInterface, uRenderScene, uobject,ueditobj, uNodeObject ;

type

  glRegItem = class(tcomponent)
  public
    node:cnodeobject;
    fbasegl:tobject;
  public
    function gettype:string;virtual;
  public
    constructor create(aowner:tcomponent);
    destructor destroy;override;
  public
    // Необходимо переопределить чтобы правильно установить родителя при загрузке формы
    procedure setParent(v:tcomponent);
  protected
    // отрисовать родительский компонент
    procedure redraw;
    procedure init;virtual;
    procedure DoInit(sender:Tobject);
  protected
    function getscene:cscene;

    procedure initEvents;virtual;
    // Метод TComponent перекрыт для сохранения всего дерева в потоке.
    // Если этот метод не перекрывать, сохраняется только текущий элемент.
    function GetParentComponent:tcomponent;override;
    function HasParent: Boolean; override;
    // Метод TComponent перекрыт для восстановления иерархии дерева при чтении
    // из потока. Если этот метод не перекрывать, подчиненность элементов нару-
    // шается.
    procedure SetParentComponent (Value: TComponent); override;
    //opInsert указанный объект создан.
    //opRemove указанный объект уничтожен.
    procedure notification(AComponent: TComponent; Operation: TOperation);override;
  private
    function getOwnerName:string;
    procedure setBase(base:tobject);
    function getBase:tobject;
  public
    property basegl:tobject read getBase write setBase ;
  published
    property ParentName:string read GetOwnerName;
  end;

implementation
 uses ubaseglcomponent, uGlComponent;


constructor glRegItem.create(aowner:tcomponent);
begin
  inherited create(aowner);
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
    scene.DeleteObj(node);
    redraw;
  end;
  inherited;
end;

function glRegItem.getscene:cscene;
var ui:cUInterface;
begin
  ui:=cbaseglcomponent(basegl).mUI;
  if ui<>nil then
    result:=ui.m_RenderScene.m_Loader
  else
    result:=nil;
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
      //ResetSubclass;
      //tcomponent(basegl).RemoveComponent(self);
      //showmessage('remove Component');
    end;
  end;
end;

procedure glRegItem.initEvents;
begin

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
  //cBaseGlComponent(basegl).subcomponents.Add(self);
  cBaseGlComponent(basegl).InsertComponent(self);
  // подвязываем на событие родительского компонента. Вызовется при инициализации контекста
  // компонента cBaseGlComponent.
  cBaseGlComponent(basegl).EList.AddEvent(name+' InitComponent',E_ComponentInit,doInit);
  DoInit(self);
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

initialization

end.
