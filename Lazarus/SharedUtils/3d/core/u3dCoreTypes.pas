unit u3dCoreTypes;

{ Holds dependency-free vectors, camera state, and bounds records shared by
  core, interaction, and rendering layers. Coordinates use right-handed units. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  T3dProjectionKind = (pkPerspective, pkOrthographic);
  T3dStandardView = (svCamera, svTop, svFront, svBottom);

  T3dVector = record
    X, Y, Z: Single;
  end;

  T3dCamera = record
    Target: T3dVector;
    { Canonical runtime orientation. Euler fields below are retained only for
      loading legacy settings and initializing this pose. }
    Forward, Right, Up: T3dVector;
    PoseValid: Boolean;
    YawDegrees: Single;
    PitchDegrees: Single;
    RollDegrees: Single;
    Distance: Single;
    VerticalFovDegrees: Single;
    NearPlane: Single;
    FarPlane: Single;
    ProjectionKind: T3dProjectionKind;
    OrthographicScale: Single;
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
