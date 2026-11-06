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
  Classes, Process, IniFiles
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

function ConfiguredLocalFirebirdPath(AConfig: TRecorderHostAgentConfig): string;
var
  lFile, lPath, lRoot, lPathsFile, lDbRoot, lDefaultRoot, lBackend: string;
  lIni: TIniFile;
begin
  Result := '';
  lRoot := AConfig.BackupMeraRoot;
  lPathsFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'RecorderLnx.paths.ini';
  if FileExists(lPathsFile) then
  begin
    lIni := TIniFile.Create(lPathsFile);
    try
      lPath := Trim(lIni.ReadString('Paths', 'MeraFiles', ''));
      if (lPath <> '') and ((lPath[1] = DirectorySeparator) or
         ((Length(lPath) >= 3) and (lPath[2] = ':'))) then lRoot := lPath;
    finally
      lIni.Free;
    end;
  end;
  lFile := IncludeTrailingPathDelimiter(lRoot) +
    'RecorderLnx' + DirectorySeparator + 'app.ini';
  if not FileExists(lFile) then Exit;
  lIni := TIniFile.Create(lFile);
  try
    { Match the SQL configuration's legacy keys and current app.ini keys.
      The explicit local path takes precedence over the legacy Database. }
    lBackend := lIni.ReadString('SQLdb', 'Backend', 'firebird');
    lDefaultRoot := Trim(GetEnvironmentVariable('RECORDERLNX_SQLDB_ROOT'));
    if lDefaultRoot = '' then
      lDefaultRoot := IncludeTrailingPathDelimiter(lRoot) + 'SQLdb';
    lDbRoot := lIni.ReadString('SQLdb', 'RootDirectory', lDefaultRoot);
    lPath := lIni.ReadString('SQLdb', 'Database',
      '/var/opt/mera/SQLdb/recorderlnx.fdb');
    lBackend := lIni.ReadString('SQLdbConnection', 'Backend', lBackend);
    if not SameText(Trim(lBackend), 'firebird') then Exit;
    lDbRoot := Trim(lIni.ReadString('SQLdbConnection', 'RootDirectory', lDbRoot));
    lPath := lIni.ReadString('SQLdbConnection', 'Database', lPath);
    lPath := Trim(lIni.ReadString('SQLdbConnection', 'LocalDatabase', lPath));
    if lPath = '' then lPath := 'recorderlnx.fdb';
    {$ifdef unix}
    if lPath[1] = '/' then Exit(ExpandFileName(lPath));
    if ((Length(lPath) >= 2) and (lPath[2] = ':')) or
      (Pos('\\', lPath) > 0) then
      lPath := ExtractFileName(StringReplace(lPath, '\\', '/', [rfReplaceAll]));
    if (lDbRoot = '') or ((Length(lDbRoot) >= 2) and (lDbRoot[2] = ':')) or
      (Pos('\\', lDbRoot) > 0) then lDbRoot := lDefaultRoot;
    {$else}
    if lPath[1] = '/' then lPath := ExtractFileName(lPath);
    if (lDbRoot = '') or (lDbRoot[1] = '/') then lDbRoot := lDefaultRoot;
    {$endif}
    if ExtractFileDrive(lPath) <> '' then Exit(ExpandFileName(lPath));
    Result := IncludeTrailingPathDelimiter(ExcludeTrailingPathDelimiter(
      ExpandFileName(lDbRoot))) + lPath;
  finally
    lIni.Free;
  end;
end;

function HostAgentStatusJson(AConfig: TRecorderHostAgentConfig): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('result_code', 'noError');
  Result.Add('service', 'RecorderHostAgent');
  Result.Add('version', '0.1.2');
  Result.Add('status', 'ready');
  Result.Add('recorder_available', FileExists(AConfig.RecorderPath));
  Result.Add('shutdown_enabled', AConfig.AllowShutdown);
  Result.Add('sql_local_database', ConfiguredLocalFirebirdPath(AConfig));
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

{$ifndef windows}
function RecorderIsRunning: Boolean;
var
  lSearch: TSearchRec;
  lPid, lStateOffset: Integer;
  lStat: TextFile;
  lLine: string;
begin
  Result := False;
  if FindFirst('/proc/*', faDirectory, lSearch) <> 0 then Exit;
  try
    repeat
      if not TryStrToInt(lSearch.Name, lPid) then Continue;
      AssignFile(lStat, '/proc/' + lSearch.Name + '/stat');
      try
        Reset(lStat);
        try
          ReadLn(lStat, lLine);
        finally
          CloseFile(lStat);
        end;
      except
        on EInOutError do Continue; // Process exited during enumeration.
      end;
      lStateOffset := LastDelimiter(')', lLine) + 2;
      if (lStateOffset <= Length(lLine)) and
         (Copy(lLine, 1, lStateOffset - 1) = lSearch.Name + ' (RecorderLnx) ') and
         not (lLine[lStateOffset] in ['Z', 'X', 'x']) then Exit(True);
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

function StopRecorderBeforeShutdown(out AMessage: string): Boolean;
const
  CGracefulExitTimeoutMs = 15000;
  CExitPollIntervalMs = 100;
  CRecorderExitRequestFile = '/tmp/mera-recorderlnx-exit.request';
var
  lRequestFile: TFileStream;
  lWaitedMs: Integer;
begin
  Result := True;
  AMessage := '';
  if not RecorderIsRunning then
    Exit;

  try
    lRequestFile := TFileStream.Create(CRecorderExitRequestFile, fmCreate);
    lRequestFile.Free;
  except
    on E: Exception do
    begin
      AMessage := 'Cannot request graceful RecorderLnx exit: ' + E.Message;
      Exit(False);
    end;
  end;

  lWaitedMs := 0;
  while RecorderIsRunning and (lWaitedMs < CGracefulExitTimeoutMs) do
  begin
    Sleep(CExitPollIntervalMs);
    Inc(lWaitedMs, CExitPollIntervalMs);
  end;
  if RecorderIsRunning then
  begin
    AMessage := 'RecorderLnx did not exit in 15 seconds; shutdown cancelled';
    Exit(False);
  end;
end;
{$endif}

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
  {$ifndef windows}
  if not StopRecorderBeforeShutdown(AMessage) then
    Exit;
  {$endif}
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
