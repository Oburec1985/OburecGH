unit UConnection;
//Модуль описывает класс TCP соединения

interface

uses
SysUtils, Classes, Winsock, UMasterConnectionThread, UCommon;


type TConnection = class(TObject)
private
  fIP: string;
  fPort: integer;

  fConnected: boolean;
  fAddress: AnsiString;
  fConnectionThread: TConnectionThread;
  fRcvBuf: TBytes; //Входной буфер
  fDataRx: TDataEvent;
  fDataTx: TDataEvent;
  fOnConnect: TNotifyEvent;
  fOnDisconnect: TNotifyEvent;

  procedure DoDataRx(data: TBytes);
  procedure DoDataTx(data: TBytes);
  procedure Disconnect;
  procedure DoConnected;
  procedure ThreadConnected;
  procedure DoDisconnected;
  function GetConnected: Boolean;
  function GetRcvBuf: TBytes;
  function GetIP: string;
  function GetPort: integer;
  procedure SetIP(const Value: string);
  procedure SetPort(const Value: integer);
public
  constructor Create;
  destructor Destroy; override;
  procedure Connect;
  //procedure SendData(data: TBytes);
  property Connected: Boolean read GetConnected;
  property IP: string read GetIP write SetIP;
  property Port: integer read GetPort write SetPort;
  property RcvBuf: TBytes read GetRcvBuf;
  property OnConnected: TNotifyEvent read fOnConnect write fOnConnect;
  property OnDisconnected: TNotifyEvent read fOnDisconnect write fOnDisconnect;
end;

implementation

{ TConnection }

procedure TConnection.Connect;
begin
  //Создаем поток соединения
  fConnectionThread := TConnectionThread.Create(fAddress, fPort);
end;

procedure TConnection.ThreadConnected;
begin

end;

constructor TConnection.Create;
var
  lib_data: TWSAData;
begin
  //inherited;

  fPort := 520;
  fIP := '127.0.0.1';

  if WSAStartup($0002, lib_data) <> 0 then
     begin
      raise Exception.Create('Error socket library init');
      Exit;
     end;
end;

function TConnection.GetConnected: Boolean;
begin
  result := fConnected;
end;


function TConnection.GetIP: string;
begin
  result := fIP;
end;

function TConnection.GetPort: integer;
begin
 result := fPort;
end;

function TConnection.GetRcvBuf: TBytes;
begin
  result := fRcvBuf;
end;

{procedure TConnection.SendData(data: TBytes);
begin
  //Создаем поток посылки данных
  //TSendDataThread.Create;

end;}

procedure TConnection.SetIP(const Value: string);
begin
 fIP := Value;
end;

procedure TConnection.SetPort(const Value: integer);
begin
 fPort := Value;
end;

procedure TConnection.Disconnect;
begin
 fConnectionThread.Terminate;
 fConnectionThread.WaitFor;
 FreeAndNil(fConnectionThread);
 fConnected := false;
end;

destructor TConnection.Destroy;
begin
  WSACleanup;
  inherited;
end;

procedure TConnection.DoConnected;
begin
  if Assigned(fOnConnect) then
     fOnConnect(Self);
end;

procedure TConnection.DoDisconnected;
begin
  if Assigned(fOnDisconnect) then
     fOnDisconnect(Self);
end;

procedure TConnection.DoDataRx(data: TBytes);
begin
  if Assigned(fDataRx) then
    fDataRx(self, data);
end;

procedure TConnection.DoDataTx(data: TBytes);
begin
  if Assigned(fDataTx) then
    fDataRx(self, data);
end;

end.
