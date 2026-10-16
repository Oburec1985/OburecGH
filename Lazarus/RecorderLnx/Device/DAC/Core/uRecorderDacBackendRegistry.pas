unit uRecorderDacBackendRegistry;

{ Registry of replaceable DAC transports. Component/runtime code resolves a
  BackendId during Configure and never depends on a concrete driver class. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, uRecorderDacContracts;

type
  TRecorderDacBackendRegistry = class
  private
    fFactories: TObjectList;
    function GetCount: Integer;
    function GetFactory(AIndex: Integer): TRecorderDacBackendFactory;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterFactory(AFactory: TRecorderDacBackendFactory);
    function FindFactory(const ABackendId: string): TRecorderDacBackendFactory;
    property Count: Integer read GetCount;
    property Factories[AIndex: Integer]: TRecorderDacBackendFactory
      read GetFactory;
  end;

implementation

constructor TRecorderDacBackendRegistry.Create;
begin
  inherited Create;
  fFactories := TObjectList.Create(True);
end;

destructor TRecorderDacBackendRegistry.Destroy;
begin
  fFactories.Free;
  inherited Destroy;
end;

function TRecorderDacBackendRegistry.GetCount: Integer;
begin
  Result := fFactories.Count;
end;

function TRecorderDacBackendRegistry.GetFactory(
  AIndex: Integer): TRecorderDacBackendFactory;
begin
  Result := TRecorderDacBackendFactory(fFactories[AIndex]);
end;

procedure TRecorderDacBackendRegistry.RegisterFactory(
  AFactory: TRecorderDacBackendFactory);
begin
  if AFactory = nil then
    raise EArgumentNilException.Create('DAC backend factory is required');
  if FindFactory(AFactory.BackendId) <> nil then
    raise Exception.CreateFmt('DAC backend already registered: %s',
      [AFactory.BackendId]);
  fFactories.Add(AFactory);
end;

function TRecorderDacBackendRegistry.FindFactory(
  const ABackendId: string): TRecorderDacBackendFactory;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fFactories.Count - 1 do
    if SameText(TRecorderDacBackendFactory(fFactories[I]).BackendId,
      ABackendId) then
      Exit(TRecorderDacBackendFactory(fFactories[I]));
end;

end.
