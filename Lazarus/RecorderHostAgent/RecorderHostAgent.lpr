program RecorderHostAgent;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, uRecorderHostAgentConfig, uRecorderHostAgentServer;

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

begin
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
      end;
    finally
      lServer.Free;
    end;
  finally
    lConfig.Free;
  end;
end.
