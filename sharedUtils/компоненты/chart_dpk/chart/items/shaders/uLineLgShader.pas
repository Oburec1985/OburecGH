unit uLineLgShader;

interface

uses
  Windows, SysUtils, Classes, dglOpengl, uShader;

Type
  PGLCharARB = PChar;
  PPChar = Array of string;

  cLineLgShader = class (cShader)
  public
    // id Uniform переменной для логарифмического шейдера по осям x,xmax,y,ymax
    aLocation:integer;
    // id Uniform переменной для логарифмического шейдера lgx, lgy
    aLocLg:integer;
  public
    // процедуры для рисования шейдера логарифмирования
    procedure BindLgShaderData;
  end;

  // шейдер для рисования линии 1d
  cLineLgShader1d = class (cShader)
  public
    // id Uniform переменной для логарифмического шейдера по осям x,xmax,y,ymax
    aLocation:integer;
    // id Uniform переменной для логарифмического шейдера lgx, lgy
    aLocLg:integer;
    // id Uniform переменной для параметров тренда x0, dx
    aLocLineParams:integer;
    // id Uniform переменной для данных
    //aLocLineBuff:integer;

    m_VBO, // id вершинного буфера
    m_VAO: GLuint; // id буфера аттрибутов вершин
  protected
  public
    procedure DeleteShader(p_Program:GLhandleARB;p_Shader: GLhandleARB);override;
    // процедуры для рисования шейдера логарифмирования
    procedure BindLgShaderData;
    procedure VBOFree;
  end;


implementation

{ cLineLgShader }
procedure cLineLgShader.BindLgShaderData;
var
  astr:ansistring;
  ls:lpcstr;
begin
  astr:='a_minmax';
  ls:=lpcstr(astr);
  // атрибуты должны устанавливаться для каждой вершины
  //aLocation := glGetAttribLocation(sh.m_program, ls);
  //glVertexAttribPointer(aLocation, 4, GL_FLOAT, false, 0, @vertexData[0]);
  //glEnableVertexAttribArray(aLocation);
  //UseProgram(true);
  aLocation:=glGetUniformLocation(m_program,ls);
  astr:='a_Lg';
  ls:=lpcstr(astr);
  aLocLg:=glGetUniformLocation(m_program,ls);
end;

{ cLineLgShader1d }

procedure cLineLgShader1d.BindLgShaderData;
var
  astr:ansistring;
  ls:lpcstr;
begin
  astr:='a_minmax';
  ls:=lpcstr(astr);
  aLocation:=glGetUniformLocation(m_program,ls);
  astr:='a_Lg';
  ls:=lpcstr(astr);
  aLocLg:=glGetUniformLocation(m_program,ls);
  astr:='a_LinePar';
  ls:=lpcstr(astr);
  aLocLineParams:=glGetUniformLocation(m_program,ls);
  //astr:='a_LineBuff';
  //ls:=lpcstr(astr);
  //aLocLineBuff:=glGetUniformLocation(m_program,ls);
  glgenBuffers(1, @m_VBO);
  glGenVertexArrays(1, @m_VAO);
end;

procedure cLineLgShader1d.DeleteShader(p_Program, p_Shader: GLhandleARB);
begin
  inherited;
  VBOFree;
end;

procedure cLineLgShader1d.VBOFree;
begin
  glBindBuffer( GL_ARRAY_BUFFER, 0 );
  glDeleteBuffers(1,@m_VBO);
  glDeleteVertexArrays(1,@m_VAO);
end;

end.
