unit uPointsList;

interface
uses
  usetList, uCommonTypes, uMyMath;

type

  p2dArray = array of point2d;

  cPointsMemMng = class
  public
    // ����� �������������� ��������� � ��������� �������������� ����
    usedItems:cardinal;
    // ����� �������������� ������ � ��������� �������������� ����
    usedBlocks:cardinal;
  public
    MemArray:array of p2dArray;
    // ��������������� ������ ����� ������
    m_BlockCapacity:cardinal;
  protected
    procedure IncUsedItems;
  public
    function count:integer;
    procedure allocateBlock;
    // �������� ����� ����� � ������� ��������� i-� �������, ���������� ������ ������ �����
    function GetBlockIndex(i:integer; var block:integer):integer;
    // ������� ������ ����� � ������� �������
    function GetBlock(x:double):integer;
    // ��� ������� ���������� 1 ����
    Constructor Create(blockCapacity:cardinal);
    Destructor Destroy;
    // ������� ��� ���������� �����
    procedure clearMem;
    // �������� ��� � ������ � ���������� ���������
    function AddP2(p2:point2d):pointer;
  end;

  cP2dList = class(csetlist)
  protected
    mem:cPointsMemMng;
  public
    procedure sortByX;
    procedure sortByY;
    function getP(i:integer):point2d;
    function getPtr(i:integer):PPoint2d;
    procedure deletechild(node: pointer); override;
    constructor create; override;
    function add(p:point2d):integer;
    destructor destroy;override;
  end;

  {cPointList = class
  protected
    // ����� �� �������� ������ ��� ���������� �����
    PointsMemMng:cPointsMemMng;
  protected
    // ���������� ����� ����� � ������� ���������� ������ �������
    function GetBlockIndex(i:integer; var block:integer):integer;
    function GetPInBlock(i:integer; block:integer):point2d;
    function GetLow(key:pointer;var index:integer):pointer;
    // ����� ��������� ������ ������ �� �����
    function GetHight(key:pointer; var index:integer):pointer;
  public
    constructor create;override;
    destructor destroy;override;
    function getP(i:integer):point2d;override;
    function GetLoP(p:point2d; var index:integer):point2d;override;
    function GetHiP(p:point2d; var index:integer):point2d;override;
    function Count:integer;override;
    procedure clear;override;
  end; }

  const
    c_blockcapacity = 40000;
    c_blockCount = 500;

implementation

function ResComparator(p1, p2: pointer): integer;
begin
  if point2d(p1^).x > point2d(p2^).x then
  begin
    result := 1;
  end
  else
  begin
    if  point2d(p1^).x <  point2d(p2^).x then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;

function ResComparatorY(p1, p2: pointer): integer;
begin
  if point2d(p1^).y > point2d(p2^).y then
  begin
    result := 1;
  end
  else
  begin
    if  point2d(p1^).y <  point2d(p2^).y then
    begin
      result := -1;
    end
    else
    begin
      result := 0;
    end;
  end;
end;

Constructor cPointsMemMng.Create(blockCapacity:cardinal);
begin
  setlength(memarray, c_blockCount);
  usedBlocks:=0;
  useditems:=0;
  m_BlockCapacity:=blockCapacity;
  allocateBlock;
end;


Destructor cPointsMemMng.Destroy;
begin
  clearMem;
  setlength(memarray,0);
end;

function cPointsMemMng.count:integer;
begin
  result:=usedItems;
  if usedBlocks>0 then
  begin
    result:=result+usedBlocks*m_BlockCapacity;
  end;
end;

procedure cPointsMemMng.clearMem;
var
  i:integer;
begin
  for I := 0 to usedBlocks do
  begin
    setlength(MemArray[i],0);
  end;
  usedBlocks:=0;
end;

procedure cPointsMemMng.allocateBlock;
begin
  setlength(MemArray[usedBlocks],m_BlockCapacity);
end;

procedure cPointsMemMng.IncUsedItems;
begin
  inc(usedItems);
  if usedItems>=m_BlockCapacity then
  begin
    inc(usedBlocks);
    allocateBlock;
    usedItems:=0;
  end;
end;

function cPointsMemMng.AddP2(p2:point2d):pointer;
begin
  MemArray[usedBlocks,usedItems]:=p2;
  result:=@MemArray[usedBlocks,usedItems];
  IncUsedItems;
end;

function cPointsMemMng.GetBlockIndex(i:integer; var block:integer):integer;
begin
  block:=0;
  while i>=m_BlockCapacity do
  begin
    inc(block);
    i:=i-m_BlockCapacity;
  end;
  result:=i;
end;

function compareD(x1,x2:double):integer;
begin
  if x1>x2 then
    result:=1
  else
  begin
    if x1<x2 then
      result:=-1
    else
      result:=0;
  end;
end;

function cPointsMemMng.GetBlock(x:double):integer;
var
  res,block:integer;
  lp:point2d;
begin
  block:=0;
  while block<>usedBlocks do
  begin
    if block<=usedBlocks then
    begin
      lp:=MemArray[block,m_BlockCapacity-1];
      res:=compareD(lp.x,x);
      if res=1 then
      begin
        break;
      end;
    end;
    inc(block);
  end;
  result:=block;
end;


{ cP2dList }

function cP2dList.add(p: point2d): integer;
var
  lp:pointer;
begin
  lp:=mem.AddP2(p);
  AddObj(lp);
end;

constructor cP2dList.create;
begin
  inherited;
  mem:=cPointsMemMng.Create(c_blockcapacity);
  comparator:=ResComparator;
end;

procedure cP2dList.sortbyx;
begin
  if @comparator<>@ResComparator then
  begin
    comparator:=ResComparator;
    SortList(comparator);
  end;
end;

procedure cP2dList.sortbyy;
begin
  if @comparator<>@ResComparatorY then
  begin
    comparator:=ResComparatorY;
    SortList(comparator);
  end;
end;


procedure cP2dList.deletechild(node: pointer);
begin
  inherited;
end;

destructor cP2dList.destroy;
begin
  mem.Destroy;
  inherited;
end;

function cP2dList.getP(i:integer):point2d;
begin
  Result:=point2d(Get(i)^);
end;

function cP2dList.getPtr(i:integer):PPoint2d;
begin
  result:=Ppoint2d(Get(i));
end;

end.
