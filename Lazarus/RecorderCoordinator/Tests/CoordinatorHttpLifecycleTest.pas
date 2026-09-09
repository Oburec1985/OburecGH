program CoordinatorHttpLifecycleTest;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Sockets,
  uCoordinatorModel, uCoordinatorHttpServer;

const
  CTestPort = 18765;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function PortIsBound(APort: Word): Boolean;
var
  lSocket: LongInt;
  lAddress: TInetSockAddr;
begin
  Result := False;
  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then Exit;
  try
    FillChar(lAddress, SizeOf(lAddress), 0);
    lAddress.sin_family := AF_INET;
    lAddress.sin_port := htons(APort);
    lAddress.sin_addr := StrToNetAddr('127.0.0.1');
    Result := fpBind(lSocket, @lAddress, SizeOf(lAddress)) <> 0;
  finally
    CloseSocket(lSocket);
  end;
end;

procedure WaitUntilBound(AServer: TCoordinatorHttpServer);
var
  lStartedAt: QWord;
begin
  lStartedAt := GetTickCount64;
  while (not PortIsBound(CTestPort)) and
    (GetTickCount64 - lStartedAt < 1000) do
    Sleep(1);
  Check(PortIsBound(CTestPort), 'listener did not bind its TCP port');
  Check(AServer.LastError = '', 'listener failed: ' + AServer.LastError);
end;

procedure CheckOneCycle(AServer: TCoordinatorHttpServer);
var
  lStartedAt: QWord;
begin
  WriteLn('start');
  AServer.Start('127.0.0.1', CTestPort);
  WriteLn('started');
  Check(AServer.LastError = '', 'start failed: ' + AServer.LastError);
  Check(AServer.Active, 'server is not active after Start');
  WaitUntilBound(AServer);
  lStartedAt := GetTickCount64;
  AServer.Stop;
  Check(GetTickCount64 - lStartedAt < 20, 'Stop blocked its caller');
  Check(not AServer.Active, 'server is still active after Stop');
  while AServer.Stopping and (GetTickCount64 - lStartedAt < 1000) do
    Sleep(1);
  Check(not AServer.Stopping, 'listener did not stop without a client');
  WriteLn('stopped in ', GetTickCount64 - lStartedAt, ' ms');
end;

var
  lCycle: Integer;
  lModel: TCoordinatorModel;
  lServer: TCoordinatorHttpServer;
begin
  lModel := TCoordinatorModel.Create;
  lServer := TCoordinatorHttpServer.Create(lModel);
  try
    for lCycle := 1 to 100 do
      CheckOneCycle(lServer);
    WriteLn('OK: 100 bound start -> asynchronous stop cycles without clients');
  finally
    lServer.Free;
    lModel.Free;
  end;
end.
