unit u3dCamera;

{ Converts canonical camera state into view/projection snapshots shared by
  rendering and ray construction, preventing lens or handedness divergence. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses u3dCoreTypes,u3dScene;

type


{ Right-handed world and camera basis: Forward looks down camera -Z, Right
    is +X, Up is +Y. Matrices are OpenGL column-major. Zero/invalid lens
    values preserve legacy files by falling back to FOV 45 and dynamic clip. }
  T3dCameraSnapshot = record
    Position,Forward,Right,Up: T3dVector;
    VerticalFovDegrees,NearPlane,FarPlane: Single;
    ViewMatrix,ProjectionMatrix: T3dMatrix;
  end;

function EffectiveVerticalFov(const ACamera:T3dCamera): Single;
function CameraPosition(const ACamera:T3dCamera): T3dVector;
procedure BuildCameraBasis(const ACamera:T3dCamera; out AForward,ARight,AUp:T3dVector);
function BuildViewMatrix(const ACamera:T3dCamera): T3dMatrix;
function BuildProjectionMatrix(const ACamera:T3dCamera; AAspect:Single;
                               ANear,AFar:Single): T3dMatrix;
function BuildCameraSnapshot(const ACamera:T3dCamera; AWidth,AHeight:Integer;
                             ASceneRadius:Single): T3dCameraSnapshot;

implementation

uses Math,u3dGeometryMath;

function EffectiveVerticalFov(const ACamera:T3dCamera): Single;
begin
  Result := ACamera.VerticalFovDegrees;
  if (Result<=1) or (Result>=179) then
    Result := 45;
end;

procedure BuildCameraBasis(const ACamera:T3dCamera; out AForward,ARight,AUp:T3dVector);

var Yaw,Pitch,Roll,C,S: Single;
  BaseRight,BaseUp,ReferenceUp: T3dVector;
  ForwardLength,RightLength,UpLength: Single;
begin
  ForwardLength := VectorDot(ACamera.Forward,ACamera.Forward);
  RightLength := VectorDot(ACamera.Right,ACamera.Right);
  UpLength := VectorDot(ACamera.Up,ACamera.Up);
  if ACamera.PoseValid and
     (Abs(ForwardLength-1)<0.001) and (Abs(RightLength-1)<0.001) and
     (Abs(UpLength-1)<0.001) and
     (Abs(VectorDot(ACamera.Forward,ACamera.Right))<0.001) and
     (Abs(VectorDot(ACamera.Forward,ACamera.Up))<0.001) then
  begin
    AForward := ACamera.Forward;
    ARight := ACamera.Right;
    AUp := ACamera.Up;
    Exit;
  end;
  Yaw := DegToRad(ACamera.YawDegrees);
  Pitch := DegToRad(ACamera.PitchDegrees);
  AForward := Vector3d(-Cos(Pitch)*Sin(Yaw),Sin(Pitch),-Cos(Pitch)*Cos(Yaw));
  TryNormalize(AForward,AForward);
  ReferenceUp := Vector3d(0,1,0);
  if Abs(VectorDot(AForward,ReferenceUp)) > 0.999 then
    ReferenceUp := Vector3d(0,0,1);
  TryNormalize(VectorCross(AForward,ReferenceUp),BaseRight);
  TryNormalize(VectorCross(BaseRight,AForward),BaseUp);
  Roll := DegToRad(ACamera.RollDegrees);
  C := Cos(Roll);
  S := Sin(Roll);
  ARight := VectorAdd(VectorScale(BaseRight,C),VectorScale(BaseUp,S));
  AUp := VectorAdd(VectorScale(BaseUp,C),VectorScale(BaseRight,-S));
end;

function CameraPosition(const ACamera:T3dCamera): T3dVector;

var F,R,U: T3dVector;
begin
  BuildCameraBasis(ACamera,F,R,U);
  Result := VectorSubtract(ACamera.Target,VectorScale(F,ACamera.Distance));
end;

function BuildViewMatrix(const ACamera:T3dCamera): T3dMatrix;

var F,R,U,P: T3dVector;
begin
  BuildCameraBasis(ACamera,F,R,U);
  P := CameraPosition(ACamera);
  SetIdentity(Result);
  Result[0] := R.X;
  Result[4] := R.Y;
  Result[8] := R.Z;
  Result[1] := U.X;
  Result[5] := U.Y;
  Result[9] := U.Z;
  Result[2] := -F.X;
  Result[6] := -F.Y;
  Result[10] := -F.Z;
  Result[12] := -VectorDot(R,P);
  Result[13] := -VectorDot(U,P);
  Result[14] := VectorDot(F,P);
end;

function BuildProjectionMatrix(const ACamera:T3dCamera; AAspect:Single;
                               ANear,AFar:Single): T3dMatrix;

var ScaleValue: Single;
  I: Integer;
  HalfHeight,HalfWidth: Single;
begin
  for I:=0 to High(Result) do
    Result[I] := 0;
  if AAspect<=0 then
    AAspect := 1;
  ANear := Max(ANear,0.0001);
  AFar := Max(AFar,ANear+0.001);
  if ACamera.ProjectionKind = pkOrthographic then
  begin
    HalfHeight := ACamera.OrthographicScale;
    if HalfHeight <= 0 then
      HalfHeight := Max(0.1, ACamera.Distance * 0.5);
    HalfWidth := HalfHeight * AAspect;
    Result[0] := 1 / HalfWidth;
    Result[5] := 1 / HalfHeight;
    Result[10] := -2 / (AFar - ANear);
    Result[14] := -(AFar + ANear) / (AFar - ANear);
    Result[15] := 1;
    Exit;
  end;
  ScaleValue := 1/Tan(DegToRad(EffectiveVerticalFov(ACamera))*0.5);
  Result[0] := ScaleValue/AAspect;
  Result[5] := ScaleValue;
  Result[10] := (AFar+ANear)/(ANear-AFar);
  Result[11] := -1;
  Result[14] := 2*AFar*ANear/(ANear-AFar);
end;

function BuildCameraSnapshot(const ACamera:T3dCamera; AWidth,AHeight:Integer;
                             ASceneRadius:Single): T3dCameraSnapshot;

var Aspect: Single;
begin
  BuildCameraBasis(ACamera,Result.Forward,Result.Right,Result.Up);
  Result.Position := CameraPosition(ACamera);
  Result.VerticalFovDegrees := EffectiveVerticalFov(ACamera);
  Result.NearPlane := ACamera.NearPlane;
  Result.FarPlane := ACamera.FarPlane;
  if (Result.NearPlane<=0) or (Result.FarPlane<=Result.NearPlane) then
    begin
      if ASceneRadius>0 then
        begin
          Result.NearPlane := Max(0.001,ACamera.Distance-ASceneRadius*2);
          Result.FarPlane := Max(Result.NearPlane+1,ACamera.Distance+ASceneRadius*2);
        end
      else
        begin
          Result.NearPlane := 0.01;
          Result.FarPlane := Max(100,ACamera.Distance*10);
        end;
    end;
  if AHeight>0 then
    Aspect := AWidth/AHeight
  else Aspect := 1;
  Result.ViewMatrix := BuildViewMatrix(ACamera);
  Result.ProjectionMatrix := BuildProjectionMatrix(ACamera,Aspect,
                             Result.NearPlane,Result.FarPlane);
end;

end.
