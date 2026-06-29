unit uRecorderMic140v2Helper;

{ TCP-probe, имена каналов, StopScan с таймаутом команды. }

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140v2Protocol, uRecorderMic140v2Consts;

const
  MIC140v2DefaultNode = 2;

function Mic140v2TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
function Mic140v2ChannelTag(ANode, ACh: Integer): string;
function Mic140v2StopScan(ACli: TMic140v2Tcp; out AErr: string): Boolean;

implementation

uses
  SysUtils, Sockets
  {$IFDEF MSWINDOWS}, WinSock2{$ENDIF};

function Mic140v2TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
var
  addr: TSockAddrIn;
  block: u_long;
  err, errLen: LongInt;
  host: string;
  ip: u_long;
  s: TSocket;
  tv: TTimeVal;
  ws: TFDSet;
  wsa: TWSAData;
begin
  Result := False;
  host := Trim(AHost);
  if host = '' then
    Exit;
  if WSAStartup($0202, wsa) <> 0 then
    Exit;
  try
    ip := inet_addr(PChar(AnsiString(host)));
    if ip = INADDR_NONE then
      Exit;
    s := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if s = INVALID_SOCKET then
      Exit;
    try
      FillChar(addr, SizeOf(addr), 0);
      addr.sin_family := AF_INET;
      addr.sin_port := htons(APort);
      addr.sin_addr.S_addr := ip;
      block := 1;
      if ioctlsocket(s, LongInt(FIONBIO), block) <> 0 then
        Exit;
      if WinSock2.connect(s, @addr, SizeOf(addr)) = 0 then
        Exit(True);
      if WSAGetLastError <> WSAEWOULDBLOCK then
        Exit;
      FillChar(tv, SizeOf(tv), 0);
      tv.tv_sec := ATimeoutMs div 1000;
      tv.tv_usec := (ATimeoutMs mod 1000) * 1000;
      FD_ZERO(ws);
      FD_SET(s, ws);
      if WinSock2.select(0, nil, @ws, nil, @tv) <= 0 then
        Exit;
      if not FD_ISSET(s, ws) then
        Exit;
      err := -1;
      errLen := SizeOf(err);
      if getsockopt(s, SOL_SOCKET, SO_ERROR, err, errLen) <> 0 then
        Exit;
      Result := err = 0;
    finally
      closesocket(s);
    end;
  finally
    WSACleanup;
  end;
end;
{$ELSE}
var
  addr: TInetSockAddr;
  host: string;
  hostAddr: in_addr;
  s: cint;
begin
  Result := False;
  host := Trim(AHost);
  if host = '' then
    Exit;
  if not TryStrToHostAddr(AnsiString(host), hostAddr) then
    Exit;
  s := fpSocket(AF_INET, SOCK_STREAM, 0);
  if s < 0 then
    Exit;
  try
    FillChar(addr, SizeOf(addr), 0);
    addr.sin_family := AF_INET;
    addr.sin_port := ShortHostToNet(APort);
    addr.sin_addr.s_addr := HostToNet(hostAddr.s_addr);
    if fpConnect(s, @addr, SizeOf(addr)) = 0 then
      Exit(True);
  finally
    fpClose(s);
  end;
end;
{$ENDIF}

function Mic140v2ChannelTag(ANode, ACh: Integer): string;
begin
  Result := Format('MIC140-%d-%2.2d', [ANode, ACh]);
end;

function Mic140v2StopScan(ACli: TMic140v2Tcp; out AErr: string): Boolean;
begin
  Result := False;
  AErr := '';
  if ACli = nil then
    Exit;
  ACli.TimeoutMs := CMic140LegacyCommandTimeoutMs;
  Result := ACli.StopScan(AErr);
  ACli.TimeoutMs := CMic140LegacyCommandTimeoutMs;
end;

end.
