// ���������� �������������� �������
unit MathFunction;

interface

uses
  // OpenGL, Math;
  Windows, ExtCtrls, SysUtils, OpenGL, Math, Forms, StdCtrls, Classes,
  uCommonTypes, uCommonMath;

Type
  Vector3f = array [0 .. 2] of GLFloat;
  Vector3D = array [0 .. 2] of GLDouble;
  MatrixGl = array [0 .. 15] of GLFloat;
  MatrixGld = array [0 .. 15] of GLDouble;
  Matrix3 = array [0 .. 8] of GLFloat;

  fcomparator = function(p1, p2: pointer): integer;

  TextureVertex = array [0 .. 1] of GLFloat;
  GlFace = array [0 .. 2] of word;
  GlFaceCard = array [0 .. 2] of Cardinal;

  TVertexArray = array of Vector3f;
  TTextureArray = array of TextureVertex;
  TFace = array of GlFace;
  TFaceC = array of GlFaceCard;
  TFaceFlagArray = array of word;

function matrixToStr(m: MatrixGl): string;
function StrToMatrix(str: string): MatrixGl;
// ������� ������� pos � ����������� dir �� ��������� distance
// dir ������ ���� ���������
function MovePoint(pos: point3; n_dir: point3; distance: single): point3;
// ���������������� ������ ��������� p3
procedure InitP3Array(p3: point3; var ar: array of point3);
// ������ ���� ����� (��� 0)
function sign_(val: single): integer;
// ������ ���� ������������������ �������
function GetCosSign(angel: single): integer;
function GetSinSign(angel: single): integer;
// �������� ���� � ��������.
function GetAngel(v1, v2: point3; normalize: boolean): single; overload;
function GetAngel(v1, v2: Vector3f; normalize: boolean): single; overload;
function GetAngel(x1, y1, x2, y2: integer): single; overload;
function GetCos(x1, y1, x2, y2: integer): single;
// --------------- ��������� �������� -------------------------------------------
Procedure DrawAxis;
// ������� ����
function VectorCos(const v1, v2: Vector3f): GLFloat; overload;
function VectorCos(const v1, v2: point3): GLFloat; overload;
function CompareArray(const v1, v2: array of single): boolean;
// ������ glOrtho
procedure CreateOrthoMatrix(left, right, bottom, top, zNear, zFar: single;
  var m: array of single);
procedure CreateOrthoMatrixd(left, right, bottom, top, zNear, zFar: double;
  var m: array of double);
// ------------------ ���������� � ������� --------------------------------------
function extent(const x: single; const y: integer): double;
// ------------------ ���������� ------------------------------------------------
function TruncTo(x: double; precision: Cardinal): double;
// ------------------ ��������� ������� -----------------------------------------
Procedure GetNormal(const Vertex1, Vertex2, Vertex3: Vector3f;
  var Normal: Vector3f); overload;
Procedure GetNormal(const Vertex1, Vertex2, Vertex3: point3;
  var Normal: point3); overload;
Function VectorLength(const v: Vector3f): GLFloat; overload;
Function VectorLength(const v: point3): GLFloat; overload;
// --------------------- ���������� ������� -----------------------------------
Procedure NormalizeVector(var Normal: Vector3f);
// --------------------- ���������� ������� -----------------------------------
Procedure NormalizeVectorP3(var Normal: point3);
// --------------------- �������� ��������  -----------------------------------
Function SummVector(const v1: Vector3f; const v2: Vector3f): Vector3f;
// �������� ��������
Function SummVectorP3(v1, v2: point3): point3;
Function subVector(startp, endp: point3): point3; overload;
Function subVector(startp, endp: Vector3f): Vector3f; overload;
// �������������� ����� ������
Function isOnLine(l1, l2, p: point3): boolean;
// -------------------- ����������� ����������� ������ --------------------------
Function LineCrossLine(const L1begin, L1end, L2begin, L2end: Vector3f;
  out Cross: Vector3f): boolean; overload;
Function LineCrossLine(const L1begin, L1end, L2begin, L2end: point3;
  out Cross: point3): boolean; overload;
// ��������� �� ����� �� ��������. ���������� True ���� ���� ��������� �� ���������� ������ ��������
Function PointToPlane(point, p1, p2, p3: point3; var Cross: point3): boolean;
// ���������� ����� ����������� ������ l1,l2 � ������� ������������ ����� ���������������� ���������
// ���������� ��� ����������� � ������ �� ���������, ����� ������������ ���������� ��������� � �������������� ����� ����������� ������ l1, l2
// res = -1 ���� ����������� �� ���� ��� ���������� ����� �������� � ������� ���� �����������
function lineCrossBound(b_lo, b_hi, l_start, l_end: point3;
  var res: integer): point3;
// -------- ����������� ����������� ������ � ����� ------------------------------
Function LineCrossFace(const l1, l2, p1, p2, p3: Vector3f;
  out Cross: Vector3f): boolean; overload;
Function LineCrossFace(const l1, l2, p1, p2, p3: point3;
  out Cross: point3): boolean; overload;
Function LineCrossPoly(const l1, l2, p1, p2, p3, p4: point3;
  out Cross: point3): boolean; overload;

// ����� ����������� ������ � ���������
Function LineCrossPlane(const l1, l2, p1, p2, p3: point3;
  out Cross: point3): boolean; overload;
// L1- ����� �� ������; N1- ������ ������������ ������
Function LineCrossPlaneN(const l1, N1, p1, p2, p3: point3;
  out Cross: point3): boolean; overload;
function LineCrossPlane(const l1, l2, p1, p2, p3: Vector3f;
  out Cross: Vector3f): boolean; overload;
// �������� ��� ������� ������ �������� (�������� ��� ��� ����� � ��������� �� ������������!!!)
function insidePoly(v, p1, p2, p3, p4: point3): boolean;
// ���������, ��� ������� ������ ������
function insideBox3d(const v, loCorner, hiCorner: Vector3f): boolean; overload;
function insideBox3d(const v, loCorner, hiCorner: point3): boolean; overload;
// �������������� ������
function scalevectorp3(s: single; v: point3): point3;
//
Function MultVector_(x, y, z, x1, y1, z1: single): point3;
// ---------------- ��������� ��������� �������� -------------
Function MultVector(const v1, v2: Vector3f): Vector3f;
// ---------------- ��������� ��������� �������� -------------
Function MultVectorP3(const v1, v2: point3): point3;
// ---------------- ��������� ��������� �������� -------------
function MultScalar(const v1: Vector3f; const v2: Vector3f): GLFloat;
// ---------------- ��������� ��������� �������� -------------
function MultScalarP3(const v1: point3; const v2: point3): GLFloat;
// ---------------- ��������� ��������� �������� -------------
function MultScalar_(x, y, z, x1, y1, z1: single): GLFloat;
// ----------------- ����������� ������� � ���
function inttoRGB(color: integer): point3;
function RGBtoInt(color: point3): integer; overload;
function RGBtoInt(color: Vector3f): integer; overload;
// �������� ����� opt - ����������� �����. flag - ����� ��� ���������
function CheckFlag(opt: Cardinal; flag: Cardinal): boolean;
procedure setflag(var opt: Cardinal; flag: Cardinal);
procedure dropflag(var opt: Cardinal; flag: Cardinal);
function P3toV(const p3: point3): Vector3f;
function VtoP3(const v: Vector3f): point3;
// ����������� ����� � ������, �������� sign �������� ����, ���� ���
// ����� �� �������, ���� �� ������ ��� sign. �� ���������� ����������!
function formatstr(val: single; sign: word): string;
function formatstrNoE(val: single; sign: word): string;
// �����?
function EqvF(v1: double; v2: double; precision: word): boolean;
// �������� ��� �������
function EqvP3(p1: point3; p2: point3; precision: word): boolean;

