unit u3dCoreTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  T3dVector = record
    X, Y, Z: Single;
  end;

  T3dCamera = record
    Target: T3dVector;
    YawDegrees: Single;
    PitchDegrees: Single;
    RollDegrees: Single;
    Distance: Single;
  end;

function Vector3d(AX, AY, AZ: Single): T3dVector;

implementation

function Vector3d(AX, AY, AZ: Single): T3dVector;
begin
  Result.X := AX;
  Result.Y := AY;
  Result.Z := AZ;
end;

end.
