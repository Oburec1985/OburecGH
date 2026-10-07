program RecorderCoreServicesTest;

{
  RecorderCoreServicesTest

  Назначение:
    Тест-пример минимальных core-сервисов RecorderLnx: событийной шины,
    реестра action-команд и менеджера статических расширений.
}

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, SyncObjs,
  uRecorderCoreServices,
  uRecorderConfigurationService,
  uRecorderUnitManager;

type
  TEventProbe = class
  public
    Count: Integer;
    LastText: string;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure HandleAction(ASender: TObject; const AContext: TRecorderActionContext);
  end;

  TReentrantProbe = class
  private
    fBus: TRecorderEventBus;
    fChild: TEventProbe;
    fSubscribedChild: Boolean;
  public
    Count: Integer;
    Token: Integer;
    constructor Create(ABus: TRecorderEventBus; AChild: TEventProbe = nil);
    procedure RecursivePublish(ASender: TObject; const AEvent: TRecorderEvent);
    procedure SubscribeFromHandler(ASender: TObject;
      const AEvent: TRecorderEvent);
    procedure SelfUnsubscribe(ASender: TObject;
      const AEvent: TRecorderEvent);
  end;

  TSlowEventProbe = class
  public
    Count: Integer;
    Started: TEvent;
    Release: TEvent;
    constructor Create;
    destructor Destroy; override;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
  end;

  TPublishThread = class(TThread)
  private
    fBus: TRecorderEventBus;
  protected
    procedure Execute; override;
  public
    constructor Create(ABus: TRecorderEventBus);
  end;

  TUnsubscribeThread = class(TThread)
  private
    fBus: TRecorderEventBus;
    fToken: Integer;
  protected
    procedure Execute; override;
  public
    Done: TEvent;
    Removed: Boolean;
    constructor Create(ABus: TRecorderEventBus; AToken: Integer);
    destructor Destroy; override;
  end;

  TDestroyBusThread = class(TThread)
  private
    fBus: TRecorderEventBus;
  protected
    procedure Execute; override;
  public
    Done: TEvent;
    constructor Create(ABus: TRecorderEventBus);
    destructor Destroy; override;
  end;

  TMockExtension = class(TInterfacedObject, IRecorderExtension)
  private
    fLog: string;
  public
    function GetId: string;
    function GetName: string;
    procedure Initialize(AHost: TObject);
    procedure RegisterServices(AEventBus: TRecorderEventBus;
      AActionRegistry: TRecorderActionRegistry);
    procedure Start;
    procedure Stop;
    function CanClose: Boolean;
    procedure Close;
    procedure Notify(const AEvent: TRecorderEvent);
    property Log: string read fLog;
  end;

  TMockConfigurationRuntime = class(TInterfacedObject,
    IRecorderConfigurationRuntime)
  private
    fRunning: Boolean;
    fFailPrepareHardware: Boolean;
    fFailRestart: Boolean;
    fLog: string;
    procedure AddLog(const AStep: string);
  public
    procedure CaptureProgrammingState(AState: TRecorderSourceProgrammingState);
    function SourceProgrammingApplied(const ASourceId,
      ASignature: string): Boolean;
    function AcquisitionRunning: Boolean;
    procedure StopAcquisitionForConfiguration;
    procedure ReplaceRuntimeSource(const ASourceId: string);
    procedure EnsureRuntimeSources;
    procedure PrepareAlgorithms;
    procedure PrepareHardware;
    procedure StartAcquisitionAfterConfiguration;
    procedure SyncEnabledSourceStates;
    property Running: Boolean read fRunning write fRunning;
    property FailPrepareHardware: Boolean read fFailPrepareHardware
      write fFailPrepareHardware;
    property FailRestart: Boolean read fFailRestart write fFailRestart;
    property Log: string read fLog;
  end;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure AssertEquals(const AActual, AExpected, AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %s, got %s',
      [AStep, AExpected, AActual]);
end;

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
end;

procedure TEventProbe.HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
begin
  Inc(Count);
  LastText := AEvent.Text;
end;

procedure TEventProbe.HandleAction(ASender: TObject;
  const AContext: TRecorderActionContext);
begin
  Inc(Count);
  LastText := AContext.Text;
end;

constructor TReentrantProbe.Create(ABus: TRecorderEventBus;
  AChild: TEventProbe);
begin
  inherited Create;
  fBus := ABus;
  fChild := AChild;
end;

procedure TReentrantProbe.RecursivePublish(ASender: TObject;
  const AEvent: TRecorderEvent);
