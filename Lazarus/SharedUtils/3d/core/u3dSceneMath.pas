unit u3dSceneMath;

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
function NodeWorldPivot(ANode:T3dNode):T3dVector;
function PickWorldAabb(AScene: T3dScene; const ARayOrigin,
  ARayDirection: T3dVector): QWord;
function SetNodeWorldPosition(AScene: T3dScene; ANodeId: QWord;
  const APosition: T3dVector): Boolean;
function SetNodeWorldPositionComponents(AScene: T3dScene; ANodeId: QWord;
  const APosition: T3dVector; AComponents: T3dPositionComponents): Boolean;
function RotateNodeLocalAxis(AScene:T3dScene; ANodeId:QWord;
  AAxis:T3dLocalRotationAxis; ADegrees:Single):Boolean;

implementation

uses
  Math;

const
  CMatrixEpsilon = 1.0e-8;

function FindSceneNode(AScene: T3dScene; AId: QWord): T3dNode;
var
  lIndex: Integer;
begin
  Result := nil;
  if (AScene = nil) or (AId = 0) then Exit;
  for lIndex := 0 to High(AScene.Nodes) do
    if AScene.Nodes[lIndex].Id = AId then Exit(AScene.Nodes[lIndex]);
end;

function NodeWorldPivot(ANode:T3dNode):T3dVector;
var B:T3dBounds;
begin
  if ANode=nil then Exit(Vector3d(0,0,0));
  B:=WorldBounds(ANode);
  if B.Valid then Result:=Vector3d((B.Min.X+B.Max.X)*0.5,
    (B.Min.Y+B.Max.Y)*0.5,(B.Min.Z+B.Max.Z)*0.5)
  else Result:=Vector3d(ANode.WorldTransform[12],ANode.WorldTransform[13],
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
  if (ANode = nil) or not ANode.Bounds.Valid then Exit;
  for lCorner := 0 to 7 do
  begin
    if (lCorner and 1) = 0 then lPoint.X := ANode.Bounds.Min.X
      else lPoint.X := ANode.Bounds.Max.X;
    if (lCorner and 2) = 0 then lPoint.Y := ANode.Bounds.Min.Y
      else lPoint.Y := ANode.Bounds.Max.Y;
    if (lCorner and 4) = 0 then lPoint.Z := ANode.Bounds.Min.Z
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
      0: begin lOrigin := ARayOrigin.X; lDirection := ARayDirection.X;
        lMinimum := ABounds.Min.X; lMaximum := ABounds.Max.X; end;
      1: begin lOrigin := ARayOrigin.Y; lDirection := ARayDirection.Y;
        lMinimum := ABounds.Min.Y; lMaximum := ABounds.Max.Y; end;
    else
      begin lOrigin := ARayOrigin.Z; lDirection := ARayDirection.Z;
        lMinimum := ABounds.Min.Z; lMaximum := ABounds.Max.Z; end;
    end;
    if Abs(lDirection) <= CMatrixEpsilon then
    begin
      if (lOrigin < lMinimum) or (lOrigin > lMaximum) then Exit(False);
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
    if lNear > ADistance then ADistance := lNear;
    if lSwap < lFar then lFar := lSwap;
    if ADistance > lFar then Exit(False);
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
  if AScene = nil then Exit;
  lBestDistance := MaxSingle;
  for lIndex := 0 to High(AScene.Nodes) do
  begin
    if AScene.Nodes[lIndex].Kind <> nkMesh then Continue;
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

function InverseLinearTransform(const AVector: T3dVector;
  const AMatrix: T3dMatrix; out AResult: T3dVector): Boolean;
var
  lA, lB, lC, lD, lE, lF, lG, lH, lI, lDeterminant: Single;
begin
  lA := AMatrix[0]; lB := AMatrix[4]; lC := AMatrix[8];
  lD := AMatrix[1]; lE := AMatrix[5]; lF := AMatrix[9];
  lG := AMatrix[2]; lH := AMatrix[6]; lI := AMatrix[10];
  lDeterminant := lA * (lE * lI - lF * lH) -
    lB * (lD * lI - lF * lG) + lC * (lD * lH - lE * lG);
  Result := Abs(lDeterminant) > CMatrixEpsilon;
  if not Result then Exit;
  AResult.X := ((lE*lI-lF*lH)*AVector.X + (lC*lH-lB*lI)*AVector.Y +
    (lB*lF-lC*lE)*AVector.Z) / lDeterminant;
  AResult.Y := ((lF*lG-lD*lI)*AVector.X + (lA*lI-lC*lG)*AVector.Y +
    (lC*lD-lA*lF)*AVector.Z) / lDeterminant;
  AResult.Z := ((lD*lH-lE*lG)*AVector.X + (lB*lG-lA*lH)*AVector.Y +
    (lA*lE-lB*lD)*AVector.Z) / lDeterminant;
end;

procedure TranslateSubtreeWorld(AScene: T3dScene; AParentId: QWord;
  const ADelta: T3dVector);
var
  lIndex: Integer;
  lNode: T3dNode;
begin
  for lIndex := 0 to High(AScene.Nodes) do
  begin
    lNode := AScene.Nodes[lIndex];
    if lNode.ParentId <> AParentId then Continue;
    lNode.WorldTransform[12] := lNode.WorldTransform[12] + ADelta.X;
    lNode.WorldTransform[13] := lNode.WorldTransform[13] + ADelta.Y;
    lNode.WorldTransform[14] := lNode.WorldTransform[14] + ADelta.Z;
    TranslateSubtreeWorld(AScene, lNode.Id, ADelta);
  end;
end;

function SetNodeWorldPosition(AScene: T3dScene; ANodeId: QWord;
  const APosition: T3dVector): Boolean;
var
  lNode, lParent: T3dNode;
  lOldPosition, lDelta, lLocalDelta: T3dVector;
begin
  Result := False;
  lNode := FindSceneNode(AScene, ANodeId);
  if lNode = nil then Exit;
  lOldPosition := Vector3d(lNode.WorldTransform[12],
    lNode.WorldTransform[13], lNode.WorldTransform[14]);
  lDelta := Vector3d(APosition.X - lOldPosition.X,
    APosition.Y - lOldPosition.Y, APosition.Z - lOldPosition.Z);
  if (Abs(lDelta.X) <= CMatrixEpsilon) and
     (Abs(lDelta.Y) <= CMatrixEpsilon) and
     (Abs(lDelta.Z) <= CMatrixEpsilon) then Exit;
  lParent := FindSceneNode(AScene, lNode.ParentId);
  if lParent = nil then lLocalDelta := lDelta
  else if not InverseLinearTransform(lDelta, lParent.WorldTransform,
    lLocalDelta) then Exit;
  lNode.LocalTransform[12] := lNode.LocalTransform[12] + lLocalDelta.X;
  lNode.LocalTransform[13] := lNode.LocalTransform[13] + lLocalDelta.Y;
  lNode.LocalTransform[14] := lNode.LocalTransform[14] + lLocalDelta.Z;
  lNode.WorldTransform[12] := APosition.X;
  lNode.WorldTransform[13] := APosition.Y;
  lNode.WorldTransform[14] := APosition.Z;
  TranslateSubtreeWorld(AScene, lNode.Id, lDelta);
  AScene.RecalculateBounds;
  Result := True;
end;

function SetNodeWorldPositionComponents(AScene: T3dScene; ANodeId: QWord;
  const APosition: T3dVector; AComponents: T3dPositionComponents): Boolean;
var
  lNode: T3dNode;
  lPosition: T3dVector;
begin
  Result := False;
  lNode := FindSceneNode(AScene, ANodeId);
  if (lNode = nil) or (AComponents = []) then Exit;
  lPosition := Vector3d(lNode.WorldTransform[12], lNode.WorldTransform[13],
    lNode.WorldTransform[14]);
  if pcX in AComponents then lPosition.X := APosition.X;
  if pcY in AComponents then lPosition.Y := APosition.Y;
  if pcZ in AComponents then lPosition.Z := APosition.Z;
  Result := SetNodeWorldPosition(AScene, ANodeId, lPosition);
end;

procedure MultiplyMatrix(const ALeft,ARight:T3dMatrix; out AResult:T3dMatrix);
var
  lRow,lColumn,lIndex:Integer;
  lValue:Single;
begin
  for lColumn:=0 to 3 do
    for lRow:=0 to 3 do
    begin
      lValue:=0;
      for lIndex:=0 to 3 do
        lValue:=lValue+ALeft[lIndex*4+lRow]*ARight[lColumn*4+lIndex];
      AResult[lColumn*4+lRow]:=lValue;
    end;
end;

procedure RebuildWorldSubtree(AScene:T3dScene; ANode:T3dNode);
var
  lIndex:Integer;
  lChild:T3dNode;
  lWorld:T3dMatrix;
begin
  for lIndex:=0 to High(AScene.Nodes) do
  begin
    lChild:=AScene.Nodes[lIndex];
    if lChild.ParentId<>ANode.Id then Continue;
    MultiplyMatrix(ANode.WorldTransform,lChild.LocalTransform,lWorld);
    lChild.WorldTransform:=lWorld;
    RebuildWorldSubtree(AScene,lChild);
  end;
end;

function RotateNodeLocalAxis(AScene:T3dScene; ANodeId:QWord;
  AAxis:T3dLocalRotationAxis; ADegrees:Single):Boolean;
var
  lNode,lParent:T3dNode;
  lRotation,lLocal,lWorld:T3dMatrix;
  lRadians,lCosine,lSine:Single;
begin
  Result:=False;
  lNode:=FindSceneNode(AScene,ANodeId);
  if (lNode=nil) or (Abs(ADegrees)<=CMatrixEpsilon) then Exit;
  SetIdentity(lRotation); lRadians:=DegToRad(ADegrees);
  lCosine:=Cos(lRadians); lSine:=Sin(lRadians);
  case AAxis of
    lraX: begin lRotation[5]:=lCosine; lRotation[6]:=lSine;
      lRotation[9]:=-lSine; lRotation[10]:=lCosine; end;
    lraY: begin lRotation[0]:=lCosine; lRotation[2]:=-lSine;
      lRotation[8]:=lSine; lRotation[10]:=lCosine; end;
    lraZ: begin lRotation[0]:=lCosine; lRotation[1]:=lSine;
      lRotation[4]:=-lSine; lRotation[5]:=lCosine; end;
  end;
  MultiplyMatrix(lNode.LocalTransform,lRotation,lLocal);
  lNode.LocalTransform:=lLocal;
  lParent:=FindSceneNode(AScene,lNode.ParentId);
  if lParent=nil then lNode.WorldTransform:=lNode.LocalTransform
  else begin
    MultiplyMatrix(lParent.WorldTransform,lNode.LocalTransform,lWorld);
    lNode.WorldTransform:=lWorld;
  end;
  RebuildWorldSubtree(AScene,lNode);
  AScene.RecalculateBounds;
  Result:=True;
end;

end.
