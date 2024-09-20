unit uQueue;

interface
uses
  ucommontypes;

type
  cQueue<T> = class
  type
    PT = ^T;
  public
    // если false то новые вершины выталкивают старые
    m_resizeMode:boolean;
  protected
    // число элементов
    fCount:integer;
    // первый элемент в очереди (выйдет первым)
    fFirst,
    // Последний (выйдет последним)
    fLast:integer;
    data: TArray<T>;
  protected
  public
    // удалить элемент
    procedure Delete(i:integer);
    // вытащить в порядке очереди 0 - первый в очереди на выход
    function Peak(i:integer):T;
    function GetByInd(i:integer):T;
    // возвращаем по указателю если нужно модифимцировать элемент в списке
    function GetPByInd(i:integer):PT;
    // Добавить (положить) в начало очереди (выйдет первым)
    procedure push_front(p:T);
    // Добавить (положить) в конец очереди (выйдет последним)
    procedure push_back(p:T);
    // Извлечь из первый элемент
    function pop_front:T;
    // Извлечь из последний элемент
    function pop_back:T;
    // Узнать значение первого элемента (не удаляя его)
    function front:T;
    // Узнать значение последнего элемента (не удаляя его)
    function back:T;
    // Узнать количество элементов в деке
    function size:integer;
    // Очистить (удалить из него все элементы)
    procedure clear;
    // отбросить i элементов
    procedure drop_front(i:integer);
  protected
    procedure SetCapacity(c:integer);
    function GetCapacity:integer;
    procedure resize;
  public
    property capacity:integer read GetCapacity write SetCapacity;
    constructor create;
  end;

const
  c_capacity_step = 256;

implementation

{ cQueue<T> }

function cQueue<T>.back: T;
begin

end;

procedure cQueue<T>.clear;
begin
  fCount:=0;
  fFirst:=-1;
  fLast:=-1;
end;

constructor cQueue<T>.create;
begin
  m_resizeMode:=true;
  fCount:=0;
  capacity:=10;
  fFirst:=-1;
  fLast:=-1;
end;

procedure cQueue<T>.Delete(i: integer);
VAR
  copycount:integer;
begin
  if i>=fFirst then
  begin
    if fcount<capacity then
      copycount:=(fLast-i)
    else
      copycount:=capacity-i;
    move(data[i+1], data[i], copycount*sizeof(T));
  end;
  dec(fcount);
  dec(flast);
end;

procedure cQueue<T>.drop_front(i: integer);
begin
  if fcount<=i then
  begin
    clear;
    exit;
  end;
  ffirst:=ffirst+i+1;
  fcount:=fcount-i-1;
  if ffirst>=capacity then
  begin
    ffirst:=ffirst-capacity;
  end;
end;

function cQueue<T>.front: T;
begin
  result:=data[ffirst];
end;

function cQueue<T>.GetByInd(i: integer): T;
begin
  result:=data[i];
end;

function cQueue<T>.GetPByInd(i:integer):PT;
begin
  result:=@data[i];
end;

function cQueue<T>.Peak(i: integer): T;
begin
  i:=ffirst+i;
  if i>=capacity then
  begin
    i:=i-capacity;
  end;
  result:=data[i];
end;

function cQueue<T>.pop_back: T;
begin
  result:=data[flast];
  dec(fcount);
  dec(flast);
  if flast=capacity then
    flast:=capacity-1;
end;

function cQueue<T>.pop_front: T;
begin
  if fcount=0 then
  begin
    //result:=p2d(0,0);
    exit;
  end;
  result:=data[ffirst];
  inc(ffirst);
  dec(fcount);
  if ffirst=capacity then
  begin
    ffirst:=0;
  end
  else
  begin
    if fcount=0 then
    begin
      ffirst:=-1;
      flast:=-1;
    end
  end;
end;

procedure cQueue<T>.push_back(p: T);
var
  copycount, newpos:integer;
begin
  if m_resizeMode=false then
  begin
    // посмотреть внимательнее в случае реализации метода drop_back
    if fcount=capacity then
    begin
      data[fFirst]:=p; // выталкиваем первого в очереди
      if ffirst=(capacity-1) then
      begin
        ffirst:=0;
      end
      else
      begin
        flast:=ffirst;
        inc(ffirst);
      end;
      exit;
    end;
  end;

  resize;
  if (Flast+1)=fFirst then
  begin
    if fcount<>0 then
    begin
      copycount:=fcount-fFirst;
      newpos:=capacity-copycount;
      move(data[fFirst], data[newpos], copycount*sizeof(T));
      fFirst:=newpos;
      Flast:=Flast+1;
    end;
  end
  else
  begin
    if flast+1=capacity then
    begin
      flast:=0;
    end
    else
    begin
      inc(flast);
    end;
  end;
  data[fLast]:=p;
  inc(fcount);
  if fcount=1 then
  begin
    ffirst:=flast;
  end;
end;

procedure cQueue<T>.push_front(p: T);
var
  copycount, newpos:integer;
begin
  if m_resizeMode=false then
  begin
    if fcount=capacity then
    begin
      data[flast]:=p;
      if flast=0 then
      begin
        flast:=capacity-1;
        ffirst:=0;
      end
      else
      begin
        newpos:=flast;
        ffirst:=flast;
        flast:=ffirst-1;
      end;
      exit;
    end;
  end;

  resize;
  if ffirst=0 then
  begin
    newpos:=capacity-1;
  end
  else
  begin
    if (ffirst-1)=flast then
    begin
      copycount:=fcount-ffirst; // число элементов в конце массива от начала очереди
      newpos:=capacity-copycount;
      move(data[fFirst], data[newpos], copycount*sizeof(T));
      fFirst:=newpos-1;
      data[fFirst]:=p;
      inc(fcount);
      exit;
    end
    else
    begin
      dec(ffirst);
      newpos:=ffirst;
    end;
  end;
  data[newpos]:=p;
  inc(fcount);
  ffirst:=newpos;
end;

procedure cQueue<T>.resize;
begin
  if fCount+1>capacity then
  begin
    capacity:=capacity+c_capacity_step;
  end;
end;

function cQueue<T>.size: integer;
begin
  result:=fCount;
end;

function cQueue<T>.GetCapacity: integer;
begin
  result:=length(data);
end;

procedure cQueue<T>.SetCapacity(c: integer);
begin
  setlength(data, c);
end;

end.
