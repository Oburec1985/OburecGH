unit uMyThreadImpulses;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, Generics.Collections,
  tags, uMyRecorderUtils;

type
  // класс вызова процедуры с параметрами
  TImpulseDataWrapper = class(TObject)
  private
    FImpulseID : Int64; // ID текущего импульса
  public
    constructor Create(ImpulseID : Int64);
    destructor Destroy; override;
    property ImpulseID: Int64 read FImpulseID write FImpulseID;
  end;

  // класс вызова события с параметрами
  TEventParam = class(TObject)
  private
   FEvent: TEvent;
   FImpulseID : Int64; // ID текущего импульса
  public
   constructor Create(EventAttributes: PSecurityAttributes; InitialState: Boolean; ManualReset: Boolean; Name: PChar);
   destructor Destroy; override;
   function WaitFor(Timeout: DWORD): TWaitResult;
   procedure Signal;
   procedure ResetEvent;
   property ImpulseID: Int64 read FImpulseID write FImpulseID;
  end;

  TImpulseRecordSet = Record
    ImpulseStartDelay   : Int64;  // длительность перед импульсом в миллисекундах
    ImpulseStartTag     : ITag;   // канал начала импульса
    ImpulseStartdValue  : Double; // значение канала начала импульса
    ImpulseStartdXValue : Double; // значение канала начала импульса

    ImpulseStartNotifyEvent : TNotifyEvent; // выполнение процедуры по началу импульса
    ImpulseStartEvent       : TEvent;       // событие наружу по началу импульса
    ImpulseStartEventParam  : TEventParam;  // событие наружу по началу импульса с параметром

    ImpulseDuration : Int64; // длительность импульса в миллисекундах

    ImpulseStopTag     : ITag;   // канал окончания импульса
    ImpulseStopdValue  : Double; // значение канала окончания импульса
    ImpulseStopdXValue : Double; // значение канала окончания импульса

    ImpulseStopNotifyEvent : TNotifyEvent; // выполнение процедуры по окончанию импульса
    ImpulseStopEvent       : TEvent;       // событие наружу по окончанию импульса
    ImpulseStopEventParam  : TEventParam;  // событие наружу по окончанию импульса с параметром
  end;

  TImpulseCurrentMode =
   (m_Start,   // только что добавили
    m_Delay,   // ждем до начала импульса
    m_Impulse, // ждем до конца импульса
    m_Final,   // импульс завершен
    m_Start_Hold,  // только что добавили, процесс приостановлен
    m_Delay_Hold,  // ждем до начала импульса, процесс приостановлен
    m_Impulse_Hold // ждем до конца импульса, процесс приостановлен
    );

  TImpulseRecordWork = Record
    ImpulseStartDelay   : Int64;  // длительность перед импульсом в миллисекундах
    ImpulseStartTag     : ITag;   // канал начала импульса
    ImpulseStopTag     : ITag;   // канал окончания импульса
    ImpulseStartdValue  : Double; // значение канала начала импульса
    ImpulseStartdXValue : Double; // значение канала начала импульса

    ImpulseStartNotifyEvent : TNotifyEvent; // выполнение процедуры по началу импульса
    ImpulseStartEvent: TEvent;              // событие наружу по началу импульса
    ImpulseStartEventParam: TEventParam;    // событие наружу по началу импульса с параметром

    ImpulseDuration: Int64;  // длительность импульса в миллисекундах

    ImpulseStopdValue  : Double; // значение канала окончания импульса
    ImpulseStopdXValue : Double; // значение канала окончания импульса

    ImpulseStopNotifyEvent : TNotifyEvent; // выполнение процедуры по окончанию импульса
    ImpulseStopEvent       : TEvent;       // событие наружу по окончанию импульса
    ImpulseStopEventParam  : TEventParam;  // событие наружу по окончанию импульса с параметром

    ImpulseID   : Int64;     // ID текущего импульса
    StartTime   : TDateTime; // время начала работы режима
    CurrentMode : TImpulseCurrentMode; // текущий режим работы
    HoldDelayStart : TDateTime;   // время начала задержки режима Hold Delay
    HoldDelayTime  : TDateTime;   // финальное время задержки режима Hold Delay
    HoldImpulseStart : TDateTime; // время начала задержки режима Hold Impulse
    HoldImpulseTime  : TDateTime; // финальное время задержки режима Hold Impulse
  end;

  // класс потока обработки импульсов
  TThreadImpulses = class(TThread)
  private
    FInterval: Int64; // длительность цикла в миллисекундах

    ImpulsesList : TList<TImpulseRecordWork>; // рабочий список с импульсами
    IDCount : Int64; // номер ID последнего импульса

    FSync: TCriticalSection; // критическая секция для синхронизации

    procedure CallNotifyEventWithParams(NotifyEvent : TNotifyEvent; ImpulseID : Int64);

    function getInterval: Int64;
    procedure setInterval(const Value: Int64);

    function GetClearRecordWork : TImpulseRecordWork;
  protected
    procedure Execute; override;
  public
    property Interval: Int64 read getInterval write setInterval;

    constructor Create(Interval: Int64 = 10);
    destructor Destroy; override;

    function GetClearRecord : TImpulseRecordSet;

    function AddImpulse(ImpulseRecordSet : TImpulseRecordSet) : Int64; overload;

    function AddImpulse(StartDelay  : Int64;  // длительность перед импульсом в миллисекундах
                        StartTag    : ITag;   // канал начала импульса
                        StartdValue : Double; // значение канала начала импульса
                        Duration    : Int64;  // длительность импульса в миллисекундах
                        StopTag     : ITag;   // канал окончания импульса
                        StopdValue  : Double  // значение канала окончания импульса
                        ) : Int64; overload;

    function AddImpulse(StartDelay  : Int64;  // длительность перед импульсом в миллисекундах
                        WorkTag     : ITag;   // канал импульса
                        StartdValue : Double; // значение канала начала импульса
                        Duration    : Int64;  // длительность импульса в миллисекундах
                        StopdValue  : Double  // значение канала окончания импульса
                        ) : Int64; overload;

    function AddImpulse(Duration   : Int64; // длительность импульса в миллисекундах
                        StopTag    : ITag;  // канал окончания импульса
                        StopdValue : Double // значение канала окончания импульса
                        ) : Int64; overload;

    function CurrentMode(ImpulseID : Int64) : TImpulseCurrentMode; // текущий режим импульса

    function HoldImpulse(ImpulseID : Int64) : HRESULT;    // заморозить импульс
    function ReleaseImpulse(ImpulseID : Int64) : HRESULT; // возобновить импульс

    function DeleteImpulse(ImpulseID : Int64) : HRESULT; // удалить импульс
    function DeleteAllImpulses : HRESULT;                // удалить все импульсы
  end;