function FindInListLowBound(a: TList; obj: tobject;
  sortfunction: fcomparator): integer;
function FindInListHiBound(a: TList; obj: tobject;
  sortfunction: fcomparator): integer;
// �������� ������ ����������� �� ����� �� ���� x,y,z, ������ len.
function GetAxis(len: single; index: integer): point3;
// ���������� �� ����� �� ������
function GetDistance(p1, p_p2: point2; p: point2): single;
function MaxFloat(const v: array of single): single; overload;
{ : Returns the maximum of given values. }
function MaxFloat(const v1, v2: single): single; overload;
function MaxFloat(const v1, v2: double): double; overload;
function MaxFloat(const v1, v2: Extended): Extended; overload;
function MaxFloat(const v1, v2, v3: single): single; overload;
function MaxFloat(const v1, v2, v3: double): double; overload;
function MaxFloat(const v1, v2, v3: Extended): Extended; overload;
// �������� ������������ P3. t - �������� 0..1 p = p2*t +p1*(1-t)
function InterpolateP3(p1, p2: point3; t: single): point3;
// ����������� ���������� �� �������. rect - ���������� ����
// irect - �������. pi - ���������� � ��������
Function P2iToP2proc(irect: trect; rect: frect; pi: tpoint): point2;

const
  cOne: single = 1.0;
  identMatrix4: MatrixGl = (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
  identMatrix4d: MatrixGld = (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);

implementation

uses
  u3dtypes;

const
  axisX: point3 = (x: 1; y: 0; z: 0);
  axisY: point3 = (x: 0; y: 1; z: 0);
  axisZ: point3 = (x: 0; y: 0; z: 1);
  axisO: point3 = (x: 0; y: 0; z: 0);

procedure glTexCoordPointer(size: GLint; atype: GLenum; stride: GLsizei;
  data: pointer); stdcall; external OpenGL32;
procedure glVertexPointer(size: GLint; atype: GLenum; stride: GLsizei;
  data: pointer); stdcall; external OpenGL32;
// ---------------------------------------------------------------------
procedure glNormalPointer(size: GLint; stride: GLsizei; data: pointer);
  stdcall; external OpenGL32;
// ---------------------------------------------------------------------
procedure glColorPointer(size: GLint; atype: GLenum; stride: GLsizei;
  data: pointer); stdcall; external OpenGL32;
// ---------------------------------------------------------------------
procedure glDrawArrays(mode: GLenum; first: GLint; count: GLsizei); stdcall;
external OpenGL32;
// ---------------------------------------------------------------------
procedure glEnableClientState(aarray: GLenum); stdcall; external OpenGL32;
// ---------------------------------------------------------------------
procedure glDisableClientState(aarray: GLenum); stdcall; external OpenGL32;
// ---------------------------------------------------------------------
procedure glDrawElements(mode: GLenum; count: GLsizei; GlType: GLenum;
  data: pointer); stdcall; external OpenGL32;
// ---------------------------------------------------------------------
procedure glBindTexture(mode: GLenum; Texture: GLuint); stdcall;
external OpenGL32;
// ---------------------------------------------------------------------
procedure glGenTextures(n: GLsizei; textures: PGLuint); stdcall;
external OpenGL32;
// ---------------------------------------------------------------------
procedure glLightModeli(n: GLenum; u: GLuint); stdcall; external OpenGL32;

const
  GL_VERTEX_ARRAY = $8074;
  GL_COLOR_ARRAY = $8076;
  GL_Normal_ARRAY = $8075;
  GL_TEXTURE_COORD_ARRAY = $8078;
  degres = 0.017453293; // ����� ������ � �������
  radians = 57.295779513; // ����� �������� � �������

function EqvF(v1: double; v2: double; precision: word): boolean;
begin
  v1 := TruncTo(v1, precision);
  v2 := TruncTo(v2, precision);
  if (v2 - v1) = 0 then
    result := true
  else
    result := false;
end;

function EqvP3(p1: point3; p2: point3; precision: word): boolean;
begin
  if not EqvF(p1.x, p2.x, precision) then
  begin
    result := false;
    exit;
  end;
  if not EqvF(p1.y, p2.y, precision) then
  begin
    result := false;
    exit;
  end;
  if not EqvF(p1.z, p2.z, precision) then
  begin
    result := false;
    exit;
  end;
  result := true;
end;

Function truncZero(str: string): string;
var
  i: integer;
  b: boolean;
begin
  result := str;
  if (pos('.', str) <> 0) or (pos(',', str) <> 0) then
  begin
    i := length(str);
    b := false;
    while (i > 0) do
    begin
      if str[i] = '0' then
      begin
        dec(i);
        b := true;
      end
      else
      begin
        break;
      end;
    end;
    if b then
      setlength(str, i);
    result := str;
  end;
end;

function CopyStrSign(str: string; from: integer; count: integer;
  var endsymbol: integer): string;
var
  s: string;
  i, toInd: integer;
begin
  toInd := from + count - 1;
  if toInd > length(str) then
    toInd := length(str);
  setlength(s, toInd - from + 1);
  // move(@str[1],@s[1],sign);
  for i := from to toInd do
  begin
    s[i - from + 1] := str[i];
  end;
  endsymbol := toInd;
  result := truncZero(s);
end;

// ������ ��� delphi � ansi ��������
function formatstr(val: single; sign: word): string;
var
  v, d: double;
  str, strorder, dest, d_str: string;
  i, fromind, pos, len, order, pow, endpos: integer;
begin
  v := val;
  if val = 0 then
  begin
    result := '0';
    exit;
  end;
  str := floattostr(val);
  len := length(str);
  if len <= sign then
  begin
    result := str;
    exit;
  end;
  dest := str;

  i := system.pos('E', str);
  if i = 0 then
  begin
    i := system.pos('e', str);
  end;
  if i <> 0 then
  begin
    strorder := Copy(str, i + 1, length(str) - i);
    pow := abs(strtoint(strorder));
    for i := 0 to pow - 1 do
    begin
      val := val * 10;
    end;
    // ����� ���� ���������
    pos := round(val);
    result := inttostr(pos) + 'E-' + inttostr(pow);
    if abs(v) < 1 then
    begin
      if strtoint(strorder) < 0 then
      begin
        if pow > sign + 1 then
        begin
          result := '0';
          exit;
        end;
      end;
    end;
    exit;
  end;

  for pos := 2 to len do
  begin
    if (str[pos] = '.') or (str[pos] = ',') then
    begin
      // �������� ������ ������ �������� ����� ����� �������
      fromind := pos + 1;
      // ���� ������ �������� �����
      while str[fromind] = '0' do
      begin
        inc(fromind);
      end;
      // ���� ����� ����� ��� 0.___
      if abs(val) < 1 then
      begin
        // �������� �������� ��������� (��������� ���� ����� -0.03456 � sign=3 ,
        // �� ��������� 345)
        if val < 0 then
          d := TruncTo(val, fromind + sign - 3)
        else
          d := TruncTo(val, fromind + sign - 2);
        d_str := floattostr(d);
        endpos := 0;
        dest := CopyStrSign(str, fromind, sign, endpos);
        len := length(dest);
        if str[1] = '-' then
          dest := '-' + dest;
        order := fromind - pos - 1 + len;
        dest := dest + 'E-' + inttostr(order);
        setlength(str, endpos);
        // val -0,003386140801
        // d_str:=truncto(v, sign);
        if length(dest) > length(d_str) then
        begin
          dest := floattostr(d);
          if length(str) <= length(dest) then
          begin
            dest := str;
          end;
        end;
      end
      else
      // ���� ����� �������� 50.0123 � sign=3
      begin
        if str[1] = '-' then
          sign := sign + 2
        else
          sign := sign + 1;
        if fromind > sign then
          setlength(dest, pos - 1)
        else
          setlength(dest, sign);
      end;
      break;
    end
  end;
  result := dest;
end;

// ������ ��� delphi � ansi ��������
function formatstrNoE(val: single; sign: word): string;
var
  v, d: double;
  str, strorder, dest, d_str: string;
  i, fromind, sep_pos, pos, len, newlen, order, pow, endpos: integer;
begin
  v := val;
  if val = 0 then
  begin
    result := '0';
    exit;
  end;
  str := floattostr(val);
  len := length(str);

  sep_pos := 0;
  for i := 1 to len do
  begin
    if (str[i] = '.') or (str[i] = ',') then
    begin
      sep_pos := i;
      break;
    end;
  end;
  if sep_pos = 0 then
  begin
    result := str;
    exit;
  end;

  if len <= sign then
  begin
    result := str;
    exit;
  end;
  dest := str;

  i := system.pos('E', str);
  if i = 0 then
  begin
    i := system.pos('e', str);
  end;
  if i <> 0 then
  begin
    strorder := Copy(str, i + 1, length(str) - i);
    pow := abs(strtoint(strorder));
    for i := 0 to pow - 1 do
    begin
      val := val * 10;
    end;
    // ����� ���� ���������
    pos := round(val);
    result := inttostr(pos) + 'E-' + inttostr(pow);
    if abs(v) < 1 then
    begin
      if strtoint(strorder) < 0 then
      begin
        if pow > sign + 1 then
        begin
          result := '0';
          exit;
        end;
      end;
    end;
    exit;
  end;
  // ����������� ����� �������� ���� ���� ������ �����
  if str[1] = '-' then
  begin
    sign := sign + 1;
  end;
  // �������� ������� �����
  if sep_pos - 1 >= sign then
  begin
    setlength(str, sep_pos - 1);
    result := str;
    exit;
  end
  else
  begin
    if abs(val) < 1 then
    begin
      // �������� ������ ������ �������� ����� ����� �������
      fromind := sep_pos + 1;
      // ���� ������ �������� �����
      while str[fromind] = '0' do
      begin
        inc(fromind);
      end;
      // ���� ����� ����� ��� 0.___
      if abs(val) < 1 then
      begin
        // �������� �������� ��������� (��������� ���� ����� -0.03456 � sign=3 ,
        // �� ��������� 345)
        if val < 0 then
          d := TruncTo(val, fromind + sign - 4)
        else
          d := TruncTo(val, fromind + sign - 3);
        d_str := floattostr(d);
        // str:=FloatToStr(val);
        // d_str:=Format('%f',[val,sign]);
        result := d_str;
        exit;
      end
    end
    else
    // ���� �������� ����� ���� ����� ������� 50.35 �������� ���� 3
    begin
      newlen := sign + 1;
      if newlen>length(str) then
        newlen:=length(str);
      if (str[newlen] = ',') or (str[newlen] = '.') then
        dec(newlen);
      if newlen > len then
        newlen := len;
      setlength(str, newlen);
      result := str;
      exit;
    end;
  end;
end;

{ function formatstr_(val:single;sign:word):string;
  var str,dest:string;
  i,len:integer;
  begin
  str:=floattostr(val);
  len:=length(str);
  if len<sign then
  begin
  result:=str;
  exit;
  end;
  for I := 1 to len do
  begin
  if (str[i]='.') or (str[i]=',') then
  begin
  begin
  if val<0 then
  inc(sign);
  if i>sign then
  begin
  setlength(dest,i);
  StrLCopy(@dest[1],@str[1],i-1);
  result:=dest;
  exit;
  end
  else
  begin
  setlength(dest,sign+1);
  StrLCopy(@dest[1],@str[1],sign+1);
  while (dest[sign+1]='0') do
  begin
  dec(sign);
  if (dest[sign+1]=',') or (dest[sign+1]='.') then
  begin
  dec(sign);
  break;
  end;
  end;
  setlength(dest,sign+1);
  result:=dest;
  exit;
  end;
  end;
  end;
  end;
  result:=floattostr(val);
  end; }

function matrixToStr(m: MatrixGl): string;
var
  i: integer;
begin
  result := floattostr(m[0]) + ';' + floattostr(m[1]) + ';' + floattostr(m[2])
    + ';' + floattostr(m[4]) + ';' + floattostr(m[5]) + ';' + floattostr(m[6])
    + ';' + floattostr(m[8]) + ';' + floattostr(m[9]) + ';' + floattostr(m[10])
    + ';' + floattostr(m[12]) + ';' + floattostr(m[13]) + ';' + floattostr
    (m[14]);
end;

function StrToMatrix(str: string): MatrixGl;
var
  i, ind: integer;
begin
  result[0] := strtofloat(getSubStrByIndex(str, ';', 1, 0));
  result[1] := strtofloat(getSubStrByIndex(str, ';', 1, 1));
  result[2] := strtofloat(getSubStrByIndex(str, ';', 1, 2));
  result[3] := 0;
  result[4] := strtofloat(getSubStrByIndex(str, ';', 1, 3));
  result[5] := strtofloat(getSubStrByIndex(str, ';', 1, 4));
  result[6] := strtofloat(getSubStrByIndex(str, ';', 1, 5));
  result[7] := 0;
  result[8] := strtofloat(getSubStrByIndex(str, ';', 1, 6));
  result[9] := strtofloat(getSubStrByIndex(str, ';', 1, 7));
  result[10] := strtofloat(getSubStrByIndex(str, ';', 1, 8));
  result[11] := 0;
  result[12] := strtofloat(getSubStrByIndex(str, ';', 1, 9));
  result[13] := strtofloat(getSubStrByIndex(str, ';', 1, 10));
  result[14] := strtofloat(getSubStrByIndex(str, ';', 1, 11));
  result[15] := 1;
end;

function MovePoint(pos: point3; n_dir: point3; distance: single): point3;
begin
  n_dir := scalevectorp3(distance, n_dir);
  result := SummVectorP3(pos, n_dir);
end;

procedure InitP3Array(p3: point3; var ar: array of point3);
var
  i, len: integer;
begin
  len := length(ar);
  for i := 0 to len - 1 do
  begin
    ar[i] := p3;
  end;
end;

// ������� � ������� ������� ����� �� �������� � �������� x
function FindInListLowBound(a: TList; obj: tobject;
  sortfunction: fcomparator): integer;
var
  b: boolean;
  len, range, curind, left, right: integer;
  frac_: boolean;
  function _div(a, b: integer; var frac_: boolean): integer;
  var
    res: integer;
  begin
    if a = 1 then
    begin
      result := 0;
      exit;
    end;
    res := trunc(a / b);
    frac_ := ((a mod b) <> 0);
    result := res;
  end;

begin
  len := a.count;
  // �������� ��������� �����������
  if len = 0 then
  begin
    result := 0;
    exit;
  end;
  if sortfunction(a.Items[len - 1], obj) = -1 then
  begin
    result := len - 1;
    exit;
  end;
  if sortfunction(a.Items[0], obj) = 1 then
  begin
    result := 0;
    exit;
  end;
  // ���������� ������� ������ � �������
  left := 0;
  right := len - 1;
  // -----------------------------------
  range := _div(right - left, 2, frac_);
  curind := range;
  b := false;
  while not b do
  begin
    if sortfunction(a.Items[curind], obj) = 1 then
    begin
      right := curind;
      range := _div(right - left, 2, frac_);
      curind := left + range;
    end
    else
    begin
      left := curind;
      range := _div(right - left, 2, frac_);
      curind := right - range;
    end;
    if range <= 0 then
      b := true;
  end;
  if sortfunction(a.Items[curind], obj) = 1 then
    result := curind - 1
  else
    result := curind;
end;

// ������� � ������� ������� ������ �� �������� � �������� x
function FindInListHiBound(a: TList; obj: tobject;
  sortfunction: fcomparator): integer;
var
  b: boolean;
  len, range, curind, left, right: integer;
  frac_: boolean;
  function _div(a, b: integer; var frac_: boolean): integer;
  var
    res: integer;
  begin
    if a = 1 then
    begin
      result := 0;
      exit;
    end;
    res := trunc(a / b);
    frac_ := ((a mod b) <> 0);
    result := res;
  end;

begin
  len := a.count;
  if len = 0 then
  begin
    result := 0;
    exit;
  end;
  // �������� ��������� �����������
  if sortfunction(a.Items[len - 1], obj) = -1 then
  begin
    result := len - 1;
    exit;
  end;
  if sortfunction(a.Items[0], obj) = 1 then
  begin
    result := 0;
    exit;
  end;
  // ���������� ������� ������ � �������
  left := 0;
  right := len - 1;
  // -----------------------------------
  range := _div(right - left, 2, frac_);
  curind := range;
  b := false;
  while not b do
  begin
    if sortfunction(a.Items[curind], obj) = 1 then
    begin
      right := curind;
      range := _div(right - left, 2, frac_);
      curind := left + range;
    end
    else
    begin
      left := curind;
      range := _div(right - left, 2, frac_);
      curind := right - range;
    end;
    if range <= 0 then
      b := true;
  end;
  if sortfunction(a.Items[curind], obj) = 1 then
    result := curind
  else
    result := curind + 1;
end;

function CheckFlag(opt: Cardinal; flag: Cardinal): boolean;
begin
  if opt and flag <> 0 then
    result := true
  else
    result := false;
end;

procedure setflag(var opt: Cardinal; flag: Cardinal);
begin
  opt := opt or flag;
end;

procedure dropflag(var opt: Cardinal; flag: Cardinal);
begin
  if CheckFlag(opt, flag) then
    opt := opt - flag;
end;

function GetAngel(x1, y1, x2, y2: integer): single;
var
  cos: single;
begin
  cos := GetCos(x1, y1, x2, y2);
  result := arccos(cos);
end;

function GetCos(x1, y1, x2, y2: integer): single;
var
  len1, len2: single;
  dx1, dx2, dy1, dy2: single;
begin
  len1 := sqrt(x1 * x1 + y1 * y1);
  dx1 := x1 / len1;
  dy1 := y1 / len1;

  len2 := sqrt(x2 * x2 + y2 * y2);
  dx2 := x2 / len2;
  dy2 := y2 / len2;

  result := (dx1 * dx2 + dy1 * dy2);
end;

function GetAngel(v1, v2: point3; normalize: boolean): single;
begin
  if normalize then
  begin
    NormalizeVectorP3(v1);
    NormalizeVectorP3(v2);
  end;
  result := arccos(MultScalarP3(v1, v2));
end;

function GetAngel(v1, v2: Vector3f; normalize: boolean): single;
begin
  if normalize then
  begin
    NormalizeVector(v1);
    NormalizeVector(v2);
  end;
  result := arccos(MultScalar(v1, v2));
end;

function P3toV(const p3: point3): Vector3f;
begin
  result[0] := p3.x;
  result[1] := p3.y;
  result[2] := p3.z;
end;

function VtoP3(const v: Vector3f): point3;
begin
  result.x := v[0];
  result.y := v[1];
  result.z := v[2];
end;

function inttoRGB(color: integer): point3;
begin
  result.x := getRvalue(color) / 255;
  result.y := getGvalue(color) / 255;
  result.z := getBvalue(color) / 255;
end;

function RGBtoInt(color: point3): integer;
var
  r, g, b: integer;
begin
  r := trunc(color.x * 255);
  g := trunc(color.y * 255);
  b := trunc(color.z * 255);
  result := RGB(r, g, b);
end;

function RGBtoInt(color: Vector3f): integer;
var
  c: point3;
begin
  c := VtoP3(color);
  result := RGBtoInt(c);
end;

// -------- �������� ���� ������ �� �������� ����
function GetSinSign(angel: single): integer;
var
  i: integer;
begin
  i := trunc(angel / 360);
  if angel > 0 then
    angel := angel - 360 * i
  else
    angel := angel + 360 * i;
  if ((angel > 0) and (angel < 180)) or ((angel < -180) and (angel > 360)) AND
    (angel <> 0) and (abs(angel) <> 180) then
  begin
    result := 1;
    exit;
  end
  else
  begin
    result := -1;
  end;
  angel := abs(angel);
  if (angel = 0) or (angel = 180) or (angel = 360) then
    result := 0;
end;

// -------- �������� ���� ������ �� �������� ����
function GetCosSign(angel: single): integer;
var
  i: integer;
begin
  i := trunc(angel / 360);
  if angel > 0 then
    angel := angel - 360 * i
  else
    angel := angel + 360 * i;
  if (((angel > -90) and (angel < 90)) or (angel < -270)) and (angel <> 90) and
    (abs(angel) <> -90) then
  begin
    result := 1;
    exit;
  end
  else
  begin
    result := -1;
  end;
  angel := abs(angel);
  angel := TruncTo(angel, 4);
  if (angel = 0) or (angel = 90) or (angel = 270) then
    result := 0;
end;

function sign_(val: single): integer;
var
  v: single;
begin
  v := val;
  val := TruncTo(val, 4);
  if val = 0 then
    result := 0
  else
    result := sign(v);
end;

// �������������� ������
function scalevectorp3(s: single; v: point3): point3;
begin
  result.x := s * v.x;
  result.y := s * v.y;
  result.z := s * v.z;
end;

Function SummVector(const v1: Vector3f; const v2: Vector3f): Vector3f;
var
  v: Vector3f;
begin
  v[0] := v1[0] + v2[0];
  v[1] := v1[1] + v2[1];
  v[2] := v1[2] + v2[2];
  result := v;
end;

Function SummVectorP3(v1, v2: point3): point3;
begin
  result.x := v1.x + v2.x;
  result.y := v1.y + v2.y;
  result.z := v1.z + v2.z;
end;

function subVector(startp, endp: point3): point3;
begin
  result.x := endp.x - startp.x;
  result.y := endp.y - startp.y;
  result.z := endp.z - startp.z;
end;

function subVector(startp, endp: Vector3f): Vector3f;
var
  i: integer;
begin
  for i := 0 to 2 do
    result[i] := endp[i] - startp[i];
end;

Function VectorLength(const v: Vector3f): GLFloat;
begin
  result := sqrt(sqr(v[0]) + sqr(v[1]) + sqr(v[2]));
end;

Function VectorLength(const v: point3): GLFloat;
begin
  result := sqrt(sqr(v.x) + sqr(v.y) + sqr(v.z));
end;

// --------------------- ���������� ������� ---------------------------
procedure NormalizeVector(var Normal: Vector3f);
var
  i: word;
  VLength: GLFloat;
begin
  VLength := VectorLength(Normal);
  if VLength = 0 then
    VLength := 1;
  for i := 0 to 2 do
    Normal[i] := Normal[i] / VLength;
end;

procedure NormalizeVectorP3(var Normal: point3);
var
  VLength: GLFloat;
begin
  VLength := VectorLength(Normal);
  if VLength = 0 then
    VLength := 1;
  Normal.x := Normal.x / VLength;
  Normal.y := Normal.y / VLength;
  Normal.z := Normal.z / VLength;
end;

// ----------------------- ��������� ������� ��������� �������� ����.
Procedure DrawAxis;
const
  Axis: array [0 .. 17] of GLFloat = (0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0,
    0, 0, 0, 2);
  c_Colors: array [0 .. 17] of GLFloat = (1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0,
    0, 0, 1, 0, 0, 1);
Begin
  // ������ ��� ���������
  glEnableClientState(GL_COLOR_ARRAY);
  glColorPointer(3, GL_FLOAT, 0, @c_Colors[0]);
  glEnableClientState(GL_VERTEX_ARRAY); // ���. ����� ���������
  glVertexPointer(3, GL_FLOAT, 0, @Axis[0]); // ��������� �� ������
  glDrawArrays(GL_LINES, 0, 6);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
End;

// ------------------------ ��������� �������� ----------------------------------
function CompareArray(const v1, v2: array of single): boolean;
begin
  result := false;
  if v1[0] = v2[0] then
    if v1[1] = v2[1] then
      if v1[2] = v2[2] then
        result := true;
end;

// ------------------ ���������� � ������� --------------------------------------
function extent(const x: single; const y: integer): double;
var
  i: word;
begin
  result := 1;
  for i := 0 to (y - 1) do
    result := result * x;
end;

{ //------------------ ���������� ---------------------------------------------
  Function Trunc(const x:single;const precision:cardinal;
  const round:boolean):real;
  var str:string;
  begin
  str:=Format('%f%d.',[x,precision]);
  Result:=strtofloat(str);
  end; }

// ------------------ ���������� ---------------------------------------------
function TruncTo(x: double; precision: Cardinal): double;
var
  mult: double;
  i: word;
begin
  if precision = 0 then
  begin
    result := round(x);
    exit;
  end;
  mult := 1;
  for i := 0 to (precision - 1) do
    mult := mult * 10;
  result := round(x * mult) / mult;
end;

// �� ���������� ������ ������ ���������� ��
// ���������������� � ���������
procedure GetNormal(const Vertex1, Vertex2, Vertex3: Vector3f;
  var Normal: Vector3f);
var
  v1, v2: array [0 .. 2] of GLFloat;
begin
  // ������� 2-� ������� ������������� � ������� ����
  // ��� y ������������� (����������� �����)
  v1[0] := Vertex1[0] - Vertex2[0]; // x
  v1[1] := -(Vertex1[1] - Vertex2[1]); // y
  v1[2] := Vertex1[2] - Vertex2[2]; // z
  v2[0] := Vertex3[0] - Vertex2[0]; // x1
  v2[1] := -(Vertex3[1] - Vertex2[1]); // y1
  v2[2] := Vertex3[2] - Vertex2[2]; // z1
  // --------------------- ������� ��������� ������������ ---------------
  Normal[0] := v1[1] * v2[2] - v1[2] * v2[1];
  Normal[1] := v1[0] * v2[2] - v1[2] * v2[0];
  Normal[2] := v1[0] * v2[1] - v1[1] * v2[0];
end;

Procedure GetNormal(const Vertex1, Vertex2, Vertex3: point3;
  var Normal: point3);
var
  v1, v2: point3;
begin
  // ������� 2-� ������� ������������� � ������� ����
  // ��� y ������������� (����������� �����)
  v1.x := Vertex1.x - Vertex2.x; // x
  v1.y := -(Vertex1.y - Vertex2.y); // y
  v1.z := Vertex1.z - Vertex2.z; // z
  v2.x := Vertex3.x - Vertex2.x; // x1
  v2.y := -(Vertex3.y - Vertex2.y); // y1
  v2.z := Vertex3.z - Vertex2.z; // z1
  // --------------------- ������� ��������� ������������ ---------------
  Normal.x := v1.y * v2.z - v1.z * v2.y;
  Normal.y := v1.x * v2.z - v1.z * v2.x;
  Normal.z := v1.x * v2.y - v1.y * v2.x;
end;

// -------------------- ��������� ������������ -----------------------
Function MultVector(const v1, v2: Vector3f): Vector3f;
Var
  Normal: Vector3f;
begin
  // --------------------- ������� ��������� ������������ ---------------
  Normal[0] := v1[1] * v2[2] - v1[2] * v2[1];
  Normal[1] := v1[0] * v2[2] - v1[2] * v2[0];
  Normal[2] := v1[0] * v2[1] - v1[1] * v2[0];
  result := Normal;
end;

Function MultVectorP3(const v1, v2: point3): point3;
begin
  // --------------------- ������� ��������� ������������ ---------------
  result.x := v1.y * v2.z - v1.z * v2.y;
  result.y := v1.x * v2.z - v1.z * v2.x;
  result.z := v1.x * v2.y - v1.y * v2.x;
end;

Function MultVector_(x, y, z, x1, y1, z1: single): point3;
begin
  // --------------------- ������� ��������� ������������ ---------------
  result.x := y * z1 - z * y1;
  result.y := x * z1 - z * x1;
  result.z := x * y1 - y * x1;
end;

Function isOnLine(l1, l2, p: point3): boolean;
var
  l, lp: point3;
  k: double;
begin
  result := false;
  l := SubP(l2, l1);
  lp := SubP(p, l1);
  NormalizeVectorP3(l);
  NormalizeVectorP3(lp);
  k := MultScalarP3(l, lp);
  if (1 - abs(k)) < 0.0000000001 then
  begin
    result := true;
  end;
end;

// -------------------- ����������� ����������� ������ ----------------
// �� ��������!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Function LineCrossLine(const L1begin, L1end, L2begin, L2end: Vector3f;
  out Cross: Vector3f): boolean;
