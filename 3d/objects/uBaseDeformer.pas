unit uBaseDeformer;

interface
uses classes,
     umatrix, mathfunction, uObject, uMeshObr, uVectorList, uBaseModificator,
     uNodeObject, dialogs, uselectools,uCommonTypes;

type
  // ����� � ������� �������� ���������� � ����������� �����
  cDeformPoint = class
    p:integer; // ������ ����� � ����� ����
    weight:single; // ��� ����� (������� ������� ����� �� �����)

    v:point3; // ���������� ����� � ������ �������� � ����������� ������
    Vres:point3; // ���������� ������� � ������� ������;
  public
    constructor create;
    destructor destroy;
  end;

  // ����� � ������� �������� ���������� � ����������� �����
  cDeformMesh = class
  public
    // ������ ��������� ����� � ������� ������ ����
    selectp:integer;
  private
    // �����
    fbone:cnodeobject;
    // ������ �� ������������� ���
    fmesh:cmeshobr;
    // ������� �������� �� ����� � ��� � ������ �������� � ����������� ������
    m:matrixgl;
    // ������ ���������� �� ������������� �����
    pointers:cIntVectorList;
  private
    procedure setmesh(obj:cmeshobr);
    function getmesh:cmeshobr;
    procedure setBone(obj:cnodeobject);
    function getBone:cnodeobject;
  protected
    procedure UnLincMesh;
  public
    constructor create(p_bone:cnodeobject);
    destructor destroy;
    // ��������� �������� ����� �������������� ����
    function findpoint(x,y:integer):integer;
    // ������ ���������� ����� � ������������� �����
    function count:integer;
    // �������� ������ �� ������������� �����
    function getpoint(i:integer):cDeformPoint;
    // ������� ������������� ����� � �������� i � ������� ������������� �����
    // ���������� ������ �� ��������� �����
    function AddPoint(i:integer):cDeformPoint;
    procedure deletePoint(i:integer);
    // ��������� ����������� ��������� ����� �� ������� ����� (bone.restm),
    // ������� ����� �� ������ �������� m (������� �������� �� ��������� ����� � �
    // ���������� ����)
    // ��������: 1) ��������� ����� ������� ������� ���� � �� ��� �������
    // 2) ������� � ����� ��� ������������ ����� �� ������� l_m bone.restm*m (���������� ���������)
    // 3) ��������� ����� ������� ������� m_p = l_m*v (���������� ���������)
    // 4) ��������� ���������� ����� � ��������� ������� ������� l_m2:=evalrightmatrix(fmesh.restm,l_m2);
    procedure Apply;
    // ���������� ������� �������� �� �������� ����� � ��������� ������
    procedure UpdateBoneToModelM(sender:tobject);
  public
    // ����� ��� ��� ����������� ��������� ���.����� ��������� �����
    property mesh:cmeshobr read getmesh write setmesh;
    property bone:cnodeobject read getbone write setbone;
  end;

  // ���������� ����������. �������� �� ����� ����� ������� ����� �������������
  // ��� ����� ������� ����� �������� � DeformMeshes
  cBaseDeformer = class(cbasemodificator)
  public
  private
    DeformMeshes:TList; // ������������� �����
  public
    // ������� ����� ��������
    function count:integer;
    // ������� ������������� ������
    function getDeformMesh(i:integer):cdeformmesh;
    // �������� ������������� ������
    procedure AddDeformMesh(mesh:cdeformmesh);
    // ��������� �����������
    procedure Apply;override;
  public
    constructor create(aowner:cnodeobject);
    destructor destroy;
  end;

implementation
uses
  umodlist;

constructor cDeformPoint.create;
begin

end;

destructor cDeformPoint.destroy;
begin
end;

function cDeformMesh.findpoint(x,y:integer):integer;
var i,j,p:integer;
    v:Vector3f;
begin
  for I := 0 to fmesh.mesh.FaceCount - 1 do
  begin
    for j := 0 to 2 do
    begin
      p:=fmesh.mesh.FaceArray[i][j];
      v:=fmesh.mesh.drawarray[p];
      if SelectVertex(x,y,5,VtoP3(v),fmesh.restm) then
      begin
        selectp:=p;
        exit;
      end;
    end;
  end;
end;

constructor cDeformMesh.create(p_bone:cnodeobject);
begin
  bone:=p_bone;
  pointers:=cIntVectorList.Create;
end;

destructor cDeformMesh.destroy;
var i:integer;
    point:cDeformPoint;
