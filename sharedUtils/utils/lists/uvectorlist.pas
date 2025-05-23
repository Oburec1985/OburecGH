// ������ ������� ������� (��������������� ������) �������������� ������� �������
unit uVectorList;

interface
uses
  Windows, SysUtils, Classes, uListMath;
type

  fcomparator = function (p1,p2:pointer):integer;

  cVectorList = class;

  cVectorObj = class
    pointer:tobject;
    parentList:cVectorList;
  protected
    procedure setKey(k:pointer);virtual;abstract;
  public
    // ����������� �������� ���� �� ����� ��������
    // ������������ ����� ����� ����� ��������� �������� :
    //   > 0 : (�������������) ������ ��� k
    //     0 : key ����� k
    //   <0 : (negative) ������ ��� k
    function compare(k:cVectorObj):integer;overload;virtual;
    function compare(k:pointer):integer;overload;virtual;
    destructor destroy(destroyData:boolean);
    constructor create;virtual;
  end;

  cTPointVectorObj = class(cVectorObj)
  public
    key:tpoint;
  protected
    procedure setKey(k:pointer);override;
  public
    procedure setTPointKey(k: tpoint);
    function compare(k:cVectorObj):integer;overload;override;
    function compare(k:pointer):integer;overload;override;
  end;

  cIntVectorObj = class(cVectorObj)
  public
    key:integer;
  protected
    procedure setKey(k:pointer);override;
  public
    procedure setiKey(k:integer);
    function compare(k:cVectorObj):integer;overload;override;
    function compare(k:pointer):integer;overload;override;
  end;

  cFloatVectorObj = class(cVectorObj)
  public
    key:single;
  protected
    procedure setKey(k:pointer);override;
  public
    procedure setfKey(k:single);
    function compare(k:cVectorObj):integer;overload;override;
    function compare(k:pointer):integer;overload;override;
  end;

  cVectorList = class(TList)
  public
    // ���� ���������� ��������� ������
    fDelData:tNotifyEvent;
    destroydata:boolean;
    // ������� ������� ��������� ���������� ������������ ����������
  private
    fsorted:boolean;
  protected
    fCustomSort:fcomparator;
    useCustomSort:boolean;
  private
    procedure setsorted(value:boolean);
    function getsorted:boolean;
    procedure SortChildrens;
  protected

  public
    procedure CustomSort(SortProc:fcomparator);
    constructor create;virtual;
    destructor destroy;virtual;
    function createObj:cVectorObj;virtual;abstract;
    // ������� ������ �� ����� �� ������. ���������� ������ � �������
    function deleteobj(key:pointer):tobject;
    function deleteIndObj(index:integer):tobject;
    // ���������� ������ ���������� ������� ��� -1
    function GetIndex(key:pointer):integer;
    // ����� ��������� ������ ����� �� �����
    function GetLow(key:pointer;var index:integer):tobject;
    // ����� ��������� ������ ������ �� �����
    function GetHight(key:pointer; var index:integer):tobject;
    function findObj(key:pointer;var index:integer):tobject;overload;
    function findObj(key:pointer):tobject;overload;
    function AddObject(key:pointer;obj:tobject):integer;
    function getNode(i:integer):cVectorobj;
    function getObj(i:integer):tobject;
    procedure clear;
    property sorted:boolean read getsorted write setsorted;
  end;

  cIntVectorList = class(cVectorList)
  public
    function createObj:cVectorObj;override;
  end;

  cTPointVectorList = class(cVectorList)
  public
    function createObj:cVectorObj;override;
  end;

  cFloatVectorList = class(cVectorList)
  public
    function createObj:cVectorObj;override;
  end;

function comparetpoint(p1,p2:tpoint):integer;

implementation


constructor cVectorObj.create;
begin
  inherited;
end;

destructor cVectorObj.destroy(destroydata:boolean);
begin
  if destroyData then
  begin
    if assigned(parentlist.fDelData) then
      parentlist.fDelData(pointer)
    else
    begin
      if pointer<>nil then
        pointer.destroy;
    end;
  end;
  inherited destroy;
end;

function cVectorObj.compare(k:cVectorObj):integer;
begin
  result:=parentlist.fCustomSort(self,k);
end;

function cVectorObj.compare(k:pointer):integer;
begin
  result:=parentlist.fCustomSort(pointer,k);
end;

function cIntVectorObj.compare(k:cVectorObj):integer;
begin
  if parentlist<>nil then
  begin
    if parentList.useCustomSort then
    begin
      result:=inherited compare(k);
      exit;
    end
  end;
  // ������ ��������� �����
  if key > cIntVectorObj(k).key then
    Result := 1
  else
    if key = cIntVectorObj(k).key then
      Result := 0
    else Result := -1;
end;