var
  i: word;
  l1, l2: array [0 .. 2] of single; // ������������ ������
  t: single;
begin
  // - ��������� ������ (x-x0)/l1x = (y-y0)/l1y = (z-z0)/l1z = t
  // x = x0+l1x*t;  y = y0+l1y*t; z = z0+l1z*t;
  // ����������� ���������� ����� ������ � ������
  result := false;
  for i := 0 to 2 do
  begin
    l1[i] := L1end[i] - L1begin[i];
    l2[i] := L2end[i] - L2begin[i];
  end;
  // j:=0;
  // for i:=0 to 2 do
  // begin
  // if L1[i]=0 then j:=j+1;
  // end;
  // �������� �� �� ��������������
  // Cross[0]:=(L1Begin[0]*L1[1]*L2[0]-L2Begin[0]*L2[1]*L1[0]+
  // L2begin[1]*L1[0]*L2[0])/(L1[1]*L2[0]-L2[1]*L1[0]);
  t := l1[0] * l2[0] + l1[1] * l2[1] + l1[2] * l2[2];
  t := TruncTo(t, 4);
  if (abs(t) = 1) then
    exit;
  result := true;
  // ������ ��������� T
  t := (L1begin[0] + L1begin[1] + L1begin[2] - L2begin[0] - L2begin[1] - L2begin
      [2]) / (l2[0] + l2[1] + l2[2] - l1[0] - l1[1] - l1[2]);
  for i := 0 to 2 do
    Cross[i] := L1begin[i] + t * l1[i];
