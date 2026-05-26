program RecorderStorageTest;

{
  RecorderStorageTest

  Назначение:
    Консольный тест-пример минимального ядра записи RecorderLnx. Тест создает
    два кадра записи `0001` и `0002`, пишет frame.ini и временный CSV-файл
    теговых sample-ов, затем печатает наглядный лог результата.

  Результат:
    Лог пишется в консоль и в RecorderStorageTest.log рядом с exe. Каталоги
    тестовой записи создаются рядом с exe в отдельном каталоге с timestamp,
    чтобы не перетирать предыдущие результаты.
}

{$mode objfpc}{$H+}

uses
  Classes,
  SysUtils,
  uRecorderDataStorage;

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

procedure PrintFile(const ATitle, AFileName: string);
var
  I: Integer;
  lLines: TStringList;
begin
  LogLine(ATitle + ': ' + AFileName);
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(AFileName);
    for I := 0 to lLines.Count - 1 do
      LogFmt('  %s', [lLines[I]]);
  finally
    lLines.Free;
  end;
end;

procedure WriteDemoFrame(AManager: TRecorderRecordFrameManager;
  const AComment: string; AValueOffset: Double);
var
  lFrameDir: string;
  lWriter: TRecorderCsvTagWriter;
begin
  lFrameDir := AManager.OpenNextFrame;
  LogFmt('FRAME opened no=%d name=%s dir=%s',
    [AManager.CurrentFrameNo, AManager.CurrentFrameName, lFrameDir]);

  AManager.WriteFrameInfo('RecorderStorageTest', AComment);

  lWriter := TRecorderCsvTagWriter.Create;
  try
    lWriter.Open(lFrameDir);
    LogLine('CSV opened: ' + lWriter.FileName);

    lWriter.WriteSample('MemTag', 0.000, 10.0 + AValueOffset);
    lWriter.WriteSample('MemTag', 0.250, 12.5 + AValueOffset);
    lWriter.WriteSample('MemTag', 0.500, 15.0 + AValueOffset);
    lWriter.Flush;
  finally
    lWriter.Free;
  end;

  PrintFile('FRAME info', lFrameDir + 'frame.ini');
  PrintFile('CSV data', lFrameDir + 'tags.csv');
  AManager.CloseFrame;
  LogLine('FRAME closed');
end;

procedure TestRecordFrames;
var
  lManager: TRecorderRecordFrameManager;
  lRootDir: string;
begin
  LogLine('--- Recorder storage test ---');

  lRootDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'recording-test-' + FormatDateTime('yyyymmdd-hhnnss-zzz', Now);
  LogLine('ROOT dir: ' + lRootDir);

  lManager := TRecorderRecordFrameManager.Create(lRootDir);
  try
    AssertEquals(lManager.FindLastFrameNo, 0, 'initial frame count');

    WriteDemoFrame(lManager, 'first frame', 0.0);
    AssertEquals(lManager.FindLastFrameNo, 1, 'last frame after first');
    AssertTrue(DirectoryExists(IncludeTrailingPathDelimiter(lRootDir) + '0001'),
      'frame 0001 directory exists');

    WriteDemoFrame(lManager, 'second frame', 100.0);
    AssertEquals(lManager.FindLastFrameNo, 2, 'last frame after second');
    AssertTrue(DirectoryExists(IncludeTrailingPathDelimiter(lRootDir) + '0002'),
      'frame 0002 directory exists');

    LogLine('RESULT storage test passed.');
  finally
    lManager.Free;
  end;
end;

begin
  OpenLog;
  try
    TestRecordFrames;
  finally
    CloseLog;
  end;
end.
