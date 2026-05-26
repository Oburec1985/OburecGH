program RecorderTimeSystemTest;

{
  RecorderTimeSystemTest

  Purpose:
    Console test/example for TRecorderTimeSystem. It checks duration formatting,
    tag-time display, UTS display and elapsed-time startup behavior.

  Result:
    The test writes a readable log to console and to RecorderTimeSystemTest.log
    beside the executable, so the result can be inspected without the IDE.
}

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  uRecorderTimeSystem;

var
  g_Log: TextFile;
  g_LogOpened: Boolean = False;

procedure LogLine(const AText: string);
begin
  Writeln(AText);
  if g_LogOpened then
  begin
    Writeln(g_Log, AText);
    Flush(g_Log);
  end;
end;

procedure LogFmt(const AFormat: string; const AArgs: array of const);
begin
  LogLine(Format(AFormat, AArgs));
end;

procedure OpenLog;
var
  lLogFileName: string;
begin
  lLogFileName := ChangeFileExt(ParamStr(0), '.log');
  AssignFile(g_Log, lLogFileName);
  Rewrite(g_Log);
  g_LogOpened := True;
  LogLine('LOG file: ' + lLogFileName);
end;

procedure CloseLog;
begin
  if g_LogOpened then
  begin
    g_LogOpened := False;
    CloseFile(g_Log);
  end;
end;

procedure AssertEquals(const AActual, AExpected, AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected "%s", got "%s"',
      [AStep, AExpected, AActual]);
  LogFmt('OK %s -> %s', [AStep, AActual]);
end;

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
  LogLine('OK ' + AStep);
end;

procedure TestFormatDuration;
begin
  LogLine('--- FormatDuration ---');
  AssertEquals(TRecorderTimeSystem.FormatDuration(0), '00:00:00', 'zero');
  AssertEquals(TRecorderTimeSystem.FormatDuration(12.9), '00:00:12', 'seconds');
  AssertEquals(TRecorderTimeSystem.FormatDuration(3661.25), '01:01:01', 'hours');
end;

procedure TestExternalTimes;
var
  lSystem: TRecorderTimeSystem;
  lSnapshot: TRecorderTimeSnapshot;
begin
  LogLine('--- External tag/UTS time ---');

  lSystem := TRecorderTimeSystem.Create;
  try
    lSystem.SourceKind := rtskTagTime;
    lSystem.UpdateFromTagSample(125.75);
    lSnapshot := lSystem.Snapshot;
    AssertEquals(lSnapshot.DisplayText, '00:02:05', 'tag time display');
    LogFmt('SNAP tag elapsed=%.3f tag=%.3f uts=%.3f text=%s',
      [lSnapshot.ElapsedSec, lSnapshot.LastTagTimeSec, lSnapshot.LastUtsTimeSec,
       lSnapshot.DisplayText]);

    lSystem.SourceKind := rtskUtsTime;
    lSystem.UpdateFromTagSample(126.0, 7201.0);
    lSnapshot := lSystem.Snapshot;
    AssertEquals(lSnapshot.DisplayText, '02:00:01', 'UTS time display');
    LogFmt('SNAP uts elapsed=%.3f tag=%.3f uts=%.3f text=%s',
      [lSnapshot.ElapsedSec, lSnapshot.LastTagTimeSec, lSnapshot.LastUtsTimeSec,
       lSnapshot.DisplayText]);
  finally
    lSystem.Free;
  end;
end;

procedure TestElapsedStartStop;
var
  lSystem: TRecorderTimeSystem;
  lSnapshot: TRecorderTimeSnapshot;
begin
  LogLine('--- Elapsed start/stop ---');

  lSystem := TRecorderTimeSystem.Create;
  try
    lSystem.SourceKind := rtskElapsedTime;
    lSystem.Start;
    Sleep(30);
    lSnapshot := lSystem.Snapshot;
    AssertTrue(lSnapshot.Running, 'elapsed snapshot is running');
    AssertTrue(lSnapshot.ElapsedSec >= 0.02, 'elapsed time advanced');
    LogFmt('SNAP elapsed=%.3f text=%s', [lSnapshot.ElapsedSec,
      lSnapshot.DisplayText]);

    lSystem.Stop;
    lSnapshot := lSystem.Snapshot;
    AssertTrue(not lSnapshot.Running, 'elapsed snapshot stopped');
    LogFmt('SNAP stopped elapsed=%.3f text=%s', [lSnapshot.ElapsedSec,
      lSnapshot.DisplayText]);
  finally
    lSystem.Free;
  end;
end;

begin
  OpenLog;
  try
    LogLine('--- Recorder time system test ---');
    TestFormatDuration;
    TestExternalTimes;
    TestElapsedStartStop;
    LogLine('RESULT time system test passed.');
  finally
    CloseLog;
  end;
end.
