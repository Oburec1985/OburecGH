program RecorderDataSourcesTest;

{
  RecorderDataSourcesTest

  Назначение:
    Тест-пример базового источника данных RecorderLnx. Тест создает mock-источник
    синуса, подключает его к реестру тегов, выполняет несколько Tick и печатает
    наглядный лог событий и итоговый снимок буфера тега.
}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Classes,
  SysUtils,
  uRecorderCoreServices,
  uRecorderDataSources,
  uRecorderTags,
  uSharedFileLogger;

type
  TDataSourceEventProbe = class
  public
    Count: Integer;
    LastValue: Double;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
  end;

var
  g_Log: TSharedFileLogger;
  g_LogOpened: Boolean = False;

procedure LogLine(const AText: string);
begin
  Writeln(AText);
  if g_LogOpened then
    g_Log.Info(AText);
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
  if FileExists(lLogFileName) then
    DeleteFile(lLogFileName);
  g_Log := TSharedFileLogger.Create(lLogFileName);
  g_LogOpened := True;
  LogLine('LOG file: ' + lLogFileName);
end;

procedure CloseLog;
begin
  if g_LogOpened then
  begin
    g_LogOpened := False;
    FreeAndNil(g_Log);
  end;
end;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string);
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

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
end;

procedure PrintSnapshot(const ATitle: string; const ASnapshot: TRecorderSignalSnapshot);
var
  I: Integer;
begin
  LogLine(ATitle + ' count=' + IntToStr(ASnapshot.Count));
  for I := 0 to ASnapshot.Count - 1 do
    LogFmt('  [%d] t=%.3f value=%.3f',
      [I, ASnapshot.Times[I], ASnapshot.Values[I]]);
end;

procedure TDataSourceEventProbe.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  lData: TRecorderTagUpdateEventData;
begin
  if AEvent.Kind <> rceDataUpdated then
    Exit;

  lData := TRecorderTagUpdateEventData(AEvent.Data);
  Inc(Count);
  LastValue := lData.Value;
  LogFmt('EVENT #%d tag=%s t=%.3f value=%.3f',
    [Count, lData.Tag.Name, lData.TimeSec, lData.Value]);
end;

procedure TestMockSineDataSource;
var
  I: Integer;
  lBus: TRecorderEventBus;
  lProbe: TDataSourceEventProbe;
  lRegistry: TRecorderTagRegistry;
  lSnapshot: TRecorderSignalSnapshot;
  lSource: TMockSineDataSource;
  lTag: TRecorderTag;
begin
  LogLine('--- Recorder data source test ---');

  lBus := TRecorderEventBus.Create;
  lProbe := TDataSourceEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lSource := TMockSineDataSource.Create('mock.sine.1', 'SineTag', 250, 1.0, 1.0);
  try
    lBus.Subscribe(@lProbe.HandleEvent);

    LogFmt('CREATE source id=%s update=%dms tag=%s',
      [lSource.SourceId, lSource.UpdateTimeMs, lSource.TagName]);

    lSource.ConfigureTags(lRegistry);
    lTag := lRegistry.FindByName('SineTag');
    AssertTrue(lTag <> nil, 'source creates tag');
    LogFmt('CONFIGURE tag name=%s address=%s unit=%s source=%s',
      [lTag.Name, lTag.Address, lTag.UnitName, lTag.SourceId]);

    lSource.Start;
    LogLine('START source state=' + RecorderDataSourceStateToString(lSource.State));

    for I := 1 to 5 do
    begin
      LogLine('TICK #' + IntToStr(I));
      lSource.Tick;
    end;

    lSnapshot := lTag.Snapshot;
    PrintSnapshot('SNAPSHOT SineTag', lSnapshot);

    AssertEquals(lProbe.Count, 5, 'event count');
    AssertEquals(lSnapshot.Count, 5, 'snapshot count');
    AssertEquals(lSnapshot.Values[0], 0.0, 'sample 0');
    AssertEquals(lSnapshot.Values[1], 1.0, 'sample 1');
    AssertEquals(lSnapshot.Values[2], 0.0, 'sample 2');
    AssertEquals(lSnapshot.Values[3], -1.0, 'sample 3');
    AssertEquals(lSnapshot.Values[4], 0.0, 'sample 4');

    lSource.Stop;
    LogLine('STOP source state=' + RecorderDataSourceStateToString(lSource.State));
    AssertTrue(lSource.State = dssStopped, 'source stopped');

    LogLine('RESULT mock sine data source test passed.');
  finally
    lSource.Free;
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestDataSourceThread;
var
  lBus: TRecorderEventBus;
  lProbe: TDataSourceEventProbe;
  lRegistry: TRecorderTagRegistry;
  lSnapshot: TRecorderSignalSnapshot;
  lSource: IRecorderDataSource;
  lSourceObject: TMockSineDataSource;
  lTag: TRecorderTag;
  lThread: TRecorderDataSourceThread;
