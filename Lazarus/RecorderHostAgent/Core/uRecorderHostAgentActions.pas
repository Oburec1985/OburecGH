unit uRecorderHostAgentActions;

{$mode objfpc}{$H+}

interface

uses SysUtils, fpjson, uRecorderHostAgentConfig;

function HostAgentStatusJson(AConfig: TRecorderHostAgentConfig): TJSONObject;
function HostAgentLaunchRecorder(AConfig: TRecorderHostAgentConfig;
  out AMessage: string): Boolean;
function HostAgentShutdown(AConfig: TRecorderHostAgentConfig;
  out AMessage: string): Boolean;

implementation

uses
  Classes, Process
  {$ifdef unix}
  , BaseUnix
  {$endif}
  ;

{$ifdef unix}
const
  CCloseOnExecDescriptorFlag = 1; { POSIX FD_CLOEXEC }

type
  { TInheritedDescriptorCloser }

  TInheritedDescriptorCloser = class
  private
    fDescriptors: array of Integer;
  public
    constructor Create;
    procedure MarkCloseOnExec;
    procedure CloseInChild(Sender: TObject);
  end;

constructor TInheritedDescriptorCloser.Create;
var
  lSearch: TSearchRec;
  lDescriptor: Integer;
begin
  inherited Create;
  if FindFirst('/proc/self/fd/*', faAnyFile, lSearch) <> 0 then
    Exit;
  try
    repeat
      if TryStrToInt(lSearch.Name, lDescriptor) and (lDescriptor > 2) then
      begin
        SetLength(fDescriptors, Length(fDescriptors) + 1);
        fDescriptors[High(fDescriptors)] := lDescriptor;
      end;
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

procedure TInheritedDescriptorCloser.MarkCloseOnExec;
var
  lIndex: Integer;
  lFlags: cint;
begin
  // The listener must remain open in HostAgent, but it must not survive the
  // exec() which replaces the forked child with RecorderLnx.  OnForkEvent is
  // kept below as a second line of defence for older Unix/FPC combinations.
  for lIndex := 0 to High(fDescriptors) do
  begin
    lFlags := fpFcntl(fDescriptors[lIndex], F_GETFD, 0);
    if lFlags >= 0 then
      fpFcntl(fDescriptors[lIndex], F_SETFD,
        lFlags or CCloseOnExecDescriptorFlag);
  end;
end;

procedure TInheritedDescriptorCloser.CloseInChild(Sender: TObject);
var
  lIndex: Integer;
begin
  // TProcess calls this after fork and before exec. Closing the snapshot only
  // affects RecorderLnx; HostAgent keeps ownership of its listener and clients.
  for lIndex := 0 to High(fDescriptors) do
    fpClose(fDescriptors[lIndex]);
end;
{$endif}

function HostAgentStatusJson(AConfig: TRecorderHostAgentConfig): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('result_code', 'noError');
  Result.Add('service', 'RecorderHostAgent');
  Result.Add('version', '0.1.2');
  Result.Add('status', 'ready');
  Result.Add('recorder_available', FileExists(AConfig.RecorderPath));
  Result.Add('shutdown_enabled', AConfig.AllowShutdown);
end;

function HostAgentLaunchRecorder(AConfig: TRecorderHostAgentConfig;
  out AMessage: string): Boolean;
var
  lProcess: TProcess;
  {$ifdef unix}
  lDescriptorCloser: TInheritedDescriptorCloser;
  {$endif}
begin
  Result := False;
  if not FileExists(AConfig.RecorderPath) then
  begin
    AMessage := 'RecorderLnx executable not found';
    Exit;
  end;
  lProcess := TProcess.Create(nil);
  {$ifdef unix}
  lDescriptorCloser := TInheritedDescriptorCloser.Create;
  lDescriptorCloser.MarkCloseOnExec;
  {$endif}
  try
    lProcess.Executable := AConfig.RecorderPath;
    lProcess.CurrentDirectory := ExtractFilePath(AConfig.RecorderPath);
    lProcess.Options := [poNoConsole];
    {$ifdef unix}
    lProcess.OnForkEvent := @lDescriptorCloser.CloseInChild;
    {$endif}
    lProcess.Execute;
    AMessage := 'RecorderLnx started';
    Result := True;
  finally
    lProcess.Free;
    {$ifdef unix}
    lDescriptorCloser.Free;
    {$endif}
  end;
end;

function HostAgentShutdown(AConfig: TRecorderHostAgentConfig;
  out AMessage: string): Boolean;
{$ifndef windows}
const
  CLinuxShutdownHelper = '/usr/local/sbin/recorder-host-agent-shutdown';
{$endif}
var
  lProcess: TProcess;
  lOutput: TStringList;
begin
  Result := False;
  if not AConfig.AllowShutdown then
  begin
    AMessage := 'Shutdown is disabled by allow_shutdown=false';
    Exit;
  end;
  lProcess := TProcess.Create(nil);
  lOutput := TStringList.Create;
  try
    {$ifdef windows}
    lProcess.Executable := 'shutdown.exe';
    lProcess.Parameters.Add('/s');
    lProcess.Parameters.Add('/t');
    lProcess.Parameters.Add('5');
    {$else}
    if not FileExists(CLinuxShutdownHelper) then
    begin
      AMessage := 'Privileged shutdown helper is not installed';
      Exit;
    end;
    lProcess.Executable := '/usr/bin/sudo';
    lProcess.Parameters.Add('-n');
    lProcess.Parameters.Add(CLinuxShutdownHelper);
    {$endif}
    lProcess.Options := [poNoConsole, poWaitOnExit, poUsePipes,
      poStderrToOutPut];
    lProcess.Execute;
    lOutput.LoadFromStream(lProcess.Output);
    if lProcess.ExitStatus <> 0 then
    begin
      AMessage := Trim(lOutput.Text);
      if AMessage = '' then
        AMessage := 'Shutdown helper failed with exit code ' +
          IntToStr(lProcess.ExitStatus);
      Exit;
    end;
    AMessage := 'Shutdown requested';
    Result := True;
  finally
    lOutput.Free;
    lProcess.Free;
  end;
end;

end.
