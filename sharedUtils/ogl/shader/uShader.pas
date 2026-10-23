// http://wingman.org.ru/glsl/ уроки по шейдерам

unit uShader;

interface
uses
  Windows, SysUtils, Classes, dglOpengl;
  //glExt; // dglOpengl и glExt делфевые заголовки, должны
         //быть идентичны но, сука, отличаются
Type
  cShaderManager = class;
  PGLCharARB = PChar;
  PPChar = Array of string;
 // Последовательность работы с шейдером:
 // 1) Создание, компиляция шейдера с CreateShader.
 // 2) Создание программы и прилинковка к программе CreateProgram.
 // 3) Использовать программу UseProgram.
 cShader = class
 public
   mng: cShaderManager;
   m_program:glHandleARB; // идентификаторы шейдеров и программы
 private
   m_active:boolean;
   name:string; // имя шейдера. Определяет имя файла
   b_vShader, b_fShader:boolean;
   m_vShader, // вершинный
   m_fShader: glHandleARB; // фрагментный
   // результаты компиляции этапов и линковки программы
   m_vCompiled,
   m_fCompiled,
   m_linked: boolean;
   m_error: string;
 private
   procedure LoadShader(const src: ansiString; var shader:GLhandleARB);
   procedure LoadShaderFromFile(const filename: AnsiString; stype:byte);
 public
  // программа скомпилирована и слинкована, её можно включать в отрисовку
  property Ready: boolean read m_linked;
  // текст последней ошибки компиляции/линковки (для журнала)
  property LastError: string read m_error;
  constructor Create(path,pname:string);
  // Загрузить шейдер из файла.
  procedure CreateShader(const filename:string;const ShaderType:byte);
  // Отвязать шейдер от программы
  procedure DeleteShader(p_Program:GLhandleARB;p_Shader: GLhandleARB);virtual;
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
    m_Extensions:PAnsiChar;
    m_ExtSupported:boolean;
    // макс число аттрибутов
    m_MaxVertsAttr:integer;


    m_shaders:tStringList;
    ActiveShader:integer; // выделенный шейдер
    Active:boolean;       // признак, выключены ли шейдеры.
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

var
  // Разрешить рантайм-проверку glGetError после установки uniform-ов (по умолчанию
  // выключена): внутри glNewList команды шейдеров сами по себе могут давать
  // GL_INVALID_OPERATION на части драйверов, хотя отрисовка при этом исправна.
  // Включать true только для разбора проблем на конкретной машине.
  g_ShaderCheckGlErrors: boolean = false;

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

  // Строки расширений недостаточно: она говорит о наличии API, но не о том,
  // что реально доступны вызываемые функции. Поэтому дополнительно требуем
  // наличие точек входа, которые использует отрисовка трендов. glUniform2i и
  // glUniform4f - это уже GL 2.0, а не ARB-варианты, и именно их отсутствие
  // даёт "шейдер включён, но не работает" на части драйверов.
  m_ExtSupported :=
    (Pos('GL_ARB_shader_objects', m_Extensions)>0) and
    Assigned(glCreateShaderObjectARB) and
    Assigned(glShaderSourceARB) and
    Assigned(glCompileShaderARB) and
    Assigned(glGetObjectParameterivARB) and
    Assigned(glCreateProgramObjectARB) and
    Assigned(glAttachObjectARB) and
    Assigned(glLinkProgramARB) and
    Assigned(glUseProgramObjectARB) and
    Assigned(glGetUniformLocationARB) and
    Assigned(glUniform1fARB) and
    Assigned(glUniform2i) and
    Assigned(glUniform4f);
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
 m_vCompiled:=false;
 m_fCompiled:=false;
 m_linked:=false;
 m_error:='';
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

// Загрузить шейдер из файла
procedure cShader.LoadShaderFromFile(const filename: ansiString; stype:byte);
var
  txt: TStringList;
begin
  txt := TStringList.Create;
  try
    try
      txt.LoadFromFile(filename);
      if stype = 0 then
      begin
         b_vShader:=true;
         LoadShader(txt.Text, m_vShader);
         m_vCompiled:=m_vShader<>0;
      end
      else
      begin
         b_fShader:=true;
         LoadShader(txt.Text, m_fShader);
         m_fCompiled:=m_fShader<>0;
      end;
    except
      on E: Exception do
      begin
        // ошибку не бросаем: LoadShaders проверит Ready и откатится на fixed-function
        if m_error<>'' then
          m_error:=m_error+#13#10;
        m_error:=m_error+filename+': '+E.Message;
        if stype = 0 then
        begin
          b_vShader:=true;
          m_vCompiled:=false;
        end
        else
        begin
          b_fShader:=true;
          m_fCompiled:=false;
        end;
      end;
    end;
  finally
    txt.Free;
  end;
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
    // ошибку не бросаем: LoadShaders проверит Ready и откатится на fixed-function
    if m_error<>'' then
      m_error:=m_error+#13#10;
    m_error:=m_error+log;
    shader:=0;
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
  glDeleteProgramsARB(1, @m_program);
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
  // Программа годна, если слинковалась и все фактически загруженные этапы
  // скомпилировались. Исключение не бросаем: решение принимает вызывающая
  // сторона (cChart.LoadShaders) - при Ready=false остаётся обычная отрисовка.
  m_linked:=((linked = 1) and
            ((not b_vShader) or m_vCompiled) and
            ((not b_fShader) or m_fCompiled));
  if (not m_linked) and (log <> '') then
    m_error:=m_error+#13#10+log;
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
