unit u3dInteractionTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes;

type
  T3dNodeId = QWord;

  T3dPoint = record
    X, Y: Single;
  end;

  T3dViewport = record
    Width, Height: Integer;
  end;

  T3dOrbitCamera = record
    Target: T3dVector;
    YawDegrees: Single;
    PitchDegrees: Single;
    RollDegrees: Single;
    Distance: Single;
    VerticalFovDegrees: Single;
  end;

  T3dCameraRotationConstraint = (crcFree, crcX, crcY, crcZ);

  T3dRay = record
    Origin: T3dVector;
    Direction: T3dVector;
  end;

  T3dAxisBasis = record
    XAxis, YAxis, ZAxis: T3dVector;
  end;

  T3dInputMode = (imSelect, imPan, imRotate, imZoom);
  T3dInputState = (isIdle, isPressed, isDragging);
  T3dPointerButton = (pbNone, pbLeft, pbMiddle, pbRight);
  T3dModifier = (mdCtrl, mdShift, mdAlt);
  T3dModifiers = set of T3dModifier;
  T3dInputCommand = (icNone, icSelect, icPan, icRotate, icZoom);

  T3dInputResult = record
    Command: T3dInputCommand;
    Delta: T3dPoint;
    Position: T3dPoint;
    CapturePointer: Boolean;
    ReleasePointer: Boolean;
  end;

function Point3d(AX, AY: Single): T3dPoint;
function IdentityAxisBasis: T3dAxisBasis;

implementation

function Point3d(AX, AY: Single): T3dPoint;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function IdentityAxisBasis: T3dAxisBasis;
begin
  Result.XAxis := Vector3d(1, 0, 0);
  Result.YAxis := Vector3d(0, 1, 0);
  Result.ZAxis := Vector3d(0, 0, 1);
end;

end.
