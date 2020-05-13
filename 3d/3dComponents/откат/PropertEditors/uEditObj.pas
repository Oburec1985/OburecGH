unit uEditObj;

interface
uses  DesignIntf, DesignEditors, uUInterface, classes, MathFunction,
      uobject;

type
  cEditObj = class(tPersistent)
  protected
    obj:cobject;
  private
    function getName:string;
  public
    Procedure SetObj(pObj:cobject);
    function getObj:cobject;
    Procedure setPosition(pos:point3);
    function getPosition:point3;
  published
    property position:point3 read getPosition write setPosition;
    property name:string read getName;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(cobject), cEditObj,'position', tVariantProperty);
end;
// Установить объект
procedure cEditObj.setPosition(pos:point3);
begin
  obj.position:=pos;
end;

function cEditObj.getPosition:point3;
begin
  result:=obj.position;
end;
// Установить объект
procedure cEditObj.setObj(pObj:cobject);
begin
  obj:=pObj;
end;

function cEditObj.getObj:cobject;
begin
  result:=obj;
end;
// Получить имя объекта
function cEditObj.getName:string;
begin
  if obj<>nil then
    result:=obj.name;
end;

end.
