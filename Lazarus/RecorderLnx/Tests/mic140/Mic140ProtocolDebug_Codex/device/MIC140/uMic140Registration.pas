unit uMic140Registration;

{
  Регистрация и поиск MIC-140.
  initialization → RegisterMIC140_48 → RecorderDeviceManager.
  Search('MIC140') → FindMIC140_48 → DiscoverMIC140OnSubnet14 (255 потоков TCP probe).
}

{$mode objfpc}{$H+}

interface

procedure RegisterMIC140_48;

implementation

uses
  Classes, SysUtils,
  uRecorderDeviceManager, uMic140Device
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

{$IFDEF MSWINDOWS}
var
  gWsaData: TWSAData;
  gWsaReady: Boolean = False;
{$ENDIF}

const
  CSubnet = '192.168.14.';
  CDefaultHost = '192.168.14.155';
  CDefaultPort = 4000;

type
  TMic140DiscoveryThread = class(TThread)
  private
    fFound: Boolean;
    fHost: string;
    fPort: Integer;
    fTimeoutMs: Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; APort: Integer; ATimeoutMs: Cardinal);
    property Found: Boolean read fFound;
    property Host: string read fHost;
  end;

{ Non-blocking TCP probe: returns True if host accepts connection within timeout. }
function TcpProbe(const AHost: string; APort: Integer; ATimeoutMs: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
var
  Addr: TSockAddrIn;
  Ip: u_long;
  Sock: TSocket;
  Tv: TTimeVal;
  WSet: TFDSet;
  Err: LongInt;
  ErrLen: LongInt;
  NB: u_long;
begin
  Result := False;
  if (Trim(AHost) = '') or (APort <= 0) or (APort > High(Word)) then Exit;
  Ip := inet_addr(PChar(AnsiString(Trim(AHost))));
  if Ip = INADDR_NONE then Exit;
  Sock := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if Sock = INVALID_SOCKET then Exit;
  try
    FillChar(Addr, SizeOf(Addr), 0);
    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(Word(APort));
    Addr.sin_addr.S_addr := Ip;
    NB := 1;
    if ioctlsocket(Sock, LongInt(FIONBIO), NB) <> 0 then Exit;
    if WinSock2.connect(Sock, @Addr, SizeOf(Addr)) = 0 then Exit(True);
    if WSAGetLastError <> WSAEWOULDBLOCK then Exit;
    Tv.tv_sec := ATimeoutMs div 1000;
    Tv.tv_usec := (ATimeoutMs mod 1000) * 1000;
    FD_ZERO(WSet);
    FD_SET(Sock, WSet);
    if WinSock2.select(0, nil, @WSet, nil, @Tv) <= 0 then Exit;
    if not FD_ISSET(Sock, WSet) then Exit;
    Err := -1; ErrLen := SizeOf(Err);
    if getsockopt(Sock, SOL_SOCKET, SO_ERROR, Err, ErrLen) <> 0 then Exit;
    Result := Err = 0;
  finally
    closesocket(Sock);
  end;
end;
{$ELSE}
var
  Addr: TInetSockAddr;
  HA: in_addr;
  Sock: cint;
  Tv: TTimeVal;
  WSet: TFDSet;
  Err: LongInt;
  ErrLen: LongInt;
begin
  Result := False;
  if (Trim(AHost) = '') or (APort <= 0) or (APort > High(Word)) then Exit;
  if not TryStrToHostAddr(AnsiString(Trim(AHost)), HA) then Exit;
  Sock := fpSocket(AF_INET, SOCK_STREAM, 0);
  if Sock < 0 then Exit;
  try
    FillChar(Addr, SizeOf(Addr), 0);
    Addr.sin_family := AF_INET;
    Addr.sin_port := ShortHostToNet(Word(APort));
    Addr.sin_addr.s_addr := HostToNet(HA.s_addr);
    {$IFDEF UNIX}
    if FpFcntl(Sock, F_SetFl, FpFcntl(Sock, F_GetFl, 0) or O_NONBLOCK) <> 0 then Exit;
    {$ENDIF}
    if fpConnect(Sock, @Addr, SizeOf(Addr)) = 0 then Exit(True);
    if SocketError <> ESysEINPROGRESS then Exit;
    Tv.tv_sec := ATimeoutMs div 1000;
    Tv.tv_usec := (ATimeoutMs mod 1000) * 1000;
    fpFD_ZERO(WSet);
    fpFD_SET(Sock, WSet);
    if fpSelect(Sock + 1, nil, @WSet, nil, @Tv) <= 0 then Exit;
    if fpFD_ISSET(Sock, WSet) <> 1 then Exit;
    Err := -1; ErrLen := SizeOf(Err);
    if fpGetSockOpt(Sock, SOL_SOCKET, SO_ERROR, @Err, @ErrLen) <> 0 then Exit;
    Result := Err = 0;
  finally
    fpClose(Sock);
  end;
end;
{$ENDIF}

constructor TMic140DiscoveryThread.Create(const AHost: string; APort: Integer;
  ATimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  Start;
end;

procedure TMic140DiscoveryThread.Execute;
begin
  fFound := TcpProbe(fHost, fPort, fTimeoutMs);
end;

procedure DiscoverOnSubnet(AFoundHosts: TStrings; APort: Integer; ATimeoutMs: Cardinal);
var
  I: Integer;
  T: TMic140DiscoveryThread;
  Threads: TList;
begin
  if AFoundHosts = nil then Exit;
  AFoundHosts.Clear;
  Threads := TList.Create;
  try
    for I := 0 to 254 do
      Threads.Add(TMic140DiscoveryThread.Create(CSubnet + IntToStr(I), APort, ATimeoutMs));
    for I := 0 to Threads.Count - 1 do
    begin
      T := TMic140DiscoveryThread(Threads[I]);
      T.WaitFor;
      if T.Found and (AFoundHosts.IndexOf(T.Host) < 0) then
        AFoundHosts.Add(T.Host);
      T.Free;
    end;
  finally
    Threads.Free;
  end;
end;

function FindMIC140_48(out AResult: TRecorderDeviceSearchResult): Boolean;
var
  Hosts: TStringList;
begin
  AResult.DeviceType := 'MIC140';
  AResult.Port := CDefaultPort;
  if TcpProbe(CDefaultHost, CDefaultPort, 150) then
  begin
    AResult.Host := CDefaultHost;
    Exit(True);
  end;
  Hosts := TStringList.Create;
  try
    DiscoverOnSubnet(Hosts, CDefaultPort, 180);
    if Hosts.Count > 0 then
      AResult.Host := Hosts[0]
    else
      AResult.Host := CDefaultHost;
  finally
    Hosts.Free;
  end;
  Result := AResult.Host <> '';
end;

procedure RegisterMIC140_48;
begin
  RecorderDeviceManager.RegisterDeviceClass(
    'MIC140', 'MIC-140', 'MIC-140 recorder device stub',
    @CreateMic140Device, @FindMIC140_48);
end;

initialization
  {$IFDEF MSWINDOWS}
  gWsaReady := WSAStartup($0202, gWsaData) = 0;
  {$ENDIF}
  RegisterMIC140_48;

finalization
  {$IFDEF MSWINDOWS}
  if gWsaReady then
    WSACleanup;
  {$ENDIF}

end.