begin
  LogLine('--- Recorder data source thread test ---');

  lBus := TRecorderEventBus.Create;
  lProbe := TDataSourceEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lSourceObject := TMockSineDataSource.Create('mock.sine.thread', 'ThreadSineTag',
    20, 2.0, 5.0);
  lSource := lSourceObject;
  lThread := nil;
  try
    lBus.Subscribe(@lProbe.HandleEvent);
    lSource.ConfigureTags(lRegistry);
    lTag := lRegistry.FindByName('ThreadSineTag');
    AssertTrue(lTag <> nil, 'thread source creates tag');

    LogFmt('CREATE thread source id=%s update=%dms tag=%s',
      [lSource.SourceId, lSource.UpdateTimeMs, lSourceObject.TagName]);

    lThread := TRecorderDataSourceThread.Create(lSource);
    LogLine('THREAD start');
    lThread.Start;

    Sleep(95);
    lThread.Terminate;
    LogLine('THREAD terminate requested');
    lThread.WaitFor;

    LogFmt('THREAD stopped ticks=%d state=%s error="%s"',
      [lThread.TickCount, RecorderDataSourceStateToString(lSource.State),
      lThread.LastErrorMessage]);

    lSnapshot := lTag.Snapshot;
    PrintSnapshot('SNAPSHOT ThreadSineTag', lSnapshot);

    AssertTrue(lThread.LastErrorMessage = '', 'thread should finish without error');
    AssertTrue(lThread.TickCount >= 3, 'thread should execute several ticks');
    AssertEquals(lProbe.Count, lSnapshot.Count, 'thread event/snapshot count');
    AssertTrue(lSource.State = dssStopped, 'thread stops source in finally');

    LogLine('RESULT data source thread test passed.');
  finally
    lThread.Free;
    lSource := nil;
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestDataSourceManager;
var
  lBus: TRecorderEventBus;
  lManager: TRecorderDataSourceManager;
  lProbe: TDataSourceEventProbe;
  lRegistry: TRecorderTagRegistry;
  lSnapshotA: TRecorderSignalSnapshot;
  lSnapshotB: TRecorderSignalSnapshot;
  lSourceA: IRecorderDataSource;
  lSourceB: IRecorderDataSource;
  lTagA: TRecorderTag;
  lTagB: TRecorderTag;
