unit uSetList;
// �����

interface

uses classes, uListMath, dialogs, ucommonmath, uqueue;

type

  cSetList = class(TList)
  public
    destroydata:boolean;
    // ���������� ��� �������
    comparator:fcomparator;
    // ���������� ���� � ��������
    // ������ - ����
    keyComparator:fcomparator;
  protected
    fsorted:boolean;
  protected
    procedure setsorted(value:boolean);virtual;
    function getsorted:boolean;
    procedure SortChildrens;
  public
    function AddObj(key:pointer):integer;virtual;
    procedure deletechild(node:pointer);overload;virtual;abstract;
    // ����� ����������� ����������
    procedure deletechild(index:integer);overload;virtual;
    procedure setComparator(c:fcomparator);
    // ������� ������ �� ������
    procedure RemoveObj(index:integer);overload;virtual;
    procedure RemoveObj(obj:tobject);overload;
    // ���������� ������ ���������� ������� ��� -1
    function GetIndex(key:pointer):integer;
    // ����� ��������� ������ ����� �� �����
    function GetLow(key:pointer;var index:integer):pointer;
    // ����� ��������� ������ ������ �� �����
    function GetHight(key:pointer; var index:integer):pointer;
    function getNode(i:integer):pointer;
    // ����� ������ ���������� �� �����
    function Findobj(key:pointer):integer;overload;
    // ����� ������ �� �������� ����� (������ ����� � �.�.)
    function FindobjWithKey(key:pointer):integer;
    // ����� ������ ������� ���������� � ����� ������
    function FindFirstNode(key:pointer):integer;
    // �������� ������ ���� destroydata=true
    procedure Listclear;
    property sorted:boolean read getsorted write setsorted;
 public
    // ��� ������� ������������������� ���-� ���������� �������������� ����������� �������
    // � ��������� ����������
    constructor create;virtual;
    destructor destroy;virtual;
  end;

  // ������ ��������������� �� ���������.
  cSelectList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
  end;

  cIntList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
    procedure addObj(k:integer);
    function GetInteger(i:integer):integer;
    function DelInteger(i:integer):integer;
  end;


  cDoubleList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
    procedure addObj(d:Double);
    function GetDouble(i:integer):double;
    function DelDouble(i:integer):double;
  end;

  cIDObj = class
  protected
    m_name:string;
    m_id:cardinal;
  public
    constructor create(p_name:string; p_id:cardinal);
  end;

  cIDList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
    procedure AddID(p_name:string; key:cardinal);
    function GetIDName(key:cardinal):string;
    procedure DestroyObj(key:cardinal);
  end;

  cIntNode = class
  public
    i:integer;
    d:pointer;
  end;

  cIntNodeList = class(cSetList)
  protected
    procedure deletechild(node:pointer);override;
  public
    constructor create;override;
    function addObj(i:integer; d:pointer):integer;
  end;



implementation
uses
  uBaseObj, uEventList;

constructor cSetList.create;
begin
  inherited;
  //comparator:=nil;
  fsorted:=true;
  destroydata:=true;
end;

destructor cSetList.destroy;
var
  i:integer;
begin
  Listclear;
  inherited;
end;

procedure cSetList.setComparator(c:fcomparator);
begin
  comparator:= c;
  SortChildrens;
end;

function cSetList.getNode(i:integer):pointer;
begin
  result:=(items[i]);
end;

function cSetList.FindObj(key:pointer):integer;
var i:integer;
    node:pointer;
begin
  result:=-1;
  if count<>0 then
  begin
    i:=FindInListLowBound(self,key,comparator);
    node:=getNode(i);
    if comparator(node,key)=0 then
    begin
      result:=i;
      exit;
    end
    else
    begin
      if (i+1)<count then
      begin
        node:=getNode(i+1);
        if comparator(node,key)=0 then
        begin
          result:=i+1;
          exit;
        end
      end;
    end;
  end;
end;

function cSetList.FindFirstNode(key:pointer):integer;
var
  i:integer;
  node:pointer;
begin
  result:=-1;
  GetLow(key,result);
  while result>0 do
  begin
    node:=getNode(result-1);
    if comparator(node,key)=0 then
    begin
      dec(result);
    end
    else
      break;
  end;
end;

procedure cSetList.setsorted(value:boolean);
begin
  fsorted:=value;
  if fsorted=true then
    SortChildrens;
end;

function cSetList.getsorted:boolean;
begin
  result:=fsorted;
