unit u3dScreenGeometryMath;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes,u3dInteractionTypes;

function ProjectWorldToScreen(const AWorld:T3dVector;
  const ACamera:T3dOrbitCamera; const AViewport:T3dViewport;
  out AScreen:T3dPoint; out ADepth:Single):Boolean;
function ScreenAxisHitTest(const AOrigin:T3dVector; const ABasis:T3dAxisBasis;
  AAxisLength:Single; const ACamera:T3dOrbitCamera;
  const AViewport:T3dViewport; const APoint:T3dPoint; ATolerancePixels:Single;
  out AAxisIndex:Integer):Boolean;

implementation

uses
  Math,u3dInteractionMath,u3dCameraInteraction;

function ProjectWorldToScreen(const AWorld:T3dVector;
  const ACamera:T3dOrbitCamera; const AViewport:T3dViewport;
  out AScreen:T3dPoint; out ADepth:Single):Boolean;
var
  lForward,lRight,lUp,lCameraOrigin,lRelative:T3dVector;
  lHalfHeight,lHalfWidth:Single;
begin
  AScreen:=Point3d(0,0); ADepth:=0;
  Result:=(AViewport.Width>0) and (AViewport.Height>0) and
    (ACamera.VerticalFovDegrees>0);
  if not Result then Exit;
  CameraBasis(ACamera,lForward,lRight,lUp);
  lCameraOrigin:=Subtract(ACamera.Target,Scale(lForward,ACamera.Distance));
  lRelative:=Subtract(AWorld,lCameraOrigin); ADepth:=Dot(lRelative,lForward);
  Result:=ADepth>C3dEpsilon; if not Result then Exit;
  lHalfHeight:=ADepth*Tan(DegToRad(ACamera.VerticalFovDegrees)*0.5);
  lHalfWidth:=lHalfHeight*AViewport.Width/AViewport.Height;
  if (lHalfHeight<=C3dEpsilon) or (lHalfWidth<=C3dEpsilon) then Exit(False);
  AScreen.X:=(Dot(lRelative,lRight)/lHalfWidth+1)*AViewport.Width*0.5;
  AScreen.Y:=(1-Dot(lRelative,lUp)/lHalfHeight)*AViewport.Height*0.5;
end;

function PointSegmentDistance(const APoint,AStart,AEnd:T3dPoint;
  out APosition:Single):Single;
var
  lX,lY,lLengthSquared,lClosestX,lClosestY:Single;
begin
  lX:=AEnd.X-AStart.X; lY:=AEnd.Y-AStart.Y;
  lLengthSquared:=lX*lX+lY*lY;
  if lLengthSquared<=C3dEpsilon then APosition:=0
  else APosition:=ClampValue(((APoint.X-AStart.X)*lX+
    (APoint.Y-AStart.Y)*lY)/lLengthSquared,0,1);
  lClosestX:=AStart.X+lX*APosition; lClosestY:=AStart.Y+lY*APosition;
  Result:=Sqrt(Sqr(APoint.X-lClosestX)+Sqr(APoint.Y-lClosestY));
end;

function ScreenAxisHitTest(const AOrigin:T3dVector; const ABasis:T3dAxisBasis;
  AAxisLength:Single; const ACamera:T3dOrbitCamera;
  const AViewport:T3dViewport; const APoint:T3dPoint; ATolerancePixels:Single;
  out AAxisIndex:Integer):Boolean;
var
  lAxis:Integer;
  lVector,lEnd:T3dVector;
  lStartScreen,lEndScreen:T3dPoint;
  lStartDepth,lEndDepth,lDepth,lPosition,lDistance,lBestDistance,lBestDepth:Single;
begin
  AAxisIndex:=-1; lBestDistance:=MaxSingle; lBestDepth:=MaxSingle;
  for lAxis:=0 to 2 do begin
    case lAxis of 0:lVector:=ABasis.XAxis; 1:lVector:=ABasis.YAxis;
    else lVector:=ABasis.ZAxis; end;
    lEnd:=Add(AOrigin,Scale(lVector,AAxisLength));
    if not ProjectWorldToScreen(AOrigin,ACamera,AViewport,lStartScreen,lStartDepth)
      or not ProjectWorldToScreen(lEnd,ACamera,AViewport,lEndScreen,lEndDepth) then Continue;
    lDistance:=PointSegmentDistance(APoint,lStartScreen,lEndScreen,lPosition);
    if lDistance>ATolerancePixels then Continue;
    lDepth:=lStartDepth+(lEndDepth-lStartDepth)*lPosition;
    if (lDistance<lBestDistance-0.01) or
      ((Abs(lDistance-lBestDistance)<=0.01) and (lDepth<lBestDepth)) then begin
      AAxisIndex:=lAxis; lBestDistance:=lDistance; lBestDepth:=lDepth;
    end;
  end;
  Result:=AAxisIndex>=0;
end;

end.
