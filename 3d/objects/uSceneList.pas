unit uSceneList;

interface
uses
  Windows, SysUtils, Classes, mathfunction, uNodeObject, uObjectTypes,
  uobject,umeshobr, ubasecamera, ulight, ushape;
type

  // 2) Tmesh ������ ������ �� �������� � ��������� �� ���������
  // 3) Load_Obr ����� ������� ��������� ������� �� ������
  cObjects = class(TStringList)
  public
    Constructor Create;
    destructor destroy;
    function getObjByName(name:string):cNodeObject;
  end;

implementation

Constructor cObjects.Create;
begin
  sorted:=true;
end;

destructor cObjects.destroy;
var
  obj:cNodeObject;
begin
  while Count<>0 do
  begin
    obj:=cNodeObject(Objects[0]);
    case obj.objtype of
      constdummy: obj.destroy;
      constmesh: cMeshObr(obj).destroy;
      constcamera: cBaseCamera(obj).destroy;
      constlight: clight(obj).destroy;
      constshape: cShapeObj(obj).destroy;
    end;
  end;
  inherited;
end;

function cObjects.getObjByName(name:string):cNodeObject;
var index:integer;
begin
  if find(name,index) then
    result:=cNodeObject(Objects[index])
  else
    result:=nil;
end;


end.
