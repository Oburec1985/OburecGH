// файлы DesignIntf DesignEditors и Proxies становятся доступны после подключения
// $(Delphi)Lib/designide.dcp
unit uBaseGlComponent;

interface
uses
  SysUtils, Classes, Controls, messages, dialogs,
  uUInterface, load3ds, uRenderScene, uobject,ueditobj ;

type

  cBaseGlComponent = class(TWinControl)
  private
    res:string;
    scene:string;
    pos:cpoint3;
  protected
    procedure init;
    // получить/установить путь к ресурсам
    procedure SetSceneName(val:string);
    function GetSceneName:string;
    // получить/установить путь к ресурсам
    procedure SetResources(val:string);
    function GetResources:string;
    // Получить записать объект сцены
    function getObj:cobject;
    procedure setObj(obj:cobject);
    procedure WndProc(var Message:TMessage);override;
  public
    mUI:cUInterface;
    Constructor Create(AOwner:TComponent);override;
    destructor destroy;
  published
    // Позиция объекта
   // property position:cpoint3 read pos write pos;
    // Свойство отвечает за объекты сцены
    property obj: cobject read getobj write setobj;
    property scenename:string read getscenename write setscenename;
    property resources:string read getresources write setresources;
  end;


implementation

procedure cBaseGlComponent.init;
begin
  if fileexists(scene) then
  begin
    if mUI<>nil then
    begin
      //showmessage('Начинаю загружать файл:' + scene);
      mUI.m_RenderScene.LoadScene(scene);
    end;
  end;
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

procedure cBaseGlComponent.setObj(obj:cobject);
begin

end;

function cBaseGlComponent.getObj:cobject;
var obj:cobject;
begin
  // Если не поставить nil редактор свойств будет ругаться
  result:=nil;
  if mUI<>nil then
  begin
    if mUI.getselected(obj) then result:=obj;
  end;
end;

procedure cBaseGlComponent.SetResources(val:string);
begin
  res:=val;
  if fileexists(res) then
  begin
    if mUI=nil then
    begin
      mUI:=cUInterface.Create(handle, res);
      init;
    end;
  end;
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
  pos:=cpoint3.Create;
end;

destructor cBaseGlComponent.destroy;
begin
  mUI.destroy;
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

end.
