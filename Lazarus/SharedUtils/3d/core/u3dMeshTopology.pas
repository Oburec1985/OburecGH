unit u3dMeshTopology;

{ Builds logical-vertex adjacency for scene editors. Callers retain the mesh;
  returned dynamic arrays contain indexes and own no scene objects. }
{$mode objfpc}{$H+}

interface

uses u3dCoreTypes, u3dScene;

type
  T3dTopologyRelation = (trNone,trAdjacent,trPrimary);
  T3dIndexArray = array of LongInt;
  T3dIndexLists = array of T3dIndexArray;
  T3dLogicalVertexInfo = record
    StableId: LongWord;
    Position: T3dVector;
    CornerCount: Integer;
    FaceIndexes: T3dIndexArray;
  end;
  T3dLogicalVertexInfos = array of T3dLogicalVertexInfo;
  T3dTopologyRelations = array of T3dTopologyRelation;
  T3dMeshTopology = record
    CornerToLogical: T3dIndexArray;
    LogicalToCorners,LogicalToFaces,Neighbors: T3dIndexLists;
    Vertices: T3dLogicalVertexInfos;
  end;
function BuildMeshTopology(AMesh:T3dMeshData): T3dMeshTopology;
function ClassifyLogicalVertices(const ATopology:T3dMeshTopology;
                                 ASelectedLogical:Integer): T3dTopologyRelations;
procedure ResolveHighlightCorners(const ATopology:T3dMeshTopology;
  ASelectedLogical:Integer; out APrimary,AAdjacent:array of LongWord;
  out APrimaryCount,AAdjacentCount:Integer);

implementation
procedure AppendUnique(var AValues:T3dIndexArray; AValue:LongInt);

var I: Integer;
begin
  for I:=0 to High(AValues) do
    if AValues[I]=AValue then
      Exit;
  SetLength(AValues,Length(AValues)+1);
  AValues[High(AValues)] := AValue;
end;
function TriangleCorner(const T:T3dTriangle; I:Integer): LongWord;
begin
  case I of
    0: Result := T.A;
    1: Result := T.B;
    else Result := T.C;
  end;
end;
procedure BuildFallback(M:T3dMeshData; var T:T3dMeshTopology);

var I: Integer;
begin
  SetLength(T.LogicalToCorners,Length(M.Positions));
  for I:=0 to High(M.Positions) do
    begin
      SetLength(T.LogicalToCorners[I],1);
      T.LogicalToCorners[I][0] := I;
      T.CornerToLogical[I] := I;
    end;
end;
function BuildMeshTopology(AMesh:T3dMeshData): T3dMeshTopology;

var L,P,F,C,O: Integer;
  V: LongWord;
begin
  FillChar(Result,SizeOf(Result),0);
  if AMesh=nil then
    Exit;
  SetLength(Result.CornerToLogical,Length(AMesh.Positions));
  for C:=0 to High(Result.CornerToLogical) do
    Result.CornerToLogical[C] := -1;
  if Length(AMesh.LogicalVertices)=0 then
    BuildFallback(AMesh,Result)
  else
    begin
      SetLength(Result.LogicalToCorners,Length(AMesh.LogicalVertices));
      for L:=0 to High(AMesh.LogicalVertices) do
        for P:=0 to High(AMesh.LogicalVertices[L].CornerIndices) do
          begin
            V := AMesh.LogicalVertices[L].CornerIndices[P];
            if V>=LongWord(Length(AMesh.Positions)) then
              Continue;
            AppendUnique(Result.LogicalToCorners[L],V);
            Result.CornerToLogical[V] := L;
          end;
    end;
  SetLength(Result.LogicalToFaces,Length(Result.LogicalToCorners));
  SetLength(Result.Neighbors,Length(Result.LogicalToCorners));
  for F:=0 to High(AMesh.Triangles) do
    for C:=0 to 2 do
      begin
        V := TriangleCorner(AMesh.Triangles[F],C);
        if V>=LongWord(Length(Result.CornerToLogical)) then
          Continue;
        L := Result.CornerToLogical[V];
        if L<0 then
          Continue;
        AppendUnique(Result.LogicalToFaces[L],F);
        for O:=0 to 2 do
          begin
            V := TriangleCorner(AMesh.Triangles[F],O);
            if V>=LongWord(Length(Result.CornerToLogical)) then
              Continue;
            if (Result.CornerToLogical[V]>=0) and (Result.CornerToLogical[V]<>L) then
              AppendUnique(Result.Neighbors[L],Result.CornerToLogical[V]);
          end;
      end;
  SetLength(Result.Vertices,Length(Result.LogicalToCorners));
  for L:=0 to High(Result.Vertices) do
    begin
      if L<=High(AMesh.LogicalVertices) then
        Result.Vertices[L].StableId := AMesh.LogicalVertices[L]
                                       .Id
      else Result.Vertices[L].StableId := L;
      Result.Vertices[L].CornerCount := Length(Result.LogicalToCorners[L]);
      Result.Vertices[L].FaceIndexes := Result.LogicalToFaces[L];
      if Length(Result.LogicalToCorners[L])>0 then
        Result.Vertices[L].Position := AMesh.Positions[Result.LogicalToCorners[L][0]];
    end;
end;
function ClassifyLogicalVertices(const ATopology:T3dMeshTopology;
                                 ASelectedLogical:Integer): T3dTopologyRelations;

var I,N: Integer;
begin
  SetLength(Result,Length(ATopology.Vertices));
  if (ASelectedLogical<0) or (ASelectedLogical>High(Result)) then
    Exit;
  Result[ASelectedLogical] := trPrimary;
  for I:=0 to High(ATopology.Neighbors[ASelectedLogical]) do
    begin
      N := ATopology.Neighbors[ASelectedLogical][I];
      if (N>=0) and (N<=High(Result)) then
        Result[N] := trAdjacent;
    end;
end;

procedure ResolveHighlightCorners(const ATopology:T3dMeshTopology;
  ASelectedLogical:Integer; out APrimary,AAdjacent:array of LongWord;
  out APrimaryCount,AAdjacentCount:Integer);
var
  I,J,LogicalIndex:Integer;
begin
  APrimaryCount := 0;
  AAdjacentCount := 0;
  if (ASelectedLogical<0) or
     (ASelectedLogical>High(ATopology.LogicalToCorners)) then
    Exit;
  for I:=0 to High(ATopology.LogicalToCorners[ASelectedLogical]) do
    begin
      if APrimaryCount>=Length(APrimary) then
        Break;
      APrimary[APrimaryCount] :=
        ATopology.LogicalToCorners[ASelectedLogical][I];
      Inc(APrimaryCount);
    end;
  for I:=0 to High(ATopology.Neighbors[ASelectedLogical]) do
    begin
      LogicalIndex := ATopology.Neighbors[ASelectedLogical][I];
      if (LogicalIndex<0) or
         (LogicalIndex>High(ATopology.LogicalToCorners)) then
        Continue;
      for J:=0 to High(ATopology.LogicalToCorners[LogicalIndex]) do
        begin
          if AAdjacentCount>=Length(AAdjacent) then
            Exit;
          AAdjacent[AAdjacentCount] :=
            ATopology.LogicalToCorners[LogicalIndex][J];
          Inc(AAdjacentCount);
        end;
    end;
end;
end.
