unit uCommonTypes;

interface

uses classes, types, windows, sysutils;

type
  // ��� ������������
  TPType = (ptNullPoly, ptlinePoly, ptCubePoly);

  cpoint2d = class
  public
    x, y: double;
  end;

  point2 = record
    x, y: single;
  end;

  point2i2 = record
    x, y: int16;
  end;

  pPoint2d = ^point2d;

  point2d = record
    x, y: double;
  end;

  pointsArray = array of point2;

  point3 = record
    x, y, z: single;
    class operator Add(p1: point3; p2: point3): point3;
    class operator Subtract(p1, p2: point3): point3;
  end;

  point3d = record
    x, y, z: double;
    class operator Add(p1, p2: point3d): point3d;
    class operator Add(p1: point3d; p2: point3): point3d;
    class operator Subtract(p1, p2: point3d): point3d;
    class operator implicit(p: point3d): point3;
  end;

  point4d = record
    x, y, z, u: double;
  end;

  fRect = record
    BottomLeft: point2;
    TopRight: point2;
  end;

  fRectd = record
    BottomLeft: point2d;
    TopRight: point2d;
  end;

  sMouseStruct = record
    // ����� ������� ���� ������
    mousedown: boolean;
    // ������� ���������� ����
    iPos: tpoint;
    // ���������� �� ������ ������ ������������� ����
    DragBegginPos: tpoint;
    // ������� ��������������� ���������� ����
    iPos_inv: tpoint;
    // ��������� ������� � ����������� ��������. ��������� ������ � �����������
    // �������� �� ������� �������� ����
    pos: point2;
    // ���������� ������ ��� ������� �������� ���
    activeAxisPos: point2;
    // �������� ���� � ����������� ����
    strafe: point2;
    // �������� ���� � ����������� ������
    activeaxisstrafe: point2d;
    // shift
    vk_shift: boolean;
  end;

  TNamedobjList = class;

  TNamedClass = class of TNamedObj;

  TNamedObj = class
  public
    owner: TNamedobjList;
    fname: string;
  protected
    procedure setname(s: string); virtual;
  public
    property name: string read fname write setname;
    constructor create; virtual;
    destructor destroy; virtual;
  end;

  TNamedobjList = class(tstringlist)
  public
    cl: TNamedClass;
  public
    function findNoSort(s: string; var ind: integer): boolean;
    function Get(tname: string): TNamedObj; overload;
    function Get(i: integer): TNamedObj; overload;
    function Add(objname: string): TNamedObj;
    procedure clear; override;
    constructor create;
    destructor destroy;
  end;

