unit UTCPClient;

interface
uses Classes, SyncObjs, SysUtils, UCommon, UMasterConnectionThread, USendThread, UReadThread, blcksock;

Const
BUFFER_MAX_LENG = 2047;

type

{ TTCPClient }


TTCPClient = class(TObject)
private
    fHost: String;
    fPort: Integer;
    fConnected: boolean;
    fRx: TNotifyEvent;
    fTx: TDataEvent;
    fSocket: TTCPBlockSocket;
    fReadThread: TTCPReadThread;
    fWriteThread: TSendThread;
    fConnectThread: TConnectionThread;
    //fRcvBuf: TBytes;
    fRcvBuf: array [0..BUFFER_MAX_LENG] of byte;
    fRcvBufLength: Cardinal;
    fEvConnected: TNotifyEvent;
    fDisconnected: TNotifyEvent;
    fConnectionFailed: TNotifyEvent;
    fCS: TCriticalSection;

    procedure DoRx;
    procedure DoTx(Data: TBytes);
    function GetConnected: boolean;
    function GetHost: string;
    function GetPort: integer;
    function GetRcvBufLeng: Cardinal;
    function getSocket: TTCPBlockSocket;
    procedure SetConnected(const Value: boolean);
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: integer);
    procedure SendThreadTx(Sender: TObject; Data: TBytes);
    procedure DoDataTx(Data: TBytes);
    procedure ReadThreadRx(Sender: TObject; data: TBytes);
    procedure ConnectThreadConnected(Sender: TObject; Sock: TTCPBlockSocket);
    function GetRcvBuf: TBytes;
    procedure SetRcvBuf(const Value: TBytes);
    procedure DoConnected;
    procedure DoDisconnected;
    procedure DoConnectionFailed;
    procedure ConnectThreadFailed(Sender: TObject);
    procedure SendThreadFail(Sender: TObject);
public
    procedure Connect;
    procedure Disconnect;
    procedure SendData(data: TBytes); overload;
    procedure SendData(data: TBytes; length: integer); overload;
    constructor Create;
    destructor Destroy; override;

    property OnRx: TNotifyEvent read fRx write fRx;
    property OnTx: TDataEvent read fTx write fTx;
    property RcvBuf: TBytes read GetRcvBuf write SetRcvBuf;
    property RcvBufLeng: Cardinal read GetRcvBufLeng; //Актуальная длина входного буфера
    property Connected: boolean read GetConnected write SetConnected;
    property Port: integer read GetPort write SetPort;
    property Host: string read GetHost write SetHost;
    property Socket: TTCPBlockSocket read getSocket;
    property OnConnected: TNotifyEvent read fEvConnected write fEvConnected;
    property OnDisconnected: TNotifyEvent read fDisconnected write fDisconnected;
    property OnConnectionFail: TNotifyEvent read fConnectionFailed write fConnectionFailed;
end;


implementation

{ TTCPClient }

procedure TTCPClient.Connect;
begin
  fConnectThread := TConnectionThread.Create(fHost, fPort);
  fConnectThread.FreeOnTerminate := true;
  //fConnectThread.FreeOnTerminate := false;
  fConnectThread.OnConnected := @ConnectThreadConnected;
  fConnectThread.OnFailConnect := @ConnectThreadFailed;
  fConnectThread.Start;
end;

procedure TTCPClient.ReadThreadRx(Sender: TObject; data: TBytes);
begin
   RcvBuf := data;
   DoRx;
end;

procedure TTCPClient.ConnectThreadConnected(Sender: TObject; Sock :TTCPBlockSocket);
begin
  fConnected := true;

  fCS.Enter;
  fSocket := Sock;
  fCS.Leave;

  //fReadThread := TTCPReadThread.Create(fSocket);
  fReadThread := TTCPReadThread.Create(self);
  fReadThread.FreeOnTerminate := false;
  fReadThread.OnRx := @ReadThreadRx;
  fReadThread.Start;
  DoConnected;
end;

