unit uRecorderFrfRepository;

{ Immutable multi-curve FRF snapshots and the synchronized publication point.
  Analysis builds a complete replacement snapshot; runtime consumers acquire
  one retained interface and never observe a partially published curve set. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, uRecorderFrfContracts;

type
  TRecorderFrfCurveData = record
    Id: QWord;
    FrequencyHz: array of Double;
    Magnitude: array of Double;
    PhaseRadians: array of Double;
    Coherence: array of Double;
  end;

  TRecorderFrfRepository = class(TInterfacedObject, IRecorderFrfProvider)
  private
    fLock: TRTLCriticalSection;
    fPublishLock: TRTLCriticalSection;
    fSnapshot: IRecorderFrfSampler;
    fVersion: QWord;
  public
    constructor Create;
    destructor Destroy; override;
    function Publish(const ACurves: array of TRecorderFrfCurveData): Boolean;
    procedure Clear;
    function AcquireSnapshot: IRecorderFrfSampler;
  end;

implementation

type
  TRecorderFrfSnapshot = class(TInterfacedObject, IRecorderFrfSampler)
  private
    fVersion: QWord;
    fCurves: array of TRecorderFrfCurveData;
    function FindCurve(AId: QWord): Integer;
  public
    constructor Create(AVersion: QWord;
      const ACurves: array of TRecorderFrfCurveData);
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function Version: QWord;
  end;

function Finite(AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

function ValidCurve(const ACurve: TRecorderFrfCurveData): Boolean;
var
  lIndex, lCount: Integer;
begin
  lCount := Length(ACurve.FrequencyHz);
  Result := (ACurve.Id <> 0) and (lCount > 0) and
    (Length(ACurve.Magnitude) = lCount) and
    (Length(ACurve.PhaseRadians) = lCount) and
    (Length(ACurve.Coherence) = lCount);
  if not Result then
    Exit;
  for lIndex := 0 to lCount - 1 do
  begin
    Result := Finite(ACurve.FrequencyHz[lIndex]) and
      Finite(ACurve.Magnitude[lIndex]) and
      Finite(ACurve.PhaseRadians[lIndex]) and
      Finite(ACurve.Coherence[lIndex]) and
      (ACurve.Magnitude[lIndex] >= 0) and
      (ACurve.Coherence[lIndex] >= 0) and
      (ACurve.Coherence[lIndex] <= 1) and
      ((lIndex = 0) or
       (ACurve.FrequencyHz[lIndex] > ACurve.FrequencyHz[lIndex - 1]));
    if not Result then
      Exit;
  end;
end;

constructor TRecorderFrfSnapshot.Create(AVersion: QWord;
  const ACurves: array of TRecorderFrfCurveData);
var
  lCurve: Integer;
begin
  inherited Create;
  fVersion := AVersion;
  SetLength(fCurves, Length(ACurves));
  for lCurve := 0 to High(ACurves) do
  begin
    fCurves[lCurve].Id := ACurves[lCurve].Id;
    fCurves[lCurve].FrequencyHz := Copy(ACurves[lCurve].FrequencyHz);
    fCurves[lCurve].Magnitude := Copy(ACurves[lCurve].Magnitude);
    fCurves[lCurve].PhaseRadians := Copy(ACurves[lCurve].PhaseRadians);
    fCurves[lCurve].Coherence := Copy(ACurves[lCurve].Coherence);
  end;
end;

function TRecorderFrfSnapshot.FindCurve(AId: QWord): Integer;
begin
  for Result := 0 to High(fCurves) do
    if fCurves[Result].Id = AId then
      Exit;
  Result := -1;
end;

function TRecorderFrfSnapshot.TrySample(ACurveId: QWord;
  AFrequencyHz: Double; out AMagnitude, APhaseRadians: Double): Boolean;
var
  lCurve, lLow, lHigh, lMiddle: Integer;
  lRatio, lPhaseDelta: Double;
begin
  Result := False;
  lCurve := FindCurve(ACurveId);
  if (lCurve < 0) or not Finite(AFrequencyHz) then
    Exit;
  lLow := 0;
  lHigh := High(fCurves[lCurve].FrequencyHz);
  if (AFrequencyHz < fCurves[lCurve].FrequencyHz[lLow]) or
    (AFrequencyHz > fCurves[lCurve].FrequencyHz[lHigh]) then
    Exit;
  while lLow < lHigh do
  begin
    lMiddle := (lLow + lHigh) div 2;
    if fCurves[lCurve].FrequencyHz[lMiddle] < AFrequencyHz then
      lLow := lMiddle + 1
    else
      lHigh := lMiddle;
  end;
  if fCurves[lCurve].FrequencyHz[lLow] = AFrequencyHz then
  begin
    AMagnitude := fCurves[lCurve].Magnitude[lLow];
    APhaseRadians := fCurves[lCurve].PhaseRadians[lLow];
    Exit(True);
  end;
  lHigh := lLow;
  Dec(lLow);
  lRatio := (AFrequencyHz - fCurves[lCurve].FrequencyHz[lLow]) /
    (fCurves[lCurve].FrequencyHz[lHigh] -
     fCurves[lCurve].FrequencyHz[lLow]);
  AMagnitude := fCurves[lCurve].Magnitude[lLow] + lRatio *
    (fCurves[lCurve].Magnitude[lHigh] - fCurves[lCurve].Magnitude[lLow]);
  lPhaseDelta := ArcTan2(
    Sin(fCurves[lCurve].PhaseRadians[lHigh] -
      fCurves[lCurve].PhaseRadians[lLow]),
    Cos(fCurves[lCurve].PhaseRadians[lHigh] -
      fCurves[lCurve].PhaseRadians[lLow]));
  APhaseRadians := fCurves[lCurve].PhaseRadians[lLow] +
    lRatio * lPhaseDelta;
  Result := True;
end;

function TRecorderFrfSnapshot.Version: QWord;
begin
  Result := fVersion;
end;

constructor TRecorderFrfRepository.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  InitCriticalSection(fPublishLock);
end;

destructor TRecorderFrfRepository.Destroy;
begin
  fSnapshot := nil;
  DoneCriticalSection(fPublishLock);
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderFrfRepository.Publish(
  const ACurves: array of TRecorderFrfCurveData): Boolean;
var
  lCurve, lOther: Integer;
  lCandidate: IRecorderFrfSampler;
  lVersion: QWord;
begin
  Result := Length(ACurves) > 0;
  for lCurve := 0 to High(ACurves) do
  begin
    Result := Result and ValidCurve(ACurves[lCurve]);
    for lOther := 0 to lCurve - 1 do
      Result := Result and (ACurves[lOther].Id <> ACurves[lCurve].Id);
  end;
  if not Result then
    Exit;
  { Build and validate the immutable payload before taking the publication
    lock. Readers then wait only for the pointer/version swap, not for a copy
    proportional to the number of curves and frequency bins. }
  EnterCriticalSection(fPublishLock);
  try
    lVersion := fVersion + 1;
    lCandidate := TRecorderFrfSnapshot.Create(lVersion, ACurves);
    EnterCriticalSection(fLock);
    try
      fVersion := lVersion;
      fSnapshot := lCandidate;
    finally
      LeaveCriticalSection(fLock);
    end;
  finally
    LeaveCriticalSection(fPublishLock);
  end;
  NotifyRecorderFrfProviderChanged(Self as IRecorderFrfProvider);
  Result := True;
end;

function TRecorderFrfRepository.AcquireSnapshot: IRecorderFrfSampler;
begin
  EnterCriticalSection(fLock);
  try
    Result := fSnapshot;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderFrfRepository.Clear;
begin
  EnterCriticalSection(fPublishLock);
  try
    EnterCriticalSection(fLock);
    try
      Inc(fVersion);
      fSnapshot := nil;
    finally
      LeaveCriticalSection(fLock);
    end;
  finally
    LeaveCriticalSection(fPublishLock);
  end;
  NotifyRecorderFrfProviderChanged(Self as IRecorderFrfProvider);
end;

end.
