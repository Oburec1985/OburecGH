// http://wingman.org.ru/glsl/ ����� �� ��������

unit uShader;

interface
uses
  Windows, SysUtils, Classes, dglOpengl;
  //glExt; // dglOpengl � glExt �������� ���������, ������
         //���� ��������� ��, ����, ����������
Type
  cShaderManager = class;
  PGLCharARB = PChar;
  PPChar = Array of string;
 // ������������������ ������ � ��������:
 // 1) ��������, ���������� ������� � CreateShader.
 // 2) �������� ��������� � ����������� � ��������� CreateProgram.
 // 3) ������������ ��������� UseProgram.
 cShader = class
 public
   mng: cShaderManager;
   m_program:glHandleARB; // �������������� �������� � ���������
 private
   m_active:boolean;
   name:string; // ��� �������. ���������� ��� �����
   b_vShader, b_fShader:boolean;
   m_vShader, // ���������
   m_fShader // �����������
   :glHandleARB;
 private
   procedure LoadShader(const src: ansiString; var shader:GLhandleARB);
   procedure LoadShaderFromFile(const filename: AnsiString; stype:byte);
 public
  constructor Create(path,pname:string);
  // ��������� ������ �� �����.
  procedure CreateShader(const filename:string;const ShaderType:byte);
  // �������� ������ �� ���������
  procedure DeleteShader(p_Program:GLhandleARB;p_Shader: GLhandleARB);virtual;
  // ������� � ���������� ��������� � ��������.
  procedure CreateProgram;
  // �������� ��������� ���������� �� ������
  function GetErrorInfo(obj:GLhandleARB):string;
  // ������������ ��������� �������.
  procedure UseProgram(use:boolean);
  // �������� ����� uniform ���������� � ������ name
  function GetUniform(Name:PAnsiChar):GlInt;
  //function GetUniform(Name:PChar):GlInt;
  // ���������� ���������� uniform
  procedure SetUniformf(adr:GlInt;Val:GlFloat);
 end;

 cShaderManager = class
 public
    m_Extensions:PAnsiChar;
    m_ExtSupported:boolean;
    // ���� ����� ����������
    m_MaxVertsAttr:integer;


    m_shaders:tStringList;
    ActiveShader:integer; // ���������� ������
    Active:boolean;       // �������, ��������� �� �������.
    constructor Create;
    destructor destroy;
    procedure EnableShader(name:string);
    procedure disableShaders;
    procedure add(shader:cshader);
    function getshader(name:string):cShader;overload;
    function getshader(i:integer):cShader;overload;
 public
   procedure GetInfo;
   function AddShader(folder:string;name:string):cshader;
 end;
implementation

function cShaderManager.AddShader(folder:string;name:string):cshader;
var shader:cshader;
begin
  result:=nil;
  if DirectoryExists(folder) then
  begin
    shader:=cshader.Create(folder,name);
    add(shader);
    result:=shader;
  end;
end;

procedure cShaderManager.enableShader(name:string);
var shader:cshader;
begin
  if m_shaders.find(name,ActiveShader) then
  begin
    shader:=cshader(m_shaders.Objects[ActiveShader]);
    shader.useprogram(true);
    active:=true;
  end;
end;

procedure cShaderManager.GetInfo;
var
  Attr:GLint;
begin
  glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, @Attr);
  m_MaxVertsAttr:=Attr;

  m_Extensions := glGetString(GL_EXTENSIONS);

  if Pos('GL_ARB_shader_objects', m_Extensions)>0 then
  begin
    m_ExtSupported:=true;
  end
  else
    m_ExtSupported:=false;
end;

procedure cShaderManager.disableShaders;
var shader:cshader;
begin
  if active then
  begin
    shader:=cshader(m_shaders.Objects[ActiveShader]);
    shader.useprogram(false);
    active:=false;
  end;
end;

function IsExtensionSupported(const Extension: AnsiString): Boolean;
var
  ExtList: AnsiString;
begin
  ExtList := glGetString(GL_EXTENSIONS);
  Result := Pos(Extension, ExtList) > 0;
end;


Constructor cShaderManager.Create;
begin
  m_shaders:=tStringList.Create;
end;

destructor cShaderManager.destroy;
var i:integer;
    shader:cshader;
begin
  for I := 0 to m_shaders.Count - 1 do
  begin
    shader:=cshader(m_shaders.Objects[i]);
    shader.Destroy;
  end;
  m_shaders.Destroy;
end;

procedure cShaderManager.add(shader:cshader);
begin
  shader.mng:=self;
  m_shaders.AddObject(shader.name,shader);
end;

function cShaderManager.getshader(name:string):cshader;
var index:integer;
begin
  result:=nil;
  if m_shaders.find(name,index) then
    result:=cshader(m_shaders.Objects[index]);
end;

function cShaderManager.getshader(i:integer):cshader;
begin
  result:=cshader(m_shaders.Objects[i]);
end;