begin
  LogLine('--- Recorder data source manager test ---');

  lBus := TRecorderEventBus.Create;
  lProbe := TDataSourceEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lManager := TRecorderDataSourceManager.Create;
  try
    lBus.Subscribe(@lProbe.HandleEvent);

    lSourceA := TMockSineDataSource.Create('mock.manager.a', 'ManagerSineA',
      25, 1.0, 2.0);
    lSourceB := TMockSineDataSource.Create('mock.manager.b', 'ManagerSineB',
      40, 1.5, 1.0);

    lManager.AddSource(lSourceA);
    lManager.AddSource(lSourceB);
    LogFmt('MANAGER add sources count=%d ids=%s,%s',
      [lManager.SourceCount, lSourceA.SourceId, lSourceB.SourceId]);

    lManager.ConfigureTagsAll(lRegistry);
    lTagA := lRegistry.FindByName('ManagerSineA');
    lTagB := lRegistry.FindByName('ManagerSineB');
    AssertTrue(lTagA <> nil, 'manager source A creates tag');
    AssertTrue(lTagB <> nil, 'manager source B creates tag');
    LogFmt('MANAGER configure tags tagA=%s tagB=%s',
      [lTagA.Name, lTagB.Name]);

    lManager.StartAll;
    LogLine('MANAGER start running=True');

    Sleep(130);
    lManager.StopAll;
    LogFmt('MANAGER stopped running=%s errors=%d',
      [BoolToStr(lManager.Running, True), lManager.LastErrorCount]);

    lSnapshotA := lTagA.Snapshot;
    lSnapshotB := lTagB.Snapshot;
    PrintSnapshot('SNAPSHOT ManagerSineA', lSnapshotA);
    PrintSnapshot('SNAPSHOT ManagerSineB', lSnapshotB);

    AssertEquals(lManager.SourceCount, 2, 'manager source count');
    AssertTrue(lManager.FindSource('MOCK.MANAGER.A') = lSourceA,
      'manager case-insensitive lookup');
    AssertTrue(not lManager.Running, 'manager stopped');
    AssertEquals(lManager.LastErrorCount, 0, 'manager thread errors');
    AssertTrue(lSnapshotA.Count >= 3, 'manager source A ticks');
    AssertTrue(lSnapshotB.Count >= 2, 'manager source B ticks');
    AssertTrue(lProbe.Count = lSnapshotA.Count + lSnapshotB.Count,
      'manager event count equals snapshots');

    LogLine('RESULT data source manager test passed.');
  finally
    lManager.Free;
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure WriteDouble(AStream: TStream; AValue: Double);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure TestMeraFileDataSource;
var
  lBus: TRecorderEventBus;
  lDataFileName: string;
  lDir: string;
  lIni: TStringList;
  lMeraFileName: string;
  lProbe: TDataSourceEventProbe;
  lRegistry: TRecorderTagRegistry;
  lSelected: TStringList;
  lSnapshot: TRecorderSignalSnapshot;
  lSource: TRecorderMeraFileDataSource;
  lStream: TFileStream;
  lTag: TRecorderTag;
