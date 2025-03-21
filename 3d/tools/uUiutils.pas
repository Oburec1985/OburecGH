unit uUIutils;
interface
uses
  uRender, inifiles, MathFunction, SysUtils, ufileMng,
  windows, classes, dialogs, pathutils, uCommonTypes, opengl;

  // ��������� UI � ���������������� ����. ��� ����� ���������� ������ ������ UI
  procedure saveUI(UI:tobject);
  // ��������� UI � ���������������� ����. ��� ����� ���������� ������ ������ UI
  procedure loadUI(UI:tobject);
  // ����������� ���������� ���� � ���������� ����
  procedure WorldToScr(p3:point3;ViewMatrix:matrixgl;var winx:integer;var winy:integer;var winz:integer);
  // ����� �������� ������� ����������� ���� ��������� ����������� dx, dy ��
  // ������ ��� �������� �������� (1 - x, 2 - y, 3 - z) � �������� ��������� ��� � ���� m
  function GetProjection(dx,dy:integer;m:matrixgl;axis:integer;axislen:single):point3;
  // �������� ����������� ������� � ������� ������� �������������� � ������� x,y
  function GetDir(x,y:integer):point3;

implementation
uses
  uUI, uSceneMng;

const
  constWindowStyle = 'WindowStyle';
  constControlConfig = 'ControlConfig';
  defaultpath = '.\files\UICfg.ini';

  axisX:point3 = (x:1;y:0;z:0);
  axisY:point3 = (x:0;y:1;z:0);
  axisZ:point3 = (x:0;y:0;z:1);
  axisO:point3 = (x:0;y:0;z:0);

function GetDir(x,y:integer):point3;
var
  viewport:array [0..3] of glint;
  modelview, projection:array [0..15] of gldouble; // ������� ��������.
  vx,vy,vz:glfloat; // ���������� ������� ���� � ������� ��������� viewport-a.
  wx,wy,wz:gldouble; // ������������ ������� ����������.
begin
  // x, y , width, height;
  glGetIntegerv(GL_VIEWPORT,@viewport);           // ����� ��������� viewport-a.
  glGetDoublev(GL_PROJECTION_MATRIX,@projection); // ����� ������� ��������.
  glGetDoublev(GL_MODELVIEW_MATRIX,@modelview);   // ����� ������� �������.

  // ��������� ������� ���������� ������� � ������� ��������� viewport-a.
  vx := x;
  vy := viewport[3] - y - 1; // ��� height - ������� ������ ����.
  // ��������� ������� ����� �������������� �������.
  vz := 1;

  gluUnProject(vx, vy, vz, @modelview, @projection, @viewport, wx, wy, wz);
  result.x := wx;  result.y := wy;  result.z := wz;
  NormalizeVectorP3(result);
end;

function GetProjection(dx,dy:integer;m:matrixgl;axis:integer;axislen:single):point3;
var
  x1,y1,z1,
  x2,y2,z2,
  x,y,z:integer;
  p3:point3;

  dx1,dy1,dx2,dy2,
  len1,len2,len,cos:single;
begin
  if ((dx=0) and (dy=0)) or (axis<=0) then
  begin
    result:=axiso;
    exit;
  end;
  axis:=axis;
  p3:=axisO;
  // ������� ����� ������� ���������� ��� �� ������
  WorldToScr(p3, m, x1, y1, z1);
  len:=AxisLen;
  p3:=getaxis(len,axis);
  WorldToScr(p3,m,x2,y2,z2);
  x:=x2-x1; y:=y2-y1; z:=z2-z1;
  // ������� ����� ������� ����������� �� ������
  len1:=sqrt(dx*dx+dy*dy);
  dx1:=dx/len1; dy1:=dy/len1;
  len2:=sqrt(x*x+y*y);
  dx2:=x/len2; dy2:=y/len2;
  cos:=(dx1*dx2+dy1*dy2);
  // ��������� �������� �������� ���� �� ���
  len1:=len1*cos/len2;
  p3:=getaxis(len1*len,axis);
  result:=p3;
end;


procedure saveUI(UI:tobject);
var ifile:tIniFile;
    str:string;
    fullpath:string;
