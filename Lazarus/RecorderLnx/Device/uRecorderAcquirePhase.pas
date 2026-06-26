unit uRecorderAcquirePhase;

{
  Общие этапы захвата и расчёт интервалов ожидания потоков.

  MIC-140 и MIC140v2 наследуют или переопределяют тайминги; этапы не должны
  опираться на разрозненные Sleep в коде потоков.

  См. Docs/devices/mic140/acquisition_rules.md
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, SyncObjs, Math;

type
  TRecorderAcquirePhase = (
    rapOffline,
    rapIdle,
    rapAcquiring,
    rapStopping,
    rapError
  );

  { Базовый расчёт интервалов. Наследники задают частоту и период блока. }
  TRecorderAcquireTimingBase = class(TObject)
  protected
    fPollFrequencyHz: Double;
    fUpdatePeriodMs: Cardinal;
    function NormalizedUpdatePeriodMs: Cardinal;
  public
    constructor Create(APollFrequencyHz: Double; AUpdatePeriodMs: Cardinal);
    {
      Единственный интервал прореживания в режиме опроса (кратность периода блока).
    }
    function AcquirePacingMs: Cardinal; virtual;
    { Ожидание, когда опрос ещё не запущен или прибор остановлен. }
    function IdleWaitMs: Cardinal; virtual;
    function ReadTimeoutMs: Cardinal; virtual;
    {
      Ожидание в потоке разбора, когда буфер пуст (проверка остановки потока).
      Не использовать как второй pacing в потоке чтения.
    }
    function PublishBlockWaitMs: Cardinal; virtual;
  end;

  TRecorderAcquirePhaseFsm = class(TObject)
  private
    fLock: TCriticalSection;
    fPhase: TRecorderAcquirePhase;
    fErrorText: string;
    fTiming: TRecorderAcquireTimingBase;
  public
    constructor Create(ATiming: TRecorderAcquireTimingBase); reintroduce;
    destructor Destroy; override;
    procedure Reset;
    procedure SetPhase(APhase: TRecorderAcquirePhase; const AErrorText: string = '');
    function CurrentPhase: TRecorderAcquirePhase;
    function ErrorText: string;
    function ShouldRead: Boolean;
    function ShouldPublish: Boolean;
    function IsActive: Boolean;
    function AcquirePacingMs: Cardinal;
    function IdleWaitMs: Cardinal;
    function PublishBlockWaitMs: Cardinal;
    property Timing: TRecorderAcquireTimingBase read fTiming;
  end;

function RecorderAcquirePhaseToText(APhase: TRecorderAcquirePhase): string;

implementation

constructor TRecorderAcquireTimingBase.Create(APollFrequencyHz: Double;
  AUpdatePeriodMs: Cardinal);
begin
  inherited Create;
  fPollFrequencyHz := APollFrequencyHz;
  fUpdatePeriodMs := AUpdatePeriodMs;
end;

function TRecorderAcquireTimingBase.NormalizedUpdatePeriodMs: Cardinal;
begin
  if fUpdatePeriodMs = 0 then
    Exit(200);
  Result := fUpdatePeriodMs;
end;

function TRecorderAcquireTimingBase.AcquirePacingMs: Cardinal;
begin
  Result := NormalizedUpdatePeriodMs;
end;

function TRecorderAcquireTimingBase.IdleWaitMs: Cardinal;
begin
  Result := Max(NormalizedUpdatePeriodMs, 100);
end;

function TRecorderAcquireTimingBase.ReadTimeoutMs: Cardinal;
var
  lBlockPeriodMs: Cardinal;
begin
  if fPollFrequencyHz > 0.1 then
    lBlockPeriodMs := Cardinal(Ceil(1500.0 / fPollFrequencyHz))
  else
    lBlockPeriodMs := NormalizedUpdatePeriodMs;
  if lBlockPeriodMs < 100 then
    lBlockPeriodMs := 100;
  Result := lBlockPeriodMs + 50;
end;

function TRecorderAcquireTimingBase.PublishBlockWaitMs: Cardinal;
begin
  Result := 1000;
end;

constructor TRecorderAcquirePhaseFsm.Create(ATiming: TRecorderAcquireTimingBase);
begin
  inherited Create;
  fLock := TCriticalSection.Create;
  fTiming := ATiming;
  Reset;
end;

destructor TRecorderAcquirePhaseFsm.Destroy;
begin
  fLock.Free;
  inherited Destroy;
end;

procedure TRecorderAcquirePhaseFsm.Reset;
begin
  fLock.Acquire;
  try
    fPhase := rapOffline;
    fErrorText := '';
  finally
    fLock.Release;
  end;
end;

procedure TRecorderAcquirePhaseFsm.SetPhase(APhase: TRecorderAcquirePhase;
  const AErrorText: string);
begin
  fLock.Acquire;
  try
    fPhase := APhase;
    if AErrorText <> '' then
      fErrorText := AErrorText
    else if APhase <> rapError then
      fErrorText := '';
  finally
    fLock.Release;
  end;
end;

function TRecorderAcquirePhaseFsm.CurrentPhase: TRecorderAcquirePhase;
begin
  fLock.Acquire;
  try
    Result := fPhase;
  finally
    fLock.Release;
  end;
end;

function TRecorderAcquirePhaseFsm.ErrorText: string;
begin
  fLock.Acquire;
  try
    Result := fErrorText;
  finally
    fLock.Release;
  end;
end;

function TRecorderAcquirePhaseFsm.ShouldRead: Boolean;
begin
  Result := CurrentPhase = rapAcquiring;
end;

function TRecorderAcquirePhaseFsm.ShouldPublish: Boolean;
begin
  Result := CurrentPhase in [rapAcquiring, rapStopping];
end;

function TRecorderAcquirePhaseFsm.IsActive: Boolean;
begin
  Result := CurrentPhase in [rapAcquiring, rapStopping];
end;

function TRecorderAcquirePhaseFsm.AcquirePacingMs: Cardinal;
begin
  if fTiming <> nil then
    Result := fTiming.AcquirePacingMs
  else
    Result := 200;
end;

function TRecorderAcquirePhaseFsm.IdleWaitMs: Cardinal;
begin
  if fTiming <> nil then
    Result := fTiming.IdleWaitMs
  else
    Result := 200;
end;

function TRecorderAcquirePhaseFsm.PublishBlockWaitMs: Cardinal;
begin
  if fTiming <> nil then
    Result := fTiming.PublishBlockWaitMs
  else
    Result := 1000;
end;

function RecorderAcquirePhaseToText(APhase: TRecorderAcquirePhase): string;
begin
  case APhase of
    rapOffline: Result := 'offline';
    rapIdle: Result := 'idle';
    rapAcquiring: Result := 'опрос';
    rapStopping: Result := 'остановка';
    rapError: Result := 'ошибка';
  else
    Result := 'неизвестно';
  end;
end;

end.
