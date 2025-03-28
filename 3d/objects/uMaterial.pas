unit uMaterial;

interface
 Uses
  Windows, Graphics, SysUtils,Classes, OpenGL, Mathfunction, TextureGL,
  dialogs, uEventList ,uCommonTypes;
 type
  cMaterialManager = class;

  cMaterial = class
    fDifTexture,fBumpTexture:TTextureGL;
    // �������� ���������
    Ambient,Diffuse,Specular:Vector3f;
    Shininess: single;
    Opacity: GLint;
    MtlExist:boolean;
    TexName:String;//��� ��������
    matmng:cMaterialManager;
  public
    events:ceventlist;
  protected
    fname:string;  
  public
    constructor create(p_matmng:cmaterialmanager);
    Destructor  Destroy;override;
    // �������� ���������������
    procedure Enable;
    // ��������� ���������������
    procedure Disable;
    // �������� ���������
    procedure SwitchOnOf;
    // ������ ���������� �� �������� ��������
    function  textured:boolean;
    // ��������� �������� (����� ������� ����� ���������� ������������� �������)
    procedure ApplyMaterial(mat:integer;defaultcolor:point3);
  protected
    procedure OnDestroyTex(sender:tobject);
    procedure setDifTex(t:ttexturegl);
    procedure setBumpTex(t:ttexturegl);
    procedure setname(newname:string);
  public
    property name:string read fname write setname;
    property difTexture:ttexturegl read fDifTexture write setDifTex;
    property BumpTexture:ttexturegl read fBumpTexture write setBumpTex;
  end;

  cMaterialManager = class
    defMat:cmaterial;
    m_materials:tStringList;
    m_texturemanager:cTextureManager;
    constructor Create(textures:cTextureManager);
    destructor destroy;
    // ������� ��������
    procedure deleteMaterial(i:integer);overload;
    procedure deleteMaterial(m:cmaterial);overload;
    // �������� ��������. ���� ����������� �������� � ������ ������� ��� ����,
    // �� ����� �������� ��������� � ������� ���������� ��� �������� �������
    // ��� ������������� � �����
    function add(material:cmaterial):integer;
    // �������� ��������
    function getmaterial(name:string):cMaterial;overload;
    function getmaterial(i:integer):cMaterial;overload;
    // ����� ����������
    function count:integer;
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
procedure glActiveTextureARB(texture:GLenum);stdcall; external OpenGL32;

const
 GL_VERTEX_ARRAY             = $8074;
 GL_COLOR_ARRAY              = $8076;
 GL_Normal_ARRAY             = $8075;
 GL_TEXTURE_COORD_ARRAY      = $8078;
 GL_TEXTURE0_ARB             = $84C0;


constructor cMaterialManager.Create(textures:cTextureManager);
var
  defaultMaterial:cmaterial;
begin
  m_materials:=tStringList.Create;
  m_texturemanager:=textures;
  m_materials.Sorted:=true;
  defaultMaterial:=cmaterial.Create(self);
  defaultMaterial.fname:='default';
  defaultMaterial.MtlExist:=false; // �������� �����������
  defMat:=defaultMaterial;
end;

destructor cMaterialManager.destroy;
var i:integer;
    material:cMaterial;
    events:ceventlist;
begin
  events:=nil;
  for i := 0 to m_materials.Count - 1 do
  begin
    material:=cmaterial(m_materials.Objects[i]);
    events:=material.events;
    events.active:=false;
    material.Destroy;
  end;
  defMat.Destroy;
  defMat:=nil;
  m_materials.Destroy;
  inherited;
end;

procedure cMaterialManager.deleteMaterial(i:integer);
var m:cmaterial;
begin
  if i<count then
  begin
    m:=getmaterial(i);
    m_materials.Delete(i);
    m.Destroy;
  end;
end;

procedure cMaterialManager.deleteMaterial(m:cmaterial);
var index:integer;
begin
  if m_materials.find(m.fname,index) then
  begin
    m_materials.Delete(index);
    m.Destroy;
  end;
