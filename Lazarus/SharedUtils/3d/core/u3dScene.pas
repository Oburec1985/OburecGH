unit u3dScene;

{ Owns nodes, meshes, animations, indexed node lookup, and cached world bounds.
  Loaders populate the graph; transforms and renderers consume it. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, u3dCoreTypes;

type
  T3dMatrix = array[0..15] of Single;
  T3dVector2 = record
    U, V: Single;
  end;
  T3dTriangle = record
    A, B, C: LongWord;
  end;
  T3dEdge = record
    A,B:LongWord;
  end;
  T3dLogicalVertex = record
    Id: LongWord;
    CornerIndices: array of LongWord;
  end;
  T3dColor = record
    R, G, B: Byte;
  end;
  T3dBounds = record
    Valid: Boolean;
    Min, Max: T3dVector;
  end;

  T3dNodeKind = (nkMesh, nkCamera, nkDummy, nkShape, nkLight, nkUnknown);
  T3dShapePrimitive = (spLineStrip, spLineLoop);

  T3dShapeLine = record
    Closed: Boolean;
    Points: array of T3dVector;
  end;

  T3dMeshData = class
  public
      { Immutable bind-pose geometry. Skinning always recomputes Positions
        from this buffer, so repeated updates cannot accumulate drift. }
      BasePositions: array of T3dVector;
      Positions: array of T3dVector;
      Normals: array of T3dVector;
      { Optional per-render-corner colors. Logical modifiers fan their result
        out to every flat-shading corner before rendering. }
      VertexColors:array of T3dColor;
      TexCoords: array of T3dVector2;
      Triangles: array of T3dTriangle;
      { Optional semantic polygon/grid edges. Procedural builders populate
        these without the triangulation diagonals used only for raster fill. }
      WireEdges:array of T3dEdge;
      LogicalVertices: array of T3dLogicalVertex;
      SourceNodeName: string;
      SourceNodeId: QWord;
      Color: T3dColor;
  end;

  T3dNode = class
  public
      Id: QWord;
      Name: string;
      ParentName: string;
      ParentId: QWord;
      Kind: T3dNodeKind;
      ObjectType: Byte;
      WorldTransform: T3dMatrix;
      LocalTransform: T3dMatrix;
      Bounds: T3dBounds;
      Mesh: T3dMeshData;
      HasColorOverride: Boolean;
      ColorOverride: T3dColor;
      HasRenderOverride: Boolean;
      DrawFillOverride: Boolean;
      DrawWireframeOverride: Boolean;
      DrawPointsOverride: Boolean;
      DrawNormalsOverride: Boolean;
      ShapeLines: array of T3dShapeLine;
      destructor Destroy;
      override;
  end;

  T3dAnimationKey = record
    Frame: LongWord;
    Transform: T3dMatrix;
  end;

  T3dAnimationTrack = class
  public
      NodeName: string;
      NodeId: QWord;
      Keys: array of T3dAnimationKey;
  end;

  T3dAnimation = class
  public
      FramesPerSecond: LongWord;
      FrameCount: LongWord;
      TicksPerFrame: LongWord;
      Tracks: array of T3dAnimationTrack;
      destructor Destroy;
      override;
  end;

  T3dScene = class
  private
      fBounds: T3dBounds;
      fBoundsDirty: Boolean;
      fIndexDirty: Boolean;
      fIdKeys: array of QWord;
      fIdValues: array of Integer;
      fVisitState: array of Byte;
      fLookupProbes: QWord;
      fNextNodeId: QWord;
      procedure EnsureIndex;
      function HashSlot(AId:QWord): Integer;
      function GetBounds: T3dBounds;
      function ValidateNode(AIndex:Integer): Boolean;
      function ResolveWorld(AIndex:Integer): Boolean;
  public
      Nodes: array of T3dNode;
      Animations: array of T3dAnimation;
      constructor Create;
      destructor Destroy;
      override;
      procedure AddNode(ANode: T3dNode);
      function RemoveNode(ANodeId: QWord): Boolean;
      function NextNodeId: QWord;
      procedure AddAnimation(AAnimation: T3dAnimation);
      function FindNode(const AName: string): T3dNode;
      function FindNode(AId: QWord): T3dNode;
      function FindNodeIndex(AId:QWord): Integer;
      procedure ResolveLinks;
      procedure RecalculateBounds;
      procedure MarkBoundsDirty;
      function ValidateHierarchy: Boolean;
      function RebuildWorldTransforms(out AUpdated:Integer): Boolean;
      procedure ResetLookupStats;
      property LookupProbes: QWord read fLookupProbes;
      property BoundsDirty: Boolean read fBoundsDirty;
      property Bounds: T3dBounds read GetBounds;
  end;

procedure SetIdentity(out AMatrix: T3dMatrix);
procedure IncludePoint(var ABounds: T3dBounds; const APoint: T3dVector);
function ShapePrimitive(AClosed: Boolean): T3dShapePrimitive;

implementation

constructor T3dScene.Create;
begin
  inherited Create;
  fIndexDirty := True;
  fBoundsDirty := True;
  fNextNodeId := 1;
end;

function ShapePrimitive(AClosed: Boolean): T3dShapePrimitive;
begin
  if AClosed then
    Result := spLineLoop
  else
    Result := spLineStrip;
end;

procedure SetIdentity(out AMatrix: T3dMatrix);

var I: Integer;
begin
  for I := 0 to High(AMatrix) do
    AMatrix[I] := 0;
  AMatrix[0] := 1;
  AMatrix[5] := 1;
  AMatrix[10] := 1;
  AMatrix[15] := 1;
end;

procedure IncludePoint(var ABounds: T3dBounds; const APoint: T3dVector);
begin
  if not ABounds.Valid then
    begin
      ABounds.Valid := True;
      ABounds.Min := APoint;
      ABounds.Max := APoint;
      Exit;
    end;
  if APoint.X < ABounds.Min.X then
    ABounds.Min.X := APoint.X;
  if APoint.Y < ABounds.Min.Y then
    ABounds.Min.Y := APoint.Y;
  if APoint.Z < ABounds.Min.Z then
    ABounds.Min.Z := APoint.Z;
  if APoint.X > ABounds.Max.X then
    ABounds.Max.X := APoint.X;
  if APoint.Y > ABounds.Max.Y then
    ABounds.Max.Y := APoint.Y;
  if APoint.Z > ABounds.Max.Z then
    ABounds.Max.Z := APoint.Z;
end;

destructor T3dNode.Destroy;
begin
  Mesh.Free;
  inherited Destroy;
end;

destructor T3dAnimation.Destroy;

var I: Integer;
begin
  for I := 0 to High(Tracks) do
    Tracks[I].Free;
  inherited Destroy;
end;

destructor T3dScene.Destroy;

var I: Integer;
begin
  for I := 0 to High(Nodes) do
    Nodes[I].Free;
  for I := 0 to High(Animations) do
    Animations[I].Free;
  inherited Destroy;
end;

procedure T3dScene.AddNode(ANode: T3dNode);
begin
  SetLength(Nodes, Length(Nodes) + 1);
  Nodes[High(Nodes)] := ANode;
  fIndexDirty := True;
  fBoundsDirty := True;
  if (ANode <> nil) and (ANode.Id >= fNextNodeId) and
     (ANode.Id < High(QWord)) then
    fNextNodeId := ANode.Id + 1;
end;

function T3dScene.NextNodeId: QWord;
begin
  if fNextNodeId = 0 then
    fNextNodeId := 1;
  Result := fNextNodeId;
  Inc(fNextNodeId);
  if Result = 0 then
    raise Exception.Create('No free 3D scene node ID');
end;

function T3dScene.RemoveNode(ANodeId: QWord): Boolean;
var
  I, J, WriteIndex: Integer;
  RemovedIds: array of QWord;

  function IsRemoved(AId: QWord): Boolean;
  var
    K: Integer;
  begin
    for K := 0 to High(RemovedIds) do
      if RemovedIds[K] = AId then
        Exit(True);
    Result := False;
  end;

  procedure AddRemoved(AId: QWord);
  begin
    SetLength(RemovedIds, Length(RemovedIds) + 1);
    RemovedIds[High(RemovedIds)] := AId;
  end;

begin
  Result := FindNode(ANodeId) <> nil;
  if not Result then
    Exit;
  AddRemoved(ANodeId);
  repeat
    J := Length(RemovedIds);
    for I := 0 to High(Nodes) do
      if (not IsRemoved(Nodes[I].Id)) and IsRemoved(Nodes[I].ParentId) then
        AddRemoved(Nodes[I].Id);
  until J = Length(RemovedIds);

  WriteIndex := 0;
  for I := 0 to High(Nodes) do
    if IsRemoved(Nodes[I].Id) then
      Nodes[I].Free
    else
    begin
      if (Nodes[I].Mesh <> nil) and
         IsRemoved(Nodes[I].Mesh.SourceNodeId) then
        Nodes[I].Mesh.SourceNodeId := 0;
      Nodes[WriteIndex] := Nodes[I];
      Inc(WriteIndex);
    end;
  SetLength(Nodes, WriteIndex);
  for I := 0 to High(Animations) do
    for J := 0 to High(Animations[I].Tracks) do
      if IsRemoved(Animations[I].Tracks[J].NodeId) then
        Animations[I].Tracks[J].NodeId := 0;
  fIndexDirty := True;
  fBoundsDirty := True;
end;

function T3dScene.HashSlot(AId:QWord): Integer;
begin
  Result := Integer(((AId xor (AId shr 33)) * QWord($9E3779B97F4A7C15))
    and QWord(High(fIdKeys)));
end;

procedure T3dScene.EnsureIndex;

var Size,I,Slot: Integer;
begin
  if not fIndexDirty then
    Exit;
  Size := 8;
  while Size<Length(Nodes)*2 do
    Size := Size shl 1;
  SetLength(fIdKeys,Size);
  SetLength(fIdValues,Size);
  SetLength(fVisitState,Length(Nodes));
  FillChar(fIdKeys[0],SizeOf(QWord)*Size,0);
  FillChar(fIdValues[0],SizeOf(Integer)*Size,$FF);
  for I:=0 to High(Nodes) do
    if Nodes[I].Id<>0 then
      begin
        Slot := HashSlot(Nodes[I].Id);
        while fIdKeys[Slot]<>0 do
          Slot := (Slot+1) and High(fIdKeys);
        fIdKeys[Slot] := Nodes[I].Id;
        fIdValues[Slot] := I;
      end;
  fIndexDirty := False;
end;

procedure T3dScene.AddAnimation(AAnimation: T3dAnimation);
begin
  SetLength(Animations, Length(Animations) + 1);
  Animations[High(Animations)] := AAnimation;
end;

function T3dScene.FindNode(const AName: string): T3dNode;

var I: Integer;
begin
  for I := 0 to High(Nodes) do
    if Nodes[I].Name = AName then
      Exit(Nodes[I]);
  Result := nil;
end;

function T3dScene.FindNode(AId: QWord): T3dNode;

var Index: Integer;
begin
  Index := FindNodeIndex(AId);
  if Index<0 then
    Result := nil
  else Result := Nodes[Index];
end;

function T3dScene.FindNodeIndex(AId:QWord): Integer;

var Slot,Start: Integer;
begin
  Result := -1;
  if AId=0 then
    Exit;
  EnsureIndex;
  Slot := HashSlot(AId);
  Start := Slot;
  repeat
    Inc(fLookupProbes);
    if fIdKeys[Slot]=0 then
      Exit;
    if fIdKeys[Slot]=AId then
      Exit(fIdValues[Slot]);
    Slot := (Slot+1) and High(fIdKeys);
  until Slot=Start;
end;

procedure T3dScene.ResetLookupStats;
begin
  fLookupProbes := 0;
end;

function T3dScene.ResolveWorld(AIndex:Integer): Boolean;

var ParentIndex,Row,Col,K: Integer;
  Parent,Local,World: T3dMatrix;
  Value: Single;
begin
  if fVisitState[AIndex]=2 then
    Exit(True);
  if fVisitState[AIndex]=1 then
    Exit(False);
  fVisitState[AIndex] := 1;
  ParentIndex := FindNodeIndex(Nodes[AIndex].ParentId);
  if ParentIndex<0 then
    World := Nodes[AIndex].LocalTransform
  else
    begin
      if not ResolveWorld(ParentIndex) then
        Exit(False);
      Parent := Nodes[ParentIndex].WorldTransform;
      Local := Nodes[AIndex].LocalTransform;
      for Col:=0 to 3 do
        for Row:=0 to 3 do
          begin
            Value := 0;
            for K:=0 to 3 do
              Value := Value+Parent[K*4+Row]*Local[Col*4+K];
            World[Col*4+Row] := Value;
          end;
    end;
  Nodes[AIndex].WorldTransform := World;
  fVisitState[AIndex] := 2;
  Result := True;
end;

function T3dScene.ValidateNode(AIndex:Integer): Boolean;

var ParentIndex: Integer;
begin
  if fVisitState[AIndex]=2 then
    Exit(True);
  if fVisitState[AIndex]=1 then
    Exit(False);
  fVisitState[AIndex] := 1;
  ParentIndex := FindNodeIndex(Nodes[AIndex].ParentId);
  if Nodes[AIndex].ParentId=0 then
    Result:=True
  else if ParentIndex<0 then
    Result:=False
  else
    Result:=ValidateNode(ParentIndex);
  if Result then
    fVisitState[AIndex] := 2;
end;

function T3dScene.ValidateHierarchy: Boolean;

var I: Integer;
begin
  EnsureIndex;
  if Length(fVisitState)>0 then
    FillChar(fVisitState[0],Length(fVisitState),0);
  for I:=0 to High(Nodes) do
    if not ValidateNode(I) then
      Exit(False);
  Result := True;
end;

function T3dScene.RebuildWorldTransforms(out AUpdated:Integer): Boolean;

var I: Integer;
begin
  AUpdated := 0;
  if not ValidateHierarchy then
    Exit(False);
  if Length(fVisitState)>0 then
    FillChar(fVisitState[0],Length(fVisitState),0);
  for I:=0 to High(Nodes) do
    begin
      if not ResolveWorld(I) then
        Exit(False);
      Inc(AUpdated);
    end;
  fBoundsDirty := True;
  Result := True;
end;

procedure T3dScene.MarkBoundsDirty;
begin
  fBoundsDirty := True;
end;

function T3dScene.GetBounds: T3dBounds;
begin
  if fBoundsDirty then
    RecalculateBounds;
  Result := fBounds;
end;

procedure T3dScene.ResolveLinks;

var I, J: Integer;
  N: T3dNode;
begin
  for I := 0 to High(Nodes) do
    begin
      N := FindNode(Nodes[I].ParentName);
      if N <> nil then
        Nodes[I].ParentId := N.Id;
      if (Nodes[I].Mesh <> nil) and (Nodes[I].Mesh.SourceNodeId = 0) then
        if I > 0 then
          for J := 0 to I - 1 do
            if (Nodes[J].Mesh <> nil) and
               (Nodes[J].Name = Nodes[I].Mesh.SourceNodeName) then
              begin
                Nodes[I].Mesh.SourceNodeId := Nodes[J].Id;
                Nodes[I].Bounds := Nodes[J].Bounds;
                Break;
              end;
    end;
  for I := 0 to High(Animations) do
    for J := 0 to High(Animations[I].Tracks) do
      begin
        N := FindNode(Animations[I].Tracks[J].NodeName);
        if N <> nil then
          Animations[I].Tracks[J].NodeId := N.Id;
      end;
end;

procedure T3dScene.RecalculateBounds;

var I,J: Integer;
  P: T3dVector;
  N: T3dNode;
begin
  fBounds.Valid := False;
  for I := 0 to High(Nodes) do
    if Nodes[I].Bounds.Valid then
      begin
        N := Nodes[I];
        for J:=0 to 7 do
          begin
            if (J and 1)=0 then
              P.X := N.Bounds.Min.X
            else P.X := N.Bounds.Max.X;
            if (J and 2)=0 then
              P.Y := N.Bounds.Min.Y
            else P.Y := N.Bounds.Max.Y;
            if (J and 4)=0 then
              P.Z := N.Bounds.Min.Z
            else P.Z := N.Bounds.Max.Z;
            IncludePoint(fBounds,Vector3d(
                         P.X*N.WorldTransform[0]+P.Y*N.WorldTransform[4]+P.Z*N.WorldTransform[8]+N.
                         WorldTransform[12],
                         P.X*N.WorldTransform[1]+P.Y*N.WorldTransform[5]+P.Z*N.WorldTransform[9]+N.
                         WorldTransform[13],
                         P.X*N.WorldTransform[2]+P.Y*N.WorldTransform[6]+P.Z*N.WorldTransform[10]+N.
                         WorldTransform[14]));
          end;
      end;
  fBoundsDirty := False;
end;

end.
