unit uCommonTypes;

{ Общие типы данных для SharedUtils Lazarus.
  Кроссплатформенный аналог Delphi uCommonTypes (без Windows-зависимостей).
  Используй эти типы во всех компонентах SharedUtils, чтобы избежать
  лишних преобразований при совместной работе модулей. }

{$mode delphi}{$H+}


interface

uses
  Classes, SysUtils, Types, Math; // Types содержит TPoint, TRect и др. стандартные типы LCL/FPC

type
  { Массивы примитивов }
  TSmallIntArray = array of SmallInt;
  PSmallIntArray = ^TSmallIntArray;
  TDoubleArray   = array of Double;
  TSingleArray   = array of Single;
  TIntArray      = array of Integer;

  { 2D точка (Single - для рендера/OpenGL) }
  point2 = record
    x, y: Single;
    class operator Add     (a, b: point2): point2;
    class operator Subtract(a, b: point2): point2;
  end;

  { 2D точка (Double - для данных/вычислений) }
  point2d = record
    x, y: Double;
    class operator Add     (a, b: point2d): point2d;
    class operator Subtract(a, b: point2d): point2d;
  end;

  pPoint2d = ^point2d;

  { 2D точка в пикселях (Int16) }
  point2i = record
    x, y: Int16;
  end;

  { 3D точка (Single) }
  point3 = record
    x, y, z: Single;
    class operator Add     (a, b: point3): point3;
    class operator Subtract(a, b: point3): point3;
  end;

  { 3D точка (Double) }
  point3d = record
    x, y, z: Double;
    class operator Add     (a, b: point3d): point3d;
    class operator Subtract(a, b: point3d): point3d;
    class operator Implicit(p: point3d): point3;
  end;

  { 4D точка (Double) - гомогенные координаты / RGBA }
  point4d = record
    x, y, z, u: Double;
  end;

  pointsArray = array of point2;

  { Прямоугольник в Single-координатах }
  fRect = record
    BottomLeft: point2;
    TopRight:   point2;
  end;

  { Прямоугольник в Double-координатах }
  fRectd = record
    BottomLeft: point2d;
    TopRight:   point2d;
  end;

  { Интервал [x..y] в Double — для осей, диапазонов }
  TInterval = point2d;

{ Конструкторы (helpers) }
function p2 (x, y: Single): point2;     inline;
function p2d(x, y: Double): point2d;    inline;
function p3 (x, y, z: Single): point3;  inline;
function p3d(x, y, z: Double): point3d; inline;

function p2ToP2d(p: point2):  point2d;  inline;
function p2dToP2(p: point2d): point2;   inline;

function getCommonInterval(i1, i2: point2d): point2d;
function CompareInterval  (i1, i2: point2d): Boolean;

implementation

{ point2 }

class operator point2.Add(a, b: point2): point2;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
end;

class operator point2.Subtract(a, b: point2): point2;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
end;

{ point2d }

class operator point2d.Add(a, b: point2d): point2d;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
end;

class operator point2d.Subtract(a, b: point2d): point2d;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
end;

{ point3 }

class operator point3.Add(a, b: point3): point3;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
end;

class operator point3.Subtract(a, b: point3): point3;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
end;

{ point3d }

class operator point3d.Add(a, b: point3d): point3d;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
end;

class operator point3d.Subtract(a, b: point3d): point3d;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
end;

class operator point3d.Implicit(p: point3d): point3;
begin
  Result.x := p.x;
  Result.y := p.y;
  Result.z := p.z;
end;

{ Конструкторы }

function p2(x, y: Single): point2;
begin
  Result.x := x;
  Result.y := y;
end;

function p2d(x, y: Double): point2d;
begin
  Result.x := x;
  Result.y := y;
end;

function p3(x, y, z: Single): point3;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function p3d(x, y, z: Double): point3d;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function p2ToP2d(p: point2): point2d;
begin
  Result.x := p.x;
  Result.y := p.y;
end;

function p2dToP2(p: point2d): point2;
begin
  Result.x := p.x;
  Result.y := p.y;
end;

function getCommonInterval(i1, i2: point2d): point2d;
begin
  Result.x := Max(i1.x, i2.x);
  Result.y := Min(i1.y, i2.y);
  if Result.y < Result.x then
    Result.y := Result.x;
end;

function CompareInterval(i1, i2: point2d): Boolean;
begin
  Result := (i1.x = i2.x) and (i1.y = i2.y);
end;

end.
