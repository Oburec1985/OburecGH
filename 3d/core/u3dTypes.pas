unit u3dTypes;

interface
uses
  windows, ucommontypes, mathfunction;
type
  tbound = record
    exist:boolean;
    lo,hi:point3;
  end;

  TWndContext = record
    Dc :hdc;//�������� ����������
    hrc:HGLRC;//�������� ��������������� Ogl
    Handle:Hwnd;//���������� ���� � ������� ���������� ���������
    Bound:Trect;//�������� ���� � ������� ����������� �����������
    ClientWidth,
    ClientHeight:integer;
    axislength:single;
    color:point3;
  end;

  MouseStruct = record
    rect:trect; // ���������� ������ � ���������� ����������� ������
    // ������ ����� ������ ����
    LButtonDown:boolean;
    // ���������� ������� ������ ����
    LButtonPos:tpoint;
    cx, cy, dx, dy, x,y:integer; // ���������� ���������� ���� ������ ����
    m_bChangeX,m_bChangeY:boolean;
    m_strafe:point3;
    m_RotSens,m_MoveSens:single;// ���������������� ��� �������� ������.
    wheel:short;
  end;

  function getBoundCenter(b:tbound;var c:point3):boolean;

implementation

function getBoundCenter(b:tbound;var c:point3):boolean;
var
  v1,v2,v3,v4:point3;
begin
  // ������� ����� ����������� ���������� ������
  V1:=b.lo; V2:=b.hi; V3:=p3(b.lo.x, b.lo.y, b.hi.z); V4:=p3(b.hi.x, b.hi.y, b.lo.z);
  result:=LineCrossLine(V1,V2,V3,V4,c);
end;

end.