procedure TTCPClient.ConnectThreadFailed(Sender: TObject);
begin
  Connected := false;
  DoConnectionFailed;
end;

procedure TTCPClient.SendData(data: TBytes);
var
  st: TSendThread;
begin
if not fConnected then Exit;

  //st := TSendThread.Create(fSocket, data);
  st := TSendThread.Create(self, data);
  st.FreeOnTerminate := true;
  st.OnTx := @SendThreadTx;
  st.OnFail := @SendThreadFail;
  st.Start;
end;

procedure TTCPClient.SendData(data: TBytes; length: integer);
var
  st: TSendThread;
begin
if not fConnected then Exit;

  //st := TSendThread.Create(fSocket, data);
  st := TSendThread.Create(self, data, length);
  st.FreeOnTerminate := true;
  st.OnTx := @SendThreadTx;
  st.OnFail := @SendThreadFail;
  st.Start;
end;

procedure TTCPClient.SendThreadFail(Sender: TObject);
begin
  Disconnect;
end;

procedure TTCPClient.DoConnected;
begin
  if Assigned(fEvConnected) then
     fEvConnected(Self);
end;

procedure TTCPClient.DoConnectionFailed;
begin
  if Assigned(fConnectionFailed) then
     fConnectionFailed(self);
end;

procedure TTCPClient.DoDataTx(Data: TBytes);
begin
  if Assigned(fTx) then
     fTx(Self, Data);
end;


procedure TTCPClient.DoDisconnected;
begin
   if Assigned(fDisconnected) then
     fDisconnected(Self);
end;

procedure TTCPClient.SendThreadTx(Sender: TObject; Data: TBytes);
begin
  DoDataTx(Data);
end;

constructor TTCPClient.Create;
begin
  inherited;
  fCS := TCriticalSection.Create;
  //fSocket := TTCPBlockSocket.Create;
  fPort := 502;
  fHost := '127.0.0.1';
end;

destructor TTCPClient.Destroy;
begin
  FreeAndNil(fCS);
  FreeAndNil(fSocket);
  inherited;
end;

procedure TTCPClient.Disconnect;
begin
  if not Connected then exit;

    if Assigned(fReadThread) then
     begin
      fReadThread.Terminate;
      fReadThread.WaitFor;
      FreeAndNil(fReadThread);
     end;

  fCS.Enter;
  fSocket.CloseSocket;
  fCS.Leave;

  Connected := false;
  DoDisconnected;
end;

procedure TTCPClient.DoRx;
begin
  if Assigned(fRx) then
     fRx(self);
end;

procedure TTCPClient.DoTx(Data: TBytes);
begin
  if Assigned(fTx) then
     fTx(self, Data);
end;

function TTCPClient.GetConnected: boolean;
begin
  result := fConnected;
end;

function TTCPClient.GetHost: string;
begin
  result := fHost;
end;

function TTCPClient.GetPort: integer;
begin
  result := fPort;
end;

function TTCPClient.GetRcvBufLeng: Cardinal;
begin
  fCS.Enter;
  result := fRcvBufLength;
  fCS.Leave;
end;

function TTCPClient.getSocket: TTCPBlockSocket;
begin
  fCS.Enter;
  result := fSocket;
  fCS.Leave;
end;

function TTCPClient.GetRcvBuf: TBytes;
begin
  fCS.Enter;
  try
  result := fRcvBuf;
  finally
  fCS.Leave;
  end;
end;

procedure TTCPClient.SetConnected(const Value: boolean);
begin
  fConnected := Value;
end;

procedure TTCPClient.SetHost(const Value: string);
begin
  fHost := Value;
end;

procedure TTCPClient.SetPort(const Value: integer);
begin
  fPort := Value;
end;

procedure TTCPClient.SetRcvBuf(const Value: TBytes);
begin
  fCS.Enter;
  try
  //setlength(fRcvBuf, length(Value));
  move(Value[0], fRcvBuf[0], length(Value));
  fRcvBufLength := length(Value);
  finally
  fCS.Leave;
  end;
end;

end.
