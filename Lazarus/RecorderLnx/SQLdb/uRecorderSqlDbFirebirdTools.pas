unit uRecorderSqlDbFirebirdTools;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderSqlDbTypes;

function RecorderSqlDbFirebirdProbeHost(const AHost: string): string;
function RecorderSqlDbFirebirdHostIsLocal(const AHost: string): Boolean;
function RecorderSqlDbFirebirdTcpAvailable(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal; out AMessage: string): Boolean;
function RecorderSqlDbStartLocalFirebird(out AMessage: string): Boolean;
function RecorderSqlDbDescribeLocalFirebird(APort: Word): string;
function RecorderSqlDbRunFirebirdSweep(AConfig: TRecorderSqlDbConfig;
  out AMessage: string): Boolean;

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
    try
      lProcess.Execute;
    except
      on E: Exception do
      begin
        AOutput := E.Message;
        Exit(False);
      end;
    end;
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

function RecorderSqlDbFirebirdDatabaseSpec(AConfig: TRecorderSqlDbConfig): string;
var
  lHost: string;
begin
  Result := '';
  if AConfig = nil then Exit;
  lHost := RecorderSqlDbFirebirdProbeHost(AConfig.Host);
  if (AConfig.Port <> 0) and (Pos('/', lHost) = 0) then
    lHost := lHost + '/' + IntToStr(AConfig.Port);
  if RecorderSqlDbFirebirdHostIsLocal(AConfig.Host) and (Trim(AConfig.Host) = '') then
    Result := AConfig.DatabaseFileName
  else
    Result := lHost + ':' + AConfig.DatabaseFileName;
end;

function RecorderSqlDbFirebirdToolCandidates(const AToolName: string): TStringList;

  procedure AddCandidate(const AValue: string);
  begin
    if (Trim(AValue) <> '') and FileExists(AValue) and
      (Result.IndexOf(AValue) < 0) then
      Result.Add(AValue);
  end;

  procedure AddUnder(const ARoot: string);
  begin
    if Trim(ARoot) = '' then Exit;
    {$ifdef windows}
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) + AToolName + '.exe');
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) + 'bin\' + AToolName + '.exe');
    {$else}
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) + AToolName);
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) + 'bin/' + AToolName);
    {$endif}
  end;

var
  lFirebird: string;
begin
  Result := TStringList.Create;
  lFirebird := Trim(GetEnvironmentVariable('FIREBIRD'));
  if lFirebird = '' then
    lFirebird := Trim(GetEnvironmentVariable('FIREBIRD_HOME'));
  AddUnder(lFirebird);
  {$ifdef windows}
  AddUnder('C:\Firebird');
  AddUnder('C:\Program Files\Firebird\Firebird_5_0');
  AddUnder('C:\Program Files (x86)\Firebird\Firebird_5_0');
  AddUnder('C:\Program Files\Firebird\Firebird_4_0');
  {$else}
  AddUnder('/opt/firebird');
  AddUnder('/usr/bin');
  AddUnder('/usr/local/bin');
  {$endif}
end;

function RecorderSqlDbRunFirebirdSweep(AConfig: TRecorderSqlDbConfig;
  out AMessage: string): Boolean;
var
  I: Integer;
  lCandidates: TStringList;
  lDatabase, lOutput, lLog: string;