begin
  LogLine('--- Recorder MERA file data source test ---');

  lDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'mera_test';
  ForceDirectories(lDir);
  lMeraFileName := IncludeTrailingPathDelimiter(lDir) + 'sample.mera';
  lDataFileName := IncludeTrailingPathDelimiter(lDir) + 'SignalA.dat';

  lIni := TStringList.Create;
  try
    lIni.Add('[MERA]');
    lIni.Add('');
    lIni.Add('[SignalA]');
    lIni.Add('Address=A1');
    lIni.Add('YFormat=R8');
    lIni.Add('YUnits=mm');
    lIni.Add('Freq=2');
    lIni.Add('tare0=SensorGX');
    lIni.Add('tare1=AmplifierGX');
    lIni.Add('Start=1');
    lIni.SaveToFile(lMeraFileName);
  finally
    lIni.Free;
  end;

  lStream := TFileStream.Create(lDataFileName, fmCreate);
  try
    WriteDouble(lStream, 10.0);
    WriteDouble(lStream, 20.0);
    WriteDouble(lStream, 30.0);
  finally
    lStream.Free;
  end;

  lBus := TRecorderEventBus.Create;
  lProbe := TDataSourceEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lSelected := TStringList.Create;
  lSource := nil;
  try
    lBus.Subscribe(@lProbe.HandleEvent);
    lSelected.Add('SignalA');
    lSource := TRecorderMeraFileDataSource.Create('mera.test', lMeraFileName,
      10, lSelected);
    lSource.ConfigureTags(lRegistry);
    lTag := lRegistry.FindByName('SignalA');
    AssertTrue(lTag <> nil, 'MERA source creates selected tag');
    AssertTrue(lTag.SensorCalibrationName = 'SensorGX', 'MERA source preserves sensor GX');
    AssertTrue(lTag.AmplifierCalibrationName = 'AmplifierGX', 'MERA source preserves amplifier GX');
    AssertEquals(lRegistry.TagCount, 1, 'MERA selected tag count');

    lSource.Start;
    lSource.Tick;
    lSource.Stop;

    lSnapshot := lTag.Snapshot;
    PrintSnapshot('SNAPSHOT SignalA', lSnapshot);

    AssertEquals(lProbe.Count, 1, 'MERA vector block event count');
    AssertEquals(lSnapshot.Count, 3, 'MERA snapshot count');
    AssertEquals(lSnapshot.Times[0], 1.0, 'MERA sample 0 time');
    AssertEquals(lSnapshot.Times[1], 1.5, 'MERA sample 1 time');
    AssertEquals(lSnapshot.Times[2], 2.0, 'MERA sample 2 time');
    AssertEquals(lSnapshot.Values[0], 10.0, 'MERA sample 0 value');
    AssertEquals(lSnapshot.Values[1], 20.0, 'MERA sample 1 value');
    AssertEquals(lSnapshot.Values[2], 30.0, 'MERA sample 2 value');

    LogLine('RESULT MERA file data source test passed.');
  finally
    lSource.Free;
    lSelected.Free;
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestMeraScalarTimeFileDataSource;
var
  lBus: TRecorderEventBus;
  lDataFileName: string;
  lDir: string;
  lIni: TStringList;
  lMeraFileName: string;
  lProbe: TDataSourceEventProbe;
  lRegistry: TRecorderTagRegistry;
  lSelected: TStringList;
  lSnapshot: TRecorderSignalSnapshot;
  lSource: TRecorderMeraFileDataSource;
  lStream: TFileStream;
  lTag: TRecorderTag;
  lXFileName: string;
begin
  LogLine('--- Recorder MERA scalar .x time data source test ---');

  lDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'mera_scalar_test';
  ForceDirectories(lDir);
  lMeraFileName := IncludeTrailingPathDelimiter(lDir) + 'sample.mera';
  lDataFileName := IncludeTrailingPathDelimiter(lDir) + 'ScalarA.dat';
  lXFileName := IncludeTrailingPathDelimiter(lDir) + 'ScalarA.x';

  lIni := TStringList.Create;
  try
    lIni.Add('[MERA]');
    lIni.Add('');
    lIni.Add('[ScalarA]');
    lIni.Add('Address=S1');
    lIni.Add('YFormat=R8');
    lIni.Add('XFormat=R8');
    lIni.Add('YUnits=N');
    lIni.Add('Freq=0');
    lIni.Add('Start=0');
    lIni.SaveToFile(lMeraFileName);
  finally
    lIni.Free;
  end;

  lStream := TFileStream.Create(lDataFileName, fmCreate);
  try
    WriteDouble(lStream, 100.0);
    WriteDouble(lStream, 200.0);
    WriteDouble(lStream, 300.0);
  finally
    lStream.Free;
  end;

  lStream := TFileStream.Create(lXFileName, fmCreate);
  try
    WriteDouble(lStream, 0.0);
    WriteDouble(lStream, 0.05);
    WriteDouble(lStream, 0.20);
  finally
    lStream.Free;
  end;

  lBus := TRecorderEventBus.Create;
  lProbe := TDataSourceEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lSelected := TStringList.Create;
  lSource := nil;
  try
    lBus.Subscribe(@lProbe.HandleEvent);
    lSelected.Add('ScalarA');
    lSource := TRecorderMeraFileDataSource.Create('mera.scalar.test',
      lMeraFileName, 20, lSelected, 128);
    lSource.ConfigureTags(lRegistry);
    lTag := lRegistry.FindByName('ScalarA');
    AssertTrue(lTag <> nil, 'MERA scalar source creates selected tag');

    lSource.Start;
    lSource.Tick;
    Sleep(70);
    lSource.Tick;
    lSnapshot := lTag.Snapshot;
    AssertEquals(lSnapshot.Count, 2, 'MERA scalar publishes due samples only');

    Sleep(160);
    lSource.Tick;
    lSource.Stop;

    lSnapshot := lTag.Snapshot;
    PrintSnapshot('SNAPSHOT ScalarA', lSnapshot);

    AssertEquals(lProbe.Count, 3, 'MERA scalar event count');
    AssertEquals(lSnapshot.Count, 3, 'MERA scalar snapshot count');
    AssertEquals(lSnapshot.Times[0], 0.0, 'MERA scalar sample 0 time');
    AssertEquals(lSnapshot.Times[1], 0.05, 'MERA scalar sample 1 time');
    AssertEquals(lSnapshot.Times[2], 0.20, 'MERA scalar sample 2 time');
    AssertEquals(lSnapshot.Values[0], 100.0, 'MERA scalar sample 0 value');
    AssertEquals(lSnapshot.Values[1], 200.0, 'MERA scalar sample 1 value');
    AssertEquals(lSnapshot.Values[2], 300.0, 'MERA scalar sample 2 value');

    LogLine('RESULT MERA scalar .x time data source test passed.');
  finally
    lSource.Free;
    lSelected.Free;
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestDiagnosticsDataSource;
var
  lBus: TRecorderEventBus;
  lCpuSnapshot: TRecorderSignalSnapshot;
  lCpuTag: TRecorderTag;
  lMemorySnapshot: TRecorderSignalSnapshot;
  lMemoryTag: TRecorderTag;
  lRegistry: TRecorderTagRegistry;
  lSource: TRecorderDiagnosticsDataSource;
