// http://wingman.org.ru/glsl/ уроки по шейдерам

unit uShader;

interface
uses
  Windows, SysUtils, Classes, dglOpengl;
  //glExt; // dglOpengl и glExt делфевые заголовки, должны
         //быть идентичны но, сука, отличаются
Type
  PGLCharARB = PChar;
  PPChar = Array of string;
 // Последовательность работы с шейдером:
 // 1) Создание, компиляция шейдера с CreateShader.
 // 2) Создание программы и прилинковка к программе CreateProgram.
 // 3) Использовать программу UseProgram.
 cShader = class
 private
   initGl:boolean; // OpenGl инициализирован
   name:string; // имя шейдера. Определяет имя файла
   b_vShader, b_fShader:boolean;
   m_vShader, // вершинный
   m_fShader, // фрагментный
   m_program:glHandleARB; // идентификаторы шейдеров и программы
 private
   procedure LoadShader(const src: ansiString; var shader:GLhandleARB);
   procedure LoadShaderFromFile(const filename: AnsiString; stype:byte);
 public
   constructor Create(path,pname:string);
  // Загрузить шейдер из файла.
  procedure CreateShader(const filename:string;const ShaderType:byte);
  // Отвязать шейдер от программы
  procedure DeleteShader(p_Program:GLhandleARB;p_Shader: GLhandleARB);
  // Создать и слинковать программу с шейдером.
  procedure CreateProgram;
  // Получить подробную информацию об ошибке
  function GetErrorInfo(obj:GLhandleARB):string;
  // Использовать программу шейдера.
  procedure UseProgram(use:boolean);
  // получить адрес uniform переменной с именем name
  function GetUniform(Name:PAnsiChar):GlInt;
  //function GetUniform(Name:PChar):GlInt;
  // Установить переменную uniform
  procedure SetUniformf(adr:GlInt;Val:GlFloat);
 end;

 cShaderManager = class
 public
    m_shaders:tStringList;
    ActiveShader:integer; // выделенный шейдер
    Active:boolean;       // признак, выключены ли шейдеры.
    constructor Create;
    destructor destroy;
    procedure EnableShader(name:string);
    procedure disableShaders;
    procedure add(shader:cshader);
    function getshader(name:string):cShader;
 public
   Procedure AddShader(folder:string;name:string);
 end;
implementation

Procedure cShaderManager.AddShader(folder:string;name:string);
var shader:cshader;
begin
  if DirectoryExists(folder) then
  begin
    shader:=cshader.Create(folder,name);
    add(shader);
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
  m_shaders.AddObject(shader.name,shader);
end;

function cShaderManager.getshader(name:string):cshader;
var index:integer;
begin
  result:=nil;
  if m_shaders.find(name,index) then
    result:=cshader(m_shaders.Objects[index]);
end;

Constructor cshader.Create(path,pname:string);
begin
 InitGl:=false;
 b_fShader:=false;
 b_vShader:=false;
 name:=pname;
 if path[length(path)]<>'\' then
 begin
   path:=path+'\';
 end;
 pname:=path + name + '.frag';
 if FileExists(pname) then
   CreateShader(pname,1); // Загрузка пиксельного шейдера
 pname:=path + name + '.vert';
 if FileExists(pname) then
   CreateShader(path + name + '.vert',0); // Загрузка вершинного шейдера
 CreateProgram;
end;

// Получить строку с ошибкой компиляции шейдера
function GetInfoLog(s: GLhandleARB): String;
var
  blen, slen: Integer;
  infolog: array of Char;
begin
  glGetObjectParameterivARB(s, GL_OBJECT_INFO_LOG_LENGTH_ARB, @blen);
  if blen > 1 then
  begin
    SetLength(infolog, blen);
//  glGetInfoLogARB(s, blen, @slen, @infolog[0]); // GLext
    glGetInfoLogARB(s, blen, slen, @infolog[0]); // //dglOpenGl
    Result := String(infolog);
    Exit;
  end;
  Result := '';
end;

// Загрузить шейдер из файла
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

// Загрузить шейдер, и скомпилять. Если не удается то выпленуть ошибку.
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
// ============================== Описание класса шейдера ==================
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
  glDetachObjectARB(p_program,p_shader);// отсоединить шейдер от программы
  glDeleteObjectARB(p_shader);// удаление шейдера.
end;

procedure cShader.CreateProgram;
var
  linked: Integer;
  log: String;
begin
  m_program:=glCreateProgramObjectARB;
  if m_vShader<>0 then
    glAttachObjectARB(m_program,m_vShader); // присоединить шейдер к программе
  if m_fShader<>0 then
    glAttachObjectARB(m_program,m_fShader); // присоединить шейдер к программе
  glLinkProgramARB(m_program);// слинковать программу
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
 if use then glUseProgramObjectARB(m_program)
 else glUseProgramObjectARB(0);
end;

// =========================================================================
// ======================== Вспомогательные функции ========================
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
