unit uEditObj;

interface
uses  uUInterface, classes, MathFunction,
      uobject;

type
  {
  cpoint3 = class(tPersistent)
  private
    p3:point3;
  protected
    function getx:single;
    procedure setx(v:single);
    function gety:single;
    procedure sety(v:single);
    function getz:single;
    procedure setz(v:single);
  published
    property x:single read getx write setx;
    property y:single read gety write sety;
    property z:single read getz write setz;
  end;
  }

  cEditObj = class(tPersistent)
  protected
    obj:cobject;
    //m_pos:cpoint3;
  private
    function getName:string;
  public
    constructor create;
    destructor destroy;
    Procedure SetObj(pObj:cobject);
    function getObj:cobject;
    Procedure setPosition(pos:point3);
    function getPosition:point3;
  published
    //property position:point3 read getPosition write setPosition;
    property name:string read getName;
  end;

implementation

// класс для хранения координат x,y,z
procedure cpoint3.setx(v: Single);
begin
  p3.x:=v;
end;
function cpoint3.getx:single;
begin
  result:=p3.x;
end;

procedure cpoint3.sety(v: Single);
begin
  p3.y:=v;
end;
function cpoint3.gety:single;
begin
  result:=p3.y;
end;

procedure cpoint3.setz(v: Single);
begin
  p3.z:=v;
end;
function cpoint3.getz:single;
begin
  result:=p3.z;
end;

constructor cEditObj.create;
begin
//  m_pos:=cpoint3.create;
end;

destructor cEditObj.destroy;
begin
//  m_pos.destroy;
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
