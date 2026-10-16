unit uRecorderDacComponentModel;

{ Persistent DAC visual model and factory. The model contains configuration
  only; a factory-owned runtime service resolves tags and owns driver objects. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel, uRecorderTags, uRecorderDacTypes,
  uRecorderDacContracts;

type
  TRecorderDacSourceMode = (rdsmTag, rdsmSine, rdsmAccurateSine,
    rdsmSweepSine);

  TRecorderDacRuntimeSnapshot = record
    State: TRecorderDacState;
    Counters: TRecorderDacCounters;
    LastResult: TRecorderDacResult;
  end;

  IRecorderDacComponentRuntime = interface
    ['{25D40DB3-B4C5-4143-9717-9A9F77E76A07}']
    function Component: TRecorderVisualComponent;
    procedure SetTagRegistry(ARegistry: TRecorderTagRegistry);
    procedure StartOutput;
    procedure StopOutput;
    function Snapshot: TRecorderDacRuntimeSnapshot;
  end;

  TRecorderDacComponent = class(TRecorderVisualComponent)
  private
    fEnabled: Boolean;
    fBackendId: string;
    fEndpoint: string;
    fSourceMode: TRecorderDacSourceMode;
    fInputTagId: TRecorderTagId;
    fInputTagName: string;
    fMirrorEnabled: Boolean;
    fMirrorTagId: TRecorderTagId;
    fMirrorTagName: string;
    fSampleRateHz: Double;
    fFramesPerBlock: Integer;
    fMinimumValue: Double;
    fMaximumValue: Double;
    fSafeValue: Double;
    fUnderrunPolicy: TRecorderDacUnderrunPolicy;
    fFrequencyHz: Double;
    fAmplitude: Double;
    fSweepStartHz: Double;
    fSweepEndHz: Double;
    fSweepTimeSec: Double;
    fRevision: LongInt;
    procedure Changed;
    procedure SetBackendId(const AValue: string);
    procedure SetEnabled(AValue: Boolean);
    procedure SetEndpoint(const AValue: string);
    procedure SetFramesPerBlock(AValue: Integer);
    procedure SetInputTagId(AValue: TRecorderTagId);
    procedure SetInputTagName(const AValue: string);
    procedure SetMaximumValue(AValue: Double);
    procedure SetMinimumValue(AValue: Double);
    procedure SetMirrorEnabled(AValue: Boolean);
    procedure SetMirrorTagId(AValue: TRecorderTagId);
    procedure SetMirrorTagName(const AValue: string);
    procedure SetSafeValue(AValue: Double);
    procedure SetSampleRateHz(AValue: Double);
    procedure SetSourceMode(AValue: TRecorderDacSourceMode);
    procedure SetUnderrunPolicy(AValue: TRecorderDacUnderrunPolicy);
    procedure SetFrequencyHz(AValue: Double);
    procedure SetAmplitude(AValue: Double);
    procedure SetSweepStartHz(AValue: Double);
    procedure SetSweepEndHz(AValue: Double);
    procedure SetSweepTimeSec(AValue: Double);
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    procedure AssignDac(ASource: TRecorderDacComponent);
    function BuildConfig: TRecorderDacConfig;
    property Revision: LongInt read fRevision;
    property Enabled: Boolean read fEnabled write SetEnabled;
    property BackendId: string read fBackendId write SetBackendId;
    property Endpoint: string read fEndpoint write SetEndpoint;
    property SourceMode: TRecorderDacSourceMode read fSourceMode write SetSourceMode;
    property InputTagId: TRecorderTagId read fInputTagId write SetInputTagId;
    property InputTagName: string read fInputTagName write SetInputTagName;
    property MirrorEnabled: Boolean read fMirrorEnabled write SetMirrorEnabled;
    property MirrorTagId: TRecorderTagId read fMirrorTagId write SetMirrorTagId;
    property MirrorTagName: string read fMirrorTagName write SetMirrorTagName;
    property SampleRateHz: Double read fSampleRateHz write SetSampleRateHz;
    property FramesPerBlock: Integer read fFramesPerBlock write SetFramesPerBlock;
    property MinimumValue: Double read fMinimumValue write SetMinimumValue;
    property MaximumValue: Double read fMaximumValue write SetMaximumValue;
    property SafeValue: Double read fSafeValue write SetSafeValue;
    property UnderrunPolicy: TRecorderDacUnderrunPolicy read fUnderrunPolicy
      write SetUnderrunPolicy;
    property FrequencyHz: Double read fFrequencyHz write SetFrequencyHz;
    property Amplitude: Double read fAmplitude write SetAmplitude;
    property SweepStartHz: Double read fSweepStartHz write SetSweepStartHz;
    property SweepEndHz: Double read fSweepEndHz write SetSweepEndHz;
    property SweepTimeSec: Double read fSweepTimeSec write SetSweepTimeSec;
  end;

  TRecorderDacComponentFactory = class(TRecorderComponentFactoryBase)
  private
    fRuntimes: TInterfaceList;
    fBackendRegistry: TObject;
  protected
    procedure ExcludeComponent(AComponent: TRecorderVisualComponent); override;
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    function CreateComponent: TRecorderVisualComponent; override;
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent); override;
    procedure SetTagRegistry(ARegistry: TRecorderTagRegistry);
    procedure DoStart; override;
    procedure DoStop; override;
    function RuntimeFor(AComponent: TRecorderVisualComponent):
      IRecorderDacComponentRuntime;
    function RuntimeSnapshot(AComponent: TRecorderVisualComponent):
      TRecorderDacRuntimeSnapshot;
    procedure RegisterBackend(AFactory: TRecorderDacBackendFactory);
    function DiscoverEndpoints(out AEndpoints: TRecorderDacEndpoints;
      out AResult: TRecorderDacResult): Boolean;
    procedure GetBackendIds(AItems: TStrings);
  end;

