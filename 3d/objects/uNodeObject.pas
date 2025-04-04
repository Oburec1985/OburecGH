unit uNodeObject;

interface
  uses
  MathFunction, uMatrix, uNode, uObjectTypes,  classes, messages,uCommonTypes,
  uBaseObj, uBaseObjMng,
  dialogs,
  uModList,
  //uNodeTreeList,
  windows,
  ueventlist,
  uMNode,
  uQNode,
  u3dTypes,
  uGlEventTypes
  ;

  const
    e_setObjtoworld = $000001;

type
  cNodeObject = class(cBaseObj)
  // ���� ������� � ��������� ���� �������
  protected
  public
    // ����������� elist ������ �������
    events:ceventlist;
    // ������ ��� �������� �������������
    ModCreator:cModCreator;
    fobjtype:byte;
    // ������ ������ � ������ ------------------------------------
    group:boolean;
    // ������������ ������ � ������-------------------------------
    groupHeader:boolean;
    // ������ �������
    groupclosed:boolean;
    freezObj:boolean;
  public
    Node:cnode;
    LocalNode:cnode;
  public
    constructor Create;override;
    destructor destroy;override;
    // ���������� ��������� �������. ���������� ������ ��������� �������
    procedure SetObjToWorld;virtual;
    // ������ � ����������� ���������
  public
    // ������������ Node ������� � ����
    procedure LincToNode(p_parent:cmNode);
    // ����������� �� �������� unlincChildrens
  public
  public
    // ������������ ������ ��������� ������� ��������
    Procedure RotateMouse(mouse:MouseStruct);// ��������� ������ ������
    Procedure TranslateMouse(mouse:MouseStruct);// ��������� ������ ������
    Procedure TranslateMouseWheel(mouse:MouseStruct);// ��������� ������ ������� ����
    procedure RotateNodeGlobal(p3:point3);overload;
    procedure RotateNodeGlobal(x,y,z:single);overload;
    procedure RotateNodeInParentWorld(p3:point3);
    procedure RotateNodeLocal(p3:point3);overload;
    procedure RotateNodeLocal(x,y,z:single);overload;
    procedure RotateNodeInLocalNodeWorld(p3:point3);
    procedure RotateNodeWorld(p3:point3;world:matrixgl);
    procedure MoveNodeInWorld(p3:point3;world:matrixgl);
    procedure MoveNodeLocal(const x,y,z:single);overload;
    procedure MoveNodeLocal(const p3:point3);overload;
    procedure MoveNodeInParentWorld(const x,y,z:single);
    procedure MoveNodeInLocalNodeWorld(const x,y,z:single);
    procedure UserMoveObj(var msg:tmessage;mouse:MouseStruct);virtual;
  protected
    // ����������� �� ��������
    procedure unLinc;override;
  private
    // ������� ������� ��������� ������� � ������� �����������
    function getResTm:matrixgl;
    function getNodeResTm:matrixgl;
    function getNodeTm:matrixgl;
    procedure setNodeTm(m:matrixgl);
    function getLocalTm:matrixgl;
    procedure setLocalTm(m:matrixgl);
    procedure setParent(p:cBaseObj);override;
    function getPosition:Point3;
    procedure setPosition(newPos:Point3);
  public
    procedure Ungroup;
    function getCopy:cnodeobject;virtual;
    // ����������� ������
    procedure CopyTo(obj:cnodeobject);virtual;
    // ������� ������� ������������ ������������� ������� ��� � ����������� identmatrix ���� �������� ���
    property nodetm:matrixgl read getNodeTm write setNodeTm;
    property nodeResTm:matrixgl read getNodeResTm;
    // ������� ������� � ��������� ������� ��������� (������������ ����)
    property localtm:matrixgl read getLocalTm write setLocalTm;
    // �������������� ������� ������� � ���������� ���� (��������� �������)
    property restm:matrixgl read getResTm;
    // ��� ������� (������ ���� ���������� � �����)
    property name:string read fname write setname;
    // ���������� ��� �������
    property objtype:byte read fobjtype write fobjtype;
    // �������������/ ������ ������� ������� � ���������� ���� (��������� �������)
    // ��� ��������� ����� ������� ������������ �� Node, � �� �� LocalNode
    property position:point3 read getPosition write setPosition;
    // i - ������������� ������� ��������� (local, parent, world, node...)
    function ActiveSystem(i:integer):matrixgl;
  end;

    const
      useQuat = false;