implementation

constructor TThreadImpulses.Create(Interval: Int64 = 10);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FInterval := Interval;

  ImpulsesList := TList<TImpulseRecordWork>.Create;
  IDCount := 0;

  FSync := TCriticalSection.Create;
end;

destructor TThreadImpulses.Destroy;
begin
  Terminate;
  //WaitFor;
  FreeAndNil(FSync);// FSync.Free;
  inherited;
end;

constructor TImpulseDataWrapper.Create(ImpulseID : Int64);
begin
  inherited Create;
  Self.FImpulseID := ImpulseID;
end;

destructor TImpulseDataWrapper.Destroy;
begin
  inherited Destroy;
end;

constructor TEventParam.Create(EventAttributes: PSecurityAttributes; InitialState: Boolean; ManualReset: Boolean; Name: PChar);
begin
  inherited Create;
  FEvent := TEvent.Create(EventAttributes, ManualReset, InitialState, Name);
end;

destructor TEventParam.Destroy;
begin
  FEvent.Free;
  inherited;
end;

function TEventParam.WaitFor(Timeout: DWORD): TWaitResult;
begin
  Result := FEvent.WaitFor(Timeout);
end;

procedure TEventParam.Signal;
begin
  FEvent.SetEvent;
end;

procedure TEventParam.ResetEvent;
begin
  FEvent.ResetEvent;
end;

procedure TThreadImpulses.Execute;
const MsSecondTime : TDateTime = 1 / (24 * 60 * 60 * 1000); // Значение 1 миллисекунды в формате TDateTime
var
  i: Integer;
  IRec : TImpulseRecordWork;