end;

Function LineCrossLine(const L1begin, L1end, L2begin, L2end: point3;
  out Cross: point3): boolean;
var
  b: boolean;
  l, l1, p: point3; // ������������ ������
  t: single;
begin
  l1 := subVector(L1begin, L1end);
  // ������ �������� � ��������� ����� �� ������� �� l1
  l := subVector(L2begin, L2end);
  l.x := (l.x + 1) * 2;
  l.y := (l.y + 1) * 3;
  t := MultScalarP3(l, l1);
  if t = 1 then
  begin
    l.x := (l.x + 1) * 3;
    l.y := (l.y + 1) * 2;
  end;
  b := LineCrossPlane(L1begin, L1end, L2begin, L2end, l, p);
  result := isOnLine(L1begin, L1end, p);
  Cross := p;
end;

Function PlaneIntersectLine(a, b, c, x, y: point3; var cp: point3): boolean;
// ���� �� ����� � ��� ��� ����� ��������� A,B,C � ��� ����� ������ X,Y
var
  n, v, W: point3;
  e, d: single;
begin
  result := true;
  n := MultVectorP3(subVector(a, b), subVector(a, c));
  NormalizeVectorP3(n);
  v := subVector(x, a);
  // ���������� �� ��������� �� �������
  d := MultScalarP3(n, v);
  W := subVector(x, y);
  // ����������� � ��������� �� ������� ��� ����������� �������
  e := MultScalarP3(n, W);

  if e <> 0 then // ���� �����,
  // � ����� ������ ������(�����������, ��� ����������� ���������)
  // ���� ��������������� ��� ������������ ����� �� ������� ����� �������
  begin
    cp.x := x.x + W.x * d / e;
    cp.y := x.y + W.y * d / e;
    cp.z := x.z + W.z * d / e;
    result := false;
  end;