begin
  Inc(Count);
  if Count = 1 then
    fBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
end;

procedure TReentrantProbe.SubscribeFromHandler(ASender: TObject;
  const AEvent: TRecorderEvent);
begin
  Inc(Count);
  if not fSubscribedChild then
  begin
    fBus.Subscribe(@fChild.HandleEvent);
    fSubscribedChild := True;
  end;
end;

procedure TReentrantProbe.SelfUnsubscribe(ASender: TObject;
  const AEvent: TRecorderEvent);
begin
  Inc(Count);
  AssertTrue(fBus.Unsubscribe(Token), 'self-unsubscribe returns true');
end;

constructor TSlowEventProbe.Create;
begin
  inherited Create;
  Started := TEvent.Create(nil, True, False, '');
  Release := TEvent.Create(nil, True, False, '');
end;

destructor TSlowEventProbe.Destroy;
begin
  Release.Free;
  Started.Free;
  inherited Destroy;
end;

procedure TSlowEventProbe.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
begin
  Inc(Count);
  Started.SetEvent;
  Release.WaitFor(INFINITE);
end;

constructor TPublishThread.Create(ABus: TRecorderEventBus);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fBus := ABus;
end;

procedure TPublishThread.Execute;
begin
  fBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
end;

constructor TUnsubscribeThread.Create(ABus: TRecorderEventBus;
  AToken: Integer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fBus := ABus;
  fToken := AToken;
  Done := TEvent.Create(nil, True, False, '');
end;

destructor TUnsubscribeThread.Destroy;
begin
  Done.Free;
  inherited Destroy;
end;

procedure TUnsubscribeThread.Execute;
begin
  Removed := fBus.Unsubscribe(fToken);
  Done.SetEvent;
end;

constructor TDestroyBusThread.Create(ABus: TRecorderEventBus);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fBus := ABus;
  Done := TEvent.Create(nil, True, False, '');
end;

destructor TDestroyBusThread.Destroy;
begin
  Done.Free;
  inherited Destroy;
end;

procedure TDestroyBusThread.Execute;
begin
  fBus.Free;
  Done.SetEvent;
end;

function TMockExtension.GetId: string;
begin
  Result := 'mock.extension';
end;

function TMockExtension.GetName: string;
begin
  Result := 'Mock extension';
end;

procedure TMockExtension.Initialize(AHost: TObject);
begin
  fLog := fLog + 'Initialize;';
end;

procedure TMockExtension.RegisterServices(AEventBus: TRecorderEventBus;
  AActionRegistry: TRecorderActionRegistry);
begin
  fLog := fLog + 'RegisterServices;';
end;

procedure TMockExtension.Start;
begin
  fLog := fLog + 'Start;';
end;

procedure TMockExtension.Stop;
begin
  fLog := fLog + 'Stop;';
end;

function TMockExtension.CanClose: Boolean;
begin
  Result := True;
end;

procedure TMockExtension.Close;
begin
  fLog := fLog + 'Close;';
end;

procedure TMockExtension.Notify(const AEvent: TRecorderEvent);
begin
  if AEvent.Kind = rceDataUpdated then
    fLog := fLog + 'NotifyData;';
end;

procedure TMockConfigurationRuntime.AddLog(const AStep: string);
begin
  fLog := fLog + AStep + ';';
end;

procedure TMockConfigurationRuntime.CaptureProgrammingState(
  AState: TRecorderSourceProgrammingState);
begin
  AState.Add('source-1', 'before');
end;

function TMockConfigurationRuntime.SourceProgrammingApplied(
  const ASourceId, ASignature: string): Boolean;
begin
  Result := False;
end;

function TMockConfigurationRuntime.AcquisitionRunning: Boolean;
begin
  Result := fRunning;
end;

procedure TMockConfigurationRuntime.StopAcquisitionForConfiguration;
begin
  AddLog('stop');
  fRunning := False;
end;

procedure TMockConfigurationRuntime.ReplaceRuntimeSource(
  const ASourceId: string);
begin
  AddLog('replace:' + ASourceId);
end;

procedure TMockConfigurationRuntime.EnsureRuntimeSources;
begin
  AddLog('ensure');
end;

procedure TMockConfigurationRuntime.PrepareAlgorithms;
begin
  AddLog('algorithms');
end;

procedure TMockConfigurationRuntime.PrepareHardware;
begin
  AddLog('hardware');
  if fFailPrepareHardware then
    raise Exception.Create('hardware prepare failed');
end;

procedure TMockConfigurationRuntime.StartAcquisitionAfterConfiguration;
begin
  AddLog('start');
  if fFailRestart then
    raise Exception.Create('restart failed');
  fRunning := True;
end;

procedure TMockConfigurationRuntime.SyncEnabledSourceStates;
begin
  AddLog('sync');
end;

procedure TestEventBus;
var
  lBus: TRecorderEventBus;
  lProbe: TEventProbe;
  lToken: Integer;
begin
  lBus := TRecorderEventBus.Create;
  lProbe := TEventProbe.Create;
  try
    lToken := lBus.Subscribe(@lProbe.HandleEvent);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceDataUpdated, nil, '', 'MemTag'));

    AssertEquals(lProbe.Count, 1, 'event count after publish');
    AssertEquals(lProbe.LastText, 'MemTag', 'event payload text');

    AssertTrue(lBus.Unsubscribe(lToken), 'unsubscribe returns true');
    lBus.Publish(TRecorderEventBus.MakeEvent(rceDataUpdated, nil, '', 'Ignored'));
    AssertEquals(lProbe.Count, 1, 'event count after unsubscribe');

    Writeln('Event bus test passed.');
  finally
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestEventBusReentrancy;
var
  lBus: TRecorderEventBus;
  lChild: TEventProbe;
  lProbe: TReentrantProbe;
