unit uSensorList;

interface
uses
  Windows, SysUtils, Classes, uBaseObj, uEventList;
type

  cObjectList = class(TStringList)
  public
    events:cEventList;
  public
    Constructor Create;
    destructor destroy;
    function getObjByName(name:string):cBaseObj;
    // Удалить объект
    procedure DeleteObj(obj:cBaseObj);
  end;

implementation

Constructor cObjectList.Create;
begin
  sorted:=true;
end;

destructor cObjectList.destroy;
var obj:cBaseObj;
    i:integer;
begin
  // Убийство всех объектов
  for I := 0 to Count - 1 do
  begin
    obj:=cBaseObj(Objects[i]);
    obj.destroy;
  end;
  inherited;
end;

function cObjectList.getObjByName(name:string):cBaseObj;
var index:integer;
begin
  if find(name,index) then
    result:=cBaseObj(Objects[index])
  else
    result:=nil;
end;

procedure cObjectList.DeleteObj(obj:cBaseObj);
var index:integer;
begin
  if find(obj.name,index) then
    Delete(index);
  obj.destioy;
end;



end.
