// ���� �������� ����� ���� ������� ������������ � ���������
unit uTickData;

interface
uses math, sysutils, uVectorList, classes, uListMath, usetlist;

type

  sTickData = record
    Data: cardinal; // ����� �����
    OverflowCount:cardinal; // ����� ������������ �������
  end;

  ptickdata = ^stickdata;

  memPool = array of stickdata;

  cBldMemMng = class
  public
    // ����� �������������� ��������� � ��������� �������������� ����
    usedItems:cardinal;
    // ����� �������������� ������ � ��������� �������������� ����
    usedBlocks:cardinal;
  public
    MemArray:array of memPool;
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
    function GetBlock(tick:stickdata):integer;
    // ��� ������� ���������� 1 ����
    Constructor Create(blockCapacity:cardinal);
    Destructor Destroy;
    // ������� ��� ���������� �����
    procedure clearMem;
    // �������� ��� � ������ � ���������� ���������
    function AddTick(tick:stickdata):pointer;
  end;

  cBaseTicks = class
  public
    constructor create;virtual;
    destructor destroy;virtual;
    procedure add(tick:stickdata);virtual;abstract;
    function gettick(i:integer):stickdata;virtual;abstract;
    function GetLoTick(tick:stickdata; var index:integer):stickdata;virtual;abstract;
    function GetHiTick(tick:stickdata; var index:integer):stickdata;virtual;abstract;
    function count:integer;virtual;abstract;
    // ����� ��������� ������ ����� �� �����
    function GetLow(key:pointer;var index:integer):pointer;virtual;abstract;
    // ����� ��������� ������ ������ �� �����
    function GetHight(key:pointer; var index:integer):pointer;virtual;abstract;
    procedure clear;virtual;abstract;
  protected
    procedure deleteobj(node:pointer);virtual;abstract;
  end;

  // ����� ������
  function FindInTickArrayLowBound(var a:array of sTickData;x:sTickData):integer;overload;
  function FindInTickArrayLowBound(var a:array of sTickData;x:sTickData;fromInd,toInd:integer):integer;overload;
  function FindInTickArrayHiBound(var a:array of sTickData;x:sTickData):integer;overload;
  function FindInTickArrayHiBound(var a:array of sTickData;x:sTickData;fromInd,toInd:integer):integer;overload;
  // ������� ������� � ����� � ������ ����������� (cardinal)
  function Addtick(t:stickdata;dt:int64):stickdata;
  // ������� ������� � ����� � ������ ����������� (cardinal)
  Function DecTicks(Tick:stickdata; dTick:Int64):stickdata;overload;
  Function DecTicks(Tick1:stickdata; Tick2:stickdata):stickdata;overload;
  // ���������� 1 ���� BigT>LowT, 0 ���� "=", -1 ���� "<"
  function CompareTicks(BigT,LowT:sTickData):integer;
  // ���������� true ���� ��� ��������� ������ �������
  function inTurn(t,LoT,hiT:sTickData):boolean;
  // t2-t1. ������� �������� overflow. ������ �������� ��� ����� ������������� ������
  // (�������� ������ ���������� �������� ������� �� ����������)
  Function evDecTicks(t1:stickdata;t2:stickdata):cardinal;
  Function TickToStr(t:stickdata):string;
  function proccomparator(p1,p2:pointer):integer;  

  const
    CardFreq = 40000000;  // 40 ���
    MaxCardinalValue = 4294967295;
    c_blockcapacity = 40000;
    c_blockCount = 500;

implementation

Constructor cBldMemMng.Create(blockCapacity:cardinal);
begin
  setlength(memarray, c_blockCount);
  usedBlocks:=0;
  useditems:=0;
  m_BlockCapacity:=blockCapacity;
  allocateBlock;
end;

Destructor cBldMemMng.Destroy;
begin
  clearMem;
  setlength(memarray,0);
end;

function cBldMemMng.count:integer;
begin
  result:=usedItems;
  if usedBlocks>0 then
  begin
    result:=result+usedBlocks*m_BlockCapacity;
  end;
end;

procedure cBldMemMng.clearMem;
var
  i:integer;
begin
  for I := 0 to usedBlocks do
  begin
    setlength(MemArray[i],0);
  end;
  usedBlocks:=0;
end;

procedure cBldMemMng.allocateBlock;
begin
  setlength(MemArray[usedBlocks],m_BlockCapacity);
end;

procedure cBldMemMng.IncUsedItems;
begin
  inc(usedItems);
  if usedItems>=m_BlockCapacity then
  begin
    inc(usedBlocks);
    allocateBlock;
    usedItems:=0;
  end;
end;

function cBldMemMng.AddTick(tick:stickdata):pointer;
begin
  MemArray[usedBlocks,usedItems]:=tick;
  result:=@MemArray[usedBlocks,usedItems];
  IncUsedItems;
end;

function proccomparator(p1,p2:pointer):integer;
begin
  result:=CompareTicks(stickdata(p1^), stickdata(p2^));
end;

function OptimisedProcComparator(p1,p2:pointer):integer;
begin
  result:=CompareTicks(stickdata(p1^), stickdata(p2^));
end;

destructor cBaseTicks.destroy;
begin
  inherited;
end;

constructor cBaseTicks.create;
begin
  inherited;
end;

Function DecTicks(Tick:stickdata;dTick:Int64):stickdata;
begin
  result:=Addtick(tick,-dtick);
end;

Function DecTicks(Tick1:stickdata; Tick2:stickdata):stickdata;
begin
  tick2:=DecTicks(tick2,tick1.data);
  tick2.OverflowCount:=tick2.OverflowCount-tick1.OverflowCount;
  result:=tick2;
end;

Function evDecTicks(t1:stickdata;t2:stickdata):cardinal;
var
  res:stickdata;
  compare:integer;