begin
  setcurrentdir(cui(ui).ConfigFile.startdir);
  if not fileexists(cui(ui).ConfigFile.UIconfigname) then
    str:=defaultpath
  else
    str:=cui(ui).ConfigFile.UIconfigname;
  if not fileexists(str) then
  begin
    str:=RelativePathToAbsolute(cui(ui).ConfigFile.startdir,str);
    showmessage('��������� ������� ��������� ������������ cUInterface � ���� ' + str);
    exit;
  end;
  ifile:=tinifile.Create(str);
  // ������ ����� BackGraund-�
  ifile.Writefloat(constWindowStyle,'BackGNDColorR',cui(ui).m_RenderScene.m_wndContext.color.x);
  ifile.Writefloat(constWindowStyle,'BackGNDColorG',cui(ui).m_RenderScene.m_wndContext.color.y);
  ifile.Writefloat(constWindowStyle,'BackGNDColorB',cui(ui).m_RenderScene.m_wndContext.color.z);
  // ������ ����� BoundBox-�
  ifile.Writefloat(constWindowStyle,'BoundColorR',cui(ui).m_RenderScene.boundColor.x);
  ifile.Writefloat(constWindowStyle,'BoundColorG',cui(ui).m_RenderScene.boundColor.y);
  ifile.Writefloat(constWindowStyle,'BoundColorB',cui(ui).m_RenderScene.boundColor.z);
  // ������ ����� ���������������� �������� � �����������
  ifile.Writefloat(constControlConfig,'RotSens',cui(ui).mouse.m_RotSens);
  ifile.Writefloat(constControlConfig,'MoveSens',cui(ui).mouse.m_MoveSens);
  ifile.destroy;
end;

procedure loadUI(UI:tobject);
var
  ifile:tIniFile;
  d:double;
  str:string;
begin

  if not fileexists(cui(ui).ConfigFile.UIconfigname) then
    exit;
  ifile:=tinifile.Create(cui(ui).ConfigFile.UIconfigname);
  // ������ ����� BackGraund-�
  str:=ifile.ReadString(constWindowStyle,'BackGNDColorR',
                '0');
  d:=strtofloat(str);
  cui(ui).m_RenderScene.m_wndContext.color.x:=d;
  d:=ifile.Readfloat(constWindowStyle,'BackGNDColorG',
                cui(ui).m_RenderScene.m_wndContext.color.y);
  cui(ui).m_RenderScene.m_wndContext.color.y:=d;
  d:=ifile.Readfloat(constWindowStyle,'BackGNDColorB',
                cui(ui).m_RenderScene.m_wndContext.color.z);
  cui(ui).m_RenderScene.m_wndContext.color.z:=d;
  // ������ ����� BoundBox-�
  d:=ifile.Readfloat(constWindowStyle,'BoundColorR',
                                    cui(ui).m_RenderScene.boundColor.x);
  cui(ui).m_RenderScene.boundColor.x:=d;
  d:=ifile.Readfloat(constWindowStyle,'BoundColorG',
                                    cui(ui).m_RenderScene.boundColor.y);
  cui(ui).m_RenderScene.boundColor.y:=d;
  d:=ifile.Readfloat(constWindowStyle,'BoundColorB',
                                    cui(ui).m_RenderScene.boundColor.z);
  cui(ui).m_RenderScene.boundColor.z:=d;
  // ������ ����� ���������������� �������� � �����������
  d:=ifile.Readfloat(constControlConfig,'RotSens',cui(ui).mouse.m_RotSens);
  cui(ui).mouse.m_RotSens:=d;
  d:=ifile.Readfloat(constControlConfig,'MoveSens',cui(ui).mouse.m_MoveSens);
  cui(ui).mouse.m_MoveSens:=d;
  ifile.destroy;
end;

procedure WorldToScr(p3:point3;ViewMatrix:matrixgl;var winx:integer;var winy:integer;var winz:integer);
var
  viewport:array [0..3] of glint;
  px,py,pz:double;
  projection:array [0..15] of gldouble; // ������� ��������.
  modelview:array [0..15] of gldouble; // ������� ��������.
  I: Integer; // ������������ ������� ����������.
  wx,wy,wz:gldouble;
begin
  glGetIntegerv(GL_VIEWPORT,@viewport); // ����� ��������� viewport-a.
  glgetdoublev(gl_projection_matrix,@projection);
  // ��������� ������� ���������� ������� � ������� ��������� viewport-a.
  for I := 0 to 15 do
  begin
    modelview[i]:=ViewMatrix[i];
  end;
  px:=p3.x; py:=p3.y; pz:=p3.z;
  gluProject(px, py, pz, @modelview, @projection, @viewport, wx, wy, wz);
  winx:=trunc(wx); winy:=trunc(wy); winz:=trunc(wz);
end;

end.
