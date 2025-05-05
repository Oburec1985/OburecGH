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
  // ���������� ����� ����������� ������ l1,l2 � ������� ������������ ����� ���������������� ���������
  // ���������� ��� ����������� � ������ �� ���������, ����� ������������ ���������� ��������� � �������������� ����� ����������� ������ l1, l2
  // res = -1 ���� ����������� �� ���� ��� ���������� ����� �������� � ������� ���� �����������
  function lineCrossBound(b_lo, b_hi, l_start, l_end: point3;  var res: integer): point3;


implementation

function getBoundCenter(b:tbound;var c:point3):boolean;
var
  v1,v2,v3,v4:point3;
begin
  // ������� ����� ����������� ���������� ������
  V1:=b.lo; V2:=b.hi; V3:=p3(b.lo.x, b.lo.y, b.hi.z); V4:=p3(b.hi.x, b.hi.y, b.lo.z);
  result:=LineCrossLine(V1,V2,V3,V4,c);
end;


function lineCrossBound(b_lo, b_hi, l_start, l_end: point3;
  var res: integer): point3;
var
  c, // ����� ����������
  view, // ������ ������ ������
  // bottom poly
  p1, p2, p3, p4,
  // top poly
  p5, p6, p7, p8, cross1, Cross, // ����� �����������
  v // ������ �� ������ � cross
    : point3;
  b: tbound;
  count, // ����� �����������
  i, ifirst: integer; // ����� �������� � ������� ���� ������ �����������
  insidebox, bool: boolean;
  l1, l2: single;
begin
  c.x := 0.5 * (b_hi.x + b_lo.x);
  c.y := 0.5 * (b_hi.y + b_lo.y);
  c.z := 0.5 * (b_hi.z + b_lo.z);
  // ���� ������ �������
  p1 := b_lo;
  p2 := p1;
  p2.x := b_hi.x;
  p3 := p1;
  p2.z := b_hi.z;
  p4 := p2;
  p2.z := b_hi.z;
  // ������� ����
  p5 := p1;
  p5.y := b_hi.y;
  p6 := p2;
  p6.y := b_hi.y;
  p7 := p3;
  p7.y := b_hi.y;
  p8 := b_hi;
  view := subVector(l_end, l_start);
  NormalizeVectorP3(view);
  b.lo := b_lo;
  b.hi := b_hi;
  // insidebox:=insideBox3d(l_start, b);
  // ���� �������
  count := 0;
  ifirst := -1;
  bool := LineCrossPoly(l_start, l_end, p1, p5, p6, p2, Cross);
  if bool then
  begin
    inc(count);
    cross1 := Cross;
    i := 0;
    v := subVector(c, Cross);
    l1 := VectorLength(v);
    ifirst := 0;
  end;
  bool := LineCrossPoly(l_start, l_end, p1, p5, p7, p3, Cross);
  if bool then
  begin
    inc(count);
    i := 1;
    v := subVector(c, Cross);
    if ifirst > -1 then
    begin
      cross1 := Cross;
      l1 := VectorLength(v)
    end
    else
    begin
      l2 := VectorLength(v);
      ifirst := i;
    end;
  end;
  bool := LineCrossPoly(l_start, l_end, p3, p7, p8, p4, Cross);
  if bool then
  begin
    inc(count);
    i := 2;
    v := subVector(c, Cross);
    if ifirst > -1 then
    begin
      cross1 := Cross;
      l1 := VectorLength(v)
    end
    else
    begin
      l2 := VectorLength(v);
      ifirst := i;
    end;
  end;
  bool := LineCrossPoly(l_start, l_end, p2, p6, p8, p4, Cross);
  if bool then
  begin
    inc(count);
    i := 3;
    v := subVector(c, Cross);
    if ifirst > -1 then
    begin
      cross1 := Cross;
      l1 := VectorLength(v)
    end
    else
    begin
      l2 := VectorLength(v);
      ifirst := i;
    end;
  end;
  bool := LineCrossPoly(l_start, l_end, p5, p7, p8, p6, Cross);
  if bool then
  begin
    inc(count);
    i := 4;
    v := subVector(c, Cross);
    if ifirst > -1 then
    begin
      cross1 := Cross;
      l1 := VectorLength(v)
    end
    else
    begin
      l2 := VectorLength(v);
      ifirst := i;
    end;
  end;
  bool := LineCrossPoly(l_start, l_end, p1, p3, p4, p2, Cross);
  if bool then
  begin
    inc(count);
    i := 5;
    v := subVector(c, Cross);
    if ifirst > -1 then
    begin
      cross1 := Cross;
      l1 := VectorLength(v)
    end
    else
    begin
      l2 := VectorLength(v);
      ifirst := i;
    end;
  end;
  res := -1;
  if count > 0 then
  begin
    res := i;
    if count = 1 then
    begin
      result := cross1;
    end
    else
    begin
      if l1 < l2 then
        result := cross1
      else
        result := Cross;
    end;
  end;
end;

end.
