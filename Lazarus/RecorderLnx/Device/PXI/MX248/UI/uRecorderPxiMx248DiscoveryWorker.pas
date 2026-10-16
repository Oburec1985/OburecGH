unit uRecorderPxiMx248DiscoveryWorker;

{
  Назначение: выполняет локальный DevAPI discovery MX-248 вне GUI-потока.

  Ограничения: worker только перечисляет маршруты; он не открывает, не
  сбрасывает и не конфигурирует плату. Ожидающий UI продолжает обрабатывать
  сообщения LCL, поэтому окно не зависает на длительном PCI scan. Результат
  передаётся в GUI-поток исключительно через Synchronize.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Forms, SysUtils,
  uRecorderDriverContractsV2, uRecorderPxiMx248Types,
  uRecorderPxiMx248SettingsService;

function RecorderDiscoverPxiMx248Responsive(
  out ADevices: TPxiMx248DiscoveredDevices;
  const AService: IPxiMx248SettingsService = nil): TRcOperationResult;
procedure RecorderKnownPxiMx248Devices(out ADevices: TPxiMx248DiscoveredDevices);

implementation

uses
  uRecorderPxiMx248WindowsTransport;

var
  g_KnownDevices: TPxiMx248DiscoveredDevices;

procedure RecorderKnownPxiMx248Devices(
  out ADevices: TPxiMx248DiscoveredDevices);
begin
  { Discovery results are published and consumed by GUI code only. The worker
    owns its private array until Synchronize has completed. }
  ADevices := Copy(g_KnownDevices, 0, Length(g_KnownDevices));
end;

type
  TPxiMx248DiscoveryWorker = class(TThread)
  private
    fCompleted: Boolean;
    fDevices: TPxiMx248DiscoveredDevices;
    fErrorText: string;
    fResult: TRcOperationResult;
    fService: IPxiMx248SettingsService;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(const AService: IPxiMx248SettingsService);
    property Completed: Boolean read fCompleted;
    property Devices: TPxiMx248DiscoveredDevices read fDevices;
    property DiscoveryResult: TRcOperationResult read fResult;
  end;

constructor TPxiMx248DiscoveryWorker.Create(
  const AService: IPxiMx248SettingsService);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fService := AService;
end;

procedure TPxiMx248DiscoveryWorker.Execute;
begin
  try
    if fService <> nil then
      fResult := fService.Discover(fDevices)
    else
      fResult := RecorderDiscoverPxiMx248(fDevices);
  except
    on E: Exception do
      fErrorText := E.ClassName + ': ' + E.Message;
  end;
  Synchronize(@Deliver);
end;

procedure TPxiMx248DiscoveryWorker.Deliver;
begin
  if fErrorText <> '' then
    fResult := TRcOperationResult.Failure(rocInternal,
      'mx248.discovery.worker', fErrorText);
  fCompleted := True;
end;

function RecorderDiscoverPxiMx248Responsive(
  out ADevices: TPxiMx248DiscoveredDevices;
  const AService: IPxiMx248SettingsService): TRcOperationResult;
var
  lWorker: TPxiMx248DiscoveryWorker;
begin
  SetLength(ADevices, 0);
  lWorker := TPxiMx248DiscoveryWorker.Create(AService);
  try
    lWorker.Start;
    while not lWorker.Completed do
    begin
      Application.ProcessMessages;
      Sleep(10);
    end;
    ADevices := Copy(lWorker.Devices, 0, Length(lWorker.Devices));
    Result := lWorker.DiscoveryResult;
    if Result.IsSuccess then
      g_KnownDevices := Copy(ADevices, 0, Length(ADevices));
  finally
    lWorker.WaitFor;
    lWorker.Free;
  end;
end;

end.
