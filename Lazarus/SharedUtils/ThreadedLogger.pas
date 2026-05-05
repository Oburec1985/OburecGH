unit ThreadedLogger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs, Contnrs, DateUtils;

type
  // Приоритеты сообщений
  TLogPriority = (lpDebug, lpInfo, lpWarning, lpError, lpCritical);

const
  LogPriorityStrings: array [TLogPriority] of string = ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL');

type
  // Структура для хранения одного сообщения
  TLogMessage = record
    Timestamp : TDateTime;
    ThreadID  : TThreadID;
    Priority  : TLogPriority;
    Message   : string;
  end;
  PLogMessage = ^TLogMessage;

  { TThreadSafeQueue }
  // Потокобезопасная очередь для сообщений
  TThreadSafeQueue = class
  private
    FQueue: TQueue;
    FCriticalSection: TCriticalSection;
    FDataAvailable: TEvent;
  public
    constructor Create;
    destructor Destroy;
    // Добавить сообщение в очередь
    procedure Enqueue(AItem: Pointer);
    // Извлечь сообщение из очереди (с ожиданием)
    function Dequeue(ATimeout: Cardinal): Pointer;
    function GetCount: Integer;
  end;

  { TLoggerWriterThread }
  // Фоновый поток для записи логов в файл
  TLoggerWriterThread = class(TThread)
  private
    FQueue: TThreadSafeQueue;
    FLogFileName: string;
    FMaxLogSize: Int64; // Макс. размер в байтах
    FMaxLogFiles: Integer;
    procedure CheckLogRotation;
    procedure WriteMessageToFile(const ALogMessage: TLogMessage);
  protected
    procedure Execute; override;
  public
    constructor Create(AQueue: TThreadSafeQueue; const ALogFileName: string;
      AMaxLogSizeKB: Integer; AMaxLogFiles: Integer);
    destructor Destroy; override;
  end;

  { TLogger }
  // Основной класс логгера (Singleton)
  TLogger = class
  private
    FQueue: TThreadSafeQueue;
    FWriterThread: TLoggerWriterThread;
    FInitialized: Boolean;
    constructor Create;
    class var FInstance: TLogger;
  public
    destructor Destroy;
    class function GetInstance: TLogger;

    procedure Initialize(const ALogFileName: string; AMaxLogSizeKB: Integer = 5120; AMaxLogFiles: Integer = 5);
    procedure FinalizeLogger;

    procedure Log(APriority: TLogPriority; const AMessage: string);
    procedure Debug(const AMessage: string);
    procedure Info(const AMessage: string);
    procedure Warning(const AMessage: string);
    procedure Error(const AMessage: string);
    procedure Critical(const AMessage: string);

    property Initialized: Boolean read FInitialized;
  end;

// Глобальная функция для удобного доступа
function Logger: TLogger;

implementation

//uses Windows;

function Logger: TLogger;
begin
  Result := TLogger.GetInstance;
end;

{ TThreadSafeQueue }

constructor TThreadSafeQueue.Create;
begin
  FQueue := TQueue.Create;
  FCriticalSection := TCriticalSection.Create;
  FDataAvailable := TEvent.Create(nil, True, False, '');
end;

destructor TThreadSafeQueue.Destroy;
begin
  FDataAvailable.Free;
  FCriticalSection.Free;
  FQueue.Free;
  inherited Destroy;
end;

procedure TThreadSafeQueue.Enqueue(AItem: Pointer);
begin
  FCriticalSection.Enter;
  try
    FQueue.Push(AItem);
  finally
    FCriticalSection.Leave;
  end;
  FDataAvailable.SetEvent;
end;

function TThreadSafeQueue.Dequeue(ATimeout: Cardinal): Pointer;
begin
  Result := nil;
  if FDataAvailable.WaitFor(ATimeout) <> wrSignaled then
    Exit;

  FCriticalSection.Enter;
  try
    if FQueue.Count > 0 then
      Result := FQueue.Pop;
    if FQueue.Count = 0 then
      FDataAvailable.ResetEvent;
  finally
    FCriticalSection.Leave;
  end;
end;

function TThreadSafeQueue.GetCount: Integer;
begin
  FCriticalSection.Enter;
  try
    Result := FQueue.Count;
  finally
    FCriticalSection.Leave;
  end;
end;

{ TLoggerWriterThread }

constructor TLoggerWriterThread.Create(AQueue: TThreadSafeQueue;
  const ALogFileName: string; AMaxLogSizeKB: Integer; AMaxLogFiles: Integer);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FQueue          := AQueue;
  FLogFileName    := ALogFileName;
  FMaxLogSize     := AMaxLogSizeKB * 1024;
  FMaxLogFiles    := AMaxLogFiles;
end;

destructor TLoggerWriterThread.Destroy;// override;
begin
  // Проверка, что вызывающий поток не является самим TThread
  if GetCurrentThreadId <> ThreadId then
  begin
    Terminate;
    while Suspended do
      Resume;
    WaitFor;
  end;
  // Освобождение всех объектов, созданных в этом классе
  inherited Destroy;

end;

procedure TLoggerWriterThread.Execute;
var
  LMessage: PLogMessage;
