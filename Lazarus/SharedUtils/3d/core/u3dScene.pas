unit u3dScene;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, u3dCoreTypes;

type
  T3dMatrix = array[0..15] of Single;
  T3dVector2 = record U, V: Single; end;
  T3dTriangle = record A, B, C: LongWord; end;
  T3dLogicalVertex = record
    Id: LongWord;
    CornerIndices: array of LongWord;
  end;
  T3dColor = record R, G, B: Byte; end;
  T3dBounds = record
    Valid: Boolean;
    Min, Max: T3dVector;
  end;

  T3dNodeKind = (nkMesh, nkCamera, nkDummy, nkShape, nkLight, nkUnknown);

  T3dShapeLine = record
    Closed: Boolean;
    Points: array of T3dVector;
  end;

  T3dMeshData = class
  public
    Positions: array of T3dVector;
    Normals: array of T3dVector;
    TexCoords: array of T3dVector2;
    Triangles: array of T3dTriangle;
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
    destructor Destroy; override;
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
    destructor Destroy; override;
  end;

  T3dScene = class
  private
    fBounds: T3dBounds;
  public
    Nodes: array of T3dNode;
    Animations: array of T3dAnimation;
    destructor Destroy; override;
    procedure AddNode(ANode: T3dNode);
    procedure AddAnimation(AAnimation: T3dAnimation);
    function FindNode(const AName: string): T3dNode;
    function FindNode(AId: QWord): T3dNode;
    procedure ResolveLinks;
    procedure RecalculateBounds;
    property Bounds: T3dBounds read fBounds;
  end;

procedure SetIdentity(out AMatrix: T3dMatrix);
procedure IncludePoint(var ABounds: T3dBounds; const APoint: T3dVector);

implementation

procedure SetIdentity(out AMatrix: T3dMatrix);
var I: Integer;
begin
  for I := 0 to High(AMatrix) do AMatrix[I] := 0;
  AMatrix[0] := 1; AMatrix[5] := 1; AMatrix[10] := 1; AMatrix[15] := 1;
end;

procedure IncludePoint(var ABounds: T3dBounds; const APoint: T3dVector);
begin
  if not ABounds.Valid then begin ABounds.Valid := True; ABounds.Min := APoint; ABounds.Max := APoint; Exit; end;
  if APoint.X < ABounds.Min.X then ABounds.Min.X := APoint.X;
  if APoint.Y < ABounds.Min.Y then ABounds.Min.Y := APoint.Y;
  if APoint.Z < ABounds.Min.Z then ABounds.Min.Z := APoint.Z;
  if APoint.X > ABounds.Max.X then ABounds.Max.X := APoint.X;
  if APoint.Y > ABounds.Max.Y then ABounds.Max.Y := APoint.Y;
  if APoint.Z > ABounds.Max.Z then ABounds.Max.Z := APoint.Z;
end;

destructor T3dNode.Destroy;
begin
  Mesh.Free;
  inherited Destroy;
end;

destructor T3dAnimation.Destroy;
var I: Integer;
begin
  for I := 0 to High(Tracks) do Tracks[I].Free;
  inherited Destroy;
end;

destructor T3dScene.Destroy;
var I: Integer;
begin
  for I := 0 to High(Nodes) do Nodes[I].Free;
  for I := 0 to High(Animations) do Animations[I].Free;
  inherited Destroy;
end;

procedure T3dScene.AddNode(ANode: T3dNode);
begin
  SetLength(Nodes, Length(Nodes) + 1);
  Nodes[High(Nodes)] := ANode;
end;

procedure T3dScene.AddAnimation(AAnimation: T3dAnimation);
begin
  SetLength(Animations, Length(Animations) + 1);
  Animations[High(Animations)] := AAnimation;
end;

function T3dScene.FindNode(const AName: string): T3dNode;
var I: Integer;
begin
  for I := 0 to High(Nodes) do if Nodes[I].Name = AName then Exit(Nodes[I]);
  Result := nil;
end;

function T3dScene.FindNode(AId: QWord): T3dNode;
var I: Integer;
begin
  for I := 0 to High(Nodes) do
    if Nodes[I].Id = AId then Exit(Nodes[I]);
  Result := nil;
end;

procedure T3dScene.ResolveLinks;
var I, J: Integer; N: T3dNode;
begin
  for I := 0 to High(Nodes) do begin
    N := FindNode(Nodes[I].ParentName);
    if N <> nil then Nodes[I].ParentId := N.Id;
    if (Nodes[I].Mesh <> nil) and (Nodes[I].Mesh.SourceNodeId = 0) then
      if I > 0 then for J := 0 to I - 1 do
        if (Nodes[J].Mesh <> nil) and
          (Nodes[J].Name = Nodes[I].Mesh.SourceNodeName) then begin
          Nodes[I].Mesh.SourceNodeId := Nodes[J].Id;
          Nodes[I].Bounds := Nodes[J].Bounds;
          Break;
        end;
  end;
  for I := 0 to High(Animations) do
    for J := 0 to High(Animations[I].Tracks) do begin
      N := FindNode(Animations[I].Tracks[J].NodeName);
      if N <> nil then Animations[I].Tracks[J].NodeId := N.Id;
    end;
end;

procedure T3dScene.RecalculateBounds;
var I,J: Integer; P:T3dVector; N:T3dNode;
begin
  fBounds.Valid := False;
  for I := 0 to High(Nodes) do if Nodes[I].Bounds.Valid then begin N:=Nodes[I];
    for J:=0 to 7 do begin
      if (J and 1)=0 then P.X:=N.Bounds.Min.X else P.X:=N.Bounds.Max.X;
      if (J and 2)=0 then P.Y:=N.Bounds.Min.Y else P.Y:=N.Bounds.Max.Y;
      if (J and 4)=0 then P.Z:=N.Bounds.Min.Z else P.Z:=N.Bounds.Max.Z;
      IncludePoint(fBounds,Vector3d(
        P.X*N.WorldTransform[0]+P.Y*N.WorldTransform[4]+P.Z*N.WorldTransform[8]+N.WorldTransform[12],
        P.X*N.WorldTransform[1]+P.Y*N.WorldTransform[5]+P.Z*N.WorldTransform[9]+N.WorldTransform[13],
        P.X*N.WorldTransform[2]+P.Y*N.WorldTransform[6]+P.Z*N.WorldTransform[10]+N.WorldTransform[14]));
    end;
  end;
end;

end.