begin
  LogLine('--- Recorder diagnostics data source test ---');
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lSource := TRecorderDiagnosticsDataSource.Create('diagnostics.test', 200,
    'MemTag', 'CpuUsage');
  try
    lSource.ConfigureTags(lRegistry);
    lMemoryTag := lRegistry.FindByName('MemTag');
    lCpuTag := lRegistry.FindByName('CpuUsage');
    AssertTrue(lMemoryTag <> nil, 'Diagnostics creates MemTag');
    AssertTrue(lCpuTag <> nil, 'Diagnostics creates CpuUsage');
    AssertEquals(lRegistry.TagCount, 2, 'Diagnostics tag count');
    AssertTrue(lMemoryTag.UnitName = 'MB', 'MemTag unit');
    AssertTrue(lCpuTag.UnitName = '%', 'CpuUsage unit');

    lSource.Start;
    lSource.Tick;
    Sleep(220);
    lSource.Tick;
    lSource.Stop;

    lMemorySnapshot := lMemoryTag.Snapshot;
    lCpuSnapshot := lCpuTag.Snapshot;
    PrintSnapshot('SNAPSHOT MemTag', lMemorySnapshot);
    PrintSnapshot('SNAPSHOT CpuUsage', lCpuSnapshot);
    AssertEquals(lMemorySnapshot.Count, 2, 'MemTag sample count');
    AssertEquals(lCpuSnapshot.Count, 2, 'CpuUsage sample count');
    AssertTrue(lMemorySnapshot.Values[0] >= 0, 'MemTag value non-negative');
    AssertTrue(lCpuSnapshot.Values[0] >= 0, 'CpuUsage value non-negative');
    AssertTrue(lCpuSnapshot.Values[0] <= 100, 'CpuUsage value <= 100');
    LogLine('RESULT diagnostics data source test passed.');
  finally
    lSource.Free;
    lRegistry.Free;
    lBus.Free;
  end;
end;

begin
  OpenLog;
  try
    TestMockSineDataSource;
    LogLine('');
    TestDataSourceThread;
    LogLine('');
    TestDataSourceManager;
    LogLine('');
    TestMeraFileDataSource;
    LogLine('');
    TestMeraScalarTimeFileDataSource;
    LogLine('');
    TestDiagnosticsDataSource;
  finally
    CloseLog;
  end;
end.
