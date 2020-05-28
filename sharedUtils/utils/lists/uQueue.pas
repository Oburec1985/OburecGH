unit uQueue;

interface
uses
  ucommontypes;

type
  cQueue_P2d = class
  protected
    // число элементов в деке
    fCount:integer;
    // первый элемент в очереди (выйдет первым)
    fFirst,
    // Последний (выйдет последним)
    fLast:integer;
    data: array of point2d;
  public
    // вытащить в порядке очереди 0 - первый в очереди на выход
    function Get(i:integer):point2d;
    // Добавить (положить) в начало очереди (выйдет первым)
    procedure push_front(p:point2d);
    // Добавить (положить) в конец очереди (выйдет последним)
    procedure push_back(p:point2d);
    // Извлечь из дека первый элемент
    function pop_front:point2d;
    // Извлечь из дека последний элемент
    function pop_back:point2d;
    // Узнать значение первого элемента (не удаляя его)
    function front:point2d;
    // Узнать значение последнего элемента (не удаляя его)
    function back:point2d;
    // Узнать количество элементов в деке
    function size:integer;
    // Очистить дек (удалить из него все элементы)
    procedure clear;
  protected
    procedure SetCapacity(c:integer);
    function GetCapacity:integer;
    procedure resize;
  public
    property capacity:integer read GetCapacity write SetCapacity;
    constructor create;
  end;

const
  c_capacity_step = 100;

implementation

{ cQueue_P2d }

constructor cQueue_P2d.create;
begin
  fCount:=0;
  fFirst:=0;
  fLast:=0;
end;

function cQueue_P2d.back: point2d;
begin
  result:=data[flast];
end;

function cQueue_P2d.front: point2d;
begin
  result:=data[ffirst];
end;

procedure cQueue_P2d.clear;
begin
  fCount:=0;
  fFirst:=0;
  fLast:=0;
end;

function cQueue_P2d.pop_back: point2d;
begin
  result:=data[flast];
  dec(fcount);
  dec(flast);
  if flast=capacity then
    flast:=capacity-1;
end;

function cQueue_P2d.pop_front: point2d;
begin
  result:=data[ffirst];
  inc(ffirst);
  dec(fcount);
  if ffirst=capacity then
  begin
    ffirst:=0;
  end;
end;
// выйдет последним
procedure cQueue_P2d.push_back(p: point2d);
var
  copycount, newpos:integer;
begin
  resize;
  if (Flast+1)=fFirst then
  begin
    copycount:=fcount-fFirst;
    newpos:=capacity-copycount;
    move(data[fFirst], data[newpos], copycount*sizeof(point2d));
    fFirst:=newpos;
  end;
  data[fLast]:=p;
  inc(fcount);
  inc(fLast);
end;
// выйдет первым
procedure cQueue_P2d.push_front(p: point2d);
var
  newpos:integer;
begin
  resize;
  newpos:=ffirst-1;
  if newpos<0 then
  begin
    newpos:=capacity-1;
  end;
  data[newpos]:=p;
  inc(fcount);
  ffirst:=newpos;
end;

procedure cQueue_P2d.resize;
begin
  if fCount+1>capacity then
  begin
    capacity:=capacity+c_capacity_step;
  end;
end;

procedure cQueue_P2d.SetCapacity(c: integer);
begin
  setlength(data, c);
end;

function cQueue_P2d.Get(i: integer): point2d;
begin
  i:=ffirst+i;
  if ffirst+i>capacity then
  begin
    i:=i-capacity;
  end;
end;

function cQueue_P2d.GetCapacity: integer;
begin
  result:=length(data);
end;

function cQueue_P2d.size: integer;
begin
  result:=fCount;
end;

end.