end;

procedure cSetList.SortChildrens;
begin
  Sort(Comparator);
end;

function cSetList.AddObj(key:pointer):integer;
var
  i,j, res:integer;
  b:boolean;
  node:pointer;
begin
  if key=nil then
  begin
    result:=-1;
    exit;
  end;
  if sorted then
  begin
    // ������� ������ ���� ��������� ������
    i:=FindInListLowBound(self,key,comparator);
    b:=true;
    j:=i;
    while b do
    begin
      if j<count then
      begin
        node:=getnode(j);
      end
      else
        break;
      res:=comparator(node,key);
      if res=0 then
      begin
        if node=key then
          exit;
      end;
      b:=(res<1);
      inc(j);
    end;
    if (count<>0) then
    begin
      if i=0 then
      begin
        node:=getnode(i);
        if comparator(node,key)=1 then
        begin
          insert(i,key);
        end
        else
        begin
          inc(i);
          insert(i,key);
        end;
        result:=i;
      end
      else
      begin
        if (i+1)=count then
        begin
          add(key);
          result:=Count;
        end
        else
        begin
          inc(i);
          insert(i,key);
          result:=i;
        end;
      end;
    end
    else
    begin
      add(key);
      result:=count;
    end;
  end
  else
  begin
    add(key);
    result:=count;
  end;
end;

procedure cSetList.deletechild(index:integer);
var
  node:pointer;
begin
  node:=getNode(index);
  // ��������� ������ �� ������
  Delete(index);
  if destroydata then
    deletechild(node)
end;


procedure cSetList.RemoveObj(index:integer);
//var
  //node:pointer;
begin
  //node:=getNode(index);
  // ��������� ������ �� ������
  Delete(index);
end;

procedure cSetList.RemoveObj(obj:tobject);
var
  i:integer;
begin
  i:=Findobj(obj);
  if i<>-1 then
  begin
    if getNode(i)=obj then
      RemoveObj(i);
  end;
end;

function cSetList.GetLow(key:pointer;var index:integer):pointer;
var i:integer;
    node:pointer;
begin
  result:=nil;
  index:=-1;
  if count<>0 then
  begin
    i:=FindInListLowBound(self,key,comparator);
    node:=getNode(i);
    index:=i;
    if i=0 then
    begin
      // ���� ������ ������� ������
      if comparator(node,key)=1 then
      begin
        result:=nil;
        exit;
      end
      else
        result:=node;
    end
    else
    begin
      if comparator(node,key)<=0 then
      begin
        result:=node;
        exit;
      end;
    end;
  end;
end;

function cSetList.GetHight(key:pointer; var index:integer):pointer;
var i:integer;
    node:pointer;
begin
  result:=nil;
  if count<>0 then
  begin
    i:=FindInListHiBound(self,key,comparator);
    index:=i;
    node:=getNode(i);
    if i=0 then
    begin
      if comparator(node,key)=-1 then
      begin
        if (i+1)=count then
        begin
          result:=nil;
          index:=-1;
        end
        else
        begin
          result:=getNode(i+1);
          exit;
        end;
      end
      else
      begin
        result:=node;
      end;
    end
    else
    begin
      result:=node;
      if comparator(node,key)=1 then
      begin
        result:=node;
        exit;
      end;
    end;
  end;
end;

function cSetList.GetIndex(key:pointer):integer;
begin
  result:=findobj(key);
end;

procedure cSetList.listclear;
var
  i:integer;
begin
  if destroydata then
  begin
    while count<>0 do
    begin
      deletechild(0);
    end;
  end
  else
  begin
    clear;
  end;
end;

function cSetList.FindobjWithKey(key:pointer):integer;
var
  res:integer;
begin
  if count=0 then
  begin
    result:=-1;
    exit;
  end;
  result:=FindInListLowBound(self,key,keyComparator);
  if keyComparator(getNode(Result),key)=0 then
  begin
    exit;
  end
  else
  begin
    while result<count-1 do
    begin
      inc(result);
      // ������ ������ �� ��������� ������ ������ ������ �� �����
      res:=keyComparator(getNode(Result),key);
      if res=1 then
      begin
        result:=-1;
        exit;
      end
      else
      begin
        // ����� ������
        if res=0 then
        begin
          exit;
        end
      end;
    end;
  end;
  result:=-1;
end;


constructor cIDObj.create(p_name:string; p_id:cardinal);
begin
  m_name:=p_name;
  m_id:=p_id;
