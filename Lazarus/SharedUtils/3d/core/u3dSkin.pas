unit u3dSkin;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  u3dCoreTypes, u3dScene;

type
  T3dSkinVertexIdKind = (svikLogical, svikLegacyCorner);

  T3dSkinInfluence = record
    MeshNodeId: QWord;
    LogicalVertexId: LongWord;
    VertexIdKind: T3dSkinVertexIdKind;
    HelperNodeId: QWord;
    Weight: Single;
    HelperBindWorld: T3dMatrix;
  end;

  T3dSkinInfluences = array of T3dSkinInfluence;

  T3dPreparedSkinInfluence = record
    Influence:T3dSkinInfluence;
    MeshNode,HelperNode:T3dNode;
    LogicalIndex:Integer;
    MeshBindWorld,InverseHelperBind:T3dMatrix;
    Valid:Boolean;
  end;

  T3dSkinEngine = class
  private
    fScene: T3dScene;
    fPrepared:array of T3dPreparedSkinInfluence;
    fMeshes:array of T3dMeshData;
    function LogicalIndex(AMesh: T3dMeshData; AStableId: LongWord;
      AIdKind:T3dSkinVertexIdKind): Integer;
    procedure EnsureBasePositions(AMesh: T3dMeshData);
  public
    procedure Configure(AScene: T3dScene;
      const AInfluences: array of T3dSkinInfluence);
    procedure Apply;
    procedure Reset;
  end;

function ResolveLogicalVertexIndex(AMesh:T3dMeshData;
  AStableId:LongWord; AIdKind:T3dSkinVertexIdKind):Integer;

implementation

uses
  Math, SysUtils, u3dGeometryMath;

function ResolveLogicalVertexIndex(AMesh:T3dMeshData;
  AStableId:LongWord; AIdKind:T3dSkinVertexIdKind):Integer;
var Corner:Integer;
begin
  if AMesh=nil then Exit(-1);
  if Length(AMesh.LogicalVertices)=0 then
  begin
    if AStableId<LongWord(Length(AMesh.Positions)) then Exit(Integer(AStableId));
    Exit(-1);
  end;
  if AIdKind=svikLogical then
  begin
    for Result:=0 to High(AMesh.LogicalVertices) do
      if AMesh.LogicalVertices[Result].Id=AStableId then Exit;
  end
  else if AStableId<LongWord(Length(AMesh.Positions)) then
    for Result:=0 to High(AMesh.LogicalVertices) do
      for Corner:=0 to High(AMesh.LogicalVertices[Result].CornerIndices) do
        if AMesh.LogicalVertices[Result].CornerIndices[Corner]=AStableId then Exit;
  Result:=-1;
end;

function T3dSkinEngine.LogicalIndex(AMesh: T3dMeshData;
  AStableId: LongWord; AIdKind:T3dSkinVertexIdKind): Integer;
begin
  Result:=ResolveLogicalVertexIndex(AMesh,AStableId,AIdKind);
end;

procedure T3dSkinEngine.EnsureBasePositions(AMesh: T3dMeshData);
begin
  if (AMesh <> nil) and (Length(AMesh.BasePositions) = 0) then
    AMesh.BasePositions := Copy(AMesh.Positions);
end;

procedure T3dSkinEngine.Configure(AScene: T3dScene;
  const AInfluences: array of T3dSkinInfluence);
var
  I,J:Integer;
  MeshNode,HelperNode:T3dNode;
  KnownMesh:Boolean;
