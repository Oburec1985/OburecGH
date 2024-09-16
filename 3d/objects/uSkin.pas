unit uSkin;

interface

uses classes, types, usetlist,
     umatrix, mathfunction, uObject, uMeshObr, uVectorList, uBaseModificator,
     uNodeObject, dialogs, uselectools,
     uBaseDeformer,
     umesh,
     uEventList,
     sysutils,
     uCommonTypes,
     uBaseObj,
     uShape,
     uBaseObjMng;

type

  dataitem = record
    ind:integer;
    weight:single;
  end;

  bonedata = class
    name:string;
    data:array of dataitem;
  public
    function count:integer;
  end;
  // ������ ������
  skinData = class(tstringlist)
  public
    constructor create;
    destructor destroy;
    function GetBoneData(i:integer):bonedata;
  end;

  cSkin = class;
  cbone = class;

  cSkinVertex = class
    i:tpoint; // ������ ���������� ������� � ������ �����. � ������ Mesh ������������� ������ x
              // � ������ shape ������������ ����� ����������� (y)
    bones:tlist;
    vres:point3;
  public
    function bone(i:integer):cbone;
    function count:integer;
    constructor create;
    destructor desroy;
  end;


  cBone = class
    // ������ ������ �� ���������� (����������������) ������� �������
    // (��.VPointers ������ cMesh), ���� ���� ������ � ��������� �� ������ ��������
    //pointers:cPointsList;
    //pointers:cIntVectorList;
    pointers:cTPointVectorList;
    // ������� �������� �� ����� � ��� � ������ �������� � ����������� ������
    m:matrixgl;
  public
    // ������ ����� � �������� ������������ �����
    fbone:cNodeObject;
  private
    skin:cskin;// ������ �� �����������
    // �����
    fmesh:cNodeobject;
  private
    // ��������� ������� �������� �� ����� � ������ � ���������
    // ��������� ������ �� ������ ��������
    procedure updateBoneToObjM;
    // ��������� ����� ������� ��� ����� ����� � ���������� ������
    // ��� ������� ���������� ��������� ����� � ������ ��������, ������� ��������
    // �� ����� � ��� � ��� �������.
    // l_m - �������������� ������� ������� (������� � ������� ����������)
    // �.�. ��� ��������� ������ ���� � ��� ���������� ���� � ���� ����������� � �����
    function EvalPointPos(i:integer;l_m:matrixgl):cDeformPoint;
    // ��������� skin ��� ���������� ��������� �����
    procedure UpdateBone(sender:tobject);

    function getname:string;
  public
    constructor create(bone:cnodeobject;pmesh:cmeshObr);
    destructor destroy;override;
    // ����� ������
    function count:integer;
    // �������� ������� �� ������� �� �������
    function getpoint(i:integer):cDeformPoint;
    // �������� ������� �� ������� �� ������� ���������� �������
    function FindPoint(i:tpoint):cDeformPoint;
    // ������� ������������� ����� � �������� i � ������� ������������� �����
    // ���������� ������ �� ��������� �����
    function AddPoint(i:tpoint;weight:single):cDeformPoint;
    // ������� ����� �� �������
    procedure deletePoint(i:integer);
    // ��������� ����� ��������� ��� ����� ����� � ���������� ������
    // ��� ������� ���������� ��������� ����� � ������ ��������, ������� ��������
    // �� ����� � ��� � ��� �������
    procedure EvalPointsPosition;
    property name:string read getname;
  end;

  // ���������� ����������. �������� �� ����� ����� ������� ����� �������������
  // ��� ����� ������� ����� �������� � DeformMeshes
  cSkin = class(cbasemodificator)
  public
    // ������ ������ � ������ ������ � ����� ������, ���� �� ���������� ������ �������� ������ ��� �������������
    // �������
    ImpExpdata:skindata;
  private
    // ������������� �������
    vList:cTPointVectorList; // ������ ������ cSkinVert
    // ������
    boneList:tlist;
  protected
    // ������������� ��� � ��� �������
    procedure UnLincMesh;
    function FindSkinVert(key:tpoint):cSkinVertex;
    // ��������� �������� ���� ����� ��� �������
    procedure EvalAll;
  public
    // �������� ����� �� �����
    function getbone(i:integer):cbone;
    constructor create(p_mesh:cmeshobr);
    destructor destroy;
    function AddBone(p_bone:cnodeObject):cbone;
    // ���������� ����������� ������ � ��������� �����
    procedure linc(objectlist:tobject);
    procedure apply;override;
  protected
    procedure OnUpdateMeshPos(Sender:Tobject);
    procedure setmesh(obj:cmeshobr);
    function getmesh:cmeshobr;
  public
    // ���������� ����� ������
    function count:integer;
    // ����� ��� ��� ����������� ��������� ���.����� ��������� �����
    property mesh:cmeshobr read getmesh write setmesh;
  end;

