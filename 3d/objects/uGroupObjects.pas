unit uGroupObjects;

interface
  uses Classes, sysutils, uNodeObject, uObjectTypes,uobject,umatrix, mathfunction,
  forms, u3dtypes;

type
  enumProc = procedure(obj:cnodeobject;data:pointer);

// ������������� ������ obj � ������� � ������� ������ ������ groupObject
procedure GroupTo(obj,groupObject:cNodeObject);
// �������� ������� ������ ������
function GetGroupLeader(groupObject:cNodeObject):cNodeObject;
// ������� ������� ������
procedure SetGroupState(groupObject:cNodeObject;state:boolean);
// ������� ������� ������
function GetGroupState(groupObject:cNodeObject):boolean;
// �������� BoundingBox ������
function GetGroupBound(groupObject:cnodeobject):tbound;
// �������� �� ���� ������ ������ ������� ��������� proc
procedure EnumGroupMembers(groupObject:cnodeobject;proc:enumProc;data:pointer);
// ������� ��� ������. ������ ���������� ���������� ����� �� ������� ��������� ������
procedure DeleteGroup(groupObject:cNodeObject);
// �������� ������ ��������
function copygroup(obj:cnodeobject):cnodeobject;

implementation

uses
  //unodetreelist,
  uSceneMng;

procedure EnumGroupMembers(groupObject:cnodeobject;proc:enumProc;data:pointer);
var i:integer;
    obj:cnodeobject;
begin
  groupObject:=GetGroupLeader(groupObject);
  for I := 0 to groupObject.childrens.Count - 1 do
  begin
    obj:=pointer(groupObject.childrens.getObj(i));
    if obj.group then
    begin
      proc(obj,data);
    end;
  end;
end;

function GetGroupLeader(groupObject:cNodeObject):cNodeObject;
var parent:cnodeobject;
begin
  if not groupobject.group then
  begin
    result:=groupobject;
    exit;
  end;
  if groupObject.groupHeader then
  begin
    result:=groupObject;
    exit;
  end;
  parent:=cnodeObject(groupObject.parent);
  while not parent.groupHeader do
  begin
    parent:=cnodeobject(parent.parent);
    if parent=nil then
    begin
      result:=nil;
    end;
  end;
  result:=parent;
end;

procedure SetGroupState(groupObject:cNodeObject;state:boolean);
begin
  groupObject:=GetGroupLeader(groupObject);
  groupObject.groupclosed:=state;
end;

function GetGroupState(groupObject:cNodeObject):boolean;
begin
  if groupobject.group then
  begin
    groupObject:=GetGroupLeader(groupObject);
    result:=groupObject.groupclosed;
  end
  else
    result:=false;
end;

procedure GroupTo(obj,groupObject:cNodeObject);
var parent:cnodeobject;
begin
  // ���� ������ �� � ������
  if not groupObject.group then
  begin
    groupObject.group:=true;
    groupObject.groupHeader:=true;
    obj.group:= true;
    obj.parent:= groupObject;
    cobject(obj.parent).bound:=GetGroupBound(cnodeobject(obj.parent));
    exit;
  end;
  // ���� ������ ����� ������
  if groupObject.groupHeader then
  begin
    obj.parent:= groupObject;
    obj.group:= true;
    cobject(obj.parent).bound:=GetGroupBound(cnodeobject(obj.parent));
    exit;
  end;
  // ���� �������� ���������� � �� ��������� ������� ������
  obj.parent:=GetGroupLeader(groupObject);
  obj.group:=true;
  cobject(obj.parent).bound:=GetGroupBound(cnodeobject(obj.parent));
end;

type
 tdata = class
   bres:tbound;
 end;

procedure GetBoundProc(obj:cobject;data:pointer);
var b:tbound;
    m:matrixgl;
    str:string;
begin
  if not obj.groupHeader then
    m:=evalrightmatrix(cnodeobject(obj.parent).restm,obj.restm)
  else
    m:=identMatrix4;
  b:=MultBoundByM(obj.bound,m);
  if b.lo.x<tdata(data).bres.lo.x then
    tdata(data).bres.lo.x:=b.lo.x;
  if b.lo.y<tdata(data).bres.lo.y then
    tdata(data).bres.lo.y:=b.lo.y;
  if b.lo.z<tdata(data).bres.lo.z then
    tdata(data).bres.lo.z:=b.lo.z;

  if b.hi.x>tdata(data).bres.hi.x then
    tdata(data).bres.hi.x:=b.hi.x;
  if b.hi.y>tdata(data).bres.hi.y then
    tdata(data).bres.hi.y:=b.hi.y;
  if b.hi.z>tdata(data).bres.hi.z then
    tdata(data).bres.hi.z:=b.hi.z;
end;

function GetGroupBound(groupObject:cnodeobject):tbound;
var dat:tdata;
    leader:cnodeobject;
    str:string;
begin
  dat:=tdata.Create;
  // ����������� ��� ������� ������ ������� ��� ���� getboundproc � ��������� �
  // ��� ������ dat ��� ��������� � ������ ���� ������������� bound-�
  EnumGroupMembers(groupObject, @GetBoundProc, dat);
  // �������� ������ ������
  leader:=GetGroupLeader(groupObject);
  result:=dat.bres;
  dat.Destroy;
end;

procedure DeleteGroup(groupObject:cNodeObject);
var
  head,
  obj:cnodeobject;
  i:integer;
begin
  head:=GetGroupLeader(groupObject);
  for I := 0 to head.ChildCount - 1 do
  begin
    obj:=cnodeobject(head.childrens.getobj(0));
    obj.destroy;
  end;
  head.destroy;
end;

function copychild(copyobj:cnodeobject):cnodeobject;
var obj,parent:cnodeobject;
    i:integer;
begin
  parent:=copyobj.getCopy;
  if copyobj.childrens.Count<>0 then
  begin
    for I := 0 to copyobj.childrens.Count - 1 do
    begin
      obj:=copychild(cnodeobject(copyobj.getChild(i)));
      obj.parent:=parent;
    end;
  end;
  result:=parent;
end;

function copygroup(obj:cnodeobject):cnodeobject;
var head:cnodeobject;
begin
  head:=getGroupLeader(obj);
  if head.groupclosed then
  begin
    result:=copychild(head);
  end
  else
    result:=obj.getCopy;
end;

end.