function cIntVectorObj.compare(k:pointer):integer;
begin
  if parentlist<>nil then
  begin
    if parentList.useCustomSort then
    begin
      result:=inherited compare(k);
      exit;
    end
  end;
  // ������ ��������� �����
  if key > integer(k^) then
    Result := 1
  else
    if key = integer(k^) then
      Result := 0
    else
      Result := -1;
end;

procedure cIntVectorObj.setKey(k:pointer);
begin
  key:=integer(k^);
end;

procedure cIntVectorObj.setiKey(k:integer);
begin
  setkey(@k);
end;

function comparetpoint(p1,p2:tpoint):integer;
begin
  if p1.x>p2.x then
  begin
    result:=1;
  end
  else
  begin
    if p1.x<p2.x then
    begin
      result:=-1;
    end
    else
    begin
      if p1.y>p2.y then
      begin
        result:=1;
      end
      else
      begin
        if p1.y<p2.y then
        begin
          result:=-1;
        end
        else
        begin
          result:=0;
        end;
      end;
    end;
  end;
end;

{ cTPointVectorObj }
function cTPointVectorObj.compare(k: pointer): integer;
begin
  if parentlist<>nil then
  begin
    if parentList.useCustomSort then
    begin
      result:=inherited compare(k);
      exit;
    end
  end;
  // ������ ��������� �����
  result:=comparetpoint(key, tpoint(k^));
end;

function cTPointVectorObj.compare(k: cVectorObj): integer;
begin
  if parentlist<>nil then
  begin
    if parentList.useCustomSort then
    begin
      result:=inherited compare(k);
      exit;
    end
  end;
  // ������ ��������� �����
  result:=comparetpoint(key, cTPointVectorObj(k).key);
end;

procedure cTPointVectorObj.setKey(k:pointer);
begin
  key:=tpoint(k^);
end;

procedure cTPointVectorObj.setTPointKey(k:tpoint);
begin
  setkey(@k)
end;




procedure cFloatVectorObj.setfKey(k:single);
begin
  setkey(@k);
end;

procedure cFloatVectorObj.setKey(k:pointer);
begin
  key:=single(k^);
end;

function cFloatVectorObj.compare(k:cVectorObj):integer;
begin
  if parentlist<>nil then
  begin
    if parentList.useCustomSort then
    begin
      result:=inherited compare(k);
      exit;
    end
  end;
  // ������ ��������� �����
  if key > cFloatVectorObj(k).key then
    Result := 1
  else
    if key = cFloatVectorObj(k).key then
      Result := 0
    else Result := -1;
end;

function cFloatVectorObj.compare(k:pointer):integer;
begin
  if parentlist<>nil then
  begin
    if parentList.useCustomSort then
    begin
      result:=inherited compare(k);
      exit;
    end
  end;
  // ������ ��������� �����
  if key > single(k^) then
    Result := 1
  else
    if key = single(k^) then
      Result := 0
    else Result := -1;
end;

{ cTPointVectorList }
function cTPointVectorList.createObj: cVectorObj;
begin
  result:=ctpointvectorobj.Create;
  result.parentList:=self;
end;

function cIntVectorList.createObj:cVectorObj;
begin
  result:=cintvectorobj.Create;
  result.parentList:=self;
end;

function cFloatVectorList.createObj:cVectorObj;
begin
  result:=cFloatVectorObj.Create;
  result.parentList:=self;
end;

function Comparator(p1,p2:pointer):integer;
var
  obj1, obj2:cVectorObj;
begin
  obj1 := cVectorObj(p1);
  obj2 := cVectorObj(p2);
  // ������ ��������� �����
  result:=obj1.compare(obj2);
end;

constructor cVectorList.create;
begin
  inherited;
  fsorted:=true;
  destroydata:=true;
end;

destructor cVectorList.destroy;
var i:integer;
begin
  for I := 0 to count - 1 do
  begin
    getNode(i).destroy(destroydata);
  end;
  inherited;
end;

function cVectorList.getObj(i:integer):tobject;
begin
  result:=nil;
  if i>=count then exit;
  result:=tobject(getnode(i).pointer);
end;

function cVectorList.getNode(i:integer):cVectorObj;
begin
  result:=cVectorObj(items[i]);
end;

procedure cVectorList.CustomSort(SortProc:fcomparator);
begin
  useCustomSort:=true;
  fCustomSort:=sortproc;
end;

procedure cVectorList.setsorted(value:boolean);
begin
  fsorted:=value;
  if fsorted=true then
    SortChildrens;
end;

function cVectorList.getsorted:boolean;
begin
  result:=fsorted;
end;

procedure cVectorList.SortChildrens;
begin
  Sort(Comparator);
end;

function cVectorList.AddObject(key:pointer;obj:tobject):integer;
var i:integer;
    vectorobj:cVectorObj;