begin
  lBus := TRecorderEventBus.Create;
  lChild := TEventProbe.Create;
  lProbe := TReentrantProbe.Create(lBus, lChild);
  try
    lBus.Subscribe(@lProbe.RecursivePublish);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
    AssertEquals(lProbe.Count, 2, 'recursive publish count');
  finally
    lProbe.Free;
    lChild.Free;
    lBus.Free;
  end;

  lBus := TRecorderEventBus.Create;
  lChild := TEventProbe.Create;
  lProbe := TReentrantProbe.Create(lBus, lChild);
  try
    lBus.Subscribe(@lProbe.SubscribeFromHandler);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
    AssertEquals(lChild.Count, 0, 'new subscription skips current publish');
    lBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
    AssertEquals(lChild.Count, 1, 'new subscription receives next publish');
    Writeln('Event bus reentrancy tests passed.');
  finally
    lProbe.Free;
    lChild.Free;
    lBus.Free;
  end;
end;

procedure TestEventBusSelfUnsubscribe;
var
  lBus: TRecorderEventBus;
  lProbe: TReentrantProbe;
begin
  lBus := TRecorderEventBus.Create;
  lProbe := TReentrantProbe.Create(lBus);
  try
    lProbe.Token := lBus.Subscribe(@lProbe.SelfUnsubscribe);
    lBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
    lBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
    AssertEquals(lProbe.Count, 1, 'self-unsubscribe callback count');
    Writeln('Event bus self-unsubscribe test passed.');
  finally
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestConcurrentUnsubscribeWaitsForCallback;
var
  lBus: TRecorderEventBus;
  lProbe: TSlowEventProbe;
  lPublish: TPublishThread;
  lUnsubscribe: TUnsubscribeThread;
  lToken: Integer;
begin
  lBus := TRecorderEventBus.Create;
  lProbe := TSlowEventProbe.Create;
  lPublish := nil;
  lUnsubscribe := nil;
  try
    lToken := lBus.Subscribe(@lProbe.HandleEvent);
    lPublish := TPublishThread.Create(lBus);
    lPublish.Start;
    AssertTrue(lProbe.Started.WaitFor(2000) = wrSignaled,
      'slow callback starts');

    lUnsubscribe := TUnsubscribeThread.Create(lBus, lToken);
    lUnsubscribe.Start;
    AssertTrue(lUnsubscribe.Done.WaitFor(50) = wrTimeout,
      'unsubscribe waits for in-flight callback');
    lProbe.Release.SetEvent;
    AssertTrue(lUnsubscribe.Done.WaitFor(2000) = wrSignaled,
      'unsubscribe completes after callback');
    lPublish.WaitFor;
    lUnsubscribe.WaitFor;
    AssertTrue(lUnsubscribe.Removed, 'concurrent unsubscribe removes token');
    lBus.Publish(TRecorderEventBus.MakeEvent(rceUser));
    AssertEquals(lProbe.Count, 1, 'removed slow callback is not called again');
    Writeln('Event bus concurrent unsubscribe test passed.');
  finally
    lProbe.Release.SetEvent;
    lUnsubscribe.Free;
    lPublish.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestConcurrentDestroyWaitsForPublish;
var
  lBus: TRecorderEventBus;
  lProbe: TSlowEventProbe;
  lPublish: TPublishThread;
  lDestroy: TDestroyBusThread;
