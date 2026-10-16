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
  T3dPrimitiveKind = (pkCube, pkBeam, pkPlane, pkLine, pkPointCloud);
  T3dPointCloudShape = (pcsBox, pcsSphere, pcsCylinder);

  T3dPrimitiveSpec = record
    NodeId: QWord;
    Kind: T3dPrimitiveKind;
    Name: string;
    Position: T3dVector;
    Iterations: Integer;
    CrossSectionIterations: Integer;
    SizeX, SizeY, SizeZ: Single;
    IterationsX, IterationsY, IterationsZ: Integer;
    PointCloudShape: T3dPointCloudShape;
    DrawPointNumbers: Boolean;
    Color: LongInt;
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
  if ASpec.SizeX <= 0 then
    if ASpec.Kind=pkBeam then ASpec.SizeX:=3 else ASpec.SizeX:=2;
  if ASpec.SizeY <= 0 then
    if ASpec.Kind=pkBeam then ASpec.SizeY:=0.5 else ASpec.SizeY:=2;
  if ASpec.SizeZ <= 0 then
    if ASpec.Kind=pkBeam then ASpec.SizeZ:=0.5 else ASpec.SizeZ:=2;
  if ASpec.IterationsX < 1 then ASpec.IterationsX := ASpec.Iterations;
  if ASpec.IterationsY < 1 then ASpec.IterationsY := ASpec.Iterations;
  if ASpec.IterationsZ < 1 then ASpec.IterationsZ := ASpec.Iterations;
  ASpec.IterationsX := EnsureRange(ASpec.IterationsX, 1, CMaxPrimitiveIterations);
  ASpec.IterationsY := EnsureRange(ASpec.IterationsY, 1, CMaxPrimitiveIterations);
  ASpec.IterationsZ := EnsureRange(ASpec.IterationsZ, 1, CMaxPrimitiveIterations);
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

procedure BuildPointCloud(AMesh:T3dMeshData; const ASpec:T3dPrimitiveSpec);
var
  X,Y,Z,R,A,Index,PointCount:Integer;
  PX,PY,PZ,Radius,Angle:Single;

  procedure StorePoint(const APoint:T3dVector);
  begin
    AMesh.Positions[Index]:=APoint;
    Inc(Index);
  end;

begin
  case ASpec.PointCloudShape of
    pcsBox:
      PointCount:=(ASpec.IterationsX+1)*(ASpec.IterationsY+1)*
        (ASpec.IterationsZ+1);
    pcsSphere:
      PointCount:=1+ASpec.IterationsX*(ASpec.IterationsZ+1)*ASpec.IterationsY;
    pcsCylinder:
      PointCount:=(ASpec.IterationsZ+1)*(1+ASpec.IterationsX*ASpec.IterationsY);
  end;
  SetLength(AMesh.Positions,PointCount);
  Index:=0;
  case ASpec.PointCloudShape of
    pcsBox:
      for Z:=0 to ASpec.IterationsZ do
        for Y:=0 to ASpec.IterationsY do
          for X:=0 to ASpec.IterationsX do
            StorePoint(Vector3d(
              -ASpec.SizeX/2+ASpec.SizeX*X/ASpec.IterationsX,
              -ASpec.SizeY/2+ASpec.SizeY*Y/ASpec.IterationsY,
              -ASpec.SizeZ/2+ASpec.SizeZ*Z/ASpec.IterationsZ));
    pcsSphere:
      begin
        StorePoint(Vector3d(0,0,0));
        for R:=1 to ASpec.IterationsX do
        begin
          Radius:=R/ASpec.IterationsX;
          for Z:=0 to ASpec.IterationsZ do
          begin
            PZ:=Cos(Pi*Z/ASpec.IterationsZ);
            for A:=0 to ASpec.IterationsY-1 do
            begin
              Angle:=2*Pi*A/ASpec.IterationsY;
              PX:=Sin(Pi*Z/ASpec.IterationsZ)*Cos(Angle);
              PY:=Sin(Pi*Z/ASpec.IterationsZ)*Sin(Angle);
              StorePoint(Vector3d(PX*Radius*ASpec.SizeX/2,
                PY*Radius*ASpec.SizeY/2,PZ*Radius*ASpec.SizeZ/2));
            end;
          end;
        end;
      end;
    pcsCylinder:
      for Z:=0 to ASpec.IterationsZ do
      begin
        PZ:=-ASpec.SizeZ/2+ASpec.SizeZ*Z/ASpec.IterationsZ;
        for R:=0 to ASpec.IterationsX do
        begin
          Radius:=R/ASpec.IterationsX;
          if R=0 then
            StorePoint(Vector3d(0,0,PZ))
          else
            for A:=0 to ASpec.IterationsY-1 do
            begin
              Angle:=2*Pi*A/ASpec.IterationsY;
              StorePoint(Vector3d(Cos(Angle)*Radius*ASpec.SizeX/2,
                Sin(Angle)*Radius*ASpec.SizeY/2,PZ));
            end;
        end;
      end;
  end;