Constructor cshader.Create(path,pname:string);
begin
 b_fShader:=false;
 b_vShader:=false;
 name:=pname;
 if path[length(path)]<>'\' then
 begin
   path:=path+'\';
 end;
 pname:=path + name + '.frag';
 if FileExists(pname) then
   CreateShader(pname,1); // �������� ����������� �������
 pname:=path + name + '.vert';
 if FileExists(pname) then
   CreateShader(path + name + '.vert',0); // �������� ���������� �������
 CreateProgram;
end;

// �������� ������ � ������� ���������� �������
function GetInfoLog(s: GLhandleARB): String;
var
  blen, slen: Integer;
  infolog: array of ansiChar;
  I: Integer;
begin
  glGetObjectParameterivARB(s, GL_OBJECT_INFO_LOG_LENGTH_ARB, @blen);
  if blen > 1 then
  begin
    SetLength(infolog, blen);
//  glGetInfoLogARB(s, blen, @slen, @infolog[0]); // GLext
    glGetInfoLogARB(s, blen, slen, @infolog[0]); // //dglOpenGl
    setlength(Result,blen );
    for I := 0 to blen - 1 do
    begin
      Result[i+1]:=char(infolog[i]);
    end;
    Exit;
  end;
  Result := '';
end;

// ��������� ������ �� �����
procedure cShader.LoadShaderFromFile(const filename: ansiString; stype:byte);
var
  txt: TStringList;
begin
  txt := TStringList.Create;
  txt.LoadFromFile(filename);
  try
    if stype = 0 then
    begin
       b_vShader:=true;
       LoadShader(txt.Text, m_vShader);
    end
    else
    begin
       b_fShader:=true;
       LoadShader(txt.Text, m_fShader);
    end;
  except on E: Exception do
    raise Exception.Create(filename + ' contains errors!' + #10 + e.Message);
  end;
  txt.Free;
end;

// ��������� ������, � ����������. ���� �� ������� �� ��������� ������.
procedure cShader.LoadShader(const src: ansiString; var shader:GLhandleARB);
var
  source: PAnsiChar;
  compiled,len: GlInt;
  log: String;
begin
  source := PAnsiCHar(@src[1]);
  len:=length(src);
  glShaderSourceARB(shader, 1, @source, @len);
  glCompileShaderARB(shader);
  glGetObjectParameterivARB(shader, GL_OBJECT_COMPILE_STATUS_ARB, @compiled);
  log := GetInfoLog(shader);
  if compiled <> 1 then
  begin
    raise Exception.Create(log);
  end;
end;

// =========================================================================
// ============================== �������� ������ ������� ==================
// =========================================================================

procedure cShader.CreateShader(const filename:string;const ShaderType:byte);
begin
  if shaderType =0 then
  begin
    m_vShader:=glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
    LoadShaderFromFile(filename,0);
  end
  else
  begin
    m_fShader:=glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
    LoadShaderFromFile(filename,1);
  end;
end;

procedure cShader.DeleteShader(p_program:GLhandleARB;p_Shader:GLhandleARB);
begin
  glDetachObjectARB(p_program,p_shader);// ����������� ������ �� ���������
  glDeleteObjectARB(p_shader);// �������� �������.
  glDeleteProgramsARB(1, @m_program);
end;

procedure cShader.CreateProgram;
var
  linked: Integer;
  log: String;
begin
  m_program:=glCreateProgramObjectARB;
  if m_vShader<>0 then
    glAttachObjectARB(m_program,m_vShader); // ������������ ������ � ���������
  if m_fShader<>0 then
    glAttachObjectARB(m_program,m_fShader); // ������������ ������ � ���������
  glLinkProgramARB(m_program);// ���������� ���������
  glGetObjectParameterivARB(m_program,GL_OBJECT_LINK_STATUS_ARB,@linked);
  log := GetInfoLog(m_program);
  if linked <> 1 then
    raise Exception.Create(log);
end;

function cShader.GetErrorInfo(obj:GLhandleARB):string;
var maxlen,len:Integer;
    //log:GlChar;//glext
    log:PAnsiChar;
    //log:PChar;
begin
 maxLen:=0;Len:=0;
 glGetObjectParameterivARB(obj,GL_OBJECT_INFO_LOG_LENGTH_ARB,@maxlen);
 if maxLen>0 then
//   glGetInfoLogARB(obj,maxLen,@len,@log);//glext
    glGetInfoLogARB(obj,maxLen,len,log);//dglOpenGl
 Result:=log;
end;

procedure cShader.UseProgram(use:boolean);
begin
  m_active:=use;
 if use then
   glUseProgramObjectARB(m_program)
 else
   glUseProgramObjectARB(0);
end;

// =========================================================================
// ======================== ��������������� ������� ========================
// =========================================================================
function cShader.GetUniform(Name:PAnsiChar):GlInt;
//function cShader.GetUniform(Name:PChar):GlInt;
begin
  Result := glGetUniformLocationARB(m_program,Name);
end;

procedure cShader.SetUniformf(adr:GlInt;Val:GlFloat);
begin
  glUniform1fARB(adr,Val);
end;


end.
