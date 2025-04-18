unit uArrayTicks;

interface

uses math, sysutils, uVectorList, classes, uListMath, usetlist, uTickData;

type
  cArrayTicks = class(cBaseTicks)
  protected
  public
    // ����� �� �������� ������ ��� ���������� �����
    BldMemMng:cBldMemMng;
  protected
    // ���������� ����� ����� � ������� ���������� ������ �������
    function GetBlockIndex(i:integer; var block:integer):integer;
    function GetTickInBlock(i:integer; block:integer):sTickData;
  public
    constructor create;override;
    destructor destroy;override;
    //procedure add(tick:stickdata);
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

constructor cArrayTicks.create;
begin
  inherited;
  BldMemMng:=cBldMemMng.Create(c_blockcapacity);
end;

destructor cArrayTicks.destroy;
begin
  BldMemMng.ClearMem;
  BldMemMng.destroy;
  inherited;
end;

function cArrayTicks.gettick(i:integer):stickdata;
var
  // ����� ����� � ������� ������ ���
  block, index:integer;
begin
  //block:=trunc(i/BldMemMng.m_blockcapacity);
  //index:=i-block*BldMemMng.m_blockcapacity;
  //result:=BldMemMng.MemArray[block,index];
  index:=getblockindex(i,block);
  //if length(BldMemMng.MemArray[block])<>0 then
  if index>=0 then
    result:=BldMemMng.MemArray[block,index];
end;

function cArrayTicks.GetLoTick(tick:stickdata; var index:integer):stickdata;
var
  used,block:integer;
begin
  block:=BldMemMng.GetBlock(tick);
  if block<BldMemMng.usedBlocks then
    used:=BldMemMng.m_BlockCapacity
  else
    used:=BldMemMng.usedItems;
  index:=FindInTickArrayLowBound(BldMemMng.MemArray[block],tick, 0,used-1);
  result:=BldMemMng.MemArray[block,index];
  index:=index+block*BldMemMng.m_BlockCapacity;
end;

function cArrayTicks.GetHiTick(tick:stickdata; var index:integer):stickdata;
var
  used,block:integer;
begin
  block:=BldMemMng.GetBlock(tick);
  if block<BldMemMng.usedBlocks then
    used:=BldMemMng.m_BlockCapacity
  else
    used:=BldMemMng.usedItems;
    index:=FindInTickArrayHiBound(BldMemMng.MemArray[block],tick,0,used-1);
  result:=BldMemMng.MemArray[block,index];
  index:=index+block*BldMemMng.m_BlockCapacity;
end;

function cArrayTicks.Count:integer;
begin
  result:=BldMemMng.count;
end;

// ����� ��������� ������ ����� �� �����
function cArrayTicks.GetLow(key:pointer;var index:integer):pointer;
var
  block:integer;
begin
  block:=BldMemMng.GetBlock(stickdata(key^));
  if block=BldMemMng.usedBlocks then
    index:=FindInTickArrayLowBound(BldMemMng.MemArray[block],stickdata(key^),
         0,BldMemMng.usedItems-1)
  else
    index:=FindInTickArrayLowBound(BldMemMng.MemArray[block],stickdata(key^),
         0,BldMemMng.m_BlockCapacity-1);
  result:=@BldMemMng.MemArray[block, index];
  index:=index+block*BldMemMng.m_BlockCapacity;
end;

// ����� ��������� ������ ������ �� �����
function cArrayTicks.GetHight(key:pointer; var index:integer):pointer;
var
  block:integer;
begin
  block:=BldMemMng.GetBlock(stickdata(key^));
  if block=BldMemMng.m_BlockCapacity then
    index:=FindInTickArrayHiBound(BldMemMng.MemArray[block],stickdata(key^),
         0,BldMemMng.usedItems-1)
  else
    index:=FindInTickArrayHiBound(BldMemMng.MemArray[block],stickdata(key^),
         0,BldMemMng.m_BlockCapacity-1);
  result:=@BldMemMng.MemArray[block, index];
  index:=index+block*BldMemMng.m_BlockCapacity;
end;

procedure cArrayTicks.clear;
begin
  //BldMemMng.clearmem;
  BldMemMng.usedBlocks:=0;
  BldMemMng.useditems:=0;
end;

function cArrayTicks.GetBlockIndex(i:integer; var block:integer):integer;
begin
  result:=BldMemMng.GetBlockIndex(i, block);
end;

function cArrayTicks.GetTickInBlock(i:integer; block:integer):sTickData;
begin
  result:=BldMemMng.MemArray[block,i];
end;


end.
