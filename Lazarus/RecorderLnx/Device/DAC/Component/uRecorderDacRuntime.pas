unit uRecorderDacRuntime;

{ Runtime owner for one DAC component. Tag lookup, validation and allocation
  happen only while configuring; the runner hot loop uses direct references. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderFormModel, uRecorderTags, uRecorderDacTypes,
  uRecorderDacBackendRegistry, uRecorderDacComponentModel;

type
  TRecorderDacRuntime = class(TInterfacedObject, IRecorderDacComponentRuntime)
  private
    fComponent: TRecorderDacComponent;
    fBackends: TRecorderDacBackendRegistry;
    fRegistry: TRecorderTagRegistry;
    fSession: TObject;
    fRunner: TObject;
    fConfiguredRevision: LongInt;
    fRestartPending: Boolean;
    fLastResult: TRecorderDacResult;
    fLock: TRTLCriticalSection;
    function ResolveTag(ATagId: TRecorderTagId;
      const ATagName: string): TRecorderTag;
    function ConfigureSession: Boolean;
    procedure ReleaseSession;
    procedure StoreResult(const AResult: TRecorderDacResult);
  public
    constructor Create(AComponent: TRecorderDacComponent;
      ABackends: TRecorderDacBackendRegistry);
    destructor Destroy; override;
    function Component: TRecorderVisualComponent;
    procedure SetTagRegistry(ARegistry: TRecorderTagRegistry);
    procedure StartOutput;
    procedure StopOutput;
    function Snapshot: TRecorderDacRuntimeSnapshot;
  end;

implementation

uses
  uRecorderDacContracts, uRecorderDacProviders,
  uRecorderDacTagMirror, uRecorderDacSession, uRecorderDacRunner;

constructor TRecorderDacRuntime.Create(AComponent: TRecorderDacComponent;
  ABackends: TRecorderDacBackendRegistry);
begin
  inherited Create;
  fComponent := AComponent;
  fBackends := ABackends;
  fLastResult := RecorderDacOk;
  InitCriticalSection(fLock);
end;

destructor TRecorderDacRuntime.Destroy;
begin
  StopOutput;
  ReleaseSession;
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderDacRuntime.Component: TRecorderVisualComponent;
begin
  Result := fComponent;
end;

procedure TRecorderDacRuntime.SetTagRegistry(ARegistry: TRecorderTagRegistry);
begin
  if fRegistry = ARegistry then Exit;
  StopOutput;
  ReleaseSession;
  fRegistry := ARegistry;
end;

procedure TRecorderDacRuntime.StoreResult(const AResult: TRecorderDacResult);
begin
  EnterCriticalSection(fLock);
  try
    fLastResult := AResult;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacRuntime.ResolveTag(ATagId: TRecorderTagId;
  const ATagName: string): TRecorderTag;
begin
  Result := nil;
  if fRegistry = nil then Exit;
  if ATagId <> 0 then Result := fRegistry.FindById(ATagId);
  if (Result = nil) and (ATagName <> '') then
    Result := fRegistry.FindByName(ATagName);
end;

function TRecorderDacRuntime.ConfigureSession: Boolean;
var
  lBackendFactory: TRecorderDacBackendFactory;
  lBackend: IRecorderDacBackend;
  lProvider: IRecorderDacSampleProvider;
  lMirror: IRecorderDacMirror;
  lInputTag, lMirrorTag: TRecorderTag;
  lSession: TRecorderDacSession;
begin
  Result := False;
  if (fRegistry = nil) and ((fComponent.SourceMode = rdsmTag) or
    fComponent.MirrorEnabled) then
  begin
    StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC tag registry is not available'));
    Exit;
  end;
  lBackendFactory := fBackends.FindFactory(fComponent.BackendId);
  if lBackendFactory = nil then
  begin
    StoreResult(RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      'Unknown DAC backend: ' + fComponent.BackendId));
    Exit;
  end;
  lInputTag := nil;
  if fComponent.SourceMode = rdsmTag then
    lInputTag := ResolveTag(fComponent.InputTagId, fComponent.InputTagName);
  if (fComponent.SourceMode = rdsmTag) and (lInputTag = nil) then
  begin
    StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC input tag is not found'));
    Exit;
  end;
  lMirror := nil;
  if fComponent.MirrorEnabled then
  begin
    lMirrorTag := ResolveTag(fComponent.MirrorTagId, fComponent.MirrorTagName);
    if lMirrorTag = nil then
    begin
      StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'DAC mirror tag is not found'));
      Exit;
    end;
    if lInputTag <> nil then
      lMirror := TRecorderDacTagMirror.Create(fRegistry, lMirrorTag,
        lInputTag.Name)
    else
      lMirror := TRecorderDacTagMirror.Create(fRegistry, lMirrorTag,
        fComponent.Name);
  end;
  lBackend := lBackendFactory.CreateBackend(fComponent.Endpoint);
  case fComponent.SourceMode of
    rdsmSine:
      lProvider := TRecorderDacWaveProvider.Create(rdwmSine,
        fComponent.FrequencyHz, fComponent.Amplitude,
        fComponent.SweepStartHz, fComponent.SweepEndHz,
        fComponent.SweepTimeSec);
    rdsmAccurateSine:
      lProvider := TRecorderDacWaveProvider.Create(rdwmAccurateSine,
        fComponent.FrequencyHz, fComponent.Amplitude,
        fComponent.SweepStartHz, fComponent.SweepEndHz,
        fComponent.SweepTimeSec);
    rdsmSweepSine:
      lProvider := TRecorderDacWaveProvider.Create(rdwmSweepSine,
        fComponent.FrequencyHz, fComponent.Amplitude,
        fComponent.SweepStartHz, fComponent.SweepEndHz,
        fComponent.SweepTimeSec);
  else
    lProvider := TRecorderDacTagProvider.Create(lInputTag);
  end;
  lSession := TRecorderDacSession.Create(lBackend, lProvider, lMirror);
  fSession := lSession;
  fConfiguredRevision := fComponent.Revision;
  StoreResult(RecorderDacOk);
  Result := True;
