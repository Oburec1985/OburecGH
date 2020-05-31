unit uQueue;

interface
uses
  ucommontypes;

type
  cQueue<T> = class
  protected
    // ����� ��������� � ����
    fCount:integer;
    // ������ ������� � ������� (������ ������)
    fFirst,
    // ��������� (������ ���������)
    fLast:integer;
    data: TArray<T>;
  public
    // �������� � ������� ������� 0 - ������ � ������� �� �����
    function Peak(i:integer):T;
    function GetByInd(i:integer):T;
    // �������� (��������) � ������ ������� (������ ������)
    procedure push_front(p:T);
    // �������� (��������) � ����� ������� (������ ���������)
    procedure push_back(p:T);
    // ������� �� ���� ������ �������
    function pop_front:T;
    // ������� �� ���� ��������� �������
    function pop_back:T;
    // ������ �������� ������� �������� (�� ������ ���)
    function front:T;
    // ������ �������� ���������� �������� (�� ������ ���)
    function back:T;
    // ������ ���������� ��������� � ����
    function size:integer;
    // �������� ��� (������� �� ���� ��� ��������)
    procedure clear;
  protected
    procedure SetCapacity(c:integer);
    function GetCapacity:integer;
    procedure resize;
  public
    property capacity:integer read GetCapacity write SetCapacity;
    constructor create;
  end;

  cQueue_P2d = class
  protected
    // ����� ��������� � ����
    fCount:integer;
    // ������ ������� � ������� (������ ������)
    fFirst,
    // ��������� (������ ���������)
    fLast:integer;
    data:array of point2d;
  public
    // �������� � ������� ������� 0 - ������ � ������� �� �����
    function Peak(i:integer):point2d;
    function GetByInd(i:integer):point2d;
    // �������� (��������) � ������ ������� (������ ������)
    procedure push_front(p:point2d);
    // �������� (��������) � ����� ������� (������ ���������)
    procedure push_back(p:point2d);
    // ������� �� ���� ������ �������
    function pop_front:point2d;
    // ������� �� ���� ��������� �������
    function pop_back:point2d;
    // ������ �������� ������� �������� (�� ������ ���)
    function front:point2d;
    // ������ �������� ���������� �������� (�� ������ ���)
    function back:point2d;
    // ������ ���������� ��������� � ����
    function size:integer;
    // �������� ��� (������� �� ���� ��� ��������)
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
  c_capacity_step = 1;

implementation

{ cQueue_P2d }

constructor cQueue_P2d.create;
begin
  fCount:=0;
  fFirst:=-1;
  fLast:=-1;
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
  fFirst:=-1;
  fLast:=-1;
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
  if fcount=0 then
  begin
    result:=p2d(0,0);
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
// ������ ���������
procedure cQueue_P2d.push_back(p: point2d);
var
  copycount, newpos:integer;
begin
  resize;
  if (Flast+1)=fFirst then
  begin
    if fcount<>0 then
    begin
      copycount:=fcount-fFirst;
      newpos:=capacity-copycount;
      move(data[fFirst], data[newpos], copycount*sizeof(point2d));
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

// ������ ������
procedure cQueue_P2d.push_front(p: point2d);
var
  copycount, newpos:integer;
begin
  resize;
  if ffirst=0 then
  begin
    newpos:=capacity-1;
  end
  else
  begin
    if (ffirst-1)=flast then
    begin
      copycount:=fcount-ffirst; // ����� ��������� � ����� ������� �� ������ �������
      newpos:=capacity-copycount;
      move(data[fFirst], data[newpos], copycount*sizeof(point2d));
      fFirst:=newpos-1;
      data[fFirst]:=p;
      inc(fcount);
      exit;
    end;
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

function cQueue_P2d.Peak(i: integer): point2d;
begin
  i:=ffirst+i;
  if i>=capacity then
  begin
    i:=i-capacity;
  end;
  result:=data[i];
end;

function cQueue_P2d.GetByInd(i: integer): point2d;
begin
  result:=data[i];
end;

function cQueue_P2d.GetCapacity: integer;
begin
  result:=length(data);
end;

function cQueue_P2d.size: integer;
begin
  result:=fCount;
end;

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
  fCount:=0;
  fFirst:=-1;
  fLast:=-1;
end;

function cQueue<T>.front: T;
begin
  result:=data[ffirst];
end;

function cQueue<T>.GetByInd(i: integer): T;
begin
  result:=data[i];
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
  resize;
  if (Flast+1)=fFirst then
  begin
    if fcount<>0 then
    begin
      copycount:=fcount-fFirst;
      newpos:=capacity-copycount;
      move(data[fFirst], data[newpos], copycount*sizeof(point2d));
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
  resize;
  if ffirst=0 then
  begin
    newpos:=capacity-1;
  end
  else
  begin
    if (ffirst-1)=flast then
    begin
      copycount:=fcount-ffirst; // ����� ��������� � ����� ������� �� ������ �������
      newpos:=capacity-copycount;
      move(data[fFirst], data[newpos], copycount*sizeof(point2d));
      fFirst:=newpos-1;
      data[fFirst]:=p;
      inc(fcount);
      exit;
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
