unit uRecorderTimeSystem;

{
  Unit uRecorderTimeSystem

  Purpose:
    Central time model for RecorderLnx. The original Recorder can show several
    time domains in the status display: PC time, recorder elapsed time, hardware
    channel/tag time and UTS time. This unit keeps that policy outside LCL forms
    so UI code only asks for a snapshot and renders it.

  Architecture:
    Core/domain unit, cross-platform and LCL-free. The first implementation is
    intentionally small: it stores the selected display source, start moment,
    last tag sample time and last UTS time. Later the same class can be fed by a
    dedicated display/update thread or by hardware source metadata.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { Selects the time domain shown on the Recorder status display. }
  TRecorderTimeSourceKind = (
    rtskPcTime,
    rtskElapsedTime,
    rtskTagTime,
    rtskUtsTime
  );

  { Immutable status-display time snapshot.

    SourceKind       - selected display source.
    Running          - True while data flow is active.
    StartLocalTime   - PC date/time captured at Start.
    ElapsedSec       - monotonic elapsed time from Start.
    LastTagTimeSec   - latest hardware/channel/tag sample time.
    LastUtsTimeSec   - latest UTS time value when available.
    DisplayText      - already formatted text for a compact status display. }
  TRecorderTimeSnapshot = record
    SourceKind: TRecorderTimeSourceKind;
    Running: Boolean;
    StartLocalTime: TDateTime;
    ElapsedSec: Double;
    LastTagTimeSec: Double;
    LastUtsTimeSec: Double;
    DisplayText: string;
  end;

  { TRecorderTimeSystem

    Owns RecorderLnx time-display policy. All public methods are protected by a
    critical section because future data/display workers may update/read it from
    different threads. }
  TRecorderTimeSystem = class
  private
    fDisplayUpdateMs: Integer;
    fLastTagTimeSec: Double;
    fLastUtsTimeSec: Double;
    fLock: TRTLCriticalSection;
    fResetAtStart: Boolean;
    fRunning: Boolean;
    fSourceKind: TRecorderTimeSourceKind;
    fStartLocalTime: TDateTime;
    fStartTickMs: QWord;
    function GetDisplayUpdateMs: Integer;
    function GetResetAtStart: Boolean;
    function GetSourceKind: TRecorderTimeSourceKind;
    procedure SetDisplayUpdateMs(AValue: Integer);
    procedure SetResetAtStart(AValue: Boolean);
    procedure SetSourceKind(AValue: TRecorderTimeSourceKind);
    function InternalElapsedSec(ANowTickMs: QWord): Double;
  public
    constructor Create;
    destructor Destroy; override;

    { Starts or restarts the active time interval.

      The start point is both PC date/time and monotonic tick counter. If
      ResetAtStart is True, last external tag/UTS times are cleared too. }
    procedure Start;

    { Stops the active interval without clearing the latest measured values. }
    procedure Stop;

    { Clears elapsed and external time values. }
    procedure Reset;

    { Updates external time domains from a received tag/channel sample.

      ATagTimeSec - hardware/channel/sample time in seconds.
      AUtsTimeSec - UTS time in seconds; pass a negative value when unavailable. }
    procedure UpdateFromTagSample(ATagTimeSec: Double; AUtsTimeSec: Double = -1);

    { Returns a thread-safe copy formatted for the status display. }
    function Snapshot: TRecorderTimeSnapshot;

    { Formats seconds as HH:MM:SS for compact Recorder-like displays. }
    class function FormatDuration(ASeconds: Double): string; static;

    property SourceKind: TRecorderTimeSourceKind read GetSourceKind write SetSourceKind;
    property ResetAtStart: Boolean read GetResetAtStart write SetResetAtStart;
    property DisplayUpdateMs: Integer read GetDisplayUpdateMs write SetDisplayUpdateMs;
  end;

implementation

const
  CDefaultDisplayUpdateMs = 100;
  CMsecsPerSec = 1000.0;

{ TRecorderTimeSystem }

constructor TRecorderTimeSystem.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  fDisplayUpdateMs := CDefaultDisplayUpdateMs;
  fResetAtStart := True;
  fSourceKind := rtskElapsedTime;
  Reset;
end;

destructor TRecorderTimeSystem.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderTimeSystem.GetDisplayUpdateMs: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result := fDisplayUpdateMs;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.GetResetAtStart: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := fResetAtStart;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.GetSourceKind: TRecorderTimeSourceKind;
begin
  EnterCriticalSection(fLock);
  try
    Result := fSourceKind;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.SetDisplayUpdateMs(AValue: Integer);
begin
  if AValue < 20 then
    AValue := 20;

  EnterCriticalSection(fLock);
  try
    fDisplayUpdateMs := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.SetResetAtStart(AValue: Boolean);
begin
  EnterCriticalSection(fLock);
  try
    fResetAtStart := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.SetSourceKind(AValue: TRecorderTimeSourceKind);
begin
  EnterCriticalSection(fLock);
  try
    fSourceKind := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.InternalElapsedSec(ANowTickMs: QWord): Double;
begin
  if (not fRunning) or (fStartTickMs = 0) or (ANowTickMs < fStartTickMs) then
    Exit(0);

  Result := (ANowTickMs - fStartTickMs) / CMsecsPerSec;
end;

procedure TRecorderTimeSystem.Start;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := True;
    fStartLocalTime := Now;
    fStartTickMs := GetTickCount64;
    if fResetAtStart then
    begin
      fLastTagTimeSec := 0;
      fLastUtsTimeSec := 0;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.Stop;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := False;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.Reset;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := False;
    fStartLocalTime := Now;
    fStartTickMs := 0;
    fLastTagTimeSec := 0;
    fLastUtsTimeSec := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.UpdateFromTagSample(ATagTimeSec: Double;
  AUtsTimeSec: Double);
begin
  EnterCriticalSection(fLock);
  try
    if ATagTimeSec >= 0 then
      fLastTagTimeSec := ATagTimeSec;
    if AUtsTimeSec >= 0 then
      fLastUtsTimeSec := AUtsTimeSec;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.Snapshot: TRecorderTimeSnapshot;
var
  lNowTickMs: QWord;
begin
  lNowTickMs := GetTickCount64;

  EnterCriticalSection(fLock);
  try
    Result.SourceKind := fSourceKind;
    Result.Running := fRunning;
    Result.StartLocalTime := fStartLocalTime;
    Result.ElapsedSec := InternalElapsedSec(lNowTickMs);
    Result.LastTagTimeSec := fLastTagTimeSec;
    Result.LastUtsTimeSec := fLastUtsTimeSec;

    case fSourceKind of
      rtskPcTime:
        Result.DisplayText := FormatDateTime('hh:nn:ss', Now);
      rtskTagTime:
        Result.DisplayText := FormatDuration(fLastTagTimeSec);
      rtskUtsTime:
        Result.DisplayText := FormatDuration(fLastUtsTimeSec);
    else
      Result.DisplayText := FormatDuration(Result.ElapsedSec);
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

class function TRecorderTimeSystem.FormatDuration(ASeconds: Double): string;
var
  lTotalSeconds: Int64;
  lHours: Int64;
  lMinutes: Int64;
  lSeconds: Int64;
begin
  if ASeconds < 0 then
    ASeconds := 0;

  lTotalSeconds := Trunc(ASeconds);
  lHours := lTotalSeconds div 3600;
  lMinutes := (lTotalSeconds div 60) mod 60;
  lSeconds := lTotalSeconds mod 60;

  Result := Format('%.2d:%.2d:%.2d', [lHours, lMinutes, lSeconds]);
end;

end.
