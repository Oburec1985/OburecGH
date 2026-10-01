unit u3dLegacySceneLoader;

interface

uses
  SysUtils, u3dContracts;

type
  T3dLegacyLoadEvent = function(const AFileName: string): Boolean of object;

  T3dLegacySceneLoader = class(TInterfacedObject, I3dSceneLoader)
  private
    fOnLoad: T3dLegacyLoadEvent;
  public
    constructor Create(const AOnLoad: T3dLegacyLoadEvent);
    function CanLoad(const AFileName: string): Boolean;
    procedure LoadScene(const AFileName: string);
  end;

implementation

constructor T3dLegacySceneLoader.Create(const AOnLoad: T3dLegacyLoadEvent);
begin
  inherited Create;
  if not Assigned(AOnLoad) then
    raise EArgumentException.Create('Legacy 3D load callback is required');
  fOnLoad := AOnLoad;
end;

function T3dLegacySceneLoader.CanLoad(const AFileName: string): Boolean;
var
  lExtension: string;
begin
  lExtension := LowerCase(ExtractFileExt(AFileName));
  Result := (lExtension = '.obr') or (lExtension = '.oba');
end;

procedure T3dLegacySceneLoader.LoadScene(const AFileName: string);
begin
  if not CanLoad(AFileName) then
    raise EArgumentException.Create('Unsupported legacy 3D file: ' + AFileName);
  if not fOnLoad(AFileName) then
    raise Exception.Create('Cannot load legacy 3D file: ' + AFileName);
end;

end.
