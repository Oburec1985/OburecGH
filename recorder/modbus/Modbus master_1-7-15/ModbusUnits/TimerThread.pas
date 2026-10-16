unit TimerThread;

interface
uses SysUtils, Windows, SyncObjs, Classes, Generics.Collections, ExtCtrls;

type
TTimerThread = class(TThread)
private
fActive: boolean;
fInterval: integer;  //Время ожидания
fTick: TNotifyEvent; //Процедура срабатывающая по таймеру
fCS: TCriticalSection;
fSync: TCriticalSection;
fEv: THandle;
fRestart: boolean;
procedure Execute; override;
    function getActive: boolean;
    function getInterval: integer;
    procedure setActive(const Value: boolean);
    procedure setInterval(const Value: integer);
    procedure DoTick;
public
  constructor Create(interv: integer = 500; Sync: TCriticalSection = nil);
  destructor Destroy; override;
  property Active: boolean read getActive write setActive;
  property OnTick: TNotifyEvent read fTick write fTick;
  property Interval: integer read getInterval write setInterval;
end;

implementation

{ TTimerThread }

constructor TTimerThread.Create(interv: integer; Sync: TCriticalSection);
begin
  inherited Create(false);
  fInterval := interv;
  fCS := TCriticalSection.Create;
  fSync := Sync;
  fEv := CreateEvent(nil, true, false, 'ev');
end;

destructor TTimerThread.Destroy;
begin
  FreeAndNil(fCS);
  CloseHandle(fEv);
  inherited;
end;

procedure TTimerThread.DoTick;
begin
  if Assigned(fTick) then
    begin
    if Assigned(fSync) then fSync.Enter;
    fTick(Self);
    if Assigned(fSync) then fSync.Leave;
    end;
end;

procedure TTimerThread.Execute;
begin
  while not Terminated do
      begin
      if Active then
          begin

          WaitForSingleObject(fEv, Interval); //Ожидаем события в течение заданного интервала
          if not fRestart then //Если во время ожидания состояние менялось то ждать заново
             begin
              if (not Terminated) and Active then
                begin
                DoTick;
                end;
             end;
            fRestart := false;
         end else
      sleep(1);
      end;
end;

function TTimerThread.getActive: boolean;
begin
  fCS.Enter;
  result := fActive;
  fCS.Leave;
end;

function TTimerThread.getInterval: integer;
begin
  fCS.Enter;
  result := fInterval;
  fCS.Leave;
end;

procedure TTimerThread.setActive(const Value: boolean);
begin
  fCS.Enter;

  if Value and (not fActive) then
    fRestart := true; //Выставляем флаг перезапуска если состояние изменилось, если не применить этот флаг то таймер сработает после ожидания, даже если Active = false


  fActive := Value;
  fCS.Leave;
end;

procedure TTimerThread.setInterval(const Value: integer);
begin
  fCS.Enter;
  fInterval := Value;
  fCS.Leave;
end;

end.
