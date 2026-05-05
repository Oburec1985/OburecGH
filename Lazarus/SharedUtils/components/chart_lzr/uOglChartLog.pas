unit uOglChartLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs;

procedure ChartLogSetFileName(const AFileName: string);
function ChartLogFileName: string;
procedure ChartLogDebug(const AMessage: string);
procedure ChartLogInfo(const AMessage: string);
procedure ChartLogWarning(const AMessage: string);
procedure ChartLogError(const AMessage: string);
procedure ChartLogException(const AContext: string; E: Exception);
function ChartPtr(AObject: TObject): string;

implementation

var
  gLogLock: TCriticalSection = nil;
  gLogFileName: string = '';

function DefaultLogFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'oglchart_debug.log';
end;

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
