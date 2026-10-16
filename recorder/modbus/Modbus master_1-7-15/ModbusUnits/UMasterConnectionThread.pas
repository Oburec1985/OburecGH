unit UMasterConnectionThread;

interface

uses
  SyncObjs, UCommon, USendThread, SysUtils, Classes, blcksock;

type
  TConnectionThread = class(TThread)
  private
    fAddress: AnsiString;
    fPort: Word;
    fConnected: Boolean;
    fSocket: TTCPBlockSocket;
    fCS: TCriticalSection;
    fOnConnected: TConnectEvent;
    fConnectionFail: TNotifyEvent;

    function GetAddress: string;
    function GetPort: Word;
    procedure SetAddress(const Value: string);
    procedure SetPort(const Value: Word);
    procedure ConnectToServer;
    procedure DoConnectEvent(Socket: TTCPBlockSocket);
    procedure DoConnectionFail;
    procedure ProcessConnected;
    { Private declarations }
  protected
      procedure Execute; override;
  public
    constructor Create(address: AnsiString; port: word);
    destructor Destroy; override;


    property Host: string read GetAddress write SetAddress;
    property Port: Word read GetPort write SetPort;
    property OnConnected: TConnectEvent read fOnConnected write fOnConnected;
    property OnFailConnect: TNotifyEvent read fConnectionFail write fConnectionFail;
  end;

implementation

{ TConnectionThread }

constructor TConnectionThread.Create(address: AnsiString; port: word);
var
  Arg: integer;
begin
  inherited Create(true);
  fPort := port;
  fAddress := address;

  fCS := TCriticalSection.Create;
  fSocket := TTCPBlockSocket.Create;
end;

destructor TConnectionThread.Destroy;
begin
  FreeAndNil(fCS);
  //FreeAndNil(fSocket);
  inherited;
end;

procedure TConnectionThread.DoConnectEvent(Socket: TTCPBlockSocket);
begin
  if Assigned(fOnConnected) then
     fOnConnected(Self, Socket);
end;


procedure TConnectionThread.DoConnectionFail;
begin
  if Assigned(fConnectionFail) then
     fConnectionFail(Self);
end;

procedure TConnectionThread.ProcessConnected;
begin
  DoConnectEvent(fSocket);
end;

procedure TConnectionThread.ConnectToServer;
begin
  fSocket.Connect(fAddress, inttostr(fPort));
  if fSocket.LastError=0 then //ошибок нет - соединились успешно
     begin
       fConnected := true;
       DoConnectEvent(fSocket);
     end
        else
     begin
       fConnected := false;
       FreeAndNil(fSocket);
       DoConnectionFail;//возвращаем ошибку
     end;
end;

procedure TConnectionThread.Execute;
begin
 if not fConnected then
    begin
      ConnectToServer;
    end;
end;

function TConnectionThread.GetAddress: string;
begin
  fCS.Enter;
  result := fAddress;
  fCS.Leave;
end;

function TConnectionThread.GetPort: Word;
begin
  fCS.Enter;
  result := fPort;
  fCS.Leave;
end;

procedure TConnectionThread.SetAddress(const Value: string);
begin
  fCS.Enter;
  fAddress := Value;
  fCS.Leave;
end;

procedure TConnectionThread.SetPort(const Value: Word);
begin
  fCS.Enter;
  fPort := Value;
  fCS.Leave;
end;

end.
