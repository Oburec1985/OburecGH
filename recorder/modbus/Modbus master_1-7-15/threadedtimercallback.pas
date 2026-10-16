unit ThreadedTimerCallback;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs;

type
  // Тип callback-функции, которая будет вызываться при срабатывании таймера
  TTimerCallback = procedure(Data: Pointer) of object;

  { TTimerThread - внутренний поток таймера }
  TTimerThread = class;

  { TThreadedTimer - основной класс таймера }
  TThreadedTimer = class(TObject)
  private
    FThread: TTimerThread;
    FInterval: Cardinal;
    FCallback: TTimerCallback;
    FCallbackData: Pointer;
    FActive: Boolean;
    FPaused: Boolean;
    FCS: TCriticalSection; // Защита состояния таймера
    FCSExecution: TCriticalSection; // Защита выполнения callback

    function GetInterval: Cardinal;
    procedure SetInterval(AValue: Cardinal);
    function GetActive: Boolean;
    procedure SetActive(AValue: Boolean);
    function GetPaused: Boolean;
    procedure SetPaused(AValue: Boolean);

    // Внутренний метод, вызываемый из потока
    procedure InternalTimerFired;
  public
    constructor Create(ACallback: TTimerCallback; ACallbackData: Pointer = nil);
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;

    property Interval: Cardinal read GetInterval write SetInterval;
    property Active: Boolean read GetActive write SetActive;
    property Paused: Boolean read GetPaused write SetPaused;
    property Callback: TTimerCallback read FCallback write FCallback;
    property CallbackData: Pointer read FCallbackData write FCallbackData;
  end;

  TTimerThread = class(TThread)
  private
    FOwner: TThreadedTimer;
    FEvent: TEvent; // Для ожидания интервала и прерывания ожидания
    FTerminating: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TThreadedTimer);
    destructor Destroy; override;
    procedure TerminateGracefully;
  end;

implementation

{ TTimerThread }

constructor TTimerThread.Create(AOwner: TThreadedTimer);
begin
  inherited Create(True);
  FOwner := AOwner;
  FEvent := TEvent.Create(nil, True, False, '');
  FTerminating := False;
  FreeOnTerminate := False;
end;

destructor TTimerThread.Destroy;
begin
  TerminateGracefully;
  FEvent.Free;
  inherited Destroy;
end;

procedure TTimerThread.TerminateGracefully;
begin
  FTerminating := True;
  FEvent.SetEvent;
end;

procedure TTimerThread.Execute;
var
  WaitResult: TWaitResult;
  LocalInterval: Cardinal;
  LocalActive, LocalPaused: Boolean;
begin
  while not Terminated and not FTerminating do
  begin
    // Получаем текущее состояние под защитой критической секции
    FOwner.FCS.Enter;
    try
      LocalInterval := FOwner.FInterval;
      LocalActive := FOwner.FActive;
      LocalPaused := FOwner.FPaused;
    finally
      FOwner.FCS.Leave;
    end;

    if not LocalActive or LocalPaused then
    begin
      // Если таймер неактивен или на паузе, ждем изменения состояния
      WaitResult := FEvent.WaitFor(INFINITE);
      if Terminated or FTerminating then
        Break;

      if WaitResult = wrSignaled then
        FEvent.ResetEvent;
    end
    else
    begin
      // Активный таймер - ждем интервал
      WaitResult := FEvent.WaitFor(LocalInterval);

      if Terminated or FTerminating then
        Break;

      if WaitResult = wrTimeout then
      begin
        // Таймер сработал - вызываем callback через владельца
        FOwner.InternalTimerFired;
      end
      else if WaitResult = wrSignaled then
      begin
        // Событие (изменение состояния) - сбрасываем и продолжаем
        FEvent.ResetEvent;
      end;
    end;
  end;
end;

{ TThreadedTimer }

constructor TThreadedTimer.Create(ACallback: TTimerCallback; ACallbackData: Pointer);
begin
  inherited Create;
  FCS := TCriticalSection.Create;
  FCSExecution := TCriticalSection.Create;
  FInterval := 1000;
  FCallback := ACallback;
  FCallbackData := ACallbackData;
  FActive := False;
  FPaused := False;

  // Создаем поток, но не запускаем
  FThread := TTimerThread.Create(Self);
end;

destructor TThreadedTimer.Destroy;
begin
  Stop;

  if Assigned(FThread) then
  begin
    FThread.TerminateGracefully;
    if FThread.Suspended then
      FThread.Start;
    FThread.WaitFor;
    FThread.Free;
  end;

  FCSExecution.Free;
  FCS.Free;
  inherited Destroy;
end;

procedure TThreadedTimer.InternalTimerFired;
begin
  // Этот метод вызывается из потока таймера
  // Используем критическую секцию для безопасного вызова callback
  FCSExecution.Enter;
  try
    if Assigned(FCallback) then
      FCallback(FCallbackData);
  finally
    FCSExecution.Leave;
  end;
end;

function TThreadedTimer.GetInterval: Cardinal;
begin
  FCS.Enter;
  try
    Result := FInterval;
  finally
    FCS.Leave;
  end;
end;

procedure TThreadedTimer.SetInterval(AValue: Cardinal);
begin
  FCS.Enter;
  try
    if FInterval = AValue then
      Exit;

    FInterval := AValue;
  finally
    FCS.Leave;
  end;

  // Сигнализируем потоку об изменении интервала
  if Assigned(FThread) and Assigned(FThread.FEvent) then
    FThread.FEvent.SetEvent;
end;

function TThreadedTimer.GetActive: Boolean;
begin
  FCS.Enter;
  try
    Result := FActive;
  finally
    FCS.Leave;
  end;
end;

procedure TThreadedTimer.SetActive(AValue: Boolean);
begin
  FCS.Enter;
  try
    if FActive = AValue then
      Exit;

    FActive := AValue;
    FPaused := False;

    // Запускаем поток при первом старте
    if AValue and Assigned(FThread) and FThread.Suspended then
      FThread.Start;
  finally
    FCS.Leave;
  end;

  // Сигнализируем потоку об изменении состояния
  if Assigned(FThread) and Assigned(FThread.FEvent) then
    FThread.FEvent.SetEvent;
end;

function TThreadedTimer.GetPaused: Boolean;
begin
  FCS.Enter;
  try
    Result := FPaused;
  finally
    FCS.Leave;
  end;
end;

procedure TThreadedTimer.SetPaused(AValue: Boolean);
begin
  FCS.Enter;
  try
    if FPaused = AValue then
      Exit;

    FPaused := AValue;
  finally
    FCS.Leave;
  end;

  // Сигнализируем потоку об изменении состояния
  if Assigned(FThread) and Assigned(FThread.FEvent) then
    FThread.FEvent.SetEvent;
end;

procedure TThreadedTimer.Start;
begin
  Active := True;
end;

procedure TThreadedTimer.Stop;
begin
  Active := False;
end;

procedure TThreadedTimer.Pause;
begin
  Paused := True;
end;

procedure TThreadedTimer.Resume;
begin
  Paused := False;
end;

end.