end;

function cMaterialManager.count:integer;
begin
  result:=m_materials.Count;
end;

function cMaterialManager.add(material:cmaterial):integer;
var index:integer;
begin
  IF not m_materials.find(material.fname,index) then
  begin
    m_materials.AddObject(material.fname,material);
    result:=-1;
  end
  else
  begin
    result:=index;
  end;
end;

function cMaterialManager.getmaterial(name:string):cmaterial;
var index:integer;
begin
  result:=nil;
  if m_materials.find(name,index) then
    result:=getmaterial(index);
end;

function cMaterialManager.getmaterial(i:integer):cMaterial;
begin
  result:=cmaterial(m_materials.Objects[i])
end;

procedure cMaterial.setname(newname:string);
var index:integer;
begin
  if matmng<>nil then
  begin
    if matmng.m_materials.Find(fname,index) then
    begin
      matmng.m_materials.Delete(index);
      matmng.m_materials.AddObject(newname,self);
    end;
  end;
  fname:=newname;
end;

Destructor cMaterial.Destroy;
begin
  events.CallAllEvents(E_AllEvents);
  events.destroy;
  inherited;
end;

procedure cMaterial.Enable;
begin
  glEnable(GL_TEXTURE_2D);
end;

procedure cMaterial.Disable;
begin
  glDisable(GL_TEXTURE_2D);
end;

Procedure cMaterial.ApplyMaterial(mat:integer;defaultcolor:point3);
begin
   if (fname ='default') then
   begin
     Disable;
     glcolor3fv(@defaultcolor);
   end
   else
   begin
     // ����� ������ �������� ��������� ����� ��������� ���� ��������� �� ������
     // gldisablecolormaterial
     glColor3f (1, 1, 1);
     glMaterialfv(GL_FRONT,GL_AMBIENT,@Ambient);
     glMaterialfv(GL_FRONT,GL_DIFFUSE,@Diffuse);
     glMaterialfv(GL_FRONT,GL_Specular,@Specular);
     glMaterialf(GL_FRONT,GL_SHININESS,SHININESS);
   end;
   begin
     if textured then
     begin
       glColor3f (1, 1, 1);
       if DifTexture<>nil then
       begin
         DifTexture.Bind;
       end;
       if BumpTexture<>nil then
       begin
         BumpTexture.Bind;
       end;
       Enable;
     end
     else
     begin
       Disable;
     end;
   end;
end;

procedure cMaterial.SwitchOnOf;
var enabled:boolean;
begin
  glGetBooleanv( GL_Texture_2d,@enabled);
  if enabled then
    glDisable(GL_TEXTURE_2D)
  else
    glEnable(GL_TEXTURE_2D);
end;

constructor cmaterial.create(p_matmng:cmaterialmanager);
begin
  inherited create;
  matmng:=p_matmng;
  events:=ceventlist.create(self,false);
end;

procedure cmaterial.OnDestroyTex(sender:tobject);
begin
  if sender=fdiftexture then
  begin
    fdiftexture:=nil;
  end;
  if sender=fdiftexture then
    fBumpTexture:=nil;
end;

procedure cmaterial.setDifTex(t:ttexturegl);
begin
  if fdiftexture<>nil then
    fdiftexture.events.removeEvent(OnDestroyTex,0);
  fdiftexture:=t;
  fdiftexture.events.AddEvent(fname+'DifTexOnDestroy',0,OnDestroyTex);
end;

procedure cmaterial.setBumpTex(t:ttexturegl);
begin
  if fBumpTexture<>nil then
    fBumpTexture.events.removeEvent(OnDestroyTex,0);
  fBumpTexture:=t;
  fBumpTexture.events.AddEvent(fname+'BumpTexOnDestroy',0,OnDestroyTex);
end;

function  cmaterial.textured:boolean;
begin
  result:=false;
  if fDifTexture<>nil then
  begin
    result:=true;
    exit;
  end;
  if fBumpTexture<>nil then
  begin
    result:=true;
    exit;
  end;
end;



end.
