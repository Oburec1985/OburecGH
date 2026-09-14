unit uCoordinatorSdbSync;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

type
  TCoordinatorSdbSyncResultEvent = procedure(Sender: TObject;
    const AReport, AError: string) of object;

procedure StartCoordinatorSdbSync(const ASourceAddress, AShareName: string;
  ATargetAddresses: TStrings; AOnComplete: TCoordinatorSdbSyncResultEvent);

implementation

uses
  Process, FileUtil;

type
  TCoordinatorSdbSyncTask = class(TThread)
  private
    fSourceAddress: string;
    fShareName: string;
    fTargets: TStringList;
    fReport: string;
    fError: string;
    fOnComplete: TCoordinatorSdbSyncResultEvent;
    function RunTool(const AExecutable: string; const AParameters: array of string;
      const AWorkingDirectory: string; out AOutput: string): Integer;
    procedure ExecuteWindows;
    procedure ExecuteUnix;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(const ASourceAddress, AShareName: string;
      ATargetAddresses: TStrings; AOnComplete: TCoordinatorSdbSyncResultEvent);
    destructor Destroy; override;
  end;

function NewTemporaryDirectory: string;
var
  lGuid: TGuid;
begin
  CreateGUID(lGuid);
  Result := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'rcpanel-sdb-' +
    StringReplace(StringReplace(GUIDToString(lGuid), '{', '', []), '}', '', []);
end;

constructor TCoordinatorSdbSyncTask.Create(const ASourceAddress,
  AShareName: string; ATargetAddresses: TStrings;
  AOnComplete: TCoordinatorSdbSyncResultEvent);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  fSourceAddress := Trim(ASourceAddress);
  fShareName := Trim(AShareName);
  fTargets := TStringList.Create;
  fTargets.Assign(ATargetAddresses);
  fOnComplete := AOnComplete;
end;

destructor TCoordinatorSdbSyncTask.Destroy;
begin
  fTargets.Free;
  inherited Destroy;
end;

function TCoordinatorSdbSyncTask.RunTool(const AExecutable: string;
  const AParameters: array of string; const AWorkingDirectory: string;
  out AOutput: string): Integer;
var
  lProcess: TProcess;
  lStream: TStringStream;
  lIndex: Integer;
begin
  lProcess := TProcess.Create(nil);
  lStream := TStringStream.Create('');
  try
    lProcess.Executable := AExecutable;
    for lIndex := Low(AParameters) to High(AParameters) do
      lProcess.Parameters.Add(AParameters[lIndex]);
    lProcess.CurrentDirectory := AWorkingDirectory;
    lProcess.Options := [poUsePipes, poStderrToOutPut, poWaitOnExit,
      poNoConsole];
    lProcess.Execute;
    lStream.CopyFrom(lProcess.Output, 0);
    AOutput := Trim(lStream.DataString);
    Result := lProcess.ExitStatus;
  finally
    lStream.Free;
    lProcess.Free;
  end;
end;

procedure TCoordinatorSdbSyncTask.ExecuteWindows;
var
  lIndex, lCode: Integer;
  lOutput, lSource, lTarget: string;
begin
  lSource := '\\' + fSourceAddress + '\' + fShareName + '\SDB';
  for lIndex := 0 to fTargets.Count - 1 do
  begin
    if Terminated then Exit;
    lTarget := '\\' + fTargets[lIndex] + '\' + fShareName + '\SDB';
    lCode := RunTool('robocopy.exe', [lSource, lTarget, '/E', '/COPY:DAT',
      '/DCOPY:DAT', '/R:1', '/W:1', '/FFT'], '', lOutput);
    if lCode > 7 then
      fReport := fReport + LineEnding + fTargets[lIndex] + ': ОШИБКА ' +
        Format('robocopy=%d %s', [lCode, lOutput])
    else
      fReport := fReport + LineEnding + fTargets[lIndex] + ': OK';
  end;
end;

procedure TCoordinatorSdbSyncTask.ExecuteUnix;
var
  lIndex, lCode: Integer;
  lOutput, lTempDirectory: string;
begin
  lTempDirectory := NewTemporaryDirectory;
  if not ForceDirectories(lTempDirectory) then
    raise Exception.Create('Не удалось создать временный каталог: ' +
      lTempDirectory);
  try
    lCode := RunTool('smbclient', ['//' + fSourceAddress + '/' + fShareName,
      '-N', '-c', 'prompt OFF; recurse ON; cd SDB; mget *'],
      lTempDirectory, lOutput);
    if lCode <> 0 then
      raise Exception.CreateFmt('Основной хост %s: smbclient=%d %s',
        [fSourceAddress, lCode, lOutput]);
    for lIndex := 0 to fTargets.Count - 1 do
    begin
      if Terminated then Exit;
      lCode := RunTool('smbclient', ['//' + fTargets[lIndex] + '/' + fShareName,
        '-N', '-c', 'mkdir SDB; cd SDB; prompt OFF; recurse ON; mput *'],
        lTempDirectory, lOutput);
      if lCode <> 0 then
        fReport := fReport + LineEnding + fTargets[lIndex] + ': ОШИБКА ' +
          Format('smbclient=%d %s', [lCode, lOutput])
      else
        fReport := fReport + LineEnding + fTargets[lIndex] + ': OK';
    end;
  finally
    DeleteDirectory(lTempDirectory, False);
  end;
end;

procedure TCoordinatorSdbSyncTask.Execute;
begin
  try
    if (fSourceAddress = '') or (fTargets.Count = 0) then
      raise Exception.Create('Не задан основной хост или список получателей');
    {$IFDEF MSWINDOWS}
    ExecuteWindows;
    {$ELSE}
    ExecuteUnix;
    {$ENDIF}
    fReport := 'SDB синхронизирована с основного хоста ' + fSourceAddress +
      ':' + fReport;
  except
    on E: Exception do fError := E.Message;
  end;
  Synchronize(@Deliver);
end;

procedure TCoordinatorSdbSyncTask.Deliver;
begin
  if Assigned(fOnComplete) then fOnComplete(Self, fReport, fError);
end;

procedure StartCoordinatorSdbSync(const ASourceAddress, AShareName: string;
  ATargetAddresses: TStrings; AOnComplete: TCoordinatorSdbSyncResultEvent);
var
  lTask: TCoordinatorSdbSyncTask;
begin
  lTask := TCoordinatorSdbSyncTask.Create(ASourceAddress, AShareName,
    ATargetAddresses, AOnComplete);
  lTask.Start;
end;

end.