const
  c_carret = #13#10;
  cllightGreen = $0000FF80;
  clPink = $008080FF;

  axisX: point3 = (x: 1; y: 0; z: 0);
  axisY: point3 = (x: 0; y: 1; z: 0);
  axisZ: point3 = (x: 0; y: 0; z: 1);
  axisO: point3 = (x: 0; y: 0; z: 0);

  red: point3 = (x: 1; y: 0; z: 0);
  green: point3 = (x: 0; y: 1; z: 0);
  blue: point3 = (x: 0; y: 0; z: 1);
  black: point3 = (x: 0; y: 0; z: 0);
  brightyellow: point3 = (x: 1; y: 1; z: 0.5);
  yellow: point3 = (x: 1; y: 1; z: 0);
  purple: point3 = (x: 0.25098; y: 0.03921; z: 0.021729);
  acid: point3 = (x: 0.35294; y: 0.93725; z: 0.003137);
  bRIGHTbLUE: point3 = (x: 0.0862745; y: 0.08235294; z: 0.827450980);
  Orange: point3 = (x: 0.85490196; y: 0.55686274; z: 0.0862745);
  violet: point3 = (x: 0.298039215; y: 0.3294117647; z: 0.61960784313);
  Lilac: point3 = (x: 0.88627450980; y: 0.06274509803; z: 0.78039215686);
  white: point3 = (x: 1; y: 1; z: 1);
  gray: point3 = (x: 0.6; y: 0.6; z: 0.6);
  Brightgray: point3 = (x: 0.8; y: 0.8; z: 0.8);
  // https://en.wikipedia.org/wiki/List_of_colors:_A%E2%80%93F
  Aero: point3 = (x: 0.49; y: 0.73; z: 0.91);
  AlienArmpit: point3 = (x: 0.77; y: 0.88; z: 0.48);
  Amazon: point3 = (x: 0.23; y: 0.48; z: 0.34);
  AntiqueRuby: point3 = (x: 0.52; y: 0.11; z: 0.18);
  BarbiePink: point3 = (x: 0.91; y: 0.25; z: 0.59);
  Bittersweet: point3 = (x: 0.100; y: 0.44; z: 0.37);
  BrickRed: point3 = (x: 0.80; y: 0.25; z: 0.33);
  CadmiumRed: point3 = (x: 0.89; y: 0.00; z: 0.13);
  Cerulean: point3 = (x: 0.00; y: 0.48; z: 0.65);
  Citron: point3 = (x: 0.62; y: 0.66; z: 0.12);

  ColorArray: array [0 .. 17] of point3 = ((x: 0; y: 0; z: 1), // blue
    (x: 0; y: 1; z: 0), // green
    (x: 1; y: 0; z: 0), // red
    (x: 0.85490196; y: 0.55686274; z: 0.0862745), // orange
    (x: 0.25098; y: 0.03921; z: 0.021729), // purple
    (x: 0.35294; y: 0.93725; z: 0.003137), // acid
    (x: 0.298039215; y: 0.3294117647; z: 0.61960784313), // violet
    (x: 0.88627450980; y: 0.06274509803; z: 0.78039215686), // Lilac
    (x: 0.49; y: 0.73; z: 0.91), // Aero
    (x: 0.77; y: 0.88; z: 0.48), // AlienArmpit
    (x: 0.23; y: 0.48; z: 0.34), // Amazon
    (x: 0.52; y: 0.11; z: 0.18), // AntiqueRuby
    (x: 0.91; y: 0.25; z: 0.59), // BarbiePink
    (x: 0.100; y: 0.44; z: 0.37), // Bittersweet
    (x: 0.80; y: 0.25; z: 0.33), // BrickRed
    (x: 0.89; y: 0.00; z: 0.13), // CadmiumRed
    (x: 0.00; y: 0.48; z: 0.65), // Cerulean
    (x: 0.62; y: 0.66; z: 0.12) // Citron
    );
  // , [red], [Orange], [purple], [acid], [violet], [Lilac]);

function p2(x, y: single): point2;
function p2d(x, y: double): point2d;
function p2top2d(p: point2): point2d;
function p2toStr(p2: point2d; digs: integer): string;
function p2toStrNoChar(p2: point2d; digs: integer): string;
function StrToP2d(s: string): point2d;
function p3(x, y, z: single): point3;
function p3ToStr(p3: point3; digs: integer): string;
function TPointToStr(tp: tpoint): string;
function StrToTpoint(s: string): tpoint;
function summP2(p1, p2: point2): point2;
function summP2d(p1, p2: point2d): point2d;
function DecP2(p0, p1: point2): point2;

function AltKeyDown: boolean;
function CtrlKeyDown: boolean;
function ShiftKeyDown: boolean;
function CapsLock: boolean;
function InsertOn: boolean;
function NumLock: boolean;

function ScrollLock: boolean;
function getCommonInterval(i1, i2: point2d): point2d;
function CompareInterval(i1, i2: point2d): boolean;
function getSubStrByIndex(src: string; tabs: char;
  p_start, index: integer): string;

function PTypeToInt(p: TPType): integer;
function IntToPtype(p: integer): TPType;
function PTypeToStr(p: TPType): string;
function StrToPType(p: string): TPType;

implementation

uses
  ucommonmath, mathfunction;

function getSubStrByIndex(src: string; tabs: char;
  p_start, index: integer): string;
var
  start, ind, i, c: integer;
  b: boolean;
begin
  ind := 0; // ����� ��������
  start := p_start;
  result := '';
  for i := p_start to length(src) do
  begin
    b := i = length(src);
    if (src[i] = tabs) or (b) then
    begin
      if ind = index then
      begin
        c := i - start;
        if b then
        begin
          if not(src[i] = tabs) then
            inc(c);
        end;
        result := Copy(src, start, c);
        exit;
      end
      else
      begin
        start := i + 1;
        inc(ind);
      end;
    end;
  end;
end;

function max(x, y: double; var b: boolean): double;
begin
  if x > y then
  begin
    result := x;
    b := true;
  end
  else
  begin
    result := y;
    b := false;
  end;
end;

