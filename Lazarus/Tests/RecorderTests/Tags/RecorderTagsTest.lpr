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
  uRecorderTags;

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

    Writeln('RESULT tags registry and signal buffer test passed.');
  finally
    lRegistry.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

begin
  TestTagRegistryAndSignalBuffer;
end.
