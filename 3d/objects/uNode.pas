unit
 uNode;

interface
uses MathFunction, uMatrix, OpenGl, Classes, uquat, uSimpleObjects,uCommonTypes;

type

  // ����� ��������� ����� �������� �� ���������������� �������
  cNode = class
  public
    // �������������� ������� ���� (������������ ���� ��� ��������). ��������
    // c������� ����/�������� + ����������� ��������
    restm:matrixgl;
    // ���� �������  
    visible:boolean;
  protected
    fsorted:boolean;  
    // ������� ��������� ������������ ������� ������ ����
    parent:cnode;
    // �������� ������ �� �������� ���� (cmnode-�)
    childrens:TList;
  private
    procedure unLincChild(node:cnode);
    // ����������� �� �������� ���� ��������
    procedure unLincAllChildrens;
    // �������� �������� ����
    procedure addchild(node:cnode);
    procedure updateChildrens;
  protected
    // ������ ������� ���, ���� ��������� � ������� ����������� �� ����������,
    // �� ��������� ������� ���������� ������������� � node. ���� ������������ ��������
    // nil ����� ������� ���� �������� ������������ ��������� �������
    //  �� parentResTm*fTM=nodeTM*fTM
    procedure ChangeWorld(node:cnode);overload;virtual;abstract;
    procedure ChangeWorld(ptm:matrixgl);overload;virtual;abstract;
    // ���������� �������, � ������� �����������
    function GetWorldTM:matrixgl;virtual;abstract;
  public
    function getCopy:cnode;virtual;
    procedure copyTo(node:cnode);virtual;
    procedure copyFrom(node:cnode);virtual;
    Constructor Create(p_parent:cnode);overload;virtual;
    Constructor Create;overload;virtual;
    destructor  destroy;virtual;
    // ����������� �� ��������
    procedure unLinc;
    // ������������ � ����
    procedure LincTo(node:cnode);
    // �������� � restm ��������� ������� ���� � ������� �����������
    procedure SetToWorld;virtual;
    // ����������
    procedure draw(size:single);
    // �������� ���� � ��������� ������� ���������
    Procedure RotateNodeLocalByAxisAngle(a:single;axis:point3);overload;virtual;abstract;
    Procedure RotateNodeLocalByAxisAngle(a:single;x,y,z:single);overload;virtual;abstract;
    // �������� ���� � ������� ������� ��������� ������ ����� world
    Procedure RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:matrixgl);overload;virtual;abstract;
    Procedure RotateNodeInWorldByAxisAngle(a:single;axis:point3;world:cnode);overload;virtual;abstract;
    // ����������� ���� � ��������� �����������
    Procedure MoveNodeLocal(x,y,z:single);overload;virtual;abstract;
    Procedure MoveNodeLocal(v:point3);overload;virtual;abstract;
    // ����������� ���� � ����������� ����
    Procedure MoveNodeInWorld(v:point3;world:matrixgl);overload;virtual;abstract;
    Procedure MoveNodeInWorld(v:point3;world:cnode);overload;virtual;abstract;
    // ������� �������� � ����
    function parentrestm:matrixgl;
    // ��������� ������� (� ���������� ��������)
    function getlocalTM:matrixgl;virtual;
    procedure setlocalTM(m:matrixgl);virtual;abstract;
    procedure SetDir(dir:point3);virtual;abstract;
  protected
    procedure setsorted(b:boolean);
    function getsorted:boolean;
    function getPosition:point3;virtual;abstract;
    procedure setPosition(pos:point3);virtual;abstract;
  public
    // ���� �������� �� ������� ���� ����� ������������� �� ���-� ��������
    property sorted:boolean read getSorted write setsorted;
    // ����������/ �������� ������� � ����
    property position:point3 read getposition write setposition;
  end;

implementation

// ����������� �������� ���� �� ����� ��������
// ������������ ����� ����� ����� ��������� �������� :
//   > 0 : (�������������) Item1 �������� ������ ��� Item2
//     0 : Item1 ����� Item2
//   <0 : (negative) ������ ��� item2
function SortChildrens(Item1 : Pointer; Item2 : Pointer) : Integer;
var
  node1, node2:cnode;
begin
  node1 := cnode(Item1);
  node2 := cnode(Item2);
  // ������ ��������� �����
  if node1.childrens.count > node2.childrens.count then
    Result := 1
  else
    if node1.childrens.count = node2.childrens.count then
      Result := 0
    else Result := -1;
end;

function cNode.getCopy:cnode;
var node:cnode;
begin
  node:=cnode.Create;
  copyto(node);
  result:=node;
end;

procedure cNode.copyto(node:cnode);
begin
  node.visible:=visible;
  node.restm:=restm;
  node.sorted:=sorted;
end;

procedure cnode.copyFrom(node:cnode);
begin
  node.copyto(self);
end;


Constructor cNode.Create(p_parent:cnode);
begin
  Childrens:=tlist.create;
  Childrens.Sort(SortChildrens);  
  lincto(p_parent);
end;

Constructor cNode.Create;
begin
  parent:=nil;
  Childrens:=tlist.create;
  Childrens.Sort(SortChildrens);
end;

destructor cnode.destroy;
begin
  // ���������� ������������� ��������
  unLincAllChildrens;
  // ���������� �� ��������
  unlinc;
  // ���������� ������������� ��������
  Childrens.destroy;
end;

procedure cnode.lincTo(node:cnode);
begin
  node.addchild(self);
end;

procedure cnode.addchild(node:cnode);
begin
  if node.parent<>nil then
  begin
    node.parent.unLincChild(node);
  end;
  node.ChangeWorld(self);
  childrens.Add(node);
  if sorted then
    childrens.Sort(SortChildrens);
end;

procedure cnode.unLincChild(node:cnode);
var i:integer;
begin
  node.changeworld(nil);
  for I := 0 to childrens.Count - 1 do
  begin
    if childrens.Items[i]=node then
    begin
      childrens.Delete(i);
      exit;
    end;
  end;
end;

procedure cnode.unLinc;
begin
  if parent<>nil then
    self.parent.unLincChild(self);
end;

procedure cnode.unLincAllChildrens;
begin
  while childrens.count<>0 do
  begin
    cnode(childrens.Items[0]).unLinc;
  end;
end;

procedure cnode.updateChildrens;
var i:integer;
begin
  for I := 0 to childrens.Count - 1 do
  begin
    cnode(childrens.items[i]).SetToWorld;
  end;
end;

procedure cnode.SetToWorld;
begin
  GetWorldTM;
  updatechildrens;
end;


procedure cnode.setsorted(b:boolean);
begin
  fsorted:=b;
  if b then
    childrens.Sort(SortChildrens);
end;

function cnode.getsorted:boolean;
begin
  result:=fsorted;
end;

procedure cnode.draw(size:single);
begin
  if visible then
    DrawBox(size,restm);
end;

function cnode.parentrestm:matrixgl;
begin
  if parent<>nil then
    result:=parent.restm
  else
    result:=identmatrix4;
end;

function cnode.getlocalTM:matrixgl;
begin
  result:=evalrightmatrix(parentrestm,restm);
end;

end.
