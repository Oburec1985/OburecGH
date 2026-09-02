program RecorderTagsTest;

{
  RecorderTagsTest

  Назначение:
    Тест-пример минимальной модели тегов RecorderLnx. Тест создает registry,
    публикует значения, проверяет кольцевой буфер и печатает наглядный лог
    обновлений рядом с проверками.
}

{$mode objfpc}{$H+}

uses
  SysUtils,
  uRecorderCoreServices,
  uRecorderTags,
  uRecorderAlarms;

type
  TTagEventProbe = class
  public
    Count: Integer;
    LastTagName: string;
    LastValue: Double;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
  end;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure AssertEquals(const AActual, AExpected, AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %s, got %s',
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
  Writeln(ATitle, ' count=', ASnapshot.Count);
  for I := 0 to ASnapshot.Count - 1 do
    Writeln(Format('  [%d] t=%.3f value=%.3f',
      [I, ASnapshot.Times[I], ASnapshot.Values[I]]));
end;

procedure TTagEventProbe.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  lData: TRecorderTagUpdateEventData;
begin
  if AEvent.Kind <> rceDataUpdated then
    Exit;

  lData := TRecorderTagUpdateEventData(AEvent.Data);
  Inc(Count);
  LastTagName := lData.Tag.Name;
  LastValue := lData.Value;

  Writeln(Format('EVENT rceDataUpdated tag=%s t=%.3f value=%.3f text=%s',
    [lData.Tag.Name, lData.TimeSec, lData.Value, AEvent.Text]));
end;

procedure TestTagRegistryAndSignalBuffer;
var
  lBus: TRecorderEventBus;
  lProbe: TTagEventProbe;
  lRegistry: TRecorderTagRegistry;
  lMemTag: TRecorderTag;
  lSnapshot: TRecorderSignalSnapshot;
begin
  Writeln('--- Recorder tags test ---');

  lBus := TRecorderEventBus.Create;
  lProbe := TTagEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  try
    lBus.Subscribe(@lProbe.HandleEvent);

    lMemTag := lRegistry.CreateTag('MemTag', 3);
    lMemTag.Address := 'virtual';
    lMemTag.UnitName := 'm';
    lMemTag.Description := 'Debug memory tag';

    Writeln(Format('CREATE tag id=%d name=%s address=%s unit=%s',
      [lMemTag.Id, lMemTag.Name, lMemTag.Address, lMemTag.UnitName]));

    lRegistry.PublishValue('MemTag', 0.0, 10.0);
    lRegistry.PublishValue('MemTag', 0.1, 11.0);
    lRegistry.PublishValue('MemTag', 0.2, 12.0);
    lRegistry.PublishValue('MemTag', 0.3, 13.0);

    lSnapshot := lMemTag.Snapshot;
    PrintSnapshot('SNAPSHOT MemTag ring buffer', lSnapshot);

    AssertEquals(lRegistry.TagCount, 1, 'tag count');
    AssertTrue(lRegistry.FindByName('memtag') = lMemTag, 'case-insensitive tag lookup');
    AssertTrue(lRegistry.FindById(lMemTag.Id) = lMemTag, 'id lookup');
    AssertEquals(lProbe.Count, 4, 'data updated event count');
    AssertEquals(lProbe.LastTagName, 'MemTag', 'last event tag');
    AssertEquals(lProbe.LastValue, 13.0, 'last event value');

    AssertEquals(lSnapshot.Count, 3, 'snapshot count keeps capacity');
    AssertEquals(lSnapshot.Times[0], 0.1, 'oldest sample time after ring overwrite');
    AssertEquals(lSnapshot.Values[0], 11.0, 'oldest sample value after ring overwrite');
    AssertEquals(lSnapshot.Values[2], 13.0, 'latest sample value');

    lMemTag.EnsureBufferCapacity(6);
    lRegistry.PublishValue('MemTag', 0.4, 14.0);
    lRegistry.PublishValue('MemTag', 0.5, 15.0);
    lRegistry.PublishValue('MemTag', 0.6, 16.0);
    lSnapshot := lMemTag.Snapshot;
    AssertEquals(lSnapshot.Count, 6, 'expanded buffer keeps older samples');
    AssertEquals(lSnapshot.Times[0], 0.1, 'expanded buffer first preserved time');
    AssertEquals(lSnapshot.Values[5], 16.0, 'expanded buffer latest value');

    { Повторный запуск аппаратного источника начинает время снова с нуля.
      Старая эпоха не должна нарушать сортировку снимка для осциллограмм. }
    lRegistry.PublishValue('MemTag', 0.0, 20.0);
    lRegistry.PublishValue('MemTag', 0.1, 21.0);
    lSnapshot := lMemTag.Snapshot;
    AssertEquals(lSnapshot.Count, 2, 'time rewind starts a new signal epoch');
    AssertEquals(lSnapshot.Times[0], 0.0, 'new epoch starts at zero');
    AssertEquals(lSnapshot.Values[1], 21.0, 'new epoch keeps subsequent samples');

    Writeln('RESULT tags registry and signal buffer test passed.');
  finally
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestTagBlockEstimates;
var
  J: Integer;
  lBus: TRecorderEventBus;
  lProbe: TTagEventProbe;
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lBlock: TRecorderSignalSnapshot;
  lEstimate: TRecorderTagEstimate;
  lBlockCursor: QWord;
  lCursor: QWord;
  lTimes: array[0..2] of Double;
  lValues: array[0..2] of Double;
begin
  Writeln('--- Recorder tag block estimates test ---');

  lBus := TRecorderEventBus.Create;
  lProbe := TTagEventProbe.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  try
    lBus.Subscribe(@lProbe.HandleEvent);
    lTag := lRegistry.CreateTag('BlockTag', 8);
    lTag.ConfigureBlockBuffer(3, 3);

    lTimes[0] := 10.0;
    lTimes[1] := 10.1;
    lTimes[2] := 10.2;
    lValues[0] := 1.0;
    lValues[1] := 2.0;
    lValues[2] := 4.0;

    lRegistry.PublishBlock('BlockTag', lTimes, lValues, 3);

    lBlock := lTag.LastBlockSnapshot;
    PrintSnapshot('SNAPSHOT BlockTag last block', lBlock);

    AssertEquals(lProbe.Count, 0, 'measurement blocks are not copied through EventBus');
    AssertEquals(lBlock.Count, 3, 'last block count');
    AssertEquals(lBlock.Times[0], 10.0, 'last block first time');
    AssertEquals(lBlock.Values[2], 4.0, 'last block last value');
    lCursor := 0;
    lBlock := lTag.SignalBuffer.SnapshotSince(lCursor);
    AssertEquals(lBlock.Count, 3, 'cursor consumer receives unread block');
    lBlock := lTag.SignalBuffer.SnapshotSince(lCursor);
    AssertEquals(lBlock.Count, 0, 'cursor consumer does not receive duplicates');
    lBlockCursor := 0;
    AssertTrue(lTag.SignalBuffer.SnapshotNextBlock(lBlockCursor, lBlock),
      'block cursor receives unread block');
    AssertEquals(lBlock.Count, 3, 'block cursor returns configured logical block');
    AssertTrue(not lTag.SignalBuffer.SnapshotNextBlock(lBlockCursor, lBlock),
      'block cursor does not receive duplicates');

    lEstimate := lTag.Estimate(tekMean);
    AssertTrue(lEstimate.Valid, 'mean estimate valid');
    AssertEquals(lEstimate.Value, 7.0 / 3.0, 'mean estimate');
    lEstimate := lTag.Estimate(tekRmsValue);
    AssertEquals(lEstimate.Value, Sqrt(7.0), 'rms value estimate');
    lEstimate := lTag.Estimate(tekRmsDeviation);
    AssertEquals(lEstimate.Value, Sqrt(7.0 / 3.0), 'rms deviation estimate');
    lEstimate := lTag.Estimate(tekPeak);
    AssertEquals(lEstimate.Value, 1.5, 'peak estimate');
    lEstimate := lTag.Estimate(tekPeakToPeak);
    AssertEquals(lEstimate.Value, 3.0, 'peak-to-peak estimate');
    lEstimate := lTag.Estimate(tekMinimum);
    AssertEquals(lEstimate.Value, 1.0, 'minimum estimate');
    lEstimate := lTag.Estimate(tekMaximum);
    AssertEquals(lEstimate.Value, 4.0, 'maximum estimate');
    lEstimate := lTag.Estimate(tekPeakToPeakByRmsDeviation);
    AssertEquals(lEstimate.Value, 2.0 * Sqrt(2.0) * Sqrt(7.0 / 3.0),
      'p2p by rmsd estimate');

    lTimes[0] := 0.0;
    lTimes[1] := 0.1;
    lTimes[2] := 0.2;
    lValues[0] := 5.0;
    lValues[1] := 6.0;
    lValues[2] := 7.0;
    lRegistry.PublishBlock('BlockTag', lTimes, lValues, 3);
    lBlock := lTag.Snapshot;
    AssertEquals(lBlock.Count, 3, 'block time rewind starts a new signal epoch');
    AssertEquals(lBlock.Times[0], 0.0, 'rewound block starts at zero');
    AssertEquals(lBlock.Values[2], 7.0, 'rewound block remains complete');

    lTag.ConfigureBlockBuffer(3, 3);
    for J := 0 to 3 do
    begin
      lTimes[0] := 1.0 + J * 0.2;
      lTimes[1] := lTimes[0] + 0.1;
      lValues[0] := J * 2;
      lValues[1] := J * 2 + 1;
      lRegistry.PublishBlock('BlockTag', lTimes, lValues, 2);
    end;
    lBlock := lTag.Snapshot;
    AssertEquals(lBlock.Count, 8,
      'several small transport blocks fill sample-capacity ring');

    lRegistry.PublishValue('BlockTag', 11.0, 9.0);
    lBlock := lTag.LastBlockSnapshot;
    AssertEquals(lBlock.Count, 1, 'single value updates last block');
    lEstimate := lTag.Estimate(tekMean);
    AssertEquals(lEstimate.Value, 9.0, 'single value estimate');

    Writeln('RESULT tag block estimates test passed.');
  finally
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestReusableRangeSnapshot;
var
  I: Integer;
  lBuffer: TRecorderSignalBuffer;
  lCount: Integer;
  lFirstValueAddress: Pointer;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
begin
  Writeln('--- Reusable range snapshot test ---');
  lBuffer := TRecorderSignalBuffer.Create(5);
  try
    for I := 0 to 6 do
      lBuffer.AddSample(I, I * 10);

    lBuffer.SnapshotRangeInto(4.0, False, lTimes, lValues, lCount);
    AssertEquals(lCount, 3, 'range count after ring wrap');
    AssertEquals(lTimes[0], 4.0, 'range starts at requested time');
    AssertEquals(lValues[2], 60.0, 'range keeps latest value');
    lFirstValueAddress := @lValues[0];

    lBuffer.SnapshotRangeInto(5.0, True, lTimes, lValues, lCount);
    AssertEquals(lCount, 3, 'range includes previous boundary sample');
    AssertEquals(lTimes[0], 4.0, 'previous boundary time');
    AssertTrue(@lValues[0] = lFirstValueAddress,
      'caller-owned range buffer is reused when capacity is sufficient');
    Writeln('RESULT reusable range snapshot test passed.');
  finally
    lBuffer.Free;
  end;
end;

procedure TestReusableBlockSnapshot;
var
  I: Integer;
  lBlock: TRecorderSignalSnapshot;
  lBuffer: TRecorderSignalBuffer;
  lCursor: QWord;
  lTimes: array[0..1] of Double;
  lValues: array[0..1] of Double;
  lTimesAddress: Pointer;
  lValuesAddress: Pointer;
begin
  Writeln('--- Reusable logical block snapshot test ---');
  lBuffer := TRecorderSignalBuffer.Create(4);
  try
    lBuffer.ConfigureBlockRing(2, 2);
    for I := 0 to 2 do
    begin
      lTimes[0] := I * 2;
      lTimes[1] := I * 2 + 1;
      lValues[0] := I * 20;
      lValues[1] := I * 20 + 10;
      lBuffer.AddSamples(lTimes, lValues, 2);
    end;

    lCursor := 0;
    AssertTrue(lBuffer.SnapshotNextBlockInto(lCursor, lBlock.Times,
      lBlock.Values, lBlock.Count), 'overwritten cursor receives oldest available block');
    AssertEquals(lBlock.Count, 2, 'reusable block count');
    AssertEquals(lBlock.Times[0], 2.0, 'overwritten cursor starts at oldest retained block');
    AssertEquals(lBlock.Values[1], 30.0, 'oldest retained block preserves order');
    lTimesAddress := @lBlock.Times[0];
    lValuesAddress := @lBlock.Values[0];

    AssertTrue(lBuffer.SnapshotNextBlockInto(lCursor, lBlock.Times,
      lBlock.Values, lBlock.Count), 'reusable reader receives wrapped block');
    AssertEquals(lBlock.Times[0], 4.0, 'wrapped block starts in order');
    AssertEquals(lBlock.Values[1], 50.0, 'wrapped block ends in order');
    AssertTrue(@lBlock.Times[0] = lTimesAddress,
      'time buffer address remains stable between blocks');
    AssertTrue(@lBlock.Values[0] = lValuesAddress,
      'value buffer address remains stable between blocks');

    AssertTrue(not lBuffer.SnapshotNextBlockInto(lCursor, lBlock.Times,
      lBlock.Values, lBlock.Count), 'reusable reader does not duplicate blocks');
    AssertEquals(lBlock.Count, 0, 'empty reusable read reports zero valid samples');
    AssertTrue(@lBlock.Times[0] = lTimesAddress,
      'empty reusable read retains allocated time buffer');
    AssertTrue(@lBlock.Values[0] = lValuesAddress,
      'empty reusable read retains allocated value buffer');
    Writeln('RESULT reusable logical block snapshot test passed.');
  finally
    lBuffer.Free;
  end;
end;

procedure TestTagAlarmEngine;
var
  lEngine: IRecorderAlarmEngine;
  lHighAlarm: TRecorderTagSetpoint;
  lHighWarning: TRecorderTagSetpoint;
  lTag: TRecorderTag;
begin
  Writeln('--- Recorder tag alarm engine test ---');

  lTag := TRecorderTag.Create(1, 'AlarmTag', 8);
  try
    lHighWarning := lTag.Setpoints[tskHighWarning];
    lHighWarning.Enabled := True;
    lHighWarning.Threshold := 5.0;
    lTag.Setpoints[tskHighWarning] := lHighWarning;

    lHighAlarm := lTag.Setpoints[tskHighAlarm];
    lHighAlarm.Enabled := True;
    lHighAlarm.Threshold := 10.0;
    lTag.Setpoints[tskHighAlarm] := lHighAlarm;

    lEngine := TRecorderAlarmEngine.Create as IRecorderAlarmEngine;
    lEngine.ProcessTagValue(lTag, 0.0, 0.0);
    AssertEquals(Ord(lEngine.GetTagAlarmLevel(lTag)), Ord(ralNone),
      'alarm level starts as OK');

    lEngine.ProcessTagValue(lTag, 0.1, 6.0);
    AssertEquals(Ord(lEngine.GetTagAlarmLevel(lTag)), Ord(ralWarning),
      'warning level after high warning threshold');

    lEngine.ProcessTagValue(lTag, 0.2, 12.0);
    AssertEquals(Ord(lEngine.GetTagAlarmLevel(lTag)), Ord(ralAlarm),
      'alarm level after high alarm threshold');

    lEngine.ProcessTagValue(lTag, 0.3, 0.0);
    AssertEquals(Ord(lEngine.GetTagAlarmLevel(lTag)), Ord(ralNone),
      'alarm level resets after value returns to normal');

    Writeln('RESULT tag alarm engine test passed.');
  finally
    lTag.Free;
  end;
end;

begin
  if (ParamCount > 0) and SameText(ParamStr(1), '--range-only') then
  begin
    TestReusableRangeSnapshot;
    Halt(0);
  end;
  if (ParamCount > 0) and SameText(ParamStr(1), '--block-reuse-only') then
  begin
    TestReusableBlockSnapshot;
    Halt(0);
  end;
  TestTagRegistryAndSignalBuffer;
  TestTagBlockEstimates;
  TestReusableRangeSnapshot;
  TestReusableBlockSnapshot;
  TestTagAlarmEngine;
end.