procedure RegisterRecorderDacComponentFactory(AFactory: TRecorderComponentFactory);

implementation

uses
  uRecorderDacBackendRegistry, uRecorderDacRuntime,
  uRecorderAudioDacBackend, uRecorderNullDacBackend;

class function TRecorderDacComponent.GetTypeId: string;
begin
  Result := 'DacOutput';
end;

constructor TRecorderDacComponent.Create;
begin
  inherited Create;
  fEnabled := True;
  fBackendId := 'audio.portaudio';
  fEndpoint := 'default';
  fSourceMode := rdsmSine;
  fSampleRateHz := 44100;
  fFramesPerBlock := 2048;
  fMinimumValue := -1;
  fMaximumValue := 1;
  fSafeValue := 0;
  fUnderrunPolicy := rdupZero;
  fFrequencyHz := 440;
  fAmplitude := 0.5;
  fSweepStartHz := 100;
  fSweepEndHz := 10000;
  fSweepTimeSec := 10;
  fRevision := 1;
end;

procedure TRecorderDacComponent.Changed;
begin
  InterlockedIncrement(fRevision);
end;

procedure TRecorderDacComponent.SetEnabled(AValue: Boolean);
begin if fEnabled = AValue then Exit; fEnabled := AValue; Changed; end;
procedure TRecorderDacComponent.SetBackendId(const AValue: string);
begin if fBackendId = AValue then Exit; fBackendId := AValue; Changed; end;
procedure TRecorderDacComponent.SetEndpoint(const AValue: string);
begin if fEndpoint = AValue then Exit; fEndpoint := AValue; Changed; end;
procedure TRecorderDacComponent.SetSourceMode(AValue: TRecorderDacSourceMode);
begin if fSourceMode = AValue then Exit; fSourceMode := AValue; Changed; end;
procedure TRecorderDacComponent.SetInputTagId(AValue: TRecorderTagId);
begin if fInputTagId = AValue then Exit; fInputTagId := AValue; Changed; end;
procedure TRecorderDacComponent.SetInputTagName(const AValue: string);
begin if fInputTagName = AValue then Exit; fInputTagName := AValue; Changed; end;
procedure TRecorderDacComponent.SetMirrorEnabled(AValue: Boolean);
begin if fMirrorEnabled = AValue then Exit; fMirrorEnabled := AValue; Changed; end;
procedure TRecorderDacComponent.SetMirrorTagId(AValue: TRecorderTagId);
begin if fMirrorTagId = AValue then Exit; fMirrorTagId := AValue; Changed; end;
procedure TRecorderDacComponent.SetMirrorTagName(const AValue: string);
begin if fMirrorTagName = AValue then Exit; fMirrorTagName := AValue; Changed; end;
procedure TRecorderDacComponent.SetSampleRateHz(AValue: Double);
begin if fSampleRateHz = AValue then Exit; fSampleRateHz := AValue; Changed; end;
procedure TRecorderDacComponent.SetFramesPerBlock(AValue: Integer);
begin if fFramesPerBlock = AValue then Exit; fFramesPerBlock := AValue; Changed; end;
procedure TRecorderDacComponent.SetMinimumValue(AValue: Double);
begin if fMinimumValue = AValue then Exit; fMinimumValue := AValue; Changed; end;
procedure TRecorderDacComponent.SetMaximumValue(AValue: Double);
begin if fMaximumValue = AValue then Exit; fMaximumValue := AValue; Changed; end;
procedure TRecorderDacComponent.SetSafeValue(AValue: Double);
begin if fSafeValue = AValue then Exit; fSafeValue := AValue; Changed; end;
procedure TRecorderDacComponent.SetUnderrunPolicy(AValue: TRecorderDacUnderrunPolicy);
begin if fUnderrunPolicy = AValue then Exit; fUnderrunPolicy := AValue; Changed; end;
procedure TRecorderDacComponent.SetFrequencyHz(AValue: Double);
begin if fFrequencyHz = AValue then Exit; fFrequencyHz := AValue; Changed; end;
procedure TRecorderDacComponent.SetAmplitude(AValue: Double);
begin if fAmplitude = AValue then Exit; fAmplitude := AValue; Changed; end;
procedure TRecorderDacComponent.SetSweepStartHz(AValue: Double);
begin if fSweepStartHz = AValue then Exit; fSweepStartHz := AValue; Changed; end;
procedure TRecorderDacComponent.SetSweepEndHz(AValue: Double);
begin if fSweepEndHz = AValue then Exit; fSweepEndHz := AValue; Changed; end;
procedure TRecorderDacComponent.SetSweepTimeSec(AValue: Double);
begin if fSweepTimeSec = AValue then Exit; fSweepTimeSec := AValue; Changed; end;

