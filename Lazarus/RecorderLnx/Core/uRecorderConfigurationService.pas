unit uRecorderConfigurationService;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

type
  TRecorderSourceProgrammingState = class
  private
    fSignatures: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const ASourceId, ASignature: string);
    function Signature(const ASourceId: string): string;
    property Signatures: TStringList read fSignatures;
  end;

  TRecorderConfigurationChangeSet = class
  public
    BeforeState: TRecorderSourceProgrammingState;
    AfterState: TRecorderSourceProgrammingState;
    SourcesChanged: Boolean;
    EnsureRuntimeSources: Boolean;
    PrepareAlgorithmRuntime: Boolean;
    SyncEnabledStates: Boolean;
    SingleSourceEdit: Boolean;
    BeforePrimarySourceId: string;
    AfterPrimarySourceId: string;
    constructor Create(ABeforeState, AAfterState: TRecorderSourceProgrammingState);
    destructor Destroy; override;
  end;

  TRecorderConfigurationResult = class
  private
    fMessages: TStringList;
    fChangedSourceIds: TStringList;
  public
    WasRunning: Boolean;
    Reconfigured: Boolean;
    ErrorMessage: string;
    constructor Create;
    destructor Destroy; override;
    property Messages: TStringList read fMessages;
    property ChangedSourceIds: TStringList read fChangedSourceIds;
  end;

  IRecorderConfigurationRuntime = interface
    procedure CaptureProgrammingState(AState: TRecorderSourceProgrammingState);
    function SourceProgrammingApplied(const ASourceId, ASignature: string): Boolean;
    function AcquisitionRunning: Boolean;
    procedure StopAcquisitionForConfiguration;
    procedure ReplaceRuntimeSource(const ASourceId: string);
    procedure EnsureRuntimeSources;
    procedure PrepareAlgorithms;
    procedure PrepareHardware;
    procedure StartAcquisitionAfterConfiguration;
    procedure SyncEnabledSourceStates;
  end;

  TRecorderConfigurationService = class
  private
    fRuntime: IRecorderConfigurationRuntime;
    procedure CollectChangedSources(AChanges: TRecorderConfigurationChangeSet;
      AResult: TRecorderConfigurationResult);
  public
    constructor Create(const ARuntime: IRecorderConfigurationRuntime);
    function CaptureState: TRecorderSourceProgrammingState;
    function Apply(AChanges: TRecorderConfigurationChangeSet): TRecorderConfigurationResult;
  end;

implementation

constructor TRecorderSourceProgrammingState.Create;
begin
  inherited Create;
  fSignatures := TStringList.Create;
  fSignatures.CaseSensitive := False;
end;

destructor TRecorderSourceProgrammingState.Destroy;
begin
  fSignatures.Free;
  inherited Destroy;
end;

procedure TRecorderSourceProgrammingState.Add(const ASourceId, ASignature: string);
begin
  if Trim(ASourceId) = '' then Exit;
  fSignatures.Values[ASourceId] := StringReplace(ASignature, LineEnding, #1,
    [rfReplaceAll]);
end;

function TRecorderSourceProgrammingState.Signature(const ASourceId: string): string;
begin
  Result := fSignatures.Values[ASourceId];
end;

constructor TRecorderConfigurationChangeSet.Create(ABeforeState,
  AAfterState: TRecorderSourceProgrammingState);
begin
  inherited Create;
  BeforeState := ABeforeState;
  AfterState := AAfterState;
end;

destructor TRecorderConfigurationChangeSet.Destroy;
begin
  AfterState.Free;
  BeforeState.Free;
  inherited Destroy;
end;

constructor TRecorderConfigurationResult.Create;
begin
  inherited Create;
  fMessages := TStringList.Create;
  fChangedSourceIds := TStringList.Create;
  fChangedSourceIds.CaseSensitive := False;
  fChangedSourceIds.Sorted := True;
  fChangedSourceIds.Duplicates := dupIgnore;
end;

destructor TRecorderConfigurationResult.Destroy;
begin
  fChangedSourceIds.Free;
  fMessages.Free;
  inherited Destroy;
end;

constructor TRecorderConfigurationService.Create(
  const ARuntime: IRecorderConfigurationRuntime);
