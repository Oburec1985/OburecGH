unit u3dCameraInteraction;

{ Supplies pure orbit, pan, zoom, fit, and ray math for the LCL input adapter.
  It mutates only the camera record supplied by the caller. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Math, u3dCoreTypes, u3dInteractionTypes;

procedure CameraBasis(const ACamera: T3dOrbitCamera; out AForward, ARight,
                      AUp: T3dVector);
function CanonicalCamera(const ACamera:T3dOrbitCamera): T3dCamera;
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
  u3dInteractionMath, u3dCamera;

function CanonicalCamera(const ACamera:T3dOrbitCamera): T3dCamera;
begin
  Result.Target := ACamera.Target;
  Result.Forward := ACamera.Forward;
  Result.Right := ACamera.Right;
  Result.Up := ACamera.Up;
  Result.PoseValid := ACamera.PoseValid;
  Result.YawDegrees := ACamera.YawDegrees;
  Result.PitchDegrees := ACamera.PitchDegrees;
  Result.RollDegrees := ACamera.RollDegrees;
  Result.Distance := ACamera.Distance;
  Result.VerticalFovDegrees := ACamera.VerticalFovDegrees;
  Result.ProjectionKind := ACamera.ProjectionKind;
  Result.OrthographicScale := ACamera.OrthographicScale;
  Result.NearPlane := 0;
  Result.FarPlane := 0;
end;

procedure CameraBasis(const ACamera: T3dOrbitCamera; out AForward, ARight,
                      AUp: T3dVector);
begin
  BuildCameraBasis(CanonicalCamera(ACamera),AForward,ARight,AUp);
end;

procedure FitCameraToBox(var ACamera:T3dOrbitCamera; const AMinimum,AMaximum:T3dVector;
                         const AViewport:T3dViewport);

var
  lCenter,lCorner,lOffset,lForward,lRight,lUp: T3dVector;
  lAspect,lTanV,lTanH,lRequired,lX,lY,lZ: Single;
  lIndex: Integer;
begin
  lCenter := Vector3d((AMinimum.X+AMaximum.X)*0.5,
             (AMinimum.Y+AMaximum.Y)*0.5,(AMinimum.Z+AMaximum.Z)*0.5);
  ACamera.Target := lCenter;
  if (AViewport.Width<=0) or (AViewport.Height<=0) then
    Exit;
  lAspect := AViewport.Width/AViewport.Height;
  lTanV := Tan(DegToRad(ACamera.VerticalFovDegrees)*0.5);
  lTanH := lTanV*lAspect;
  if (lTanV<=C3dEpsilon) or (lTanH<=C3dEpsilon) then
    Exit;
  CameraBasis(ACamera,lForward,lRight,lUp);
  lRequired := C3dEpsilon;
  for lIndex:=0 to 7 do
    begin
      if (lIndex and 1)=0 then
        lCorner.X := AMinimum.X
      else lCorner.X := AMaximum.X;
      if (lIndex and 2)=0 then
        lCorner.Y := AMinimum.Y
      else lCorner.Y := AMaximum.Y;
      if (lIndex and 4)=0 then
        lCorner.Z := AMinimum.Z
      else lCorner.Z := AMaximum.Z;
      lOffset := Subtract(lCorner,lCenter);
      lX := Abs(Dot(lOffset,lRight));
      lY := Abs(Dot(lOffset,lUp));
      lZ := Dot(lOffset,lForward);
      lRequired := Max(lRequired,1.2*lX/lTanH-lZ);
      lRequired := Max(lRequired,1.2*lY/lTanV-lZ);
    end;
  ACamera.Distance := lRequired;
end;

procedure RotateCamera(var ACamera: T3dOrbitCamera; const ADelta: T3dPoint;
                       ASensitivity: Single);
begin
  RotateCameraConstrained(ACamera,ADelta,ASensitivity,crcFree);
end;

function RotateAroundAxis(const AVector,AAxis:T3dVector;
                          AAngleRadians:Single):T3dVector;

var
  lAxis: T3dVector;
  lCosine,lSine: Single;
begin
  lAxis := Normalize(AAxis);
  lCosine := Cos(AAngleRadians);
  lSine := Sin(AAngleRadians);
  Result := Add(Add(Scale(AVector,lCosine),
                Scale(Cross(lAxis,AVector),lSine)),
                Scale(lAxis,Dot(lAxis,AVector)*(1-lCosine)));
end;

procedure AssignCameraBasis(var ACamera:T3dOrbitCamera;
                            const AForward,ARight:T3dVector);

var
  lForward,lRight,lUp: T3dVector;
begin
  lForward := Normalize(AForward);
  lRight := Normalize(ARight);
  { Re-orthogonalize after incremental matrix/axis-angle rotations. The pose,
    not an Euler decomposition, remains the source of truth. }
  lUp := Normalize(Cross(lRight,lForward));
  lRight := Normalize(Cross(lForward,lUp));
  ACamera.Forward := lForward;
  ACamera.Right := lRight;
  ACamera.Up := lUp;
  ACamera.PoseValid := True;
end;

procedure RotateCameraConstrained(var ACamera: T3dOrbitCamera;
                                  const ADelta: T3dPoint; ASensitivity: Single;
                                  AConstraint: T3dCameraRotationConstraint);

var
  lForward,lRight,lUp,lAxis: T3dVector;
  lAngle: Single;
begin
  case AConstraint of
    crcX,crcY,crcZ:
      begin
        CameraBasis(ACamera,lForward,lRight,lUp);
        case AConstraint of
          crcX:
            begin
              lAxis := lRight;
              lAngle := DegToRad(-ADelta.Y*ASensitivity);
            end;
          crcY:
            begin
              lAxis := lUp;
              lAngle := DegToRad(ADelta.X*ASensitivity);
            end;
          else
            begin
              lAxis := lForward;
              lAngle := DegToRad(-ADelta.X*ASensitivity);
            end;
        end;
        lForward := RotateAroundAxis(lForward,lAxis,lAngle);
        lRight := RotateAroundAxis(lRight,lAxis,lAngle);
        AssignCameraBasis(ACamera,lForward,lRight);
      end;
    else
      begin
        CameraBasis(ACamera,lForward,lRight,lUp);
        lAngle := DegToRad(-ADelta.X*ASensitivity);
        lForward := RotateAroundAxis(lForward,lUp,lAngle);
        lRight := RotateAroundAxis(lRight,lUp,lAngle);
        AssignCameraBasis(ACamera,lForward,lRight);
        CameraBasis(ACamera,lForward,lRight,lUp);
        lAngle := DegToRad(-ADelta.Y*ASensitivity);
        lForward := RotateAroundAxis(lForward,lRight,lAngle);
        lUp := RotateAroundAxis(lUp,lRight,lAngle);
        AssignCameraBasis(ACamera,lForward,lRight);
      end;
  end;
end;

procedure PanCamera(var ACamera: T3dOrbitCamera; const ADelta: T3dPoint;
                    const AViewport: T3dViewport);

var
  lForward, lRight, lUp, lMove: T3dVector;
  lWorldPerPixel, lScale: Single;
begin
  if AViewport.Height <= 0 then
    Exit;
  CameraBasis(ACamera, lForward, lRight, lUp);
  if ACamera.ProjectionKind=pkOrthographic then
  begin
    lScale := ACamera.OrthographicScale;
    if lScale<=0 then
      lScale := Max(0.1,ACamera.Distance*0.5);
    lWorldPerPixel := 2*lScale/AViewport.Height;
  end
  else
    lWorldPerPixel := 2 * ACamera.Distance *
                      Tan(DegToRad(ACamera.VerticalFovDegrees) * 0.5) / AViewport.Height;


{ Dragging moves the viewed surface with the pointer, so the camera translates
    in the opposite direction in its right/up plane. }
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
  lX, lY, lAspect, lTanHalfFov, lScale: Single;
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
  if ACamera.ProjectionKind = pkOrthographic then
  begin
    lScale := ACamera.OrthographicScale;
    if lScale<=0 then
      lScale := Max(0.1,ACamera.Distance*0.5);
    lOffset := Add(Scale(lRight, lX * lAspect * lScale),
               Scale(lUp, lY * lScale));
    Result.Origin := Add(Result.Origin, lOffset);
    Result.Direction := lForward;
    Exit;
  end;
  lTanHalfFov := Tan(DegToRad(ACamera.VerticalFovDegrees) * 0.5);
  lOffset := Add(Scale(lRight, lX * lAspect * lTanHalfFov),
             Scale(lUp, lY * lTanHalfFov));
  Result.Direction := Normalize(Add(lForward, lOffset));
end;

end.
