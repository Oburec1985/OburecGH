unit uRecorderMic140LegacyTiming;

{
  Legacy MIC-140 scan timing: frequency table, SPORT period math, and derived
  TRecorderMic140Timing for device programming.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderMic140StreamTypes;

const
  CMic140FrequencyCount = 8;
  CMic140LegacyMaxUiReadFrequencyHz = 1000.0;
  CMic140LegacyFreqClkHz = 16000000.0;
  CMic140LegacyTimerPeriod = 640;
  CMic140LegacySportSclkDivProgr = 4;
  CMic140LegacyPeriodProgrammingChanCode =
    (CMic140LegacySportSclkDivProgr + 1) * 2 * (16 * 2 + (16 + 3));
  CMic140LegacyPeriodAdSec = 5.0E-6;
  CMic140LegacyInitPeriodDecaySec = 57.0E-6;
  CMic140LegacyPeriodSumChanCode = 58;
  CMic140LegacyPeriodWriteChanCode = 115;
  CMic140LegacyPeriodTimerOsc = 62;
  CMic140LegacyDeltaSport = 11;
  CMic140LegacyPeriod1ChanCode = 30;
  CMic140LegacyPeriod21ChanCode = 21;
  CMic140LegacyPeriod2ChanCode = 27;
  CMic140LegacyPeriod3ChanCode = 59;
  CMic140LegacyPeriod4ChanCode = 120;
  CMic140LegacyPeriodTimerWork = 80 + 32;
  CMic140LegacyMinCountAver = 1;
  CMic140LegacyMaxCountAver = 32767;

function RecorderMic140FrequencyCount: Integer;
function RecorderMic140Frequency(AIndex: Integer): Double;
function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;
function Mic140LegacyTimingForFrequency(AFrequencyHz: Double;
  AChannelCount: Integer): TRecorderMic140Timing;
function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;

function Mic140LegacyPeriodDecayToSport(APeriodSec: Double): Word;
function Mic140LegacyPeriodAverageToSport(APeriodSec: Double): Word;
function Mic140LegacySportToPeriodDecay(ACount: Word): Double;
function Mic140LegacySportToPeriodAverage(ACount: Word): Double;
function Mic140LegacyCheckPeriodDecay(ACountChans: Word; APeriodSec,
  APeriodDecaySec, APeriodAverSec: Double; ACountAver: Word;
  AGroundEnabled: Boolean): Double;
function Mic140LegacyCheckCountAver(ACountChans: Word; APeriodSec,
  APeriodDecaySec, APeriodAverSec: Double; ACountAver: Word;
  AGroundEnabled: Boolean): Word;

implementation

const
  CMic140Frequencies: array[0..CMic140FrequencyCount - 1] of Double =
    (1.0, 2.0, 5.0, 10.0, 20.0, 25.0, 50.0, 100.0);

function RecorderMic140FrequencyCount: Integer;
begin
  Result := CMic140FrequencyCount;
end;

function RecorderMic140Frequency(AIndex: Integer): Double;
begin
  if (AIndex < 0) or (AIndex >= CMic140FrequencyCount) then
    raise Exception.CreateFmt('MIC-140 frequency index is invalid: %d', [AIndex]);
  Result := CMic140Frequencies[AIndex];
end;

function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;
var
  I: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  if AFrequencyHz <= 0 then
    Exit(MIC140DefaultPollFrequencyHz);
  if AFrequencyHz > CMic140LegacyMaxUiReadFrequencyHz then
    Exit(CMic140LegacyMaxUiReadFrequencyHz);
  Result := MIC140DefaultPollFrequencyHz;
  lBestDelta := MaxDouble;
  for I := 0 to High(CMic140Frequencies) do
  begin
    lDelta := Abs(CMic140Frequencies[I] - AFrequencyHz);
    if lDelta < lBestDelta then
    begin
      lBestDelta := lDelta;
      Result := CMic140Frequencies[I];
    end;
  end;
end;

function Mic140LegacyPeriodToSport(APeriodSec: Double): LongWord;
begin
  Result := LongWord(Trunc(APeriodSec * CMic140LegacyFreqClkHz + 1.0E-9)) and $00FFFFFF;
end;

function Mic140LegacySportToPeriod(ACount: LongWord): Double;
begin
  Result := (ACount and $00FFFFFF) / CMic140LegacyFreqClkHz;
end;

function Mic140LegacyCodeToPeriod(ACount: Double): Double;
begin
  Result := ACount / (2.0 * CMic140LegacyFreqClkHz);
end;

function Mic140LegacyMinProgrammingPeriod: Double;
begin
  Result := CMic140LegacyPeriodProgrammingChanCode /
    (2.0 * CMic140LegacyFreqClkHz);
end;

function Mic140LegacyMinGroundPeriod: Double;
var
  lPeriod: Double;
begin
  lPeriod := Mic140LegacyCodeToPeriod(CMic140LegacyPeriod4ChanCode) +
    Mic140LegacyMinProgrammingPeriod;
  if lPeriod < CMic140LegacyPeriodAdSec then
    lPeriod := CMic140LegacyPeriodAdSec;
  Result := Mic140LegacySportToPeriod(Mic140LegacyPeriodToSport(lPeriod));
end;

function Mic140LegacyPeriodDecayToSport(APeriodSec: Double): Word;
var
  lPeriod: Double;
begin
  lPeriod := APeriodSec -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod3ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport) -
    Mic140LegacyMinProgrammingPeriod;
  if lPeriod < 0.0 then
    lPeriod := 0.0;
  Result := Word(Mic140LegacyPeriodToSport(lPeriod) and $FFFF);
