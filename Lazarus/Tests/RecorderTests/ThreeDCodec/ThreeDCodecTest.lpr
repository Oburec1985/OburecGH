program ThreeDCodecTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Classes, SysUtils, u3dScene, u3dMeshTopology, u3dBinaryReader, u3dObrReader, u3dObaReader;

procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;

procedure ExpectTruncatedFailure(const ASource, ATemporary: string;
  const ALimits: T3dReadLimits);
var Source, Target: TFileStream; Buffer: array[0..255] of Byte; ToCopy, N: Int64;
  Reader: T3dObrReader; Scene: T3dScene; Failed: Boolean;
begin
  Source := TFileStream.Create(ASource, fmOpenRead); Target := TFileStream.Create(ATemporary, fmCreate);
  try
    ToCopy := Source.Size div 2;
    while ToCopy > 0 do begin
      N := ToCopy; if N > SizeOf(Buffer) then N := SizeOf(Buffer);
      Source.ReadBuffer(Buffer, N); Target.WriteBuffer(Buffer, N); Dec(ToCopy, N);
    end;
  finally Target.Free; Source.Free; end;
  Reader := T3dObrReader.Create(ALimits); Failed := False;
  try
    try Scene := Reader.LoadFromFile(ATemporary); Scene.Free;
    except on E: E3dFormatError do Failed := True; end;
  finally Reader.Free; DeleteFile(ATemporary); end;
  Check(Failed, 'truncated OBR was accepted');
end;

procedure TestObr(const AFileName: string; const ALimits: T3dReadLimits);
var Reader: T3dObrReader; Scene: T3dScene;
begin
  Check(FileExists(AFileName), 'fixture not found: ' + AFileName);
  Reader := T3dObrReader.Create(ALimits);
  try
    Scene := Reader.LoadFromFile(AFileName);
    try
      Check(Length(Scene.Nodes) > 0, 'empty scene: ' + AFileName);
      WriteLn('PASS OBR ', ExtractFileName(AFileName), ' nodes=', Length(Scene.Nodes),
        ' bounds=', Scene.Bounds.Valid);
    finally Scene.Free; end;
  finally Reader.Free; end;
end;

procedure TestPair(const AObr, AOba: string; const ALimits: T3dReadLimits);
var Obr: T3dObrReader; Oba: T3dObaReader; Scene: T3dScene; Animation: T3dAnimation;
begin
  Check(FileExists(AObr), 'fixture not found: ' + AObr);
  Check(FileExists(AOba), 'fixture not found: ' + AOba);
  Obr := T3dObrReader.Create(ALimits); Oba := T3dObaReader.Create(ALimits);
  try
    Scene := Obr.LoadFromFile(AObr);
    try
      Animation := Oba.LoadFromFile(AOba, Scene);
      Check(Length(Animation.Tracks) > 0, 'empty animation');
      WriteLn('PASS OBA ', ExtractFileName(AOba), ' tracks=', Length(Animation.Tracks));
    finally Scene.Free; end;
  finally Oba.Free; Obr.Free; end;
end;

procedure TestLogicalTopology;
var M:T3dMeshData; T:T3dMeshTopology; R:T3dTopologyRelations;
begin M:=T3dMeshData.Create; try
  SetLength(M.Positions,5); SetLength(M.Triangles,2);
  M.Triangles[0].A:=0; M.Triangles[0].B:=1; M.Triangles[0].C:=2;
  M.Triangles[1].A:=3; M.Triangles[1].B:=2; M.Triangles[1].C:=4;
  SetLength(M.LogicalVertices,4);
  M.LogicalVertices[0].Id:=100; SetLength(M.LogicalVertices[0].CornerIndices,2);
  M.LogicalVertices[0].CornerIndices[0]:=0; M.LogicalVertices[0].CornerIndices[1]:=3;
  M.LogicalVertices[1].Id:=101; SetLength(M.LogicalVertices[1].CornerIndices,1); M.LogicalVertices[1].CornerIndices[0]:=1;
  M.LogicalVertices[2].Id:=102; SetLength(M.LogicalVertices[2].CornerIndices,1); M.LogicalVertices[2].CornerIndices[0]:=2;
  M.LogicalVertices[3].Id:=103; SetLength(M.LogicalVertices[3].CornerIndices,1); M.LogicalVertices[3].CornerIndices[0]:=4;
  T:=BuildMeshTopology(M); Check(Length(T.Vertices)=4,'logical row count');
  Check((T.CornerToLogical[0]=0) and (T.CornerToLogical[3]=0),'explicit seam mapping');
  Check((Length(T.LogicalToFaces[0])=2) and (T.Vertices[0].CornerCount=2),'faces and copies');
  R:=ClassifyLogicalVertices(T,0); Check(R[0]=trPrimary,'primary vertex');
  Check((R[1]=trAdjacent) and (R[2]=trAdjacent) and (R[3]=trAdjacent),'topological neighbors');
finally M.Free; end; end;

var Root, TempName: string; Limits: T3dReadLimits;
begin
  try
    if ParamCount > 0 then Root := ParamStr(1)
    else Root := 'D:\works\delphi11\3d\files\3d\Meshes';
    Limits := Default3dReadLimits;
    TestObr(IncludeTrailingPathDelimiter(Root) + 'box.OBR', Limits);
    TestObr(IncludeTrailingPathDelimiter(Root) + 'Axis.OBR', Limits);
    TestObr(IncludeTrailingPathDelimiter(Root) + 'Animation.OBR', Limits);
    TestObr(IncludeTrailingPathDelimiter(Root) + 'turbina.OBR', Limits);
    TestObr(IncludeTrailingPathDelimiter(Root) + 'skin.OBR', Limits);
    TestObr(IncludeTrailingPathDelimiter(Root) + 'airplane_5.OBR', Limits);
    TestPair(IncludeTrailingPathDelimiter(Root) + 'Animation.OBR',
      IncludeTrailingPathDelimiter(Root) + 'Animation.oba', Limits);
    TempName := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'three_d_truncated.obr';
    ExpectTruncatedFailure(IncludeTrailingPathDelimiter(Root) + 'box.OBR', TempName, Limits);
    TestLogicalTopology;
    WriteLn('RESULT ThreeDCodec passed');
  except
    on E: Exception do begin WriteLn(StdErr, 'RESULT ThreeDCodec failed: ', E.Message); Halt(1); end;
  end;
end.
