unit uTicks;

interface

uses math, sysutils, uVectorList, classes, uListMath, usetlist, uTickData;

type

  cTicksList = class(cSetList)
  protected
  public
    constructor create;override;
    destructor destroy;override;
  end;


  cSortedticks = class(cBaseTicks)
  protected
  public
    TickList:cTicksList;
    // ����� �� �������� ������ ��� ���������� �����
    BldMemMng:cBldMemMng;
  public
    constructor create;override;
    destructor destroy;override;
    procedure add(tick:stickdata);override;
    function gettick(i:integer):stickdata;override;
    function GetLoTick(tick:stickdata; var index:integer):stickdata;override;
    function GetHiTick(tick:stickdata; var index:integer):stickdata;override;
    function Count:integer;override;
    // ����� ��������� ������ ����� �� �����
    function GetLow(key:pointer;var index:integer):pointer;override;
    // ����� ��������� ������ ������ �� �����
    function GetHight(key:pointer; var index:integer):pointer;override;
    procedure clear;override;
  end;

implementation

constructor cTicksList.create;
begin
  inherited;
  comparator:=proccomparator;
  destroydata:=false;
end;

destructor cTicksList.destroy;
begin
  inherited;
end;

destructor cSortedticks.destroy;
begin
  cBldMemMng(BldMemMng).ClearMem;
  cbldmemmng(BldMemMng).Destroy;
  tickList.destroy;
  inherited;
end;

constructor cSortedticks.create;
begin
  inherited;
  BldMemMng:=cBldMemMng.Create(c_blockcapacity);
  TickList:=cTicksList.create;
end;

procedure cSortedticks.clear;
begin
  ticklist.clear;
end;

procedure cSortedticks.add(tick:stickdata);
var
  ltick:ptickdata;
begin
  ltick:=ptickdata(cBldMemMng(BldMemMng).AddTick(tick));
  ltick^:=tick;
  ticklist.AddObj(ltick);
end;

function cSortedticks.gettick(i:integer):stickdata;
begin
  if i<=TickList.count-1 then
  begin
    result:=stickdata(TickList.getnode(i)^);
  end;
end;

function cSortedticks.GetLoTick(tick:stickdata; var index:integer):stickdata;
var
  p:pointer;
begin
  p:=(ticklist.GetLow(@tick,index));
  if p=nil then
    result:=gettick(0)
  else
    result:=gettick(index);
end;

function cSortedticks.GetHiTick(tick:stickdata; var index:integer):stickdata;

begin
  result:=stickdata(ticklist.GetHight(@tick,index)^);
end;

// ����� ��������� ������ ����� �� �����
function cSortedticks.GetLow(key:pointer;var index:integer):pointer;
begin
  result:=ticklist.getlow(key,index);
end;
// ����� ��������� ������ ������ �� �����
function cSortedticks.GetHight(key:pointer; var index:integer):pointer;
begin
  result:=ticklist.gethight(key,index);
end;

function cSortedticks.Count:integer;
begin
  result:=TickList.count;
end;

end.
