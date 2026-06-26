unit uRecorderMic140AcquireTiming;

{
  Интервалы ожидания потоков MIC-140 (наследник общего TRecorderAcquireTimingBase).
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderAcquirePhase,
  uRecorderMic140StreamTypes;

const
  CMic140ScanReadTimeoutExtraMs = 100;

type
  TRecorderMic140AcquireTiming = class(TRecorderAcquireTimingBase)
  public
    procedure Apply(APollFrequencyHz: Double; AUpdatePeriodMs: Cardinal);
    function ReadTimeoutMs: Cardinal; override;
    function MainScanReadTimeoutMs: Cardinal;
  end;

implementation

uses
  uRecorderMic140LegacyTiming;

procedure TRecorderMic140AcquireTiming.Apply(APollFrequencyHz: Double;
  AUpdatePeriodMs: Cardinal);
begin
  fPollFrequencyHz := APollFrequencyHz;
  fUpdatePeriodMs := AUpdatePeriodMs;
end;

function TRecorderMic140AcquireTiming.ReadTimeoutMs: Cardinal;
var
  lBlockPeriodMs: Cardinal;
  lFreq: Double;
begin
  lFreq := RecorderMic140NormalizeFrequency(fPollFrequencyHz);
  if lFreq > 0.1 then
    lBlockPeriodMs := Cardinal(Ceil(1500.0 / lFreq))
  else
    lBlockPeriodMs := NormalizedUpdatePeriodMs;
  if lBlockPeriodMs < 100 then
    lBlockPeriodMs := 100;
  Result := lBlockPeriodMs + 50;
end;

function TRecorderMic140AcquireTiming.MainScanReadTimeoutMs: Cardinal;
var
  lBlockPeriodMs: Cardinal;
  lFreq: Double;
  lUpdate: Cardinal;
begin
  lUpdate := NormalizedUpdatePeriodMs;
  if lUpdate = 0 then
    Exit(1);
  lFreq := RecorderMic140NormalizeFrequency(fPollFrequencyHz);
  if lFreq > 0.1 then
    lBlockPeriodMs := Cardinal(Ceil(5.0 / lFreq * 1000.0))
  else
    lBlockPeriodMs := 500;
  if lBlockPeriodMs < 250 then
    lBlockPeriodMs := 250;
  Result := Max(lUpdate + CMic140ScanReadTimeoutExtraMs, lBlockPeriodMs);
end;

end.