begin
  UnLincMesh;
  for I := 0 to pointers.Count - 1 do
  begin
    Point:=cDeformPoint(pointers.items[i]);
    Point.Destroy;
  end;
  pointers.destroy;
end;

function cDeformMesh.count:integer;
begin
  result:=pointers.count;
end;

procedure cDeformMesh.UnLincMesh;
begin
  if fmesh<>nil then
  begin
    fmesh.events.removeEvent(UpdateBoneToModelM,e_setObjtoworld);
    fmesh:=nil;
  end;
end;

procedure cDeformMesh.setmesh(obj:cmeshobr);
begin
  UnLincMesh;
  fmesh:=obj;
  UpdateBoneToModelM(obj);
  fmesh.events.AddEvent('basedeformer updateBoneToModelM',e_setObjtoworld,UpdateBoneToModelM);
end;

procedure cDeformMesh.UpdateBoneToModelM(sender:tobject);
var i:integer;
    p:cdeformpoint;
begin
  // ���������� ������� �������� �� bone � mesh
  m:=evalrightmatrix(bone.restm, fmesh.restm);
  for i := 0 to count - 1 do
  begin
    p:=getpoint(i);
    // ������� ��������� ����� �� ������ ��������
    p.v:=VtoP3(mesh.mesh.drawarray[p.p]);
  end;
end;

function cDeformMesh.getmesh:cmeshobr;
begin
  result:=fmesh;
end;

procedure cDeformMesh.setBone(obj:cnodeobject);
begin
  fbone:=obj;
end;

function cDeformMesh.getBone:cnodeobject;
begin
  result:=fbone;
end;

function cDeformMesh.getpoint(i:integer):cDeformPoint;
begin
  result:=cDeformPoint(pointers.getObj(i));
end;

function cDeformMesh.AddPoint(i:integer):cdeformpoint;
var p:cDeformPoint;
begin
  p:=cDeformPoint.Create;
  p.p:=i;
  p.v:=VtoP3(mesh.mesh.drawarray[i]);
  pointers.AddObject(@p.p,p);
  result:=p;
end;

procedure cDeformMesh.Apply;
var i:integer;
    p:cdeformpoint;
    l_m, m_p, l_m2:matrixgl;
    p_global:point3;
begin
  // m - ������� �������� �� ����� � ���������� ������
  // l_m - �������������� ������� ������� (������� � ������� ����������)
  l_m:=multmatrix4(bone.restm,m);
  for i := 0 to count - 1 do
  begin
    p:=getpoint(i);
    // ������� ��������� ����� �� ������ ��������
    m_p:=setpos(identmatrix4,p.v);
    l_m2:=multmatrix4(l_m,m_p); // ����� ������� ������� � ���������� �����������
    l_m2:=evalrightmatrix(fmesh.restm,l_m2); // ��������� ������� �������� �� ���� ������ � global+�������
    p.Vres:=GetPosFromMatrixP3(l_m2);
    mesh.mesh.DrawArray[p.p]:=P3ToV(summvectorp3(scalevectorp3(p.weight,p.Vres),
                                    scalevectorp3(1-p.weight,p.v)));
  end;
end;

procedure cDeformMesh.deletePoint(i:integer);
var p:cDeformPoint;
begin
  p:=cDeformPoint(pointers.deleteobj(@i));
  p.destroy;
end;

constructor cBaseDeformer.create;
begin
  DeformMeshes:=tlist.Create;
  modtype:=constBaseDeformer;
end;

destructor cBaseDeformer.destroy;
var i:integer;
    deformmesh:cdeformmesh;
begin
  for I := 0 to deformmeshes.Count - 1 do
  begin
    deformmesh:=cdeformmesh(deformMeshes.items[i]);
    deformmesh.Destroy;
  end;
  DeformMeshes.destroy;
end;

function cBaseDeformer.getDeformMesh(i:integer):cdeformmesh;
begin
  result:=cDeformMesh(DeformMeshes.Items[i]);
end;

procedure cBaseDeformer.AddDeformMesh(mesh:cdeformmesh);
begin
  DeformMeshes.Add(mesh);
end;

function cBaseDeformer.count:integer;
begin
  result:=deformmeshes.count;
end;

procedure cBaseDeformer.Apply;
var i:integer;
    mesh:cdeformmesh;
begin
  for I := 0 to count - 1 do
  begin
    mesh:=getDeformMesh(i);
    mesh.Apply;
  end;
end;



end.
