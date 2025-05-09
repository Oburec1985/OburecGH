// ������ ����sdftn ����� ������������� �����
unit uChan;

interface
uses uTickData, uBldObj, uBaseObjTypes, ubaseobj, sysutils, uTicks, uArrayTicks;

type
  cChanList = class(cBaseObjList)
  public
    constructor create;override;
  end;

  cChanObj = class(cbaseobj)
  public
    constructor create;override;
    procedure CreateChildrens;override;
  end;

  cChan = class(cBldObj)
    // ������ �����
    ticks:cbaseticks;
    // �������� ������
    Amplifier:byte;
  protected
    fchan:integer;
  protected
    function SupportedChildClass(obj:cbaseobj):boolean;override;
    function SupportedChildClass(classname:string):boolean;override;
    function SupportedChildClass(objtype:integer):boolean;override;
    procedure setchan(b:integer);
  public
    property chan:integer read fchan write setchan;
    constructor create;overload;override;
    constructor create(ticksType:integer);overload;
    destructor destroy;override;
    function ticksCount:integer;
    // ����������� ������ �����
    procedure CreateTicks(ticktype:integer);
  end;

const
  c_ArrayTicks = 1;
  c_Sortedticks = 2;

implementation

function ChanComparator(p1,p2:pointer):integer;
var
  c1,c2:cchan;
begin
  c1:=cchan(p1);
  c2:=cchan(p2);
  if c1.chan>c2.chan then
    result:=1
  else
  begin
    if c1.chan<c2.chan then
    begin
      result:=-1;
    end
    else
      result:=0;
  end;
end;

function ChanKeyComparator(p1,p2:pointer):integer;
var
  c:cchan;
  v:integer;
begin
  v:=integer(p2^);
  c:=cchan(p1);
  if v>c.chan then
    result:=-1
  else
  begin
    if v<c.chan then
    begin
      result:=1;
    end
    else
      result:=0;
  end;
end;


constructor cChan.create;
begin
  inherited;
  helper:=false;
  CreateTicks(c_ArrayTicks);
  imageindex:=c_Hardware_img;
  objtype:=c_chan;
end;

constructor cChan.create(ticksType:integer);
begin
  inherited create;
  helper:=false;
  CreateTicks(ticksType);
  imageindex:=c_Hardware_img;
  objtype:=c_chan;
end;

destructor cChan.destroy;
begin
  ticks.destroy;
  ticks:=nil;
  inherited;
end;

function cChan.SupportedChildClass(obj:cbaseobj):boolean;
begin
  result:=false;
end;

function cChan.SupportedChildClass(classname:string):boolean;
begin
  result:=false;
end;

function cChan.SupportedChildClass(objtype:integer):boolean;
begin
  result:=false;
end;

procedure cChan.setchan(b:integer);
begin
  fchan:=b;
  name:=name+inttostr(b);
end;

function cChan.ticksCount:integer;
begin
  result:=ticks.Count;
end;

procedure cChan.CreateTicks(ticktype:integer);
begin
  if ticks<>nil then
  begin
    ticks.destroy;
  end;
  case ticktype of
    c_ArrayTicks: ticks:=cArrayTicks.create;
    c_SortedTicks: ticks:=cSortedTicks.create;
  end;
end;

constructor cChanList.create;
begin
  inherited;
  comparator:=ChanComparator;
  keyComparator:=ChanKeyComparator;
end;

constructor cChanObj.create;
begin
  inherited;
  childrens.comparator:=ChanComparator;
  childrens.keyComparator:=ChanKeyComparator;
end;

procedure cChanObj.CreateChildrens;
begin
  childrens:=cChanList.create;
end;



end.