begin
  while not Terminated do
  begin
    FSync.Enter;
    try
      for i := 0 to ImpulsesList.Count - 1 do
        begin
          IRec := ImpulsesList.Items[i];

          // ID текущего импульса =-1, импульс не работает
          if IRec.ImpulseID = -1 then Continue;

          // режим Hold, или m_Final, импульс не работает
          if IRec.CurrentMode in [m_Start_Hold, m_Delay_Hold, m_Impulse_Hold, m_Final] then Continue;

          // текущий режим работы - только что добавили импульс
          if IRec.CurrentMode = m_Start then
            begin
              if IRec.ImpulseStartDelay < 0 then
                begin // нет задержки перед импульсом
                  IRec.CurrentMode := m_Impulse; // ждем до конца импульса
                end
              else // есть задержка перед импульсом
                begin
                  IRec.CurrentMode := m_Delay; // ждем до начала импульса
                end;
            end;

          // текущий режим работы - ждем до начала импульса
          if IRec.CurrentMode = m_Delay then
            begin
              if IRec.ImpulseStartDelay < 0 then
                begin // отрицательное время - пропускаем
                  IRec.CurrentMode := m_Impulse; // ждем до конца импульса
                end
              else // есть время задержки
                begin
                  if Now >= (IRec.StartTime + IRec.ImpulseStartDelay*MsSecondTime + IRec.HoldDelayTime) then
                    begin // время задержки закончилось
                      IRec.CurrentMode := m_Impulse; // ждем до конца импульса
                      IRec.StartTime   := Now;       // стартовая точка отсчета - сейчас

                      if IRec.ImpulseStartTag <> nil then // пишем в тег при старте импульса
                        IRec.ImpulseStartTag.PushValue(IRec.ImpulseStartdValue, IRec.ImpulseStartdXValue);

                      try // нотифаеры
                        //if Assigned(IRec.ImpulseStartNotifyEvent) then IRec.ImpulseStartNotifyEvent(Self);
                        if Assigned(IRec.ImpulseStartNotifyEvent) then
                          CallNotifyEventWithParams(IRec.ImpulseStartNotifyEvent, IRec.ImpulseID);

                        if Assigned(IRec.ImpulseStartEvent) then
                          IRec.ImpulseStartEvent.SetEvent;

                        if Assigned(IRec.ImpulseStartEventParam) then
                          begin
                            IRec.ImpulseStartEventParam.ImpulseID := IRec.ImpulseID;
                            IRec.ImpulseStartEventParam.Signal;
                          end;
                      finally
                      end;
                    end;
                end;
            end;

          // текущий режим работы - ждем до конца импульса
          if IRec.CurrentMode = m_Impulse then
            begin
              if IRec.ImpulseDuration < 0 then
                begin // отрицательное время - пропускаем
                  IRec.CurrentMode := m_Final; // импульс завершен
                  IRec.ImpulseID   := -1;
                end
              else // есть время импульса
                begin
                  if Now >= (IRec.StartTime + IRec.ImpulseDuration*MsSecondTime + IRec.HoldImpulseTime) then
                    begin // время задержки закончилось
                      if IRec.ImpulseStopTag <> nil then // пишем в тег при завершении импульса
                        IRec.ImpulseStopTag.PushValue(IRec.ImpulseStopdValue, IRec.ImpulseStopdXValue);

                      try // нотифаеры
                        //if Assigned(IRec.ImpulseStopNotifyEvent) then IRec.ImpulseStopNotifyEvent(Self);
                        if Assigned(IRec.ImpulseStopNotifyEvent) then
                          CallNotifyEventWithParams(IRec.ImpulseStopNotifyEvent, IRec.ImpulseID);

                        if Assigned(IRec.ImpulseStopEvent) then
                          IRec.ImpulseStopEvent.SetEvent;

                        if Assigned(IRec.ImpulseStopEventParam) then
                          begin
                            IRec.ImpulseStopEventParam.ImpulseID := IRec.ImpulseID;
                            IRec.ImpulseStopEventParam.Signal;
                          end;
                      finally
                      end;

                      IRec.CurrentMode := m_Final; // импульс завершен
                      IRec.ImpulseID   := -1;
                    end;
                end;
            end;

          ImpulsesList.Items[i] := IRec; // обновляем данные
        end;
    finally
      FSync.Leave;
    end;

    Sleep(FInterval);
  end;

  ImpulsesList.Free;
end;

function TThreadImpulses.GetClearRecord : TImpulseRecordSet;
begin
  Result.ImpulseStartDelay   := -1;  // длительность перед импульсом в миллисекундах

  Result.ImpulseStartTag     := nil; // канал начала импульса
  Result.ImpulseStartdValue  := 0;   // значение канала начала импульса
  Result.ImpulseStartdXValue := -1;  // значение канала начала импульса

  Result.ImpulseStartNotifyEvent := nil; // выполнение процедуры по началу импульса
  Result.ImpulseStartEvent       := nil; // событие наружу по началу импульса
  Result.ImpulseStartEventParam  := nil; // событие наружу по началу импульса с параметром

  Result.ImpulseDuration    := -1; // длительность импульса в миллисекундах

  Result.ImpulseStopTag     := nil; // канал окончания импульса
  Result.ImpulseStopdValue  := 0;   // значение канала окончания импульса
  Result.ImpulseStopdXValue := -1;  // значение канала окончания импульса

  Result.ImpulseStopNotifyEvent := nil; // выполнение процедуры по окончанию импульса
  Result.ImpulseStopEvent       := nil; // событие наружу по окончанию импульса
  Result.ImpulseStopEventParam  := nil; // событие наружу по окончанию импульса с параметром