function min(x, y: double; var b: boolean): double;
begin
  if x < y then
  begin
    result := x;
    b := true;
  end
  else
  begin
    result := y;
    b := false;
  end;
end;

function getCommonInterval(i1, i2: point2d): point2d;
var
  b: boolean;
begin
  result.x := max(i1.x, i2.x, b);
  result.y := min(i1.y, i2.y, b);
  if result.y < result.x then
    result.y := result.x;
end;

function CompareInterval(i1, i2: point2d): boolean;
begin
  result := false;
  if i1.x = i2.x then
  begin
    if i1.y = i2.y then
      result := true;
  end;
end;

function AltKeyDown: boolean;
begin
  result := (Word(GetAsyncKeyState(VK_MENU)) and $8000) <> 0;
end;

function CtrlKeyDown: boolean;
begin
  result := (Word(GetAsyncKeyState(VK_CONTROL)) and $8000) <> 0;
end;

function ShiftKeyDown: boolean;
begin
  result := (Word(GetAsyncKeyState(vk_shift)) and $8000) <> 0;
end;

function CapsLock: boolean;
begin
  result := (GetAsyncKeyState(VK_CAPITAL) and 1) <> 0;
end;

function InsertOn: boolean;
begin
  result := (GetAsyncKeyState(VK_INSERT) and 1) <> 0;
end;

function NumLock: boolean;
begin
  result := (GetAsyncKeyState(VK_NUMLOCK) and 1) <> 0;
end;

function ScrollLock: boolean;
begin
  result := (GetAsyncKeyState(VK_SCROLL) and 1) <> 0;
end;

function DecP2(p0, p1: point2): point2;
begin
  result := p2((p0.x - p1.x), (p0.y - p1.y));
end;

function summP2(p1, p2: point2): point2;
begin
  result.y := p1.y + p2.y;
  result.x := p1.x + p2.x;
end;

function summP2d(p1, p2: point2d): point2d;
begin
  result.y := p1.y + p2.y;
  result.x := p1.x + p2.x;
end;

function p2(x, y: single): point2;
begin
  result.x := x;
  result.y := y;
end;

function p2d(x, y: double): point2d;
begin
  result.x := x;
  result.y := y;
end;

function p2top2d(p: point2): point2d;
begin
  result := p2d(p.x, p.y);
end;

function p3(x, y, z: single): point3;
begin
  result.x := x;
  result.y := y;
  result.z := z;
end;

function p3ToStr(p3: point3; digs: integer): string;
begin
  result := 'x:' + formatstrNoE(p3.x, digs) + ';' + 'y:' + formatstrNoE(p3.y,
    digs) + ';' + 'z:' + formatstrNoE(p3.z, digs)
end;

function p2toStr(p2: point2d; digs: integer): string;
begin
  result := 'x:' + formatstrNoE(p2.x, digs) + ';' + 'y:' + formatstrNoE(p2.y,
    digs);
end;

function p2toStrNoChar(p2: point2d; digs: integer): string;
begin
  result := formatstrNoE(p2.x, digs) + ';' + formatstrNoE(p2.y,digs);
end;

function StrToP2d(s: string): point2d;
var
  ls: string;
  i: integer;
begin
  ls := GetSubString(s, ';', 1, i);
  result.x := strtoFloatExt(ls);
  ls := GetSubString(s, ';', i + 1, i);
  result.y := strtoFloatExt(ls);
end;

function TPointToStr(tp: tpoint): string;
begin
  result := inttostr(tp.x) + '_' + inttostr(tp.y);
end;

function StrToTpoint(s: string): tpoint;
var
  s1: string;
begin
  s1 := getSubStrByIndex(s, '_', 1, 0);
  result.x := strtoint(s1);
  s1 := getSubStrByIndex(s, '_', 1, 1);
  result.y := strtoint(s1);
end;

{ TNamedObj }

constructor TNamedObj.create;
begin
  inherited;
end;

destructor TNamedObj.destroy;
var
  i: integer;
  b: boolean;
begin
  if owner <> nil then
  begin
    if owner.sorted then
      b := owner.Find(fname, i)
    else
      b := owner.findNoSort(fname, i);
    if b then
    begin
      owner.Delete(i);
    end;
  end;
  inherited;
end;

procedure TNamedObj.setname(s: string);
var
  i: integer;
  b: boolean;
  c: TNamedObj;