begin
  Result := False;
  lLog := '';
  if (AConfig = nil) or (AConfig.Backend <> rsbFirebird) then
  begin
    AMessage := 'Сборка мусора поддержана только для Firebird.';
    Exit;
  end;
  lDatabase := RecorderSqlDbFirebirdDatabaseSpec(AConfig);
  lCandidates := RecorderSqlDbFirebirdToolCandidates('gfix');
  try
    if lCandidates.Count = 0 then
    begin
      AMessage := 'Утилита Firebird gfix не найдена. ' +
        'Обычно она лежит в /opt/firebird/bin или в каталоге Firebird.';
      Exit;
    end;
    for I := 0 to lCandidates.Count - 1 do
    begin
      Result := RunProcessCapture(lCandidates[I],
        ['-user', AConfig.UserName, '-password', AConfig.Password,
         '-sweep', lDatabase], 30000, lOutput);
      lLog := AppendAttempt(lLog, lCandidates[I] + ' -sweep', lOutput);
      if Result then Break;
    end;
  finally
    lCandidates.Free;
  end;
  if Result then
    AMessage := 'Сборка мусора Firebird выполнена.' + LineEnding + lLog
  else
    AMessage := 'Не удалось выполнить сборку мусора Firebird.' +
      LineEnding + lLog;
end;

function OutputHasTcpListen(const AOutput: string; APort: Word): Boolean;
var
  lText: string;
begin
  lText := LowerCase(AOutput);
  Result := (Pos(':' + IntToStr(APort), lText) > 0) and
    (Pos('listen', lText) > 0);
end;

function RecorderSqlDbDescribeLocalFirebird(APort: Word): string;
var
  lOutput, lLog: string;
begin
  Result := '';
  {$ifdef windows}
  lLog := '';
  if RunProcessCapture('sc.exe', ['query', 'FirebirdServerDefaultInstance'],
    3000, lOutput) then
    lLog := AppendAttempt(lLog, 'sc query FirebirdServerDefaultInstance',
      lOutput)
  else
    lLog := AppendAttempt(lLog, 'sc query FirebirdServerDefaultInstance',
      lOutput);
  if RunProcessCapture('netstat.exe', ['-ano', '-p', 'tcp'], 3000, lOutput) then
  begin
    if OutputHasTcpListen(lOutput, APort) then
      lLog := AppendAttempt(lLog, 'netstat', 'TCP port ' +
        IntToStr(APort) + ' is listening')
    else
      lLog := AppendAttempt(lLog, 'netstat', 'TCP port ' +
        IntToStr(APort) + ' is not listening');
  end;
  Result := lLog;
  {$else}
  lLog := '';
  if FileExists('/bin/systemctl') then
    RunProcessCapture('/bin/systemctl',
      ['--no-pager', '--full', 'status', 'firebird.service'], 3000, lOutput)
  else if FileExists('/usr/bin/systemctl') then
    RunProcessCapture('/usr/bin/systemctl',
      ['--no-pager', '--full', 'status', 'firebird.service'], 3000, lOutput)
  else
    lOutput := 'systemctl was not found';
  lLog := AppendAttempt(lLog, 'systemctl status firebird.service', lOutput);
  Result := lLog;
  {$endif}
end;

{$ifdef windows}
function WindowsEnv(const AName: string): string;
begin
  Result := Trim(GetEnvironmentVariable(AName));
end;

function WindowsFirebirdExeCandidates: TStringList;

  procedure AddCandidate(const AValue: string);
  begin
    if (AValue <> '') and FileExists(AValue) and (Result.IndexOf(AValue) < 0) then
      Result.Add(AValue);
  end;

  procedure AddUnderProgramFiles(const ARoot: string);
  begin
    if ARoot = '' then Exit;
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) +
      'Firebird\Firebird_5_0\firebird.exe');
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) +
      'Firebird\Firebird_4_0\firebird.exe');
    AddCandidate(IncludeTrailingPathDelimiter(ARoot) +
      'Firebird\Firebird_3_0\firebird.exe');
  end;

var
  lFirebird: string;
begin
  Result := TStringList.Create;
  lFirebird := WindowsEnv('FIREBIRD');
  if lFirebird = '' then
    lFirebird := WindowsEnv('FIREBIRD_HOME');
  if lFirebird <> '' then
    AddCandidate(IncludeTrailingPathDelimiter(lFirebird) + 'firebird.exe');
  AddUnderProgramFiles(WindowsEnv('ProgramFiles'));
  AddUnderProgramFiles(WindowsEnv('ProgramFiles(x86)'));
  AddCandidate('C:\Firebird\firebird.exe');