end;

function TThreadImpulses.GetClearRecordWork : TImpulseRecordWork;
begin
  Result.ImpulseStartDelay   := -1;  // длительность перед импульсом в миллисекундах
  Result.ImpulseStartTag     := nil; // канал начала импульса
  Result.ImpulseStartdValue  := 0;   // значение канала начала импульса
  Result.ImpulseStartdXValue := -1;  // значение канала начала импульса

  Result.ImpulseStartNotifyEvent := nil; // выполнение процедуры по началу импульса
  Result.ImpulseStartEvent       := nil; // событие наружу по началу импульса
  Result.ImpulseStartEventParam  := nil; // событие наружу по началу импульса с параметром

  Result.ImpulseDuration := -1; // длительность импульса в миллисекундах

  Result.ImpulseStopTag     := nil; // канал окончания импульса
  Result.ImpulseStopdValue  := 0;   // значение канала окончания импульса
  Result.ImpulseStopdXValue := -1;  // значение канала окончания импульса

  Result.ImpulseStopNotifyEvent := nil; // выполнение процедуры по окончанию импульса
  Result.ImpulseStopEvent       := nil; // событие наружу по окончанию импульса
  Result.ImpulseStopEventParam  := nil; // событие наружу по окончанию импульса с параметром

  Result.ImpulseID   := -1;      // ID текущего импульса
  Result.StartTime   := Now;     // время начала работы режима
  Result.CurrentMode := m_Start; // текущий режим работы
  Result.HoldDelayStart := 0;    // время начала задержки режима Hold Delay
  Result.HoldDelayTime  := 0;    // финальное время задержки режима Hold Delay
  Result.HoldImpulseStart := 0;  // время начала задержки режима Hold Impulse
  Result.HoldImpulseTime  := 0;  // финальное время задержки режима Hold Impulse
end;

function TThreadImpulses.AddImpulse(ImpulseRecordSet : TImpulseRecordSet) : Int64;
var
  ImpulseRecord : TImpulseRecordWork;
  i, IndexFree : Integer;
begin
  Result := -1;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    IndexFree := -1;
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = -1 then
          begin
            IndexFree := i;
            Break;
          end;
      end;

    ImpulseRecord.ImpulseStartDelay   := ImpulseRecordSet.ImpulseStartDelay;   // длительность перед импульсом в миллисекундах
    ImpulseRecord.ImpulseStartTag     := ImpulseRecordSet.ImpulseStartTag;     // канал начала импульса
    ImpulseRecord.ImpulseStartdValue  := ImpulseRecordSet.ImpulseStartdValue;  // значение канала начала импульса
    ImpulseRecord.ImpulseStartdXValue := ImpulseRecordSet.ImpulseStartdXValue; // значение канала начала импульса

    ImpulseRecord.ImpulseStartNotifyEvent := ImpulseRecordSet.ImpulseStartNotifyEvent; // выполнение процедуры по началу импульса
    ImpulseRecord.ImpulseStartEvent       := ImpulseRecordSet.ImpulseStartEvent;       // событие наружу по началу импульса
    ImpulseRecord.ImpulseStartEventParam  := ImpulseRecordSet.ImpulseStartEventParam;  // событие наружу по началу импульса с параметром

    ImpulseRecord.ImpulseDuration := ImpulseRecordSet.ImpulseDuration; // длительность импульса в миллисекундах

    ImpulseRecord.ImpulseStopTag     := ImpulseRecordSet.ImpulseStopTag;     // канал окончания импульса
    ImpulseRecord.ImpulseStopdValue  := ImpulseRecordSet.ImpulseStopdValue;  // значение канала окончания импульса
    ImpulseRecord.ImpulseStopdXValue := ImpulseRecordSet.ImpulseStopdXValue; // значение канала окончания импульса

    ImpulseRecord.ImpulseStopNotifyEvent := ImpulseRecordSet.ImpulseStopNotifyEvent; // выполнение процедуры по окончанию импульса
    ImpulseRecord.ImpulseStopEvent       := ImpulseRecordSet.ImpulseStopEvent;       // событие наружу по окончанию импульса
    ImpulseRecord.ImpulseStopEventParam  := ImpulseRecordSet.ImpulseStopEventParam;  // событие наружу по окончанию импульса с параметром

    IDCount := IDCount + 1;
    ImpulseRecord.ImpulseID   := IDCount; // ID текущего импульса
    ImpulseRecord.StartTime   := Now;     // время начала работы режима
    ImpulseRecord.CurrentMode := m_Start; // текущий режим работы
    ImpulseRecord.HoldDelayStart := 0;    // время начала задержки режима Hold Delay
    ImpulseRecord.HoldDelayTime  := 0;    // финальное время задержки режима Hold Delay
    ImpulseRecord.HoldImpulseStart := 0;  // время начала задержки режима Hold Impulse
    ImpulseRecord.HoldImpulseTime  := 0;  // финальное время задержки режима Hold Impulse

    if IndexFree = -1 then // все импульсы заняты или их еще нет
      ImpulsesList.Add(ImpulseRecord)
    else // есть свободный импульс
      ImpulsesList.Items[IndexFree] := ImpulseRecord;

    Result := IDCount;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.AddImpulse(
                    StartDelay : Int64;   // длительность перед импульсом в миллисекундах
                    StartTag    : ITag;   // канал начала импульса
                    StartdValue : Double; // значение канала начала импульса
                    Duration    : Int64;  // длительность импульса в миллисекундах
                    StopTag     : ITag;   // канал окончания импульса
                    StopdValue  : Double  // значение канала окончания импульса
                    ) : Int64;
