unit u3dSceneMath;

{ Provides scene-level bounds, picking broad phase, and compatibility transform
  helpers used by interaction and Recorder adapters. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dScene;

type
  T3dPositionComponent = (pcX, pcY, pcZ);
  T3dPositionComponents = set of T3dPositionComponent;
  T3dLocalRotationAxis = (lraX, lraY, lraZ);

function FindSceneNode(AScene: T3dScene; AId: QWord): T3dNode;
function WorldBounds(ANode: T3dNode): T3dBounds;
function RayBoundsDistance(const ARayOrigin, ARayDirection:T3dVector;
                           const ABounds:T3dBounds; out ADistance:Single): Boolean;
function NodeWorldPivot(ANode:T3dNode): T3dVector;
function PickWorldAabb(AScene: T3dScene; const ARayOrigin,
                       ARayDirection: T3dVector): QWord;
function SetNodeWorldPosition(AScene: T3dScene; ANodeId: QWord;
                              const APosition: T3dVector): Boolean;
function SetNodeWorldPositionComponents(AScene: T3dScene; ANodeId: QWord;
                                        const APosition: T3dVector; AComponents:
                                        T3dPositionComponents): Boolean;
function RotateNodeLocalAxis(AScene:T3dScene; ANodeId:QWord;
                             AAxis:T3dLocalRotationAxis; ADegrees:Single): Boolean;

implementation

uses
  Math, u3dTransforms;

const
  CMatrixEpsilon = 1.0e-8;

function FindSceneNode(AScene: T3dScene; AId: QWord): T3dNode;

var
  lIndex: Integer;
begin
  Result := nil;
  if (AScene = nil) or (AId = 0) then
    Exit;
  for lIndex := 0 to High(AScene.Nodes) do
    if AScene.Nodes[lIndex].Id = AId then
      Exit(AScene.Nodes[lIndex]);
end;

function NodeWorldPivot(ANode:T3dNode): T3dVector;

var B: T3dBounds;
begin
  if ANode=nil then
    Exit(Vector3d(0,0,0));
  B := WorldBounds(ANode);
  if B.Valid then
    Result := Vector3d((B.Min.X+B.Max.X)*0.5,
              (B.Min.Y+B.Max.Y)*0.5,(B.Min.Z+B.Max.Z)*0.5)
  else Result := Vector3d(ANode.WorldTransform[12],ANode.WorldTransform[13],
                 ANode.WorldTransform[14]);
end;

function TransformPoint(const APoint: T3dVector;
                        const AMatrix: T3dMatrix): T3dVector;
begin
  Result := Vector3d(
            APoint.X * AMatrix[0] + APoint.Y * AMatrix[4] +
            APoint.Z * AMatrix[8] + AMatrix[12],
            APoint.X * AMatrix[1] + APoint.Y * AMatrix[5] +
            APoint.Z * AMatrix[9] + AMatrix[13],
            APoint.X * AMatrix[2] + APoint.Y * AMatrix[6] +
            APoint.Z * AMatrix[10] + AMatrix[14]);
end;

function WorldBounds(ANode: T3dNode): T3dBounds;

var
  lCorner: Integer;
  lPoint: T3dVector;
begin
  Result.Valid := False;
  if (ANode = nil) or not ANode.Bounds.Valid then
    Exit;
  for lCorner := 0 to 7 do
    begin
      if (lCorner and 1) = 0 then
        lPoint.X := ANode.Bounds.Min.X
      else lPoint.X := ANode.Bounds.Max.X;
      if (lCorner and 2) = 0 then
        lPoint.Y := ANode.Bounds.Min.Y
      else lPoint.Y := ANode.Bounds.Max.Y;
      if (lCorner and 4) = 0 then
        lPoint.Z := ANode.Bounds.Min.Z
      else lPoint.Z := ANode.Bounds.Max.Z;
      IncludePoint(Result, TransformPoint(lPoint, ANode.WorldTransform));
    end;
end;

function RayBoundsDistance(const ARayOrigin, ARayDirection: T3dVector;
                           const ABounds: T3dBounds; out ADistance: Single): Boolean;

var
  lAxis: Integer;
  lOrigin, lDirection, lMinimum, lMaximum, lNear, lFar, lSwap: Single;
begin
  ADistance := 0;
  lFar := MaxSingle;
  for lAxis := 0 to 2 do
    begin
      case lAxis of
        0:
           begin
             lOrigin := ARayOrigin.X;
             lDirection := ARayDirection.X;
             lMinimum := ABounds.Min.X;
             lMaximum := ABounds.Max.X;
           end;
        1:
           begin
             lOrigin := ARayOrigin.Y;
             lDirection := ARayDirection.Y;
             lMinimum := ABounds.Min.Y;
             lMaximum := ABounds.Max.Y;
           end;
        else
          begin
            lOrigin := ARayOrigin.Z;
            lDirection := ARayDirection.Z;
            lMinimum := ABounds.Min.Z;
            lMaximum := ABounds.Max.Z;
          end;
      end;
      if Abs(lDirection) <= CMatrixEpsilon then
        begin
          if (lOrigin < lMinimum) or (lOrigin > lMaximum) then
            Exit(False);
          Continue;
        end;
      lNear := (lMinimum - lOrigin) / lDirection;
      lSwap := (lMaximum - lOrigin) / lDirection;
      if lNear > lSwap then
        begin
          lMaximum := lNear;
          lNear := lSwap;
          lSwap := lMaximum;
        end;
      if lNear > ADistance then
        ADistance := lNear;
      if lSwap < lFar then
        lFar := lSwap;
      if ADistance > lFar then
        Exit(False);
    end;
  Result := lFar >= Max(ADistance, 0);
end;

function PickWorldAabb(AScene: T3dScene; const ARayOrigin,
                       ARayDirection: T3dVector): QWord;

var
  lIndex: Integer;
  lBounds: T3dBounds;
  lDistance, lBestDistance: Single;
begin
  Result := 0;
  if AScene = nil then
    Exit;
  lBestDistance := MaxSingle;
  for lIndex := 0 to High(AScene.Nodes) do
    begin
      if AScene.Nodes[lIndex].Kind <> nkMesh then
        Continue;
      lBounds := WorldBounds(AScene.Nodes[lIndex]);
      if lBounds.Valid and
         RayBoundsDistance(ARayOrigin, ARayDirection, lBounds, lDistance) and
         (lDistance < lBestDistance) then
        begin
          lBestDistance := lDistance;
          Result := AScene.Nodes[lIndex].Id;
        end;
    end;
end;

function SetNodeWorldPosition(AScene: T3dScene; ANodeId: QWord;
                              const APosition: T3dVector): Boolean;

var N: T3dNode;
  W: T3dMatrix;
begin
  N := FindSceneNode(AScene,ANodeId);
  if N=nil then
    Exit(False);
  W := N.WorldTransform;
  W[12] := APosition.X;
  W[13] := APosition.Y;
  W[14] := APosition.Z;
  Result := SetNodeWorldTransform(AScene,ANodeId,W);
end;

function SetNodeWorldPositionComponents(AScene: T3dScene; ANodeId: QWord;
                                        const APosition: T3dVector; AComponents:
                                        T3dPositionComponents): Boolean;

var
  lNode: T3dNode;
  lPosition: T3dVector;
begin
  Result := False;
  lNode := FindSceneNode(AScene, ANodeId);
  if (lNode = nil) or (AComponents = []) then
    Exit;
  lPosition := Vector3d(lNode.WorldTransform[12], lNode.WorldTransform[13],
               lNode.WorldTransform[14]);
  if pcX in AComponents then
    lPosition.X := APosition.X;
  if pcY in AComponents then
    lPosition.Y := APosition.Y;
  if pcZ in AComponents then
    lPosition.Z := APosition.Z;
  Result := SetNodeWorldPosition(AScene, ANodeId, lPosition);
end;

function RotateNodeLocalAxis(AScene:T3dScene; ANodeId:QWord;
                             AAxis:T3dLocalRotationAxis; ADegrees:Single): Boolean;

var Axis: T3dVector;
  Frame: T3dMatrix;
begin
  if Abs(ADegrees)<=CMatrixEpsilon then
    Exit(False);
  case AAxis of
    lraX: Axis := Vector3d(1,0,0);
    lraY: Axis := Vector3d(0,1,0);
    else Axis := Vector3d(0,0,1);
  end;
  SetIdentity(Frame);
  Result := RotateNode(AScene,ANodeId,Axis,DegToRad(ADegrees),
            Vector3d(0,0,0),tsLocal,Frame);
end;

end.
