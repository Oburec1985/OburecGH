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
    - движок подписывается на rceDataUpdated;
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
    Реализация проверки уставок. Может работать как подписчик TRecorderEventBus
    или вызываться явно через ProcessTagValue. }
  TRecorderAlarmEngine = class(TInterfacedObject, IRecorderAlarmEngine)
  private type
    TTagAlarmState = class
    public
      Active: array[TRecorderTagSetpointKind] of Boolean;
      Tag: TRecorderTag;
    end;
  private
    fEventBus: TRecorderEventBus;
    fLastEventData: TRecorderAlarmEventData;
    fStates: TList;
    fToken: Integer;
    function AcquireState(ATag: TRecorderTag): TTagAlarmState;
    function EvaluateSetpoint(ATag: TRecorderTag; AKind: TRecorderTagSetpointKind;
      const ASetpoint: TRecorderTagSetpoint; AWasActive: Boolean;
      AValue: Double): Boolean;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure PublishAlarmChange(ATag: TRecorderTag; AKind: TRecorderTagSetpointKind;
      ALevel: TRecorderAlarmLevel; AActive: Boolean; ATimeSec, AValue,
      AThreshold: Double);
  public
    constructor Create(AEventBus: TRecorderEventBus = nil);
    destructor Destroy; override;

    procedure Attach(AEventBus: TRecorderEventBus);
    procedure Detach;

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

constructor TRecorderAlarmEngine.Create(AEventBus: TRecorderEventBus);
begin
  inherited Create;
  fStates := TList.Create;
  if AEventBus <> nil then
    Attach(AEventBus);
end;

destructor TRecorderAlarmEngine.Destroy;
begin
  Detach;
  Reset;
  fStates.Free;
  fLastEventData.Free;
  inherited Destroy;
end;

procedure TRecorderAlarmEngine.Attach(AEventBus: TRecorderEventBus);
begin
  if AEventBus = nil then
    Exit;
  if fEventBus <> nil then
    Detach;

  fEventBus := AEventBus;
  fToken := fEventBus.Subscribe(@HandleEvent);
end;

procedure TRecorderAlarmEngine.Detach;
begin
  if (fEventBus <> nil) and (fToken <> 0) then
    fEventBus.Unsubscribe(fToken);
  fToken := 0;
  fEventBus := nil;
end;

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

procedure TRecorderAlarmEngine.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  lTagData: TRecorderTagUpdateEventData;
begin
  if (AEvent.Kind <> rceDataUpdated) or
    (not (AEvent.Data is TRecorderTagUpdateEventData)) then
    Exit;

  lTagData := TRecorderTagUpdateEventData(AEvent.Data);
  ProcessTagValue(lTagData.Tag, lTagData.TimeSec, lTagData.Value);
end;

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

function TRecorderAlarmEngine.GetTagAlarmLevel(
  ATag: TRecorderTag): TRecorderAlarmLevel;
var
  lState: TTagAlarmState;
begin
  Result := ralNone;
  lState := AcquireState(ATag);
  if lState = nil then
    Exit;

  if lState.Active[tskHighAlarm] or lState.Active[tskLowAlarm] then
    Result := ralAlarm
  else if lState.Active[tskHighWarning] or lState.Active[tskLowWarning] then
    Result := ralWarning;
end;

function TRecorderAlarmEngine.GetTagAlarmText(ATag: TRecorderTag): string;
begin
  Result := RecorderAlarmLevelToString(GetTagAlarmLevel(ATag));
end;

function TRecorderAlarmEngine.GetTagAlarmColor(ATag: TRecorderTag): LongInt;
var
  lState: TTagAlarmState;
begin
  Result := 0;
  lState := AcquireState(ATag);
  if lState = nil then
    Exit;

  if lState.Active[tskHighAlarm] then
    Result := ATag.Setpoints[tskHighAlarm].Color
  else if lState.Active[tskLowAlarm] then
    Result := ATag.Setpoints[tskLowAlarm].Color
  else if lState.Active[tskHighWarning] then
    Result := ATag.Setpoints[tskHighWarning].Color
  else if lState.Active[tskLowWarning] then
    Result := ATag.Setpoints[tskLowWarning].Color;
end;

procedure TRecorderAlarmEngine.ProcessTagValue(ATag: TRecorderTag; ATimeSec,
  AValue: Double);
var
  lActive: Boolean;
  lKind: TRecorderTagSetpointKind;
  lLevel: TRecorderAlarmLevel;
  lSetpoint: TRecorderTagSetpoint;
  lState: TTagAlarmState;
begin
  lState := AcquireState(ATag);
  if lState = nil then
    Exit;

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
end;

procedure TRecorderAlarmEngine.Reset;
var
  I: Integer;
begin
  for I := 0 to fStates.Count - 1 do
    TObject(fStates[I]).Free;
  fStates.Clear;
end;

end.