var
  ImpulseRecord : TImpulseRecordWork;
  i, IndexFree : Integer;
begin
  Result := -1;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    IndexFree := -1;
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = -1 then
          begin
            IndexFree := i;
            Break;
          end;
      end;

    ImpulseRecord := GetClearRecordWork;

    ImpulseRecord.ImpulseStartDelay  := StartDelay;  // длительность перед импульсом в миллисекундах
    ImpulseRecord.ImpulseStartTag    := StartTag;    // канал начала импульса
    ImpulseRecord.ImpulseStartdValue := StartdValue; // значение канала начала импульса

    ImpulseRecord.ImpulseDuration := Duration; // длительность импульса в миллисекундах

    ImpulseRecord.ImpulseStopTag    := StopTag;    // канал окончания импульса
    ImpulseRecord.ImpulseStopdValue := StopdValue; // значение канала окончания импульса

    IDCount := IDCount + 1;
    ImpulseRecord.ImpulseID := IDCount; // ID текущего импульса

    if IndexFree = -1 then // все импульсы заняты или их еще нет
      ImpulsesList.Add(ImpulseRecord)
    else // есть свободный импульс
      ImpulsesList.Items[IndexFree] := ImpulseRecord;

    Result := IDCount;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.AddImpulse(
                    StartDelay  : Int64;  // длительность перед импульсом в миллисекундах
                    WorkTag     : ITag;   // канал импульса
                    StartdValue : Double; // значение канала начала импульса
                    Duration    : Int64;  // длительность импульса в миллисекундах
                    StopdValue  : Double  // значение канала окончания импульса
                    ) : Int64;
var
  ImpulseRecord : TImpulseRecordWork;
  i, IndexFree : Integer;
begin
  Result := -1;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    IndexFree := -1;
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = -1 then
          begin
            IndexFree := i;
            Break;
          end;
      end;

    ImpulseRecord := GetClearRecordWork;

    ImpulseRecord.ImpulseStartDelay  := StartDelay;  // длительность перед импульсом в миллисекундах
    ImpulseRecord.ImpulseStartTag    := WorkTag;     // канал начала импульса
    ImpulseRecord.ImpulseStartdValue := StartdValue; // значение канала начала импульса

    ImpulseRecord.ImpulseDuration := Duration; // длительность импульса в миллисекундах

    ImpulseRecord.ImpulseStopTag    := WorkTag;    // канал окончания импульса
    ImpulseRecord.ImpulseStopdValue := StopdValue; // значение канала окончания импульса

    IDCount := IDCount + 1;
    ImpulseRecord.ImpulseID := IDCount; // ID текущего импульса

    if IndexFree = -1 then // все импульсы заняты или их еще нет
      ImpulsesList.Add(ImpulseRecord)
    else // есть свободный импульс
      ImpulsesList.Items[IndexFree] := ImpulseRecord;

    Result := IDCount;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.AddImpulse(
                    Duration   : Int64; // длительность импульса в миллисекундах
                    StopTag    : ITag;  // канал окончания импульса
                    StopdValue : Double // значение канала окончания импульса
                    ) : Int64;