end;

procedure cIDList.AddID(p_name: string; key: Cardinal);
var
  id:cIDObj;
begin
  id:=cIDObj.Create(p_name, key);
  AddObj(id);
end;

function IdComparator(p1,p2:pointer):integer;
begin
  if cIDObj(p1).m_id>cIDObj(p2).m_id then
  begin
    result:=1;
  end
  else
  begin
    if cIDObj(p1).m_id<cIDObj(p2).m_id then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;


constructor cIDList.create;
begin
  inherited;
  comparator:=IDComparator;
  destroydata:=true;
end;

function cIDList.GetIDName(key:cardinal):string;
var
  ind:integer;
  id:cidobj;
  lId:cidobj;
begin
  lId:=cIDobj.create('Key',key);
  ind:=Findobj(lId);
  id:=cIDObj(getnode(ind));
  if id<>nil then
  begin
    result:=id.m_name;
  end
  else
    result:='';
  lID.Destroy;
end;

procedure cIDList.DestroyObj(key:cardinal);
var
  ind:integer;
  id,lID:cIDObj;
begin
  lID:=cIDObj.create('Key', key);
  ind:=Findobj(lID);
  id:=cidobj(getnode(ind));
  Delete(ind);
  id.Destroy;
  lID.Destroy;
end;

procedure cIDList.deletechild(node:pointer);
begin
  cidobj(node).destroy;
end;


function IntComparator(p1,p2:pointer):integer;
begin
  if integer(p1^)>integer(p2^) then
  begin
    result:=1;
  end
  else
  begin
    if integer(p1^)<integer(p2^) then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;


constructor cIntList.create;
begin
  inherited;
  comparator:=IntComparator;
  destroydata:=true;
end;

procedure cIntList.addObj(k:integer);
var
  p:pinteger;
begin
  if Findobj(@k)=-1 then
  begin
    getmem(p,sizeof(integer));
    p^:=k;
    Add(p);
  end;
end;

function cIntList.GetInteger(i:integer):integer;
begin
  result:=integer(items[i]^);
end;

function cIntList.DelInteger(i:integer):integer;
begin
  RemoveObj(i);
end;

procedure cIntList.deletechild(node:pointer);
begin
  FreeMem(node,sizeof(integer));
end;


{ cDoubleList }

function DoubleComparator(p1,p2:pointer):integer;
begin
  if Double(p1^)>Double(p2^) then
  begin
    result:=1;
  end
  else
  begin
    if Double(p1^)<Double(p2^) then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

procedure cDoubleList.addObj(d: Double);
var
  p:pDouble;
begin
  if Findobj(@d)=-1 then
  begin
    getmem(p,sizeof(double));
    p^:=d;
  end;
  inherited AddObj(p);
end;

constructor cDoubleList.create;
begin
  inherited;
  comparator:=DoubleComparator;
  destroydata:=true;
end;

procedure cDoubleList.deletechild(node: pointer);
begin
  FreeMem(node,sizeof(double));
end;

function cDoubleList.DelDouble(i: integer): double;
begin
  RemoveObj(i);
end;

function cDoubleList.GetDouble(i: integer): double;
begin
  result:=Double(items[i]^);
end;

function IDSelectListComparator(p1,p2:pointer):integer;
begin
  if cardinal(p1)>cardinal(p2) then
  begin
    result:=1;
  end
  else
  begin
    if cardinal(p1)<cardinal(p2) then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

constructor cSelectList.create;
begin
  inherited;
  comparator:=IDSelectListComparator;
  destroydata:=false;
end;

procedure cSelectList.deletechild(node:pointer);
begin
  tobject(node).destroy;
end;


{ cIntNodeList }

function IntNodeComparator(p1,p2:pointer):integer;
begin
  if cIntNode(p1).i>cIntNode(p2).i then
  begin
    result:=1;
  end
  else
  begin
    if cIntNode(p1).i<cIntNode(p2).i then
    begin
      result:=-1;
    end
    else
    begin
      result:=0;
    end;
  end;
end;

function cIntNodeList.addObj(i: integer; d: pointer):integer;
var
  n:cIntNode;
begin
  n:=cIntNode.Create;
  result:=Add(n);
end;

constructor cIntNodeList.create;
begin
  inherited;
  destroydata:=true;
  comparator:=IntNodeComparator;
end;

procedure cIntNodeList.deletechild(node: pointer);
begin
  cIntNode(node).destroy;
end;

end.
