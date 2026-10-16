unit USendThread;
//Модуль описывает поток отправки данных

interface

uses
  SysUtils, SyncObjs, UCommon, WinSock, Classes, blcksock;

type
  TSendThread = class(TThread)
  private
    fBytes: array [0 .. 1023] of byte;
    fSocket: TTCPBlockSocket;
    fTx: TDataEvent;
    fCS: TCriticalSection;
    fFail: TNotifyEvent;
    fParent: pointer;
    fLength: integer;
    { Private declarations }
    procedure DoTx(data: TBytes);
    procedure DoFail;
    procedure TxSync;
  protected
    procedure Execute; override;
  public
    constructor Create(socket: TTCPBlockSocket; data: TBytes);
    constructor Create(parent: pointer; data: TBytes; leng: integer = -1);
    destructor Destroy; override;
    property OnTx: TDataEvent read fTx write fTx;
    property OnFail: TNotifyEvent read fFail write fFail;
  end;

implementation

uses uTCPClient;

{ TSendThread }
constructor TSendThread.Create(socket: TTCPBlockSocket; data: TBytes);
begin
  inherited Create(true);
  //Suspended := true;
  //setlength(fBytes, length(data));
  //fBytes := data;
  fLength := -1;
  move(data[0], fBytes[0], length(data));
  //fSocket := socket;
  fCS := TCriticalSection.Create;
end;


constructor TSendThread.Create(parent: pointer; data: TBytes; leng: integer = -1);
begin
  inherited Create(true);
  //Suspended := true;
  //setlength(fBytes, length(data));
  //fBytes := data;
  if leng > 0 then
  move(data[0], fBytes[0], leng) else
  move(data[0], fBytes[0], length(data));
  fParent := parent;
  fLength := leng;
  fCS := TCriticalSection.Create;
end;


destructor TSendThread.Destroy;
begin
  FreeAndNil(fCS);
  inherited;
end;

procedure TSendThread.DoFail;
begin
  if Assigned(fFail) then
       fFail(self);
end;

procedure TSendThread.TxSync;
begin
  DoTx(fBytes);
end;

procedure TSendThread.DoTx(data: TBytes);
begin
  if Assigned(fTx) then
    fTx(self, data);
end;

procedure TSendThread.Execute;
var
  err: integer;
begin
  //send(fSocket, fBytes[0], length(fBytes), 0);
    if fLength > 0 then
    TTCPClient(fParent).Socket.SendBuffer(@fBytes[0], fLength) else
    TTCPClient(fParent).Socket.SendBuffer(@fBytes[0], length(fBytes));
    //fSocket.SendBuffer(@fBytes, length(fBytes));
    //err := fSocket.LastError;
    err := TTCPClient(fParent).Socket.LastError;

    if err = WSAEWOULDBLOCK then
     begin
     //fSocket.ResetLastError;
     TTCPClient(fParent).Socket.ResetLastError;
     end;

     DoTx(fBytes);
     //Synchronize(TxSync);

     if (err <> 0) and (err <> WSAEWOULDBLOCK) then
     begin
     //WSAECONNRESET = 10054
     //fSocket.ResetLastError;
        TTCPClient(fParent).Socket.ResetLastError;
        DoFail;
     end;

  { Place thread code here }
end;

end.
