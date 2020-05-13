// класс описатель. Хранит id и имя описываемого объекта
unit uDescObj;

interface
uses
  uVectorList;
type
  cDescObj = class
  public
    // группа к которой относиться алгоритм
    groupID,
    // идентификатор описываемого объекта
    id:integer;
    // имя строки
    name:string;
    // группа к которой относиться алгоритм
  public
    constructor create(p_groupID, p_id:cardinal; p_name:string);
  end;

  cDescList = class(cIntVectorList)
  public
    constructor Create;
    procedure addItem(item:cDescObj);
    function GetItem(id:integer):cDescObj;
  end;

implementation

constructor cDescList.Create;
begin
  destroydata:=true;
end;

procedure cDescList.addItem(item: cDescObj);
begin
  AddObject(@item.id, item);
end;

function cDescList.GetItem(id:integer):cDescObj;
var
  index:integer;
begin
  result:=cDescObj(findObj(@id,index));
end;

constructor cDescObj.create(p_groupID, p_id:cardinal; p_name:string);
begin
  id:=p_id;
  groupID:=p_groupID;
  name:=p_name;
end;

end.