end;

procedure TRecorderDacRuntime.ReleaseSession;
var
  lResult: TRecorderDacResult;
begin
  if fRunner <> nil then
  begin
    TRecorderDacRunner(fRunner).RequestStop;
    TRecorderDacRunner(fRunner).WaitFor;
    StoreResult(TRecorderDacRunner(fRunner).LastResult);
    FreeAndNil(fRunner);
  end;
  if fSession = nil then Exit;
  TRecorderDacSession(fSession).Disconnect(lResult);
  StoreResult(lResult);
  FreeAndNil(fSession);
  fConfiguredRevision := 0;
end;

procedure TRecorderDacRuntime.StartOutput;
var
  lRunner: TRecorderDacRunner;
begin
  if (fRunner <> nil) and TRecorderDacRunner(fRunner).Finished then
  begin
    StoreResult(TRecorderDacRunner(fRunner).LastResult);
    FreeAndNil(fRunner);
  end;
  if (fComponent = nil) or not fComponent.Enabled then Exit;
  if fRunner <> nil then
  begin
    fRestartPending := True;
    Exit;
  end;
  fRestartPending := False;
  if (fSession <> nil) and
    (fConfiguredRevision <> fComponent.Revision) then
    ReleaseSession;
  if (fSession = nil) and not ConfigureSession then Exit;
  lRunner := TRecorderDacRunner.Create(TRecorderDacSession(fSession),
    fComponent.BuildConfig);
  fRunner := lRunner;
  lRunner.StartRun;
end;

procedure TRecorderDacRuntime.StopOutput;
var
  lRunner: TRecorderDacRunner;
begin
  fRestartPending := False;
  if fRunner = nil then Exit;
  lRunner := TRecorderDacRunner(fRunner);
  lRunner.RequestStop;
  { Abort is immediate; joining/freeing is deferred until the runner has
    actually finished, so a driver stop cannot freeze the GUI transition. }
  if lRunner.Finished then
  begin
    StoreResult(lRunner.LastResult);
    FreeAndNil(fRunner);
  end;
end;

function TRecorderDacRuntime.Snapshot: TRecorderDacRuntimeSnapshot;
var
  lRestart: Boolean;
begin
  if (fRunner <> nil) and TRecorderDacRunner(fRunner).Finished then
  begin
    StoreResult(TRecorderDacRunner(fRunner).LastResult);
    FreeAndNil(fRunner);
    lRestart := fRestartPending;
    fRestartPending := False;
    if lRestart then StartOutput;
  end;
  Result.Counters := Default(TRecorderDacCounters);
  Result.State := rdsClosed;
  if fSession <> nil then
  begin
    Result.State := TRecorderDacSession(fSession).State;
    Result.Counters := TRecorderDacSession(fSession).Counters;
  end;
  EnterCriticalSection(fLock);
  try
    Result.LastResult := fLastResult;
  finally
    LeaveCriticalSection(fLock);
  end;
  if fRunner <> nil then
    Result.LastResult := TRecorderDacRunner(fRunner).LastResult;
end;

end.
