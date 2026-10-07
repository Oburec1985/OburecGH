unit u3dCameraRotateOverlay;

{ Tracks the screen-space camera-rotation overlay, including hit selection and
  drag lifecycle. Rendering consumes its state but does not own it. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dInteractionTypes;

type
  T3dCameraRotateHandle = (crhY,crhX,crhZ,crhNone);
  T3dCameraRotateOverlayState = (crosHidden,crosIdle,crosHover,crosPressed,crosDragging);

  T3dCameraRotateOverlay = class
  private
      fState: T3dCameraRotateOverlayState;
      fCenter: T3dPoint;
      fRadius: Single;
      fTolerance: Single;
      fSelected: T3dCameraRotateHandle;
      fHover: T3dCameraRotateHandle;
      fPress,fLast: T3dPoint;
      fDragThreshold: Single;
  public
      constructor Create;
      procedure Show(const ACenter:T3dPoint; ARadius:Single);
      procedure Hide;
      function HitTest(const APoint:T3dPoint): T3dCameraRotateHandle;
      procedure SelectHandle(AHandle:T3dCameraRotateHandle);
      function BeginDrag(AHandle:T3dCameraRotateHandle;
                         const APoint:T3dPoint): Boolean;
      function UpdateDrag(const APoint:T3dPoint; out ADelta:T3dPoint): Boolean;
      procedure EndDrag;
      property State: T3dCameraRotateOverlayState read fState;
      property Center: T3dPoint read fCenter;
      property Radius: Single read fRadius;
      property HoverHandle: T3dCameraRotateHandle read fHover;
      property SelectedHandle: T3dCameraRotateHandle read fSelected;
  end;

function RotationConstraintForHandle(AHandle:T3dCameraRotateHandle):
                                                                     T3dCameraRotationConstraint;

implementation

uses Math;

constructor T3dCameraRotateOverlay.Create;
begin
  inherited Create;
  fState := crosHidden;
  fSelected := crhNone;
  fHover := crhNone;
  fTolerance := 10;
  fDragThreshold := 3;
end;

procedure T3dCameraRotateOverlay.Show(const ACenter:T3dPoint; ARadius:Single);
begin
  fCenter := ACenter;
  fRadius := Max(ARadius,16);
  fHover := crhNone;
  fState := crosIdle;
end;

procedure T3dCameraRotateOverlay.Hide;
begin
  fState := crosHidden;
  fHover := crhNone;
  fSelected := crhNone;
end;

function T3dCameraRotateOverlay.HitTest(const APoint:T3dPoint): T3dCameraRotateHandle;

var
  lX,lY,lCircleDistance,lBest,lCenterDistance: Single;
procedure Consider(AHandle:T3dCameraRotateHandle; AScore:Single);
begin
  if AScore<lBest then
    begin
      lBest := AScore;
      Result := AHandle;
    end;
end;
begin
  Result := crhNone;
  if fState=crosHidden then
    Exit;
  lX := APoint.X-fCenter.X;
  lY := APoint.Y-fCenter.Y;
  lBest := MaxSingle;
  lCenterDistance := Sqrt(lX*lX+lY*lY);
  { The crossing is deliberately neutral: choosing an axis there is accidental. }
  if lCenterDistance<=fTolerance then
    begin
      fHover := crhNone;
      fState := crosIdle;
      Exit;
    end;
  if (Abs(lX)<=fRadius) and (Abs(lY)<=fTolerance) then
    Consider(crhY,Abs(lY)/fTolerance);
  if (Abs(lY)<=fRadius) and (Abs(lX)<=fTolerance) then
    Consider(crhX,Abs(lX)/fTolerance);
  lCircleDistance := Abs(Sqrt(lX*lX+lY*lY)-fRadius);
  if lCircleDistance<=fTolerance then
    Consider(crhZ,lCircleDistance/fTolerance);
  fHover := Result;
  if Result=crhNone then
    fState := crosIdle
  else fState := crosHover;
end;

procedure T3dCameraRotateOverlay.SelectHandle(AHandle:T3dCameraRotateHandle);
begin
  if fState<>crosHidden then
    fSelected := AHandle;
end;

function T3dCameraRotateOverlay.BeginDrag(AHandle:T3dCameraRotateHandle;
                                          const APoint:T3dPoint): Boolean;
begin
  Result := (fState<>crosHidden) and (AHandle=fSelected) and
            (AHandle<>crhNone);
  if not Result then
    Exit;
  fPress := APoint;
  fLast := APoint;
  fState := crosPressed;
end;

function T3dCameraRotateOverlay.UpdateDrag(const APoint:T3dPoint;
                                           out ADelta:T3dPoint): Boolean;
var
  lPreviousAngle,lCurrentAngle,lAngleDelta:Single;
begin
  ADelta := Point3d(0,0);
  Result := False;
  if not (fState in [crosPressed,crosDragging]) then
    Exit;
  if (fState=crosPressed) and
     (Sqrt(Sqr(APoint.X-fPress.X)+Sqr(APoint.Y-fPress.Y))<fDragThreshold) then
    Exit;
  fState := crosDragging;
  if fSelected=crhZ then
  begin
    { The blue ring is a roll handle. Its drag must follow the cursor angle
      around the overlay centre; horizontal delta alone reverses at the top
      and bottom halves and makes camera rotation appear erratic. }
    lPreviousAngle:=ArcTan2(-(fLast.Y-fCenter.Y),fLast.X-fCenter.X);
    lCurrentAngle:=ArcTan2(-(APoint.Y-fCenter.Y),APoint.X-fCenter.X);
    lAngleDelta:=RadToDeg(lCurrentAngle-lPreviousAngle);
    while lAngleDelta>180 do lAngleDelta:=lAngleDelta-360;
    while lAngleDelta< -180 do lAngleDelta:=lAngleDelta+360;
    { Consumers currently apply sensitivity 0.5 degrees per delta unit. }
    ADelta:=Point3d(lAngleDelta*2,0);
  end
  else
    ADelta := Point3d(APoint.X-fLast.X,APoint.Y-fLast.Y);
  fLast := APoint;
  Result := True;
end;

procedure T3dCameraRotateOverlay.EndDrag;
begin
  if fState in [crosPressed,crosDragging] then
    fState := crosHover;
end;

function RotationConstraintForHandle(AHandle:T3dCameraRotateHandle):
                                                                     T3dCameraRotationConstraint;
begin
  case AHandle of
    crhX: Result := crcX;
    crhY: Result := crcY;
    crhZ: Result := crcZ;
    else Result := crcFree;
  end;
end;

end.