implementation
uses
  umodlist;

function bonedata.count:integer;
begin
  result := length(data);
end;

constructor skindata.create;
begin

end;

destructor skindata.destroy;
var i:integer;
    bdata:bonedata;
begin
  for I := 0 to count - 1 do
  begin
    bdata:=bonedata(Objects[i]);
    bdata.Destroy;
  end;
  inherited;
end;

function skindata.GetBoneData(i:integer):bonedata;
begin
  result:=bonedata(Objects[i]);
end;

constructor cSkinVertex.create;
begin
  bones:=tlist.Create;
end;

destructor cSkinVertex.desroy;
begin
  bones.Destroy;
end;

function cSkinVertex.count:integer;
begin
  result:=bones.Count;
end;

function cSkinVertex.bone(i:integer):cbone;
begin
  result:=cBone(bones.Items[i]);
end;


constructor cBone.create(bone:cnodeobject;pmesh:cmeshObr);
begin
  fmesh:=pmesh;
  //pointers:=cIntVectorList.create;
  pointers:=cTPointVectorList.create;
  fbone:=bone;
  bone.events.AddEvent(fbone.name+'updateBone',e_setObjtoworld,UpdateBone);
  updateBoneToObjM;
end;

procedure cBone.UpdateBone(sender:tobject);
var p:cdeformpoint;
    p3,realPos:point3;
    i:integer;
begin
  {EvalPointsPosition;
  for I := 0 to count - 1 do
  begin
    p:=getpoint(i);
    realPos:=fmesh.fmesh.UnicVertPos[p.p];
    p3:=summvectorp3((p.Vres),scalevectorp3(1-p.weight,realPos));
    fmesh.fMesh.UnicVertPos[p.p]:=p3;
  end;}
  skin.EvalAll;
end;

destructor cBone.destroy;
begin
  pointers.destroy;
end;

function cBone.count:integer;
begin
  result:=pointers.Count;
end;

// �������� ������ �� ������������� �����
function cBone.getpoint(i:integer):cDeformPoint;
begin
  result:=cDeformPoint(pointers.getObj(i));
end;

function cBone.AddPoint(i:tpoint;weight:single):cdeformpoint;
var p:cDeformPoint;
    sV:cSkinVertex;
    j:integer;
begin
  result:=cDeformPoint(pointers.findObj(@i,j));
  if result=nil then
  begin
    p:=cDeformPoint.Create;
    p.weight:=weight;
    p.p:=i;
    if fmesh is cMeshObr then
    begin
      p.v:=VtoP3(cMeshObr(fmesh).mesh.drawarray[cMeshObr(fmesh).mesh.UnicVert[i.x].Pointers[0]]);
    end;
    if fmesh is cShapeObj then
    begin
      p.v:=cShapeObj(fmesh).getPoint(i);
    end;
    pointers.AddObject(@p.p,p);
    result:=p;
    sv:=skin.FindSkinVert(i);
    if sv<>nil then
    begin
      // ���������� ����� � ��� ������������ �������
      sv.bones.Add(self);
    end
    else
    begin
      // ���������� ����� �������
      sv:=cskinvertex.create;
      sv.i:=i;
      skin.vList.AddObject(@i,sv);
      sv.bones.Add(self);
    end;
  end;