end;

function Mic140LegacySportToPeriodDecay(ACount: Word): Double;
begin
  Result := Mic140LegacySportToPeriod(ACount) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod3ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport) +
    Mic140LegacyMinProgrammingPeriod;
end;

function Mic140LegacyPeriodAverageToSport(APeriodSec: Double): Word;
var
  lPeriod: Double;
begin
  lPeriod := APeriodSec -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod21ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport);
  if lPeriod < 0.0 then
    lPeriod := 0.0;
  Result := Word(Mic140LegacyPeriodToSport(lPeriod) and $FFFF);
end;

function Mic140LegacySportToPeriodAverage(ACount: Word): Double;
begin
  Result := Mic140LegacySportToPeriod(ACount) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod21ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport);
end;

function Mic140LegacyCalcPeriodDecay(ACountChans: Word; APeriodSec,
  APeriodAverSec: Double; ACountAver: Word; AGroundEnabled: Boolean): Double;
var
  lPeriodProc: Double;
  lPeriods: Double;
  lTimerFactor: Double;
  lGroundPeriod: Double;
begin
  lTimerFactor := 1.0 + (2.0 * CMic140LegacyFreqClkHz /
    CMic140LegacyTimerPeriod) *
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriodTimerWork);
  lPeriods := APeriodSec / lTimerFactor;
  APeriodAverSec := Mic140LegacySportToPeriodAverage(
    Mic140LegacyPeriodAverageToSport(APeriodAverSec));
  lPeriodProc := Mic140LegacyCodeToPeriod(CMic140LegacyPeriod2ChanCode);
  if AGroundEnabled then
  begin
    lGroundPeriod := Mic140LegacySportToPeriodDecay(
      Mic140LegacyPeriodDecayToSport(Mic140LegacyMinGroundPeriod));
    Result := (lPeriods - (ACountChans div 2) * lGroundPeriod) /
      (ACountChans div 2) - (lPeriodProc + (ACountAver - 1) * APeriodAverSec);
  end
  else
    Result := lPeriods / ACountChans -
      (lPeriodProc + (ACountAver - 1) * APeriodAverSec);
end;

function Mic140LegacyCalcCountAver(ACountChans: Word; APeriodSec,
  APeriodDecaySec, APeriodAverSec: Double; AGroundEnabled: Boolean): Word;
var
  lCount: LongInt;
  lPeriodProc: Double;
  lPeriods: Double;
  lTimerFactor: Double;
  lGroundPeriod: Double;
begin
  lTimerFactor := 1.0 + (2.0 * CMic140LegacyFreqClkHz /
    CMic140LegacyTimerPeriod) *
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriodTimerWork);
  lPeriods := APeriodSec / lTimerFactor;
  APeriodDecaySec := Mic140LegacySportToPeriodDecay(
    Mic140LegacyPeriodDecayToSport(APeriodDecaySec));
  APeriodAverSec := Mic140LegacySportToPeriodAverage(
    Mic140LegacyPeriodAverageToSport(APeriodAverSec));
  lPeriodProc := Mic140LegacyCodeToPeriod(CMic140LegacyPeriod2ChanCode);
  if AGroundEnabled then
  begin
    lGroundPeriod := Mic140LegacySportToPeriodDecay(
      Mic140LegacyPeriodDecayToSport(Mic140LegacyMinGroundPeriod));
    lCount := Trunc(((lPeriods - (ACountChans div 2) * lGroundPeriod) /
      (ACountChans div 2) - (lPeriodProc + APeriodDecaySec)) /
      APeriodAverSec + 1.0);
  end
  else
    lCount := Trunc((lPeriods / ACountChans -
      (lPeriodProc + APeriodDecaySec)) / APeriodAverSec + 1.0);
  if lCount < CMic140LegacyMinCountAver then
    lCount := CMic140LegacyMinCountAver;
  if lCount > CMic140LegacyMaxCountAver then
    lCount := CMic140LegacyMaxCountAver;
  Result := Word(lCount);
