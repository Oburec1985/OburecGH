unit uRecorderSqlDbRuntime;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderSqlDbTypes;

type
  TRecorderSqlDbRuntime = class;

  { TRecorderSqlDbWriterThread
    Единственный рабочий поток SQLdb runtime. GUI/notify-потоки только кладут
    задания в очередь; все подключения к БД, транзакции и файловое хранилище
    живут внутри Execute/RunWriter. }
  TRecorderSqlDbWriterThread = class(TThread)
  private
    fOwner: TRecorderSqlDbRuntime;                  { Runtime-владелец очереди и состояния. }
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderSqlDbRuntime);
    { Обёртка над Terminated, чтобы RunWriter не зависел от protected-поля потока. }
    function IsStopping: Boolean;
  end;

  { TRecorderSqlDbRuntime
    Асинхронная запись в SQL БД. Принимает короткие задания из основного
    Recorder runtime и последовательно выполняет их в одном writer-потоке.
    Вызовы Submit* не должны открывать БД и не должны блокировать GUI. }
  TRecorderSqlDbRuntime = class
  private type
    { Вид задания, которое writer-поток достаёт из очереди. }
    TJobKind = (jkStart, jkStop, jkValue, jkEvent, jkFile);

    { TJob
      Универсальный контейнер одного действия SQLdb. Поля используются
      по-разному для разных Kind, чтобы не плодить мелкие классы и не таскать
      ссылки на живые TRecorderTag между потоками. }
    TJob = class
      Kind: TJobKind;                               { Тип операции: старт/стоп/значение/событие/файл. }
      Name: string;                                 { Имя тега, тип события или имя файла. }
      SourceId: string;                             { Стабильный источник тега; вместе с Address связывает историю при переименовании. }
      Address: string;                              { Аппаратный/логический адрес канала внутри источника. }
      UnitText: string;                             { Единицы измерения тега на момент записи. Не UnitName: конфликтует с FPC. }
      Text: string;                                 { Причина регистрации или текст события. }
      Extra: string;                                { Дополнительный тип данных, сейчас формат/тип файла. }
      TimeUtc: Double;                              { Астрономическое UTC-время события/значения. }
      Value: Double;                                { Числовое значение или числовая нагрузка события. }
      Quality: Integer;                             { Качество значения; 0 = штатное значение. }
    end;
  private
    fConfig: TRecorderSqlDbConfig;                  { Снимок настроек, с которым создан runtime. }
    fJobs: TThreadList;                             { Потокобезопасная очередь TJob; владеет объектами до PopJob. }
    fThread: TRecorderSqlDbWriterThread;            { Активный writer-поток или nil, если запись остановлена. }
    fAccepting: Boolean;                            { Разрешено ли принимать новые задания в очередь. }
    fDropped: Int64;                                { Сколько заданий отброшено из-за переполнения очереди. }
    fLastError: string;                             { Последняя ошибка writer-потока для UI/диагностики. }
    fState: TRecorderSqlDbRuntimeState;             { Текущее состояние SQLdb runtime. }
    { Добавляет задание в очередь или освобождает его, если runtime не принимает
      данные/очередь переполнена. }
    function Enqueue(AJob: TJob): Boolean;
    { Забирает первое задание из очереди; владение объектом переходит вызывающему. }
    function PopJob: TJob;
    { Быстрая проверка остатка очереди при остановке writer-потока. }
    function HasJobs: Boolean;
    { Основной цикл writer-потока: открытие БД, регистрация объекта, обработка заданий. }
    procedure RunWriter;
  public
    constructor Create(AConfig: TRecorderSqlDbConfig);
    destructor Destroy; override;
    { Создаёт writer-поток и начинает принимать задания. }
    procedure Start;
    { Запрещает новые задания, ждёт выгрузки очереди и останавливает поток. }
    procedure Stop;
    { Открывает новую регистрацию/сеанс записи в БД. }
    procedure BeginRegistration(const AReason: string; AStartUtc: TDateTime);
    { Закрывает текущую регистрацию/сеанс записи. }
    procedure EndRegistration(AStopUtc: TDateTime);
    { Ставит в очередь значение тега. SourceId+Address нужны, чтобы история
      оставалась связанной с тем же каналом при смене имени тега. }
    function SubmitValue(const ATagName: string; ATimeUtc, AValue: Double;
      AQuality: Integer = 0; const ASourceId: string = '';
      const AAddress: string = ''; const AUnitName: string = ''): Boolean;
    { Ставит в очередь диагностическое/аварийное событие. }
    function SubmitEvent(const AEventType, AText: string; ATimeUtc: Double;
      AValue: Double = 0): Boolean;
    { Копирует внешний файл в SQLdb file store и связывает его с регистрацией. }
    function SubmitFile(const AFileName, ADataType: string;
      AAnchorUtc: Double): Boolean;
    property DroppedCount: Int64 read fDropped;
    property LastError: string read fLastError;
    property State: TRecorderSqlDbRuntimeState read fState;
  end;