implementation
uses
  ubasedeformer,
  uBaseModificator,
  uRender,
  uSceneMng,
  uGroupObjects;


function cNodeObject.ActiveSystem(i:integer):matrixgl;
var camera:cnodeobject;
    m:matrixgl;
begin
  case i of
    constWorld: m:=GetTranslateMatrix4(identmatrix4,Node.restm);
    constNode:
    begin
      m:=Node.restm;
    end;
    constLocal:
    begin
      m:=GetTranslateMatrix4(restm, Node.restm);
    end;
    constParent:
    begin
      m:=GetTranslateMatrix4(cnodeobject(parent).restm, Node.restm);
    end;
    constView:
    begin
      camera:=cRender(cscene(getmng).render).activecamera;
      if camera<>nil then
        m:=GetTranslateMatrix4(camera.restm, Node.restm);
    end;
  end;
  result:=m;
end;

 procedure cNodeObject.Ungroup;
var
  head,obj:cnodeobject;
  i:integer;
begin
  head:=GetGroupLeader(self);
  head.group:=false;
  head.groupHeader:=false;
  for I := 0 to head.ChildCount - 1 do
  begin
    obj:=cnodeobject(head.childrens.getobj(0));
    obj.unLinc;
    if cscene(obj.getmng).World<>nil then
      obj.parent:=cscene(obj.getmng).World;
    obj.group:=false;
  end;
end;

constructor cNodeObject.Create;
begin
  inherited create;

  if useQuat then
    Node:= cqNode.create
  else
    Node:= cmNode.create;

  events:=cEventList.create(self,true);
  ModCreator:=cModCreator.create(self);
  if useQuat then
    localnode:= cqnode.Create(node)
  else
    localnode:= cmnode.Create(node);
  fobjtype:= constNodeObject;

  group:= false;
  groupHeader:= false;
  groupclosed:=true;
  fhelper:=True;
  autocreate:=true;
  freezObj:=false;

  setobjtoworld;
end;

destructor cNodeObject.destroy;
var
  obj:cnodeobject;
  index:integer;
begin
  ModCreator.destroy;
  ModCreator:=nil;
  events.destroy;
  events:=nil;
  if groupHeader then
  begin
    //unGroup(self);
  end;
  // ������� ���� �������, � �������� ���������� ���������� ����. �� ������ �����
  node.destroy;
  node:=nil;
  localnode.destroy;
  localnode:=nil;
  //cnodetreelist(m_childrens).Destroy;
  inherited;
end;

procedure cNodeObject.SetObjToWorld;
var
  i:integer;
  def:cBaseModificator;
begin
  Node.SetToWorld;
  // � ������ ������ ������ ��������� ������ � ������� � �� � ���������.
  // (���� �� ���� ������ ������� ��� �������� ����� (��������))
  events.CallAllEvents(e_setObjtoworld);
  for I := 0 to ChildCount - 1 do
  begin
    cnodeobject(getChild(i)).events.CallAllEvents(e_setObjtoworld);
  end;
  if getmng<>nil then
  begin
    cBaseObjMng(getmng).Events.CallAllEvents(e_setObjtoworld);
    //for I := 0 to ChildCount - 1 do
    //begin
    //  cBaseObjMng(getmng).events.CallAllEvents(e_setObjtoworld);
    //end;
  end;
  for I := 0 to ModCreator.Count - 1 do
  begin
    def:=ModCreator.getitem(i);
    case def.modtype of
      constBaseDeformer:
      begin
        def.apply;
      end;
    end;
  end;
end;

procedure cNodeObject.unLinc;
begin
  if node<>nil then
    node.unlinc;
  inherited;
end;