end;

Function LineCrossPlaneN(const l1, N1, p1, p2, p3: point3;
  out Cross: point3): boolean;
var
  l2: point3;
begin
  l2 := SummVectorP3(l1, N1);
  result := LineCrossPlane(l1, l2, p1, p2, p3, Cross);
end;

Function LineCrossPlane(const l1, l2, p1, p2, p3: point3;
  out Cross: point3): boolean;
var
  Normal: point3; // ������� � �����
  d, t: single; // ����.-� � ���������
begin
  result := false;
  // ��������� ������������ ������� �������
  GetNormal(p1, p2, p3, Normal);
  // �������� �� �� ������������������
  t := Normal.x * (l2.x - l1.x) + Normal.y * (l2.y - l1.y) + Normal.z *
    (l2.z - l1.z);
  d := t;
  d := TruncTo(d, 4);
  if d = 0 then
    exit;
  // ����������� ���������� ����������� (A*x+B*y+C*z+D=0 ��������� ���������)
  d := -(Normal.x * p1.x + Normal.y * p1.y + Normal.z * p1.z);
  // ������� �������� T   x/nx=y/ny=z/nz=T (����. �������. ��������� ������)
  t := -(Normal.x * l1.x + Normal.y * l1.y + Normal.z * l1.z + d) / t;
  // ���������� ��������� - ����������� T � ��������� ������
  Cross.x := l1.x + t * (l2.x - l1.x);
  Cross.y := l1.y + t * (l2.y - l1.y);
  Cross.z := l1.z + t * (l2.z - l1.z);
  result := true;
