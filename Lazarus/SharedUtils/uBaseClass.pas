unit uBaseClass;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, uEventTypes, uEventList, fpjson;

type
  TBaseObjManager = class; 
  TBaseObj = class;
  
  { Список объектов с типизированным доступом }

  { TBaseObjList }

  TBaseObjList = class(TObjectList)
  private
    function GetItem(Index: Integer): TBaseObj;
  public
    constructor Create;
//    procedure AddObject(o:tbaseObj);
    procedure AddObject(ABaseObj : TBaseObj; Root : TBaseObj);
    function FindByName(const AName: string): TBaseObj;
    property Items[Index: Integer]: TBaseObj read GetItem; default;
  end;
  
  TBaseObjClass = class of TBaseObj;

  { Базовый объект }

  { TBaseObj }

  TBaseObj = class
  private
    procedure SetParent(AParent: TBaseObj);virtual;
    function GetChild(const Index: Integer): TBaseObj;
    function GetChildCount: Integer;
  protected
    // уникальное имя внутри менеджера объектов. При добавлении к менеджеру если такое имя есть
    // то автоинкемент на конце имени
    fName: string;
    // при моздании текстовая метка равна имени. Внутри менеджера может быть несколько обьектов с одинаковой меткой
    fCaption: string;
    fParent: TBaseObj;
    m_Children: TBaseObjList;
    fManager: TBaseObjManager;
    // переименовать в AutoCreate. Логика этой переменной определяет сразу нобор поведений:
    // 1) объект создается как вспомогательный подкаталог внутри родительского класса. Соответственно удаляется тоже вместе с ним
    // 2) дочерние элементы при запросе MainParent возвращают не каталог в котором лежат а именно класс создатель этого каталога
    fAutoCreate:boolean;
    // удалять или нет когда удаляеим родитльский объект
    // если родитель удаляется, а флаг=false, то линкуем объект в корень менеджера объектов
    fDestroyWithParent: Boolean;
    // в процессе уничтожения
    fDestroying: Boolean;

    procedure SetManager(AManager: TBaseObjManager); virtual;
    procedure SetName(const AValue: string); virtual;
              {
    procedure setState(s:TEngineState);
    function getState:TEngineState;}
    // Вход/ выход в крит секцию. Не реализованы. Крит секцию надо увщзять которая работает в linux и windows
    procedure EnterCS;                //скопипастили из TBladeEngine
    procedure ExitCS;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    function CreateChild(const AClassName: string): TBaseObj; virtual;
    procedure AddChild(AChild: TBaseObj); virtual;
    // получить потомка по совпадению меток. Пока не реализован метод
    function getChildrenByCaption(const AName: string): TBaseObj;
    // получить родителя по имени класса
    function getParentByClassName(const clname:string):Tbaseobj;
    // переопределяется при необходимости в потомках, упрощает программирование и
    // возвращает оснвоной объект структуры дерева (например, у объекта могут быть служебные
    // подкаталоги для хранения дочерних объектов. У страницы компонента графики есть подкаталоги:
    // список осей, список тектовых меток, доп. построения. Клшжа мы у дочернего элемента получаем главного родителя, этьот значит что мы
    // возвращаем не автоматически созданные объект пустышку (список осей), а создателя этого подкаталога - страницу)
    function MainParent:tbaseobj; virtual;
    { Сериализация JSON }
    function SaveToJSON: TJSONObject; virtual;
    procedure LoadFromJSON(AObject: TJSONObject); virtual;

    property Name: string read fName write SetName;
    property Caption: string read fCaption write fCaption;
    property Parent: TBaseObj read fParent write SetParent;
    property Manager: TBaseObjManager read fManager;
    property ChildCount: Integer read GetChildCount;
    property Items[Index: Integer]: TBaseObj read GetChild; default;
  end;

  { Менеджер объектов }
  TBaseObjManager = class
  private
    m_Objects: TBaseObjList; 
    m_RegisteredClasses: TStringList;
    m_EventList: TEventList;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    // добавить объект в менеджер объектов, слинковать с root в кочастве дочернего элемента
    procedure AddObject(ABaseObj : TBaseObj; Root : TBaseObj);

    procedure RegisterObjClass(AClass: TBaseObjClass);
    function CreateObjByClassName(const AClassName: string): TBaseObj;

    procedure Register(AObj: TBaseObj);
    procedure Unregister(AObj: TBaseObj);

    function GetObj(Index: Integer): TBaseObj;
    function FindByName(const AName: string): TBaseObj;
    function GenerateUniqueName(const ABaseName: string): string;

    property Count: Integer read GetCount;
    property Objects[Index: Integer]: TBaseObj read GetObj; default;
    property Events: TEventList read m_EventList;
  end;

