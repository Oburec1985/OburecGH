unit u3dPrimitives;



{ Creates small engine-owned scenes used when an application has no external
  scene file. The returned scene owns every node and mesh; the caller owns the
  returned scene. Coordinates are right-handed world units. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dScene, u3dCoreTypes;

type
  T3dPrimitiveKind = (pkCube, pkBeam, pkPlane, pkLine);

  T3dPrimitiveSpec = record
    NodeId: QWord;
    Kind: T3dPrimitiveKind;
    Name: string;
    Position: T3dVector;
    Iterations: Integer;
    CrossSectionIterations: Integer;
  end;

function CreateDefaultCubeScene: T3dScene;
function CreatePrimitiveNode(const ASpec: T3dPrimitiveSpec): T3dNode;
procedure RebuildPrimitiveNodeGeometry(ANode: T3dNode;
  const ASpec: T3dPrimitiveSpec);
function PrimitiveIterationMinimum(AKind: T3dPrimitiveKind): Integer;
function NormalizePrimitiveSpec(var ASpec: T3dPrimitiveSpec): Boolean;

implementation

uses
  SysUtils, Math, u3dGeometryMath;

const
  CMaxPrimitiveIterations = 128;

function PrimitiveIterationMinimum(AKind: T3dPrimitiveKind): Integer;
begin
  if AKind = pkLine then
    Result := 2
  else
    Result := 1;
end;

function NormalizePrimitiveSpec(var ASpec: T3dPrimitiveSpec): Boolean;
begin
  Result := ASpec.NodeId <> 0;
  if not Result then
    Exit;
  if ASpec.Iterations < PrimitiveIterationMinimum(ASpec.Kind) then
    ASpec.Iterations := PrimitiveIterationMinimum(ASpec.Kind);
  if ASpec.Iterations > CMaxPrimitiveIterations then
    ASpec.Iterations := CMaxPrimitiveIterations;
  if ASpec.CrossSectionIterations < 1 then
    ASpec.CrossSectionIterations := 1;
  if ASpec.CrossSectionIterations > CMaxPrimitiveIterations then
    ASpec.CrossSectionIterations := CMaxPrimitiveIterations;
end;

procedure AddVertex(AMesh: T3dMeshData; const APosition: T3dVector;
  out AIndex: LongWord);
begin
  AIndex := Length(AMesh.Positions);
  SetLength(AMesh.Positions, Length(AMesh.Positions) + 1);
  AMesh.Positions[AIndex] := APosition;
end;

procedure AddTriangle(AMesh: T3dMeshData; A, B, C: LongWord);
var
  I: Integer;
begin
  I := Length(AMesh.Triangles);
  SetLength(AMesh.Triangles, I + 1);
  AMesh.Triangles[I].A := A;
  AMesh.Triangles[I].B := B;
  AMesh.Triangles[I].C := C;
end;

procedure AddWireEdge(AMesh:T3dMeshData; A,B:LongWord);
var
  I:Integer;
begin
  { Duplicate shared grid edges are cheap to draw; appending keeps high
    subdivision geometry construction linear instead of searching the cache. }
  I:=Length(AMesh.WireEdges);
  SetLength(AMesh.WireEdges,I+1);
  AMesh.WireEdges[I].A:=A;
  AMesh.WireEdges[I].B:=B;
end;

procedure BuildLogicalVerticesByPosition(AMesh:T3dMeshData);
var
  Slots:array of Integer;
  Size,Mask,I,Slot,Logical,CornerCount:Integer;
  XBits,YBits,ZBits:LongWord;
  P:T3dVector;

  function Bits(AValue:Single):LongWord;
  begin
    Move(AValue,Result,SizeOf(Result));
  end;

  function Hash(AX,AY,AZ:LongWord):LongWord;
  begin
    Result:=(AX*73856093) xor (AY*19349663) xor (AZ*83492791);
  end;

begin
  if AMesh=nil then
    Exit;
  Size:=8;
  while Size<Length(AMesh.Positions)*2 do
    Size:=Size shl 1;
  SetLength(Slots,Size);
  for I:=0 to High(Slots) do
    Slots[I]:=-1;
  Mask:=Size-1;
  SetLength(AMesh.LogicalVertices,0);
  for I:=0 to High(AMesh.Positions) do
  begin
    P:=AMesh.Positions[I];
    XBits:=Bits(P.X); YBits:=Bits(P.Y); ZBits:=Bits(P.Z);
    Slot:=Integer(Hash(XBits,YBits,ZBits) and LongWord(Mask));
    while Slots[Slot]>=0 do
    begin
      Logical:=Slots[Slot];
      CornerCount:=Length(AMesh.LogicalVertices[Logical].CornerIndices);
      if (CornerCount>0) and
         (AMesh.Positions[AMesh.LogicalVertices[Logical].CornerIndices[0]].X=P.X) and
         (AMesh.Positions[AMesh.LogicalVertices[Logical].CornerIndices[0]].Y=P.Y) and
         (AMesh.Positions[AMesh.LogicalVertices[Logical].CornerIndices[0]].Z=P.Z) then
        Break;
      Slot:=(Slot+1) and Mask;
    end;
    if Slots[Slot]<0 then
    begin
      Logical:=Length(AMesh.LogicalVertices);
      SetLength(AMesh.LogicalVertices,Logical+1);
      AMesh.LogicalVertices[Logical].Id:=Logical;
      Slots[Slot]:=Logical;
    end
    else
      Logical:=Slots[Slot];
    CornerCount:=Length(AMesh.LogicalVertices[Logical].CornerIndices);
    SetLength(AMesh.LogicalVertices[Logical].CornerIndices,CornerCount+1);
    AMesh.LogicalVertices[Logical].CornerIndices[CornerCount]:=I;
  end;
end;

procedure AddGridFace(AMesh: T3dMeshData; const AOrigin, AU, AV: T3dVector;
  AUDivisions, AVDivisions: Integer; AReverse: Boolean);
var
  X, Y: Integer;
  Base, A, B, C, D: LongWord;
  P: T3dVector;
begin
  Base := Length(AMesh.Positions);
  for Y := 0 to AVDivisions do
    for X := 0 to AUDivisions do
    begin
      P := Vector3d(AOrigin.X + AU.X * X / AUDivisions + AV.X * Y / AVDivisions,
        AOrigin.Y + AU.Y * X / AUDivisions + AV.Y * Y / AVDivisions,
        AOrigin.Z + AU.Z * X / AUDivisions + AV.Z * Y / AVDivisions);
      AddVertex(AMesh, P, A);
    end;
  for Y := 0 to AVDivisions - 1 do
    for X := 0 to AUDivisions - 1 do
    begin
      A := Base + LongWord(Y * (AUDivisions + 1) + X);
      B := A + 1;
      D := A + LongWord(AUDivisions + 1);
      C := D + 1;
      if AReverse then
      begin
        AddTriangle(AMesh, A, C, B);
        AddTriangle(AMesh, A, D, C);
      end
      else
      begin
        AddTriangle(AMesh, A, B, C);
        AddTriangle(AMesh, A, C, D);
      end;
      AddWireEdge(AMesh,A,B);
      AddWireEdge(AMesh,B,C);
      AddWireEdge(AMesh,C,D);
      AddWireEdge(AMesh,D,A);
    end;
end;

procedure BuildBox(AMesh: T3dMeshData; const AHalfSize: T3dVector;
  ADivisions: Integer);
begin
  AddGridFace(AMesh, Vector3d(-AHalfSize.X, -AHalfSize.Y, -AHalfSize.Z),
    Vector3d(2 * AHalfSize.X, 0, 0), Vector3d(0, 2 * AHalfSize.Y, 0),
    ADivisions, ADivisions, True);
  AddGridFace(AMesh, Vector3d(-AHalfSize.X, -AHalfSize.Y, AHalfSize.Z),
    Vector3d(0, 2 * AHalfSize.Y, 0), Vector3d(2 * AHalfSize.X, 0, 0),
    ADivisions, ADivisions, True);
  AddGridFace(AMesh, Vector3d(-AHalfSize.X, -AHalfSize.Y, -AHalfSize.Z),
    Vector3d(0, 0, 2 * AHalfSize.Z), Vector3d(2 * AHalfSize.X, 0, 0),
    ADivisions, ADivisions, True);
  AddGridFace(AMesh, Vector3d(-AHalfSize.X, AHalfSize.Y, -AHalfSize.Z),
    Vector3d(2 * AHalfSize.X, 0, 0), Vector3d(0, 0, 2 * AHalfSize.Z),
    ADivisions, ADivisions, True);
  AddGridFace(AMesh, Vector3d(-AHalfSize.X, -AHalfSize.Y, -AHalfSize.Z),
    Vector3d(0, 2 * AHalfSize.Y, 0), Vector3d(0, 0, 2 * AHalfSize.Z),
    ADivisions, ADivisions, True);
  AddGridFace(AMesh, Vector3d(AHalfSize.X, -AHalfSize.Y, -AHalfSize.Z),
    Vector3d(0, 0, 2 * AHalfSize.Z), Vector3d(0, 2 * AHalfSize.Y, 0),
    ADivisions, ADivisions, True);
end;

procedure BuildBeam(AMesh: T3dMeshData; ALongitudinalDivisions,
  ACrossSectionDivisions: Integer);
const
  HX = 1.5;
  HY = 0.25;
  HZ = 0.25;
begin
  { One transverse value controls both dimensions of the cross section. }
  AddGridFace(AMesh, Vector3d(-HX,-HY,-HZ), Vector3d(2*HX,0,0),
    Vector3d(0,2*HY,0), ALongitudinalDivisions,
    ACrossSectionDivisions, True);
  AddGridFace(AMesh, Vector3d(-HX,-HY,HZ), Vector3d(0,2*HY,0),
    Vector3d(2*HX,0,0), ACrossSectionDivisions,
    ALongitudinalDivisions, True);
  AddGridFace(AMesh, Vector3d(-HX,-HY,-HZ), Vector3d(0,0,2*HZ),
    Vector3d(2*HX,0,0), ACrossSectionDivisions,
    ALongitudinalDivisions, True);
  AddGridFace(AMesh, Vector3d(-HX,HY,-HZ), Vector3d(2*HX,0,0),
    Vector3d(0,0,2*HZ), ALongitudinalDivisions,
    ACrossSectionDivisions, True);
  AddGridFace(AMesh, Vector3d(-HX,-HY,-HZ), Vector3d(0,2*HY,0),
    Vector3d(0,0,2*HZ), ACrossSectionDivisions,
    ACrossSectionDivisions, True);
  AddGridFace(AMesh, Vector3d(HX,-HY,-HZ), Vector3d(0,0,2*HZ),
    Vector3d(0,2*HY,0), ACrossSectionDivisions,
    ACrossSectionDivisions, True);
end;

function CreatePrimitiveNode(const ASpec: T3dPrimitiveSpec): T3dNode;
var
  I, Count: Integer;
begin
  Count := ASpec.Iterations;
  if (Count < PrimitiveIterationMinimum(ASpec.Kind)) or
     (Count > CMaxPrimitiveIterations) then
    raise ERangeError.CreateFmt('Primitive iterations must be in %d..%d',
      [PrimitiveIterationMinimum(ASpec.Kind), CMaxPrimitiveIterations]);
  Result := T3dNode.Create;
  try
    Result.Id := ASpec.NodeId;
    Result.Name := ASpec.Name;
    SetIdentity(Result.LocalTransform);
    Result.LocalTransform[12] := ASpec.Position.X;
    Result.LocalTransform[13] := ASpec.Position.Y;
    Result.LocalTransform[14] := ASpec.Position.Z;
    Result.WorldTransform := Result.LocalTransform;
    if ASpec.Kind = pkLine then
    begin
      Result.Kind := nkShape;
      SetLength(Result.ShapeLines, 1);
      SetLength(Result.ShapeLines[0].Points, Count);
      for I := 0 to Count - 1 do
        Result.ShapeLines[0].Points[I] := Vector3d(-1 + 2 * I / (Count - 1), 0, 0);
      Result.Bounds.Valid := True;
      Result.Bounds.Min := Vector3d(-1, 0, 0);
      Result.Bounds.Max := Vector3d(1, 0, 0);
    end
    else
    begin
      Result.Kind := nkMesh;
      Result.Mesh := T3dMeshData.Create;
      case ASpec.Kind of
        pkCube:
          begin
            BuildBox(Result.Mesh, Vector3d(1, 1, 1), Count);
            Result.Bounds.Min := Vector3d(-1, -1, -1);
            Result.Bounds.Max := Vector3d(1, 1, 1);
          end;
        pkBeam:
          begin
            BuildBeam(Result.Mesh,Count,Max(1,ASpec.CrossSectionIterations));
            Result.Bounds.Min := Vector3d(-1.5, -0.25, -0.25);
            Result.Bounds.Max := Vector3d(1.5, 0.25, 0.25);
          end;
        pkPlane:
          begin
            AddGridFace(Result.Mesh, Vector3d(-1, -1, 0), Vector3d(2, 0, 0),
              Vector3d(0, 2, 0), Count, Count, False);
            Result.Bounds.Min := Vector3d(-1, -1, 0);
            Result.Bounds.Max := Vector3d(1, 1, 0);
          end;
      end;
      Result.Bounds.Valid := True;
      Result.Mesh.Color.R := 190;
      Result.Mesh.Color.G := 205;
      Result.Mesh.Color.B := 220;
      RebuildMeshNormals(Result.Mesh);
      BuildLogicalVerticesByPosition(Result.Mesh);
      Result.Mesh.BasePositions := Copy(Result.Mesh.Positions);
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure RebuildPrimitiveNodeGeometry(ANode: T3dNode;
  const ASpec: T3dPrimitiveSpec);
var
  Replacement: T3dNode;
begin
  if ANode = nil then
    Exit;
  Replacement := CreatePrimitiveNode(ASpec);
  try
    ANode.Mesh.Free;
    ANode.Mesh := Replacement.Mesh;
    Replacement.Mesh := nil;
    ANode.ShapeLines := Replacement.ShapeLines;
    SetLength(Replacement.ShapeLines, 0);
    ANode.Kind := Replacement.Kind;
    ANode.Bounds := Replacement.Bounds;
  finally
    Replacement.Free;
  end;
end;

function CreateDefaultCubeScene: T3dScene;
var
  Spec:T3dPrimitiveSpec;
  Node: T3dNode;
begin
  FillChar(Spec,SizeOf(Spec),0);
  Spec.NodeId:=1;
  Spec.Kind:=pkCube;
  Spec.Name:='Default cube';
  Spec.Position:=Vector3d(0,0,0);
  Spec.Iterations:=1;
  Spec.CrossSectionIterations:=1;
  Node := nil;
  Result := T3dScene.Create;
  try
    Node:=CreatePrimitiveNode(Spec);
    Result.AddNode(Node);
    Node := nil;
    Result.ResolveLinks;
  except
    Node.Free;
    Result.Free;
    raise;
  end;
end;

end.
