unit uRecorderAlarms;

{
  Модуль uRecorderAlarms

  Назначение:
    Кроссплатформенный движок тревог RecorderLnx. В оригинальном Recorder
    компоненты отображения получают состояние тревог через интерфейсы
    IAlarmsControl/IAlarmEventHandler; здесь сохранена та же идея без COM:
    UI обращается к IRecorderAlarmEngine, а изменения состояния публикуются
    в TRecorderEventBus как rceAlarmChanged.

  Логика:
    - TRecorderTagRegistry явно вызывает движок через модель TRecorder;
    - проверяет включенные уставки тега;
    - хранит активность каждой уставки между значениями;
    - публикует событие только при входе в тревогу или выходе из нее.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderCoreServices, uRecorderTags;

type
  { Обобщенный уровень тревоги тега для компонентов отображения. }
  TRecorderAlarmLevel = (
    ralNone,
    ralWarning,
    ralAlarm
  );

  { Данные события изменения тревоги. Владение остается у движка тревог. }
  TRecorderAlarmEventData = class
  private
    fActive: Boolean;
    fKind: TRecorderTagSetpointKind;
    fLevel: TRecorderAlarmLevel;
    fTag: TRecorderTag;
    fThreshold: Double;
    fTimeSec: Double;
    fValue: Double;
  public
    constructor Create(ATag: TRecorderTag; AKind: TRecorderTagSetpointKind;
      ALevel: TRecorderAlarmLevel; AActive: Boolean; ATimeSec, AValue,
      AThreshold: Double);

    property Active: Boolean read fActive;
    property Kind: TRecorderTagSetpointKind read fKind;
    property Level: TRecorderAlarmLevel read fLevel;
    property Tag: TRecorderTag read fTag;
    property Threshold: Double read fThreshold;
    property TimeSec: Double read fTimeSec;
    property Value: Double read fValue;
  end;

  { Интерфейс движка тревог, который используют компоненты отображения. }
  IRecorderAlarmEngine = interface
    ['{E7D7A2D8-6DD0-4ACF-8E0A-4F2693213C28}']
    function GetTagAlarmLevel(ATag: TRecorderTag): TRecorderAlarmLevel;
    function GetTagAlarmText(ATag: TRecorderTag): string;
    function GetTagAlarmColor(ATag: TRecorderTag): LongInt;
    procedure ProcessTagValue(ATag: TRecorderTag; ATimeSec, AValue: Double);
    procedure Reset;
  end;

  { TRecorderAlarmEngine
    Реализация проверки уставок. Входные значения получает только явным вызовом
    ProcessTagValue; EventBus используется лишь для динамического уведомления UI. }
  TRecorderAlarmEngine = class(TInterfacedObject, IRecorderAlarmEngine)
  private type
    TTagAlarmState = class
    public
      Active: array[TRecorderTagSetpointKind] of Boolean;
      OutOfRange: Boolean;
      Tag: TRecorderTag;
    end;
  private
    fEventBus: TRecorderEventBus;
    fLastEventData: TRecorderAlarmEventData;
    fLock: TRTLCriticalSection;
    fStates: TList;
    function AcquireState(ATag: TRecorderTag): TTagAlarmState;
    function EvaluateSetpoint(ATag: TRecorderTag; AKind: TRecorderTagSetpointKind;
      const ASetpoint: TRecorderTagSetpoint; AWasActive: Boolean;
      AValue: Double): Boolean;
    procedure PublishAlarmChange(ATag: TRecorderTag; AKind: TRecorderTagSetpointKind;
      ALevel: TRecorderAlarmLevel; AActive: Boolean; ATimeSec, AValue,
      AThreshold: Double);
  public
    constructor Create(AEventBus: TRecorderEventBus = nil);
    destructor Destroy; override;

    function GetTagAlarmLevel(ATag: TRecorderTag): TRecorderAlarmLevel;
    function GetTagAlarmText(ATag: TRecorderTag): string;
    function GetTagAlarmColor(ATag: TRecorderTag): LongInt;
    procedure ProcessTagValue(ATag: TRecorderTag; ATimeSec, AValue: Double);
    procedure Reset;
  end;

function RecorderAlarmLevelToString(ALevel: TRecorderAlarmLevel): string;
function RecorderSetpointKindToAlarmLevel(
  AKind: TRecorderTagSetpointKind): TRecorderAlarmLevel;
function RecorderSetpointKindToName(AKind: TRecorderTagSetpointKind): string;

implementation

{ RecorderAlarmLevelToString
  Назначение:
    Преобразует значение перечисления TRecorderAlarmLevel в строку ('OK', 'Warning', 'Alarm').
  Вызывается из:
    Вызывается в логах и методе GetTagAlarmText.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
function RecorderAlarmLevelToString(ALevel: TRecorderAlarmLevel): string;
begin
  case ALevel of
    ralNone:
      Result := 'OK';
    ralWarning:
      Result := 'Warning';
    ralAlarm:
      Result := 'Alarm';
  else
    Result := 'Unknown';
  end;
end;

{ RecorderSetpointKindToAlarmLevel
  Назначение:
    Определяет уровень тревоги ( ralWarning или ralAlarm) на основе типа уставки тега.
  Вызывается из:
    Вызывается в методе ProcessTagValue.
  Аналог в оригинальном Recorder:
    Соответствует распределению тревог по критичности в uAlarms.pas оригинального Recorder. }
function RecorderSetpointKindToAlarmLevel(
  AKind: TRecorderTagSetpointKind): TRecorderAlarmLevel;
begin
  case AKind of
    tskHighAlarm, tskLowAlarm:
      Result := ralAlarm;
    tskHighWarning, tskLowWarning:
      Result := ralWarning;
  else
    Result := ralNone;
  end;
end;

{ RecorderSetpointKindToName
  Назначение:
    Преобразует значение TRecorderTagSetpointKind в строковое имя на английском языке.
  Вызывается из:
    Используется для форматирования текстовых сообщений о тревогах в PublishAlarmChange.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
function RecorderSetpointKindToName(AKind: TRecorderTagSetpointKind): string;
begin
  case AKind of
    tskHighAlarm:
      Result := 'High alarm';
    tskHighWarning:
      Result := 'High warning';
    tskLowWarning:
      Result := 'Low warning';
    tskLowAlarm:
      Result := 'Low alarm';
  else
    Result := 'Unknown';
  end;
end;

{ TRecorderAlarmEventData.Create
  Назначение:
    Создает объект данных для публикации события тревоги на шине EventBus, сохраняя метки времени, значение и порог.
  Вызывается из:
    Вызывается в методе PublishAlarmChange при срабатывании тревоги.
  Аналог в оригинальном Recorder:
    Соответствует передаче параметров тревоги обработчикам IAlarmEventHandler в оригинальном Recorder. }
constructor TRecorderAlarmEventData.Create(ATag: TRecorderTag;
  AKind: TRecorderTagSetpointKind; ALevel: TRecorderAlarmLevel;
  AActive: Boolean; ATimeSec, AValue, AThreshold: Double);
begin
  inherited Create;
  fTag := ATag;
  fKind := AKind;
  fLevel := ALevel;
  fActive := AActive;
  fTimeSec := ATimeSec;
  fValue := AValue;
  fThreshold := AThreshold;
end;

{ TRecorderAlarmEngine.Create
  Назначение:
    Конструктор движка тревог. Создает список состояний и подписывается на шину событий, если она передана.
  Вызывается из:
    Вызывается из конструктора TRecorder.Create.
  Аналог в оригинальном Recorder:
    Аналогичен инициализации контроллера тревог в оригинальном Recorder. }
constructor TRecorderAlarmEngine.Create(AEventBus: TRecorderEventBus);
begin
  inherited Create;
  InitCriticalSection(fLock);
  fStates := TList.Create;
  fEventBus := AEventBus;
end;

{ TRecorderAlarmEngine.Destroy
  Назначение:
    Деструктор движка тревог. Отписывается от шины событий и освобождает память списков состояний.
  Вызывается из:
    Вызывается при уничтожении фасада TRecorder.
  Аналог в оригинальном Recorder:
    Очистка ресурсов тревог оригинального Recorder. }
destructor TRecorderAlarmEngine.Destroy;
begin
  fEventBus := nil;
  Reset;
  fStates.Free;
  fLastEventData.Free;
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

{ TRecorderAlarmEngine.AcquireState
  Назначение:
    Возвращает структуру TTagAlarmState для тега. Если структура еще не создана, создает и добавляет ее в список.
  Вызывается из:
    Вызывается в методах GetTagAlarmLevel, GetTagAlarmColor, GetTagAlarmText и ProcessTagValue.
  Аналог в оригинальном Recorder:
    Соответствует получению состояния уставки тега в uAlarms.pas оригинального Recorder. }
function TRecorderAlarmEngine.AcquireState(ATag: TRecorderTag): TTagAlarmState;
var
  I: Integer;
begin
  Result := nil;
  if ATag = nil then
    Exit;

  for I := 0 to fStates.Count - 1 do
    if TTagAlarmState(fStates[I]).Tag = ATag then
      Exit(TTagAlarmState(fStates[I]));

  Result := TTagAlarmState.Create;
  Result.Tag := ATag;
  fStates.Add(Result);
end;

{ TRecorderAlarmEngine.EvaluateSetpoint
  Назначение:
    Проверяет значение тега на прохождение уставки с учетом гистерезиса в процентах, если он включен.
  Вызывается из:
    Вызывается из ProcessTagValue для каждой из 4 уставок тега.
  Аналог в оригинальном Recorder:
    Полный аналог алгоритма сравнения с гистерезисом в uAlarms.pas оригинального Recorder. }
function TRecorderAlarmEngine.EvaluateSetpoint(ATag: TRecorderTag;
  AKind: TRecorderTagSetpointKind; const ASetpoint: TRecorderTagSetpoint;
  AWasActive: Boolean; AValue: Double): Boolean;
var
  lDelta: Double;
  lLeaveThreshold: Double;
begin
  Result := False;
  if (ATag = nil) or (not ASetpoint.Enabled) then
    Exit;

  lDelta := 0.0;
  if ATag.SetpointHysteresisEnabled and (ASetpoint.HysteresisPercent > 0) then
    lDelta := Abs(ASetpoint.Threshold) * ASetpoint.HysteresisPercent / 100.0;

  case AKind of
    tskHighAlarm, tskHighWarning:
      begin
        if AWasActive then
        begin
          lLeaveThreshold := ASetpoint.Threshold - lDelta;
          Result := AValue >= lLeaveThreshold;
        end
        else
          Result := AValue >= ASetpoint.Threshold;
      end;
    tskLowWarning, tskLowAlarm:
      begin
        if AWasActive then
        begin
          lLeaveThreshold := ASetpoint.Threshold + lDelta;
          Result := AValue <= lLeaveThreshold;
        end
        else
          Result := AValue <= ASetpoint.Threshold;
      end;
  end;
end;

{ TRecorderAlarmEngine.PublishAlarmChange
  Назначение:
    Создает событие rceAlarmChanged, форматирует текстовое сообщение и публикует его на шине событий.
  Вызывается из:
    Вызывается из ProcessTagValue при изменении состояния активности любой из уставок.
  Аналог в оригинальном Recorder:
    Соответствует отправке уведомлений об изменении состояния тревог на UI. }
procedure TRecorderAlarmEngine.PublishAlarmChange(ATag: TRecorderTag;
  AKind: TRecorderTagSetpointKind; ALevel: TRecorderAlarmLevel; AActive: Boolean;
  ATimeSec, AValue, AThreshold: Double);
var
  lEvent: TRecorderEvent;
  lText: string;
begin
  if (fEventBus = nil) or (ATag = nil) then
    Exit;

  if AActive then
    lText := Format('%s: %s entered, value=%.3f threshold=%.3f',
      [ATag.Name, RecorderSetpointKindToName(AKind), AValue, AThreshold])
  else
    lText := Format('%s: %s left, value=%.3f threshold=%.3f',
      [ATag.Name, RecorderSetpointKindToName(AKind), AValue, AThreshold]);

  fLastEventData.Free;
  fLastEventData := TRecorderAlarmEventData.Create(ATag, AKind, ALevel,
    AActive, ATimeSec, AValue, AThreshold);
  lEvent := TRecorderEventBus.MakeEvent(rceAlarmChanged, Self, ATag.Name,
    lText, Ord(ALevel), fLastEventData);
  fEventBus.Publish(lEvent);
end;

{ TRecorderAlarmEngine.GetTagAlarmLevel
  Назначение:
    Возвращает максимальный активный уровень тревоги для конкретного тега (ralNone, ralWarning, ralAlarm).
  Вызывается из:
    Вызывается таблицами тегов UI и компонентами отображения (для подсветки ячеек).
  Аналог в оригинальном Recorder:
    Аналог метода IAlarmsControl.GetAlarmLevel в uAlarms.pas оригинального Recorder. }
function TRecorderAlarmEngine.GetTagAlarmLevel(
  ATag: TRecorderTag): TRecorderAlarmLevel;
var
  lState: TTagAlarmState;
begin
  Result := ralNone;
  EnterCriticalSection(fLock);
  try
    lState := AcquireState(ATag);
    if lState = nil then
      Exit;

    if lState.Active[tskHighAlarm] or lState.Active[tskLowAlarm] then
      Result := ralAlarm
    else if lState.Active[tskHighWarning] or lState.Active[tskLowWarning] then
      Result := ralWarning;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderAlarmEngine.GetTagAlarmText
  Назначение:
    Возвращает строковое описание текущего состояния тревоги для тега.
  Вызывается из:
    Вызывается табличными представлениями тегов на форме.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
function TRecorderAlarmEngine.GetTagAlarmText(ATag: TRecorderTag): string;
begin
  Result := RecorderAlarmLevelToString(GetTagAlarmLevel(ATag));
end;

{ TRecorderAlarmEngine.GetTagAlarmColor
  Назначение:
    Возвращает цвет активной уставки тега для отображения.
  Вызывается из:
    Вызывается таблицами тегов UI и графиками для смены цвета пера.
  Аналог в оригинальном Recorder:
    Соответствует получению цвета тревоги тега в оригинальном Recorder. }
function TRecorderAlarmEngine.GetTagAlarmColor(ATag: TRecorderTag): LongInt;
var
  lState: TTagAlarmState;
begin
  // Zero is the neutral sentinel used by the UI for a tag without an active
  // alarm. Gray is reserved for an explicitly detected range violation.
  Result := 0;
  EnterCriticalSection(fLock);
  try
    lState := AcquireState(ATag);
    if lState = nil then
      Exit;

    if lState.OutOfRange then
      Exit($808080);

    if lState.Active[tskHighAlarm] then
      Result := ATag.Setpoints[tskHighAlarm].Color
    else if lState.Active[tskLowAlarm] then
      Result := ATag.Setpoints[tskLowAlarm].Color
    else if lState.Active[tskHighWarning] then
      Result := ATag.Setpoints[tskHighWarning].Color
    else if lState.Active[tskLowWarning] then
      Result := ATag.Setpoints[tskLowWarning].Color;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderAlarmEngine.ProcessTagValue
  Назначение:
    Центральный метод движка. Проверяет новое значение тега по всем 4 уставкам (HighAlarm, HighWarning, LowWarning, LowAlarm) и генерирует события при изменении их активности.
  Вызывается из:
    Вызывается из HandleEvent при получении новых данных тега.
  Аналог в оригинальном Recorder:
    Аналог метода IAlarmsControl.Process в uAlarms.pas оригинального Recorder. }
procedure TRecorderAlarmEngine.ProcessTagValue(ATag: TRecorderTag; ATimeSec,
  AValue: Double);
var
  lActive: Boolean;
  lKind: TRecorderTagSetpointKind;
  lLevel: TRecorderAlarmLevel;
  lSetpoint: TRecorderTagSetpoint;
  lState: TTagAlarmState;
begin
  EnterCriticalSection(fLock);
  try
    lState := AcquireState(ATag);
    if lState = nil then
      Exit;

    lState.OutOfRange := ATag.SetpointRangeControlEnabled and
      (ATag.RangeMax > ATag.RangeMin) and
      ((AValue < ATag.RangeMin) or (AValue > ATag.RangeMax));

    for lKind := Low(TRecorderTagSetpointKind) to High(TRecorderTagSetpointKind) do
    begin
      lSetpoint := ATag.Setpoints[lKind];
      lActive := EvaluateSetpoint(ATag, lKind, lSetpoint,
        lState.Active[lKind], AValue);
      if lActive = lState.Active[lKind] then
        Continue;

      lState.Active[lKind] := lActive;
      lLevel := RecorderSetpointKindToAlarmLevel(lKind);
      PublishAlarmChange(ATag, lKind, lLevel, lActive, ATimeSec, AValue,
        lSetpoint.Threshold);
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderAlarmEngine.Reset
  Назначение:
    Очищает все состояния тревог и сбрасывает списки.
  Вызывается из:
    Вызывается при остановке сбора/записи или изменении конфигурации.
  Аналог в оригинальном Recorder:
    Сброс утилиты тревог в оригинальном Recorder. }
procedure TRecorderAlarmEngine.Reset;
var
  I: Integer;
begin
  EnterCriticalSection(fLock);
  try
    for I := 0 to fStates.Count - 1 do
      TObject(fStates[I]).Free;
    fStates.Clear;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

end.