implementation

{ TBaseObjList }

constructor TBaseObjList.Create;
begin
  inherited Create(False); // Не владеем объектами, владеет менеджер или дерево
end;

procedure TBaseObjList.AddObject(ABaseObj : TBaseObj; Root : TBaseObj);
begin

end;

function TBaseObjList.GetItem(Index: Integer): TBaseObj;
begin
  Result := TBaseObj(inherited Items[Index]);
end;

function TBaseObjList.FindByName(const AName: string): TBaseObj;
var i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if CompareText(Items[i].Name, AName) = 0 then
      Exit(Items[i]);
end;

{ TBaseObjManager }

constructor TBaseObjManager.Create;
begin
  m_Objects := TBaseObjList.Create;
  m_RegisteredClasses := TStringList.Create;
  m_EventList := TEventList.Create(Self);
  RegisterObjClass(TBaseObj);
end;

destructor TBaseObjManager.Destroy;
begin
  m_Objects.Free;
  m_RegisteredClasses.Free;
  m_EventList.Free;
  inherited Destroy;
end;


procedure TBaseObjManager.AddObject(ABaseObj : TBaseObj; Root : TBaseObj);
begin

end;

procedure TBaseObjManager.RegisterObjClass(AClass: TBaseObjClass);
begin
  if Assigned(AClass) then
    m_RegisteredClasses.AddObject(AClass.ClassName, TObject(AClass));
end;

function TBaseObjManager.CreateObjByClassName(const AClassName: string): TBaseObj;
var i: Integer;
begin
  Result := nil;
  i := m_RegisteredClasses.IndexOf(AClassName);
  if i >= 0 then
    Result := TBaseObjClass(m_RegisteredClasses.Objects[i]).Create;
end;

function TBaseObjManager.GetCount: Integer;
begin
  Result := m_Objects.Count;
end;

function TBaseObjManager.GetObj(Index: Integer): TBaseObj;
begin
  Result := m_Objects[Index];
end;

procedure TBaseObjManager.Register(AObj: TBaseObj);
begin
  if not Assigned(AObj) or (m_Objects.IndexOf(AObj) >= 0) then
    Exit;
  
  if FindByName(AObj.Name) <> nil then
    AObj.fName := GenerateUniqueName(AObj.Name);
    
  m_Objects.Add(AObj);
  if AObj.fManager <> Self then
    AObj.SetManager(Self);
end;

procedure TBaseObjManager.Unregister(AObj: TBaseObj);
begin
  if Assigned(AObj) and Assigned(m_Objects) then
    m_Objects.Remove(AObj);
end;

function TBaseObjManager.FindByName(const AName: string): TBaseObj;
begin
  Result := m_Objects.FindByName(AName);
end;

function TBaseObjManager.GenerateUniqueName(const ABaseName: string): string;
var i: Integer;
begin
  i := 1;
  Result := ABaseName + '_' + IntToStr(i);
  while FindByName(Result) <> nil do
  begin
    Inc(i);
    Result := ABaseName + '_' + IntToStr(i);
  end;
end;

{ TBaseObj }

constructor TBaseObj.Create;
begin
  m_Children := TBaseObjList.Create;
  fDestroyWithParent := false;
  fDestroying := False;