end;

function TryStartFirebirdApplication(out ALog: string): Boolean;
var
  I: Integer;
  lCandidates: TStringList;
  lProcess: TProcess;
begin
  Result := False;
  lCandidates := WindowsFirebirdExeCandidates;
  try
    if lCandidates.Count = 0 then
    begin
      ALog := AppendAttempt(ALog, 'firebird.exe -a',
        'firebird.exe was not found in standard paths');
      Exit;
    end;
    for I := 0 to lCandidates.Count - 1 do
    begin
      lProcess := TProcess.Create(nil);
      try
        lProcess.Executable := lCandidates[I];
        lProcess.Parameters.Add('-a');
        lProcess.Options := [poNoConsole];
        try
          lProcess.Execute;
        except
          on E: Exception do
          begin
            ALog := AppendAttempt(ALog, 'firebird.exe -a',
              lCandidates[I] + LineEnding + E.Message);
            Continue;
          end;
        end;
        ALog := AppendAttempt(ALog, 'firebird.exe -a', lCandidates[I]);
        Result := True;
        Exit;
      finally
        lProcess.Free;
      end;
    end;
  finally
    lCandidates.Free;
  end;
end;

function AddFirebirdServicesFromQuery(AItems: TStrings; const AOutput: string): Integer;
var
  lLine, lName: string;
  lLines: TStringList;
  I, lPos: Integer;
begin
  Result := 0;
  lLines := TStringList.Create;
  try
    lLines.Text := AOutput;
    for I := 0 to lLines.Count - 1 do
    begin
      lLine := Trim(lLines[I]);
      lPos := Pos(':', lLine);
      if (lPos <= 0) or (Pos('SERVICE_NAME', UpperCase(lLine)) <> 1) then
        Continue;
      lName := Trim(Copy(lLine, lPos + 1, MaxInt));
      if (Pos('firebird', LowerCase(lName)) > 0) and
        (AItems.IndexOf(lName) < 0) then
      begin
        AItems.Add(lName);
        Inc(Result);
      end;
    end;
  finally
    lLines.Free;
  end;
end;
{$endif}

function RecorderSqlDbStartLocalFirebird(out AMessage: string): Boolean;
var
  {$ifdef windows}
  I: Integer;
  lServices: TStringList;
  {$endif}
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
  lServices := TStringList.Create;
  try
  if RunProcessCapture('sc.exe', ['query', 'state=', 'all'], 6000, lOutput) then
    AddFirebirdServicesFromQuery(lServices, lOutput);
  if lServices.IndexOf('FirebirdServerDefaultInstance') < 0 then
    lServices.Insert(0, 'FirebirdServerDefaultInstance');
  if lServices.IndexOf('FirebirdGuardianDefaultInstance') < 0 then
    lServices.Add('FirebirdGuardianDefaultInstance');
  if TryCommand('sc start FirebirdServerDefaultInstance',
    'sc.exe', ['start', 'FirebirdServerDefaultInstance']) then
    Result := True
  else if TryCommand('sc start FirebirdGuardianDefaultInstance',
    'sc.exe', ['start', 'FirebirdGuardianDefaultInstance']) then
    Result := True
  else if TryCommand('net start FirebirdServerDefaultInstance',
    'net.exe', ['start', 'FirebirdServerDefaultInstance']) then
    Result := True
  else
  begin
    for I := 0 to lServices.Count - 1 do
    begin
      if (lServices[I] = 'FirebirdServerDefaultInstance') or
        (lServices[I] = 'FirebirdGuardianDefaultInstance') then
        Continue;
      if TryCommand('sc start ' + lServices[I], 'sc.exe',
        ['start', lServices[I]]) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
  if not Result then
    Result := TryStartFirebirdApplication(lLog);
  finally
    lServices.Free;
  end;
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
