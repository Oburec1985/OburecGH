unit uMeshObr;

interface
uses
  Windows, OpenGL, Classes, MathFunction, TextureGl, uMaterial,
  SysUtils, uObject, uObjectTypes, umatrix, uMesh, unodeobject;
type

 cMeshObr = class (cObject)
 public
   inst:boolean; // ����� ������� �������?   instname:string; // ��� ���������
   instname:string;
   fMesh:cMesh;
   m_MatMng:cMaterialManager; // ������ �� �������� ����������
 private
   fmat:cmaterial;
 protected
   Procedure DrawData;override;
 private
   Procedure  DrawNormal(len:single);
   destructor destroy;override;
 public
   function getCopy:cnodeobject;override;
   procedure CopyTo(obj:cnodeobject);override;
   // ���������� min max ������� �� x � y;
   Constructor Create;override;
   procedure UpdateBounds;
   function GetMaterial:cmaterial;
   function AddMaterial(pmaterial:cmaterial):boolean;
 protected
   procedure setmesh(m:cmesh);
   procedure OnDelMaterial(sender:tobject);
   procedure setMaterial(m:cmaterial);
 protected
   procedure setdrawgeom(b:boolean);
   function getdrawgeom:boolean;
   procedure setdrawEdges(b:boolean);
   function getdrawEdges:boolean;
   procedure setdrawPoints(b:boolean);
   function getdrawPoints:boolean;
 public
   property drawGeom:boolean read getDrawGeom write SetDrawGeom;
   property drawEdges:boolean read getDrawEdges write SetDrawEdges;
   property drawPoints:boolean read getDrawPoints write SetDrawPoints;

   property mesh:cmesh read fmesh write setmesh;
   property material:cmaterial read fmat write setmaterial;
 end;

implementation
procedure glTexCoordPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
procedure glVertexPointer (size: GLint; atype: GLenum;
          stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glNormalPointer (size: GLint; stride: GLsizei; data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glColorPointer (size: GLint; atype: GLenum; stride: GLsizei;
          data: pointer); stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDrawArrays (mode: GLenum; first: GLint; count: GLsizei);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glEnableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDisableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDrawElements(mode: GLenum;count: GLsizei;
          GlType:GLEnum;data: pointer);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glBindTexture(mode: GLenum; Texture:GLuint
          ); stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glGenTextures (n: GLsizei; textures: PGLuint);
          stdcall; external opengl32;
//---------------------------------------------------------------------
procedure glLightModeli (n: GLEnum; u: GLuint);
          stdcall; external opengl32;

const
 GL_VERTEX_ARRAY             = $8074;
 GL_COLOR_ARRAY              = $8076;
 GL_Normal_ARRAY             = $8075;
 GL_TEXTURE_COORD_ARRAY      = $8078;

//-----------------------------------------------------------------
//-------------------- ������ ������ TMesh_Obr --------------------
//-----------------------------------------------------------------

procedure cMeshObr.setmesh(m:cmesh);
begin
  fmesh:=m;
  fmesh.obj:=Self;
  inc(fmesh.linccount);
end;

procedure cMeshObr.OnDelMaterial(sender:tobject);
begin
  fmat:=m_matmng.defMat;
end;

procedure cMeshObr.setdrawgeom(b:boolean);
begin
  if b then
    setflag(draw_Geom)
  else
    dropflag(draw_Geom);
end;

function cMeshObr.getdrawgeom:boolean;
begin
  result:=CheckFlag(draw_Geom, settings);
end;

procedure cMeshObr.setdrawEdges(b:boolean);
begin
  if b then
    setflag(draw_Edges)
  else
    dropflag(draw_Edges);
end;

function cMeshObr.getdrawEdges:boolean;
begin
  result:=CheckFlag(draw_Edges, settings);
end;

procedure cMeshObr.setdrawPoints(b:boolean);
begin
  if b then
    setflag(draw_Points)
  else
    dropflag(draw_Points);
end;

function cMeshObr.getdrawPoints:boolean;
begin
  result:=CheckFlag(draw_Points, settings);
end;

procedure cMeshObr.setMaterial(m:cmaterial);
begin
  if m=fmat then
    exit;
  if fmat<>nil then
    fmat.events.removeEvent(OnDelMaterial,0);
  if m=nil then
  begin
    m:=fmat.matmng.defMat;
  end;
  fmat:=m;
  fmat.events.AddEvent(NAME+' OnMaterialDestroy',0,OnDelMaterial);
end;

function cMeshObr.getCopy:cnodeobject;
var obj:cmeshobr;
begin
  obj:=cmeshobr.Create;
  //obj:=cmeshobr.Create(scene);
  copyto(obj);
  result:=obj;
end;

procedure cMeshObr.CopyTo(obj:cnodeobject);
begin
  if obj is cmeshobr then
  begin
    inherited copyto(obj);
    cmeshobr(obj).inst:=true;
    if instname<>'' then
      cmeshobr(obj).instname:=instname
    else
      cmeshobr(obj).instname:=obj.name;
    cmeshobr(obj).Mesh:=Mesh;
    cmeshobr(obj).m_MatMng:=m_MatMng;
    cmeshobr(obj).Material:=material;
  end;
end;

constructor cMeshObr.Create;
begin
  inherited;
  objtype:=constmesh;
  fHelper:=false;
  setflag(Draw_Geom);
  inst:=false;  
end;

Destructor cMeshObr.Destroy;
begin
 dec(mesh.linccount);
 if mesh.linccount=0 then
   mesh.Destroy;
  inherited;
end;

function cMeshObr.AddMaterial(pmaterial:cmaterial):boolean;
var i:integer;
begin
  material:=pmaterial;
  i:=m_MatMng.add(material);
  if i<>-1 then
  begin
    material:=m_MatMng.getmaterial(i);
    result:=false;
    //pmaterial.Destroy;
  end
  else
    result:=true;
end;

function  cMeshObr.GetMaterial:cmaterial;
begin
  result:=material;
end;

procedure cMeshObr.DrawData;
begin
 // ���� ���� �������� �� ��������� ����� ���������� ��������� ����
 mesh.Draw(settings,material);
end;

//---------- ��������� ��������� ������� ��������� �������
Procedure cMeshObr.DrawNormal(len:single);
Begin
  mesh.DrawNormal(len);
End;

procedure cMeshObr.UpdateBounds;
begin
  mesh.UpdateBounds(bound.lo,bound.hi);
end;

end.
