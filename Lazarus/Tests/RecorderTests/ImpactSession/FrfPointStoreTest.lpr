program FrfPointStoreTest;

{$mode objfpc}{$H+}

uses SysUtils, uRecorderFrfPointStore, uRecorderImpactSessionContracts;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

var
  lSource, lLoaded: TRecorderImpactSessionSnapshot;
  lDirectory, lError: string;
  lIdentity: TGuid;
begin
  CreateGUID(lIdentity);
  lDirectory := IncludeTrailingPathDelimiter(GetTempDir) +
    'frf-point-test-' + GUIDToString(lIdentity);
  lSource := Default(TRecorderImpactSessionSnapshot);
  lSource.FormatVersion := 1;
  lSource.SampleRateHz := 1024;
  lSource.SessionId := 'point';
  SetLength(lSource.Impacts, 1);
  lSource.Impacts[0].Sequence := 1;
  lSource.Impacts[0].TriggerTimeSeconds := 10;
  SetLength(lSource.Impacts[0].Excitation.Samples, 2);
  lSource.Impacts[0].Excitation.Samples[0].TimeSeconds := 9.5;
  lSource.Impacts[0].Excitation.Samples[1].TimeSeconds := 10;
  lSource.Impacts[0].Excitation.Samples[1].Value := 4;
  SetLength(lSource.Curves, 1);
  lSource.Curves[0].CurveId := 12;
  lSource.Curves[0].FrequencyHz := [1.0, 2.0];
  lSource.Curves[0].Magnitude := [3.0, 4.0];
  lSource.Curves[0].PhaseRadians := [0.1, 0.2];
  lSource.Curves[0].Coherence := [0.9, 0.8];
  lSource.Curves[0].ExcitationSpectrum := [8.0, 9.0];
  lSource.Curves[0].ResponseSpectrum := [10.0, 11.0];
  try
    Check(not TRecorderFrfPointStore.Exists(lDirectory), 'initial existence');
    Check(TRecorderFrfPointStore.Save(lDirectory, lSource, lError), lError);
    Check(TRecorderFrfPointStore.Exists(lDirectory), 'saved existence');
    Check(TRecorderFrfPointStore.Load(lDirectory, lLoaded, lError), lError);
    Check(lLoaded.Impacts[0].Excitation.Samples[0].TimeSeconds = 9.5,
      'absolute time realization preserved');
    Check(lLoaded.Curves[0].ResponseSpectrum[1] = 11, 'spectrum preserved');
    lSource.SessionId := 'replacement';
    Check(TRecorderFrfPointStore.Save(lDirectory, lSource, lError), lError);
    lSource.SampleRateHz := 0;
    Check(not TRecorderFrfPointStore.Save(lDirectory, lSource, lError),
      'invalid snapshot must fail');
    Check(TRecorderFrfPointStore.Load(lDirectory, lLoaded, lError), lError);
    Check(lLoaded.SessionId = 'replacement', 'failed save preserves prior data');
  finally
    DeleteFile(TRecorderFrfPointStore.SessionFileName(lDirectory));
    RemoveDir(lDirectory);
  end;
  Check(not TRecorderFrfPointStore.Load(lDirectory, lLoaded, lError),
    'missing realization must fail');
  Check(Length(lLoaded.Curves) = 0, 'failed load returns empty snapshot');
  WriteLn('FrfPointStoreTest passed');
end.
