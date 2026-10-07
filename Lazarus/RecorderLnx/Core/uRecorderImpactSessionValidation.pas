unit uRecorderImpactSessionValidation;

{ Trust-boundary validation and resource limits for imported/exported impact
  sessions. Adapters must validate before allocating domain-sized arrays. }

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, uRecorderImpactSessionContracts;

const
  RECORDER_IMPACT_SESSION_VERSION = 1;
  RECORDER_IMPACT_MAX_FILE_BYTES = 64 * 1024 * 1024;
  RECORDER_IMPACT_MAX_IMPACTS = 4096;
  RECORDER_IMPACT_MAX_RESPONSES = 256;
  RECORDER_IMPACT_MAX_CURVES = 256;
  RECORDER_IMPACT_MAX_BINS = 4 * 1024 * 1024;
  RECORDER_IMPACT_MAX_TOTAL_SAMPLES = 16 * 1024 * 1024;
  RECORDER_IMPACT_MAX_STRING_CHARS = 4096;

function ValidateImpactSession(const ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
function ValidImpactCount(AValue, AMaximum: Integer;
  const AName: string; out AError: string): Boolean;

implementation

function ValidImpactCount(AValue, AMaximum: Integer;
  const AName: string; out AError: string): Boolean;
begin
  Result := (AValue >= 0) and (AValue <= AMaximum);
  if not Result then
    AError := Format('%s exceeds supported limit (%d).', [AName, AMaximum]);
end;

function FiniteValue(AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

function ValidText(const AValue, AName: string; out AError: string): Boolean;
begin
  Result := Length(AValue) <= RECORDER_IMPACT_MAX_STRING_CHARS;
  if not Result then
    AError := AName + ' is too long.';
end;

function ValidateSeries(const ASeries: TRecorderImpactSessionSeries;
  var ATotalSamples: Int64; out AError: string): Boolean;
var
  I: Integer;
begin
  Result := ValidText(ASeries.Name, 'Series name', AError) and
    ValidText(ASeries.UnitName, 'Series unit', AError);
  if not Result then
    Exit;
  Inc(ATotalSamples, Length(ASeries.Samples));
  if ATotalSamples > RECORDER_IMPACT_MAX_TOTAL_SAMPLES then
  begin
    AError := 'Total sample count exceeds supported limit.';
    Exit(False);
  end;
  for I := 0 to High(ASeries.Samples) do
  begin
    if not FiniteValue(ASeries.Samples[I].TimeSeconds) or
      not FiniteValue(ASeries.Samples[I].Value) then
    begin
      AError := 'Series contains a non-finite sample.';
      Exit(False);
    end;
    if (I > 0) and (ASeries.Samples[I].TimeSeconds <=
      ASeries.Samples[I - 1].TimeSeconds) then
    begin
      AError := 'Series timestamps must be strictly increasing.';
      Exit(False);
    end;
  end;
end;

function ValidateImpactSession(const ASnapshot: TRecorderImpactSessionSnapshot;
  out AError: string): Boolean;
var
  TotalSamples: Int64;
  I, J, K: Integer;
begin
  AError := '';
  if ASnapshot.FormatVersion <> RECORDER_IMPACT_SESSION_VERSION then
  begin
    AError := 'Unsupported impact session schema version.';
    Exit(False);
  end;
  if not FiniteValue(ASnapshot.SampleRateHz) or
    (ASnapshot.SampleRateHz <= 0) then
  begin
    AError := 'Sample rate must be finite and positive.';
    Exit(False);
  end;
  if not ValidText(ASnapshot.SessionId, 'Session id', AError) or
    not ValidImpactCount(Length(ASnapshot.Impacts),
      RECORDER_IMPACT_MAX_IMPACTS, 'Impact count', AError) or
    not ValidImpactCount(Length(ASnapshot.Curves),
      RECORDER_IMPACT_MAX_CURVES, 'Curve count', AError) then
    Exit(False);
  TotalSamples := 0;
  for I := 0 to High(ASnapshot.Impacts) do
  begin
    if (ASnapshot.Impacts[I].Sequence = 0) or
      not FiniteValue(ASnapshot.Impacts[I].TriggerTimeSeconds) then
    begin
      AError := 'Impact identity and trigger time are invalid.';
      Exit(False);
    end;
    for J := 0 to I - 1 do
      if ASnapshot.Impacts[J].Sequence = ASnapshot.Impacts[I].Sequence then
      begin
        AError := 'Impact sequence ids must be unique.';
        Exit(False);
      end;
    if not ValidImpactCount(Length(ASnapshot.Impacts[I].Responses),
      RECORDER_IMPACT_MAX_RESPONSES, 'Response count', AError) or
      not ValidateSeries(ASnapshot.Impacts[I].Excitation,
        TotalSamples, AError) then
      Exit(False);
    for J := 0 to High(ASnapshot.Impacts[I].Responses) do
      if not ValidateSeries(ASnapshot.Impacts[I].Responses[J],
        TotalSamples, AError) then
        Exit(False);
  end;
  for I := 0 to High(ASnapshot.Curves) do
  begin
    if ASnapshot.Curves[I].CurveId = 0 then
    begin
      AError := 'Curve id must be nonzero.';
      Exit(False);
    end;
    for J := 0 to I - 1 do
      if ASnapshot.Curves[J].CurveId = ASnapshot.Curves[I].CurveId then
      begin
        AError := 'Curve ids must be unique.';
        Exit(False);
      end;
    if not ValidText(ASnapshot.Curves[I].Name, 'Curve name', AError) or
      not ValidText(ASnapshot.Curves[I].ExcitationUnitName,
        'Excitation unit', AError) or
      not ValidText(ASnapshot.Curves[I].ResponseUnitName,
        'Response unit', AError) or
      not ValidImpactCount(Length(ASnapshot.Curves[I].FrequencyHz),
        RECORDER_IMPACT_MAX_BINS, 'Frequency bin count', AError) then
      Exit(False);
    K := Length(ASnapshot.Curves[I].FrequencyHz);
    if (Length(ASnapshot.Curves[I].Magnitude) <> K) or
      (Length(ASnapshot.Curves[I].PhaseRadians) <> K) or
      (Length(ASnapshot.Curves[I].Coherence) <> K) or
      ((Length(ASnapshot.Curves[I].ExcitationSpectrum) <> 0) and
       (Length(ASnapshot.Curves[I].ExcitationSpectrum) <> K)) or
      ((Length(ASnapshot.Curves[I].ResponseSpectrum) <> 0) and
       (Length(ASnapshot.Curves[I].ResponseSpectrum) <> K)) then
    begin
      AError := 'Curve arrays have mismatched lengths.';
      Exit(False);
    end;
    for J := 0 to K - 1 do
    begin
      if not FiniteValue(ASnapshot.Curves[I].FrequencyHz[J]) or
        not FiniteValue(ASnapshot.Curves[I].Magnitude[J]) or
        not FiniteValue(ASnapshot.Curves[I].PhaseRadians[J]) or
        not FiniteValue(ASnapshot.Curves[I].Coherence[J]) or
        ((Length(ASnapshot.Curves[I].ExcitationSpectrum) > 0) and
         not FiniteValue(ASnapshot.Curves[I].ExcitationSpectrum[J])) or
        ((Length(ASnapshot.Curves[I].ResponseSpectrum) > 0) and
         not FiniteValue(ASnapshot.Curves[I].ResponseSpectrum[J])) or
        (ASnapshot.Curves[I].Coherence[J] < 0) or
        (ASnapshot.Curves[I].Coherence[J] > 1) or
        ((J > 0) and (ASnapshot.Curves[I].FrequencyHz[J] <=
          ASnapshot.Curves[I].FrequencyHz[J - 1])) then
      begin
        AError := 'Curve values, frequency order, or coherence are invalid.';
        Exit(False);
      end;
    end;
  end;
  Result := True;
end;

end.
