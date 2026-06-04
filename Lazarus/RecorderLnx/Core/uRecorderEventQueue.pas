unit uRecorderEventQueue;

{
  Модуль uRecorderEventQueue

  Назначение:
    Потокобезопасная очередь снимков событий RecorderLnx. Рабочие потоки
    источников данных публикуют события в TRecorderEventBus синхронно, то есть
    обработчик вызывается в том же worker-thread. Этот модуль быстро копирует
    необходимые поля события в самостоятельный объект, чтобы UI thread позднее
    мог вычитать очередь таймером и не трогал LCL из фоновых потоков.

  Место в архитектуре:
    Core/domain. Модуль не зависит от LCL и подходит для Windows/Linux. UI-слой
    будет использовать TRecorderEventSnapshotQueue как границу между
    многопоточным сбором данных и визуальными компонентами формуляров.

  Важная деталь:
    TRecorderTagRegistry переиспользует объект TRecorderTagUpdateEventData при
    публикации новых значений тегов. Поэтому очередь не хранит AEvent.Data, а
    копирует имя тега, время и значение в TRecorderEventSnapshot.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderCoreServices,
  uRecorderTags,
  uRecorderAlarms;

type
  { Класс исключения для очереди событий }
  ERecorderEventQueueError = class(Exception);

  { TRecorderEventSnapshot
    Самостоятельный снимок события core-шины.
    
    Kind      - тип исходного события.
    Name      - имя события или имя тега для rceDataUpdated.
    Text      - текстовое поле события.
    IntValue  - числовое поле события.
    TagName   - имя обновленного тега, если событие несет данные тега.
    TimeSec   - время sample-а в секундах для обновления тега.
    Value     - числовое значение sample-а для обновления тега.
    HasTagData - True, если TagName/TimeSec/Value заполнены из
      TRecorderTagUpdateEventData. }
  TRecorderEventSnapshot = class
  private
    fHasTagData: Boolean;          { Флаг наличия данных тега }
    fAlarmActive: Boolean;         { Флаг входа в тревогу; False - выход }
    fAlarmKind: TRecorderTagSetpointKind; { Тип сработавшей уставки }
    fAlarmLevel: TRecorderAlarmLevel;     { Уровень тревоги }
    fAlarmThreshold: Double;       { Порог сработавшей уставки }
    fHasAlarmData: Boolean;        { Флаг наличия данных тревоги }
    fIntValue: Int64;              { Числовой параметр }
    fKind: TRecorderEventKind;     { Тип события }
    fName: string;                 { Имя события }
    fTagName: string;              { Имя тега }
    fText: string;                 { Текстовый параметр }
    fTimeSec: Double;              { Время измерения }
    fValue: Double;                { Значение измерения }
    fSampleCount: Integer;         { Число точек в блоке }
    fTimes: TRecorderDoubleArray;  { Времена блока }
    fValues: TRecorderDoubleArray; { Значения блока }
  public
    { Создает снимок на основе события core-шины.
      AEvent - исходное событие. Объект AEvent.Data не сохраняется, из него
        копируются только безопасные значения. }
    constructor CreateFromEvent(const AEvent: TRecorderEvent);

    property Kind: TRecorderEventKind read fKind;
    property Name: string read fName;
    property Text: string read fText;
    property IntValue: Int64 read fIntValue;
    property HasTagData: Boolean read fHasTagData;
    property AlarmActive: Boolean read fAlarmActive;
    property AlarmKind: TRecorderTagSetpointKind read fAlarmKind;
    property AlarmLevel: TRecorderAlarmLevel read fAlarmLevel;
    property AlarmThreshold: Double read fAlarmThreshold;
    property HasAlarmData: Boolean read fHasAlarmData;
    property TagName: string read fTagName;
    property TimeSec: Double read fTimeSec;
    property Value: Double read fValue;
    property SampleCount: Integer read fSampleCount;
    property Times: TRecorderDoubleArray read fTimes;
    property Values: TRecorderDoubleArray read fValues;
  end;

  { TRecorderEventSnapshotQueue
    Очередь снимков событий. Подписывается на TRecorderEventBus, копирует
    входящие события в собственный список и позволяет вызывающему коду забирать
    их по одному. Возвращенный Pop объект принадлежит вызывающему коду. }
  TRecorderEventSnapshotQueue = class
  private
    fEventBus: TRecorderEventBus;      { Ссылка на шину событий }
    fItems: TList;                     { Список накопленных снимков (TRecorderEventSnapshot) }
    fLock: TRTLCriticalSection;        { Критическая секция защиты очереди }
    fToken: Integer;                   { Токен подписки на события }
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    function GetCount: Integer;
  public
    { AEventBus - необязательная шина событий для автоматической подписки.
      Владение шиной не передается. }
    constructor Create(AEventBus: TRecorderEventBus = nil);
    { Деструктор отписывается от шины и очищает список }
    destructor Destroy; override;

    { Подписывает очередь на шину событий.
      AEventBus - шина событий. Владение не передается. Очередь может быть
        подключена только к одной шине одновременно. }
    procedure Attach(AEventBus: TRecorderEventBus);

    { Отписывает очередь от текущей шины, если она была подключена. }
    procedure Detach;

    { Удаляет все накопленные снимки событий. }
    procedure Clear;

    { Возвращает самый старый снимок события или nil, если очередь пуста.
      Владение возвращенным объектом переходит вызывающему коду. }
    function Pop: TRecorderEventSnapshot;

    property Count: Integer read GetCount;
    property EventBus: TRecorderEventBus read fEventBus;
  end;

implementation

{ TRecorderEventSnapshot }

constructor TRecorderEventSnapshot.CreateFromEvent(const AEvent: TRecorderEvent);
var
  I: Integer;
  lAlarmData: TRecorderAlarmEventData;
  lTagData: TRecorderTagUpdateEventData;
begin
  inherited Create;

  fKind := AEvent.Kind;
  fName := AEvent.Name;
  fText := AEvent.Text;
  fIntValue := AEvent.IntValue;

  if AEvent.Data is TRecorderTagUpdateEventData then
  begin
    lTagData := TRecorderTagUpdateEventData(AEvent.Data);
    fHasTagData := True;
    if lTagData.Tag <> nil then
      fTagName := lTagData.Tag.Name
    else
      fTagName := AEvent.Name;
    fTimeSec := lTagData.TimeSec;
    fValue := lTagData.Value;
    fSampleCount := lTagData.SampleCount;
    SetLength(fTimes, fSampleCount);
    SetLength(fValues, fSampleCount);
    for I := 0 to fSampleCount - 1 do
    begin
      fTimes[I] := lTagData.Times[I];
      fValues[I] := lTagData.Values[I];
    end;
  end
  else if AEvent.Data is TRecorderAlarmEventData then
  begin
    lAlarmData := TRecorderAlarmEventData(AEvent.Data);
    fHasAlarmData := True;
    fAlarmActive := lAlarmData.Active;
    fAlarmKind := lAlarmData.Kind;
    fAlarmLevel := lAlarmData.Level;
    fAlarmThreshold := lAlarmData.Threshold;
    if lAlarmData.Tag <> nil then
      fTagName := lAlarmData.Tag.Name
    else
      fTagName := AEvent.Name;
    fTimeSec := lAlarmData.TimeSec;
    fValue := lAlarmData.Value;
    fSampleCount := 1;
    SetLength(fTimes, 1);
    SetLength(fValues, 1);
    fTimes[0] := fTimeSec;
    fValues[0] := fValue;
  end;
end;

{ TRecorderEventSnapshotQueue }

constructor TRecorderEventSnapshotQueue.Create(AEventBus: TRecorderEventBus);
begin
  inherited Create;
  fItems := TList.Create;
  InitCriticalSection(fLock);
  if AEventBus <> nil then
    Attach(AEventBus);
end;

destructor TRecorderEventSnapshotQueue.Destroy;
begin
  Detach;
  Clear;
  DoneCriticalSection(fLock);
  fItems.Free;
  inherited Destroy;
end;

procedure TRecorderEventSnapshotQueue.Attach(AEventBus: TRecorderEventBus);
begin
  if AEventBus = nil then
    raise ERecorderEventQueueError.Create('Event bus cannot be nil');
  if fEventBus <> nil then
    raise ERecorderEventQueueError.Create('Event queue is already attached');

  fEventBus := AEventBus;
  fToken := fEventBus.Subscribe(@HandleEvent);
end;

procedure TRecorderEventSnapshotQueue.Detach;
begin
  if (fEventBus <> nil) and (fToken <> 0) then
    fEventBus.Unsubscribe(fToken);
  fToken := 0;
  fEventBus := nil;
end;

procedure TRecorderEventSnapshotQueue.Clear;
var
  I: Integer;
begin
  EnterCriticalSection(fLock);
  try
    for I := 0 to fItems.Count - 1 do
      TObject(fItems[I]).Free;
    fItems.Clear;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderEventSnapshotQueue.GetCount: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result := fItems.Count;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderEventSnapshotQueue.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  lSnapshot: TRecorderEventSnapshot;
begin
  lSnapshot := TRecorderEventSnapshot.CreateFromEvent(AEvent);
  EnterCriticalSection(fLock);
  try
    fItems.Add(lSnapshot);
    lSnapshot := nil;
  finally
    LeaveCriticalSection(fLock);
    lSnapshot.Free;
  end;
end;

function TRecorderEventSnapshotQueue.Pop: TRecorderEventSnapshot;
begin
  EnterCriticalSection(fLock);
  try
    if fItems.Count = 0 then
      Exit(nil);

    Result := TRecorderEventSnapshot(fItems[0]);
    fItems.Delete(0);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

end.
