unit uObjectTypes;

interface

uses Mathfunction,opengl,windows,umatrix,uCommonTypes, u3dtypes;

type

  // ����� ������ -----------------------------------------------------
 cWindowContext = class
   Dc :hdc      ;//�������� ����������
   hrc:HGLRC    ;//�������� ��������������� Ogl
   Handle:Hwnd  ;//���������� ���� � ������� ���������� ���������
   Bound:Trect  ;//�������� ���� � ������� ����������� �����������
   axislength:single; // ����� ���� ��������� ��������    
   ClientWidth,ClientHeight:integer;
   color:point3;
 end;

const
  // --------------------- ����� �������
  DRAW_NODE = $0001; // �������� ������� ��������� ����
  DRAW_LOCAL = $0002; // �������� ������� ��������� ���������
  DRAW_NORMAL = $0004; // �������� �������
  draw_bound = $0008; // �������� �������������� �����
  draw_Parent = $0010; // �������� ������� ��������� ��������
  draw_Points = $0020; // �������� �������
  draw_Geom = $0040; // �������� ���������
  draw_Edges = $0080; // �������� ������
  DRAW_TARGET = $0100; // �������� ������� ��������� ����
  Use_Colors = $0100; // ������������ ����� �����
  DRAW_ALL = $00ff; // �������� ���
  // --------------------- ����� ������
  C_ACTIVECAMERA = $0200;

  ACTIVECAMERA = $1000;



  constmesh = 0;

  constLightImgIndex = 23;
  constcameraImgIndex = 22;
  constShapeImgIndex = 24;
  constdummyImgIndex = 3;

  // 0 - ���, 2 - ������, 4 - shape, 3 - dummy
  constLight = 23;
  constcamera = 2;
  constShape = 4;
  constdummy = 3;
  constQuatObject = 4;
  constNodeObject = 5;
  constlog = false;

  constWorld = 0;
  constNode = 1;
  constLocal = 2;
  constParent = 3;
  constView = 4;

// �������� boundbox �� �������
function MultBoundByM(b:tbound;m:matrixgl):tbound;

implementation


function MultBoundByM(b:tbound;m:matrixgl):tbound;
begin
  b.lo:=multp3bym(m,b.lo);
  b.hi:=multp3bym(m,b.hi);
  if b.lo.x<b.hi.x then
  begin
    result.lo.x:=b.lo.x;
    result.hi.x:=b.hi.x;
  end
  else
  begin
    result.lo.x:=b.hi.x;
    result.hi.x:=b.lo.x;
  end;
  //----------------------
  if b.lo.y<b.hi.y then
  begin
    result.lo.y:=b.lo.y;
    result.hi.y:=b.hi.y;
  end
  else
  begin
    result.lo.y:=b.hi.y;
    result.hi.y:=b.lo.y;    
  end;
  //----------------------
  if b.lo.z<b.hi.z then
  begin
    result.lo.z:=b.lo.z;
    result.hi.z:=b.hi.z;
  end
  else
  begin
    result.lo.z:=b.hi.z;
    result.hi.z:=b.lo.z;
  end;
end;


end.