var
  ImpulseRecord : TImpulseRecordWork;
  i, IndexFree : Integer;
begin
  Result := -1;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    IndexFree := -1;
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = -1 then
          begin
            IndexFree := i;
            Break;
          end;
      end;

    ImpulseRecord := GetClearRecordWork;

    ImpulseRecord.ImpulseDuration := Duration; // длительность импульса в миллисекундах

    ImpulseRecord.ImpulseStopTag    := StopTag;    // канал окончания импульса
    ImpulseRecord.ImpulseStopdValue := StopdValue; // значение канала окончания импульса

    IDCount := IDCount + 1;
    ImpulseRecord.ImpulseID := IDCount; // ID текущего импульса

    if IndexFree = -1 then // все импульсы заняты или их еще нет
      ImpulsesList.Add(ImpulseRecord)
    else // есть свободный импульс
      ImpulsesList.Items[IndexFree] := ImpulseRecord;

    Result := IDCount;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.CurrentMode(ImpulseID : Int64) : TImpulseCurrentMode;
var i : Integer;
begin
  Result := m_Final;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = ImpulseID then
          begin
            Result := ImpulsesList.Items[i].CurrentMode;
            Break;
          end;
      end;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.HoldImpulse(ImpulseID : Int64) : HRESULT;
var
  ImpulseRecord : TImpulseRecordWork;
  i : Integer;
begin
  Result := S_FALSE;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = ImpulseID then
          begin
            ImpulseRecord := ImpulsesList.Items[i];

            case ImpulseRecord.CurrentMode of
              m_Start :
                begin
                  ImpulseRecord.CurrentMode := m_Start_Hold;
                end;
              m_Delay :
                begin
                  ImpulseRecord.CurrentMode    := m_Delay_Hold;
                  ImpulseRecord.HoldDelayStart := Now; // время начала задержки режима Hold Delay
                end;
              m_Impulse :
                begin
                  ImpulseRecord.CurrentMode      := m_Impulse_Hold;
                  ImpulseRecord.HoldImpulseStart := Now; // время начала задержки режима Hold Impulse
                end
              else
                Break;
            end;

            ImpulsesList.Items[i] := ImpulseRecord;

            Result := S_OK;
            Break;
          end;
      end;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.ReleaseImpulse(ImpulseID : Int64) : HRESULT;
var
  ImpulseRecord : TImpulseRecordWork;
  i : Integer;
begin
  Result := S_FALSE;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = ImpulseID then
          begin
            ImpulseRecord := ImpulsesList.Items[i];

            case ImpulseRecord.CurrentMode of
              m_Start_Hold :
                begin
                  ImpulseRecord.CurrentMode := m_Start;
                end;
              m_Delay_Hold :
                begin
                  ImpulseRecord.CurrentMode   := m_Delay;
                  // финальное время задержки режима Hold Delay
                  ImpulseRecord.HoldDelayTime := ImpulseRecord.HoldDelayTime + Now - ImpulseRecord.HoldDelayStart;
                end;
              m_Impulse_Hold :
                begin
                  ImpulseRecord.CurrentMode     := m_Impulse;
                  // финальное время задержки режима Hold Impulse
                  ImpulseRecord.HoldImpulseTime := ImpulseRecord.HoldImpulseTime + Now - ImpulseRecord.HoldImpulseStart;
                end
              else
                Break;
            end;

            ImpulsesList.Items[i] := ImpulseRecord;

            Result := S_OK;
            Break;
          end;
      end;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.DeleteImpulse(ImpulseID : Int64) : HRESULT;
var
  ImpulseRecord : TImpulseRecordWork;
  i : Integer;
begin
  Result := S_FALSE;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID = ImpulseID then
          begin
            ImpulseRecord := ImpulsesList.Items[i];
            ImpulseRecord.ImpulseID   := -1;
            ImpulseRecord.CurrentMode := m_Final; // импульс завершен
            ImpulsesList.Items[i] := ImpulseRecord;
          end;
      end;

    Result := S_OK;
  finally
    FSync.Leave;
  end;
end;

function TThreadImpulses.DeleteAllImpulses : HRESULT;
var
  ImpulseRecord : TImpulseRecordWork;
  i : Integer;