end;

// -------- ����������� ����������� ������ � ��������� -------------------------
function LineCrossPlane(const l1, l2, p1, p2, p3: Vector3f;
  out Cross: Vector3f): boolean;
var
  Normal: Vector3f; // ������� � �����
  d, t: single; // ����.-� � ���������
begin
  result := false;
  // ��������� ������������ ������� �������
  GetNormal(p1, p2, p3, Normal);
  // �������� �� �� ������������������
  t := Normal[0] * (l2[0] - l1[0]) + Normal[1] * (l2[1] - l1[1]) + Normal[2] *
    (l2[2] - l1[2]);
  d := t;
  d := TruncTo(d, 4);
  if d = 0 then
    exit;
  // ����������� ���������� ����������� (A*x+B*y+C*z+D=0 ��������� ���������)
  d := -(Normal[0] * p1[0] + Normal[1] * p1[1] + Normal[2] * p1[2]);
  // ������� �������� T   x/nx=y/ny=z/nz=T (����. �������. ��������� ������)
  t := -(Normal[0] * l1[0] + Normal[1] * l1[1] + Normal[2] * l1[2] + d) / t;
  // ���������� ��������� - ����������� T � ��������� ������
  Cross[0] := l1[0] + t * (l2[0] - l1[0]);
  Cross[1] := l1[1] + t * (l2[1] - l1[1]);
  Cross[2] := l1[2] + t * (l2[2] - l1[2]);
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

Function PointToPlane(point, p1, p2, p3: point3; var Cross: point3): boolean;
var
  v1, v2, n: point3;
begin
  // ������� ������� � ��������
  v1 := subVector(p1, p2);
  v2 := subVector(p1, p3);
  // ������ ������� � �������
  n := MultVectorP3(v1, v2);
  /// n:=