begin
  inherited Create;
  if ARuntime = nil then
    raise EArgumentNilException.Create('Configuration runtime is required');
  fRuntime := ARuntime;
end;

function TRecorderConfigurationService.CaptureState:
  TRecorderSourceProgrammingState;
begin
  Result := TRecorderSourceProgrammingState.Create;
  try
    fRuntime.CaptureProgrammingState(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TRecorderConfigurationService.CollectChangedSources(
  AChanges: TRecorderConfigurationChangeSet; AResult: TRecorderConfigurationResult);
var
  I: Integer;
  lIds: TStringList;
  lSourceId: string;
  lSignature: string;
begin
  if AChanges.SingleSourceEdit then
  begin
    lSignature := AChanges.AfterState.Signature(AChanges.AfterPrimarySourceId);
    if AChanges.BeforeState.Signature(AChanges.BeforePrimarySourceId) =
      lSignature then
      Exit;
    if fRuntime.SourceProgrammingApplied(AChanges.AfterPrimarySourceId,
      lSignature) then
    begin
      AResult.Messages.Add('Source programming already applied: ' +
        AChanges.AfterPrimarySourceId);
      Exit;
    end;
    AResult.ChangedSourceIds.Add(AChanges.BeforePrimarySourceId);
    AResult.ChangedSourceIds.Add(AChanges.AfterPrimarySourceId);
    Exit;
  end;

  lIds := TStringList.Create;
  try
    lIds.CaseSensitive := False;
    lIds.Sorted := True;
    lIds.Duplicates := dupIgnore;
    for I := 0 to AChanges.BeforeState.Signatures.Count - 1 do
      lIds.Add(AChanges.BeforeState.Signatures.Names[I]);
    for I := 0 to AChanges.AfterState.Signatures.Count - 1 do
      lIds.Add(AChanges.AfterState.Signatures.Names[I]);
    for I := 0 to lIds.Count - 1 do
    begin
      lSourceId := lIds[I];
      lSignature := AChanges.AfterState.Signature(lSourceId);
      if AChanges.BeforeState.Signature(lSourceId) = lSignature then Continue;
      if fRuntime.SourceProgrammingApplied(lSourceId, lSignature) then
      begin
        AResult.Messages.Add('Source programming already applied: ' + lSourceId);
        Continue;
      end;
      AResult.ChangedSourceIds.Add(lSourceId);
    end;
  finally
    lIds.Free;
  end;
end;

function TRecorderConfigurationService.Apply(
  AChanges: TRecorderConfigurationChangeSet): TRecorderConfigurationResult;
var
  I: Integer;
begin
  Result := TRecorderConfigurationResult.Create;
  try
    if AChanges = nil then
      raise EArgumentNilException.Create('Configuration change set is required');
    if AChanges.SyncEnabledStates then
      fRuntime.SyncEnabledSourceStates;
    if not AChanges.SourcesChanged then
    begin
      Result.Messages.Add('Hardware configuration unchanged: initialized devices retained.');
      Exit;
    end;

    CollectChangedSources(AChanges, Result);
    Result.WasRunning := fRuntime.AcquisitionRunning;
    if (Result.ChangedSourceIds.Count > 0) and Result.WasRunning then
      fRuntime.StopAcquisitionForConfiguration;
    for I := 0 to Result.ChangedSourceIds.Count - 1 do
      fRuntime.ReplaceRuntimeSource(Result.ChangedSourceIds[I]);
    if AChanges.PrepareAlgorithmRuntime then
      fRuntime.PrepareAlgorithms;
    if Result.ChangedSourceIds.Count = 0 then
    begin
      Result.Messages.Add('Source programming skipped: hardware settings unchanged.');
      Exit;
    end;
    if AChanges.EnsureRuntimeSources then
      fRuntime.EnsureRuntimeSources;
    fRuntime.PrepareHardware;
    if Result.WasRunning then
      fRuntime.StartAcquisitionAfterConfiguration;
    Result.Reconfigured := True;
    Result.Messages.Add('Changed data sources hardware prepared.');
  except
    on E: Exception do
      Result.ErrorMessage := E.ClassName + ': ' + E.Message;
  end;
end;

end.
