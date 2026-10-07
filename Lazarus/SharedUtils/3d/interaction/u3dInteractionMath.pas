unit u3dInteractionMath;

{ Contains allocation-free vector helpers used in pointer and camera hot paths.
  Functions are pure and operate in right-handed world coordinates. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Math, u3dCoreTypes, u3dInteractionTypes;

const
  C3dEpsilon = 1.0e-6;

function Add(const A, B: T3dVector): T3dVector;
inline;
function Subtract(const A, B: T3dVector): T3dVector;
inline;
function Scale(const A: T3dVector; AFactor: Single): T3dVector;
inline;
function Dot(const A, B: T3dVector): Single;
inline;
function Cross(const A, B: T3dVector): T3dVector;
inline;
function Length3d(const A: T3dVector): Single;
inline;
function Normalize(const A: T3dVector): T3dVector;
function ClampValue(AValue, AMinimum, AMaximum: Single): Single;
inline;

implementation

function Add(const A, B: T3dVector): T3dVector;
begin
  Result := Vector3d(A.X + B.X, A.Y + B.Y, A.Z + B.Z);
end;

function Subtract(const A, B: T3dVector): T3dVector;
begin
  Result := Vector3d(A.X - B.X, A.Y - B.Y, A.Z - B.Z);
end;

function Scale(const A: T3dVector; AFactor: Single): T3dVector;
begin
  Result := Vector3d(A.X * AFactor, A.Y * AFactor, A.Z * AFactor);
end;

function Dot(const A, B: T3dVector): Single;
begin
  Result := A.X * B.X + A.Y * B.Y + A.Z * B.Z;
end;

function Cross(const A, B: T3dVector): T3dVector;
begin
  Result := Vector3d(A.Y * B.Z - A.Z * B.Y,
            A.Z * B.X - A.X * B.Z, A.X * B.Y - A.Y * B.X);
end;

function Length3d(const A: T3dVector): Single;
begin
  Result := Sqrt(Dot(A, A));
end;

function Normalize(const A: T3dVector): T3dVector;

var
  lLength: Single;
begin
  lLength := Length3d(A);
  if lLength <= C3dEpsilon then
    Exit(Vector3d(0, 0, 0));
  Result := Scale(A, 1 / lLength);
end;

function ClampValue(AValue, AMinimum, AMaximum: Single): Single;
begin
  if AValue < AMinimum then
    Exit(AMinimum);
  if AValue > AMaximum then
    Exit(AMaximum);
  Result := AValue;
end;

end.