end;

procedure cBone.deletePoint(i:integer);
var
  p:cDeformPoint;
begin
  p:=cDeformPoint(pointers.deleteobj(@i));
  p.destroy;
end;

function cBone.EvalPointPos(i:integer;l_m:matrixgl):cdeformpoint;
var p:cdeformpoint;
    m_p, l_m2:matrixgl;
    prev, shift:point3;
begin
  // m - ������� �������� �� ����� � ���������� ������
  p:=getpoint(i);
  // ������� ��������� ����� �� ������ ��������
  m_p:=setpos(identmatrix4,p.v);
  l_m2:=multmatrix4(l_m,m_p); // ����� ������� ������� � ���������� �����������
  l_m2:=evalrightmatrix(fmesh.restm,l_m2); // ��������� ������� �������� �� ���� ������ � global+�������
  prev:=p.v;
  p.Vres:=GetPosFromMatrixP3(l_m2);
  // ��������� 11.09.24
  shift:=subVector(prev, p.Vres);
  shift:=scalevectorp3(p.weight,shift);
  p.Vres:=summvectorp3(prev, shift);
  //p.Vres:=GetPosFromMatrixP3(l_m2);
  //if p.weight<>1 then
  //  p.Vres:=P3ToV(summvectorp3(scalevectorp3(p.weight,p.Vres),
  //                             scalevectorp3(1-p.weight,p.v)));
  //mesh.mesh.DrawArray[p.p]:=P3ToV(summvectorp3(scalevectorp3(p.weight,p.Vres),
  //                          scalevectorp3(1-p.weight,p.v)));
end;

procedure cBone.EvalPointsPosition;
var p:cdeformpoint;
    i:integer;
    l_m:matrixgl;
begin
  // l_m - �������������� ������� ������� (������� � ������� ����������)
  // ����� ��� �� ���� mesh.restm �� ��������� ������ ������������ ������� ��������
  // �.�. ��� ��������� ������ ���� � ��� ���������� ���� � ���� ����������� � �����
  // m - ������� �� ������ ���
  l_m:=multmatrix4(fbone.restm,m);
  for I := 0 to Count - 1 do
  begin
    EvalPointPos(i,l_m);
  end;
end;

function cBone.getname:string;
begin
  result:=fbone.name;
end;

// �������� ������� �� ������� �� ������� ���������� �������
function cBone.FindPoint(i:tpoint):cDeformPoint;
var
  p:cdeformpoint;
  j:integer;
begin
  result:=cdeformpoint(pointers.findObj(@i));
end;

// �������� ��� �������� �������
procedure cBone.updateBoneToObjM;
var i:integer;
    p:cdeformpoint;
begin
  m:=evalrightmatrix(fbone.restm, fmesh.restm);
  for i := 0 to count - 1 do
  begin
    p:=getpoint(i);
    // ��������� ��������� ����� �� ������ ��������
    if fmesh is cmeshobr then
      p.v:=VtoP3(cmeshobr(fmesh).mesh.drawarray[cmeshobr(fmesh).mesh.UnicVert[p.p.x].Pointers[0]])
    else
    begin
      if fmesh is cshapeobj then
      begin
        p.v:=cshapeobj(fmesh).getPoint(p.p);
      end;
    end;
  end;
end;

procedure cSkin.linc(objectlist:tobject);
var
  skin:cskin;
  j,vcount,i,bonecount:integer;
  bdata:bonedata;
  Objbone:cnodeobject;
  bone:cbone;
  str:string;
  p:tpoint;
