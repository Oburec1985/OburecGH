unit uRcClient;

interface
uses
  windows, sysutils, winSock, classes, Sockets, uScktComp, uRCFunc;

// для работы необходимо установить компонент TClientSocket (Sockets, ScktComp)

type
  TMsgHeader = record
    //unsigned __int16
    leader:word;  // первые символы, д.б. "ME", 0x454D
    size:word;    // размер сообщения с учетом заголовка
    //unsigned __int8

		//	switch (hdr->code)
		//		case CODE_NOTIFY_ERRCODE: OnError(hdr);        break;
		//		case CODE_NOTIFY_STATE:   OnStateChanged(hdr); break;
		//		case CODE_NOTIFY_TIME:    OnTimeChanged(hdr);  break;
		//		case CODE_NOTIFY_FILE:    OnFileChanged(hdr);  break;
		//		default: // unknown command
		//			break;
    code:byte;    // код сообщения
    data:array [0..255] of byte; // остальные данные (длина зависит от поля size)
  end;

  TRConnection = class;
  cRegController= class;

  TRConnectionEvent  = procedure (connection:TRConnection; msg:tmsgHeader) of object;


  TRConnection = class
  public
    OnDelete:tNotifyevent;
    //IdTCPClient,,,
    s:TClientSocket;
    // путь по которому собирается писать регистратор
    curPath,
    Address,
    folder:string;
    // состояние регистратора полученное в OnReceive
    port:integer;
    state:byte;
    RC_PAN:cRegController;
  protected
    function getname:string;
    procedure setname(s:string);
  public
    property name:string read getname write setname;
    constructor create;
    destructor destroy;
  end;

  // хранит в себе список TSocketConnection
  cRegController = class(tstringlist)
  public
    OnReceive:TRConnectionEvent;
    OnCreateConnection:tnotifyevent;
  protected
    procedure doSocketCreateConnection(Sender: TObject; Socket: TCustomWinSocket);
    procedure doSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure doSocketConnecting(Sender: TObject; Socket: TCustomWinSocket);
    //TSocketErrorEvent
    procedure doSocketError(Sender: TObject;Socket:TCustomWinSocket;
                            ErrorEvent:TErrorEvent;var ErrorCode: Integer);
    //TSocketDataEvent = procedure (Sender: TObject; Buf: PAnsiChar; var DataLen: Integer)
    procedure onReceiveData(Sender: TObject; Buf: PAnsiChar; var DataLen: Integer);overload;
    procedure onReceiveData(Sender: TObject; Socket: TCustomWinSocket);overload;
  protected
    procedure cleardata;
    function getconnection(name:string):TRConnection;overload;
    function getconnection(sock:TClientSocket):TRConnection;overload;
    function getconnection(s:TCustomWinSocket):TRConnection;overload;
  public
    function getconnection(i:integer):TRConnection;overload;
    function Connected(i:integer):boolean;
    function getConnectionIndex(c:TRConnection):integer;
    function getConnectionIP(i:integer):string;
    function getConnectionFolder(i:integer):string;
    function getConnectionPath(i:integer):string;
    function getConnectionName(i:integer):string;
    function getConnectionState(i:integer):byte;
    procedure start;
    procedure stop;
    procedure Rec;
    // читаем серверы/ Вставлено в OnTimer компонента MBaseControl
    procedure read;
    // попытка подконектить отсоединенные сокеты
    procedure connect;
    function createConnection(name:string; folder:string; ip:string; port:integer):TRConnection;
    destructor destroy;override;
  end;

const
  // порты по умолчанию

  DEF_PORT_MR300 = 4500;
  DEF_PORT_RECORDER = 4510;
  DEF_PORT_VIDEOREG =  4520;

