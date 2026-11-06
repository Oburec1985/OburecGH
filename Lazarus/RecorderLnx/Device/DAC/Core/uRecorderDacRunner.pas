unit uRecorderDacRunner;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SyncObjs, uRecorderDacTypes, uRecorderDacSession;

type
  TRecorderDacMirrorPublisher = class(TThread)
  private
    fSession: TRecorderDacSession;
    fWake: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(ASession: TRecorderDacSession; AWake: TEvent);
  end;

  { Owns the blocking DAC pump. StartRun/RequestStop are called outside UI work. }
  TRecorderDacRunner = class(TThread)
  private
    fSession: TRecorderDacSession;
    fConfig: TRecorderDacConfig;
    fResultLock: TRTLCriticalSection;
    fLastResult: TRecorderDacResult;
    fStarted: Boolean;
    fMirrorWake: TEvent;
    fMirrorPublisher: TRecorderDacMirrorPublisher;
    procedure StoreResult(const AResult: TRecorderDacResult);
    procedure FinishPublisher;
  protected
    procedure Execute; override;
  public
    constructor Create(ASession: TRecorderDacSession;
      const AConfig: TRecorderDacConfig);
    destructor Destroy; override;
    procedure StartRun;
    procedure RequestStop;
    function LastResult: TRecorderDacResult;
  end;

implementation

uses SysUtils, uRecorderDebugLog;

constructor TRecorderDacRunner.Create(ASession: TRecorderDacSession;
  const AConfig: TRecorderDacConfig);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fSession := ASession;
  fConfig := AConfig;
  InitCriticalSection(fResultLock);
  fLastResult := RecorderDacOk;
  fMirrorWake := TEvent.Create(nil, False, False, '');
  fMirrorPublisher := nil;
end;

destructor TRecorderDacRunner.Destroy;
begin
  if fStarted and not Finished then
  begin
    RequestStop;
    WaitFor;
  end;
  FinishPublisher;
  fMirrorWake.Free;
  DoneCriticalSection(fResultLock);
  inherited Destroy;
end;

procedure TRecorderDacRunner.FinishPublisher;
begin
  if fMirrorPublisher = nil then Exit;
  fMirrorPublisher.Terminate;
  fMirrorWake.SetEvent;
  fMirrorPublisher.WaitFor;
  FreeAndNil(fMirrorPublisher);
end;

procedure TRecorderDacRunner.StoreResult(const AResult: TRecorderDacResult);
begin
  EnterCriticalSection(fResultLock);
  try
    fLastResult := AResult;
  finally
    LeaveCriticalSection(fResultLock);
  end;
end;

procedure TRecorderDacRunner.Execute;
var
  lFailure: TRecorderDacResult;
  lFailed: Boolean;
  lResult: TRecorderDacResult;
begin
  if not fSession.Configure(fConfig, lResult) then
  begin
    StoreResult(lResult);
    Exit;
  end;
  if Terminated then
    Exit;
  fMirrorPublisher := TRecorderDacMirrorPublisher.Create(fSession, fMirrorWake);
  fMirrorPublisher.Start;
  try
  if not fSession.Start(lResult) then
  begin
    StoreResult(lResult);
    Exit;
  end;
  lFailed := False;
  while not Terminated do
  begin
    if not fSession.Pump(lResult) then
    begin
      StoreResult(lResult);
      lFailure := lResult;
      lFailed := lResult.Error <> rdeCompleted;
      Break;
    end;
    fMirrorWake.SetEvent;
  end;
  if fSession.State = rdsRunning then fSession.Stop(lResult);
  { A finite marker may be delivered by the ADC after output has completed.
    Keep the publisher alive until lock/timeout, even on a hidden component. }
  fMirrorWake.SetEvent;
  while not Terminated and fSession.MirrorPending do
    fMirrorWake.WaitFor(50);
  if Terminated and fSession.MirrorPending then fSession.CancelMirror;
  finally
    FinishPublisher;
  end;
  { The final drain can fail too. Decide the result only after the publisher
    has joined, preserving the original driver failure when one exists. }
  if not lFailed and (fSession.MirrorResult.Error <> rdeNone) then
  begin
    lFailure := fSession.MirrorResult;
    lFailed := True;
  end;
  if not lFailed then StoreResult(lResult) else StoreResult(lFailure);
  RecorderDebugLog(Format('[DAC run] submitted=%d mirrored=%d underruns=%d dropped_mirror=%d result=%s',
    [fSession.Counters.SubmittedFrames, fSession.Counters.MirroredFrames,
    fSession.Counters.Underruns, fSession.Counters.DroppedMirrorBlocks,
    LastResult.Text]));
end;

procedure TRecorderDacRunner.StartRun;
begin
  if fStarted then Exit;
  fStarted := True;
  Start;
end;

procedure TRecorderDacRunner.RequestStop;
begin
  Terminate;
  { Only the worker may call the native stream API. Aborting here races with
    its blocking WriteStream, and rapid parameter edits can then close/unload
    the driver while its stop path is still executing. The worker observes
    Terminated after the current block and performs Stop itself. }
  fMirrorWake.SetEvent;
end;

function TRecorderDacRunner.LastResult: TRecorderDacResult;
begin
  EnterCriticalSection(fResultLock);
  try
    Result := fLastResult;
  finally
    LeaveCriticalSection(fResultLock);
  end;
end;

constructor TRecorderDacMirrorPublisher.Create(ASession: TRecorderDacSession;
  AWake: TEvent);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fSession := ASession;
  fWake := AWake;
end;

procedure TRecorderDacMirrorPublisher.Execute;
var
  lResult: TRecorderDacResult;
begin
  while not Terminated do
  begin
    fWake.WaitFor(50);
    while fSession.FlushMirror(lResult) do ;
    fSession.MaintainMirror;
  end;
  while fSession.FlushMirror(lResult) do ;
end;

end.