begin
  if owner <> nil then
  begin
    if owner.sorted then
      b := owner.Find(fname, i)
    else
    begin
      b := owner.findNoSort(fname, i);
      if owner.Duplicates = dupAccept then
      begin
        c := owner.Get(i);
        while c <> self do
        begin
          inc(i);
          c := owner.Get(i);
          if c <> nil then
          begin
            if c.name <> s then
            begin
              b := false;
              break;
            end;
          end;
        end;
      end;
    end;
    if b then
    begin
      owner.Delete(i);
      if not owner.sorted then
      begin
        owner.InsertObject(i, s, self);
      end
      else
      begin
        owner.AddObject(s, self);
      end;
    end;
  end;
  fname := s;
end;

{ TNamedobjList }

function TNamedobjList.Add(objname: string): TNamedObj;
var
  i: integer;
  o: TNamedObj;
begin
  if not Find(objname, i) then
  begin
    if cl <> nil then
    begin
      o := TNamedObj(cl.create);
    end
    else
      o := TNamedObj.create;
    o.fname := objname;
    AddObject(objname, o);
    result := o;
    o.owner := self;
  end
  else
  begin
    result := TNamedObj(Objects[i]);
  end;
end;

procedure TNamedobjList.clear;
var
  i: integer;
  o: TNamedObj;
begin
  for i := Count - 1 downto 0 do
  begin
    o := TNamedObj(Objects[i]);
    o.destroy;
  end;
  inherited clear;
end;

constructor TNamedobjList.create;
begin
  inherited;
  sorted := true;
end;

destructor TNamedobjList.destroy;
begin
  clear;
  inherited;
end;

function TNamedobjList.findNoSort(s: string; var ind: integer): boolean;
var
  i: integer;
begin
  ind := -1;
  result := false;
  for i := 0 to Count - 1 do
  begin
    if strings[i] = s then
    begin
      result := true;
      ind := i;
      break;
    end;
  end;
end;

function TNamedobjList.Get(tname: string): TNamedObj;
var
  i: integer;
begin
  if sorted then
  begin
    if Find(tname, i) then
    begin
      result := TNamedObj(Objects[i]);
    end
    else
      result := nil;
  end
  else
  begin
    if findNoSort(tname, i) then
    begin
      result := TNamedObj(Objects[i]);
    end
    else
      result := nil;
  end;
end;

function TNamedobjList.Get(i: integer): TNamedObj;
begin
  result := nil;
  if i < 0 then
    exit;
  if i < Count then
    result := TNamedObj(Objects[i]);
end;

function PTypeToInt(p: TPType): integer;
begin
  case p of
    ptNullPoly:
      result := 0;
    ptlinePoly:
      result := 1;
    ptCubePoly:
      result := 2;
  end;
end;

function IntToPtype(p: integer): TPType;
begin
  case p of
    0:
      result := ptNullPoly;
    1:
      result := ptlinePoly;
    2:
      result := ptCubePoly;
  end;
end;

function PTypeToStr(p: TPType): string;
begin
  result := inttostr(PTypeToInt(p));
end;

function StrToPType(p: string): TPType;
begin
  result := IntToPtype(strtoint(p));
end;

{ point3d }

class operator point3d.Add(p1, p2: point3d): point3d;
begin
  result.x := p1.x + p2.x;
  result.y := p1.y + p2.y;
  result.z := p1.z + p2.z;
end;

class operator point3d.Add(p1: point3d; p2: point3): point3d;
begin
  result.x := p1.x + p2.x;
  result.y := p1.y + p2.y;
  result.z := p1.z + p2.z;
end;

class operator point3d.implicit(p: point3d): point3;
begin
  result.x := p.x;
  result.y := p.y;
  result.z := p.z;
end;

class operator point3d.Subtract(p1, p2: point3d): point3d;
begin
  result.x := p1.x - p2.x;
  result.y := p1.y - p2.y;
  result.z := p1.z - p2.z;
end;

{ point3 }

class operator point3.Add(p1, p2: point3): point3;
begin
  result.x := p1.x + p2.x;
  result.y := p1.y + p2.y;
  result.z := p1.z + p2.z;
end;

class operator point3.Subtract(p1, p2: point3): point3;
begin
  result.x := p1.x - p2.x;
  result.y := p1.y - p2.y;
  result.z := p1.z - p2.z;
end;

end.
