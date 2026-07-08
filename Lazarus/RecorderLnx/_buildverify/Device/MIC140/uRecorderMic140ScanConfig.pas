unit uRecorderMic140ScanConfig;

{
  Runtime scan configuration for MIC-140. All thread pacing and read timeouts
  are derived here from poll frequency and UI update interval.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uRecorderMic140StreamTypes;

const
  CMic140ScanReadTimeoutExtraMs = 100;
  CMic140LegacyReadTimeoutWarnAfter = 3;
  CMic140LegacyReadStallRestartAfter = 6;

type
  TRecorderMic140ScanConfig = class(TObject)
  public
    ChannelCount: Integer;
    PollFrequencyHz: Double;
    UpdateTimeMs: Cardinal;
    constructor Create(AChannelCount: Integer; APollFrequencyHz: Double;
      AUpdateTimeMs: Cardinal);
    function NormalizedFrequency: Double;
    function DataUpdateMs: Cardinal;
    function ReadTimeoutMs: Cardinal;
    function MainScanReadTimeoutMs: Cardinal;
    function IdleWaitMs: Cardinal;
    function ReadTimeoutWarnAfter: Integer;
    function ReadStallRestartAfter: Integer;
  end;

implementation

uses
  uRecorderMic140LegacyTiming;

constructor TRecorderMic140ScanConfig.Create(AChannelCount: Integer;
  APollFrequencyHz: Double; AUpdateTimeMs: Cardinal);
begin
  inherited Create;
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;
  ChannelCount := AChannelCount;
  PollFrequencyHz := APollFrequencyHz;
  UpdateTimeMs := AUpdateTimeMs;
end;

function TRecorderMic140ScanConfig.NormalizedFrequency: Double;
begin
  Result := RecorderMic140NormalizeFrequency(PollFrequencyHz);
end;

function TRecorderMic140ScanConfig.DataUpdateMs: Cardinal;
begin
  if UpdateTimeMs = 0 then
    Exit(200);
  Result := UpdateTimeMs;
end;

function TRecorderMic140ScanConfig.ReadTimeoutMs: Cardinal;
var
  lBlockPeriodMs: Cardinal;
  lFreq: Double;
begin
  lFreq := NormalizedFrequency;
  if lFreq > 0.1 then
    lBlockPeriodMs := Cardinal(Ceil(1500.0 / lFreq))
  else
    lBlockPeriodMs := DataUpdateMs;
  if lBlockPeriodMs < 100 then
    lBlockPeriodMs := 100;
  Result := lBlockPeriodMs + 50;
end;

function TRecorderMic140ScanConfig.MainScanReadTimeoutMs: Cardinal;
var
  lBlockPeriodMs: Cardinal;
  lFreq: Double;
  lUpdate: Cardinal;
begin
  lUpdate := DataUpdateMs;
  if lUpdate = 0 then
    Exit(1);
  lFreq := NormalizedFrequency;
  if lFreq > 0.1 then
    lBlockPeriodMs := Cardinal(Ceil(5.0 / lFreq * 1000.0))
  else
    lBlockPeriodMs := 500;
  if lBlockPeriodMs < 250 then
    lBlockPeriodMs := 250;
  Result := Max(lUpdate + CMic140ScanReadTimeoutExtraMs, lBlockPeriodMs);
end;

function TRecorderMic140ScanConfig.IdleWaitMs: Cardinal;
begin
  Result := Max(DataUpdateMs, 100);
end;

function TRecorderMic140ScanConfig.ReadTimeoutWarnAfter: Integer;
begin
  Result := CMic140LegacyReadTimeoutWarnAfter;
end;

function TRecorderMic140ScanConfig.ReadStallRestartAfter: Integer;
begin
  Result := CMic140LegacyReadStallRestartAfter;
end;

end.