end;

function Mic140LegacyCheckPeriodDecay(ACountChans: Word; APeriodSec,
  APeriodDecaySec, APeriodAverSec: Double; ACountAver: Word;
  AGroundEnabled: Boolean): Double;
var
  lMaxDecay: Double;
  lMinDelay: Double;
begin
  lMaxDecay := Mic140LegacyCalcPeriodDecay(ACountChans, APeriodSec,
    APeriodAverSec, ACountAver, AGroundEnabled);
  lMinDelay := Mic140LegacyMinGroundPeriod;
  Result := APeriodDecaySec;
  if lMaxDecay < Result then
    Result := lMaxDecay;
  if Result < lMinDelay then
    Result := lMinDelay;
  Result := Mic140LegacySportToPeriod(Mic140LegacyPeriodToSport(Result));
end;

function Mic140LegacyCheckCountAver(ACountChans: Word; APeriodSec,
  APeriodDecaySec, APeriodAverSec: Double; ACountAver: Word;
  AGroundEnabled: Boolean): Word;
var
  lMaxCount: LongInt;
begin
  Result := ACountAver;
  lMaxCount := Mic140LegacyCalcCountAver(ACountChans, APeriodSec,
    APeriodDecaySec, APeriodAverSec, AGroundEnabled);
  if lMaxCount < Result then
    Result := Word(lMaxCount);
  if Result < CMic140LegacyMinCountAver then
    Result := CMic140LegacyMinCountAver;
end;

function Mic140LegacyTimingForFrequency(AFrequencyHz: Double;
  AChannelCount: Integer): TRecorderMic140Timing;
var
  lCountChans: Word;
  lPeriodDecaySec: Double;
begin
  Result.FrequencyHz := RecorderMic140NormalizeFrequency(AFrequencyHz);
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  lCountChans := Word(AChannelCount * 2);
  lPeriodDecaySec := CMic140LegacyInitPeriodDecaySec;
  lPeriodDecaySec := Mic140LegacyCheckPeriodDecay(lCountChans,
    1.0 / Result.FrequencyHz, lPeriodDecaySec, CMic140LegacyPeriodAdSec, 1, True);
  Result.AveragePeriodUs := CMic140LegacyPeriodAdSec * 1000000.0;
  Result.AverageSampleCount := Mic140LegacyCheckCountAver(lCountChans,
    1.0 / Result.FrequencyHz, lPeriodDecaySec, CMic140LegacyPeriodAdSec,
    CMic140LegacyMaxCountAver, True);
  if (Result.FrequencyHz <= 10.0) and (Result.AverageSampleCount > 4) then
    Result.AverageSampleCount := 4;
  Result.ChannelCommutationUs := lPeriodDecaySec * 1000000.0;
  Result.GroundCommutationUs := Mic140LegacySportToPeriodDecay(
    Mic140LegacyPeriodDecayToSport(Mic140LegacyMinGroundPeriod)) * 1000000.0;
  Result.LegacyChannelDelaySport := Mic140LegacyPeriodDecayToSport(
    lPeriodDecaySec);
  Result.LegacyGroundDelaySport := Mic140LegacyPeriodDecayToSport(
    Mic140LegacyMinGroundPeriod);
  Result.LegacyAverageDelaySport := Mic140LegacyPeriodAverageToSport(
    CMic140LegacyPeriodAdSec);
  Result.AveragePower := 7;
  if Result.FrequencyHz >= 10000.0 then
    Result.AveragePower := 0
  else if Result.FrequencyHz >= 400.0 then
    Result.AveragePower := 4
  else if Result.FrequencyHz >= 250.0 then
    Result.AveragePower := 5
  else if Result.FrequencyHz >= 150.0 then
    Result.AveragePower := 6;
end;

function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;
begin
  Result := Mic140LegacyTimingForFrequency(AFrequencyHz,
    MIC140DefaultChannelCount);
end;

end.
