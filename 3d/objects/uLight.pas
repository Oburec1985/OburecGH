unit uLight;

interface
uses
  Windows, OpenGL, Classes, uObject, MathFunction, uMatrix, uselectools,uObjectTypes,
  uVectorList, unodeobject,uCommonTypes;
Type
  clightlist = class;

  cLight = class(cObject)
  private
    m_Ambient,m_Diffuse, m_specular:array[0..3] of GlFloat;
    // GL_Light0+i, ��� i - ����� ��������� (�� ����� 8)
    lightID:Cardinal;
  public
    Constructor Create(ID:cardinal;p_scene:tobject);
    destructor destroy;
    procedure draw;override;
    Procedure SetObjToWorld;override;
  private
    Procedure Enable;
    Procedure Disable;
    procedure setState(v:boolean);
    function getState:boolean;
    function getlightlist:clightlist;
  public
    function getIndex:integer;
    function getCopy:cnodeobject;override;
    function TypeString:string;override;
    procedure CopyTo(obj:cnodeobject);override;
    property state:boolean read getState write setState;
  end;

  clightlist = class(cIntVectorList)
  protected
    scene:tobject;
  public
    constructor create(p_scene:tobject);
    // �������� ����� �������� �����
    function AddLight:clight;
    // ������ �� ���������� � ������� �� ��������� � �����
    procedure setLights;
    // ������� �������� ����� ������ � �� ��������� ������������ � ��� ������
    procedure deleteLight(light:clight);
    // �������� �������� �� �������
    function getlight(index:integer):clight;
  end;


implementation
uses
  uSceneMng;

//---------------------------------------------------------------------
procedure glEnableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glDisableClientState (aarray: GLenum);
          stdcall; external OpenGL32;
//---------------------------------------------------------------------
procedure glLightModeli (n: GLEnum; u: GLuint);
          stdcall; external opengl32;

const
 GL_VERTEX_ARRAY  = $8074;
 GL_COLOR_ARRAY   = $8076;
 GL_Normal_ARRAY  = $8075;
 GL_TEXTURE_COORD_ARRAY = $8078;

 c_m_Ambient:array[0..3] of glfloat = (0.3,0.3,0.3,1);
 c_m_Diffuse:array[0..3] of glfloat = (0.7,0.7,0.7,1);
 c_Spec:array[0..3] of glfloat = (1,1,1,1);

function cLight.TypeString:String;
begin
  result:='����';
end;


function cLight.getlightlist:clightlist;
begin
  result:=cscene(getmng).lights;
end;

function cLight.getCopy:cnodeobject;
var obj:clight;
begin
  obj:= getlightlist.AddLight;
  copyto(obj);
  result:=obj;
end;

procedure cLight.CopyTo(obj:cnodeobject);
begin
  if obj is clight then
  begin
    inherited copyto(obj);
    clight(obj).m_Ambient:=m_Ambient;
    clight(obj).m_Diffuse:=m_Diffuse;
    // GL_Light0+i, ��� i - ����� ��������� (�� ����� 8)
  end;
end;

Constructor cLight.Create(id:cardinal;p_scene:tobject);
begin
  inherited create;
  objtype:=constLight;
  imageindex:=constLight;
  fHelper:=false;
  lightID:=id;
  Enable;
  m_Ambient[0]:=0.3; m_Ambient[1]:=0.3; m_Ambient[2]:=0.3; m_Ambient[3]:=1;
  m_Diffuse[0]:=0.7; m_Diffuse[1]:=0.7; m_Diffuse[2]:=0.7; m_Diffuse[3]:=1;
  m_specular[0]:=1; m_specular[1]:=1; m_specular[2]:=1; m_specular[3]:=1;
  glLightfv(lightID, GL_Ambient, @c_m_Ambient); // ���������� ���������� ����
  glLightfv(lightID, GL_Diffuse, @c_m_Diffuse); // ���������� ��������� ����
  glLightfv(lightID, GL_Specular, @c_Spec); // ���������� ��������� ����
  objtype:=constLight;
  SetObjToWorld;
end;

destructor cLight.destroy;
var i:integer;
begin
  // ��������� ����������
  disable;
  // ������� ������ �� �������� �� ������
  i:=lightID-GL_Light0;
  // ������� ������ �� �������� �� ������
  i:=getlightlist.GetIndex(@i);
  getlightlist.deleteIndObj(i);
  inherited;
end;

function cLight.getIndex:integer;
begin
  result:=self.lightID-GL_Light0;
end;

procedure cLight.setState(v:boolean);
begin
  if v then
    enable
  else
    disable;
end;

function cLight.getState:boolean;
var b:boolean;
begin
  glgetbooleanv(lightID,@b);
  result:=b;
end;

Procedure cLight.SetObjToWorld;
var
  pos:array [0..3] of glfloat;
  position:point3;
  TMtype:GLUInt;
begin
  inherited;
  {glGetIntegerv(gl_Matrix_Mode, @TMType);
  glMatrixMode(GL_Modelview);
  glPushMatrix;
  glloadidentity;}
  position:=getposition;
  // ������� ������, �� ���������� ����������
  // ����� ����� ������������� ���������� ����� ������������ �������� ���������
  // �������
  pos[0]:=position.x; pos[1]:=position.y; pos[2]:=position.z; pos[3]:=1;
  glLightfv(lightID,GL_Position,@pos);
  {glPopMatrix;
  if TMType = GL_PROJECTION then
    glMatrixMode(GL_PROJECTION);}
end;

Procedure cLight.Enable;
begin
  glEnable(lightID);
end;

Procedure cLight.Disable;
begin
  glDisable(lightID);
end;

Procedure cLight.Draw;
begin
  inherited;
end;

constructor clightlist.create(p_scene:tobject);
begin
  scene:=p_scene;
  sorted:=true;
end;

function clightlist.AddLight:cLight;
var i:integer;
    light:clight;
begin
  result:=nil;
  // ������� �������� �����, ��� ���� ����������� ���������� �� ����� ���� ������ 8
  for I := 0 to 7 do
  begin
    light:=clight(findObj(@i));
    if light=nil then
    begin
      light:=cLight.Create(GL_Light0+i,scene);
      AddObject(@i,light);
      result:=light;
      exit;
    end;
  end;
end;

function clightlist.getlight(index:integer):clight;
begin
  if index<count then
  begin
    result:=clight(getobj(index));
  end
  else
    result:=nil;
end;

procedure clightlist.deleteLight(light:clight);
var i:integer;
begin
  // ������� ��� ������
  light.destroy;
end;

procedure clightlist.setLights;
Var i:Integer;
    light:clight;
begin
  for I := 0 to Count - 1 do
  begin
    light:=getlight(i);
    light.SetObjToWorld;
  end;
end;

end.
