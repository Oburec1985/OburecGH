unit u3dCameraInteraction;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Math, u3dCoreTypes, u3dInteractionTypes;

procedure CameraBasis(const ACamera: T3dOrbitCamera; out AForward, ARight,
  AUp: T3dVector);
procedure RotateCamera(var ACamera: T3dOrbitCamera; const ADelta: T3dPoint;
  ASensitivity: Single);
procedure RotateCameraConstrained(var ACamera: T3dOrbitCamera;
  const ADelta: T3dPoint; ASensitivity: Single;
  AConstraint: T3dCameraRotationConstraint);
procedure PanCamera(var ACamera: T3dOrbitCamera; const ADelta: T3dPoint;
  const AViewport: T3dViewport);
procedure ZoomCamera(var ACamera: T3dOrbitCamera; ASteps: Single);
procedure FitCamera(var ACamera: T3dOrbitCamera; const ACenter: T3dVector;
  ARadius: Single; const AViewport: T3dViewport);
function CameraRay(const ACamera: T3dOrbitCamera; const AViewport: T3dViewport;
  const APosition: T3dPoint): T3dRay;
procedure FitCameraToBox(var ACamera:T3dOrbitCamera; const AMinimum,AMaximum:T3dVector;
  const AViewport:T3dViewport);

implementation

uses
  u3dInteractionMath;

procedure CameraBasis(const ACamera: T3dOrbitCamera; out AForward, ARight,
  AUp: T3dVector);
var
  lYaw, lPitch, lRoll, lCosRoll, lSinRoll: Single;
  lBaseRight, lBaseUp: T3dVector;
begin
  lYaw := DegToRad(ACamera.YawDegrees);
  lPitch := DegToRad(ACamera.PitchDegrees);
  AForward := Normalize(Vector3d(-Cos(lPitch) * Sin(lYaw), Sin(lPitch),
    -Cos(lPitch) * Cos(lYaw)));
  lBaseRight := Normalize(Cross(AForward, Vector3d(0, 1, 0)));
  lBaseUp := Normalize(Cross(lBaseRight, AForward));
  lRoll := DegToRad(ACamera.RollDegrees);
  lCosRoll := Cos(lRoll); lSinRoll := Sin(lRoll);
  ARight := Add(Scale(lBaseRight,lCosRoll),Scale(lBaseUp,lSinRoll));
  AUp := Add(Scale(lBaseUp,lCosRoll),Scale(lBaseRight,-lSinRoll));
end;

procedure FitCameraToBox(var ACamera:T3dOrbitCamera; const AMinimum,AMaximum:T3dVector;
  const AViewport:T3dViewport);
var
  lCenter:T3dVector;
  lRadius:Single;
begin
  lCenter:=Vector3d((AMinimum.X+AMaximum.X)*0.5,
    (AMinimum.Y+AMaximum.Y)*0.5,(AMinimum.Z+AMaximum.Z)*0.5);
  lRadius:=0.5*Sqrt(Sqr(AMaximum.X-AMinimum.X)+
    Sqr(AMaximum.Y-AMinimum.Y)+Sqr(AMaximum.Z-AMinimum.Z));
  FitCamera(ACamera,lCenter,lRadius,AViewport);
end;

procedure RotateCamera(var ACamera: T3dOrbitCamera; const ADelta: T3dPoint;
  ASensitivity: Single);
begin
  RotateCameraConstrained(ACamera,ADelta,ASensitivity,crcFree);
end;

procedure RotateCameraConstrained(var ACamera: T3dOrbitCamera;
  const ADelta: T3dPoint; ASensitivity: Single;
  AConstraint: T3dCameraRotationConstraint);
begin
  case AConstraint of
    crcX: ACamera.PitchDegrees:=ClampValue(ACamera.PitchDegrees-
      ADelta.Y*ASensitivity,-89,89);
    crcY: ACamera.YawDegrees:=ACamera.YawDegrees+ADelta.X*ASensitivity;
    crcZ: ACamera.RollDegrees:=ACamera.RollDegrees+ADelta.X*ASensitivity;
  else
    begin
      ACamera.YawDegrees:=ACamera.YawDegrees+ADelta.X*ASensitivity;
      ACamera.PitchDegrees:=ClampValue(ACamera.PitchDegrees-
        ADelta.Y*ASensitivity,-89,89);
    end;
  end;
end;

procedure PanCamera(var ACamera: T3dOrbitCamera; const ADelta: T3dPoint;
  const AViewport: T3dViewport);
var
  lForward, lRight, lUp, lMove: T3dVector;
  lWorldPerPixel: Single;
begin
  if AViewport.Height <= 0 then Exit;
  CameraBasis(ACamera, lForward, lRight, lUp);
  lWorldPerPixel := 2 * ACamera.Distance *
    Tan(DegToRad(ACamera.VerticalFovDegrees) * 0.5) / AViewport.Height;
  lMove := Add(Scale(lRight, -ADelta.X * lWorldPerPixel),
    Scale(lUp, ADelta.Y * lWorldPerPixel));
  ACamera.Target := Add(ACamera.Target, lMove);
end;

procedure ZoomCamera(var ACamera: T3dOrbitCamera; ASteps: Single);
begin
  ACamera.Distance := ClampValue(ACamera.Distance * Power(0.9, ASteps),
    0.001, 1.0e9);
end;

procedure FitCamera(var ACamera: T3dOrbitCamera; const ACenter: T3dVector;
  ARadius: Single; const AViewport: T3dViewport);
var
  lVerticalHalfAngle, lHorizontalHalfAngle, lFitAngle, lAspect: Single;
begin
  ACamera.Target := ACenter;
  if (ARadius <= 0) or (AViewport.Width <= 0) or (AViewport.Height <= 0) then
    Exit;
  lVerticalHalfAngle := DegToRad(ACamera.VerticalFovDegrees) * 0.5;
  lAspect := AViewport.Width / AViewport.Height;
  lHorizontalHalfAngle := ArcTan(Tan(lVerticalHalfAngle) * lAspect);
  lFitAngle := Min(lVerticalHalfAngle, lHorizontalHalfAngle);
  ACamera.Distance := ARadius / Max(Sin(lFitAngle), C3dEpsilon);
end;

function CameraRay(const ACamera: T3dOrbitCamera; const AViewport: T3dViewport;
  const APosition: T3dPoint): T3dRay;
var
  lForward, lRight, lUp, lOffset: T3dVector;
  lX, lY, lAspect, lTanHalfFov: Single;
begin
  CameraBasis(ACamera, lForward, lRight, lUp);
  Result.Origin := Subtract(ACamera.Target, Scale(lForward, ACamera.Distance));
  if (AViewport.Width <= 0) or (AViewport.Height <= 0) then
  begin
    Result.Direction := lForward;
    Exit;
  end;
  lX := 2 * APosition.X / AViewport.Width - 1;
  lY := 1 - 2 * APosition.Y / AViewport.Height;
  lAspect := AViewport.Width / AViewport.Height;
  lTanHalfFov := Tan(DegToRad(ACamera.VerticalFovDegrees) * 0.5);
  lOffset := Add(Scale(lRight, lX * lAspect * lTanHalfFov),
    Scale(lUp, lY * lTanHalfFov));
  Result.Direction := Normalize(Add(lForward, lOffset));
end;

end.
