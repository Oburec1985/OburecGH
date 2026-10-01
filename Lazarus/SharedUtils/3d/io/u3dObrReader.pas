unit u3dObrReader;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, u3dCoreTypes, u3dScene, u3dBinaryReader;

type
  T3dObrReader = class
  private
    fLimits: T3dReadLimits;
    fReader: T3dBinaryReader;
    function Text(const ARaw: RawByteString): string;
    procedure ReadMatrix(out AMatrix: T3dMatrix);
    procedure ReadNodeHeader(ANode: T3dNode);
    procedure ReadMesh(ANode: T3dNode);
    procedure ReadShape(ANode: T3dNode);
    procedure SkipSkin;
    procedure SkipMaterial;
    function ReadNode(AId: QWord): T3dNode;
  public
    constructor Create(const ALimits: T3dReadLimits);
    function LoadFromFile(const AFileName: string): T3dScene;
  end;

implementation

type
  TObrEntry = record Name: string; Offset: LongWord; end;

const
  NodeChunk = $ABCD;
  VertexChunk = $2FF2;
  ParentChunk = $3FF3;
  MaterialChunk = $1FF1;

constructor T3dObrReader.Create(const ALimits: T3dReadLimits);
begin inherited Create; fLimits := ALimits; end;

function T3dObrReader.Text(const ARaw: RawByteString): string;
begin Result := string(ARaw); end;

procedure T3dObrReader.ReadMatrix(out AMatrix: T3dMatrix);
var Row, Col: Integer;
begin
  SetIdentity(AMatrix);
  for Row := 0 to 3 do for Col := 0 to 2 do
    AMatrix[Row * 4 + Col] := fReader.ReadSingleLE;
end;

procedure T3dObrReader.ReadNodeHeader(ANode: T3dNode);
var Chunk: Word; LinkType: Byte;
begin
  ANode.Name := Text(fReader.ReadCString(fLimits.MaxStringBytes));
  ReadMatrix(ANode.WorldTransform);
  ReadMatrix(ANode.LocalTransform);
  Chunk := fReader.ReadWordLE;
  if Chunk = ParentChunk then begin
    LinkType := fReader.ReadByte;
    if LinkType = 0 then ANode.ParentName := Text(fReader.ReadCString(fLimits.MaxStringBytes));
  end;
end;

procedure T3dObrReader.SkipSkin;
var Marker: string; BoneCount, VertexCount, I, J: QWord;
begin
  Marker := Text(fReader.ReadCString(fLimits.MaxStringBytes));
  if Marker = 'Skin0' then Exit;
  if Marker <> 'Skin1' then raise E3dFormatError.CreateFmt('Unknown skin marker %s', [Marker]);
  BoneCount := fReader.ReadUInt32LE;
  RequireCount(BoneCount, fLimits.MaxNodes, 'skin bone');
  if BoneCount > 0 then for I := 0 to BoneCount - 1 do begin
    fReader.ReadCString(fLimits.MaxStringBytes);
    VertexCount := fReader.ReadUInt32LE;
    RequireCount(VertexCount, fLimits.MaxVertices, 'skin vertex');
    if VertexCount > 0 then for J := 0 to VertexCount - 1 do begin fReader.ReadUInt32LE; fReader.ReadSingleLE; end;
  end;
end;

procedure T3dObrReader.SkipMaterial;
var I: Integer;
begin
  if fReader.ReadWordLE <> MaterialChunk then Exit;
  fReader.ReadCString(fLimits.MaxStringBytes);
  for I := 1 to 10 do fReader.ReadSingleLE;
  if fReader.ReadByte <> 0 then fReader.ReadCString(fLimits.MaxStringBytes);
  if fReader.ReadByte <> 0 then fReader.ReadCString(fLimits.MaxStringBytes);
end;

procedure T3dObrReader.ReadMesh(ANode: T3dNode);
var InlineData: Byte; FaceCount, VertexCount, UniqueCount, PointerCount: QWord;
  I, J: QWord; P: T3dVector;
