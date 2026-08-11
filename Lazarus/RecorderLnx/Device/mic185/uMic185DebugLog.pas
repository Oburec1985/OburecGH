unit uMic185DebugLog;

{
  Лог стенда MIC183/185: файл + буфер для отображения в Memo через Mic185LogPumpTo.
  Без прямой записи в TMemo.Lines из обработчиков — избегаем AV при reentrancy LCL.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDebugLog, uSharedFileLogger;

{ Инициализирует файл и кольцевой буфер лога MIC-185. }
procedure Mic185LogInit(const ALogPath: string = '');
{ Совместимость со старым UI: теперь только прокачивает буфер в Lines. }
procedure Mic185LogAttachLines(ALines: TStrings); deprecated 'use Mic185LogPumpTo from a timer';
{ Совместимость со старым UI, реального detach больше не требуется. }
procedure Mic185LogDetachLines; deprecated 'no longer needed';
{ Переносит новые строки лога в Memo/ListBox из GUI-таймера. }
procedure Mic185LogPumpTo(ALines: TStrings);
{ Добавляет строку в файл и память, защищая доступ critical section. }
procedure Mic185Log(const AMsg: string);
{ Возвращает текущий путь файла лога. }
function Mic185LogFilePath: string;

implementation

var
  gLogPath: string = '';
  gLogBuffer: TStringList = nil;
  gLogPumpPos: Integer = 0;
  gLogLock: TRTLCriticalSection;
  gLogLockReady: Boolean = False;

procedure Mic185LogInit(const ALogPath: string);
begin
  if not gLogLockReady then
  begin
    InitCriticalSection(gLogLock);
    gLogLockReady := True;
  end;
  if gLogBuffer = nil then
    gLogBuffer := TStringList.Create;
  if ALogPath <> '' then
    gLogPath := ALogPath
  else
    gLogPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'mic185_protocol_debug.log';
end;

procedure Mic185LogAttachLines(ALines: TStrings);
begin
  Mic185LogPumpTo(ALines);
end;

procedure Mic185LogDetachLines;
begin
  // kept for source compatibility; buffer is always used
end;

function Mic185LogFilePath: string;
begin
  Result := gLogPath;
end;

const
  CMic185LogBufferMaxLines = 3000;
  CMic185MemLogMaxLines = 400;

procedure Mic185LogPumpTo(ALines: TStrings);
var
  I: Integer;
begin
  if (gLogBuffer = nil) or (ALines = nil) then
    Exit;
  if not gLogLockReady then
    Mic185LogInit('');
  EnterCriticalSection(gLogLock);
  try
    for I := gLogPumpPos to gLogBuffer.Count - 1 do
      ALines.Add(gLogBuffer[I]);
    gLogPumpPos := gLogBuffer.Count;
    while ALines.Count > CMic185MemLogMaxLines do
      ALines.Delete(0);
  finally
    LeaveCriticalSection(gLogLock);
  end;
end;

procedure Mic185AppendLineToFile(const ALine: string);
var
  lHandle: THandle;
  lText: UTF8String;
begin
  if FileExists(gLogPath) then
    lHandle := FileOpen(gLogPath, fmOpenWrite or fmShareDenyNone)
  else
    lHandle := FileCreate(gLogPath);
  if lHandle = THandle(-1) then
    Exit;
  try
    FileSeek(lHandle, 0, fsFromEnd);
    lText := UTF8String(ALine + LineEnding);
    if lText <> '' then
      FileWrite(lHandle, lText[1], Length(lText));
  finally
    FileClose(lHandle);
  end;
end;

procedure Mic185Log(const AMsg: string);
var
  lLine: string;
  lFs: TFormatSettings;
begin
  if not DeviceLogEnabled then
    Exit;
  if not gLogLockReady then
    Mic185LogInit('');
  lFs := DefaultFormatSettings;
  lLine := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now, lFs) + '  ' + AMsg;
  EnterCriticalSection(gLogLock);
  try
    gLogBuffer.Add(lLine);
    while gLogBuffer.Count > CMic185LogBufferMaxLines do
      gLogBuffer.Delete(0);
    if gLogPumpPos > gLogBuffer.Count then
      gLogPumpPos := gLogBuffer.Count;
    { Общий runtime уже пишет эту строку через SharedLogger. Два независимых
      writer-а одного файла приводили к AppendFileLine и повреждению строк. }
    if (gLogPath <> '') and
       (not SameFileName(gLogPath, SharedLogger.FileName)) then
    begin
      try
        Mic185AppendLineToFile(lLine);
      except
      end;
    end;
  finally
    LeaveCriticalSection(gLogLock);
  end;
end;

finalization
  if gLogLockReady then
    DoneCriticalSection(gLogLock);
  FreeAndNil(gLogBuffer);

end.