end;

Function LineCrossPoly(const l1, l2, p1, p2, p3, p4: point3;
  out Cross: point3): boolean;
begin
  result := LineCrossFace(l1, l2, p1, p2, p3, Cross);
  if not result then
  begin
    result := insidePoly(Cross, p1, p2, p3, p4);
  end;
end;

/// ��� �������� ��� ������� ����� �� ������ L1, L2
function LineCrossFace(const l1, l2, p1, p2, p3: Vector3f;
  out Cross: Vector3f): boolean;
var
  Normal: Vector3f; // ������������ (������� ����� -> middle)
  d, t: single; // ����.-� � ���������
  v1, v2, v3: Vector3f; // ������� � �������� ������
  angel: single;
begin
  result := false;
  // ��������� ������������ ������� �������
  GetNormal(p1, p2, p3, Normal);
  // NormalizeVector(Normal) ;
  // �������� �� �� ������������������
  t := Normal[0] * (l2[0] - l1[0]) + Normal[1] * (l2[1] - l1[1]) + Normal[2] *
    (l2[2] - l1[2]);
  d := t;
  d := TruncTo(d, 4);
  if d = 0 then
    exit;
  // ����������� ���������� ����������� (A*x+B*y+C*z+D=0 ��������� ���������)
  d := -(Normal[0] * p1[0] + Normal[1] * p1[1] + Normal[2] * p1[2]);
  // ������� �������� T   x/nx=y/ny=z/nz=T (����. �������. ��������� ������)
  t := -(Normal[0] * l1[0] + Normal[1] * l1[1] + Normal[2] * l1[2] + d) / t;
  // ���������� ��������� - ����������� T � ��������� ������
  Cross[0] := l1[0] + t * (l2[0] - l1[0]);
  Cross[1] := l1[1] + t * (l2[1] - l1[1]);
  Cross[2] := l1[2] + t * (l2[2] - l1[2]);
  // ----------- ���������� ����� �� ����� ����������� ������ ����� -----------
  // ���� ����� ����� ������ ��������, �� ����� ����� ����� ����� ��������� � ���
  // ����� ����� 360 ��������
  v1 := subVector(Cross, p1);
  v2 := subVector(Cross, p2);
  v3 := subVector(Cross, p3);
  angel := GetAngel(v1, v2, true);
  angel := GetAngel(v2, v3, true) + angel;
  angel := GetAngel(v3, v1, true) + angel;
  if abs(angel - 2 * pi) < 0.00001 then
    result := true;
end;

function LineCrossFace(const l1, l2, p1, p2, p3: point3;
  out Cross: point3): boolean;
var
  l1_, l2_, p1_, p2_, p3_, cross_: Vector3f;
begin
  l1_ := P3toV(l1);
  l2_ := P3toV(l2);
  p1_ := P3toV(p1);
  p2_ := P3toV(p2);
  p3_ := P3toV(p3);
  result := LineCrossFace(l1_, l2_, p1_, p2_, p3_, cross_);
  Cross := VtoP3(cross_);
end;

function insidePoly(v, p1, p2, p3, p4: point3): boolean;
var
  v1, v2, v3, v4: point3;
  a: single;
begin
  v1 := subVector(v, p1);
  v2 := subVector(v, p2);
  v3 := subVector(v, p3);
  v4 := subVector(v, p3);
  a := GetAngel(v1, v2, true);
  a := GetAngel(v2, v3, true) + a;
  a := GetAngel(v3, v4, true) + a;
  a := GetAngel(v4, v1, true) + a;
  if abs(a - 2 * pi) < 0.00001 then
    result := true;
end;

function insideBox3d(const v, loCorner, hiCorner: point3): boolean;
var
  // bottom poly
  p1, p2, p3, p4,
  // top poly
  p5, p6, p7, p8, c, // ����� �������
  half, // ����� �� ������ �� ������� ���������
  cx, cy, cz, // ������ ��������� � ����������� ���� x y z
  nx, ny, nz, // ������� � ���������
  vec // ������ � ������ �� �������
    : point3;

begin
  // ���� ������ �������
  p1 := loCorner;
  p2 := p1;
  p2.x := hiCorner.x;
  p3 := p1;
  p2.z := hiCorner.z;
  p4 := p2;
  p2.z := hiCorner.z;
  // ������� ����
  p5 := p1;
  p5.y := hiCorner.y;
  p6 := p2;
  p6.y := hiCorner.y;
  p7 := p3;
  p7.y := hiCorner.y;
  p8 := hiCorner;
  c.x := (loCorner.x + hiCorner.x) * 0.5;
  c.y := (loCorner.y + hiCorner.y) * 0.5;
  c.z := (loCorner.z + hiCorner.z) * 0.5;
  // ������ �������
  cx.x := (p2.x + p8.x) * 0.5;
  cx.y := (p2.y + p8.y) * 0.5;
  cx.z := (p2.z + p8.z) * 0.5;
  nx := SubP(cx, c);
  // ������� �������
  cy.x := (p5.x + p8.x) * 0.5;
  cy.y := (p5.y + p8.y) * 0.5;
  cy.z := (p5.z + p8.z) * 0.5;
  ny := SubP(cy, c);
  // ������� �������
  cz.x := (p3.x + p8.x) * 0.5;
  cz.y := (p3.y + p8.y) * 0.5;
  cz.z := (p3.z + p8.z) * 0.5;
  nz := SubP(cz, c);
  // ����� ��������
  half.x := VectorLength(nx);
  half.y := VectorLength(ny);
  half.z := VectorLength(nz);
  nx := scalevectorp3(1 / half.x, nx);
  ny := scalevectorp3(1 / half.y, ny);
  nz := scalevectorp3(1 / half.z, nz);
  vec := SubP(v, c);
  result := false;
  if abs(MultScalarP3(vec, nx)) < half.x then
  begin
    if abs(MultScalarP3(vec, ny)) < half.y then
    begin
      if abs(MultScalarP3(vec, nz)) < half.z then
      begin
        result := true;
      end;
    end;
  end;
end;

function insideBox3d(const v, loCorner, hiCorner: Vector3f): boolean;
var
  i: integer;
begin
  result := insideBox3d(point3(v), point3(loCorner), point3(hiCorner));
end;

function MultScalar(const v1: Vector3f; const v2: Vector3f): GLFloat;
begin
  result := v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
end;

function MultScalarP3(const v1: point3; const v2: point3): GLFloat;
begin
  result := v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
end;

function MultScalar_(x, y, z, x1, y1, z1: single): GLFloat;
begin
  result := x * x1 + y * y1 + z * z1;
end;

function VectorCos(const v1, v2: point3): GLFloat;
var
  s, lv1, lv2: GLFloat;
begin
  s := MultScalarP3(v1, v2);
  lv1 := VectorLength(v1);
  lv2 := VectorLength(v2);
  result := s / (lv1 * lv2);
end;

function VectorCos(const v1, v2: Vector3f): GLFloat;
var
  s, lv1, lv2: GLFloat;
begin
  s := MultScalar(v1, v2);
  lv1 := VectorLength(v1);
  lv2 := VectorLength(v2);
  result := s / (lv1 * lv2);