begin
  if fReader.ReadWordLE <> VertexChunk then raise E3dFormatError.Create('Missing mesh chunk');
  ANode.Mesh := T3dMeshData.Create;
  InlineData := fReader.ReadByte;
  if InlineData = 0 then
    ANode.Mesh.SourceNodeName := Text(fReader.ReadCString(fLimits.MaxStringBytes))
  else if InlineData = 1 then begin
    FaceCount := fReader.ReadUInt32LE; VertexCount := fReader.ReadUInt32LE;
    RequireCount(FaceCount, fLimits.MaxTriangles, 'triangle');
    RequireCount(VertexCount, fLimits.MaxVertices, 'vertex');
    SetLength(ANode.Mesh.Triangles, FaceCount);
    if FaceCount > 0 then for I := 0 to FaceCount - 1 do begin
      ANode.Mesh.Triangles[I].A := fReader.ReadUInt32LE;
      ANode.Mesh.Triangles[I].B := fReader.ReadUInt32LE;
      ANode.Mesh.Triangles[I].C := fReader.ReadUInt32LE;
      if (ANode.Mesh.Triangles[I].A >= VertexCount) or
        (ANode.Mesh.Triangles[I].B >= VertexCount) or
        (ANode.Mesh.Triangles[I].C >= VertexCount) then
        raise E3dFormatError.Create('Triangle index is outside vertex array');
    end;
    SetLength(ANode.Mesh.Positions, VertexCount);
    if VertexCount > 0 then for I := 0 to VertexCount - 1 do begin
      P.X := fReader.ReadSingleLE; P.Y := fReader.ReadSingleLE; P.Z := fReader.ReadSingleLE;
      ANode.Mesh.Positions[I] := P; IncludePoint(ANode.Bounds, P);
    end;
    SetLength(ANode.Mesh.Normals, VertexCount);
    if VertexCount > 0 then for I := 0 to VertexCount - 1 do begin
      ANode.Mesh.Normals[I].X := fReader.ReadSingleLE;
      ANode.Mesh.Normals[I].Y := fReader.ReadSingleLE;
      ANode.Mesh.Normals[I].Z := fReader.ReadSingleLE;
    end;
    SetLength(ANode.Mesh.TexCoords, VertexCount);
    if VertexCount > 0 then for I := 0 to VertexCount - 1 do begin
      ANode.Mesh.TexCoords[I].U := fReader.ReadSingleLE;
      ANode.Mesh.TexCoords[I].V := fReader.ReadSingleLE;
    end;
    UniqueCount := fReader.ReadUInt32LE;
    RequireCount(UniqueCount, fLimits.MaxVertices, 'unique vertex');
    SetLength(ANode.Mesh.LogicalVertices, UniqueCount);
    if UniqueCount > 0 then for I := 0 to UniqueCount - 1 do begin
      ANode.Mesh.LogicalVertices[I].Id := fReader.ReadUInt32LE;
      PointerCount := fReader.ReadUInt32LE;
      RequireCount(PointerCount, fLimits.MaxVertices, 'vertex pointer');
      SetLength(ANode.Mesh.LogicalVertices[I].CornerIndices, PointerCount);
      if PointerCount > 0 then for J := 0 to PointerCount - 1 do begin
        ANode.Mesh.LogicalVertices[I].CornerIndices[J] := fReader.ReadUInt32LE;
        if ANode.Mesh.LogicalVertices[I].CornerIndices[J] >= VertexCount then
          raise E3dFormatError.Create('Logical vertex pointer outside vertex array');
      end;
    end;
  end else raise E3dFormatError.Create('Invalid mesh storage flag');
  SkipSkin;
  ANode.Mesh.Color.R := fReader.ReadByte;
  ANode.Mesh.Color.G := fReader.ReadByte;
  ANode.Mesh.Color.B := fReader.ReadByte;
  SkipMaterial;
end;