begin
  while not Terminated do
  begin
    LMessage := FQueue.Dequeue(1000); // Ждем до 1 секунды
    if Assigned(LMessage) then
    begin
      try
        CheckLogRotation;
        WriteMessageToFile(LMessage^);
      finally
        FreeMem(LMessage);
      end;
    end;
  end;
  // Обработка оставшихся сообщений после команды на завершение
  while FQueue.GetCount > 0 do
  begin
    LMessage := FQueue.Dequeue(0);
    if Assigned(LMessage) then
    begin
      try
        CheckLogRotation;
        WriteMessageToFile(LMessage^);
      finally
        FreeMem(LMessage);
      end;
    end;
  end;
end;

function GetFileSize(const FileName : String) : Int64;
var
  myFile : File of byte;
begin
  AssignFile(myFile, FileName);
  ReWrite(myFile);
  Result := FileSize(myFile);
  CloseFile(myFile);
end;


procedure TLoggerWriterThread.CheckLogRotation;
var
  i: Integer;
  LBaseName, LExt, LRotatedName, LOldName: string;
begin
  if not FileExists(FLogFileName) then
    Exit;

  if GetFileSize(FLogFileName) < FMaxLogSize then
    Exit;

  LBaseName := ChangeFileExt(FLogFileName, '');
  LExt := ExtractFileExt(FLogFileName);

  // Удаляем самый старый файл, если он есть
  LOldName := LBaseName + '.' + IntToStr(FMaxLogFiles) + LExt;
  if FileExists(LOldName) then
    DeleteFile(LOldName);

  // Сдвигаем архивные файлы
  for i := FMaxLogFiles - 1 downto 1 do
  begin
    LOldName := LBaseName + '.' + IntToStr(i) + LExt;
    if FileExists(LOldName) then
    begin
      LRotatedName := LBaseName + '.' + IntToStr(i + 1) + LExt;
      RenameFile(LOldName, LRotatedName);
    end;
  end;

  // Переименовываем текущий лог-файл
  LRotatedName := LBaseName + '.1' + LExt;
  RenameFile(FLogFileName, LRotatedName);
end;

procedure TLoggerWriterThread.WriteMessageToFile(const ALogMessage: TLogMessage);
var
  F: TextFile;
  s: string;
begin
  // Форматируем сообщение
  s := Format('%s [%s] (Thread %d): %s', [
    FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ALogMessage.Timestamp),
    LogPriorityStrings[ALogMessage.Priority],
    ALogMessage.ThreadID,
    ALogMessage.Message
  ]);

  AssignFile(F, FLogFileName);
  try
    if FileExists(FLogFileName) then
      Append(F)
    else
      Rewrite(F);

    Writeln(F, s);
  finally
    CloseFile(F);
  end;
end;

{ TLogger }

constructor TLogger.Create;
begin
 // FreeOnTerminate:= True;
  FInitialized := False;
  FQueue := nil;
  FWriterThread := nil;
end;

destructor TLogger.Destroy;
begin
  FinalizeLogger;
  inherited Destroy;
end;

class function TLogger.GetInstance: TLogger;
begin
  if not Assigned(FInstance) then
    FInstance := TLogger.Create;
  Result := FInstance;
end;

procedure TLogger.Initialize(const ALogFileName: string; AMaxLogSizeKB: Integer; AMaxLogFiles: Integer);
begin
  if FInitialized then
    Exit;

  FQueue := TThreadSafeQueue.Create;
  FWriterThread := TLoggerWriterThread.Create(FQueue, ALogFileName, AMaxLogSizeKB, AMaxLogFiles);
//  FWriterThread.FreeOnTerminate:= True;   ///////////////////////////////
  FWriterThread.Start;
  FInitialized := True;
end;

procedure TLogger.FinalizeLogger;
begin
  if not FInitialized then
    Exit;

  // Даем потоку немного времени на обработку оставшихся сообщений
  while FQueue.GetCount > 0 do
    Sleep(500);

  if Assigned(FWriterThread) then
  begin
    FWriterThread.Terminate;

  //  FWriterThread.WaitFor;
  //  FWriterThread.Free;
    FreeAndNil(FWriterThread);
   // FWriterThread.Destroy;
  end;

  if Assigned(FQueue) then
    FreeAndNil(FQueue);

  FInitialized := False;
end;

procedure TLogger.Log(APriority: TLogPriority; const AMessage: string);
var
  LMessage: PLogMessage;
begin
  if not FInitialized then
    Exit;

  New(LMessage);
  LMessage^.Timestamp := Now;
  LMessage^.ThreadID := GetCurrentThreadID;
  LMessage^.Priority := APriority;
  LMessage^.Message := AMessage;

  FQueue.Enqueue(LMessage);
end;

procedure TLogger.Debug(const AMessage: string);
begin
  Log(lpDebug, AMessage);
end;

procedure TLogger.Info(const AMessage: string);
begin
  Log(lpInfo, AMessage);
end;

procedure TLogger.Warning(const AMessage: string);
begin
  Log(lpWarning, AMessage);
end;

procedure TLogger.Error(const AMessage: string);
begin
  Log(lpError, AMessage);
end;

procedure TLogger.Critical(const AMessage: string);
begin
  Log(lpCritical, AMessage);
end;


initialization
  // При инициализации модуля создается экземпляр синглтона
  TLogger.FInstance := nil;

finalization
  // При финализации модуля экземпляр уничтожается
  if Assigned(TLogger.FInstance) then
    TLogger.FInstance.Free;

end.
