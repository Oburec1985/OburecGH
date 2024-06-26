unit uSimpleSetList;
// �����

interface

uses classes, uSetList, uListMath;

type

  cFloatSetList = class(cSetList)
  public
    constructor create;override;
    function add(v:single):integer;
    function getSingle(i:integer):single;
  protected
    procedure deletechild(node:pointer);override;
  end;

  cDoubleSetList = class(cSetList)
  public
    constructor create;override;
    function add(v:double):integer;
    function getDouble(i:integer):double;
  protected
    procedure deletechild(node:pointer);override;
  end;


  cIntSetList = class(cSetList)
  public
    constructor create;override;
    function add(v:integer):integer;
    function getInt(i:integer):integer;
  protected
    procedure deletechild(node:pointer);override;
  end;


implementation

function Floatproccomparator(p1,p2:pointer):integer;
begin
  if single(p1^)>single(p2^) then
    result:=1
  else
  begin
    if single(p1^)<single(p2^) then
      result:=-1
    else
      result:=0;
  end;
end;

constructor cFloatSetList.create;
begin
  inherited;
  comparator:=Floatproccomparator;
end;

function cFloatSetList.add(v:single):integer;
var pv:psingle;
begin
  getmem(pv, sizeof(single));
  pv^:=v;
  result:=AddObj(pv);
end;

function cFloatSetList.getSingle(i:integer):single;
begin
  if i<=count-1 then
  begin
    result:=single(getnode(i)^);
  end;
end;

procedure cFloatSetList.deletechild(node:pointer);
begin
  freemem(psingle(node));
end;

function Doubleproccomparator(p1,p2:pointer):integer;
begin
  if Double(p1^)>Double(p2^) then
    result:=1
  else
  begin
    if Double(p1^)<Double(p2^) then
      result:=-1
    else
      result:=0;
  end;
end;

constructor cDoubleSetList.create;
begin
  inherited;
  comparator:=Doubleproccomparator;
end;

function cDoubleSetList.add(v:Double):integer;
var pv:pDouble;
begin
  getmem(pv, sizeof(Double));
  pv^:=v;
  result:=AddObj(pv);
end;

function cDoubleSetList.getDouble(i:integer):Double;
begin
  if i<=count-1 then
  begin
    result:=double(getnode(i)^);
  end;
end;

procedure cDoubleSetList.deletechild(node:pointer);
begin
  freemem(pDouble(node));
end;


function Intproccomparator(p1,p2:pointer):integer;
begin
  if integer(p1^)>integer(p2^) then
    result:=1
  else
  begin
    if integer(p1^)<integer(p2^) then
      result:=-1
    else
      result:=0;
  end;
end;

constructor cIntSetList.create;
begin
  inherited;
  comparator:=Floatproccomparator;
end;

function cIntSetList.add(v:integer):integer;
var pi:pinteger;
begin
  getmem(pi, sizeof(single));
  pi^:=v;
  result:=AddObj(pi);
end;

function cIntSetList.getInt(i:integer):integer;
begin
  if i<=count-1 then
  begin
    result:=integer(getnode(i)^);
  end;
end;

procedure cIntSetList.deletechild(node:pointer);
begin
  freemem(pinteger(node));
end;



end.