procedure cNodeObject.LincToNode(p_parent:cmNode);
begin
  node.lincto(p_parent);
end;

function cNodeObject.GetCopy:cnodeobject;
var obj:cnodeobject;
begin
  obj:=cnodeobject.Create;
  obj.setMng(getmng);
  copyto(obj);
  result:=obj;
end;

procedure cNodeObject.CopyTo(obj:cnodeobject);
begin
  obj.fname:=fname;
  obj.fobjtype:=fobjtype;
  obj.fHelper:=fHelper;
  obj.group:=group;
  obj.groupHeader:=groupheader;
  obj.groupclosed:=groupclosed;
  obj.Node.copyFrom(node);
  // �.�. ����� ����������� ��� ��� �� ����� ��������, ���������� ���������
  // ��� � ����� ��������� ���� �� � ������� ����������� (�������� ���� �����
  // ���������� �������� � ������������ ������ ��������)
  obj.nodetm:=node.restm;
  //obj.Node.position:=GetPosFromMatrixP3(node.restm);
  obj.LocalNode.copyFrom(localnode);
end;

procedure cNodeObject.setParent(p:cBaseObj);
begin
  unLinc;
  if p=nil then
  begin
    exit;
  end;
  node.LincTo(cNodeObject(p).Node);
  inherited;
end;

function cNodeObject.getResTm:matrixgl;
begin
  result:=localnode.restm;
end;

function cNodeObject.getNodeTm:matrixgl;
begin
  result:=node.getlocaltm;
end;

procedure cNodeObject.setNodeTm(m:matrixgl);
begin
  node.setlocalTM(m);
  SetObjToWorld;
end;

function cNodeObject.getNodeResTm:matrixgl;
begin
  result:=node.restm;
end;

function cNodeObject.getLocalTm:matrixgl;
begin
  result:=localnode.getLocalTm;
end;

procedure cNodeObject.setLocalTm(m:matrixgl);
begin
  localnode.setLocalTm(m);
  SetObjToWorld;  
end;

procedure cNodeObject.MoveNodeInWorld(p3:point3;world:matrixgl);
begin
  node.MoveNodeInWorld(p3,world);
  SetObjToWorld;
end;

procedure cNodeObject.MoveNodeInParentWorld(const x,y,z:single);
var localtm:matrixgl;
    p3:point3;
begin
  localtm:=GetTranslateMatrix4(node.parentrestm,node.restm);
  p3.x:=x;  p3.y:=y;  p3.z:=z;
  MoveNodeInWorld(p3,localtm);
end;

procedure cNodeObject.MoveNodeInLocalNodeWorld(const x,y,z:single);
var localtm:matrixgl;
    p3:point3;
begin
  localtm:=GetTranslateMatrix4(localnode.restm,node.restm);
  p3.x:=x;  p3.y:=y;  p3.z:=z;
  MoveNodeInWorld(p3,localtm);
end;

procedure cNodeObject.RotateNodeLocal(x,y,z:single);
begin
  if x<>0 then
  begin
    node.RotateNodeLocalByAxisAngle(x,axisx);
  end;
  if y<>0 then
  begin
    node.RotateNodeLocalByAxisAngle(y,axisy);
  end;
  if z<>0 then
  begin
    node.RotateNodeLocalByAxisAngle(z,axisz);
  end;
  SetObjToWorld;
end;


procedure cNodeObject.RotateNodeLocal(p3:point3);
begin
  RotateNodeLocal(p3.x, p3.y, p3.z);
end;

procedure cNodeObject.RotateNodeInLocalNodeWorld(p3:point3);
//var world:matrixgl;
begin
  if p3.x<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.x,axisx,localnode);
  end;
  if p3.y<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.y,axisy,localnode);
  end;
  if p3.z<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.z,axisz,localnode);
  end;
  SetObjToWorld;
end;

procedure cNodeObject.RotateNodeInParentWorld(p3:point3);
begin
  if p3.x<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.x,axisx,node.parentrestm);
  end;
  if p3.y<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.y,axisy,node.parentrestm);
  end;
  if p3.z<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.z,axisz,node.parentrestm);
  end;
  SetObjToWorld;