begin
  Result := S_FALSE;

  if ImpulsesList = nil then Exit;

  FSync.Enter;
  try
    for i := 0 to ImpulsesList.Count - 1 do
      begin
        if ImpulsesList.Items[i].ImpulseID <> -1 then
          begin
            ImpulseRecord := ImpulsesList.Items[i];
            ImpulseRecord.ImpulseID   := -1;
            ImpulseRecord.CurrentMode := m_Final; // импульс завершен
            ImpulsesList.Items[i] := ImpulseRecord;
          end;
      end;

    Result := S_OK;
  finally
    FSync.Leave;
  end;
end;

procedure TThreadImpulses.CallNotifyEventWithParams(NotifyEvent : TNotifyEvent; ImpulseID : Int64);
var
  Wrapper: TImpulseDataWrapper;
begin
  Wrapper := TImpulseDataWrapper.Create(ImpulseID);
  try
    NotifyEvent(Wrapper); // тут передаем созданный объект-параметр
  finally
    FreeAndNil(Wrapper);
  end;
end;

function TThreadImpulses.getInterval: Int64;
begin
  FSync.Enter;
  try
    Result := FInterval;
  finally
    FSync.Leave;
  end;
end;

procedure TThreadImpulses.setInterval(const Value: Int64);
begin
  FSync.Enter;
  try
    if Value < 0 then
      FInterval := 0
    else
      FInterval := Value;
  finally
    FSync.Leave;
  end;
end;

