unit uRecorderApplicationController;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorder, uRecorderStateMachine, uRecorderCoreServices;

type
  { Neutral boundary implemented by the application composition root. }
  IRecorderApplicationLifecycle = interface
    procedure OpenRecordSession;
    procedure CloseRecordSession;
    procedure ResetDisplaySessions;
    procedure StartAcquisition;
    procedure StopAcquisition;
    procedure RunStateChanged(AOldState, ANewState: TRecorderState);
    procedure LifecycleMessage(const AMessage: string);
  end;

  { Owns application orchestration, but no UI, device or file-format details. }
  TRecorderApplicationController = class
  private
    fRecorder: TRecorder;
    fLifecycle: IRecorderApplicationLifecycle;
    procedure StateChanging(ASender: TObject; AOldState, ANewState: TRecorderState;
      ATransition: TRecorderStateTransition);
    procedure StateChanged(ASender: TObject; AOldState, ANewState: TRecorderState);
    procedure PublishTransition(AEventKind: TRecorderEventKind;
      ATransition: TRecorderStateTransition);
    procedure EnterActiveState(ATransition: TRecorderStateTransition);
    procedure EnterStoppedState(ATransition: TRecorderStateTransition);
  public
    constructor Create(ARecorder: TRecorder;
      const ALifecycle: IRecorderApplicationLifecycle);
    destructor Destroy; override;
    procedure StartPreview;
    procedure StartRecord;
    procedure Stop;
  end;

implementation

constructor TRecorderApplicationController.Create(ARecorder: TRecorder;
  const ALifecycle: IRecorderApplicationLifecycle);
begin
  inherited Create;
  if ARecorder = nil then
    raise EArgumentNilException.Create('Recorder is required');
  if ALifecycle = nil then
    raise EArgumentNilException.Create('Application lifecycle is required');
  fRecorder := ARecorder;
  fLifecycle := ALifecycle;
  fRecorder.StateMachine.OnStateChanging := @StateChanging;
  fRecorder.StateMachine.OnStateChanged := @StateChanged;
end;

destructor TRecorderApplicationController.Destroy;
begin
  if (fRecorder <> nil) and (fRecorder.StateMachine <> nil) then
  begin
    fRecorder.StateMachine.OnStateChanging := nil;
    fRecorder.StateMachine.OnStateChanged := nil;
  end;
  fLifecycle := nil;
  fRecorder := nil;
  inherited Destroy;
end;

procedure TRecorderApplicationController.StartPreview;
begin
  if fRecorder.StateMachine.State <> rsPreview then
    fRecorder.StateMachine.StartPreview(rscManual);
end;

procedure TRecorderApplicationController.StartRecord;
begin
  fRecorder.RunSettings.RequireValid;
  fRecorder.StateMachine.StartRecord(fRecorder.RunSettings.StartCondition);
end;

procedure TRecorderApplicationController.Stop;
begin
  fRecorder.StateMachine.Stop;
end;

procedure TRecorderApplicationController.StateChanging(ASender: TObject;
  AOldState, ANewState: TRecorderState; ATransition: TRecorderStateTransition);
begin
  if ATransition = rstNone then
    Exit;
  if fRecorder.AlgorithmManager <> nil then
    fRecorder.AlgorithmManager.ValidateStateTransition(ATransition);
  PublishTransition(rceRunTransitionBefore, ATransition);
end;

procedure TRecorderApplicationController.StateChanged(ASender: TObject;
  AOldState, ANewState: TRecorderState);
var
  lTransition: TRecorderStateTransition;
begin
  lTransition := TRecorderStateMachine(ASender).LastTransition;
  if (ANewState = rsRecord) and (AOldState <> rsRecord) then
    fLifecycle.OpenRecordSession;
  case ANewState of
    rsPreview, rsRecord: EnterActiveState(lTransition);
    rsStop: EnterStoppedState(lTransition);
  end;
  if (AOldState = rsRecord) and (ANewState <> rsRecord) and
    (ANewState <> rsStop) then
    fLifecycle.CloseRecordSession;
  fLifecycle.RunStateChanged(AOldState, ANewState);
  if lTransition <> rstNone then
    PublishTransition(rceRunTransitionAfter, lTransition);
  fLifecycle.LifecycleMessage(Format('State changed: %s -> %s',
    [TRecorderStateMachine.StateToString(AOldState),
     TRecorderStateMachine.StateToString(ANewState)]));
end;

procedure TRecorderApplicationController.EnterActiveState(
  ATransition: TRecorderStateTransition);
begin
  if not (ATransition in [rstStopToView, rstStopToRecord]) then Exit;
  if fRecorder.AlgorithmManager <> nil then
    fRecorder.AlgorithmManager.HandleStateTransition(ATransition);
  fLifecycle.ResetDisplaySessions;
  fRecorder.TimeSystem.Start;
  fLifecycle.StartAcquisition;
end;

procedure TRecorderApplicationController.EnterStoppedState(
  ATransition: TRecorderStateTransition);
begin
  if not (ATransition in [rstViewToStop, rstRecordToStop]) then Exit;
  fLifecycle.StopAcquisition;
  fLifecycle.CloseRecordSession;
  fRecorder.TimeSystem.Stop;
  if fRecorder.AlgorithmManager <> nil then
    fRecorder.AlgorithmManager.HandleStateTransition(ATransition);
end;

procedure TRecorderApplicationController.PublishTransition(
  AEventKind: TRecorderEventKind; ATransition: TRecorderStateTransition);
begin
  if fRecorder.EventBus = nil then Exit;
  fRecorder.EventBus.Publish(TRecorderEventBus.MakeEvent(AEventKind, Self,
    TRecorderStateMachine.TransitionToString(ATransition), '', 0, nil,
    ATransition));
end;

end.
