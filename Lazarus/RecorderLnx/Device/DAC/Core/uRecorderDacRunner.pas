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
    fResultLock: TRTLCriticalSection;
    fLastResult: TRecorderDacResult;
    fStarted: Boolean;
    fMirrorWake: TEvent;
    fMirrorPublisher: TRecorderDacMirrorPublisher;
    procedure StoreResult(const AResult: TRecorderDacResult);
  protected
    procedure Execute; override;
  public
    constructor Create(ASession: TRecorderDacSession);
    destructor Destroy; override;
    procedure StartRun;
    procedure RequestStop;
    function LastResult: TRecorderDacResult;
  end;

implementation

constructor TRecorderDacRunner.Create(ASession: TRecorderDacSession);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fSession := ASession;
  InitCriticalSection(fResultLock);
  fLastResult := RecorderDacOk;
  fMirrorWake := TEvent.Create(nil, False, False, '');
  fMirrorPublisher := TRecorderDacMirrorPublisher.Create(fSession, fMirrorWake);
  fMirrorPublisher.Start;
end;

destructor TRecorderDacRunner.Destroy;
begin
  if fStarted and not Finished then
  begin
    RequestStop;
    WaitFor;
  end;
  fMirrorPublisher.Terminate;
  fMirrorWake.SetEvent;
  fMirrorPublisher.WaitFor;
  fMirrorPublisher.Free;
  fMirrorWake.Free;
  DoneCriticalSection(fResultLock);
  inherited Destroy;
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
      lFailed := True;
      Break;
    end;
    fMirrorWake.SetEvent;
  end;
  if fSession.State = rdsRunning then fSession.Stop(lResult);
  if not lFailed then StoreResult(lResult) else StoreResult(lFailure);
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
  fSession.Abort;
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
    fWake.WaitFor(1000);
    while fSession.FlushMirror(lResult) do ;
  end;
  while fSession.FlushMirror(lResult) do ;
end;

end.