{#define PACKET_LEADER         0x454D
#define MSG_CMDSIZE           0x10
#define MSG_MINSIZE           0x10
#define MSG_MAXSIZE           0x100

#define CODE_COMMAND_STOP     0x01
#define CODE_COMMAND_VIEW     0x02
#define CODE_COMMAND_RECORD   0x03
#define CODE_COMMAND_PLAY     0x04
#define CODE_COMMAND_SETMARK  0x10
#define CODE_COMMAND_SETPATH  0x20

#define CODE_NOTIFY_ERRCODE   0x10
#define CODE_NOTIFY_TYPE      0x11
#define CODE_NOTIFY_STATE     0x12
#define CODE_NOTIFY_TIME      0x13
#define CODE_NOTIFY_FILE      0x14}
////////////////////////////////////////////
///
  PACKET_LEADER       =  $454D;
  MSG_HEADSIZE         =  5 ;
  MSG_CMDSIZE         =  $10 ;
  MSG_MINSIZE         =  $10 ;
  MSG_MAXSIZE         =  $100;

  CODE_COMMAND_STOP   =  $01;
  CODE_COMMAND_VIEW   =  $02;
  CODE_COMMAND_RECORD =  $03;
  CODE_COMMAND_PLAY   =  $04;
  CODE_COMMAND_SETMARK=  $10;
  CODE_COMMAND_SETPATH=  $20;

  CODE_NOTIFY_ERRCODE =  $10;
  CODE_NOTIFY_TYPE    =  $11;
  CODE_NOTIFY_STATE   =  $12;
  CODE_NOTIFY_TIME    =  $13;
  CODE_NOTIFY_FILE    =  $14;


  LocalHost='127.0.0.1';

  function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
  function getIPFromHost(const HostName: string): string;

implementation

{ cRegController }

procedure cRegController.cleardata;
var
  I: Integer;
  s:TRConnection;
begin
  for I := 0 to Count - 1 do
  begin
    s:=getconnection(i);
    s.OnDelete:=nil;
    s.Destroy;
  end;
  Clear;
end;



function cRegController.Connected(i: integer): boolean;
begin
  //result:=getconnection(i).s.Connected;
  result:=getconnection(i).s.Active;
end;

function cRegController.createConnection(name: string; folder:string; ip: string; port: integer): TRConnection;
begin
  result:=TRConnection.Create;
  result.RC_PAN:=self;
  result.Address:=ip;
  result.port:=port;
  result.folder:=folder;

  result.s.Host:=ip;
  result.s.Port:=port;
  result.s.OnRead:=onReceiveData;
  // происходит когда соединение установилось (после успешного Open)
  result.s.OnConnect:=doSocketCreateConnection;
  result.s.OnDisconnect:=doSocketCreateConnection;
  result.s.OnError:=doSocketError;
  result.s.Open;
  //result.s.OnConnecting:=doSocketConnecting;

  AddObject(name, result);
  //if assigned(OnCreateConnection) then
  //begin
  //  OnCreateConnection(result);
  //end;
end;

destructor cRegController.destroy;
begin
  cleardata;
  inherited;
 end;

procedure cRegController.doSocketConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
var
  c:TRConnection;
begin
  c:=getconnection(socket);
  if c<>nil then
  begin
    if not c.s.Active then
    begin

    end;
  end;
end;

procedure cRegController.doSocketCreateConnection(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if assigned(OnCreateConnection)  then
    OnCreateConnection(sender);
end;

procedure cRegController.doSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  c:TRConnection;
begin
  c:=getconnection(socket);
  if c<>nil then
  begin
    c.s.Close;
  end;
end;

procedure cRegController.doSocketError(Sender: TObject;
                                       Socket:TCustomWinSocket;
                                       ErrorEvent:TErrorEvent;
                                       var ErrorCode: Integer);
begin
  errorCode:=0;
end;

function cRegController.getConnectionIndex(c: TRConnection): integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if c=getconnection(i) then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function cRegController.getConnectionIP(i: integer): string;
var
  s:TRConnection;
begin
  s:=getconnection(i);
  result:=s.Address;
end;

function cRegController.getConnectionName(i: integer): string;
begin
  result:=Strings[i];
end;

function cRegController.getConnectionFolder(i: integer): string;
var
  con:TRConnection;
begin
  con:=getconnection(i);
  if con.name='LocalRC' then
  begin
    if not con.s.Active then
    begin
      result:=GetMeraFile;
    end;
  end
  else
  begin
    result:=con.folder;
  end;
end;


function cRegController.getConnectionPath(i: integer): string;
var
  s:TRConnection;
begin
  s:=getconnection(i);
  if s.name='LocalRC' then
  begin
    if not s.s.Active then
    begin
      result:=GetMeraFile;
      exit;
    end;
  end;
  result:=s.curPath;
end;

function cRegController.getConnectionState(i: integer): byte;
var
  s:TRConnection;
begin
  s:=getconnection(i);
  result:=s.state;
end;

procedure cRegController.onReceiveData(Sender: TObject;
  Socket: TCustomWinSocket);
var
  msg:TMsgHeader;
  c:TRConnection;
  p:pAnsiChar;
  n,DataLen:integer;
  buf:pAnsiChar;
begin
  DataLen:=Socket.ReceiveLength;
  buf:=pAnsiChar(Socket.ReceiveText);
  if TMsgHeader(pointer(buf)^).leader=PACKET_LEADER then
  begin
    n:=0;

    c:=getconnection(TClientSocket(sender));
    while (DataLen - n >= MSG_MINSIZE) do
    begin
      //MsgHeader* hdr = (MsgHeader*) &(data[n]);
      msg:= TMsgHeader ((@buf[n])^);
      if (msg.leader = PACKET_LEADER) and
         (msg.size<=DataLen - n) and
         (msg.size >= MSG_MINSIZE) and
         (msg.size <= MSG_MAXSIZE)
      then
      begin
        case (msg.code) of
          // здесь можно в теории обработать некорректный путь к замеру регистратора
          CODE_NOTIFY_ERRCODE:
          begin
            //OnError(hdr);
          end;
          CODE_NOTIFY_STATE:
          begin
            c.state:=msg.data[0];
            if c.state=CODE_COMMAND_STOP then
            begin
              if c.curpath='' then
              begin
                p:=pAnsiChar(@msg.data[0]);
                p:=p+MSG_CMDSIZE;
                c.curpath:=lpcstr(p);
              end;
            end;
            break;
          end;
          CODE_NOTIFY_TIME:
          begin
            //OnTimeChanged(hdr);
          end;
          CODE_NOTIFY_FILE:
          begin
            c.curpath:=lpcstr(@msg.data[0]);
          end;
          else // unknown command
          begin
            break;
          end;
        end;
        n:= msg.size+n;
      end
      else
        inc(n);
    end;

    if c<>nil then
    begin
      if assigned(OnReceive) then
      begin
        OnReceive(c, msg);
      end;
    end;
  end;
end;

procedure cRegController.onReceiveData(Sender: TObject; Buf: PAnsiChar; var DataLen: Integer);
var
  msg:TMsgHeader;
  c:TRConnection;
  p:pAnsiChar;
  n:integer;
begin
  if TMsgHeader(pointer(buf)^).leader=PACKET_LEADER then
  begin
    n:=0;

    c:=getconnection(TClientSocket(sender));
    while (DataLen - n >= MSG_MINSIZE) do
    begin
      //MsgHeader* hdr = (MsgHeader*) &(data[n]);
      msg:= TMsgHeader ((@buf[n])^);
      if (msg.leader = PACKET_LEADER) and
         (msg.size<=DataLen - n) and
         (msg.size >= MSG_MINSIZE) and
         (msg.size <= MSG_MAXSIZE)
      then
      begin
        case (msg.code) of
          // здесь можно в теории обработать некорректный путь к замеру регистратора
          CODE_NOTIFY_ERRCODE:
          begin
            //OnError(hdr);
          end;
          CODE_NOTIFY_STATE:
          begin
            c.state:=msg.data[0];
            if c.state=CODE_COMMAND_STOP then
            begin
              if c.curpath='' then
              begin
                p:=pAnsiChar(@msg.data[0]);
                p:=p+MSG_CMDSIZE;
                c.curpath:=lpcstr(p);
              end;
            end;
            break;
          end;
          CODE_NOTIFY_TIME:
          begin
            //OnTimeChanged(hdr);
          end;
          CODE_NOTIFY_FILE:
          begin
            c.curpath:=lpcstr(@msg.data[0]);
            break;
          end;
          else // unknown command
          begin
            break;
          end;
        end;
        n:= msg.size+n;
      end
      else
        inc(n);
    end;

    if c<>nil then
    begin
      if assigned(OnReceive) then
      begin
        OnReceive(c, msg);
      end;
    end;
  end;
end;

procedure cRegController.read;
var
  msg:TMsgHeader;
  p:pointer;
  I: Integer;
  c:TRConnection;
  buf:TMsgHeader;
  s:ansistring;
begin
  for I := 0 to Count - 1 do
  begin
    c:=getconnection(i);
    //if c.s.connected then
    //begin
    //  if c.s.WaitForData(0) then
    //  begin
    //    c.s.ReceiveBuf(buf, MSG_MAXSIZE, 0);
    //  end;
    //end;
  end;
end;

procedure cRegController.connect;
var
  I: Integer;
  c:TRConnection;
  readready, writeReady, exceptFlag:boolean;
begin
  for I := 0 to Count - 1 do
  begin
    c:=getconnection(i);
    if not c.s.Active then
    begin
      c.s.Open;
    end;
  end
end;

procedure cRegController.Rec;
var
  I: Integer;
  c:TRConnection;
  buf:TMsgHeader;
begin
  buf.leader:=PACKET_LEADER;
  buf.size:=MSG_CMDSIZE;
  //buf.code:=CODE_NOTIFY_STATE;
  buf.code:=CODE_COMMAND_RECORD;
  for I := 0 to Count - 1 do
  begin
    c:=getconnection(i);
    c.s.Socket.SendBuf(buf,buf.size);
  end;
end;

procedure cRegController.start;
var
  I: Integer;
  c:TRConnection;
  buf:TMsgHeader;
begin
  buf.leader:=PACKET_LEADER;
  buf.size:=MSG_CMDSIZE;
  buf.code:=CODE_COMMAND_VIEW;
  for I := 0 to Count - 1 do
  begin
    c:=getconnection(i);
    c.s.Socket.SendBuf(buf,buf.size);
  end;
end;

procedure cRegController.stop;
var
  I: Integer;
  c:TRConnection;
  buf:TMsgHeader;
begin
  buf.leader:=PACKET_LEADER;
  buf.size:=MSG_CMDSIZE;
  //buf.code:=CODE_NOTIFY_STATE;
  buf.code:=CODE_COMMAND_STOP;
  for I := 0 to Count - 1 do
  begin
    c:=getconnection(i);
    //c.s.SendBuf(buf,buf.size,0);
    c.s.Socket.SendBuf(buf,buf.size);
  end;
end;

function cRegController.getconnection(i: integer): TRConnection;
begin
  result:=TRConnection(objects[i]);
end;

function cRegController.getconnection(s:TCustomWinSocket):TRConnection;
var
  I: Integer;
  c:TRConnection;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    c:=getconnection(i);
    if c.s.Socket=s then
    begin
      result:=c;
      exit;
    end;
  end;
end;

function cRegController.getconnection(name: string): TRConnection;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    if strings[i]=name then
    begin
      result:=getconnection(i);
      exit;
    end;
  end;
end;

function cRegController.getconnection(sock: TClientSocket): TRConnection;
var
  I: Integer;
  c:TRConnection;
begin
  result:=nil;
  for I := 0 to count - 1 do
  begin
    c:=getconnection(i);
    if c.s=sock then
    begin
      result:=getconnection(i);
      exit;
    end;
  end;
end;

function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
var
 pCurChar: ^byte;
 prevChar: byte;
 i, dotCount, digitCount: integer;
 x: longword;
begin
 if strIP <> '' then
 begin
   uintIP := 0;
   x := 0;
   dotCount := 0;
   pCurChar := @strIP[1];
   digitCount := 0;
   prevChar := ord('.');
   for i := length(strIP)-1 downto 0 do
   begin
     if (pCurChar^ >= ord('0')) and (pCurChar^ <= ord('9')) then
     begin
       if digitCount = 3 then break;
       x := x*10 + pCurChar^ - ord('0');
       if x > 255 then break;
       if i = 0 then
       begin
         if dotCount <> 3 then break;
         uintIP := uintIP shl 8 + x;
         Result := true;
         exit;
       end;
       inc(digitCount);
     end
     else if pCurChar^ = ord('.') then
     begin
       if (dotCount = 3) or (prevChar = pCurChar^) then break;
       inc(dotCount);
       uintIP := uintIP shl 8 + x;
       x := 0;
       digitCount := 0;
     end
     else break;
     prevChar := pCurChar^;
     inc(pCurChar);
   end;
 end;
 Result := false;
 uintIP := 0;
end;

function getIPFromHost(const HostName: string): string;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  i: Integer;
  GInitData: TWSAData;
begin
  //gethostbyname();
  WSAStartup($101, GInitData);
  Result := '';
  phe := GetHostByName(PAnsiChar(HostName));
  if phe = nil then Exit;
  pPtr := PaPInAddr(phe^.h_addr_list);
  i := 0;
  while pPtr^[i] <> nil do
  begin
    Result := inet_ntoa(pptr^[i]^);
    Inc(i);
  end;
  WSACleanup;
end;



{ TRConnection }

constructor TRConnection.create;
begin
  //s:=TTcpClient.Create(nil);
  s:=TClientSocket.Create(nil);
end;

destructor TRConnection.destroy;
begin
  if assigned(OnDelete) then
    OnDelete(self);
  s.Destroy;
  s:=nil;
end;


function TRConnection.getname: string;
var
  I: Integer;
begin
  result:='';
  for I := 0 to RC_PAN.Count - 1 do
  begin
    if self=RC_PAN.getconnection(i) then
    begin
      result:=RC_PAN.getConnectionName(i);
      exit;
    end;
  end;
end;

procedure TRConnection.setname(s: string);
var
  I: Integer;
begin
  i:=RC_PAN.getConnectionIndex(self);
  RC_PAN.Delete(i);
  RC_PAN.AddObject(s,self);
end;

end.
