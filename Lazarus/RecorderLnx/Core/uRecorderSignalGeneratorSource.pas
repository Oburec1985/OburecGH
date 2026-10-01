unit uRecorderSignalGeneratorSource;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, uRecorderDataSources, uRecorderTags,
  uRecorderSignalGeneratorModel;

type
  TRecorderSignalGeneratorSource = class(TRecorderDataSourceBase)
  private type
    TRuntimeSignal = class
    public
      Config: TRecorderGeneratedSignal;
      Tag: TRecorderTag;
      PhaseRad: Double;
      AppliedPhaseDeg: Double;
      ElapsedSec: Double;
      Times: array of Double;
      Values: array of Double;
      constructor Create(ASource: TRecorderGeneratedSignal);
      destructor Destroy; override;
    end;
  private
    fSignals: TObjectList;
    fComponent: TRecorderSignalGeneratorComponent;
    fConfigRevision: LongInt;
    fTimeSec: Double;
    function CurrentFrequency(ASignal: TRuntimeSignal): Double;
    function GenerateValue(ASignal: TRuntimeSignal): Double;
    procedure SyncRuntimeConfig;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId: string; AUpdateTimeMs: Cardinal;
      AComponent: TRecorderSignalGeneratorComponent);
    destructor Destroy; override;
    procedure Start; override;
  end;

implementation

uses Math;

constructor TRecorderSignalGeneratorSource.TRuntimeSignal.Create(
  ASource: TRecorderGeneratedSignal);
begin
  inherited Create;
  Config := TRecorderGeneratedSignal.Create;
  Config.Assign(ASource);
  AppliedPhaseDeg := Config.PhaseDeg;
end;

destructor TRecorderSignalGeneratorSource.TRuntimeSignal.Destroy;
begin
  Config.Free;
  inherited Destroy;
end;

constructor TRecorderSignalGeneratorSource.Create(const ASourceId: string;
  AUpdateTimeMs: Cardinal; AComponent: TRecorderSignalGeneratorComponent);
var
  I, lCount: Integer;
  lRuntimeSignal: TRuntimeSignal;
begin
  inherited Create(ASourceId, 'Signal generator', AUpdateTimeMs);
  fComponent := AComponent;
  fConfigRevision := -1;
  fSignals := TObjectList.Create(True);
  if AComponent <> nil then
    for I := 0 to AComponent.SignalCount - 1 do
    begin
      lRuntimeSignal := TRuntimeSignal.Create(AComponent.Signals[I]);
      lCount := Max(1, Round(lRuntimeSignal.Config.SampleRateHz *
        AUpdateTimeMs / 1000.0));
      SetLength(lRuntimeSignal.Times, lCount);
      SetLength(lRuntimeSignal.Values, lCount);
      fSignals.Add(lRuntimeSignal);
    end;
end;

procedure TRecorderSignalGeneratorSource.SyncRuntimeConfig;
var
  I: Integer;
  lPhaseDeltaDeg: Double;
  lSignal: TRuntimeSignal;
  lRevision: LongInt;
begin
  if fComponent = nil then Exit;
  lRevision := fComponent.Revision;
  if lRevision = fConfigRevision then Exit;
  for I := 0 to fSignals.Count - 1 do
    if I < fComponent.SignalCount then
    begin
      lSignal := TRuntimeSignal(fSignals[I]);
      lPhaseDeltaDeg := -lSignal.AppliedPhaseDeg;
      fComponent.SnapshotSignal(I, lSignal.Config);
      lPhaseDeltaDeg := lPhaseDeltaDeg + lSignal.Config.PhaseDeg;
      if lPhaseDeltaDeg <> 0.0 then
        lSignal.PhaseRad := lSignal.PhaseRad + DegToRad(lPhaseDeltaDeg);
      lSignal.AppliedPhaseDeg := lSignal.Config.PhaseDeg;
    end;
  fConfigRevision := lRevision;
end;

destructor TRecorderSignalGeneratorSource.Destroy;
begin
  fSignals.Free;
  inherited Destroy;
end;

procedure TRecorderSignalGeneratorSource.Start;
var
  I: Integer;
  lSignal: TRuntimeSignal;
begin
  fTimeSec := 0.0;
  for I := 0 to fSignals.Count - 1 do
  begin
    lSignal := TRuntimeSignal(fSignals[I]);
    lSignal.PhaseRad := DegToRad(lSignal.Config.PhaseDeg);
    lSignal.AppliedPhaseDeg := lSignal.Config.PhaseDeg;
    lSignal.ElapsedSec := 0.0;
  end;
  inherited Start;
