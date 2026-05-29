unit uOglChartLog;

{$mode objfpc}{$H+}

{
  Модуль uOglChartLog
  Описание: Обеспечивает потокобезопасное ведение отладочных логов компонента OGlChart.
            Поддерживает уровни логирования DEBUG, INFO, WARNING, ERROR и форматированный вывод.
}

interface

uses
  Classes, SysUtils, SyncObjs;

// Задает имя файла для сохранения лога
procedure ChartLogSetFileName(const AFileName: string);
// Возвращает текущее имя файла лога
function ChartLogFileName: string;
// Выводит отладочное сообщение
procedure ChartLogDebug(const AMessage: string);
// Выводит информационное сообщение
procedure ChartLogInfo(const AMessage: string);
// Выводит предупреждение
procedure ChartLogWarning(const AMessage: string);
// Выводит ошибку
procedure ChartLogError(const AMessage: string);
// Выводит описание исключения
procedure ChartLogException(const AContext: string; E: Exception);
// Преобразует указатель объекта в шестнадцатеричную строку (для логирования адресов)
function ChartPtr(AObject: TObject): string;

implementation

var
  gLogLock: TCriticalSection = nil;      // Критическая секция для защиты файла лога при многопоточном доступе
  gLogFileName: string = '';             // Путь к файлу лога

/// <summary>
/// Вычисляет имя лог-файла по умолчанию в папке исполняемого файла программы.
/// </summary>
function DefaultLogFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'oglchart_debug.log';
end;

/// <summary>
/// Инициализирует критическую секцию логирования, если она еще не создана.
/// </summary>
procedure EnsureLogLock;
begin
  if not Assigned(gLogLock) then
    gLogLock := TCriticalSection.Create;
end;

function ChartLogFileName: string;
begin
  if gLogFileName = '' then
    gLogFileName := DefaultLogFileName;
  Result := gLogFileName;
end;

procedure ChartLogSetFileName(const AFileName: string);
begin
  EnsureLogLock;
  gLogLock.Enter;
  try
    gLogFileName := AFileName;
  finally
    gLogLock.Leave;
  end;
end;

/// <summary>
/// Записывает сообщение в лог-файл.
/// Добавляет временную метку, приоритет, ID текущего потока и переданный текст.
/// </summary>
procedure WriteLog(const APriority, AMessage: string);
var
  F: TextFile;
  LFileName: string;
begin
  EnsureLogLock;
  gLogLock.Enter;
  try
    LFileName := ChartLogFileName;
    AssignFile(F, LFileName);
    try
      // Если файл существует — дописываем, иначе создаем новый
      if FileExists(LFileName) then
        Append(F)
      else
        Rewrite(F);
      Writeln(F, Format('%s [%s] thread=%d %s', [
        FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
        APriority,
        GetCurrentThreadId,
        AMessage
      ]));
    finally
      CloseFile(F);
    end;
  finally
    gLogLock.Leave;
  end;
end;

procedure ChartLogDebug(const AMessage: string);
begin
  WriteLog('DEBUG', AMessage);
end;

procedure ChartLogInfo(const AMessage: string);
begin
  WriteLog('INFO', AMessage);
end;

procedure ChartLogWarning(const AMessage: string);
begin
  WriteLog('WARNING', AMessage);
end;

procedure ChartLogError(const AMessage: string);
begin
  WriteLog('ERROR', AMessage);
end;

/// <summary>
/// Записывает информацию об исключении.
/// </summary>
procedure ChartLogException(const AContext: string; E: Exception);
begin
  if Assigned(E) then
    ChartLogError(Format('%s exception=%s message="%s"', [
      AContext,
      E.ClassName,
      E.Message
    ]))
  else
    ChartLogError(AContext + ' exception=nil');
end;

/// <summary>
/// Преобразует адрес объекта в строку формата $XXXXXXXX для отладки жизненного цикла объектов.
/// </summary>
function ChartPtr(AObject: TObject): string;
begin
  if Assigned(AObject) then
    Result := '$' + IntToHex(PtrUInt(AObject), SizeOf(Pointer) * 2)
  else
    Result := 'nil';
end;

initialization
  EnsureLogLock;

finalization
  FreeAndNil(gLogLock);

end.