implementation

uses
  ssockets, uRecorderSqlDbRepository, uRecorderSqlDbFileStore,
  uRecorderNetworkBinding, uRecorderDebugLog;

{ Ключ локального кэша signal_id внутри writer-потока.
  Если есть адрес, имя тега не участвует в ключе: переименование не должно
  создавать новый сигнал в текущем сеансе. }
function SqlSignalCacheKey(const AName, ASourceId, AAddress: string): string;
begin
  if Trim(AAddress) <> '' then
    Result := Trim(ASourceId) + '|' + Trim(AAddress)
  else
    Result := AName;
end;

{ Лёгкая предварительная проверка удалённого SQL-сервера. Для локальных
  файловых баз TCP-проверка не нужна: доступность проверит само открытие БД. }
function SqlServerAvailable(AConfig: TRecorderSqlDbConfig;
  out AError: string): Boolean;
var
  lStream: TSocketStream;
begin
  AError := '';
  if AConfig.IsLocalFileDatabase then
    Exit(True);
  Result := RecorderOpenBoundTcpStream(AConfig.Host, AConfig.Port, 700,
    lStream, AError, False);
  lStream.Free;
end;

constructor TRecorderSqlDbWriterThread.Create(AOwner: TRecorderSqlDbRuntime);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
end;

procedure TRecorderSqlDbWriterThread.Execute;
begin
  fOwner.RunWriter;
end;

function TRecorderSqlDbWriterThread.IsStopping: Boolean;
begin
  Result := Terminated;
end;

constructor TRecorderSqlDbRuntime.Create(AConfig: TRecorderSqlDbConfig);
begin
  inherited Create;
  fConfig := TRecorderSqlDbConfig.Create;
  fConfig.Assign(AConfig);
  fJobs := TThreadList.Create;
  fState := rsrsDisabled;
end;

destructor TRecorderSqlDbRuntime.Destroy;
var
  lJob: TJob;
begin
  Stop;
  repeat
    lJob := PopJob;
    lJob.Free;
  until lJob = nil;
  fJobs.Free;
  fConfig.Free;
  inherited Destroy;
end;

procedure TRecorderSqlDbRuntime.Start;
begin
  if not fConfig.Enabled then Exit;
  if fThread <> nil then Exit;
  fConfig.RequireValid;
  fAccepting := True;
  fState := rsrsReady;
  fThread := TRecorderSqlDbWriterThread.Create(Self);
  fThread.Start;
end;

procedure TRecorderSqlDbRuntime.Stop;
begin
  fAccepting := False;
  if fThread = nil then Exit;
  fThread.Terminate;
  fThread.WaitFor;
  FreeAndNil(fThread);
  if fState <> rsrsError then fState := rsrsDisabled;
end;

function TRecorderSqlDbRuntime.Enqueue(AJob: TJob): Boolean;
var
  L: TList;
begin
  Result := False;
  if (AJob = nil) or not fAccepting then
  begin
    AJob.Free;
    Exit;
  end;
  L := fJobs.LockList;
  try
    if L.Count >= fConfig.QueueCapacity then
    begin
      Inc(fDropped);
      AJob.Free;
      Exit;
    end;
    L.Add(AJob);
    Result := True;
  finally fJobs.UnlockList; end;
end;

function TRecorderSqlDbRuntime.PopJob: TJob;
var
  L: TList;
begin
  Result := nil;
  L := fJobs.LockList;
  try
    if L.Count > 0 then
    begin
      Result := TJob(L[0]);
      L.Delete(0);
    end;
  finally fJobs.UnlockList; end;
end;

function TRecorderSqlDbRuntime.HasJobs: Boolean;
var L: TList;
begin
  L := fJobs.LockList;
  try Result := L.Count > 0; finally fJobs.UnlockList; end;
end;

procedure TRecorderSqlDbRuntime.BeginRegistration(const AReason: string;
  AStartUtc: TDateTime);
var J: TJob;
begin
  J := TJob.Create; J.Kind := jkStart; J.Text := AReason; J.TimeUtc := AStartUtc;
  Enqueue(J);
end;

procedure TRecorderSqlDbRuntime.EndRegistration(AStopUtc: TDateTime);
var J: TJob;
begin
  J := TJob.Create; J.Kind := jkStop; J.TimeUtc := AStopUtc; Enqueue(J);
end;

function TRecorderSqlDbRuntime.SubmitValue(const ATagName: string; ATimeUtc,
  AValue: Double; AQuality: Integer; const ASourceId: string;
  const AAddress: string; const AUnitName: string): Boolean;