(*
delphi 2010 вызвать TNotifyEvent с параметрами

В Delphi событие типа `TNotifyEvent` представляет собой процедуру без параметров, поэтому оно не позволяет передавать дополнительные аргументы непосредственно при вызове события. Если возникает необходимость передать параметры обработчику события, есть два распространенных подхода:

### Вариант 1: Передача параметров через объект-обработчик события
Вы можете создать класс-посредник, который хранит необходимые параметры и вызывает исходное событие с ними. Например:

#### Шаг 1: Создание вспомогательного класса-обертки
Создаем простой класс, который будет хранить нужные параметры и вызывать событие с этими параметрами:

```delphi
type
  TDataWrapper = class(TObject)
  private
    FParam1: String;
    FParam2: Integer;
  public
    constructor Create(Param1: String; Param2: Integer);
    property Param1: String read FParam1 write FParam1;
    property Param2: Integer read FParam2 write FParam2;
  end;

constructor TDataWrapper.Create(Param1: String; Param2: Integer);
begin
  inherited Create;
  Self.FParam1 := Param1;
  Self.FParam2 := Param2;
end;
```

#### Шаг 2: Определение метода обработки события
Метод обработки события получает ссылку на наш объект-обертку и извлекает оттуда параметры:

```delpi
procedure TForm1.OnNotifyEvent(Sender: TObject);
var
  Data: TDataWrapper;
begin
  Data := Sender as TDataWrapper;
  ShowMessageFmt('Параметры события: %s, %d', [Data.Param1, Data.Param2]);
end;
```

#### Шаг 3: Вызов события с передачей параметров
Передайте экземпляр вашего объекта-параметра при вызове события:

```delphi
procedure TForm1.CallNotifyEventWithParams(const AParam1: String; const AParam2: Integer);
var
  Wrapper: TDataWrapper;
begin
  Wrapper := TDataWrapper.Create(AParam1, AParam2);
  try
    OnNotifyEvent(Wrapper); // тут передаем созданный объект-параметр
  finally
    FreeAndNil(Wrapper);
  end;
end;
```

Затем используйте этот метод везде, где хотите вызвать событие с параметрами:

```delphi
CallNotifyEventWithParams('Привет!', 42);
```

### Вариант 2: Использование анонимных методов
Начиная с версии Delphi XE, поддерживаются анонимные методы. Хотя в Delphi 2010 анонимные методы ещё не были реализованы, если ваша версия поддерживает такую функциональность, можно воспользоваться ей.

Однако, поскольку в вашей задаче указано использование Delphi 2010, первый подход является предпочтительным решением проблемы передачи параметров событию типа `TNotifyEvent`.

-------------------------------------------------------------------------------
delphi 2010 вызвать TEvent с параметрами

Тип `TEvent` в Delphi представляет собой потокобезопасный механизм синхронизации потоков (mutex). Его основное назначение — управление состоянием ожидания потока (ожидает/не ожидает). У самого события `TEvent` нет возможности передавать произвольные параметры, так как это примитивная форма межпоточной коммуникации.

Тем не менее, существует ряд способов, позволяющих организовать передачу параметров вместе с событием:

### Варианты передачи параметров совместно с событием `TEvent`

1. **Использование глобальных переменных**
   Можно определить глобальные переменные, которые будут содержать передаваемые параметры. Это самый простой способ, однако наименее безопасный и гибкий, особенно в многопоточности.

   ```delphi
   var
     GlobalParameter: Integer;

   procedure SomeThreadProcedure;
   begin
     // Устанавливаем параметр перед сигналом события
     GlobalParameter := 42;

     // Сигнализируем событие
     Event.SetEvent;
   end;
   ```

2. **Обёртка над событием**
   Другой подход заключается в создании дополнительного класса, содержащего сам объект события и дополнительные параметры, которые можно передавать вместе с ним.

   #### Пример реализации:

   Определяем дополнительный класс-обёртку:

   ```delphi
   type
     TEventWithParameters = class(TObject)
       private
         FEvent: TEvent;
         FParam1: Integer;
         FParam2: String;
       public
         constructor Create(EventHandle: THandle; InitialState: Boolean; ManualReset: Boolean; Name: PChar);
         destructor Destroy; override;
         function WaitFor(Timeout: DWORD): TWaitResult;
         procedure Signal;
         property Param1: Integer read FParam1 write FParam1;
         property Param2: String read FParam2 write FParam2;
       end;

   constructor TEventWithParameters.Create(EventHandle: THandle; InitialState: Boolean; ManualReset: Boolean; Name: PChar);
   begin
     inherited Create;
     FEvent := TEvent.Create(nil, ManualReset, InitialState, Name);
   end;

   destructor TEventWithParameters.Destroy;
   begin
     FEvent.Free;
     inherited;
   end;

   function TEventWithParameters.WaitFor(Timeout: DWORD): TWaitResult;
   begin
     Result := FEvent.WaitFor(Timeout);
   end;

   procedure TEventWithParameters.Signal;
   begin
     FEvent.SetEvent;
   end;
   ```

   Теперь вы можете использовать этот класс следующим образом:

   ```delphi
   var
     CustomEvent: TEventWithParameters;

   procedure MainThreadProc;
   begin
     while True do
     begin
       case CustomEvent.WaitFor(INFINITE) of
         wrSignaled:
           begin
             WriteLn('Получены параметры:', CustomEvent.Param1, ', ', CustomEvent.Param2);
           end;
       end;
     end;
   end;

   procedure WorkerThreadProc;
   begin
     // Установка параметров перед сигнализацией события
     CustomEvent.Param1 := 123;
     CustomEvent.Param2 := 'Hello World!';
     CustomEvent.Signal;
   end;
   ```

3. **Асинхронные очереди сообщений**
   Ещё одним вариантом является организация очередей сообщений (например, используя очередь `TMessageQueue`), куда отправляются структуры данных с необходимыми параметрами. Эти структуры могут сопровождаться событием для уведомления ожидающего потока.

   Пример организации асинхронной отправки параметризованных сообщений:

   ```delphi
   uses SyncObjs, Contnrs;

   type
     TMessageData = record
       ID: Integer;
       Text: String;
     end;

   TMessageQueue = class(TObject)
     private
       FList: TFPObjectList;
       FLock: TCriticalSection;
       FOnMessageReceived: TNotifyEvent;
       FEvent: TEvent;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Add(Message: TMessageData);
       procedure ProcessMessages;
       property OnMessageReceived: TNotifyEvent read FOnMessageReceived write FOnMessageReceived;
     end;

   constructor TMessageQueue.Create;
   begin
     inherited Create;
     FList := TFPObjectList.Create(True);
     FLock := TCriticalSection.Create;
     FEvent := TEvent.Create(nil, False, False, '');
   end;

   destructor TMessageQueue.Destroy;
   begin
     FList.Free;
     FLock.Free;
     FEvent.Free;
     inherited;
   end;

   procedure TMessageQueue.Add(Message: TMessageData);
   begin
     FLock.Enter;
     try
       FList.Add(Pointer(@Message));
       FEvent.SetEvent;
     finally
       FLock.Leave;
     end;
   end;

   procedure TMessageQueue.ProcessMessages;
   var
     Msg: Pointer;
   begin
     repeat
       if FEvent.WaitFor(INFINITE) <> wrSignaled then Exit;
       FLock.Enter;
       try
         while FList.Count > 0 do
         begin
           Msg := FList.Extract(FList.First);
           FOnMessageReceived(Self);
         end;
       finally
         FLock.Leave;
       end;
     until False;
   end;
   ```

### Заключение
Самый надежный и чистый способ — это создание классов-оберток, как показано во втором варианте. Таким образом, можно легко передавать любые типы данных и избежать побочных эффектов использования глобальных переменных.
*)

end.
