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
fEv: THandle;
fRestart: boolean;
procedure Execute; override;
    function getActive: boolean;
    function getInterval: integer;
    procedure setActive(const Value: boolean);
    procedure setInterval(const Value: integer);
    procedure DoTick;
public
  constructor Create(interv: integer = 500);
  destructor Destroy; override;
  property Active: boolean read getActive write setActive;
  property OnTick: TNotifyEvent read fTick write fTick;
  property Interval: integer read getInterval write setInterval;
end;

implementation

{ TTimerThread }

constructor TTimerThread.Create(interv: integer);
begin
  inherited Create(true);
  fInterval := interv;
  fCS := TCriticalSection.Create;
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
    fTick(Self);
    end;
end;

procedure TTimerThread.Execute;
begin
  inherited;
  while not Terminated do
      begin
      if Active then
          begin
          fRestart := false;
          WaitForSingleObject(fEv, Interval); //Ожидаем события в течение заданного интервала
          if not fRestart then //Если во время ожидания состояние менялось то ждать заново
             begin
              if not Terminated and Active then DoTick;
             end;
         end;
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
  if Value = fActive then exit;

  fCS.Enter;
  fRestart := Value <> fActive; //Выставляем флаг перезапуска если состояние изменилось, если не применить этот флаг то таймер сработает после ожидания, даже если Active = false

  fActive := Value;

  if fActive then
     begin
     if self.Suspended then
     Resume else
     Start;
     end

     else
     Suspended := true;

  fCS.Leave;
end;

procedure TTimerThread.setInterval(const Value: integer);
begin
  fCS.Enter;
  fInterval := Value;
  fCS.Leave;
end;

end.
