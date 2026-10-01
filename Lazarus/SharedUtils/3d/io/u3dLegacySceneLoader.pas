unit u3dLegacySceneLoader;

{$mode objfpc}{$H+}

interface

uses u3dScene;

type
  I3dSceneLoader=interface
    ['{E28493A3-E1A0-4D17-91B0-504849794233}']
    function LoadScene(const AFileName:string):T3dScene;
  end;

  T3dLegacySceneLoader=class(TInterfacedObject,I3dSceneLoader)
  public
    function LoadScene(const AFileName:string):T3dScene;
  end;

implementation

uses SysUtils, u3dObrReader, u3dObaReader, u3dBinaryReader;

function T3dLegacySceneLoader.LoadScene(const AFileName:string):T3dScene;
var Obr:T3dObrReader; Oba:T3dObaReader; Limits:T3dReadLimits; AnimationFile:string;
begin
  Result:=nil; Limits:=Default3dReadLimits; Obr:=T3dObrReader.Create(Limits);
  try
    try
      Result:=Obr.LoadFromFile(AFileName);
      AnimationFile:=ChangeFileExt(AFileName,'.oba');
      if FileExists(AnimationFile) then begin
        Oba:=T3dObaReader.Create(Limits);
        try Oba.LoadFromFile(AnimationFile,Result); finally Oba.Free; end;
      end;
    except FreeAndNil(Result); raise;
    end;
  finally Obr.Free; end;
end;

end.
