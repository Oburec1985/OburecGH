program RecorderStateMachineTest;

{$mode objfpc}{$H+}

uses
  SysUtils,
  uRecorderStateMachine,
  uRecorderRunControlSettings;

procedure AssertState(AMachine: TRecorderStateMachine; AExpected: TRecorderState;
  const AStep: string);
begin
  if AMachine.State <> AExpected then
    raise Exception.CreateFmt('%s: expected %s, got %s',
      [AStep, TRecorderStateMachine.StateToString(AExpected),
       TRecorderStateMachine.StateToString(AMachine.State)]);
end;

procedure AssertValid(ASettings: TRecorderRunControlSettings; const AStep: string);
var
  lMessage: string;
begin
  if not ASettings.Validate(lMessage) then
    raise Exception.CreateFmt('%s: settings should be valid, error: %s',
      [AStep, lMessage]);
end;

procedure AssertInvalid(ASettings: TRecorderRunControlSettings; const AStep: string);
var
  lMessage: string;
begin
  if ASettings.Validate(lMessage) then
    raise Exception.Create(AStep + ': settings should be invalid');
  Writeln(AStep, ': ', lMessage);
end;

procedure AssertEquals(const AActual, AExpected, AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %s, got %s',
      [AStep, AExpected, AActual]);
end;

procedure AssertEquals(AActual, AExpected: Cardinal; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure AssertEquals(AActual, AExpected: Double; const AStep: string);
begin
  if Abs(AActual - AExpected) > 0.000001 then
    raise Exception.CreateFmt('%s: expected %.6f, got %.6f',
      [AStep, AExpected, AActual]);
end;

procedure TestRunControlSettingsSaveLoad;
var
  lFileName: string;
  lSaved: TRecorderRunControlSettings;
  lLoaded: TRecorderRunControlSettings;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'run-control-settings-test.ini';

  lSaved := TRecorderRunControlSettings.Create;
  lLoaded := TRecorderRunControlSettings.Create;
  try
    lSaved.StartCondition := rscSignalLevel;
    lSaved.StartChannelName := 'AI0';
    lSaved.StartLevel := 12.5;
    lSaved.StartEdge := rseRising;
    lSaved.StopCondition := rstopDuration;
    lSaved.StopDelayMs := 15000;
    lSaved.ScreenUpdateMs := 750;
    lSaved.DisplayBufferMs := 1250;
    lSaved.DataUpdateMs := 200;
    lSaved.RecordRootDir := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'recorder-mera-records';
    lSaved.SaveToFile(lFileName);

    lLoaded.LoadFromFile(lFileName);

    if lLoaded.StartCondition <> rscSignalLevel then
      raise Exception.Create('loaded StartCondition mismatch');
    AssertEquals(lLoaded.StartChannelName, 'AI0', 'loaded StartChannelName');
    AssertEquals(lLoaded.StartLevel, 12.5, 'loaded StartLevel');
    if lLoaded.StartEdge <> rseRising then
      raise Exception.Create('loaded StartEdge mismatch');
    if lLoaded.StopCondition <> rstopDuration then
      raise Exception.Create('loaded StopCondition mismatch');
    AssertEquals(lLoaded.StopDelayMs, 15000, 'loaded StopDelayMs');
    AssertEquals(lLoaded.ScreenUpdateMs, 750, 'loaded ScreenUpdateMs');
    AssertEquals(lLoaded.DisplayBufferMs, 1250, 'loaded DisplayBufferMs');
    AssertEquals(lLoaded.DataUpdateMs, 200, 'loaded DataUpdateMs');
    AssertEquals(lLoaded.RecordRootDir, lSaved.RecordRootDir, 'loaded RecordRootDir');

    Writeln('Run control settings save/load test passed.');
  finally
    lLoaded.Free;
    lSaved.Free;
    if FileExists(lFileName) then
      DeleteFile(lFileName);
  end;
end;

procedure TestRunControlSettings;
var
  lSettings: TRecorderRunControlSettings;
begin
  lSettings := TRecorderRunControlSettings.Create;
  try
    AssertValid(lSettings, 'default manual settings');

    lSettings.StartCondition := rscSignalLevel;
    lSettings.StartLevel := 12.5;
    lSettings.StartEdge := rseRising;
    AssertInvalid(lSettings, 'start level without channel');

    lSettings.StartChannelName := 'AI0';
    AssertValid(lSettings, 'start level with channel');

    lSettings.ResetDefaults;
    lSettings.StartCondition := rscTime;
    lSettings.StartDelayMs := 2500;
    lSettings.StopCondition := rstopDuration;
    lSettings.StopDelayMs := 10000;
    AssertValid(lSettings, 'delayed start and duration stop');

    lSettings.ResetDefaults;
    lSettings.StopCondition := rstopSignalLevel;
    lSettings.StopLevel := -1.0;
    lSettings.StopEdge := rseFalling;
    AssertInvalid(lSettings, 'stop level without channel');

    lSettings.StopChannelName := 'AI1';
    AssertValid(lSettings, 'stop level with channel');

    Writeln('Run control settings test passed.');
  finally
    lSettings.Free;
  end;
end;

procedure TestStateMachine;
var
  lMachine: TRecorderStateMachine;
begin
  lMachine := TRecorderStateMachine.Create;
  try
    AssertState(lMachine, rsStop, 'initial state');

    lMachine.StartPreview(rscManual);
    AssertState(lMachine, rsPreview, 'manual preview');

    lMachine.StartRecord(rscManual);
    AssertState(lMachine, rsRecord, 'manual record from preview');

    lMachine.StartPreview(rscManual);
    AssertState(lMachine, rsPreview, 'preview from record closes current record frame');

    lMachine.StartRecord(rscManual);
    AssertState(lMachine, rsRecord, 'manual record after preview creates next record frame');

    lMachine.Stop;
    AssertState(lMachine, rsStop, 'stop record');

    lMachine.StartRecord(rscExternalTrigger);
    AssertState(lMachine, rsRecordArmed, 'record waits external trigger');
    lMachine.StartConditionMet;
    AssertState(lMachine, rsRecord, 'external trigger starts record');

    lMachine.Stop;
    AssertState(lMachine, rsStop, 'stop after triggered record');

    lMachine.StartPreview(rscSignalLevel);
    AssertState(lMachine, rsPreviewArmed, 'preview waits signal level');
    lMachine.StartConditionMet;
    AssertState(lMachine, rsPreview, 'signal level starts preview');

    lMachine.Stop;
    AssertState(lMachine, rsStop, 'stop preview');

    try
      lMachine.StartConditionMet;
      raise Exception.Create('unexpected trigger in stop: ERecorderStateError was expected');
    except
      on E: ERecorderStateError do
        Writeln('unexpected trigger in stop: ', E.Message);
    end;

    Writeln('Recorder state machine test passed.');
  finally
    lMachine.Free;
  end;
end;

begin
  TestRunControlSettings;
  TestRunControlSettingsSaveLoad;
  TestStateMachine;
end.