begin
  compare:=CompareTicks(t2,t1);
  if compare=1 then
  begin
    res:=DecTicks(t1,t2);
    result:=res.Data;
    exit;
  end
  else
  begin
    if compare=-1 then
    begin
      res:=DecTicks(t2,t1);
      result:=-res.Data;
      exit;
    end
    else
    begin
      result:=0;
      exit;
    end;
  end;
end;

// ��������� ������
function CompareTicks(BigT,LowT:sTickData):integer;
begin
  if BigT.OverflowCount>LowT.OverflowCount then begin Result:=1; exit end;
  if BigT.OverflowCount<LowT.OverflowCount then begin Result:=-1; exit end;  if BigT.OverflowCount=LowT.OverflowCount then
  begin
    if BigT.Data>LowT.Data then
      Result:=1
    else if BigT.Data=LowT.Data then
      Result:=0
    else
      Result:=-1
  end;
end;

function _div(a,b:integer;var frac_:boolean):integer;
var res:integer;
begin
   if a=1 then
   begin
    result:=0;
    exit;
   end;
   res:= trunc(a/b);
   frac_:=((a mod b)<>0);
   result:=res;
end;

function FindInTickArrayLowBound(var a:array of sTickData;x:sTickData;fromInd,toInd:integer):integer;
var b:boolean;
    range,curind,
    len,left,right:integer;
    frac_:boolean;
begin
  len:=toInd+1;
  curind:=fromInd;
  // �������� ��������� �����������
  if CompareTicks(a[len-1],x)<0 then
  begin
    result:=len-1;
    exit;
  end;
  if CompareTicks(a[curind],x)>0 then
  begin
    result:=0;
    exit;
  end;
  // ���������� ������� ������ � �������
  left:=curind;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if CompareTicks(a[curind],x)>0 then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if CompareTicks(a[curind],x)>0 then
    result:=curind-1
  else
    result:=curind;

end;

// ������� � ������� ������� ����� �� �������� � �������� x
function FindInTickArrayLowBound(var a:array of sTickData;x:sTickData):integer;
begin
  result:=FindInTickArrayLowBound(a,x,0,length(a)-1);
end;

function FindInTickArrayHiBound(var a:array of sTickData;x:sTickData;fromInd,toInd:integer):integer;overload;
var b:boolean;
    len,range,curind,
    left,right:integer;
    frac_:boolean;
    function _div(a,b:integer;var frac_:boolean):integer;
    var res:integer;
    begin
       if a=1 then
       begin
        result:=0;
        exit;
       end;
       res:= trunc(a/b);
       frac_:=((a mod b)<>0);
       result:=res;
    end;
begin
  len:=toind+1;
  curind:=fromind;
  // �������� ��������� �����������
  if CompareTicks(a[len-1],x)<0 then
  begin
    result:=len-1;
    exit;
  end;
  if CompareTicks(a[curind],x)>0 then
  begin
    result:=0;
    exit;
  end;
  // ���������� ������� ������ � �������
  left:=curind;
  right:=len-1;
  // -----------------------------------
  range:=_div(right - left,2,frac_);
  curind:=range;
  b:=false;
  while not b do
  begin
    if CompareTicks(a[curind],x)>0 then
    begin
      right := curind;
      range:=_div(right - left,2,frac_);
      curind:=left + range;
    end
    else
    begin
      left:=curind;
      range:=_div(right - left,2,frac_);
      curind:=right - range;
    end;
    if range<=0 then b := true;
  end;
  if CompareTicks(a[curind],x)>0 then
    result:=curind
  else
    result:=curind+1;
end;

// ������� � ������� ������� ������ �� �������� � �������� x
function FindInTickArrayHiBound(var a:array of sTickData;x:sTickData):integer;
begin
  result:=FindInTickArrayHiBound(a,x,0,length(a)-1);
end;

// �������� ��� ��� ��������� ������ �������
function inTurn(t,LoT,hiT:sTickData):boolean;
begin
  result:=false;
  if compareticks(hit,t)>0 then
  begin
    if compareticks(t,loT)>0 then
    begin
      result:=true;
    end;
  end;
end;

function Addtick(t:stickdata;dt:int64):stickdata;
var
  // ����� �� ������������
  delt:cardinal;
  absdt:cardinal;
begin
  if dt>=0 then
  begin
    delt:=MaxCardinalValue-t.Data;
    if dT>delt then
    begin
      inc(t.OverflowCount);
      t.Data:=dt-delt;
    end
    else
    begin
      t.Data:=t.Data+dt;
    end;
  end
  else
  begin
    absdt:=abs(dt);
    if absdt>t.data then
    begin
      dec(t.OverflowCount);
      t.Data:=MaxCardinalValue-(absdt-t.data);
    end
    else
    begin
      t.Data:=t.Data-absdt;
    end;
  end;
  result:=t;
end;

Function TickToStr(t:stickdata):string;
begin
  result:=inttostr(t.Data)+'/ '+inttostr(t.OverflowCount);
end;

function cBldMemMng.GetBlockIndex(i:integer; var block:integer):integer;
begin
  block:=0;
  while i>=m_BlockCapacity do
  begin
    inc(block);
    i:=i-m_BlockCapacity;
  end;
  result:=i;
end;

function cBldMemMng.GetBlock(tick:stickdata):integer;
var
  res,block:integer;
  ltick:stickdata;
begin
  block:=0;
  while block<>usedBlocks do
  begin
    if block<=usedBlocks then
    begin
      ltick:=MemArray[block,m_BlockCapacity-1];
      res:=compareticks(ltick,tick);
      if res=1 then
      begin
        break;
      end;
    end;
    inc(block);
  end;
  result:=block;
end;

end.
