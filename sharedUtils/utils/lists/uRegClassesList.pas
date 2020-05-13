unit uRegClassesList;

interface
uses
  Windows, Messages, SysUtils, Classes, StdCtrls, Controls, ExtCtrls, uCommonMath,
  dialogs, usetlist,  ubaseobj;

type
  cBaseObjClass = class of cBaseObj;

  cObjCreator = class
  public
    // список дополнительных атрибутов класса
    addInfo:tstringlist;
    createfunc:cBaseObjClass;
  public
    constructor create;
    destructor destroy;
    function GetObj(s:string):tobject;overload;
    function GetObj(i:integer):tobject;overload;
  end;

  cRegClassesList = class(TStringList)
  public
    constructor create;
    destructor destroy;
    function callFunc(index:integer):cbaseobj;overload;
    function callFunc(classname:string):cbaseobj;overload;
    function regclass(cl:tclass):cObjCreator;
    function GetObj(s:string):cObjCreator;overload;
    function GetObj(i:integer):cObjCreator;overload;
    function GetClass(i:integer):cBaseObjClass;
  end;

implementation

constructor cRegClassesList.create;
begin
  inherited;
  sorted:=true;
end;

destructor cRegClassesList.destroy;
var
  I: Integer;
  cr:cObjCreator;
begin
  for I := 0 to Count - 1 do
  begin
    cr:=cObjCreator(objects[i]);
    cr.Destroy;
  end;
  inherited;
end;

function cRegClassesList.regclass(cl:tclass):cObjCreator;
var
  i:integer;
  creator:cObjCreator;
begin
  if not find(cl.classname,i) then
  begin
    creator:=cObjCreator.Create;
    creator.createfunc:=cBaseObjClass(cl);
    AddObject(cl.ClassName, creator);
    result:=creator;
  end
  else
  begin
    result:=cObjCreator(objects[i]);
  end;
end;

function cRegClassesList.callFunc(index:integer):cbaseobj;
var
  creator:cObjCreator;
begin
  creator:=cObjCreator(objects[index]);
  result:=creator.createfunc.create;
end;

function cRegClassesList.callFunc(classname:string):cbaseobj;
var
  i:integer;
begin
  result:=nil;
  if find(classname,i) then
  begin
    result:=callFunc(i);
  end;
end;

function cRegClassesList.GetObj(s:string):cObjCreator;
var
  i:integer;
begin
  result:=nil;
  begin
    if Find(s,i) then
    begin
      result:=cObjCreator(Objects[i]);
    end;
  end;
end;

function cRegClassesList.GetClass(i: integer): cBaseObjClass;
begin
  result:=cObjCreator(Objects[i]).createfunc;
end;

function cRegClassesList.GetObj(i:integer):cObjCreator;
begin
  result:=cObjCreator(Objects[i]);
end;

function cObjCreator.GetObj(s:string):tobject;
var
  i:integer;
begin
  result:=nil;
  if addInfo<>nil then
  begin
    if addInfo.Find(s,i) then
    begin
      result:=addInfo.Objects[i];
    end;
  end;
end;

function cObjCreator.GetObj(i:integer):tobject;
begin
  result:=nil;
  if addInfo<>nil then
  begin
    result:=addInfo.Objects[i];
  end;
end;

constructor cObjCreator.create;
begin
  inherited;
  addInfo:=tstringlist.Create;
  addInfo.Sorted:=true;
end;

destructor cObjCreator.destroy;
begin
  addInfo.Destroy;
  inherited;
end;

end.