end;

function GetAxis(len: single; index: integer): point3;
var
  p3: point3;
begin
  p3 := axisO;
  case index of
    1:
      begin
        p3.x := len;
      end;
    2:
      begin
        p3.y := len;
      end;
    3:
      begin
        p3.z := len;
      end;
  end;
  result := p3;
end;

// MaxFloat
//
function MaxFloat(const v: array of single): single;
var
  i: integer;
begin
  if length(v) > 0 then
  begin
    result := v[0];
    for i := 1 to High(v) do
      if v[i] > result then
        result := v[i];
  end
  else
    result := 0;
end;

// MaxFloat
//
function MaxFloat(const v1, v2: single): single;
{$IFDEF GEOMETRY_NO_ASM}
begin
  if v1 > v2 then
    result := v1
  else
    result := v2;
{$ELSE}
asm
   fld     v1
   fld     v2
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   ffree   st(1)
{$ENDIF}
end;

  // MaxFloat
  //
  function MaxFloat(const v1, v2: double): double;
{$IFDEF GEOMETRY_NO_ASM}
  begin
    if v1 > v2 then
      result := v1
    else
      result := v2;
{$ELSE}
asm
   fld     v1
   fld     v2
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   ffree   st(1)
{$ENDIF}
end;

    // MaxFloat
    //
    function MaxFloat(const v1, v2: Extended): Extended;
{$IFDEF GEOMETRY_NO_ASM}
    begin
      if v1 > v2 then
        result := v1
      else
        result := v2;
{$ELSE}
asm
   fld     v1
   fld     v2
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   ffree   st(1)
{$ENDIF}
end;

      // MaxFloat
      //
      function MaxFloat(const v1, v2, v3: single): single;
{$IFDEF GEOMETRY_NO_ASM}
      begin
        if v1 >= v2 then
          if v1 >= v3 then
            result := v1
          else if v3 >= v2 then
            result := v3
          else
            result := v2
          else if v2 >= v3 then
            result := v2
          else if v3 >= v1 then
            result := v3
          else
            result := v1;
{$ELSE}
asm
   fld     v1
   fld     v2
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   ffree   st(1)
   fld     v3
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   ffree   st(1)
{$ENDIF}
end;

        // MaxFloat
        //
        function MaxFloat(const v1, v2, v3: double): double;
{$IFDEF GEOMETRY_NO_ASM}
        begin
          if v1 >= v2 then
            if v1 >= v3 then
              result := v1
            else if v3 >= v2 then
              result := v3
            else
              result := v2
            else if v2 >= v3 then
              result := v2
            else if v3 >= v1 then
              result := v3
            else
              result := v1;
{$ELSE}
asm
   fld     v1
   fld     v2
   fld     v3
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   db $DB,$F2                 /// fcomi   st(0), st(2)
   db $DA,$C2                 /// fcmovb  st(0), st(2)
   ffree   st(2)
   ffree   st(1)
{$ENDIF}
end;

          // MaxFloat
          //
          function MaxFloat(const v1, v2, v3: Extended): Extended;
{$IFDEF GEOMETRY_NO_ASM}
          begin
            if v1 >= v2 then
              if v1 >= v3 then
                result := v1
              else if v3 >= v2 then
                result := v3
              else
                result := v2
              else if v2 >= v3 then
                result := v2
              else if v3 >= v1 then
                result := v3
              else
                result := v1;
{$ELSE}
asm
   fld     v1
   fld     v2
   fld     v3
   db $DB,$F1                 /// fcomi   st(0), st(1)
   db $DA,$C1                 /// fcmovb  st(0), st(1)
   db $DB,$F2                 /// fcomi   st(0), st(2)
   db $DA,$C2                 /// fcmovb  st(0), st(2)
   ffree   st(2)
   ffree   st(1)
{$ENDIF}
end;

function InterpolateP3(p1, p2: point3; t: single): point3;
begin
  p2 := scalevectorp3(t, p2);
  p1 := scalevectorp3(1 - t, p1);
  result := SummVectorP3(p1, p2);
end;

procedure CreateOrthoMatrix(left, right, bottom, top, zNear,
  zFar: single; var m: array of single);
var
  rl, tb, fn: single;
begin
  rl := (right - left);
  if rl=0 then exit;

  m[0] := 2 / rl;
  m[1] := 0;
  m[2] := 0;
  m[3] := 0;
  m[4] := 0;
  tb := (top - bottom);
  m[5] := 2 / tb;
  m[6] := 0;
  m[7] := 0;
  m[8] := 0;
  m[9] := 0;
  fn := (zFar - zNear);
  m[10] := -2 / fn;
  m[11] := 0;
  m[12] := -(right + left) / rl;
  m[13] := -(top + bottom) / tb;
  m[14] := -(zNear + zFar) / fn;
  m[15] := 1;
end;

procedure CreateOrthoMatrixd(left, right, bottom, top, zNear,
  zFar: double; var m: array of double);
var
  rl, tb, fn: double;
begin
  rl := (right - left);
  m[0] := 2 / rl;
  m[1] := 0;
  m[2] := 0;
  m[3] := 0;
  m[4] := 0;
  tb := (top - bottom);
  m[5] := 2 / tb;
  m[6] := 0;
  m[7] := 0;
  m[8] := 0;
  m[9] := 0;
  fn := (zFar - zNear);
  m[10] := -2 / fn;
  m[11] := 0;
  m[12] := -(right + left) / rl;
  m[13] := -(top + bottom) / tb;
  m[14] := -(zNear + zFar) / fn;
  m[15] := 1;
end;

function GetDistance(p1, p_p2: point2; p: point2): single;
var
  // �������� �� ��������� ������ p1,p2
  cosZ: single;
  v, v_norm,
  // ������ �� p2 � p
  z: point2;
begin
  v.x := (p_p2.x - p1.x);
  v.y := (p_p2.y - p1.y);
  result := sqrt(v.x * v.x + v.y * v.y);
  v_norm := p2(v.x / result, v.y / result);
  z := p2(p_p2.x - p.x, p_p2.y - p.y);
  cosZ := z.x * v_norm.x + z.y * v_norm.y;
  // ���������� ��������
  v_norm := p2(p_p2.x - cosZ * v_norm.x, p_p2.y - cosZ * v_norm.y);
  // ���������� ������� �� p � ��������
  if v_norm.x > p1.x then
  begin
    if v_norm.x < p_p2.x then
    begin
      v.x := (v_norm.x - p.x);
      v.y := (v_norm.y - p.y);
      result := sqrt(v.x * v.x + v.y * v.y);
      exit;
    end;
  end;
  result := -1;
end;

Function P2iToP2proc(irect: trect; rect: frect; pi: tpoint): point2;
var
  i_w, i_h: integer;
  W, h: single;
begin
  i_w := irect.right - irect.left;
  i_h := irect.top - irect.bottom;
  W := rect.TopRight.x - rect.BottomLeft.x;
  h := rect.TopRight.y - rect.BottomLeft.y;
  result.x := W * (pi.x - irect.left) / i_w + rect.BottomLeft.x;
  result.y := h * (pi.y - irect.top) / i_h + rect.TopRight.y;
end;

end.