procedure T3dObrReader.ReadShape(ANode: T3dNode);
var LineCount, PointCount, I, J, Total: QWord; P: T3dVector;
begin
  LineCount := fReader.ReadUInt32LE;
  RequireCount(LineCount, fLimits.MaxNodes, 'shape line');
  SetLength(ANode.ShapeLines, LineCount); Total := 0;
  if LineCount > 0 then for I := 0 to LineCount - 1 do begin
    ANode.ShapeLines[I].Closed := fReader.ReadByte <> 0;
    PointCount := fReader.ReadUInt32LE;
    Inc(Total, PointCount); RequireCount(Total, fLimits.MaxShapePoints, 'shape point');
    SetLength(ANode.ShapeLines[I].Points, PointCount);
    if PointCount > 0 then for J := 0 to PointCount - 1 do begin
      P.X := fReader.ReadSingleLE; P.Y := fReader.ReadSingleLE; P.Z := fReader.ReadSingleLE;
      ANode.ShapeLines[I].Points[J] := P; IncludePoint(ANode.Bounds, P);
    end;
  end;
end;

function T3dObrReader.ReadNode(AId: QWord): T3dNode;
var ObjectType: Byte;
begin
  if fReader.ReadWordLE <> NodeChunk then raise E3dFormatError.Create('Missing node chunk');
  ObjectType := fReader.ReadByte;
  Result := T3dNode.Create;
  try
    Result.Id := AId; Result.ObjectType := ObjectType;
    case ObjectType of
      0: Result.Kind := nkMesh; 2: Result.Kind := nkCamera; 3: Result.Kind := nkDummy;
      4: Result.Kind := nkShape; 23: Result.Kind := nkLight;
    else Result.Kind := nkUnknown; end;
    ReadNodeHeader(Result);
    case Result.Kind of nkMesh: ReadMesh(Result); nkShape: ReadShape(Result); end;
  except Result.Free; raise; end;
end;

function T3dObrReader.LoadFromFile(const AFileName: string): T3dScene;
var Stream: TFileStream; Entries: array of TObrEntry; Entry: TObrEntry;
  Signature: string; I, J: Integer; Node: T3dNode; ChunkLimit: Int64;
begin
  Result := nil;
  SetLength(Entries, 0);
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    if QWord(Stream.Size) > fLimits.MaxFileBytes then raise E3dFormatError.Create('File exceeds size limit');
    fReader := T3dBinaryReader.Create(Stream, Stream.Size);
    try
      Signature := Text(fReader.ReadCString(fLimits.MaxStringBytes));
      if Signature <> 'ObrFile' then raise E3dFormatError.Create('Not an OBR file');
      repeat
        Signature := Text(fReader.ReadCString(fLimits.MaxStringBytes));
        if Signature = 'ObrFile_Body' then Break;
        RequireCount(Length(Entries) + 1, fLimits.MaxNodes, 'node');
        Entry.Name := Signature; Entry.Offset := fReader.ReadUInt32LE;
        if Entry.Offset >= QWord(Stream.Size) then raise E3dFormatError.Create('Node offset outside file');
        SetLength(Entries, Length(Entries) + 1); Entries[High(Entries)] := Entry;
      until False;
      FreeAndNil(fReader);
      Result := T3dScene.Create;
      try
        for I := 0 to High(Entries) do begin
          ChunkLimit := Stream.Size;
          for J := 0 to High(Entries) do
            if (Entries[J].Offset > Entries[I].Offset) and
              (Entries[J].Offset < QWord(ChunkLimit)) then ChunkLimit := Entries[J].Offset;
          fReader := T3dBinaryReader.Create(Stream, ChunkLimit);
          try
            fReader.Seek(Entries[I].Offset);
            Node := ReadNode(I + 1);
            if Node.Name <> Entries[I].Name then begin Node.Free; raise E3dFormatError.Create('Header/body node name mismatch'); end;
            Result.AddNode(Node);
          finally FreeAndNil(fReader); end;
        end;
        Result.ResolveLinks; Result.RecalculateBounds;
      except FreeAndNil(Result); raise; end;
    finally FreeAndNil(fReader); end;
  finally Stream.Free; end;
end;

end.
