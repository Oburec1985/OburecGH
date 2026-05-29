unit uOglChartMng;

{$mode objfpc}{$H+}

{
  Модуль uOglChartMng
  Описание: Содержит класс cChartMng (TChartObjectManager), который управляет жизненным циклом
            корневой модели чарта (cChart) и ведет плоский реестр всех объектов дерева
            для быстрого поиска, сериализации и интеграции с инспектором объектов.
}

interface

uses
  Classes, SysUtils, uOglChartTypes, uOglChartLog, uOglChartBaseObj, uOglChartChart;

type
  { cChartMng }
  // Владеет корневой моделью и ведёт плоский реестр объектов для поиска,
  // сериализации и будущего инспектора.
  cChartMng = class(cChartObjRegistry)
  private
    fObjects: TList;                     // Список всех зарегистрированных объектов в дереве модели
    fRoot: cChart;                       // Корневой объект модели чарта

    function GetObject(AIndex: Integer): cBaseObj;
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // Регистрация отдельного объекта в реестре
    procedure RegisterObject(AObject: cBaseObj); override;
    // Разрегистрация отдельного объекта
    procedure UnregisterObject(AObject: cBaseObj); override;
    // Рекурсивная регистрация всего поддерева объектов
    procedure RegisterTree(AObject: cBaseObj); override;
    // Рекурсивная разрегистрация всего поддерева объектов
    procedure UnregisterTree(AObject: cBaseObj); override;

    // Очистка данных модели чарта (сбрасывает настройки и удаляет страницы)
    procedure Clear;
    // Автоматическое позиционирование всех страниц модели по сетке
    procedure AlignPagesAuto(AAspect: Double = 1);
    // Устанавливает новый корневой объект модели
    procedure SetRoot(ARoot: cChart);
    // Добавляет объект в дерево под родителя ARoot и регистрирует его
    procedure Add(AObject, ARoot: cBaseObj);
    // Находит зарегистрированный объект по его уникальному имени
    function FindObject(const AName: string): cBaseObj;
    
    // Сохранение и загрузка всей структуры модели через IChartSerializer
    function SaveToString(ASerializer: IChartSerializer): string;
    procedure LoadFromString(ASerializer: IChartSerializer; const AData: string);

    property Root: cChart read fRoot;
    property Objects[AIndex: Integer]: cBaseObj read GetObject;
    property Count: Integer read GetCount;
  end;

  TChartObjectManager = cChartMng;

implementation

{ cChartMng }

constructor cChartMng.Create;
begin
  inherited Create;
  fObjects := TList.Create;
  ChartLogInfo('cChartMng.Create self=' + ChartPtr(Self));
  // Создаем корневой элемент чарта по умолчанию
  SetRoot(cChart.Create);
end;

destructor cChartMng.Destroy;
begin
  ChartLogInfo(Format('cChartMng.Destroy self=%s root=%s count=%d', [
    ChartPtr(Self), ChartPtr(fRoot), Count
  ]));
  FreeAndNil(fRoot);
  fObjects.Free;
  inherited Destroy;
end;

/// <summary>
/// Регистрирует объект в плоском списке менеджера и связывает объект с этим менеджером.
/// </summary>
procedure cChartMng.RegisterObject(AObject: cBaseObj);
begin
  if not Assigned(AObject) or (fObjects.IndexOf(AObject) >= 0) then
    Exit;
  fObjects.Add(AObject);
  AObject.Manager := Self;
end;

/// <summary>
/// Удаляет объект из плоского списка и разрывает связь объекта с менеджером.
/// </summary>
procedure cChartMng.UnregisterObject(AObject: cBaseObj);
begin
  if not Assigned(AObject) then
    Exit;
  fObjects.Remove(AObject);
  if AObject.Manager = Self then
    AObject.Manager := nil;
end;

/// <summary>
/// Рекурсивно регистрирует объект и всех его дочерних потомков в дереве.
/// </summary>
procedure cChartMng.RegisterTree(AObject: cBaseObj);
var
  I: Integer;
begin
  if not Assigned(AObject) then
    Exit;
  RegisterObject(AObject);
  for I := 0 to AObject.ChildCount - 1 do
    RegisterTree(AObject.Children[I]);
end;

/// <summary>
/// Рекурсивно разрегистрирует объект и всех его потомков.
/// </summary>
procedure cChartMng.UnregisterTree(AObject: cBaseObj);
var
  I: Integer;
begin
  if not Assigned(AObject) then
    Exit;
  for I := 0 to AObject.ChildCount - 1 do
    UnregisterTree(AObject.Children[I]);
  UnregisterObject(AObject);
end;

function cChartMng.GetObject(AIndex: Integer): cBaseObj;
begin
  Result := cBaseObj(fObjects[AIndex]);
end;

function cChartMng.GetCount: Integer;
begin
  Result := fObjects.Count;
end;

/// <summary>
/// Очищает содержимое корневого элемента чарта и пересоздает плоский реестр.
/// </summary>
procedure cChartMng.Clear;
begin
  if Assigned(fRoot) then
  begin
    fRoot.Clear;
    fObjects.Clear;
    RegisterTree(fRoot);
  end;
end;

/// <summary>
/// Вызывает автовыравнивание страниц в корневой модели чарта.
/// </summary>
procedure cChartMng.AlignPagesAuto(AAspect: Double);
begin
  if Assigned(fRoot) then
    fRoot.AlignPagesAuto(AAspect);
end;

/// <summary>
/// Меняет корневую модель чарта. Освобождает предыдущую модель и регистрирует новое дерево.
/// </summary>
procedure cChartMng.SetRoot(ARoot: cChart);
begin
  if fRoot = ARoot then
    Exit;
  if Assigned(fRoot) then
    FreeAndNil(fRoot);
  fRoot := ARoot;
  fObjects.Clear;
  RegisterTree(fRoot);
end;

/// <summary>
/// Добавляет объект AObject к родителю ARoot. Если родитель не указан, объект не связывается в дерево,
/// но регистрируется в плоском списке.
/// </summary>
procedure cChartMng.Add(AObject, ARoot: cBaseObj);
begin
  if not Assigned(AObject) then
    Exit;
  if Assigned(ARoot) then
    ARoot.AddChild(AObject);
  RegisterTree(AObject);
end;

/// <summary>
/// Выполняет линейный поиск объекта в плоском списке по имени (без учета регистра).
/// </summary>
function cChartMng.FindObject(const AName: string): cBaseObj;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Objects[I].Name, AName) then
      Exit(Objects[I]);
end;

/// <summary>
/// Сохраняет корневой объект в строку через сериализатор.
/// </summary>
function cChartMng.SaveToString(ASerializer: IChartSerializer): string;
begin
  Result := '';
  if Assigned(fRoot) and Assigned(ASerializer) then
    Result := ASerializer.SaveObject(fRoot);
end;

/// <summary>
/// Загружает состояние корневого объекта из строки и заново выстраивает плоский список зарегистрированных объектов.
/// </summary>
procedure cChartMng.LoadFromString(ASerializer: IChartSerializer; const AData: string);
begin
  if Assigned(fRoot) and Assigned(ASerializer) then
  begin
    ASerializer.LoadObject(fRoot, AData);
    fObjects.Clear;
    RegisterTree(fRoot);
  end;
end;

end.