begin
  lBus := TRecorderEventBus.Create;
  lProbe := TSlowEventProbe.Create;
  lPublish := nil;
  lDestroy := nil;
  try
    lBus.Subscribe(@lProbe.HandleEvent);
    lPublish := TPublishThread.Create(lBus);
    lPublish.Start;
    AssertTrue(lProbe.Started.WaitFor(2000) = wrSignaled,
      'slow callback starts before destroy');

    lDestroy := TDestroyBusThread.Create(lBus);
    lDestroy.Start;
    AssertTrue(lDestroy.Done.WaitFor(50) = wrTimeout,
      'destroy waits for in-flight publish');
    lProbe.Release.SetEvent;
    AssertTrue(lDestroy.Done.WaitFor(2000) = wrSignaled,
      'destroy completes after publish');
    lPublish.WaitFor;
    lDestroy.WaitFor;
    lBus := nil;
    Writeln('Event bus concurrent destroy test passed.');
  finally
    lProbe.Release.SetEvent;
    lDestroy.Free;
    lPublish.Free;
    lProbe.Free;
    lBus.Free;
  end;
end;

procedure TestActionRegistry;
var
  lRegistry: TRecorderActionRegistry;
  lProbe: TEventProbe;
  lContext: TRecorderActionContext;
begin
  lRegistry := TRecorderActionRegistry.Create;
  lProbe := TEventProbe.Create;
  try
    lRegistry.AddAction('recorder.test.action', 'Test action', 'Executes test',
      nil, @lProbe.HandleAction);

    AssertEquals(lRegistry.ActionCount, 1, 'action count');
    AssertTrue(lRegistry.FindAction('recorder.test.action') <> nil,
      'registered action exists');

    lContext.Sender := nil;
    lContext.Text := 'Run';
    lContext.IntValue := 0;
    lContext.Data := nil;
    lRegistry.ExecuteAction('recorder.test.action', lContext);

    AssertEquals(lProbe.Count, 1, 'action execute count');
    AssertEquals(lProbe.LastText, 'Run', 'action context text');

    Writeln('Action registry test passed.');
  finally
    lProbe.Free;
    lRegistry.Free;
  end;
end;

procedure TestExtensionManager;
var
  lActions: TRecorderActionRegistry;
  lBus: TRecorderEventBus;
  lManager: TRecorderExtensionManager;
  lMock: TMockExtension;
  lExt: IRecorderExtension;
begin
  lBus := TRecorderEventBus.Create;
  lActions := TRecorderActionRegistry.Create;
  lManager := TRecorderExtensionManager.Create(lBus, lActions);
  try
    lMock := TMockExtension.Create;
    lExt := lMock;
    lManager.AddExtension(lExt);
    AssertEquals(lManager.ExtensionCount, 1, 'extension count');

    lManager.InitializeAll(nil);
    lManager.RegisterServicesAll;
    lManager.StartAll;
    lBus.Publish(TRecorderEventBus.MakeEvent(rceDataUpdated, nil, '', 'Tags'));
    lManager.StopAll;
    AssertTrue(lManager.CanCloseAll, 'extensions can close');
    lManager.CloseAll;

    AssertEquals(lMock.Log,
      'Initialize;RegisterServices;Start;NotifyData;Stop;Close;',
      'extension lifecycle log');

    Writeln('Extension manager test passed.');
  finally
    lManager.Free;
    lActions.Free;
    lBus.Free;
  end;
end;

function MakeChanges(const ABeforeSignature, AAfterSignature: string;
  ASourcesChanged: Boolean): TRecorderConfigurationChangeSet;
var
  lBeforeState: TRecorderSourceProgrammingState;
  lAfterState: TRecorderSourceProgrammingState;
begin
  lBeforeState := TRecorderSourceProgrammingState.Create;
  lAfterState := TRecorderSourceProgrammingState.Create;
  lBeforeState.Add('source-1', ABeforeSignature);
  lAfterState.Add('source-1', AAfterSignature);
  Result := TRecorderConfigurationChangeSet.Create(lBeforeState, lAfterState);
  Result.SourcesChanged := ASourcesChanged;
end;

procedure TestAlgorithmOnlyConfiguration;
var
  lMock: TMockConfigurationRuntime;
  lRuntime: IRecorderConfigurationRuntime;
  lService: TRecorderConfigurationService;
  lChanges: TRecorderConfigurationChangeSet;
  lResult: TRecorderConfigurationResult;