procedure TRecorderDacComponent.AssignDac(ASource: TRecorderDacComponent);
begin
  if ASource = nil then Exit;
  Enabled := ASource.Enabled;
  BackendId := ASource.BackendId;
  Endpoint := ASource.Endpoint;
  SourceMode := ASource.SourceMode;
  InputTagId := ASource.InputTagId;
  InputTagName := ASource.InputTagName;
  MirrorEnabled := ASource.MirrorEnabled;
  MirrorTagId := ASource.MirrorTagId;
  MirrorTagName := ASource.MirrorTagName;
  SampleRateHz := ASource.SampleRateHz;
  FramesPerBlock := ASource.FramesPerBlock;
  MinimumValue := ASource.MinimumValue;
  MaximumValue := ASource.MaximumValue;
  SafeValue := ASource.SafeValue;
  UnderrunPolicy := ASource.UnderrunPolicy;
  FrequencyHz := ASource.FrequencyHz;
  Amplitude := ASource.Amplitude;
  SweepStartHz := ASource.SweepStartHz;
  SweepEndHz := ASource.SweepEndHz;
  SweepTimeSec := ASource.SweepTimeSec;
end;

function TRecorderDacComponent.BuildConfig: TRecorderDacConfig;
begin
  Result.SampleRateHz := fSampleRateHz;
  Result.ChannelCount := 1;
  Result.FramesPerBlock := fFramesPerBlock;
  Result.MinimumValue := fMinimumValue;
  Result.MaximumValue := fMaximumValue;
  Result.SafeValue := fSafeValue;
  Result.UnderrunPolicy := fUnderrunPolicy;
end;

constructor TRecorderDacComponentFactory.Create;
var
  lRegistry: TRecorderDacBackendRegistry;
begin
  inherited Create(TRecorderDacComponent.TypeId, 'DAC output',
    TRecorderDacComponent, 458, 266, False);
  ConfigurePalette('ЦАП', 'Добавить управление ЦАП', 'digital-indicator',
    70, rppGroup, CRecorderPaletteGroupSignals);
  fRuntimes := TInterfaceList.Create;
  lRegistry := TRecorderDacBackendRegistry.Create;
  lRegistry.RegisterFactory(TRecorderAudioDacFactory.Create);
  lRegistry.RegisterFactory(TRecorderNullDacFactory.Create);
  fBackendRegistry := lRegistry;
end;

destructor TRecorderDacComponentFactory.Destroy;
begin
  DoStop;
  while ChildCount > 0 do ReleaseComponent(Children[0]);
  fRuntimes.Free;
  TObject(fBackendRegistry).Free;
  inherited Destroy;
end;

function TRecorderDacComponentFactory.CreateComponent: TRecorderVisualComponent;
var
  lRuntime: IRecorderDacComponentRuntime;
begin
  Result := inherited CreateComponent;
  try
    lRuntime := TRecorderDacRuntime.Create(TRecorderDacComponent(Result),
      TRecorderDacBackendRegistry(fBackendRegistry));
    fRuntimes.Add(lRuntime);
  except
    inherited ReleaseComponent(Result);
    raise;
  end;
end;