var J: TJob;
begin
  J := TJob.Create; J.Kind := jkValue; J.Name := ATagName; J.TimeUtc := ATimeUtc;
  J.SourceId := ASourceId; J.Address := AAddress; J.UnitText := AUnitName;
  J.Value := AValue; J.Quality := AQuality; Result := Enqueue(J);
end;

function TRecorderSqlDbRuntime.SubmitEvent(const AEventType, AText: string;
  ATimeUtc, AValue: Double): Boolean;
var J: TJob;
begin
  J := TJob.Create; J.Kind := jkEvent; J.Name := AEventType; J.Text := AText;
  J.TimeUtc := ATimeUtc; J.Value := AValue; Result := Enqueue(J);
end;

function TRecorderSqlDbRuntime.SubmitFile(const AFileName, ADataType: string;
  AAnchorUtc: Double): Boolean;
var J: TJob;
begin
  J := TJob.Create; J.Kind := jkFile; J.Name := AFileName; J.Extra := ADataType;
  J.TimeUtc := AAnchorUtc; Result := Enqueue(J);
end;

procedure TRecorderSqlDbRuntime.RunWriter;
var
  R: TRecorderSqlDbRepository;
  S: TRecorderSqlDbFileStore;
  J: TJob;
  lObjectId, lRegistrationId, lSignalId: string;
  lSignalKey: string;
  lSignals: TStringList;
  lStored: TRecorderStoredFile;
  lSequence: Int64;
begin
  R := nil; S := nil; lSignals := TStringList.Create;
  lRegistrationId := '';
  lSequence := 0;
  lSignals.NameValueSeparator := '=';
  try
    if not SqlServerAvailable(fConfig, fLastError) then
    begin
      fLastError := 'SQL server not found: ' + fConfig.Host + ':' +
        IntToStr(fConfig.Port) + ' (' + fLastError + ')';
      fState := rsrsError;
      RecorderDebugLog(fLastError);
      Exit;
    end;
    R := TRecorderSqlDbRepository.Create(fConfig);
    R.EnsureDatabase;
    S := TRecorderSqlDbFileStore.Create(fConfig.DataDirectory);
    lObjectId := R.EnsureObject(fConfig.ObjectName, fConfig.ObjectType,
      fConfig.SerialNumber);
    while not fThread.IsStopping or HasJobs do
    begin
      J := PopJob;
      if J = nil then begin Sleep(10); Continue; end;
      try
        case J.Kind of
          jkStart:
            begin
              if lRegistrationId <> '' then
                R.FinishRegistration(lRegistrationId, 'closed', J.TimeUtc);
              lRegistrationId := R.BeginRegistration(lObjectId, '', J.Text, J.TimeUtc);
              fState := rsrsRecording;
            end;
          jkStop:
            begin
              if lRegistrationId <> '' then
                R.FinishRegistration(lRegistrationId, 'closed', J.TimeUtc);
              lRegistrationId := ''; fState := rsrsReady;
            end;
          jkValue:
            if lRegistrationId <> '' then
            begin
              lSignalKey := SqlSignalCacheKey(J.Name, J.SourceId, J.Address);
              lSignalId := lSignals.Values[lSignalKey];
              if lSignalId = '' then
              begin
                lSignalId := R.EnsureSignal(lObjectId, J.Name, 'double',
                  J.UnitText, J.Name, J.SourceId, J.Address);
                lSignals.Values[lSignalKey] := lSignalId;
              end;
              Inc(lSequence);
              R.InsertSignalValue(lRegistrationId, lSignalId, J.TimeUtc,
                J.Value, J.Quality, lSequence);
            end;
          jkEvent:
            R.InsertEvent(lRegistrationId, lObjectId, '', J.TimeUtc, J.Name,
              'info', J.Text, J.Value, '');
          jkFile:
            begin
              lStored := S.StoreFile(J.Name, J.Extra, J.TimeUtc);
              R.InsertDataFile(lStored.Id, lStored.StorageKey, J.Extra,
                Copy(ExtractFileExt(J.Name), 2, MaxInt), lStored.Size,
                lStored.Checksum, 'ready', lRegistrationId, '', '', J.TimeUtc,
                J.TimeUtc, J.TimeUtc);
            end;
        end;
      finally J.Free; end;
    end;
    if lRegistrationId <> '' then
      R.FinishRegistration(lRegistrationId, 'interrupted', Now);
  except
    on E: Exception do
    begin
      fLastError := E.Message;
      fState := rsrsError;
      RecorderDebugLog('SQL database disabled: ' + fLastError);
    end;
  end;
  lSignals.Free; S.Free; R.Free;
end;

end.
