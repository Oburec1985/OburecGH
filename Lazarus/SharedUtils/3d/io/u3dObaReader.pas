unit u3dObaReader;

{ Decodes bounded legacy animation files and resolves tracks against an
  optional caller-owned scene. The reader owns no resulting scene. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, u3dScene, u3dBinaryReader;

type
  T3dObaReader = class
  private
      fLimits: T3dReadLimits;
      fReader: T3dBinaryReader;
      procedure ReadMatrix(out AMatrix: T3dMatrix);
  public
      constructor Create(const ALimits: T3dReadLimits);
      function LoadFromFile(const AFileName: string; AScene: T3dScene): T3dAnimation;
  end;

implementation

constructor T3dObaReader.Create(const ALimits: T3dReadLimits);
begin
  inherited Create;
  fLimits := ALimits;
end;

procedure T3dObaReader.ReadMatrix(out AMatrix: T3dMatrix);

var Row, Col: Integer;
begin
  SetIdentity(AMatrix);
  for Row := 0 to 3 do
    for Col := 0 to 2 do
      AMatrix[Row * 4 + Col] := fReader.ReadSingleLE;
end;

function T3dObaReader.LoadFromFile(const AFileName: string;
                                   AScene: T3dScene): T3dAnimation;

var Stream: TFileStream;
  Track: T3dAnimationTrack;
  Marker, NodeName: string;
  KeyCount, TotalKeys: QWord;
  I: QWord;
begin
  Result := nil;
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    if QWord(Stream.Size) > fLimits.MaxFileBytes then
      raise E3dFormatError.Create(
                                  'File exceeds size limit'
      );
    fReader := T3dBinaryReader.Create(Stream, Stream.Size);
    try
      Marker := string(fReader.ReadCString(fLimits.MaxStringBytes));
      if Marker <> 'Animation' then
        raise E3dFormatError.Create('Not an OBA file');
      Result := T3dAnimation.Create;
      try
        Result.FramesPerSecond := fReader.ReadUInt32LE;
        Result.FrameCount := fReader.ReadUInt32LE;
        Result.TicksPerFrame := fReader.ReadUInt32LE;
        if Result.FramesPerSecond = 0 then
          raise E3dFormatError.Create('Animation FPS is zero');
        TotalKeys := 0;
        while fReader.Position < Stream.Size do
          begin
            RequireCount(Length(Result.Tracks) + 1, fLimits.MaxNodes, 'animation track');
            NodeName := string(fReader.ReadCString(fLimits.MaxStringBytes));
            KeyCount := fReader.ReadUInt32LE;
            Inc(TotalKeys, KeyCount);
            RequireCount(TotalKeys, fLimits.MaxAnimationKeys, 'animation key');
            Track := T3dAnimationTrack.Create;
            try
              Track.NodeName := NodeName;
              SetLength(Track.Keys, KeyCount);
              if KeyCount > 0 then
                for I := 0 to KeyCount - 1 do
                  begin
                    Track.Keys[I].Frame := fReader.ReadUInt32LE;
                    ReadMatrix(Track.Keys[I].Transform);
                  end;
              Marker := string(fReader.ReadCString(fLimits.MaxStringBytes));
              if Marker <> 'NextNode' then
                raise E3dFormatError.Create('Missing NextNode marker');
              SetLength(Result.Tracks, Length(Result.Tracks) + 1);
              Result.Tracks[High(Result.Tracks)] := Track;
              Track := nil;
            finally
              Track.Free;
          end;
end;
if AScene <> nil then
  begin
    AScene.AddAnimation(Result);
    AScene.ResolveLinks;
  end;
except
  Result.Free;
  Result := nil;
  raise;
end;
finally
  FreeAndNil(fReader);
end;
finally
  Stream.Free;
end;
end;

end.
