// файлы DesignIntf DesignEditors и Proxies становятся доступны
// после подключения $(Delphi)Lib/designide.dcp
unit uBaseGlComponent;

interface
uses
  SysUtils, Classes, Controls, messages, dialogs, Load3ds,
  uUInterface, uRenderScene, uobject,ueditobj, uNodeObject, uGlBaseItem,
  uGlComponent, windows, uEventList;

const
  E_ComponentInit = 0;

type

  cBaseGlComponent = class(twincontrol)
  private
    res:string;
    scene:string;
    // декорации на сцене. Объекты созданы без помощи idesigner
    mObjects:array of ceditobj;
  public
    // сслыка на список событий компонента
    EList:cEventList;
    // Если свойство true значит объект был обновлен и сцену надо сохранить
    update:boolean;
    // ссылка на объект движка
    mUI:cUInterface;
    // Объекты созданы с помощью idesigner
    //SubComponents:TList;
    Constructor Create(AOwner:TComponent);override;
    destructor destroy;
  public
    procedure redraw;
  protected
    // создание списка объектов cEditObjects для сохранения в dfm файл
    procedure lincObjects;
    // создание списка объектов cEditObjects для сохранения в dfm файл
    procedure deleteobjects;
    // здесь происходит загрузка сцены
    procedure init;
    // получить/установить путь к ресурсам
    procedure SetSceneName(val:string);
    function GetSceneName:string;
    // получить/установить путь к ресурсам
    procedure SetResources(val:string);
    function GetResources:string;
    // Получить записать объект сцены
    function getObj:cobject;
    //-------------------------------
    function readObj(i:integer):ceditobj;
    procedure WndProc(var Message:TMessage);override;
    // вызывается после загрузки формы
    procedure Loaded; override;
  protected
    // Процедура которая вызывается при сохранении сцены
    procedure WriteState(Writer: TWriter);override;
    // Переопределенный метод для сохранения свойств объектов
    // Позволяет указать ссылку на процедуру которая будет сохранять то или иное
    // свойство
    procedure DefineProperties(Filer: TFiler); override;
    //function GetChildOwner:tcomponent; override;
    //function GetChildParent:tcomponent;override;
  private
    // процедура сохранения измененных свойств объектов в форму
    procedure readObjects(Reader: TReader);
    // процедура загрузки измененных свойств объектов в форму
    procedure writeObjects(Writer: TWriter);
    //
    procedure GetChildren(Proc: TGetChildProc;Root: TComponent);override;
    function getSubComponent(index:integer):glRegItem;
    procedure InitScene;
    // инициализация контекста окна. Происходит при первом показывании окна
    procedure Oninithandle(var Message: TCMControlListChanging);message wm_size;
  public
    // заведено для того. чтобы сохранять
    property objects[i:integer]:ceditobj read readObj;
  public
  public
    property subComponent[index:integer]:glRegItem read getSubComponent;
  published
    // Позиция объекта
    // property position:cpoint3 read pos write pos;
    // Свойство отвечает за объекты сцены
    property obj: cobject read getobj;
    property scenename:string read getscenename write setscenename;
    property resources:string read getresources write setresources;
  end;


implementation

procedure cBaseGlComponent.redraw;
begin
  mUI.m_RenderScene.invalidaterect;
end;

// Переопределенный метод для сохранения свойств объектов
procedure cBaseGlComponent.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  self.DockSite:=true;
  // Определить методы сохранения свойства TextHistory в файл формы
  //Filer.DefineProperty('Objects', readObjects, writeObjects, true);
end;

procedure cBaseGlComponent.GetChildren(Proc: TGetChildProc;Root: TComponent);
var
 i: integer;
begin
 //for i := 0 to SubComponents.Count-1 do
 showmessage('componentcount '+inttostr(ComponentCount));
 for i := 0 to ComponentCount-1 do
 begin
   //Proc(TComponent(subcomponents.Items[i]));
   Proc(TComponent(Components[i]));
 end;
end;

// процедура сохранения измененных свойств объектов в форму
procedure cBaseGlComponent.readObjects(Reader: TReader);
begin
  try
    //Найти маркер начала списка
    Reader.ReadListBegin;
    // Загрузить элементы списка истории
    while not Reader.EndOfList do
    begin
      Reader.ReadString;
    end;
    // Прочитать маркер окончания списка
    Reader.ReadListEnd;
  except
    raise;
  end;
end;

procedure cBaseGlComponent.WriteState(Writer: TWriter);
var i:integer;
    obj:ceditobj;
begin
 showmessage('writeState');
 inherited WriteState(Writer);
 if update then
 begin
   //showmessage('writeState update');
   update:=false;
   if mui<>nil then
   begin
     //showmessage('writeState ui<>nil');
     mUI.m_RenderScene.m_Loader.SaveScene(scene);
   end;
 end;
 showmessage('writeState цикл');
 for I := 0 to ComponentCount - 1 do
 begin
 end;
 //showmessage('writeState end');
 //Writer.Root:=self;
 //for I := 0 to length(mobjects) - 1 do
 //begin
 //  obj := mobjects[i];
 //  if obj.Owner = Writer.Root then
    //Writer.WriteComponent(obj);
 //end;
