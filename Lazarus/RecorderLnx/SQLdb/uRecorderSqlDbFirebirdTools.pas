unit uRecorderSqlDbFirebirdTools;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

function RecorderSqlDbFirebirdProbeHost(const AHost: string): string;
function RecorderSqlDbFirebirdHostIsLocal(const AHost: string): Boolean;
function RecorderSqlDbFirebirdTcpAvailable(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out AMessage: string): Boolean;
function RecorderSqlDbStartLocalFirebird(out AMessage: string): Boolean;

implementation

uses
  Process, uRecorderNetworkBinding;

function RecorderSqlDbFirebirdProbeHost(const AHost: string): string;
begin
  Result := Trim(AHost);
  if Result = '' then
    Result := '127.0.0.1';
end;

function RecorderSqlDbFirebirdHostIsLocal(const AHost: string): Boolean;
var
  lHost: string;
begin
  lHost := LowerCase(Trim(AHost));
  Result := (lHost = '') or (lHost = 'localhost') or
    (lHost = '127.0.0.1') or (lHost = '::1');
end;

function RecorderSqlDbFirebirdTcpAvailable(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out AMessage: string): Boolean;
var
  lHost: string;
begin
  lHost := RecorderSqlDbFirebirdProbeHost(AHost);
  Result := RecorderTcpPortOpen(lHost, APort, ATimeoutMs);
  if Result then
    AMessage := Format('Firebird доступен: %s:%d.', [lHost, APort])
  else
    AMessage := Format('Firebird не отвечает: %s:%d.', [lHost, APort]);
end;

function RunProcessCapture(const AExecutable: string; const AParams: array of string;
  ATimeoutMs: Cardinal; out AOutput: string): Boolean;
var
  I: Integer;
  lProcess: TProcess;
  lBuffer: array[0..4095] of Byte;
  lChunk: string;
  lRead: LongInt;
  lStarted: QWord;
begin
  Result := False;
  AOutput := '';
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := AExecutable;
    for I := Low(AParams) to High(AParams) do
      lProcess.Parameters.Add(AParams[I]);
    lProcess.Options := [poUsePipes, poStderrToOutPut];
    lStarted := GetTickCount64;
    lProcess.Execute;
    while lProcess.Running do
    begin
      while lProcess.Output.NumBytesAvailable > 0 do
      begin
        lRead := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lRead > 0 then
        begin
          SetString(lChunk, PChar(@lBuffer[0]), lRead);
          AOutput := AOutput + lChunk;
        end;
      end;
      if GetTickCount64 - lStarted > ATimeoutMs then
      begin
        lProcess.Terminate(1);
        AOutput := AOutput + LineEnding + 'Команда запуска Firebird превысила таймаут.';
        Exit(False);
      end;
      Sleep(50);
    end;
    while lProcess.Output.NumBytesAvailable > 0 do
    begin
      lRead := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
      if lRead > 0 then
      begin
        SetString(lChunk, PChar(@lBuffer[0]), lRead);
        AOutput := AOutput + lChunk;
      end;
    end;
    Result := lProcess.ExitStatus = 0;
  finally
    lProcess.Free;
  end;
end;

function CommandSuccessOrAlreadyRunning(const AOutput: string): Boolean;
var
  lText: string;
begin
  lText := LowerCase(AOutput);
  Result := (Pos('already', lText) > 0) or (Pos('1056', lText) > 0) or
    (Pos('уже', lText) > 0) or (Pos('запущ', lText) > 0) or
    (Pos('active', lText) > 0);
end;

function AppendAttempt(const ALog, ATitle, AOutput: string): string;
begin
  Result := ALog;
  if Result <> '' then
    Result := Result + LineEnding + LineEnding;
  Result := Result + ATitle;
  if Trim(AOutput) <> '' then
    Result := Result + LineEnding + Trim(AOutput);
end;

function RecorderSqlDbStartLocalFirebird(out AMessage: string): Boolean;
var
  lOutput, lLog: string;

  function TryCommand(const ATitle, AExecutable: string;
    const AParams: array of string): Boolean;
  begin
    Result := RunProcessCapture(AExecutable, AParams, 8000, lOutput) or
      CommandSuccessOrAlreadyRunning(lOutput);
    lLog := AppendAttempt(lLog, ATitle, lOutput);
  end;

begin
  Result := False;
  lLog := '';
  {$ifdef windows}
  if TryCommand('sc start FirebirdServerDefaultInstance',
    'sc.exe', ['start', 'FirebirdServerDefaultInstance']) then
    Result := True
  else if TryCommand('sc start FirebirdGuardianDefaultInstance',
    'sc.exe', ['start', 'FirebirdGuardianDefaultInstance']) then
    Result := True
  else if TryCommand('net start FirebirdServerDefaultInstance',
    'net.exe', ['start', 'FirebirdServerDefaultInstance']) then
    Result := True;
  {$else}
  if FileExists('/bin/systemctl') then
    Result := TryCommand('systemctl start firebird.service',
      '/bin/systemctl', ['start', 'firebird.service'])
  else if FileExists('/usr/bin/systemctl') then
    Result := TryCommand('systemctl start firebird.service',
      '/usr/bin/systemctl', ['start', 'firebird.service']);
  if (not Result) and FileExists('/usr/sbin/service') then
    Result := TryCommand('service firebird start',
      '/usr/sbin/service', ['firebird', 'start']);
  if (not Result) and FileExists('/sbin/service') then
    Result := TryCommand('service firebird start',
      '/sbin/service', ['firebird', 'start']);
  {$endif}
  if Result then
    AMessage := 'Команда запуска Firebird выполнена.' + LineEnding + lLog
  else
    AMessage := 'Не удалось запустить локальный Firebird. ' +
      'Проверьте, установлен ли сервис и есть ли права администратора/root.' +
      LineEnding + lLog;
end;

end.
