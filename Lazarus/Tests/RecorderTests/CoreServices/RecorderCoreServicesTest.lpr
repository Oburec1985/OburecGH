program RecorderCoreServicesTest;

{
  RecorderCoreServicesTest

  Назначение:
    Тест-пример минимальных core-сервисов RecorderLnx: событийной шины,
    реестра action-команд и менеджера статических расширений.
}

{$mode objfpc}{$H+}

uses
  SysUtils,
  uRecorderCoreServices;

type
  TEventProbe = class
  public
    Count: Integer;
    LastText: string;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure HandleAction(ASender: TObject; const AContext: TRecorderActionContext);
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

begin
  TestEventBus;
  TestActionRegistry;
  TestExtensionManager;
end.