begin
  vectorobj:=createObj;
  vectorobj.pointer:=obj;
  vectorobj.setkey(key);
  if sorted then
  begin
    // ������� ������ ���� ��������� ������
    i:=FindInListLowBound(self,vectorobj,comparator);
    if (count<>0) then
    begin
      if i=0 then
      begin
        if getnode(i).compare(key)=1 then
        begin
          insert(i,vectorobj);
          result:=i;
        end
        else
        begin
          insert(i+1,vectorobj);
          result:=i+1;
        end;
      end
      else
      begin
        if (i+1)=count then
        begin
          add(vectorobj);
          result:=i+1;
        end
        else
        begin
          insert(i+1,vectorobj);
          result:=i+1;
        end;
      end;
    end
    else
    begin
      add(vectorobj);
      result:=0;
    end;
  end
  else
  begin
    add(vectorobj);
    result:=count-1;
  end;
end;

function cVectorList.deleteIndObj(index:integer):tobject;
var
  vectorobj:cvectorobj;
begin
  vectorobj:=getNode(index);
  // ��������� ������ �� ������
  self.Delete(index);
  // ���������� ������
  result:=vectorobj.pointer;
  // ������� ��������������� ������
  vectorobj.Destroy(destroydata);
end;

function cVectorList.deleteobj(key:pointer):tobject;
var i:integer;
    vectorobj:cvectorobj;
begin
  vectorobj:=createObj;
  vectorobj.setkey(key);
  i:=FindInListLowBound(self,vectorobj,comparator);
  vectorobj.Destroy(false);
  vectorobj:=getNode(i);
  if vectorobj.compare(key)=0 then
  begin
    // ��������� ������ �� ������
    self.Delete(i);
    // ���������� ������
    result:=vectorobj.pointer;
    // ������� ��������������� ������
    vectorobj.Destroy(destroydata);
  end;
end;

function cVectorList.GetLow(key:pointer;var index:integer):tobject;
var i:integer;
    vectorobj:cvectorobj;
begin
  result:=nil;
  if count<>0 then
  begin
    vectorobj:=createObj;
    vectorobj.setkey(key);
    i:=FindInListLowBound(self,vectorobj,comparator);
    vectorobj.Destroy(destroydata);
    vectorobj:=getNode(i);
    index:=i;
    if i=0 then
    begin
      if vectorobj.compare(key)=1 then
      begin
        result:=nil;
        exit;
      end
      else
        result:=vectorobj.pointer;
    end
    else
    begin
      if vectorobj.compare(key)<=0 then
      begin
        result:=vectorobj.pointer;
        exit;
      end;
    end;
  end;
end;

function cVectorList.GetHight(key:pointer; var index:integer):tobject;
var i:integer;
    vectorobj:cvectorobj;
begin
  result:=nil;
  if count<>0 then
  begin
    vectorobj:=createObj;
    vectorobj.setkey(key);
    i:=FindInListHiBound(self,vectorobj,comparator);
    index:=i;
    vectorobj.Destroy(destroydata);
    vectorobj:=getNode(i);
    if i=0 then
    begin
      if vectorobj.compare(key)=-1 then
      begin
        result:=vectorobj.pointer;
        exit;
      end;
    end
    else
    begin
      if vectorobj.compare(key)=1 then
      begin
        result:=vectorobj.pointer;
        exit;
      end;
    end;
  end
  else
  begin
    index:=0;
  end;
end;

function cVectorList.findObj(key:pointer):tobject;
var i:integer;
begin
  result:=findobj(key,i);
end;

function cVectorList.findObj(key:pointer;var index:integer):tobject;
var i:integer;
    vectorobj:cvectorobj;
begin
  index:=-1;
  result:=nil;
  if count<>0 then
  begin
    vectorobj:=createObj;
    vectorobj.setkey(key);
    i:=FindInListLowBound(self,vectorobj,comparator);
    vectorobj.Destroy(destroydata);
    vectorobj:=getNode(i);
    if vectorobj.compare(key)=0 then
    begin
      index:=i;
      result:=vectorobj.pointer;
      exit;
    end
    else
    begin
      if (i+1)<count then
      begin
        vectorobj:=getNode(i+1);
        if vectorobj.compare(key)=0 then
        begin
          index:=i+1;
          result:=vectorobj.pointer;
          exit;
        end
      end;
    end;
  end;
end;

function cVectorList.GetIndex(key:pointer):integer;
var i:integer;
    vectorobj:cvectorobj;
begin
  result:=-1;
  if count<>0 then
  begin
    vectorobj:=createObj;
    vectorobj.setkey(key);
    i:=FindInListLowBound(self,vectorobj,comparator);
    if vectorobj.compare(key)=0 then
      result:=i
    else
    begin
      if getnode(i+1).compare(key)=0 then
        result:=i+1;
    end;
    vectorobj.destroy(false);
  end;
end;

procedure cVectorList.clear;
var
  vectorobj:cvectorobj;
  i:integer;
begin
  while count<>0 do
  begin
    deleteIndObj(0);
  end;
end;

end.