function TRecorderDacComponentFactory.RuntimeFor(
  AComponent: TRecorderVisualComponent): IRecorderDacComponentRuntime;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fRuntimes.Count - 1 do
    if (fRuntimes[I] as IRecorderDacComponentRuntime).Component = AComponent then
      Exit(fRuntimes[I] as IRecorderDacComponentRuntime);
end;

procedure TRecorderDacComponentFactory.ReleaseComponent(
  AComponent: TRecorderVisualComponent);
begin
  inherited ReleaseComponent(AComponent);
end;

procedure TRecorderDacComponentFactory.ExcludeComponent(
  AComponent: TRecorderVisualComponent);
var
  I: Integer;
  lRuntime: IRecorderDacComponentRuntime;
begin
  for I := fRuntimes.Count - 1 downto 0 do
  begin
    lRuntime := fRuntimes[I] as IRecorderDacComponentRuntime;
    if lRuntime.Component = AComponent then
    begin
      lRuntime.StopOutput;
      fRuntimes.Delete(I);
      Break;
    end;
  end;
  inherited ExcludeComponent(AComponent);
end;

procedure TRecorderDacComponentFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  inherited ConfigureNewComponent(AComponent, AContext);
  AComponent.Name := Format('ЦАП %d', [AContext.ComponentNo]);
end;

procedure TRecorderDacComponentFactory.SetTagRegistry(
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
begin
  for I := 0 to fRuntimes.Count - 1 do
    (fRuntimes[I] as IRecorderDacComponentRuntime).SetTagRegistry(ARegistry);
end;

procedure TRecorderDacComponentFactory.DoStart;
var
  I: Integer;
begin
  for I := 0 to fRuntimes.Count - 1 do
    (fRuntimes[I] as IRecorderDacComponentRuntime).StartOutput;
end;

procedure TRecorderDacComponentFactory.DoStop;
var
  I: Integer;
begin
  for I := 0 to fRuntimes.Count - 1 do
    (fRuntimes[I] as IRecorderDacComponentRuntime).StopOutput;
end;

function TRecorderDacComponentFactory.RuntimeSnapshot(
  AComponent: TRecorderVisualComponent): TRecorderDacRuntimeSnapshot;
var
  lRuntime: IRecorderDacComponentRuntime;
begin
  Result.Counters := Default(TRecorderDacCounters);
  Result.State := rdsClosed;
  Result.LastResult := RecorderDacOk;
  lRuntime := RuntimeFor(AComponent);
  if lRuntime <> nil then Result := lRuntime.Snapshot;
end;

function TRecorderDacComponentFactory.DiscoverEndpoints(
  out AEndpoints: TRecorderDacEndpoints;
  out AResult: TRecorderDacResult): Boolean;
var
  I, J, lOffset: Integer;
  lDiscovered: TRecorderDacEndpoints;
  lFactoryResult: TRecorderDacResult;
  lRegistry: TRecorderDacBackendRegistry;
begin
  SetLength(AEndpoints, 0);
  AResult := RecorderDacOk;
  lRegistry := TRecorderDacBackendRegistry(fBackendRegistry);
  for I := 0 to lRegistry.Count - 1 do
  begin
    if not lRegistry.Factories[I].DiscoverEndpoints(lDiscovered,
      lFactoryResult) then
    begin
      AResult := lFactoryResult;
      Continue;
    end;
    lOffset := Length(AEndpoints);
    SetLength(AEndpoints, lOffset + Length(lDiscovered));
    for J := 0 to High(lDiscovered) do
      AEndpoints[lOffset + J] := lDiscovered[J];
  end;
  Result := Length(AEndpoints) > 0;
  if Result and (AResult.Error <> rdeNone) then
    AResult := RecorderDacOk;
end;

procedure TRecorderDacComponentFactory.GetBackendIds(AItems: TStrings);
var
  I: Integer;
  lRegistry: TRecorderDacBackendRegistry;
begin
  if AItems = nil then Exit;
  AItems.Clear;
  lRegistry := TRecorderDacBackendRegistry(fBackendRegistry);
  for I := 0 to lRegistry.Count - 1 do
    AItems.Add(lRegistry.Factories[I].BackendId);
end;

procedure TRecorderDacComponentFactory.RegisterBackend(
  AFactory: TRecorderDacBackendFactory);
begin
  TRecorderDacBackendRegistry(fBackendRegistry).RegisterFactory(AFactory);
end;

procedure RegisterRecorderDacComponentFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and not AFactory.IsComponentRegistered(
    TRecorderDacComponent.TypeId) then
    AFactory.RegisterFactory(TRecorderDacComponentFactory.Create);
end;

end.