end;

procedure TRecorderSignalGeneratorSource.DoCreateTags(
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lSignal: TRuntimeSignal;
begin
  for I := 0 to fSignals.Count - 1 do
  begin
    lSignal := TRuntimeSignal(fSignals[I]);
    lSignal.Tag := ARegistry.FindByName(lSignal.Config.Name);
    if lSignal.Tag = nil then
      lSignal.Tag := ARegistry.CreateTag(lSignal.Config.Name, 4096, True);
    lSignal.Tag.SourceId := SourceId;
    lSignal.Tag.Address := IntToStr(I + 1);
    lSignal.Tag.ModuleType := 'signal-generator';
    lSignal.Tag.Description := 'Generated signal';
    lSignal.Tag.IsVirtual := True;
    lSignal.Tag.UnitName := 'a.u.';
    lSignal.Tag.PollFrequencyHz := lSignal.Config.SampleRateHz;
  end;
end;

function TRecorderSignalGeneratorSource.CurrentFrequency(
  ASignal: TRuntimeSignal): Double;
var
  lFraction: Double;
begin
  Result := ASignal.Config.FrequencyHz;
  if not ASignal.Config.SweepEnabled or
    (ASignal.Config.SweepDurationSec <= 0) then Exit;
  lFraction := Frac(ASignal.ElapsedSec / ASignal.Config.SweepDurationSec);
  if ASignal.Config.SweepLogarithmic and
    (ASignal.Config.FrequencyHz > 0) and
    (ASignal.Config.SweepEndFrequencyHz > 0) then
    Result := ASignal.Config.FrequencyHz * Power(
      ASignal.Config.SweepEndFrequencyHz / ASignal.Config.FrequencyHz,
      lFraction)
  else
    Result := ASignal.Config.FrequencyHz +
      (ASignal.Config.SweepEndFrequencyHz - ASignal.Config.FrequencyHz) *
      lFraction;
end;

function TRecorderSignalGeneratorSource.GenerateValue(
  ASignal: TRuntimeSignal): Double;
var
  lNormalizedPhase: Double;
begin
  lNormalizedPhase := ASignal.PhaseRad / (2.0 * Pi);
  lNormalizedPhase := lNormalizedPhase - Floor(lNormalizedPhase);
  case ASignal.Config.Kind of
    rgskSine:
      Result := Sin(ASignal.PhaseRad);
    rgskSaw:
      Result := lNormalizedPhase;
    rgskNoise:
      Result := Random;
  end;
  Result := ASignal.Config.Offset + ASignal.Config.Amplitude * Result;
end;

procedure TRecorderSignalGeneratorSource.DoTick;
var
  I, J, lCount: Integer;
  lDt, lFrequency: Double;
  lSignal: TRuntimeSignal;
begin
  SyncRuntimeConfig;
  if (fComponent <> nil) and not fComponent.Enabled then Exit;
  for I := 0 to fSignals.Count - 1 do
  begin
    lSignal := TRuntimeSignal(fSignals[I]);
    if not lSignal.Config.Enabled or (lSignal.Tag = nil) or
      (lSignal.Config.SampleRateHz <= 0) then Continue;
    lCount := Min(Length(lSignal.Values), Max(1,
      Round(lSignal.Config.SampleRateHz * UpdateTimeMs / 1000.0)));
    lDt := 1.0 / lSignal.Config.SampleRateHz;
    for J := 0 to lCount - 1 do
    begin
      lSignal.Times[J] := fTimeSec + J * lDt;
      lSignal.Values[J] := GenerateValue(lSignal);
      lFrequency := CurrentFrequency(lSignal);
      lSignal.PhaseRad := lSignal.PhaseRad + 2.0 * Pi * lFrequency * lDt;
      if lSignal.Config.ChangePhase then
        lSignal.PhaseRad := lSignal.PhaseRad + DegToRad(
          lSignal.Config.PhaseVelocityDegSec) * lDt;
      if lSignal.PhaseRad >= 2.0 * Pi then
        lSignal.PhaseRad := lSignal.PhaseRad -
          Floor(lSignal.PhaseRad / (2.0 * Pi)) * 2.0 * Pi;
      lSignal.ElapsedSec := lSignal.ElapsedSec + lDt;
    end;
    Registry.PublishBlock(lSignal.Tag.Name, lSignal.Times, lSignal.Values,
      lCount, True);
  end;
  fTimeSec := fTimeSec + UpdateTimeMs / 1000.0;
end;

end.
