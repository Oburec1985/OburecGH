unit uRecorderBlockClock;

{ Recorder-wide monotonic block time and reversible device-session anchors.
  Producers anchor once per hardware run; delivery/GUI latency never retimes
  an already submitted block. Host anchors are not hardware clock locking. }

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

type
  TRecorderBlockTimeDomain = (btSessionRelative, btRecorderMonotonic);

  TRecorderBlockTime = record
    DeviceStartSeconds, RecorderStartSeconds, SubmittedRecorderSeconds: Double;
    SampleRateHz, UncertaintySeconds: Double;
    SampleCount: Integer;
    Generation: QWord;
  end;

  TRecorderDeviceTimeMap = record
  private
    fDeviceSeconds, fRecorderSeconds, fUncertaintySeconds: Double;
    fValid: Boolean;
    fGeneration: QWord;
  public
    procedure BeginSession(ADeviceSeconds, ARecorderSeconds,
      AUncertaintySeconds: Double);
    function ToRecorder(ADeviceSeconds: Double): Double;
    function ToDevice(ARecorderSeconds: Double): Double;
    property Valid: Boolean read fValid;
    property Generation: QWord read fGeneration;
    property UncertaintySeconds: Double read fUncertaintySeconds;
  end;

function RecorderClockSeconds: Double;
function RecorderClockResolution: Double;

implementation

uses SysUtils, Math
  {$IFDEF MSWINDOWS}, Windows{$ENDIF}
  {$IFDEF LINUX}, ctypes{$ENDIF};

{$IFDEF MSWINDOWS}
var gCounterFrequency: Int64;
{$ENDIF}

{$IFDEF LINUX}
type
  TRecorderTimespec = record
    Seconds, Nanoseconds: clong;
  end;
const RECORDER_CLOCK_MONOTONIC = 1;
function RecorderPosixClock(AClock: cint; var ATime: TRecorderTimespec): cint;
  cdecl; external 'c' name 'clock_gettime';
{$ENDIF}

function RecorderClockSeconds: Double;
{$IFDEF MSWINDOWS}var lCounter: Int64;{$ENDIF}
{$IFDEF LINUX}var lTime: TRecorderTimespec;{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  if (gCounterFrequency > 0) and QueryPerformanceCounter(lCounter) then
    Exit(lCounter / gCounterFrequency);
  {$ENDIF}
  {$IFDEF LINUX}
  if RecorderPosixClock(RECORDER_CLOCK_MONOTONIC, lTime) = 0 then
    Exit(lTime.Seconds + lTime.Nanoseconds * 1E-9);
  {$ENDIF}
  Result := GetTickCount64 * 0.001;
end;

function RecorderClockResolution: Double;
begin
  {$IFDEF MSWINDOWS}
  if gCounterFrequency > 0 then Exit(1 / gCounterFrequency);
  {$ENDIF}
  {$IFDEF LINUX}Exit(1E-9);{$ENDIF}
  Result := 0.001;
end;

procedure TRecorderDeviceTimeMap.BeginSession(ADeviceSeconds,
  ARecorderSeconds, AUncertaintySeconds: Double);
begin
  fValid := not IsNan(ADeviceSeconds) and not IsInfinite(ADeviceSeconds) and
    not IsNan(ARecorderSeconds) and not IsInfinite(ARecorderSeconds) and
    not IsNan(AUncertaintySeconds) and not IsInfinite(AUncertaintySeconds) and
    (AUncertaintySeconds >= 0);
  if not fValid then Exit;
  fDeviceSeconds := ADeviceSeconds;
  fRecorderSeconds := ARecorderSeconds;
  fUncertaintySeconds := AUncertaintySeconds;
  Inc(fGeneration);
end;

function TRecorderDeviceTimeMap.ToRecorder(ADeviceSeconds: Double): Double;
begin
  if not fValid then Exit(NaN);
  Result := fRecorderSeconds + (ADeviceSeconds - fDeviceSeconds);
end;

function TRecorderDeviceTimeMap.ToDevice(ARecorderSeconds: Double): Double;
begin
  if not fValid then Exit(NaN);
  Result := fDeviceSeconds + (ARecorderSeconds - fRecorderSeconds);
end;

initialization
  {$IFDEF MSWINDOWS}
  if not QueryPerformanceFrequency(gCounterFrequency) then gCounterFrequency := 0;
  {$ENDIF}
end.