begin
  lMock := TMockConfigurationRuntime.Create;
  lRuntime := lMock;
  lMock.Running := True;
  lService := TRecorderConfigurationService.Create(lRuntime);
  lChanges := MakeChanges('same', 'same', False);
  lChanges.PrepareAlgorithmRuntime := True;
  try
    lResult := lService.Apply(lChanges);
    try
      AssertEquals(lMock.Log, 'algorithms;',
        'algorithm-only configuration order');
      AssertTrue(lMock.Running, 'algorithm-only configuration keeps acquisition');
      AssertEquals(lResult.ErrorMessage, '', 'algorithm-only error');
    finally
      lResult.Free;
    end;
  finally
    lChanges.Free;
    lService.Free;
    lRuntime := nil;
  end;
  Writeln('Algorithm-only configuration test passed.');
end;

procedure TestHardwareFailureRestartsAcquisition;
var
  lMock: TMockConfigurationRuntime;
  lRuntime: IRecorderConfigurationRuntime;
  lService: TRecorderConfigurationService;
  lChanges: TRecorderConfigurationChangeSet;
  lResult: TRecorderConfigurationResult;
begin
  lMock := TMockConfigurationRuntime.Create;
  lRuntime := lMock;
  lMock.Running := True;
  lMock.FailPrepareHardware := True;
  lService := TRecorderConfigurationService.Create(lRuntime);
  lChanges := MakeChanges('before', 'after', True);
  lChanges.EnsureRuntimeSources := True;
  lChanges.PrepareAlgorithmRuntime := True;
  try
    lResult := lService.Apply(lChanges);
    try
      AssertEquals(lMock.Log,
        'stop;replace:source-1;algorithms;ensure;hardware;start;',
        'failed hardware configuration order');
      AssertTrue(lMock.Running, 'failed hardware configuration restarts acquisition');
      AssertTrue(Pos('hardware prepare failed', lResult.ErrorMessage) > 0,
        'hardware failure is returned');
      AssertTrue(not lResult.Reconfigured,
        'failed hardware configuration is not marked reconfigured');
    finally
      lResult.Free;
    end;
  finally
    lChanges.Free;
    lService.Free;
    lRuntime := nil;
  end;
  Writeln('Hardware failure recovery test passed.');
end;

procedure TestRestartFailureIsReported;
var
  lMock: TMockConfigurationRuntime;
  lRuntime: IRecorderConfigurationRuntime;
  lService: TRecorderConfigurationService;
  lChanges: TRecorderConfigurationChangeSet;
  lResult: TRecorderConfigurationResult;
begin
  lMock := TMockConfigurationRuntime.Create;
  lRuntime := lMock;
  lMock.Running := True;
  lMock.FailPrepareHardware := True;
  lMock.FailRestart := True;
  lService := TRecorderConfigurationService.Create(lRuntime);
  lChanges := MakeChanges('before', 'after', True);
  try
    lResult := lService.Apply(lChanges);
    try
      AssertTrue(Pos('hardware prepare failed', lResult.ErrorMessage) > 0,
        'prepare error retained when restart fails');
      AssertTrue(Pos('Restart failed', lResult.ErrorMessage) > 0,
        'restart error appended');
      AssertTrue(not lMock.Running, 'failed restart leaves truthful stopped state');
    finally
      lResult.Free;
    end;
  finally
    lChanges.Free;
    lService.Free;
    lRuntime := nil;
  end;
  Writeln('Restart failure reporting test passed.');
end;

procedure TestAccelerationReferenceConversion;
var
  lValue: Double;
begin
  AssertTrue(RecorderUnitManager.TryConvert(1.0, 'g', 'm/s2', lValue),
    'g must be compatible with m/s2');
  AssertTrue(Abs(lValue - 9.80665) < 1E-9,
    '1 g must become 9.80665 m/s2 before calibration');
  AssertTrue(RecorderUnitManager.TryConvert(lValue, 'm/s2', 'g', lValue),
    'm/s2 must be compatible with g');
  AssertTrue(Abs(lValue - 1.0) < 1E-9,
    'acceleration reference conversion must be reversible');
  Writeln('Acceleration reference conversion test passed.');
end;

begin
  TestEventBus;
  TestEventBusReentrancy;
  TestEventBusSelfUnsubscribe;
  TestConcurrentUnsubscribeWaitsForCallback;
  TestConcurrentDestroyWaitsForPublish;
  TestActionRegistry;
  TestExtensionManager;
  TestAlgorithmOnlyConfiguration;
  TestHardwareFailureRestartsAcquisition;
  TestRestartFailureIsReported;
  TestAccelerationReferenceConversion;
end.