end;

procedure cNodeObject.RotateNodeWorld(p3:point3;world:matrixgl);
begin
  if p3.x<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.x,axisx,world);
  end;
  if p3.y<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.y,axisy,world);
  end;
  if p3.z<>0 then
  begin
    node.RotateNodeInWorldByAxisAngle(p3.z,axisz,world);
  end;
  SetObjToWorld;
end;

procedure cNodeObject.RotateNodeGlobal(x,y,z:single);
begin
  RotateNodeGlobal(p3(x,y,z));
end;

procedure cNodeObject.RotateNodeGlobal(p3:point3);
var world:matrixgl;
begin
  if p3.x<>0 then
  begin
    world:=SetPos(identmatrix4,node.position);
    node.RotateNodeInWorldByAxisAngle(p3.x,axisx,world);
  end;
  if p3.y<>0 then
  begin
    world:=SetPos(identmatrix4,node.position);
    node.RotateNodeInWorldByAxisAngle(p3.y,axisy,world);
  end;
  if p3.z<>0 then
  begin
    world:=SetPos(identmatrix4,node.position);
    node.RotateNodeInWorldByAxisAngle(p3.z,axisz,world);
  end;
  SetObjToWorld;
end;

procedure cNodeObject.RotateMouse(mouse:MouseStruct);
var len:single;
begin
  len:=VectorLength(mouse.m_Strafe);
  NormalizeVectorP3(mouse.m_Strafe);
  Node.RotateNodeLocalByAxisAngle(
       mouse.m_RotSens*len*0.01,
       mouse.m_Strafe.x,
       mouse.m_Strafe.y,
       mouse.m_Strafe.z);
  SetObjToWorld;
end;

procedure cNodeObject.TranslateMouse(mouse:MouseStruct);
begin
  LocalNode.MoveNodeLocal(-mouse.m_MoveSens*mouse.m_Strafe.y,
                     mouse.m_MoveSens*mouse.m_Strafe.x,0);
  SetObjToWorld;
end;

procedure cNodeObject.TranslateMouseWheel(mouse:MouseStruct);
begin

end;

procedure cNodeObject.MoveNodeLocal(const x,y,z:single);
begin
  node.MoveNodeLocal(x,y,z);
  SetObjToWorld;
end;

procedure cNodeObject.MoveNodeLocal(const p3:point3);
begin
  MoveNodeLocal(p3.x,p3.y,p3.z);
end;

function cNodeObject.GetPosition:point3;
begin
  result:=GetPosFromMatrixP3(node.restm);
end;

procedure cNodeObject.setPosition(newpos:point3);
var curpos:point3;
begin
  curpos:=node.position;
  node.position:=newpos;
  setobjtoworld;
end;

procedure cNodeObject.UserMoveObj(var msg:tmessage; mouse:MouseStruct);
var p3,dir:point3;
    b:boolean;
    cx,cy:integer; // ���������� ������ ����
begin
  b:=false;
  p3.x:=0;p3.y:=0;p3.z:=0;
  if GetKeyState(65)<0 then // 'a'
  begin
    p3.x:=mouse.m_MoveSens;
    b:=true;
  end
  else
  begin
    if GetKeyState(68)<0 then // 'd'
    begin
      p3.x:=-mouse.m_MoveSens;
      b:=true;
    end;
  end;
  if GetKeyState(83)<0 then // 's'
  begin
    p3.z:=-mouse.m_MoveSens;
    b:=true;
  end
  else
  begin
    if GetKeyState(87)<0 then // 'w'
    begin
      p3.z:=mouse.m_MoveSens;
      b:=true;
    end;
  end;
  if GetKeyState(vk_space)<0 then // 'space'
  begin
    p3.y:=mouse.m_MoveSens;
    b:=true;
  end
  else
  begin
    if GetKeyState(67)<0 then // 'c'
    begin
      p3.y:=-mouse.m_MoveSens;
      b:=true;
    end;
  end;
  if b then
  begin
    MoveNodeLocal(p3);
  end;
end;


end.
