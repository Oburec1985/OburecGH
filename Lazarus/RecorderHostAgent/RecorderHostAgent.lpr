program RecorderHostAgent;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}cthreads,{$endif}
  {$ifdef windows}Windows,{$endif}
  Classes, SysUtils, uRecorderHostAgentConfig, uRecorderHostAgentServer;

const
  CIdleIntervalMs = 500;

var
  lConfig: TRecorderHostAgentConfig;
  lServer: THostAgentServer;
  lConfigFile: string;
  lError: string;

procedure LogStartupFailure(const AMessage: string);
var
  lLog: TextFile;
  lLogFile: string;
begin
  lLogFile := ChangeFileExt(ParamStr(0), '.log');
  try
    AssignFile(lLog, lLogFile);
    if FileExists(lLogFile) then
      Append(lLog)
    else
      Rewrite(lLog);
    try
      WriteLn(lLog, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
        ' startup failed: ', AMessage);
    finally
      CloseFile(lLog);
    end;
  except
    { Failure to write a diagnostic must not turn a normal duplicate start
      into an application crash. }
  end;
end;

{$ifdef windows}
{ Windows kills every process attached to a console when that console goes
  away (SSH channel closed, RDP session ended, installer console finished).
  CTRL_CLOSE_EVENT cannot save us there: OpenSSH tears down the whole process
  tree. The only reliable fix is to stop owning the inherited console, so the
  agent outlives whatever started it. Returns False only when the process has
  no console at all, which is a perfectly good final state. }
procedure DetachFromLaunchingConsole;
var
  lStdIn: THandle;
  lStdOut: THandle;
begin
  if FreeConsole then
  begin
    { Without a console, ReadLn would raise; give stdin/stdout a valid sink. }
    lStdIn := CreateFile('\\.\NUL', GENERIC_READ, FILE_SHARE_READ or
      FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    lStdOut := CreateFile('\\.\NUL', GENERIC_WRITE, FILE_SHARE_READ or
      FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    if lStdIn <> INVALID_HANDLE_VALUE then
      SetStdHandle(STD_INPUT_HANDLE, lStdIn);
    if lStdOut <> INVALID_HANDLE_VALUE then
    begin
      SetStdHandle(STD_OUTPUT_HANDLE, lStdOut);
      SetStdHandle(STD_ERROR_HANDLE, lStdOut);
    end;
  end;
end;
{$endif}

{ TFPHTTPServer serves requests from its own worker threads, but the process
  itself lives only while the main thread stays alive. Without this wait the
  console program reached "end." immediately after Active := True, so the agent
  vanished right after reporting itself ready - remote shutdown therefore
  always failed with "connection refused". Stopping is explicit: a line on
  stdin, or EOF when stdin is gone. On EOF the agent keeps serving instead of
  exiting, so a detached start cannot kill it. }
procedure WaitForStopRequest;
begin
  try
    ReadLn;
  except
    on E: EInOutError do
      { stdin is not readable (no console / closed handle): serve forever. }
      ;
  end;
  { A line was read, or stdin reported EOF: keep the process alive. }
  while True do
    Sleep(CIdleIntervalMs);
end;

begin
  {$ifdef windows}
  DetachFromLaunchingConsole;
  {$endif}
  lConfigFile := ChangeFileExt(ParamStr(0), '.ini');
  lConfig := TRecorderHostAgentConfig.Create;
  try
    lConfig.Load(lConfigFile);
    lServer := THostAgentServer.Create(lConfig);
    try
      {$ifndef windows}
      WriteLn('RecorderHostAgent listening on ', lConfig.ListenAddress, ':', lConfig.Port);
      WriteLn('Config: ', lConfigFile);
      {$endif}
      if not lServer.TryStart(lError) then
      begin
        LogStartupFailure(lError);
        ExitCode := 2;
      end
      else
        WaitForStopRequest;
    finally
      lServer.Free;
    end;
  finally
    lConfig.Free;
  end;
end.
