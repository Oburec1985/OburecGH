unit uOglChartBaseObj;

{$mode objfpc}{$H+}

{
  Модуль uOglChartBaseObj
  Описание: Содержит базовые классы объектной модели компонента TOglChart.
            Определяет cBaseObj (базовый узел дерева объектов), cChartObjRegistry
            и вспомогательные типы для обхода дерева.
}

interface

uses
  Classes, SysUtils, fpjson, uOglChartLog;

type
  cBaseObj = class;

  { TChartEnumProc }
  // Процедура обхода дерева объектов чарта.
  // Возвращает False, если нужно прервать рекурсию обхода.
  TChartEnumProc = function(AObject: cBaseObj; AData: Pointer): Boolean;

  { cChartObjRegistry }
  // Базовый реестр объектов чарта.
  // cBaseObj взаимодействует с реестром через этот контракт. Конкретный менеджер регистрирует объекты.
  cChartObjRegistry = class(TObject)
  public
    procedure RegisterObject(AObject: cBaseObj); virtual; abstract;
    procedure UnregisterObject(AObject: cBaseObj); virtual; abstract;
    procedure RegisterTree(AObject: cBaseObj); virtual; abstract;
    procedure UnregisterTree(AObject: cBaseObj); virtual; abstract;
  end;

  { cBaseObj }
  // Общий базовый класс для объектов модели чарта.
  // Обеспечивает иерархическую структуру дерева (дети/родитель), уникальное имя,
  // заголовок (подпись), связь с реестром менеджера и поддержку сериализации JSON.
  cBaseObj = class(TObject)
  private
    fName: string;                       // Уникальное имя объекта
    fCaption: string;                    // Заголовок/подпись объекта для отображения
    fParent: cBaseObj;                   // Ссылка на родительский объект
    fChildren: TList;                    // Список дочерних объектов
    fManager: TObject;                   // Ссылка на менеджер/реестр объектов

    function GetChild(AIndex: Integer): cBaseObj;
    function GetChildCount: Integer;
    procedure SetParent(AValue: cBaseObj);
  protected
    procedure SetName(const AValue: string); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // Возвращает True, если объект не нужно сохранять в JSON.
    function NotSaveToJson: Boolean; virtual;
    // Инициализирует свойства объекта значениями по умолчанию.
    procedure AssignDefaultProperties; virtual;
    // Сохраняет специфичные атрибуты объекта в JSONObject.
    procedure SaveJsonAttributes(AJson: TJSONObject); virtual;
    // Загружает специфичные атрибуты объекта из JSONObject.
    procedure LoadJsonAttributes(AJson: TJSONObject); virtual;

    // Добавляет дочерний объект.
    procedure AddChild(AChild: cBaseObj);
    // Удаляет дочерний объект без его уничтожения.
    procedure RemoveChild(AChild: cBaseObj);
    // Уничтожает все дочерние объекты и очищает список.
    procedure ClearChildren;
    // Находит дочерний объект по имени (только на первом уровне).
    function FindChild(const AName: string): cBaseObj;
    // Рекурсивный обход дерева объектов, начиная с текущего.
    function EnumTree(AProc: TChartEnumProc; AData: Pointer): Boolean;

    property Name: string read fName write SetName;
    property Caption: string read fCaption write fCaption;
    property Parent: cBaseObj read fParent write SetParent;
    property Children[AIndex: Integer]: cBaseObj read GetChild;
    property ChildCount: Integer read GetChildCount;
    property Manager: TObject read fManager write fManager;
  end;

  TChartBaseObject = cBaseObj;

implementation

{ cBaseObj }

constructor cBaseObj.Create;
begin
  inherited Create;
  fChildren := TList.Create;
  AssignDefaultProperties;
  ChartLogDebug(Format('cBaseObj.Create self=%s class=%s name="%s"', [
    ChartPtr(Self), ClassName, fName
  ]));
end;

destructor cBaseObj.Destroy;
begin
  ChartLogDebug(Format('cBaseObj.Destroy enter self=%s class=%s name="%s" children=%d parent=%s manager=%s', [
    ChartPtr(Self), ClassName, fName, ChildCount, ChartPtr(fParent), ChartPtr(TObject(fManager))
  ]));
  // Очищаем дерево детей перед уничтожением
  ClearChildren;
  // Уведомляем родителя об удалении ссылки
  if Assigned(fParent) then
    fParent.RemoveChild(Self);
  // Разрегистрируем объект в менеджере
  if Assigned(fManager) and (fManager is cChartObjRegistry) then
    cChartObjRegistry(fManager).UnregisterObject(Self);
  fChildren.Free;
  inherited Destroy;
end;

procedure cBaseObj.AssignDefaultProperties;
begin
  fName := ClassName;
  fCaption := fName;
end;

function cBaseObj.NotSaveToJson: Boolean;
begin
  Result := False;
end;

procedure cBaseObj.SaveJsonAttributes(AJson: TJSONObject);
begin
  // Переопределяется в наследниках для записи дополнительных полей
end;

procedure cBaseObj.LoadJsonAttributes(AJson: TJSONObject);
begin
  // Переопределяется в наследниках для чтения дополнительных полей
end;

procedure cBaseObj.SetName(const AValue: string);
begin
  fName := AValue;
  if fCaption = '' then
    fCaption := AValue;
end;

function cBaseObj.GetChild(AIndex: Integer): cBaseObj;
begin
  Result := cBaseObj(fChildren[AIndex]);
end;

function cBaseObj.GetChildCount: Integer;
begin
  Result := fChildren.Count;
end;

procedure cBaseObj.SetParent(AValue: cBaseObj);
begin
  if fParent = AValue then
    Exit;
  if Assigned(fParent) then
    fParent.RemoveChild(Self);
  fParent := AValue;
  if Assigned(fParent) and (fParent.fChildren.IndexOf(Self) < 0) then
    fParent.fChildren.Add(Self);
end;

procedure cBaseObj.AddChild(AChild: cBaseObj);
begin
  if not Assigned(AChild) then
    Exit;
  AChild.Parent := Self;
  // Если у нас назначен менеджер, регистрируем все дерево добавляемого ребенка
  if Assigned(fManager) and (fManager is cChartObjRegistry) then
    cChartObjRegistry(fManager).RegisterTree(AChild);
end;

procedure cBaseObj.RemoveChild(AChild: cBaseObj);
begin
  if not Assigned(AChild) then
    Exit;
  fChildren.Remove(AChild);
  if AChild.fParent = Self then
    AChild.fParent := nil;
end;

procedure cBaseObj.ClearChildren;
begin
  // Уничтожаем дочерние объекты с конца списка
  while fChildren.Count > 0 do
    cBaseObj(fChildren.Last).Free;
end;

function cBaseObj.FindChild(const AName: string): cBaseObj;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildCount - 1 do
    if SameText(Children[I].Name, AName) then
      Exit(Children[I]);
end;

function cBaseObj.EnumTree(AProc: TChartEnumProc; AData: Pointer): Boolean;
var
  I: Integer;
begin
  Result := True;
  if Assigned(AProc) then
    Result := AProc(Self, AData);
  if not Result then
    Exit;
  for I := 0 to ChildCount - 1 do
  begin
    Result := Children[I].EnumTree(AProc, AData);
    if not Result then
      Exit;
  end;
end;

end.