begin
  bonecount:=impexpdata.Count;
  for I := 0 to bonecount - 1 do
  begin
    // ������ ��� �����
    bdata:=bonedata(impexpdata.GetObject(i));
    str:=bdata.name;
    Objbone:=cnodeobject(cBaseObjList(objectlist).getobj(str));
    bone:=AddBone(Objbone);
    // ������ ����� ������ �����
    vcount:=bdata.count;
    p.y:=0;
    for j := 0 to vcount - 1 do
    begin
      p.x:=bdata.data[j].ind;
      bone.addpoint(p,bdata.data[j].weight);
    end;
  end;
end;

constructor cSkin.create(p_mesh:cmeshobr);
begin
  vList:=cTPointVectorList.create;
  boneList:=tlist.create;
  mesh:=p_mesh;
  modtype:=constskin;
end;

destructor cSkin.destroy;
var i:integer;
    point:cDeformPoint;
begin
  bonelist.destroy;
end;

function cSkin.count:integer;
begin
  result:=BoneList.Count;
end;

function cSkin.FindSkinVert(key:tpoint):cSkinVertex;
begin
  result:=cSkinVertex(vList.findObj(@key));
end;

procedure cSkin.OnUpdateMeshPos(Sender:Tobject);
var i:integer;
    bone:cbone;
begin
  for I := 0 to count - 1 do
  begin
    bone:=cBone(bonelist.items[i]);
    bone.updateBoneToObjM;
  end;
end;

procedure cSkin.UnLincMesh;
begin
  if owner<>nil then
  begin
    cmeshobr(owner).events.removeEvent(OnUpdateMeshPos,e_setObjtoworld);
    cmeshobr(owner):=nil;
  end;
end;

procedure cSkin.setmesh(obj:cmeshobr);
begin
  UnLincMesh;
  owner:=obj;
  OnUpdateMeshPos(obj);
  cmeshobr(owner).events.AddEvent('basedeformer updateBoneToModelM',e_setObjtoworld,OnUpdateMeshPos);
end;

function cSkin.getmesh:cmeshobr;
begin
  result:=cmeshobr(owner)
end;

function cSkin.AddBone(p_bone:cnodeObject):cbone;
var bone:cbone;
begin
  bone:=cbone.create(p_bone,cmeshobr(owner));
  bone.skin:=self;
  result:=bone;
  bonelist.Add(bone);
end;

function cSkin.getbone(i:integer):cbone;
begin
  result:=cbone(Bonelist.items[i]);
end;

procedure cSkin.EvalAll;
var i,j,bonecount:integer;
    p3:point3;
    bone:cbone;
    sv:cskinvertex;
    v:cdeformpoint;
    uv:cVPointer;
    l:tline;
begin
  bonecount:=count;
  for I := 0 to bonecount - 1 do
  begin
    getbone(i).EvalPointsPosition;
  end;
  for I := 0 to vList.Count-1 do
  begin
    p3.x:=0;p3.y:=0;p3.z:=0;
    sv:=cskinvertex(vlist.getObj(i));
    // ��������� ������ �������� ������� �� ���������� ������
    for j := 0 to sv.Count - 1 do
    begin
      bone:=sv.bone(j);
      v:=bone.FindPoint(sv.i);
      p3:=SummVectorP3(p3,v.Vres);
    end;
    if owner is cmeshobr then
    begin
      // ��������� ���������� ������
      uv:=cmeshobr(owner).mesh.UnicVert[i];
      cmeshobr(owner).mesh.updateVertDataByUV(uv,p3);
    end
    else
    begin
      if owner is cShapeObj then
      begin
        l:=cShapeObj(owner).Lines[sv.i.x];
        l.data[sv.i.y]:=p3;
        cShapeObj(owner).needRecompile:=true;
      end;
    end;
  end;
end;

procedure cSkin.apply;
begin
  EvalAll;
end;

end.
