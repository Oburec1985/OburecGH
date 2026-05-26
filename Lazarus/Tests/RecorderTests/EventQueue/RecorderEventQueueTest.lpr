program RecorderEventQueueTest;

{
  RecorderEventQueueTest

  Назначение:
    Консольный тест-пример очереди снимков событий RecorderLnx. Тест запускает
    mock-источник данных через manager, публикует значения в реестр тегов и
    показывает, что TRecorderEventSnapshotQueue получает независимые снимки
    событий, пригодные для последующего чтения UI thread.

  Результат:
    Тест печатает понятный лог в консоль и в файл RecorderEventQueueTest.log
    рядом с exe, чтобы результат можно было проверить без отладчика.
}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Classes,
  SysUtils,
  uRecorderCoreServices,
  uRecorderDataSources,
  uRecorderEventQueue,
  uRecorderTags;

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

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
end;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure TestEventSnapshotQueue;
var
  lBus: TRecorderEventBus;
  lEventCount: Integer;
  lManager: TRecorderDataSourceManager;
  lQueue: TRecorderEventSnapshotQueue;
  lRegistry: TRecorderTagRegistry;
  lSnapshot: TRecorderEventSnapshot;
  lSource: IRecorderDataSource;
  lTag: TRecorderTag;
begin
  LogLine('--- Recorder event snapshot queue test ---');

  lBus := TRecorderEventBus.Create;
  lQueue := TRecorderEventSnapshotQueue.Create(lBus);
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lManager := TRecorderDataSourceManager.Create;
  try
    lSource := TMockSineDataSource.Create('mock.queue.sine',
      'QueueSineTag', 25, 1.0, 1.0);

    lManager.AddSource(lSource);
    lManager.ConfigureTagsAll(lRegistry);
    lTag := lRegistry.FindByName('QueueSineTag');
    AssertTrue(lTag <> nil, 'source creates QueueSineTag');

    LogFmt('SOURCE id=%s tag=%s update=%dms',
      [lSource.SourceId, lTag.Name, lSource.UpdateTimeMs]);

    lManager.StartAll;
    LogLine('MANAGER start');
    Sleep(115);
    lManager.StopAll;
    LogFmt('MANAGER stop errors=%d queued=%d',
      [lManager.LastErrorCount, lQueue.Count]);

    AssertEquals(lManager.LastErrorCount, 0, 'manager thread errors');
    AssertTrue(lQueue.Count >= 3, 'queue should receive several events');

    lEventCount := 0;
    repeat
      lSnapshot := lQueue.Pop;
      if lSnapshot = nil then
        Break;
      try
        Inc(lEventCount);
        LogFmt('QUEUE pop #%d kind=%d name=%s tag=%s t=%.3f value=%.3f',
          [lEventCount, Ord(lSnapshot.Kind), lSnapshot.Name,
          lSnapshot.TagName, lSnapshot.TimeSec, lSnapshot.Value]);

        AssertTrue(lSnapshot.Kind = rceDataUpdated, 'snapshot event kind');
        AssertTrue(lSnapshot.HasTagData, 'snapshot has tag data');
        AssertTrue(lSnapshot.TagName = 'QueueSineTag', 'snapshot tag name');
      finally
        lSnapshot.Free;
      end;
    until False;

    AssertTrue(lEventCount >= 3, 'drained event count');
    AssertEquals(lQueue.Count, 0, 'queue drained');

    LogFmt('RESULT event snapshot queue test passed, events=%d.', [lEventCount]);
  finally
    lManager.Free;
    lRegistry.Free;
    lQueue.Free;
    lBus.Free;
  end;
end;

begin
  OpenLog;
  try
    TestEventSnapshotQueue;
  finally
    CloseLog;
  end;
end.
