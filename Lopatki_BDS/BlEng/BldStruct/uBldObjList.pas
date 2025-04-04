unit uBldObjList;

interface
uses
   uSetList, uVectorList, sysutils, uBldObj, ubldeng;

type


  cbldObjList = class(cSetList)
  protected
    fsort:integer;
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;
    procedure add(obj:cbldObj);
    procedure setSortType(i:integer);virtual;
    function GetObj(i:integer):cBldObj;overload;
    function GetObj(name:string):cBldObj;overload;
    function GetObjectsType:integer;
    function Engine:cbldeng;
  end;

  const
    c_namesort = 0;
    c_PosSort = 1;

implementation

function NameSort(p1,p2:pointer):integer;
begin
  result:=AnsiCompareText(cBldObj(p1).name,cBldObj(p2).name);
end;

constructor cbldObjList.create;
begin
  inherited;
  setSortType(c_namesort);
end;

procedure cbldObjList.add(obj:cbldObj);
begin
  AddObj(pointer(obj));
end;

function cbldObjList.Engine:cbldeng;
begin
  if count<>0 then
    result:=GetObj(0).eng
  else
    result:=nil;
end;

function cbldObjList.getObj(i:integer):cBldObj;
begin
  result:=cbldobj(items[i]);
end;

function cbldObjList.getObj(name:string):cBldObj;
var
  i:integer;
  o:cBldObj;
begin
  result:=nil;
  if fsort=c_namesort then
  begin
    i:=FindObj(@name);
    if i<>-1 then
    begin
      result:=getObj(i);
      exit;
    end;
  end;
  for I := 0 to Count - 1 do
  begin
    o:=getObj(i);
    if o.name=name then
    begin
      result:=o;
      exit;
    end;
  end;
end;

function cbldObjList.GetObjectsType:integer;
var
  objtype,i:integer;
begin
  result:=-1;
  objtype:=getobj(0).objtype;
  if count>1 then
  begin
    for I := 0 to Count - 1 do
    begin
      if objtype<>getobj(i).objtype then
        exit;
    end;
  end;
  result:=objtype;
end;

procedure cbldObjList.setSortType(i:integer);
begin
  case i of
    c_namesort:setComparator(NameSort);
  end;
  fsort:=i;
end;

procedure cbldObjList.deletechild(node:pointer);
begin
  cbldobj(node).destroy;
end;

end.