end;

// процедура загрузки измененных свойств объектов в форму
procedure cBaseGlComponent.writeObjects(Writer: TWriter);
var
  len,i:integer;
begin
  // Записать маркер начала списка
  len:=length(mObjects);
  if len=0 then exit;
  Writer.WriteListBegin;
  // Записать историю изменений
  //  Writer.root:=self;
  //  Writer.WriteComponent(self);
  //  for i:=0 to len-1 do
  //  begin
  //  end;
  //  showmessage('Закончил писать компоненты');
  // Записать маркер окончания списка
  Writer.WriteListEnd;
end;

procedure cBaseGlComponent.deleteobjects;
var i,len:integer;
begin
  len:=length(mobjects);
  for I := 0 to len - 1 do
  begin
    mobjects[i].destroy;
  end;
  setlength(mobjects,0);
end;

procedure cBaseGlComponent.lincObjects;
var len,i:integer;
    obj:cEditObj;
begin
  len:=mUI.m_RenderScene.GetCount;
  setlength(mObjects,len);
  for I := 0 to len - 1 do
  begin
    obj:=ceditobj.create(self);
    mobjects[i]:=obj;
    obj.SetObj(cobject(mUI.m_RenderScene.m_Loader.GetObj(i)));
  end;
end;

procedure cBaseGlComponent.init;
begin
  if fileexists(scene) then
  begin
    if mUI<>nil then
    begin
      mUI.m_RenderScene.LoadScene(scene);
      lincObjects;
    end;
  end;
end;

procedure cBaseglComponent.Loaded;
begin
  inherited;
  InitScene;
end;

procedure cBaseGlComponent.SetSceneName(val:string);
begin
  scene:=val;
  init;
end;

function cBaseGlComponent.GetSceneName:string;
begin
  result:=scene;
end;

function cBaseGlComponent.readObj(i:integer):ceditobj;
var obj:cobject;
    len:integer;
begin
  // Если не поставить nil редактор свойств будет ругаться
  len:=length(mObjects);
  result:=nil;
  if mUI<>nil then
  begin
    if i<len then
      result:=mObjects[i];
  end;
end;

function cBaseGlComponent.getObj:cobject;
var obj:cobject;
begin
  // Если не поставить nil редактор свойств будет ругаться
  result:=nil;
  if mUI<>nil then
  begin
    if mUI.getselected(cNodeObject(obj)) then result:=obj;
  end;
end;

procedure cBaseGlComponent.Oninithandle;
begin
  InitScene;
end;

procedure cBaseGlComponent.InitScene;
begin
  if HandleAllocated then
  begin
    if fileexists(res) then
    begin
      if mUI=nil then
      begin
        mUI:=cUInterface.Create(handle, res);
        init;
        // вызов событий подписанных компонентов
        EList.CallAllEvents(E_ComponentInit);
      end
      else
      begin
      end;
    end;
  end;
end;

procedure cBaseGlComponent.SetResources(val:string);
begin
  res:=val;
  if not (csLoading in componentstate) then
    InitScene;
end;

function cBaseGlComponent.GetResources:string;
begin
  result:=res;
end;

Constructor cBaseGlComponent.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  parent:=TWinControl(AOwner);
  Width:=200;
  hEIght:=200;
  resources:='';
  scenename:='';
  update:=false;
  //SubComponents:=tlist.Create;
  EList:=cEventList.create(self,false);
  SetSubComponent(true);
end;

destructor cBaseGlComponent.destroy;
begin
  mUI.destroy;
  deleteobjects;
  //SubComponents.Destroy;
  inherited destroy;
end;

procedure cBaseGlComponent.WndProc(var Message:TMessage);
begin
 inherited WndProc(Message);
 case Message.Msg of
   wm_paint:
   begin
     //mUI.m_RenderScene.RenderScene;
   end;
 end;
end;

{
// процедура загрузки измененных свойств объектов в форму
procedure cBaseGlComponent.writeObjects(Writer: TWriter);
var
  i:integer;
begin
  // Записать маркер начала списка
  Writer.WriteListBegin;
  // Записать историю изменений
  for i:=0 to mUI.m_RenderScene.GetCount-1 do
  begin
    Writer.WriteString(mUI.m_RenderScene.m_Loader.GetObj(i).name);
  end;
  // Записать маркер окончания списка
  Writer.WriteListEnd;
end;
}

function cBaseGlComponent.getSubComponent(index:integer):glRegItem;
begin
  //result:=glRegItem(subcomponents.items[index]);
  result:=glRegItem(Components[index]);
end;

end.
