unit uLineLgShader;

interface

uses
  Windows, SysUtils, Classes, dglOpengl, uShader;

Type
  PGLCharARB = PChar;
  PPChar = Array of string;

  cLineLgShader = class (cShader)
  public
    // id Uniform ���������� ��� ���������������� ������� �� ���� x,xmax,y,ymax
    aLocation:integer;
    // id Uniform ���������� ��� ���������������� ������� lgx, lgy
    aLocLg:integer;
  public
    // ��������� ��� ��������� ������� ����������������
    procedure BindLgShaderData;
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
  // �������� ������ ��������������� ��� ������ �������
  //aLocation := glGetAttribLocation(sh.m_program, ls);
  //glVertexAttribPointer(aLocation, 4, GL_FLOAT, false, 0, @vertexData[0]);
  //glEnableVertexAttribArray(aLocation);
  //UseProgram(true);
  aLocation:=glGetUniformLocation(m_program,ls);
  astr:='a_Lg';
  ls:=lpcstr(astr);
  aLocLg:=glGetUniformLocation(m_program,ls);
end;

end.