begin
  fScene := AScene;
  SetLength(fPrepared,Length(AInfluences));
  SetLength(fMeshes,0);
  for I := 0 to High(AInfluences) do
  begin
    if IsNan(AInfluences[I].Weight) or IsInfinite(AInfluences[I].Weight) or
       (AInfluences[I].Weight < 0) or (AInfluences[I].Weight > 1) then
      raise ERangeError.Create('Skin influence weight must be in 0..1');
    MeshNode := nil;
    HelperNode:=nil;
    if fScene <> nil then
    begin
      MeshNode := fScene.FindNode(AInfluences[I].MeshNodeId);
      HelperNode:=fScene.FindNode(AInfluences[I].HelperNodeId);
    end;
    fPrepared[I].Influence:=AInfluences[I];
    fPrepared[I].MeshNode:=MeshNode;
    fPrepared[I].HelperNode:=HelperNode;
    if (MeshNode<>nil) and (MeshNode.Mesh<>nil) and (HelperNode<>nil) then
    begin
      EnsureBasePositions(MeshNode.Mesh);
      if Length(MeshNode.Mesh.Positions)<>Length(MeshNode.Mesh.BasePositions) then
        SetLength(MeshNode.Mesh.Positions,Length(MeshNode.Mesh.BasePositions));
      fPrepared[I].MeshBindWorld:=MeshNode.WorldTransform;
      fPrepared[I].LogicalIndex:=LogicalIndex(MeshNode.Mesh,
        AInfluences[I].LogicalVertexId,AInfluences[I].VertexIdKind);
      fPrepared[I].Valid:=(fPrepared[I].LogicalIndex>=0) and
        TryInverseMatrix(AInfluences[I].HelperBindWorld,
          fPrepared[I].InverseHelperBind);
      KnownMesh:=False;
      for J:=0 to High(fMeshes) do
        if fMeshes[J]=MeshNode.Mesh then
        begin
          KnownMesh:=True;
          Break;
        end;
      if not KnownMesh then
      begin
        SetLength(fMeshes,Length(fMeshes)+1);
        fMeshes[High(fMeshes)]:=MeshNode.Mesh;
      end;
    end;
  end;
end;

procedure T3dSkinEngine.Reset;
var
  I,J:Integer;
  Mesh:T3dMeshData;
begin
  if fScene = nil then
    Exit;
  for I:=0 to High(fMeshes) do
  begin
    Mesh:=fMeshes[I];
    for J:=0 to High(Mesh.BasePositions) do
      Mesh.Positions[J]:=Mesh.BasePositions[J];
  end;
  fScene.MarkBoundsDirty;
end;

procedure T3dSkinEngine.Apply;
var
  I,J,Logical,Corner: Integer;
  Prepared:^T3dPreparedSkinInfluence;
  MeshNode,HelperNode:T3dNode;
  InvMeshWorld,InvHelperBind,Delta,SkinMatrix: T3dMatrix;
  Base,Deformed,Contribution: T3dVector;
  TotalWeight: Single;
begin
  if fScene = nil then
    Exit;
  Reset;
  for I := 0 to High(fPrepared) do
  begin
    Prepared:=@fPrepared[I];
    if not Prepared^.Valid then
      Continue;
    MeshNode:=Prepared^.MeshNode;
    HelperNode:=Prepared^.HelperNode;
    if not TryInverseMatrix(MeshNode.WorldTransform,InvMeshWorld) then
      Continue;
    InvHelperBind:=Prepared^.InverseHelperBind;
    Logical:=Prepared^.LogicalIndex;
    if Length(MeshNode.Mesh.LogicalVertices) = 0 then
      Corner := Logical
    else if Length(MeshNode.Mesh.LogicalVertices[Logical].CornerIndices) > 0 then
      Corner := MeshNode.Mesh.LogicalVertices[Logical].CornerIndices[0]
    else
      Continue;
    if (Corner < 0) or (Corner > High(MeshNode.Mesh.BasePositions)) then
      Continue;
    Base := MeshNode.Mesh.BasePositions[Corner];
    ComposeMatrices(InvHelperBind,Prepared^.MeshBindWorld,Delta);
    ComposeMatrices(HelperNode.WorldTransform, Delta, SkinMatrix);
    ComposeMatrices(InvMeshWorld, SkinMatrix, Delta);
    Contribution := TransformPoint(Base, Delta);
    { Every Apply starts from BasePositions. Add only this influence's delta;
      weight zero and missing bindings therefore leave the point unchanged. }
    TotalWeight:=Prepared^.Influence.Weight;
    Deformed := MeshNode.Mesh.Positions[Corner];
    Deformed.X := Deformed.X + (Contribution.X - Base.X) * TotalWeight;
    Deformed.Y := Deformed.Y + (Contribution.Y - Base.Y) * TotalWeight;
    Deformed.Z := Deformed.Z + (Contribution.Z - Base.Z) * TotalWeight;
    if Length(MeshNode.Mesh.LogicalVertices) = 0 then
      MeshNode.Mesh.Positions[Corner] := Deformed
    else
      for J := 0 to High(MeshNode.Mesh.LogicalVertices[Logical].CornerIndices) do
      begin
        Corner := MeshNode.Mesh.LogicalVertices[Logical].CornerIndices[J];
        if Corner <= High(MeshNode.Mesh.Positions) then
          MeshNode.Mesh.Positions[Corner] := Deformed;
      end;
  end;
  for I:=0 to High(fMeshes) do
    RebuildMeshNormals(fMeshes[I]);
  fScene.MarkBoundsDirty;
end;

end.
