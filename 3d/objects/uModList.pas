// Класс заведует созданием модификаторов и их хранением
unit uModList;

interface
uses
 uBaseModificator, classes;

type
  cModCreator = class
  private
    // Объект к которому будет прикреплен модификатор
    obj:tobject;
    // Список созданных модификаторов
    modificators:TList;
    // Список доступных модификаторов
    modNames:tstringlist;
  public
    constructor create(aowner:tobject);
    destructor destroy;
    // Получить уже созданный модификатор из списка
    function GetModificator(classname:string):cbasemodificator;
    procedure addMod(modif:tobject);
    // Получить список имен существыующих модификаторов
    function getnames:tstrings;
    // Получить i-й модификатор
    function getitem(i:integer):cBaseModificator;
    function count:integer;
    // Создать модификатор
    Function CreateModificator(name:string):cBaseModificator;
  end;

const
  constBaseDeformer = 1;
  constSkin = 2;    

implementation
uses
  uBaseDeformer, unodeobject,
  uskin, umeshobr, ushape,
  uMoveController, uSceneMng;

constructor cModCreator.create(aowner:tobject);
begin
  obj:=aowner;
  modificators:=TList.Create;
  modNames:=tstringlist.Create;
  modNames.add('cBaseDeformer');
  modNames.add('cSkin');
end;

destructor cModCreator.destroy;
var i:integer;
    l_mod:cBaseModificator;
begin
  for I := 0 to modificators.Count - 1 do
  begin
    l_mod:=cBaseModificator(modificators.items[i]);
    if l_mod is cMoveController then
      cMoveController(l_mod).Destroy;
    modificators.Delete(i);
  end;
  modificators.Destroy;
  modNames.destroy;
end;

function cModCreator.getitem(i:integer):cBaseModificator;
begin
  result:=cBaseModificator(modificators.items[i]);
end;

function cModCreator.getnames:tstrings;
begin
  result:=modnames;
end;

function cModCreator.count:integer;
begin
  result:=modificators.Count;
end;

Function cModCreator.CreateModificator(name:string):cBaseModificator;
begin
  if name='cBaseDeformer' then
  begin
    result:=cBaseDeformer.create(cnodeobject(obj));
    cBaseDeformer(result).owner:=cnodeobject(obj);
    modificators.Add(result);
  end;
  if name='cSkin' then
  begin
    if (obj is cmeshobr) or (obj is cshapeobj) then
    begin
      result:=cSkin.create(cmeshobr(obj));
      cBaseDeformer(result).owner:=cnodeobject(obj);
      modificators.Add(result);
    end;
  end;
end;

procedure cModCreator.addMod(modif:tobject);
begin
  cBaseDeformer(modif).owner:=cnodeobject(obj);
  modificators.Add(modif);
end;

function cModCreator.GetModificator(classname:string):cbasemodificator;
var i:integer;
begin
  result:=nil;
  for I := 0 to modificators.Count - 1 do
  begin
    if cbasemodificator(modificators.Items[i]).ClassName=classname then
    begin
      result:=modificators.Items[i];
      break;
    end;
  end;
end;


end.