end;

procedure ScaleMesh(AMesh:T3dMeshData; const AScale:T3dVector);
var I:Integer;
begin
  for I:=0 to High(AMesh.Positions) do
  begin
    AMesh.Positions[I].X:=AMesh.Positions[I].X*AScale.X;
    AMesh.Positions[I].Y:=AMesh.Positions[I].Y*AScale.Y;
    AMesh.Positions[I].Z:=AMesh.Positions[I].Z*AScale.Z;
  end;
end;

function CreatePrimitiveNode(const ASpec: T3dPrimitiveSpec): T3dNode;
var
  I, Count: Integer;
  Spec:T3dPrimitiveSpec;
begin
  Count := ASpec.Iterations;
  if (Count < PrimitiveIterationMinimum(ASpec.Kind)) or
     (Count > CMaxPrimitiveIterations) then
    raise ERangeError.CreateFmt('Primitive iterations must be in %d..%d',
      [PrimitiveIterationMinimum(ASpec.Kind), CMaxPrimitiveIterations]);
  Spec:=ASpec;
  NormalizePrimitiveSpec(Spec);
  Result := T3dNode.Create;
  try
    Result.Id := Spec.NodeId;
    Result.Name := Spec.Name;
    SetIdentity(Result.LocalTransform);
    Result.LocalTransform[12] := Spec.Position.X;
    Result.LocalTransform[13] := Spec.Position.Y;
    Result.LocalTransform[14] := Spec.Position.Z;
    Result.WorldTransform := Result.LocalTransform;
    if Spec.Kind = pkLine then
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
      case Spec.Kind of
        pkCube:
          begin
            BuildBox(Result.Mesh, Vector3d(1, 1, 1), Count);
            ScaleMesh(Result.Mesh,Vector3d(Spec.SizeX/2,Spec.SizeY/2,Spec.SizeZ/2));
            Result.Bounds.Min:=Vector3d(-Spec.SizeX/2,-Spec.SizeY/2,-Spec.SizeZ/2);
            Result.Bounds.Max:=Vector3d(Spec.SizeX/2,Spec.SizeY/2,Spec.SizeZ/2);
          end;
        pkBeam:
          begin
            BuildBeam(Result.Mesh,Count,Max(1,Spec.CrossSectionIterations));
            ScaleMesh(Result.Mesh,Vector3d(Spec.SizeX/3,Spec.SizeY/0.5,Spec.SizeZ/0.5));
            Result.Bounds.Min:=Vector3d(-Spec.SizeX/2,-Spec.SizeY/2,-Spec.SizeZ/2);
            Result.Bounds.Max:=Vector3d(Spec.SizeX/2,Spec.SizeY/2,Spec.SizeZ/2);
          end;
        pkPlane:
          begin
            AddGridFace(Result.Mesh, Vector3d(-1, -1, 0), Vector3d(2, 0, 0),
              Vector3d(0, 2, 0), Count, Count, False);
            ScaleMesh(Result.Mesh,Vector3d(Spec.SizeX/2,Spec.SizeY/2,1));
            Result.Bounds.Min:=Vector3d(-Spec.SizeX/2,-Spec.SizeY/2,0);
            Result.Bounds.Max:=Vector3d(Spec.SizeX/2,Spec.SizeY/2,0);
          end;
        pkPointCloud:
          begin
            BuildPointCloud(Result.Mesh,Spec);
            Result.Bounds.Min:=Vector3d(-Spec.SizeX/2,-Spec.SizeY/2,-Spec.SizeZ/2);
            Result.Bounds.Max:=Vector3d(Spec.SizeX/2,Spec.SizeY/2,Spec.SizeZ/2);
            Result.HasRenderOverride:=True;
            Result.DrawFillOverride:=False;
            Result.DrawWireframeOverride:=True;
            Result.DrawPointsOverride:=True;
            Result.DrawNormalsOverride:=False;
            Result.DrawBoundsOverride:=True;
          end;
      end;
      Result.Bounds.Valid := True;
      Result.Mesh.Color.R := Byte(Spec.Color and $FF);
      Result.Mesh.Color.G := Byte((Spec.Color shr 8) and $FF);
      Result.Mesh.Color.B := Byte((Spec.Color shr 16) and $FF);
      if Spec.Kind<>pkPointCloud then
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
  Spec.SizeX:=2; Spec.SizeY:=2; Spec.SizeZ:=2;
  Spec.IterationsX:=1; Spec.IterationsY:=1; Spec.IterationsZ:=1;
  Spec.PointCloudShape:=pcsBox;
  Spec.Color:=$00DCCDBE;
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
