// потомок базового объекта, но индексирован строками
unit uBaseObjStr;

interface

uses ubaseobj, controls, classes;

type

  // именованый список объктов
  cBaseObjListStr = class(cBaseObjList)
  protected
    fdestroydata: boolean;
  protected
    procedure destroylist; override;
    function getdestroydata: boolean; override;
    procedure SetDestroyData(b: boolean); override;
  public
    childrens: tstringlist;
  public
    constructor create; override;
    destructor destroy; override;
    procedure clear; override;
    procedure renameKey(obj: cBaseObj; name: string); override;
    procedure renameStringKey(name: string; newname: string);
    function getobj(name: string): cBaseObj; overload; override;
    function getobj(i: integer): cBaseObj; overload; override;
    procedure addobj(obj: cBaseObj); override;
    procedure removeobj(obj: cBaseObj); overload; override;
    procedure removeobj(i: integer); overload; override;
    procedure sortByChildCount;
    function find(name: string; var index: integer): boolean; overload;
      override;
    function find(obj: cBaseObj; var index: integer): boolean; overload;
      override;
    function count: integer; override;
    procedure deletechild(obj: cBaseObj); override;
  public
    // новый метод
    procedure sort;
  end;

  cbaseobjstr = class(cBaseObj)
  public
    constructor create; override;
    // новые методы
  protected
    // Отсортировать по имени
    procedure SortByName;
  protected
    // Установка типа сортировки
    procedure setsorted(value: integer); override;
  end;

const
  NameSort = 1;
  ChildSort = 2;

implementation

// Сортировать дочерние узлы по числу потомков
// Возвращенное целое число имеет следующее значение :
// > 0 : (положительное) Item1 является меньше чем Item2
// 0 : Item1 равно Item2
// <0 : (negative) больше чем item2
function ChildCountComparator(p1, p2: pointer): integer;
var
  obj1, obj2: cBaseObj;
begin
  obj1 := cBaseObj(p1);
  obj2 := cBaseObj(p2);
  // Теперь сравнение строк
  if obj1.ChildCount > obj2.ChildCount then
    Result := 1
  else if obj1.ChildCount = obj2.ChildCount then
    Result := 0
  else
    Result := -1;
end;

function StrListChildCountComparator(List: tstringlist; Index1, Index2: integer)
  : integer;
var
  obj1, obj2: cBaseObj;
begin
  obj1 := cBaseObj(List.Objects[Index1]);
  obj2 := cBaseObj(List.Objects[Index2]);
  // Теперь сравнение строк
  if obj1.ChildCount > obj2.ChildCount then
    Result := 1
  else if obj1.ChildCount = obj2.ChildCount then
    Result := 0
  else
    Result := -1;
end;

constructor cbaseobjstr.create;
begin
  inherited;
  fname := classname;
  imageindex := c_baseobj_img;
  childrens := cBaseObjListStr.create;
end;

procedure cbaseobjstr.setsorted(value: integer);
begin
  fsort := value;
  case fsort of
    NameSort:
      SortByName;
    ChildSort:
      cBaseObjListStr(childrens).sortByChildCount;
  end;
end;

procedure cbaseobjstr.SortByName;
begin
  cBaseObjListStr(childrens).sort;
end;

constructor cBaseObjListStr.create;
begin
  inherited;
  childrens := tstringlist.create;
  childrens.Sorted := true;
end;

procedure cBaseObjListStr.destroylist;
begin
  childrens.destroy;
  childrens := nil;
end;

destructor cBaseObjListStr.destroy;
begin
  inherited;
end;

procedure cBaseObjListStr.addobj(obj: cBaseObj);
begin
  childrens.addobject(obj.name, obj);
end;

procedure cBaseObjListStr.removeobj(obj: cBaseObj);
var
  i: integer;
begin
  if childrens.Sorted then
  begin
    if childrens.find(obj.name, i) then
    begin
      if obj = getobj(i) then
        childrens.delete(i);
    end;
  end
  else
  begin
    for i := 0 to childrens.count - 1 do
    begin
      if getobj(i) = obj then
        childrens.delete(i)
    end;
  end;
end;

procedure cBaseObjListStr.removeobj(i: integer);
begin
  if i < count then
  begin
    childrens.delete(i);
  end;
end;

procedure cBaseObjListStr.renameStringKey(name: string; newname: string);
var
  index: integer;
  obj: tobject;
begin
  if childrens.find(name, index) then
  begin
    if index < childrens.count then
    begin
      obj := childrens.Objects[index];
    end
    else
      obj := nil;
    childrens.delete(index);
    if obj <> nil then
    begin
      childrens.addobject(newname, obj);
    end
    else
    begin
      childrens.Add(newname);
    end;
  end;
end;

procedure cBaseObjListStr.renameKey(obj: cBaseObj; name: string);
var
  index: integer;
begin
  if childrens.find(obj.name, index) then
  begin
    if obj = childrens.Objects[index] then
    begin
      childrens.delete(index);
      childrens.addobject(name, obj);
    end;
  end;
end;

function cBaseObjListStr.find(name: string; var index: integer): boolean;
var
  i: integer;
  obj: cBaseObj;
begin
  if childrens.Sorted then // Если включена сортировка по именам
  begin
    Result := childrens.find(name, index);
  end
  else // Если сортировки по именам нет
  begin
    for i := 0 to count - 1 do
    begin
      obj := cBaseObj(childrens.Objects[i]);
      if obj.name = name then
      begin
        index := i;
        Result := true;
        exit;
      end;
    end;
  end;
end;

function cBaseObjListStr.find(obj: cBaseObj; var index: integer): boolean;
begin
  Result := find(obj.name, index);
end;

function cBaseObjListStr.getobj(name: string): cBaseObj;
var
  index: integer;
  obj: cBaseObj;
begin
  if not find(name, index) then
  begin
    Result := nil;
  end
  else
  begin
    Result := getobj(index);
  end;
end;

function cBaseObjListStr.getobj(i: integer): cBaseObj;
begin
  if i < count then
  begin
    Result := cBaseObj(childrens.Objects[i])
  end
  else
    Result := nil;
end;

procedure cBaseObjListStr.sort;
begin
  childrens.sort;
end;

procedure cBaseObjListStr.sortByChildCount;
begin
  childrens.CustomSort(StrListChildCountComparator);
end;

function cBaseObjListStr.count: integer;
begin
  if childrens <> nil then
    Result := childrens.count
  else
    Result := 0;
end;

procedure cBaseObjListStr.deletechild(obj: cBaseObj);
var
  i: integer;
  lobj: cBaseObj;
begin
  if find(obj.name, i) then
  begin
    if lobj = obj then
    begin
      deletechild(i);
    end;
  end;
end;

function cBaseObjListStr.getdestroydata: boolean;
begin
  Result := fdestroydata;
end;

procedure cBaseObjListStr.SetDestroyData(b: boolean);
begin
  fdestroydata := b;
end;

procedure cBaseObjListStr.clear;
begin
  childrens.clear;
end;

end.