end;

destructor TBaseObj.Destroy;
var
  i: Integer;
  lChild: TBaseObj;
begin
  if Assigned(fManager) and not fDestroying then
  begin
    fDestroying := True;
    fManager.Unregister(Self);
    fManager := nil;
  end;
  if Assigned(m_Children) then
  begin
    { Освобождаем детей в обратном порядке }
    for i := m_Children.Count - 1 downto 0 do
    begin
      lChild := m_Children[i];
      if lChild.fDestroyWithParent then
      begin
        lChild.Free;
      end
      else // есди не удаляем тог перелинковываем в root
      begin
   //     fManager.add
      end;
    end;
    m_Children.Free;
  end;
  inherited Destroy;
end;

procedure TBaseObj.SetManager(AManager: TBaseObjManager);
var i: Integer;
begin
  if fManager = AManager then
    Exit;
  fManager := AManager;
  if Assigned(fManager) then
    fManager.Register(Self);
  for i := 0 to m_Children.Count - 1 do
    m_Children[i].SetManager(AManager);
end;

procedure TBaseObj.SetName(const AValue: string);
begin
  fName := AValue;
end;
  (*
procedure TBaseObj.setState(s: TEngineState);
begin

end;

function TBaseObj.getState: TEngineState;
begin

end;
    *)
procedure TBaseObj.EnterCS;
begin

end;

procedure TBaseObj.ExitCS;
begin

end;

procedure TBaseObj.SetParent(AParent: TBaseObj);
begin
  if fParent = AParent then
    Exit;
  if Assigned(fParent) then
    fParent.m_Children.Remove(Self);
  fParent := AParent;
  if Assigned(fParent) then
  begin
    fParent.m_Children.Add(Self);
    SetManager(fParent.Manager);
  end;
end;

procedure TBaseObj.AddChild(AChild: TBaseObj);
begin
  if Assigned(AChild) then
    AChild.Parent := Self;
end;

function TBaseObj.getChildrenByCaption(const AName: string): TBaseObj;
begin
  { Возвращает первый найденный объект по совпадению Caption }
  { Пока не реализован метод }
  Result := nil;
end;

function IsClass(obj: tobject; const name: string): boolean;
var
  cl: TClass;
begin
  result := false;
  cl := obj.ClassType;
  if cl.classname = name then
    Exit(True)
  else
    while cl.ClassParent <> nil do
    begin
      cl := cl.ClassParent;
      if cl.classname = name then
        Exit(True);
    end;
end;

function TBaseObj.getParentByClassName(const clname: string): Tbaseobj;
var
  node: TBaseObj;
begin
  result := nil;
  node := self;
  while (node.parent <> nil) do
  begin
    if IsClass(node.parent, clname) then
    begin
      result := node.parent;
      break;
    end;
    node := node.parent;
  end;
end;

function TBaseObj.MainParent: tbaseobj;
begin
  result := Parent;
end;

function TBaseObj.CreateChild(const AClassName: string): TBaseObj;
begin
  if Assigned(fManager) then
    Result := fManager.CreateObjByClassName(AClassName)
  else
    Result := TBaseObj.Create;
  AddChild(Result);
end;

function TBaseObj.GetChild(const Index: Integer): TBaseObj;
begin
  Result := m_Children[Index];
end;

function TBaseObj.GetChildCount: Integer;
begin
  Result := m_Children.Count;
end;

function TBaseObj.SaveToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('ClassName', ClassName);
  Result.Add('Name', fName);
  Result.Add('Caption', fCaption);
end;

procedure TBaseObj.LoadFromJSON(AObject: TJSONObject);
var
  lJSONData: TJSONData;
begin
  if AObject.Find('Name', lJSONData) then
    fName := lJSONData.AsString
  else
    fName := '';

  if AObject.Find('Caption', lJSONData) then
    fCaption := lJSONData.AsString
  else
    fCaption := '';
end;

end.
