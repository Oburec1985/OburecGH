unit uBaseObjInt;

interface

uses
  uBaseObj, uVectorList;

type

  // индексированный список объктов
  cBaseObjListInt = class(cBaseObjList)
  protected
    // не умеет правильно удалять вложенные в узлы объекты, тк они имеют тип baseobj
    // а cIntVectorList думает что в узлах лежат tobject-ы
    procedure destroylist;override;
    function getdestroydata:boolean;override;
    procedure SetDestroyData(b:boolean);override;
  public
    childrens:cIntVectorList;
  // новые методы недоступные в cBaseObjList
  public
    function findObj(key:integer;var index:integer):cBaseObj;    
    procedure AddObject(i:integer;chan:cbaseobj);
  public
    constructor create;override;
    destructor destroy;override;
    function getobj(i:integer):cbaseobj;override;
    procedure addobj(obj:cbaseobj);override;
    // убирает объект из списка но не удаляет данные
    procedure removeobj(obj:cbaseobj);overload;override;
    procedure removeobj(i:integer);overload;override;
    function find(name:string;var index:integer):boolean;overload;override;
    function find(obj:cbaseobj;var index:integer):boolean;overload;override;
    function count:integer;override;
    procedure deletechild(obj:cbaseobj);override;
  end;

  cBaseObjInt = class(cbaseobj)
  protected
    key:integer;
  public
    procedure addchild(k:integer;obj:cbaseobj);
    function findobj(k:integer):cbaseobj;overload;
    function findobj(k:integer; index:integer):cbaseobj;overload;
    constructor create;override;
  end;



implementation


constructor cBaseObjInt.create;
begin
  inherited;
  childrens:=cBaseObjListInt.create;
end;

function cBaseObjInt.findobj(k:integer):cbaseobj;
var ind:integer;
begin
  result:=cBaseObjListInt(childrens).findObj(k,ind);
end;

function cBaseObjInt.findobj(k:integer; index:integer):cbaseobj;
begin
  result:=cBaseObjListInt(childrens).findObj(k,index);
end;

procedure cBaseObjInt.addchild(k:integer;obj:cbaseobj);
begin
  if SupportedChildClass(obj) then
  begin
    if obj.fparent<>nil then
      obj.unlinc;
    obj.fparent:=self;
    cBaseObjListInt(childrens).childrens.AddObject(@k,obj);
    obj.DoLincParent;
  end;
end;

constructor cBaseObjListInt.create;
begin
  childrens:=cIntVectorList.create;
  inherited;
end;

destructor cBaseObjListInt.destroy;
begin
  inherited;
end;

procedure cBaseObjListInt.destroylist;
begin
  childrens.Destroy;
end;

procedure cBaseObjListInt.addobj(obj:cbaseobj);
var i:integer;
begin
  if obj is cBaseobjInt then
    childrens.addobject(@cBaseobjInt(obj).key,obj)
  else
  begin
    i:=count;
    childrens.addobject(@i,obj);
  end;
end;

procedure cBaseObjListInt.removeobj(obj:cbaseobj);
var i:integer;
begin
  if (obj is cbaseobjint) then
  begin
    childrens.findObj(@cbaseobjint(obj).key,i);
    removeobj(i);
  end
  else
  begin
    for I := 0 to count - 1 do
    begin
      if childrens.getObj(i)=obj then
      begin
        removeobj(i);
        break;
      end;
    end;
  end;
end;

procedure cBaseObjListInt.removeobj(i:integer);
var
  vobj:cvectorobj;
begin
  if i<count then
  begin
    vobj:=childrens.getNode(i);
    vobj.destroy(false);
    childrens.Delete(i);
  end;
end;

function cBaseObjListInt.find(name:string;var index:integer):boolean;
var i:integer;
    obj:cBaseObj;
begin
  for I := 0 to count - 1 do
  begin
    obj:=cbaseobj(childrens.getobj(i));
    if obj.name=name then
    begin
      index:=i;
      result:=true;
      exit;
    end;
  end;
end;

function cBaseObjListint.find(obj:cbaseobj;var index:integer):boolean;
begin
  index:=childrens.GetIndex(@cbaseobjint(obj).key);
  if index>=0 then
    result:=true
  else
    result:=false;
end;

function cBaseObjListint.findObj(key:integer;var index:integer):cBaseObj;
begin
  result:=cbaseobj(childrens.findObj(@key,index));
end;

function cBaseObjListint.getobj(i:integer):cbaseobj;
begin
  if (i<count) and (i>=0) then
  begin
    result:=cbaseobj(childrens.getobj(i));
  end
  else
    result:=nil;
end;

function cBaseObjListInt.count:integer;
begin
  result:=childrens.count;
end;

procedure cBaseObjListInt.deletechild(obj:cbaseobj);
var
  i:integer;
  lobj:cbaseobj;
begin
  if find(obj.name,i) then
  begin
    if lobj=obj then
    begin
      deletechild(i);
    end;
  end;
end;

procedure cBaseObjListInt.AddObject(i:integer;chan:cbaseobj);
begin
  childrens.AddObject(@i,chan);
end;

function cBaseObjListInt.getdestroydata:boolean;
begin
  result:=childrens.destroydata;
end;

procedure cBaseObjListInt.SetDestroyData(b:boolean);
begin
  childrens.destroydata:=b;
end;


end.
