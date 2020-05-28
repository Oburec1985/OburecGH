unit uQueue;

interface
uses
  ucommontypes;

type
  cQueue_P2d = class
  protected
    // ����� ��������� � ����
    fCount:integer;
    // ������ ������� � ������� (������ ������)
    fFirst,
    // ��������� (������ ���������)
    fLast:integer;
    data: array of point2d;
  public
    // �������� � ������� ������� 0 - ������ � ������� �� �����
    function Get(i:integer):point2d;
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
// ������ ���������
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
// ������ ������
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
